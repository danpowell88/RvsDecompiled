"""
find_medium_fns.py - Find medium functions (31-150b) in retail Engine.dll exports.
Used to identify next-wave stubs for implementation.
"""
import sys

min_sz = int(sys.argv[1]) if len(sys.argv) > 1 else 31
max_sz = int(sys.argv[2]) if len(sys.argv) > 2 else 80

with open('build/retail_engine_exports.txt', 'r', encoding='utf-16-le') as f:
    lines = f.readlines()

exports = []
for line in lines:
    parts = line.split()
    if len(parts) >= 4 and len(parts[2]) == 8:
        try:
            rva = int(parts[2], 16)
            name = parts[3].strip()
            exports.append((rva, name))
        except:
            pass

exports.sort()

with open('retail/system/Engine.dll', 'rb') as f:
    data = f.read()

medium = []
for i, (rva, name) in enumerate(exports):
    if i + 1 < len(exports):
        sz = exports[i+1][0] - rva
        if min_sz <= sz <= max_sz:
            raw = data[rva:rva+min(sz, 6)]
            # skip vtable entries: pointer into image (starts 10 xx xx xx)
            if len(raw) >= 4 and raw[0] == 0x10:
                continue
            medium.append((sz, rva, name, data[rva:rva+sz]))

medium.sort()
print(f'Functions ({min_sz}-{max_sz}b) in Engine.dll:')
for sz, rva, name, raw in medium:
    print(f'  {sz:3d}b  RVA={rva:08X}  {name[:90]}')
    print(f'       bytes: {" ".join(f"{b:02x}" for b in raw)}')
