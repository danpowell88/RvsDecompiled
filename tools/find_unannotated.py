"""Find unannotated exported functions across all DLLs."""
import json, re, os, glob

def find_impl_addresses(src_dir):
    addresses = set()
    pat = re.compile(r'IMPL_MATCH\s*\(\s*"[^"]+"\s*,\s*(0x[0-9a-fA-F]+)\s*\)')
    for ext in ['*.cpp', '*.h', '*.parity']:
        for fpath in glob.glob(os.path.join(src_dir, '**', ext), recursive=True):
            try:
                with open(fpath) as f:
                    for line in f:
                        for m in pat.finditer(line):
                            addresses.add(int(m.group(1), 16))
            except:
                pass
    return addresses

known = find_impl_addresses('src')
print('Total known IMPL_MATCH addresses: %d' % len(known))

modules = ['Core', 'Engine', 'Fire', 'R6Engine', 'R6Game', 'R6GameService',
           'R6Abstract', 'R6Weapons', 'IpDrv', 'WinDrv', 'Window',
           'DareAudio', 'DareAudioRelease', 'DareAudioScript', 'D3DDrv']

for name in modules:
    with open('ghidra/exports/reports/%s_function_index.json' % name) as f:
        data = json.load(f)
    
    unannotated = []
    for fn in data['functions']:
        if not fn.get('exported') or fn.get('unnamed'):
            continue
        addr = int(fn['addr'], 16)
        if addr not in known:
            unannotated.append(fn)
    
    small = [f for f in unannotated if f.get('size', 999) <= 20]
    med = [f for f in unannotated if 20 < f.get('size', 999) <= 50]
    print('%s: %d unannotated (%d small, %d medium)' % (name, len(unannotated), len(small), len(med)))
    
    # Show top 5 smallest
    for fn in sorted(small, key=lambda x: x.get('size', 999))[:5]:
        print('  0x%s  %3dB  %s' % (fn['addr'], fn.get('size', 0), fn.get('name', '?')))
