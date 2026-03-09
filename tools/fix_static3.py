"""Fix static strip in the third occurrence (implementation section)"""
path = 'tools/gen_impl3.py'
with open(path) as f:
    lines = f.readlines()

count = 0
for i, line in enumerate(lines):
    if 'ret = fix_type(m.group(2))' in line:
        count += 1
        if count == 3:
            fix_line = "                if ret.startswith('static '): ret = ret[7:]\n"
            lines.insert(i+1, fix_line)
            print(f'Inserted at line {i+2}')
            break

with open(path, 'w') as f:
    f.writelines(lines)
