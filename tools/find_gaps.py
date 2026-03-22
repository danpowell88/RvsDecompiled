"""Analyze gaps between Ghidra function index and implemented source."""
import json
import re
import os
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
REPORTS = REPO / "ghidra" / "exports" / "reports"
SRC = REPO / "src"

MODULE_MAP = {
    'Core':     ('Core.dll',  'Core'),
    'Engine':   ('Engine.dll','Engine'),
    'R6Engine': ('R6Engine.dll','R6Engine'),
    'Fire':     ('Fire.dll',  'Fire'),
    'WinDrv':   ('WinDrv.dll','WinDrv'),
    'D3DDrv':   ('D3DDrv.dll','D3DDrv'),
    'R6Game':   ('R6Game.dll','R6Game'),
    'R6Abstract': ('R6Abstract.dll','R6Abstract'),
    'R6Weapons': ('R6Weapons.dll','R6Weapons'),
    'R6GameService': ('R6GameService.dll','R6GameService'),
    'DareAudio': ('DareAudio.dll','DareAudio'),
    'IpDrv':     ('IpDrv.dll','IpDrv'),
    'Window':    ('Window.dll','Window'),
}

addr_re = re.compile(r'IMPL_MATCH\([^,]+,\s*(0x[0-9a-fA-F]+)\)')

for module, (dll, index_name) in MODULE_MAP.items():
    # Get all IMPL_MATCH addresses from source
    src_dir = SRC / module / "Src"
    impl_addrs = set()
    if src_dir.exists():
        for cpp in src_dir.glob("*.cpp"):
            for m in addr_re.finditer(cpp.read_text(errors='replace')):
                impl_addrs.add(m.group(1).lower().replace('0x',''))
    
    # Get all exported named functions from Ghidra
    idx_path = REPORTS / f"{index_name}_function_index.json"
    if not idx_path.exists():
        continue
    data = json.load(open(idx_path))
    exported = [f for f in data['functions'] if f.get('exported') and not f.get('unnamed')]
    
    # Find gaps
    covered = 0
    missing = []
    for f in exported:
        addr = f['addr'].lower().replace('0x','')
        if addr in impl_addrs:
            covered += 1
        else:
            missing.append(f)
    
    missing.sort(key=lambda f: f.get('size', 999))
    
    print(f"\n{'='*60}")
    print(f"{dll}: {len(exported)} exported named | {covered} covered | {len(missing)} MISSING")
    print(f"{'='*60}")
    if missing:
        print(f"  Top 15 smallest missing:")
        for f in missing[:15]:
            print(f"    {f['addr']:>12s}  {f['size']:4d}b  {f['name']}")
        if len(missing) > 15:
            print(f"    ... and {len(missing)-15} more")
