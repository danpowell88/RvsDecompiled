#!/usr/bin/env python3
"""
annotate_impl.py — Insert IMPL_xxx macros before every unannotated
function definition in Ravenshield .cpp files.

Safe: insert-only, never removes or modifies existing lines.
Uses brace-depth tracking to find top-level function definitions only.
"""

import re
import sys
import os
from pathlib import Path

REPO_ROOT = Path(__file__).parent.parent

# ---------------------------------------------------------------------------
# Regex patterns
# ---------------------------------------------------------------------------

# Matches an existing IMPL_ macro line
RE_IMPL = re.compile(r'^\s*IMPL_\w+\s*\(')

# Macros to skip (not function definitions)
RE_SKIP_MACRO = re.compile(r'^\s*(?:IMPLEMENT_|DECLARE_|DEFINE_|EXEC_STUB|#)')

# Karma-related identifiers
RE_KARMA = re.compile(
    r'physKarma|getKConstraint|getKModel|KUpdate|KActor|KConstraint|KConeLimit'
    r'|R6MP2IOKarma|KarmaSupport',
    re.IGNORECASE
)

# Ghidra address in comments
RE_GHIDRA_ADDR = re.compile(
    r'(?:Ghidra|ghidra)\s+(0x[0-9a-fA-F]+)'
    r'|(?:^|\s)FUN_(1[0-9a-fA-F]{7})'
    r'|@\s*(0x[0-9a-fA-F]{5,})'
)

# ---------------------------------------------------------------------------
# DLL name lookup
# ---------------------------------------------------------------------------

def get_dll(filepath: Path) -> str:
    path_str = str(filepath).replace('\\', '/')
    if '/R6GameService/' in path_str: return 'R6GameService.dll'
    if '/R6Abstract/'   in path_str: return 'R6Abstract.dll'
    if '/R6Weapons/'    in path_str: return 'R6Weapons.dll'
    if '/R6Engine/'     in path_str: return 'R6Engine.dll'
    if '/R6Game/'       in path_str: return 'R6Game.dll'
    if '/DareAudio/'    in path_str: return 'DareAudio.dll'
    if '/SNDDSound3D/'  in path_str: return 'SNDDSound3D.dll'
    if '/Launch/'       in path_str: return 'Launch.exe'
    if '/D3DDrv/'       in path_str: return 'D3DDrv.dll'
    if '/WinDrv/'       in path_str: return 'WinDrv.dll'
    if '/Window/'       in path_str: return 'Window.dll'
    if '/IpDrv/'        in path_str: return 'IpDrv.dll'
    if '/Fire/'         in path_str: return 'Fire.dll'
    if '/Engine/'       in path_str: return 'Engine.dll'
    if '/Core/'         in path_str: return 'Core.dll'
    return 'Unknown.dll'


# ---------------------------------------------------------------------------
# Determine appropriate IMPL macro for a function
# ---------------------------------------------------------------------------

def is_empty_stub(body_lines: list) -> bool:
    """True if function body has no meaningful logic (just guard/unguard, return 0)."""
    for line in body_lines:
        s = line.strip()
        if not s or s in ('{', '}'):
            continue
        if s.startswith('//') or s.startswith('/*') or s.startswith('*'):
            continue
        if re.match(r'^guard\s*\(', s) or s in ('unguard;', 'unguard'):
            continue
        if re.match(r'^return\s+(0|NULL|nullptr|false|FALSE)\s*;', s):
            continue
        if re.match(r'^return\s*;', s):
            continue
        return False  # has meaningful code
    return True


def find_ghidra_in_context(all_lines: list, func_line: int) -> tuple:
    """
    Search for a Ghidra address in comments near the function.
    Returns (addr_str, found_in_body) or (None, False).
    """
    # Look in lines before the function (up to 10 lines back)
    start = max(0, func_line - 10)
    for i in range(func_line - 1, start - 1, -1):
        m = RE_GHIDRA_ADDR.search(all_lines[i])
        if m:
            addr = m.group(1) or ('0x' + m.group(2)) if m.group(2) else m.group(3)
            return addr, False
    
    # Look in lines after the function (body context, up to 20 lines)
    end = min(len(all_lines), func_line + 20)
    for i in range(func_line, end):
        m = RE_GHIDRA_ADDR.search(all_lines[i])
        if m:
            addr = m.group(1) or ('0x' + m.group(2)) if m.group(2) else m.group(3)
            return addr, True
    
    return None, False


def choose_macro(filepath: Path, all_lines: list, func_start: int, body_lines: list, func_name: str) -> str:
    dll = get_dll(filepath)
    fname = filepath.name
    
    # NullDrv: all functions intentionally empty
    if 'NullDrv' in fname:
        return 'IMPL_INTENTIONALLY_EMPTY("NullDrv — headless renderer; retail body is also empty")'
    
    # Karma physics
    if 'Karma' in fname or RE_KARMA.search(func_name):
        if 'R6MP2IOKarma' in fname:
            return 'IMPL_PERMANENT_DIVERGENCE("Karma physics integration — MathEngine SDK proprietary; source unavailable")'
        return 'IMPL_PERMANENT_DIVERGENCE("Karma physics — MathEngine SDK proprietary; source unavailable")'
    
    # Find Ghidra address
    addr, in_body = find_ghidra_in_context(all_lines, func_start)
    
    if addr:
        if is_empty_stub(body_lines):
            return 'IMPL_TODO("Needs Ghidra analysis")'
        if in_body:
            return f'IMPL_GHIDRA_APPROX("{dll}", {addr}, "Ghidra reference; body approximated")'
        return f'IMPL_GHIDRA("{dll}", {addr})'
    
    # No Ghidra address
    if is_empty_stub(body_lines):
        return 'IMPL_TODO("Needs Ghidra analysis")'
    
    return 'IMPL_INFERRED("Reconstructed from context")'


# ---------------------------------------------------------------------------
# Core annotation logic with brace-depth tracking
# ---------------------------------------------------------------------------

def process_file(filepath: Path, dry_run: bool = False) -> dict:
    """
    Annotate all top-level function definitions in a .cpp file.
    Insert-only: never removes existing lines.
    """
    try:
        raw = filepath.read_bytes()
        # Detect encoding (most files are UTF-8 or Latin-1)
        try:
            content = raw.decode('utf-8')
        except UnicodeDecodeError:
            content = raw.decode('latin-1')
    except Exception as e:
        return {'error': str(e)}

    lines = content.splitlines()
    n = len(lines)
    
    # Collect insertions: list of (line_idx, macro_str)
    insertions = []
    
    # State
    brace_depth = 0
    in_block_comment = False
    
    i = 0
    while i < n:
        raw_line = lines[i]
        stripped = raw_line.strip()
        
        # ---- Handle block comments ----
        if in_block_comment:
            if '*/' in stripped:
                in_block_comment = False
            i += 1
            continue
        
        if stripped.startswith('/*') and '*/' not in stripped:
            in_block_comment = True
            # Count braces in this line still
        
        # ---- Count braces (outside string literals - simplified) ----
        # We do a simple character scan, ignoring string contents
        line_depth_change = 0
        in_str = False
        in_char = False
        j = 0
        while j < len(raw_line):
            c = raw_line[j]
            if in_str:
                if c == '\\': j += 1  # skip escaped char
                elif c == '"': in_str = False
            elif in_char:
                if c == '\\': j += 1
                elif c == "'": in_char = False
            elif c == '"':
                in_str = True
            elif c == "'":
                in_char = True
            elif c == '{':
                line_depth_change += 1
            elif c == '}':
                line_depth_change -= 1
            elif c == '/' and j + 1 < len(raw_line) and raw_line[j+1] == '/':
                break  # rest of line is comment
            j += 1
        
        # ---- Only look for function definitions at brace_depth == 0 ----
        if brace_depth == 0 and not stripped.startswith('//') and not stripped.startswith('/*'):
            # Skip preprocessor, macros, class/struct/namespace declarations
            if not stripped.startswith('#') and not RE_SKIP_MACRO.match(stripped):
                # Check if this could be the START of a function definition
                # Detect the function signature: look for `{` starting from this line
                func_info = try_parse_function_def(lines, i, brace_depth)
                if func_info:
                    func_start, func_sig_end, func_body_start = func_info
                    
                    # Check if already annotated
                    if not already_annotated(lines, func_start):
                        # Get the body for analysis
                        body = extract_body(lines, func_body_start)
                        func_name = extract_name(lines, func_start, func_sig_end)
                        
                        macro = choose_macro(filepath, lines, func_start, body, func_name)
                        
                        # Get indentation of function line
                        indent = ''
                        for ch in lines[func_start]:
                            if ch in (' ', '\t'):
                                indent += ch
                            else:
                                break
                        
                        insertions.append((func_start, indent + macro))
                        
                        if dry_run:
                            print(f"  L{func_start+1}: {macro[:70]} -> {func_name}")
        
        brace_depth += line_depth_change
        if brace_depth < 0:
            brace_depth = 0  # guard against malformed files
        i += 1
    
    stats = {'total': len(insertions), 'already': 0}
    
    if not dry_run and insertions:
        # Sort insertions in REVERSE order to preserve line indices
        insertions.sort(key=lambda x: x[0], reverse=True)
        for line_idx, macro_str in insertions:
            lines.insert(line_idx, macro_str)
        
        # Write back
        new_content = '\n'.join(lines)
        if content.endswith('\n'):
            new_content += '\n'
        try:
            filepath.write_text(new_content, encoding='utf-8')
        except Exception as e:
            return {'error': str(e), 'total': len(insertions)}
    
    return stats


def try_parse_function_def(lines: list, start_idx: int, current_depth: int):
    """
    Try to parse a function definition starting at lines[start_idx].
    
    Returns (func_start, sig_end, body_start) if this is a function definition,
    where:
      func_start   = line index of the return type / function name
      sig_end      = last line of the parameter list
      body_start   = line index of '{'
    
    Returns None if not a function definition.
    """
    n = len(lines)
    stripped = lines[start_idx].strip()
    
    # Quick pre-filter: must contain certain patterns
    # Must have ( and must not be control flow or macros
    if '(' not in stripped:
        return None
    
    # Not control flow
    if re.match(r'^(?:if|else|for|while|do|switch|catch|try|return)\b', stripped):
        return None
    
    # Not a declaration ending with ;
    if stripped.endswith(';'):
        return None
    
    # Not an existing IMPL_ macro (they look like function calls but aren't)
    if RE_IMPL.match(stripped):
        return None
    
    # Not a skip macro
    if RE_SKIP_MACRO.match(stripped):
        return None
    
    # Not an initializer list entry (starts with : or ,)
    if stripped.startswith(':') or stripped.startswith(','):
        return None
    
    # Not a function CALL (heuristic: lines with = before ( are assignments/calls)
    # Not a class/struct/namespace definition
    if re.match(r'^(?:class|struct|namespace|template|extern|typedef|enum|union)\b', stripped):
        return None
    
    # For lines without ::, must have something like a return type
    # We'll be more permissive and check the context
    
    # Find the end of the parameter list and check what follows
    # Walk forward until we find ) followed by { (with possible :, const, etc.)
    
    sig_end = start_idx
    paren_depth = 0
    found_open_paren = False
    
    for j in range(start_idx, min(n, start_idx + 8)):
        line = lines[j].strip()
        
        # Skip comments
        if line.startswith('//') or line.startswith('/*'):
            continue
        
        for ch in lines[j]:
            if ch == '(':
                paren_depth += 1
                found_open_paren = True
            elif ch == ')':
                paren_depth -= 1
            elif ch == ';' and paren_depth == 0 and found_open_paren:
                # It's a declaration, not definition
                return None
            elif ch == '{' and paren_depth == 0 and found_open_paren:
                # Found the opening brace on this line
                return (start_idx, j, j)
        
        if found_open_paren and paren_depth == 0:
            sig_end = j
            break
    
    if not found_open_paren or paren_depth != 0:
        return None
    
    # Now look for { after the param list (might be on next line, 
    # or after initializer list :)
    for j in range(sig_end, min(n, sig_end + 6)):
        line = lines[j].strip()
        if line.startswith('//') or line.startswith('/*'):
            continue
        if '{' in line:
            # But also check it's not an array initializer or something
            # If we're here, we've found the brace
            return (start_idx, sig_end, j)
        # If it's = 0 or ; this is a declaration/pure virtual
        if line.endswith(';') or '= 0' in line:
            return None
        # A line starting with : is an initializer list (OK, keep going)
        if line.startswith(':'):
            continue
        # A line that isn't {, :, or comment... hmm, might be next function
        # If it looks like another function signature, stop
        if re.match(r'^\w', line) and '(' in line and '{' not in line and not line.startswith(':'):
            # This might be a function definition following - stop
            # But only if we've seen the paren close
            pass
    
    return None


def already_annotated(lines: list, func_start: int) -> bool:
    """Check if there's already an IMPL_ macro immediately before func_start.
    Looks back up to 15 lines to handle multi-line IMPL_GHIDRA_APPROX macros.
    """
    for j in range(func_start - 1, max(-1, func_start - 15), -1):
        s = lines[j].strip()
        if not s:
            continue
        # Check if this line or any nearby line is an IMPL_ macro
        if RE_IMPL.match(s):
            return True
        # Also check if we're inside a multi-line IMPL_ macro (continuation line)
        # A line ending with ) could be the end of a multi-line IMPL_ call
        if s.endswith(')'):
            # Look further back to see if there's an IMPL_ that starts the macro
            for k in range(j - 1, max(-1, j - 10), -1):
                sk = lines[k].strip()
                if RE_IMPL.match(sk):
                    return True
                if not sk or sk.startswith('"') or sk.startswith('//'):
                    continue
                break
        # Hit a non-blank, non-IMPL, non-continuation line
        # (but continue looking in case of blank lines between)
        if s and not s.startswith('"') and not s.endswith(',') and not s.endswith('('):
            # If it's not obviously a continuation of an IMPL call, stop
            if not RE_IMPL.match(s):
                break
    return False


def extract_body(lines: list, body_start: int, max_lines: int = 40) -> list:
    """Extract function body lines for analysis."""
    body = []
    depth = 0
    found = False
    
    for i in range(body_start, min(len(lines), body_start + max_lines)):
        line = lines[i]
        for ch in line:
            if ch == '{':
                depth += 1
                found = True
            elif ch == '}':
                depth -= 1
        body.append(line.strip())
        if found and depth == 0:
            break
    
    return body


def extract_name(lines: list, start: int, end: int) -> str:
    """Extract function name from signature lines."""
    sig = ' '.join(lines[start:end+1])
    # Look for Class::Name pattern
    m = re.search(r'([\w~<>]+::[\w~<>]+)\s*\(', sig)
    if m:
        return m.group(1)
    # Look for operator
    m = re.search(r'(operator\s*[^\s(]+)\s*\(', sig)
    if m:
        return m.group(1).strip()
    # Generic name extraction
    m = re.search(r'(\w+)\s*\(', sig)
    if m:
        return m.group(1)
    return 'unknown'


# ---------------------------------------------------------------------------
# Module definitions
# ---------------------------------------------------------------------------

MODULES = {
    'Core':         'src/Core/Src',
    'Engine':       'src/Engine/Src',
    'Fire':         'src/Fire/Src',
    'IpDrv':        'src/IpDrv/Src',
    'WinDrv':       'src/WinDrv/Src',
    'Window':       'src/Window/Src',
    'D3DDrv':       'src/D3DDrv/Src',
    'R6Abstract':   'src/R6Abstract/Src',
    'R6Engine':     'src/R6Engine/Src',
    'R6Game':       'src/R6Game/Src',
    'R6GameService':'src/R6GameService/Src',
    'SNDDSound3D':  'src/SNDDSound3D/Src',
    'DareAudio':    'src/DareAudio/Src',
    'Launch':       'src/Launch/Src',
    'R6Weapons':    'src/R6Weapons/Src',
}


def main():
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument('files', nargs='*', help='.cpp files to process')
    parser.add_argument('--module', '-m', help='Module name')
    parser.add_argument('--all', '-a', action='store_true')
    parser.add_argument('--dry-run', '-n', action='store_true')
    args = parser.parse_args()
    
    files = []
    if args.files:
        files = [Path(f) for f in args.files]
    elif args.module:
        if args.module not in MODULES:
            print(f"Unknown module: {args.module}. Available: {', '.join(MODULES)}")
            sys.exit(1)
        files = sorted((REPO_ROOT / MODULES[args.module]).glob('*.cpp'))
    elif args.all:
        for mod, rel in MODULES.items():
            files += sorted((REPO_ROOT / rel).glob('*.cpp'))
    else:
        parser.print_help(); sys.exit(1)
    
    total_added = 0
    for f in files:
        if not f.exists():
            print(f"WARNING: {f} not found"); continue
        print(f"\n=== {f.name} ===")
        s = process_file(f, dry_run=args.dry_run)
        if 'error' in s:
            print(f"  ERROR: {s['error']}")
        else:
            print(f"  Added: {s['total']}")
            total_added += s['total']
    
    print(f"\nTotal added: {total_added}")


if __name__ == '__main__':
    main()
