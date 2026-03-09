import re
import subprocess

UNDNAME = r'C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\VC\Tools\MSVC\14.29.30133\bin\Hostx64\x86\undname.exe'

stubs = []
for i in range(1,5):
    path = f'src/engine/EngineStubs{i}.cpp'
    content = open(path).read()
    for m in re.finditer(r'#pragma comment\(linker,\s*\"/export:([^"]+)\"\)', content):
        sym = m.group(1)
        if '__FUNC_NAME__' not in sym and 'vftable' not in sym:
            stubs.append(sym)

print(f'Total actionable stubs: {len(stubs)}')

# Demangle all
for sym in stubs:
    try:
        result = subprocess.run([UNDNAME, sym], capture_output=True, text=True, timeout=5)
        demangled = result.stdout.strip().split('\n')[-1].strip()
        print(f'  {demangled}')
    except:
        print(f'  {sym} (failed to demangle)')
