"""Extract ALL bad symbols from error file, merge with existing SKIP_MANGLES, rewrite."""
import re

# Read error file
with open('build/impl3_errors4.txt') as f:
    error_lines = set()
    for line in f:
        m = re.search(r'EngineBatchImpl3\.cpp\((\d+)', line)
        if m:
            error_lines.add(int(m.group(1)))

print(f"Found {len(error_lines)} unique error lines")

# Read the generated file
with open('src/engine/EngineBatchImpl3.cpp') as f:
    src_lines = f.readlines()

# Map each error line to the nearest preceding // comment with a mangled symbol
new_skips = set()
for err_line in sorted(error_lines):
    for i in range(err_line - 1, -1, -1):
        stripped = src_lines[i].strip()
        if stripped.startswith('// ?') or stripped.startswith('// ??'):
            symbol = stripped[3:]
            new_skips.add(symbol)
            break
        if stripped.startswith('// DATA') or stripped.startswith('#include') or stripped == '':
            break

print(f"Found {len(new_skips)} bad symbols from errors")

# Read existing SKIP_MANGLES from gen_impl4.py
with open('tools/gen_impl4.py') as f:
    content = f.read()

m = re.search(r'SKIP_MANGLES = \{([^}]*)\}', content, re.DOTALL)
existing = set()
for line in m.group(1).split('\n'):
    line = line.strip().rstrip(',')
    if line.startswith("'") and line.endswith("'"):
        existing.add(line[1:-1])

print(f"Existing: {len(existing)}, New: {len(new_skips)}, Added: {len(new_skips - existing)}")

all_skips = existing | new_skips

# Rebuild set
new_set = "SKIP_MANGLES = {\n"
for s in sorted(all_skips):
    new_set += f"    '{s}',\n"
new_set += "}"

content = re.sub(r'SKIP_MANGLES = \{[^}]*\}', new_set, content, flags=re.DOTALL)

with open('tools/gen_impl4.py', 'w') as f:
    f.write(content)

print(f"Updated SKIP_MANGLES: {len(all_skips)} total")
