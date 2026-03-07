"""Fix broken event function bodies in R6Engine.cpp.

The generator produced event functions with bare type names as struct members:
    struct { INT; } Parms; Parms.INT = INT;
Should be:
    struct { INT A; } Parms; Parms.A = A;
"""
import re
import sys

filepath = sys.argv[1] if len(sys.argv) > 1 else "src/r6engine/R6Engine.cpp"

with open(filepath, 'r') as f:
    lines = f.readlines()

i = 0
changes = 0
output = []

while i < len(lines):
    line = lines[i]
    # Match event function definition: void Class::eventName(TYPE1, TYPE2, ...)
    m = re.match(r'^(void \w+::event\w+)\((.*?)\)\s*$', line)
    if not m or not m.group(2).strip():
        output.append(line)
        i += 1
        continue

    func_name = m.group(1)
    params_str = m.group(2).strip()
    param_types = [p.strip() for p in params_str.split(',')]

    # Check if next line is '{'
    if i + 1 >= len(lines) or lines[i + 1].strip() != '{':
        output.append(line)
        i += 1
        continue

    # Check if the line after '{' starts the struct pattern
    if i + 2 >= len(lines) or 'struct' not in lines[i + 2]:
        output.append(line)
        i += 1
        continue

    # Scan forward to find } Parms;
    j = i + 2
    found_parms = False
    while j < len(lines):
        if '} Parms;' in lines[j]:
            found_parms = True
            break
        j += 1
        if j > i + 2 + len(param_types) + 5:
            break

    if not found_parms:
        output.append(line)
        i += 1
        continue

    parms_line = j
    # Now scan for Parms.X = X; assignments
    j = parms_line + 1
    while j < len(lines) and lines[j].strip().startswith('Parms.'):
        j += 1

    # Check for ProcessEvent
    if j >= len(lines) or 'ProcessEvent' not in lines[j]:
        output.append(line)
        i += 1
        continue

    pe_line_idx = j
    # Check closing brace
    if j + 1 >= len(lines) or lines[j + 1].strip() != '}':
        output.append(line)
        i += 1
        continue

    end_idx = j + 2  # line after '}'

    # Build replacement
    param_names = [chr(65 + k) for k in range(len(param_types))]
    new_params = ', '.join(f'{t} {n}' for t, n in zip(param_types, param_names))

    output.append(f'{func_name}({new_params})\n')
    output.append('{\n')
    if len(param_types) == 1:
        output.append(f'\tstruct {{ {param_types[0]} {param_names[0]}; }} Parms;\n')
    else:
        output.append('\tstruct { \n')
        for t, n in zip(param_types, param_names):
            output.append(f'\t\t{t} {n};\n')
        output.append('\t} Parms;\n')
    for n in param_names:
        output.append(f'\tParms.{n} = {n};\n')
    output.append(lines[pe_line_idx])
    output.append('}\n')

    changes += 1
    i = end_idx
    continue

with open(filepath, 'w') as f:
    f.writelines(output)

print(f'Fixed {changes} event functions in {filepath}')
