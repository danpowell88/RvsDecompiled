"""Find current trivial implementations to understand the pattern."""
import re

targets = [
    'FBspVertex::operator=', 'FFontPage::operator=', 'FMipmap::operator=', 'FMipmapBase::operator=',
    'FOrientation::operator=', 'FPoly::operator=', 'FCollisionHash::operator=', 
    'FRebuildOptions::operator=', 'FStaticMeshCollisionNode::operator=',
    'FStaticMeshCollisionTriangle::operator=', 'FStaticMeshTriangle::operator=',
    'FStaticMeshUV::operator=', 'FStaticMeshVertex::operator=', 'FTerrainMaterialLayer::operator=',
    'FWaveModInfo::operator=', 'FDXTCompressionOptions::operator=', 'FFontCharacter::operator=',
    'FPoly::SplitInHalf', 'FPoly::SplitWithNode', 'FPoly::Faces', 'FPoly::IsCoplanar',
    'FPoly::SplitWithPlane', 'FPoly::SplitWithPlaneFast', 'FPoly::SplitWithPlaneFastPrecise',
    'FPoly::operator==', 'FPoly::operator!=',
    'FLightMap::~FLightMap', 'FLightMapTexture::~FLightMapTexture',
    'FRaw32BitIndexBuffer::~FRaw32BitIndexBuffer', 'FRawIndexBuffer::~FRawIndexBuffer',
    'FStaticLightMapTexture::~FStaticLightMapTexture',
    'FFontPage::FFontPage', 'FMipmap::FMipmap', 'FStaticMeshCollisionTriangle::FStaticMeshCollisionTriangle',
    'FCollisionHash::FCollisionHash',
    'APawn::findNewFloor', 'AKConstraint::getKConstraint',
    'FConvexVolume::ClipPolygon', 'FConvexVolume::ClipPolygonPrecise',
    'URenderResource::Serialize', 'USpriteEmitter::FillVertexBuffer',
    'UMeshAnimation::GetMovement', 'FRebuildTools::GetCurrent', 'FRebuildTools::GetFromName', 'FRebuildTools::Save',
    'UCanvas::WrappedPrint', 'UInputPlanning::StaticConfigName',
    'FOrientation::operator!='
]

for fname in ['src/engine/EngineBatchImpl2.cpp', 'src/engine/EngineBatchImpl3.cpp']:
    content = open(fname).read()
    for t in targets:
        idx = content.find(t)
        if idx >= 0:
            start = max(0, content.rfind('\n', 0, idx))
            brace_start = content.find('{', idx)
            if brace_start < 0: continue
            depth = 0
            end = brace_start
            for i in range(brace_start, min(brace_start+500, len(content))):
                if content[i] == '{': depth += 1
                elif content[i] == '}': 
                    depth -= 1
                    if depth == 0:
                        end = i + 1
                        break
            snippet = content[start:end].strip()
            if len(snippet) < 300:
                bn = fname.split('/')[-1]
                print(f"[{bn}] {snippet}")
                print()
