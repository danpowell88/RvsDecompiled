#!/usr/bin/env python3
"""Find all IMPL_TODO annotations and show function details."""
import os, re

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

todos = []
pat = re.compile(r'IMPL_TODO\s*\(\s*"([^"]*)"\s*\)')

for root, dirs, files in os.walk(os.path.join(ROOT, 'src')):
    for f in files:
        if not f.endswith('.cpp'):
            continue
        path = os.path.join(root, f)
        with open(path, 'r', errors='ignore') as fh:
            lines = fh.readlines()
        for i, line in enumerate(lines):
            m = pat.search(line)
            if m:
                reason = m.group(1)
                funcname = ''
                for j in range(i+1, min(i+5, len(lines))):
                    stripped = lines[j].strip()
                    if stripped and not stripped.startswith('//') and not stripped.startswith('#'):
                        funcname = stripped[:80]
                        break
                todos.append((f, i+1, reason[:60], funcname))

todos.sort()
print(f"Total IMPL_TODO: {len(todos)}")
for fname, line, reason, func in todos:
    print(f"  {fname}:{line}  {func}")
