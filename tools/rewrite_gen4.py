"""Rewrite gen_impl4.py with all build-error fixes."""
import textwrap

content = textwrap.dedent(r'''
"""
gen_impl4.py - Generate implementations for remaining Engine.dll stubs (round 3).
Handles: free functions, operators, data symbols, and SDK/pre-declared class methods.
Skips: __FUNC_NAME__ string literals, vftable entries, and known conflicts.
"""
import subprocess
import re

UNDNAME = r'C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\VC\Tools\MSVC\14.29.30133\bin\Hostx64\x86\undname.exe'
OUTPUT = 'src/engine/EngineBatchImpl3.cpp'

# Methods/classes to skip (already implemented elsewhere or conflict)
SKIP_MANGLES = set()

# Skip specific demangled patterns
SKIP_PATTERNS = [
    'AR6AbstractClimbableObj::AR6AbstractClimbableObj',  # already in EngineBatchImpl2
    'UR6AbstractTerroristMgr::UR6AbstractTerroristMgr',  # already in EngineBatchImpl2
    'UInput::StaticConfigName',  # not declared in class
    'UInputPlanning::StaticConfigName',  # not declared in class
    'UCanvas::WrappedPrint',  # not declared in class
]

# Classes whose methods are defined in Engine.h with different signatures
SKIP_CLASSES = {
    'FColor',  # defined in Engine.h with inline methods
}

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

# Match conversion operators: operator TYPE
CONV_OP_RE = re.compile(
    r'(?:(?:public|protected|private):\s+)?'
    r'(?:__\w+\s+)'
    r'(\w+)::operator\s+(.*?)\s*\(\s*void\s*\)'
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
               'INT', 'UBOOL', 'FLOAT'):
        return 'return 0;'
    return f'return {ret}();'

# Classes that inherit from FSceneNode (no default ctor)
FSCENENODE_SUBCLASSES = {
    'FActorSceneNode', 'FCameraSceneNode', 'FLevelSceneNode',
    'FMirrorSceneNode', 'FSkySceneNode', 'FWarpZoneSceneNode',
    'FDirectionalLightMapSceneNode', 'FPointLightMapSceneNode',
    'FLightMapSceneNode',
}

def should_skip(demangled):
    for pat in SKIP_PATTERNS:
        if pat in demangled:
            return True
    return False

def generate_implementations(demangled_map):
    impls = []
    skipped = {'funcname': 0, 'vftable': 0, 'skip_class': 0, 'skip_pat': 0,
               'conv_op': 0, 'unmatched': 0, 'data': 0}
    generated = 0

    for mangled, demangled in sorted(demangled_map.items(), key=lambda x: x[1]):
        if '__FUNC_NAME__' in demangled or 'FUNC_NAME' in demangled:
            skipped['funcname'] += 1
            continue
        if "'vftable'" in demangled or "'vbtable'" in demangled:
            skipped['vftable'] += 1
            continue
        if 'default constructor closure' in demangled:
            skipped['unmatched'] += 1
            continue
        if 'Copyright' in demangled or 'Microsoft' in demangled:
            skipped['unmatched'] += 1
            continue
        if should_skip(demangled):
            skipped['skip_pat'] += 1
            continue
        if mangled in SKIP_MANGLES:
            skipped['skip_pat'] += 1
            continue

        # Check if this is a conversion operator
        cm = CONV_OP_RE.match(demangled)
        if cm:
            # Skip conversion operators - complex to generate correctly
            skipped['conv_op'] += 1
            continue

        m = SIG_RE.match(demangled)
        if not m:
            skipped['unmatched'] += 1
            continue

        ret_raw = m.group(1)
        cls = m.group(2)
        name = m.group(3).strip()
        params_raw = m.group(4)
        is_const = bool(m.group(5))

        # Skip entire classes
        if cls and cls in SKIP_CLASSES:
            skipped['skip_class'] += 1
            continue

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

        # Constructors/destructors
        if cls and (name == cls or name == f'~{cls}'):
            if name.startswith('~'):
                impl = f'{cls}::~{cls}(){const_str} {{}}'
            else:
                # Constructors for FSceneNode subclasses need initializer
                if cls in FSCENENODE_SUBCLASSES:
                    impl = f'{cls}::{cls}({param_str}){const_str} : FSceneNode((UViewport*)NULL) {{}}'
                elif cls == 'FInBunch':
                    impl = f'{cls}::{cls}({param_str}){const_str} : FBitReader(NULL, 0) {{}}'
                else:
                    impl = f'{cls}::{cls}({param_str}){const_str} {{}}'
        elif cls:
            body = default_return(ret)
            if body:
                impl = f'{ret} {cls}::{name}({param_str}){const_str} {{ {body} }}'
            else:
                impl = f'{ret} {cls}::{name}({param_str}){const_str} {{}}'
        else:
            # Free function / operator
            body = default_return(ret)
            if body:
                impl = f'{ret} {name}({param_str}){const_str} {{ {body} }}'
            else:
                impl = f'{ret} {name}({param_str}){const_str} {{}}'

        impls.append(f'// {mangled}')
        impls.append(impl)
        impls.append('')
        generated += 1

    return impls, generated, skipped

def generate_data_defs(demangled_map):
    defs = []
    count = 0
    for mangled, demangled in sorted(demangled_map.items(), key=lambda x: x[1]):
        dm = re.match(r'(?:public|protected|private):\s+static\s+(.*?)\s+(\w+)::(\w+)\s*$', demangled)
        if dm:
            ret = fix_type(dm.group(1))
            cls = dm.group(2)
            member = dm.group(3)
            if cls in SKIP_CLASSES:
                continue
            if '*' in ret:
                defs.append(f'{ret} {cls}::{member} = NULL;')
            elif ret == 'int' or ret == 'INT':
                defs.append(f'{ret} {cls}::{member} = 0;')
            elif ret == 'FString':
                defs.append(f'{ret} {cls}::{member};')
            else:
                defs.append(f'{ret} {cls}::{member};')
            defs.append('')
            count += 1
            continue

        if '(' not in demangled and '::' not in demangled and 'vftable' not in demangled:
            gm = re.match(r'^(.*?)\s+(\w+)\s*$', demangled)
            if gm and 'Microsoft' not in demangled:
                ret = fix_type(gm.group(1))
                name = gm.group(2)
                if '*' in ret:
                    defs.append(f'{ret} {name} = NULL;')
                elif ret == 'int' or ret == 'INT':
                    defs.append(f'{ret} {name} = 0;')
                else:
                    defs.append(f'{ret} {name};')
                defs.append('')
                count += 1

    return defs, count

# Forward declarations needed for types used in operator<< and other stubs
FORWARD_DECLS = """
// Forward declarations for types used by generated stubs
struct FBspNode;
struct FBspSection;
struct FBspVertex;
struct FPosNormTexData;
struct FSkinVertex;
struct FStaticMeshBatcherVertex;
struct FStaticMeshCollisionNode;
struct FStaticMeshCollisionTriangle;
struct FStaticMeshLightInfo;
struct FStaticMeshMaterial;
struct FStaticMeshSection;
struct FStaticMeshTriangle;
struct FStaticMeshUV;
struct FStaticMeshVertex;
struct FStaticMeshVertexStream;
struct FTerrainVertex;
struct FTerrainVertexStream;
struct FUV2Data;
struct FUntransformedVertex;
struct FProjectorRelativeRenderInfo;
struct FOrientation { BYTE Pad[16]; FOrientation& operator=(FOrientation) { return *this; } int operator!=(const FOrientation&) const { return 0; } };
struct FHitCause;
struct HHitProxy;
struct FRebuildOptions { BYTE Pad[256]; };
struct _KarmaGlobals;
struct _McdGeometry;
struct McdGeomMan;
struct _KarmaTriListData;
struct FDXTCompressionOptions { BYTE Pad[64]; };
struct FFontCharacter { BYTE Pad[16]; };
struct FFontPage { BYTE Pad[64]; };
struct FMipmapBase { BYTE Pad[32]; };
struct FDbgVectorInfo { BYTE Pad[64]; };
struct FTerrainMaterialLayer { BYTE Pad[64]; };
"""

def main():
    stubs = read_remaining_stubs()
    print(f'Total remaining stubs: {len(stubs)}')

    demangled_map = demangle_stubs(stubs)
    print(f'Demangled: {len(demangled_map)}')

    impls, gen_count, skipped = generate_implementations(demangled_map)
    data_defs, data_count = generate_data_defs(demangled_map)

    lines = [
        '/*=============================================================================',
        '  EngineBatchImpl3.cpp: Round 3 batch implementations.',
        '  Auto-generated by gen_impl4.py',
        '=============================================================================*/',
        '',
        '#include "EnginePrivate.h"',
        '',
        FORWARD_DECLS,
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
    print(f'Skipped: {skipped}')
    print(f'Wrote {OUTPUT}')

if __name__ == '__main__':
    main()
''').lstrip()

with open('tools/gen_impl4.py', 'w') as f:
    f.write(content)
print(f'Wrote tools/gen_impl4.py ({len(content)} bytes)')
