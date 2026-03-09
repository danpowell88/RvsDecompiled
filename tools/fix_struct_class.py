"""
Fix struct/class declarations to match retail game's mangled names.
Based on analysis of V/U mismatches between stubs and .obj symbols.
"""
import re

# Types that need to be changed TO STRUCT (our code has class, retail has struct)
NEEDS_STRUCT = [
    'FBspVertex', 'FFontPage', 'FFontCharacter', 'FMipmap', 'FMipmapBase',
    'FOrientation', 'FStaticMeshCollisionNode', 'FStaticMeshCollisionTriangle',
    'FStaticMeshTriangle', 'FStaticMeshUV', 'FStaticMeshVertex',
    'FTerrainMaterialLayer', 'FDXTCompressionOptions', 'MdtBaseConstraint',
]

# Types that need to be changed TO CLASS (our code has struct, retail has class)
NEEDS_CLASS = [
    'FPoly', 'FCollisionHash', 'FWaveModInfo', 'FBspNode', 'FBspSection',
    'FStaticMeshBatcherVertex', 'FStaticMeshLightInfo', 'FStaticMeshMaterial',
    'FStaticMeshSection', 'FTerrainVertexStream', 'FRebuildOptions',
    'FSpriteParticleVertex', 'MotionChunk',
]

import os

# Files to search
search_files = []
for root, dirs, files in os.walk('src/engine'):
    for f in files:
        if f.endswith(('.h', '.cpp')):
            search_files.append(os.path.join(root, f))

changes_made = []

for filepath in search_files:
    content = open(filepath).read()
    original = content
    
    # Fix types that need to be struct
    for typename in NEEDS_STRUCT:
        # Change "class TypeName" in forward declarations and member/param types
        # Careful: don't change class keyword when it's part of DECLARE_CLASS or other macros
        
        # Forward declarations: "class TypeName;" -> "struct TypeName;"
        pattern = r'\bclass\s+' + re.escape(typename) + r'\s*;'
        if re.search(pattern, content):
            content = re.sub(pattern, f'struct {typename};', content)
            changes_made.append((filepath, f"fwd decl class {typename} -> struct {typename}"))
        
        # Class definitions: "class TypeName {" or "class TypeName :" -> "struct TypeName"
        # But NOT "class ENGINE_API TypeName" - that's a different pattern
        pattern = r'\bclass\s+' + re.escape(typename) + r'\b(?!\s*\*|\s*&)'
        # Only change if it's NOT preceded by ENGINE_API or similar
        for m in re.finditer(pattern, content):
            # Check context - is this a definition/declaration, not a usage in a cast or template?
            start = m.start()
            # Check if ENGINE_API is between 'class' and typename
            snippet = content[max(0, start-30):start+len(m.group())+20]
            if 'ENGINE_API' in snippet:
                # class ENGINE_API TypeName -> struct ENGINE_API TypeName
                # Handle separately
                pass
            # Just do the replacement
        
        # Simple approach: replace "class TypeName" with "struct TypeName" everywhere
        # EXCEPT: "class TypeName::" (method definitions), template args, etc.
        # Actually, in C++ name mangling, what matters is how the type is DECLARED.
        # A forward declaration "class X;" makes ALL uses of X use class mangling.
        # So we just need to fix the original declaration/forward declaration.
        
    # Fix types that need to be class
    for typename in NEEDS_CLASS:
        pattern = r'\bstruct\s+' + re.escape(typename) + r'\s*;'
        if re.search(pattern, content):
            content = re.sub(pattern, f'class {typename};', content)
            changes_made.append((filepath, f"fwd decl struct {typename} -> class {typename}"))
    
    if content != original:
        open(filepath, 'w').write(content)
        print(f"Modified: {filepath}")

print(f"\nChanges made: {len(changes_made)}")
for filepath, desc in changes_made:
    print(f"  {filepath}: {desc}")

print("\n\nNOTE: This script only fixes forward declarations.")
print("You may also need to fix actual struct/class definitions in headers.")
print("Check EngineClasses.h and Engine.h for the actual type definitions.")
