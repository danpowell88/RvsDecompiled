"""Helper script for disassembly research."""
import struct, capstone, sys

data = open('retail/system/Engine.dll','rb').read()
cs = capstone.Cs(capstone.CS_ARCH_X86, capstone.CS_MODE_32)
IMGBASE = 0x10300000

def rva_to_fo(rva):
    # Identity mapped: fo == rva for .text (.text raw offset == vva)
    # For .rdata: raw offset == vva too (from section table)
    return rva

def va_to_fo(va):
    return rva_to_fo(va - IMGBASE)

def disasm(va, size, label=''):
    rva = va - IMGBASE
    fo = rva_to_fo(rva)
    bs = data[fo:fo+size]
    if label:
        print(f'=== {label} (VA 0x{va:X}) ===')
    for ins in cs.disasm(bs, va):
        print(f'  0x{ins.address:X}: {ins.mnemonic:<8} {ins.op_str}')
        if ins.mnemonic.startswith('ret'):
            break
    print()

def read_ptr(va):
    fo = va_to_fo(va)
    return struct.unpack_from('<I', data, fo)[0]

def read_str(va, maxlen=64):
    fo = va_to_fo(va)
    s = data[fo:fo+maxlen]
    return s.split(b'\x00')[0].decode('ascii','replace')

# --- Analyze critical Serialize functions ---
addrs = [
    (0x10300000 + 0x7C130,  250, 'AActor::Serialize'),
    (0x10300000 + 0x93120,  200, 'UEngine::Serialize'),
    (0x10300000 + 0xF7120,  200, 'UPlayer::Serialize'),
    (0x10300000 + 0xC0F60,  200, 'ULevelBase::Serialize'),
    (0x10300000 + 0xC3070,  300, 'ULevel::Serialize'),
    (0x10300000 + 0x184200, 250, 'UNetConnection::Serialize'),
    (0x10300000 + 0x18C210, 200, 'UNetDriver::Serialize'),
]

for va, size, label in addrs:
    disasm(va, size, label)
