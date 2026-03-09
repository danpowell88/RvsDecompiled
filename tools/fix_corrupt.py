"""Fix the corrupted UVertexStreamBase declaration in EngineClasses.h."""

PATH = r"c:\Users\danpo\Desktop\rvs\src\engine\EngineClasses.h"

with open(PATH, 'r') as f:
    content = f.read()

# Fix the corrupted UVertexStreamBase
old = """\tDECLARE_CLASS(UVertexStreamBase,URenderResource,0,Engine)
\tNO_DEFAULT_CONSTRU) {}
\tUVertexStreamBase(CTOR(UVertexStreamBase)
\tUVertexStreamBase(INT InType, DWORD InStride, DWORD InFlags);"""

new = """\tDECLARE_CLASS(UVertexStreamBase,URenderResource,0,Engine)
\tNO_DEFAULT_CONSTRUCTOR(UVertexStreamBase)
\tUVertexStreamBase(INT InType, DWORD InStride, DWORD InFlags);"""

if old in content:
    content = content.replace(old, new)
    with open(PATH, 'w') as f:
        f.write(content)
    print("Fixed corrupted UVertexStreamBase")
else:
    print("Pattern not found!")
