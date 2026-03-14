#!/usr/bin/env python3
"""
analyze_impl_approx.py  – resolve IMPL_APPROX macros for the three Engine files.

For each IMPL_APPROX occurrence, look up the function in the Ghidra export and
print whether it should become IMPL_MATCH / IMPL_EMPTY / IMPL_DIVERGE, together
with the VA so the caller can apply the change.
"""

import re
import sys

# ---------------------------------------------------------------------------
# Load Ghidra exports once.
# ---------------------------------------------------------------------------
print("[*] Loading Ghidra global.cpp ...", flush=True)
with open("ghidra/exports/Engine/_global.cpp", "r", encoding="utf-8", errors="replace") as f:
    GHIDRA_LINES = f.readlines()
print(f"    {len(GHIDRA_LINES)} lines loaded", flush=True)

def search_ghidra_function(class_name: str, func_name: str) -> dict | None:
    """
    Find a function definition in the Ghidra export.
    Returns {'va': hex_string, 'body_lines': [str]} or None.
    """
    # Pattern: __thiscall <ClassName>::<FuncName>(
    pattern = re.compile(
        r"__thiscall\s+" + re.escape(class_name) + r"::" + re.escape(func_name) + r"\s*\(",
        re.IGNORECASE,
    )
    match_line = None
    for i, line in enumerate(GHIDRA_LINES):
        if pattern.search(line):
            match_line = i
            break
    if match_line is None:
        return None

    # Collect lines from the function definition up to (and including) its closing }
    # and the Address: comment that comes after.
    body = []
    brace_depth = 0
    started = False
    va = None
    for i in range(match_line, min(match_line + 300, len(GHIDRA_LINES))):
        line = GHIDRA_LINES[i]
        body.append(line)
        # Look for VA comment: /* 0x... NNNN ?...func... */
        va_match = re.search(r'/\*\s*(0x[0-9a-fA-F]+)\s+\d+\s+\?', line)
        if va_match:
            va = va_match.group(1)
        brace_depth += line.count("{") - line.count("}")
        if "{" in line:
            started = True
        if started and brace_depth <= 0:
            # Collect the Address: comment if present immediately after closing }
            for j in range(i + 1, min(i + 5, len(GHIDRA_LINES))):
                extra = GHIDRA_LINES[j]
                body.append(extra)
                va_m = re.search(r'//\s*Address:\s*([0-9a-fA-F]+)', extra)
                if va_m:
                    va = "0x" + va_m.group(1)
                if extra.strip():
                    break
            break

    return {"va": va, "body_lines": body}


def is_trivial_body(body_lines: list[str]) -> bool:
    """Return True if the Ghidra function body is trivial (empty, just return, etc.)."""
    code = " ".join(l.strip() for l in body_lines if l.strip())
    # Strip the function signature line and braces.
    # Look for things like: { return; } or { } or { return 0; } etc.
    # Remove comments
    code = re.sub(r'/\*.*?\*/', '', code)
    code = re.sub(r'//[^\n]*', '', code)
    # Get just the function body between first { and last }
    m = re.search(r'\{(.*)\}', code, re.DOTALL)
    if not m:
        return False
    inner = m.group(1).strip()
    # Trivial if empty or only a return statement
    trivial_patterns = [
        r'^\s*$',
        r'^return\s*;$',
        r'^return\s+[^;]+;\s*$',
    ]
    for tp in trivial_patterns:
        if re.match(tp, inner):
            return True
    return False


# ---------------------------------------------------------------------------
# Parse source file to extract IMPL_APPROX occurrences.
# Returns list of (line_no, reason, func_signature, func_body)
# ---------------------------------------------------------------------------
def extract_impl_approx(filename: str) -> list[dict]:
    with open(filename, "r", encoding="utf-8-sig") as f:
        lines = f.readlines()

    results = []
    i = 0
    while i < len(lines):
        line = lines[i]
        if "IMPL_APPROX" not in line:
            i += 1
            continue

        reason_match = re.search(r'IMPL_APPROX\("([^"]+)"\)', line)
        reason = reason_match.group(1) if reason_match else ""

        # Next non-empty line should be the function signature
        j = i + 1
        while j < len(lines) and not lines[j].strip():
            j += 1

        sig_line = lines[j].rstrip() if j < len(lines) else ""
        # Extract class and function name from signature
        # Patterns: void ClassName::FuncName(   or   RetType ClassName::FuncName(
        class_func_match = re.search(r'(\w+)::(\w+)\s*\(', sig_line)
        if not class_func_match:
            # Try constructor/destructor pattern on next few lines
            for k in range(j, min(j + 3, len(lines))):
                class_func_match = re.search(r'(\w+)::(\w+)\s*\(', lines[k])
                if class_func_match:
                    sig_line = lines[k].rstrip()
                    break

        if class_func_match:
            class_name = class_func_match.group(1)
            func_name = class_func_match.group(2)
        else:
            class_name = ""
            func_name = ""

        results.append({
            "line_no": i + 1,
            "reason": reason,
            "sig": sig_line.strip(),
            "class_name": class_name,
            "func_name": func_name,
        })
        i = j + 1

    return results


# ---------------------------------------------------------------------------
# Main analysis
# ---------------------------------------------------------------------------
SOURCE_FILES = [
    "src/Engine/Src/UnLevel.cpp",
    "src/Engine/Src/UnMaterial.cpp",
    "src/Engine/Src/UnModel.cpp",
]

for src_file in SOURCE_FILES:
    print(f"\n{'='*70}")
    print(f"FILE: {src_file}")
    print(f"{'='*70}")
    items = extract_impl_approx(src_file)
    print(f"Found {len(items)} IMPL_APPROX occurrences\n")

    for item in items:
        line_no = item["line_no"]
        class_name = item["class_name"]
        func_name = item["func_name"]
        sig = item["sig"]
        reason = item["reason"]

        if not class_name or not func_name:
            print(f"  Line {line_no:5d}: ??? COULD NOT PARSE --- {sig[:60]}")
            continue

        ghidra = search_ghidra_function(class_name, func_name)
        if ghidra is None:
            va_str = "NOT FOUND"
            suggestion = "IMPL_DIVERGE (no Ghidra match)"
        else:
            va = ghidra["va"] or "VA_UNKNOWN"
            # Ensure we have 0x prefix and uppercase for the full address
            if va and va != "VA_UNKNOWN":
                if va.startswith("0x") or va.startswith("0X"):
                    va_hex = va[2:]
                else:
                    va_hex = va
                # Ghidra shows RVA (relative), retail base is 0x10000000
                va_str = f"0x{va_hex.upper()}"
            else:
                va_str = "VA_UNKNOWN"
            body = "".join(ghidra["body_lines"])
            trivial = is_trivial_body(ghidra["body_lines"])
            if trivial:
                suggestion = f"IMPL_EMPTY or IMPL_MATCH({va_str})"
            else:
                suggestion = f"IMPL_MATCH(\"Engine.dll\", {va_str})"
        
        print(f"  Line {line_no:5d}: [{class_name}::{func_name}]")
        print(f"           Sig: {sig[:80]}")
        print(f"           VA:  {va_str if 'ghidra' in dir() and ghidra else 'NOT FOUND'}")
        print(f"           --> {suggestion}")
        print()
