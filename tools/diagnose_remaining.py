"""
Diagnose remaining stubs: compare mangled names from stubs vs obj symbols.
Focus on stubs that are NOT __FUNC_NAME__ or vftable.
"""
import re, os, subprocess

stubs_dir = r'c:\Users\danpo\Desktop\rvs\src\engine'
OBJ_DIR = r'c:\Users\danpo\Desktop\rvs\build\src\engine\Engine.dir\Release'
DUMPBIN = r'C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\VC\Tools\MSVC\14.29.30133\bin\Hostx64\x86\dumpbin.exe'
UNDNAME = r'C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\VC\Tools\MSVC\14.29.30133\bin\Hostx64\x86\undname.exe'

# Collect all remaining stub mangled names
all_stubs = []
for fname in ['EngineStubs1.cpp', 'EngineStubs2.cpp', 'EngineStubs3.cpp', 'EngineStubs4.cpp']:
    path = os.path.join(stubs_dir, fname)
    with open(path, 'r') as f:
        for line in f:
            m = re.search(r'/alternatename:(\S+)=', line)
            if m:
                all_stubs.append(m.group(1))

# Filter out __FUNC_NAME__ and vftable stubs (not fixable)
func_name_stubs = [s for s in all_stubs if '__FUNC_NAME__' in s or 'FUNC_NAME' in s]
vftable_stubs = [s for s in all_stubs if 'vftable' in s or '??_7' in s]
fixable = [s for s in all_stubs if s not in func_name_stubs and s not in vftable_stubs]

print(f"Total remaining: {len(all_stubs)}")
print(f"__FUNC_NAME__: {len(func_name_stubs)}")
print(f"vftable: {len(vftable_stubs)}")
print(f"Potentially fixable: {len(fixable)}")
print()

# Get all defined symbols from EngineBatchImpl4.obj
result = subprocess.run(
    [DUMPBIN, '/SYMBOLS', os.path.join(OBJ_DIR, 'EngineBatchImpl4.obj')],
    capture_output=True, text=True
)
obj_symbols = set()
for line in result.stdout.split('\n'):
    parts = line.split()
    if len(parts) >= 6 and ('External' in parts or 'SECT' in line):
        # Extract the symbol name (last part after | or just the mangled name)
        for p in parts:
            if p.startswith('?') or p.startswith('_'):
                obj_symbols.add(p)

# For each fixable stub, check if a similar symbol exists in obj
for stub_mangled in fixable:
    result = subprocess.run([UNDNAME, stub_mangled], capture_output=True, text=True)
    out = result.stdout.strip()
    demangled = out.split('is :- ')[-1].strip().strip('"') if 'is :-' in out else stub_mangled
    
    # Check if exact match
    if stub_mangled in obj_symbols:
        print(f"MATCH: {demangled}")
    else:
        # Find close matches
        # Extract the function name from the mangled symbol
        base = stub_mangled.split('@')[0].lstrip('?')
        close = [s for s in obj_symbols if base in s]
        if close:
            # Demangle the close match
            close_result = subprocess.run([UNDNAME, close[0]], capture_output=True, text=True)
            close_dem = close_result.stdout.strip().split('is :- ')[-1].strip().strip('"') if 'is :-' in close_result.stdout else close[0]
            print(f"MISMATCH: {demangled}")
            print(f"  stub:  {stub_mangled}")
            print(f"  obj:   {close[0]}")
            print(f"  obj_d: {close_dem}")
        else:
            print(f"NO OBJ: {demangled}")
            print(f"  stub:  {stub_mangled}")
