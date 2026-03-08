"""
remove_resolved_stubs.py — Identify and remove /alternatename pragmas from
EngineStubs*.cpp that now have real implementations in compiled .obj files.

Uses dumpbin to get the exact mangled symbols defined in each .obj, then
matches them against the /alternatename targets in the stub files.
This ensures only pragmas with exact symbol matches are removed.
"""

import re
import os
import subprocess
import sys

ENGINE_DIR = os.path.join(os.path.dirname(__file__), '..', 'src', 'engine')
OBJ_DIR = os.path.join(os.path.dirname(__file__), '..', 'build', 'src', 'engine', 'Engine.dir', 'Release')
DUMPBIN = r'C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\VC\Tools\MSVC\14.29.30133\bin\Hostx64\x86\dumpbin.exe'

STUB_FILES = [
    'EngineStubs1.cpp', 'EngineStubs2.cpp',
    'EngineStubs3.cpp', 'EngineStubs4.cpp',
]

# .obj files that contain real implementations (not stubs)
IMPL_OBJS = [
    'UnActor.obj', 'UnPawn.obj', 'UnEffects.obj', 'UnLevel.obj',
    'UnRender.obj', 'UnAudio.obj', 'UnMaterial.obj', 'UnMesh.obj',
    'UnModel.obj', 'UnNet.obj', 'EngineExtra.obj', 'Engine.obj',
    'EngineEvents.obj',
    'EngineBatchImpl.obj',
    'EngineBatchImpl2.obj',
    'EngineVirtuals.obj',
]


def get_defined_symbols(obj_path):
    """Use dumpbin /SYMBOLS to get all externally-defined symbols from an .obj."""
    symbols = set()
    try:
        result = subprocess.run(
            [DUMPBIN, '/SYMBOLS', obj_path],
            capture_output=True, text=True, timeout=30
        )
        for line in result.stdout.splitlines():
            # Match: External symbols in a SECT (defined, not UNDEF)
            if 'External' in line and 'SECT' in line:
                # Extract the mangled symbol after '| '
                m = re.search(r'\|\s+(\S+)', line)
                if m:
                    symbols.add(m.group(1))
    except Exception as e:
        print(f"  Warning: dumpbin failed for {obj_path}: {e}")
    return symbols


def main():
    obj_dir = os.path.normpath(OBJ_DIR)
    engine_dir = os.path.normpath(ENGINE_DIR)

    # Collect all defined symbols from implementation .obj files
    all_defined = set()
    for obj_name in IMPL_OBJS:
        obj_path = os.path.join(obj_dir, obj_name)
        if not os.path.exists(obj_path):
            print(f"  Skipping {obj_name} (not found)")
            continue
        syms = get_defined_symbols(obj_path)
        print(f"{obj_name}: {len(syms)} defined symbols")
        all_defined.update(syms)

    print(f"\nTotal defined symbols across all impl objects: {len(all_defined)}")

    # Process each stub file
    total_pragmas = 0
    removed_pragmas = 0

    for stub_name in STUB_FILES:
        stub_path = os.path.join(engine_dir, stub_name)
        if not os.path.exists(stub_path):
            continue

        with open(stub_path, 'r', encoding='utf-8', errors='replace') as f:
            lines = f.readlines()

        new_lines = []
        file_removed = 0
        for line in lines:
            if '/alternatename:' not in line:
                new_lines.append(line)
                continue

            total_pragmas += 1
            # Extract the mangled symbol from /alternatename:SYMBOL=...
            m = re.search(r'/alternatename:(\S+?)=', line)
            if not m:
                new_lines.append(line)
                continue

            symbol = m.group(1)
            if symbol in all_defined:
                # Real implementation exists — remove the pragma
                removed_pragmas += 1
                file_removed += 1
            else:
                new_lines.append(line)

        with open(stub_path, 'w', encoding='utf-8') as f:
            f.writelines(new_lines)

        remaining = sum(1 for l in new_lines if '/alternatename:' in l)
        print(f"{stub_name}: removed {file_removed} pragmas, {remaining} remaining")

    print(f"\nTotal: {total_pragmas} pragmas processed")
    print(f"  Removed: {removed_pragmas}")
    print(f"  Kept:    {total_pragmas - removed_pragmas}")


if __name__ == '__main__':
    main()
