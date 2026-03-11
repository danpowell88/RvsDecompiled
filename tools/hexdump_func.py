import struct

def read_pe_exports(path):
    with open(path, 'rb') as f:
        data = f.read()
    pe_off = struct.unpack_from('<I', data, 0x3C)[0]
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
    exp_dir_off = rva_to_off(struct.unpack_from('<I', data, pe_off + 0x78)[0])
    names_rva = struct.unpack_from('<I', data, exp_dir_off + 32)[0]
    addrs_rva = struct.unpack_from('<I', data, exp_dir_off + 28)[0]
    name_ords_rva = struct.unpack_from('<I', data, exp_dir_off + 36)[0]
    num_names = struct.unpack_from('<I', data, exp_dir_off + 24)[0]
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
            exports[name] = (func_rva, func_off, data)
    return exports, data

eng_exp, data = read_pe_exports('retail/system/Engine.dll')

# Dump first 200 bytes of function, formatted as hex
def hexdump(data, off, n=200):
    b = data[off:off+n]
    for i in range(0, n, 16):
        chunk = b[i:i+16]
        if not chunk:
            break
        hex_str = ' '.join(f'{x:02X}' for x in chunk)
        print(f"  +{i:4d} ({off+i:6X}): {hex_str}")

funcs = [
    ('AActor::CheckOwnerUpdated', '?CheckOwnerUpdated@AActor@@UAEHXZ'),
    ('AActor::StartAnimPoll', '?StartAnimPoll@AActor@@UAEXXZ'),
]

for label, sym in funcs:
    if sym in eng_exp:
        rva, off, _ = eng_exp[sym]
        print(f"=== {label} ===")
        hexdump(data, off, n=200)
        print()
