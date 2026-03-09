"""Comprehensive stub resolution: patches EngineClasses.h declarations and
creates EngineBatchImpl4.cpp for all remaining ~160 stubs."""

import re

CLASSES_H = 'src/engine/EngineClasses.h'

# =======================================================================
# 1. Patch EngineClasses.h
# =======================================================================
content = open(CLASSES_H).read()
changes = 0

def do_replace(old, new, desc, required=True):
    global content, changes
    if old not in content:
        if required:
            print(f'  WARN: {desc} not found')
            # Try to show context
            key = old[:40]
            idx = content.find(key[:20])
            if idx >= 0:
                print(f'    near: {content[max(0,idx-20):idx+60]}')
        return False
    content = content.replace(old, new, 1)
    changes += 1
    print(f'  OK: {desc}')
    return True

print('=== Patching EngineClasses.h ===')

# --- Add EChannelType enum before UChannel class ---
do_replace(
    'class ENGINE_API UChannel : public UObject',
    'enum EChannelType { CHTYPE_None=0, CHTYPE_Control=1, CHTYPE_Actor=2, CHTYPE_File=3, CHTYPE_MAX=8 };\n\nclass ENGINE_API UChannel : public UObject',
    'Add EChannelType enum')

# --- Add EStatsType, EStatsDataType, EStatsUnit enums (needed for FStats::RegisterStats) ---
do_replace(
    "class ENGINE_API FEngineStats  { public:",
    "enum EStatsType { STAT_None=0 };\nenum EStatsDataType { STATSDATA_None=0 };\nenum EStatsUnit { STATSUNIT_None=0 };\n\nclass ENGINE_API FEngineStats  { public:",
    'Add EStats enums')

# --- UEngine::edDrawAxisIndicator: void* -> FSceneNode* ---
do_replace(
    'virtual void edDrawAxisIndicator( void* /*FSceneNode**/ SceneNode ) {}',
    'virtual void edDrawAxisIndicator( FSceneNode* SceneNode ) {}',
    'UEngine::edDrawAxisIndicator void* -> FSceneNode*')

# --- UEngine::EdCallback: return INT -> void ---
do_replace(
    'virtual INT  EdCallback( DWORD Code, INT Param, DWORD Flags ) { return 0; }',
    'virtual void EdCallback( DWORD Code, INT Param, DWORD Flags ) {}',
    'UEngine::EdCallback INT return -> void')

# --- UGameEngine::BuildServerMasterMap: return UNetDriver* -> void ---
do_replace(
    'virtual UNetDriver* BuildServerMasterMap( UNetDriver* NetDriver, ULevel* InLevel );',
    'virtual void BuildServerMasterMap( UNetDriver* NetDriver, ULevel* InLevel );',
    'UGameEngine::BuildServerMasterMap return fix')

# --- UInput: Change INT params to enum types ---
do_replace(
    '\tvirtual INT PreProcess( INT Key, INT Action, FLOAT Delta );',
    '\tvirtual INT PreProcess( EInputKey Key, EInputAction Action, FLOAT Delta );',
    'UInput::PreProcess INT -> enum')
do_replace(
    '\tvirtual INT Process( FOutputDevice& Ar, INT Key, INT Action, FLOAT Delta );',
    '\tvirtual INT Process( FOutputDevice& Ar, EInputKey Key, EInputAction Action, FLOAT Delta );',
    'UInput::Process INT -> enum')
do_replace(
    '\tvirtual void DirectAxis( INT Key, FLOAT Value, FLOAT Delta );',
    '\tvirtual void DirectAxis( EInputKey Key, FLOAT Value, FLOAT Delta );',
    'UInput::DirectAxis INT -> enum')
do_replace(
    '\tvirtual const TCHAR* GetKeyName( INT Key ) const;',
    '\tvirtual const TCHAR* GetKeyName( EInputKey Key ) const;',
    'UInput::GetKeyName INT -> enum')
do_replace(
    '\tvirtual INT FindKeyName( const TCHAR* KeyName, INT& Key ) const;',
    '\tvirtual INT FindKeyName( const TCHAR* KeyName, EInputKey& Key ) const;',
    'UInput::FindKeyName INT -> enum')
do_replace(
    '\tvoid SetInputAction( INT Action, FLOAT Delta );',
    '\tvoid SetInputAction( EInputAction Action, FLOAT Delta );\n\tEInputAction GetInputAction();\n\tFLOAT GetInputDelta();',
    'UInput::SetInputAction + add GetInputAction/GetInputDelta')

# --- UInput: Add StaticConfigName (private) and StaticInitInput ---
do_replace(
    '\tvoid StaticConstructor();\n};',
    '\tvoid StaticConstructor();\nprivate:\n\tstatic const TCHAR* StaticConfigName();\npublic:\n\tstatic void StaticInitInput();\n};',
    'UInput: add StaticConfigName + StaticInitInput',
    required=False)
# If previous didn't work, try different context
if '\tstatic void StaticInitInput();' not in content:
    # Try after StaticConstructor in UInput block
    # UInput has 'void StaticConstructor();' near the end
    # Let me find the UInput closing brace
    idx = content.find('class ENGINE_API UInput : public USubsystem')
    if idx >= 0:
        end_idx = content.find('\n};', idx)
        if end_idx >= 0:
            insert_at = end_idx
            insert_text = '\nprivate:\n\tstatic const TCHAR* StaticConfigName();\npublic:\n\tstatic void StaticInitInput();\n'
            # Check if not already there
            if 'StaticInitInput' not in content[idx:end_idx+50]:
                content = content[:insert_at] + insert_text + content[insert_at:]
                changes += 1
                print('  OK: UInput StaticConfigName + StaticInitInput (inserted)')

# --- UNullRenderDevice: Fix SetEmulationMode and SupportsTextureFormat types ---
do_replace(
    '\tvirtual void SetEmulationMode( INT Mode );',
    '\tvirtual void SetEmulationMode( EHardwareEmulationMode Mode );',
    'UNullRenderDevice::SetEmulationMode INT -> enum')
do_replace(
    '\tvirtual INT SupportsTextureFormat( INT Format );',
    '\tvirtual INT SupportsTextureFormat( ETextureFormat Format );',
    'UNullRenderDevice::SupportsTextureFormat INT -> enum')

# --- UNetConnection::CreateChannel: INT -> EChannelType ---
do_replace(
    '\tUChannel* CreateChannel( INT ChType, INT bOpenedLocally, INT ChIndex );',
    '\tUChannel* CreateChannel( EChannelType ChType, INT bOpenedLocally, INT ChIndex );',
    'UNetConnection::CreateChannel INT -> EChannelType')

# --- UChannel: ChannelClasses function -> static data member ---
do_replace(
    'static UClass** ChannelClasses();',
    'static UClass** ChannelClasses;',
    'UChannel::ChannelClasses function -> data')

# --- HCoords ctor: FSceneNode* -> FCameraSceneNode* ---
do_replace(
    'HCoords(FSceneNode* InFrame);',
    'HCoords(FCameraSceneNode* InFrame);',
    'HCoords ctor FSceneNode* -> FCameraSceneNode*')

# --- FRenderInterface: add ENGINE_API and missing members ---
do_replace(
    '''class FRenderInterface
{
public:
\tvirtual ~FRenderInterface() {}
\tvirtual void GetDistanceFog(INT& bEnabled, FLOAT& FogStart, FLOAT& FogEnd, FColor& FogColor) {}
};''',
    '''class ENGINE_API FRenderInterface
{
public:
\tBYTE RIPad[256];
\tFRenderInterface();
\tFRenderInterface(const FRenderInterface&);
\tvirtual ~FRenderInterface() {}
\tFRenderInterface& operator=(const FRenderInterface&);
\tvirtual void GetDistanceFog(INT& bEnabled, FLOAT& FogStart, FLOAT& FogEnd, FColor& FogColor) {}
\tvirtual void SetNPatchesInfos(INT bEnabled, FLOAT TessellationLevel) {}
};''',
    'FRenderInterface: ENGINE_API + full members')

# --- FSceneNode subclasses: add missing virtual method declarations ---
# FActorSceneNode
do_replace(
    '''class ENGINE_API FActorSceneNode : public FSceneNode
{
public:
\tFActorSceneNode(UViewport*, AActor*, AActor*, FVector, FRotator, FLOAT);
};''',
    '''class ENGINE_API FActorSceneNode : public FSceneNode
{
public:
\tFActorSceneNode(UViewport*, AActor*, AActor*, FVector, FRotator, FLOAT);
\tvirtual void Render(FRenderInterface*);
\tvirtual FActorSceneNode* GetActorSceneNode();
};''',
    'FActorSceneNode: add Render + GetActorSceneNode')

# FCameraSceneNode
do_replace(
    '''class ENGINE_API FCameraSceneNode : public FSceneNode
{
public:
\tFCameraSceneNode(UViewport*, AActor*, FVector, FRotator, FLOAT);
};''',
    '''class ENGINE_API FCameraSceneNode : public FSceneNode
{
public:
\tFCameraSceneNode(UViewport*, AActor*, FVector, FRotator, FLOAT);
\tvirtual void Render(FRenderInterface*);
\tvirtual FCameraSceneNode* GetCameraSceneNode();
\tvirtual void UpdateMatrices();
};''',
    'FCameraSceneNode: add Render + GetCameraSceneNode + UpdateMatrices')

# FMirrorSceneNode
do_replace(
    'class ENGINE_API FMirrorSceneNode : public FSceneNode { public: BYTE Pad2[64]; };',
    '''class ENGINE_API FMirrorSceneNode : public FSceneNode
{
public:
\tBYTE Pad2[64];
\tFMirrorSceneNode(FLevelSceneNode*, FPlane, INT, INT);
\tvirtual FMirrorSceneNode* GetMirrorSceneNode();
};''',
    'FMirrorSceneNode: add ctor + GetMirrorSceneNode')

# FSkySceneNode
do_replace(
    'class ENGINE_API FSkySceneNode : public FSceneNode { public: BYTE Pad2[64]; };',
    '''class ENGINE_API FSkySceneNode : public FSceneNode
{
public:
\tBYTE Pad2[64];
\tFSkySceneNode(FLevelSceneNode*, INT);
\tvirtual FSkySceneNode* GetSkySceneNode();
};''',
    'FSkySceneNode: add ctor + GetSkySceneNode')

# FWarpZoneSceneNode
do_replace(
    'class ENGINE_API FWarpZoneSceneNode : public FSceneNode { public: BYTE Pad2[64]; };',
    '''class ENGINE_API FWarpZoneSceneNode : public FSceneNode
{
public:
\tBYTE Pad2[64];
\tFWarpZoneSceneNode(FLevelSceneNode*, AWarpZoneInfo*);
\tvirtual FWarpZoneSceneNode* GetWarpZoneSceneNode();
};''',
    'FWarpZoneSceneNode: add ctor + GetWarpZoneSceneNode')

# FDirectionalLightMapSceneNode
do_replace(
    '''class ENGINE_API FDirectionalLightMapSceneNode : public FSceneNode
{
public:
\tFDirectionalLightMapSceneNode(UViewport*, AActor*, class FBspSurf&, FLightMap*);
};''',
    '''class ENGINE_API FDirectionalLightMapSceneNode : public FSceneNode
{
public:
\tFDirectionalLightMapSceneNode(UViewport*, AActor*, class FBspSurf&, FLightMap*);
\tvirtual FConvexVolume GetViewFrustum();
};''',
    'FDirectionalLightMapSceneNode: add GetViewFrustum')

# FPointLightMapSceneNode
do_replace(
    '''class ENGINE_API FPointLightMapSceneNode : public FSceneNode
{
public:
\tFPointLightMapSceneNode(UViewport*, AActor*, class FBspSurf&, FLightMap*, INT, INT, INT, INT);
};''',
    '''class ENGINE_API FPointLightMapSceneNode : public FSceneNode
{
public:
\tFPointLightMapSceneNode(UViewport*, AActor*, class FBspSurf&, FLightMap*, INT, INT, INT, INT);
\tvirtual FConvexVolume GetViewFrustum();
};''',
    'FPointLightMapSceneNode: add GetViewFrustum')

# FLightMapSceneNode
do_replace(
    '''class ENGINE_API FLightMapSceneNode : public FSceneNode
{
public:
\tFLightMapSceneNode(UViewport*, AActor*, FLightMap*);
};''',
    '''class ENGINE_API FLightMapSceneNode : public FSceneNode
{
public:
\tFLightMapSceneNode(UViewport*, AActor*, FLightMap*);
\tvirtual void Render(FRenderInterface*);
\tvirtual INT FilterActor(AActor*);
};''',
    'FLightMapSceneNode: add Render + FilterActor')

# --- FSortedPathList: expand from forward decl to full class ---
do_replace(
    'class FSortedPathList;',
    '''class ENGINE_API FSortedPathList
{
public:
\tBYTE Pad[64];
\tFSortedPathList();
\tvoid addPath(ANavigationPoint*, INT);
};''',
    'FSortedPathList: expand to full class')

# --- FSoundData: add missing members ---
do_replace(
    '''class ENGINE_API FSoundData
{
public:
\tBYTE Pad[64];
\tvirtual ~FSoundData() {}
};''',
    '''class ENGINE_API FSoundData
{
public:
\tBYTE Pad[64];
\tFSoundData(USound*);
\tvirtual ~FSoundData();
\tvirtual void Load();
\tFLOAT GetPeriod();
};''',
    'FSoundData: add ctor/dtor/Load/GetPeriod')

# --- FStats: add missing members ---
do_replace(
    "class ENGINE_API FStats        { public: BYTE Pad[256]; FStats()       { appMemzero(this, sizeof(*this)); } };",
    '''class ENGINE_API FStats
{
public:
\tBYTE Pad[256];
\tFStats() { appMemzero(this, sizeof(*this)); }
\tFStats(const FStats&);
\t~FStats();
\tvoid UpdateString(FString&, INT);
\tvoid Render(UViewport*, UEngine*);
\tINT RegisterStats(EStatsType, EStatsDataType, FString, FString, EStatsUnit);
\tvoid CalcMovingAverage(INT, DWORD);
\tvoid Clear();
};''',
    'FStats: add copy ctor/dtor/methods')

# --- FEngineStats: add Init ---
do_replace(
    "class ENGINE_API FEngineStats  { public: BYTE Pad[256]; FEngineStats() { appMemzero(this, sizeof(*this)); } };",
    '''class ENGINE_API FEngineStats
{
public:
\tBYTE Pad[256];
\tFEngineStats() { appMemzero(this, sizeof(*this)); }
\tvoid Init();
};''',
    'FEngineStats: add Init')

# --- FInBunch: add constructors, operator=, operator<< ---
do_replace(
    '''class ENGINE_API FInBunch : public FBitReader
{
public:
\tBYTE Pad[64];
};''',
    '''class ENGINE_API FInBunch : public FBitReader
{
public:
\tBYTE Pad[64];
\tFInBunch(const FInBunch&);
\tFInBunch(UNetConnection*);
\tFInBunch& operator=(const FInBunch&);
\tvirtual FArchive& operator<<(UObject*&);
\tvirtual FArchive& operator<<(FName&);
};''',
    'FInBunch: add ctors/operator=/operator<<')

# --- FOutBunch: add constructors, destructor, operator<< ---
do_replace(
    '''class ENGINE_API FOutBunch
{
public:
\tBYTE Pad[256];
};''',
    '''class ENGINE_API FOutBunch
{
public:
\tBYTE Pad[256];
\tFOutBunch();
\tFOutBunch(const FOutBunch&);
\tFOutBunch(UChannel*, INT);
\tvirtual ~FOutBunch();
\tvirtual FArchive& operator<<(UObject*&);
\tvirtual FArchive& operator<<(FName&);
};''',
    'FOutBunch: add ctors/dtor/operator<<')

# --- FPointRegion: add missing ctor and operator= ---
do_replace(
    '''\tFPointRegion() : Zone(NULL), iLeaf(0), ZoneNumber(0) {}
\tFPointRegion(class AZoneInfo* InZone) : Zone(InZone), iLeaf(0), ZoneNumber(0) {}''',
    '''\tFPointRegion() : Zone(NULL), iLeaf(0), ZoneNumber(0) {}
\tFPointRegion(class AZoneInfo* InZone) : Zone(InZone), iLeaf(0), ZoneNumber(0) {}
\tFPointRegion(class AZoneInfo* InZone, INT InLeaf, BYTE InZoneNumber) : Zone(InZone), iLeaf(InLeaf), ZoneNumber(InZoneNumber) {}
\tFPointRegion& operator=(const FPointRegion&);''',
    'FPointRegion: add 3-arg ctor + operator=')

# --- FDbgVectorInfo: declaration already exists. No changes needed. ---

# --- ALevelInfo: add missing method declarations ---
do_replace(
    '''\tvoid eventServerTravel(const FString&, DWORD);
\tDWORD eventGameTypeUseNbOfTerroristToSpawn(const FString&);
\tDWORD eventIsGameTypePlayWithNonRainbowNPCs(const FString&);
};''',
    '''\tvoid eventServerTravel(const FString&, DWORD);
\tDWORD eventGameTypeUseNbOfTerroristToSpawn(const FString&);
\tDWORD eventIsGameTypePlayWithNonRainbowNPCs(const FString&);

\t// Native C++ method declarations
\tvirtual void SetVolumes(const TArray<class AVolume*>&);
\tvirtual void SetVolumes();
\tvirtual void SetZone(INT, INT);
\tvirtual void PostNetReceive();
\tvirtual void PreNetReceive();
\tvirtual void CheckForErrors();
\tvirtual INT* GetOptimizedRepList(BYTE*, FPropertyRetirement*, INT*, UPackageMap*, UActorChannel*);
\tvoid CallLogThisActor(AActor*);
\tclass APhysicsVolume* GetDefaultPhysicsVolume();
\tFString GetDisplayAs(FString);
\tclass APhysicsVolume* GetPhysicsVolume(FVector, AActor*, INT);
\tINT IsSoundAudibleFromZone(INT, INT);
};''',
    'ALevelInfo: add native method declarations')

# --- AGameInfo: add missing method declarations ---
do_replace(
    '''\tvoid eventUpdateServer();
};''',
    '''\tvoid eventUpdateServer();

\t// Native C++ method declarations
\tvirtual void AbortScoreSubmission();
\tvirtual void MasterServerManager();
\tvirtual void InitGameInfoGameService();
\tstatic void CDECL ProcessR6Availabilty(ULevel*, FString);
};''',
    'AGameInfo: add native method declarations')

# --- AGameReplicationInfo: add missing method declarations ---
do_replace(
    '''class ENGINE_API AGameReplicationInfo : public AReplicationInfo
{
public:
\tDECLARE_CLASS(AGameReplicationInfo,AReplicationInfo,0|CLASS_Config|CLASS_NativeReplication,Engine)
\t// Event thunks
\tvoid eventNewServerState();
\tvoid eventSaveRemoteServerSettings(const FString&);
};''',
    '''class ENGINE_API AGameReplicationInfo : public AReplicationInfo
{
public:
\tDECLARE_CLASS(AGameReplicationInfo,AReplicationInfo,0|CLASS_Config|CLASS_NativeReplication,Engine)
\t// Event thunks
\tvoid eventNewServerState();
\tvoid eventSaveRemoteServerSettings(const FString&);
\t// Native C++ method declarations
\tvirtual void PostNetReceive();
\tvirtual INT* GetOptimizedRepList(BYTE*, FPropertyRetirement*, INT*, UPackageMap*, UActorChannel*);
};''',
    'AGameReplicationInfo: add PostNetReceive + GetOptimizedRepList')

# --- APlayerReplicationInfo: add missing method declarations ---
do_replace(
    '''class ENGINE_API APlayerReplicationInfo : public AReplicationInfo
{
public:
\tDECLARE_CLASS(APlayerReplicationInfo,AReplicationInfo,0|CLASS_NativeReplication,Engine)
};''',
    '''class ENGINE_API APlayerReplicationInfo : public AReplicationInfo
{
public:
\tDECLARE_CLASS(APlayerReplicationInfo,AReplicationInfo,0|CLASS_NativeReplication,Engine)
\tvirtual void PostNetReceive();
\tvirtual INT* GetOptimizedRepList(BYTE*, FPropertyRetirement*, INT*, UPackageMap*, UActorChannel*);
};''',
    'APlayerReplicationInfo: add PostNetReceive + GetOptimizedRepList')

# --- UDemoRecConnection: add missing method declarations ---
do_replace(
    '''class ENGINE_API UDemoRecConnection : public UNetConnection
{
public:
\tDECLARE_CLASS(UDemoRecConnection,UNetConnection,0,Engine)
\tNO_DEFAULT_CONSTRUCTOR(UDemoRecConnection)
};''',
    '''class ENGINE_API UDemoRecConnection : public UNetConnection
{
public:
\tDECLARE_CLASS(UDemoRecConnection,UNetConnection,0,Engine)
\tNO_DEFAULT_CONSTRUCTOR(UDemoRecConnection)
\tUDemoRecConnection(UNetDriver*, const FURL&);
\tvoid StaticConstructor();
\tvirtual FString LowLevelDescribe();
\tvirtual FString LowLevelGetRemoteAddress();
\tvirtual void LowLevelSend(void*, INT);
\tvirtual void FlushNet();
\tvirtual INT IsNetReady(INT);
\tvirtual void HandleClientPlayer(APlayerController*);
\tclass UDemoRecDriver* GetDriver();
};''',
    'UDemoRecConnection: add method declarations')

# --- UPackageMapLevel: add missing method declarations ---
do_replace(
    '''class ENGINE_API UPackageMapLevel : public UPackageMap
{
public:
\tDECLARE_CLASS(UPackageMapLevel,UPackageMap,0,Engine)
};''',
    '''class ENGINE_API UPackageMapLevel : public UPackageMap
{
public:
\tDECLARE_CLASS(UPackageMapLevel,UPackageMap,0,Engine)
\tUPackageMapLevel(UNetConnection*);
\tvirtual INT SerializeObject(FArchive&, UClass*, UObject*&);
\tvirtual INT CanSerializeObject(UObject*);
};''',
    'UPackageMapLevel: add method declarations')

# --- UControlChannel: add missing method declarations ---
do_replace(
    '''class ENGINE_API UControlChannel : public UChannel
{
public:
\tDECLARE_CLASS(UControlChannel,UChannel,0,Engine)''',
    '''class ENGINE_API UControlChannel : public UChannel
{
public:
\tDECLARE_CLASS(UControlChannel,UChannel,0,Engine)
\tUControlChannel() {}''',
    'UControlChannel: add default ctor',
    required=False)

# --- UTerrainPrimitive: add missing method declarations ---
do_replace(
    '''class ENGINE_API UTerrainPrimitive : public UPrimitive
{
public:
\tDECLARE_CLASS(UTerrainPrimitive,UPrimitive,0,Engine)
\tNO_DEFAULT_CONSTRUCTOR(UTerrainPrimitive)
};''',
    '''class ENGINE_API UTerrainPrimitive : public UPrimitive
{
public:
\tDECLARE_CLASS(UTerrainPrimitive,UPrimitive,0,Engine)
\tNO_DEFAULT_CONSTRUCTOR(UTerrainPrimitive)
\tUTerrainPrimitive(ATerrainInfo*);
\tvirtual void Serialize(FArchive&);
\tvirtual INT LineCheck(FCheckResult&, AActor*, FVector, FVector, FVector, DWORD, DWORD);
\tvirtual INT PointCheck(FCheckResult&, AActor*, FVector, FVector, DWORD);
\tvirtual void Illuminate(AActor*, INT);
\tFBox GetRenderBoundingBox(const AActor*, INT);
};''',
    'UTerrainPrimitive: add method declarations')

# --- UTerrainSector: add missing method declarations ---
do_replace(
    '''class ENGINE_API UTerrainSector : public UObject
{
public:
\tDECLARE_CLASS(UTerrainSector,UObject,0,Engine)
\tNO_DEFAULT_CONSTRUCTOR(UTerrainSector)
};''',
    '''class ENGINE_API UTerrainSector : public UObject
{
public:
\tDECLARE_CLASS(UTerrainSector,UObject,0,Engine)
\tNO_DEFAULT_CONSTRUCTOR(UTerrainSector)
\tUTerrainSector(ATerrainInfo*, INT, INT, INT, INT);
\tvirtual void Serialize(FArchive&);
\tvirtual void PostLoad();
\tvoid StaticLight(INT);
\tvoid GenerateTriangles();
\tINT GetGlobalVertex(INT, INT);
\tINT GetLocalVertex(INT, INT);
\tINT PassShouldRenderTriangle(INT, INT, INT, INT, INT);
\tINT IsSectorAll(INT, BYTE);
\tINT IsTriangleAll(INT, INT, INT, INT, INT, BYTE);
\tvoid AttachProjector(class AProjector*, FProjectorRenderInfo*);
};''',
    'UTerrainSector: add method declarations')

# --- FStaticMeshColorStream: add GetComponents ---
do_replace(
    '''class ENGINE_API FStaticMeshColorStream : public FVertexStream
{
public:
\tBYTE Pad[64];
\tFStaticMeshColorStream() { appMemzero(Pad, sizeof(Pad)); }
};''',
    '''class ENGINE_API FStaticMeshColorStream : public FVertexStream
{
public:
\tBYTE Pad[64];
\tFStaticMeshColorStream() { appMemzero(Pad, sizeof(Pad)); }
\tvirtual INT GetComponents(struct FVertexComponent*);
};''',
    'FStaticMeshColorStream: add GetComponents')

# --- UNetConnection::PostSend fix (PostSend takes INT in stub, void in header) ---
# Stub: ?PostSend@UNetConnection@@QAEXXZ -> void PostSend(void)
# Header: void PostSend( INT PacketId );
# The stub says NO parameter! Fix:
do_replace(
    '\tvoid PostSend( INT PacketId );',
    '\tvoid PostSend();',
    'UNetConnection::PostSend remove INT param')

# --- AR6AbstractClimbableObj: ctor access needs to be protected ---
# Stub: ??0AR6AbstractClimbableObj@@IAE@XZ -> protected ctor
do_replace(
    '''class AR6AbstractClimbableObj : public AActor
{
public:
\tDECLARE_CLASS(AR6AbstractClimbableObj,AActor,0,Engine)
\tAR6AbstractClimbableObj() {}''',
    '''class AR6AbstractClimbableObj : public AActor
{
public:
\tDECLARE_CLASS(AR6AbstractClimbableObj,AActor,0,Engine)
protected:
\tAR6AbstractClimbableObj() {}
public:''',
    'AR6AbstractClimbableObj: ctor -> protected')

# --- UR6AbstractTerroristMgr: ctor needs to be protected ---
# Stub: ??0UR6AbstractTerroristMgr@@IAE@XZ -> protected ctor
do_replace(
    '''class UR6AbstractTerroristMgr : public UObject
{
public:
\tDECLARE_CLASS(UR6AbstractTerroristMgr,UObject,0,Engine)
\tUR6AbstractTerroristMgr() {}''',
    '''class UR6AbstractTerroristMgr : public UObject
{
public:
\tDECLARE_CLASS(UR6AbstractTerroristMgr,UObject,0,Engine)
protected:
\tUR6AbstractTerroristMgr() {}
public:''',
    'UR6AbstractTerroristMgr: ctor -> protected')

# --- UMeshInstance: add default ctor ---
# It has  NO_DEFAULT_CONSTRUCTOR which makes ctor protected.
# But stub: ??0UMeshInstance@@QAE@XZ -> PUBLIC ctor
do_replace(
    '''class ENGINE_API UMeshInstance : public UPrimitive
{
public:
\tDECLARE_CLASS(UMeshInstance,UPrimitive,0,Engine)
\tNO_DEFAULT_CONSTRUCTOR(UMeshInstance)''',
    '''class ENGINE_API UMeshInstance : public UPrimitive
{
public:
\tDECLARE_CLASS(UMeshInstance,UPrimitive,0,Engine)
\tUMeshInstance() {}''',
    'UMeshInstance: NO_DEFAULT_CONSTRUCTOR -> public ctor')

# --- FConvexVolume: need to expand from forward declaration ---
# Check if it's just a forward decl
idx = content.find('class FConvexVolume;')
if idx >= 0:
    content = content.replace('class FConvexVolume;', 'class ENGINE_API FConvexVolume { public: BYTE Pad[256]; };', 1)
    changes += 1
    print('  OK: FConvexVolume: expand from forward decl')
else:
    # Check if it's already a full class
    idx2 = content.find('class FConvexVolume')
    if idx2 >= 0:
        print('  SKIP: FConvexVolume already defined')
    else:
        print('  WARN: FConvexVolume not found')

open(CLASSES_H, 'w').write(content)
print(f'\nTotal EngineClasses.h changes: {changes}')
print(f'Written {CLASSES_H}')
