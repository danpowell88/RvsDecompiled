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
            exports[name] = (func_rva, func_off, data[func_off:func_off+200])
    return exports, data, rva_to_off

def disasm_simple(data, off, imgbase=0):
    """Very basic x86 disassembler for common patterns."""
    i = 0
    lines = []
    while i < len(data):
        b = data[i:]
        # Single byte ops
        if b[0] == 0xC3:
            lines.append(f"+{i:3d}: C3              ret")
            break
        elif b[0] == 0xC2:
            n = struct.unpack_from('<H', b, 1)[0]
            lines.append(f"+{i:3d}: C2 {n:04X}        ret {n}")
            break
        elif b[0] == 0x55:
            lines.append(f"+{i:3d}: 55              push ebp")
            i += 1
        elif b[0] == 0x56:
            lines.append(f"+{i:3d}: 56              push esi")
            i += 1
        elif b[0] == 0x57:
            lines.append(f"+{i:3d}: 57              push edi")
            i += 1
        elif b[0] == 0x53:
            lines.append(f"+{i:3d}: 53              push ebx")
            i += 1
        elif b[0] == 0x5E:
            lines.append(f"+{i:3d}: 5E              pop esi")
            i += 1
        elif b[0] == 0x5F:
            lines.append(f"+{i:3d}: 5F              pop edi")
            i += 1
        elif b[0] == 0x5B:
            lines.append(f"+{i:3d}: 5B              pop ebx")
            i += 1
        elif b[0] == 0x5D:
            lines.append(f"+{i:3d}: 5D              pop ebp")
            i += 1
        elif b[:2] == bytes([0x8B, 0xEC]):
            lines.append(f"+{i:3d}: 8B EC           mov ebp, esp")
            i += 2
        elif b[:2] == bytes([0x8B, 0xF1]):
            lines.append(f"+{i:3d}: 8B F1           mov esi, ecx")
            i += 2
        elif b[0] == 0x6A:
            lines.append(f"+{i:3d}: 6A {b[1]:02X}           push {b[1]:02X}h")
            i += 2
        elif b[0] == 0x68:
            v = struct.unpack_from('<I', b, 1)[0]
            lines.append(f"+{i:3d}: 68 {v:08X}    push {v:08X}h")
            i += 5
        elif b[:2] == bytes([0x8B, 0x86]):
            off2 = struct.unpack_from('<I', b, 2)[0]
            lines.append(f"+{i:3d}: 8B 86 {off2:08X} mov eax, [esi+{off2:X}h]")
            i += 6
        elif b[:2] == bytes([0x8B, 0x8E]):
            off2 = struct.unpack_from('<I', b, 2)[0]
            lines.append(f"+{i:3d}: 8B 8E {off2:08X} mov ecx, [esi+{off2:X}h]")
            i += 6
        elif b[:2] == bytes([0x8B, 0x80]):
            off2 = struct.unpack_from('<I', b, 2)[0]
            lines.append(f"+{i:3d}: 8B 80 {off2:08X} mov eax, [eax+{off2:X}h]")
            i += 6
        elif b[:2] == bytes([0x8B, 0x81]):
            off2 = struct.unpack_from('<I', b, 2)[0]
            lines.append(f"+{i:3d}: 8B 81 {off2:08X} mov eax, [ecx+{off2:X}h]")
            i += 6
        elif b[:2] == bytes([0x8B, 0x91]):
            off2 = struct.unpack_from('<I', b, 2)[0]
            lines.append(f"+{i:3d}: 8B 91 {off2:08X} mov edx, [ecx+{off2:X}h]")
            i += 6
        elif b[:2] == bytes([0x85, 0xC0]):
            lines.append(f"+{i:3d}: 85 C0           test eax, eax")
            i += 2
        elif b[:2] == bytes([0x85, 0xC9]):
            lines.append(f"+{i:3d}: 85 C9           test ecx, ecx")
            i += 2
        elif b[:2] == bytes([0x33, 0xC0]):
            lines.append(f"+{i:3d}: 33 C0           xor eax, eax")
            i += 2
        elif b[:2] == bytes([0x3B, 0xC2]):
            lines.append(f"+{i:3d}: 3B C2           cmp eax, edx")
            i += 2
        elif b[:2] == bytes([0x83, 0xE0]):
            lines.append(f"+{i:3d}: 83 E0 {b[2]:02X}        and eax, {b[2]:02X}h")
            i += 3
        elif b[0] == 0x74:
            lines.append(f"+{i:3d}: 74 {b[1]:02X}           jz +{b[1]} (to +{i+2+b[1]})")
            i += 2
        elif b[0] == 0x75:
            lines.append(f"+{i:3d}: 75 {b[1]:02X}           jnz +{b[1]} (to +{i+2+b[1]})")
            i += 2
        elif b[0] == 0xEB:
            lines.append(f"+{i:3d}: EB {b[1]:02X}           jmp +{b[1]} (to +{i+2+b[1]})")
            i += 2
        elif b[0] in (0x90, 0xCC):
            # NOP or INT3 (padding) - stop
            lines.append(f"+{i:3d}: {b[0]:02X}              nop/pad")
            break
        else:
            lines.append(f"+{i:3d}: {b[:4].hex():10s}  ??? (unknown opcode {b[0]:02X})")
            i += 1
            if i > 150:
                break
    return lines

eng_exp, data_eng, rva_to_off = read_pe_exports('retail/system/Engine.dll')

print("=== AActor::CheckOwnerUpdated ===")
name = '?CheckOwnerUpdated@AActor@@UAEHXZ'
if name in eng_exp:
    rva, off, raw = eng_exp[name]
    lines = disasm_simple(raw, off)
    for l in lines[:50]:
        print(l)

print()
print("=== AActor::StartAnimPoll ===")
name = '?StartAnimPoll@AActor@@UAEXXZ'
if name in eng_exp:
    rva, off, raw = eng_exp[name]
    lines = disasm_simple(raw, off)
    for l in lines[:50]:
        print(l)
