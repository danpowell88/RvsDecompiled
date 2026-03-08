"""Disassemble UR6ModMgr::execSetGeneralModSettings from retail Engine.dll"""
import struct
import sys

DLL_PATH = r"c:\Users\danpo\Desktop\rvs\retail\system\Engine.dll"

# Function RVA and size from Ghidra
FUNC_RVA = 0x93220
FUNC_SIZE = 566  # from Ghidra comment
TARGET_RET_ADDR_RVA = 0x933A0  # return address from _purecall

with open(DLL_PATH, "rb") as f:
    data = f.read()

# Parse PE
pe_off = struct.unpack_from("<I", data, 0x3C)[0]
num_sections = struct.unpack_from("<H", data, pe_off + 6)[0]
opt_hdr_size = struct.unpack_from("<H", data, pe_off + 0x14)[0]
image_base = struct.unpack_from("<I", data, pe_off + 0x18 + 0x1C)[0]
print(f"ImageBase: 0x{image_base:08X}")

sec_table_off = pe_off + 0x18 + opt_hdr_size

# Find section containing our RVA
file_offset = None
for i in range(num_sections):
    so = sec_table_off + i * 40
    name = data[so:so+8].rstrip(b'\0').decode()
    vsize = struct.unpack_from("<I", data, so + 8)[0]
    va = struct.unpack_from("<I", data, so + 12)[0]
    raw_size = struct.unpack_from("<I", data, so + 16)[0]
    raw_off = struct.unpack_from("<I", data, so + 20)[0]
    print(f"  {name}: VA=0x{va:08X} VSize=0x{vsize:X} RawOff=0x{raw_off:X} RawSize=0x{raw_size:X}")
    if va <= FUNC_RVA < va + vsize:
        file_offset = raw_off + (FUNC_RVA - va)
        print(f"  ** Function at file offset 0x{file_offset:X}")

if file_offset is None:
    print("Could not find section!")
    sys.exit(1)

# Extract function bytes
func_bytes = data[file_offset:file_offset + FUNC_SIZE + 64]  # extra margin

# Manual x86 disassembly around the target area
# target_offset within function = 0x933A0 - 0x93220 = 0x180
target_func_offset = TARGET_RET_ADDR_RVA - FUNC_RVA
print(f"\nTarget return address: RVA 0x{TARGET_RET_ADDR_RVA:X} (func offset 0x{target_func_offset:X})")
print(f"Function starts at RVA 0x{FUNC_RVA:X}, absolute 0x{image_base + FUNC_RVA:08X}")
print(f"Function size: {FUNC_SIZE} bytes (0x{FUNC_SIZE:X})")
print(f"Function ends at RVA 0x{FUNC_RVA + FUNC_SIZE:X}, absolute 0x{image_base + FUNC_RVA + FUNC_SIZE:08X}")

# Dump hex around the call site
print(f"\n--- Raw bytes around offset 0x{target_func_offset:X} (RVA 0x{TARGET_RET_ADDR_RVA:X}) ---")
start = max(0, target_func_offset - 32)
end = min(len(func_bytes), target_func_offset + 16)
for off in range(start, end, 16):
    hex_str = " ".join(f"{func_bytes[off+j]:02X}" for j in range(min(16, end - off)))
    rva = FUNC_RVA + off
    print(f"  0x{image_base+rva:08X} (func+0x{off:03X}):  {hex_str}")

# Look for CALL instructions near the target
# E8 xx xx xx xx = relative call (5 bytes, return addr = next instruction)
# FF 10/FF 50 xx/FF 90 xx xx xx xx = call [eax]/call [eax+xx]/call [eax+xxxxxxxx]  
# FF D0 = call eax (2 bytes)
# FF 11 = call [ecx] (2 bytes)
# FF 51 xx = call [ecx+xx] (3 bytes)
# FF 91 xx xx xx xx = call [ecx+xxxxxxxx] (6 bytes)
print(f"\n--- Searching for CALL instructions near target ---")
search_start = max(0, target_func_offset - 20)
search_end = target_func_offset + 1  # return address is just after the call
for off in range(search_start, search_end):
    b = func_bytes[off]
    rva = FUNC_RVA + off
    abs_addr = image_base + rva
    
    # E8 = relative call (5 bytes)
    if b == 0xE8 and off + 5 <= search_end + 5:
        rel = struct.unpack_from("<i", func_bytes, off + 1)[0]
        target = image_base + rva + 5 + rel
        ret_addr = rva + 5
        if FUNC_RVA + target_func_offset - 1 <= ret_addr <= FUNC_RVA + target_func_offset + 1:
            print(f"  ** CALL rel32 at 0x{abs_addr:08X} (func+0x{off:03X}): E8 {' '.join(f'{func_bytes[off+1+j]:02X}' for j in range(4))}")
            print(f"     Target: 0x{target:08X}, Return addr: RVA 0x{ret_addr:X} (0x{image_base+ret_addr:08X})")
    
    # FF /2 = call [reg+disp] or call reg
    if b == 0xFF and off + 1 < len(func_bytes):
        modrm = func_bytes[off + 1]
        reg_field = (modrm >> 3) & 7
        mod = (modrm >> 6) & 3
        rm = modrm & 7
        
        if reg_field == 2:  # CALL /2
            if mod == 0 and rm != 4 and rm != 5:  # call [reg]
                instr_len = 2
            elif mod == 0 and rm == 4:  # SIB
                instr_len = 3
            elif mod == 0 and rm == 5:  # call [disp32]
                instr_len = 6
            elif mod == 1 and rm != 4:  # call [reg+disp8]
                instr_len = 3
            elif mod == 1 and rm == 4:  # SIB + disp8
                instr_len = 4
            elif mod == 2 and rm != 4:  # call [reg+disp32]
                instr_len = 6
            elif mod == 2 and rm == 4:  # SIB + disp32
                instr_len = 7
            elif mod == 3:  # call reg
                instr_len = 2
            else:
                continue
            
            ret_addr = rva + instr_len
            if FUNC_RVA + target_func_offset - 1 <= ret_addr <= FUNC_RVA + target_func_offset + 1:
                hex_instr = " ".join(f"{func_bytes[off+j]:02X}" for j in range(instr_len))
                regs = ["eax", "ecx", "edx", "ebx", "esp", "ebp", "esi", "edi"]
                
                if mod == 3:
                    desc = f"call {regs[rm]}"
                elif mod == 0:
                    if rm == 5:
                        disp = struct.unpack_from("<I", func_bytes, off + 2)[0]
                        desc = f"call [0x{disp:08X}]"
                    else:
                        desc = f"call [{regs[rm]}]"
                elif mod == 1:
                    disp = struct.unpack_from("<b", func_bytes, off + 2)[0]
                    desc = f"call [{regs[rm]}+0x{disp & 0xFF:02X}]"
                elif mod == 2:
                    disp = struct.unpack_from("<i", func_bytes, off + 2)[0]
                    desc = f"call [{regs[rm]}+0x{disp:08X}]"
                
                print(f"  ** CALL indirect at 0x{abs_addr:08X} (func+0x{off:03X}): {hex_instr}")
                print(f"     Instruction: {desc}")
                print(f"     Return addr: RVA 0x{ret_addr:X} (0x{image_base+ret_addr:08X})")

# Also dump the full function hex with basic disassembly markers
print(f"\n--- Full hex dump of function (first 0x1A0 bytes covering through the target) ---")
for off in range(0, min(0x1A0, len(func_bytes)), 16):
    hex_str = " ".join(f"{func_bytes[off+j]:02X}" for j in range(min(16, len(func_bytes) - off)))
    rva = FUNC_RVA + off
    marker = " <-- TARGET" if off <= target_func_offset < off + 16 else ""
    print(f"  0x{image_base+rva:08X}:  {hex_str}{marker}")
