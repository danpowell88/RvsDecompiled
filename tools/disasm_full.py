"""disasm_full.py - disassemble engine function without premature truncation"""
import struct, sys
try:
    import capstone
    cs = capstone.Cs(capstone.CS_ARCH_X86, capstone.CS_MODE_32)
    IMGBASE = 0x10300000
except ImportError:
    print("capstone not available"); sys.exit(1)

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

def disasm_smart(sym_fragment, max_size=2000):
    matches = [k for k in exports if sym_fragment in k]
    if not matches:
        print(f'NOT FOUND: {sym_fragment}'); return
    sym = min(matches, key=len) if len(matches)>1 else matches[0]
    if len(matches)>1:
        for m in sorted(matches): disasm_smart(m, max_size)
        return
    rva = exports[sym]
    off = rva2off(rva)
    if not off: return

    # Use capstone to disassemble up to max_size bytes; stop at top-level ret
    bs = data[off:off+max_size]
    va = IMGBASE + rva
    print(f'\n=== {sym} (RVA 0x{rva:X}, VA 0x{va:X}) ===')
    
    # Track SEH frame depth (push -1 near start = SEH-framed)
    seh_framed = (bs[0] == 0x55 and bs[1] == 0x8B)  # push ebp; mov ebp,esp
    
    total = 0
    for ins in cs.disasm(bs, va):
        print(f'  0x{ins.address:X}: {ins.mnemonic:<8} {ins.op_str}')
        total += ins.size
        if ins.mnemonic.startswith('ret'):
            # If SEH-framed, ret appears inside epilogue at a fixed pattern
            # Real function end always has: mov dword ptr fs:[0], X; ...several pops; ret
            # Simple heuristic: stop at first ret if function < 50 bytes; else at any ret
            if total < 50 or not seh_framed:
                break
            # For SEH-framed: stop at second ret (one per epilogue block)
            break

for arg in sys.argv[1:]:
    disasm_smart(arg)
