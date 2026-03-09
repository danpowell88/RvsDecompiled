"""Add round 2 skip symbols to gen_impl4.py."""

# Read the new skips
with open('build/skip_list2.txt') as f:
    new_skips = []
    for line in f:
        line = line.strip().rstrip(',')
        if line.startswith("'") and line.endswith("'"):
            new_skips.append(line[1:-1])

print(f"Adding {len(new_skips)} new skip mangles")

# Read gen_impl4.py
with open('tools/gen_impl4.py') as f:
    content = f.read()

# Find the closing brace of SKIP_MANGLES
# Pattern: find the last entry before the closing }
import re
# Add new entries before the closing }
for sym in new_skips:
    entry = f"    '{sym}',\n"
    if entry not in content:
        content = content.replace("\n}\n\nSKIP_PATTERNS", f"\n    '{sym}',\n" + "}\n\nSKIP_PATTERNS")

# Also add UChannel::ChannelClasses to data skip
# Find where data definitions are generated and skip ChannelClasses
content = content.replace(
    "# Data definitions",
    "# Data definitions\n    SKIP_DATA = {'?ChannelClasses@UChannel@@2PAPAVUClass@@A'}"
)

# Add check for SKIP_DATA
if 'SKIP_DATA' not in content.split("# Data definitions")[1][:500]:
    # Need to add the check in the data section
    pass

with open('tools/gen_impl4.py', 'w') as f:
    f.write(content)

print("Patched gen_impl4.py")
