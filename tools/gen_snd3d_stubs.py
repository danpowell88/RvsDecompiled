"""Generate SNDDSound3D.cpp stub file from dumpbin export tables."""
import re
import os

def parse_exports(filename):
    exports = []
    in_table = False
    with open(filename, encoding='utf-8') as f:
        for line in f:
            stripped = line.strip()
            if 'ordinal' in stripped and 'hint' in stripped and 'RVA' in stripped:
                in_table = True
                continue
            if not in_table:
                continue
            if not stripped:
                continue
            if stripped.startswith('Summary'):
                break
            parts = stripped.split()
            if len(parts) >= 4 and parts[0].isdigit():
                exports.append(parts[3])
    return exports

def get_return_type(funcname):
    m = re.match(r'(?:dbg)?SND_fn_([a-z]+)', funcname)
    if not m:
        if funcname.startswith('SND_Is'):
            return 'int'
        return 'int'
    indicator = m.group(1)
    if indicator.startswith('v'):
        return 'void'
    elif indicator.startswith('b'):
        return 'int'
    elif indicator.startswith('l'):
        return 'long'
    elif indicator.startswith('r'):
        return 'float'
    elif indicator.startswith('f'):
        return 'float'
    elif indicator.startswith('h'):
        return 'void*'
    elif indicator.startswith('pst'):
        return 'void*'
    elif indicator.startswith('p'):
        return 'void*'
    elif indicator.startswith('ul'):
        return 'unsigned long'
    elif indicator.startswith('uw'):
        return 'unsigned short'
    elif indicator.startswith('uc'):
        return 'unsigned char'
    elif indicator.startswith('e'):
        return 'int'
    elif indicator.startswith('sz') or indicator.startswith('cz'):
        return 'const char*'
    elif indicator.startswith('rt'):
        return 'double'
    elif indicator.startswith('i'):
        return 'int'
    return 'int'

def get_return_stmt(rtype):
    if rtype == 'void':
        return ''
    elif rtype in ('float', 'double'):
        return ' return 0.0f;'
    return ' return 0;'

def main():
    base = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    ret_names = parse_exports(os.path.join(base, 'build', 'snd3d_ret_exports.txt'))
    vsr_names = parse_exports(os.path.join(base, 'build', 'snd3d_vsr_exports.txt'))
    ret_set = set(ret_names)

    data_exports = {'liste_of_association', 'liste_of_voices'}
    stdcall_exports = {}
    cdecl_exports = set()

    for name in sorted(set(ret_names + vsr_names)):
        if name in data_exports:
            continue
        if name.startswith('?'):
            continue  # handled manually
        elif name.startswith('_'):
            m = re.match(r'^_(.+)@(\d+)$', name)
            if m:
                stdcall_exports[m.group(1)] = int(m.group(2))
        else:
            cdecl_exports.add(name)

    lines = []
    lines.append('// SNDDSound3D.cpp - DARE Sound Engine DirectSound3D backend stubs')
    lines.append('// Auto-generated stubs for SNDDSound3DDLL_ret.dll and SNDDSound3DDLL_VSR.dll')
    lines.append('// All functions defined here; .def files control which are exported per variant.')
    lines.append('//')
    lines.append('// DARE (Digital Audio Rendering Engine) is third-party audio middleware by')
    lines.append('// Ubi Soft Montreal\'s audio team. This module provides the DirectSound3D')
    lines.append('// backend implementation with EAX support.')
    lines.append('')
    lines.append('#pragma warning(disable: 4100) // unreferenced formal parameter')
    lines.append('')
    lines.append('#include <windows.h>')
    lines.append('')
    lines.append('// DARE HRTF type enum (for C++ mangled export)')
    lines.append('enum _SND_tdeHTRFType { SND_HRTF_NONE = 0 };')
    lines.append('')

    # Data exports
    lines.append('// =============================================================================')
    lines.append('// Data exports')
    lines.append('// =============================================================================')
    lines.append('')
    lines.append('extern "C" {')
    lines.append('__declspec(dllexport) void* functions = 0;')
    lines.append('__declspec(dllexport) void* liste_of_association = 0;')
    lines.append('__declspec(dllexport) void* liste_of_voices = 0;')
    lines.append('__declspec(dllexport) void* names = 0;')
    lines.append('}')
    lines.append('')

    # C++ mangled functions
    lines.append('// =============================================================================')
    lines.append('// C++ exports (name-mangled)')
    lines.append('// =============================================================================')
    lines.append('')
    lines.append('// ?SND_fn_vDisableHardwareAcceleration@@YAXH@Z')
    lines.append('void SND_fn_vDisableHardwareAcceleration(int bDisable) {}')
    lines.append('')
    lines.append('// ?SND_fn_vSetHRTFOption@@YAXW4_SND_tdeHTRFType@@@Z')
    lines.append('void SND_fn_vSetHRTFOption(_SND_tdeHTRFType eType) {}')
    lines.append('')

    # Stdcall functions
    lines.append('// =============================================================================')
    lines.append('// __stdcall exports (decorated _Name@N)')
    lines.append('// =============================================================================')
    lines.append('')
    lines.append('extern "C" {')
    lines.append('')

    for name in sorted(stdcall_exports.keys()):
        nbytes = stdcall_exports[name]
        nparams = nbytes // 4
        rtype = get_return_type(name)
        ret_stmt = get_return_stmt(rtype)
        params = ', '.join([f'int p{i}' for i in range(nparams)]) if nparams > 0 else 'void'
        decorated = f'_{name}@{nbytes}'
        vsr_only = decorated not in ret_set
        marker = ' // VSR only' if vsr_only else ''
        lines.append(f'{rtype} __stdcall {name}({params}) {{{ret_stmt} }}{marker}')

    lines.append('')
    lines.append('} // extern "C"')
    lines.append('')

    # Cdecl functions
    lines.append('// =============================================================================')
    lines.append('// __cdecl exports (undecorated names)')
    lines.append('// =============================================================================')
    lines.append('')
    lines.append('extern "C" {')
    lines.append('')

    for name in sorted(cdecl_exports):
        rtype = get_return_type(name)
        ret_stmt = get_return_stmt(rtype)
        vsr_only = name not in ret_set
        marker = ' // VSR only' if vsr_only else ''
        lines.append(f'{rtype} {name}() {{{ret_stmt} }}{marker}')

    lines.append('')
    lines.append('} // extern "C"')
    lines.append('')

    # DllMain
    lines.append('BOOL WINAPI DllMain(HINSTANCE hinstDLL, DWORD fdwReason, LPVOID lpvReserved)')
    lines.append('{')
    lines.append('    return TRUE;')
    lines.append('}')
    lines.append('')

    outpath = os.path.join(base, 'src', 'sndsound3d', 'SNDDSound3D.cpp')
    with open(outpath, 'w', encoding='utf-8') as f:
        f.write('\n'.join(lines))

    print(f'Written {len(lines)} lines to {outpath}')
    print(f'  Stdcall functions: {len(stdcall_exports)}')
    print(f'  Cdecl functions: {len(cdecl_exports)}')
    print(f'  C++ functions: 2')
    print(f'  Data exports: {len(data_exports)}')

if __name__ == '__main__':
    main()
