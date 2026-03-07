"""
Generate R6EngineClasses.h from the SDK header.
Strips exec/event Parms structs, replaces DLL_IMPORT with R6ENGINE_API,
removes IMPLEMENT_CLASS boilerplate, adds DECLARE_CLASS macro.
"""
import re
import sys

SDK_PATH = 'sdk/Raven_Shield_C_SDK/inc/R6EngineClasses.h'
DEF_PATH = 'src/r6engine/R6Engine.def'
OUTPUT_PATH = 'src/r6engine/R6EngineClasses.h'

# Read input files
with open(SDK_PATH, encoding='latin-1') as f:
    sdk_lines = f.readlines()

with open(DEF_PATH, encoding='latin-1') as f:
    def_text = f.read()

autoclass_names = set(re.findall(r'autoclass(\w+)', def_text))
print(f"Autoclass classes: {len(autoclass_names)}")

# ---- Phase 1: Parse the SDK header into sections ----

sections = []  # list of (type, content) tuples
# Types: 'preamble', 'autogenerate', 'struct_parms', 'struct_normal', 'enum', 'class', 'other'

i = 0
total = len(sdk_lines)

def skip_block(start_idx, lines):
    """Skip a {} block starting from a line containing or preceding {, return index after closing }."""
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

# Collect lines before #ifndef NAMES_ONLY as preamble
preamble_end = 0
for j, line in enumerate(sdk_lines):
    if 'AUTOGENERATE_NAME' in line and not line.strip().startswith('//') and not line.strip().startswith('#'):
        preamble_end = j
        break

# Find all AUTOGENERATE_NAME lines
autogen_lines = []
for j, line in enumerate(sdk_lines):
    if line.strip().startswith('AUTOGENERATE_NAME'):
        autogen_lines.append(line)

# ---- Phase 2: Extract classes ----

class ClassInfo:
    def __init__(self, name, base, lines_raw, start_line):
        self.name = name
        self.base = base
        self.lines_raw = lines_raw  # list of raw lines
        self.start_line = start_line
        self.is_autoclass = name in autoclass_names
        self.members = []
        self.virtuals = []
        self.events = []
        self.execs = []
        self.other_methods = []

classes = []
structs_normal = []
enums = []

i = 0
while i < total:
    line = sdk_lines[i]
    stripped = line.strip()
    
    # Skip exec/event Parms structs
    if re.match(r'struct\s+\w+_(exec|event)\w+_Parms', stripped):
        end = skip_block(i, sdk_lines)
        i = end
        continue
    
    # Normal struct (not Parms)
    m_struct = re.match(r'struct\s+(?:DLL_IMPORT\s+)?(\w+)', stripped)
    if m_struct and not stripped.startswith('//') and '{' not in stripped:
        # Multi-line struct
        struct_lines = []
        while i < total:
            struct_lines.append(sdk_lines[i])
            if '};' in sdk_lines[i]:
                break
            i += 1
        structs_normal.append((''.join(struct_lines), m_struct.group(1)))
        i += 1
        continue
    elif m_struct and '{' in stripped:
        struct_lines = []
        end = skip_block(i, sdk_lines)
        for j in range(i, end):
            struct_lines.append(sdk_lines[j])
        structs_normal.append((''.join(struct_lines), m_struct.group(1)))
        i = end
        continue
    
    # Enum
    if stripped.startswith('enum ') and '{' in stripped:
        enum_lines = []
        end = skip_block(i, sdk_lines)
        for j in range(i, end):
            enum_lines.append(sdk_lines[j])
        enums.append(''.join(enum_lines))
        i = end
        continue
    
    # Class
    m_class = re.match(r'class\s+(?:DLL_IMPORT\s+)?(\w+)\s*:\s*public\s+(\w+)', stripped)
    if m_class:
        class_name = m_class.group(1)
        base_name = m_class.group(2)
        class_lines = []
        end = skip_block(i, sdk_lines)
        for j in range(i, end):
            class_lines.append(sdk_lines[j])
        classes.append(ClassInfo(class_name, base_name, class_lines, i))
        i = end
        continue
    
    i += 1

print(f"Classes found: {len(classes)}")
print(f"Normal structs: {len(structs_normal)}")
print(f"Enums: {len(enums)}")
print(f"AUTOGENERATE_NAME entries: {len(autogen_lines)}")

# ---- Phase 3: Process each class ----

def process_class(cls):
    """Extract members, virtuals, and other methods from raw class lines."""
    members = []
    virtuals = []
    events = []
    execs = []
    other_methods = []
    
    for line in cls.lines_raw[1:]:  # skip class declaration line
        stripped = line.strip()
        
        # Remove trailing comments (SDK has //CPF_Edit etc.)
        code = re.sub(r'\s*//.*$', '', stripped).strip()
        
        # Skip boilerplate
        if any(k in code for k in [
            'InternalConstructor', 'PrivateStaticClass', 
            'operator new', 'operator=',
        ]):
            continue
        if code.startswith('static class UClass * CDECL StaticClass'):
            continue
        if code.startswith('static class UClass PrivateStaticClass'):
            continue
        if code.startswith('static void CDECL InternalConstructor'):
            continue
        
        # Skip copy constructor
        if re.match(r'\w+\s*\(\s*class\s+\w+\s+const\s*&\s*\)', code):
            continue
        
        # Skip default constructor (we'll add protected one)
        if re.match(r'^' + re.escape(cls.name) + r'\s*\(\s*\)\s*;?$', code):
            continue
        
        # Skip destructor
        if re.match(r'virtual\s+~' + re.escape(cls.name), code):
            continue
            
        # Skip access specifiers and braces
        if code in ['public:', 'protected:', 'private:', '{', '};', '']:
            continue
        if code.startswith('//'):
            continue
            
        # Virtual methods
        if code.startswith('virtual '):
            virtuals.append(code.rstrip(';').strip())
            continue
        
        # Event methods  
        if re.match(r'(?:void|FLOAT|INT|BYTE|BITFIELD|FString|FVector|FRotator)\s+event\w+\s*\(', code):
            events.append(code.rstrip(';').strip())
            continue
        
        # Exec methods
        if 'exec' in code and 'FFrame' in code:
            execs.append(code.rstrip(';').strip())
            continue
        
        # Member variables (end with ; and don't have parentheses)
        if code.endswith(';') and '(' not in code:
            clean = code.rstrip(';').strip() + ';'
            if clean and clean != ';':
                members.append(clean)
            continue
        
        # Other methods (non-virtual, non-event, non-exec, non-static)
        if '(' in code and code.endswith(';') and not code.startswith('static'):
            other_methods.append(code.rstrip(';').strip())
            continue
    
    cls.members = members
    cls.virtuals = virtuals
    cls.events = events
    cls.execs = execs
    cls.other_methods = other_methods

for cls in classes:
    process_class(cls)

# ---- Phase 4: Generate output ----

out = []
out.append("/*=============================================================================")
out.append("\tR6EngineClasses.h: R6Engine class declarations.")
out.append("\tReconstructed from Ravenshield 1.56 SDK and Ghidra analysis.")
out.append("")
out.append("\t50 classes: Core game engine — pawns, AI, interactive objects,")
out.append("\tdeployment zones, doors, ragdolls, climbing, stairs, team management.")
out.append("=============================================================================*/")
out.append("")
out.append("#if _MSC_VER")
out.append("#pragma pack(push, 4)")
out.append("#endif")
out.append("")
out.append("#ifndef R6ENGINE_API")
out.append("#define R6ENGINE_API DLL_IMPORT")
out.append("#endif")
out.append("")
out.append("/*==========================================================================")
out.append("\tAUTOGENERATE_NAME / AUTOGENERATE_FUNCTION entries.")
out.append("==========================================================================*/")
out.append("")
out.append("#ifndef NAMES_ONLY")
out.append("#define AUTOGENERATE_NAME(name) extern R6ENGINE_API FName R6ENGINE_##name;")
out.append("#define AUTOGENERATE_FUNCTION(cls,idx,name)")
out.append("#endif")
out.append("")

for line in autogen_lines:
    out.append(line.rstrip())

out.append("")
out.append("#ifndef NAMES_ONLY")
out.append("")

# Forward declarations
out.append("/*==========================================================================")
out.append("\tForward declarations.")
out.append("==========================================================================*/")
out.append("")

# Collect all class names referenced
all_class_names = set(c.name for c in classes)
# Add forward declarations for non-autoclass classes that might be referenced
forward_decls = set()
for cls in classes:
    for member in cls.members:
        # Find class* references
        refs = re.findall(r'class\s+(\w+)\s*\*', member)
        for ref in refs:
            if ref not in all_class_names and ref not in ['FVector', 'FRotator', 'FString', 'FName', 'FColor', 'AActor', 'APawn', 'UObject', 'UClass', 'UTexture', 'USound', 'UStaticMesh', 'UFont', 'AEmitter', 'APlayerController', 'ALevelInfo', 'ANavigationPoint', 'AVolume', 'UPackageMap', 'UActorChannel']:
                forward_decls.add(ref)

# Known forward declarations we need
forward_decls.update([
    'AR6Weapons', 'AR6Bullet', 'AR6Gadget', 'AR6Reticule',
    'AR6AbstractBulletManager', 'AR6AbstractGadget',
    'AR6MissionObjectiveMgr', 'UR6MissionObjectiveBase', 'UR6MissionDescription',
    'UR6AbstractNoiseMgr', 'UR6AbstractGameService',
    'AR6AbstractWeapon', 'AR6AbstractFirstPersonWeapon',
])

for decl in sorted(forward_decls):
    if decl.startswith('U'):
        out.append(f"class {decl};")
    else:
        out.append(f"class {decl};")
out.append("")

# Enums
if enums:
    out.append("/*==========================================================================")
    out.append("\tEnums.")
    out.append("==========================================================================*/")
    out.append("")
    for enum_text in enums:
        out.append(enum_text.rstrip())
        out.append("")

# Structs (non-Parms)
if structs_normal:
    out.append("/*==========================================================================")
    out.append("\tStructs.")
    out.append("==========================================================================*/")
    out.append("")
    for struct_text, struct_name in structs_normal:
        # Replace DLL_IMPORT with nothing (structs don't need API linkage for compilation)
        clean = struct_text.replace('DLL_IMPORT ', '')
        # Remove trailing comments  
        clean = re.sub(r'\s*//CPF_\w+(\|\w+)*', '', clean)
        clean = re.sub(r'\s*//0\s*$', '', clean, flags=re.MULTILINE)
        out.append(clean.rstrip())
        out.append("")

# Classes - need to output in dependency order
# Build dependency graph
class_by_name = {c.name: c for c in classes}
output_classes = set()

def output_class(cls, out_lines):
    if cls.name in output_classes:
        return
    # Output base class first if it's in our set
    if cls.base in class_by_name and cls.base not in output_classes:
        output_class(class_by_name[cls.base], out_lines)
    
    output_classes.add(cls.name)
    
    out_lines.append("/*==========================================================================")
    out_lines.append(f"\t{cls.name}")
    out_lines.append("==========================================================================*/")
    out_lines.append("")
    
    if cls.is_autoclass:
        out_lines.append(f"class R6ENGINE_API {cls.name} : public {cls.base}")
    else:
        # Non-autoclass classes still need to be declared for inheritance
        out_lines.append(f"class R6ENGINE_API {cls.name} : public {cls.base}")
    
    out_lines.append("{")
    out_lines.append("public:")
    
    if cls.is_autoclass:
        out_lines.append(f"\tDECLARE_CLASS({cls.name}, {cls.base}, 0, R6Engine)")
        out_lines.append("")
    
    # Members
    for member in cls.members:
        # Clean up 'class ' prefix on types that don't need it
        clean = member
        clean = re.sub(r'class\s+(FVector|FRotator|FString|FName|FColor)\b', r'\1', clean)
        clean = re.sub(r'class\s+', '', clean)  # Remove remaining 'class ' prefixes
        clean = re.sub(r'struct\s+', '', clean)  # Remove 'struct ' prefixes
        out_lines.append(f"\t{clean}")
    
    if cls.members:
        out_lines.append("")
    
    # Virtual methods
    for virt in cls.virtuals:
        clean = virt
        clean = re.sub(r'class\s+(FVector|FRotator|FString|FName|FColor)\b', r'\1', clean)
        clean = re.sub(r'class\s+', '', clean)
        out_lines.append(f"\t{clean};")
    
    # Events
    for ev in cls.events:
        clean = ev
        clean = re.sub(r'class\s+(FVector|FRotator|FString|FName|FColor)\b', r'\1', clean)
        clean = re.sub(r'class\s+', '', clean)
        out_lines.append(f"\t{clean};")
    
    # Execs
    for ex in cls.execs:
        clean = ex
        out_lines.append(f"\t{clean};")
    
    # Other methods
    for meth in cls.other_methods:
        clean = meth
        clean = re.sub(r'class\s+(FVector|FRotator|FString|FName|FColor)\b', r'\1', clean)
        clean = re.sub(r'class\s+', '', clean)
        out_lines.append(f"\t{clean};")
    
    out_lines.append("")
    out_lines.append("protected:")
    out_lines.append(f"\t{cls.name}() {{}}")
    out_lines.append("};")
    out_lines.append("")

# Output classes in order, respecting dependencies
for cls in classes:
    output_class(cls, out)

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

# Write output
with open(OUTPUT_PATH, 'w') as f:
    f.write('\n'.join(out) + '\n')

print(f"\nGenerated {OUTPUT_PATH}")
print(f"Output lines: {len(out)}")
print(f"Autoclass classes output: {len([c for c in classes if c.is_autoclass])}")
print(f"Non-autoclass classes output: {len([c for c in classes if not c.is_autoclass])}")
