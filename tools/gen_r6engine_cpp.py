"""
Generate R6Engine.cpp from the SDK header and .def file.
Generates IMPLEMENT_PACKAGE, NAMES_ONLY section, IMPLEMENT_CLASS calls,
IMPLEMENT_FUNCTION calls, and method stubs for all exported methods.
"""
import re

SDK_PATH = 'sdk/Raven_Shield_C_SDK/inc/R6EngineClasses.h'
DEF_PATH = 'src/r6engine/R6Engine.def'
HEADER_PATH = 'src/r6engine/R6EngineClasses.h'
OUTPUT_PATH = 'src/r6engine/R6Engine.cpp'

# Read the DEF file to get autoclass names and exec functions
with open(DEF_PATH, encoding='latin-1') as f:
    def_text = f.read()

autoclass_names = sorted(set(re.findall(r'autoclass(\w+)', def_text)))

# Get exec function registrations (from int exports)
exec_funcs = []
for m in re.finditer(r'int(\w+)(exec\w+)', def_text):
    cls = m.group(1)
    func = m.group(2)
    # The class name is embedded: e.g., intAR6PawnexecFootStep -> class=AR6Pawn, func=execFootStep
    # Need to split properly - find where 'exec' starts
    full = m.group(1) + m.group(2)
    exec_idx = full.find('exec')
    class_name = full[:exec_idx]
    func_name = full[exec_idx:]
    exec_funcs.append((class_name, func_name))

print(f"Autoclass: {len(autoclass_names)}")
print(f"Exec functions: {len(exec_funcs)}")

# Read the generated header to get class declarations and method signatures
with open(HEADER_PATH) as f:
    header_content = f.read()

# Parse all non-boilerplate exports from the .def
with open(DEF_PATH, encoding='latin-1') as f:
    def_lines = [l.strip() for l in f if l.strip() and not l.strip().startswith(';') and 'LIBRARY' not in l and 'EXPORTS' not in l]

# Extract demangled method exports
from collections import defaultdict
exported_methods = defaultdict(list)  # class -> list of (method, mangled)

for line in def_lines:
    # Skip boilerplate
    if any(k in line for k in ['autoclass', '??0', '??1', '??_7', '??4', '??2', 'GPackage', '_DllMain', 'PrivateStaticClass', 'InternalConstructor', '?StaticClass@', 'R6ENGINE_']):
        continue
    if line.startswith('int') and 'exec' in line:
        continue
    
    m = re.match(r'\?(\w+)@(\w+)@@(\w+)', line)
    if m:
        method = m.group(1)
        cls = m.group(2)
        signature = m.group(3)
        exported_methods[cls].append((method, line))

# Parse method signatures from the generated header
class_methods = {}  # class_name -> {method_name: signature_line}

current_class = None
in_class = False
for line in header_content.split('\n'):
    stripped = line.strip()
    m = re.match(r'class\s+R6ENGINE_API\s+(\w+)\s*:\s*public\s+(\w+)', stripped)
    if m:
        current_class = m.group(1)
        in_class = True
        class_methods[current_class] = {}
        continue
    if in_class and stripped == '};':
        in_class = False
        continue
    if in_class and current_class:
        # Extract method declarations
        if '(' in stripped and stripped.endswith(';'):
            # Get method name
            m2 = re.match(r'(?:virtual\s+)?(?:\w+\s+(?:\*\s*)?)+(\w+)\s*\(', stripped)
            if m2:
                mname = m2.group(1)
                class_methods[current_class][mname] = stripped.rstrip(';')

# ---- Generate the .cpp file ----

out = []
out.append("/*=============================================================================")
out.append("\tR6Engine.cpp: R6Engine package — core R6 game engine classes.")
out.append("\tReconstructed for Ravenshield decompilation project.")
out.append("")
out.append("\t50 classes, 1126 exports. Pawns, AI controllers, interactive objects,")
out.append("\tdeployment zones, doors, ragdolls, climbing, stairs, team management.")
out.append("=============================================================================*/")
out.append("")
out.append('#include "R6EnginePrivate.h"')
out.append("")
out.append("/*-----------------------------------------------------------------------------")
out.append("\tPackage.")
out.append("-----------------------------------------------------------------------------*/")
out.append("")
out.append("IMPLEMENT_PACKAGE(R6Engine)")
out.append("")
out.append("/*-----------------------------------------------------------------------------")
out.append("\tFName event/callback tokens.")
out.append("-----------------------------------------------------------------------------*/")
out.append("")
out.append("#define NAMES_ONLY")
out.append("#define AUTOGENERATE_NAME(name) R6ENGINE_API FName R6ENGINE_##name;")
out.append("#define AUTOGENERATE_FUNCTION(cls,idx,name) IMPLEMENT_FUNCTION(cls,idx,name)")
out.append('#include "R6EngineClasses.h"')
out.append("#undef AUTOGENERATE_FUNCTION")
out.append("#undef AUTOGENERATE_NAME")
out.append("#undef NAMES_ONLY")
out.append("")
out.append("/*-----------------------------------------------------------------------------")
out.append("\tIMPLEMENT_CLASS for all 50 exported classes.")
out.append("-----------------------------------------------------------------------------*/")
out.append("")

for cls in autoclass_names:
    out.append(f"IMPLEMENT_CLASS({cls})")

out.append("")
out.append("/*-----------------------------------------------------------------------------")
out.append("\tNative function exports (IMPLEMENT_FUNCTION).")
out.append("\tAll dispatched by name (INDEX_NONE / -1).")
out.append("-----------------------------------------------------------------------------*/")
out.append("")

for cls, func in exec_funcs:
    out.append(f"IMPLEMENT_FUNCTION({cls}, -1, {func})")

out.append("")
out.append("/*-----------------------------------------------------------------------------")
out.append("\tMethod stubs.")
out.append("\tReconstructed from retail .def exports — virtual overrides, events,")
out.append("\texec functions, and non-virtual exported methods.")
out.append("-----------------------------------------------------------------------------*/")
out.append("")

# For each class that has exported methods, generate stubs
# We need the method signatures from the header
# Group by class and generate

def get_return_default(sig):
    """Given a signature, return the default value for the return type."""
    sig = sig.strip()
    if sig.startswith('virtual '):
        sig = sig[8:]
    
    # Extract return type
    m = re.match(r'([\w\s\*&]+?)\s+\w+\s*\(', sig)
    if not m:
        return ''
    ret_type = m.group(1).strip()
    
    if ret_type == 'void':
        return None
    elif ret_type in ('INT', 'int', 'DWORD', 'BYTE'):
        return '0'
    elif ret_type in ('FLOAT', 'float'):
        return '0.f'
    elif ret_type == 'bool':
        return 'false'
    elif ret_type == 'FString':
        return 'TEXT("")'
    elif ret_type == 'FVector':
        return 'FVector(0,0,0)'
    elif ret_type == 'FRotator':
        return 'FRotator(0,0,0)'
    elif '*' in ret_type:
        return 'NULL'
    else:
        return '0'

def make_stub(cls_name, method_name, sig):
    """Generate a method stub."""
    lines = []
    
    # Clean signature
    clean_sig = sig.rstrip(';').strip()
    if clean_sig.startswith('virtual '):
        clean_sig = clean_sig[8:]
    
    # Build the qualified signature: ReturnType ClassName::MethodName(params)
    # Parse: "INT IsBlockedBy(AActor const*) const"
    m = re.match(r'([\w\s\*&]+?)\s+(\w+)\s*\((.*?)\)\s*(const)?', clean_sig)
    if not m:
        return []
    
    ret = m.group(1).strip()
    name = m.group(2)
    params = m.group(3).strip()
    const = m.group(4) or ''
    
    const_str = ' const' if const else ''
    
    # Build full signature
    full_sig = f"{ret} {cls_name}::{name}({params}){const_str}"
    
    ret_default = get_return_default(sig)
    
    lines.append(f"{full_sig}")
    lines.append("{")
    
    if ret_default is None:
        # void return - try calling Super:: for virtual overrides
        lines.append("}")
    elif ret_default == '0' and ret in ('INT', 'int', 'DWORD', 'BYTE'):
        lines.append(f"\treturn {ret_default};")
        lines.append("}")
    else:
        lines.append(f"\treturn {ret_default};")
        lines.append("}")
    
    return lines

def make_event_stub(cls_name, method_name, sig):
    """Generate an event method stub (delegates to UnrealScript via ProcessEvent)."""
    lines = []
    clean_sig = sig.rstrip(';').strip()
    
    # Parse: "RetType eventName(params)"
    m = re.match(r'([\w\s\*&]+?)\s+(event\w+)\s*\((.*?)\)', clean_sig)
    if not m:
        return []
    
    ret = m.group(1).strip()
    name = m.group(2)
    params = m.group(3).strip()
    
    # The FName for event lookup uses the name without 'event' prefix
    event_name = name[5:]  # strip 'event'
    fname_var = f"R6ENGINE_{event_name}"
    
    full_sig = f"{ret} {cls_name}::{name}({params})"
    
    if ret == 'void' and not params:
        lines.append(f"{full_sig}")
        lines.append("{")
        lines.append(f"\tProcessEvent(FindFunctionChecked({fname_var}), NULL);")
        lines.append("}")
    elif ret == 'void' and params:
        # Build Parms struct
        lines.append(f"{full_sig}")
        lines.append("{")
        # Parse params
        param_list = [p.strip() for p in params.split(',') if p.strip()]
        lines.append("\tstruct { ")
        for p in param_list:
            lines.append(f"\t\t{p};")
        lines.append("\t} Parms;")
        # Assign params
        for p in param_list:
            # Extract param name (last word)
            parts = p.strip().split()
            pname = parts[-1].lstrip('*&')
            lines.append(f"\tParms.{pname} = {pname};")
        lines.append(f"\tProcessEvent(FindFunctionChecked({fname_var}), &Parms);")
        lines.append("}")
    else:
        # Has return value
        lines.append(f"{full_sig}")
        lines.append("{")
        param_list = [p.strip() for p in params.split(',') if p.strip()] if params else []
        ret_default = get_return_default(f"{ret} x()")
        lines.append("\tstruct {")
        for p in param_list:
            lines.append(f"\t\t{p};")
        lines.append(f"\t\t{ret} ReturnValue;")
        lines.append("\t} Parms;")
        if ret_default is not None:
            lines.append(f"\tParms.ReturnValue = {ret_default};")
        for p in param_list:
            parts = p.strip().split()
            pname = parts[-1].lstrip('*&')
            lines.append(f"\tParms.{pname} = {pname};")
        lines.append(f"\tProcessEvent(FindFunctionChecked({fname_var}), &Parms);")
        lines.append("\treturn Parms.ReturnValue;")
        lines.append("}")
    
    return lines

def make_exec_stub(cls_name, func_name):
    """Generate an exec function stub."""
    return [
        f"void {cls_name}::{func_name}(FFrame& Stack, RESULT_DECL)",
        "{",
        "\tP_FINISH;",
        "}"
    ]

# Process each class
for cls_name in sorted(exported_methods.keys()):
    methods = exported_methods[cls_name]
    
    # Skip special entries
    if cls_name.startswith('_') or cls_name.startswith('?'):
        continue
    
    cls_sigs = class_methods.get(cls_name, {})
    
    out.append(f"// --- {cls_name} ---")
    out.append("")
    
    for method_name, mangled in methods:
        if method_name in cls_sigs:
            sig = cls_sigs[method_name]
            
            if method_name.startswith('event'):
                stub = make_event_stub(cls_name, method_name, sig)
            elif method_name.startswith('exec') and 'FFrame' in sig:
                stub = make_exec_stub(cls_name, method_name)
            else:
                stub = make_stub(cls_name, method_name, sig)
            
            if stub:
                out.extend(stub)
                out.append("")
        elif method_name.startswith('exec'):
            # Exec function not found in header sigs - generate basic stub
            stub = make_exec_stub(cls_name, method_name)
            out.extend(stub)
            out.append("")
        elif method_name.startswith('m_'):
            # This is a data member export (e.g., m_stKillChart), not a method
            # Skip - these are exported as data symbols
            pass
        else:
            out.append(f"// TODO: {cls_name}::{method_name} — signature not found in header")
            out.append("")

out.append("/*-----------------------------------------------------------------------------")
out.append("\tThe End.")
out.append("-----------------------------------------------------------------------------*/")

with open(OUTPUT_PATH, 'w') as f:
    f.write('\n'.join(out) + '\n')

print(f"\nGenerated {OUTPUT_PATH}")
print(f"Output lines: {len(out)}")
