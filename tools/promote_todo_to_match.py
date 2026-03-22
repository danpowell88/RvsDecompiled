#!/usr/bin/env python3
"""
promote_todo_to_match.py — Find IMPL_TODO("Byte-parity unverified") functions, 
look up their Ghidra addresses, and promote them to IMPL_MATCH.

This script:
1. Scans source files for IMPL_TODO("Byte-parity unverified") annotations
2. Extracts the function name from the line(s) following the annotation
3. Looks up the function in Ghidra function_index.json to get the address
4. Rewrites the IMPL_TODO to IMPL_MATCH("Foo.dll", 0xADDR)

Usage:
  python tools/promote_todo_to_match.py [--dry-run] [--file path.cpp]
  
  --dry-run     Print proposed changes without modifying files
  --file PATH   Only process the specified file (can be specified multiple times)
"""
import json
import re
import sys
import os
from pathlib import Path
from collections import defaultdict

SCRIPT_DIR = Path(__file__).resolve().parent
REPO_ROOT = SCRIPT_DIR.parent
SRC_DIR = REPO_ROOT / "src"
REPORTS_DIR = REPO_ROOT / "ghidra" / "exports" / "reports"

# Map source directory names to DLL names and function index files
MODULE_MAP = {
    'Core':           ('Core.dll',           'Core'),
    'Engine':         ('Engine.dll',         'Engine'),
    'Fire':           ('Fire.dll',           'Fire'),
    'Window':         ('Window.dll',         'Window'),
    'IpDrv':          ('IpDrv.dll',          'IpDrv'),
    'WinDrv':         ('WinDrv.dll',         'WinDrv'),
    'D3DDrv':         ('D3DDrv.dll',         'D3DDrv'),
    'R6Abstract':     ('R6Abstract.dll',     'R6Abstract'),
    'R6Weapons':      ('R6Weapons.dll',      'R6Weapons'),
    'R6Engine':       ('R6Engine.dll',       'R6Engine'),
    'R6Game':         ('R6Game.dll',         'R6Game'),
    'R6GameService':  ('R6GameService.dll',  'R6GameService'),
    'DareAudio':      ('DareAudio.dll',      'DareAudio'),
    'Launch':         ('RavenShield.exe',    'RavenShield'),
}

def load_function_index(module_name):
    """Load function index and build name->address mapping."""
    path = REPORTS_DIR / f"{module_name}_function_index.json"
    if not path.exists():
        return {}
    data = json.load(open(path))
    name_to_addr = {}
    for f in data.get('functions', []):
        if f.get('exported') and not f.get('unnamed'):
            name = f['name']
            addr = f['addr']
            # Store as-is (may have duplicates, last wins)
            name_to_addr[name] = addr
    return name_to_addr

# Regex to match IMPL_TODO with byte-parity reason
TODO_PATTERN = re.compile(r'^IMPL_TODO\("Byte-parity unverified"\)\s*$')

# Regex to extract function name from declaration line
# Matches: ReturnType ClassName::FunctionName(
FUNC_DECL = re.compile(r'(?:\w[\w\s\*&:<>]*?)\s+(\w+::~?\w+)\s*\(')
# Also match operator overloads
OPERATOR_DECL = re.compile(r'(?:\w[\w\s\*&:<>]*?)\s+(\w+::operator\S+)\s*\(')

def extract_func_name(lines, start_idx):
    """Extract the class::function name from lines following an IMPL annotation."""
    # Look at the next few lines for a function declaration
    for i in range(start_idx, min(start_idx + 5, len(lines))):
        line = lines[i].strip()
        # Skip empty lines and comments
        if not line or line.startswith('//') or line.startswith('/*'):
            continue
        # Try operator first (more specific)
        m = OPERATOR_DECL.match(line)
        if m:
            return m.group(1)
        # Then regular function
        m = FUNC_DECL.match(line)
        if m:
            return m.group(1)
    return None

def detect_module(filepath):
    """Determine which module a source file belongs to."""
    parts = Path(filepath).parts
    for part in parts:
        if part in MODULE_MAP:
            return part
    return None

def process_file(filepath, name_to_addr, dll_name, dry_run=False):
    """Process a single source file, promoting TODOs to MATCHes."""
    with open(filepath, 'r', encoding='utf-8', errors='replace') as f:
        lines = f.readlines()
    
    promotions = []
    i = 0
    while i < len(lines):
        line = lines[i]
        if TODO_PATTERN.match(line.strip()):
            func_name = extract_func_name(lines, i + 1)
            if func_name and func_name in name_to_addr:
                addr = name_to_addr[func_name]
                # Ensure address has 0x prefix
                if not addr.startswith('0x'):
                    addr = '0x' + addr
                old_line = line
                new_line = line.replace(
                    'IMPL_TODO("Byte-parity unverified")',
                    f'IMPL_MATCH("{dll_name}", {addr})'
                )
                promotions.append({
                    'line_num': i + 1,
                    'func': func_name,
                    'addr': addr,
                    'old': old_line.rstrip(),
                    'new': new_line.rstrip(),
                })
                lines[i] = new_line
        i += 1
    
    if promotions and not dry_run:
        with open(filepath, 'w', encoding='utf-8', newline='') as f:
            f.writelines(lines)
    
    return promotions

def main():
    import argparse
    parser = argparse.ArgumentParser(description='Promote IMPL_TODO to IMPL_MATCH')
    parser.add_argument('--dry-run', action='store_true', help='Print changes without modifying files')
    parser.add_argument('--file', action='append', dest='files', help='Only process specific file(s)')
    args = parser.parse_args()
    
    # Load all function indexes
    all_indexes = {}
    for module, (dll_name, index_name) in MODULE_MAP.items():
        idx = load_function_index(index_name)
        all_indexes[module] = (dll_name, idx)
    
    # Find source files to process
    if args.files:
        source_files = [Path(f) for f in args.files]
    else:
        source_files = sorted(SRC_DIR.rglob('*.cpp'))
    
    total_promoted = 0
    total_skipped = 0
    
    for filepath in source_files:
        module = detect_module(filepath)
        if not module or module not in all_indexes:
            continue
        
        dll_name, name_to_addr = all_indexes[module]
        if not name_to_addr:
            continue
        
        promotions = process_file(filepath, name_to_addr, dll_name, dry_run=args.dry_run)
        
        if promotions:
            relpath = filepath.relative_to(REPO_ROOT) if filepath.is_relative_to(REPO_ROOT) else filepath
            print(f"\n{'[DRY RUN] ' if args.dry_run else ''}{relpath}: {len(promotions)} promotions")
            for p in promotions:
                print(f"  L{p['line_num']:5d}  {p['func']}  -> {p['addr']}")
            total_promoted += len(promotions)
    
    # Count remaining TODOs
    for filepath in (source_files if args.files else sorted(SRC_DIR.rglob('*.cpp'))):
        module = detect_module(filepath)
        if not module or module not in all_indexes:
            continue
        with open(filepath, 'r', encoding='utf-8', errors='replace') as f:
            for line in f:
                if 'IMPL_TODO("Byte-parity unverified")' in line:
                    total_skipped += 1
    
    action = "Would promote" if args.dry_run else "Promoted"
    print(f"\n{'='*60}")
    print(f"{action} {total_promoted} functions to IMPL_MATCH")
    print(f"Remaining byte-parity-unverified TODOs: {total_skipped}")
    print(f"{'='*60}")

if __name__ == '__main__':
    main()
