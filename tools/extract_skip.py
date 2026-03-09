"""Extract failing line numbers from build errors, find the mangled symbols
on the comment lines above them, and output a skip list."""
import re

# Read errors
error_lines = set()
with open('build/impl3_errors.txt') as f:
    for line in f:
        m = re.search(r'EngineBatchImpl3\.cpp\((\d+)', line)
        if m:
            error_lines.add(int(m.group(1)))

print(f"Error lines: {len(error_lines)}")

# Read the generated file and find mangled symbols associated with error lines
impl_lines = []
with open('src/engine/EngineBatchImpl3.cpp') as f:
    impl_lines = f.readlines()

# For each error line, look backwards for the comment with the mangled symbol
skip_mangles = set()
for err_line in sorted(error_lines):
    idx = err_line - 1  # 0-based
    # Search backwards for comment line
    for back in range(idx, max(idx-5, 0), -1):
        if back < len(impl_lines) and impl_lines[back].strip().startswith('// ?'):
            mangled = impl_lines[back].strip()[3:]  # Remove '// '
            skip_mangles.add(mangled)
            break

print(f"Mangled symbols to skip: {len(skip_mangles)}")
for s in sorted(skip_mangles):
    print(f"  {s}")

# Also output as a Python set literal
print("\n# Add to SKIP_MANGLES in gen_impl4.py:")
print("SKIP_MANGLES = {")
for s in sorted(skip_mangles):
    print(f"    '{s}',")
print("}")
