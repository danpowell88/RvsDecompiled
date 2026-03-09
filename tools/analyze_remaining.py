import subprocess, re

UNDNAME = r'C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\VC\Tools\MSVC\14.29.30133\bin\Hostx64\x86\undname.exe'

stubs = []
for i in range(1, 5):
    with open(f'src/engine/EngineStubs{i}.cpp') as f:
        for line in f:
            if '/alternatename:' in line and '=_dummy' in line:
                idx1 = line.index('/alternatename:') + len('/alternatename:')
            if '/alternatename:' in line and '=_dummy' in line:
                idx1 = line.index('/alternatename:') + len('/alternatename:')
                idx2 = line.index('=_dummy')
                stubs.append(line[idx1:idx2]ernatename:') + len('/alternatename:')
                idx2 = line.index('=_dummy')
                sym = line[idx1:idx2]
                stubs.append(sym)
print(f'Total remaining stubs: {len(stubs)}')

demangled_map = {}
batch_size = 50
for start in range(0, len(stubs), batch_size):
    batch = stubs[start:start+batch_size]
    proc = subprocess.run([UNDNAME] + batch, capture_output=True, text=True)
    lines = proc.stdout.strip().split(chr(10))
    for j in range(0, len(lines), 3):
        if j+1 >= len(lines): break
        mangled = lines[j].strip().replace('>> ', '')
        demangled = lines[j+1].strip().replace('is :- ', '').strip(chr(34))
        demangled_map[mangled] = demangled

free_funcs = []
class_methods = []
data_syms = []
operators = []

for mangled, demangled in demangled_map.items():
    if 'operator<<' in demangled or 'operator>>' in demangled:
        operators.append((mangled, demangled))
    elif '::' in demangled and ('(' in demangled or 'vftable' in demangled or 'vbtable' in demangled):
        class_methods.append((mangled, demangled))
    elif '(' in demangled and '::' not in demangled:
        free_funcs.append((mangled, demangled))
    else:
        data_syms.append((mangled, demangled))

print(f'Class methods: {len(class_methods)}')
print(f'Free functions: {len(free_funcs)}')
print(f'Operators: {len(operators)}')
print(f'Data/other: {len(data_syms)}')

print()
print('=== FREE FUNCTIONS ===')
for m, d in sorted(free_funcs, key=lambda x: x[1]):
    print(f'  {d}')

print()
print('=== OPERATORS ===')
for m, d in sorted(operators, key=lambda x: x[1]):
    print(f'  {d}')

print()
print('=== DATA/OTHER ===')
for m, d in sorted(data_syms, key=lambda x: x[1]):
    print(f'  {d}')

print()
print('=== CLASS METHODS (by class) ===')
by_class = {}
for m, d in class_methods:
    cm = re.match(r'(?:public|protected|private): .*?(\w+)::', d)
    if cm:
        cls = cm.group(1)
    else:
        cls = d.split('::')[0].strip().split()[-1] if '::' in d else 'unknown'
    by_class.setdefault(cls, []).append((m, d))

for cls in sorted(by_class.keys()):
    methods = by_class[cls]
    print(f'  {cls} ({len(methods)} methods):')
    for m, d in methods:
        print(f'    {d}')
