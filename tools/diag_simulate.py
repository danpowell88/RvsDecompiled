"""Simulate the patching and check what appears at each position"""
import re, subprocess
from collections import defaultdict

# Read COMMITTED version
committed_raw = subprocess.check_output(
    ['git', 'show', 'HEAD:src/engine/EngineClasses.h']
).decode('utf-8', errors='replace')
committed_lines = committed_raw.split('\n')

# Read PATCHED version
with open('src/engine/EngineClasses.h') as f:
    patched_lines = f.readlines()

# For each committed line around the problem area, find its output position
# The committed lines have no tabs for ATerrainInfo methods
# We know committed 4959 = };, 4960 = blank, 4961 = class UMaterialSwitch

# Find where each committed line appears in patched file
# Use exact line matching for unique lines
print("=== Tracking committed lines 4959-4965 in patched file ===")
for ci in range(4959, 4966):
    cline = committed_lines[ci]
    # Find this line in patched (could be ambiguous for blank/}; lines)
    if cline.strip():
        for pi, pline in enumerate(patched_lines):
            if pline.rstrip() == cline.rstrip():
                # Check if this is the right occurrence by context
                pass
    print(f"  Committed[{ci}]: {repr(cline[:60])}")

# Better approach: the insert_map only adds lines at specific indices.
# So committed line at index X appears at output position X + (total insert lines before X).
# Let me count inserted lines before each index.

# Read the patched file and find lines that DON'T exist in committed
# Actually, let me just check the content around output lines 5460-5470

print("\n=== Patched file output lines 5462-5516 ===")
for i in range(5461, 5516):
    print(f"  Out[{i+1}]: {patched_lines[i].rstrip()[:80]}")

# Check if there's a class insert between committed 4959 and 4961
# that would contain SoftSelect
# The only explanation is an insert at an index in that range

# Let me check ALL lines from committed 4955 to 4970 and what's in
# the patched equivalent
print("\n=== What insert_map entries exist from gen_impl3.py? ===")
# Run find_class_insert_points on committed version
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

pts = find_class_insert_points(committed_lines)
# Check for inserts between 4959 and 4962
for cls, idx in sorted(pts.items(), key=lambda x: x[1]):
    if 4959 <= idx <= 4962:
        print(f"  {cls} -> insert at {idx}")

# The big question: where does SoftSelect at output 5464 come from?
# If it's not from an insert, it must be from the committed file.
# But committed SoftSelect doesn't have \t prefix.

# Let me check: does the CURRENT working file (post-gen_impl3) differ from 
# just the committed + inserts? Maybe gen_impl3 does something else too?
print("\n=== Checking if committed ATerrainInfo at 5387 has tab ===")
print(f"  repr: {repr(committed_lines[5387])}")
