"""Parse Core.u to extract iNative ordinals for all UFunction objects."""
import struct

path = r'c:\Users\danpo\Desktop\rvs\retail\system\Core.u'
data = open(path, 'rb').read()

def read_index(data, pos):
    """Read a compact index from UE2 package."""
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
                if b3 & 0x80:
                    b4 = data[pos]; pos += 1
                    val |= (b4 & 0x1F) << 27
    if neg:
        val = -val
    return val, pos

# Parse names
names = []
pos = 0x44
for i in range(428):
    name_len, pos = read_index(data, pos)
    if name_len < 0:
        name_len = -name_len
    name_str = data[pos:pos+name_len-1].decode('ascii', errors='replace')
    pos += name_len
    flags = struct.unpack_from('<I', data, pos)[0]
    pos += 4
    names.append(name_str)

# Parse imports
imports = []
pos = 0x5648
for i in range(17):
    class_package, pos = read_index(data, pos)
    class_name, pos = read_index(data, pos)
    package = struct.unpack_from('<i', data, pos)[0]; pos += 4
    object_name, pos = read_index(data, pos)
    imports.append({
        'name': names[object_name] if 0 <= object_name < len(names) else '?'
    })

# Parse exports
exports = []
pos = 0x56E0
for i in range(775):
    class_index, pos = read_index(data, pos)
    super_index, pos = read_index(data, pos)
    group = struct.unpack_from('<i', data, pos)[0]; pos += 4
    object_name, pos = read_index(data, pos)
    object_flags = struct.unpack_from('<I', data, pos)[0]; pos += 4
    serial_size, pos = read_index(data, pos)
    serial_offset = 0
    if serial_size > 0:
        serial_offset, pos = read_index(data, pos)
    exports.append({
        'class_index': class_index,
        'serial_size': serial_size,
        'serial_offset': serial_offset,
        'name': names[object_name] if 0 <= object_name < len(names) else '?'
    })

def get_class_name(ci):
    if ci > 0 and ci - 1 < len(exports):
        return exports[ci - 1]['name']
    elif ci < 0 and (-ci) - 1 < len(imports):
        return imports[(-ci) - 1]['name']
    return '?'

def parse_function(exp):
    """Parse a UFunction's serial data - reading iNative/OperPrec/FuncFlags from end."""
    sz = exp['serial_size']
    if sz < 7:
        return None
    off = exp['serial_offset']
    try:
        # Read from the END of the serial data:
        # Layout: [...fields...] iNative(WORD) OperPrec(BYTE) FuncFlags(DWORD) [RepOffset(WORD) if FUNC_Net]
        # First read FuncFlags at end-4 to check for FUNC_Net
        func_flags = struct.unpack_from('<I', data, off + sz - 4)[0]
        FUNC_Net = 0x00000040
        if func_flags & FUNC_Net and sz >= 9:
            # Has RepOffset (2 bytes) after FuncFlags
            inative = struct.unpack_from('<H', data, off + sz - 9)[0]
            oper_prec = data[off + sz - 7]
            rep_offset = struct.unpack_from('<H', data, off + sz - 2)[0]
        else:
            inative = struct.unpack_from('<H', data, off + sz - 7)[0]
            oper_prec = data[off + sz - 5]
        return {
            'iNative': inative,
            'oper_prec': oper_prec,
            'func_flags': func_flags,
        }
    except Exception as e:
        return None

# Parse all Function exports
results = []
for i, exp in enumerate(exports):
    if get_class_name(exp['class_index']) != 'Function':
        continue
    parsed = parse_function(exp)
    if parsed is None:
        continue
    is_native = bool(parsed['func_flags'] & 0x0400)
    if not is_native and parsed['iNative'] == 0:
        continue
    results.append({
        'name': exp['name'],
        'iNative': parsed['iNative'],
        'oper_prec': parsed['oper_prec'],
        'func_flags': parsed['func_flags'],
    })

# Sort by iNative
results.sort(key=lambda x: (x['iNative'], x['name']))

print("\nNative functions from Core.u (package version 118):")
print(f"{'Name':<45} {'iNative':>7} {'Prec':>4} {'FuncFlags':>10}")
print("-" * 70)
for r in results:
    flag_str = ""
    if r['func_flags'] & 0x1000: flag_str += "Op "
    if r['func_flags'] & 0x0010: flag_str += "Pre "
    if r['func_flags'] & 0x0400: flag_str += "Nat "
    if r['func_flags'] & 0x0001: flag_str += "Fin "
    if r['func_flags'] & 0x2000: flag_str += "Sta "
    print(f"{r['name']:<45} {r['iNative']:>7} {r['oper_prec']:>4} {flag_str}")

print(f"\nTotal native functions: {len(results)}")
# Count by range
low = sum(1 for r in results if 0 < r['iNative'] < 256)
mid = sum(1 for r in results if 256 <= r['iNative'] < 1000)
high = sum(1 for r in results if r['iNative'] >= 1000)
zero = sum(1 for r in results if r['iNative'] == 0)
print(f"  iNative 1-255: {low}")
print(f"  iNative 256-999: {mid}")
print(f"  iNative >= 1000: {high}")
print(f"  iNative == 0 (bare native): {zero}")

# Build Core.u ordinal→name mapping
core_ordinals = {}  # ordinal → name
core_names = {}  # name → ordinal
for r in results:
    if r['iNative'] > 0:
        core_ordinals[r['iNative']] = r['name']
        core_names[r['name']] = r['iNative']

# Parse IMPLEMENT_FUNCTION entries from UnScript.cpp
import re, os
cpp_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'src', 'core', 'UnScript.cpp')
cpp_data = open(cpp_path, 'r', errors='replace').read()

# Extract IMPLEMENT_FUNCTION( ClassName, ordinal_expr, exec_funcname )
impl_funcs = []  # (ordinal, exec_name, raw_text)
for m in re.finditer(r'IMPLEMENT_FUNCTION\s*\(\s*\w+\s*,\s*([^,]+?)\s*,\s*(exec\w+)\s*\)', cpp_data):
    expr = m.group(1).strip()
    name = m.group(2).strip()
    # Evaluate numeric expressions
    try:
        if expr.startswith('EX_'):
            ordinal = None  # EX_* bytecode
        else:
            ordinal = eval(expr)
    except:
        ordinal = None
    impl_funcs.append((ordinal, name, expr))

# Build C++ name→ordinal mapping
cpp_name_to_ord = {}  # exec_name → ordinal 
cpp_ord_to_name = {}  # ordinal → exec_name
for ordinal, name, expr in impl_funcs:
    if ordinal is not None:
        cpp_name_to_ord[name] = ordinal
        cpp_ord_to_name[ordinal] = name

# Map exec function names to Core.u names
# Core.u uses short names (Add_IntInt) while C++ uses exec prefix (execAdd_IntInt)
# Some naming differences: StringString→StrStr, DotVectorVector→Dot_VectorVector
def exec_to_core_name(exec_name):
    """Convert exec function name to Core.u function name."""
    n = exec_name.replace('exec', '', 1)
    # Known naming differences
    replacements = {
        'Concat_StringString': 'Concat_StrStr',
        'Less_StringString': 'Less_StrStr',
        'Greater_StringString': 'Greater_StrStr',
        'LessEqual_StringString': 'LessEqual_StrStr',
        'GreaterEqual_StringString': 'GreaterEqual_StrStr',
        'EqualEqual_StringString': 'EqualEqual_StrStr',
        'NotEqual_StringString': 'NotEqual_StrStr',
        'ComplementEqual_StringString': 'ComplementEqual_StrStr',
        'At_StringString': 'At_StrStr',
        'Dot_VectorVector': 'Dot_VectorVector',
        'Cross_VectorVector': 'Cross_VectorVector',
    }
    return replacements.get(n, n)

# Cross-reference
print("\n=== CROSS-REFERENCE: C++ vs Core.u ===\n")
print("WRONG ordinals (C++ != Core.u):")
print(f"{'exec Function':<45} {'C++ Ord':>7} {'Core.u':>7} {'Delta':>6}")
print("-" * 70)
wrong_count = 0
for ordinal, name, expr in sorted(impl_funcs, key=lambda x: (x[0] or 0)):
    if ordinal is None:
        continue
    core_name = exec_to_core_name(name)
    if core_name in core_names:
        correct_ord = core_names[core_name]
        if ordinal != correct_ord:
            print(f"  {name:<43} {ordinal:>7} {correct_ord:>7} {ordinal-correct_ord:>+6}")
            wrong_count += 1

print(f"\nTotal wrong: {wrong_count}")

# Functions in Core.u but NOT in C++ IMPLEMENT_FUNCTION
print("\nMISSING from IMPLEMENT_FUNCTION (Core.u functions with no C++ registration):")
print(f"{'Core.u Function':<45} {'Ordinal':>7}")
print("-" * 55)
missing_count = 0
cpp_exec_names = set(exec_to_core_name(name) for _, name, _ in impl_funcs if _ is not None)
for r in sorted(results, key=lambda x: x['iNative']):
    if r['iNative'] > 0 and r['name'] not in cpp_exec_names:
        print(f"  {r['name']:<43} {r['iNative']:>7}")
        missing_count += 1
    elif r['iNative'] == 0 and r['name'] not in cpp_exec_names:
        print(f"  {r['name']:<43} {'bare':>7}")
        missing_count += 1

print(f"\nTotal missing: {missing_count}")

# Functions in C++ with ordinals matching Core.u (correct)
correct_count = 0
for ordinal, name, expr in impl_funcs:
    if ordinal is None:
        continue
    core_name = exec_to_core_name(name)
    if core_name in core_names and ordinal == core_names[core_name]:
        correct_count += 1
print(f"\nTotal CORRECT IMPLEMENT_FUNCTION entries: {correct_count}")
