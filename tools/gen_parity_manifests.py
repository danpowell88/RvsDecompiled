#!/usr/bin/env python3
"""
gen_parity_manifests.py — Generate .parity manifest files for macro-generated
functions (StaticClass, InternalConstructor, operator new, etc.) that already
match retail bytes but lack IMPL_MATCH annotations in source.

These manifest files are scanned by verify_byte_parity.py and gen_progress_report.py
alongside .cpp files.
"""
import json, re, glob, os, sys

try:
    import pefile
except ImportError:
    print("ERROR: pip install pefile", file=sys.stderr)
    sys.exit(1)

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RETAIL_DIR = os.path.join(REPO_ROOT, "retail", "system")
BUILD_BIN = os.path.join(REPO_ROOT, "build-71", "bin")
GHIDRA_REPORTS = os.path.join(REPO_ROOT, "ghidra", "exports", "reports")
SRC_DIR = os.path.join(REPO_ROOT, "src")

DLL_CONFIGS = [
    ("Core.dll",        "Core",             "Core"),
    ("Engine.dll",      "Engine",           "Engine"),
    ("R6Engine.dll",    "R6Engine",         "R6Engine"),
    ("R6Game.dll",      "R6Game",           "R6Game"),
    ("R6Weapons.dll",   "R6Weapons",        "R6Weapons"),
    ("Fire.dll",        "Fire",             "Fire"),
    ("IpDrv.dll",       "IpDrv",            "IpDrv"),
    ("R6Abstract.dll",  "R6Abstract",       "R6Abstract"),
    ("D3DDrv.dll",      "D3DDrv",           "D3DDrv"),
    ("DareAudio.dll",   "DareAudio",        "DareAudio"),
    ("DareAudioRelease.dll","DareAudioRelease","DareAudioRelease"),
    ("DareAudioScript.dll","DareAudioScript","DareAudioScript"),
    ("R6GameService.dll","R6GameService",   "R6GameService"),
    ("WinDrv.dll",      "WinDrv",           "WinDrv"),
    ("Window.dll",      "Window",           "Window"),
]


def load_pe(path):
    pe = pefile.PE(path, fast_load=False)
    pe.parse_data_directories(
        directories=[pefile.DIRECTORY_ENTRY["IMAGE_DIRECTORY_ENTRY_BASERELOC"]]
    )
    raw = bytearray(pe.__data__)
    base = pe.OPTIONAL_HEADER.ImageBase
    reloc_offsets = set()
    if hasattr(pe, "DIRECTORY_ENTRY_BASERELOC"):
        for block in pe.DIRECTORY_ENTRY_BASERELOC:
            for entry in block.entries:
                if entry.type == pefile.RELOCATION_TYPE["IMAGE_REL_BASED_HIGHLOW"]:
                    fo = pe.get_offset_from_rva(entry.rva)
                    if fo is not None:
                        for i in range(4):
                            reloc_offsets.add(fo + i)
    return pe, raw, base, reloc_offsets


def get_func_bytes(pe, raw, base, relocs, rva, size):
    fo = pe.get_offset_from_rva(rva)
    if fo is None or fo + size > len(raw):
        return None
    result = bytearray(raw[fo : fo + size])
    for i in range(size):
        if (fo + i) in relocs:
            result[i] = 0
    return bytes(result)


def find_existing_annotations():
    """Return set of (dll_lower, addr_hex_lower) for all existing IMPL_MATCH."""
    annotated = set()
    for ext in ("*.cpp", "*.h", "*.parity"):
        for f in glob.glob(os.path.join(SRC_DIR, "**", ext), recursive=True):
            try:
                content = open(f, encoding="utf-8", errors="replace").read()
            except OSError:
                continue
            for m in re.finditer(
                r'IMPL_MATCH\(\s*"([^"]+\.dll)"\s*,\s*0x([0-9a-fA-F]+)',
                content,
                re.IGNORECASE,
            ):
                annotated.add((m.group(1).lower(), m.group(2).lower()))
    return annotated


def ghidra_name_to_decl(name, addr_hex, dll_name):
    """Convert Ghidra function name to a C++-like declaration for the manifest.

    The verify script extracts ClassName::MethodName from this line.
    """
    # StaticClass → UClass* ClassName::StaticClass()
    if "::StaticClass" in name:
        return f"UClass* {name}()"
    # InternalConstructor → void ClassName::InternalConstructor(void* X)
    if "::InternalConstructor" in name:
        return f"void {name}(void* X)"
    # operator_new with 2 params (placement) → void* ClassName::operator new(size_t, EInternal*)
    if "::operator_new" in name:
        cls = name.split("::")[0]
        return f"void* {cls}::operator new(size_t S, UObject* O, FName N, DWORD F)"
    # Destructors
    if "::~" in name:
        return f"void {name}()"
    # Constructors (copy or default)
    parts = name.split("::")
    if len(parts) == 2 and parts[0] == parts[1]:
        return f"void {name}()"
    if len(parts) == 2 and parts[1] == parts[0]:
        return f"void {name}()"
    # operator=
    if "::operator=" in name:
        cls = name.split("::")[0]
        return f"{cls}& {name}(const {cls}& Other)"
    # operator==, operator!=, etc.
    if "::operator" in name:
        return f"auto {name}()"
    # Generic fallback
    return f"void {name}()"


def main():
    annotated = find_existing_annotations()
    print(f"Found {len(annotated)} existing IMPL_MATCH annotations")

    total_new = 0

    for dll_name, module, src_subdir in DLL_CONFIGS:
        retail_path = os.path.join(RETAIL_DIR, dll_name)
        rebuilt_path = os.path.join(BUILD_BIN, dll_name)
        idx_path = os.path.join(GHIDRA_REPORTS, f"{module}_function_index.json")

        if not all(os.path.exists(p) for p in (retail_path, rebuilt_path, idx_path)):
            continue

        idx = json.load(open(idx_path))

        retail_pe, retail_raw, retail_base, retail_relocs = load_pe(retail_path)
        rebuilt_pe, rebuilt_raw, rebuilt_base, rebuilt_relocs = load_pe(rebuilt_path)

        # Get rebuilt exports by mangled name
        rebuilt_exports = {}
        if hasattr(rebuilt_pe, "DIRECTORY_ENTRY_EXPORT"):
            for exp in rebuilt_pe.DIRECTORY_ENTRY_EXPORT.symbols:
                if exp.name:
                    rebuilt_exports[exp.name.decode("ascii", errors="replace")] = exp.address

        matches = []
        for func in idx["functions"]:
            if not func["exported"] or func.get("unnamed", False):
                continue

            name = func["name"]
            addr_hex = func["addr"].lower()
            size = func["size"]

            # Skip already annotated
            if (dll_name.lower(), addr_hex) in annotated:
                continue

            # Get retail bytes
            retail_rva = int(addr_hex, 16) - retail_base
            retail_bytes = get_func_bytes(
                retail_pe, retail_raw, retail_base, retail_relocs, retail_rva, size
            )
            if not retail_bytes:
                continue

            # Find in rebuilt by mangled name
            mangled = func.get("mangled", "")
            if not mangled or mangled not in rebuilt_exports:
                continue

            rebuilt_rva = rebuilt_exports[mangled]
            rebuilt_bytes = get_func_bytes(
                rebuilt_pe, rebuilt_raw, rebuilt_base, rebuilt_relocs, rebuilt_rva, size
            )
            if rebuilt_bytes and retail_bytes == rebuilt_bytes:
                matches.append((name, addr_hex, size, mangled))

        if not matches:
            continue

        # Write manifest file
        manifest_dir = os.path.join(SRC_DIR, src_subdir, "Src")
        manifest_path = os.path.join(manifest_dir, f"{src_subdir}AutoParity.parity")

        lines = [
            f"// Auto-generated parity manifest for {dll_name}",
            f"// {len(matches)} macro-generated functions verified to match retail bytes.",
            f"// Generated by tools/gen_parity_manifests.py — do not edit manually.",
            "",
        ]

        for name, addr_hex, size, mangled in sorted(matches, key=lambda x: int(x[1], 16)):
            lines.append(f'IMPL_MATCH("{dll_name}", 0x{addr_hex})')
            lines.append(f'{mangled} // {name} ({size} bytes)')
            lines.append("")

        os.makedirs(manifest_dir, exist_ok=True)
        with open(manifest_path, "w", encoding="utf-8") as f:
            f.write("\n".join(lines))

        print(f"  {dll_name}: {len(matches)} new matches → {manifest_path}")
        total_new += len(matches)

    print(f"\nTotal new parity annotations: {total_new}")


if __name__ == "__main__":
    main()
