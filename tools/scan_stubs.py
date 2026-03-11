import re, glob

def scan_stubs(path):
    try:
        with open(path, encoding='utf-8', errors='ignore') as f:
            content = f.read()
    except:
        return []
    pattern = re.compile(r'(\w[\w\s\*&:<>]+?)\s+(\w+::\w+)\s*\(([^)]*)\)\s*\{[^{}]*guard\([^)]+\);?\s*(return\s+[^;]+;|)\s*unguard;?\s*\}', re.DOTALL)
    results = []
    for m in pattern.finditer(content):
        func = m.group(2)
        body = m.group(4).strip()
        if body in ('return 0;', 'return NULL;', 'return FALSE;', 'return 1;', 'return TRUE;', ''):
            results.append((func, body if body else '(void)'))
    return results

import os
all_files = []
for root, dirs, files in os.walk('src'):
    for f in files:
        if f.endswith('.cpp') and 'Stubs' not in f and 'Batch' not in f:
            all_files.append(os.path.join(root, f))

total = 0
for f in sorted(all_files):
    stubs = scan_stubs(f)
    if stubs:
        print(f'\n{f}: {len(stubs)} stubs')
        total += len(stubs)
        for name, body in stubs[:20]:
            print(f'  {name}: {body}')

print(f'\nTotal: {total} trivial stubs')

