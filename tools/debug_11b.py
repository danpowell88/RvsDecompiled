"""Find exact mangling differences for the 11 'in-source but not in obj' stubs."""
import subprocess, re, os

DUMPBIN = r'C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\VC\Tools\MSVC\14.29.30133\bin\Hostx64\x86\dumpbin.exe'
UNDNAME = r'C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\VC\Tools\MSVC\14.29.30133\bin\Hostx64\x86\undname.exe'

# Get remaining stubs  
stubs = {}
for fname in ['src/engine/EngineStubs1.cpp', 'src/engine/EngineStubs2.cpp', 
              'src/engine/EngineStubs3.cpp', 'src/engine/EngineStubs4.cpp']:
    with open(fname) as f:
        for line in f:
            m = re.search(r'/alternatename:(\S+)=', line)
            if m:
                stubs[m.group(1)] = fname

# Get all defined symbols from all obj files (all engine obj, not just impl)
OBJ_DIR = r'build\src\engine\Engine.dir\Release'
all_defined = {}  # mangled -> obj_name
for obj in os.listdir(OBJ_DIR):
    if not obj.endswith('.obj'):
        continue
    r = subprocess.run([DUMPBIN, '/SYMBOLS', os.path.join(OBJ_DIR, obj)], 
                       capture_output=True, text=True)
    for line in r.stdout.splitlines():
        if 'SECT' in line:
            m = re.search(r'External\s+\|\s+(\S+)', line)
            if m:
                all_defined[m.group(1)] = obj

# For each unresolved stub, search for the function name (without access/calling convention)
targets = ['findNewFloor', 'StaticConfigName@UInputPlanning', 'WrappedPrint',
           'URenderResource@@', 'FLightMap@@QAE', 'FLightMapTexture@@QAE',
           'FRaw32BitIndexBuffer@@QAE', 'FRawIndexBuffer@@QAE', 'FStaticLightMapTexture@@QAE',
           'FOrientation@@QAE', 'FRebuildOptions@@QAE']

for stub_mangled, stub_file in sorted(stubs.items()):
    # Check if this is one of our target stubs
    is_target = False
    for t in targets:
        if t in stub_mangled:
            is_target = True
            break
    if not is_target:
        continue
    
    # Demangle
    r = subprocess.run([UNDNAME, stub_mangled], capture_output=True, text=True)
    stub_dem = ''
    for line in r.stdout.splitlines():
        if line.startswith('is :-'):
            stub_dem = line[6:].strip().strip('"')
    
    # Extract function name for searching .obj
    # Get the part after ? and before @@
    func_part = stub_mangled.split('@@')[0]  # e.g., ?findNewFloor@APawn or ??1FLightMap
    
    # Search for matching function in .obj
    obj_matches = []
    for obj_mangled, obj_name in all_defined.items():
        if func_part in obj_mangled and obj_mangled != stub_mangled:
            r2 = subprocess.run([UNDNAME, obj_mangled], capture_output=True, text=True)
            obj_dem = ''
            for line in r2.stdout.splitlines():
                if line.startswith('is :-'):
                    obj_dem = line[6:].strip().strip('"')
            obj_matches.append((obj_mangled, obj_dem, obj_name))
    
    if obj_matches:
        print(f"STUB: {stub_dem}")
        print(f"  mangled: {stub_mangled}")
        for om, od, oname in obj_matches[:3]:
            print(f"  OBJ [{oname}]: {od}")
            print(f"    mangled: {om}")
            # Show char-by-char diff
            diffs = []
            for i in range(min(len(stub_mangled), len(om))):
                if stub_mangled[i] != om[i]:
                    diffs.append(f"pos {i}: stub='{stub_mangled[i]}' obj='{om[i]}'")
            if len(stub_mangled) != len(om):
                diffs.append(f"lengths: stub={len(stub_mangled)} obj={len(om)}")
            if diffs:
                print(f"    DIFFS: {diffs}")
        print()
