"""Disassemble UR6ModMgr::eventGetServerIni crash at 0x1031B2F3"""
from capstone import *
import struct

DLL_PATH = r"c:\Users\danpo\Desktop\rvs\retail\system\Engine.dll"
FUNC_RVA = 0x1B2A0
FUNC_SIZE = 147
IMAGE_BASE = 0x10300000
CRASH_ADDR = IMAGE_BASE + 0x1B2F3

with open(DLL_PATH, "rb") as f:
    data = f.read()

pe_off = struct.unpack_from("<I", data, 0x3C)[0]
num_sections = struct.unpack_from("<H", data, pe_off + 6)[0]
opt_hdr_size = struct.unpack_from("<H", data, pe_off + 0x14)[0]
sec_table_off = pe_off + 0x18 + opt_hdr_size

file_offset = None
for i in range(num_sections):
    so = sec_table_off + i * 40
    va = struct.unpack_from("<I", data, so + 12)[0]
    vsize = struct.unpack_from("<I", data, so + 8)[0]
    raw_off = struct.unpack_from("<I", data, so + 20)[0]
    if va <= FUNC_RVA < va + vsize:
        file_offset = raw_off + (FUNC_RVA - va)
        break

func_bytes = data[file_offset:file_offset + FUNC_SIZE]

md = Cs(CS_ARCH_X86, CS_MODE_32)
md.detail = True
print(f"UR6ModMgr::eventGetServerIni")
print(f"Function: 0x{IMAGE_BASE + FUNC_RVA:08X} - 0x{IMAGE_BASE + FUNC_RVA + FUNC_SIZE:08X}")
print(f"Crash at:  0x{CRASH_ADDR:08X} (offset +0x{CRASH_ADDR - IMAGE_BASE - FUNC_RVA:X})")
print()
for insn in md.disasm(func_bytes, IMAGE_BASE + FUNC_RVA):
    marker = "  <--- CRASH HERE" if insn.address == CRASH_ADDR else ""
    print(f"  {insn.address:08X}: {insn.mnemonic:8s} {insn.op_str}{marker}")
