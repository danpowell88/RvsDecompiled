"""Analyze remaining Engine.dll stubs by category."""
import subprocess, re, os
from collections import defaultdict

UNDNAME = r'C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\VC\Tools\MSVC\14.29.30133\bin\Hostx64\x86\undname.exe'
DUMPBIN = r'C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\VC\Tools\MSVC\14.29.30133\bin\Hostx64\x86\dumpbin.exe'

# Collect stubs
stubs = []
for fname in ['src/engine/EngineStubs1.cpp', 'src/engine/EngineStubs2.cpp', 
              'src/engine/EngineStubs3.cpp', 'src/engine/EngineStubs4.cpp']:
    if not os.path.exists(fname):
        continue
    with open(fname) as f:
        for line in f:
            m = re.search(r'/alternatename:(\S+)=', line)
            if m:
                stubs.append(m.group(1))

print(f"Total stubs: {len(stubs)}")

# Demangle all at once
demangled = {}
for s in stubs:
    r = subprocess.run([UNDNAME, s], capture_output=True, text=True)
    for line in r.stdout.splitlines():
        if line.startswith('is :-'):
            demangled[s] = line[6:].strip().strip('"')
            break

# Collect all symbols from impl .obj files
OBJ_DIR = r'build\src\engine\Engine.dir\Release'
all_obj_syms = set()
for obj in os.listdir(OBJ_DIR):
    if not obj.endswith('.obj'):
        continue
    r = subprocess.run([DUMPBIN, '/SYMBOLS', os.path.join(OBJ_DIR, obj)], 
                       capture_output=True, text=True)
    for line in r.stdout.splitlines():
        # External symbols
        m = re.search(r'External\s+\|\s+(\S+)', line)
        if m:
            all_obj_syms.add(m.group(1))

# Categorize
categories = defaultdict(list)
for s in stubs:
    d = demangled.get(s, s)
    
    if '__FUNC_NAME__' in s:
        categories['__FUNC_NAME__ (string constants)'].append(d)
    elif '??_7' in s:  # vftable
        categories['vftable'].append(d)
    else:
        # Extract class name
        m = re.match(r".*?(\w+)::", d)
        if m:
            cls = m.group(1)
            categories[cls].append(d)
        else:
            categories['(unknown)'].append(d)

# Check which stubs have "close" matches in .obj (possible mangling mismatches)
print("\n=== POTENTIAL MANGLING MISMATCHES ===")
mismatch_count = 0
for s in stubs:
    if '__FUNC_NAME__' in s or '??_7' in s:
        continue
    # Extract function name part (after last @@ or ?)
    # Try to find a symbol in .obj that's similar but not identical
    # Simple heuristic: replace V with U or U with V in specific positions
    variants = []
    # Try swapping V<->U for class/struct
    for i in range(len(s)):
        if i > 0 and s[i] == 'V' and s[i-1] in '@(P':
            variant = s[:i] + 'U' + s[i+1:]
            variants.append(variant)
        elif i > 0 and s[i] == 'U' and s[i-1] in '@(P':
            variant = s[:i] + 'V' + s[i+1:]
            variants.append(variant)
    
    for v in variants:
        if v in all_obj_syms and s not in all_obj_syms:
            mismatch_count += 1
            d = demangled.get(s, s)
            print(f"  MISMATCH: {d[:80]}")
            print(f"    stub:  {s}")
            print(f"    .obj:  {v}")
            break

if mismatch_count == 0:
    print("  None found")
print(f"  Total mismatches: {mismatch_count}")

# Print categories sorted by count
print("\n=== STUB CATEGORIES (by class) ===")
for cat, items in sorted(categories.items(), key=lambda x: -len(x[1])):
    print(f"\n[{cat}] ({len(items)} stubs)")
    for item in sorted(items):
        print(f"  {item[:120]}")
