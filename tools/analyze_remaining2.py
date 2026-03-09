"""Analyze remaining 380 stubs breakdown."""
import subprocess

UNDNAME = r'C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\VC\Tools\MSVC\14.29.30133\bin\Hostx64\x86\undname.exe'

stubs = []
for i in range(1, 5):
    with open(f'src/engine/EngineStubs{i}.cpp') as f:
        for line in f:
            if '/alternatename:' in line and '=_dummy' in line:
                idx1 = line.index('/alternatename:') + len('/alternatename:')
                idx2 = line.index('=_dummy')
                stubs.append(line[idx1:idx2])

vftable = [s for s in stubs if s.startswith('??_7') or s.startswith('??_8')]
funcname = [s for s in stubs if '__FUNC_NAME__' in s]
tarray = [s for s in stubs if 'TArray' in s or 'TLazyArray' in s]
other = [s for s in stubs if s not in set(vftable + funcname + tarray)]

print(f'Total: {len(stubs)}')
print(f'__FUNC_NAME__: {len(funcname)}')
print(f'vftable/vbtable: {len(vftable)}')
print(f'TArray/TLazyArray: {len(tarray)}')
print(f'Other: {len(other)}')

# Demangle all 'other'
demangled = []
for start in range(0, len(other), 50):
    batch = other[start:start+50]
    proc = subprocess.run([UNDNAME] + batch, capture_output=True, text=True)
    lines = proc.stdout.strip().split('\n')
    i = 0
    while i < len(lines):
        line = lines[i].strip()
        if line.startswith('Undecoration of :- "') and line.endswith('"'):
            mangled = line[len('Undecoration of :- "'):-1]
            if i+1 < len(lines):
                dem = lines[i+1].strip()
                if dem.startswith('is :- "') and dem.endswith('"'):
                    demangled.append(dem[len('is :- "'):-1])
            i += 2
        else:
            i += 1

# Categorize 'other' demangled
classes = {}
for d in demangled:
    if '::' in d:
        cls = d.split('::')[0].split()[-1]
        classes[cls] = classes.get(cls, 0) + 1

print(f'\nOther stubs by class ({len(demangled)} total):')
for cls, count in sorted(classes.items(), key=lambda x: -x[1])[:25]:
    print(f'  {cls}: {count}')

# Count free functions
free = [d for d in demangled if '::' not in d]
print(f'\nFree functions: {len(free)}')
for f in free[:10]:
    print(f'  {f}')

# Count operators
ops = [d for d in demangled if 'operator' in d]
print(f'\nOperators: {len(ops)}')

# Show TArray samples
print(f'\nTArray/TLazyArray stubs ({len(tarray)}):')
for start in range(0, len(tarray), 50):
    batch = tarray[start:start+50]
    proc = subprocess.run([UNDNAME] + batch, capture_output=True, text=True)
    lines = proc.stdout.strip().split('\n')
    i = 0
    while i < len(lines):
        line = lines[i].strip()
        if line.startswith('Undecoration of :- "') and line.endswith('"'):
            if i+1 < len(lines):
                dem = lines[i+1].strip()
                if dem.startswith('is :- "') and dem.endswith('"'):
                    print(f'  {dem[len("is :- " + chr(34)):-1]}')
            i += 2
        else:
            i += 1
