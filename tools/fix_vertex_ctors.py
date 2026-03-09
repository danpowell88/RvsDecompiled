"""Fix VertexStream class declarations: use NO_DEFAULT_CONSTRUCTOR + only declare
parameterized constructors that match the stubs."""

PATH = r"c:\Users\danpo\Desktop\rvs\src\engine\EngineClasses.h"

with open(PATH, 'r') as f:
    content = f.read()

# Fix UVertexStreamBase - add NO_DEFAULT_CONSTRUCTOR, remove inline default ctor
content = content.replace(
    '\tDECLARE_CLASS(UVertexStreamBase,URenderResource,0,Engine)\n\tUVertexStreamBase() {}\n\tUVertexStreamBase(INT InType, DWORD InStride, DWORD InFlags);',
    '\tDECLARE_CLASS(UVertexStreamBase,URenderResource,0,Engine)\n\tNO_DEFAULT_CONSTRUCTOR(UVertexStreamBase)\n\tUVertexStreamBase(INT InType, DWORD InStride, DWORD InFlags);'
)

# Fix each subclass - add NO_DEFAULT_CONSTRUCTOR, remove explicit default ctor
for cls in ['UVertexBuffer', 'UVertexStreamCOLOR', 'UVertexStreamPosNormTex', 'UVertexStreamUV', 'UVertexStreamVECTOR']:
    base = 'UVertexStreamBase'
    old = f'\tDECLARE_CLASS({cls},{base},0,Engine)\n\t{cls}();\n\t{cls}(DWORD InFlags);'
    new = f'\tDECLARE_CLASS({cls},{base},0,Engine)\n\tNO_DEFAULT_CONSTRUCTOR({cls})\n\t{cls}(DWORD InFlags);'
    if old in content:
        content = content.replace(old, new)
        print(f"Fixed {cls}")
    else:
        print(f"NOT FOUND: {cls}")

with open(PATH, 'w') as f:
    f.write(content)

# Also fix the .cpp to remove default constructor out-of-line definitions
CPP = r"c:\Users\danpo\Desktop\rvs\src\engine\EngineBatchImpl3.cpp"
with open(CPP, 'r') as f:
    cpp = f.read()

for cls in ['UVertexBuffer', 'UVertexStreamCOLOR', 'UVertexStreamPosNormTex', 'UVertexStreamUV', 'UVertexStreamVECTOR']:
    old_line = f'{cls}::{cls}() {{}}\n'
    if old_line in cpp:
        cpp = cpp.replace(old_line, '')
        print(f"Removed default ctor from .cpp: {cls}")

with open(CPP, 'w') as f:
    f.write(cpp)

print("Done!")
