"""Fix: remove erroneous static strip from declaration sections, keep only in impl section.
Also add UTerrainSector to KNOWN_DECLARED_ELSEWHERE."""
path = 'tools/gen_impl3.py'
with open(path) as f:
    lines = f.readlines()

# Find and remove the first two "static strip" lines (in decl sections)
# Keep only the third one (in impl section)
removed = 0
i = 0
while i < len(lines):
    if "if ret.startswith('static '): ret = ret[7:]" in lines[i]:
        removed += 1
        if removed <= 2:
            # Remove this line (it's in a declaration section)
            lines.pop(i)
            print(f"Removed static strip at line {i+1} (occurrence {removed})")
            continue
        else:
            print(f"Kept static strip at line {i+1} (occurrence {removed}, impl section)")
    i += 1

# Add UTerrainSector to KNOWN_DECLARED_ELSEWHERE
old = "    'FLevelSceneNode', 'FLightMapSceneNode', 'FPointLightMapSceneNode',\n}"
new = "    'FLevelSceneNode', 'FLightMapSceneNode', 'FPointLightMapSceneNode',\n    'UTerrainSector',\n}"
found = False
for i, line in enumerate(lines):
    if 'FLevelSceneNode' in line and 'FPointLightMapSceneNode' in line:
        lines[i] = lines[i]  # don't modify this line
        # Find the closing }
        for j in range(i+1, min(i+5, len(lines))):
            if lines[j].strip() == '}':
                lines[j] = "    'UTerrainSector',\n}\n"
                found = True
                print(f"Added UTerrainSector at line {j+1}")
                break
        break

with open(path, 'w') as f:
    f.writelines(lines)
print("Done")
