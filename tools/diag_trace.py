"""Trace exactly what insert_map does near the problem area"""
import re, subprocess
from collections import defaultdict

HEADER = 'src/engine/EngineClasses.h'

# Read COMMITTED version (what gen_impl3 reads)
committed = subprocess.check_output(
    ['git', 'show', 'HEAD:src/engine/EngineClasses.h']
).decode('utf-8', errors='replace').split('\n')

# Run the SAME find_class_insert_points logic
def find_class_insert_points(lines):
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

pts = find_class_insert_points(committed)

# Now read the PATCHED file and check which committed lines map to which output lines
with open(HEADER) as f:
    patched = f.readlines()

# Find the insert points that fall in range 4950-5450
print("=== Insert points in range 4950-5450 ===")
for cls, idx in sorted(pts.items(), key=lambda x: x[1]):
    if 4950 <= idx <= 5450:
        print(f"  {cls}: index {idx} -> {committed[idx].rstrip()}")

# Now check: in the PATCHED file, where are lines 5462-5470 from?
# If they have \t prefix, they're inserts. Original committed lines don't have \t
print("\n=== Committed file indentation at ATerrainInfo ===")
for i in range(5385, 5395):
    print(f"  {i}: {repr(committed[i][:60])}")

# The patched output shows \t prefixed methods after UShadowBitmapMaterial close.
# Check: does the committed file have tab vs space indentation for ATerrainInfo?
print("\n=== ATerrainInfo committed indentation ===")
for i in range(5382, 5440):
    if committed[i].strip():
        c = committed[i][0]
        print(f"  {i}: starts with {'TAB' if c == chr(9) else 'SPACE' if c == ' ' else repr(c)}: {committed[i].rstrip()[:60]}")
