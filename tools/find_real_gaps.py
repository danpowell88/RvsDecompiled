"""Find non-trivial exported functions missing from source.
Excludes auto-generated functions (StaticClass, InternalConstructor, operator new, DllMain, etc.)
"""
import json
import re
import os
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
REPORTS = REPO / "ghidra" / "exports" / "reports"
SRC = REPO / "src"

# Patterns that indicate auto-generated functions from IMPLEMENT_CLASS/IMPLEMENT_PACKAGE
AUTO_GEN_PATTERNS = [
    'StaticClass',
    'InternalConstructor',
    'operator_new',     # Ghidra might use underscore
    'operator new',
    '_DllMain',
    'DllMain',
    'autoclass',
    'autoclassU',
    'PrivateStaticClass',
    'StaticConstructor',  # Often empty or trivial
]

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
empty_re = re.compile(r'IMPL_EMPTY\(')
todo_re = re.compile(r'IMPL_TODO\(')
diverge_re = re.compile(r'IMPL_DIVERGE\(')

def is_auto_generated(name):
    for pat in AUTO_GEN_PATTERNS:
        if pat in name:
            return True
    return False

total_gap = 0
total_autogen = 0

for module, (dll, index_name) in MODULE_MAP.items():
    src_dir = SRC / module / "Src"
    impl_addrs = set()
    if src_dir.exists():
        for cpp in src_dir.glob("*.cpp"):
            text = cpp.read_text(errors='replace')
            for m in addr_re.finditer(text):
                impl_addrs.add(m.group(1).lower().replace('0x',''))
    
    idx_path = REPORTS / f"{index_name}_function_index.json"
    if not idx_path.exists():
        continue
    data = json.load(open(idx_path))
    exported = [f for f in data['functions'] if f.get('exported') and not f.get('unnamed')]
    
    missing_real = []
    autogen_count = 0
    
    for f in exported:
        addr = f['addr'].lower().replace('0x','')
        if addr in impl_addrs:
            continue
        if is_auto_generated(f['name']):
            autogen_count += 1
            continue
        missing_real.append(f)
    
    missing_real.sort(key=lambda f: f.get('size', 999))
    total_gap += len(missing_real)
    total_autogen += autogen_count
    
    print(f"\n{'='*60}")
    print(f"{dll}: {len(missing_real)} REAL missing ({autogen_count} auto-generated skipped)")
    print(f"{'='*60}")
    if missing_real:
        # Group by size category
        tiny = [f for f in missing_real if f['size'] <= 20]
        small = [f for f in missing_real if 20 < f['size'] <= 50]
        medium = [f for f in missing_real if 50 < f['size'] <= 200]
        large = [f for f in missing_real if f['size'] > 200]
        print(f"  Tiny (<=20b): {len(tiny)} | Small (21-50b): {len(small)} | Medium (51-200b): {len(medium)} | Large (>200b): {len(large)}")
        print(f"  Top 20 smallest real missing:")
        for f in missing_real[:20]:
            print(f"    {f['addr']:>12s}  {f['size']:4d}b  {f['name']}")
        if len(missing_real) > 20:
            print(f"    ... and {len(missing_real)-20} more")

print(f"\n{'='*60}")
print(f"TOTAL: {total_gap} real missing functions ({total_autogen} auto-generated excluded)")
print(f"{'='*60}")
