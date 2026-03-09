"""Patch gen_impl4.py to add error-extracted skip list."""
import re

# The skip mangles from build errors
SKIP_MANGLES_SET = {
    '??0FDbgVectorInfo@@QAE@ABU0@@Z',
    '??0FDbgVectorInfo@@QAE@XZ',
    '??0FFontPage@@QAE@ABU0@@Z',
    '??0FInBunch@@QAE@ABV0@@Z',
    '??0FInBunch@@QAE@PAVUNetConnection@@@Z',
    '??0FMipmap@@QAE@ABU0@@Z',
    '??0FMirrorSceneNode@@QAE@PAVFLevelSceneNode@@VFPlane@@HH@Z',
    '??0FOutBunch@@QAE@ABV0@@Z',
    '??0FOutBunch@@QAE@PAVUChannel@@H@Z',
    '??0FOutBunch@@QAE@XZ',
    '??0FPointRegion@@QAE@PAVAZoneInfo@@@Z',
    '??0FPointRegion@@QAE@PAVAZoneInfo@@HE@Z',
    '??0FPointRegion@@QAE@XZ',
    '??0FRenderInterface@@QAE@ABV0@@Z',
    '??0FRenderInterface@@QAE@XZ',
    '??0FSkySceneNode@@QAE@PAVFLevelSceneNode@@H@Z',
    '??0FSortedPathList@@QAE@XZ',
    '??0FSoundData@@QAE@PAVUSound@@@Z',
    '??0FStaticMeshCollisionTriangle@@QAE@ABU0@@Z',
    '??0FStats@@QAE@ABV0@@Z',
    '??0FWarpZoneSceneNode@@QAE@PAVFLevelSceneNode@@PAVAWarpZoneInfo@@@Z',
    '??0HActor@@QAE@PAVAActor@@@Z',
    '??0HBspSurf@@QAE@H@Z',
    '??0HCoords@@QAE@PAVFCameraSceneNode@@@Z',
    '??0HMaterialTree@@QAE@PAVUMaterial@@K@Z',
    '??0HMatineeAction@@QAE@PAVASceneManager@@PAVUMatAction@@@Z',
    '??0HMatineeScene@@QAE@PAVASceneManager@@@Z',
    '??0HMatineeSubAction@@QAE@PAVUMatSubAction@@PAVUMatAction@@@Z',
    '??0HMatineeTimePath@@QAE@PAVASceneManager@@@Z',
    '??0HTerrain@@QAE@PAVATerrainInfo@@@Z',
    '??0HTerrainToolLayer@@QAE@PAVATerrainInfo@@HPAVUTexture@@@Z',
    '??0UDemoRecConnection@@QAE@PAVUNetDriver@@ABVFURL@@@Z',
    '??0UMeshInstance@@QAE@XZ',
    '??0UPackageMapLevel@@QAE@PAVUNetConnection@@@Z',
    '??0URenderResource@@QAE@XZ',
    '??0UTerrainPrimitive@@QAE@PAVATerrainInfo@@@Z',
    '??0UTerrainSector@@QAE@PAVATerrainInfo@@HHHH@Z',
    '??0UVertexBuffer@@QAE@K@Z',
    '??0UVertexStreamBase@@QAE@HKK@Z',
    '??0UVertexStreamCOLOR@@QAE@K@Z',
    '??0UVertexStreamPosNormTex@@QAE@K@Z',
    '??0UVertexStreamUV@@QAE@K@Z',
    '??0UVertexStreamVECTOR@@QAE@K@Z',
    '??1FDbgVectorInfo@@QAE@XZ',
    '??1FSoundData@@QAE@XZ',
    '??1FStaticMeshColorStream@@QAE@XZ',
    '??1FStats@@QAE@XZ',
    '??4FBspVertex@@QAEAAU0@ABU0@@Z',
    '??4FDXTCompressionOptions@@QAEAAU0@ABU0@@Z',
    '??4FDbgVectorInfo@@QAEAAU0@ABU0@@Z',
    '??4FFontCharacter@@QAEAAU0@ABU0@@Z',
    '??4FFontPage@@QAEAAU0@ABU0@@Z',
    '??4FInBunch@@QAEAAV0@ABV0@@Z',
    '??4FLevelSceneNode@@QAEAAV0@ABV0@@Z',
    '??4FRebuildOptions@@QAE?AV0@V0@@Z',
    '??4FRenderInterface@@QAEAAV0@ABV0@@Z',
    '??4FSceneNode@@QAEAAV0@ABV0@@Z',
    '??9FOrientation@@QBEHABU0@@Z',
    '?ClipPolygon@FConvexVolume@@QAE?AVFPoly@@V2@@Z',
    '?ClipPolygonPrecise@FConvexVolume@@QAE?AVFPoly@@V2@@Z',
    '?CreateChannel@UNetConnection@@QAEPAVUChannel@@W4EChannelType@@HH@Z',
    '?GetDefaultPhysicsVolume@ALevelInfo@@QAEPAVAPhysicsVolume@@XZ',
    '?GetDisplayAs@ALevelInfo@@QAE?AVFString@@V2@@Z',
    '?GetDriver@UDemoRecConnection@@QAEPAVUDemoRecDriver@@XZ',
    '?GetGlobalVertex@UTerrainSector@@QAEHHH@Z',
    '?GetHashLink@FCollisionHash@@QAEAAPAUFCollisionLink@1@HHHAAH@Z',
    '?GetInputAction@UInput@@QAE?AW4EInputAction@@XZ',
    '?GetInputDelta@UInput@@QAEMXZ',
    '?GetLocalVertex@UTerrainSector@@QAEHHH@Z',
    '?GetPeriod@FSoundData@@QAEMXZ',
    '?GetPhysicsVolume@ALevelInfo@@QAEPAVAPhysicsVolume@@VFVector@@PAVAActor@@H@Z',
    '?GetRenderBoundingBox@UTerrainPrimitive@@QAE?AVFBox@@PBVAActor@@H@Z',
    '?IsSectorAll@UTerrainSector@@QAEHHE@Z',
    '?IsSoundAudibleFromZone@ALevelInfo@@QAEHHH@Z',
    '?IsTriangleAll@UTerrainSector@@QAEHHHHHHE@Z',
    '?PassShouldRenderTriangle@UTerrainSector@@QAEHHHHHH@Z',
    '?ProcessR6Availabilty@AGameInfo@@SAXPAVULevel@@VFString@@@Z',
    '?RegisterStats@FStats@@QAEHW4EStatsType@@W4EStatsDataType@@VFString@@2W4EStatsUnit@@@Z',
    '?RemoveColinears@FPoly@@QAEHXZ',
    '?StaticInitInput@UInput@@SAXXZ',
}

# Read gen_impl4.py
with open('tools/gen_impl4.py') as f:
    content = f.read()

# Replace the empty SKIP_MANGLES set with the populated one
skip_set_str = "SKIP_MANGLES = {\n"
for s in sorted(SKIP_MANGLES_SET):
    skip_set_str += f"    '{s}',\n"
skip_set_str += "}"

content = content.replace("SKIP_MANGLES = set()", skip_set_str)

# Also remove redundant forward declarations that cause redefinition
# FDbgVectorInfo, FFontCharacter, FFontPage, FMipmapBase, FDXTCompressionOptions
# are now being skipped entirely, so remove their forward decls
for struct_name in ['FDbgVectorInfo', 'FFontCharacter', 'FFontPage', 'FMipmapBase', 
                    'FDXTCompressionOptions', 'FTerrainMaterialLayer']:
    content = re.sub(rf'struct {struct_name}\s+\{{[^}}]*\}};\n', '', content)

# Also remove the UChannel::ChannelClasses data def issue - it's an array not a pointer
# We need to skip it in data generation
# Add UChannel to SKIP_CLASSES  
content = content.replace(
    "'FColor',  # defined in Engine.h with inline methods",
    "'FColor',  # defined in Engine.h with inline methods\n    'FOrientation',  # forward-declared struct"
)

with open('tools/gen_impl4.py', 'w') as f:
    f.write(content)

print(f"Patched gen_impl4.py with {len(SKIP_MANGLES_SET)} skip mangles")
