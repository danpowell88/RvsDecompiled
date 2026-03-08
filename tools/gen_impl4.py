"""
gen_impl4.py - Generate implementations for remaining Engine.dll stubs (round 3).
Handles: free functions, operators, data symbols, and SDK/pre-declared class methods.
Skips: __FUNC_NAME__ string literals, vftable entries, and known conflicts.
"""
import subprocess
import re

UNDNAME = r'C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\VC\Tools\MSVC\14.29.30133\bin\Hostx64\x86\undname.exe'
OUTPUT = 'src/engine/EngineBatchImpl3.cpp'

# Methods/classes to skip (already implemented elsewhere or conflict)
SKIP_MANGLES = {
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
    '??1FAnimMeshVertexStream@@UAE@XZ',
    '??1FBspVertexStream@@UAE@XZ',
    '??1FCanvasUtil@@UAE@XZ',
    '??1FDbgVectorInfo@@QAE@XZ',
    '??1FLightMap@@UAE@XZ',
    '??1FLightMapTexture@@UAE@XZ',
    '??1FLineBatcher@@UAE@XZ',
    '??1FOutBunch@@UAE@XZ',
    '??1FRaw32BitIndexBuffer@@UAE@XZ',
    '??1FRawColorStream@@UAE@XZ',
    '??1FRawIndexBuffer@@UAE@XZ',
    '??1FSkinVertexStream@@UAE@XZ',
    '??1FSoundData@@QAE@XZ',
    '??1FStaticLightMapTexture@@UAE@XZ',
    '??1FStaticMeshColorStream@@QAE@XZ',
    '??1FStaticMeshUVStream@@UAE@XZ',
    '??1FStaticMeshVertexStream@@UAE@XZ',
    '??1FStats@@QAE@XZ',
    '??4FBspVertex@@QAEAAU0@ABU0@@Z',
    '??4FDXTCompressionOptions@@QAEAAU0@ABU0@@Z',
    '??4FDbgVectorInfo@@QAEAAU0@ABU0@@Z',
    '??4FFontCharacter@@QAEAAU0@ABU0@@Z',
    '??4FFontPage@@QAEAAU0@ABU0@@Z',
    '??4FInBunch@@QAEAAV0@ABV0@@Z',
    '??4FLevelSceneNode@@QAEAAV0@ABV0@@Z',
    '??4FMipmap@@QAEAAU0@ABU0@@Z',
    '??4FMipmapBase@@QAEAAU0@ABU0@@Z',
    '??4FPointRegion@@QAEAAU0@ABU0@@Z',
    '??4FRebuildOptions@@QAE?AV0@V0@@Z',
    '??4FRenderInterface@@QAEAAV0@ABV0@@Z',
    '??4FSceneNode@@QAEAAV0@ABV0@@Z',
    '??4FStaticMeshCollisionNode@@QAEAAU0@ABU0@@Z',
    '??4FStaticMeshCollisionTriangle@@QAEAAU0@ABU0@@Z',
    '??4FStaticMeshTriangle@@QAEAAU0@ABU0@@Z',
    '??4FStaticMeshUV@@QAEAAU0@ABU0@@Z',
    '??4FStaticMeshVertex@@QAEAAU0@ABU0@@Z',
    '??4FTerrainMaterialLayer@@QAEAAU0@ABU0@@Z',
    '??6FInBunch@@UAEAAVFArchive@@AAPAVUObject@@@Z',
    '??6FInBunch@@UAEAAVFArchive@@AAVFName@@@Z',
    '??6FOutBunch@@UAEAAVFArchive@@AAPAVUObject@@@Z',
    '??6FOutBunch@@UAEAAVFArchive@@AAVFName@@@Z',
    '??9FOrientation@@QBEHABU0@@Z',
    '?AbortScoreSubmission@AGameInfo@@UAEXXZ',
    '?AttachProjector@UTerrainSector@@QAEXPAVAProjector@@PAUFProjectorRenderInfo@@@Z',
    '?BuildServerMasterMap@UGameEngine@@UAEXPAVUNetDriver@@PAVULevel@@@Z',
    '?CalcMovingAverage@FStats@@QAEXHK@Z',
    '?CallLogThisActor@ALevelInfo@@QAEXPAVAActor@@@Z',
    '?CanSerializeObject@UPackageMapLevel@@UAEHPAVUObject@@@Z',
    '?ChannelClasses@UChannel@@2PAPAVUClass@@A',
    '?CheckForErrors@ALevelInfo@@UAEXXZ',
    '?Clear@FStats@@QAEXXZ',
    '?Click@FHitObserver@@UAEXABUFHitCause@@ABUHHitProxy@@@Z',
    '?Click@HHitProxy@@UAEXABUFHitCause@@@Z',
    '?ClipPolygon@FConvexVolume@@QAE?AVFPoly@@V2@@Z',
    '?ClipPolygonPrecise@FConvexVolume@@QAE?AVFPoly@@V2@@Z',
    '?CreateChannel@UNetConnection@@QAEPAVUChannel@@W4EChannelType@@HH@Z',
    '?DirectAxis@UInput@@UAEXW4EInputKey@@MM@Z',
    '?EdCallback@UEngine@@UAEXKHK@Z',
    '?FillVertexBuffer@USpriteEmitter@@UAEHPAUFSpriteParticleVertex@@PAVFLevelSceneNode@@@Z',
    '?FilterActor@FLightMapSceneNode@@UAEHPAVAActor@@@Z',
    '?FindKeyName@UInput@@UBEHPBGAAW4EInputKey@@@Z',
    '?FlushNet@UDemoRecConnection@@UAEXXZ',
    '?GenerateTriangles@UTerrainSector@@QAEXXZ',
    '?GetActor@HActor@@UAEPAVAActor@@XZ',
    '?GetActor@HHitProxy@@UAEPAVAActor@@XZ',
    '?GetActor@HTerrain@@UAEPAVAActor@@XZ',
    '?GetActorSceneNode@FActorSceneNode@@UAEPAV1@XZ',
    '?GetCameraSceneNode@FCameraSceneNode@@UAEPAV1@XZ',
    '?GetComponents@FStaticMeshColorStream@@UAEHPAUFVertexComponent@@@Z',
    '?GetData@UVertexBuffer@@UAEPAXXZ',
    '?GetData@UVertexStreamCOLOR@@UAEPAXXZ',
    '?GetData@UVertexStreamPosNormTex@@UAEPAXXZ',
    '?GetData@UVertexStreamUV@@UAEPAXXZ',
    '?GetData@UVertexStreamVECTOR@@UAEPAXXZ',
    '?GetDataSize@UVertexBuffer@@UAEHXZ',
    '?GetDataSize@UVertexStreamCOLOR@@UAEHXZ',
    '?GetDataSize@UVertexStreamPosNormTex@@UAEHXZ',
    '?GetDataSize@UVertexStreamUV@@UAEHXZ',
    '?GetDataSize@UVertexStreamVECTOR@@UAEHXZ',
    '?GetDefaultPhysicsVolume@ALevelInfo@@QAEPAVAPhysicsVolume@@XZ',
    '?GetDisplayAs@ALevelInfo@@QAE?AVFString@@V2@@Z',
    '?GetDistanceFog@FRenderInterface@@UAEXAAHAAM1AAVFColor@@@Z',
    '?GetDriver@UDemoRecConnection@@QAEPAVUDemoRecDriver@@XZ',
    '?GetGlobalVertex@UTerrainSector@@QAEHHH@Z',
    '?GetHashLink@FCollisionHash@@QAEAAPAUFCollisionLink@1@HHHAAH@Z',
    '?GetInputAction@UInput@@QAE?AW4EInputAction@@XZ',
    '?GetInputDelta@UInput@@QAEMXZ',
    '?GetKeyName@UInput@@UBEPBGW4EInputKey@@@Z',
    '?GetLocalVertex@UTerrainSector@@QAEHHH@Z',
    '?GetMirrorSceneNode@FMirrorSceneNode@@UAEPAV1@XZ',
    '?GetMovement@UMeshAnimation@@UAEPAUMotionChunk@@VFName@@@Z',
    '?GetName@HActor@@UBEPBGXZ',
    '?GetName@HBspSurf@@UBEPBGXZ',
    '?GetName@HCoords@@UBEPBGXZ',
    '?GetName@HHitProxy@@UBEPBGXZ',
    '?GetName@HMaterialTree@@UBEPBGXZ',
    '?GetName@HMatineeAction@@UBEPBGXZ',
    '?GetName@HMatineeScene@@UBEPBGXZ',
    '?GetName@HMatineeSubAction@@UBEPBGXZ',
    '?GetName@HMatineeTimePath@@UBEPBGXZ',
    '?GetName@HTerrain@@UBEPBGXZ',
    '?GetName@HTerrainToolLayer@@UBEPBGXZ',
    '?GetOptimizedRepList@AGameReplicationInfo@@UAEPAHPAEPAUFPropertyRetirement@@PAHPAVUPackageMap@@PAVUActorChannel@@@Z',
    '?GetOptimizedRepList@ALevelInfo@@UAEPAHPAEPAUFPropertyRetirement@@PAHPAVUPackageMap@@PAVUActorChannel@@@Z',
    '?GetOptimizedRepList@APlayerReplicationInfo@@UAEPAHPAEPAUFPropertyRetirement@@PAHPAVUPackageMap@@PAVUActorChannel@@@Z',
    '?GetPeriod@FSoundData@@QAEMXZ',
    '?GetPhysicsVolume@ALevelInfo@@QAEPAVAPhysicsVolume@@VFVector@@PAVAActor@@H@Z',
    '?GetRenderBoundingBox@UTerrainPrimitive@@QAE?AVFBox@@PBVAActor@@H@Z',
    '?GetSkySceneNode@FSkySceneNode@@UAEPAV1@XZ',
    '?GetViewFrustum@FDirectionalLightMapSceneNode@@UAE?AVFConvexVolume@@XZ',
    '?GetViewFrustum@FLevelSceneNode@@UAE?AVFConvexVolume@@XZ',
    '?GetViewFrustum@FPointLightMapSceneNode@@UAE?AVFConvexVolume@@XZ',
    '?GetWarpZoneSceneNode@FWarpZoneSceneNode@@UAEPAV1@XZ',
    '?HandleClientPlayer@UDemoRecConnection@@UAEXPAVAPlayerController@@@Z',
    '?Illuminate@UTerrainPrimitive@@UAEXPAVAActor@@H@Z',
    '?Init@FEngineStats@@QAEXXZ',
    '?InitGameInfoGameService@AGameInfo@@UAEXXZ',
    '?IsA@HActor@@UBEHPBG@Z',
    '?IsA@HBspSurf@@UBEHPBG@Z',
    '?IsA@HCoords@@UBEHPBG@Z',
    '?IsA@HHitProxy@@UBEHPBG@Z',
    '?IsA@HMaterialTree@@UBEHPBG@Z',
    '?IsA@HMatineeAction@@UBEHPBG@Z',
    '?IsA@HMatineeScene@@UBEHPBG@Z',
    '?IsA@HMatineeSubAction@@UBEHPBG@Z',
    '?IsA@HMatineeTimePath@@UBEHPBG@Z',
    '?IsA@HTerrain@@UBEHPBG@Z',
    '?IsA@HTerrainToolLayer@@UBEHPBG@Z',
    '?IsNetReady@UDemoRecConnection@@UAEHH@Z',
    '?IsSectorAll@UTerrainSector@@QAEHHE@Z',
    '?IsSoundAudibleFromZone@ALevelInfo@@QAEHHH@Z',
    '?IsTriangleAll@UTerrainSector@@QAEHHHHHHE@Z',
    '?KAggregateGeomInstance@@YAPAU_McdGeometry@@PAVFKAggregateGeom@@VFVector@@PAUMcdGeomMan@@PBG@Z',
    '?KME2UCoords@@YAXPAVFCoords@@QAY03$$CBM@Z',
    '?KME2UMatrixCopy@@YAXPAVFMatrix@@QAY03M@Z',
    '?KME2UTransform@@YAXPAVFVector@@PAVFRotator@@QAY03$$CBM@Z',
    '?KModelToHulls@@YAXPAVFKAggregateGeom@@PAVUModel@@VFVector@@@Z',
    '?KU2MEMatrixCopy@@YAXQAY03MPAVFMatrix@@@Z',
    '?KU2METransform@@YAXQAY03MVFVector@@VFRotator@@@Z',
    '?LineCheck@UTerrainPrimitive@@UAEHAAUFCheckResult@@PAVAActor@@VFVector@@22KK@Z',
    '?Load@FSoundData@@UAEXXZ',
    '?LowLevelDescribe@UDemoRecConnection@@UAE?AVFString@@XZ',
    '?LowLevelGetRemoteAddress@UDemoRecConnection@@UAE?AVFString@@XZ',
    '?LowLevelSend@UDemoRecConnection@@UAEXPAXH@Z',
    '?MasterServerManager@AGameInfo@@UAEXXZ',
    '?PassShouldRenderTriangle@UTerrainSector@@QAEHHHHHH@Z',
    '?PointCheck@UTerrainPrimitive@@UAEHAAUFCheckResult@@PAVAActor@@VFVector@@2K@Z',
    '?PostLoad@UTerrainSector@@UAEXXZ',
    '?PostNetReceive@AGameReplicationInfo@@UAEXXZ',
    '?PostNetReceive@ALevelInfo@@UAEXXZ',
    '?PostNetReceive@APlayerReplicationInfo@@UAEXXZ',
    '?PostSend@UNetConnection@@QAEXXZ',
    '?PreNetReceive@ALevelInfo@@UAEXXZ',
    '?PreProcess@UInput@@UAEHW4EInputKey@@W4EInputAction@@M@Z',
    '?Process@UInput@@UAEHAAVFOutputDevice@@W4EInputKey@@W4EInputAction@@M@Z',
    '?ProcessR6Availabilty@AGameInfo@@SAXPAVULevel@@VFString@@@Z',
    '?RegisterStats@FStats@@QAEHW4EStatsType@@W4EStatsDataType@@VFString@@2W4EStatsUnit@@@Z',
    '?RemoveColinears@FPoly@@QAEHXZ',
    '?Render@FActorSceneNode@@UAEXPAVFRenderInterface@@@Z',
    '?Render@FCameraSceneNode@@UAEXPAVFRenderInterface@@@Z',
    '?Render@FLightMapSceneNode@@UAEXPAVFRenderInterface@@@Z',
    '?Render@FStats@@QAEXPAVUViewport@@PAVUEngine@@@Z',
    '?Serialize@URenderResource@@UAEXAAVFArchive@@@Z',
    '?Serialize@UTerrainPrimitive@@UAEXAAVFArchive@@@Z',
    '?Serialize@UTerrainSector@@UAEXAAVFArchive@@@Z',
    '?Serialize@UVertexBuffer@@UAEXAAVFArchive@@@Z',
    '?Serialize@UVertexStreamBase@@UAEXAAVFArchive@@@Z',
    '?Serialize@UVertexStreamCOLOR@@UAEXAAVFArchive@@@Z',
    '?Serialize@UVertexStreamPosNormTex@@UAEXAAVFArchive@@@Z',
    '?Serialize@UVertexStreamUV@@UAEXAAVFArchive@@@Z',
    '?Serialize@UVertexStreamVECTOR@@UAEXAAVFArchive@@@Z',
    '?SerializeObject@UPackageMapLevel@@UAEHAAVFArchive@@PAVUClass@@AAPAVUObject@@@Z',
    '?SetEmulationMode@UNullRenderDevice@@UAEXW4EHardwareEmulationMode@@@Z',
    '?SetInputAction@UInput@@QAEXW4EInputAction@@M@Z',
    '?SetNPatchesInfos@FRenderInterface@@UAEXHM@Z',
    '?SetPolyFlags@UVertexStreamBase@@QAEXK@Z',
    '?SetVolumes@ALevelInfo@@UAEXABV?$TArray@PAVAVolume@@@@@Z',
    '?SetVolumes@ALevelInfo@@UAEXXZ',
    '?SetZone@ALevelInfo@@UAEXHH@Z',
    '?StaticConstructor@UDemoRecConnection@@QAEXXZ',
    '?StaticInitInput@UInput@@SAXXZ',
    '?StaticLight@UTerrainSector@@QAEXH@Z',
    '?SupportsTextureFormat@UNullRenderDevice@@UAEHW4ETextureFormat@@@Z',
    '?UpdateMatrices@FCameraSceneNode@@UAEXXZ',
    '?UpdateString@FStats@@QAEXAAVFString@@H@Z',
    '?addPath@FSortedPathList@@QAEXPAVANavigationPoint@@H@Z',
    '?edDrawAxisIndicator@UEngine@@UAEXPAVFSceneNode@@@Z',
    '?findNewFloor@APawn@@QAEHVFVector@@MMH@Z',
    '?getKConstraint@AKConstraint@@UBEPAVMdtBaseConstraint@@XZ',
}

# Skip specific demangled patterns
SKIP_PATTERNS = [
    'AR6AbstractClimbableObj::AR6AbstractClimbableObj',  # already in EngineBatchImpl2
    'UR6AbstractTerroristMgr::UR6AbstractTerroristMgr',  # already in EngineBatchImpl2
    'UInput::StaticConfigName',  # not declared in class
    'UInputPlanning::StaticConfigName',  # not declared in class
    'UCanvas::WrappedPrint',  # not declared in class
]

# Classes whose methods are defined in Engine.h with different signatures
SKIP_CLASSES = {
    'FColor',  # defined in Engine.h with inline methods
    'FOrientation',  # forward-declared struct
}

SIG_RE = re.compile(
    r'(?:(?:public|protected|private):\s+)?'
    r'(?:virtual\s+)?'
    r'(?:static\s+)?'
    r'(.*?)\s+'
    r'(?:__\w+\s+)'
    r'(?:(\w+)::)?'
    r'(~?\w+|operator[^(]+)\s*'
    r'\((.*?)\)'
    r'(\s*const)?'
)

# Match conversion operators: operator TYPE
CONV_OP_RE = re.compile(
    r'(?:(?:public|protected|private):\s+)?'
    r'(?:__\w+\s+)'
    r'(\w+)::operator\s+(.*?)\s*\(\s*void\s*\)'
    r'(\s*const)?'
)

def read_remaining_stubs():
    stubs = []
    for i in range(1, 5):
        with open(f'src/engine/EngineStubs{i}.cpp') as f:
            for line in f:
                if '/alternatename:' in line and '=_dummy' in line:
                    idx1 = line.index('/alternatename:') + len('/alternatename:')
                    idx2 = line.index('=_dummy')
                    stubs.append(line[idx1:idx2])
    return stubs

def demangle_stubs(stubs):
    result = {}
    batch_size = 50
    for start in range(0, len(stubs), batch_size):
        batch = stubs[start:start+batch_size]
        proc = subprocess.run([UNDNAME] + batch, capture_output=True, text=True)
        lines = proc.stdout.strip().split('\n')
        i = 0
        while i < len(lines):
            line = lines[i].strip()
            if line.startswith('Undecoration of :- "') and line.endswith('"'):
                mangled = line[len('Undecoration of :- "'):-1]
                if i+1 < len(lines):
                    dem_line = lines[i+1].strip()
                    if dem_line.startswith('is :- "') and dem_line.endswith('"'):
                        demangled = dem_line[len('is :- "'):-1]
                        result[mangled] = demangled
                i += 2
            else:
                i += 1
    return result

TYPE_MAP = {
    'unsigned short const *': 'const TCHAR*',
    'unsigned short *': 'TCHAR*',
    'unsigned short': 'TCHAR',
    'unsigned long': 'DWORD',
    'unsigned int': 'UINT',
    'unsigned char': 'BYTE',
}

def fix_type(t):
    t = t.strip()
    t = re.sub(r'\bclass\s+', '', t)
    t = re.sub(r'\bstruct\s+', '', t)
    t = re.sub(r'\benum\s+', '', t)
    for old, new in TYPE_MAP.items():
        t = t.replace(old, new)
    return t.strip()

def default_return(ret):
    ret = ret.strip()
    if ret == 'void':
        return ''
    if '*' in ret:
        return 'return NULL;'
    if '&' in ret:
        base = ret.replace('&', '').strip().replace('const ', '')
        return f'static {base} dummy; return dummy;'
    if ret in ('int', 'float', 'double', 'bool', 'DWORD', 'UINT', 'BYTE', 'TCHAR',
               'INT', 'UBOOL', 'FLOAT'):
        return 'return 0;'
    return f'return {ret}();'

# Classes that inherit from FSceneNode (no default ctor)
FSCENENODE_SUBCLASSES = {
    'FActorSceneNode', 'FCameraSceneNode', 'FLevelSceneNode',
    'FMirrorSceneNode', 'FSkySceneNode', 'FWarpZoneSceneNode',
    'FDirectionalLightMapSceneNode', 'FPointLightMapSceneNode',
    'FLightMapSceneNode',
}

def should_skip(demangled):
    for pat in SKIP_PATTERNS:
        if pat in demangled:
            return True
    return False

def generate_implementations(demangled_map):
    impls = []
    skipped = {'funcname': 0, 'vftable': 0, 'skip_class': 0, 'skip_pat': 0,
               'conv_op': 0, 'unmatched': 0, 'data': 0}
    generated = 0

    for mangled, demangled in sorted(demangled_map.items(), key=lambda x: x[1]):
        if '__FUNC_NAME__' in demangled or 'FUNC_NAME' in demangled:
            skipped['funcname'] += 1
            continue
        if "'vftable'" in demangled or "'vbtable'" in demangled:
            skipped['vftable'] += 1
            continue
        if 'default constructor closure' in demangled:
            skipped['unmatched'] += 1
            continue
        if 'Copyright' in demangled or 'Microsoft' in demangled:
            skipped['unmatched'] += 1
            continue
        if should_skip(demangled):
            skipped['skip_pat'] += 1
            continue
        if mangled in SKIP_MANGLES:
            skipped['skip_pat'] += 1
            continue

        # Check if this is a conversion operator
        cm = CONV_OP_RE.match(demangled)
        if cm:
            # Skip conversion operators - complex to generate correctly
            skipped['conv_op'] += 1
            continue

        m = SIG_RE.match(demangled)
        if not m:
            skipped['unmatched'] += 1
            continue

        ret_raw = m.group(1)
        cls = m.group(2)
        name = m.group(3).strip()
        params_raw = m.group(4)
        is_const = bool(m.group(5))

        # Skip entire classes
        if cls and cls in SKIP_CLASSES:
            skipped['skip_class'] += 1
            continue

        ret = fix_type(ret_raw)
        if ret.startswith('static '):
            ret = ret[7:]

        # Parse params
        params_parts = []
        if params_raw and params_raw.strip() != 'void':
            depth = 0
            current = ''
            for ch in params_raw:
                if ch in '<(':
                    depth += 1
                elif ch in '>)':
                    depth -= 1
                if ch == ',' and depth == 0:
                    params_parts.append(current.strip())
                    current = ''
                else:
                    current += ch
            if current.strip():
                params_parts.append(current.strip())

        params_fixed = []
        for i, p in enumerate(params_parts):
            p = fix_type(p)
            params_fixed.append(f'{p} p{i}')

        param_str = ', '.join(params_fixed) if params_fixed else ''
        const_str = ' const' if is_const else ''

        # Constructors/destructors
        if cls and (name == cls or name == f'~{cls}'):
            if name.startswith('~'):
                impl = f'{cls}::~{cls}(){const_str} {{}}'
            else:
                # Constructors for FSceneNode subclasses need initializer
                if cls in FSCENENODE_SUBCLASSES:
                    impl = f'{cls}::{cls}({param_str}){const_str} : FSceneNode((UViewport*)NULL) {{}}'
                elif cls == 'FInBunch':
                    impl = f'{cls}::{cls}({param_str}){const_str} : FBitReader(NULL, 0) {{}}'
                else:
                    impl = f'{cls}::{cls}({param_str}){const_str} {{}}'
        elif cls:
            body = default_return(ret)
            if body:
                impl = f'{ret} {cls}::{name}({param_str}){const_str} {{ {body} }}'
            else:
                impl = f'{ret} {cls}::{name}({param_str}){const_str} {{}}'
        else:
            # Free function / operator
            body = default_return(ret)
            if body:
                impl = f'{ret} {name}({param_str}){const_str} {{ {body} }}'
            else:
                impl = f'{ret} {name}({param_str}){const_str} {{}}'

        impls.append(f'// {mangled}')
        impls.append(impl)
        impls.append('')
        generated += 1

    return impls, generated, skipped

def generate_data_defs(demangled_map):
    defs = []
    count = 0
    for mangled, demangled in sorted(demangled_map.items(), key=lambda x: x[1]):
        if mangled in SKIP_MANGLES:
            continue
        dm = re.match(r'(?:public|protected|private):\s+static\s+(.*?)\s+(\w+)::(\w+)\s*$', demangled)
        if dm:
            ret = fix_type(dm.group(1))
            cls = dm.group(2)
            member = dm.group(3)
            if cls in SKIP_CLASSES:
                continue
            if '*' in ret:
                defs.append(f'{ret} {cls}::{member} = NULL;')
            elif ret == 'int' or ret == 'INT':
                defs.append(f'{ret} {cls}::{member} = 0;')
            elif ret == 'FString':
                defs.append(f'{ret} {cls}::{member};')
            else:
                defs.append(f'{ret} {cls}::{member};')
            defs.append('')
            count += 1
            continue

        if '(' not in demangled and '::' not in demangled and 'vftable' not in demangled:
            gm = re.match(r'^(.*?)\s+(\w+)\s*$', demangled)
            if gm and 'Microsoft' not in demangled:
                ret = fix_type(gm.group(1))
                name = gm.group(2)
                if '*' in ret:
                    defs.append(f'{ret} {name} = NULL;')
                elif ret == 'int' or ret == 'INT':
                    defs.append(f'{ret} {name} = 0;')
                else:
                    defs.append(f'{ret} {name};')
                defs.append('')
                count += 1

    return defs, count

# Forward declarations needed for types used in operator<< and other stubs
FORWARD_DECLS = """
// Forward declarations for types used by generated stubs
struct FBspNode;
struct FBspSection;
struct FBspVertex;
struct FPosNormTexData;
struct FSkinVertex;
struct FStaticMeshBatcherVertex;
struct FStaticMeshCollisionNode;
struct FStaticMeshCollisionTriangle;
struct FStaticMeshLightInfo;
struct FStaticMeshMaterial;
struct FStaticMeshSection;
struct FStaticMeshTriangle;
struct FStaticMeshUV;
struct FStaticMeshVertex;
struct FStaticMeshVertexStream;
struct FTerrainVertex;
struct FTerrainVertexStream;
struct FUV2Data;
struct FUntransformedVertex;
struct FProjectorRelativeRenderInfo;
struct FOrientation { BYTE Pad[16]; FOrientation& operator=(FOrientation) { return *this; } int operator!=(const FOrientation&) const { return 0; } };
struct FHitCause;
struct HHitProxy;
struct FRebuildOptions { BYTE Pad[256]; };
struct _KarmaGlobals;
struct _McdGeometry;
struct McdGeomMan;
struct _KarmaTriListData;
"""

def main():
    stubs = read_remaining_stubs()
    print(f'Total remaining stubs: {len(stubs)}')

    demangled_map = demangle_stubs(stubs)
    print(f'Demangled: {len(demangled_map)}')

    impls, gen_count, skipped = generate_implementations(demangled_map)
    data_defs, data_count = generate_data_defs(demangled_map)

    lines = [
        '/*=============================================================================',
        '  EngineBatchImpl3.cpp: Round 3 batch implementations.',
        '  Auto-generated by gen_impl4.py',
        '=============================================================================*/',
        '',
        '#include "EnginePrivate.h"',
        '',
        FORWARD_DECLS,
        '',
        '/*-----------------------------------------------------------------------------',
        '  Data definitions',
        '-----------------------------------------------------------------------------*/',
        '',
    ]
    lines.extend(data_defs)
    lines.append('')
    lines.append('/*-----------------------------------------------------------------------------')
    lines.append('  Implementations')
    lines.append('-----------------------------------------------------------------------------*/')
    lines.append('')
    lines.extend(impls)

    with open(OUTPUT, 'w') as f:
        f.write('\n'.join(lines))

    print(f'Generated implementations: {gen_count}')
    print(f'Data definitions: {data_count}')
    print(f'Skipped: {skipped}')
    print(f'Wrote {OUTPUT}')

if __name__ == '__main__':
    main()
