"""
Find the AActor vtable in retail Engine.dll and disassemble its entries.
"""
import struct

def load_dll(path):
    with open(path, 'rb') as f:
        data = f.read()
    pe_offset = struct.unpack_from('<I', data, 0x3C)[0]
    imagebase = struct.unpack_from('<I', data, pe_offset + 0x34)[0]
    opt_header_size = struct.unpack_from('<H', data, pe_offset + 0x14)[0]
    sec_offset = pe_offset + 0x18 + opt_header_size
    num_sections = struct.unpack_from('<H', data, pe_offset + 6)[0]
    sections = []
    for i in range(num_sections):
        offs = sec_offset + i * 40
        name = data[offs:offs+8].decode(errors='replace').rstrip('\x00')
        vaddr, vsize, raw_offs = struct.unpack_from('<III', data, offs + 12)
        sections.append((name, vaddr, vsize, raw_offs))
    def r2r(rva):
        for (name, va, vsize, raw) in sections:
            if va <= rva < va + vsize:
                return raw + (rva - va)
        return None
    def va2rva(va):
        return va - imagebase
    def r2r_va(va):
        return r2r(va2rva(va))
    
    exp_rva = struct.unpack_from('<I', data, pe_offset + 0x78)[0]
    raw = r2r(exp_rva)
    num_funcs, num_names = struct.unpack_from('<II', data, raw + 0x14)
    funcs_rva, names_rva, ords_rva = struct.unpack_from('<III', data, raw + 0x1C)
    exports = {}
    for i in range(num_names):
        name_rva = struct.unpack_from('<I', data, r2r(names_rva) + i*4)[0]
        ord_idx  = struct.unpack_from('<H', data, r2r(ords_rva)  + i*2)[0]
        func_rva = struct.unpack_from('<I', data, r2r(funcs_rva) + ord_idx*4)[0]
        nr = r2r(name_rva)
        name = b''
        while data[nr] != 0:
            name += bytes([data[nr]]); nr += 1
        exports[name.decode(errors='replace')] = func_rva
    return exports, data, r2r, r2r_va, imagebase

eng_exports, eng_data, eng_r2r, eng_r2r_va, imagebase = load_dll('retail/system/Engine.dll')

# Find AActor vtable: look for ??_7AActor@@6B@
vtable_symbol = '??_7AActor@@6B@'
if vtable_symbol in eng_exports:
    vtable_rva = eng_exports[vtable_symbol]
    vtable_raw = eng_r2r(vtable_rva)
    print(f'Found AActor vtable at RVA 0x{vtable_rva:x}')
    
    # Read 100 vtable entries (each is 4 bytes for 32-bit)
    # Entry at offset 0xF0 = slot 60
    target_slot = 60
    
    # Also reverse-lookup exports (build RVA → name map)
    rva_to_name = {}
    for name, rva in eng_exports.items():
        rva_to_name[rva] = name
    
    print(f'\nVtable slots 55-65:')
    for slot in range(55, 70):
        byte_offset = slot * 4
        entry_va = struct.unpack_from('<I', eng_data, vtable_raw + byte_offset)[0]
        if entry_va == 0:
            print(f'  [{slot}] NULL')
            continue
        entry_rva = entry_va - imagebase
        # Find bytes at this function
        raw = eng_r2r(entry_rva)
        if raw:
            func_bytes = eng_data[raw:raw+8].hex()
        else:
            func_bytes = '?'
        # Find name
        func_name = rva_to_name.get(entry_rva, f'RVA_0x{entry_rva:x}')
        # Demangle if possible (just strip leading ?)
        display_name = func_name.lstrip('?')[:60]
        marker = ' <<<< TARGET (slot 60)' if slot == target_slot else ''
        print(f'  [{slot}] {display_name} [{func_bytes}]{marker}')
else:
    print(f'AActor vtable NOT found as export')
    # Search for it by name
    vtable_matches = [(k,v) for k,v in eng_exports.items() if 'AActor' in k and '7' in k]
    print(f'AActor vtable candidates:')
    for k, v in vtable_matches[:5]:
        print(f'  {k[:80]}')
