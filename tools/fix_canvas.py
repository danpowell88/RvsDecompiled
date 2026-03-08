"""Fix corrupted UCanvas class definition in EngineClasses.h"""
import re

f = r'c:\Users\danpo\Desktop\rvs\src\engine\EngineClasses.h'
with open(f, 'r', encoding='utf-8') as fh:
    lines = fh.readlines()

# Find UCanvas start
canvas_start = None
for i, line in enumerate(lines):
    if 'class ENGINE_API UCanvas : public UObject' in line:
        canvas_start = i
        break

if canvas_start is None:
    print("UCanvas not found!")
    exit(1)

print(f"UCanvas starts at line {canvas_start + 1}")

# Find the corrupted m_bDisplayGam line
corrupt_start = None
for i in range(canvas_start, min(canvas_start + 100, len(lines))):
    if 'm_bDisplayGam' in lines[i]:
        corrupt_start = i
        break

if corrupt_start is None:
    print("Corrupted line not found!")
    exit(1)

print(f"Corrupted section starts at line {corrupt_start + 1}")

# Find the next class definition after UCanvas (to find where it should end)
# Look for the closing of UCanvas which should be before the next class
canvas_end = None
for i in range(corrupt_start, min(corrupt_start + 100, len(lines))):
    stripped = lines[i].strip()
    if stripped == '};' and i > corrupt_start + 5:
        # Check if the next non-empty line starts a new class or comment block
        canvas_end = i
        break

# Actually, let's find where the correct UCanvas should end
# by looking for the next "class ENGINE_API" 
next_class = None
for i in range(corrupt_start, min(corrupt_start + 100, len(lines))):
    if 'class ENGINE_API' in lines[i] and i > corrupt_start:
        next_class = i
        break

print(f"Next class at line {next_class + 1 if next_class else 'not found'}")

# Print the corrupted region
for j in range(corrupt_start, min(canvas_end + 2 if canvas_end else next_class, len(lines))):
    print(f"  {j+1}: {lines[j].rstrip()[:80]}")

# Build the replacement block
replacement_lines = [
    '\tBITFIELD m_bDisplayGameOutroVideo : 1;\n',
    '\tBITFIELD m_bChangeResRequested : 1;\n',
    '\tINT m_iNewResolutionX;\n',
    '\tINT m_iNewResolutionY;\n',
    '\tBITFIELD m_bFading : 1;\n',
    '\tBITFIELD m_bFadeAutoStop : 1;\n',
    '\tFColor m_FadeStartColor;\n',
    '\tFColor m_FadeEndColor;\n',
    '\tFLOAT m_fFadeTotalTime;\n',
    '\tFLOAT m_fFadeCurrentTime;\n',
    '\tclass UMaterial* m_pWritableMapIconsTexture;\n',
    '\n',
    '\t// Non-virtual methods\n',
    '\tvoid SetVirtualSize(FLOAT, FLOAT);\n',
    '\tvoid StartFade(FColor, FColor, FLOAT, INT);\n',
    '\tvoid UseVirtualSize(INT, FLOAT, FLOAT);\n',
    '\tvoid SetStretch(FLOAT, FLOAT);\n',
    '\tvoid DrawTileClipped(UMaterial*, FLOAT, FLOAT, FLOAT, FLOAT, FLOAT, FLOAT);\n',
    '\n',
    '\t// Virtual methods\n',
    '\tvirtual void DrawTile(UMaterial*, FLOAT, FLOAT, FLOAT, FLOAT, FLOAT, FLOAT, FLOAT, FLOAT, FLOAT, FPlane, FPlane, FLOAT);\n',
    '\tvirtual void DrawIcon(UMaterial*, FLOAT, FLOAT, FLOAT, FLOAT, FLOAT, FPlane, FPlane);\n',
    '\tvirtual void DrawPattern(UMaterial*, FLOAT, FLOAT, FLOAT, FLOAT, FLOAT, FLOAT, FLOAT, FLOAT, FPlane, FPlane);\n',
    '\tvirtual INT _DrawString(class UFont*, INT, INT, const TCHAR*, FPlane, INT, INT, INT);\n',
    '\tvirtual void WrappedDrawString(ERenderStyle, INT&, INT&, class UFont*, INT, const TCHAR*);\n',
    '\tvirtual void WrappedStrLenf(class UFont*, INT&, INT&, const TCHAR*, ...);\n',
    '\tvirtual void WrappedPrintf(class UFont*, INT, const TCHAR*, ...);\n',
    '\tvirtual void SetClip(INT, INT, INT, INT);\n',
    '\n',
    '\t// Virtual interface stubs defined in UnRender.cpp.\n',
    '\tvirtual void Init( class UViewport* InViewport );\n',
    '\tvirtual void Update();\n',
    '};\n',
]

# Find the end of the corrupted UCanvas section
# It should end where we see a line that's part of the next construct
# Looking at the content: after the private section there are lines like:
# 'public:eOutroVideo : 1;' which is garbled
# Then BITFIELD m_bChangeResRequested : 1; etc which are legit but misplaced
# Then virtual void Init and Update which belong in UCanvas
# Then the closing };

# Find the }; that closes UCanvas
end_idx = None
brace_depth = 0
for i in range(canvas_start, min(canvas_start + 150, len(lines))):
    if '{' in lines[i]:
        brace_depth += lines[i].count('{')
    if '}' in lines[i]:
        brace_depth -= lines[i].count('}')
    if brace_depth == 0 and i > canvas_start and '};' in lines[i]:
        end_idx = i
        break

print(f"UCanvas closes at line {end_idx + 1 if end_idx else 'not found'}")

if end_idx:
    # Replace from corrupt_start to end_idx (inclusive) with replacement_lines
    new_lines = lines[:corrupt_start] + replacement_lines + lines[end_idx + 1:]
    
    with open(f, 'w', encoding='utf-8') as fh:
        fh.writelines(new_lines)
    print(f"Fixed! Old:{len(lines)} New:{len(new_lines)}")
else:
    print("Could not find UCanvas closing brace!")
