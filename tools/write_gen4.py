"""Helper to write gen_impl4.py to disk."""
import textwrap

content = textwrap.dedent(r'''
"""
gen_impl4.py - Generate implementations for remaining Engine.dll stubs (round 3).
Handles: free functions, operators, data symbols, and SDK/pre-declared class methods.
Skips: __FUNC_NAME__ string literals and vftable entries (compiler-generated).
"""
import subprocess
import re

UNDNAME = r'C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\VC\Tools\MSVC\14.29.30133\bin\Hostx64\x86\undname.exe'
OUTPUT = 'src/engine/EngineBatchImpl3.cpp'

# Signature regex for demangled symbols
SIG_RE = re.compile(
    r'(?:(?:public|protected|private):\s+)?'
    r'(?:virtual\s+)?'
    r'(?:static\s+)?'
    r'(.*?)\s+'
    r'(?:__\w+\s+)'
    r'(?:(\w+)::)?'
    r'(~?\w+|operator[^(]+)\s*'
    r'\((.*?)\)'
    r'(\s*const)?'
)

def read_remaining_stubs():
    stubs = []
    for i in range(1, 5):
        with open(f'src/engine/EngineStubs{i}.cpp') as f:
            for line in f:
                if '/alternatename:' in line and '=_dummy' in line:
                    idx1 = line.index('/alternatename:') + len('/alternatename:')
                    idx2 = line.index('=_dummy')
                    stubs.append(line[idx1:idx2])
    return stubs

def demangle_stubs(stubs):
    result = {}
    batch_size = 50
    for start in range(0, len(stubs), batch_size):
        batch = stubs[start:start+batch_size]
        proc = subprocess.run([UNDNAME] + batch, capture_output=True, text=True)
        lines = proc.stdout.strip().split('\n')
        for j in range(0, len(lines), 3):
            if j+1 >= len(lines):
                break
            mangled = lines[j].strip().replace('>> ', '')
            demangled = lines[j+1].strip().replace('is :- ', '').strip('"')
            result[mangled] = demangled
    return result

TYPE_MAP = {
    'unsigned short const *': 'const TCHAR*',
    'unsigned short *': 'TCHAR*',
    'unsigned short': 'TCHAR',
    'unsigned long': 'DWORD',
    'unsigned int': 'UINT',
    'unsigned char': 'BYTE',
}

def fix_type(t):
    t = t.strip()
    t = re.sub(r'\bclass\s+', '', t)
    t = re.sub(r'\bstruct\s+', '', t)
    t = re.sub(r'\benum\s+', '', t)
    for old, new in TYPE_MAP.items():
        t = t.replace(old, new)
    return t.strip()

def default_return(ret):
    ret = ret.strip()
    if ret == 'void':
        return ''
    if '*' in ret:
        return 'return NULL;'
    if '&' in ret:
        base = ret.replace('&', '').strip().replace('const ', '')
        return f'static {base} dummy; return dummy;'
    if ret in ('int', 'float', 'double', 'bool', 'DWORD', 'UINT', 'BYTE', 'TCHAR',
               'INT', 'UBOOL'):
        return 'return 0;'
    # Complex type - default construct
    return f'return {ret}();'

def generate_implementations(demangled_map):
    impls = []
    skipped_funcname = 0
    skipped_vftable = 0
    skipped_other = 0
    generated = 0

    for mangled, demangled in sorted(demangled_map.items(), key=lambda x: x[1]):
        if '__FUNC_NAME__' in demangled or 'FUNC_NAME' in demangled:
            skipped_funcname += 1
            continue
        if "'vftable'" in demangled or "'vbtable'" in demangled:
            skipped_vftable += 1
            continue
        if 'default constructor closure' in demangled:
            skipped_other += 1
            continue
        if 'Copyright' in demangled or 'Microsoft' in demangled:
            skipped_other += 1
            continue

        m = SIG_RE.match(demangled)
        if not m:
            # Try data symbol
            skipped_other += 1
            continue

        ret_raw = m.group(1)
        cls = m.group(2)
        name = m.group(3).strip()
        params_raw = m.group(4)
        is_const = bool(m.group(5))

        ret = fix_type(ret_raw)
        if ret.startswith('static '):
            ret = ret[7:]

        # Parse params
        params_parts = []
        if params_raw and params_raw.strip() != 'void':
            depth = 0
            current = ''
            for ch in params_raw:
                if ch in '<(':
                    depth += 1
                elif ch in '>)':
                    depth -= 1
                if ch == ',' and depth == 0:
                    params_parts.append(current.strip())
                    current = ''
                else:
                    current += ch
            if current.strip():
                params_parts.append(current.strip())

        params_fixed = []
        for i, p in enumerate(params_parts):
            p = fix_type(p)
            params_fixed.append(f'{p} p{i}')

        param_str = ', '.join(params_fixed) if params_fixed else ''
        const_str = ' const' if is_const else ''

        # Handle operator overloads  
        if name.startswith('operator'):
            name = name.strip()

        # Constructors/destructors
        if cls and (name == cls or name == f'~{cls}'):
            if name.startswith('~'):
                impl = f'{cls}::~{cls}(){const_str} {{}}'
            else:
                impl = f'{cls}::{cls}({param_str}){const_str} {{}}'
        elif cls:
            body = default_return(ret)
            if body:
                impl = f'{ret} {cls}::{name}({param_str}){const_str} {{ {body} }}'
            else:
                impl = f'{ret} {cls}::{name}({param_str}){const_str} {{}}'
        else:
            body = default_return(ret)
            if body:
                impl = f'{ret} {name}({param_str}){const_str} {{ {body} }}'
            else:
                impl = f'{ret} {name}({param_str}){const_str} {{}}'

        impls.append(f'// {mangled}')
        impls.append(impl)
        impls.append('')
        generated += 1

    return impls, generated, skipped_funcname, skipped_vftable, skipped_other

def generate_data_defs(demangled_map):
    defs = []
    count = 0
    for mangled, demangled in sorted(demangled_map.items(), key=lambda x: x[1]):
        # Static class members
        dm = re.match(r'(?:public|protected|private):\s+static\s+(.*?)\s+(\w+)::(\w+)\s*$', demangled)
        if dm:
            ret = fix_type(dm.group(1))
            cls = dm.group(2)
            member = dm.group(3)
            if '*' in ret:
                defs.append(f'{ret} {cls}::{member} = NULL;')
            else:
                defs.append(f'{ret} {cls}::{member};')
            defs.append('')
            count += 1
            continue

        # Globals
        if '(' not in demangled and '::' not in demangled and 'vftable' not in demangled:
            gm = re.match(r'^(.*?)\s+(\w+)\s*$', demangled)
            if gm and 'Microsoft' not in demangled:
                ret = fix_type(gm.group(1))
                name = gm.group(2)
                if '*' in ret:
                    defs.append(f'{ret} {name} = NULL;')
                else:
                    defs.append(f'{ret} {name};')
                defs.append('')
                count += 1

    return defs, count

def main():
    stubs = read_remaining_stubs()
    print(f'Total remaining stubs: {len(stubs)}')

    demangled_map = demangle_stubs(stubs)
    print(f'Demangled: {len(demangled_map)}')

    impls, gen_count, skip_fn, skip_vt, skip_other = generate_implementations(demangled_map)
    data_defs, data_count = generate_data_defs(demangled_map)

    lines = [
        '/*=============================================================================',
        '  EngineBatchImpl3.cpp: Round 3 batch implementations.',
        '  Auto-generated by gen_impl4.py',
        '=============================================================================*/',
        '',
        '#include "EnginePrivate.h"',
        '',
        '// Forward declarations for types only used in stubs',
        'struct FOrientation { BYTE Pad[16]; FOrientation& operator=(FOrientation p0) { return *this; } int operator!=(const FOrientation&) const { return 0; } };',
        'struct FHitCause;',
        'struct HHitProxy;',
        'struct FRebuildOptions { BYTE Pad[256]; };',
        'struct _KarmaGlobals;',
        'struct _McdGeometry;',
        'struct McdGeomMan;',
        'struct _KarmaTriListData;',
        '',
        '/*-----------------------------------------------------------------------------',
        '  Data definitions',
        '-----------------------------------------------------------------------------*/',
        '',
    ]
    lines.extend(data_defs)
    lines.append('')
    lines.append('/*-----------------------------------------------------------------------------')
    lines.append('  Implementations')
    lines.append('-----------------------------------------------------------------------------*/')
    lines.append('')
    lines.extend(impls)

    with open(OUTPUT, 'w') as f:
        f.write('\n'.join(lines))

    print(f'Generated implementations: {gen_count}')
    print(f'Data definitions: {data_count}')
    print(f'Skipped __FUNC_NAME__: {skip_fn}')
    print(f'Skipped vftable/vbtable: {skip_vt}')
    print(f'Skipped other: {skip_other}')
    print(f'Wrote {OUTPUT}')

if __name__ == '__main__':
    main()
''').lstrip()

with open('tools/gen_impl4.py', 'w') as f:
    f.write(content)
print(f'Wrote tools/gen_impl4.py ({len(content)} bytes)')
