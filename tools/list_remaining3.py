"""List all remaining stubs with demangled names."""
import re, os, subprocess

stubs_dir = r'c:\Users\danpo\Desktop\rvs\src\engine'
UNDNAME = r'C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\VC\Tools\MSVC\14.29.30133\bin\Hostx64\x86\undname.exe'

all_stubs = []
for fname in ['EngineStubs1.cpp', 'EngineStubs2.cpp', 'EngineStubs3.cpp', 'EngineStubs4.cpp']:
    path = os.path.join(stubs_dir, fname)
    with open(path, 'r') as f:
        for line in f:
            m = re.search(r'/alternatename:(\S+)=', line)
            if m:
                mangled = m.group(1)
                all_stubs.append((fname, mangled))

print(f'Total remaining stubs: {len(all_stubs)}')
print()

for fname, mangled in all_stubs:
    result = subprocess.run([UNDNAME, mangled], capture_output=True, text=True)
    out = result.stdout.strip()
    if 'is :-' in out:
        demangled = out.split('is :- ')[-1].strip().strip('"')
    else:
        demangled = mangled
    print(f'{fname}: {demangled}')
