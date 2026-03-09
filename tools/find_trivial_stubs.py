"""
Find which remaining stubs have trivial implementations in source that are being optimized away.
Outputs the specific functions and their current bodies.
"""
import re, subprocess, os
from collections import defaultdict

DUMPBIN = r'C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\VC\Tools\MSVC\14.29.30133\bin\Hostx64\x86\dumpbin.exe'
UNDNAME = r'C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\VC\Tools\MSVC\14.29.30133\bin\Hostx64\x86\undname.exe'

# Collect all remaining stubs with mangled names
stubs = []
for fname in ['src/engine/EngineStubs1.cpp', 'src/engine/EngineStubs2.cpp', 
              'src/engine/EngineStubs3.cpp', 'src/engine/EngineStubs4.cpp']:
    with open(fname) as f:
        for line in f:
            m = re.search(r'/alternatename:(\S+)=', line)
            if m:
                stubs.append(m.group(1))

# Demangle
demangled = {}
for s in stubs:
    r = subprocess.run([UNDNAME, s], capture_output=True, text=True)
    for line in r.stdout.splitlines():
        if line.startswith('is :-'):
            demangled[s] = line[6:].strip().strip('"')
            break

# Collect all symbols from .obj files  
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
            all_obj_syms.add(m.group(1))

# For each stub, extract the class::method name and search in source files
impl_files = [
    'src/engine/EngineBatchImpl.cpp',
    'src/engine/EngineBatchImpl2.cpp', 
    'src/engine/EngineBatchImpl3.cpp',
    'src/engine/EngineEvents.cpp',
    'src/engine/EngineVirtuals.cpp'
]

# Read all source files
source_content = {}
for f in impl_files:
    if os.path.exists(f):
        source_content[f] = open(f).read()

# Skip __FUNC_NAME__ and vftable - those are special
actionable_stubs = [(s, demangled[s]) for s in stubs 
                    if '__FUNC_NAME__' not in s and '??_7' not in s]

print(f"Actionable stubs (excluding __FUNC_NAME__ and vftable): {len(actionable_stubs)}")

# For each stub, try to find its implementation in source
# Extract class::method from demangled name
found_in_source = []
not_found = []

for mangled, dem in actionable_stubs:
    # Extract class::method  
    # Pattern: access: return_type class::method(args)
    m = re.search(r'(\w+)::(\w+|operator[^(]+|~\w+)', dem)
    if not m:
        # Free functions like operator<<
        m2 = re.search(r'(operator<<|operator>>|operator\+|operator-)', dem) 
        if m2:
            not_found.append((mangled, dem, "free function"))
            continue
        # K* functions
        m3 = re.match(r'.*?(\w+)\(', dem)
        if m3:
            func_name = m3.group(1)
            found = False
            for f, content in source_content.items():
                if func_name + '(' in content:
                    found_in_source.append((mangled, dem, f, func_name))
                    found = True
                    break
            if not found:
                not_found.append((mangled, dem, "free function not found"))
        continue
    
    cls, method = m.group(1), m.group(2)
    search = f"{cls}::{method}"
    
    found = False
    for f, content in source_content.items():
        if search in content:
            found_in_source.append((mangled, dem, f, search))
            found = True
            break
    
    if not found:
        not_found.append((mangled, dem, f"{cls}::{method} not in any impl file"))

print(f"\n=== FOUND IN SOURCE (likely trivial body being optimized away): {len(found_in_source)} ===")
for mangled, dem, src_file, search in found_in_source:
    in_obj = "IN OBJ" if mangled in all_obj_syms else "NOT in obj"
    print(f"  [{in_obj}] {dem[:100]}")
    print(f"    source: {src_file} (search: {search})")

print(f"\n=== NOT FOUND IN SOURCE (need implementation): {len(not_found)} ===")
for mangled, dem, reason in not_found:
    print(f"  {dem[:100]}")
    print(f"    reason: {reason}")
