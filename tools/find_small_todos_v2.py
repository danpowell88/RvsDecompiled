"""Find smallest IMPL_TODO functions - fixed address extraction."""
import json, re, os, glob

todos = []
pat = re.compile(r'IMPL_TODO\s*\(\s*"([^"]*)"\s*\)')

for fpath in glob.glob(os.path.join('src', '**', '*.cpp'), recursive=True):
    try:
        with open(fpath) as f:
            lines = f.readlines()
        for i, line in enumerate(lines):
            if 'IMPL_TODO' in line:
                reason = ''
                func_name = ''
                addr = None
                m = pat.search(line)
                if m:
                    reason = m.group(1)
                    # Extract address from the IMPL_TODO reason string only
                    am = re.search(r'0x([0-9a-fA-F]{8,})', reason)
                    if am:
                        addr = int(am.group(0), 16)
                for j in range(i+1, min(i+5, len(lines))):
                    l = lines[j].strip()
                    if l and not l.startswith('//') and not l.startswith('IMPL_'):
                        func_name = l[:80]
                        break
                todos.append({
                    'file': os.path.relpath(fpath),
                    'line': i+1,
                    'reason': reason,
                    'addr': addr,
                    'func': func_name
                })
    except:
        pass

print('Total IMPL_TODO: %d' % len(todos))

# Load sizes from function index
sizes = {}
names = {}
for mod in ['Core', 'Engine', 'Fire', 'R6Engine', 'R6Game', 'R6GameService',
            'R6Abstract', 'R6Weapons', 'IpDrv', 'WinDrv', 'Window',
            'DareAudio', 'DareAudioRelease', 'DareAudioScript', 'D3DDrv']:
    try:
        with open('ghidra/exports/reports/%s_function_index.json' % mod) as f:
            data = json.load(f)
        for fn in data['functions']:
            a = int(fn['addr'], 16)
            sizes[a] = fn.get('size', 0)
            names[a] = fn.get('name', '')
    except:
        pass

for t in todos:
    if t['addr'] and t['addr'] in sizes:
        t['size'] = sizes[t['addr']]
    else:
        # Try to extract size from reason string (e.g. "retail has 1862B")
        sm = re.search(r'(\d+)\s*[Bb]', t['reason'])
        if sm:
            t['size'] = int(sm.group(1))
        else:
            t['size'] = 0

sized_todos = [t for t in todos if t['size'] > 0]
sized_todos.sort(key=lambda x: x['size'])
print('TODOs with known sizes: %d' % len(sized_todos))
print()
print('Smallest 40 IMPL_TODO functions:')
for t in sized_todos[:40]:
    a = ('0x%x' % t['addr']) if t['addr'] else 'no-addr'
    print('  %5dB  %-12s  %s:%d' % (t['size'], a, t['file'], t['line']))
    print('          %s' % t['func'][:70])
