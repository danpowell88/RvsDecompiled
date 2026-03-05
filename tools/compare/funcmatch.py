#!/usr/bin/env python3
"""
funcmatch.py — Function-level comparison between original and rebuilt PE binaries.

Uses the Ghidra JSON export (from batch_import.py) and MSVC map files to
compare functions at the instruction-byte level.

Usage:
    python funcmatch.py <original.dll> <rebuilt.dll> \\
        --orig-map analysis/original.json \\
        --rebuilt-map build/rebuilt.map

The original function list comes from Ghidra analysis JSON (function table).
The rebuilt function list comes from the MSVC .map file (linker output).

Reports per-function match percentages sorted worst-first for triage.
"""

import argparse
import json
import re
import struct
import sys
from pathlib import Path


# ---------------------------------------------------------------------------
# PE helpers (same minimal approach as bindiff.py)
# ---------------------------------------------------------------------------

def _read_u16(data, off):
    return struct.unpack_from('<H', data, off)[0]

def _read_u32(data, off):
    return struct.unpack_from('<I', data, off)[0]


def get_text_section(data):
    """Return (raw_offset, raw_size, virtual_addr) of .text section."""
    pe_off = _read_u32(data, 0x3C)
    coff_off = pe_off + 4
    num_sections = _read_u16(data, coff_off + 2)
    opt_hdr_size = _read_u16(data, coff_off + 16)
    section_table = coff_off + 20 + opt_hdr_size

    for i in range(num_sections):
        off = section_table + i * 40
        name = data[off:off + 8].split(b'\x00', 1)[0]
        if name == b'.text':
            vs = _read_u32(data, off + 8)
            va = _read_u32(data, off + 12)
            rs = _read_u32(data, off + 16)
            ro = _read_u32(data, off + 20)
            return ro, rs, va
    raise ValueError("No .text section found")


def get_image_base(data):
    """Return ImageBase from optional header."""
    pe_off = _read_u32(data, 0x3C)
    # ImageBase is at optional header + 28 (for PE32)
    opt_off = pe_off + 4 + 20
    return _read_u32(data, opt_off + 28)


# ---------------------------------------------------------------------------
# Function list parsers
# ---------------------------------------------------------------------------

def parse_ghidra_json(json_path):
    """
    Parse a Ghidra analysis JSON report (from batch_import.py) for function
    addresses and sizes.

    Expected format:
      { "functions": [ {"address": "0x10001000", "name": "...", "size": 42}, ... ] }

    Returns list of (rva, size, name) sorted by address.
    """
    with open(json_path, 'r', encoding='utf-8') as f:
        report = json.load(f)

    funcs = []
    for fn in report.get('functions', []):
        addr_str = fn.get('address', '0')
        if isinstance(addr_str, str):
            addr = int(addr_str, 16) if addr_str.startswith('0x') else int(addr_str)
        else:
            addr = int(addr_str)
        size = int(fn.get('size', 0))
        name = fn.get('name', f'FUN_{addr:08X}')
        if size > 0:
            funcs.append((addr, size, name))

    funcs.sort(key=lambda x: x[0])
    return funcs


def parse_msvc_map(map_path):
    """
    Parse an MSVC linker .map file for function addresses.

    Map file lines look like:
     0001:00000000       _WinMain@16                10001000 f   Launch.obj

    Returns list of (rva, name). Sizes are inferred from gaps.
    """
    funcs = []
    # Pattern: segment:offset  name  address  type  object
    pat = re.compile(
        r'^\s*\d{4}:[0-9A-Fa-f]+\s+'   # segment:offset
        r'(\S+)\s+'                      # symbol name
        r'([0-9A-Fa-f]+)\s+'            # flat address
        r'[fF]\s+'                       # 'f' = function
        r'(\S+)',                        # object file
        re.MULTILINE
    )
    text = Path(map_path).read_text(encoding='utf-8', errors='replace')
    for m in pat.finditer(text):
        name = m.group(1)
        addr = int(m.group(2), 16)
        funcs.append((addr, name))

    funcs.sort(key=lambda x: x[0])

    # Infer sizes from gaps between consecutive functions
    result = []
    for i in range(len(funcs)):
        addr, name = funcs[i]
        if i + 1 < len(funcs):
            size = funcs[i + 1][0] - addr
        else:
            size = 64  # last function, assume small
        if size > 0:
            result.append((addr, size, name))

    return result


# ---------------------------------------------------------------------------
# Comparison
# ---------------------------------------------------------------------------

def extract_bytes(image_data, text_raw_off, text_va, image_base, func_addr, func_size):
    """Extract function bytes given its address (absolute or RVA)."""
    # The address in Ghidra/map is typically absolute (image_base + RVA)
    rva = func_addr - image_base if func_addr >= image_base else func_addr
    file_off = text_raw_off + (rva - text_va)

    if file_off < 0 or file_off + func_size > len(image_data):
        return None
    return image_data[file_off:file_off + func_size]


def compare_function_bytes(orig_bytes, rebuilt_bytes):
    """Compare two byte sequences, return match percentage."""
    if orig_bytes is None or rebuilt_bytes is None:
        return 0.0, 0, 0

    compare_len = min(len(orig_bytes), len(rebuilt_bytes))
    if compare_len == 0:
        return 0.0, 0, 0

    matches = sum(1 for i in range(compare_len) if orig_bytes[i] == rebuilt_bytes[i])
    total = max(len(orig_bytes), len(rebuilt_bytes))
    pct = matches / total * 100 if total > 0 else 0
    return pct, matches, total


def match_functions_by_name(orig_funcs, rebuilt_funcs):
    """
    Match functions between original and rebuilt by name.
    Returns list of (orig_entry, rebuilt_entry | None).
    """
    rebuilt_map = {}
    for entry in rebuilt_funcs:
        addr, size, name = entry
        # Normalize: strip leading underscore, @N suffix (stdcall decoration)
        clean = re.sub(r'^_', '', name)
        clean = re.sub(r'@\d+$', '', clean)
        rebuilt_map[clean] = entry
        rebuilt_map[name] = entry  # also keep original

    paired = []
    for entry in orig_funcs:
        addr, size, name = entry
        clean = re.sub(r'^_', '', name)
        clean = re.sub(r'@\d+$', '', clean)
        match = rebuilt_map.get(name) or rebuilt_map.get(clean)
        paired.append((entry, match))

    return paired


# ---------------------------------------------------------------------------
# Reporting
# ---------------------------------------------------------------------------

def print_report(results, orig_path, rebuilt_path):
    print(f"\n{'='*78}")
    print(f"  Function-Level Comparison Report")
    print(f"  Original : {orig_path}")
    print(f"  Rebuilt  : {rebuilt_path}")
    print(f"{'='*78}\n")

    # Sort by match percentage (worst first)
    results.sort(key=lambda r: r['match_pct'])

    total_funcs = len(results)
    perfect = sum(1 for r in results if r['match_pct'] == 100.0)
    matched = sum(1 for r in results if r['rebuilt_name'] is not None)
    unmatched = total_funcs - matched

    print(f"  Functions: {total_funcs} total, {matched} matched, "
          f"{perfect} perfect (100%), {unmatched} unmatched\n")

    header = f"  {'Match':>7}  {'Size':>6}  {'Name'}"
    print(header)
    print(f"  {'-'*70}")

    for r in results:
        if r['rebuilt_name'] is None:
            status = "  MISS"
        else:
            status = f"{r['match_pct']:6.2f}%"
        print(f"  {status}  {r['orig_size']:>6}  {r['orig_name']}")

    # Summary
    if matched > 0:
        overall_bytes = sum(r['total_bytes'] for r in results if r['rebuilt_name'])
        overall_match = sum(r['match_bytes'] for r in results if r['rebuilt_name'])
        overall_pct = overall_match / overall_bytes * 100 if overall_bytes > 0 else 0
        print(f"\n  Overall byte match (matched functions): {overall_pct:.4f}%")
        print(f"  ({overall_match}/{overall_bytes} bytes)")
    print()


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(description="Function-level PE comparison")
    parser.add_argument('original', help="Path to original binary")
    parser.add_argument('rebuilt', help="Path to rebuilt binary")
    parser.add_argument('--orig-map', required=True,
                        help="Ghidra JSON analysis report for original binary")
    parser.add_argument('--rebuilt-map', required=True,
                        help="MSVC .map file for rebuilt binary")
    args = parser.parse_args()

    orig_data = Path(args.original).read_bytes()
    rebuilt_data = Path(args.rebuilt).read_bytes()

    orig_text_off, orig_text_sz, orig_text_va = get_text_section(orig_data)
    rebuilt_text_off, rebuilt_text_sz, rebuilt_text_va = get_text_section(rebuilt_data)

    orig_base = get_image_base(orig_data)
    rebuilt_base = get_image_base(rebuilt_data)

    orig_funcs = parse_ghidra_json(args.orig_map)
    rebuilt_funcs = parse_msvc_map(args.rebuilt_map)

    pairs = match_functions_by_name(orig_funcs, rebuilt_funcs)

    results = []
    for orig_entry, rebuilt_entry in pairs:
        o_addr, o_size, o_name = orig_entry
        o_bytes = extract_bytes(orig_data, orig_text_off, orig_text_va, orig_base,
                                o_addr, o_size)
        if rebuilt_entry:
            r_addr, r_size, r_name = rebuilt_entry
            r_bytes = extract_bytes(rebuilt_data, rebuilt_text_off, rebuilt_text_va,
                                    rebuilt_base, r_addr, r_size)
            pct, match_b, total_b = compare_function_bytes(o_bytes, r_bytes)
            results.append({
                'orig_name': o_name,
                'rebuilt_name': r_name,
                'orig_size': o_size,
                'match_pct': pct,
                'match_bytes': match_b,
                'total_bytes': total_b,
            })
        else:
            results.append({
                'orig_name': o_name,
                'rebuilt_name': None,
                'orig_size': o_size,
                'match_pct': 0.0,
                'match_bytes': 0,
                'total_bytes': o_size,
            })

    print_report(results, args.original, args.rebuilt)

    # Exit 0 only if all matched functions are 100%
    if any(r['match_pct'] < 100.0 for r in results if r['rebuilt_name']):
        sys.exit(1)
    if any(r['rebuilt_name'] is None for r in results):
        sys.exit(2)


if __name__ == '__main__':
    main()
