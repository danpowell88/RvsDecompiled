"""Debug: revert header, run gen_impl3 logic, dump exactly what insert_map contains"""
import re, subprocess, os
from collections import defaultdict

UNDNAME = r"C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\VC\Tools\MSVC\14.29.30133\bin\Hostx64\x86\undname.exe"
HEADER = 'src/engine/EngineClasses.h'
STUB_FILES = [
    'src/engine/EngineStubs1.cpp',
    'src/engine/EngineStubs2.cpp',
    'src/engine/EngineStubs3.cpp',
    'src/engine/EngineStubs4.cpp',
]

# First revert
os.system('git checkout -- src/engine/EngineClasses.h')

# Read header
with open(HEADER) as f:
    header_content = f.read()
    header_lines_list = header_content.split('\n')

with open(HEADER) as f:
    header_lines = f.readlines()

# Verify they match
print(f"header_content split: {len(header_lines_list)} lines")
print(f"header_lines readlines: {len(header_lines)} lines")

# Check line 4959 (0-indexed) in both
print(f"\nheader_lines_list[4959] = {repr(header_lines_list[4959])}")
print(f"header_lines[4959] = {repr(header_lines[4959])}")
print(f"header_lines_list[4960] = {repr(header_lines_list[4960])}")
print(f"header_lines[4960] = {repr(header_lines[4960])}")
print(f"header_lines_list[4961] = {repr(header_lines_list[4961])}")
print(f"header_lines[4961] = {repr(header_lines[4961])}")

# Now run insert_points on the READLINES version (what gen_impl3 uses)
def find_class_insert_points():
    # This reads the file AGAIN - just like gen_impl3.py does
    with open(HEADER) as f:
        lines = f.readlines()
    points = {}
    for i, line in enumerate(lines):
        m = re.match(r'class\s+ENGINE_API\s+(\w+)', line)
        if not m:
            continue
        cls = m.group(1)
        if ';' in line and '{' not in line:
            continue
        if '{' in line and '};' in line:
            points[cls] = None
            continue
        depth = 0
        entered = False
        for j in range(i, len(lines)):
            depth += lines[j].count('{') - lines[j].count('}')
            if depth > 0:
                entered = True
            if entered and depth == 0:
                points[cls] = j
                break
        else:
            points[cls] = None
    return {k: v for k, v in points.items() if v is not None}

insert_pts = find_class_insert_points()

# Check ALL classes around the problem area (insert points 4955-4965)
print("\n=== Classes with insert points 4955-4965 ===")
for cls, idx in sorted(insert_pts.items(), key=lambda x: x[1]):
    if 4955 <= idx <= 4965:
        print(f"  {cls} -> {idx}: {header_lines[idx].rstrip()}")

# Now simulate the patching for JUST ATerrainInfo
# What methods does gen_impl3 detect for ATerrainInfo?

SIG_RE = re.compile(
    r'(?:public|protected|private):\s*'
    r'(virtual\s+)?'
    r'(.*?)\s+'
    r'(?:__thiscall|__cdecl)\s+'
    r'(\w+(?:<[^>]+>)?)::(\w+(?:<[^>]+>)?|operator\s*[^\(]+)'
    r'\((.*)\)'
    r'(\s*const)?'
)

def get_declared_methods():
    with open(HEADER) as f:
        content = f.read()
    declared = defaultdict(set)
    current = None
    for line in content.split('\n'):
        m = re.match(r'class\s+ENGINE_API\s+(\w+)', line)
        if m and ';' not in line:
            current = m.group(1)
            continue
        if line.strip() == '};':
            current = None
            continue
        if current:
            stripped = line.strip()
            m2 = re.match(r'(?:virtual\s+)?(?:static\s+)?[\w\s\*\&<>,]+\s+(\w+)\s*\(', stripped)
            if m2 and stripped.endswith(';') and not stripped.startswith('DECLARE_') and not stripped.startswith('//'):
                declared[current].add(m2.group(1))
    return declared

decl_methods = get_declared_methods()
print(f"\n=== ATerrainInfo declared methods ({len(decl_methods.get('ATerrainInfo', set()))}) ===")
print(f"  {decl_methods.get('ATerrainInfo', set())}")
print(f"\nATerrainInfo insert point: {insert_pts.get('ATerrainInfo', 'NOT FOUND')}")
