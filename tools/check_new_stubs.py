import struct, sys

def read_pe_exports(path):
    with open(path, 'rb') as f:
        data = f.read()
    
    dos_sig = struct.unpack_from('<H', data, 0)[0]
    assert dos_sig == 0x5A4D
    pe_off = struct.unpack_from('<I', data, 0x3C)[0]
    pe_sig = struct.unpack_from('<I', data, pe_off)[0]
    assert pe_sig == 0x00004550
    
    imgbase = struct.unpack_from('<I', data, pe_off + 0x34)[0]
    num_sections = struct.unpack_from('<H', data, pe_off + 0x06)[0]
    opt_hdr_size = struct.unpack_from('<H', data, pe_off + 0x14)[0]
    
    sections = []
    sec_off = pe_off + 0x18 + opt_hdr_size
    for i in range(num_sections):
        s = data[sec_off + i*40 : sec_off + i*40 + 40]
        vaddr = struct.unpack_from('<I', s, 12)[0]
        vsz = struct.unpack_from('<I', s, 16)[0]
        raw = struct.unpack_from('<I', s, 20)[0]
        sections.append((vaddr, vsz, raw))
    
    def rva_to_off(rva):
        for vaddr, vsz, raw in sections:
            if vaddr <= rva < vaddr + vsz:
                return raw + (rva - vaddr)
        return None
    
    exp_dir_rva = struct.unpack_from('<I', data, pe_off + 0x78)[0]
    names_rva = struct.unpack_from('<I', data, rva_to_off(exp_dir_rva) + 32)[0]
    addrs_rva = struct.unpack_from('<I', data, rva_to_off(exp_dir_rva) + 28)[0]
    name_ords_rva = struct.unpack_from('<I', data, rva_to_off(exp_dir_rva) + 36)[0]
    num_names = struct.unpack_from('<I', data, rva_to_off(exp_dir_rva) + 24)[0]
    
    exports = {}
    for i in range(num_names):
        name_rva = struct.unpack_from('<I', data, rva_to_off(names_rva) + i*4)[0]
        ord_idx = struct.unpack_from('<H', data, rva_to_off(name_ords_rva) + i*2)[0]
        func_rva = struct.unpack_from('<I', data, rva_to_off(addrs_rva) + ord_idx*4)[0]
        name_off = rva_to_off(name_rva)
        end = data.index(b'\x00', name_off)
        name = data[name_off:end].decode('ascii', errors='replace')
        func_off = rva_to_off(func_rva)
        if func_off:
            exports[name] = (func_rva, func_off, data[func_off:func_off+64])
    
    return exports, data

def classify(b):
    """Classify function body bytes."""
    # ret (C3)
    if b[0] == 0xC3:
        return "void (ret)"
    # ret N (C2 xx 00)
    if b[0] == 0xC2:
        n = struct.unpack_from('<H', b, 1)[0]
        return f"void (ret {n})"
    # xor eax,eax; ret
    if b[:3] == bytes([0x33, 0xC0, 0xC3]):
        return "return 0 (xor eax,eax; ret)"
    # xor eax,eax; ret N
    if b[:2] == bytes([0x33, 0xC0]) and b[2] == 0xC2:
        n = struct.unpack_from('<H', b, 3)[0]
        return f"return 0 (xor eax,eax; ret {n})"
    # mov eax,1; ret
    if b[:5] == bytes([0xB8, 0x01, 0x00, 0x00, 0x00]) and b[5] == 0xC3:
        return "return 1"
    # mov eax,1; ret N
    if b[:5] == bytes([0xB8, 0x01, 0x00, 0x00, 0x00]) and b[5] == 0xC2:
        n = struct.unpack_from('<H', b, 6)[0]
        return f"return 1 (ret {n})"
    # push ebp; etc (SEH prolog)
    if b[0] == 0x55:
        return f"complex (ebp prolog) [{b[:8].hex()}]"
    # push esi / push edi etc
    if b[0] in (0x56, 0x57, 0x53):
        return f"complex (push reg) [{b[:8].hex()}]"
    return f"unknown [{b[:8].hex()}]"

# Check Engine.dll
print("=== Engine.dll CheckCircularReferences ===")
eng_exp, _ = read_pe_exports('retail/system/Engine.dll')
for name, (rva, off, raw) in eng_exp.items():
    if 'CheckCircular' in name:
        print(f"  {name}: {classify(raw)}")

print()
print("=== Core.dll UnNet / UnStream / UnExport ===")
core_exp, _ = read_pe_exports('retail/system/Core.dll')

searches = ['CanSerialize', 'IndexToObject', 'StaticConstructor', 'FileStream', 
            'UExporter', 'UFactory', 'UPackageMap']
for name, (rva, off, raw) in core_exp.items():
    if any(x in name for x in searches):
        print(f"  {name}: {classify(raw)}")
