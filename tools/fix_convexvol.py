"""Fix FConvexVolume in EngineClasses.h - add missing { and }; brackets"""
import re

path = r'c:\Users\danpo\Desktop\rvs\src\engine\EngineClasses.h'
with open(path, 'r') as f:
    content = f.read()

# Fix 1: Replace "class ENGINE_API FConvexVolume;\npublic:" with "class ENGINE_API FConvexVolume {\npublic:"
old = 'class ENGINE_API FConvexVolume;\npublic:'
new = 'class ENGINE_API FConvexVolume {\npublic:'
assert old in content, "Cannot find FConvexVolume; pattern"
content = content.replace(old, new, 1)

# Fix 2: Add closing }; after FPoly ClipPolygonPrecise(FPoly);
old2 = '\tFPoly ClipPolygonPrecise(FPoly);\n\nclass FVisibilityInterface;'
new2 = '\tFPoly ClipPolygonPrecise(FPoly);\n};\nclass FVisibilityInterface;'
assert old2 in content, "Cannot find ClipPolygonPrecise pattern"
content = content.replace(old2, new2, 1)

with open(path, 'w') as f:
    f.write(content)

print("Fixed FConvexVolume brackets in EngineClasses.h")
