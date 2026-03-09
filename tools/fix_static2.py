"""Fix static strip in implementation section"""
path = 'tools/gen_impl3.py'
with open(path) as f:
    lines = f.readlines()

# Find the SECOND occurrence of 'ret = fix_type(m.group(2))' (in impl section)
count = 0
for i, line in enumerate(lines):
    if 'ret = fix_type(m.group(2))' in line:
        count += 1
        if count == 2:  # Second occurrence is in impl section
            indent = '                '
            new_line = indent + "if ret.startswith('static '): ret = ret[7:]\n"
            lines.insert(i+1, new_line)
            print(f'Inserted static strip after line {i+1}')
            break

with open(path, 'w') as f:
    f.writelines(lines)
