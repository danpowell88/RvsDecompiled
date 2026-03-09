"""Generate EngineBatchImpl.cpp with stub implementations for all
class methods from the demangled report."""
import re

DEMANGLED = 'build/demangled_report.txt'
OUTPUT = 'src/engine/EngineBatchImpl.cpp'

SKIP_CLASSES = {
    'AActor', 'APawn', 'ULevel', 'ULevelBase', 'ALevelInfo', 'AGameInfo',
    'AInfo', 'AGameReplicationInfo', 'APlayerReplicationInfo', 'UNKNOWN',
}

SKIP_METHODS = {
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
}

SIG_RE = re.compile(
    r'(?:public|protected|private):\s*'
    r'(virtual\s+)?'
    r'(.*?)\s+'
    r'__thiscall\s+'
    r'(\w+)::(\w+)'
    r'\((.*)\)'
)

CLASS_RE = re.compile(r'^CLASS:\s+(\w+)\s+\((\d+)\s+stubs?\)')
ENTRY_RE = re.compile(r'\s*\[(\w+)\s*\]\s+(.*)')


def parse_report():
    classes = {}
    current = None
    with open(DEMANGLED, 'r') as f:
        for line in f:
            line = line.rstrip()
            if not line or line.startswith('==='):
                continue
            m = CLASS_RE.match(line)
            if m:
                current = m.group(1)
                classes[current] = []
                continue
            m = ENTRY_RE.match(line)
            if m and current:
                classes[current].append((m.group(1), m.group(2).strip()))
    return classes


def parse_sig(sig):
    m = SIG_RE.match(sig)
    if not m:
        return None
    return {
        'virtual': bool(m.group(1)),
        'ret': m.group(2).strip(),
        'cls': m.group(3),
        'method': m.group(4),
        'params': m.group(5).strip(),
    }


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
    if r == 'void':
        return None
    if r in ('int', 'INT', 'UBOOL'):
        return '0'
    if r in ('float', 'FLOAT'):
        return '0.0f'
    if r in ('DWORD', 'UINT', 'BYTE', '_WORD'):
        return '0'
    if '*' in r:
        return 'NULL'
    if 'FString' in r:
        return 'FString()'
    if 'FVector' in r:
        return 'FVector(0,0,0)'
    if 'FRotator' in r:
        return 'FRotator(0,0,0)'
    if 'FMatrix' in r:
        return 'FMatrix()'
    if 'FName' in r:
        return 'FName(NAME_None)'
    return '{}()'


def main():
    classes = parse_report()
    total_entries = sum(len(v) for v in classes.values())
    print(f'Parsed {len(classes)} classes, {total_entries} total entries')

    out = []
    out.append('// EngineBatchImpl.cpp - Auto-generated stub implementations\n')
    out.append('#include "Engine.h"\n\n')

    generated = 0
    cls_count = 0

    for cls_name in sorted(classes.keys()):
        if cls_name in SKIP_CLASSES:
            continue

        methods = []
        for kind, sig in classes[cls_name]:
            if kind in ('data', 'vtable', 'ctor', 'dtor'):
                continue
            p = parse_sig(sig)
            if p is None:
                continue
            if (cls_name, p['method']) in SKIP_METHODS:
                continue
            methods.append(p)

        if not methods:
            continue

        cls_count += 1
        out.append(f'// --- {cls_name} ---\n')

        for p in methods:
            ret_cpp = fix_type(p['ret'])
            params_cpp = fix_type(p['params'])
            if params_cpp == 'void':
                params_cpp = ''

            dr = default_return(ret_cpp)
            body = f'\treturn {dr};\n' if dr else ''

            line = f'{ret_cpp} {cls_name}::{p["method"]}({params_cpp})\n'
            out.append(line)
            out.append('{\n')
            out.append(body)
            out.append('}\n\n')
            generated += 1

    with open(OUTPUT, 'w') as f:
        f.writelines(out)

    print(f'Generated {generated} implementations for {cls_count} classes')
    print(f'Written to {OUTPUT}')


if __name__ == '__main__':
    main()
