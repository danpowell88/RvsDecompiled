"""
Find ALL struct/class mismatches by trying all combinations of V<->U swaps.
"""
import subprocess, re, os

DUMPBIN = r'C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\VC\Tools\MSVC\14.29.30133\bin\Hostx64\x86\dumpbin.exe'
UNDNAME = r'C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\VC\Tools\MSVC\14.29.30133\bin\Hostx64\x86\undname.exe'

# Collect stubs
stubs = set()
for fname in ['src/engine/EngineStubs1.cpp', 'src/engine/EngineStubs2.cpp', 
              'src/engine/EngineStubs3.cpp', 'src/engine/EngineStubs4.cpp']:
    with open(fname) as f:
        for line in f:
            m = re.search(r'/alternatename:(\S+)=', line)
            if m:
                stubs.add(m.group(1))

# Collect defined symbols
OBJ_DIR = r'build\src\engine\Engine.dir\Release'
all_obj_syms = set()
for obj in os.listdir(OBJ_DIR):
    if not obj.endswith('.obj'):
        continue
    r = subprocess.run([DUMPBIN, '/SYMBOLS', os.path.join(OBJ_DIR, obj)], 
                       capture_output=True, text=True)
    for line in r.stdout.splitlines():
        if 'SECT' in line:
            m = re.search(r'External\s+\|\s+(\S+)', line)
            if m:
                all_obj_syms.add(m.group(1))

# For each unresolved stub (not __FUNC_NAME__ or vftable), try all V<->U combos
unresolved = [s for s in stubs if s not in all_obj_syms 
              and '__FUNC_NAME__' not in s and '??_7' not in s]

print(f"Unresolved stubs (not __FUNC_NAME__/vftable): {len(unresolved)}")

# Find positions where V or U appears after mangling-significant chars
def find_vu_positions(mangled):
    """Find positions in mangled name where V/U indicates struct/class."""
    positions = []
    for i in range(1, len(mangled)):
        if mangled[i] in ('V', 'U'):
            prev = mangled[i-1]
            # V/U after these chars typically indicates a type name
            if prev in 'PA@Q?':  # P=pointer, A=reference, @=separator, Q=const ptr
                positions.append(i)
            # Also check for backreference: V0, U0, V1, U1 etc.
            if i+1 < len(mangled) and mangled[i+1].isdigit():
                positions.append(i)
    return list(set(positions))

from itertools import product

all_matches = []
for stub in sorted(unresolved):
    positions = find_vu_positions(stub)
    if not positions:
        continue
    
    # Try all 2^n combinations (but limit to reasonable count)
    if len(positions) > 10:
        continue  # Too many combos
    
    found = False
    for combo in product([False, True], repeat=len(positions)):
        if not any(combo):  # Skip no-change case
            continue
        variant = list(stub)
        for pos, flip in zip(positions, combo):
            if flip:
                if variant[pos] == 'V':
                    variant[pos] = 'U'
                elif variant[pos] == 'U':
                    variant[pos] = 'V'
        variant_str = ''.join(variant)
        if variant_str in all_obj_syms:
            # Found a match! Record the changes
            changes = []
            for pos, flip in zip(positions, combo):
                if flip:
                    changes.append((pos, stub[pos], variant_str[pos]))
            all_matches.append((stub, variant_str, changes))
            found = True
            break

print(f"\nMatches found via V/U swap: {len(all_matches)}")

# Analyze which type names need to change
type_changes_needed = {}  # type_name -> 'struct' or 'class'
for stub, variant, changes in all_matches:
    for pos, from_char, to_char in changes:
        # Extract type name after V/U
        if pos + 1 < len(stub) and stub[pos+1].isdigit():
            # Back-reference (V0, U0, V1, etc.) - the type is the class itself
            type_name = f"(self-ref {stub[pos:pos+2]})"
        else:
            name_start = pos + 1
            name_end = stub.find('@', name_start)
            if name_end > 0:
                type_name = stub[name_start:name_end]
            else:
                type_name = f"(unknown at pos {pos})"
        
        if from_char == 'V':
            # stub has V(class) but we need U(struct) in our code's .obj
            # Actually: stub is what retail expects, .obj has the swapped version
            # stub V = retail expects class, our .obj produces struct with U
            # WAIT: the stub is what we NEED to match. If stub has V, retail used class.
            # If our .obj has U, our code has struct.
            # So we need: change struct -> class in our code
            need = 'class'
        else:  # from_char == 'U'
            # stub has U(struct), our .obj has V(class)
            # So we need: change class -> struct in our code
            need = 'struct'
        
        if type_name not in type_changes_needed or type_changes_needed[type_name] == need:
            type_changes_needed[type_name] = need

# Wait, I had the logic backwards. Let me re-think.
# The stub mangled name = what the RETAIL game exported (the target we want to match)
# The .obj mangled name = what OUR code produces
# If stub has 'U' at a position and our .obj has 'V', it means:
#   - Retail used 'struct' (U) for that type  
#   - Our code uses 'class' (V) for that type
#   - We need to change our code to use 'struct'

print("\n=== TYPE CHANGES NEEDED ===")
for stub, variant, changes in sorted(all_matches, key=lambda x: x[0]):
    r = subprocess.run([UNDNAME, stub], capture_output=True, text=True)
    dem = ""
    for line in r.stdout.splitlines():
        if line.startswith('is :-'):
            dem = line[6:].strip().strip('"')
    
    change_desc = []
    for pos, stub_char, obj_char in changes:
        if pos + 1 < len(stub) and stub[pos+1].isdigit():
            tname = "(self-ref)"
        else:
            nstart = pos + 1
            nend = stub.find('@', nstart)
            tname = stub[nstart:nend] if nend > 0 else "???"
        
        if stub_char == 'U':
            change_desc.append(f"  class {tname} in our code -> needs struct (retail)")
        else:  # stub_char == 'V'
            change_desc.append(f"  struct {tname} in our code -> needs class (retail)")
    
    print(f"\n{dem[:120]}")
    for c in change_desc:
        print(c)

# Summary: unique type changes
print("\n\n=== SUMMARY: Unique type changes needed ===")
summary = {}
for stub, variant, changes in all_matches:
    for pos, stub_char, obj_char in changes:
        if pos + 1 < len(stub) and stub[pos+1].isdigit():
            tname = "(self-ref in " + stub.split('@')[1] + ")" if '@' in stub else "(self-ref)"
        else:
            nstart = pos + 1
            nend = stub.find('@', nstart)
            tname = stub[nstart:nend] if nend > 0 else "???"
        
        direction = "struct->class" if stub_char == 'V' else "class->struct"
        key = (tname, direction)
        summary[key] = summary.get(key, 0) + 1

for (tname, direction), count in sorted(summary.items()):
    print(f"  {tname}: {direction} ({count} stubs affected)")
