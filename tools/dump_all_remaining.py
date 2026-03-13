"""dump_all_remaining.py - disassemble all remaining complex stubs from check_engine_stubs"""
import struct, sys
try:
    import capstone
    cs = capstone.Cs(capstone.CS_ARCH_X86, capstone.CS_MODE_32)
    IMGBASE = 0x10300000
    has_capstone = True
except:
    has_capstone = False

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

def find_end(off, limit=600):
    for i in range(off, min(off+limit, len(data))):
        b = data[i]
        if b == 0xC3: return i-off+1
        if b == 0xC2 and i+2<len(data): return i-off+3
    return limit

# filter by argv[1] if given
filt = sys.argv[1] if len(sys.argv)>1 else ''

for sym, rva in sorted(exports.items(), key=lambda x: x[1]):
    if filt and filt not in sym:
        continue
    off = rva2off(rva)
    if not off: continue
    sz = find_end(off)
    bs = data[off:off+sz]
    # Skip trivial stubs
    trivial = (bs[0]==0xC3 or bs[0]==0xC2 or
               bs[:3]==bytes([0x33,0xC0,0xC3]) or
               (bs[:2]==bytes([0x33,0xC0]) and len(bs)>2 and bs[2]==0xC2) or
               (bs[:5]==bytes([0xB8,0x01,0x00,0x00,0x00]) and len(bs)>5 and bs[5] in (0xC3,0xC2)))
    if trivial: continue
    print(f'\n=== {sym} (RVA 0x{rva:X}, {sz}b) ===')
    if has_capstone:
        va = IMGBASE + rva
        for ins in cs.disasm(bs, va):
            print(f'  0x{ins.address:X}: {ins.mnemonic:<8} {ins.op_str}')
    else:
        print('  ' + ' '.join(f'{x:02X}' for x in bs))
