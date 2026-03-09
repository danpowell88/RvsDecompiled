"""Full simulation: re-run patching on committed header and check output at critical lines"""
import re, subprocess, os
from collections import defaultdict

os.system('git checkout -- src/engine/EngineClasses.h')

HEADER = 'src/engine/EngineClasses.h'

# Read the file EXACTLY as gen_impl3.py does in the patching section
with open(HEADER) as f:
    header_lines = f.readlines()

# Simulate find_class_insert_points (which also reads the file)
with open(HEADER) as f:
    ip_lines = f.readlines()

points = {}
for i, line in enumerate(ip_lines):
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
    for j in range(i, len(ip_lines)):
        depth += ip_lines[j].count('{') - ip_lines[j].count('}')
        if depth > 0:
            entered = True
        if entered and depth == 0:
            points[cls] = j
            break
    else:
        points[cls] = None

insert_points = {k: v for k, v in points.items() if v is not None}

# Create a FAKE insert_map with just a few test entries
# Simulate what gen_impl3 generates for UShadowBitmapMaterial
fake_insert_map = {}
fake_insert_map[4959] = '\t// Auto-generated method declarations\n\tvirtual void Destroy();\n'

# Now run the rebuild  
output_lines = []
for i, line in enumerate(header_lines):
    if i in fake_insert_map:
        output_lines.append(fake_insert_map[i])
    output_lines.append(line)

# Check what's at the critical output positions
# Count output lines
total_out = sum(elem.count('\n') for elem in output_lines)
print(f"Total output lines: {total_out}")
print(f"Total header lines: {len(header_lines)}")
print(f"Total insert lines: {sum(elem.count(chr(10)) for elem in output_lines) - len(header_lines)}")

# Write to temp and check specific lines
with open('build/test_patch.h', 'w') as f:
    f.writelines(output_lines)

with open('build/test_patch.h') as f:
    test_lines = f.readlines()

# Find output position for committed lines 4959-4965
print("\n=== Test patch around committed index 4959-4965 ===")
for i in range(4959, 4970):
    # committed line should be at position i + (inserts before i)
    pass

# Just search for the pattern
for i, line in enumerate(test_lines):
    if 'SoftSelect' in line and i < 6000:
        print(f"  test line {i+1}: {line.rstrip()[:80]}")
    if 'UMaterialSwitch' in line and 'class' in line and i < 6000:
        print(f"  test line {i+1}: {line.rstrip()[:80]}")
    if i >= 4958 and i < 4968:
        print(f"  test line {i+1}: {repr(line[:60])}")

print("\n=== Now actual gen_impl3 output ===")
# Read the ACTUAL patched file from last gen_impl3 run
# Revert first won't work since we just reverted... let me just check the 
# insert_map from gen_impl3 by importing it

# Actually, let me just check: how many insert_map entries are there between 4959 and 5437?
print(f"\nInsert points between 4959 and 5437:")
for cls, idx in sorted(insert_points.items(), key=lambda x: x[1]):
    if 4959 <= idx <= 5440:
        print(f"  {cls}: {idx}")
