"""batch_dump.py - dump retail bytes for a list of mangled names or partial names"""
import struct, sys, re

data = open('retail/system/Engine.dll','rb').read()

with open('build/retail_engine_exports.txt', encoding='utf-16', errors='ignore') as f:
    exports = {}
    for line in f:
        p = line.strip().split()
        if len(p) >= 4:
            try: exports[p[3]] = int(p[2],16)
            except: pass

pe_off = struct.unpack_from('<I', data, 0x3C)[0]
sections = []
sec_off = pe_off + 0x18 + struct.unpack_from('<H', data, pe_off+0x14)[0]
for i in range(struct.unpack_from('<H', data, pe_off+0x06)[0]):
    s = data[sec_off+i*40:sec_off+i*40+40]
    sections.append((struct.unpack_from('<I',s,12)[0], struct.unpack_from('<I',s,16)[0], struct.unpack_from('<I',s,20)[0]))

def rva2off(rva):
    for va,vsz,raw in sections:
        if va <= rva < va+vsz: return raw+(rva-va)
    return None

def func_size(off, limit=300):
    for i in range(off, min(off+limit, len(data))):
        b = data[i]
        if b == 0xC3: return i - off + 1
        if b == 0xC2 and i+2 < len(data): return i - off + 3
    return limit

def dump_sym(label, sym):
    if sym in exports:
        off = rva2off(exports[sym])
        if off:
            sz = func_size(off)
            b = data[off:off+sz]
            print(f'=== {label} ({sz}b) ===')
            print(' '.join(f'{x:02X}' for x in b))
            return
    # partial match
    matches = [k for k in exports if sym in k]
    if not matches:
        print(f'=== {label} === NOT FOUND')
        return
    # pick shortest match
    sym2 = min(matches, key=len)
    off = rva2off(exports[sym2])
    if off:
        sz = func_size(off)
        b = data[off:off+sz]
        print(f'=== {label} [{sym2}] ({sz}b) ===')
        print(' '.join(f'{x:02X}' for x in b))

# Pass symbol fragments as args
for arg in sys.argv[1:]:
    dump_sym(arg, arg)
