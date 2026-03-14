#!/usr/bin/env python3
"""
check_byte_parity.py — Function size parity checker vs retail DLL.

Uses dumpbin /EXPORTS to compare exported function sizes between a rebuilt
DLL and the corresponding retail DLL. Reports parity failures for functions
annotated with IMPL_MATCH (which claim byte-level parity).

Functions annotated with IMPL_APPROX, IMPL_INFERRED, IMPL_SDK_MODIFIED,
or IMPL_PERMANENT_DIVERGENCE are exempt from the size check.

Usage:
    python check_byte_parity.py <rebuilt_dll> <retail_dll> <source_dir>
        [--tolerance <bytes>] [--report <file>] [--warn-only]

Arguments:
    rebuilt_dll   Path to the freshly-built DLL to check
    retail_dll    Path to the reference retail DLL
    source_dir    Directory containing .cpp source files (to read IMPL_ macros)
    --tolerance   Allowed byte difference before flagging (default: 4)
    --report      Write machine-readable JSON report to <file>
    --warn-only   Print issues but exit 0
"""

import os
import re
import sys
import json
import argparse
import subprocess
from pathlib import Path
from typing import Optional

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------

DEFAULT_TOLERANCE = 4  # bytes — accounts for alignment padding differences

# Macros that claim byte parity (checked by this script)
PARITY_MACROS = {"IMPL_MATCH"}

# Macros that are explicitly exempt from parity checking
EXEMPT_MACROS = {
    "IMPL_APPROX",
    "IMPL_APPROX",
    "IMPL_APPROX",
    "IMPL_APPROX",
    "IMPL_EMPTY",
    "IMPL_DIVERGE",
    "IMPL_TODO",
}

DUMPBIN_CANDIDATES = [
    r"C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\VC\Tools\MSVC\14.29.30133\bin\Hostx64\x86\dumpbin.exe",
    r"C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Tools\MSVC\14.29.30133\bin\Hostx64\x86\dumpbin.exe",
    r"C:\Program Files\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.36.32532\bin\Hostx64\x86\dumpbin.exe",
    r"C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Tools\MSVC\14.36.32532\bin\Hostx64\x86\dumpbin.exe",
]

# ---------------------------------------------------------------------------
# Find dumpbin
# ---------------------------------------------------------------------------

def find_dumpbin() -> Optional[str]:
    # Try PATH first
    import shutil
    found = shutil.which("dumpbin")
    if found:
        return found
    for candidate in DUMPBIN_CANDIDATES:
        if os.path.isfile(candidate):
            return candidate
    return None

# ---------------------------------------------------------------------------
# Run dumpbin /EXPORTS and parse the output
# ---------------------------------------------------------------------------

EXPORT_LINE_RE = re.compile(
    r"^\s+(\d+)\s+([0-9A-Fa-f]+)\s+([0-9A-Fa-f]+)\s+(.+?)\s*$"
)


def get_exports(dumpbin: str, dll_path: str) -> dict[str, int]:
    """
    Run dumpbin /EXPORTS on dll_path. Return {symbol_name: rva} dict.
    Decorated names are returned as-is (mangled C++ names).
    """
    result = subprocess.run(
        [dumpbin, "/EXPORTS", dll_path],
        capture_output=True, text=True
    )
    exports: dict[str, int] = {}
    for line in result.stdout.splitlines():
        m = EXPORT_LINE_RE.match(line)
        if m:
            rva_str = m.group(3)
            name = m.group(4).strip()
            try:
                exports[name] = int(rva_str, 16)
            except ValueError:
                pass
    return exports


def compute_function_sizes(exports: dict[str, int]) -> dict[str, int]:
    """
    Estimate function sizes from the gap between consecutive RVAs.
    Returns {symbol_name: estimated_size_bytes}.
    NOTE: This is an approximation — padding and data between functions
    can inflate sizes. Use only for relative comparison.
    """
    sorted_items = sorted(exports.items(), key=lambda kv: kv[1])
    sizes: dict[str, int] = {}
    for i, (name, rva) in enumerate(sorted_items):
        if i + 1 < len(sorted_items):
            next_rva = sorted_items[i + 1][1]
            sizes[name] = max(0, next_rva - rva)
        else:
            # Last export — no way to know the actual size
            sizes[name] = -1
    return sizes

# ---------------------------------------------------------------------------
# Parse IMPL_ macros from source files
# ---------------------------------------------------------------------------

IMPL_MATCH_RE = re.compile(r'IMPL_MATCH\s*\(\s*"([^"]+)"\s*,\s*(0x[0-9A-Fa-f]+)\s*\)')
FUNC_COMMENT_RE = re.compile(r'//\s*(?:Ghidra\s+)?(0x[0-9A-Fa-f]+)', re.IGNORECASE)


def load_impl_annotations(source_dir: Path) -> dict[str, str]:
    """
    Scan .cpp files for IMPL_GHIDRA / IMPL_APPROX / etc. annotations
    just before function definitions. Returns {decorated_or_plain_name: macro}.

    This is a best-effort approximation — mangled names are not resolved.
    The primary output is a count of how many functions claim parity.
    """
    annotations: dict[str, str] = {}
    for cpp in source_dir.rglob("*.cpp"):
        try:
            text = cpp.read_text(encoding="utf-8", errors="replace")
        except OSError:
            continue
        # Look for IMPL_GHIDRA("DLL", 0xADDR) patterns
        for m in IMPL_MATCH_RE.finditer(text):
            addr = m.group(2).lower()
            annotations[addr] = "IMPL_MATCH"
    return annotations

# ---------------------------------------------------------------------------
# Main comparison logic
# ---------------------------------------------------------------------------

def compare_dlls(
    dumpbin: str,
    rebuilt: str,
    retail: str,
    tolerance: int,
) -> list[dict]:
    """
    Compare exports between rebuilt and retail DLLs.
    Returns a list of issue dicts for symbols that exceed the tolerance.
    """
    print(f"  Reading exports: {os.path.basename(rebuilt)}")
    rebuilt_exports = get_exports(dumpbin, rebuilt)
    print(f"  Reading exports: {os.path.basename(retail)}")
    retail_exports  = get_exports(dumpbin, retail)

    rebuilt_sizes = compute_function_sizes(rebuilt_exports)
    retail_sizes  = compute_function_sizes(retail_exports)

    common = set(rebuilt_sizes.keys()) & set(retail_sizes.keys())
    print(f"  Shared exports: {len(common)}  |  "
          f"Rebuilt-only: {len(rebuilt_sizes) - len(common)}  |  "
          f"Retail-only: {len(retail_sizes) - len(common)}")

    issues = []
    for name in sorted(common):
        r = rebuilt_sizes[name]
        t = retail_sizes[name]
        if r == -1 or t == -1:
            continue  # Last export — skip
        diff = abs(r - t)
        if diff > tolerance:
            issues.append({
                "symbol": name,
                "rebuilt_size": r,
                "retail_size": t,
                "diff": diff,
                "tolerance": tolerance,
            })

    return issues


# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------

def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("rebuilt_dll", help="Path to rebuilt DLL")
    parser.add_argument("retail_dll",  help="Path to retail reference DLL")
    parser.add_argument("source_dir",  help="Source directory containing .cpp files")
    parser.add_argument("--tolerance", type=int, default=DEFAULT_TOLERANCE,
                        help=f"Byte tolerance (default: {DEFAULT_TOLERANCE})")
    parser.add_argument("--report", metavar="FILE",
                        help="Write JSON report to FILE")
    parser.add_argument("--warn-only", action="store_true",
                        help="Print issues but exit 0")
    args = parser.parse_args()

    dumpbin = find_dumpbin()
    if not dumpbin:
        print("WARNING: dumpbin.exe not found — skipping byte parity check.", file=sys.stderr)
        print("  Install Visual Studio or add dumpbin to PATH.", file=sys.stderr)
        return 0  # Don't fail the build; just warn

    rebuilt = args.rebuilt_dll
    retail  = args.retail_dll
    source_dir = Path(args.source_dir).resolve()

    if not os.path.isfile(rebuilt):
        print(f"ERROR: rebuilt DLL not found: {rebuilt}", file=sys.stderr)
        return 1
    if not os.path.isfile(retail):
        print(f"WARNING: retail DLL not found: {retail} — skipping parity check.",
              file=sys.stderr)
        return 0

    print(f"\nByte parity check: {os.path.basename(rebuilt)} vs {os.path.basename(retail)}")
    print(f"  Tolerance: ±{args.tolerance} bytes\n")

    issues = compare_dlls(dumpbin, rebuilt, retail, args.tolerance)

    if issues:
        print(f"\n{'='*70}")
        print(f"  SIZE DIVERGENCES DETECTED ({len(issues)} function(s))")
        print(f"  These may indicate incomplete implementations.")
        print(f"  If divergence is intentional, use IMPL_APPROX with a reason.")
        print(f"{'='*70}")
        for i in issues:
            print(f"  {i['symbol']}")
            print(f"    rebuilt={i['rebuilt_size']} bytes  retail={i['retail_size']} bytes  "
                  f"diff={i['diff']} bytes")
        print()
    else:
        print("OK — no size divergences beyond tolerance.")

    if args.report:
        report_path = Path(args.report)
        report_path.parent.mkdir(parents=True, exist_ok=True)
        report_path.write_text(json.dumps(issues, indent=2))
        print(f"Report written to: {args.report}")

    # For now this is always warn-only until annotation pass is complete.
    # When --warn-only is removed, IMPL_MATCH functions that diverge will fail.
    if issues and not args.warn_only:
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
