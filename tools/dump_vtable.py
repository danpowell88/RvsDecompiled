"""Dump vtable at 0x0050F29C from rebuilt exe"""
import struct

EXE_PATH = r"c:\Users\danpo\Desktop\rvs\build\bin\RavenShield.exe"
TARGET_VTABLE = 0x0050F29C
PURECALL_ADDR = 0x704F4F10

with open(EXE_PATH, "rb") as f:
    data = f.read()

pe_off = struct.unpack_from('<I', data, 0x3C)[0]
opt_off = pe_off + 0x18
image_base = struct.unpack_from('<I', data, opt_off + 0x1C)[0]
opt_size = struct.unpack_from('<H', data, pe_off + 0x14)[0]
nsections = struct.unpack_from('<H', data, pe_off + 6)[0]
sec_off = pe_off + 0x18 + opt_size

target_rva = TARGET_VTABLE - image_base
print(f'Image base: 0x{image_base:08X}')
print(f'Target vtable RVA: 0x{target_rva:08X}')
print(f'Target vtable abs: 0x{TARGET_VTABLE:08X}')

file_offset = None
for i in range(nsections):
    so = sec_off + i * 40
    name = data[so:so+8].rstrip(b'\0').decode()
    vsize = struct.unpack_from('<I', data, so + 8)[0]
    va = struct.unpack_from('<I', data, so + 12)[0]
    raw_size = struct.unpack_from('<I', data, so + 16)[0]
    raw_off = struct.unpack_from('<I', data, so + 20)[0]
    print(f'  Section {name}: VA=0x{va:08X} VSize=0x{vsize:X} RawOff=0x{raw_off:X}')
    if va <= target_rva < va + vsize:
        file_offset = raw_off + (target_rva - va)
        print(f'  ** Target at file offset 0x{file_offset:X}')

if file_offset:
    print(f'\nVtable dump at 0x{TARGET_VTABLE:08X} (25 slots):')
    purecall_slots = []
    for i in range(25):
        off = file_offset + i * 4
        val = struct.unpack_from('<I', data, off)[0]
        # Check if it looks like code or _purecall
        note = ""
        if val == PURECALL_ADDR:
            note = " <-- _purecall!"
            purecall_slots.append(i)
        elif 0x00400000 <= val <= 0x00600000:
            note = " (exe code)"
        elif 0x10000000 <= val <= 0x20000000:
            note = " (DLL)"
        elif 0x70000000 <= val <= 0x80000000:
            note = " (system DLL)"
        print(f'  slot[{i:2d}] @+0x{i*4:02X} = 0x{val:08X}{note}')
    if purecall_slots:
        print(f'\n_purecall found at slots: {purecall_slots}')
    
    # Also try reading nearby strings or RTTI data
    # RTTI Complete Object Locator is typically at vtable[-1]
    rtti_off = file_offset - 4
    rtti_ptr = struct.unpack_from('<I', data, rtti_off)[0]
    print(f'\nvtable[-1] (RTTI COL ptr): 0x{rtti_ptr:08X}')
    
    # Also dump GConfig vtable for comparison
    gconfig_rva = 0x0050F938 - image_base
    for i in range(nsections):
        so = sec_off + i * 40
        va = struct.unpack_from('<I', data, so + 12)[0]
        vsize = struct.unpack_from('<I', data, so + 8)[0]
        raw_off = struct.unpack_from('<I', data, so + 20)[0]
        if va <= gconfig_rva < va + vsize:
            gc_file_off = raw_off + (gconfig_rva - va)
            print(f'\nGConfig vtable at 0x0050F938 (25 slots):')
            for j in range(25):
                off = gc_file_off + j * 4
                val = struct.unpack_from('<I', data, off)[0]
                note = ""
                if val == PURECALL_ADDR:
                    note = " <-- _purecall!"
                print(f'  slot[{j:2d}] @+0x{j*4:02X} = 0x{val:08X}{note}')
            break
