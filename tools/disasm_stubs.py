"""disasm_stubs.py - disassemble specific stubs for batch implementation"""
import struct, sys
try:
    import capstone
    cs = capstone.Cs(capstone.CS_ARCH_X86, capstone.CS_MODE_32)
    cs.detail = False
    IMGBASE = 0x10300000
except ImportError:
    cs = None

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

def find_end(off, limit=1000):
    depth = 0
    for i in range(off, min(off+limit, len(data))):
        b = data[i]
        if b == 0xC3: return i-off+1
        if b == 0xC2 and i+2<len(data): return i-off+3
    return limit

def disasm(sym_fragment):
    matches = [k for k in exports if sym_fragment in k]
    if not matches:
        print(f'NOT FOUND: {sym_fragment}')
        return
    sym = min(matches, key=len) if len(matches)>1 else matches[0]
    if len(matches)>1:
        # show all matches
        for m in sorted(matches):
            rva = exports[m]
            off = rva2off(rva)
            sz = find_end(off)
            bs = data[off:off+sz]
            print(f'\n=== {m} (RVA 0x{rva:X}, {sz}b) ===')
            if cs:
                va = IMGBASE + rva
                for ins in cs.disasm(bs, va):
                    print(f'  0x{ins.address:X}: {ins.mnemonic:<8} {ins.op_str}')
        return
    rva = exports[sym]
    off = rva2off(rva)
    sz = find_end(off)
    bs = data[off:off+sz]
    print(f'\n=== {sym} (RVA 0x{rva:X}, {sz}b) ===')
    if cs:
        va = IMGBASE + rva
        for ins in cs.disasm(bs, va):
            print(f'  0x{ins.address:X}: {ins.mnemonic:<8} {ins.op_str}')
    else:
        print('  ' + ' '.join(f'{x:02X}' for x in bs))

for arg in sys.argv[1:]:
    disasm(arg)
