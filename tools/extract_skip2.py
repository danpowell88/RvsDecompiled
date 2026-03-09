"""Extract failing mangled symbols from build errors and generate a skip list.
Reads build/impl3_errors.txt and src/engine/EngineBatchImpl3.cpp."""
import re

# Read error line numbers
error_lines = set()
with open('build/impl3_errors.txt') as f:
    for line in f:
        m = re.search(r'EngineBatchImpl3\.cpp\((\d+)', line)
        if m:
            error_lines.add(int(m.group(1)))

print(f"Error lines: {sorted(error_lines)[:20]}...")

# Read the generated file
with open('src/engine/EngineBatchImpl3.cpp') as f:
    impl_lines = f.readlines()

# For each error line, search backwards for comment with mangled symbol
skip_mangles = set()
for err_line in sorted(error_lines):
    idx = err_line - 1  # 0-based
    for back in range(idx, max(idx-5, -1), -1):
        if back < 0 or back >= len(impl_lines):
            continue
        line = impl_lines[back].strip()
        # Match: // Undecoration of :- "?mangled_name"
        m = re.match(r'// Undecoration of :- "(.+)"', line)
        if m:
            skip_mangles.add(m.group(1))
            break

print(f"\nMangled symbols to skip: {len(skip_mangles)}")

# Output as Python set literal
print("\nSKIP_MANGLES = {")
for s in sorted(skip_mangles):
    print(f"    '{s}',")
print("}")
