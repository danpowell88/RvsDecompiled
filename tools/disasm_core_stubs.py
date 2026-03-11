"""disasm_core_stubs.py - Disassemble Core.dll stubs for analysis."""
import capstone

data = open('retail/system/Core.dll','rb').read()
exports = {}
with open('build/retail_core_exports.txt', 'r') as f:
    for line in f:
        p = line.strip().split()
        if len(p) >= 4:
            try: exports[p[3]] = int(p[2], 16)
            except: pass

md = capstone.Cs(capstone.CS_ARCH_X86, capstone.CS_MODE_32)

targets = [
    ('Modify',           'UObject'),
    ('PostEditChange',   'UObject'),
    ('ScriptConsoleExec','UObject'),
    ('LanguageChange',   'UObject'),
    ('StaticExec',       'UObject'),
    ('IsReferenced',     'UObject'),
    ('VerifyLinker',     'UObject'),
    ('AttemptDelete',    'UObject'),
    ('ObjectToIndex',    'UPackageMap'),
    ('IndexToObject',    'UPackageMap'),
    ('CanSerializeObject','UPackageMap'),
    ('AddCppProperty',   'UField'),
    ('StaticConstructor','UExporter'),
    ('MapName',          'ULinkerSave'),
    ('FindState',        'UObject'),
    ('BindPackage',      'UObject'),
    ('ResetLoaders',     'UObject'),
    ('Enter',            'FFileStream'),
    ('Leave',            'FFileStream'),
    ('Read',             'FFileStream'),
]

for fname, cls in targets:
    matches = [(k, v) for k, v in exports.items() if fname in k and cls in k]
    if not matches:
        print(f'{cls}::{fname}: NOT FOUND')
        continue
    k, rva = min(matches, key=lambda x: len(x[0]))
    print(f'=== {cls}::{fname} (RVA=0x{rva:05X}) ===')
    count = 0
    for ins in md.disasm(data[rva:rva+300], rva):
        print(f'  {ins.address:05X}  {ins.mnemonic} {ins.op_str}')
        count += 1
        if ins.mnemonic in ('ret', 'retn'):
            break
        if count > 60:
            print('  ...(truncated)')
            break
    print()
