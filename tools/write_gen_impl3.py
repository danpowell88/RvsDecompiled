"""Writes gen_impl3.py to disk using Python to avoid PowerShell corruption."""
import os

content = r'''"""gen_impl3.py v3 - Comprehensive stub implementation generator.
Generates EngineDecls.h for new classes AND patches EngineClasses.h safely."""

import re, subprocess, os
from collections import defaultdict

UNDNAME = r"C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\VC\Tools\MSVC\14.29.30133\bin\Hostx64\x86\undname.exe"
HEADER = 'src/engine/EngineClasses.h'
STUB_FILES = [
    'src/engine/EngineStubs1.cpp',
    'src/engine/EngineStubs2.cpp',
    'src/engine/EngineStubs3.cpp',
    'src/engine/EngineStubs4.cpp',
]
OUTPUT_HEADER = 'src/engine/EngineDecls.h'
OUTPUT_IMPL = 'src/engine/EngineBatchImpl2.cpp'

SKIP_CLASSES = {
    'AActor', 'APawn', 'ULevel', 'ULevelBase', 'ALevelInfo', 'AGameInfo',
    'AInfo', 'AGameReplicationInfo', 'APlayerReplicationInfo',
}

SKIP_IMPLS = {
    ('UCanvas', 'Destroy'), ('UCanvas', 'Serialize'), ('UCanvas', 'Exec'),
    ('UNetDriver', 'Exec'), ('UNetDriver', 'LowLevelDestroy'),
    ('UNetDriver', 'LowLevelGetNetworkNumber'),
    ('UChannel', 'StaticConstructor'), ('UChannel', 'ReceivedBunch'),
    ('UChannel', 'Serialize'), ('UMaterial', 'PostEditChange'),
    ('AReplicationInfo', 'StaticConstructor'),
    ('AReplicationInfo', 'StartVideo'), ('AReplicationInfo', 'StopVideo'),
    ('AReplicationInfo', 'OpenVideo'), ('AReplicationInfo', 'ChangeDrawingSurface'),
    ('AReplicationInfo', 'CloseVideo'), ('AReplicationInfo', 'DisplayVideo'),
    ('AReplicationInfo', 'Draw3DLine'), ('AReplicationInfo', 'GetAvailableResolutions'),
    ('AReplicationInfo', 'GetAvailableVideoMemory'),
    ('AReplicationInfo', 'HandleFullScreenEffects'),
    ('UGameEngine', 'BuildServerMasterMap'),
    ('UEngine', 'EdCallback'),
    ('UEngine', 'edDrawAxisIndicator'),
}

SIG_RE = re.compile(
    r'(?:public|protected|private):\s*'
    r'(virtual\s+)?'
    r'(.*?)\s+'
    r'(?:__thiscall|__cdecl)\s+'
    r'(\w+(?:<[^>]+>)?)::(\w+(?:<[^>]+>)?|operator\s*[^\(]+)'
    r'\((.*)\)'
    r'(\s*const)?'
)

STATIC_SIG_RE = re.compile(
    r'(?:public|protected|private):\s*'
    r'static\s+'
    r'(.*?)\s+'
    r'(?:__cdecl)\s+'
    r'(\w+)::(\w+)'
    r'\((.*)\)'
)

def demangle(sym):
    try:
        r = subprocess.run([UNDNAME, sym], capture_output=True, text=True, timeout=5)
        for line in r.stdout.split('\n'):
            if 'is :-' in line:
                return line.split('is :-')[1].strip().strip('"')
    except:
        pass
    return None

def fix_type(t):
    t = t.replace('class ', '').replace('struct ', '').replace('enum ', '')
    t = t.replace('unsigned short const *', 'const TCHAR*')
    t = t.replace('unsigned short *', 'TCHAR*')
    t = t.replace('unsigned char *', 'BYTE*')
    t = t.replace('unsigned char const *', 'const BYTE*')
    t = t.replace('unsigned long', 'DWORD')
    t = t.replace('unsigned int', 'UINT')
    t = t.replace('unsigned short', '_WORD')
    t = t.replace('unsigned char', 'BYTE')
    return t

def default_return(ret):
    r = ret.strip()
    if r == 'void': return None
    if r in ('int', 'INT', 'UBOOL'): return '0'
    if r in ('float', 'FLOAT'): return '0.0f'
    if r in ('double',): return '0.0'
    if r in ('DWORD', 'UINT', 'BYTE', '_WORD'): return '0'
    if 'unsigned __int64' in r: return '0'
    if '*' in r: return 'NULL'
    if 'FString' in r: return 'FString()'
    if 'FVector' in r: return 'FVector(0,0,0)'
    if 'FRotator' in r: return 'FRotator(0,0,0)'
    if 'FMatrix' in r: return 'FMatrix()'
    if 'FName' in r: return 'FName(NAME_None)'
    if 'FBox' in r: return 'FBox()'
    if 'FColor' in r: return 'FColor(0,0,0,0)'
    if 'FSphere' in r: return 'FSphere()'
    if 'FCoords' in r: return 'FCoords()'
    if 'ETextureFormat' in r: return 'TEXF_P8'
    if 'ETexClampMode' in r: return 'TC_Wrap'
    return r + '()'

def get_class_name(sym):
    m = re.match(r'\?\?_7(\w+)@@', sym)
    if m: return m.group(1)
    m = re.match(r'\?\?[0-9A-Z](\w+)@@', sym)
    if m: return m.group(1)
    m = re.match(r'\?\w+@(\w+)@@', sym)
    if m: return m.group(1)
    return None

def classify(sym, tgt):
    if tgt == '_dummy_stub_data': return 'data'
    if sym.startswith('??_7'): return 'vtable'
    if sym.startswith('??0'): return 'ctor'
    if sym.startswith('??1'): return 'dtor'
    if sym.startswith('??4'): return 'op='
    if sym.startswith('??6'): return 'op<<'
    if sym.startswith('??5'): return 'op>>'
    if '@@UAE' in sym or '@@UBE' in sym: return 'virtual'
    if '@@QAE' in sym or '@@QBE' in sym: return 'public'
    if '@@IAE' in sym or '@@IBE' in sym: return 'protected'
    if '@@SA' in sym or '@@SB' in sym: return 'static'
    if '@@Y' in sym: return 'free'
    return 'other'

def get_declared_classes():
    with open(HEADER) as f:
        hdr = f.read()
    classes = set()
    for line in hdr.split('\n'):
        if re.match(r'\s*class\s+ENGINE_API\s+\w+\s*;', line):
            continue
        m = re.match(r'\s*class\s+ENGINE_API\s+(\w+)', line)
        if m:
            classes.add(m.group(1))
    return classes

def get_declared_methods():
    with open(HEADER) as f:
        content = f.read()
    declared = defaultdict(set)
    current = None
    for line in content.split('\n'):
        m = re.match(r'class\s+ENGINE_API\s+(\w+)', line)
        if m and ';' not in line:
            current = m.group(1)
            continue
        if line.strip() == '};':
            current = None
            continue
        if current:
            stripped = line.strip()
            m2 = re.match(r'(?:virtual\s+)?(?:static\s+)?[\w\s\*\&<>,]+\s+(\w+)\s*\(', stripped)
            if m2 and stripped.endswith(';') and not stripped.startswith('DECLARE_') and not stripped.startswith('//'):
                declared[current].add(m2.group(1))
    return declared

def find_class_insert_points():
    with open(HEADER) as f:
        lines = f.readlines()
    points = {}
    for i, line in enumerate(lines):
        m = re.match(r'class\s+ENGINE_API\s+(\w+)', line)
        if not m:
            continue
        cls = m.group(1)
        if ';' in line and '{' not in line:
            continue
        if '{' in line and '};' in line:
            points[cls] = None
            continue
        depth = 0
        entered = False
        for j in range(i, len(lines)):
            depth += lines[j].count('{') - lines[j].count('}')
            if depth > 0:
                entered = True
            if entered and depth == 0:
                points[cls] = j
                break
        else:
            points[cls] = None
    return {k: v for k, v in points.items() if v is not None}

print("Parsing stubs...")
stubs = []
for fpath in STUB_FILES:
    with open(fpath) as f:
        for line in f:
            m = re.search(r'alternatename:(\S+)=(\S+)', line.rstrip())
            if m:
                stubs.append((m.group(1), m.group(2)))
print(f"Total remaining stubs: {len(stubs)}")

by_class = defaultdict(list)
other_stubs = []
for sym, tgt in stubs:
    kind = classify(sym, tgt)
    cls = get_class_name(sym)
    if cls and (cls.startswith('TArray') or cls.startswith('TLazyArray')):
        other_stubs.append((sym, tgt, kind, 'template'))
        continue
    if kind == 'data':
        other_stubs.append((sym, tgt, kind, 'data'))
        continue
    if kind == 'free' or cls is None:
        other_stubs.append((sym, tgt, kind, 'free'))
        continue
    by_class[cls].append((sym, tgt, kind))

declared_classes = get_declared_classes()
declared_methods = get_declared_methods()
insert_points = find_class_insert_points()

print("Demangling stubs...")
class_info = {}
for cls, members in sorted(by_class.items()):
    if cls in SKIP_CLASSES:
        continue
    info_list = []
    for sym, tgt, kind in members:
        demangled = demangle(sym)
        info_list.append((kind, sym, demangled))
    class_info[cls] = info_list

no_header = {c for c in class_info if c not in declared_classes}
has_header = {c for c in class_info if c in declared_classes}
print(f"No header: {len(no_header)}, Has header: {len(has_header)}")

# ---- Generate EngineDecls.h ----
decl_lines = []
decl_lines.append('// EngineDecls.h - Class declarations for Engine stubs without headers\n')
decl_lines.append('#pragma once\n\n')

for cls in sorted(no_header):
    members = class_info[cls]
    if not members: continue
    has_vtable = any(k == 'vtable' for k, s, d in members)
    has_virtual_dtor = any(k == 'dtor' and '@@UAE' in s for k, s, d in members)
    has_virtual_methods = any(k == 'virtual' for k, s, d in members)
    needs_virtual = has_vtable or has_virtual_dtor or has_virtual_methods
    decl_lines.append(f'class ENGINE_API {cls} {{\npublic:\n')
    for kind, sym, demangled in members:
        if not demangled or kind == 'vtable': continue
        if kind == 'ctor':
            m = re.search(r'::' + re.escape(cls) + r'\((.*)\)', demangled)
            if m:
                params = fix_type(m.group(1))
                if params == 'void': params = ''
                decl_lines.append(f'\t{cls}({params});\n')
        elif kind == 'dtor':
            kw = 'virtual ' if needs_virtual else ''
            decl_lines.append(f'\t{kw}~{cls}();\n')
        elif kind == 'op=':
            decl_lines.append(f'\t{cls}& operator=(const {cls}&);\n')
        else:
            m = SIG_RE.match(demangled)
            if m:
                virt = 'virtual ' if m.group(1) else ''
                ret = fix_type(m.group(2))
                method = m.group(4)
                params = fix_type(m.group(5))
                const = ' const' if m.group(6) else ''
                if params == 'void': params = ''
                decl_lines.append(f'\t{virt}{ret} {method}({params}){const};\n')
            else:
                m2 = STATIC_SIG_RE.match(demangled)
                if m2:
                    ret = fix_type(m2.group(1))
                    method = m2.group(3)
                    params = fix_type(m2.group(4))
                    if params == 'void': params = ''
                    decl_lines.append(f'\tstatic {ret} {method}({params});\n')
    decl_lines.append('};\n\n')

with open(OUTPUT_HEADER, 'w') as f:
    f.writelines(decl_lines)
print(f"Wrote {OUTPUT_HEADER}")

# ---- Patch EngineClasses.h - add missing method declarations ----
with open(HEADER) as f:
    header_lines = f.readlines()

new_decls = defaultdict(list)
for cls in sorted(has_header):
    existing = declared_methods.get(cls, set())
    for kind, sym, demangled in class_info[cls]:
        if not demangled or kind in ('vtable', 'data', 'op<<', 'op>>', 'ctor', 'dtor', 'op='):
            continue
        m = SIG_RE.match(demangled)
        if m:
            method = m.group(4)
            if method not in existing and (cls, method) not in SKIP_IMPLS:
                virt = 'virtual ' if m.group(1) else ''
                ret = fix_type(m.group(2))
                params = fix_type(m.group(5))
                const = ' const' if m.group(6) else ''
                if params == 'void': params = ''
                new_decls[cls].append(f'\t{virt}{ret} {method}({params}){const};\n')
        else:
            m2 = STATIC_SIG_RE.match(demangled)
            if m2:
                method = m2.group(3)
                if method not in existing and (cls, method) not in SKIP_IMPLS:
                    ret = fix_type(m2.group(1))
                    params = fix_type(m2.group(4))
                    if params == 'void': params = ''
                    new_decls[cls].append(f'\tstatic {ret} {method}({params});\n')

insert_map = {}
for cls, decls in new_decls.items():
    if cls not in insert_points:
        continue
    line_idx = insert_points[cls]
    insert_text = '\t// Auto-generated method declarations\n' + ''.join(decls)
    insert_map[line_idx] = insert_text

output_lines = []
patch_count = 0
for i, line in enumerate(header_lines):
    if i in insert_map:
        output_lines.append(insert_map[i])
        patch_count += insert_map[i].count('\n') - 1
    output_lines.append(line)

with open(HEADER, 'w') as f:
    f.writelines(output_lines)
print(f"Patched EngineClasses.h: {patch_count} declarations in {len(insert_map)} classes")

# ---- Generate implementations ----
impl_lines = []
impl_lines.append('// EngineBatchImpl2.cpp - Auto-generated implementations round 2\n')
impl_lines.append('#include "Engine.h"\n')
impl_lines.append('#include "EngineDecls.h"\n\n')
gen_count = 0

for cls in sorted(class_info.keys()):
    members = class_info[cls]
    impl_lines.append(f'// --- {cls} ---\n')
    seen_dtor = False
    seen_opassign = False
    for kind, sym, demangled in members:
        if not demangled or kind == 'vtable': continue
        if kind == 'ctor':
            m = re.search(r'::' + re.escape(cls) + r'\((.*)\)', demangled)
            if m:
                params = fix_type(m.group(1))
                if params == 'void': params = ''
                impl_lines.append(f'{cls}::{cls}({params})\n{{\n}}\n\n')
                gen_count += 1
        elif kind == 'dtor' and not seen_dtor:
            seen_dtor = True
            impl_lines.append(f'{cls}::~{cls}()\n{{\n}}\n\n')
            gen_count += 1
        elif kind == 'op=' and not seen_opassign:
            seen_opassign = True
            impl_lines.append(f'{cls}& {cls}::operator=(const {cls}&)\n{{\n\treturn *this;\n}}\n\n')
            gen_count += 1
        elif kind in ('op<<', 'op>>'): continue
        elif kind in ('virtual', 'public', 'protected', 'static', 'other'):
            m = SIG_RE.match(demangled)
            if m:
                ret = fix_type(m.group(2))
                method = m.group(4)
                params = fix_type(m.group(5))
                const = ' const' if m.group(6) else ''
                if params == 'void': params = ''
                if (cls, method) in SKIP_IMPLS: continue
                dr = default_return(ret)
                body = f'\treturn {dr};\n' if dr else ''
                impl_lines.append(f'{ret} {cls}::{method}({params}){const}\n{{\n{body}}}\n\n')
                gen_count += 1
            else:
                m2 = STATIC_SIG_RE.match(demangled)
                if m2:
                    ret = fix_type(m2.group(1))
                    method = m2.group(3)
                    params = fix_type(m2.group(4))
                    if params == 'void': params = ''
                    dr = default_return(ret)
                    body = f'\treturn {dr};\n' if dr else ''
                    impl_lines.append(f'{ret} {cls}::{method}({params})\n{{\n{body}}}\n\n')
                    gen_count += 1

with open(OUTPUT_IMPL, 'w') as f:
    f.writelines(impl_lines)
print(f"Wrote {OUTPUT_IMPL}: {gen_count} implementations")
other_cats = defaultdict(int)
for s, t, k, c in other_stubs:
    other_cats[c] += 1
print(f"Unhandled: {dict(other_cats)}")
'''

path = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'gen_impl3.py')
with open(path, 'w') as f:
    f.write(content)
print(f"Wrote {path}")
print(f"Size: {len(content)} bytes")
