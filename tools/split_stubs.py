#!/usr/bin/env python3
"""
split_stubs.py - Split EngineStubs.cpp into files matching the original source tree.

Parses every // --- ClassName --- section from EngineStubs.cpp, maps each class
to a target .cpp file, deduplicates by function signature, and writes the output.
Sections that have no mapping stay in EngineStubs.cpp.
"""

import re
import os

SRC_DIR = os.path.join(os.path.dirname(__file__), '..', 'src', 'engine', 'Src')
STUBS_PATH = os.path.join(SRC_DIR, 'EngineStubs.cpp')

# ---------------------------------------------------------------------------
# Mapping: class/struct name -> target .cpp file (relative to Engine/Src)
# ---------------------------------------------------------------------------
MAPPING = {
    # --- UnChan.cpp: network channels (UnBunch/UnChan in original UE2) ---
    'UChannel':        'UnChan.cpp',
    'UControlChannel': 'UnChan.cpp',
    'UActorChannel':   'UnChan.cpp',
    'UFileChannel':    'UnChan.cpp',

    # --- UnConn.cpp: net connection + player/viewport anchors ---
    'UNetConnection': 'UnConn.cpp',
    'UPlayer':        'UnConn.cpp',
    'UClient':        'UnConn.cpp',

    # --- UnNetDrv.cpp: net driver + demo recording ---
    'UNetDriver':     'UnNetDrv.cpp',
    'UDemoRecDriver': 'UnNetDrv.cpp',

    # --- NullDrv.cpp: null render device stubs ---
    'URenderDevice':  'NullDrv.cpp',
    # UNullRenderDevice appears in first block only; maps here too if present

    # --- UnDownload.cpp: file download system ---
    'UDownload':         'UnDownload.cpp',
    'UBinaryFileDownload':'UnDownload.cpp',
    'UChannelDownload':  'UnDownload.cpp',

    # --- UnGame.cpp: engine/game engine core ---
    'UEngine':          'UnGame.cpp',
    'UGameEngine':      'UnGame.cpp',
    'UInteractionMaster':'UnGame.cpp',

    # --- UnIn.cpp: input subsystem ---
    'UInputPlanning': 'UnIn.cpp',

    # --- UnFont.cpp: font rendering ---
    'UFont':        'UnFont.cpp',
    'FFontCharacter':'UnFont.cpp',
    'FFontPage':    'UnFont.cpp',

    # --- UnCanvas.cpp: 2D canvas rendering ---
    'UCanvas':      'UnCanvas.cpp',
    'FCanvasUtil':  'UnCanvas.cpp',
    'FCanvasVertex':'UnCanvas.cpp',

    # --- UnTex.cpp: texture and material system ---
    'UTexture':           'UnTex.cpp',
    'UCubemap':           'UnTex.cpp',
    'UBitmapMaterial':    'UnTex.cpp',
    'UCombiner':          'UnTex.cpp',
    'UConstantColor':     'UnTex.cpp',
    'UConstantMaterial':  'UnTex.cpp',
    'UFadeColor':         'UnTex.cpp',
    'UFinalBlend':        'UnTex.cpp',
    'UMaterial':          'UnTex.cpp',
    'UMaterialSwitch':    'UnTex.cpp',
    'UModifier':          'UnTex.cpp',
    'UPalette':           'UnTex.cpp',
    'UProxyBitmapMaterial':'UnTex.cpp',
    'UShader':            'UnTex.cpp',
    'UShadowBitmapMaterial':'UnTex.cpp',
    'UTexCoordMaterial':  'UnTex.cpp',
    'UTexCoordSource':    'UnTex.cpp',
    'UTexEnvMap':         'UnTex.cpp',
    'UTexMatrix':         'UnTex.cpp',
    'UTexModifier':       'UnTex.cpp',
    'UTexOscillator':     'UnTex.cpp',
    'UTexPanner':         'UnTex.cpp',
    'UTexRotator':        'UnTex.cpp',
    'UTexScaler':         'UnTex.cpp',
    'FMipmap':            'UnTex.cpp',
    'FMipmapBase':        'UnTex.cpp',
    'FDXTCompressionOptions':'UnTex.cpp',

    # --- UnSceneManager.cpp: Matinee / scene manager ---
    'ASceneManager':         'UnSceneManager.cpp',
    'UMatAction':            'UnSceneManager.cpp',
    'UMatSubAction':         'UnSceneManager.cpp',
    'USubActionCameraEffect':'UnSceneManager.cpp',
    'USubActionCameraShake': 'UnSceneManager.cpp',
    'USubActionFOV':         'UnSceneManager.cpp',
    'USubActionFade':        'UnSceneManager.cpp',
    'USubActionGameSpeed':   'UnSceneManager.cpp',
    'USubActionOrientation': 'UnSceneManager.cpp',
    'USubActionSceneSpeed':  'UnSceneManager.cpp',
    'USubActionTrigger':     'UnSceneManager.cpp',
    'FR6MatineePreviewProxy':'UnSceneManager.cpp',

    # --- KarmaSupport.cpp: Karma physics actors and geometry ---
    'AKActor':       'KarmaSupport.cpp',
    'AKConeLimit':   'KarmaSupport.cpp',
    'AKConstraint':  'KarmaSupport.cpp',
    'AKHinge':       'KarmaSupport.cpp',
    'UKMeshProps':   'KarmaSupport.cpp',
    'UKarmaParams':  'KarmaSupport.cpp',
    'FKAggregateGeom':'KarmaSupport.cpp',
    'FKBoxElem':     'KarmaSupport.cpp',
    'FKConvexElem':  'KarmaSupport.cpp',
    'FKCylinderElem':'KarmaSupport.cpp',
    'FKSphereElem':  'KarmaSupport.cpp',

    # --- UnStaticMeshCollision.cpp: FStaticMesh geometry structs ---
    'FStaticMeshCollisionNode':    'UnStaticMeshCollision.cpp',
    'FStaticMeshCollisionTriangle':'UnStaticMeshCollision.cpp',
    'FStaticMeshMaterial':         'UnStaticMeshCollision.cpp',
    'FStaticMeshSection':          'UnStaticMeshCollision.cpp',
    'FStaticMeshTriangle':         'UnStaticMeshCollision.cpp',
    'FStaticMeshUV':               'UnStaticMeshCollision.cpp',
    'FStaticMeshUVStream':         'UnStaticMeshCollision.cpp',
    'FStaticMeshVertex':           'UnStaticMeshCollision.cpp',
    'FStaticMeshVertexStream':     'UnStaticMeshCollision.cpp',

    # --- UnStaticMeshBuild.cpp: UStaticMesh and UStaticMeshInstance ---
    'UStaticMesh':         'UnStaticMeshBuild.cpp',
    'UStaticMeshInstance': 'UnStaticMeshBuild.cpp',

    # --- UnRenderUtil.cpp: render buffers, lighting, BSP geometry ---
    'FRawIndexBuffer':     'UnRenderUtil.cpp',
    'FRaw32BitIndexBuffer':'UnRenderUtil.cpp',
    'FRawColorStream':     'UnRenderUtil.cpp',
    'FSkinVertexStream':   'UnRenderUtil.cpp',
    'FAnimMeshVertexStream':'UnRenderUtil.cpp',
    'FBspSection':         'UnRenderUtil.cpp',
    'FBspVertex':          'UnRenderUtil.cpp',
    'FBspVertexStream':    'UnRenderUtil.cpp',
    'FStaticTexture':      'UnRenderUtil.cpp',
    'FStaticCubemap':      'UnRenderUtil.cpp',
    'FStaticLightMapTexture':'UnRenderUtil.cpp',
    'FDynamicActor':       'UnRenderUtil.cpp',
    'FDynamicLight':       'UnRenderUtil.cpp',
    'FLineVertex':         'UnRenderUtil.cpp',
    'FLineBatcher':        'UnRenderUtil.cpp',
    'FTempLineBatcher':    'UnRenderUtil.cpp',
    'FLevelSceneNode':     'UnRenderUtil.cpp',
    'FConvexVolume':       'UnRenderUtil.cpp',
    'UConvexVolume':       'UnRenderUtil.cpp',
    'UIndexBuffer':        'UnRenderUtil.cpp',
    'USkinVertexBuffer':   'UnRenderUtil.cpp',
    'FLightMap':           'UnRenderUtil.cpp',
    'FLightMapTexture':    'UnRenderUtil.cpp',
    'FLightMapIndex':      'UnRenderUtil.cpp',

    # --- UnTerrain.cpp: terrain system ---
    'ATerrainInfo':        'UnTerrain.cpp',
    'FTerrainMaterialLayer':'UnTerrain.cpp',
    'FTerrainTools':       'UnTerrain.cpp',
    'UTerrainMaterial':    'UnTerrain.cpp',

    # --- UnTerrainTools.cpp: terrain editor brushes ---
    'UTerrainBrush':              'UnTerrainTools.cpp',
    'UTerrainBrushColor':         'UnTerrainTools.cpp',
    'UTerrainBrushEdgeTurn':      'UnTerrainTools.cpp',
    'UTerrainBrushFlatten':       'UnTerrainTools.cpp',
    'UTerrainBrushNoise':         'UnTerrainTools.cpp',
    'UTerrainBrushPaint':         'UnTerrainTools.cpp',
    'UTerrainBrushPlanningPaint': 'UnTerrainTools.cpp',
    'UTerrainBrushSelect':        'UnTerrainTools.cpp',
    'UTerrainBrushSmooth':        'UnTerrainTools.cpp',
    'UTerrainBrushTexPan':        'UnTerrainTools.cpp',
    'UTerrainBrushTexRotate':     'UnTerrainTools.cpp',
    'UTerrainBrushTexScale':      'UnTerrainTools.cpp',
    'UTerrainBrushVertexEdit':    'UnTerrainTools.cpp',
    'UTerrainBrushVisibility':    'UnTerrainTools.cpp',

    # --- UnFluidSurface.cpp: fluid surface actors ---
    'AFluidSurfaceInfo':       'UnFluidSurface.cpp',
    'AFluidSurfaceOscillator': 'UnFluidSurface.cpp',
    'UFluidSurfacePrimitive':  'UnFluidSurface.cpp',

    # --- UnStatGraph.cpp: statistics graph ---
    'FStatGraphLine': 'UnStatGraph.cpp',

    # --- UnFPoly.cpp: face polygons ---
    'FBezier': 'UnFPoly.cpp',

    # --- UnPhysic.cpp: physics volumes and zones ---
    'APhysicsVolume':  'UnPhysic.cpp',
    'AVolume':         'UnPhysic.cpp',
    'AZoneInfo':       'UnPhysic.cpp',
    'AWarpZoneInfo':   'UnPhysic.cpp',
    'AWarpZoneMarker': 'UnPhysic.cpp',
    'FZoneProperties': 'UnPhysic.cpp',

    # --- UnCamera.cpp: camera, viewport, motion blur ---
    'ACamera':       'UnCamera.cpp',
    'UCameraEffect': 'UnCamera.cpp',
    'UCameraOverlay':'UnCamera.cpp',
    'UViewport':     'UnCamera.cpp',
    'UMotionBlur':   'UnCamera.cpp',

    # --- UnScript.cpp (engine-side): animation notifies ---
    'UAnimation':              'UnScript.cpp',
    'UAnimNotify':             'UnScript.cpp',
    'UAnimNotify_DestroyEffect':'UnScript.cpp',
    'UAnimNotify_Effect':      'UnScript.cpp',
    'UAnimNotify_MatSubAction':'UnScript.cpp',
    'UAnimNotify_Script':      'UnScript.cpp',
    'UAnimNotify_Scripted':    'UnScript.cpp',
    'UAnimNotify_Sound':       'UnScript.cpp',

    # --- UnActCol.cpp: reach spec / actor collision ---
    'UReachSpec': 'UnActCol.cpp',
    'FReachSpec': 'UnActCol.cpp',

    # --- UnLevAct.cpp: level actor management ---
    'ULevelSummary': 'UnLevAct.cpp',

    # --- UnEmitter.cpp: particle emitters ---
    'UParticleEmitter': 'UnEmitter.cpp',
    'UBeamEmitter':     'UnEmitter.cpp',
    'UMeshEmitter':     'UnEmitter.cpp',
    'USparkEmitter':    'UnEmitter.cpp',
    'USpriteEmitter':   'UnEmitter.cpp',
    'AEmitter':         'UnEmitter.cpp',

    # --- UnProjector.cpp: projector actors ---
    'AProjector':        'UnProjector.cpp',
    'UProjectorPrimitive':'UnProjector.cpp',

    # --- R6EngineIntegration.cpp: R6-specific types hosted in Engine.dll ---
    'UR6AbstractGameManager': 'R6EngineIntegration.cpp',
    'UR6AbstractPlanningInfo':'R6EngineIntegration.cpp',
    'UR6FileManager':         'R6EngineIntegration.cpp',
    'AR6AbstractCircumstantialActionQuery':'R6EngineIntegration.cpp',
    'AR6ActionSpot':      'R6EngineIntegration.cpp',
    'AR6ColBox':          'R6EngineIntegration.cpp',
    'AR6DecalGroup':      'R6EngineIntegration.cpp',
    'AR6DecalManager':    'R6EngineIntegration.cpp',
    'AR6DecalsBase':      'R6EngineIntegration.cpp',
    'AR6EngineWeapon':    'R6EngineIntegration.cpp',
    'AR6RainbowStartInfo':'R6EngineIntegration.cpp',
    'AR6TeamStartInfo':   'R6EngineIntegration.cpp',
    'AR6WallHit':         'R6EngineIntegration.cpp',
    'AR6eviLTesting':     'R6EngineIntegration.cpp',

    # --- UnMesh.cpp: mesh data classes ---
    'UMesh':              'UnMesh.cpp',
    'ULodMesh':           'UnMesh.cpp',
    'UMeshAnimation':     'UnMesh.cpp',
    'CBoneDescData':      'UnMesh.cpp',
    'CCompressedLipDescData':'UnMesh.cpp',
    'UVertMesh':          'UnMesh.cpp',

    # --- UnModel.cpp: BSP model and polygons ---
    'UModel': 'UnModel.cpp',
    'UPolys': 'UnModel.cpp',

    # --- UnAudio.cpp: audio subsystem ---
    'USound':       'UnAudio.cpp',
    'USoundGen':    'UnAudio.cpp',
    'UI3DL2Listener':'UnAudio.cpp',
}

# Files that already exist and should be APPENDED to (not created fresh)
APPEND_TO_EXISTING = {'UnMesh.cpp', 'UnModel.cpp', 'UnAudio.cpp'}

# ---------------------------------------------------------------------------
# File header templates
# ---------------------------------------------------------------------------
HEADER_TEMPLATE = """\
/*=============================================================================
\t{filename}: {description}
\tReconstructed for Ravenshield decompilation project.
=============================================================================*/
#pragma optimize("", off)

// Placement new for placement-new stubs in this TU.
#pragma warning(push)
#pragma warning(disable: 4291)
inline void* operator new(size_t, void* p) noexcept {{ return p; }}
inline void  operator delete(void*, void*) noexcept {{}}
#pragma warning(pop)

#include "EnginePrivate.h"
#include "EngineDecls.h"

"""

DESCRIPTIONS = {
    'UnChan.cpp':         'Network channel implementations (UChannel hierarchy)',
    'UnConn.cpp':         'Net connection and player/client stubs (UNetConnection)',
    'UnNetDrv.cpp':       'Network driver (UNetDriver, UDemoRecDriver)',
    'NullDrv.cpp':        'Null render device stubs (URenderDevice)',
    'UnDownload.cpp':     'File download system (UDownload hierarchy)',
    'UnGame.cpp':         'Engine and game-engine core (UEngine, UGameEngine)',
    'UnIn.cpp':           'Input subsystem (UInputPlanning)',
    'UnFont.cpp':         'Font rendering system (UFont, FFontCharacter, FFontPage)',
    'UnCanvas.cpp':       '2D canvas rendering (UCanvas, FCanvasUtil)',
    'UnTex.cpp':          'Texture and material system (UTexture hierarchy)',
    'UnSceneManager.cpp': 'Matinee scene manager and sub-action system',
    'KarmaSupport.cpp':   'Karma physics actors and geometry elements',
    'UnStaticMeshCollision.cpp':'Static mesh collision and geometry data structures',
    'UnStaticMeshBuild.cpp':   'Static mesh objects (UStaticMesh, UStaticMeshInstance)',
    'UnRenderUtil.cpp':   'Render buffers, lighting, and BSP geometry helpers',
    'UnTerrain.cpp':      'Terrain system (ATerrainInfo, FTerrainTools)',
    'UnTerrainTools.cpp': 'Terrain editor brush hierarchy (UTerrainBrush*)',
    'UnFluidSurface.cpp': 'Fluid surface actors and primitives',
    'UnStatGraph.cpp':    'Statistics graph rendering (FStatGraphLine)',
    'UnFPoly.cpp':        'Face polygon helpers (FBezier)',
    'UnPhysic.cpp':       'Physics volumes and zone system',
    'UnCamera.cpp':       'Camera, viewport and motion blur (ACamera, UViewport)',
    'UnScript.cpp':       'Engine-side animation notify system (UAnimNotify*)',
    'UnActCol.cpp':       'Actor collision and reach specs (UReachSpec)',
    'UnLevAct.cpp':       'Level actor management (ULevelSummary)',
    'UnEmitter.cpp':      'Particle emitter hierarchy (UParticleEmitter*)',
    'UnProjector.cpp':    'Projector actors (AProjector, UProjectorPrimitive)',
    'R6EngineIntegration.cpp': 'R6-specific types hosted in Engine.dll',
    'UnMesh.cpp':         'Mesh data stubs (UMesh, ULodMesh, UMeshAnimation)',
    'UnModel.cpp':        'BSP model and polygon stubs (UModel, UPolys)',
    'UnAudio.cpp':        'Audio subsystem stubs (USound, USoundGen)',
}

APPEND_SECTION_HEADER = """\

// =============================================================================
// Stubs imported from EngineStubs.cpp during file reorganization.
// These will be replaced with full implementations as decompilation progresses.
// =============================================================================
#pragma optimize("", off)

#pragma warning(push)
#pragma warning(disable: 4291)
inline void* operator new(size_t, void* p) noexcept { return p; }
inline void  operator delete(void*, void*) noexcept {}
#pragma warning(pop)

#include "EngineDecls.h"

"""

# ---------------------------------------------------------------------------
# Parse EngineStubs.cpp
# ---------------------------------------------------------------------------
print(f"Reading {STUBS_PATH} ...")
with open(STUBS_PATH, encoding='utf-8') as f:
    content = f.read()
lines = content.splitlines(keepends=True)

SECTION_RE = re.compile(r'^// --- ([A-Za-z0-9_:]+) ---\s*$')

# Find section boundaries
sections = []  # list of (line_idx, class_name)
for i, line in enumerate(lines):
    m = SECTION_RE.match(line)
    if m:
        sections.append((i, m.group(1)))

# Extract preamble (everything before first section)
preamble_end = sections[0][0] if sections else len(lines)
preamble = ''.join(lines[:preamble_end])

# Build section content map: class_name -> list of (start, end, content)
# For classes appearing multiple times, we collect ALL occurrences
section_occurrences = {}  # class_name -> list of content strings
for idx, (line_start, class_name) in enumerate(sections):
    if idx + 1 < len(sections):
        line_end = sections[idx + 1][0]
    else:
        line_end = len(lines)
    # Content of this section (including the header comment)
    section_content = ''.join(lines[line_start:line_end])
    if class_name not in section_occurrences:
        section_occurrences[class_name] = []
    section_occurrences[class_name].append(section_content)

# ---------------------------------------------------------------------------
# Deduplicate functions across multiple occurrences of the same class section
# ---------------------------------------------------------------------------
# A "function signature" is the first line of each function block that looks
# like a definition. We use a simple heuristic: lines ending with ')' or
# containing '::' before '{' on the next non-blank line.
FUNC_SIG_RE = re.compile(r'^[A-Za-z_].*\b\w+::\w+\s*\(')

def extract_functions(text):
    """Return list of (signature_line, full_block) tuples for each function."""
    result = []
    func_lines = text.split('\n')
    i = 0
    while i < len(func_lines):
        line = func_lines[i]
        m = FUNC_SIG_RE.match(line.strip())
        if m:
            # Find the function block (match braces)
            start = i
            depth = 0
            j = i
            found_open = False
            while j < len(func_lines):
                for ch in func_lines[j]:
                    if ch == '{':
                        depth += 1
                        found_open = True
                    elif ch == '}':
                        depth -= 1
                if found_open and depth == 0:
                    block = '\n'.join(func_lines[start:j+1])
                    sig = func_lines[start].strip()
                    result.append((sig, block))
                    i = j + 1
                    break
                j += 1
            else:
                i += 1
        else:
            i += 1
    return result

def merge_section_occurrences(occurrences):
    """Merge multiple occurrences of the same class section, deduplicating by signature."""
    if len(occurrences) == 1:
        return occurrences[0]
    
    # Use the section header from the LAST occurrence
    # Collect all unique functions across all occurrences, preferring later ones
    seen_sigs = {}  # sig -> block (later overrides earlier)
    for occ in occurrences:
        for sig, block in extract_functions(occ):
            seen_sigs[sig] = block  # last one wins
    
    # Reconstruct: take header from last occurrence, then all unique functions
    last_occ = occurrences[-1]
    # Find the header line
    header_match = SECTION_RE.match(last_occ.splitlines()[0] if last_occ.splitlines() else '')
    header = f'// --- {last_occ.split(chr(10))[0].strip().strip("/-").strip()} ---\n'
    
    # Check functions already in last occurrence to preserve ordering
    last_sigs_ordered = [sig for sig, _ in extract_functions(last_occ)]
    
    # Collect function bodies in order: functions from last occurrence first,
    # then any functions that only appeared in earlier occurrences
    earlier_only = {}
    for occ in occurrences[:-1]:
        for sig, block in extract_functions(occ):
            if sig not in (x for x, _ in extract_functions(last_occ)):
                if sig not in earlier_only:
                    earlier_only[sig] = block
    
    # Build merged output
    parts = [last_occ.rstrip('\n')]  # start with full last occurrence
    if earlier_only:
        parts.append('\n// (merged from earlier occurrence)')
        for sig, block in earlier_only.items():
            parts.append(block)
    parts.append('\n')
    return '\n'.join(parts)

# ---------------------------------------------------------------------------
# Group sections by target file
# ---------------------------------------------------------------------------
target_sections = {}  # target_file -> list of merged section content
remaining_classes = []  # classes with no mapping (stay in EngineStubs)

for class_name, occurrences in section_occurrences.items():
    target = MAPPING.get(class_name)
    merged = merge_section_occurrences(occurrences)
    if target:
        if target not in target_sections:
            target_sections[target] = []
        target_sections[target].append(merged)
    else:
        remaining_classes.append(class_name)

# ---------------------------------------------------------------------------
# Write new / updated files
# ---------------------------------------------------------------------------
created = []
appended = []
for target_file, sections_content in sorted(target_sections.items()):
    out_path = os.path.join(SRC_DIR, target_file)
    combined_sections = '\n'.join(sections_content)
    
    if target_file in APPEND_TO_EXISTING and os.path.exists(out_path):
        # Append stubs section to existing file (UnMesh.cpp, UnModel.cpp, UnAudio.cpp)
        with open(out_path, 'a', encoding='utf-8') as f:
            f.write(APPEND_SECTION_HEADER)
            f.write(combined_sections)
        appended.append(target_file)
        print(f"  APPENDED: {target_file}")
    else:
        # Create new file
        desc = DESCRIPTIONS.get(target_file, f'{target_file} stubs')
        header = HEADER_TEMPLATE.format(filename=target_file, description=desc)
        with open(out_path, 'w', encoding='utf-8') as f:
            f.write(header)
            f.write(combined_sections)
        created.append(target_file)
        print(f"  CREATED:  {target_file}")

# ---------------------------------------------------------------------------
# Rewrite EngineStubs.cpp with only remaining (unmapped) sections
# ---------------------------------------------------------------------------
remaining_content_parts = []
for class_name in remaining_classes:
    for occ in section_occurrences[class_name]:
        remaining_content_parts.append(occ)

new_stubs_content = preamble + '\n'.join(remaining_content_parts)
with open(STUBS_PATH, 'w', encoding='utf-8') as f:
    f.write(new_stubs_content)

remaining_lines = new_stubs_content.count('\n')
print(f"\n  UPDATED:  EngineStubs.cpp ({remaining_lines} lines remaining)")

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
print(f"\nDone.")
print(f"  Created  {len(created)} new files")
print(f"  Appended {len(appended)} existing files")
print(f"  Unmapped classes remaining in EngineStubs.cpp ({len(remaining_classes)}):")
for c in sorted(remaining_classes):
    print(f"    {c}")
