import re

HEADER = 'src/engine/EngineClasses.h'
DEMANGLED = 'build/demangled_report.txt'
OUTPUT = 'src/engine/EngineBatchImpl.cpp'

# Parse header for declared class methods
def get_declared_methods():
    with open(HEADER, 'r') as f:
        content = f.read()
    
    # Find all class names
    declared = {}  # cls -> set of method names
    current_class = None
    
    for line in content.split('\n'):
        m = re.match(r'class\s+ENGINE_API\s+(\w+)\s*:', line)
        if m:
            current_class = m.group(1)
            if current_class not in declared:
                declared[current_class] = set()
            continue
        if line.strip() == '};':
            current_class = None
            continue
        if current_class:
            stripped = line.strip()
            # Match method declarations
            m2 = re.match(r'(?:virtual\s+)?(?:static\s+)?\w[\w\s\*\&<>,]*\s+(\w+)\s*\(', stripped)
            if m2 and stripped.endswith(';') and not stripped.startswith('DECLARE_') and not stripped.startswith('//'):
                declared[current_class].add(m2.group(1))
    
    return declared

# Parse demangled report
def parse_report():
    classes = {}
    current = None
    CLASS_RE = re.compile(r'^CLASS:\s+(\w+)\s+\((\d+)\s+stubs?\)')
    ENTRY_RE = re.compile(r'\s*\[(\w+)\s*\]\s+(.*)')
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

SIG_RE = re.compile(
    r'(?:public|protected|private):\s*'
    r'(virtual\s+)?'
    r'(.*?)\s+'
    r'__thiscall\s+'
    r'(\w+)::(\w+)'
    r'\((.*)\)'
)

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
    if r == 'void': return None
    if r in ('int', 'INT', 'UBOOL'): return '0'
    if r in ('float', 'FLOAT'): return '0.0f'
    if r in ('DWORD', 'UINT', 'BYTE', '_WORD'): return '0'
    if '*' in r: return 'NULL'
    if 'FString' in r: return 'FString()'
    if 'FVector' in r: return 'FVector(0,0,0)'
    if 'FRotator' in r: return 'FRotator(0,0,0)'
    if 'FMatrix' in r: return 'FMatrix()'
    if 'FName' in r: return 'FName(NAME_None)'
    return '{}()'

# Already implemented in other .cpp files
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

declared = get_declared_methods()
report = parse_report()

out = []
out.append('// EngineBatchImpl.cpp - Auto-generated stub implementations\n')
out.append('// Only includes methods that are declared in EngineClasses.h\n')
out.append('#include "Engine.h"\n\n')

generated = 0
cls_count = 0
missing_total = 0

for cls_name in sorted(report.keys()):
    if cls_name in SKIP_CLASSES:
        continue
    if cls_name not in declared:
        continue
    
    cls_methods = declared[cls_name]
    methods = []
    missing = []
    
    for kind, sig in report[cls_name]:
        if kind in ('data', 'vtable', 'ctor', 'dtor'):
            continue
        p = parse_sig(sig)
        if p is None:
            continue
        if (cls_name, p['method']) in SKIP_METHODS:
            continue
        if p['method'] in cls_methods:
            methods.append(p)
        else:
            missing.append(p['method'])
    
    if missing:
        missing_total += len(missing)
    
    if not methods:
        continue
    
    cls_count += 1
    out.append('// --- %s ---\n' % cls_name)
    
    for p in methods:
        ret_cpp = fix_type(p['ret'])
        params_cpp = fix_type(p['params'])
        if params_cpp == 'void':
            params_cpp = ''
        dr = default_return(ret_cpp)
        body = '\treturn %s;\n' % dr if dr else ''
        out.append('%s %s::%s(%s)\n' % (ret_cpp, cls_name, p['method'], params_cpp))
        out.append('{\n')
        out.append(body)
        out.append('}\n\n')
        generated += 1

with open(OUTPUT, 'w') as f:
    f.writelines(out)

print('Generated %d implementations for %d classes' % (generated, cls_count))
print('Missing declarations (not generated): %d methods' % missing_total)