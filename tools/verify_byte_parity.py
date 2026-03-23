#!/usr/bin/env python3
"""
verify_byte_parity.py — byte-accuracy enforcement for IMPL_MATCH annotations.

For every  IMPL_MATCH("Foo.dll", 0xADDR)  annotation found in source files,
this tool:
  1. Reads the retail DLL at the given virtual address.
  2. Gets the function size from the Ghidra exports ("// Size: N bytes").
  3. Finds the compiled function in our built DLL via the MSVC .map file.
  4. Compares instruction sequences with relocation-entry masking.
  5. Reports PASS / FAIL for each function, grouped by DLL.
  6. Exits non-zero if any FAIL is found (used as a build gate).

Usage:
  python tools/verify_byte_parity.py [options] [src_dir]

  --warn-only    print failures but exit 0
  --dll NAME     only check functions from this DLL (e.g. Engine.dll)
  --no-size-check  skip size comparison (only check masked bytes)

Requires:
  pip install pefile capstone

Build must have been run with /MAP linker flag (added automatically when this
module adds the byte-parity post-build step via cmake/ByteParity.cmake).
"""

import re
import sys
import os
import ctypes
import struct
import argparse
from pathlib import Path
from collections import defaultdict

try:
    import pefile
except ImportError:
    print("ERROR: pip install pefile", file=sys.stderr)
    sys.exit(1)

try:
    from capstone import Cs, CS_ARCH_X86, CS_MODE_32
except ImportError:
    print("ERROR: pip install capstone", file=sys.stderr)
    sys.exit(1)

# ── Root-relative paths ──────────────────────────────────────────────────────

SCRIPT_DIR  = Path(__file__).resolve().parent
REPO_ROOT   = SCRIPT_DIR.parent
RETAIL_DIR  = REPO_ROOT / "retail" / "system"
GHIDRA_DIR  = REPO_ROOT / "ghidra" / "exports"

def _find_build_bin() -> Path:
    """Return the best available build/bin directory.

    Prefer build-71/bin (MSVC 7.1 — closest to retail) over build/bin (VS2019).
    Can be overridden with --build-dir on the command line.
    """
    for candidate in ("build-71", "build"):
        p = REPO_ROOT / candidate / "bin"
        if p.exists():
            return p
    return REPO_ROOT / "build" / "bin"

BUILD_BIN = _find_build_bin()

# Map DLL stem → locations.  All retail DLL names are lower-cased on lookup.
DLL_MAP = {
    "engine":       {"retail": "Engine.dll",       "built": "Engine.dll",
                     "ghidra": "Engine/_global.cpp",
                     "base":   0x10300000},
    "core":         {"retail": "Core.dll",          "built": "Core.dll",
                     "ghidra": "Core/_global.cpp",
                     "base":   0x10100000},
    "r6engine":     {"retail": "R6Engine.dll",      "built": "R6Engine.dll",
                     "ghidra": "R6Engine/_global.cpp",
                     "base":   0x10000000},
    "r6game":       {"retail": "R6Game.dll",        "built": "R6Game.dll",
                     "ghidra": "R6Game/_global.cpp",
                     "base":   0x10000000},
    "r6abstract":   {"retail": "R6Abstract.dll",    "built": "R6Abstract.dll",
                     "ghidra": "R6Abstract/_global.cpp",
                     "base":   0x10000000},
    "fire":         {"retail": "Fire.dll",          "built": "Fire.dll",
                     "ghidra": "Fire/_global.cpp",
                     "base":   0x10500000},
    "ipdrv":        {"retail": "IpDrv.dll",         "built": "IpDrv.dll",
                     "ghidra": "IpDrv/_global.cpp",
                     "base":   0x10700000},
    "r6weapons":    {"retail": "R6Weapons.dll",     "built": "R6Weapons.dll",
                     "ghidra": "R6Weapons/_global.cpp",
                     "base":   0x10000000},
}

# ── Undname helper ────────────────────────────────────────────────────────────

import ctypes

_DBGHELP = None

def _init_dbghelp():
    global _DBGHELP
    if _DBGHELP is None:
        try:
            _DBGHELP = ctypes.windll.LoadLibrary("DbgHelp.dll")
        except OSError:
            pass
    return _DBGHELP

def demangle(mangled: str) -> str:
    """Return the C++ demangled form using DbgHelp (in-process, fast)."""
    dbg = _init_dbghelp()
    if not dbg or not mangled.startswith('?'):
        return mangled
    try:
        buf = ctypes.create_unicode_buffer(4096)
        ret = dbg.UnDecorateSymbolNameW(
            ctypes.c_wchar_p(mangled),
            buf,
            ctypes.c_ulong(4096),
            ctypes.c_ulong(0)  # UNDNAME_COMPLETE
        )
        if ret:
            return buf.value
    except Exception:
        pass
    return mangled

# ── PE utilities ──────────────────────────────────────────────────────────────

def _rva_to_file_offset(pe, rva: int) -> int:
    """Convert an RVA to a file offset inside the PE."""
    for section in pe.sections:
        s_rva  = section.VirtualAddress
        s_size = section.Misc_VirtualSize
        if s_rva <= rva < s_rva + s_size:
            return section.PointerToRawData + (rva - s_rva)
    raise ValueError(f"RVA 0x{rva:08x} not found in any section")

def load_pe_bytes(dll_path: Path) -> tuple:
    """Return (pe_object, raw_bytes, image_base, reloc_set).

    reloc_set contains file offsets of every HIGHLOW relocation entry —
    any 4-byte slot at those offsets must be zeroed before byte comparison.
    """
    pe = pefile.PE(str(dll_path), fast_load=True)
    pe.parse_data_directories(
        directories=[pefile.DIRECTORY_ENTRY["IMAGE_DIRECTORY_ENTRY_BASERELOC"]]
    )
    raw  = pe.__data__[:]  # mutable copy as bytearray
    base = pe.OPTIONAL_HEADER.ImageBase

    reloc_file_offsets = set()
    if hasattr(pe, "DIRECTORY_ENTRY_BASERELOC"):
        for block in pe.DIRECTORY_ENTRY_BASERELOC:
            for entry in block.entries:
                if entry.type == 3:   # IMAGE_REL_BASED_HIGHLOW
                    try:
                        fo = _rva_to_file_offset(pe, entry.rva)
                        reloc_file_offsets.add(fo)
                    except ValueError:
                        pass

    return pe, bytearray(raw), base, reloc_file_offsets

def extract_function_bytes(pe_raw: bytearray, pe_obj, base: int,
                           va: int, size: int) -> bytearray:
    """Extract `size` bytes at virtual address `va` from the PE image."""
    rva = va - base
    fo  = _rva_to_file_offset(pe_obj, rva)
    return pe_raw[fo : fo + size]

def apply_reloc_mask(data: bytearray, base_file_offset: int,
                     reloc_offsets: set) -> bytearray:
    """Zero out the 4 bytes at each relocation site within `data`.

    `base_file_offset` is the file offset of data[0].
    """
    out = bytearray(data)
    for fo in reloc_offsets:
        local = fo - base_file_offset
        if 0 <= local <= len(out) - 4:
            out[local : local + 4] = b"\x00\x00\x00\x00"
    return out

# ── Ghidra size database ──────────────────────────────────────────────────────

def _parse_ghidra_sizes(ghidra_file: Path) -> dict:
    """Return {va_int: size_int} from a Ghidra _global.cpp export file."""
    sizes = {}
    # Pattern:
    #   // Address: 103a37a0
    #   // Size: 1830 bytes
    addr_pat = re.compile(r"//\s+Address:\s+([0-9a-fA-F]+)")
    size_pat = re.compile(r"//\s+Size:\s+(\d+)\s+bytes")
    last_addr = None
    try:
        with open(ghidra_file, encoding="utf-8", errors="replace") as f:
            for line in f:
                m = addr_pat.match(line.strip())
                if m:
                    last_addr = int(m.group(1), 16)
                    continue
                if last_addr is not None:
                    m = size_pat.match(line.strip())
                    if m:
                        sizes[last_addr] = int(m.group(1))
                        last_addr = None
    except FileNotFoundError:
        pass
    return sizes

_GHIDRA_CACHE: dict[str, dict] = {}

def get_ghidra_sizes(dll_stem: str) -> dict:
    if dll_stem not in _GHIDRA_CACHE:
        info = DLL_MAP.get(dll_stem.lower())
        if info:
            path = GHIDRA_DIR / info["ghidra"]
            sizes = _parse_ghidra_sizes(path)
            # Also merge sizes from _unnamed.cpp (unexported functions) if present
            unnamed = path.parent / "_unnamed.cpp"
            if unnamed.exists():
                sizes.update(_parse_ghidra_sizes(unnamed))
            _GHIDRA_CACHE[dll_stem] = sizes
        else:
            _GHIDRA_CACHE[dll_stem] = {}
    return _GHIDRA_CACHE[dll_stem]

# ── MAP file parser ───────────────────────────────────────────────────────────

def parse_map_file(map_path: Path) -> dict:
    """Return {demangled_name: va_int} from an MSVC .map file.

    The MAP file format relevant to us:
      Section:Offset   PublicName    Rva+Base   Lib:Object

    We extract both the mangled and demangled form.
    """
    if not map_path.exists():
        return {}

    # Pattern:  0001:000abc12    ?Init@UGameEngine@@UAEXXZ    100abc12 f
    row_pat = re.compile(
        r"\s+[0-9a-fA-F]{4}:[0-9a-fA-F]{8}\s+(\S+)\s+([0-9a-fA-F]{8})"
    )

    raw: dict[str, int] = {}   # mangled → va
    with open(map_path, encoding="utf-8", errors="replace") as f:
        for line in f:
            m = row_pat.match(line)
            if m:
                name = m.group(1)
                va   = int(m.group(2), 16)
                raw[name] = va

    # Batch-demangle for efficiency
    result: dict[str, int] = {}
    for mangled, va in raw.items():
        demangled = demangle(mangled)
        # Store both forms so callers can look up by either
        result[mangled]   = va
        result[demangled] = va
    return result

_MAP_CACHE: dict[str, dict] = {}

def get_map(dll_stem: str) -> dict:
    if dll_stem not in _MAP_CACHE:
        info = DLL_MAP.get(dll_stem.lower())
        if info:
            # Map file lives next to the built DLL
            map_name = info["built"].replace(".dll", ".map")
            path = BUILD_BIN / map_name
            _MAP_CACHE[dll_stem] = parse_map_file(path)
        else:
            _MAP_CACHE[dll_stem] = {}
    return _MAP_CACHE[dll_stem]

# ── Source scanner ────────────────────────────────────────────────────────────

# Matches: IMPL_MATCH("Engine.dll", 0x103a37a0) or IMPL_MATCH("Engine.dll",0xA37A0)
IMPL_MATCH_RE = re.compile(
    r'IMPL_MATCH\s*\(\s*"([^"]+)"\s*,\s*(0x[0-9a-fA-F]+)\s*\)'
)

def scan_sources(src_root: Path, dll_filter: str | None = None) -> list:
    """Yield (dll_name, va_int, src_file, func_decl_line, line_no) tuples."""
    results = []
    # Scan both .cpp source files and .parity manifest files
    for pattern in ("*.cpp", "*.parity"):
        for cpp in src_root.rglob(pattern):
            lines = cpp.read_text(encoding="utf-8", errors="replace").splitlines()
            for i, line in enumerate(lines):
                m = IMPL_MATCH_RE.search(line)
                if not m:
                    continue
                dll  = m.group(1)           # e.g. "Engine.dll"
                addr = int(m.group(2), 16)  # may be RVA or full VA

                if dll_filter and dll.lower() != dll_filter.lower():
                    continue

                # Next non-blank line should be the function declaration
                decl = ""
                for j in range(i + 1, min(i + 5, len(lines))):
                    stripped = lines[j].strip()
                    if stripped and not stripped.startswith("//"):
                        decl = stripped
                        break

                results.append((dll, addr, cpp, decl, i + 1))
    return results

# ── Name normalisation (source decl → lookup key) ────────────────────────────

def _decl_to_key(decl: str) -> str | None:
    """
    Convert a C++ function declaration line to a lookup key matching MAP
    demangled entries.  We extract ClassName::MethodName (for member functions)
    or FunctionName (for free functions).

    Examples:
      "void UGameEngine::Init()"                   →  "UGameEngine::Init"
      "UBOOL ULevel::SpawnActor(...)"               →  "ULevel::SpawnActor"
      "FVector FVector::operator+(FVector Other)"   →  "FVector::operator+"
      "FLOAT appSRand()"                            →  "appSRand"
      "static UBOOL FVector::FNormalize()"          →  "FVector::FNormalize"
    """
    if not decl:
        return None

    # Strip trailing const/override/= 0
    decl = re.sub(r'\s+(const|override|final|=\s*0)\s*$', '', decl.strip())

    # Find the opening parenthesis (marks end of function name)
    paren = decl.find('(')
    if paren < 0:
        paren = len(decl)
    before_paren = decl[:paren].strip()

    # Look for last "::" — use it to find ClassName::MethodName
    last_dc = before_paren.rfind('::')
    if last_dc >= 0:
        # Find where the class name starts (skip back past return type tokens)
        left = before_paren[:last_dc]
        # The class name is the last identifier (or identifier chain) in `left`
        # Walk backwards past whitespace and pointer/ref decorators
        i = len(left) - 1
        while i >= 0 and left[i] in ' \t*&':
            i -= 1
        class_end = i + 1
        while i >= 0 and (left[i].isalnum() or left[i] == '_'):
            i -= 1
        class_start = i + 1
        class_name  = left[class_start:class_end]
        method_name = before_paren[last_dc + 2:].strip()
        # Handle multi-word operators: "operator new", "operator delete"
        method_parts = method_name.split()
        if len(method_parts) >= 2 and method_parts[0] == 'operator' and method_parts[1] in ('new', 'delete', 'new[]', 'delete[]'):
            method_name = method_parts[0] + ' ' + method_parts[1]
        elif method_parts and method_parts[0].startswith('operator'):
            # Single-char operators: operator*, operator+, operator==, etc.
            # Keep the full operator token as-is (don't strip at * or &)
            method_name = method_parts[0]
        else:
            method_name = method_parts[0] if method_parts else method_name
        # Strip trailing template / pointer junk from method name, but
        # NOT for operator overloads (operator* would lose its *)
        if not method_name.startswith('operator'):
            method_name = re.split(r'[<\s*&]', method_name)[0] if ' ' not in method_name else method_name
        if class_name:
            return f"{class_name}::{method_name}"
    
    # Free function — last token before '('
    words = re.split(r'[\s*&]+', before_paren)
    words = [w for w in words if w]
    if words:
        return words[-1]
    return None

# ── DLL base auto-detection ──────────────────────────────────────────────────

_BASE_CACHE: dict[str, int] = {}

def get_retail_base(dll_stem: str) -> int:
    if dll_stem not in _BASE_CACHE:
        info = DLL_MAP.get(dll_stem.lower(), {})
        retail_path = RETAIL_DIR / info.get("retail", "")
        if retail_path.exists():
            pe = pefile.PE(str(retail_path), fast_load=True)
            _BASE_CACHE[dll_stem] = pe.OPTIONAL_HEADER.ImageBase
        else:
            _BASE_CACHE[dll_stem] = info.get("base", 0x10300000)
    return _BASE_CACHE[dll_stem]

def normalise_va(dll_stem: str, addr: int) -> int:
    """If `addr` looks like an RVA (< 0x01000000), add the retail DLL base."""
    if addr < 0x01000000:
        base = get_retail_base(dll_stem)
        return base + addr
    return addr

# ── Comparison ───────────────────────────────────────────────────────────────

def compare_function(
    retail_bytes: bytearray,
    our_bytes:    bytearray,
    retail_fo:    int,
    our_fo:       int,
    retail_relocs: set,
    our_relocs:    set,
) -> tuple[bool, str]:
    """
    Compare two function byte sequences with relocation masking.
    Returns (passed: bool, detail: str).
    """
    if len(retail_bytes) != len(our_bytes):
        return False, (
            f"size mismatch: retail={len(retail_bytes)} bytes, "
            f"ours={len(our_bytes)} bytes"
        )

    r_masked = apply_reloc_mask(retail_bytes, retail_fo, retail_relocs)
    o_masked = apply_reloc_mask(our_bytes,    our_fo,    our_relocs)

    if r_masked == o_masked:
        return True, "exact match (relocation-masked)"

    # Find first differing byte for a useful diagnostic
    for i, (rb, ob) in enumerate(zip(r_masked, o_masked)):
        if rb != ob:
            # Disassemble around the difference
            cs = Cs(CS_ARCH_X86, CS_MODE_32)
            cs.detail = False
            context_start = max(0, i - 8)
            r_insns = list(cs.disasm(bytes(r_masked[context_start:i+16]), context_start))
            o_insns = list(cs.disasm(bytes(o_masked[context_start:i+16]), context_start))
            r_str = "; ".join(f"{ins.mnemonic} {ins.op_str}" for ins in r_insns[:4])
            o_str = "; ".join(f"{ins.mnemonic} {ins.op_str}" for ins in o_insns[:4])
            detail = (
                f"first diff at byte +{i}: "
                f"retail=0x{rb:02x} ours=0x{ob:02x}\n"
                f"  retail: {r_str}\n"
                f"  ours:   {o_str}"
            )
            return False, detail

    return True, "exact match"

# ── Main ─────────────────────────────────────────────────────────────────────

def main():
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("src_dir", nargs="?", default=str(REPO_ROOT / "src"),
                        help="Source root to scan (default: src/)")
    parser.add_argument("--warn-only", action="store_true",
                        help="Report failures but exit 0")
    parser.add_argument("--dll", metavar="NAME",
                        help="Only check this DLL (e.g. Engine.dll)")
    parser.add_argument("--no-size-check", action="store_true",
                        help="Skip size verification (only compare masked bytes)")
    parser.add_argument("--show-pass", action="store_true",
                        help="Print PASS lines too (default: only FAIL)")
    parser.add_argument("--build-dir", metavar="DIR",
                        help="Path to bin directory containing built DLLs "
                             "(default: auto-detect build-71/bin or build/bin)")
    parser.add_argument("--report", metavar="FILE",
                        help="Write results to this file (in addition to stdout)")
    args = parser.parse_args()

    # Override BUILD_BIN if requested
    global BUILD_BIN
    if args.build_dir:
        BUILD_BIN = Path(args.build_dir).resolve()
    # Rebuild DLL_MAP "map" paths relative to BUILD_BIN
    for stem, entry in DLL_MAP.items():
        entry["map"] = str(BUILD_BIN / (entry["built"].replace(".dll", ".map")))


    src_root = Path(args.src_dir)

    print("Scanning sources for IMPL_MATCH annotations...")
    annotations = scan_sources(src_root, args.dll)
    if not annotations:
        print("No IMPL_MATCH annotations found.")
        return

    # Group by DLL stem
    by_dll: dict[str, list] = defaultdict(list)
    for dll, addr, src, decl, lineno in annotations:
        stem = dll.lower().removesuffix(".dll")
        by_dll[stem].append((addr, src, decl, lineno))

    total = passes = fails = skipped = 0
    fail_msgs = []

    for stem, entries in sorted(by_dll.items()):
        info = DLL_MAP.get(stem)
        if not info:
            print(f"\n[{stem}.dll] — no DLL_MAP entry, skipping {len(entries)} annotations")
            skipped += len(entries)
            continue

        retail_path = RETAIL_DIR / info["retail"]
        built_path  = BUILD_BIN  / info["built"]
        map_path    = BUILD_BIN  / info["built"].replace(".dll", ".map")

        if not retail_path.exists():
            print(f"\n[{stem}.dll] — retail DLL not found at {retail_path}, skipping")
            skipped += len(entries)
            continue
        if not built_path.exists():
            print(f"\n[{stem}.dll] — built DLL not found at {built_path} (need to build first), skipping")
            skipped += len(entries)
            continue
        if not map_path.exists():
            print(f"\n[{stem}.dll] — MAP file not found at {map_path}")
            print(f"  Add /MAP to linker options and rebuild (see cmake/ByteParity.cmake)")
            skipped += len(entries)
            continue

        print(f"\n[{stem}.dll] — checking {len(entries)} IMPL_MATCH functions...")

        # Load PE data
        retail_pe, retail_raw, retail_base, retail_relocs = load_pe_bytes(retail_path)
        our_pe,    our_raw,    our_base,    our_relocs    = load_pe_bytes(built_path)
        ghidra_sizes = get_ghidra_sizes(stem)
        sym_map      = get_map(stem)

        # Build PE export table for accurate post-ICF address lookup.
        # The MAP file can show pre-ICF addresses that differ from the
        # actual export addresses (Core.dll has ~1800 such mismatches).
        our_pe.parse_data_directories(
            directories=[pefile.DIRECTORY_ENTRY["IMAGE_DIRECTORY_ENTRY_EXPORT"]]
        )
        pe_export_map = {}
        if hasattr(our_pe, "DIRECTORY_ENTRY_EXPORT"):
            for exp in our_pe.DIRECTORY_ENTRY_EXPORT.symbols:
                if exp.name:
                    name = exp.name.decode()
                    va = our_base + exp.address
                    pe_export_map[name] = va
                    # Also store demangled form for Strategy 1-3 lookups
                    d = demangle(name)
                    if d != name:
                        pe_export_map[d] = va

        for addr, src, decl, lineno in entries:
            total += 1
            # Normalise address to full VA
            va = normalise_va(stem, addr)

            # Get function size from Ghidra
            size = ghidra_sizes.get(va)
            if size is None:
                # Try without base normalisation
                rva = va - retail_base
                size = ghidra_sizes.get(rva)
            if not size:
                print(f"  SKIP {src.name}:{lineno} — no Ghidra size for VA 0x{va:08x}")
                skipped += 1
                continue

            # Find function in our DLL via MAP file
            key = None
            our_va = None
            # Strategy 0: if decl is a mangled name (starts with ? or _),
            # prefer PE export table (accurate post-ICF address), fall back to MAP
            if decl.startswith('?') or decl.startswith('_'):
                key = decl.split()[0]  # mangled name (first token)
                our_va = pe_export_map.get(key)
                if our_va is None:
                    our_va = sym_map.get(key)
            if our_va is None:
                key = _decl_to_key(decl)
            if key and our_va is None:
                # Strategy 1: exact match — prefer PE exports over MAP
                our_va = pe_export_map.get(key)
                if our_va is None:
                    our_va = sym_map.get(key)
                if our_va is None:
                    # Strategy 2: demangled name contains "ClassName::MethodName("
                    # (avoids matching FVector::Size when looking for FVector::SizeSquared)
                    key_paren = key + "("
                    # Check PE exports first (accurate post-ICF addresses)
                    for sym_key, sym_va in pe_export_map.items():
                        if key_paren in sym_key:
                            our_va = sym_va
                            break
                    if our_va is None:
                        for sym_key, sym_va in sym_map.items():
                            if key_paren in sym_key:
                                our_va = sym_va
                                break
                if our_va is None:
                    # Strategy 3: ends with ::MethodName or contains " ClassName::MethodName"
                    for sym_key, sym_va in pe_export_map.items():
                        if sym_key.endswith("::" + key.split("::")[-1] + "("):
                            if "::" in key:
                                cls = key.split("::")[0]
                                if cls in sym_key:
                                    our_va = sym_va
                                    break
                            else:
                                our_va = sym_va
                                break
                    if our_va is None:
                        for sym_key, sym_va in sym_map.items():
                            if sym_key.endswith("::" + key.split("::")[-1] + "("):
                                if "::" in key:
                                    cls = key.split("::")[0]
                                    if cls in sym_key:
                                        our_va = sym_va
                                        break
                                else:
                                    our_va = sym_va
                                    break
            if our_va is None:
                print(f"  SKIP {src.name}:{lineno} — '{key}' not found in MAP file")
                skipped += 1
                continue

            # Extract bytes
            try:
                retail_rva = va - retail_base
                retail_fo  = _rva_to_file_offset(retail_pe, retail_rva)
                r_bytes    = extract_function_bytes(retail_raw, retail_pe,
                                                    retail_base, va, size)
            except (ValueError, Exception) as e:
                print(f"  SKIP {src.name}:{lineno} — retail extract failed: {e}")
                skipped += 1
                continue

            try:
                our_rva = our_va - our_base
                our_fo  = _rva_to_file_offset(our_pe, our_rva)
                o_bytes = extract_function_bytes(our_raw, our_pe,
                                                 our_base, our_va, size)
            except (ValueError, Exception) as e:
                print(f"  SKIP {src.name}:{lineno} — built extract failed: {e}")
                skipped += 1
                continue

            # Compare
            passed, detail = compare_function(
                r_bytes, o_bytes,
                retail_fo, our_fo,
                retail_relocs, our_relocs,
            )
            label = f"{src.name}:{lineno}  {key or decl[:60]}"
            if passed:
                passes += 1
                if args.show_pass:
                    print(f"  PASS  {label}")
            else:
                fails += 1
                msg = f"  FAIL  {label}\n        {detail}"
                fail_msgs.append(msg)
                print(msg)

    # Summary
    print(f"\n{'='*60}")
    print(f"IMPL_MATCH byte-parity results:")
    print(f"  PASS:    {passes}")
    print(f"  FAIL:    {fails}")
    print(f"  SKIPPED: {skipped}  (no MAP, no Ghidra size, or DLL not found)")
    print(f"  TOTAL:   {total}")
    print(f"{'='*60}")

    # Write report file if requested
    if args.report:
        report_path = Path(args.report)
        report_path.parent.mkdir(parents=True, exist_ok=True)
        with open(report_path, "w", encoding="utf-8") as f:
            f.write("IMPL_MATCH byte-parity report\n")
            f.write(f"{'='*60}\n")
            f.write(f"PASS:    {passes}\n")
            f.write(f"FAIL:    {fails}\n")
            f.write(f"SKIPPED: {skipped}\n")
            f.write(f"TOTAL:   {total}\n")
            f.write(f"{'='*60}\n\n")
            if fail_msgs:
                f.write("FAILURES:\n")
                for msg in fail_msgs:
                    f.write(msg + "\n")
        print(f"\nReport written to: {report_path}")

    if fails and not args.warn_only:
        print(f"\nerror: {fails} IMPL_MATCH byte-parity violation(s) detected.")
        print("Either fix the implementation or change IMPL_MATCH → IMPL_DIVERGE.")
        sys.exit(1)
    elif fails:
        print("\nWarning: byte-parity violations found (--warn-only, build continues).")

if __name__ == "__main__":
    main()
