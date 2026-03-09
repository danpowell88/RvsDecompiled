"""Fix gen_impl4.py undname parsing to properly extract mangled symbols."""

with open('tools/gen_impl4.py') as f:
    content = f.read()

OLD_PARSE = '''def demangle_stubs(stubs):
    result = {}
    batch_size = 50
    for start in range(0, len(stubs), batch_size):
        batch = stubs[start:start+batch_size]
        proc = subprocess.run([UNDNAME] + batch, capture_output=True, text=True)
        lines = proc.stdout.strip().split('\\n')
        for j in range(0, len(lines), 3):
            if j+1 >= len(lines):
                break
            mangled = lines[j].strip().replace('>> ', '')
            demangled = lines[j+1].strip().replace('is :- ', '').strip('"')
            result[mangled] = demangled
    return result'''

NEW_PARSE = '''def demangle_stubs(stubs):
    result = {}
    batch_size = 50
    for start in range(0, len(stubs), batch_size):
        batch = stubs[start:start+batch_size]
        proc = subprocess.run([UNDNAME] + batch, capture_output=True, text=True)
        lines = proc.stdout.strip().split('\\n')
        i = 0
        while i < len(lines):
            line = lines[i].strip()
            if line.startswith('Undecoration of :- "') and line.endswith('"'):
                mangled = line[len('Undecoration of :- "'):-1]
                if i+1 < len(lines):
                    dem_line = lines[i+1].strip()
                    if dem_line.startswith('is :- "') and dem_line.endswith('"'):
                        demangled = dem_line[len('is :- "'):-1]
                        result[mangled] = demangled
                i += 2
            else:
                i += 1
    return result'''

assert OLD_PARSE in content, "Could not find old parse function"
content = content.replace(OLD_PARSE, NEW_PARSE)

with open('tools/gen_impl4.py', 'w') as f:
    f.write(content)

print("Fixed demangle_stubs parsing")
