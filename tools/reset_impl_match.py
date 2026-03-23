#!/usr/bin/env python3
"""
reset_impl_match.py — Convert FAIL IMPL_MATCH annotations to IMPL_TODO.

Reads the verify output file (build-71/verify_all.txt) and converts every
IMPL_MATCH that FAILed byte-parity to IMPL_TODO("Byte-parity unverified").
PASS annotations are left as IMPL_MATCH.

Usage:
  python tools/reset_impl_match.py build-71/verify_all.txt
"""

import re
import sys
from pathlib import Path
from collections import defaultdict

def main():
    if len(sys.argv) < 2:
        print("Usage: python tools/reset_impl_match.py <verify_output.txt>")
        sys.exit(1)

    verify_file = Path(sys.argv[1])
    src_root = Path(__file__).resolve().parent.parent / "src"

    # Parse verify output - get FAIL lines with file:line
    fails = []
    with open(verify_file, encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            m = re.match(r"(FAIL)\s+(\S+):(\d+)\s+(\S+)", line)
            if m:
                fname = m.group(2)
                lineno = int(m.group(3))
                func = m.group(4)
                fails.append((fname, lineno, func))

    print(f"Total FAIL entries: {len(fails)}")

    # Find all .cpp files under src/
    cpp_files = {}
    for cpp in src_root.rglob("*.cpp"):
        cpp_files[cpp.name] = cpp

    # Group fails by file
    by_file = defaultdict(list)
    not_found = set()
    for fname, lineno, func in fails:
        if fname in cpp_files:
            by_file[cpp_files[fname]].append(lineno)
        else:
            not_found.add(fname)

    if not_found:
        for f in sorted(not_found):
            print(f"  WARNING: {f} not found under src/")

    print(f"Files to modify: {len(by_file)}")
    print(f"Total lines to change: {sum(len(v) for v in by_file.values())}")

    # Process each file
    total_changed = 0
    for filepath, linenos in sorted(by_file.items()):
        lines = filepath.read_text(encoding="utf-8", errors="replace").splitlines(keepends=True)
        changed = 0
        linenos_set = set(linenos)

        for target_lineno in sorted(linenos_set):
            # The verify output line number points to the IMPL_MATCH line itself
            # or the function declaration line after it. Check both.
            found = False
            for check in (target_lineno, target_lineno - 1):
                idx = check - 1  # 0-indexed
                if 0 <= idx < len(lines):
                    if "IMPL_MATCH(" in lines[idx]:
                        indent = lines[idx][: len(lines[idx]) - len(lines[idx].lstrip())]
                        lines[idx] = indent + 'IMPL_TODO("Byte-parity unverified")\n'
                        changed += 1
                        found = True
                        break
            if not found:
                # Try wider search: up to 3 lines before target
                for check in range(target_lineno - 2, max(target_lineno - 5, 0), -1):
                    idx = check - 1
                    if 0 <= idx < len(lines) and "IMPL_MATCH(" in lines[idx]:
                        indent = lines[idx][: len(lines[idx]) - len(lines[idx].lstrip())]
                        lines[idx] = indent + 'IMPL_TODO("Byte-parity unverified")\n'
                        changed += 1
                        found = True
                        break
                if not found:
                    print(f"  MISS: {filepath.name}:{target_lineno} — no IMPL_MATCH found nearby")

        if changed > 0:
            filepath.write_text("".join(lines), encoding="utf-8")
            total_changed += changed
            print(f"  {filepath}: {changed} IMPL_MATCH -> IMPL_TODO")

    print(f"\nDone. Changed {total_changed} annotations.")


if __name__ == "__main__":
    main()
