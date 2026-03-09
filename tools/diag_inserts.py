"""Diagnostic: check insert_map for duplicate indices and ATerrainInfo"""
import re, subprocess, os, sys
from collections import defaultdict, Counter

# Add tools dir to path and import the functions we need
UNDNAME = r"C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\VC\Tools\MSVC\14.29.30133\bin\Hostx64\x86\undname.exe"
HEADER = 'src/engine/EngineClasses.h'
# Read the COMMITTED version
lines_raw = subprocess.check_output(['git', 'show', 'HEAD:src/engine/EngineClasses.h']).decode('utf-8', errors='replace')

def find_class_insert_points_from(content):
    lines = content.split('\n')
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

points = find_class_insert_points_from(lines_raw)

# Check for duplicate indices
idx_to_classes = defaultdict(list)
for cls, idx in points.items():
    idx_to_classes[idx].append(cls)

print("Duplicate insert point indices:")
for idx, classes in sorted(idx_to_classes.items()):
    if len(classes) > 1:
        lines_list = lines_raw.split('\n')
        print(f"  Index {idx} ({lines_list[idx].rstrip()}): {classes}")

# Show ATerrainInfo specifically
if 'ATerrainInfo' in points:
    print(f"\nATerrainInfo insert point: {points['ATerrainInfo']}")
    lines_list = lines_raw.split('\n')
    idx = points['ATerrainInfo']
    print(f"  Line at that index: {lines_list[idx].rstrip()}")
    
# Check: which class's insert point is at or near index 4959 (UShadowBitmapMaterial's };)
for idx in range(4955, 4965):
    if idx in idx_to_classes:
        print(f"\nClasses at index {idx}: {idx_to_classes[idx]}")
