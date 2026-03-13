"""Scan retail Engine.dll exports and categorize by implementation complexity."""
import struct, sys

with open('retail/system/Engine.dll','rb') as f:
    data = f.read()
base = 0x10300000

exports = {}
with open('build/retail_engine_exports.txt', encoding='utf-16-le') as f:
    for line in f:
        line = line.strip()
        if not line:
            continue
        parts = line.split()
        # Format: ordinal hint RVA name
        if len(parts) >= 4:
            try:
                rva = int(parts[2], 16)
                name = parts[3]
                exports[name] = rva
            except:
                pass

def rva_to_offset(rva):
    pe_off = struct.unpack_from('<I', data, 0x3C)[0]
    num_sections = struct.unpack_from('<H', data, pe_off+6)[0]
    section_off = pe_off + 0xF8
    for i in range(num_sections):
        s = section_off + i*40
        vaddr = struct.unpack_from('<I', data, s+12)[0]
        vsize = struct.unpack_from('<I', data, s+16)[0]
        raw = struct.unpack_from('<I', data, s+20)[0]
        rawsize = struct.unpack_from('<I', data, s+24)[0]
        if vaddr <= rva < vaddr + max(vsize, rawsize):
            return raw + (rva - vaddr)
    return None

trivial = {'ret': [], 'ret_n': [], 'false_ret': [], 'false_ret_n': [], 'true_ret': []}

for name, rva in exports.items():
    off = rva_to_offset(rva)
    if off is None:
        continue
    b = data[off:off+8]
    if len(b) < 1:
        continue
    # Pure ret (C3)
    if b[0] == 0xC3:
        trivial['ret'].append(name)
    # ret N (C2 xx 00)  [stdcall with param cleanup]
    elif b[0] == 0xC2 and len(b) >= 3 and b[2] == 0:
        n = b[1]
        trivial['ret_n'].append((n, name))
    # xor eax,eax / ret  =>  return 0/false (no params)
    elif b[0:3] == bytes([0x33, 0xC0, 0xC3]):
        trivial['false_ret'].append(name)
    # xor eax,eax / ret N  =>  return 0/false (with param cleanup)
    elif b[0:3] == bytes([0x33, 0xC0, 0xC2]) and len(b) >= 5 and b[4] == 0:
        trivial['false_ret_n'].append((b[3], name))
    # mov eax,1 / ret  =>  return true
    elif b[0:5] == bytes([0xB8, 0x01, 0x00, 0x00, 0x00]) and len(b) >= 6 and b[5] == 0xC3:
        trivial['true_ret'].append(name)

print('=== Trivially simple Engine.dll exports ===')
print(f'Pure ret (void, no params):       {len(trivial["ret"])}')
print(f'ret N (void, N bytes of params):  {len(trivial["ret_n"])}')
print(f'xor eax,eax + ret (return 0):    {len(trivial["false_ret"])}')
print(f'xor eax,eax + ret N (return 0):  {len(trivial["false_ret_n"])}')
print(f'mov eax,1 + ret (return 1):      {len(trivial["true_ret"])}')

total = sum(len(v) for v in trivial.values())
print(f'Total trivially simple exports:    {total}')
print()

print('=== Sample: pure ret ===')
for n in trivial['ret'][:10]:
    print(f'  {n}')

print()
print('=== Sample: ret N ===')
for sz, n in trivial['ret_n'][:10]:
    print(f'  ret {sz}: {n}')

print()
print('=== Sample: xor eax,eax + ret ===')
for n in trivial['false_ret'][:10]:
    print(f'  {n}')

print()
print('=== Sample: xor eax,eax + ret N ===')
for sz, n in trivial['false_ret_n'][:10]:
    print(f'  ret {sz}: {n}')

if '--all' in sys.argv:
    print()
    print('=== ALL ret (void no params) ===')
    for n in sorted(trivial['ret']):
        print(f'  {n}')
    print()
    print('=== ALL ret N ===')
    for sz, n in sorted(trivial['ret_n']):
        print(f'  ret {sz}: {n}')
    print()
    print('=== ALL xor+ret ===')
    for n in sorted(trivial['false_ret']):
        print(f'  {n}')
    print()
    print('=== ALL xor+ret N ===')
    for sz, n in sorted(trivial['false_ret_n']):
        print(f'  ret {sz}: {n}')
