"""Fix VertexStream classes: remove NO_DEFAULT_CONSTRUCTOR, add explicit default 
constructor declarations. The out-of-line .cpp definitions will provide the bodies."""

PATH = r"c:\Users\danpo\Desktop\rvs\src\engine\EngineClasses.h"
CPP = r"c:\Users\danpo\Desktop\rvs\src\engine\EngineBatchImpl3.cpp"

with open(PATH, 'r') as f:
    content = f.read()

# Fix UVertexStreamBase: keep NO_DEFAULT_CONSTRUCTOR since its default ctor
# isn't exported (no stub for it)
# Already has: NO_DEFAULT_CONSTRUCTOR(UVertexStreamBase)

# Fix subclasses: replace NO_DEFAULT_CONSTRUCTOR with plain declaration
for cls in ['UVertexBuffer', 'UVertexStreamCOLOR', 'UVertexStreamPosNormTex', 'UVertexStreamUV', 'UVertexStreamVECTOR']:
    old = f'\tNO_DEFAULT_CONSTRUCTOR({cls})\n\t{cls}(DWORD InFlags);'
    new = f'\t{cls}();\n\t{cls}(DWORD InFlags);'
    if old in content:
        content = content.replace(old, new)
        print(f"Fixed header: {cls}")
    else:
        print(f"NOT FOUND in header: {cls}")

with open(PATH, 'w') as f:
    f.write(content)

# Add back default constructor out-of-line definitions in .cpp
with open(CPP, 'r') as f:
    cpp = f.read()

# Find the parameterized constructor for each and add default ctor before it
for cls in ['UVertexBuffer', 'UVertexStreamCOLOR', 'UVertexStreamPosNormTex', 'UVertexStreamUV', 'UVertexStreamVECTOR']:
    # Find the parameterized ctor line
    param_marker = f'{cls}::{cls}(DWORD'
    if param_marker in cpp:
        # Add default ctor line before the parameterized one
        default_ctor = f'{cls}::{cls}() {{}}\n'
        if default_ctor not in cpp:
            cpp = cpp.replace(param_marker, default_ctor + param_marker)
            print(f"Added default ctor to .cpp: {cls}")
        else:
            print(f"Default ctor already in .cpp: {cls}")
    else:
        print(f"Parameterized ctor not found in .cpp: {cls}")

with open(CPP, 'w') as f:
    f.write(cpp)

print("Done!")
