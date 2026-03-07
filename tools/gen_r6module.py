"""
Generic R6 module header + cpp generator.
Usage: python tools/gen_r6module.py <ModuleName> <sdk_header> <def_file> <out_header> <out_cpp>
"""
import re
import sys
from collections import defaultdict

def skip_block(start_idx, lines):
    brace = 0
    found_open = False
    idx = start_idx
    while idx < len(lines):
        brace += lines[idx].count('{') - lines[idx].count('}')
        if brace > 0:
            found_open = True
        if found_open and brace <= 0:
            return idx + 1
        idx += 1
    return idx

def generate_module(module_name, sdk_path, def_path, out_header, out_cpp, depends_on=None):
    API_MACRO = f'{module_name.upper()}_API'
    PREFIX = module_name.upper()
    
    with open(sdk_path, encoding='latin-1') as f:
        sdk_lines = f.readlines()
    
    with open(def_path, encoding='latin-1') as f:
        def_text = f.read()
    
    autoclass_names = set(re.findall(r'autoclass(\w+)', def_text))
    
    # Extract exec functions
    exec_funcs = []
    for m in re.finditer(r'int(\w+exec\w+)', def_text):
        full = m.group(1)
        exec_idx = full.find('exec')
        exec_funcs.append((full[:exec_idx], full[exec_idx:]))
    
    # Extract AUTOGENERATE_NAME entries
    autogen_lines = []
    for line in sdk_lines:
        if line.strip().startswith('AUTOGENERATE_NAME'):
            autogen_lines.append(line)
    
    # Parse classes
    classes = []
    structs_normal = []
    enums = []
    
    i = 0
    total = len(sdk_lines)
    while i < total:
        line = sdk_lines[i]
        stripped = line.strip()
        
        if re.match(r'struct\s+\w+_(exec|event)\w+_Parms', stripped):
            end = skip_block(i, sdk_lines)
            i = end
            continue
        
        m_struct = re.match(r'struct\s+(?:DLL_IMPORT\s+)?(\w+)', stripped)
        if m_struct and not stripped.startswith('//'):
            if '{' not in stripped:
                struct_lines = []
                while i < total:
                    struct_lines.append(sdk_lines[i])
                    if '};' in sdk_lines[i]:
                        break
                    i += 1
                structs_normal.append((''.join(struct_lines), m_struct.group(1)))
                i += 1
                continue
            else:
                struct_lines = []
                end = skip_block(i, sdk_lines)
                for j in range(i, end):
                    struct_lines.append(sdk_lines[j])
                structs_normal.append((''.join(struct_lines), m_struct.group(1)))
                i = end
                continue
        
        if stripped.startswith('enum ') and '{' in stripped:
            enum_lines = []
            end = skip_block(i, sdk_lines)
            for j in range(i, end):
                enum_lines.append(sdk_lines[j])
            enums.append(''.join(enum_lines))
            i = end
            continue
        
        m_class = re.match(r'class\s+(?:DLL_IMPORT\s+)?(\w+)\s*:\s*public\s+(\w+)', stripped)
        if m_class:
            class_name = m_class.group(1)
            base_name = m_class.group(2)
            class_lines_raw = []
            end = skip_block(i, sdk_lines)
            for j in range(i, end):
                class_lines_raw.append(sdk_lines[j])
            
            # Process class
            members = []
            virtuals = []
            events = []
            execs = []
            other_methods = []
            
            for cl in class_lines_raw[1:]:
                code = re.sub(r'\s*//.*$', '', cl.strip()).strip()
                
                if any(k in code for k in ['InternalConstructor', 'PrivateStaticClass', 'operator new', 'operator=']):
                    continue
                if code.startswith('static class UClass') or code.startswith('static void CDECL InternalConstructor'):
                    continue
                if re.match(r'\w+\s*\(\s*class\s+\w+\s+const\s*&\s*\)', code):
                    continue
                if re.match(r'^' + re.escape(class_name) + r'\s*\(\s*\)\s*;?$', code):
                    continue
                if re.match(r'virtual\s+~' + re.escape(class_name), code):
                    continue
                if code in ['public:', 'protected:', 'private:', '{', '};', '']:
                    continue
                if code.startswith('//'):
                    continue
                
                if code.startswith('virtual '):
                    virtuals.append(code.rstrip(';').strip())
                    continue
                
                if re.match(r'(?:void|FLOAT|INT|BYTE|BITFIELD|FString|FVector|FRotator|DWORD)\s+event\w+\s*\(', code):
                    events.append(code.rstrip(';').strip())
                    continue
                
                if 'exec' in code and 'FFrame' in code:
                    execs.append(code.rstrip(';').strip())
                    continue
                
                if code.endswith(';') and '(' not in code:
                    clean = code.rstrip(';').strip() + ';'
                    if clean and clean != ';':
                        members.append(clean)
                    continue
                
                if '(' in code and code.endswith(';') and not code.startswith('static'):
                    other_methods.append(code.rstrip(';').strip())
                    continue
            
            classes.append({
                'name': class_name,
                'base': base_name,
                'is_autoclass': class_name in autoclass_names,
                'members': members,
                'virtuals': virtuals,
                'events': events,
                'execs': execs,
                'other_methods': other_methods,
            })
            i = end
            continue
        
        i += 1
    
    print(f"  Classes: {len(classes)}, Autoclass: {len([c for c in classes if c['is_autoclass']])}")
    print(f"  Structs: {len(structs_normal)}, Enums: {len(enums)}")
    print(f"  AUTOGENERATE_NAMEs: {len(autogen_lines)}, Exec functions: {len(exec_funcs)}")
    
    # ---- Generate Header ----
    out = []
    out.append(f"/*=============================================================================")
    out.append(f"\t{module_name}Classes.h: {module_name} class declarations.")
    out.append(f"\tReconstructed from Ravenshield 1.56 SDK and Ghidra analysis.")
    out.append(f"=============================================================================*/")
    out.append("")
    out.append("#if _MSC_VER")
    out.append("#pragma pack(push, 4)")
    out.append("#endif")
    out.append("")
    out.append(f"#ifndef {API_MACRO}")
    out.append(f"#define {API_MACRO} DLL_IMPORT")
    out.append("#endif")
    out.append("")
    out.append("#ifndef NAMES_ONLY")
    out.append(f"#define AUTOGENERATE_NAME(name) extern {API_MACRO} FName {PREFIX}_##name;")
    out.append("#define AUTOGENERATE_FUNCTION(cls,idx,name)")
    out.append("#endif")
    out.append("")
    
    for line in autogen_lines:
        out.append(line.rstrip())
    
    out.append("")
    out.append("#ifndef NAMES_ONLY")
    out.append("")
    
    # Enums
    if enums:
        for enum_text in enums:
            out.append(enum_text.rstrip())
            out.append("")
    
    # Structs
    if structs_normal:
        for struct_text, struct_name in structs_normal:
            clean = struct_text.replace('DLL_IMPORT ', '')
            clean = re.sub(r'\s*//CPF_\w+(\|\w+)*', '', clean)
            clean = re.sub(r'\s*//0\s*$', '', clean, flags=re.MULTILINE)
            out.append(clean.rstrip())
            out.append("")
    
    # Classes - dependency order
    class_by_name = {c['name']: c for c in classes}
    output_classes = set()
    
    def emit_class(cls):
        if cls['name'] in output_classes:
            return
        if cls['base'] in class_by_name and cls['base'] not in output_classes:
            emit_class(class_by_name[cls['base']])
        output_classes.add(cls['name'])
        
        out.append(f"class {API_MACRO} {cls['name']} : public {cls['base']}")
        out.append("{")
        out.append("public:")
        
        if cls['is_autoclass']:
            out.append(f"\tDECLARE_CLASS({cls['name']}, {cls['base']}, 0, {module_name})")
            out.append("")
        
        for member in cls['members']:
            clean = re.sub(r'class\s+', '', member)
            clean = re.sub(r'struct\s+', '', clean)
            out.append(f"\t{clean}")
        
        if cls['members']:
            out.append("")
        
        for virt in cls['virtuals']:
            clean = re.sub(r'class\s+', '', virt)
            out.append(f"\t{clean};")
        
        for ev in cls['events']:
            clean = re.sub(r'class\s+', '', ev)
            out.append(f"\t{clean};")
        
        for ex in cls['execs']:
            out.append(f"\t{ex};")
        
        for meth in cls['other_methods']:
            clean = re.sub(r'class\s+', '', meth)
            out.append(f"\t{clean};")
        
        out.append("")
        out.append("protected:")
        out.append(f"\t{cls['name']}() {{}}")
        out.append("};")
        out.append("")
    
    for cls in classes:
        emit_class(cls)
    
    out.append("#endif // !NAMES_ONLY")
    out.append("")
    out.append("#ifndef NAMES_ONLY")
    out.append("#undef AUTOGENERATE_NAME")
    out.append("#undef AUTOGENERATE_FUNCTION")
    out.append("#endif")
    out.append("")
    out.append("#if _MSC_VER")
    out.append("#pragma pack(pop)")
    out.append("#endif")
    
    with open(out_header, 'w') as f:
        f.write('\n'.join(out) + '\n')
    print(f"  Generated header: {out_header} ({len(out)} lines)")
    
    # ---- Generate CPP ----
    
    # Parse exported methods from .def
    def_lines = [l.strip() for l in def_text.split('\n') if l.strip() and not l.strip().startswith(';') and 'LIBRARY' not in l and 'EXPORTS' not in l]
    
    exported_methods = defaultdict(list)
    for line in def_lines:
        if any(k in line for k in ['autoclass', '??0', '??1', '??_7', '??4', '??2', 'GPackage', '_DllMain', 'PrivateStaticClass', 'InternalConstructor', '?StaticClass@', f'{PREFIX}_']):
            continue
        if line.startswith('int') and 'exec' in line:
            continue
        m = re.match(r'\?(\w+)@(\w+)@@', line)
        if m:
            exported_methods[m.group(2)].append((m.group(1), line))
    
    # Build class method signatures from header
    class_methods = {}
    current_cls = None
    in_cls = False
    for hline in out:  # use generated header
        stripped = hline.strip()
        m = re.match(r'class\s+\w+\s+(\w+)\s*:\s*public\s+(\w+)', stripped)
        if m:
            current_cls = m.group(1)
            in_cls = True
            class_methods[current_cls] = {}
            continue
        if in_cls and stripped == '};':
            in_cls = False
            continue
        if in_cls and current_cls and '(' in stripped and stripped.endswith(';'):
            m2 = re.match(r'(?:virtual\s+)?(?:[\w\s\*&]+?)\s+(\w+)\s*\(', stripped)
            if m2:
                class_methods[current_cls][m2.group(1)] = stripped.rstrip(';')
    
    cpp = []
    cpp.append(f"/*=============================================================================")
    cpp.append(f"\t{module_name}.cpp: {module_name} package.")
    cpp.append(f"\tReconstructed for Ravenshield decompilation project.")
    cpp.append(f"=============================================================================*/")
    cpp.append("")
    cpp.append(f'#include "{module_name}Private.h"')
    cpp.append("")
    cpp.append(f"IMPLEMENT_PACKAGE({module_name})")
    cpp.append("")
    cpp.append("#define NAMES_ONLY")
    cpp.append(f"#define AUTOGENERATE_NAME(name) {API_MACRO} FName {PREFIX}_##name;")
    cpp.append("#define AUTOGENERATE_FUNCTION(cls,idx,name) IMPLEMENT_FUNCTION(cls,idx,name)")
    cpp.append(f'#include "{module_name}Classes.h"')
    cpp.append("#undef AUTOGENERATE_FUNCTION")
    cpp.append("#undef AUTOGENERATE_NAME")
    cpp.append("#undef NAMES_ONLY")
    cpp.append("")
    
    sorted_autoclass = sorted(autoclass_names)
    for cls in sorted_autoclass:
        cpp.append(f"IMPLEMENT_CLASS({cls})")
    
    cpp.append("")
    for cls, func in exec_funcs:
        cpp.append(f"IMPLEMENT_FUNCTION({cls}, -1, {func})")
    
    cpp.append("")
    cpp.append("/*-----------------------------------------------------------------------------")
    cpp.append("\tMethod stubs.")
    cpp.append("-----------------------------------------------------------------------------*/")
    cpp.append("")
    
    def get_ret_default(sig):
        sig = sig.strip()
        if sig.startswith('virtual '):
            sig = sig[8:]
        m = re.match(r'([\w\s\*&]+?)\s+\w+\s*\(', sig)
        if not m:
            return ''
        ret = m.group(1).strip()
        if ret == 'void': return None
        elif ret in ('INT', 'int', 'DWORD', 'BYTE'): return '0'
        elif ret in ('FLOAT', 'float'): return '0.f'
        elif ret == 'bool': return 'false'
        elif ret == 'FString': return 'TEXT("")'
        elif ret == 'FVector': return 'FVector(0,0,0)'
        elif ret == 'FRotator': return 'FRotator(0,0,0)'
        elif '*' in ret: return 'NULL'
        else: return '0'
    
    for cls_name in sorted(exported_methods.keys()):
        if cls_name.startswith('_') or cls_name.startswith('?'):
            continue
        
        methods = exported_methods[cls_name]
        cls_sigs = class_methods.get(cls_name, {})
        
        cpp.append(f"// --- {cls_name} ---")
        cpp.append("")
        
        for method_name, mangled in methods:
            if method_name in cls_sigs:
                sig = cls_sigs[method_name]
                clean_sig = sig.rstrip(';').strip()
                
                if method_name.startswith('event'):
                    event_name = method_name[5:]
                    fname_var = f"{PREFIX}_{event_name}"
                    
                    # Parse signature
                    m = re.match(r'(?:virtual\s+)?([\w\s\*&]+?)\s+(event\w+)\s*\((.*?)\)\s*(const)?', clean_sig)
                    if m:
                        ret = m.group(1).strip()
                        params = m.group(3).strip()
                        const_str = ' const' if m.group(4) else ''
                        
                        if ret == 'void' and not params:
                            cpp.append(f"void {cls_name}::{method_name}(){const_str}")
                            cpp.append("{")
                            cpp.append(f"\tProcessEvent(FindFunctionChecked({fname_var}), NULL);")
                            cpp.append("}")
                        elif ret == 'void':
                            cpp.append(f"void {cls_name}::{method_name}({params}){const_str}")
                            cpp.append("{")
                            param_list = [p.strip() for p in params.split(',') if p.strip()]
                            cpp.append("\tstruct {")
                            for p in param_list:
                                cpp.append(f"\t\t{p};")
                            cpp.append("\t} Parms;")
                            for p in param_list:
                                parts = p.strip().split()
                                pname = parts[-1].lstrip('*&')
                                cpp.append(f"\tParms.{pname} = {pname};")
                            cpp.append(f"\tProcessEvent(FindFunctionChecked({fname_var}), &Parms);")
                            cpp.append("}")
                        else:
                            cpp.append(f"{ret} {cls_name}::{method_name}({params}){const_str}")
                            cpp.append("{")
                            param_list = [p.strip() for p in params.split(',') if p.strip()] if params else []
                            ret_def = get_ret_default(f"{ret} x()")
                            cpp.append("\tstruct {")
                            for p in param_list:
                                cpp.append(f"\t\t{p};")
                            cpp.append(f"\t\t{ret} ReturnValue;")
                            cpp.append("\t} Parms;")
                            if ret_def is not None:
                                cpp.append(f"\tParms.ReturnValue = {ret_def};")
                            for p in param_list:
                                parts = p.strip().split()
                                pname = parts[-1].lstrip('*&')
                                cpp.append(f"\tParms.{pname} = {pname};")
                            cpp.append(f"\tProcessEvent(FindFunctionChecked({fname_var}), &Parms);")
                            cpp.append("\treturn Parms.ReturnValue;")
                            cpp.append("}")
                    cpp.append("")
                elif method_name.startswith('exec') and 'FFrame' in sig:
                    cpp.append(f"void {cls_name}::{method_name}(FFrame& Stack, RESULT_DECL)")
                    cpp.append("{")
                    cpp.append("\tP_FINISH;")
                    cpp.append("}")
                    cpp.append("")
                else:
                    # Regular method
                    m = re.match(r'(?:virtual\s+)?([\w\s\*&]+?)\s+(\w+)\s*\((.*?)\)\s*(const)?', clean_sig)
                    if m:
                        ret = m.group(1).strip()
                        params = m.group(3).strip()
                        const_str = ' const' if m.group(4) else ''
                        
                        ret_def = get_ret_default(sig)
                        cpp.append(f"{ret} {cls_name}::{method_name}({params}){const_str}")
                        cpp.append("{")
                        if ret_def is None:
                            pass
                        else:
                            cpp.append(f"\treturn {ret_def};")
                        cpp.append("}")
                        cpp.append("")
            elif method_name.startswith('exec'):
                cpp.append(f"void {cls_name}::{method_name}(FFrame& Stack, RESULT_DECL)")
                cpp.append("{")
                cpp.append("\tP_FINISH;")
                cpp.append("}")
                cpp.append("")
            elif not method_name.startswith('m_'):
                cpp.append(f"// TODO: {cls_name}::{method_name}")
                cpp.append("")
    
    with open(out_cpp, 'w') as f:
        f.write('\n'.join(cpp) + '\n')
    print(f"  Generated cpp: {out_cpp} ({len(cpp)} lines)")

if __name__ == '__main__':
    modules = {
        'R6Game': {
            'sdk': 'sdk/Raven_Shield_C_SDK/inc/R6GameClasses.h',
            'def': 'src/r6game/R6Game.def',
            'header': 'src/r6game/R6GameClasses.h',
            'cpp': 'src/r6game/R6Game.cpp',
        },
        'R6GameService': {
            'sdk': 'sdk/Raven_Shield_C_SDK/inc/R6GameServiceClasses.h',
            'def': 'src/r6gameservice/R6GameService.def',
            'header': 'src/r6gameservice/R6GameServiceClasses.h',
            'cpp': 'src/r6gameservice/R6GameService.cpp',
        },
    }
    
    for name, paths in modules.items():
        print(f"\n=== {name} ===")
        generate_module(name, paths['sdk'], paths['def'], paths['header'], paths['cpp'])
