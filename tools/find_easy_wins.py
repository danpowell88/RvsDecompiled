#!/usr/bin/env python3
"""Find small exported functions not yet annotated in any .parity or .cpp file."""
import json, os, re, sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

def load_existing_addrs():
    """Scan all .parity and .cpp files for IMPL_MATCH addresses."""
    addrs = set()
    pat = re.compile(r'IMPL_MATCH\s*\(\s*"[^"]+"\s*,\s*(0x[0-9a-fA-F]+)\s*\)')
    for root, dirs, files in os.walk(os.path.join(ROOT, 'src')):
        for f in files:
            if f.endswith('.parity') or f.endswith('.cpp'):
                with open(os.path.join(root, f), 'r', errors='ignore') as fh:
                    for line in fh:
                        m = pat.search(line)
                        if m:
                            addrs.add(int(m.group(1), 16))
    return addrs

def main():
    existing = load_existing_addrs()
    print(f"Existing IMPL_MATCH annotations: {len(existing)}")

    max_size = int(sys.argv[1]) if len(sys.argv) > 1 else 30
    modules = ['Core', 'Engine', 'Fire', 'R6Engine', 'R6Game', 'R6GameService',
               'R6Abstract', 'R6Weapons', 'IpDrv', 'WinDrv', 'Window',
               'DareAudio', 'DareAudioRelease', 'DareAudioScript', 'D3DDrv']

    total = 0
    for mod in modules:
        path = os.path.join(ROOT, 'ghidra', 'exports', 'reports', f'{mod}_function_index.json')
        if not os.path.exists(path):
            continue
        data = json.load(open(path))
        unannotated = []
        for f in data['functions']:
            if f.get('exported') and not f.get('unnamed') and f.get('size', 999) <= max_size:
                addr = int(f['addr'], 16)
                if addr not in existing:
                    unannotated.append(f)
        if unannotated:
            unannotated.sort(key=lambda x: x.get('size', 999))
            print(f"\n{mod} ({len(unannotated)} unannotated <= {max_size}B):")
            for func in unannotated:
                print(f"  0x{func['addr']}  {func.get('size','?'):>3}B  {func['name']}")
            total += len(unannotated)

    print(f"\nTOTAL unannotated <= {max_size}B: {total}")

if __name__ == '__main__':
    main()
