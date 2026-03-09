"""Robustly update SKIP_MANGLES in gen_impl4.py by parsing and rewriting."""
import re

# Read the new skips from file
with open('build/skip_list2.txt') as f:
    new_skips = set()
    for line in f:
        line = line.strip().rstrip(',')
        if line.startswith("'") and line.endswith("'"):
            new_skips.add(line[1:-1])

print(f"New skip symbols: {len(new_skips)}")

# Read gen_impl4.py
with open('tools/gen_impl4.py') as f:
    content = f.read()

# Extract existing SKIP_MANGLES
m = re.search(r'SKIP_MANGLES = \{([^}]*)\}', content, re.DOTALL)
if not m:
    print("ERROR: Could not find SKIP_MANGLES")
    exit(1)

existing = set()
for line in m.group(1).split('\n'):
    line = line.strip().rstrip(',')
    if line.startswith("'") and line.endswith("'"):
        existing.add(line[1:-1])

print(f"Existing skip symbols: {len(existing)}")

# Merge
all_skips = existing | new_skips
print(f"Total skip symbols: {len(all_skips)}")

# Build new set string
new_set = "SKIP_MANGLES = {\n"
for s in sorted(all_skips):
    new_set += f"    '{s}',\n"
new_set += "}"

# Replace in content
content = re.sub(r'SKIP_MANGLES = \{[^}]*\}', new_set, content, flags=re.DOTALL)

# Also skip UChannel::ChannelClasses data definition
# Find the data generation section and add a skip
CHANNEL_MANGLED = '?ChannelClasses@UChannel@@2PAPAVUClass@@A'
if CHANNEL_MANGLED not in content:
    # Add to SKIP_MANGLES
    content = content.replace(new_set, new_set.replace("}", f"    '{CHANNEL_MANGLED}',\n" + "}"))

with open('tools/gen_impl4.py', 'w') as f:
    f.write(content)

print("Updated gen_impl4.py with all skip symbols")
