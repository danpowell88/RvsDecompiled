"""
Compare mangled names between stubs and .obj to find ALL struct/class mismatches.
Now that #pragma optimize("", off) is in place, many symbols exist but with wrong mangling.
"""
import subprocess, re, os
from collections import defaultdict

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

# Collect ALL defined symbols from .obj files
OBJ_DIR = r'build\src\engine\Engine.dir\Release'
all_obj_syms = set()
for obj in os.listdir(OBJ_DIR):
    if not obj.endswith('.obj'):
        continue
    r = subprocess.run([DUMPBIN, '/SYMBOLS', os.path.join(OBJ_DIR, obj)], 
                       capture_output=True, text=True)
    for line in r.stdout.splitlines():
        m = re.search(r'External\s+\|\s+(\S+)', line)
        if m:
            sym = m.group(1)
            # Only DEFINED (has SECT*) symbols matter
            if 'SECT' in line:
                all_obj_syms.add(sym)

print(f"Total stubs: {len(stubs)}")
print(f"Total defined obj symbols: {len(all_obj_syms)}")

# Check for V<->U mismatches
# In MSVC mangling: V = class, U = struct
# We want to find stubs where swapping V for U (or vice versa) at specific positions
# would match an existing .obj symbol

mismatches = []
for stub in sorted(stubs):
    if stub in all_obj_syms:
        continue  # Already resolved
    if '__FUNC_NAME__' in stub or '??_7' in stub:
        continue  # Skip vftable and __FUNC_NAME__
    
    # Try all single-character V<->U swaps
    for i in range(len(stub)):
        if stub[i] == 'V':
            variant = stub[:i] + 'U' + stub[i+1:]
            if variant in all_obj_syms:
                mismatches.append((stub, variant, i, 'stub=class(V), obj=struct(U)'))
                break
        elif stub[i] == 'U':
            variant = stub[:i] + 'V' + stub[i+1:]
            if variant in all_obj_syms:
                mismatches.append((stub, variant, i, 'stub=struct(U), obj=class(V)'))
                break
    else:
        # Try multi-character swaps (multiple V/U differences)
        # Generate variant with ALL V->U and U->V swaps in meaningful positions
        pass

print(f"\n=== SINGLE V/U SWAP MISMATCHES: {len(mismatches)} ===")
# Group by the type that needs changing
needs_struct = []  # Our code has class, stub wants struct
needs_class = []   # Our code has struct, stub wants class

for stub, variant, pos, direction in mismatches:
    # Demangle stub for readability
    r = subprocess.run([UNDNAME, stub], capture_output=True, text=True)
    demangled = ""
    for line in r.stdout.splitlines():
        if line.startswith('is :-'):
            demangled = line[6:].strip().strip('"')
    
    if 'obj=struct' in direction:
        needs_struct.append((stub, variant, demangled))
    else:
        needs_class.append((stub, variant, demangled))

if needs_struct:
    print(f"\n--- Need to change CLASS -> STRUCT in our code ({len(needs_struct)}) ---")
    # Group by the type name that differs
    type_changes = defaultdict(list)
    for stub, variant, dem in needs_struct:
        # Find what type differs
        for i in range(len(stub)):
            if stub[i] != variant[i]:
                # Extract type name after V/U
                name_start = i + 1
                name_end = stub.find('@', name_start)
                if name_end > 0:
                    type_name = stub[name_start:name_end]
                else:
                    type_name = "???"
                type_changes[type_name].append(dem)
                break
    for tname, dems in sorted(type_changes.items(), key=lambda x: -len(x[1])):
        print(f"  Change 'class {tname}' -> 'struct {tname}': {len(dems)} stubs")
        for d in dems[:3]:
            print(f"    {d[:100]}")
        if len(dems) > 3:
            print(f"    ... and {len(dems)-3} more")

if needs_class:
    print(f"\n--- Need to change STRUCT -> CLASS in our code ({len(needs_class)}) ---")
    type_changes = defaultdict(list)
    for stub, variant, dem in needs_class:
        for i in range(len(stub)):
            if stub[i] != variant[i]:
                name_start = i + 1
                name_end = stub.find('@', name_start)
                if name_end > 0:
                    type_name = stub[name_start:name_end]
                else:
                    type_name = "???"
                type_changes[type_name].append(dem)
                break
    for tname, dems in sorted(type_changes.items(), key=lambda x: -len(x[1])):
        print(f"  Change 'struct {tname}' -> 'class {tname}': {len(dems)} stubs")
        for d in dems[:3]:
            print(f"    {d[:100]}")
        if len(dems) > 3:
            print(f"    ... and {len(dems)-3} more")

# Now try multi-swap: change ALL V->U or U->V at non-function-name positions
print(f"\n=== CHECKING MULTI-SWAP MISMATCHES ===")
unresolved_after_single = set()
for stub in stubs:
    if stub in all_obj_syms:
        continue
    if '__FUNC_NAME__' in stub or '??_7' in stub:
        continue
    if any(stub == s for s, _, _, _ in mismatches):
        continue
    unresolved_after_single.add(stub)

multi_matches = []
for stub in sorted(unresolved_after_single):
    # Try swapping ALL V at parameter positions (after @@ or after P, A, Q markers)
    # Build variant by swapping V->U everywhere
    variant = list(stub)
    changed = False
    for i in range(len(variant)):
        if variant[i] == 'V' and i > 0 and stub[i-1] in 'PA@Q':
            variant[i] = 'U'
            changed = True
    variant = ''.join(variant)
    if changed and variant in all_obj_syms:
        multi_matches.append((stub, variant))
        continue
    
    # Try U->V
    variant = list(stub)
    changed = False
    for i in range(len(variant)):
        if variant[i] == 'U' and i > 0 and stub[i-1] in 'PA@Q':
            variant[i] = 'V'
            changed = True
    variant = ''.join(variant)
    if changed and variant in all_obj_syms:
        multi_matches.append((stub, variant))

print(f"Multi-swap matches: {len(multi_matches)}")
for stub, variant in multi_matches[:10]:
    r = subprocess.run([UNDNAME, stub], capture_output=True, text=True)
    dem = ""
    for line in r.stdout.splitlines():
        if line.startswith('is :-'):
            dem = line[6:].strip().strip('"')
    print(f"  {dem[:100]}")
    # Show the differences
    diffs = []
    for i in range(min(len(stub), len(variant))):
        if stub[i] != variant[i]:
            diffs.append(f"pos {i}: stub={stub[i]} obj={variant[i]}")
    print(f"    diffs: {diffs}")
