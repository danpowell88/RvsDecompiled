"""Compare exports between built and retail DLLs."""
import pefile
import sys

def get_exports(path):
    pe = pefile.PE(path)
    exports = {}
    for exp in pe.DIRECTORY_ENTRY_EXPORT.symbols:
        name = exp.name.decode('ascii') if exp.name else f'ord_{exp.ordinal}'
        exports[exp.ordinal] = name
    return exports

def analyze(dll_name, built_path, retail_path):
    built = get_exports(built_path)
    retail = get_exports(retail_path)
    
    built_ords = set(built.keys())
    retail_ords = set(retail.keys())
    extra = built_ords - retail_ords
    missing = retail_ords - built_ords
    shared = built_ords & retail_ords
    
    print(f"\n=== {dll_name} ===")
    print(f"Built: {len(built)} exports, Retail: {len(retail)} exports")
    print(f"Shared: {len(shared)}, Extra in built: {len(extra)}, Missing from retail: {len(missing)}")
    
    if extra:
        names = [built[o] for o in extra]
        move_ctors = [n for n in names if '$$QA' in n]  # MSVC 2019 move constructors
        vtables = [n for n in names if n.startswith('??_7')]
        others = [n for n in names if '$$QA' not in n and not n.startswith('??_7')]
        
        print(f"\nExtra exports breakdown ({len(extra)} total):")
        print(f"  Move constructors (MSVC 2019 artifact): {len(move_ctors)}")
        print(f"  Vtables: {len(vtables)}")
        print(f"  Other: {len(others)}")
        if others:
            print(f"\n  Other extras (first 20):")
            for n in sorted(others)[:20]:
                print(f"    {n}")
    
    if missing:
        print(f"\nMissing from built ({len(missing)}):")
        for o in sorted(missing)[:20]:
            print(f"  @{o}: {retail[o]}")

# Core.dll
analyze("Core.dll",
    r"c:\Users\danpo\Desktop\rvs\build\bin\Core.dll",
    r"c:\Users\danpo\Desktop\rvs\retail\system\Core.dll")

# Engine.dll
analyze("Engine.dll",
    r"c:\Users\danpo\Desktop\rvs\build\bin\Engine.dll",
    r"c:\Users\danpo\Desktop\rvs\retail\system\Engine.dll")
