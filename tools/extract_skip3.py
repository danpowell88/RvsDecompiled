"""Extract mangled symbols from error lines in EngineBatchImpl3.cpp.
Maps error line numbers back to the // MANGLED_SYMBOL comments."""
import re

# Read error file
with open('build/impl3_errors3.txt') as f:
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
bad_symbols = set()
for err_line in sorted(error_lines):
    # Search backward from error line for a // comment
    for i in range(err_line - 1, -1, -1):
        stripped = src_lines[i].strip()
        if stripped.startswith('// ?') or stripped.startswith('// ??'):
            symbol = stripped[3:]  # remove "// "
            bad_symbols.add(symbol)
            break
        if stripped.startswith('// DATA DEFINITIONS') or stripped.startswith('#include') or stripped == '':
            # Went too far back, this is a data definition error
            break

print(f"Found {len(bad_symbols)} bad symbols")

# Also check for UChannel::ChannelClasses data definition error
for err_line in sorted(error_lines):
    line_content = src_lines[err_line - 1].strip() if err_line <= len(src_lines) else ''
    if 'ChannelClasses' in line_content:
        print(f"  ChannelClasses error at line {err_line}: {line_content}")

# Print as a Python set
print("\nSKIP_MANGLES additions:")
for s in sorted(bad_symbols):
    print(f"    '{s}',")

# Write to file
with open('build/skip_list2.txt', 'w') as f:
    for s in sorted(bad_symbols):
        f.write(f"    '{s}',\n")
print(f"\nWrote {len(bad_symbols)} symbols to build/skip_list2.txt")
