"""Read float/data values from retail DLL at given absolute addresses."""
import struct, sys

dll = open('retail/system/Engine.dll','rb').read()
e_lfanew = struct.unpack_from('<I', dll, 0x3C)[0]
num_sections = struct.unpack_from('<H', dll, e_lfanew+6)[0]
opt_hdr_sz   = struct.unpack_from('<H', dll, e_lfanew+20)[0]
sects_off    = e_lfanew + 24 + opt_hdr_sz
image_base   = struct.unpack_from('<I', dll, e_lfanew+52)[0]  # PE + COFF(20) + OptHdr offset 28

def rva_to_off(rva):
    for i in range(num_sections):
        s = sects_off + i*40
        vaddr  = struct.unpack_from('<I', dll, s+12)[0]
        vsz    = struct.unpack_from('<I', dll, s+16)[0]
        rawoff = struct.unpack_from('<I', dll, s+20)[0]
        rawsz  = struct.unpack_from('<I', dll, s+24)[0]
        if vaddr <= rva < vaddr + max(vsz, rawsz):
            return rawoff + (rva - vaddr)
    return None

if '--sections' in sys.argv:
    print(f'Image base: {image_base:#x}')
    for i in range(num_sections):
        s = sects_off + i*40
        name  = dll[s:s+8].rstrip(b'\x00').decode(errors='replace')
        vaddr = struct.unpack_from('<I', dll, s+12)[0]
        vsz   = struct.unpack_from('<I', dll, s+16)[0]
        rawoff= struct.unpack_from('<I', dll, s+20)[0]
        rawsz = struct.unpack_from('<I', dll, s+24)[0]
        print(f'  {name}: VA={vaddr:#010x} Vsz={vsz:#x} Raw={rawoff:#x} Rawsz={rawsz:#x}')
    sys.exit(0)

addrs = [int(a, 16) for a in sys.argv[1:]] if len(sys.argv) > 1 else [0x10529E20, 0x10529E24]

for abs_addr in addrs:
    rva = abs_addr - image_base
    off = rva_to_off(rva)
    if off:
        f = struct.unpack_from('<f', dll, off)[0]
        b = dll[off:off+4]
        print(f'{abs_addr:#x}: float={f:.8f}  bytes={" ".join(f"{x:02X}" for x in b)}')
    else:
        print(f'{abs_addr:#x}: not in any section')
