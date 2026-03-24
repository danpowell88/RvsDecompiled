#!/usr/bin/env python3
"""Check which functions are truly missing vs already annotated differently."""
import json, os, re

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# Load all IMPL_MATCH addresses
match_addrs = set()
pat = re.compile(r'IMPL_MATCH\s*\(\s*"[^"]+"\s*,\s*(0x[0-9a-fA-F]+)\s*\)')
for root, dirs, files in os.walk(os.path.join(ROOT, 'src')):
    for f in files:
        if f.endswith('.parity') or f.endswith('.cpp'):
            with open(os.path.join(root, f), 'r', errors='ignore') as fh:
                for line in fh:
                    m = pat.search(line)
                    if m:
                        match_addrs.add(int(m.group(1), 16))

print(f"IMPL_MATCH annotations: {len(match_addrs)}")

# Check all Core small functions
funcs = json.load(open(os.path.join(ROOT, 'ghidra/exports/reports/Core_function_index.json')))
addrs = ['10115120', '10128840', '101497c0', '10137020', '101086a0', '1010e340',
         '10119d00', '101316b0', '10108700', '101287c0', '1010dff0', '10110f40',
         '1013c9a0', '10101840', '10108000', '101085d0']

for func in funcs['functions']:
    if func['addr'] in addrs:
        addr_int = int(func['addr'], 16)
        in_match = addr_int in match_addrs
        print(f"  0x{func['addr']}  {func.get('size','?'):>3}B  in_manifest={'Y' if in_match else 'N'}  {func['name']}")
