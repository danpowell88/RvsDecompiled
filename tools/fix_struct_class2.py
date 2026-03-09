"""
Fix struct/class declarations to match retail game's export mangling.
This changes the keyword for type declarations/definitions in headers and forward decls.
"""
import re

# === CHANGES TO EngineDecls.h ===
# These are all "class ENGINE_API X" that need to become "struct ENGINE_API X"
# (retail had them as struct)
filepath = 'src/engine/EngineDecls.h'
content = open(filepath).read()
original = content

DECLS_TO_STRUCT = [
    'FBspVertex', 'FFontPage', 'FFontCharacter', 'FMipmap', 'FMipmapBase',
    'FOrientation', 'FStaticMeshCollisionNode', 'FStaticMeshCollisionTriangle',
    'FStaticMeshTriangle', 'FStaticMeshUV', 'FStaticMeshVertex',
    'FTerrainMaterialLayer', 'FDXTCompressionOptions',
]

for typename in DECLS_TO_STRUCT:
    old = f'class ENGINE_API {typename}'
    new = f'struct ENGINE_API {typename}'
    if old in content:
        content = content.replace(old, new, 1)
        # Remove "public:" that immediately follows the opening brace since struct is public by default
        # Pattern: "struct ENGINE_API TypeName { public:" -> "struct ENGINE_API TypeName {"
        # Or the public: might be on the next line
        content = re.sub(
            r'(struct ENGINE_API ' + re.escape(typename) + r'\s*\{)\s*public:',
            r'\1', content)
        print(f"EngineDecls.h: class ENGINE_API {typename} -> struct")

if content != original:
    open(filepath, 'w').write(content)
    print(f"  Written {filepath}")

# === CHANGES TO EngineClasses.h ===
filepath = 'src/engine/EngineClasses.h'
content = open(filepath).read()
original = content

# Forward decl changes
fwd_changes = {
    # class -> struct
    'class FOrientation': 'struct FOrientation',
    'class MdtBaseConstraint': 'struct MdtBaseConstraint',
    # struct -> class
    'struct FRebuildOptions;': 'class FRebuildOptions;',
    'struct FSpriteParticleVertex;': 'class FSpriteParticleVertex;',
    'struct MotionChunk;': 'class MotionChunk;',
}
for old, new in fwd_changes.items():
    if old in content:
        content = content.replace(old, new, 1)
        print(f"EngineClasses.h: {old} -> {new}")

# struct ENGINE_API FPoly -> class ENGINE_API FPoly
# Need to add public: after opening brace
if 'struct ENGINE_API FPoly' in content:
    content = content.replace('struct ENGINE_API FPoly', 'class ENGINE_API FPoly', 1)
    # Add public: after opening brace
    idx = content.find('class ENGINE_API FPoly')
    brace = content.find('{', idx)
    if brace > 0:
        # Check if there's already a public: after the brace
        after_brace = content[brace+1:brace+30].strip()
        if not after_brace.startswith('public:'):
            content = content[:brace+1] + '\npublic:\n' + content[brace+1:]
    print("EngineClasses.h: struct ENGINE_API FPoly -> class (added public:)")

# struct ENGINE_API FCollisionHash -> class ENGINE_API FCollisionHash
if 'struct ENGINE_API FCollisionHash' in content:
    content = content.replace('struct ENGINE_API FCollisionHash', 'class ENGINE_API FCollisionHash', 1)
    idx = content.find('class ENGINE_API FCollisionHash')
    brace = content.find('{', idx)
    if brace > 0:
        after_brace = content[brace+1:brace+30].strip()
        if not after_brace.startswith('public:'):
            content = content[:brace+1] + '\npublic:\n' + content[brace+1:]
    print("EngineClasses.h: struct ENGINE_API FCollisionHash -> class (added public:)")

# struct ENGINE_API FWaveModInfo -> class ENGINE_API FWaveModInfo
if 'struct ENGINE_API FWaveModInfo' in content:
    content = content.replace('struct ENGINE_API FWaveModInfo', 'class ENGINE_API FWaveModInfo', 1)
    idx = content.find('class ENGINE_API FWaveModInfo')
    brace = content.find('{', idx)
    if brace > 0:
        after_brace = content[brace+1:brace+30].strip()
        if not after_brace.startswith('public:'):
            content = content[:brace+1] + '\npublic:\n' + content[brace+1:]
    print("EngineClasses.h: struct ENGINE_API FWaveModInfo -> class (added public:)")

if content != original:
    open(filepath, 'w').write(content)
    print(f"  Written {filepath}")

# === CHANGES TO EngineBatchImpl3.cpp ===
filepath = 'src/engine/EngineBatchImpl3.cpp'
content = open(filepath).read()
original = content

# Forward declarations that need struct -> class
IMPL3_TO_CLASS = [
    'FBspNode', 'FBspSection', 'FStaticMeshBatcherVertex', 'FStaticMeshLightInfo',
    'FStaticMeshMaterial', 'FStaticMeshSection', 'FTerrainVertexStream',
]

for typename in IMPL3_TO_CLASS:
    old = f'struct {typename};'
    new = f'class {typename};'
    if old in content:
        content = content.replace(old, new, 1)
        print(f"EngineBatchImpl3.cpp: struct {typename}; -> class {typename};")

# FRebuildOptions definition line
if 'struct FRebuildOptions' in content:
    content = content.replace('struct FRebuildOptions', 'class FRebuildOptions', 1)
    # Add public: if it has a brace
    idx = content.find('class FRebuildOptions')
    brace = content.find('{', idx)
    if brace > 0 and brace < idx + 100:
        after_brace = content[brace+1:brace+30].strip()
        if not after_brace.startswith('public:'):
            content = content[:brace+1] + ' public: ' + content[brace+1:]
    print("EngineBatchImpl3.cpp: struct FRebuildOptions -> class")

# FOrientation is already struct in EngineBatchImpl3.cpp (OK)
# MdtBaseConstraint forward decl
if 'struct _KarmaGlobals; struct _McdGeometry;' in content:
    # Check if MdtBaseConstraint is forward declared here
    pass

# Check for MdtBaseConstraint
if 'class MdtBaseConstraint' in content:
    content = content.replace('class MdtBaseConstraint', 'struct MdtBaseConstraint', 1)
    print("EngineBatchImpl3.cpp: class MdtBaseConstraint -> struct")

if content != original:
    open(filepath, 'w').write(content)
    print(f"  Written {filepath}")

print("\nDone! Build and verify.")
