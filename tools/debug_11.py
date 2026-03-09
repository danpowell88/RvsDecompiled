"""Debug the 11 stubs that have source implementations but aren't in .obj."""
import subprocess, re, os

UNDNAME = r'C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\VC\Tools\MSVC\14.29.30133\bin\Hostx64\x86\undname.exe'
DUMPBIN = r'C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\VC\Tools\MSVC\14.29.30133\bin\Hostx64\x86\dumpbin.exe'

checks = ['findNewFloor', 'UInputPlanning', 'WrappedPrint',
          'URenderResource@@', '??1FLightMap@@', '??1FLightMapTexture@@',
          '??1FRaw32BitIndexBuffer@@', '??1FRawIndexBuffer@@',
          '??1FStaticLightMapTexture@@', '??4FOrientation@@',
          '??4FRebuildOptions@@']

# Get all stubs
stubs = {}
for fname in ['src/engine/EngineStubs1.cpp', 'src/engine/EngineStubs2.cpp', 
              'src/engine/EngineStubs3.cpp', 'src/engine/EngineStubs4.cpp']:
    with open(fname) as f:
        for line in f:
            m = re.search(r'/alternatename:(\S+)=', line)
            if m:
                s = m.group(1)
                for c in checks:
                    if c in s:
                        r = subprocess.run([UNDNAME, s], capture_output=True, text=True)
                        dem = ''
                        for line2 in r.stdout.splitlines():
                            if line2.startswith('is :-'):
                                dem = line2[6:].strip().strip('"')
                        stubs[s] = dem
                        break

# Get all defined obj symbols
OBJ_DIR = r'build\src\engine\Engine.dir\Release'
all_obj_syms = {}
for obj in os.listdir(OBJ_DIR):
    if not obj.endswith('.obj'):
        continue
    r = subprocess.run([DUMPBIN, '/SYMBOLS', os.path.join(OBJ_DIR, obj)], 
                       capture_output=True, text=True)
    for line in r.stdout.splitlines():
        if 'SECT' in line:
            m = re.search(r'External\s+\|\s+(\S+)', line)
            if m:
                all_obj_syms[m.group(1)] = obj

# For each stub, search for similar symbols in .obj
print("=== DEBUGGING 11 UNRESOLVED STUBS ===\n")
for stub, dem in sorted(stubs.items()):
    print(f"STUB: {dem}")
    print(f"  mangled: {stub}")
    
    # Search for anything with this class/function name in obj
    # Extract a short identifier
    parts = stub.split('@')
    if len(parts) >= 2:
        short_name = parts[0].lstrip('?')
        classname = parts[1] if parts[1] else parts[2] if len(parts) > 2 else ''
        search = classname if classname else short_name
    else:
        search = stub[:20]
    
    similar = [(sym, obj) for sym, obj in all_obj_syms.items() if search in sym]
    if similar:
        # Show a few matches
        for sym, obj in similar[:3]:
            r2 = subprocess.run([UNDNAME, sym], capture_output=True, text=True) 
            dem2 = ''
            for line in r2.stdout.splitlines():
                if line.startswith('is :-'):
                    dem2 = line[6:].strip().strip('"')
            print(f"  OBJ [{obj}]: {dem2}")
            print(f"    mangled: {sym}")
    else:
        print(f"  No similar symbols found for '{search}'")
    print()
