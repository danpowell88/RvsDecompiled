"""Dump vtable entries for a given class by finding where a known function appears in vtable."""
import struct, sys

with open('retail/system/Engine.dll','rb') as f:
    data = f.read()
base = 0x10300000

def rva_to_offset(rva):
    pe_off = struct.unpack_from('<I', data, 0x3C)[0]
    nsec = struct.unpack_from('<H', data, pe_off+6)[0]
    sec_off = pe_off + 0xF8
    for i in range(nsec):
        s = sec_off + i*40
        va = struct.unpack_from('<I', data, s+12)[0]
        vs = struct.unpack_from('<I', data, s+16)[0]
        raw = struct.unpack_from('<I', data, s+20)[0]
        rs = struct.unpack_from('<I', data, s+24)[0]
        if va <= rva < va + max(vs, rs):
            return raw + (rva - va)
    return None

exports = {}
with open('build/retail_engine_exports.txt', encoding='utf-16-le') as f:
    for line in f:
        parts = line.strip().split()
        if len(parts) >= 4:
            try:
                rva = int(parts[2], 16)
                exports[rva] = parts[3]
            except:
                pass

# Export lookup: VA -> name
va_to_name = {(base + rva): name for rva, name in exports.items()}

# AProjector::TickSpecial is at RVA 0x60C0
# In the vtable, TickSpecial is called via [this->vtable + 0x190] = slot 100
# So the vtable should contain the VA of TickSpecial at position 100

tickspecial_va = base + 0x60C0
target_bytes = struct.pack('<I', tickspecial_va)

print(f'Searching for AProjector::TickSpecial VA 0x{tickspecial_va:x} in binary...')

# Find all occurrences of the TickSpecial VA in the binary
positions = []
pos = 0
while True:
    pos = data.find(target_bytes, pos)
    if pos == -1:
        break
    positions.append(pos)
    pos += 1

print(f'Found at {len(positions)} positions: {[hex(p) for p in positions]}')

for pos in positions:
    # If this is at vtable slot 100 (offset 0x190 from vtable start),
    # then vtable_start = pos - 100*4 = pos - 0x190
    vtable_start_off = pos - 0x190
    if vtable_start_off < 0:
        continue
    
    # Check a range around slot 100 to see if this looks like a vtable
    print(f'\n--- Possible vtable at file offset 0x{vtable_start_off:x} ---')
    for slot in range(97, 115):
        entry_off = vtable_start_off + slot * 4
        if entry_off + 4 > len(data):
            break
        fn_va = struct.unpack_from('<I', data, entry_off)[0]
        fn_rva = fn_va - base
        name = va_to_name.get(fn_va, f'<unknown 0x{fn_va:x}>')
        marker = ' <-- TickSpecial' if slot == 100 else ''
        print(f'  [{slot:3d}] 0x{fn_va:x} = {name}{marker}')
