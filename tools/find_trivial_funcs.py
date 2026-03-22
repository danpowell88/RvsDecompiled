"""Find trivial (small) exported named functions across all modules.

Usage: python tools/find_trivial_funcs.py [--max-size N]
"""
import json
import os
import sys

MAX_SIZE = int(sys.argv[1]) if len(sys.argv) > 1 else 20
REPORTS_DIR = os.path.join(os.path.dirname(__file__), '..', 'ghidra', 'exports', 'reports')

modules = [
    'Core', 'Engine', 'R6Engine', 'R6GameService', 'DareAudio',
    'WinDrv', 'D3DDrv', 'Fire', 'R6Game', 'R6Weapons',
    'R6Abstract', 'Window', 'IpDrv',
    'DareAudioRelease', 'DareAudioScript',
]

total_trivial = 0

for mod in modules:
    path = os.path.join(REPORTS_DIR, f'{mod}_function_index.json')
    if not os.path.exists(path):
        continue
    data = json.load(open(path))
    funcs = data.get('functions', [])
    small = [f for f in funcs
             if f.get('exported', False)
             and not f.get('unnamed', True)
             and f.get('size', 999) <= MAX_SIZE]
    small.sort(key=lambda f: f.get('size', 0))
    total_trivial += len(small)
    print(f'\n=== {mod} ({len(small)} trivial functions <= {MAX_SIZE} bytes) ===')
    for f in small[:30]:
        print(f"  {f['addr']:>12s}  {f['size']:3d}b  {f['name']}")
    if len(small) > 30:
        print(f"  ... and {len(small) - 30} more")

print(f'\n=== TOTAL: {total_trivial} trivial exported named functions <= {MAX_SIZE} bytes ===')
