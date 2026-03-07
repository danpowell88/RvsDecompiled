"""Export analysis for retail Core.dll"""
import pefile
pe = pefile.PE(r'c:\Users\danpo\Desktop\rvs\retail\system\Core.dll')
exports = [(e.ordinal, e.name.decode() if e.name else 'N/A') for e in pe.DIRECTORY_ENTRY_EXPORT.symbols]

# Template instantiation exports
templates = [n for o,n in exports if '$T' in n]
print(f'Template instantiation exports: {len(templates)}')
for t in templates[:10]:
    print(f'  {t}')

# Global function exports (app*)
app_exports = sorted([n for o,n in exports if n.startswith('?app')])
print(f'\napp* exports: {len(app_exports)}')
for a in app_exports[:20]:
    print(f'  {a}')

# G* globals  
g_exports = sorted([n for o,n in exports if n.startswith('?G') and '@@3' in n])
print(f'\nG* global variables: {len(g_exports)}')
for g in g_exports[:20]:
    print(f'  {g}')

# operator<< exports (serialization)
ser_exports = [n for o,n in exports if 'operator' in n.lower() or '??6' in n or '??5' in n]
print(f'\nSerializer (operator<</>>): {len(ser_exports)}')
for s in ser_exports[:10]:
    print(f'  {s}')

# DllExport free functions (Localize, Parse, etc)
free_funcs = sorted([n for o,n in exports if n.startswith('?') and '@@Y' in n and '$' not in n])
print(f'\nFree functions (non-class, non-template): {len(free_funcs)}')
for f in free_funcs[:30]:
    print(f'  {f}')

# Remaining unaccounted  
accounted = set()
for o,n in exports:
    if '$T' in n: accounted.add(o)
    elif n.startswith('?app'): accounted.add(o)
    elif '@@3' in n and n.startswith('?G'): accounted.add(o)
    elif '@@Y' in n: accounted.add(o)
    elif '@@' in n:
        parts = n.split('@')
        if len(parts) > 2:
            accounted.add(o)

unaccounted = [(o,n) for o,n in exports if o not in accounted]
print(f'\nUnaccounted exports: {len(unaccounted)}')
for o,n in unaccounted[:10]:
    print(f'  {o}: {n}')
