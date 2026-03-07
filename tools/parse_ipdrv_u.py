"""Parse IpDrv.u to extract iNative ordinals for all native UFunction objects."""
import struct

data = open(r'c:\Users\danpo\Desktop\rvs\retail\system\IpDrv.u', 'rb').read()

def read_index(data, pos):
    b0 = data[pos]; pos += 1
    neg = (b0 & 0x80) != 0
    val = b0 & 0x3F
    if b0 & 0x40:
        b1 = data[pos]; pos += 1
        val |= (b1 & 0x7F) << 6
        if b1 & 0x80:
            b2 = data[pos]; pos += 1
            val |= (b2 & 0x7F) << 13
            if b2 & 0x80:
                b3 = data[pos]; pos += 1
                val |= (b3 & 0x7F) << 20
    if neg:
        val = -val
    return val, pos

# Parse header
name_count  = struct.unpack_from('<I', data, 12)[0]
name_offset = struct.unpack_from('<I', data, 16)[0]
exp_count   = struct.unpack_from('<I', data, 20)[0]
exp_offset  = struct.unpack_from('<I', data, 24)[0]
imp_count   = struct.unpack_from('<I', data, 28)[0]
imp_offset  = struct.unpack_from('<I', data, 32)[0]
print(f"Package: names={name_count}@0x{name_offset:x}  exports={exp_count}@0x{exp_offset:x}  imports={imp_count}@0x{imp_offset:x}")

# Parse name table
names = []
pos = name_offset
for i in range(name_count):
    l, pos = read_index(data, pos)
    if l < 0: l = -l
    names.append(data[pos:pos+l-1].decode('ascii', 'replace'))
    pos += l + 4  # skip EObjectFlags

# Parse imports
imports = []
pos = imp_offset
for i in range(imp_count):
    _, pos = read_index(data, pos)   # ClassPackage
    _, pos = read_index(data, pos)   # ClassName
    pos += 4                          # Package
    nm, pos = read_index(data, pos)  # ObjectName
    imports.append(names[nm] if 0 <= nm < len(names) else '?')

# Parse exports
exports = []
pos = exp_offset
for i in range(exp_count):
    ci, pos  = read_index(data, pos)  # ClassIndex
    si, pos  = read_index(data, pos)  # SuperIndex
    pos += 4                           # Group
    nm, pos  = read_index(data, pos)  # ObjectName
    pos += 4                           # ObjectFlags
    sz, pos  = read_index(data, pos)  # SerialSize
    so = 0
    if sz > 0:
        so, pos = read_index(data, pos)  # SerialOffset

    if ci > 0 and ci - 1 < len(exports):
        cn = exports[ci - 1]['name']
    elif ci < 0 and (-ci) - 1 < len(imports):
        cn = imports[(-ci) - 1]
    else:
        cn = '?'

    exports.append({'name': names[nm] if 0 <= nm < len(names) else '?',
                    'class': cn, 'size': sz, 'offset': so})

FUNC_Native = 0x0400
FUNC_Net    = 0x00000040

print()
print(f"{'Function':<40} {'iNative':>8}")
print('-' * 50)

results = []
for exp in exports:
    if exp['class'] != 'Function' or exp['size'] < 7:
        continue
    off, sz = exp['offset'], exp['size']
    try:
        func_flags = struct.unpack_from('<I', data, off + sz - 4)[0]
        if not (func_flags & FUNC_Native):
            continue
        if func_flags & FUNC_Net and sz >= 9:
            inative = struct.unpack_from('<H', data, off + sz - 9)[0]
        else:
            inative = struct.unpack_from('<H', data, off + sz - 7)[0]
        results.append((exp['name'], inative))
    except Exception as e:
        pass

results.sort(key=lambda x: x[1])
for name, inative in results:
    print(f"{name:<40} {inative:>8}")

print(f"\nTotal native functions: {len(results)}")
