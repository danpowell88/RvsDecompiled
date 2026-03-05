#!/usr/bin/env python3
"""
bindiff.py — Section-level byte comparison between original and rebuilt PE binaries.

Usage:
    python bindiff.py <original.dll> <rebuilt.dll> [--section .text]

Compares matched PE sections byte-by-byte, reports:
  - Per-section match percentage
  - Overall match percentage
  - First N mismatches with file offsets
  - Summary table for quick triage
"""

import argparse
import struct
import sys
from pathlib import Path


# ---------------------------------------------------------------------------
# Minimal PE parser (no external deps — works with stock Python 3.x)
# ---------------------------------------------------------------------------

IMAGE_DOS_SIGNATURE = 0x5A4D
IMAGE_NT_SIGNATURE = 0x00004550


def _read_u16(data, off):
    return struct.unpack_from('<H', data, off)[0]


def _read_u32(data, off):
    return struct.unpack_from('<I', data, off)[0]


class Section:
    __slots__ = ('name', 'virtual_size', 'virtual_addr',
                 'raw_size', 'raw_offset', 'characteristics')

    def __init__(self, name, vs, va, rs, ro, ch):
        self.name = name
        self.virtual_size = vs
        self.virtual_addr = va
        self.raw_size = rs
        self.raw_offset = ro
        self.characteristics = ch

    def data(self, image):
        return image[self.raw_offset:self.raw_offset + self.raw_size]


def parse_sections(data):
    """Return list[Section] from a PE image buffer."""
    if len(data) < 64:
        raise ValueError("File too small to be a PE image")
    if _read_u16(data, 0) != IMAGE_DOS_SIGNATURE:
        raise ValueError("Not a valid DOS header (missing MZ)")

    pe_off = _read_u32(data, 0x3C)
    if _read_u32(data, pe_off) != IMAGE_NT_SIGNATURE:
        raise ValueError("Not a valid PE header (missing PE\\0\\0)")

    coff_off = pe_off + 4
    num_sections = _read_u16(data, coff_off + 2)
    opt_hdr_size = _read_u16(data, coff_off + 16)
    section_table = coff_off + 20 + opt_hdr_size

    sections = []
    for i in range(num_sections):
        off = section_table + i * 40
        raw_name = data[off:off + 8]
        name = raw_name.split(b'\x00', 1)[0].decode('ascii', errors='replace')
        vs = _read_u32(data, off + 8)
        va = _read_u32(data, off + 12)
        rs = _read_u32(data, off + 16)
        ro = _read_u32(data, off + 20)
        ch = _read_u32(data, off + 36)
        sections.append(Section(name, vs, va, rs, ro, ch))
    return sections


# ---------------------------------------------------------------------------
# Comparison engine
# ---------------------------------------------------------------------------

def compare_sections(orig_data, rebuilt_data, orig_sec, rebuilt_sec, max_mismatches=20):
    """Compare two section buffers byte-by-byte."""
    a = orig_sec.data(orig_data)
    b = rebuilt_sec.data(rebuilt_data)
    compare_len = min(len(a), len(b))

    matches = 0
    mismatches = []
    for i in range(compare_len):
        if a[i] == b[i]:
            matches += 1
        else:
            if len(mismatches) < max_mismatches:
                mismatches.append({
                    'offset': i,
                    'file_offset_orig': orig_sec.raw_offset + i,
                    'file_offset_rebuilt': rebuilt_sec.raw_offset + i,
                    'orig': a[i],
                    'rebuilt': b[i],
                })

    # Bytes beyond the shorter section count as mismatches
    size_diff = abs(len(a) - len(b))
    total = max(len(a), len(b))
    pct = (matches / total * 100) if total > 0 else 100.0

    return {
        'section': orig_sec.name,
        'orig_size': len(a),
        'rebuilt_size': len(b),
        'compared': compare_len,
        'matches': matches,
        'total': total,
        'size_diff': size_diff,
        'match_pct': pct,
        'mismatches': mismatches,
    }


def match_sections(orig_secs, rebuilt_secs):
    """Pair sections by name, return list of (orig, rebuilt | None)."""
    rebuilt_map = {s.name: s for s in rebuilt_secs}
    paired = []
    for s in orig_secs:
        paired.append((s, rebuilt_map.pop(s.name, None)))
    for s in rebuilt_map.values():
        paired.append((None, s))
    return paired


# ---------------------------------------------------------------------------
# Reporting
# ---------------------------------------------------------------------------

def print_report(results, orig_path, rebuilt_path):
    print(f"\n{'='*72}")
    print(f"  Binary Diff Report")
    print(f"  Original : {orig_path}")
    print(f"  Rebuilt  : {rebuilt_path}")
    print(f"{'='*72}\n")

    header = f"  {'Section':<10} {'Orig Size':>10} {'Rebuilt':>10} {'Match':>8} {'Status'}"
    print(header)
    print(f"  {'-'*60}")

    total_matches = 0
    total_bytes = 0

    for r in results:
        total_matches += r['matches']
        total_bytes += r['total']
        status = "OK" if r['match_pct'] == 100.0 else f"{r['match_pct']:.2f}%"
        print(f"  {r['section']:<10} {r['orig_size']:>10} {r['rebuilt_size']:>10} {status:>8}")

    overall = (total_matches / total_bytes * 100) if total_bytes > 0 else 0
    print(f"\n  Overall: {overall:.4f}% match ({total_matches}/{total_bytes} bytes)\n")

    # Show first mismatches for sections that differ
    for r in results:
        if r['mismatches']:
            print(f"  First mismatches in {r['section']}:")
            for m in r['mismatches']:
                print(f"    +0x{m['offset']:06X}  orig=0x{m['orig']:02X}  rebuilt=0x{m['rebuilt']:02X}"
                      f"  (file: 0x{m['file_offset_orig']:06X} vs 0x{m['file_offset_rebuilt']:06X})")
            if len(r['mismatches']) == 20:
                print(f"    ... (showing first 20 only)")
            print()


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(description="PE section-level byte comparison")
    parser.add_argument('original', help="Path to original binary")
    parser.add_argument('rebuilt', help="Path to rebuilt binary")
    parser.add_argument('--section', '-s', help="Compare only this section (e.g. .text)")
    parser.add_argument('--max-mismatches', '-m', type=int, default=20,
                        help="Max mismatches to show per section (default: 20)")
    args = parser.parse_args()

    orig_path = Path(args.original)
    rebuilt_path = Path(args.rebuilt)

    if not orig_path.exists():
        print(f"Error: original file not found: {orig_path}", file=sys.stderr)
        sys.exit(1)
    if not rebuilt_path.exists():
        print(f"Error: rebuilt file not found: {rebuilt_path}", file=sys.stderr)
        sys.exit(1)

    orig_data = orig_path.read_bytes()
    rebuilt_data = rebuilt_path.read_bytes()

    orig_sections = parse_sections(orig_data)
    rebuilt_sections = parse_sections(rebuilt_data)

    pairs = match_sections(orig_sections, rebuilt_sections)

    results = []
    for orig_sec, rebuilt_sec in pairs:
        if args.section:
            if orig_sec and orig_sec.name != args.section:
                continue
            if not orig_sec and rebuilt_sec and rebuilt_sec.name != args.section:
                continue

        if orig_sec is None:
            print(f"  Warning: section {rebuilt_sec.name} only in rebuilt binary")
            continue
        if rebuilt_sec is None:
            print(f"  Warning: section {orig_sec.name} only in original binary")
            results.append({
                'section': orig_sec.name,
                'orig_size': orig_sec.raw_size,
                'rebuilt_size': 0,
                'compared': 0,
                'matches': 0,
                'total': orig_sec.raw_size,
                'size_diff': orig_sec.raw_size,
                'match_pct': 0.0,
                'mismatches': [],
            })
            continue

        results.append(compare_sections(
            orig_data, rebuilt_data, orig_sec, rebuilt_sec, args.max_mismatches
        ))

    print_report(results, orig_path, rebuilt_path)

    # Exit with non-zero if any section isn't 100%
    if any(r['match_pct'] < 100.0 for r in results):
        sys.exit(1)


if __name__ == '__main__':
    main()
