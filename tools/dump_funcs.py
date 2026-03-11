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
    return exports, data, rva_to_off

def dump_func(data, start_off, max_bytes=200):
    """Dump bytes as formatted hex, stopping at ret/ret N or max_bytes."""
    b = data[start_off:start_off+max_bytes]
    # Find end of function (first C3 or C2 XX XX that's likely ret)
    # Simple scan: stop after 200 bytes max
    print(f"  Raw start: {b[:16].hex()}")
    print()
    # Format as lines of 16 bytes
    for i in range(0, min(len(b), max_bytes), 16):
        chunk = b[i:i+16]
        hex_str = ' '.join(f'{x:02X}' for x in chunk)
        print(f"  {start_off+i:6X}: {hex_str}")
        # Check for ret
        for j, byte in enumerate(chunk):
            if byte == 0xC3:
                # Might be ret
                abs_j = i + j
                print(f"  ^-- ret at offset +{abs_j}")
                return
            if byte == 0xC2 and i+j+2 < len(b):
                n = struct.unpack_from('<H', b, i+j+1)[0]
                print(f"  ^-- ret {n} at offset +{i+j}")
                return

eng_exp, data_eng, rva_to_off_eng = read_pe_exports('retail/system/Engine.dll')

funcs = [
    ('AActor::CheckOwnerUpdated', '?CheckOwnerUpdated@AActor@@UAEHXZ'),
    ('AActor::StartAnimPoll', '?StartAnimPoll@AActor@@UAEXXZ'),
    ('AActor::preKarmaStep', '?preKarmaStep@AActor@@UAEXM@Z'),
    ('AActor::postKarmaStep', '?postKarmaStep@AActor@@UAEXXZ'),
]

for label, sym in funcs:
    if sym in eng_exp:
        rva, off, data = eng_exp[sym]
        print(f"=== {label} (RVA={rva:X}, file off={off:X}) ===")
        dump_func(data, off, max_bytes=200)
        print()
