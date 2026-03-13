"""Dump APawn vtable entries from retail Engine.dll"""
import struct

data = open('retail/system/Engine.dll','rb').read()
IMGBASE = 0x10300000
pe_off = struct.unpack_from('<I', data, 0x3C)[0]
sections = []
sec_off = pe_off + 0x18 + struct.unpack_from('<H', data, pe_off+0x14)[0]
for i in range(struct.unpack_from('<H', data, pe_off+0x06)[0]):
    s = data[sec_off+i*40:sec_off+i*40+40]
    sections.append((struct.unpack_from('<I',s,12)[0], struct.unpack_from('<I',s,16)[0], struct.unpack_from('<I',s,20)[0]))

def rva2off(rva):
    for va,vsz,raw in sections:
        if va <= rva < va+vsz:
            return raw+(rva-va)
    return None

with open('build/retail_engine_exports.txt', encoding='utf-16', errors='ignore') as f:
    exports = {}
    for line in f:
        p = line.strip().split()
        if len(p) >= 4:
            try:
                exports[p[3]] = int(p[2], 16)
            except:
                pass

# Reverse map: RVA -> symbol
rva_to_sym = {v: k for k, v in exports.items()}

# Find APawn vtable
apawn_vt = [k for k in exports if '??_7APawn@@' in k]
if not apawn_vt:
    print('APawn vtable not found')
else:
    sym = apawn_vt[0]
    rva = exports[sym]
    off = rva2off(rva)
    print('APawn vtable RVA 0x%X' % rva)
    for i in range(130):
        entry_va = struct.unpack_from('<I', data, off + i*4)[0]
        entry_rva = entry_va - IMGBASE
        name = rva_to_sym.get(entry_rva, '?')
        print('  [%3d] 0x%X (RVA 0x%X) %s' % (i, entry_va, entry_rva, name))
