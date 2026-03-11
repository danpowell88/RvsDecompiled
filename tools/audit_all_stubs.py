"""audit_all_stubs.py - Audit all trivial stubs against retail DLLs.

Reads export tables for Core.dll, Engine.dll, WinDrv.dll and classifies
every stub function as:
  EMPTY    - retail function is a no-op (ret/ret N)
  TINY     - retail function is 1-10 bytes (worth implementing)
  SHORT    - 11-50 bytes (feasible)
  MEDIUM   - 51-150 bytes (possible with effort)
  LARGE    - >150 bytes (complex, skip for now)
  NOTFOUND - not in retail exports
"""
import sys, struct

# ---------------------------------------------------------------------------
# Capstone optional (for disasm preview)
# ---------------------------------------------------------------------------
try:
    from capstone import Cs, CS_ARCH_X86, CS_MODE_32
    def disasm_snippet(data, rva, nbytes=32):
        md = Cs(CS_ARCH_X86, CS_MODE_32)
        md.detail = False
        lines = []
        for ins in md.disasm(data[rva:rva+nbytes], rva):
            lines.append(f"  {ins.address:05X}  {ins.mnemonic} {ins.op_str}")
            if ins.mnemonic in ('ret', 'retn'):
                break
        return '\n'.join(lines)
    HAS_CAPSTONE = True
except ImportError:
    HAS_CAPSTONE = False
    def disasm_snippet(data, rva, nbytes=32):
        return "  (install capstone for disasm)"

# ---------------------------------------------------------------------------
# Load an export table from a dumpbin UTF-16 text file
# Format: ordinal  hint  RVA  mangled_name
# ---------------------------------------------------------------------------
def load_exports(path):
    exports = {}
    try:
        with open(path, 'rb') as f:
            bom2 = f.read(2)
        enc = 'utf-16' if bom2 == b'\xff\xfe' else 'utf-8'
        with open(path, encoding=enc, errors='ignore') as f:
            for line in f:
                parts = line.strip().split()
                if len(parts) >= 4:
                    try:
                        rva  = int(parts[2], 16)
                        name = parts[3]
                        exports[name] = rva
                    except (ValueError, IndexError):
                        pass
    except FileNotFoundError:
        print(f"WARNING: {path} not found")
    return exports

# ---------------------------------------------------------------------------
# Classify a function at `rva` in `data`
# ---------------------------------------------------------------------------
def classify(data, rva, max_scan=800):
    if rva >= len(data):
        return 'INVALID', 0
    b0 = data[rva]
    # Plain ret
    if b0 == 0xC3:
        return 'EMPTY', 1
    # ret N (stdcall)
    if b0 == 0xC2:
        return 'EMPTY', 3
    # xor eax,eax (return 0 immediate)
    if data[rva:rva+2] == bytes([0x33, 0xC0]):
        # Check if next instruction is ret
        if rva+2 < len(data) and data[rva+2] in (0xC3, 0xC2):
            return 'TINY', 4
    # Has prolog or other start — scan for first ret
    for end in range(rva, min(rva + max_scan, len(data))):
        b = data[end]
        if b == 0xC3:
            size = end - rva + 1
            break
        if b == 0xC2 and end + 2 < len(data):
            size = end - rva + 3
            break
    else:
        size = max_scan
    if size <= 10:   return 'TINY',   size
    if size <= 50:   return 'SHORT',  size
    if size <= 150:  return 'MEDIUM', size
    return 'LARGE', size

# ---------------------------------------------------------------------------
# Stub database: (function_name_fragment, class_fragment, dll)
# ---------------------------------------------------------------------------
STUBS = [
    # Core stubs
    ("ProcessDelegate",          "UObject",      "core"),
    ("Modify",                   "UObject",      "core"),
    ("GotoLabel",                "UObject",      "core"),
    ("GotoState",                "UObject",      "core"),
    ("PostEditChange",           "UObject",      "core"),
    ("ScriptConsoleExec",        "UObject",      "core"),
    ("Register",                 "UObject",      "core"),
    ("LanguageChange",           "UObject",      "core"),
    ("IsInState",                "UObject",      "core"),
    ("StaticTick",               "UObject",      "core"),
    ("StaticExec",               "UObject",      "core"),
    ("IsReferenced",             "UObject",      "core"),
    ("AttemptDelete",            "UObject",      "core"),
    ("BindPackage",              "UObject",      "core"),
    ("ResetLoaders",             "UObject",      "core"),
    ("VerifyLinker",             "UObject",      "core"),
    ("GetRegistryObjects",       "UObject",      "core"),
    ("GetPreferences",           "UObject",      "core"),
    ("GlobalSetProperty",        "UObject",      "core"),
    ("ExportProperties",         "UObject",      "core"),
    ("InitClassDefaultObject",   "UObject",      "core"),
    ("CheckDanglingOuter",       "UObject",      "core"),
    ("FindState",                "UObject",      "core"),
    ("FindIntProperty",          "UObject",      "core"),
    ("FindFNameProperty",        "UObject",      "core"),
    ("FindArrayProperty",        "UObject",      "core"),
    ("LoadConfig",               "UObject",      "core"),
    ("ResetConfig",              "UObject",      "core"),
    ("UObject_EStaticConstructor","UObject",     "core"),
    ("AddCppProperty",           "UField",       "core"),
    ("Main",                     "UCommandlet",  "core"),
    ("Exec",                     "USystem",      "core"),
    ("StaticConstructor",        "UExporter",    "core"),
    ("StaticConstructor",        "UFactory",     "core"),
    ("CanSerializeObject",       "UPackageMap",  "core"),
    ("IndexToObject",            "UPackageMap",  "core"),
    ("ObjectToIndex",            "UPackageMap",  "core"),
    # FFileStream
    ("Create",                   "FFileStream",  "core"),
    ("CreateStream",             "FFileStream",  "core"),
    ("Destroy",                  "FFileStream",  "core"),
    ("DestroyStream",            "FFileStream",  "core"),
    ("Enter",                    "FFileStream",  "core"),
    ("Leave",                    "FFileStream",  "core"),
    ("Read",                     "FFileStream",  "core"),
    ("RequestChunks",            "FFileStream",  "core"),

    # Engine stubs
    ("CheckOwnerUpdated",        "AActor",       "engine"),
    ("TestCanSeeMe",             "AActor",       "engine"),
    ("GetR6AvailabilityPtr",     "AActor",       "engine"),
    ("CheckCircularReferences",  "UMaterial",    "engine"),
    ("CheckCircularReferences",  "UShader",      "engine"),
    ("CheckCircularReferences",  "UCombiner",    "engine"),
    ("HurtByVolume",             "APawn",        "engine"),
    ("R6LineOfSightTo",          "APawn",        "engine"),
    ("R6SeePawn",                "APawn",        "engine"),
    ("Reachable",                "APawn",        "engine"),
    ("CanCrouchWalk",            "APawn",        "engine"),
    ("CanProneWalk",             "APawn",        "engine"),
    ("Pick3DWallAdjust",         "APawn",        "engine"),
    ("PickWallAdjust",           "APawn",        "engine"),
    ("ValidAnchor",              "APawn",        "engine"),
    ("checkFloor",               "APawn",        "engine"),
    ("findNewFloor",             "APawn",        "engine"),
    ("flyReachable",             "APawn",        "engine"),
    ("jumpReachable",            "APawn",        "engine"),
    ("ladderReachable",          "APawn",        "engine"),
    ("pointReachable",           "APawn",        "engine"),
    ("swimReachable",            "APawn",        "engine"),
    ("walkReachable",            "APawn",        "engine"),
    ("CheckAnimFinished",        "AController",  "engine"),
    ("CanHear",                  "AController",  "engine"),
    ("SetPath",                  "AController",  "engine"),

    # WinDrv stubs
    ("Lock",                     "UWindowsViewport", "windrv"),
    ("Unlock",                   "UWindowsViewport", "windrv"),
    ("Hold",                     "UWindowsViewport", "windrv"),
    ("JoystickInputEvent",       "UWindowsViewport", "windrv"),
    ("NotifyDestroy",            "UWindowsClient",   "windrv"),
    ("Exec",                     "UWindowsClient",   "windrv"),
]

def main():
    dlls = {
        'core':   ('retail/system/Core.dll',   'build/retail_core_exports.txt'),
        'engine': ('retail/system/Engine.dll', 'build/retail_engine_exports.txt'),
        'windrv': ('retail/system/WinDrv.dll', 'build/retail_windrv_exports.txt'),
    }
    dll_data    = {}
    dll_exports = {}
    for name, (dll_path, exp_path) in dlls.items():
        try:
            dll_data[name]    = open(dll_path, 'rb').read()
        except FileNotFoundError:
            dll_data[name]    = b''
        dll_exports[name] = load_exports(exp_path)
        print(f"Loaded {name}: {len(dll_exports[name])} exports, {len(dll_data[name])//1024}KB DLL")

    print()
    results = []
    for fname, cls, dll in STUBS:
        exp = dll_exports[dll]
        data = dll_data[dll]
        matches = [(k, v) for k, v in exp.items() if fname in k and cls in k]
        if not matches:
            results.append((dll, cls, fname, 'NOTFOUND', 0, ''))
            continue
        # Pick best match (shortest name = least decorated)
        k, rva = min(matches, key=lambda x: len(x[0]))
        cat, size = classify(data, rva)
        snippet = ''
        if cat in ('TINY', 'SHORT') and HAS_CAPSTONE:
            snippet = '\n' + disasm_snippet(data, rva, min(size+4, 64))
        results.append((dll, cls, fname, cat, size, snippet))

    # Print grouped by category
    for cat_filter in ('EMPTY', 'TINY', 'SHORT', 'MEDIUM', 'LARGE', 'NOTFOUND', 'INVALID'):
        items = [(d,c,f,cat,sz,snip) for d,c,f,cat,sz,snip in results if cat==cat_filter]
        if not items: continue
        print(f"=== {cat_filter} ({len(items)}) ===")
        for d, c, f, cat, sz, snip in items:
            print(f"  [{d}] {c}::{f}  ~{sz}b{snip}")
        print()

if __name__ == '__main__':
    main()
