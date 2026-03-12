"""
find_tiny_fns.py - Find all tiny functions (<=30b) in retail Engine.dll exports.
Used to identify quick-win stubs for implementation.
"""
import struct

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

MAX_SIZE = 30
tiny = []
for i, (rva, name) in enumerate(exports):
    if i + 1 < len(exports):
        sz = exports[i+1][0] - rva
        if 3 <= sz <= MAX_SIZE:
            raw = data[rva:rva+sz]
            tiny.append((sz, rva, name, raw))

tiny.sort()
print(f'Tiny functions (<={MAX_SIZE}b) in Engine.dll:')
for sz, rva, name, raw in tiny:
    print(f'  {sz:3d}b  RVA={rva:08X}  {name[:90]}')
    print(f'       bytes: {" ".join(f"{b:02x}" for b in raw)}')
