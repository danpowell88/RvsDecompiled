"""Parse SDK C++ header files for R6 modules and output structured data."""
import re
import sys

files = {
    'R6WeaponsClasses.h': r'c:\Users\danpo\Desktop\rvs\sdk\Raven_Shield_C_SDK\inc\R6WeaponsClasses.h',
    'R6EngineClasses.h': r'c:\Users\danpo\Desktop\rvs\sdk\Raven_Shield_C_SDK\inc\R6EngineClasses.h',
    'R6GameClasses.h': r'c:\Users\danpo\Desktop\rvs\sdk\Raven_Shield_C_SDK\inc\R6GameClasses.h',
    'R6GameServiceClasses.h': r'c:\Users\danpo\Desktop\rvs\sdk\Raven_Shield_C_SDK\inc\R6GameServiceClasses.h',
}

output = r'c:\Users\danpo\Desktop\rvs\build\sdk_headers_full_analysis.txt'

with open(output, 'w', encoding='utf-8') as out:
    for fname, fpath in files.items():
        with open(fpath, 'r', encoding='latin-1') as f:
            content = f.read()
        lines = content.split('\n')
        
        out.write(f'\n{"="*80}\n')
        out.write(f' {fname}\n')
        out.write(f'{"="*80}\n')
        
        # 1. AUTOGENERATE_NAME macro
        macro_m = re.search(r'#define\s+AUTOGENERATE_NAME\(name\)\s+extern\s+DLL_IMPORT\s+FName\s+(\w+)_##name;', content)
        if macro_m:
            out.write(f'\nAPI Macro Prefix: {macro_m.group(1)}\n')
            out.write(f'Usage: extern DLL_IMPORT FName {macro_m.group(1)}_##name;\n')
        
        # 2. AUTOGENERATE_NAME entries
        names = re.findall(r'AUTOGENERATE_NAME\((\w+)\)', content)
        out.write(f'\n--- AUTOGENERATE_NAME entries ({len(names)}) ---\n')
        for n in names:
            out.write(f'  AUTOGENERATE_NAME({n})\n')
        
        # 3. Enums
        enum_pattern = re.compile(r'enum\s+(\w+)\s*\{([^}]+)\}', re.DOTALL)
        enums = enum_pattern.findall(content)
        out.write(f'\n--- Enums ({len(enums)}) ---\n')
        for ename, ebody in enums:
            out.write(f'\nenum {ename} {{\n')
            for val_line in ebody.strip().split('\n'):
                val_line = val_line.strip()
                if val_line:
                    out.write(f'    {val_line}\n')
            out.write(f'}};\n')
        
        # 4. DLL_IMPORT Structs with members
        struct_pattern = re.compile(
            r'^struct\s+DLL_IMPORT\s+(\w+)\s*\n\{([^}]*)\}',
            re.MULTILINE
        )
        structs = struct_pattern.findall(content)
        out.write(f'\n--- DLL_IMPORT Structs ({len(structs)}) ---\n')
        for sname, sbody in structs:
            out.write(f'\nstruct DLL_IMPORT {sname} {{\n')
            for member_line in sbody.strip().split('\n'):
                member_line = member_line.strip()
                if member_line and member_line != 'public:':
                    out.write(f'    {member_line}\n')
            out.write(f'}};\n')
        
        # 5. Class declarations with complete content
        out.write(f'\n--- Class Declarations ---\n')
        
        i = 0
        while i < len(lines):
            line = lines[i]
            # Match class declaration
            m = re.match(r'^class\s+DLL_IMPORT\s+(\w+)\s*:\s*public\s+(\w+)\s*$', line)
            if m:
                class_name = m.group(1)
                base_class = m.group(2)
                i += 1
                # Find opening brace
                while i < len(lines) and '{' not in lines[i]:
                    i += 1
                if i >= len(lines):
                    break
                
                brace_count = 1
                i += 1
                
                members = []
                virtuals = []
                methods = []
                access = 'public'
                
                while i < len(lines) and brace_count > 0:
                    cur = lines[i].strip()
                    if '{' in cur:
                        brace_count += cur.count('{')
                    if '}' in cur:
                        brace_count -= cur.count('}')
                    
                    if brace_count <= 0:
                        break
                    
                    if cur in ('public:', 'protected:', 'private:'):
                        access = cur.rstrip(':')
                    elif cur and not cur.startswith('//'):
                        if cur.startswith('virtual '):
                            virtuals.append((access, cur))
                        elif cur.startswith('static ') or cur.startswith('void ') or \
                             cur.startswith('INT ') or cur.startswith('FLOAT ') or \
                             cur.startswith('DWORD ') or cur.startswith('class ') and '(' in cur or \
                             'operator' in cur or cur.startswith('BYTE ') and '(' in cur or \
                             cur.startswith('bool ') and '(' in cur or \
                             '(' in cur and ');' in cur:
                            # It's a method
                            methods.append((access, cur))
                        else:
                            # It's a member variable
                            members.append((access, cur))
                    i += 1
                
                out.write(f'\nclass DLL_IMPORT {class_name} : public {base_class}\n{{\n')
                
                if members:
                    out.write(f'  // Member Variables:\n')
                    last_access = None
                    for acc, mem in members:
                        if acc != last_access:
                            out.write(f'  {acc}:\n')
                            last_access = acc
                        out.write(f'    {mem}\n')
                
                if virtuals:
                    out.write(f'  // Virtual Methods:\n')
                    for acc, v in virtuals:
                        out.write(f'    [{acc}] {v}\n')
                
                if methods:
                    out.write(f'  // Non-Virtual Methods:\n')
                    for acc, m in methods:
                        out.write(f'    [{acc}] {m}\n')
                
                out.write(f'}};\n')
            i += 1
        
        # 6. Exec/Event Parms structs (just names for reference)
        parm_structs = re.findall(
            r'^struct\s+((?:A|U)\w+_(?:exec|event)\w+_Parms)',
            content, re.MULTILINE
        )
        out.write(f'\n--- Exec/Event Parms Structs ({len(parm_structs)}) ---\n')
        for s in parm_structs:
            out.write(f'  {s}\n')

print(f'Output written to {output}')
