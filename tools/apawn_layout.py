"""Compute APawn layout to find offset of this+0x2D0 and this+0x3E0"""
import re

content = open('src/engine/Inc/EngineClasses.h').read()
start = content.find('class ENGINE_API APawn : public AActor')
end = content.find('\nclass ENGINE_API AController')
if end == -1:
    end = content.find('\nclass ENGINE_API APlayerController')
body = content[start:end]
lines = body.split('\n')

fields = []
bit_accumulator = 0
prev_was_bitfield = False
bitfield_names = []

for line in lines:
    s = line.strip()
    if not s or s.startswith('//') or s.startswith('DECLARE') or s.startswith('virtual') or 'class ENGINE_API' in s or s in ('{', 'public:', '}'):
        continue

    m_byte = re.match(r'BYTE\s+(\w+)(\[(\d+)\])?;', s)
    m_int = re.match(r'INT\s+(\w+)(\[(\d+)\])?;', s)
    m_bit = re.match(r'BITFIELD\s+(\w+)\s*:\s*(\d+);', s)
    m_float = re.match(r'FLOAT\s+(\w+)(\[(\d+)\])?;', s)
    m_ptr = re.match(r'class\s+\w+\*\s+(\w+)(\[(\d+)\])?;', s)
    m_fname = re.match(r'FName\s+(\w+)(\[(\d+)\])?;', s)
    m_dword = re.match(r'DWORD\s+(\w+);', s)

    def flush_bits():
        global bit_accumulator, prev_was_bitfield, bitfield_names
        if prev_was_bitfield and bit_accumulator > 0:
            fields.append(('bitfield', '|'.join(bitfield_names[:4]) + '...', 4))
            bit_accumulator = 0
            prev_was_bitfield = False
            bitfield_names = []

    if m_byte:
        flush_bits()
        cnt = int(m_byte.group(3)) if m_byte.group(3) else 1
        fields.append(('BYTE', m_byte.group(1), cnt))
    elif m_int or m_dword:
        flush_bits()
        mm = m_int or m_dword
        cnt = int(mm.group(2)) if (m_int and mm.group(2)) else 1
        fields.append(('INT', mm.group(1), cnt * 4))
    elif m_bit:
        bits = int(m_bit.group(2))
        if not prev_was_bitfield or bit_accumulator + bits > 32:
            flush_bits()
        bit_accumulator += bits
        prev_was_bitfield = True
        bitfield_names.append(m_bit.group(1))
    elif m_float:
        flush_bits()
        cnt = int(m_float.group(3)) if m_float.group(3) else 1
        fields.append(('FLOAT', m_float.group(1), cnt * 4))
    elif m_ptr:
        flush_bits()
        cnt = int(m_ptr.group(3)) if m_ptr.group(3) else 1
        fields.append(('PTR', m_ptr.group(1), cnt * 4))
        if m_ptr.group(1) == 'Controller':
            break
    elif m_fname:
        flush_bits()
        cnt = int(m_fname.group(3)) if m_fname.group(3) else 1
        fields.append(('FName', m_fname.group(1), cnt * 8))

# Compute cumulative offsets
apawn_offset = 0
print("APawn field layout:")
for ftype, name, size in fields:
    align = 4 if size >= 4 else size
    if ftype == 'BYTE':
        align = 1
    if ftype == 'FName':
        align = 4
    if align > 1:
        apawn_offset = (apawn_offset + align - 1) & ~(align - 1)
    print("  %-10s %-50s apawn+0x%03X" % (ftype, name[:50], apawn_offset))
    apawn_offset += size

print("\nTotal APawn offset to Controller: apawn+0x%X" % apawn_offset)
aactor_size = 0x4EC - apawn_offset
print("=> AActor size: 0x4EC - 0x%X = 0x%X" % (apawn_offset, aactor_size))
print("=> this+0x2D0 corresponds to APawn field at apawn+0x%X" % (0x2D0 - aactor_size))
print("=> this+0x3E0 corresponds to APawn field at apawn+0x%X" % (0x3E0 - aactor_size))
print("=> this+0xA0  corresponds to APawn field at apawn+0x%X" % (0xA0  - aactor_size if 0xA0 >= aactor_size else -1))
print("=> this+0x39C corresponds to APawn field at apawn+0x%X" % (0x39C - aactor_size))
