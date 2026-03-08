/*===========================================================================
	EngineClasses.h: Ravenshield Engine class declarations.
	Reconstructed for decompilation — provides DECLARE_CLASS macros that
	IMPLEMENT_CLASS requires, plus the AUTOGENERATE_NAME / FUNCTION pattern.

	This file deliberately omits member variables (sizeof will be minimal).
	The runtime .u package metadata overrides PropertiesSize at load time.
===========================================================================*/
#if _MSC_VER
#pragma pack (push,4)
#endif

#ifndef ENGINE_API
#define ENGINE_API DLL_IMPORT
#endif

#ifndef NAMES_ONLY
#define AUTOGENERATE_NAME(name) extern ENGINE_API FName ENGINE_##name;
#define AUTOGENERATE_FUNCTION(cls,idx,name)
#endif

// Forward declarations for types used by generated method stubs
struct FProjectorRenderInfo;
struct MdtBaseConstraint;
class MotionChunk;
class UDemoRecDriver;
class FSpriteParticleVertex;
enum eDecalType : int;


/*==========================================================================
	AUTOGENERATE_NAME entries — RVS Engine FName tokens (211 names).
==========================================================================*/

AUTOGENERATE_NAME(AIHearSound)
AUTOGENERATE_NAME(Accept)
AUTOGENERATE_NAME(AcceptInventory)
AUTOGENERATE_NAME(ActionStart)
AUTOGENERATE_NAME(ActorEntered)
AUTOGENERATE_NAME(ActorEnteredVolume)
AUTOGENERATE_NAME(ActorLeaving)
AUTOGENERATE_NAME(ActorLeavingVolume)
AUTOGENERATE_NAME(AddCameraEffect)
AUTOGENERATE_NAME(AddInteraction)
AUTOGENERATE_NAME(AnimEnd)
AUTOGENERATE_NAME(Attach)
AUTOGENERATE_NAME(BaseChange)
AUTOGENERATE_NAME(BeginEvent)
AUTOGENERATE_NAME(BeginPlay)
AUTOGENERATE_NAME(BreathTimer)
AUTOGENERATE_NAME(Broadcast)
AUTOGENERATE_NAME(BroadcastLocalized)
AUTOGENERATE_NAME(BroadcastLocalizedMessage)
AUTOGENERATE_NAME(Bump)
AUTOGENERATE_NAME(CanPlayIntroVideo)
AUTOGENERATE_NAME(CanPlayOutroVideo)
AUTOGENERATE_NAME(ChangeAnimation)
AUTOGENERATE_NAME(ClientHearSound)
AUTOGENERATE_NAME(ClientMessage)
AUTOGENERATE_NAME(ClientPBKickedOutMessage)
AUTOGENERATE_NAME(ClientSetNewViewTarget)
AUTOGENERATE_NAME(ClientTravel)
AUTOGENERATE_NAME(ConnectionFailed)
AUTOGENERATE_NAME(ConvertKeyToLocalisation)
AUTOGENERATE_NAME(DemoPlaySound)
AUTOGENERATE_NAME(DeployWeaponBipod)
AUTOGENERATE_NAME(Destroyed)
AUTOGENERATE_NAME(Detach)
AUTOGENERATE_NAME(DetailChange)
AUTOGENERATE_NAME(EncroachedBy)
AUTOGENERATE_NAME(EncroachingOn)
AUTOGENERATE_NAME(EndClimbLadder)
AUTOGENERATE_NAME(EndCrouch)
AUTOGENERATE_NAME(EndEvent)
AUTOGENERATE_NAME(EndedRotation)
AUTOGENERATE_NAME(EnemyNotVisible)
AUTOGENERATE_NAME(EyePosition)
AUTOGENERATE_NAME(Falling)
AUTOGENERATE_NAME(FellOutOfWorld)
AUTOGENERATE_NAME(FinishedInterpolation)
AUTOGENERATE_NAME(ForceGenerate)
AUTOGENERATE_NAME(GMProcessMsg)
AUTOGENERATE_NAME(GainedChild)
AUTOGENERATE_NAME(GameEnding)
AUTOGENERATE_NAME(GameTypeUseNbOfTerroristToSpawn)
AUTOGENERATE_NAME(Generate)
AUTOGENERATE_NAME(GetBackgroundsRoot)
AUTOGENERATE_NAME(GetBeaconText)
AUTOGENERATE_NAME(GetCampaignDir)
AUTOGENERATE_NAME(GetDefaultCampaignDir)
AUTOGENERATE_NAME(GetGameTypeIndex)
AUTOGENERATE_NAME(GetGameTypeName)
AUTOGENERATE_NAME(GetIniFilesDir)
AUTOGENERATE_NAME(GetLocalLogFileName)
AUTOGENERATE_NAME(GetLocalPlayerIp)
AUTOGENERATE_NAME(GetMapsDir)
AUTOGENERATE_NAME(GetModKeyword)
AUTOGENERATE_NAME(GetModName)
AUTOGENERATE_NAME(GetNbMods)
AUTOGENERATE_NAME(GetReticuleInfo)
AUTOGENERATE_NAME(GetServerIni)
AUTOGENERATE_NAME(GetSkins)
AUTOGENERATE_NAME(GetStoreGamePwd)
AUTOGENERATE_NAME(GetVideosRoot)
AUTOGENERATE_NAME(GetViewRotation)
AUTOGENERATE_NAME(HandleServerMsg)
AUTOGENERATE_NAME(HeadVolumeChange)
AUTOGENERATE_NAME(HearNoise)
AUTOGENERATE_NAME(HitWall)
AUTOGENERATE_NAME(Init)
AUTOGENERATE_NAME(InitGame)
AUTOGENERATE_NAME(InitInputSystem)
AUTOGENERATE_NAME(InitModMgr)
AUTOGENERATE_NAME(InitMultiPlayerOptions)
AUTOGENERATE_NAME(Initialize)
AUTOGENERATE_NAME(Initialized)
AUTOGENERATE_NAME(IsGameTypePlayWithNonRainbowNPCs)
AUTOGENERATE_NAME(IsGoggles)
AUTOGENERATE_NAME(IsMissionPack)
AUTOGENERATE_NAME(IsPlayerPassiveSpectator)
AUTOGENERATE_NAME(IsRavenShield)
AUTOGENERATE_NAME(KApplyForce)
AUTOGENERATE_NAME(KForceExceed)
AUTOGENERATE_NAME(KImpact)
AUTOGENERATE_NAME(KSkelConvulse)
AUTOGENERATE_NAME(KVelDropBelow)
AUTOGENERATE_NAME(KeyFrameReached)
AUTOGENERATE_NAME(KilledBy)
AUTOGENERATE_NAME(Landed)
AUTOGENERATE_NAME(LaunchR6MainMenu)
AUTOGENERATE_NAME(LightUpdateDirect)
AUTOGENERATE_NAME(LogGameSpecial)
AUTOGENERATE_NAME(LogGameSpecial2)
AUTOGENERATE_NAME(LogThis)
AUTOGENERATE_NAME(Login)
AUTOGENERATE_NAME(LongFall)
AUTOGENERATE_NAME(LostChild)
AUTOGENERATE_NAME(MayFall)
AUTOGENERATE_NAME(MenuLoadProfile)
AUTOGENERATE_NAME(MonitoredPawnAlert)
AUTOGENERATE_NAME(NewServerState)
AUTOGENERATE_NAME(Notify)
AUTOGENERATE_NAME(NotifyAfterLevelChange)
AUTOGENERATE_NAME(NotifyBump)
AUTOGENERATE_NAME(NotifyHeadVolumeChange)
AUTOGENERATE_NAME(NotifyHitMover)
AUTOGENERATE_NAME(NotifyHitWall)
AUTOGENERATE_NAME(NotifyLanded)
AUTOGENERATE_NAME(NotifyLevelChange)
AUTOGENERATE_NAME(NotifyPhysicsVolumeChange)
AUTOGENERATE_NAME(PawnEnteredVolume)
AUTOGENERATE_NAME(PawnIsMoving)
AUTOGENERATE_NAME(PawnLeavingVolume)
AUTOGENERATE_NAME(PawnStoppedMoving)
AUTOGENERATE_NAME(PhysicsChangedFor)
AUTOGENERATE_NAME(PhysicsVolumeChange)
AUTOGENERATE_NAME(PlayDying)
AUTOGENERATE_NAME(PlayFalling)
AUTOGENERATE_NAME(PlayJump)
AUTOGENERATE_NAME(PlayLandingAnimation)
AUTOGENERATE_NAME(PlayWeaponAnimation)
AUTOGENERATE_NAME(PlayerCalcView)
AUTOGENERATE_NAME(PlayerInput)
AUTOGENERATE_NAME(PlayerSeesMe)
AUTOGENERATE_NAME(PlayerTick)
AUTOGENERATE_NAME(PostBeginPlay)
AUTOGENERATE_NAME(PostFadeRender)
AUTOGENERATE_NAME(PostLogin)
AUTOGENERATE_NAME(PostNetBeginPlay)
AUTOGENERATE_NAME(PostRender)
AUTOGENERATE_NAME(PostTeleport)
AUTOGENERATE_NAME(PostTouch)
AUTOGENERATE_NAME(PreBeginPlay)
AUTOGENERATE_NAME(PreClientTravel)
AUTOGENERATE_NAME(PreLogOut)
AUTOGENERATE_NAME(PreLogin)
AUTOGENERATE_NAME(PreTeleport)
AUTOGENERATE_NAME(PrepareForMove)
AUTOGENERATE_NAME(ProcessHeart)
AUTOGENERATE_NAME(Process_KeyEvent)
AUTOGENERATE_NAME(Process_KeyType)
AUTOGENERATE_NAME(Process_Message)
AUTOGENERATE_NAME(Process_PostRender)
AUTOGENERATE_NAME(Process_PreRender)
AUTOGENERATE_NAME(Process_Tick)
AUTOGENERATE_NAME(R6ConnectionFailed)
AUTOGENERATE_NAME(R6ConnectionInProgress)
AUTOGENERATE_NAME(R6ConnectionInterrupted)
AUTOGENERATE_NAME(R6ConnectionSuccess)
AUTOGENERATE_NAME(R6DeadEndedMoving)
AUTOGENERATE_NAME(R6MakeNoise)
AUTOGENERATE_NAME(R6ProgressMsg)
AUTOGENERATE_NAME(R6QueryCircumstantialAction)
AUTOGENERATE_NAME(ReceiveLocalizedMessage)
AUTOGENERATE_NAME(ReceivedEngineWeapon)
AUTOGENERATE_NAME(ReceivedWeapons)
AUTOGENERATE_NAME(RemoveCameraEffect)
AUTOGENERATE_NAME(RemoveInteraction)
AUTOGENERATE_NAME(RenderFirstPersonGun)
AUTOGENERATE_NAME(Reset)
AUTOGENERATE_NAME(RestartServer)
AUTOGENERATE_NAME(RunAll)
AUTOGENERATE_NAME(SaveAndResetData)
AUTOGENERATE_NAME(SaveRemoteServerSettings)
AUTOGENERATE_NAME(SceneEnded)
AUTOGENERATE_NAME(SceneStarted)
AUTOGENERATE_NAME(SeeMonster)
AUTOGENERATE_NAME(SeePlayer)
AUTOGENERATE_NAME(ServerDisconnected)
AUTOGENERATE_NAME(ServerTravel)
AUTOGENERATE_NAME(SetAnimAction)
AUTOGENERATE_NAME(SetCurrentMod)
AUTOGENERATE_NAME(SetFocusTo)
AUTOGENERATE_NAME(SetIdentifyTarget)
AUTOGENERATE_NAME(SetInitialState)
AUTOGENERATE_NAME(SetMatchResult)
AUTOGENERATE_NAME(SetProgressTime)
AUTOGENERATE_NAME(SetWalking)
AUTOGENERATE_NAME(ShowUpgradeMenu)
AUTOGENERATE_NAME(ShowWeaponParticules)
AUTOGENERATE_NAME(SpecialCost)
AUTOGENERATE_NAME(SpecialHandling)
AUTOGENERATE_NAME(Spawned)
AUTOGENERATE_NAME(StartCrouch)
AUTOGENERATE_NAME(StopAnimForRG)
AUTOGENERATE_NAME(StopPlayFiring)
AUTOGENERATE_NAME(SuggestMovePreparation)
AUTOGENERATE_NAME(TeamMessage)
AUTOGENERATE_NAME(Tick)
AUTOGENERATE_NAME(Timer)
AUTOGENERATE_NAME(ToggleRadar)
AUTOGENERATE_NAME(TornOff)
AUTOGENERATE_NAME(Touch)
AUTOGENERATE_NAME(TravelPostAccept)
AUTOGENERATE_NAME(TravelPreAccept)
AUTOGENERATE_NAME(Trigger)
AUTOGENERATE_NAME(TriggerEvent)
AUTOGENERATE_NAME(UnTouch)
AUTOGENERATE_NAME(UnTrigger)
AUTOGENERATE_NAME(UpdateServer)
AUTOGENERATE_NAME(UpdateShadow)
AUTOGENERATE_NAME(UpdateWeaponAttachment)
AUTOGENERATE_NAME(UsedBy)
AUTOGENERATE_NAME(UserDisconnected)
AUTOGENERATE_NAME(WorldSpaceOverlays)
AUTOGENERATE_NAME(ZoneChange)

#ifndef NAMES_ONLY

/*==========================================================================
	Forward declarations.
==========================================================================*/

class AActor;
class APawn;
class AController;
class APlayerController;
class ABrush;
class AVolume;
class AInfo;
class AZoneInfo;
class ALevelInfo;
class AGameInfo;
class AHUD;
class UCanvas;
class ULevel;
class ULevelBase;
class UModel;
class UPolys;
class UMesh;
class ULodMesh;
class USkeletalMesh;
class USkeletalMeshInstance;
class UStaticMesh;
class UStaticMeshInstance;
class UMeshInstance;
class URenderResource;
class UMaterial;
class UTexture;
class USound;
class UMusic;
class UAudioSubsystem;
class URenderDevice;
class UNetDriver;
class UNetConnection;
class UChannel;
class UPlayer;
class AEmitter;
class AProjector;
class ANavigationPoint;
class AJumpPad;
class AJumpDest;
class ALadder;
class ALiftCenter;
class APlayerStart;
class ATeleporter;
class AWarpZoneMarker;
class APathNode;
class ADoor;
class AMover;
class ALadderVolume;
class AFluidSurfaceInfo;
class ASceneManager;
class ATerrainInfo;
class UReachSpec;
class UViewport;
class UPendingLevel;
class UEngine;
class UGameEngine;
class FCollisionHash;
class FPoly;
class FSortedPathList;
class FRenderInterface;
class FRenderCaps;
class FLevelSceneNode;
class FDynamicActor;
class FBaseTexture;
class FBitReader;
class FOutBunch;
class FInBunch;
class FHitCause;
struct FOrientation;
class UMatAction;
class UClient;
class UBitmapMaterial;
class UPrimitive;
struct HHitProxy;
struct FDXTCompressionOptions;

// ---------------------------------------------------------------------------
// EPhysics — physics modes for actors.
// ---------------------------------------------------------------------------
enum EPhysics
{
	PHYS_None=0,
	PHYS_Walking=1,
	PHYS_Falling=2,
	PHYS_Swimming=3,
	PHYS_Flying=4,
	PHYS_Rotating=5,
	PHYS_Projectile=6,
	PHYS_Interpolating=7,
	PHYS_MovingBrush=8,
	PHYS_Spider=9,
	PHYS_Trailer=10,
	PHYS_Ladder=11,
	PHYS_RootMotion=12,
	PHYS_Karma=13,
	PHYS_KarmaRagDoll=14,
};

enum ETestMoveResult
{
	TESTMOVE_Stopped=0,
	TESTMOVE_Moved=1,
	TESTMOVE_Fell=2,
};

// ---------------------------------------------------------------------------
// EInputKey — keyboard / mouse / joystick virtual key codes.
// Used by UViewport::CauseInputEvent and related input dispatch functions.
// Ordinals match the retail Engine.dll/WinDrv.dll ABI (CSDK EngineClasses.h).
// ---------------------------------------------------------------------------
enum EInputKey
{
	IK_None=0, IK_LeftMouse=1, IK_RightMouse=2, IK_Cancel=3,
	IK_MiddleMouse=4, IK_Backspace=8, IK_Tab=9, IK_Enter=13,
	IK_Shift=16, IK_Ctrl=17, IK_Alt=18, IK_Pause=19, IK_CapsLock=20,
	IK_Escape=27, IK_Space=32, IK_PageUp=33, IK_PageDown=34,
	IK_End=35, IK_Home=36, IK_Left=37, IK_Up=38, IK_Right=39, IK_Down=40,
	IK_PrintScrn=44, IK_Insert=45, IK_Delete=46,
	IK_0=48,IK_1=49,IK_2=50,IK_3=51,IK_4=52,
	IK_5=53,IK_6=54,IK_7=55,IK_8=56,IK_9=57,
	IK_A=65,IK_B=66,IK_C=67,IK_D=68,IK_E=69,IK_F=70,
	IK_G=71,IK_H=72,IK_I=73,IK_J=74,IK_K=75,IK_L=76,
	IK_M=77,IK_N=78,IK_O=79,IK_P=80,IK_Q=81,IK_R=82,
	IK_S=83,IK_T=84,IK_U=85,IK_V=86,IK_W=87,IK_X=88,
	IK_Y=89,IK_Z=90,
	IK_NumPad0=96,IK_NumPad1=97,IK_NumPad2=98,IK_NumPad3=99,
	IK_NumPad4=100,IK_NumPad5=101,IK_NumPad6=102,IK_NumPad7=103,
	IK_NumPad8=104,IK_NumPad9=105,
	IK_F1=112,IK_F2=113,IK_F3=114,IK_F4=115,IK_F5=116,
	IK_F6=117,IK_F7=118,IK_F8=119,IK_F9=120,IK_F10=121,
	IK_F11=122,IK_F12=123,
	IK_NumLock=144, IK_ScrollLock=145,
	IK_LShift=160, IK_RShift=161, IK_LControl=162, IK_RControl=163,
	IK_Joy1=200,IK_Joy2=201,IK_Joy3=202,IK_Joy4=203,
	IK_JoyX=224,IK_JoyY=225,IK_JoyZ=226,IK_JoyR=227,
	IK_MouseX=228,IK_MouseY=229,IK_MouseZ=230,IK_MouseW=231,
	IK_JoyU=232,IK_JoyV=233,
	IK_MouseWheelUp=236,IK_MouseWheelDown=237
};

// ---------------------------------------------------------------------------
// EInputAction — input event type (press, hold, release, axis).
// ---------------------------------------------------------------------------
enum EInputAction
{
	IST_None=0, IST_Press=1, IST_Hold=2, IST_Release=3, IST_Axis=4
};

/*==========================================================================
	Minimal struct types needed by Engine globals.
	Full member layouts will be added as runtime correctness improves.
==========================================================================*/

class ENGINE_API FEngineStats  { public: BYTE Pad[256]; FEngineStats() { appMemzero(this, sizeof(*this)); } };
class ENGINE_API FStats        { public: BYTE Pad[256]; FStats()       { appMemzero(this, sizeof(*this)); } };

// FRebuildTools — BSP rebuild configuration manager.
class ENGINE_API FRebuildTools
{
public:
	BYTE Pad[64];
	FRebuildTools() { appMemzero(this, sizeof(*this)); }
	FRebuildTools(const FRebuildTools&);
	~FRebuildTools();
	void Init();
	void Shutdown();
	void SetCurrent(FString);
	void Delete(FString);
	class FRebuildOptions* GetCurrent();
	class FRebuildOptions* GetFromName(FString);
	INT GetIdxFromName(FString);
	class FRebuildOptions* Save(FString);
};

// FMatineeTools — cinematic action sequencing tools.
class ENGINE_API FMatineeTools
{
public:
	BYTE Pad[60]; // 60 + 4(vptr) = 64 bytes total
	FMatineeTools() { appMemzero(Pad, sizeof(Pad)); }
	FMatineeTools(const FMatineeTools&);
	virtual ~FMatineeTools();
	void Init();
	ASceneManager* SetCurrent(UEngine*, ULevel*, ASceneManager*);
	ASceneManager* SetCurrent(UEngine*, ULevel*, FString);
	UMatAction* SetCurrentAction(UMatAction*);
	class UMatSubAction* SetCurrentSubAction(class UMatSubAction*);
	ASceneManager* GetCurrent();
	UMatAction* GetCurrentAction();
	class UMatSubAction* GetCurrentSubAction();
	UMatAction* GetNextAction(ASceneManager*, UMatAction*);
	UMatAction* GetNextMovementAction(ASceneManager*, UMatAction*);
	FString GetOrientationDesc(INT);
	INT GetPathStyle(UMatAction*);
	UMatAction* GetPrevAction(ASceneManager*, UMatAction*);
	void GetSamples(ASceneManager*, UMatAction*, TArray<FVector>*);
	INT GetSubActionIdx(class UMatSubAction*);
	INT GetActionIdx(ASceneManager*, UMatAction*);
};

// FTerrainTools — terrain editing tools.
class ENGINE_API FTerrainTools
{
public:
	BYTE Pad[60]; // 60 + 4(vptr) = 64 bytes total
	FTerrainTools() { appMemzero(Pad, sizeof(Pad)); }
	FTerrainTools(const FTerrainTools&);
	virtual ~FTerrainTools();
	void Init();
	void SetAdjust(INT);
	void SetCurrentBrush(INT);
	void SetCurrentTerrainInfo(ATerrainInfo*);
	void SetFloorOffset(INT);
	void SetInnerRadius(INT);
	void SetMirrorAxis(INT);
	void SetOuterRadius(INT);
	void SetStrength(INT);
	void AdjustAlignedActors();
	void FindActorsToAlign();
	INT GetAdjust();
	ATerrainInfo* GetCurrentTerrainInfo();
	FString GetExecFromBrushName(FString&);
	INT GetFloorOffset();
	INT GetInnerRadius();
	INT GetMirrorAxis();
	INT GetOuterRadius();
	INT GetStrength();
};

// Pointer-only types — forward declarations sufficient.
class FTempLineBatcher;
struct STDbgLine;
struct FVertexComponent;
class FConvexVolume;
class FVisibilityInterface;
class FRebuildOptions;
class UCubemap;
class UAnimNotify;
class UMeshAnimation;
class UConsole;
class UCameraEffect;
class UMotionBlur;
class UCameraOverlay;
class UProxyBitmapMaterial;
class UShadowBitmapMaterial;
class UParticleMaterial;
class UParticleEmitter;
class UInteraction;
class AEmitter;
class AKConstraint;
class AKHinge;
class AScout;
class APhysicsVolume;
class AR6ColBox;
class AR6eviLTesting;
class UDownload;
class UBinaryFileDownload;
class UFileChannel;
class UKMeshProps;
class UVertexBuffer;
class UVertexStreamCOLOR;
class UVertexStreamPosNormTex;
class UVertexStreamUV;
class UVertexStreamVECTOR;
class UPolys;
class ULevelSummary;
class UPackageMap;
class CBoneDescData;
class UR6AbstractGameManager;
class UShader;
class UCameraEffect;

// ---------------------------------------------------------------------------
// Enums needed by rendering interfaces.
// ---------------------------------------------------------------------------
enum ETexClampMode { TC_Wrap=0, TC_Clamp=1 };
enum ETextureFormat
{
	TEXF_P8      = 0,
	TEXF_BGRA8   = 1,
	TEXF_RGBA8   = 2,
	TEXF_RGB8    = 3,
	TEXF_BGR8    = 4,
	TEXF_BCRGB8  = 5,
	TEXF_DXT1    = 6,
	TEXF_RGB16   = 7,
	TEXF_DXT3    = 8,
	TEXF_DXT5    = 9,
	TEXF_L8      = 10,
	TEXF_LA8     = 11,
	TEXF_A1      = 14,
	TEXF_A8      = 15
};
template<class T> class TList;
class FCylinder;
enum EPrimitiveType { PT_TriangleList=0, PT_TriangleStrip=1, PT_TriangleFan=2, PT_PointList=3, PT_LineList=4 };
enum ERenderStyle { STY_None=0, STY_Normal=1, STY_Masked=2, STY_Translucent=3, STY_Modulated=4, STY_Alpha=5, STY_Additive=6, STY_Subtractive=7, STY_Particle=8, STY_AlphaZ=9 };
enum ETextureArithOp { TAO_Add=0, TAO_Subtract=1, TAO_Multiply=2, TAO_Divide=3 };
enum ETerrainRenderMethod { TRM_Normal=0, TRM_PerPixelDetail=1, TRM_PerPixelLighting=2 };
enum ENoiseType { NOISE_None=0, NOISE_Footstep=1, NOISE_Weapon=2, NOISE_Explosion=3 };
enum EPawnType { PAWN_None=0, PAWN_Player=1, PAWN_Bot=2 };
enum ESoundType { SOUND_None=0, SOUND_Speech=1, SOUND_Effect=2, SOUND_Music=3, SOUND_Ambient=4 };
enum EDrawType { DT_None=0, DT_Sprite=1, DT_Mesh=2, DT_Brush=3, DT_RopeSprite=4, DT_VerticalSprite=5, DT_Terraform=6, DT_SpriteAnimOnce=7, DT_StaticMesh=8, DT_DrawType=9, DT_Particle=10, DT_AntiPortal=11, DT_FluidSurface=12 };
enum ER6SwitchSurface { R6SS_None=0 };
enum eGameVideoType { GVT_None=0 };

// ---------------------------------------------------------------------------
// FVertexStream — abstract base for vertex buffer data.
// ---------------------------------------------------------------------------
class ENGINE_API FVertexStream
{
public:
	~FVertexStream() {}
	virtual QWORD GetCacheId() = 0;
	virtual INT GetRevision() = 0;
	virtual INT GetComponents(FVertexComponent*) = 0;
	virtual void GetStreamData(void*) = 0;
	virtual void GetRawStreamData(void**, INT) = 0;
	virtual INT GetSize() = 0;
	virtual INT GetStride() = 0;
};

// ---------------------------------------------------------------------------
// FIndexBuffer — abstract base for index buffer data.
// ---------------------------------------------------------------------------
class ENGINE_API FIndexBuffer
{
public:
	~FIndexBuffer() {}
	virtual QWORD GetCacheId() = 0;
	virtual INT GetRevision() = 0;
	virtual INT GetSize() = 0;
	virtual INT GetIndexSize() = 0;
	virtual void GetContents(void*) = 0;
};

// ---------------------------------------------------------------------------
// FBaseTexture / FTexture — abstract base for texture interfaces.
// ---------------------------------------------------------------------------
class ENGINE_API FTexture
{
public:
	~FTexture() {}
	virtual QWORD GetCacheId() { return 0; }
	virtual INT GetRevision() { return 0; }
	virtual INT GetWidth() { return 0; }
	virtual INT GetHeight() { return 0; }
	virtual INT GetNumMips() { return 0; }
	virtual INT GetFirstMip() { return 0; }
	virtual ETextureFormat GetFormat() { return TEXF_P8; }
	virtual ETexClampMode GetUClamp() { return TC_Wrap; }
	virtual ETexClampMode GetVClamp() { return TC_Wrap; }
	virtual void* GetRawTextureData(INT) { return NULL; }
	virtual void GetTextureData(INT, void*, INT, ETextureFormat, INT) {}
	virtual UTexture* GetUTexture() { return NULL; }
};

// ---------------------------------------------------------------------------
// FStatGraph — performance graph rendering.
// ---------------------------------------------------------------------------
class ENGINE_API FStatGraph
{
public:
	BYTE Pad[256];
	FStatGraph() { appMemzero(Pad, sizeof(Pad)); }
	FStatGraph(const FStatGraph&);
	~FStatGraph();
	FStatGraph& operator=(const FStatGraph&);
	void Reset();
	void Render(UViewport*, FRenderInterface*);
	void AddDataPoint(FString, FLOAT, INT);
	void AddLine(FString, FColor, FLOAT, FLOAT);
	void AddLineAutoRange(FString, FColor);
	INT Exec(const TCHAR*, FOutputDevice&);
};

// ===========================================================================
// Concrete Vertex Stream implementations.
// ===========================================================================

class ENGINE_API FLineBatcher : public FVertexStream
{
public:
	BYTE Pad[128];
	FLineBatcher(FRenderInterface*, INT, INT);
	FLineBatcher(const FLineBatcher&);
	~FLineBatcher();
	FLineBatcher& operator=(const FLineBatcher&);
	void DrawBox(FBox, FColor);
	void DrawCircle(FVector, FVector, FVector, FColor, FLOAT, INT);
	void DrawConvexVolume(FConvexVolume, FColor);
	void DrawCylinder(FRenderInterface*, FVector, FVector, FVector, FVector, FColor, FLOAT, FLOAT, INT);
	void DrawDirectionalArrow(FVector, FRotator, FColor, FLOAT);
	void DrawLine(FVector, FVector, FColor);
	void DrawPoint(class FSceneNode*, FVector, FColor);
	void DrawSphere(FVector, FColor, FLOAT, INT);
	void Flush(DWORD);
	// FVertexStream
	virtual QWORD GetCacheId();
	virtual INT GetRevision();
	virtual INT GetComponents(FVertexComponent*);
	virtual void GetStreamData(void*);
	virtual void GetRawStreamData(void**, INT);
	virtual INT GetSize();
	virtual INT GetStride();
};

class ENGINE_API FCanvasUtil : public FVertexStream
{
public:
	BYTE Pad[128];
	FCanvasUtil(UViewport*, FRenderInterface*, INT, INT);
	FCanvasUtil(const FCanvasUtil&);
	~FCanvasUtil();
	FCanvasUtil& operator=(const FCanvasUtil&);
	void BeginPrimitive(EPrimitiveType, UMaterial*);
	void DrawLine(FLOAT, FLOAT, FLOAT, FLOAT, FColor);
	void DrawPoint(FLOAT, FLOAT, FLOAT, FLOAT, FLOAT, FColor);
	void DrawTile(FLOAT, FLOAT, FLOAT, FLOAT, FLOAT, FLOAT, FLOAT, FLOAT, FLOAT, UMaterial*, FColor);
	void DrawTileRotated(FLOAT, FLOAT, FLOAT, FLOAT, FLOAT, FLOAT, FLOAT, FLOAT, FLOAT, UMaterial*, FColor, FLOAT);
	void Flush();
	// FVertexStream
	virtual QWORD GetCacheId();
	virtual INT GetRevision();
	virtual INT GetComponents(FVertexComponent*);
	virtual void GetStreamData(void*);
	virtual void GetRawStreamData(void**, INT);
	virtual INT GetSize();
	virtual INT GetStride();
};

class ENGINE_API FBspVertexStream : public FVertexStream
{
public:
	BYTE Pad[64];
	FBspVertexStream();
	FBspVertexStream(const FBspVertexStream&);
	~FBspVertexStream();
	FBspVertexStream& operator=(const FBspVertexStream&);
	virtual QWORD GetCacheId();
	virtual INT GetRevision();
	virtual INT GetComponents(FVertexComponent*);
	virtual void GetStreamData(void*);
	virtual void GetRawStreamData(void**, INT);
	virtual INT GetSize();
	virtual INT GetStride();
};

class ENGINE_API FRawColorStream : public FVertexStream
{
public:
	BYTE Pad[64];
	FRawColorStream();
	FRawColorStream(const FRawColorStream&);
	~FRawColorStream();
	FRawColorStream& operator=(const FRawColorStream&);
	virtual QWORD GetCacheId();
	virtual INT GetRevision();
	virtual INT GetComponents(FVertexComponent*);
	virtual void GetStreamData(void*);
	virtual void GetRawStreamData(void**, INT);
	virtual INT GetSize();
	virtual INT GetStride();
};

class ENGINE_API FSkinVertexStream : public FVertexStream
{
public:
	BYTE Pad[64];
	FSkinVertexStream();
	FSkinVertexStream(const FSkinVertexStream&);
	~FSkinVertexStream();
	FSkinVertexStream& operator=(const FSkinVertexStream&);
	virtual QWORD GetCacheId();
	virtual INT GetRevision();
	virtual INT GetComponents(FVertexComponent*);
	virtual void GetStreamData(void*);
	virtual void GetRawStreamData(void**, INT);
	virtual INT GetSize();
	virtual INT GetStride();
};

class ENGINE_API FStaticMeshUVStream : public FVertexStream
{
public:
	BYTE Pad[64];
	FStaticMeshUVStream();
	FStaticMeshUVStream(const FStaticMeshUVStream&);
	~FStaticMeshUVStream();
	FStaticMeshUVStream& operator=(const FStaticMeshUVStream&);
	virtual QWORD GetCacheId();
	virtual INT GetRevision();
	virtual INT GetComponents(FVertexComponent*);
	virtual void GetStreamData(void*);
	virtual void GetRawStreamData(void**, INT);
	virtual INT GetSize();
	virtual INT GetStride();
};

class ENGINE_API FStaticMeshVertexStream : public FVertexStream
{
public:
	BYTE Pad[64];
	FStaticMeshVertexStream();
	FStaticMeshVertexStream(const FStaticMeshVertexStream&);
	~FStaticMeshVertexStream();
	FStaticMeshVertexStream& operator=(const FStaticMeshVertexStream&);
	virtual QWORD GetCacheId();
	virtual INT GetRevision();
	virtual INT GetComponents(FVertexComponent*);
	virtual void GetStreamData(void*);
	virtual void GetRawStreamData(void**, INT);
	virtual INT GetSize();
	virtual INT GetStride();
};

class ENGINE_API FAnimMeshVertexStream : public FVertexStream
{
public:
	BYTE Pad[64];
	FAnimMeshVertexStream();
	FAnimMeshVertexStream(const FAnimMeshVertexStream&);
	~FAnimMeshVertexStream();
	FAnimMeshVertexStream& operator=(const FAnimMeshVertexStream&);
	virtual INT SetPartialSize(INT);
	virtual QWORD GetCacheId();
	virtual INT GetRevision();
	virtual INT GetComponents(FVertexComponent*);
	virtual INT GetPartialSize();
	virtual void GetStreamData(void*);
	virtual void GetRawStreamData(void**, INT);
	virtual INT GetSize();
	virtual INT GetStride();
};

class ENGINE_API FStaticMeshColorStream : public FVertexStream
{
public:
	BYTE Pad[64];
	FStaticMeshColorStream() { appMemzero(Pad, sizeof(Pad)); }
};

// ===========================================================================
// Concrete Index Buffer implementations.
// ===========================================================================

class ENGINE_API FRawIndexBuffer : public FIndexBuffer
{
public:
	BYTE Pad[64];
	FRawIndexBuffer();
	FRawIndexBuffer(const FRawIndexBuffer&);
	~FRawIndexBuffer();
	FRawIndexBuffer& operator=(const FRawIndexBuffer&);
	virtual void CacheOptimize();
	virtual QWORD GetCacheId();
	virtual INT GetRevision();
	virtual INT GetSize();
	virtual INT GetIndexSize();
	virtual void GetContents(void*);
	virtual INT Stripify();
};

class ENGINE_API FRaw32BitIndexBuffer : public FIndexBuffer
{
public:
	BYTE Pad[64];
	FRaw32BitIndexBuffer();
	FRaw32BitIndexBuffer(const FRaw32BitIndexBuffer&);
	~FRaw32BitIndexBuffer();
	FRaw32BitIndexBuffer& operator=(const FRaw32BitIndexBuffer&);
	virtual QWORD GetCacheId();
	virtual INT GetRevision();
	virtual INT GetSize();
	virtual INT GetIndexSize();
	virtual void GetContents(void*);
};

// ===========================================================================
// Concrete Texture wrapper implementations.
// ===========================================================================

class ENGINE_API FLightMap : public FTexture
{
public:
	BYTE Pad[128];
	FLightMap();
	FLightMap(ULevel*, INT, INT);
	FLightMap(const FLightMap&);
	~FLightMap();
	FLightMap& operator=(const FLightMap&);
	virtual QWORD GetCacheId();
	virtual INT GetRevision();
	virtual INT GetWidth();
	virtual INT GetHeight();
	virtual INT GetNumMips();
	virtual INT GetFirstMip();
	virtual ETextureFormat GetFormat();
	virtual ETexClampMode GetUClamp();
	virtual ETexClampMode GetVClamp();
	virtual void* GetRawTextureData(INT);
	virtual void GetTextureData(INT, void*, INT, ETextureFormat, INT);
	virtual UTexture* GetUTexture();
};

class ENGINE_API FLightMapTexture : public FTexture
{
public:
	BYTE Pad[128];
	FLightMapTexture();
	FLightMapTexture(ULevel*);
	FLightMapTexture(const FLightMapTexture&);
	~FLightMapTexture();
	FLightMapTexture& operator=(const FLightMapTexture&);
	virtual FTexture* GetChild(INT, INT*, INT*);
	virtual INT GetNumChildren();
	virtual QWORD GetCacheId();
	virtual INT GetRevision();
	virtual INT GetWidth();
	virtual INT GetHeight();
	virtual INT GetNumMips();
	virtual INT GetFirstMip();
	virtual ETextureFormat GetFormat();
	virtual ETexClampMode GetUClamp();
	virtual ETexClampMode GetVClamp();
};

class ENGINE_API FStaticLightMapTexture : public FTexture
{
public:
	BYTE Pad[128];
	FStaticLightMapTexture();
	FStaticLightMapTexture(const FStaticLightMapTexture&);
	~FStaticLightMapTexture();
	FStaticLightMapTexture& operator=(const FStaticLightMapTexture&);
	virtual QWORD GetCacheId();
	virtual INT GetRevision();
	virtual INT GetWidth();
	virtual INT GetHeight();
	virtual INT GetNumMips();
	virtual INT GetFirstMip();
	virtual ETextureFormat GetFormat();
	virtual ETexClampMode GetUClamp();
	virtual ETexClampMode GetVClamp();
	virtual void* GetRawTextureData(INT);
	virtual void GetTextureData(INT, void*, INT, ETextureFormat, INT);
	virtual UTexture* GetUTexture();
};

class ENGINE_API FStaticTexture : public FTexture
{
public:
	BYTE Pad[64];
	FStaticTexture(UTexture*);
	FStaticTexture(const FStaticTexture&);
	FStaticTexture& operator=(const FStaticTexture&);
	virtual QWORD GetCacheId();
	virtual INT GetRevision();
	virtual INT GetWidth();
	virtual INT GetHeight();
	virtual INT GetNumMips();
	virtual INT GetFirstMip();
	virtual ETextureFormat GetFormat();
	virtual ETexClampMode GetUClamp();
	virtual ETexClampMode GetVClamp();
	virtual void* GetRawTextureData(INT);
	virtual void GetTextureData(INT, void*, INT, ETextureFormat, INT);
	virtual UTexture* GetUTexture();
};

class ENGINE_API FStaticCubemap
{
public:
	BYTE Pad[64];
	FStaticCubemap(UCubemap*);
	FStaticCubemap(const FStaticCubemap&);
	FStaticCubemap& operator=(const FStaticCubemap&);
	virtual FTexture* GetFace(INT);
	virtual QWORD GetCacheId();
	virtual INT GetRevision();
	virtual INT GetWidth();
	virtual INT GetHeight();
	virtual INT GetNumMips();
	virtual INT GetFirstMip();
	virtual ETextureFormat GetFormat();
	virtual ETexClampMode GetUClamp();
	virtual ETexClampMode GetVClamp();
};

// ===========================================================================
// Collision system classes.
// ===========================================================================

class ENGINE_API FCollisionHashBase
{
public:
	virtual ~FCollisionHashBase() {}
	virtual void AddActor(AActor*) = 0;
	virtual void RemoveActor(AActor*) = 0;
	virtual FCheckResult* ActorLineCheck(FMemStack&, FVector, FVector, FVector, DWORD, DWORD, AActor*) = 0;
	virtual FCheckResult* ActorPointCheck(FMemStack&, FVector, FVector, DWORD, DWORD, INT, AActor*) = 0;
	virtual FCheckResult* ActorRadiusCheck(FMemStack&, FVector, FLOAT, DWORD) = 0;
	virtual FCheckResult* ActorEncroachmentCheck(FMemStack&, AActor*, FVector, FRotator, DWORD, DWORD) = 0;
	virtual FCheckResult* ActorOverlapCheck(FMemStack&, AActor*, FBox*, INT) = 0;
	virtual void CheckActorLocations(ULevel*) = 0;
	virtual void CheckActorNotReferenced(AActor*) = 0;
	virtual void CheckIsEmpty() = 0;
	virtual void Tick() = 0;
};

class ENGINE_API FCollisionHash : public FCollisionHashBase
{
public:
	struct FCollisionLink { BYTE Pad[32]; };
	BYTE Pad[256];
	static INT CollisionTag;
	static INT* HashX;
	static INT* HashY;
	static INT* HashZ;
	static INT Inited;
	FCollisionHash();
	FCollisionHash(const FCollisionHash&);
	virtual ~FCollisionHash();
	FCollisionHash& operator=(const FCollisionHash&);
	void GetActorExtent(AActor*, INT&, INT&, INT&, INT&, INT&, INT&);
	void GetHashIndices(FVector, INT&, INT&, INT&);
	FCollisionLink*& GetHashLink(INT, INT, INT, INT&);
	virtual void AddActor(AActor*);
	virtual void RemoveActor(AActor*);
	virtual FCheckResult* ActorLineCheck(FMemStack&, FVector, FVector, FVector, DWORD, DWORD, AActor*);
	virtual FCheckResult* ActorPointCheck(FMemStack&, FVector, FVector, DWORD, DWORD, INT, AActor*);
	virtual FCheckResult* ActorRadiusCheck(FMemStack&, FVector, FLOAT, DWORD);
	virtual FCheckResult* ActorEncroachmentCheck(FMemStack&, AActor*, FVector, FRotator, DWORD, DWORD);
	virtual FCheckResult* ActorOverlapCheck(FMemStack&, AActor*, FBox*, INT);
	virtual void CheckActorLocations(ULevel*);
	virtual void CheckActorNotReferenced(AActor*);
	virtual void CheckIsEmpty();
	virtual void Tick();
private:
	FLOAT DistanceToHashPlane(INT, FLOAT, FLOAT, INT);
};

class ENGINE_API FCollisionOctree : public FCollisionHashBase
{
public:
	BYTE Pad[256];
	FCollisionOctree();
	FCollisionOctree(const FCollisionOctree&);
	virtual ~FCollisionOctree();
	FCollisionOctree& operator=(const FCollisionOctree&);
	virtual void AddActor(AActor*);
	virtual void RemoveActor(AActor*);
	virtual FCheckResult* ActorLineCheck(FMemStack&, FVector, FVector, FVector, DWORD, DWORD, AActor*);
	virtual FCheckResult* ActorPointCheck(FMemStack&, FVector, FVector, DWORD, DWORD, INT, AActor*);
	virtual FCheckResult* ActorRadiusCheck(FMemStack&, FVector, FLOAT, DWORD);
	virtual FCheckResult* ActorEncroachmentCheck(FMemStack&, AActor*, FVector, FRotator, DWORD, DWORD);
	virtual FCheckResult* ActorOverlapCheck(FMemStack&, AActor*, FBox*, INT);
	virtual void CheckActorLocations(ULevel*);
	virtual void CheckActorNotReferenced(AActor*);
	virtual void CheckIsEmpty();
	virtual void Tick();
};

class ENGINE_API FOctreeNode
{
public:
	BYTE Pad[64];
	FOctreeNode();
	FOctreeNode(const FOctreeNode&);
	~FOctreeNode();
	FOctreeNode& operator=(const FOctreeNode&);
	void SingleNodeFilter(AActor*, FCollisionOctree*, const FPlane*);
	void MultiNodeFilter(AActor*, FCollisionOctree*, const FPlane*);
	void RemoveAllActors(FCollisionOctree*);
	void ActorEncroachmentCheck(FCollisionOctree*, const FPlane*);
	void ActorNonZeroExtentLineCheck(FCollisionOctree*, const FPlane*);
	void ActorOverlapCheck(FCollisionOctree*, const FPlane*);
	void ActorPointCheck(FCollisionOctree*, const FPlane*, AActor*);
	void ActorRadiusCheck(FCollisionOctree*, const FPlane*);
	void ActorZeroExtentLineCheck(FCollisionOctree*, FLOAT, FLOAT, FLOAT, FLOAT, FLOAT, FLOAT, const FPlane*);
	void CheckActorNotReferenced(AActor*);
	void CheckIsEmpty();
	void Draw(FColor, INT, const FPlane*);
	void DrawFlaggedActors(FCollisionOctree*, const FPlane*);
	void FilterTest(FBox*, INT, TArray<FOctreeNode*>*, const FPlane*);
private:
	void StoreActor(AActor*, FCollisionOctree*, const FPlane*);
};

// ===========================================================================
// Scene node classes.
// ===========================================================================

class ENGINE_API FSceneNode
{
public:
	BYTE Pad[512];
	FSceneNode(UViewport*);
	FSceneNode(FSceneNode*);
	FSceneNode(const FSceneNode&);
	virtual ~FSceneNode();
	FSceneNode& operator=(const FSceneNode&);
	FPlane Project(FVector);
	FVector Deproject(FPlane);
	virtual class FActorSceneNode* GetActorSceneNode();
	virtual class FCameraSceneNode* GetCameraSceneNode();
	virtual FLevelSceneNode* GetLevelSceneNode();
	virtual class FMirrorSceneNode* GetMirrorSceneNode();
	virtual class FSkySceneNode* GetSkySceneNode();
	virtual class FWarpZoneSceneNode* GetWarpZoneSceneNode();
};

class ENGINE_API FLevelSceneNode : public FSceneNode
{
public:
	FLevelSceneNode(UViewport*);
	FLevelSceneNode(FLevelSceneNode*, INT, FMatrix);
	FLevelSceneNode(const FLevelSceneNode&);
	virtual ~FLevelSceneNode();
	FLevelSceneNode& operator=(const FLevelSceneNode&);
	virtual void Render(FRenderInterface*);
	virtual INT FilterActor(AActor*);
	virtual FLevelSceneNode* GetLevelSceneNode();
	virtual FConvexVolume GetViewFrustum();
};

class ENGINE_API FActorSceneNode : public FSceneNode
{
public:
	FActorSceneNode(UViewport*, AActor*, AActor*, FVector, FRotator, FLOAT);
};

class ENGINE_API FCameraSceneNode : public FSceneNode
{
public:
	FCameraSceneNode(UViewport*, AActor*, FVector, FRotator, FLOAT);
};

class ENGINE_API FMirrorSceneNode : public FSceneNode { public: BYTE Pad2[64]; };
class ENGINE_API FSkySceneNode : public FSceneNode { public: BYTE Pad2[64]; };
class ENGINE_API FWarpZoneSceneNode : public FSceneNode { public: BYTE Pad2[64]; };
class ENGINE_API FDirectionalLightMapSceneNode : public FSceneNode
{
public:
	FDirectionalLightMapSceneNode(UViewport*, AActor*, class FBspSurf&, FLightMap*);
};
class ENGINE_API FPointLightMapSceneNode : public FSceneNode
{
public:
	FPointLightMapSceneNode(UViewport*, AActor*, class FBspSurf&, FLightMap*, INT, INT, INT, INT);
};
class ENGINE_API FLightMapSceneNode : public FSceneNode
{
public:
	FLightMapSceneNode(UViewport*, AActor*, FLightMap*);
};

// ===========================================================================
// FPoly — BSP polygon.
// ===========================================================================

class ENGINE_API FPoly
{
public:

	FVector Base;
	FVector Normal;
	FVector TextureU;
	FVector TextureV;
	FVector Vertex[16]; // FPoly::MAX_VERTICES
	INT NumVertices;
	DWORD PolyFlags;
	ABrush* Actor;
	UMaterial* Material;
	FName ItemName;
	INT iLink;
	INT iBrushPoly;
	FLOAT PanU;
	FLOAT PanV;
	INT SavePolyIndex;
	FLOAT LightMapScale;

	FPoly();
	void Init();
	FPoly& operator=(const FPoly&);
	INT operator==(FPoly);
	INT operator!=(FPoly);
	FLOAT Area();
	INT CalcNormal(INT);
	INT DoesLineIntersect(FVector, FVector, FVector*);
	INT Faces(const FPoly&) const;
	INT Finalize(INT);
	INT Fix();
	FVector GetTextureSize();
	void InsertVertex(INT, FVector);
	INT IsBackfaced(const FVector&) const;
	INT IsCoplanar(const FPoly&) const;
	INT OnPlane(FVector);
	INT OnPoly(FVector);
	void RemoveColinears();
	void Reverse();
	INT Split(const FVector&, const FVector&, INT);
	void SplitInHalf(FPoly*);
	INT SplitPrecise(const FVector&, const FVector&, INT);
	INT SplitWithNode(const UModel*, INT, FPoly*, FPoly*, INT) const;
	INT SplitWithPlane(const FVector&, const FVector&, FPoly*, FPoly*, INT) const;
	INT SplitWithPlaneFast(FPlane, FPoly*, FPoly*) const;
	INT SplitWithPlaneFastPrecise(FPlane, FPoly*, FPoly*) const;
	void Transform(const FModelCoords&, const FVector&, const FVector&, FLOAT);
};

// ===========================================================================
// FColor methods — declared inline struct, methods in .cpp.
// ===========================================================================
// FColor is defined in Core headers. We add non-inline method declarations here.
// These are implemented in EngineMiscClasses.cpp.

// ===========================================================================
// FPathBuilder — navigation path construction.
// ===========================================================================

class ENGINE_API FPathBuilder
{
public:
	BYTE Pad[128];
	FPathBuilder& operator=(const FPathBuilder&);
	INT buildPaths(ULevel*);
	INT removePaths(ULevel*);
	void undefinePaths(ULevel*);
	void definePaths(ULevel*);
	void defineChangedPaths(ULevel*);
	void ReviewPaths(ULevel*);
	void BuildActionSpotList(ULevel*);
private:
	INT createPaths();
	void getScout();
	ANavigationPoint* newPath(FVector);
	void testPathsFrom(FVector);
	void testPathwithRadius(FVector, FLOAT);
	INT TestReach(FVector, FVector);
	INT TestWalk(FVector, FCheckResult, FLOAT);
	INT ValidNode(ANavigationPoint*, AActor*);
	void SetPathCollision(INT);
	void Pass2From(FVector, FVector, FLOAT);
	void FindBlockingNormal(FVector&);
};

// ===========================================================================
// FSortedPathList — path node sorting.
// ===========================================================================

class ENGINE_API FSortedPathList
{
public:
	BYTE Pad[64];
	ANavigationPoint* findEndAnchor(APawn*, AActor*, FVector, INT);
	ANavigationPoint* findStartAnchor(APawn*);
};

// ===========================================================================
// FWaveModInfo — WAV file info/manipulation.
// ===========================================================================

class ENGINE_API FWaveModInfo
{
public:

	BYTE Pad[128];
	FWaveModInfo();
	FWaveModInfo& operator=(const FWaveModInfo&);
	INT ReadWaveInfo(TArray<BYTE>&);
	INT UpdateWaveData(TArray<BYTE>&);
	DWORD Pad16Bit(DWORD);
	void Reduce16to8();
	void NoiseGateFilter();
	void HalveData();
	void HalveReduce16to8();
};

// ===========================================================================
// FRotatorF — floating-point rotator.
// ===========================================================================

class ENGINE_API FRotatorF
{
public:
	FLOAT Pitch, Yaw, Roll;
	FRotatorF();
	FRotatorF(FLOAT, FLOAT, FLOAT);
	FRotatorF(FRotator);
	FVector Vector();
	FRotator Rotator();
	FRotatorF& operator=(const FRotatorF&);
	FRotatorF operator*(FLOAT) const;
	FRotatorF operator-(FRotatorF) const;
	FRotatorF operator+(FRotatorF) const;
	FRotatorF operator*=(FLOAT);
	FRotatorF operator+=(FRotatorF);
	FRotatorF operator-=(FRotatorF);
};

// ===========================================================================
// ECLipSynchData — lip-synch animation data.
// ===========================================================================

class ENGINE_API ECLipSynchData
{
public:
	BYTE Pad[256];
	ECLipSynchData();
	ECLipSynchData(UMeshInstance*, USound*, USound*, AActor*);
	ECLipSynchData& operator=(const ECLipSynchData&);
	void m_vStartLipsynch();
	void m_vStopLipsynch();
	void m_vUpdateBonesCompressed(INT);
	void m_vUpdateBonesCompressed_BoneView(INT);
	void m_vUpdateBonesCompressed_PhonemsSeq(INT);
	void m_vUpdateLipSynch(FLOAT);
};

// ===========================================================================
// FHitCause and HHitProxy variants.
// ===========================================================================

class ENGINE_API FHitObserver
{
public:
	virtual ~FHitObserver() {}
	virtual void Click(const FHitCause& Cause, const struct HHitProxy& Hit) {}
};

struct ENGINE_API FHitCause
{
	FHitObserver* Observer;
	UViewport* Viewport;
	DWORD Buttons;
	FLOAT MouseX;
	FLOAT MouseY;
	FHitCause(FHitObserver*, UViewport*, DWORD, FLOAT, FLOAT);
};

struct ENGINE_API HHitProxy
{
	union { mutable INT Size; HHitProxy* Parent; };
	virtual ~HHitProxy() {}
	virtual const TCHAR* GetName() const { return TEXT("HHitProxy"); }
	virtual UBOOL IsA(const TCHAR* Str) const { return appStricmp(TEXT("HHitProxy"), Str) == 0; }
	virtual void Click(const FHitCause& Cause) { Cause.Observer->Click(Cause, *this); }
	virtual AActor* GetActor() { return NULL; }
};

#define DECLARE_HIT_PROXY(cls,parent) \
	const TCHAR* GetName() const { return TEXT(#cls); } \
	UBOOL IsA(const TCHAR* Str) const { return appStricmp(TEXT(#cls), Str) == 0 || parent::IsA(Str); }

struct ENGINE_API HActor : public HHitProxy {
	DECLARE_HIT_PROXY(HActor, HHitProxy)
	AActor* Actor;
	HActor(AActor* InActor) : Actor(InActor) {}
	AActor* GetActor() { return Actor; }
};
struct ENGINE_API HBspSurf : public HHitProxy {
	DECLARE_HIT_PROXY(HBspSurf, HHitProxy)
	INT iSurf;
	HBspSurf(INT iInSurf) : iSurf(iInSurf) {}
};
struct ENGINE_API HCoords : public HHitProxy {
	DECLARE_HIT_PROXY(HCoords, HHitProxy)
	FCoords Coords, Uncoords;
	FVector Direction;
	HCoords(FSceneNode* InFrame);
};
struct ENGINE_API HMaterialTree : public HHitProxy {
	DECLARE_HIT_PROXY(HMaterialTree, HHitProxy)
	UMaterial* Material;
	DWORD Flags;
	HMaterialTree(UMaterial* InMaterial, DWORD InFlags) : Material(InMaterial), Flags(InFlags) {}
};
struct ENGINE_API HMatineeAction : public HHitProxy {
	DECLARE_HIT_PROXY(HMatineeAction, HHitProxy)
	ASceneManager* SceneManager;
	UMatAction* Action;
	HMatineeAction(ASceneManager* InSM, UMatAction* InAction) : SceneManager(InSM), Action(InAction) {}
};
struct ENGINE_API HMatineeScene : public HHitProxy {
	DECLARE_HIT_PROXY(HMatineeScene, HHitProxy)
	ASceneManager* SceneManager;
	HMatineeScene(ASceneManager* InSM) : SceneManager(InSM) {}
};
struct ENGINE_API HMatineeSubAction : public HHitProxy {
	DECLARE_HIT_PROXY(HMatineeSubAction, HHitProxy)
	UMatSubAction* SubAction;
	UMatAction* Action;
	HMatineeSubAction(UMatSubAction* InSub, UMatAction* InAction) : SubAction(InSub), Action(InAction) {}
};
struct ENGINE_API HMatineeTimePath : public HHitProxy {
	DECLARE_HIT_PROXY(HMatineeTimePath, HHitProxy)
	ASceneManager* SceneManager;
	HMatineeTimePath(ASceneManager* InSM) : SceneManager(InSM) {}
};
struct ENGINE_API HTerrain : public HHitProxy {
	DECLARE_HIT_PROXY(HTerrain, HHitProxy)
	ATerrainInfo* TerrainInfo;
	HTerrain(ATerrainInfo* InTerrain) : TerrainInfo(InTerrain) {}
	AActor* GetActor() { return (AActor*)TerrainInfo; }
};
struct ENGINE_API HTerrainToolLayer : public HHitProxy {
	DECLARE_HIT_PROXY(HTerrainToolLayer, HHitProxy)
	ATerrainInfo* TerrainInfo;
	INT LayerIndex;
	UTexture* Texture;
	HTerrainToolLayer(ATerrainInfo* InTerrain, INT InLayer, UTexture* InTexture)
		: TerrainInfo(InTerrain), LayerIndex(InLayer), Texture(InTexture) {}
};

// ===========================================================================
// FInBunch / FOutBunch — network bunch wrappers.
// ===========================================================================

class ENGINE_API FInBunch : public FBitReader
{
public:
	BYTE Pad[64];
};

class ENGINE_API FOutBunch
{
public:
	BYTE Pad[256];
};

// ===========================================================================
// FSoundData — sound data wrapper.
// ===========================================================================

class ENGINE_API FSoundData
{
public:
	BYTE Pad[64];
	virtual ~FSoundData() {}
};

struct FProjectorRenderInfoPtr { INT Ptr; };
struct FIndexBufferPtr         { INT Ptr; };

struct FStaticMeshBatchRenderInfo
{
	INT m_iBatchIndex;
	INT m_iFirstIndex;
	INT m_iMinVertexIndex;
	INT m_iMaxVertexIndex;
};

struct FstCustomAvailability
{
	FString szGameType;
	BYTE eAvailabilityFlag;
};

struct FAnimRep
{
	FName AnimSequence;
	BITFIELD bAnimLoop : 1;
	BYTE AnimRate;
	BYTE AnimFrame;
	BYTE TweenRate;
};

struct FDbgVectorInfo
{
	BITFIELD m_bDisplay : 1;
	FVector m_vLocation;
	FVector m_vCylinder;
	FColor m_color;
	FString m_szDef;
	~FDbgVectorInfo();
	FDbgVectorInfo(const FDbgVectorInfo&);
	FDbgVectorInfo();
	FDbgVectorInfo& operator=(const FDbgVectorInfo&);
};

struct FProjectorRelativeRenderInfo
{
	FProjectorRenderInfoPtr m_RenderInfoPtr;
	FVector m_RelativeLocation;
	FRotator m_RelativeRotation;
};

struct FPointRegion
{
	class AZoneInfo* Zone;
	INT iLeaf;
	BYTE ZoneNumber;
	FPointRegion() : Zone(NULL), iLeaf(0), ZoneNumber(0) {}
	FPointRegion(class AZoneInfo* InZone) : Zone(InZone), iLeaf(0), ZoneNumber(0) {}
};

struct FCompressedPosition
{
	FVector Location;
	FRotator Rotation;
	FVector Velocity;
};

/*==========================================================================
	Parent classes not defined elsewhere in our include chain.
==========================================================================*/

// UMeshInstance — parent of USkeletalMeshInstance & UStaticMeshInstance.
class ENGINE_API UMeshInstance : public UPrimitive
{
	DECLARE_CLASS(UMeshInstance,UPrimitive,0,Engine)
	NO_DEFAULT_CONSTRUCTOR(UMeshInstance)
public:
	// Anim query interface (virtual, base implementations)
	virtual INT AnimForcePose(FName, FLOAT, FLOAT, INT);
	virtual FLOAT AnimGetFrameCount(void*);
	virtual FName AnimGetGroup(void*);
	virtual FName AnimGetName(void*);
	virtual INT AnimGetNotifyCount(void*);
	virtual UAnimNotify* AnimGetNotifyObject(void*, INT);
	virtual const TCHAR* AnimGetNotifyText(void*, INT);
	virtual FLOAT AnimGetNotifyTime(void*, INT);
	virtual FLOAT AnimGetRate(void*);
	virtual INT AnimIsInGroup(void*, FName);
	virtual INT AnimStopLooping(INT);
	virtual void ClearChannel(INT);
	virtual INT FreezeAnimAt(FLOAT, INT);
	virtual FLOAT GetActiveAnimFrame(INT);
	virtual FLOAT GetActiveAnimRate(INT);
	virtual FName GetActiveAnimSequence(INT);
	virtual AActor* GetActor();
	virtual INT GetAnimCount();
	virtual void* GetAnimIndexed(INT);
	virtual void* GetAnimNamed(FName);
	virtual FBox GetCollisionBoundingBox(const AActor*);
	virtual void GetFrame(AActor*, FLevelSceneNode*, FVector*, INT, INT&, DWORD);
	virtual UMaterial* GetMaterial(INT, AActor*);
	virtual class UMesh* GetMesh();
	virtual FBox GetRenderBoundingBox(const AActor*);
	virtual FSphere GetRenderBoundingSphere(const AActor*);
	virtual INT GetStatus();
	virtual INT IsAnimating(INT);
	virtual INT IsAnimLooping(INT);
	virtual INT IsAnimPastLastFrame(INT);
	virtual INT IsAnimTweening(INT);
	virtual INT LineCheck(FCheckResult&, AActor*, FVector, FVector, FVector, DWORD, DWORD);
	virtual void MeshBuildBounds();
	virtual FMatrix MeshToWorld();
	virtual INT PlayAnim(INT, FName, FLOAT, FLOAT, INT, INT, INT);
	virtual INT PointCheck(FCheckResult&, AActor*, FVector, FVector, DWORD);
	virtual void Render(class FDynamicActor*, FLevelSceneNode*, class TList<class FDynamicLight*>*, FRenderInterface*);
	virtual void SetActor(AActor*);
	virtual void SetAnimFrame(INT, FLOAT);
	virtual void SetMesh(class UMesh*);
	virtual void SetScale(FVector);
	virtual void SetStatus(INT);
	virtual INT StopAnimating(INT);
	virtual INT UpdateAnimation(FLOAT);
};

// URenderResource — parent of UProceduralTexture.
class ENGINE_API URenderResource : public UObject
{
	DECLARE_CLASS(URenderResource,UObject,0,Engine)
	URenderResource() {}
};

/*==========================================================================
	Class declarations — UnActor.cpp classes.
==========================================================================*/

class ENGINE_API AActor : public UObject
{
public:
	DECLARE_CLASS(AActor,UObject,0|CLASS_NativeReplication,Engine)
	// Member fields (extracted from SDK class definition)
	BYTE Physics;
	BYTE Role;
	BYTE RemoteRole;
	BYTE DrawType;
	BYTE AmbientGlow;
	BYTE MaxLights;
	BYTE Style;
	BYTE SoundPitch;
	BYTE SoundOcclusion;
	BYTE m_iTracedBone;
	BYTE LightType;
	BYTE LightEffect;
	BYTE LightHue;
	BYTE LightSaturation;
	BYTE LightPeriod;
	BYTE LightPhase;
	BYTE LightCone;
	BYTE ForceType;
	BYTE m_eDisplayFlag;
	BYTE m_u8SpritePlanningAngle;
	BYTE m_eStoryMode;
	BYTE m_eMissionMode;
	BYTE m_eTerroristHunt;
	BYTE m_eTerroristHuntCoop;
	BYTE m_eHostageRescue;
	BYTE m_eHostageRescueCoop;
	BYTE m_eHostageRescueAdv;
	BYTE m_eDefend;
	BYTE m_eDefendCoop;
	BYTE m_eRecon;
	BYTE m_eReconCoop;
	BYTE m_eDeathmatch;
	BYTE m_eTeamDeathmatch;
	BYTE m_eBomb;
	BYTE m_eEscort;
	BYTE m_eLoneWolf;
	BYTE m_eSquadDeathmatch;
	BYTE m_eSquadTeamDeathmatch;
	BYTE m_eTerroristHuntAdv;
	BYTE m_eScatteredHuntAdv;
	BYTE m_eCaptureTheEnemyAdv;
	BYTE m_eCountDown;
	BYTE m_eKamikaze;
	BYTE m_eFreeBackupAdv;
	BYTE m_eGazAlertAdv;
	BYTE m_eIntruderAdv;
	BYTE m_eLimitSeatsAdv;
	BYTE m_eVirusUploadAdv;
	BYTE m_u8RenderDataLastUpdate;
	BYTE m_HeatIntensity;
	BYTE m_wTickFrequency;
	BYTE m_wNbTickSkipped;
	INT CollisionTag;
	INT LightingTag;
	INT ActorTag;
	INT KStepTag;
	INT m_iPlanningFloor_0;
	INT m_iPlanningFloor_1;
	INT m_bInWeatherVolume;
	INT m_iLastRenderCycles;
	INT m_iLastRenderTick;
	INT m_iTotalRenderCycles;
	INT m_iNbRenders;
	INT m_iTickCycles;
	INT m_iTraceCycles;
	INT m_iTraceLastTick;
	INT m_iTracedCycles;
	INT m_iTracedLastTick;
	BITFIELD bStatic : 1;
	BITFIELD bHidden : 1;
	BITFIELD bNoDelete : 1;
	BITFIELD m_bR6Deletable : 1;
	BITFIELD m_bUseR6Availability : 1;
	BITFIELD m_bSkipHitDetection : 1;
	BITFIELD bAnimByOwner : 1;
	BITFIELD bDeleteMe : 1;
	BITFIELD bDynamicLight : 1;
	BITFIELD m_bDynamicLightOnlyAffectPawns : 1;
	BITFIELD bTimerLoop : 1;
	BITFIELD bCanTeleport : 1;
	BITFIELD bOwnerNoSee : 1;
	BITFIELD bOnlyOwnerSee : 1;
	BITFIELD bAlwaysTick : 1;
	BITFIELD bHighDetail : 1;
	BITFIELD bStasis : 1;
	BITFIELD bTrailerSameRotation : 1;
	BITFIELD bTrailerPrePivot : 1;
	BITFIELD bClientAnim : 1;
	BITFIELD bWorldGeometry : 1;
	BITFIELD bAcceptsProjectors : 1;
	BITFIELD m_bHandleRelativeProjectors : 1;
	BITFIELD bOrientOnSlope : 1;
	BITFIELD bDisturbFluidSurface : 1;
	BITFIELD bOnlyAffectPawns : 1;
	BITFIELD bShowOctreeNodes : 1;
	BITFIELD bWasSNFiltered : 1;
	BITFIELD bNetTemporary : 1;
	BITFIELD bNetOptional : 1;
	BITFIELD bNetDirty : 1;
	BITFIELD bAlwaysRelevant : 1;
	BITFIELD bReplicateInstigator : 1;
	BITFIELD bReplicateMovement : 1;
	BITFIELD bSkipActorPropertyReplication : 1;
	BITFIELD bUpdateSimulatedPosition : 1;
	BITFIELD bTearOff : 1;
	BITFIELD m_bUseRagdoll : 1;
	BITFIELD m_bForceBaseReplication : 1;
	BITFIELD bOnlyDirtyReplication : 1;
	BITFIELD bReplicateAnimations : 1;
	BITFIELD bNetInitialRotation : 1;
	BITFIELD bCompressedPosition : 1;
	BITFIELD m_bReticuleInfo : 1;
	BITFIELD m_bShowInHeatVision : 1;
	BITFIELD m_bFirstTimeInZone : 1;
	BITFIELD m_bBypassAmbiant : 1;
	BITFIELD m_bRenderOutOfWorld : 1;
	BITFIELD m_bSpawnedInGame : 1;
	BITFIELD m_bResetSystemLog : 1;
	BITFIELD m_bDeleteOnReset : 1;
	BITFIELD m_bInAmbientRange : 1;
	BITFIELD m_bPlayIfSameZone : 1;
	BITFIELD m_bPlayOnlyOnce : 1;
	BITFIELD m_bListOfZoneHearable : 1;
	BITFIELD m_bIfDirectLineOfSight : 1;
	BITFIELD m_bUseExitSounds : 1;
	BITFIELD m_bSoundWasPlayed : 1;
	BITFIELD m_bDrawFromBase : 1;
	BITFIELD bHardAttach : 1;
	BITFIELD m_bAllowLOD : 1;
	BITFIELD bUnlit : 1;
	BITFIELD bShadowCast : 1;
	BITFIELD bStaticLighting : 1;
	BITFIELD bUseLightingFromBase : 1;
	BITFIELD bHurtEntry : 1;
	BITFIELD bGameRelevant : 1;
	BITFIELD bCollideWhenPlacing : 1;
	BITFIELD bTravel : 1;
	BITFIELD bMovable : 1;
	BITFIELD bDestroyInPainVolume : 1;
	BITFIELD bShouldBaseAtStartup : 1;
	BITFIELD bPendingDelete : 1;
	BITFIELD m_bUseDifferentVisibleCollide : 1;
	BITFIELD m_b3DSound : 1;
	BITFIELD bCollideActors : 1;
	BITFIELD bCollideWorld : 1;
	BITFIELD bBlockActors : 1;
	BITFIELD bBlockPlayers : 1;
	BITFIELD bProjTarget : 1;
	BITFIELD m_bSeeThrough : 1;
	BITFIELD m_bPawnGoThrough : 1;
	BITFIELD m_bBulletGoThrough : 1;
	BITFIELD m_bShotThrough : 1;
	BITFIELD m_bDoPerBoneTrace : 1;
	BITFIELD bAutoAlignToTerrain : 1;
	BITFIELD bUseCylinderCollision : 1;
	BITFIELD bBlockKarma : 1;
	BITFIELD m_bLogNetTraffic : 1;
	BITFIELD bSpecialLit : 1;
	BITFIELD bActorShadows : 1;
	BITFIELD bCorona : 1;
	BITFIELD bLightChanged : 1;
	BITFIELD m_bLightingVisibility : 1;
	BITFIELD bIgnoreOutOfWorld : 1;
	BITFIELD bBounce : 1;
	BITFIELD bFixedRotationDir : 1;
	BITFIELD bRotateToDesired : 1;
	BITFIELD bInterpolating : 1;
	BITFIELD bJustTeleported : 1;
	BITFIELD m_bUseOriginalRotationInPlanning : 1;
	BITFIELD bNetInitial : 1;
	BITFIELD bNetOwner : 1;
	BITFIELD bNetRelevant : 1;
	BITFIELD bDemoRecording : 1;
	BITFIELD bClientDemoRecording : 1;
	BITFIELD bClientDemoNetFunc : 1;
	BITFIELD bHiddenEd : 1;
	BITFIELD bHiddenEdGroup : 1;
	BITFIELD bDirectional : 1;
	BITFIELD bSelected : 1;
	BITFIELD bEdShouldSnap : 1;
	BITFIELD bObsolete : 1;
	BITFIELD bPathColliding : 1;
	BITFIELD bScriptInitialized : 1;
	BITFIELD bLockLocation : 1;
	BITFIELD bEdLocked : 1;
	BITFIELD m_bPlanningAlwaysDisplay : 1;
	BITFIELD m_bIsWalkable : 1;
	BITFIELD m_bSpriteShowFlatInPlanning : 1;
	BITFIELD m_bSpriteShownIn3DInPlanning : 1;
	BITFIELD m_bSpriteShowOver : 1;
	BITFIELD m_bHideInLowGoreLevel : 1;
	BITFIELD m_bIsRealtime : 1;
	BITFIELD m_bShouldHidePortal : 1;
	BITFIELD m_bHidePortal : 1;
	BITFIELD m_bOutlinedInPlanning : 1;
	BITFIELD m_bNeedOutlineUpdate : 1;
	BITFIELD m_bBatchesStaticLightingUpdated : 1;
	BITFIELD m_bForceStaticLighting : 1;
	BITFIELD m_bSkipTick : 1;
	BITFIELD m_bTickOnlyWhenVisible : 1;
	FLOAT LastRenderTime;
	FLOAT TimerRate;
	FLOAT TimerCounter;
	FLOAT LifeSpan;
	FLOAT LODBias;
	FLOAT m_fAmbientSoundRadius;
	FLOAT m_fSoundRadiusSaturation;
	FLOAT m_fSoundRadiusActivation;
	FLOAT m_fSoundRadiusLinearFadeDist;
	FLOAT m_fSoundRadiusLinearFadeEnd;
	FLOAT LatentFloat;
	FLOAT DrawScale;
	FLOAT m_fLightingScaleFactor;
	FLOAT CullDistance;
	FLOAT SoundRadius;
	FLOAT TransientSoundVolume;
	FLOAT TransientSoundRadius;
	FLOAT CollisionRadius;
	FLOAT CollisionHeight;
	FLOAT m_fCircumstantialActionRange;
	FLOAT LightBrightness;
	FLOAT LightRadius;
	FLOAT Mass;
	FLOAT Buoyancy;
	FLOAT fLightValue;
	FLOAT m_fBoneRotationTransition;
	FLOAT ForceRadius;
	FLOAT ForceScale;
	FLOAT NetPriority;
	FLOAT NetUpdateFrequency;
	FLOAT bCoronaMUL2XFactor;
	FLOAT m_fCoronaMinSize;
	FLOAT m_fCoronaMaxSize;
	FLOAT m_fAttachFactor;
	FLOAT m_fCummulativeTick;
	class AActor* Owner;
	class ALevelInfo* Level;
	class APawn* Instigator;
	class USound* AmbientSound;
	class USound* AmbientSoundStop;
	class AActor* m_CurrentAmbianceObject;
	class AActor* m_CurrentVolumeSound;
	class AActor* Base;
	class AActor* Deleted;
	class APhysicsVolume* PhysicsVolume;
	class UMaterial* Texture;
	class UMesh* Mesh;
	class UStaticMesh* StaticMesh;
	class UStaticMeshInstance* StaticMeshInstance;
	class UModel* Brush;
	class UConvexVolume* AntiPortal;
	class AR6ColBox* m_collisionBox;
	class AR6ColBox* m_collisionBox2;
	class AActor* PendingTouch;
	class UKarmaParamsCollision* KParams;
	class AActor* m_AttachedTo;
	class AProjector* Shadow;
	class UStaticMesh* m_OutlineStaticMesh;
	FName Tag;
	FName InitialState;
	FName Group;
	FName Event;
	FName AttachTag;
	FName AttachmentBone;
	FName m_szSoundBoneName;
	class UClass* MessageClass;
	TArray<class AZoneInfo*> m_ListOfZoneInfo;
	TArray<class AActor*> Touching;
	TArray<class AActor*> Attached;
	TArray<class UMaterial*> Skins;
	TArray<class UMaterial*> NightVisionSkins;
	TArray<struct FDbgVectorInfo> m_dbgVectorInfo;
	TArray<struct FstCustomAvailability> m_aCustomAvailability;
	TArray<INT> m_OutlineIndices;
	TArray<struct FStaticMeshBatchRenderInfo> m_Batches;
	struct FPointRegion Region;
	class FVector Location;
	class FRotator Rotation;
	class FVector Velocity;
	class FVector Acceleration;
	class FVector RelativeLocation;
	class FRotator RelativeRotation;
	class FMatrix HardRelMatrix;
	class FVector DrawScale3D;
	class FVector PrePivot;
	class FColor m_fLightingAdditiveAmbiant;
	class FVector m_vVisibleCenter;
	class FRotator sm_Rotation;
	class FRotator RotationRate;
	class FRotator DesiredRotation;
	class FVector ColLocation;
	class FColor m_PlanningColor;
	INT NetTag;
	INT JoinedTag;
	BITFIELD bTicked : 1;
	BITFIELD bEdSnap : 1;
	BITFIELD bTempEditor : 1;
	BITFIELD bPathTemp : 1;
	class UMeshInstance* MeshInstance;
	class ULevel* XLevel;
	TArray<INT> Leaves;
	TArray<INT> OctreeNodes;
	TArray<struct FProjectorRelativeRenderInfo> Projectors;
	class FBox OctreeBox;
	class FVector OctreeBoxCenter;
	class FVector OctreeBoxRadii;
	struct FAnimRep SimAnim;
	struct FIndexBufferPtr m_OutlineIndexBuffer;

	// Virtual methods — UObject overrides
	virtual void Serialize(FArchive&);
	virtual void PostLoad();
	virtual void Destroy();
	virtual void PostEditChange();
	virtual void InitExecution();
	virtual void ProcessEvent(class UFunction*, void*, void* Result=NULL);
	virtual void ProcessState(FLOAT);
	virtual INT ProcessRemoteFunction(class UFunction*, void*, struct FFrame*);
	virtual void NetDirty(class UProperty*);

	// Virtual methods — AActor
	virtual INT IsPendingKill();
	virtual INT IsPendingDelete();
	virtual INT * GetOptimizedRepList(BYTE *, struct FPropertyRetirement *, INT *, class UPackageMap *, class UActorChannel *);
	virtual class APawn * GetPawnOrColBoxOwner() const;
	virtual class APawn * GetPlayerPawn() const;
	virtual INT PlayerControlled();
	virtual INT IsBlockedBy(class AActor const *) const;
	virtual FLOAT GetNetPriority(class AActor *, FLOAT, FLOAT);
	virtual FLOAT WorldLightRadius() const;
	virtual INT Tick(FLOAT, enum ELevelTick);
	virtual void BoundProjectileVelocity();
	virtual void PostBeginPlay();
	virtual void PostEditLoad();
	virtual void PostEditMove();
	virtual void PostPath();
	virtual void PostRaytrace();
	virtual void PostScriptDestroyed();
	virtual void PrePath();
	virtual void PreRaytrace();
	virtual void Spawned();
	virtual void PreNetReceive();
	virtual void PostNetReceive();
	virtual void PostNetReceiveLocation();
	virtual class UMaterial * GetSkin(INT);
	virtual class FCoords ToLocal() const;
	virtual class FCoords ToWorld() const;
	virtual class FMatrix LocalToWorld() const;
	virtual class FMatrix WorldToLocal() const;
	virtual void UpdateColBox(class FVector &, INT, INT, INT);
	virtual INT ShouldTrace(class AActor *, DWORD);
	virtual class UPrimitive * GetPrimitive();
	virtual void BeginTouch(class AActor *);
	virtual INT IsMovingBrush() const;
	virtual void NotifyBump(class AActor *);
	virtual void SetBase(class AActor *, class FVector, INT);
	virtual class FRotator GetViewRotation();
	virtual void NotifyAnimEnd(INT);
	virtual void UpdateAnimation(FLOAT);
	virtual void StartAnimPoll();
	virtual INT CheckAnimFinished(INT);
	virtual void UpdateTimers(FLOAT);
	virtual INT CheckOwnerUpdated();
	virtual void TickAuthoritative(FLOAT);
	virtual void TickSimulated(FLOAT);
	virtual void AddMyMarker(class AActor *);
	virtual void TickSpecial(FLOAT);
	virtual INT IsNetRelevantFor(class APlayerController *, class AActor *, class FVector);
	virtual void RenderEditorInfo(class FLevelSceneNode *, class FRenderInterface *, class FDynamicActor *);
	virtual void RenderEditorSelected(class FLevelSceneNode *, class FRenderInterface *, class FDynamicActor *);
	virtual void SetZone(INT, INT);
	virtual void SetVolumes(class TArray<class AVolume *> const &);
	virtual void SetVolumes();
	virtual void setPhysics(BYTE, class AActor *, class FVector);
	virtual void performPhysics(FLOAT);
	virtual void processHitWall(class FVector, class AActor *);
	virtual void processLanded(class FVector, class AActor *, FLOAT, INT);
	virtual void physFalling(FLOAT, INT);
	virtual class FRotator FindSlopeRotation(class FVector, class FRotator);
	virtual void SmoothHitWall(class FVector, class AActor *);
	virtual void stepUp(class FVector, class FVector, class FVector, struct FCheckResult &);
	virtual struct _McdModel * getKModel() const;
	virtual void physKarma(FLOAT);
	virtual void preKarmaStep(FLOAT);
	virtual void postKarmaStep();
	virtual INT KMP2DynKarmaInterface(INT, class FVector, class FRotator, class AActor *);
	virtual class AActor * AssociatedLevelGeometry();
	virtual INT HasAssociatedLevelGeometry(class AActor *);
	virtual void PlayAnim(INT, class FName, FLOAT, FLOAT, INT, INT, INT);
	virtual INT IsRelevantToPawnHeartBeat(class APawn *);
	virtual INT IsRelevantToPawnHeatVision(class APawn *);
	virtual INT IsRelevantToPawnRadar(class APawn *);
	virtual INT TickThisFrame(FLOAT);
	virtual void CheckForErrors();
	virtual class AActor * GetProjectorBase();

	// Native C++ methods
	AActor();
	void AnimBlendParams(INT, FLOAT, FLOAT, FLOAT, class FName);
	void AttachProjector(class AProjector *);
	INT AttachToBone(class AActor *, class FName);
	void CheckNoiseHearing(FLOAT, enum ENoiseType, enum EPawnType, enum ESoundType);
	void CopyR6Availability(class AActor *);
	void DbgAddLine(class FVector, class FVector, class FColor);
	void DbgVectorAdd(class FVector, class FVector, INT, class FString, class FColor *);
	void DbgVectorDraw(class FLevelSceneNode *, class FRenderInterface &);
	void DbgVectorReset(INT);
	INT DetachFromBone(class AActor *);
	void DetachProjector(class AProjector *);
	void EndTouch(class AActor *, INT);
	void FindBase();
	class AActor * GetAmbientLightingActor();
	class FVector GetCylinderExtent() const;
	class AActor * GetHitActor();
	class ULevel * GetLevel() const;
	void GetNetBuoyancy(FLOAT &, FLOAT &);
	BYTE * GetR6AvailabilityPtr(class FString, INT);
	class AActor * GetTopOwner();
	class FString GlobalIDToString(BYTE * const);
	INT IsAnimating(INT) const;
	INT IsAvailableInGameType(class FString);
	INT IsBasedOn(class AActor const *) const;
	INT IsBrush() const;
	INT IsEncroacher() const;
	INT IsHiddenEd();
	INT IsInOctree();
	INT IsInZone(class AZoneInfo const *) const;
	INT IsJoinedTo(class AActor const *) const;
	INT IsOverlapping(class AActor *, struct FCheckResult *);
	INT IsOwnedBy(class AActor const *) const;
	INT IsPlayer() const;
	INT IsStaticBrush() const;
	INT IsVolumeBrush() const;
	void KFreezeRagdoll();
	FLOAT LifeFraction();
	INT NativeNonUbiMatchMaking();
	INT NativeNonUbiMatchMakingHost();
	INT NativeStartedByGSClient();
	void PlayReplicatedAnim();
	void ProcessDemoRecFunction(class UFunction *, void *, struct FFrame *);
	void PutOnGround();
	void ReplicateAnim(INT, class FName, FLOAT, FLOAT, FLOAT, FLOAT, INT);
	void SafeDestroyActor(class AActor *);
	void SaveServerOptions(class FString);
	void SecondsToString(INT, INT, class FString &);
	void SetCollision(INT, INT, INT);
	void SetCollisionSize(FLOAT, FLOAT);
	void SetDrawScale(FLOAT);
	void SetDrawScale3D(class FVector);
	void SetDrawType(enum EDrawType);
	void SetGameType(class FString);
	void SetOwner(class AActor *);
	void SetStaticMesh(class UStaticMesh *);
	INT TestCanSeeMe(class APlayerController *);
	class AActor * Trace(class FVector &, class FVector &, class FVector &, class FVector &, INT, class FVector &, class UMaterial * *);
	void TwoWallAdjust(class FVector &, class FVector &, class FVector &, class FVector &, FLOAT);
	void UpdateRelativeRotation();
	void UpdateRenderData();
	INT fixedTurn(INT, INT, INT);
	INT moveSmooth(class FVector);
	void physKarmaRagDoll(FLOAT);
	void physKarmaRagDoll_internal(FLOAT);
	void physKarma_internal(FLOAT);
	void physProjectile(FLOAT, INT);
	void physRootMotion(FLOAT);
	void physTrailer(FLOAT);
	void physicsRotation(FLOAT);
	void postKarmaStep_skeletal();
	void preKarmaStep_skeletal(FLOAT);

	// Indexed exec functions (from UnActor.cpp)
	DECLARE_FUNCTION(execError)
	DECLARE_FUNCTION(execSleep)
	DECLARE_FUNCTION(execPlayAnim)
	DECLARE_FUNCTION(execLoopAnim)
	DECLARE_FUNCTION(execFinishAnim)
	DECLARE_FUNCTION(execSetCollision)
	DECLARE_FUNCTION(execHasAnim)
	DECLARE_FUNCTION(execPlaySound)
	DECLARE_FUNCTION(execMove)
	DECLARE_FUNCTION(execSetLocation)
	DECLARE_FUNCTION(execSetOwner)
	DECLARE_FUNCTION(execTrace)
	DECLARE_FUNCTION(execSpawn)
	DECLARE_FUNCTION(execDestroy)
	DECLARE_FUNCTION(execSetTimer)
	DECLARE_FUNCTION(execIsAnimating)
	DECLARE_FUNCTION(execSetCollisionSize)
	DECLARE_FUNCTION(execGetAnimGroup)
	DECLARE_FUNCTION(execTweenAnim)
	DECLARE_FUNCTION(execSetBase)
	DECLARE_FUNCTION(execSetRotation)
	DECLARE_FUNCTION(execFinishInterpolation)
	DECLARE_FUNCTION(execAllActors)
	DECLARE_FUNCTION(execChildActors)
	DECLARE_FUNCTION(execBasedActors)
	DECLARE_FUNCTION(execTouchingActors)
	DECLARE_FUNCTION(execTraceActors)
	DECLARE_FUNCTION(execRadiusActors)
	DECLARE_FUNCTION(execVisibleActors)
	DECLARE_FUNCTION(execVisibleCollidingActors)
	DECLARE_FUNCTION(execMakeNoise)
	DECLARE_FUNCTION(execPlayerCanSeeMe)
	DECLARE_FUNCTION(execGetMapName)
	DECLARE_FUNCTION(execGetNextSkin)
	DECLARE_FUNCTION(execGetURLMap)
	DECLARE_FUNCTION(execFastTrace)
	DECLARE_FUNCTION(execMoveSmooth)
	DECLARE_FUNCTION(execSetPhysics)
	DECLARE_FUNCTION(execAutonomousPhysics)
	DECLARE_FUNCTION(execR6Trace)
	DECLARE_FUNCTION(execFindSpot)
	DECLARE_FUNCTION(execGetAnimBlendAlpha)
	DECLARE_FUNCTION(execClearChannel)
	DECLARE_FUNCTION(execWasSkeletonUpdated)
	DECLARE_FUNCTION(execUnLinkSkelAnim)
	DECLARE_FUNCTION(execIsPlayingSound)
	DECLARE_FUNCTION(execStopAllSounds)
	DECLARE_FUNCTION(execStopAllSoundsActor)
	DECLARE_FUNCTION(execStopSound)
	DECLARE_FUNCTION(execFadeSound)
	DECLARE_FUNCTION(execAddSoundBank)
	DECLARE_FUNCTION(execAddAndFindBankInSound)
	DECLARE_FUNCTION(execResetVolume_AllTypeSound)
	DECLARE_FUNCTION(execResetVolume_TypeSound)
	DECLARE_FUNCTION(execChangeVolumeType)
	DECLARE_FUNCTION(execSaveCurrentFadeValue)
	DECLARE_FUNCTION(execReturnSavedFadeValue)
	DECLARE_FUNCTION(execGetTime)
	DECLARE_FUNCTION(execGetGameManager)
	DECLARE_FUNCTION(execGetModMgr)
	DECLARE_FUNCTION(execGetGameOptions)
	DECLARE_FUNCTION(execGetServerOptions)
	DECLARE_FUNCTION(execSaveServerOptions)
	DECLARE_FUNCTION(execGetMissionDescription)
	DECLARE_FUNCTION(execSetServerBeacon)
	DECLARE_FUNCTION(execGetServerBeacon)
	DECLARE_FUNCTION(execNativeStartedByGSClient)
	DECLARE_FUNCTION(execNativeNonUbiMatchMaking)
	DECLARE_FUNCTION(execNativeNonUbiMatchMakingAddress)
	DECLARE_FUNCTION(execNativeNonUbiMatchMakingPassword)
	DECLARE_FUNCTION(execNativeNonUbiMatchMakingHost)
	DECLARE_FUNCTION(execGetGameVersion)
	DECLARE_FUNCTION(execIsPBClientEnabled)
	DECLARE_FUNCTION(execIsPBServerEnabled)
	DECLARE_FUNCTION(execSetPBStatus)
	DECLARE_FUNCTION(execIsAvailableInGameType)
	DECLARE_FUNCTION(execConvertGameTypeIntToString)
	DECLARE_FUNCTION(execConvertGameTypeToInt)
	DECLARE_FUNCTION(execConvertIntTimeToString)
	DECLARE_FUNCTION(execGlobalIDToString)
	DECLARE_FUNCTION(execGlobalIDToBytes)
	DECLARE_FUNCTION(execGetTagInformations)
	DECLARE_FUNCTION(execDbgVectorReset)
	DECLARE_FUNCTION(execDbgVectorAdd)
	DECLARE_FUNCTION(execDbgAddLine)
	DECLARE_FUNCTION(execGetFPlayerMenuInfo)
	DECLARE_FUNCTION(execSetFPlayerMenuInfo)
	DECLARE_FUNCTION(execGetPlayerSetupInfo)
	DECLARE_FUNCTION(execSetPlayerSetupInfo)
	DECLARE_FUNCTION(execSortFPlayerMenuInfo)
	DECLARE_FUNCTION(execSetPlanningMode)
	DECLARE_FUNCTION(execSetFloorToDraw)
	DECLARE_FUNCTION(execInPlanningMode)
	DECLARE_FUNCTION(execLoadLoadingScreen)
	DECLARE_FUNCTION(execLoadRandomBackgroundImage)
	DECLARE_FUNCTION(execGetNbAvailableResolutions)
	DECLARE_FUNCTION(execGetAvailableResolution)
	DECLARE_FUNCTION(execReplaceTexture)
	DECLARE_FUNCTION(execIsVideoHardwareAtLeast64M)
	DECLARE_FUNCTION(execGetCanvas)
	DECLARE_FUNCTION(execEnableLoadingScreen)
	DECLARE_FUNCTION(execAddMessageToConsole)
	DECLARE_FUNCTION(execUpdateGraphicOptions)
	DECLARE_FUNCTION(execGarbageCollect)
	DECLARE_FUNCTION(execDrawDashedLine)
	DECLARE_FUNCTION(execDrawText3D)
	DECLARE_FUNCTION(execRenderLevelFromMe)
	DECLARE_FUNCTION(execGetMapNameExt)
	// Non-indexed exec functions
	DECLARE_FUNCTION(execPollSleep)
	DECLARE_FUNCTION(execPollFinishAnim)
	DECLARE_FUNCTION(execPollFinishInterpolation)
	DECLARE_FUNCTION(execSetRelativeLocation)
	DECLARE_FUNCTION(execSetRelativeRotation)
	DECLARE_FUNCTION(execStopAnimating)
	DECLARE_FUNCTION(execIsTweening)
	DECLARE_FUNCTION(execGetAnimParams)
	DECLARE_FUNCTION(execAnimBlendParams)
	DECLARE_FUNCTION(execAnimBlendToAlpha)
	DECLARE_FUNCTION(execAnimIsInGroup)
	DECLARE_FUNCTION(execFreezeAnimAt)
	DECLARE_FUNCTION(execGetNotifyChannel)
	DECLARE_FUNCTION(execEnableChannelNotify)
	DECLARE_FUNCTION(execLinkMesh)
	DECLARE_FUNCTION(execLinkSkelAnim)
	DECLARE_FUNCTION(execLockRootMotion)
	DECLARE_FUNCTION(execGetRootLocation)
	DECLARE_FUNCTION(execGetRootLocationDelta)
	DECLARE_FUNCTION(execGetRootRotation)
	DECLARE_FUNCTION(execGetRootRotationDelta)
	DECLARE_FUNCTION(execGetBoneCoords)
	DECLARE_FUNCTION(execGetBoneRotation)
	DECLARE_FUNCTION(execSetBoneRotation)
	DECLARE_FUNCTION(execSetBoneDirection)
	DECLARE_FUNCTION(execSetBoneLocation)
	DECLARE_FUNCTION(execSetBoneScale)
	DECLARE_FUNCTION(execGetRenderBoundingSphere)
	DECLARE_FUNCTION(execAttachToBone)
	DECLARE_FUNCTION(execDetachFromBone)
	DECLARE_FUNCTION(execPlayOwnedSound)
	DECLARE_FUNCTION(execDemoPlaySound)
	DECLARE_FUNCTION(execPlayMusic)
	DECLARE_FUNCTION(execStopMusic)
	DECLARE_FUNCTION(execStopAllMusic)
	DECLARE_FUNCTION(execGetSoundDuration)
	DECLARE_FUNCTION(execSetDrawScale)
	DECLARE_FUNCTION(execSetDrawScale3D)
	DECLARE_FUNCTION(execSetDrawType)
	DECLARE_FUNCTION(execSetStaticMesh)
	DECLARE_FUNCTION(execOnlyAffectPawns)
	DECLARE_FUNCTION(execConsoleCommand)
	DECLARE_FUNCTION(execGetNextInt)
	DECLARE_FUNCTION(execGetNextIntDesc)
	DECLARE_FUNCTION(execGetCacheEntry)
	DECLARE_FUNCTION(execMoveCacheEntry)
	DECLARE_FUNCTION(execMultiply_ColorFloat)
	DECLARE_FUNCTION(execMultiply_FloatColor)
	DECLARE_FUNCTION(execAdd_ColorColor)
	DECLARE_FUNCTION(execSubtract_ColorColor)
	// Extra non-stubbed exec declarations (from prior analysis)
	DECLARE_FUNCTION(execSetCollisionDrawScale)
	DECLARE_FUNCTION(execUpdateRenderData)
	DECLARE_FUNCTION(execDrawDebugLine)
	DECLARE_FUNCTION(execDynamicActors)
	DECLARE_FUNCTION(execCollidingActors)
	DECLARE_FUNCTION(execConnectedDoors)
	DECLARE_FUNCTION(execGetViewRotation)
	DECLARE_FUNCTION(execAntiPortalActors)
	DECLARE_FUNCTION(execGetMapRevision)
	DECLARE_FUNCTION(execIsValidActor)
	DECLARE_FUNCTION(execGetDiffuseColor)
	DECLARE_FUNCTION(execSetR6Collision)
	DECLARE_FUNCTION(execSetSoundParamsExt)
	DECLARE_FUNCTION(execR6MakeNoise)
	DECLARE_FUNCTION(execSetReverbPreset)
	DECLARE_FUNCTION(execClientHearSound)
	DECLARE_FUNCTION(execSetSweptCollision)
	DECLARE_FUNCTION(execRenderOverlays)
	// Karma physics exec functions
	DECLARE_FUNCTION(execGetServerOptionsRefreshed)
	DECLARE_FUNCTION(execKAddBoneLifter)
	DECLARE_FUNCTION(execKAddImpulse)
	DECLARE_FUNCTION(execKDisableCollision)
	DECLARE_FUNCTION(execKEnableCollision)
	DECLARE_FUNCTION(execKFreezeRagdoll)
	DECLARE_FUNCTION(execKGetActorGravScale)
	DECLARE_FUNCTION(execKGetCOMOffset)
	DECLARE_FUNCTION(execKGetCOMPosition)
	DECLARE_FUNCTION(execKGetDampingProps)
	DECLARE_FUNCTION(execKGetFriction)
	DECLARE_FUNCTION(execKGetImpactThreshold)
	DECLARE_FUNCTION(execKGetInertiaTensor)
	DECLARE_FUNCTION(execKGetMass)
	DECLARE_FUNCTION(execKGetRestitution)
	DECLARE_FUNCTION(execKGetSkelMass)
	DECLARE_FUNCTION(execKIsAwake)
	DECLARE_FUNCTION(execKIsRagdollAvailable)
	DECLARE_FUNCTION(execKMakeRagdollAvailable)
	DECLARE_FUNCTION(execKMP2IOKarmaAllNativeFct)
	DECLARE_FUNCTION(execKRemoveAllBoneLifters)
	DECLARE_FUNCTION(execKRemoveLifterFromBone)
	DECLARE_FUNCTION(execKSetActorGravScale)
	DECLARE_FUNCTION(execKSetBlockKarma)
	DECLARE_FUNCTION(execKSetCOMOffset)
	DECLARE_FUNCTION(execKSetDampingProps)
	DECLARE_FUNCTION(execKSetFriction)
	DECLARE_FUNCTION(execKSetImpactThreshold)
	DECLARE_FUNCTION(execKSetInertiaTensor)
	DECLARE_FUNCTION(execKSetMass)
	DECLARE_FUNCTION(execKSetRestitution)
	DECLARE_FUNCTION(execKSetSkelVel)
	DECLARE_FUNCTION(execKSetStayUpright)
	DECLARE_FUNCTION(execKWake)
	// Event thunks
	void eventAnimEnd(INT);
	void eventAttach(class AActor*);
	void eventBaseChange();
	void eventBeginEvent();
	void eventBeginPlay();
	void eventBroadcastLocalizedMessage(class UClass*, INT, class APlayerReplicationInfo*, class APlayerReplicationInfo*, class UObject*);
	void eventBump(class AActor*);
	void eventDemoPlaySound(class USound*, BYTE, FLOAT, DWORD, FLOAT, FLOAT, DWORD);
	void eventDestroyed();
	void eventDetach(class AActor*);
	void eventEncroachedBy(class AActor*);
	DWORD eventEncroachingOn(class AActor*);
	void eventEndedRotation();
	void eventEndEvent();
	void eventFalling();
	void eventFellOutOfWorld();
	void eventFinishedInterpolation();
	void eventGainedChild(class AActor*);
	DWORD eventGetReticuleInfo(class APawn*, FString&);
	void eventHitWall(FVector, class AActor*);
	void eventKApplyForce(FVector&, FVector&);
	void eventKilledBy(class APawn*);
	void eventKImpact(class AActor*, FVector, FVector, FVector);
	void eventKSkelConvulse();
	void eventKVelDropBelow();
	void eventLanded(FVector);
	void eventLostChild(class AActor*);
	void eventPhysicsVolumeChange(class APhysicsVolume*);
	void eventPostBeginPlay();
	void eventPostNetBeginPlay();
	void eventPostTeleport(class ATeleporter*);
	void eventPostTouch(class AActor*);
	void eventPreBeginPlay();
	DWORD eventPreTeleport(class ATeleporter*);
	DWORD eventProcessHeart(FLOAT, FLOAT&, FLOAT&);
	void eventR6MakeNoise(BYTE);
	void eventR6QueryCircumstantialAction(FLOAT, class AR6AbstractCircumstantialActionQuery*&, class APlayerController*);
	void eventSaveAndResetData();
	void eventSetInitialState();
	class AActor* eventSpecialHandling(class APawn*);
	void eventTick(FLOAT);
	void eventTimer();
	void eventTornOff();
	void eventTouch(class AActor*);
	void eventTravelPostAccept();
	void eventTravelPreAccept();
	void eventTrigger(class AActor*, class APawn*);
	void eventTriggerEvent(FName, class AActor*, class APawn*);
	void eventUnTouch(class AActor*);
	void eventUnTrigger(class AActor*, class APawn*);
	void eventUsedBy(class APawn*);
	void eventZoneChange(class AZoneInfo*);

};

class ENGINE_API AInfo : public AActor
{
public:
	DECLARE_CLASS(AInfo,AActor,0,Engine)
protected:
	AInfo() {}
};

class ABroadcastHandler : public AInfo
{
public:
	DECLARE_CLASS(ABroadcastHandler,AInfo,0,Engine)
	ABroadcastHandler() {}
	ABroadcastHandler(const ABroadcastHandler&) {}
};

class ENGINE_API ABrush : public AActor
{
public:
	DECLARE_CLASS(ABrush,AActor,0,Engine)
	ABrush() {}

	BYTE CsgOper;
	INT PolyFlags;
	BITFIELD bColored : 1;
	class UObject* UnusedLightMesh;
	FVector PostPivot;
	FScale MainScale;
	FScale PostScale;
	FScale TempScale;
	FColor BrushColor;

	// Virtual methods
	virtual void PostLoad();
	virtual void PostEditChange();
	virtual FCoords ToLocal() const;
	virtual FCoords ToWorld() const;
	virtual class UPrimitive * GetPrimitive();
	virtual void CheckForErrors();
	virtual void CopyPosRotScaleFrom(class ABrush *);
	virtual void InitPosRotScale();

	// Non-virtual methods
	FLOAT BuildCoords(FModelCoords *, FModelCoords *);
	FLOAT OldBuildCoords(FModelCoords *, FModelCoords *);
	FCoords OldToLocal() const;
	FCoords OldToWorld() const;
};

class ENGINE_API AVolume : public ABrush
{
public:
	DECLARE_CLASS(AVolume,ABrush,0,Engine)
	DECLARE_FUNCTION(execEncompasses)
	// Auto-generated method declarations
	virtual void SetVolumes(TArray<AVolume *> const &);
	virtual void SetVolumes();
	virtual int ShouldTrace(AActor *,DWORD);
	virtual void PostBeginPlay();
	int Encompasses(FVector);
};

class ENGINE_API AKeypoint : public AActor
{
public:
	DECLARE_CLASS(AKeypoint,AActor,0,Engine)
	NO_DEFAULT_CONSTRUCTOR(AKeypoint)
};

class ENGINE_API ATriggers : public AActor
{
public:
	DECLARE_CLASS(ATriggers,AActor,0,Engine)
	NO_DEFAULT_CONSTRUCTOR(ATriggers)
};

class ENGINE_API ATrigger : public ATriggers
{
public:
	DECLARE_CLASS(ATrigger,ATriggers,0,Engine)
	NO_DEFAULT_CONSTRUCTOR(ATrigger)
};

class ENGINE_API ALight : public AActor
{
public:
	DECLARE_CLASS(ALight,AActor,0,Engine)
};

class ENGINE_API ANavigationPoint : public AActor
{
public:
	DECLARE_CLASS(ANavigationPoint,AActor,0,Engine)
	ANavigationPoint() {}

	INT visitedWeight;
	INT bestPathWeight;
	INT cost;
	INT ExtraCost;
	BITFIELD taken : 1;
	BITFIELD bBlocked : 1;
	BITFIELD bPropagatesSound : 1;
	BITFIELD bOneWayPath : 1;
	BITFIELD bNeverUseStrafing : 1;
	BITFIELD bAlwaysUseStrafing : 1;
	BITFIELD bForceNoStrafing : 1;
	BITFIELD bAutoBuilt : 1;
	BITFIELD bSpecialMove : 1;
	BITFIELD bNoAutoConnect : 1;
	BITFIELD bNotBased : 1;
	BITFIELD bPathsChanged : 1;
	BITFIELD bDestinationOnly : 1;
	BITFIELD bSourceOnly : 1;
	BITFIELD bSpecialForced : 1;
	BITFIELD bMustBeReachable : 1;
	BITFIELD m_bExactMove : 1;
	class ANavigationPoint* nextNavigationPoint;
	class ANavigationPoint* nextOrdered;
	class ANavigationPoint* prevOrdered;
	class ANavigationPoint* previousPath;
	FName ProscribedPaths[4];
	FName ForcedPaths[4];
	TArray<class UReachSpec*> PathList;
	BITFIELD bEndPoint : 1;

	// Virtual methods
	virtual void Destroy();
	virtual void PostEditMove();
	virtual void Spawned();
	virtual void InitForPathFinding();
	virtual void CheckSymmetry(class ANavigationPoint *);
	virtual void PostaddReachSpecs(class APawn *);
	virtual void SetVolumes(const TArray<class AVolume *> &);
	virtual void CheckForErrors();
	virtual INT ProscribedPathTo(class ANavigationPoint *);
	virtual void addReachSpecs(class APawn *, INT);
	virtual void SetupForcedPath(class APawn *, class UReachSpec *);
	virtual void ClearPaths();
	virtual void FindBase();
	virtual INT PrunePaths();
	virtual INT IsIdentifiedAs(FName);
	virtual INT ReviewPath(class APawn *);

	// Non-virtual methods
	INT CanReach(class ANavigationPoint *, FLOAT);
	void CleanUpPruned();
	INT FindAlternatePath(class UReachSpec *, INT);
	class UReachSpec * GetReachSpecTo(class ANavigationPoint *);
	INT ShouldBeBased();

	// Event thunks
	DWORD eventAccept(class AActor*, class AActor*);
	INT eventSpecialCost(class APawn*, class UReachSpec*);
	DWORD eventSuggestMovePreparation(class APawn*);
};

class ENGINE_API ASmallNavigationPoint : public ANavigationPoint
{
public:
	DECLARE_CLASS(ASmallNavigationPoint,ANavigationPoint,0,Engine)
	NO_DEFAULT_CONSTRUCTOR(ASmallNavigationPoint)
};

class ENGINE_API APhysicsVolume : public AVolume
{
public:
	DECLARE_CLASS(APhysicsVolume,AVolume,0,Engine)
	// Event thunks
	void eventActorEnteredVolume(class AActor*);
	void eventActorLeavingVolume(class AActor*);
	void eventPawnEnteredVolume(class APawn*);
	void eventPawnLeavingVolume(class APawn*);
	void eventPhysicsChangedFor(class AActor*);
	// Auto-generated method declarations
	virtual void SetZone(int,int);
	virtual int * GetOptimizedRepList(BYTE*,FPropertyRetirement *,int *,UPackageMap *,UActorChannel *);
};

class ENGINE_API ADefaultPhysicsVolume : public APhysicsVolume
{
public:
	DECLARE_CLASS(ADefaultPhysicsVolume,APhysicsVolume,0,Engine)
	NO_DEFAULT_CONSTRUCTOR(ADefaultPhysicsVolume)
};

class ENGINE_API ABlockingVolume : public AVolume
{
public:
	DECLARE_CLASS(ABlockingVolume,AVolume,0,Engine)
	NO_DEFAULT_CONSTRUCTOR(ABlockingVolume)
};

class ENGINE_API AAntiPortalActor : public AActor
{
public:
	DECLARE_CLASS(AAntiPortalActor,AActor,0,Engine)
	NO_DEFAULT_CONSTRUCTOR(AAntiPortalActor)
};

class ENGINE_API ANote : public AActor
{
public:
	DECLARE_CLASS(ANote,AActor,0,Engine)
	// Auto-generated method declarations
	virtual void CheckForErrors();
};

class ENGINE_API APolyMarker : public AActor
{
public:
	DECLARE_CLASS(APolyMarker,AActor,0,Engine)
	NO_DEFAULT_CONSTRUCTOR(APolyMarker)
};

class ENGINE_API AClipMarker : public AKeypoint
{
public:
	DECLARE_CLASS(AClipMarker,AKeypoint,0,Engine)
	NO_DEFAULT_CONSTRUCTOR(AClipMarker)
};

class ENGINE_API AStaticMeshActor : public AActor
{
public:
	DECLARE_CLASS(AStaticMeshActor,AActor,0,Engine)
	// Auto-generated method declarations
	virtual int ShouldTrace(AActor *,DWORD);
};

class ENGINE_API AEffects : public AActor
{
public:
	DECLARE_CLASS(AEffects,AActor,0,Engine)
};

class ENGINE_API AAmbientSound : public AActor
{
public:
	DECLARE_CLASS(AAmbientSound,AActor,0,Engine)
};

class ENGINE_API ADecoVolumeObject : public AActor
{
public:
	DECLARE_CLASS(ADecoVolumeObject,AActor,0,Engine)
	NO_DEFAULT_CONSTRUCTOR(ADecoVolumeObject)
};

class ENGINE_API ADecorationList : public AActor
{
public:
	DECLARE_CLASS(ADecorationList,AActor,0,Engine)
	NO_DEFAULT_CONSTRUCTOR(ADecorationList)
};

class ENGINE_API AKActor : public AActor
{
public:
	DECLARE_CLASS(AKActor,AActor,0,Engine)
	// Auto-generated method declarations
	virtual void Spawned();
};

class ENGINE_API AMover : public ABrush
{
public:
	DECLARE_CLASS(AMover,ABrush,0|CLASS_NativeReplication,Engine)
	// Event thunks
	void eventKeyFrameReached();

	void physMovingBrush(FLOAT);

	virtual void performPhysics(FLOAT);
	virtual INT ShouldTrace(AActor*, DWORD);
	virtual void AddMyMarker(AActor*);
	virtual INT* GetOptimizedRepList(BYTE*, struct FPropertyRetirement*, INT*, UPackageMap*, class UActorChannel*);
	virtual void SetWorldRaytraceKey();
	virtual void Spawned();
	virtual void SetBrushRaytraceKey();
	virtual void PostEditChange();
	virtual void PostEditMove();
	virtual void PostLoad();
	virtual void PostNetReceive();
	virtual void PostRaytrace();
	virtual void PreNetReceive();
	virtual void PreRaytrace();
};

class ENGINE_API AProjector : public AActor
{
public:
	DECLARE_CLASS(AProjector,AActor,0,Engine)
	DECLARE_FUNCTION(execAbandonProjector)
	DECLARE_FUNCTION(execAttachActor)
	DECLARE_FUNCTION(execAttachProjector)
	DECLARE_FUNCTION(execDetachActor)
	DECLARE_FUNCTION(execDetachProjector)
	// Event thunks
	void eventLightUpdateDirect(FVector, FLOAT, BYTE);
	void eventUpdateShadow();
	// Auto-generated method declarations
	virtual int ShouldTrace(AActor *,DWORD);
	virtual void TickSpecial(float);
	virtual void UpdateParticleMaterial(UParticleMaterial *,int);
	virtual void RenderEditorSelected(FLevelSceneNode *,FRenderInterface *,FDynamicActor *);
	void RenderWireframe(FRenderInterface *);
	virtual void PostEditChange();
	virtual void PostEditLoad();
	virtual void PostEditMove();
	virtual void Abandon();
	virtual void Attach();
	virtual void CalcMatrix();
	virtual void Destroy();
	virtual void Detach(int);
	virtual UPrimitive * GetPrimitive();
};

class ENGINE_API AShadowProjector : public AProjector
{
public:
	DECLARE_CLASS(AShadowProjector,AProjector,0,Engine)
};

class ENGINE_API AR6MorphMeshActor : public AActor
{
public:
	DECLARE_CLASS(AR6MorphMeshActor,AActor,0,Engine)
	NO_DEFAULT_CONSTRUCTOR(AR6MorphMeshActor)
};

class ENGINE_API AR6ActorSound : public AActor
{
public:
	DECLARE_CLASS(AR6ActorSound,AActor,0,Engine)
};

class ENGINE_API AR6Alarm : public AActor
{
public:
	DECLARE_CLASS(AR6Alarm,AActor,0,Engine)
};

/*==========================================================================
	Class declarations — UnPawn.cpp classes.
==========================================================================*/

class ENGINE_API APawn : public AActor
{
public:
	DECLARE_CLASS(APawn,AActor,0|CLASS_Config|CLASS_NativeReplication,Engine)
	// Member fields (extracted from SDK class definition)
	BYTE FlashCount;
	BYTE Visibility;
	BYTE noiseType;
	BYTE OldPhysics;
	BYTE AnimPlayBackward[4];
	BYTE m_ePeekingMode;
	BYTE m_bIsFiringWeapon;
	BYTE m_ePawnType;
	BYTE m_eEffectiveGrenade;
	BYTE m_eGrenadeThrow;
	BYTE m_eRepGrenadeThrow;
	BYTE m_eHealth;
	INT Health;
	INT m_iIsInStairVolume;
	INT m_iNoCircleBeat;
	INT m_iTeam;
	INT m_iDefaultTeam;
	INT m_iFriendlyTeams;
	INT m_iEnemyTeams;
	INT m_iExtentX0;
	INT m_iExtentY0;
	INT m_iExtentZ0;
	INT m_iExtentX1;
	INT m_iExtentY1;
	INT m_iExtentZ1;
	INT m_iProneTrailPtr;
	INT m_iCurrentFloor;
	BITFIELD bJustLanded : 1;
	BITFIELD bUpAndOut : 1;
	BITFIELD bIsWalking : 1;
	BITFIELD bWarping : 1;
	BITFIELD bWantsToCrouch : 1;
	BITFIELD bIsCrouched : 1;
	BITFIELD bTryToUncrouch : 1;
	BITFIELD bCanCrouch : 1;
	BITFIELD m_bWantsToProne : 1;
	BITFIELD m_bIsProne : 1;
	BITFIELD m_bTryToUnProne : 1;
	BITFIELD m_bCanProne : 1;
	BITFIELD bCrawler : 1;
	BITFIELD bReducedSpeed : 1;
	BITFIELD bCanJump : 1;
	BITFIELD bCanWalk : 1;
	BITFIELD bCanSwim : 1;
	BITFIELD bCanFly : 1;
	BITFIELD bCanClimbLadders : 1;
	BITFIELD bCanStrafe : 1;
	BITFIELD bAvoidLedges : 1;
	BITFIELD bStopAtLedges : 1;
	BITFIELD bNoJumpAdjust : 1;
	BITFIELD bCountJumps : 1;
	BITFIELD bSimulateGravity : 1;
	BITFIELD bIgnoreForces : 1;
	BITFIELD bNoVelocityUpdate : 1;
	BITFIELD bCanWalkOffLedges : 1;
	BITFIELD bSteadyFiring : 1;
	BITFIELD bCanBeBaseForPawns : 1;
	BITFIELD bThumped : 1;
	BITFIELD bInvulnerableBody : 1;
	BITFIELD bIsFemale : 1;
	BITFIELD bAutoActivate : 1;
	BITFIELD bUpdatingDisplay : 1;
	BITFIELD bAmbientCreature : 1;
	BITFIELD bLOSHearing : 1;
	BITFIELD bSameZoneHearing : 1;
	BITFIELD bAdjacentZoneHearing : 1;
	BITFIELD bMuffledHearing : 1;
	BITFIELD bAroundCornerHearing : 1;
	BITFIELD bDontPossess : 1;
	BITFIELD bAutoFire : 1;
	BITFIELD bRollToDesired : 1;
	BITFIELD bIgnorePlayFiring : 1;
	BITFIELD m_bArmPatchSet : 1;
	BITFIELD bCachedRelevant : 1;
	BITFIELD bUseCompressedPosition : 1;
	BITFIELD m_bDroppedWeapon : 1;
	BITFIELD m_bHaveGasMask : 1;
	BITFIELD m_bUseHighStance : 1;
	BITFIELD m_bWantsHighStance : 1;
	BITFIELD m_bTurnRight : 1;
	BITFIELD m_bTurnLeft : 1;
	BITFIELD bPhysicsAnimUpdate : 1;
	BITFIELD bWasProne : 1;
	BITFIELD bWasCrouched : 1;
	BITFIELD bWasWalking : 1;
	BITFIELD bWasOnGround : 1;
	BITFIELD bInitializeAnimation : 1;
	BITFIELD bPlayedDeath : 1;
	BITFIELD m_bIsLanding : 1;
	BITFIELD m_bMakesTrailsWhenProning : 1;
	BITFIELD m_bPeekingLeft : 1;
	BITFIELD m_bHBJammerOn : 1;
	BITFIELD m_bUseSpecialSkin : 1;
	BITFIELD m_bIsDeadBody : 1;
	BITFIELD m_bAnimStopedForRG : 1;
	BITFIELD m_bIsPlayer : 1;
	BITFIELD m_bFlashBangVisualEffectRequested : 1;
	BITFIELD m_bRepFinishShotgun : 1;
	FLOAT m_fFallingHeight;
	FLOAT NetRelevancyTime;
	FLOAT DesiredSpeed;
	FLOAT MaxDesiredSpeed;
	FLOAT Alertness;
	FLOAT SightRadius;
	FLOAT PeripheralVision;
	FLOAT SkillModifier;
	FLOAT AvgPhysicsTime;
	FLOAT MeleeRange;
	FLOAT DestinationOffset;
	FLOAT NextPathRadius;
	FLOAT SerpentineDist;
	FLOAT SerpentineTime;
	FLOAT UncrouchTime;
	FLOAT GroundSpeed;
	FLOAT WaterSpeed;
	FLOAT AirSpeed;
	FLOAT LadderSpeed;
	FLOAT AccelRate;
	FLOAT JumpZ;
	FLOAT AirControl;
	FLOAT WalkingPct;
	FLOAT CrouchedPct;
	FLOAT MaxFallSpeed;
	FLOAT SplashTime;
	FLOAT CrouchHeight;
	FLOAT CrouchRadius;
	FLOAT BreathTime;
	FLOAT UnderWaterTime;
	FLOAT m_fProneHeight;
	FLOAT m_fProneRadius;
	FLOAT noiseTime;
	FLOAT noiseLoudness;
	FLOAT m_NextBulletImpact;
	FLOAT m_NextFireSound;
	FLOAT LastPainSound;
	FLOAT Bob;
	FLOAT LandBob;
	FLOAT AppliedBob;
	FLOAT bobtime;
	FLOAT SoundDampening;
	FLOAT DamageScaling;
	FLOAT CarcassCollisionHeight;
	FLOAT OldRotYaw;
	FLOAT BaseMovementRate;
	FLOAT BlendChangeTime;
	FLOAT MovementBlendStartTime;
	FLOAT ForwardStrafeBias;
	FLOAT BackwardStrafeBias;
	FLOAT m_fCrouchBlendRate;
	FLOAT m_fHeartBeatTime[2];
	FLOAT m_fHeartBeatFrequency;
	FLOAT m_fBlurValue;
	FLOAT m_fDecrementalBlurValue;
	FLOAT m_fRepDecrementalBlurValue;
	FLOAT m_fRemainingGrenadeTime;
	FLOAT m_fFlashBangVisualEffectTime;
	FLOAT m_fXFlashBang;
	FLOAT m_fYFlashBang;
	FLOAT m_fDistanceFlashBang;
	FLOAT m_fLastCommunicationTime;
	FLOAT m_fPrePivotPawnInitialOffset;
	class AController* Controller;
	class APlayerController* LastRealViewer;
	class AActor* LastViewer;
	class ANavigationPoint* Anchor;
	class AR6EngineWeapon* EngineWeapon;
	class AR6EngineWeapon* PendingWeapon;
	class AR6EngineWeapon* m_WeaponsCarried[4];
	class APhysicsVolume* HeadVolume;
	class APlayerReplicationInfo* PlayerReplicationInfo;
	class ALadderVolume* OnLadder;
	class UMaterial* m_HitMaterial;
	class UTexture* m_pHeartBeatTexture;
	class USound* m_sndHBSSound;
	class USound* m_sndHearToneSound;
	class USound* m_sndHearToneSoundStop;
	class UTexture* m_ArmPatchTexture;
	FName AIScriptTag;
	FName LandMovementState;
	FName WaterMovementState;
	FName AnimStatus;
	FName AnimAction;
	FName MovementAnims[4];
	FName TurnLeftAnim;
	FName TurnRightAnim;
	class UClass* BloodEffect;
	class UClass* LowDetailBlood;
	class UClass* LowGoreBlood;
	class UClass* ControllerClass;
	class UClass* m_HelmetClass;
	class FVector SerpentineDir;
	class FVector ConstantAcceleration;
	class FVector Floor;
	class FVector m_vLastNetLocation;
	class FVector noiseSpot;
	class FVector WalkBob;
	class FVector TakeHitLocation;
	class FVector TearOffMomentum;
	class FVector OldAcceleration;
	class FVector m_vEyeLocation;
	class FRotator m_rRotationOffset;
	class FVector m_vGrenadeLocation;
	class FGuid m_ArmPatchGUID;
	class FString OwnerName;
	class FString MenuName;
	class FString m_CharacterName;
	struct FCompressedPosition PawnPosition;

	// Virtual methods
	virtual INT * GetOptimizedRepList(BYTE *, struct FPropertyRetirement *, INT *, class UPackageMap *, class UActorChannel *);
	virtual class APawn * GetPawnOrColBoxOwner() const;
	virtual class APawn * GetPlayerPawn() const;
	virtual INT IsBlockedBy(class AActor const *) const;
	virtual FLOAT GetNetPriority(class AActor *, FLOAT, FLOAT);
	virtual void PreNetReceive();
	virtual void PostNetReceive();
	virtual void PostNetReceiveLocation();
	virtual INT ShouldTrace(class AActor *, DWORD);
	virtual void NotifyBump(class AActor *);
	virtual void SetBase(class AActor *, class FVector, INT);
	virtual void NotifyAnimEnd(INT);
	virtual INT CheckOwnerUpdated();
	virtual void TickSimulated(FLOAT);
	virtual void TickSpecial(FLOAT);
	virtual INT PlayerControlled();
	virtual INT IsNetRelevantFor(class APlayerController *, class AActor *, class FVector);
	virtual void RenderEditorSelected(class FLevelSceneNode *, class FRenderInterface *, class FDynamicActor *);
	virtual void SetZone(INT, INT);
	virtual void PostBeginPlay();
	virtual void performPhysics(FLOAT);
	virtual void processHitWall(class FVector, class AActor *);
	virtual void processLanded(class FVector, class AActor *, FLOAT, INT);
	virtual void physFalling(FLOAT, INT);
	virtual class FRotator FindSlopeRotation(class FVector, class FRotator);
	virtual void SmoothHitWall(class FVector, class AActor *);
	virtual void stepUp(class FVector, class FVector, class FVector, struct FCheckResult &);
	virtual void CheckForErrors();
	virtual INT moveToward(class FVector const &, class AActor *);
	virtual INT HurtByVolume(class AActor *);
	virtual void SetPrePivot(class FVector);
	virtual class FVector CheckForLedges(class AActor *, class FVector, class FVector, class FVector, INT &, INT &, FLOAT);
	virtual void physLadder(FLOAT, INT);
	virtual void physicsRotation(FLOAT, class FVector);
	virtual void UpdateMovementAnimation(FLOAT);
	virtual DWORD R6SeePawn(class APawn *, INT);
	virtual DWORD R6LineOfSightTo(class AActor *, INT);
	virtual void calcVelocity(class FVector, FLOAT, FLOAT, FLOAT, INT, INT, INT);
	virtual void Destroy();

	// Native C++ methods
	APawn();
	INT CacheNetRelevancy(INT, class APlayerController *, class AActor *);
	INT CanCrouchWalk(class FVector const &, class FVector const &);
	INT CanProneWalk(class FVector const &, class FVector const &);
	void ClearSerpentine();
	void Crouch(INT);
	enum ETestMoveResult FindBestJump(class FVector);
	enum ETestMoveResult FindJumpUp(class FVector);
	FLOAT GetMaxSpeed();
	INT IsAlive();
	INT IsCrouched();
	INT IsEnemy(class APawn *);
	INT IsFriend(INT);
	INT IsFriend(class APawn *);
	INT IsHumanControlled();
	INT IsLocallyControlled();
	INT IsNeutral(class APawn *);
	INT IsPlayer();
	class FVector NewFallVelocity(class FVector, class FVector, FLOAT);
	INT PickWallAdjust(class FVector);
	INT Reachable(class FVector, class AActor *);
	INT ReachedDestination(class FVector, class AActor *);
	void StartNewSerpentine(class FVector, class FVector);
	class FVector SuggestJumpVelocity(class FVector, FLOAT, FLOAT);
	void UnCrouch(INT);
	INT ValidAnchor();
	void ZeroMovementAlpha(INT, INT, FLOAT);
	INT actorReachable(class AActor *, INT, INT);
	class ANavigationPoint * breadthPathTo(FLOAT (CDECL*)(class ANavigationPoint *, class APawn *, FLOAT), class ANavigationPoint *, INT, FLOAT *);
	INT calcMoveFlags();
	void clearPath(class ANavigationPoint *);
	void clearPaths();
	FLOAT findPathToward(class AActor *, class FVector, FLOAT (CDECL*)(class ANavigationPoint *, class APawn *, FLOAT), INT, FLOAT);
private:
	INT findNewFloor(class FVector, FLOAT, FLOAT, INT);
public:
	enum ETestMoveResult flyMove(class FVector, class AActor *, FLOAT);
	INT flyReachable(class FVector, INT, class AActor *);
	enum ETestMoveResult jumpLanding(class FVector, INT);
	INT jumpReachable(class FVector, INT, class AActor *);
	INT ladderReachable(class FVector, INT, class AActor *);
	void physFlying(FLOAT, INT);
	void physSpider(FLOAT, INT);
	void physSwimming(FLOAT, INT);
	void physWalking(FLOAT, INT);
	INT pointReachable(class FVector, INT);
	void rotateToward(class AActor *, class FVector);
	void setMoveTimer(FLOAT);
	void startNewPhysics(FLOAT, INT);
	void startSwimming(class FVector, class FVector, FLOAT, FLOAT, INT);
	enum ETestMoveResult swimMove(class FVector, class AActor *, FLOAT);
	INT swimReachable(class FVector, INT, class AActor *);
	enum ETestMoveResult walkMove(class FVector, struct FCheckResult &, class AActor *, FLOAT);
	INT walkReachable(class FVector, INT, class AActor *);

private:
	INT Pick3DWallAdjust(class FVector);
	void SpiderstepUp(class FVector, class FVector, struct FCheckResult &);
	FLOAT Swim(class FVector, struct FCheckResult &);
	INT checkFloor(class FVector, struct FCheckResult &);
	class FVector findWaterLine(class FVector, class FVector);

public:
	// Non-indexed exec
	DECLARE_FUNCTION(execReachedDestination)
	DECLARE_FUNCTION(execIsFriend)
	DECLARE_FUNCTION(execIsEnemy)
	DECLARE_FUNCTION(execIsNeutral)
	DECLARE_FUNCTION(execIsAlive)
	// Event thunks
	void eventBreathTimer();
	void eventChangeAnimation();
	void eventClientMessage(const FString&, FName);
	void eventEndClimbLadder(class ALadderVolume*);
	void eventEndCrouch(FLOAT);
	FVector eventEyePosition();
	FRotator eventGetViewRotation();
	void eventHeadVolumeChange(class APhysicsVolume*);
	void eventPlayDying(FVector);
	void eventPlayFalling();
	void eventPlayJump();
	void eventPlayLandingAnimation(FLOAT);
	void eventPlayWeaponAnimation();
	void eventR6DeadEndedMoving();
	void eventReceivedEngineWeapon();
	void eventReceivedWeapons();
	void eventSetAnimAction(FName);
	void eventSetWalking(DWORD);
	void eventStartCrouch(FLOAT);
	void eventStopAnimForRG();
	void eventStopPlayFiring();
};

class ENGINE_API AController : public AActor
{
public:
	DECLARE_CLASS(AController,AActor,0|CLASS_NativeReplication,Engine)

	// Member variables (from SDK EngineClasses.h)
	BYTE AttitudeToPlayer;
	BYTE bRun;
	BYTE bFire;
	BYTE bAltFire;
	BYTE m_bMoveUp;
	BYTE m_bMoveDown;
	BYTE m_bMoveLeft;
	BYTE m_bMoveRight;
	BYTE m_bRotateCW;
	BYTE m_bRotateCCW;
	BYTE m_bZoomIn;
	BYTE m_bZoomOut;
	BYTE m_bAngleUp;
	BYTE m_bAngleDown;
	BYTE m_bLevelUp;
	BYTE m_bLevelDown;
	BYTE m_bGoLevelUp;
	BYTE m_bGoLevelDown;
	BYTE bDuck;
	BYTE m_eMoveToResult;
	BITFIELD bIsPlayer : 1;
	BITFIELD bGodMode : 1;
	BITFIELD bLOSflag : 1;
	BITFIELD bAdvancedTactics : 1;
	BITFIELD bCanOpenDoors : 1;
	BITFIELD bCanDoSpecial : 1;
	BITFIELD bAdjusting : 1;
	BITFIELD bPreparingMove : 1;
	BITFIELD bControlAnimations : 1;
	BITFIELD bEnemyInfoValid : 1;
	BITFIELD m_bCrawl : 1;
	BITFIELD m_bLockWeaponActions : 1;
	BITFIELD m_bHideReticule : 1;
	FLOAT SightCounter;
	FLOAT FovAngle;
	FLOAT Handedness;
	FLOAT Stimulus;
	FLOAT MoveTimer;
	FLOAT MinHitWall;
	FLOAT LastSeenTime;
	FLOAT OldMessageTime;
	FLOAT RouteDist;
	FLOAT GroundPitchTime;
	FLOAT MonitorMaxDistSq;
	class APawn* Pawn;
	class AController* nextController;
	class AActor* MoveTarget;
	class AActor* Focus;
	class AMover* PendingMover;
	class AActor* GoalList[4];
	class ANavigationPoint* home;
	class APawn* Enemy;
	class AActor* Target;
	class AActor* RouteCache[16];
	class UReachSpec* CurrentPath;
	class AActor* RouteGoal;
	class APlayerReplicationInfo* PlayerReplicationInfo;
	class ANavigationPoint* StartSpot;
	class AR6PawnReplicationInfo* m_PawnRepInfo;
	class APawn* MonitoredPawn;
	FName NextState;
	FName NextLabel;
	class UClass* PlayerReplicationInfoClass;
	class UClass* PawnClass;
	class UClass* PreviousPawnClass;
	class FVector AdjustLoc;
	class FVector Destination;
	class FVector FocalPoint;
	class FVector LastSeenPos;
	class FVector LastSeeingPos;
	class FVector ViewX;
	class FVector ViewY;
	class FVector ViewZ;
	class FVector MonitorStartLoc;
	class FString VoiceType;

	// Virtual methods
	virtual INT * GetOptimizedRepList(BYTE *, struct FPropertyRetirement *, INT *, class UPackageMap *, class UActorChannel *);
	virtual class AActor * GetTeamManager();
	virtual INT LocalPlayerController();
	virtual INT Tick(FLOAT, enum ELevelTick);
	virtual void AdjustFromWall(class FVector, class AActor *);
	virtual void StartAnimPoll();
	virtual INT CheckAnimFinished(INT);
	virtual INT AcceptNearbyPath(class AActor *);
	virtual INT CanHear(class FVector, FLOAT, class AActor *, enum ENoiseType, enum EPawnType);
	virtual void CheckHearSound(class AActor *, INT, class USound *, class FVector, FLOAT, INT);
	virtual class AActor * GetViewTarget();
	virtual void SetAdjustLocation(class FVector);

	// Non-virtual methods
	INT CanHearSound(class FVector, class AActor *, FLOAT, class FVector &);
	void CheckEnemyVisible();
	class AActor * FindPath(class FVector, class AActor *, INT);
	class AActor * HandleSpecial(class AActor *);
	DWORD LineOfSightTo(class AActor *, INT);
	DWORD SeePawn(class APawn *, INT);
	class AActor * SetPath(INT);
	void SetRouteCache(class ANavigationPoint *, FLOAT, FLOAT);
	void ShowSelf();

	// Indexed exec
	DECLARE_FUNCTION(execMoveTo)
	DECLARE_FUNCTION(execMoveToward)
	DECLARE_FUNCTION(execStrafeTo)
	DECLARE_FUNCTION(execStrafeFacing)
	DECLARE_FUNCTION(execTurnTo)
	DECLARE_FUNCTION(execTurnToward)
	DECLARE_FUNCTION(execLineOfSightTo)
	DECLARE_FUNCTION(execFindPathToward)
	DECLARE_FUNCTION(execFindPathTo)
	DECLARE_FUNCTION(execactorReachable)
	DECLARE_FUNCTION(execpointReachable)
	DECLARE_FUNCTION(execClearPaths)
	DECLARE_FUNCTION(execEAdjustJump)
	DECLARE_FUNCTION(execFindRandomDest)
	DECLARE_FUNCTION(execPickWallAdjust)
	DECLARE_FUNCTION(execWaitForLanding)
	DECLARE_FUNCTION(execAddController)
	DECLARE_FUNCTION(execRemoveController)
	DECLARE_FUNCTION(execPickTarget)
	DECLARE_FUNCTION(execCanSee)
	DECLARE_FUNCTION(execPickAnyTarget)
	DECLARE_FUNCTION(execFindBestInventoryPath)
	DECLARE_FUNCTION(execFinishRotation)
	DECLARE_FUNCTION(execFindPathTowardNearest)
	// Non-indexed exec
	DECLARE_FUNCTION(execStopWaiting)
	DECLARE_FUNCTION(execInLatentExecution)
	DECLARE_FUNCTION(execEndClimbLadder)
	DECLARE_FUNCTION(execPollMoveTo)
	DECLARE_FUNCTION(execPollMoveToward)
	DECLARE_FUNCTION(execPollWaitForLanding)
	DECLARE_FUNCTION(execPollFinishRotation)
	// Event thunks
	void eventAIHearSound(class AActor*, INT, class USound*, FVector, FVector, DWORD);
	void eventEnemyNotVisible();
	void eventHearNoise(FLOAT, class AActor*, BYTE, BYTE);
	void eventLongFall();
	void eventMayFall();
	void eventMonitoredPawnAlert();
	DWORD eventNotifyBump(class AActor*);
	DWORD eventNotifyHeadVolumeChange(class APhysicsVolume*);
	void eventNotifyHitMover(FVector, class AMover*);
	DWORD eventNotifyHitWall(FVector, class AActor*);
	DWORD eventNotifyLanded(FVector);
	DWORD eventNotifyPhysicsVolumeChange(class APhysicsVolume*);
	void eventPrepareForMove(class ANavigationPoint*, class UReachSpec*);
	void eventSeeMonster(class APawn*);
	void eventSeePlayer(class APawn*);
};

class ENGINE_API APlayerController : public AController
{
public:
	DECLARE_CLASS(APlayerController,AController,0|CLASS_Config|CLASS_NativeReplication,Engine)
	// Indexed exec
	DECLARE_FUNCTION(execFindStairRotation)
	DECLARE_FUNCTION(execResetKeyboard)
	DECLARE_FUNCTION(execUpdateURL)
	DECLARE_FUNCTION(execPB_CanPlayerSpawn)
	DECLARE_FUNCTION(execGetKey)
	DECLARE_FUNCTION(execGetActionKey)
	DECLARE_FUNCTION(execGetEnumName)
	DECLARE_FUNCTION(execChangeInputSet)
	DECLARE_FUNCTION(execSetKey)
	DECLARE_FUNCTION(execSetSoundOptions)
	DECLARE_FUNCTION(execChangeVolumeTypeLinear)
	DECLARE_FUNCTION(execClientHearSound)
	// Non-indexed exec
	DECLARE_FUNCTION(execConsoleCommand)
	DECLARE_FUNCTION(execGetValueFromMenu)
	DECLARE_FUNCTION(execGetDefaultURL)
	DECLARE_FUNCTION(execGetEntryLevel)
	DECLARE_FUNCTION(execSetViewTarget)
	DECLARE_FUNCTION(execSpecialDestroy)
	DECLARE_FUNCTION(execClientTravel)
	DECLARE_FUNCTION(execGetPlayerNetworkAddress)
	DECLARE_FUNCTION(execCopyToClipboard)
	DECLARE_FUNCTION(execPasteFromClipboard)
	DECLARE_FUNCTION(execIsPBEnabled)
	DECLARE_FUNCTION(execGetPBConnectStatus)
	// Event thunks
	void eventAddCameraEffect(class UCameraEffect*, DWORD);
	void eventClientHearSound(class AActor*, class USound*, BYTE);
	void eventClientMessage(const FString&, FName);
	void eventClientPBKickedOutMessage(const FString&);
	void eventClientSetNewViewTarget();
	void eventClientTravel(const FString&, BYTE, DWORD);
	FString eventGetLocalPlayerIp();
	void eventHandleServerMsg(const FString&, INT);
	void eventInitInputSystem();
	void eventInitMultiPlayerOptions();
	DWORD eventIsPlayerPassiveSpectator();
	void eventPlayerCalcView(class AActor*&, FVector&, FRotator&);
	void eventPlayerTick(FLOAT);
	void eventPreClientTravel();
	void eventReceiveLocalizedMessage(class UClass*, INT, class APlayerReplicationInfo*, class APlayerReplicationInfo*, class UObject*);
	void eventRemoveCameraEffect(class UCameraEffect*);
	void eventSetMatchResult(const FString&, INT, INT);
	void eventSetProgressTime(FLOAT);
	void eventTeamMessage(class APlayerReplicationInfo*, const FString&, FName);
	void eventToggleRadar(DWORD);
	// Auto-generated method declarations
	void SpecialDestroy();
	virtual int Tick(float,ELevelTick);
	void R6PBKickPlayer(FString);
	void SetPlayer(UPlayer *);
	virtual int LocalPlayerController();
	virtual void PostNetReceive();
	virtual void PreNetReceive();
	virtual void CheckHearSound(AActor *,int,USound *,FVector,float,int);
	virtual int * GetOptimizedRepList(BYTE*,FPropertyRetirement *,int *,UPackageMap *,UActorChannel *);
	FString GetPlayerNetworkAddress();
	virtual AActor * GetViewTarget();
	virtual int IsNetRelevantFor(APlayerController *,AActor *,FVector);
};

class ENGINE_API AAIController : public AController
{
public:
	DECLARE_CLASS(AAIController,AController,0|CLASS_NativeReplication,Engine)
	DECLARE_FUNCTION(execWaitToSeeEnemy)
	DECLARE_FUNCTION(execPollWaitToSeeEnemy)
	// Auto-generated method declarations
	virtual void SetAdjustLocation(FVector);
	virtual int AcceptNearbyPath(AActor *);
	virtual void AdjustFromWall(FVector,AActor *);
};

/*==========================================================================
	Class declarations — UnLevel.cpp classes.
==========================================================================*/

class ENGINE_API ULevelBase : public UObject, public FNetworkNotify
{
public:
	DECLARE_ABSTRACT_CLASS(ULevelBase,UObject,0,Engine)

	// Database.
	TTransArray<AActor*> Actors;

	// Variables.
	class UNetDriver*	NetDriver;
	class UEngine*		Engine;
	FURL				URL;
	class UNetDriver*	DemoRecDriver;

	// Constructors.
	ULevelBase( UEngine* InOwner, const FURL& InURL=FURL(NULL) );

	// UObject interface.
	virtual void Serialize( FArchive& Ar );
	virtual void Destroy();

	// FNetworkNotify interface.
	virtual void NotifyProgress( const TCHAR* Str1, const TCHAR* Str2, FLOAT Seconds );

protected:
	ULevelBase()
	: Actors( this )
	{}
};

class ENGINE_API ULevel : public ULevelBase
{
public:
	DECLARE_CLASS(ULevel,ULevelBase,0,Engine)

	// Constructor.
	ULevel( UEngine* InEngine, INT InRootOutside );

	// UObject interface.
	virtual void Serialize( FArchive& Ar );
	virtual void PostLoad();
	virtual void Destroy();

	// ULevel interface.
	virtual void Modify( INT DoTransArrays=0 );
	virtual void SetActorCollision( INT bCollision, INT bUnused=0 );
	virtual void Tick( ELevelTick TickType, FLOAT DeltaSeconds );
	virtual void TickNetClient( FLOAT DeltaSeconds );
	virtual void TickNetServer( FLOAT DeltaSeconds );
	virtual INT ServerTickClient( class UNetConnection* Conn, FLOAT DeltaSeconds );
	virtual void ReconcileActors();
	virtual void RememberActors();
	virtual INT Exec( const TCHAR* Cmd, FOutputDevice& Ar );
	virtual void ShrinkLevel();
	virtual void CompactActors();
	virtual INT Listen( FString& Error );
	virtual INT IsServer();
	virtual INT MoveActor( AActor* Actor, FVector Delta, FRotator NewRotation, FCheckResult& Hit, INT bTest=0, INT bIgnorePawns=0, INT bIgnoreBases=0, INT bNoFail=0, INT bExtra=0 );
	virtual INT FarMoveActor( AActor* Actor, FVector DestLocation, INT bTest=0, INT bNoCheck=0, INT bAttachedMove=0, INT bExtra=0 );
	virtual INT DestroyActor( AActor* Actor, INT bNetForce=0 );
	virtual void CleanupDestroyed( INT bForce );
	virtual AActor* SpawnActor( UClass* Class, FName InName=NAME_None, FVector Location=FVector(0,0,0), FRotator Rotation=FRotator(0,0,0), AActor* Template=NULL, INT bNoCollisionFail=0, INT bRemoteOwned=0, AActor* SpawnTag=NULL, APawn* Instigator=NULL );
	virtual ABrush* SpawnBrush();
	virtual void SpawnViewActor( class UViewport* Viewport );
	virtual APlayerController* SpawnPlayActor( class UPlayer* Player, ENetRole RemoteRole, const FURL& URL, FString& Error );
	virtual INT FindSpot( FVector Extent, FVector& Location, INT bCheckActors=0, AActor* Requester=NULL );
	virtual INT CheckSlice( FVector& Adjusted, FVector TraceDest, INT& TraceLen, AActor* Actor );
	virtual INT CheckEncroachment( AActor* Actor, FVector TestLocation, FRotator TestRotation, INT bTouchNotify );
	virtual INT SinglePointCheck( FCheckResult& Hit, AActor* SourceActor, FVector Location, FVector Extent, DWORD ExtraNodeFlags, ALevelInfo* Level, INT bActors );
	virtual INT SinglePointCheck( FCheckResult& Hit, FVector Location, FVector Extent, DWORD ExtraNodeFlags, ALevelInfo* Level, INT bActors );
	virtual INT SingleLineCheck( FCheckResult& Hit, AActor* SourceActor, const FVector& End, const FVector& Start, DWORD TraceFlags, FVector Extent );
	virtual INT EncroachingWorldGeometry( FCheckResult& Hit, FVector Location, FVector Extent, DWORD ExtraNodeFlags, ALevelInfo* Level, AActor* Actor );
	virtual FCheckResult* MultiPointCheck( FMemStack& Mem, FVector Location, FVector Extent, DWORD ExtraNodeFlags, ALevelInfo* Level, INT bActors, INT bOnlyWorldGeometry=0, INT bSingleResult=0, AActor* Requester=NULL );
	virtual FCheckResult* MultiLineCheck( FMemStack& Mem, FVector End, FVector Start, FVector Extent, ALevelInfo* Level, DWORD TraceFlags, AActor* SourceActor );
	virtual void DetailChange( INT NewDetail );
	virtual INT TickDemoRecord( FLOAT DeltaSeconds );
	virtual INT TickDemoPlayback( FLOAT DeltaSeconds );
	virtual void UpdateTime( ALevelInfo* Info );
	virtual INT IsPaused();
	virtual void WelcomePlayer( class UNetConnection* Connection, TCHAR* Optional=TEXT("") );
	virtual INT IsAudibleAt( FVector Location, FVector ListenerLocation, AActor* SourceActor, ESoundOcclusion Occlusion );
	virtual FLOAT CalculateRadiusMultiplier( INT SoundRadius, INT SoundRadiusInner );

	// FNetworkNotify interface.
	virtual EAcceptConnection NotifyAcceptingConnection();
	virtual void NotifyAcceptedConnection( class UNetConnection* Connection );
	virtual INT NotifyAcceptingChannel( class UChannel* Channel );
	virtual ULevel* NotifyGetLevel();
	virtual void NotifyReceivedText( class UNetConnection* Connection, const TCHAR* Text );
	virtual INT NotifySendingFile( class UNetConnection* Connection, FGuid GUID );
	virtual void NotifyReceivedFile( class UNetConnection* Connection, INT PackageIndex, const TCHAR* Error, INT Forced );

	// Non-virtual methods.
	ABrush* Brush();
	INT EditorDestroyActor( AActor* Actor );
	INT GetActorIndex( AActor* Actor );
	ALevelInfo* GetLevelInfo();
	class AZoneInfo* GetZoneActor( INT iZone );
	INT MoveActorFirstBlocking( AActor* Actor, INT bTest, INT bIgnorePawns, FCheckResult* FirstHit, FCheckResult& Hit );
	INT ToFloor( AActor* Actor, INT bTest, AActor* IgnoreActor );
	void UpdateTerrainArrays();

protected:
	ULevel() {}
};

class ENGINE_API AZoneInfo : public AInfo
{
public:
	DECLARE_CLASS(AZoneInfo,AInfo,0|CLASS_NativeReplication,Engine)
	DECLARE_FUNCTION(execZoneActors)
	// Event thunks
	void eventActorEntered(class AActor*);
	void eventActorLeaving(class AActor*);
	// Auto-generated method declarations
	virtual void PostEditChange();
};

class ENGINE_API ALevelInfo : public AZoneInfo
{
public:
	DECLARE_CLASS(ALevelInfo,AZoneInfo,0|CLASS_Config|CLASS_NativeReplication,Engine)
	DECLARE_FUNCTION(execGetAddressURL)
	DECLARE_FUNCTION(execGetLocalURL)
	DECLARE_FUNCTION(execGetMapNameLocalisation)
	DECLARE_FUNCTION(execFinalizeLoading)
	DECLARE_FUNCTION(execResetLevelInNative)
	DECLARE_FUNCTION(execSetBankSound)
	DECLARE_FUNCTION(execNotifyMatchStart)
	DECLARE_FUNCTION(execPBNotifyServerTravel)
	DECLARE_FUNCTION(execCallLogThisActor)
	DECLARE_FUNCTION(execAddWritableMapPoint)
	DECLARE_FUNCTION(execAddWritableMapIcon)
	DECLARE_FUNCTION(execAddEncodedWritableMapStrip)
	// Event thunks
	void eventServerTravel(const FString&, DWORD);
	DWORD eventGameTypeUseNbOfTerroristToSpawn(const FString&);
	DWORD eventIsGameTypePlayWithNonRainbowNPCs(const FString&);
};

class ENGINE_API AGameInfo : public AInfo
{
public:
	DECLARE_CLASS(AGameInfo,AInfo,0|CLASS_Config,Engine)
	DECLARE_FUNCTION(execGetNetworkNumber)
	DECLARE_FUNCTION(execGetCurrentMapNum)
	DECLARE_FUNCTION(execSetCurrentMapNum)
	DECLARE_FUNCTION(execParseKillMessage)
	DECLARE_FUNCTION(execProcessR6Availabilty)
	DECLARE_FUNCTION(execAbortScoreSubmission)
	// Event thunks
	void eventAcceptInventory(class APawn*);
	void eventBroadcast(class AActor*, const FString&, FName);
	void eventBroadcastLocalized(class AActor*, class UClass*, INT, class APlayerReplicationInfo*, class APlayerReplicationInfo*, class UObject*);
	DWORD eventCanPlayIntroVideo();
	DWORD eventCanPlayOutroVideo();
	void eventDetailChange();
	void eventGameEnding();
	FString eventGetBeaconText();
	void eventInitGame(const FString&, FString&);
	class APlayerController* eventLogin(const FString&, const FString&, FString&);
	void eventPostLogin(class APlayerController*);
	void eventPreLogin(const FString&, const FString&, FString&, FString&);
	void eventPreLogOut(class APlayerController*);
	void eventUpdateServer();
};

class ENGINE_API AReplicationInfo : public AInfo
{
public:
	DECLARE_CLASS(AReplicationInfo,AInfo,0,Engine)

	void StaticConstructor();
	virtual void StartVideo(UCanvas*, INT, INT, INT);
	virtual void StopVideo(UCanvas*);
	virtual INT OpenVideo(UCanvas*, char*, char*, INT);
	virtual void ChangeDrawingSurface(ER6SwitchSurface, INT);
	virtual void CloseVideo(UCanvas*);
	virtual void DisplayVideo(UCanvas*, void*, INT);
	virtual void Draw3DLine(FVector, FVector, FColor, UTexture*, FLOAT, FLOAT, FLOAT, FLOAT);
	virtual void GetAvailableResolutions(TArray<struct FResolutionInfo>&);
	virtual DWORD GetAvailableVideoMemory();
	virtual void HandleFullScreenEffects(INT, INT);
	NO_DEFAULT_CONSTRUCTOR(AReplicationInfo)
};

class ENGINE_API APlayerReplicationInfo : public AReplicationInfo
{
public:
	DECLARE_CLASS(APlayerReplicationInfo,AReplicationInfo,0|CLASS_NativeReplication,Engine)
};

class ENGINE_API AGameReplicationInfo : public AReplicationInfo
{
public:
	DECLARE_CLASS(AGameReplicationInfo,AReplicationInfo,0|CLASS_Config|CLASS_NativeReplication,Engine)
	// Event thunks
	void eventNewServerState();
	void eventSaveRemoteServerSettings(const FString&);
};

class ENGINE_API AR6PawnReplicationInfo : public APlayerReplicationInfo
{
public:
	DECLARE_CLASS(AR6PawnReplicationInfo,APlayerReplicationInfo,0,Engine)
	NO_DEFAULT_CONSTRUCTOR(AR6PawnReplicationInfo)
};

/*==========================================================================
	Class declarations — UnRender.cpp classes.
==========================================================================*/

class ENGINE_API URenderDevice : public USubsystem
{
public:
	DECLARE_CLASS(URenderDevice,USubsystem,CLASS_Config,Engine)
	virtual UBOOL Exec( const TCHAR* Cmd, FOutputDevice& Ar ) { return 0; }
	// Auto-generated method declarations
	virtual void StartVideo(UCanvas *,int,int,int);
	void StaticConstructor();
	virtual void StopVideo(UCanvas *);
	virtual int OpenVideo(UCanvas *,char *,char *,int);
	virtual void ChangeDrawingSurface(ER6SwitchSurface,int);
	virtual void CloseVideo(UCanvas *);
	virtual void DisplayVideo(UCanvas *,void *,int);
	virtual void Draw3DLine(FVector,FVector,FColor,UTexture *,float,float,float,float);
	virtual void GetAvailableResolutions(TArray<FResolutionInfo> &);
	virtual DWORD GetAvailableVideoMemory();
	virtual void HandleFullScreenEffects(int,int);
};

// ---------------------------------------------------------------------------
// Types used by URenderDevice implementations (D3DDrv, etc.).
// Minimal stubs — full definitions deferred until rendering is implemented.
// ---------------------------------------------------------------------------

// FRenderInterface — abstract render-dispatch interface returned by Lock().
// Base class for device-specific render interfaces (FD3DRenderInterface, etc.).
// The engine holds a pointer to this during Lock/Unlock and issues draw calls.
// Not ENGINE_API: defined inline. D3DDrv defines the vtable via FD3DRenderInterface.
class FRenderInterface
{
public:
	virtual ~FRenderInterface() {}
	virtual void GetDistanceFog(INT& bEnabled, FLOAT& FogStart, FLOAT& FogEnd, FColor& FogColor) {}
};

// FRenderCaps — hardware capability query result from GetRenderCaps().
// Members reconstructed from D3DDrv Ghidra analysis of Init() and
// engine-side consumers (terrain renderer, material compiler).
struct ENGINE_API FRenderCaps
{
	INT HardwareTL;                    // Hardware transform & lighting available
	INT MaxSimultaneousTerrainLayers;  // Max terrain texture layers (capped at 4)
	INT PixelShaderVersion;            // Pixel shader version (0=none, 1=1.x, 2=2.x)
	INT MaxTextureBlendStages;         // Maximum texture stages for blending

	FRenderCaps()
		: HardwareTL(0)
		, MaxSimultaneousTerrainLayers(1)
		, PixelShaderVersion(0)
		, MaxTextureBlendStages(2)
	{}
};

// FResolutionInfo — display-mode descriptor for GetAvailableResolutions().
struct ENGINE_API FResolutionInfo
{
	INT Width;
	INT Height;
	INT BitsPerPixel;
};

// EHardwareEmulationMode — D3D software-emulation level for SetEmulationMode().
enum EHardwareEmulationMode
{
	HEM_None       = 0,
	HEM_Software   = 1,
	HEM_Refrast    = 2
};

// ETextureFormat -- moved above to line ~521

class ENGINE_API UCanvas : public UObject
{
public:
	DECLARE_CLASS(UCanvas,UObject,0,Engine)
	NO_DEFAULT_CONSTRUCTOR(UCanvas)

	// Member variables (from CSDK EngineClasses.h).
	class UFont* Font;
	FLOAT SpaceX;
	FLOAT SpaceY;
	FLOAT OrgX;
	FLOAT OrgY;
	FLOAT ClipX;
	FLOAT ClipY;
	FLOAT HalfClipX;
	FLOAT HalfClipY;
	FLOAT CurX;
	FLOAT CurY;
	FLOAT Z;
	BYTE Style;
	FLOAT CurYL;
	FColor DrawColor;
	BITFIELD bCenter : 1;
	BITFIELD bNoSmooth : 1;
	INT SizeX;
	INT SizeY;
	class UFont* SmallFont;
	class UFont* MedFont;
	class UViewport* Viewport;
	INT m_hBink;
	BITFIELD m_bPlaying : 1;
	INT m_iPosX;
	INT m_iPosY;
	BITFIELD m_bForceMul2x : 1;
	FLOAT m_fStretchX;
	FLOAT m_fStretchY;
	FLOAT m_fVirtualResX;
	FLOAT m_fVirtualResY;
	FLOAT m_fNormalClipX;
	FLOAT m_fNormalClipY;
	BITFIELD m_bDisplayGameOutroVideo : 1;
	BITFIELD m_bChangeResRequested : 1;
	INT m_iNewResolutionX;
	INT m_iNewResolutionY;
	BITFIELD m_bFading : 1;
	BITFIELD m_bFadeAutoStop : 1;
	FColor m_FadeStartColor;
	FColor m_FadeEndColor;
	FLOAT m_fFadeTotalTime;
	FLOAT m_fFadeCurrentTime;
	class UMaterial* m_pWritableMapIconsTexture;

	// Non-virtual methods
	void SetVirtualSize(FLOAT, FLOAT);
	void StartFade(FColor, FColor, FLOAT, INT);
	void UseVirtualSize(INT, FLOAT, FLOAT);
	void SetStretch(FLOAT, FLOAT);
	void DrawTileClipped(UMaterial*, FLOAT, FLOAT, FLOAT, FLOAT, FLOAT, FLOAT);

	// Virtual methods
	virtual void DrawTile(UMaterial*, FLOAT, FLOAT, FLOAT, FLOAT, FLOAT, FLOAT, FLOAT, FLOAT, FLOAT, FPlane, FPlane, FLOAT);
	virtual void DrawIcon(UMaterial*, FLOAT, FLOAT, FLOAT, FLOAT, FLOAT, FPlane, FPlane);
	virtual void DrawPattern(UMaterial*, FLOAT, FLOAT, FLOAT, FLOAT, FLOAT, FLOAT, FLOAT, FLOAT, FPlane, FPlane);
	virtual INT _DrawString(class UFont*, INT, INT, const TCHAR*, FPlane, INT, INT, INT);
	virtual void WrappedDrawString(ERenderStyle, INT&, INT&, class UFont*, INT, const TCHAR*);
	virtual void WrappedStrLenf(class UFont*, INT&, INT&, const TCHAR*, ...);
	virtual void WrappedPrintf(class UFont*, INT, const TCHAR*, ...);
	virtual void SetClip(INT, INT, INT, INT);

	// Virtual interface stubs defined in UnRender.cpp.
	virtual void Init( class UViewport* InViewport );
	virtual void Update();

	// Exec functions.
	DECLARE_FUNCTION(execSetPos)
	DECLARE_FUNCTION(execSetOrigin)
	DECLARE_FUNCTION(execSetClip)
	DECLARE_FUNCTION(execSetDrawColor)
	DECLARE_FUNCTION(execDrawText)
	DECLARE_FUNCTION(execDrawTextClipped)
	DECLARE_FUNCTION(execClipTextNative)
	DECLARE_FUNCTION(execDrawTile)
	DECLARE_FUNCTION(execDrawTileClipped)
	DECLARE_FUNCTION(execDrawStretchedTextureSegmentNative)
	DECLARE_FUNCTION(execDrawActor)
	DECLARE_FUNCTION(execDrawPortal)
	DECLARE_FUNCTION(execDraw3DLine)
	DECLARE_FUNCTION(execStrLen)
	DECLARE_FUNCTION(execTextSize)
	DECLARE_FUNCTION(execGetScreenCoordinate)

DECLARE_FUNCTION(execVideoClose)
DECLARE_FUNCTION(execSetVirtualSize)
DECLARE_FUNCTION(execUseVirtualSize)
DECLARE_FUNCTION(execSetMotionBlurIntensity)
DECLARE_FUNCTION(execDrawWritableMap)
DECLARE_FUNCTION(execVideoOpen)
DECLARE_FUNCTION(execVideoPlay)
    DECLARE_FUNCTION(execVideoStop)

virtual void Serialize(FArchive&);
virtual void Destroy();
virtual INT Exec(const TCHAR*, FOutputDevice&);

// Event thunks
void eventReset();
	// Auto-generated method declarations
private:
	void __cdecl WrappedPrint(ERenderStyle,int &,int &,UFont *,int,const TCHAR*);
public:
};

class ENGINE_API AHUD : public AActor
{
public:
	DECLARE_CLASS(AHUD,AActor,0|CLASS_Config,Engine)
	DECLARE_FUNCTION(execDraw3DLine)
	// Event thunks
	void eventPostFadeRender(class UCanvas*);
	void eventPostRender(class UCanvas*);
	void eventRenderFirstPersonGun(class UCanvas*);
	void eventShowUpgradeMenu();
	void eventWorldSpaceOverlays();
	// Auto-generated method declarations
	virtual void DrawInGameMap(FCameraSceneNode *,UViewport *);
	virtual void DrawRadar(FCameraSceneNode *,UViewport *);
	virtual void DrawSpecificModeInfo(FCameraSceneNode *,UViewport *);
};

/*==========================================================================
	Class declarations — UnNet.cpp classes.
==========================================================================*/

class ENGINE_API UPlayer : public UObject
{
public:
	DECLARE_CLASS(UPlayer,UObject,0,Engine)
	// Auto-generated method declarations
	virtual void Serialize(FArchive &);
	virtual void Destroy();
	virtual int Exec(const TCHAR*,FOutputDevice &);
};

class ENGINE_API UNetDriver : public USubsystem
{
public:
DECLARE_CLASS(UNetDriver,USubsystem,0,Engine)

void StaticConstructor();

virtual void TickFlush();
virtual void TickDispatch(FLOAT);
virtual void Serialize(FArchive&);
virtual void NotifyActorDestroyed(AActor*);
virtual void AssertValid();
virtual void Destroy();
virtual INT InitConnect(FNetworkNotify*, FURL&, FString&);
virtual INT InitListen(FNetworkNotify*, FURL&, FString&);
virtual void LowLevelDestroy();
virtual FString LowLevelGetNetworkNumber();
virtual INT Exec(const TCHAR*, FOutputDevice&);
};

class ENGINE_API UNetConnection : public UPlayer
{
public:
	DECLARE_CLASS(UNetConnection,UPlayer,0,Engine)
	UNetConnection() {}
	UNetConnection( UNetDriver* InDriver, const FURL& InURL );

	// Virtual methods
	virtual INT Exec( const TCHAR* Cmd, FOutputDevice& Ar );
	virtual void Serialize( const TCHAR* Data, EName Event );
	virtual void Destroy();
	virtual void Serialize( FArchive& Ar );
	virtual void ReadInput( FLOAT DeltaSeconds );
	virtual void InitOut();
	virtual void AssertValid();
	virtual void SendAck( INT PacketId, INT RemotePacketId );
	virtual void FlushNet();
	virtual void Tick();
	virtual INT IsNetReady( INT Saturate );
	virtual void HandleClientPlayer( APlayerController* PC );

	// Non-virtual methods
	UChannel* CreateChannel( INT ChType, INT bOpenedLocally, INT ChIndex );
	UNetDriver* GetDriver();
	void PostSend( INT PacketId );
	void PreSend( INT SizeBits );
	void PurgeAcks();
	void ReceiveFile( INT PackageIndex );
	void ReceivedNak( INT NakPacketId );
	void ReceivedPacket( FBitReader& Reader );
	void ReceivedRawPacket( void* Data, INT Count );
	void SendPackageMap();
	INT SendRawBunch( FOutBunch& Bunch, INT InPacketId );
	void SetActorDirty( AActor* Actor );
	void SlowAssertValid();
};

class ENGINE_API UChannel : public UObject
{
public:
DECLARE_CLASS(UChannel,UObject,0,Engine)
UChannel() {}

void StaticConstructor();
INT SendBunch(FOutBunch*, INT);

virtual void Tick();
virtual void ReceivedBunch(FInBunch&);
virtual void Serialize(const TCHAR*, EName);
virtual FString Describe();
virtual void Destroy();
virtual void Init(UNetConnection*, INT, INT);
virtual void SetClosingFlag();
virtual void Close();
virtual void ReceivedNak(INT);

// Non-virtual methods
void AssertInSequenced();
static UClass** ChannelClasses();
static INT CDECL IsKnownChannelType(INT);
INT IsNetReady(INT);
INT MaxSendBytes();
void ReceivedAcks();
void ReceivedRawBunch(FInBunch&);
INT ReceivedSequencedBunch(FInBunch&);
INT RouteDestroy();
};

class ENGINE_API UActorChannel : public UChannel
{
public:
	DECLARE_CLASS(UActorChannel,UChannel,0,Engine)
	// Auto-generated method declarations
	void StaticConstructor();
	virtual void Tick();
	virtual void ReceivedBunch(FInBunch &);
	virtual void ReceivedNak(int);
	void ReplicateActor();
	void SetChannelActor(AActor *);
	virtual void SetClosingFlag();
	virtual void Close();
	virtual FString Describe();
	virtual void Destroy();
	AActor * GetActor();
	virtual void Init(UNetConnection *,int,int);
};

class ENGINE_API UControlChannel : public UChannel
{
public:
	DECLARE_CLASS(UControlChannel,UChannel,0,Engine)
	// Auto-generated method declarations
	void StaticConstructor();
	virtual void ReceivedBunch(FInBunch &);
	virtual void Serialize(const TCHAR*,EName);
	virtual FString Describe();
	virtual void Destroy();
	virtual void Init(UNetConnection *,int,int);
};

class ENGINE_API UFileChannel : public UChannel
{
public:
DECLARE_CLASS(UFileChannel,UChannel,0,Engine)

void StaticConstructor();

virtual void Tick();
virtual void ReceivedBunch(FInBunch&);
virtual FString Describe();
virtual void Destroy();
virtual void Init(UNetConnection*, INT, INT);
};

class ENGINE_API UPackageMapLevel : public UPackageMap
{
public:
	DECLARE_CLASS(UPackageMapLevel,UPackageMap,0,Engine)
};

/*==========================================================================
	Class declarations — UnMaterial.cpp classes.
==========================================================================*/


class ENGINE_API UMaterial : public UObject
{
public:
DECLARE_CLASS(UMaterial,UObject,0,Engine)

UMaterial* ConvertPolyFlagsToMaterial(UMaterial*, DWORD);
static void ClearFallbacks();

virtual BYTE RequiredUVStreams();
virtual INT RequiresSorting();
virtual INT MaterialUSize();
virtual INT MaterialVSize();
virtual void Serialize(FArchive&);
virtual void PostEditChange();
virtual void SetValidated(INT);
virtual INT CheckCircularReferences(TArray<UMaterial*>&);
virtual UMaterial* CheckFallback();
virtual UMaterial* GetDiffuse();
virtual INT GetValidated();
virtual INT HasFallback();
virtual INT IsTransparent();
};

class ENGINE_API URenderedMaterial : public UMaterial
{
public:
	DECLARE_CLASS(URenderedMaterial,UMaterial,0,Engine)
};

class ENGINE_API UBitmapMaterial : public URenderedMaterial
{
public:
	DECLARE_CLASS(UBitmapMaterial,URenderedMaterial,0,Engine)
	// Auto-generated method declarations
	virtual int MaterialUSize();
	virtual int MaterialVSize();
	virtual UBitmapMaterial * Get(double,UViewport *);
};

class ENGINE_API UTexture : public UBitmapMaterial
{
public:
	DECLARE_CLASS(UTexture,UBitmapMaterial,0,Engine)

	static class UClient* __Client;

	void SetLastUpdateTime(double);
	INT Compress(ETextureFormat, INT, struct FDXTCompressionOptions*);
	ETextureFormat ConvertDXT(INT, INT, INT, void**);
	ETextureFormat ConvertDXT();
	void CreateColorRange();
	void CreateMips(INT, INT);
	INT Decompress(ETextureFormat);
	INT DefaultLOD();
	FColor* GetColors();
	DWORD GetColorsIndex();
	FString GetFormatDesc();
	double GetLastUpdateTime();
	struct FMipmapBase* GetMip(INT);
	INT GetNumMips();
	FColor GetTexel(FLOAT, FLOAT, FLOAT, FLOAT);

	// UTexture interface (from UT99 UnTex.h).
	virtual void Clear( DWORD ClearFlags );
	virtual void Clear( FColor );
	virtual void Init( INT InUSize, INT InVSize );
	virtual void Tick( FLOAT DeltaSeconds );
	virtual void ConstantTimeTick();
	virtual void MousePosition( DWORD Buttons, FLOAT X, FLOAT Y ) {}
	virtual void Click( DWORD Buttons, FLOAT X, FLOAT Y ) {}
	virtual void Update( double Time ) {}
	virtual void Prime();
	virtual void Serialize(FArchive&);
	virtual void ArithOp(UTexture*, ETextureArithOp);
	virtual void Destroy();
	virtual UBitmapMaterial* Get(double, UViewport*);
	virtual class FBaseTexture* GetRenderInterface();
	virtual INT IsTransparent();
	virtual INT RequiresSorting();
	virtual void PostLoad();
};

class ENGINE_API UShader : public URenderedMaterial
{
public:
	DECLARE_CLASS(UShader,URenderedMaterial,0,Engine)
	// Auto-generated method declarations
	virtual BYTE RequiredUVStreams();
	virtual int RequiresSorting();
	virtual int MaterialUSize();
	virtual int MaterialVSize();
	virtual void PostEditChange();
	virtual int CheckCircularReferences(TArray<UMaterial *> &);
	virtual UMaterial * CheckFallback();
	virtual UMaterial * GetDiffuse();
	virtual int HasFallback();
	virtual int IsTransparent();
};

class ENGINE_API UModifier : public UMaterial
{
public:
	DECLARE_CLASS(UModifier,UMaterial,0,Engine)
	// Auto-generated method declarations
	virtual BYTE RequiredUVStreams();
	virtual int RequiresSorting();
	virtual int MaterialUSize();
	virtual int MaterialVSize();
	virtual void PostEditChange();
	virtual int CheckCircularReferences(TArray<UMaterial *> &);
	virtual int IsTransparent();
};

class ENGINE_API UCombiner : public UMaterial
{
public:
	DECLARE_CLASS(UCombiner,UMaterial,0,Engine)
	// Auto-generated method declarations
	virtual BYTE RequiredUVStreams();
	virtual int RequiresSorting();
	virtual int MaterialUSize();
	virtual int MaterialVSize();
	virtual void PostEditChange();
	virtual int CheckCircularReferences(TArray<UMaterial *> &);
	virtual int IsTransparent();
};

class ENGINE_API UFinalBlend : public UModifier
{
public:
	DECLARE_CLASS(UFinalBlend,UModifier,0,Engine)
	// Auto-generated method declarations
	virtual int RequiresSorting();
	virtual void SetValidated(int);
	virtual void PostEditChange();
	virtual int GetValidated();
	virtual int IsTransparent();
};

class ENGINE_API UConstantMaterial : public UMaterial
{
public:
	DECLARE_CLASS(UConstantMaterial,UMaterial,0,Engine)
	// Auto-generated method declarations
	virtual FColor GetColor(float);
};

class ENGINE_API UConstantColor : public UConstantMaterial
{
public:
	DECLARE_CLASS(UConstantColor,UConstantMaterial,0,Engine)
	// Auto-generated method declarations
	virtual FColor GetColor(float);
};

class ENGINE_API UPalette : public UObject
{
public:
	DECLARE_CLASS(UPalette,UObject,0,Engine)
	// Auto-generated method declarations
	UPalette * ReplaceWithExisting();
	virtual void Serialize(FArchive &);
	BYTE BestMatch(FColor,int);
	void FixPalette();
};

class ENGINE_API UTexCoordMaterial : public UModifier
{
public:
	DECLARE_CLASS(UTexCoordMaterial,UModifier,0,Engine)
	// Auto-generated method declarations
	virtual int MaterialUSize();
	virtual int MaterialVSize();
};

class ENGINE_API UTexMatrix : public UTexCoordMaterial
{
public:
	DECLARE_CLASS(UTexMatrix,UTexCoordMaterial,0,Engine)
	// Auto-generated method declarations
	virtual FMatrix * GetMatrix(float);
};

class ENGINE_API UTexOscillator : public UTexCoordMaterial
{
public:
DECLARE_CLASS(UTexOscillator,UTexCoordMaterial,0,Engine)
	// Auto-generated method declarations
	virtual FMatrix * GetMatrix(float);
};

class ENGINE_API UTexPanner : public UTexCoordMaterial
{
public:
	DECLARE_CLASS(UTexPanner,UTexCoordMaterial,0,Engine)
	// Auto-generated method declarations
	virtual FMatrix * GetMatrix(float);
};

class ENGINE_API UTexRotator : public UTexCoordMaterial
{
public:
	DECLARE_CLASS(UTexRotator,UTexCoordMaterial,0,Engine)
	// Auto-generated method declarations
	virtual void PostLoad();
	virtual FMatrix * GetMatrix(float);
};

class ENGINE_API UTexScaler : public UTexCoordMaterial
{
public:
	DECLARE_CLASS(UTexScaler,UTexCoordMaterial,0,Engine)
	// Auto-generated method declarations
	virtual FMatrix * GetMatrix(float);
};

class ENGINE_API UTexEnvMap : public UTexCoordMaterial
{
public:
	DECLARE_CLASS(UTexEnvMap,UTexCoordMaterial,0,Engine)
	// Auto-generated method declarations
	virtual FMatrix * GetMatrix(float);
};

class ENGINE_API UColorModifier : public UModifier
{
public:
	DECLARE_CLASS(UColorModifier,UModifier,0,Engine)
	NO_DEFAULT_CONSTRUCTOR(UColorModifier)
};

class ENGINE_API UOpacityModifier : public UModifier
{
public:
	DECLARE_CLASS(UOpacityModifier,UModifier,0,Engine)
	NO_DEFAULT_CONSTRUCTOR(UOpacityModifier)
};

class ENGINE_API UVertexColor : public UModifier
{
public:
	DECLARE_CLASS(UVertexColor,UModifier,0,Engine)
	NO_DEFAULT_CONSTRUCTOR(UVertexColor)
};

class ENGINE_API UProceduralTexture : public URenderResource
{
public:
	DECLARE_CLASS(UProceduralTexture,URenderResource,0,Engine)
};

class ENGINE_API UScriptedTexture : public UTexture
{
public:
	DECLARE_CLASS(UScriptedTexture,UTexture,0,Engine)
};

class ENGINE_API UCubemap : public UTexture
{
public:
	DECLARE_CLASS(UCubemap,UTexture,0,Engine)
	// Auto-generated method declarations
	virtual void Destroy();
	virtual FBaseTexture * GetRenderInterface();
};

class ENGINE_API UPlayerLight : public UTexture
{
public:
	DECLARE_CLASS(UPlayerLight,UTexture,0,Engine)
};

/*==========================================================================
	Class declarations — UnAudio.cpp classes.
==========================================================================*/

class ENGINE_API UAudioSubsystem : public USubsystem
{
public:
	DECLARE_CLASS(UAudioSubsystem,USubsystem,CLASS_Config,Engine)
	NO_DEFAULT_CONSTRUCTOR(UAudioSubsystem)
	UBOOL Exec( const TCHAR* Cmd, FOutputDevice& Ar ) { return 0; }
};

class ENGINE_API USound : public UObject
{
public:
	DECLARE_CLASS(USound,UObject,0,Engine)
    USound() {}

	USound(const TCHAR*, INT);
	static class UAudioSubsystem* Audio;

	virtual void PostLoad();
	virtual void PS2Convert();
	virtual void Serialize(FArchive&);
	virtual void Destroy();
	virtual FLOAT GetDuration();
};

class ENGINE_API UMusic : public UObject
{
public:
	DECLARE_CLASS(UMusic,UObject,0,Engine)
};

/*==========================================================================
	Class declarations — UnMesh.cpp classes.
==========================================================================*/

class ENGINE_API UMesh : public UPrimitive
{
public:
	DECLARE_CLASS(UMesh,UPrimitive,0,Engine)
	// Auto-generated method declarations
	virtual void Serialize(FArchive &);
	virtual UMeshInstance * MeshGetInstance(AActor const *);
	virtual UClass * MeshGetInstanceClass();
};

class ENGINE_API ULodMesh : public UMesh
{
public:
	DECLARE_CLASS(ULodMesh,UMesh,0,Engine)
	// Auto-generated method declarations
	virtual void Serialize(FArchive &);
	virtual int MemFootprint(int);
	virtual UClass * MeshGetInstanceClass();
};

class ENGINE_API USkeletalMesh : public UMesh
{
public:
	DECLARE_CLASS(USkeletalMesh,UMesh,0,Engine)

	void m_bLoadLbpFile(FString);
	INT SetAttachAlias(FName, FName, FCoords&);
	INT SetAttachmentLocation(AActor*, AActor*);
	INT LODFootprint(INT, INT);
	void NormalizeInfluences(INT);
	void CalculateNormals(TArray<FVector>&, INT);
	void ClearAttachAliases();
	void FlipFaces();
	void GenerateLodModel(INT, FLOAT, FLOAT, INT, INT);
	void InsertLodModel(INT, USkeletalMesh*, FLOAT, INT);
	void ReconstructRawMesh();
	INT RenderPreProcess();

	virtual UClass* MeshGetInstanceClass();
	virtual void PostLoad();
	virtual INT UseCylinderCollision(const AActor*);
	virtual INT R6LineCheck(FCheckResult&, AActor*, FVector, FVector, FVector, DWORD, DWORD);
	virtual void Serialize(FArchive&);
	virtual INT LineCheck(FCheckResult&, AActor*, FVector, FVector, FVector, DWORD, DWORD);
	virtual INT MemFootprint(INT);
	virtual void Destroy();
	virtual FBox GetCollisionBoundingBox(const AActor*) const;
	virtual FBox GetRenderBoundingBox(const AActor*);
	virtual FSphere GetRenderBoundingSphere(const AActor*);
};

class ENGINE_API ULodMeshInstance : public UMeshInstance
{
public:
	DECLARE_CLASS(ULodMeshInstance,UMeshInstance,0,Engine)

	struct FMeshAnimSeq* GetAnimSeq(FName);
	virtual void Serialize(FArchive&);
	virtual void SetActor(AActor*);
	virtual void SetMesh(class UMesh*);
	virtual void SetStatus(INT);
	virtual AActor* GetActor();
	virtual void GetFrame(AActor*, FLevelSceneNode*, FVector*, INT, INT&, DWORD);
	virtual UMaterial* GetMaterial(INT, AActor*);
	virtual class UMesh* GetMesh();
	virtual void GetMeshVerts(AActor*, FVector*, INT, INT&);
	virtual INT GetStatus();
};

class ENGINE_API USkeletalMeshInstance : public ULodMeshInstance
{
public:
	DECLARE_CLASS(USkeletalMeshInstance,ULodMeshInstance,0,Engine)

	static FLOAT* m_fCylindersRadius;

	// Public non-virtual methods
	INT TraceHeadHit(FCheckResult&, const FVector&, const FVector&, const FVector&, const FLOAT&);
	void UpdateBlendAlpha(INT, FLOAT, FLOAT);
	INT ValidateAnimChannel(INT);
	void SetAnimRate(INT, FLOAT);
	void SetAnimSequence(INT, FName);
	void SetBlendAlpha(INT, FLOAT);
	INT SetBlendParams(INT, FLOAT, FLOAT, FLOAT, FName, INT);
	INT SetBoneDirection(FName, FRotator, FVector, FLOAT);
	INT SetBoneLocation(FName, FVector, FLOAT);
	INT SetBonePosition(FName, FRotator, FVector, FLOAT);
	INT SetBoneRotation(FName, FRotator, INT, FLOAT, FLOAT);
	INT SetBoneScale(INT, FLOAT, FName);
	INT SetSkelAnim(class UMeshAnimation*, USkeletalMesh*);
	INT LockRootMotion(INT, INT);
	INT MatchRefBone(FName);
	void BlendToAlpha(INT, FLOAT, FLOAT);
	void BuildPivotsList();
	void ClearSkelAnims();
	void CopyAnimation(INT, INT);
	void DrawCollisionCylinders(FSceneNode*);
	INT EnableChannelNotify(INT, INT);
	void ForceAnimRate(INT, FLOAT);
	INT GetAnimChannelCount();
	FLOAT GetAnimFrame(INT);
	FLOAT GetAnimRateOnChannel(INT);
	FName GetAnimSequence(INT);
	FLOAT GetBlendAlpha(INT);
	FCoords GetBoneCoords(DWORD, INT);
	INT GetBoneCylinder(INT, FCylinder&);
	FName GetBoneName(FName);
	FRotator GetBoneRotation(DWORD, INT);
	FRotator GetBoneRotation(FName, INT);
	FVector GetRootLocation();
	FVector GetRootLocationDelta();
	FRotator GetRootRotation();
	FRotator GetRootRotationDelta();
	FCoords GetTagCoords(FName);
	FCoords GetTagPosition(FName);
	INT WasSkeletonUpdated();

	// Virtual overrides
	virtual INT ActiveVertStreamSize();
	virtual void ActualizeAnimLinkups();
	virtual INT AnimForcePose(FName, FLOAT, FLOAT, INT);
	virtual FLOAT AnimGetFrameCount(void*);
	virtual FName AnimGetGroup(void*);
	virtual FName AnimGetName(void*);
	virtual INT AnimGetNotifyCount(void*);
	virtual UAnimNotify* AnimGetNotifyObject(void*, INT);
	virtual const TCHAR* AnimGetNotifyText(void*, INT);
	virtual FLOAT AnimGetNotifyTime(void*, INT);
	virtual FLOAT AnimGetRate(void*);
	virtual INT AnimIsInGroup(void*, FName);
	virtual INT AnimStopLooping(INT);
	virtual void ClearChannel(INT);
	virtual class UMeshAnimation* CurrentSkelAnim(INT);
	virtual void Destroy();
	virtual class UMeshAnimation* FindAnimObjectForSequence(FName);
	virtual INT FreezeAnimAt(FLOAT, INT);
	virtual FLOAT GetActiveAnimFrame(INT);
	virtual FLOAT GetActiveAnimRate(INT);
	virtual FName GetActiveAnimSequence(INT);
	virtual INT GetAnimCount();
	virtual void* GetAnimIndexed(INT);
	virtual void* GetAnimNamed(FName);
	virtual void GetFrame(AActor*, FLevelSceneNode*, FVector*, INT, INT&, DWORD);
	virtual UMaterial* GetMaterial(INT, AActor*);
	virtual void GetMeshVerts(AActor*, FVector*, INT, INT&);
	virtual FBox GetRenderBoundingBox(const AActor*);
	virtual FSphere GetRenderBoundingSphere(const AActor*);
	virtual INT IsAnimating(INT);
	virtual INT IsAnimLooping(INT);
	virtual INT IsAnimPastLastFrame(INT);
	virtual INT IsAnimTweening(INT);
	virtual INT LineCheck(FCheckResult&, AActor*, FVector, FVector, FVector, DWORD, DWORD);
	virtual void MeshBuildBounds();
	virtual void MeshSkinVertsCallback(void*);
	virtual FMatrix MeshToWorld();
	virtual INT PlayAnim(INT, FName, FLOAT, FLOAT, INT, INT, INT);
	virtual void Render(class FDynamicActor*, FLevelSceneNode*, class TList<class FDynamicLight*>*, FRenderInterface*);
	virtual void Serialize(FArchive&);
	virtual void SetAnimFrame(INT, FLOAT);
	virtual void SetMesh(class UMesh*);
	virtual void SetScale(FVector);
	virtual INT StopAnimating(INT);
	virtual INT UpdateAnimation(FLOAT);
};

class ENGINE_API UStaticMesh : public UPrimitive
{
public:
	DECLARE_CLASS(UStaticMesh,UPrimitive,0,Engine)

	void StaticConstructor();
	void TriangleSphereQuery(AActor*, FSphere&, TArray<struct FStaticMeshCollisionTriangle*>&);
	void Build();
	UMaterial* GetSkin(AActor*, INT);
	class FTags* GetTag(FString);

	virtual void PostEditChange();
	virtual void PostLoad();
	virtual void Serialize(FArchive&);
	virtual INT LineCheck(FCheckResult&, AActor*, FVector, FVector, FVector, DWORD, DWORD);
	virtual INT PointCheck(FCheckResult&, AActor*, FVector, FVector, DWORD);
	virtual void Destroy();
	virtual FBox GetCollisionBoundingBox(const AActor*) const;
	virtual FVector GetEncroachCenter(AActor*);
	virtual FVector GetEncroachExtent(AActor*);
	virtual FBox GetRenderBoundingBox(const AActor*);
	virtual FSphere GetRenderBoundingSphere(const AActor*);
	virtual void Illuminate(AActor*, INT);
};

class ENGINE_API UStaticMeshInstance : public UObject
{
public:
	DECLARE_CLASS(UStaticMeshInstance,UObject,0,Engine)
	// Auto-generated method declarations
	virtual void Serialize(FArchive &);
	virtual void AttachProjectorClipped(AActor *,AProjector *);
	virtual void DetachProjectorClipped(AProjector *);
};

/*==========================================================================
	Class declarations — UnModel.cpp classes.
==========================================================================*/

class ENGINE_API UModel : public UPrimitive
{
public:
	DECLARE_CLASS(UModel,UPrimitive,0,Engine)
	UModel() {}
	UModel( ABrush* Owner, INT InRootOutside );

	// Virtual methods (UObject/UPrimitive overrides)
	virtual void PostLoad();
	virtual void Destroy();
	virtual void Serialize( FArchive& Ar );
	virtual INT PointCheck( FCheckResult& Result, AActor* Owner, FVector Location, FVector Extent, DWORD ExtraNodeFlags );
	virtual INT LineCheck( FCheckResult& Result, AActor* Owner, FVector End, FVector Start, FVector Extent, DWORD TraceFlags, DWORD ExtraNodeFlags );
	virtual FBox GetRenderBoundingBox( const AActor* Owner );
	virtual FBox GetCollisionBoundingBox( const AActor* Owner ) const;
	virtual void Illuminate( AActor* Owner, INT bExtra );
	virtual FVector GetEncroachExtent( AActor* Owner );
	virtual FVector GetEncroachCenter( AActor* Owner );
	virtual INT UseCylinderCollision( const AActor* Owner );

	// Non-virtual methods
	TArray<INT> BoxLeaves( FBox Box );
	void BuildBound();
	void BuildRenderData();
	void ClearRenderData( URenderDevice* RenDev );
	void CompressLightmaps();
	INT ConvexVolumeMultiCheck( FBox& Box, FPlane* Planes, INT NumPlanes, FVector Extent, TArray<INT>& Result, FLOAT VisRadius );
	void EmptyModel( INT EmptySurfs, INT EmptyPolys );
	BYTE FastLineCheck( FVector Start, FVector End );
	FLOAT FindNearestVertex( const FVector& SourcePoint, FVector& DestPoint, FLOAT MinRadius, INT& iVertex ) const;
	void Modify( INT DoTransArrays );
	void ModifyAllSurfs( INT SetBits );
	void ModifySelectedSurfs( INT SetBits );
	void ModifySurf( INT iSurf, INT SetBits );
	FPointRegion PointRegion( AZoneInfo* Zone, FVector Location ) const;
	INT PotentiallyVisible( INT iLeaf0, INT iLeaf1 );
	void PrecomputeSphereFilter( const FPlane& Sphere );
	INT R6LineCheck( FCheckResult& Result, INT iNode, FVector Start, FVector End );
	void ShrinkModel();
	void Transform( ABrush* Brush );
	// Auto-generated method declarations
	void Render(FDynamicActor *,FLevelSceneNode *,FRenderInterface *);
	void AttachProjector(int,FProjectorRenderInfo *,FPlane *);
};

class ENGINE_API UPolys : public UObject
{
public:
	DECLARE_CLASS(UPolys,UObject,0,Engine)
	// Auto-generated method declarations
	virtual void Serialize(FArchive &);
};

/*==========================================================================
	Class declarations — UnEffects.cpp classes.
==========================================================================*/

class ENGINE_API AEmitter : public AActor
{
public:
	DECLARE_CLASS(AEmitter,AActor,0,Engine)
	DECLARE_FUNCTION(execKill)
	// Auto-generated method declarations
	virtual void Spawned();
	virtual int Tick(float,ELevelTick);
	void Render(FDynamicActor *,FLevelSceneNode *,TList<FDynamicLight *> *,FRenderInterface *);
	virtual void RenderEditorInfo(FLevelSceneNode *,FRenderInterface *,FDynamicActor *);
	virtual void Kill();
	virtual void PostScriptDestroyed();
	virtual int CheckForProjectors();
	virtual void Initialize();
};

class ENGINE_API UParticleEmitter : public UObject
{
public:
	DECLARE_CLASS(UParticleEmitter,UObject,0,Engine)
	DECLARE_FUNCTION(execSpawnParticle)
	// Auto-generated method declarations
	virtual void SpawnIndividualParticles(int);
	virtual void SpawnParticle(int,float,int,int,FVector const &);
	virtual float SpawnParticles(float,float,float);
	virtual int UpdateParticles(float);
	virtual int RenderParticles(FDynamicActor *,FLevelSceneNode *,TList<FDynamicLight *> *,FRenderInterface *);
	virtual void Reset();
	virtual void Scale(float);
	virtual void PostEditChange();
	virtual void PostLoad();
	virtual void CleanUp();
	virtual void Destroy();
	virtual void HandleActorForce(AActor *,float);
	virtual void Initialize(int);
};

/*==========================================================================
	RVS-specific classes used only as pointer types in globals.
==========================================================================*/

class ENGINE_API UR6AbstractGameManager : public UObject
{
public:
	DECLARE_CLASS(UR6AbstractGameManager,UObject,0,Engine)
	DECLARE_FUNCTION(execClientLeaveServer)
	DECLARE_FUNCTION(execConnectionInterrupted)
	DECLARE_FUNCTION(execIsGSCreateUbiServer)
	DECLARE_FUNCTION(execLaunchListenSrv)
	DECLARE_FUNCTION(execSetGSCreateUbiServer)
	DECLARE_FUNCTION(execStartJoinServer)
	DECLARE_FUNCTION(execStartLogInProcedure)
	DECLARE_FUNCTION(execStartPreJoinProcedure)
	DECLARE_FUNCTION(execStopGSClientProcedure)
	// Event thunks
	void eventGMProcessMsg(const FString&);
	// Auto-generated method declarations
	virtual void StartJoinServer(FString,FString,int);
	virtual int StartLogInProcedure();
	virtual void StartPreJoinProcedure(int);
	virtual void UnInitialize();
	virtual void SetGSCreateUbiServer(int);
	virtual void LaunchListenSrv(FString,FString);
	virtual void ClientLeaveServer();
	virtual void ConnectionInterrupted(int);
	virtual void GameServiceTick(UConsole *);
	virtual int GetGSCreateUbiServer();
	virtual void InitializeGameService(UConsole *);
};

class ENGINE_API UR6MissionDescription : public UObject
{
public:
	DECLARE_CLASS(UR6MissionDescription,UObject,0,Engine)
	// Event thunks
	DWORD eventGetSkins(class ALevelInfo*&, const FString&);
	DWORD eventInit(class ALevelInfo*, const FString&);
	void eventReset();
};

class ENGINE_API UR6ModMgr : public UObject
{
public:
	DECLARE_CLASS(UR6ModMgr,UObject,0,Engine)
	DECLARE_FUNCTION(execAddNewModExtraPath)
	DECLARE_FUNCTION(execCallSndEngineInit)
	DECLARE_FUNCTION(execGetASBuildVersion)
	DECLARE_FUNCTION(execGetIWBuildVersion)
	DECLARE_FUNCTION(execIsOfficialMod)
	DECLARE_FUNCTION(execSetGeneralModSettings)
	DECLARE_FUNCTION(execSetSystemMod)
	// Event thunks
	FString eventGetBackgroundsRoot();
	FString eventGetCampaignDir();
	FString eventGetDefaultCampaignDir();
	INT eventGetGameTypeIndex(const FString&);
	FString eventGetGameTypeName(INT);
	FString eventGetIniFilesDir();
	FString eventGetMapsDir();
	FString eventGetModKeyword();
	FString eventGetModName();
	INT eventGetNbMods();
	FString eventGetServerIni();
	FString eventGetVideosRoot();
	void eventInitModMgr();
	DWORD eventIsMissionPack();
	DWORD eventIsRavenShield();
	void eventSetCurrentMod(const FString&, class ALevelInfo*, DWORD, class UConsole*, class ULevel*);
};

class ENGINE_API UR6ServerInfo : public UObject
{
public:
	DECLARE_CLASS(UR6ServerInfo,UObject,0,Engine)
	// Event thunks
	void eventRestartServer();
};

class ENGINE_API UR6GameOptions : public UObject
{
public:
	DECLARE_CLASS(UR6GameOptions,UObject,0,Engine)
};

class ENGINE_API UGlobalTempObjects : public UObject
{
public:
	DECLARE_CLASS(UGlobalTempObjects,UObject,0,Engine)
};

class ENGINE_API AR6eviLTesting : public AActor
{
public:
	DECLARE_CLASS(AR6eviLTesting,AActor,0,Engine)
	DECLARE_FUNCTION(execNativeRunAllTests)
	// Event thunks
	void eventRunAll();
	// Auto-generated method declarations
	void eviLTestATS();
	void evilTestUpdateSystem();
};

/*==========================================================================
	Additional class declarations required by Engine.def exports.
	These are classes that appear in the retail Engine.dll export table
	but do not have IMPLEMENT_CLASS in the original stub .cpp files.
==========================================================================*/

// --- Parent/intermediate classes (must come before children) ---

class ENGINE_API UClient;  // Forward declaration — full definition below.

class ENGINE_API UEngine : public USubsystem
{
public:
	DECLARE_CLASS(UEngine,USubsystem,CLASS_Config|CLASS_Transient,Engine)

	// --- Member data (offsets from Ghidra analysis of retail Engine.dll) ---
	// UObject base:   0x00-0x2F
	// USubsystem add: 0x30-0x43
	// UEngine add:    0x44+

	// Padding to align Client at offset 0x44.
	// UObject is ~0x30 bytes, USubsystem adds ~0x14 bytes of data.
	// The exact intermediate layout depends on the full USubsystem layout,
	// but for vtable dispatch (virtual calls) only the virtual method
	// declaration order matters — not member layout.

	UClient*        Client;         // 0x44: Active client (viewport manager)

	// --- Virtual method table ---
	// The following virtual methods MUST appear in exactly this order to match
	// the retail Engine.dll vtable layout. VTable slot numbers are from the
	// complete inheritance chain (UObject=0-24, USubsystem::Tick=25).
	//
	// Slot 25: Tick(FLOAT) — inherited from USubsystem, overridden by UGameEngine.
	// (Tick is already virtual in USubsystem; UEngine re-declares it for override.)

	// Slot 26: PaintProgress — displays loading progress.
	virtual void PaintProgress() {}

	// Slot 27: CacheArmPatch — R6-specific: cache arm patch data for operators.
	virtual void CacheArmPatch( void* /*FGuid**/ Guid, DWORD* Param ) {}

	// Slot 28: Init — engine initialisation (create client, audio, renderer).
	virtual void Init() {}

	// Slot 29: Exit — engine shutdown.
	virtual void Exit() {}

	// Slot 30: Flush — flush rendering/audio caches.
	virtual void Flush( INT Param ) {}

	// Slot 31: UpdateGamma — apply gamma correction.
	virtual void UpdateGamma() {}

	// Slot 32: RestoreGamma — restore original gamma ramp.
	virtual void RestoreGamma() {}

	// Slot 33: Key — keyboard input event.
	virtual INT Key( UViewport* Viewport, INT Key ) { return 0; }

	// Slot 34: InputEvent — generic input event.
	virtual INT InputEvent( UViewport* Viewport, INT Key, INT Action, FLOAT Delta ) { return 0; }

	// Slot 35: Draw — render a viewport (pure virtual in retail).
	virtual void Draw( UViewport* Viewport, INT
		, BYTE* HitData, INT* HitSize ) {}

	// Slot 36: MouseDelta — relative mouse movement.
	virtual void MouseDelta( UViewport* Viewport, DWORD Buttons, FLOAT DX, FLOAT DY ) {}

	// Slot 37: MousePosition — absolute mouse position.
	virtual void MousePosition( UViewport* Viewport, DWORD Buttons, FLOAT X, FLOAT Y ) {}

	// Slot 38: MouseWheel — mouse wheel scroll (R6 addition).
	virtual void MouseWheel( UViewport* Viewport, DWORD Buttons, INT Delta ) {}

	// Slot 39: Click — mouse button down.
	virtual void Click( UViewport* Viewport, DWORD Buttons, FLOAT X, FLOAT Y ) {}

	// Slot 40: UnClick — mouse button up (R6 addition).
	virtual void UnClick( UViewport* Viewport, DWORD Buttons, INT X, INT Y ) {}

	// Slot 41: SetClientTravel — initiate level transition.
	virtual void SetClientTravel( UPlayer* Player, const TCHAR* URL, INT Flags, INT TravelType ) {}

	// Slot 42: ChallengeResponse — network challenge token.
	virtual INT ChallengeResponse( INT Challenge ) { return 0; }

	// Slot 43: GetMaxTickRate — maximum frames per second.
	virtual FLOAT GetMaxTickRate() { return 0.f; }

	// Slot 44: SetProgress — update loading/progress display.
	virtual void SetProgress( const TCHAR* Str1, const TCHAR* Str2, FLOAT Progress ) {}

	// Editor virtuals (slots 45-50) — unused at runtime.
	virtual void edDrawAxisIndicator( void* /*FSceneNode**/ SceneNode ) {}
	virtual void edSetClickLocation( FVector& Location ) {}
	virtual INT  edcamMode( UViewport* Viewport ) { return 0; }
	virtual INT  edcamTerrainBrush() { return 0; }
	virtual INT  edcamMouseControl( UViewport* Viewport ) { return 0; }
	virtual INT  EdCallback( DWORD Code, INT Param, DWORD Flags ) { return 0; }

	// Slot 51-53: R6-specific menu/texture background loading.
	virtual void LoadRandomMenuBackgroundImage( const TCHAR* Path ) {}
	virtual void LoadBackgroundImage( const TCHAR* Path, UTexture* Tex1, UTexture* Tex2 ) {}
	virtual void ReplaceTexture( const TCHAR* Path, UTexture* Tex ) {}

	// FExec interface.
	UBOOL Exec( const TCHAR* Cmd, FOutputDevice& Ar ) { return 0; }
	// Auto-generated method declarations
	void StaticConstructor();
	virtual int ReplaceTexture(FString,UTexture *);
	virtual void Serialize(FArchive &);
	virtual int Key(UViewport *,EInputKey);
	virtual int LoadBackgroundImage(FString,UTexture *,UTexture *);
	virtual void LoadRandomMenuBackgroundImage(FString);
	virtual int CacheArmPatch(FGuid *,DWORD *);
	virtual void Destroy();
	int ExecServerProf(const TCHAR*,int,FOutputDevice &);
	void InitAudio();
	virtual int InputEvent(UViewport *,EInputKey,EInputAction,float);
};

class ENGINE_API UClient : public UObject
{
public:
	DECLARE_CLASS(UClient,UObject,CLASS_Config,Engine)
	// Auto-generated method declarations
	void StaticConstructor();
	virtual void UpdateGamma();
	virtual void UpdateGraphicOptions();
	virtual void RestoreGamma();
	virtual void Serialize(FArchive &);
	virtual void PostEditChange();
	virtual void Destroy();
	virtual int Exec(const TCHAR*,FOutputDevice &);
	virtual void Flush(int);
	virtual void Init(UEngine *);
};

class ENGINE_API UInteractions : public UObject
{
public:
	DECLARE_CLASS(UInteractions,UObject,0,Engine)
protected:
	UInteractions() {}
};

class ENGINE_API UDownload : public UObject
{
public:
	DECLARE_CLASS(UDownload,UObject,CLASS_Transient,Engine)
	NO_DEFAULT_CONSTRUCTOR(UDownload)
	// Auto-generated method declarations
	void StaticConstructor();
	virtual void Tick();
	virtual int TrySkipFile();
	virtual void ReceiveData(BYTE*,int);
	virtual void ReceiveFile(UNetConnection *,int,const TCHAR*,int);
	virtual void Serialize(FArchive &);
	virtual void Destroy();
	virtual void DownloadDone();
	virtual void DownloadError(const TCHAR*);
};

class ENGINE_API UMatObject : public UObject
{
public:
	DECLARE_CLASS(UMatObject,UObject,0,Engine)
	NO_DEFAULT_CONSTRUCTOR(UMatObject)
};

class ENGINE_API UPendingLevel : public UObject
{
public:
	DECLARE_CLASS(UPendingLevel,UObject,0,Engine)
};

class ENGINE_API UCameraEffect : public UObject
{
public:
	DECLARE_CLASS(UCameraEffect,UObject,0,Engine)
	// Auto-generated method declarations
	virtual void PostRender(UViewport *,FRenderInterface *);
	virtual void PreRender(UViewport *,FRenderInterface *);
};

class ENGINE_API UKarmaParamsCollision : public UObject
{
public:
	DECLARE_CLASS(UKarmaParamsCollision,UObject,0,Engine)
	NO_DEFAULT_CONSTRUCTOR(UKarmaParamsCollision)
};

class ENGINE_API UVertexStreamBase : public URenderResource
{
public:
	DECLARE_CLASS(UVertexStreamBase,URenderResource,0,Engine)
	NO_DEFAULT_CONSTRUCTOR(UVertexStreamBase)
	UVertexStreamBase(INT InType, DWORD InStride, DWORD InFlags);
	virtual void Serialize(FArchive& Ar);
	virtual void* GetData() { return NULL; }
	virtual INT GetDataSize() { return 0; }
	void SetPolyFlags(DWORD Flags);
};

class ENGINE_API UTexModifier : public UModifier
{
public:
	DECLARE_CLASS(UTexModifier,UModifier,0,Engine)
	// Auto-generated method declarations
	virtual void SetValidated(int);
	virtual BYTE RequiredUVStreams();
	virtual int MaterialUSize();
	virtual int MaterialVSize();
	virtual FMatrix * GetMatrix(float);
	virtual int GetValidated();
};

class ENGINE_API UAnimNotify : public UObject
{
public:
	DECLARE_CLASS(UAnimNotify,UObject,0,Engine)
	// Auto-generated method declarations
	virtual void Notify(UMeshInstance *,AActor *);
	virtual void PostEditChange();
};

class ENGINE_API UMatAction : public UMatObject
{
public:
	DECLARE_CLASS(UMatAction,UMatObject,0,Engine)
	// Event thunks
	void eventActionStart(class AActor*);
	void eventInitialize();
	// Auto-generated method declarations
	virtual void PostEditChange();
	virtual void PostLoad();
	virtual void Initialize();
};

class ENGINE_API UMatSubAction : public UMatObject
{
public:
	DECLARE_CLASS(UMatSubAction,UMatObject,0,Engine)
	// Event thunks
	void eventInitialize();
	// Auto-generated method declarations
	virtual int Update(float,ASceneManager *);
	virtual void PostEditChange();
	virtual void PreBeginPreview();
	virtual FString GetStatString();
	FString GetStatusDesc();
	virtual void Initialize();
	virtual int IsEnding();
	virtual int IsRunning();
};

class ENGINE_API AStatLog : public AInfo
{
public:
	DECLARE_CLASS(AStatLog,AInfo,0,Engine)
	NO_DEFAULT_CONSTRUCTOR(AStatLog)
	DECLARE_FUNCTION(execBatchLocal)
	DECLARE_FUNCTION(execBrowseRelativeLocalURL)
	DECLARE_FUNCTION(execExecuteLocalLogBatcher)
	DECLARE_FUNCTION(execExecuteSilentLogBatcher)
	DECLARE_FUNCTION(execExecuteWorldLogBatcher)
	DECLARE_FUNCTION(execGetGMTRef)
	DECLARE_FUNCTION(execGetMapFileName)
	DECLARE_FUNCTION(execGetPlayerChecksum)
	DECLARE_FUNCTION(execInitialCheck)
	// Event thunks
	FString eventGetLocalLogFileName();
	void eventLogGameSpecial(const FString&, const FString&);
	void eventLogGameSpecial2(const FString&, const FString&, const FString&);
};

class ENGINE_API AKConstraint : public AKActor
{
public:
	DECLARE_CLASS(AKConstraint,AKActor,0,Engine)
	DECLARE_FUNCTION(execKGetConstraintForce)
	DECLARE_FUNCTION(execKGetConstraintTorque)
	DECLARE_FUNCTION(execKUpdateConstraintParams)
	// Event thunks
	void eventKForceExceed(FLOAT);
	// Auto-generated method declarations
	virtual MdtBaseConstraint * getKConstraint() const;
	virtual _McdModel * getKModel() const;
	virtual void physKarma(float);
	virtual void postKarmaStep();
	virtual void preKarmaStep(float);
	virtual void RenderEditorSelected(FLevelSceneNode *,FRenderInterface *,FDynamicActor *);
	virtual void KUpdateConstraintParams();
	virtual void PostEditChange();
	virtual void PostEditMove();
	virtual void CheckForErrors();
	virtual int CheckOwnerUpdated();
};

class ENGINE_API ASceneManager : public AInfo
{
public:
	DECLARE_CLASS(ASceneManager,AInfo,0,Engine)
	ASceneManager() {}
	DECLARE_FUNCTION(execGetTotalSceneTime)
	DECLARE_FUNCTION(execSceneDestroyed)
	DECLARE_FUNCTION(execTerminateAIAction)

	// Virtual methods
	virtual void PostEditChange();
	virtual INT Tick( FLOAT DeltaTime, ELevelTick TickType );
	virtual void PostBeginPlay();
	virtual void CheckForErrors();

	// Non-virtual methods
	FLOAT GetTotalSceneTime();
	void SetCurrentTime( FLOAT NewTime );
	void SetSceneStartTime();

	// Event thunks
	void eventSceneEnded();
	void eventSceneStarted();
	// Auto-generated method declarations
	void UpdateViewerFromPct(float);
	int VerifyIntPoints();
	void RefreshSubActions(float);
	void SceneEnded();
	void SceneStarted();
	void PreparePath();
	void ChangeOrientation(FOrientation);
	void DeletePathSamples();
	UMatAction * GetActionFromPct(float);
	float GetActionPctFromScenePct(float);
	FVector GetLocation(TArray<FVector> *,float);
	FRotator GetRotation(TArray<FVector> *,float,FVector,FRotator,UMatAction *,int);
	void InitializeActions();
};

class ENGINE_API AMapList : public AInfo
{
public:
	DECLARE_CLASS(AMapList,AInfo,0,Engine)
	NO_DEFAULT_CONSTRUCTOR(AMapList)
};

class ENGINE_API AWarpZoneInfo : public AZoneInfo
{
public:
	DECLARE_CLASS(AWarpZoneInfo,AZoneInfo,0,Engine)
	DECLARE_FUNCTION(execUnWarp)
	DECLARE_FUNCTION(execWarp)
	// Event thunks
	void eventForceGenerate();
	void eventGenerate();
	// Auto-generated method declarations
	virtual void AddMyMarker(AActor *);
};

class ENGINE_API AInternetInfo : public AInfo
{
public:
	DECLARE_CLASS(AInternetInfo,AInfo,0,Engine)
	NO_DEFAULT_CONSTRUCTOR(AInternetInfo)
};

class ENGINE_API AFluidSurfaceInfo : public AInfo
{
public:
	DECLARE_CLASS(AFluidSurfaceInfo,AInfo,0,Engine)
	NO_DEFAULT_CONSTRUCTOR(AFluidSurfaceInfo)
	DECLARE_FUNCTION(execPling)

	// Virtual methods
	virtual void PostLoad();
	virtual void Destroy();
	virtual void PostEditChange();
	virtual INT Tick( FLOAT DeltaTime, ELevelTick TickType );
	virtual void PostEditMove();
	virtual void Spawned();
	virtual UPrimitive* GetPrimitive();

	// Non-virtual methods
	void Init();
	void Pling( const FVector& Location, FLOAT Strength, FLOAT Radius );
	void PlingVertex( INT X, INT Y, FLOAT Strength );
	void UpdateSimulation( FLOAT DeltaTime );
	// Auto-generated method declarations
	void UpdateOscillatorList();
	void RebuildClampedBitmap();
	void Render(FDynamicActor *,FLevelSceneNode *,TList<FDynamicLight *> *,FRenderInterface *);
	virtual void RenderEditorInfo(FLevelSceneNode *,FRenderInterface *,FDynamicActor *);
	void SetClampedBitmap(int,int,int);
	void FillIndexBuffer(void *);
	void FillVertexBuffer(void *);
	int GetClampedBitmap(int,int);
	void GetNearestIndex(FVector const &,int &,int &);
	FVector GetVertexPos(int,int);
};

class ENGINE_API ASkyZoneInfo : public AZoneInfo
{
public:
	DECLARE_CLASS(ASkyZoneInfo,AZoneInfo,0,Engine)
	NO_DEFAULT_CONSTRUCTOR(ASkyZoneInfo)
};

// --- Children of existing classes ---

class ENGINE_API UGameEngine : public UEngine
{
public:
	DECLARE_CLASS(UGameEngine,UEngine,CLASS_Config|CLASS_Transient,Engine)
	UGameEngine() {}

	// Virtual methods
	virtual INT Exec( const TCHAR* Cmd, FOutputDevice& Ar );
	virtual void Destroy();
	virtual void Serialize( FArchive& Ar );
	virtual void Tick( FLOAT DeltaSeconds );
	virtual void UpdateConnectingMessage();
	virtual void Init();
	virtual void Exit();
	virtual void Draw( UViewport* Viewport, INT bFlush, BYTE* HitData, INT* HitSize );
	virtual void MouseDelta( UViewport* Viewport, DWORD Buttons, FLOAT DX, FLOAT DY );
	virtual void MousePosition( UViewport* Viewport, DWORD Buttons, FLOAT X, FLOAT Y );
	virtual void MouseWheel( UViewport* Viewport, DWORD Buttons, INT Delta );
	virtual void Click( UViewport* Viewport, DWORD Buttons, FLOAT X, FLOAT Y );
	virtual void UnClick( UViewport* Viewport, DWORD Buttons, INT MouseX, INT MouseY );
	virtual void SetClientTravel( UPlayer* Viewport, const TCHAR* NextURL, INT bItems, ETravelType TravelType );
	virtual INT ChallengeResponse( INT Challenge );
	virtual FLOAT GetMaxTickRate();
	virtual void SetProgress( const TCHAR* Str1, const TCHAR* Str2, FLOAT Seconds );
	virtual INT Browse( FURL URL, const TMap<FString,FString>* TravelInfo, FString& Error );
	virtual ULevel* LoadMap( const FURL& URL, UPendingLevel* Pending, const TMap<FString,FString>* TravelInfo, FString& Error );
	virtual void SaveGame( INT Position );
	virtual void CancelPending();
	virtual void PaintProgress( const FURL& URL );
	virtual UNetDriver* BuildServerMasterMap( UNetDriver* NetDriver, ULevel* InLevel );
	virtual void NotifyLevelChange();

	// Non-virtual methods
	void FixUpLevel();
	// Auto-generated method declarations
	virtual int ReplaceTexture(FString,UTexture *);
	virtual int LoadBackgroundImage(FString,UTexture *,UTexture *);
	virtual void LoadRandomMenuBackgroundImage(FString);
	void PostRenderFullScreenEffects(FLevelSceneNode *,UViewport *);
	void AddLinkerToMasterMap(UNetDriver *,APawn *);
	void AddLinkerToMasterMap(UNetDriver *,UMaterial *);
	void AddLinkerToMasterMap(UNetDriver *,UMesh *);
	void AddLinkerToMasterMap(UNetDriver *,UStaticMesh *);
	virtual void DisplayGameVideo(eGameVideoType);
	virtual void InitializeMissionDescription(FString &);
};

class ENGINE_API UInteraction : public UInteractions
{
public:
	DECLARE_CLASS(UInteraction,UInteractions,0,Engine)
	DECLARE_FUNCTION(execConsoleCommand)
	DECLARE_FUNCTION(execInitialize)
	DECLARE_FUNCTION(execScreenToWorld)
	DECLARE_FUNCTION(execWorldToScreen)
	// Event thunks
	void eventConnectionFailed();
	FString eventConvertKeyToLocalisation(BYTE, const FString&);
	FString eventGetStoreGamePwd();
	void eventInitialized();
	void eventLaunchR6MainMenu();
	void eventMenuLoadProfile(DWORD);
	void eventNotifyAfterLevelChange();
	void eventNotifyLevelChange();
	void eventR6ConnectionFailed(const FString&);
	void eventR6ConnectionInProgress();
	void eventR6ConnectionInterrupted();
	void eventR6ConnectionSuccess();
	void eventR6ProgressMsg(const FString&, const FString&, FLOAT);
	void eventServerDisconnected();
	void eventUserDisconnected();
protected:
	UInteraction() {}
};

class ENGINE_API UInteractionMaster : public UInteractions
{
public:
	DECLARE_CLASS(UInteractionMaster,UInteractions,0,Engine)
	DECLARE_FUNCTION(execTravel)
	// Event thunks
	UInteraction* eventAddInteraction(const FString&, class UPlayer*);
	DWORD eventProcess_KeyEvent(TArray<UInteraction*>, BYTE&, BYTE&, FLOAT);
	DWORD eventProcess_KeyType(TArray<UInteraction*>, BYTE&);
	void eventProcess_Message(const FString&, FLOAT, TArray<UInteraction*>);
	void eventProcess_PostRender(TArray<UInteraction*>, class UCanvas*);
	void eventProcess_PreRender(TArray<UInteraction*>, class UCanvas*);
	void eventProcess_Tick(TArray<UInteraction*>, FLOAT);
	void eventRemoveInteraction(UInteraction*);
	void eventSetFocusTo(UInteraction*, class UPlayer*);
	// Auto-generated method declarations
	int MasterProcessKeyEvent(EInputKey,EInputAction,float);
	int MasterProcessKeyType(EInputKey);
	void MasterProcessMessage(FString const &,float);
	void MasterProcessPostRender(UCanvas *);
	void MasterProcessPreRender(UCanvas *);
	void MasterProcessTick(float);
	void DisplayCopyright();
	int Exec(const TCHAR*,FOutputDevice &);
};

class ENGINE_API UConsole : public UInteraction
{
public:
	DECLARE_CLASS(UConsole,UInteraction,0,Engine)
protected:
	UConsole() {}
};

// UWindowConsole — from UWindow package. Not exported from any .lib;
// defined inline so R6Game's UR6Console can inherit from it.
class UUWindowRootWindow;
class UWindowConsole : public UConsole
{
public:
	DECLARE_CLASS(UWindowConsole,UConsole,0,UWindow)
	UWindowConsole() {}
};

class ENGINE_API UInput : public USubsystem
{
public:
	DECLARE_CLASS(UInput,USubsystem,CLASS_Transient,Engine)
	UInput() {}

	// Virtual methods
	virtual INT Exec( const TCHAR* Cmd, FOutputDevice& Ar );
	virtual void Serialize( FArchive& Ar );
	virtual void Init( UViewport* InViewport );
	virtual INT PreProcess( INT Key, INT Action, FLOAT Delta );
	virtual INT Process( FOutputDevice& Ar, INT Key, INT Action, FLOAT Delta );
	virtual void DirectAxis( INT Key, FLOAT Value, FLOAT Delta );
	virtual void ReadInput( FLOAT DeltaSeconds, FOutputDevice& Ar );
	virtual void ResetInput();
	virtual const TCHAR* GetKeyName( INT Key ) const;
	virtual INT FindKeyName( const TCHAR* KeyName, INT& Key ) const;
	virtual BYTE GetKey( const TCHAR* KeyName );
	virtual void SetKey( const TCHAR* KeyName );
	virtual FString GetActionKey( BYTE Key );

protected:
	virtual BYTE* FindButtonName( AActor* Actor, const TCHAR* ButtonName ) const;
	virtual FLOAT* FindAxisName( AActor* Actor, const TCHAR* AxisName ) const;
	virtual void ExecInputCommands( const TCHAR* Cmd, FOutputDevice& Ar );

public:
	// Non-virtual methods
	void SetInputAction( INT Action, FLOAT Delta );
	BYTE KeyDown( INT Key );
	void StaticConstructor();
};

class ENGINE_API UInputPlanning : public UInput
{
public:
	DECLARE_CLASS(UInputPlanning,UInput,CLASS_Transient,Engine)
	// Auto-generated method declarations
private:
	static const TCHAR* StaticConfigName();
public:
	static void StaticInitInput();
};

class ENGINE_API UPlayerInput : public UObject
{
public:
	DECLARE_CLASS(UPlayerInput,UObject,0,Engine)
	// Event thunks
	void eventPlayerInput(FLOAT);
protected:
	UPlayerInput() {}
};

class ENGINE_API UCheatManager : public UObject
{
public:
	DECLARE_CLASS(UCheatManager,UObject,0,Engine)
	// Event thunks
	void eventLogThis(DWORD, class AActor*);
protected:
	UCheatManager() {}
};

class ENGINE_API UFont : public UObject
{
public:
	DECLARE_CLASS(UFont,UObject,0,Engine)
	// Auto-generated method declarations
	_WORD RemapChar(_WORD);
	virtual void Serialize(FArchive &);
};

class ENGINE_API UAnimation : public UObject
{
public:
	DECLARE_CLASS(UAnimation,UObject,0,Engine)
	// Auto-generated method declarations
	virtual void Serialize(FArchive &);
};

class ENGINE_API UMeshAnimation : public UObject
{
public:
	DECLARE_CLASS(UMeshAnimation,UObject,0,Engine)
	// Auto-generated method declarations
	virtual int SequenceMemFootprint(FName);
	virtual void Serialize(FArchive &);
	virtual int MemFootprint();
	virtual void PostLoad();
	void ClearAnimNotifys();
	virtual FMeshAnimSeq * GetAnimSeq(FName);
	virtual MotionChunk * GetMovement(FName);
	virtual void InitForDigestion();
};

class ENGINE_API UViewport : public UPlayer
{
public:
	DECLARE_CLASS(UViewport,UPlayer,0,Engine)
	UViewport() {}

	// Virtual methods
	virtual INT Exec( const TCHAR* Cmd, FOutputDevice& Ar );
	virtual void Serialize( const TCHAR* Data, EName Event );
	virtual void Destroy();
	virtual void Serialize( FArchive& Ar );
	virtual void ReadInput( FLOAT DeltaSeconds );
	virtual INT Lock( BYTE* HitData, INT* HitSize );
	virtual void Unlock();
	virtual void Present();
	virtual INT SetDrag( INT NewDrag );
	virtual void* GetServer();
	virtual void TryRenderDevice( const TCHAR* ClassName, INT NewX, INT NewY, INT NewColorBytes );

	// Non-virtual methods
	void ExecMacro( const TCHAR* Filename, FOutputDevice& Ar );
	UClient* GetOuterUClient() const;
	void InitInput();
	INT IsOrtho();
	INT IsPerspective();
	INT IsRealtime();
	INT IsWire();
	void ScreenShot();
	BYTE* _Screen( INT X, INT Y );
	// Auto-generated method declarations
	void PushHit(HHitProxy const &,int);
	static void RefreshAll();
	void LockOnActor(AActor *);
	int MultiShot();
	void PopHit(int);
	void ChangeInputSet(BYTE);
	void ExecProfile(const TCHAR*,int,FOutputDevice &);
	void ExecuteHits(FHitCause const &,BYTE*,int,TCHAR*,FColor *,AActor * *);
	int IsDepthComplexity();
	int IsEditing();
	int IsLit();
	int IsTopView();
};

class ENGINE_API UChannelDownload : public UDownload
{
public:
	DECLARE_CLASS(UChannelDownload,UDownload,CLASS_Transient,Engine)
	NO_DEFAULT_CONSTRUCTOR(UChannelDownload)
	// Auto-generated method declarations
	void StaticConstructor();
	virtual int TrySkipFile();
	virtual void ReceiveFile(UNetConnection *,int,const TCHAR*,int);
	virtual void Serialize(FArchive &);
	virtual void Destroy();
};

class ENGINE_API UBinaryFileDownload : public UChannelDownload
{
public:
	DECLARE_CLASS(UBinaryFileDownload,UChannelDownload,CLASS_Transient,Engine)
	NO_DEFAULT_CONSTRUCTOR(UBinaryFileDownload)

	void StaticConstructor();

	virtual void Tick();
	virtual INT TrySkipFile();
	virtual void ReceiveData(BYTE*, INT);
	virtual void ReceiveFile(UNetConnection*, INT, const TCHAR*, INT);
	virtual void Serialize(FArchive&);
	virtual void Destroy();
	virtual void DownloadDone();
	virtual void DownloadError(const TCHAR*);
};

class ENGINE_API UDemoRecConnection : public UNetConnection
{
public:
	DECLARE_CLASS(UDemoRecConnection,UNetConnection,0,Engine)
	NO_DEFAULT_CONSTRUCTOR(UDemoRecConnection)
};

class ENGINE_API UDemoRecDriver : public UNetDriver
{
public:
	DECLARE_CLASS(UDemoRecDriver,UNetDriver,0,Engine)
	// Auto-generated method declarations
	void SpawnDemoRecSpectator(UNetConnection *);
	void StaticConstructor();
	virtual void TickDispatch(float);
	virtual void LowLevelDestroy();
	virtual FString LowLevelGetNetworkNumber();
	virtual int Exec(const TCHAR*,FOutputDevice &);
	ULevel * GetLevel();
	int InitBase(int,FNetworkNotify *,FURL &,FString &);
	virtual int InitConnect(FNetworkNotify *,FURL &,FString &);
	virtual int InitListen(FNetworkNotify *,FURL &,FString &);
};

class ENGINE_API UNetPendingLevel : public UPendingLevel
{
public:
	DECLARE_CLASS(UNetPendingLevel,UPendingLevel,0,Engine)
};

class ENGINE_API UDemoPlayPendingLevel : public UPendingLevel
{
public:
	DECLARE_CLASS(UDemoPlayPendingLevel,UPendingLevel,0,Engine)
};

class ENGINE_API UNullRenderDevice : public URenderDevice
{
public:
	DECLARE_CLASS(UNullRenderDevice,URenderDevice,0,Engine)
	UNullRenderDevice() {}

	// Virtual methods
	virtual INT Exec( const TCHAR* Cmd, FOutputDevice& Ar );
	virtual INT Init();
	virtual INT SetRes( UViewport* Viewport, INT NewX, INT NewY, INT NewColorBytes );
	virtual void Exit( UViewport* Viewport );
	virtual void Flush( UViewport* Viewport );
	virtual void Present( UViewport* Viewport );
	virtual void SetEmulationMode( INT Mode );
	virtual void Unlock( FRenderInterface* RI );
	virtual void UpdateGamma( UViewport* Viewport );
	virtual void FlushResource( QWORD ResourceId );
	virtual void ReadPixels( UViewport* Viewport, FColor* Pixels );
	virtual void RestoreGamma();
	virtual FRenderInterface* Lock( UViewport* Viewport, BYTE* HitData, INT* HitSize );
	virtual FRenderCaps* GetRenderCaps();
	virtual INT SupportsTextureFormat( INT Format );

	void StaticConstructor();
};

class ENGINE_API UConvexVolume : public UPrimitive
{
public:
	DECLARE_CLASS(UConvexVolume,UPrimitive,0,Engine)
	// Auto-generated method declarations
	virtual void Serialize(FArchive &);
	virtual FBox GetRenderBoundingBox(AActor const *);
	int IsPointInside(FVector,FMatrix);
};

class ENGINE_API UFluidSurfacePrimitive : public UPrimitive
{
public:
	DECLARE_CLASS(UFluidSurfacePrimitive,UPrimitive,0,Engine)
	NO_DEFAULT_CONSTRUCTOR(UFluidSurfacePrimitive)
	// Auto-generated method declarations
	virtual void Serialize(FArchive &);
	virtual int LineCheck(FCheckResult &,AActor *,FVector,FVector,FVector,DWORD,DWORD);
	virtual int PointCheck(FCheckResult &,AActor *,FVector,FVector,DWORD);
	virtual FBox GetCollisionBoundingBox(AActor const *) const;
	virtual FBox GetRenderBoundingBox(AActor const *);
	virtual FSphere GetRenderBoundingSphere(AActor const *);
};

class ENGINE_API UProjectorPrimitive : public UPrimitive
{
public:
	DECLARE_CLASS(UProjectorPrimitive,UPrimitive,0,Engine)
	// Auto-generated method declarations
	virtual int LineCheck(FCheckResult &,AActor *,FVector,FVector,FVector,DWORD,DWORD);
	virtual int PointCheck(FCheckResult &,AActor *,FVector,FVector,DWORD);
	virtual void Destroy();
	virtual FBox GetCollisionBoundingBox(AActor const *) const;
	virtual FVector GetEncroachCenter(AActor *);
	virtual FVector GetEncroachExtent(AActor *);
};

class ENGINE_API UTerrainPrimitive : public UPrimitive
{
public:
	DECLARE_CLASS(UTerrainPrimitive,UPrimitive,0,Engine)
	NO_DEFAULT_CONSTRUCTOR(UTerrainPrimitive)
};

class ENGINE_API UVertMesh : public ULodMesh
{
public:
	DECLARE_CLASS(UVertMesh,ULodMesh,0,Engine)
	// Auto-generated method declarations
	int RenderPreProcess();
	virtual void Serialize(FArchive &);
	virtual UClass * MeshGetInstanceClass();
	virtual void PostLoad();
	virtual FBox GetRenderBoundingBox(AActor const *);
	virtual FSphere GetRenderBoundingSphere(AActor const *);
};

class ENGINE_API UVertMeshInstance : public ULodMeshInstance
{
public:
	DECLARE_CLASS(UVertMeshInstance,ULodMeshInstance,0,Engine)

	struct FMeshAnimSeq* GetAnimSeq(FName);

	virtual void MeshBuildBounds();
	virtual FMatrix MeshToWorld();
	virtual INT StopAnimating(INT);
	virtual INT UpdateAnimation(FLOAT);
	virtual void Render(class FDynamicActor*, FLevelSceneNode*, TList<class FDynamicLight*>*, FRenderInterface*);
	virtual void Serialize(FArchive&);
	virtual void SetAnimFrame(INT, FLOAT);
	virtual void SetScale(FVector);
	virtual INT PlayAnim(INT, FName, FLOAT, FLOAT, INT, INT, INT);
	virtual INT AnimForcePose(FName, FLOAT, FLOAT, INT);
	virtual FLOAT AnimGetFrameCount(void*);
	virtual FName AnimGetGroup(void*);
	virtual FName AnimGetName(void*);
	virtual INT AnimGetNotifyCount(void*);
	virtual UAnimNotify* AnimGetNotifyObject(void*, INT);
	virtual const TCHAR* AnimGetNotifyText(void*, INT);
	virtual FLOAT AnimGetNotifyTime(void*, INT);
	virtual FLOAT AnimGetRate(void*);
	virtual INT AnimIsInGroup(void*, FName);
	virtual INT AnimStopLooping(INT);
	virtual FLOAT GetActiveAnimFrame(INT);
	virtual FLOAT GetActiveAnimRate(INT);
	virtual FName GetActiveAnimSequence(INT);
	virtual INT GetAnimCount();
	virtual void* GetAnimIndexed(INT);
	virtual void* GetAnimNamed(FName);
	virtual void GetFrame(AActor*, FLevelSceneNode*, FVector*, INT, INT&, DWORD);
	virtual UMaterial* GetMaterial(INT, AActor*);
	virtual void GetMeshVerts(AActor*, FVector*, INT, INT&);
	virtual FBox GetRenderBoundingBox(const AActor*);
	virtual FSphere GetRenderBoundingSphere(const AActor*);
	virtual INT IsAnimating(INT);
	virtual INT IsAnimLooping(INT);
	virtual INT IsAnimPastLastFrame(INT);
	virtual INT IsAnimTweening(INT);
};

class ENGINE_API USkinVertexBuffer : public URenderResource
{
public:
	DECLARE_CLASS(USkinVertexBuffer,URenderResource,0,Engine)
	// Auto-generated method declarations
	virtual void Serialize(FArchive &);
};

class ENGINE_API UIndexBuffer : public URenderResource
{
public:
	DECLARE_CLASS(UIndexBuffer,URenderResource,0,Engine)
	// Auto-generated method declarations
	virtual void Serialize(FArchive &);
};

class ENGINE_API UVertexBuffer : public UVertexStreamBase
{
public:
	DECLARE_CLASS(UVertexBuffer,UVertexStreamBase,0,Engine)
	UVertexBuffer();
	UVertexBuffer(DWORD InFlags);
	virtual void Serialize(FArchive& Ar);
	virtual void* GetData();
	virtual INT GetDataSize();
};

class ENGINE_API UVertexStreamCOLOR : public UVertexStreamBase
{
public:
	DECLARE_CLASS(UVertexStreamCOLOR,UVertexStreamBase,0,Engine)
	UVertexStreamCOLOR();
	UVertexStreamCOLOR(DWORD InFlags);
	virtual void Serialize(FArchive& Ar);
	virtual void* GetData();
	virtual INT GetDataSize();
};

class ENGINE_API UVertexStreamPosNormTex : public UVertexStreamBase
{
public:
	DECLARE_CLASS(UVertexStreamPosNormTex,UVertexStreamBase,0,Engine)
	UVertexStreamPosNormTex();
	UVertexStreamPosNormTex(DWORD InFlags);
	virtual void Serialize(FArchive& Ar);
	virtual void* GetData();
	virtual INT GetDataSize();
};

class ENGINE_API UVertexStreamUV : public UVertexStreamBase
{
public:
	DECLARE_CLASS(UVertexStreamUV,UVertexStreamBase,0,Engine)
	UVertexStreamUV();
	UVertexStreamUV(DWORD InFlags);
	virtual void Serialize(FArchive& Ar);
	virtual void* GetData();
	virtual INT GetDataSize();
};

class ENGINE_API UVertexStreamVECTOR : public UVertexStreamBase
{
public:
	DECLARE_CLASS(UVertexStreamVECTOR,UVertexStreamBase,0,Engine)
	UVertexStreamVECTOR();
	UVertexStreamVECTOR(DWORD InFlags);
	virtual void Serialize(FArchive& Ar);
	virtual void* GetData();
	virtual INT GetDataSize();
};

class ENGINE_API UCameraOverlay : public UCameraEffect
{
public:
	DECLARE_CLASS(UCameraOverlay,UCameraEffect,0,Engine)
	// Auto-generated method declarations
	virtual void PostRender(UViewport *,FRenderInterface *);
};

class ENGINE_API UMotionBlur : public UCameraEffect
{
public:
	DECLARE_CLASS(UMotionBlur,UCameraEffect,0,Engine)
	// Auto-generated method declarations
	virtual void PostRender(UViewport *,FRenderInterface *);
	virtual void PreRender(UViewport *,FRenderInterface *);
	virtual void Destroy();
};

class ENGINE_API UFadeColor : public UConstantMaterial
{
public:
	DECLARE_CLASS(UFadeColor,UConstantMaterial,0,Engine)
	// Auto-generated method declarations
	virtual FColor GetColor(float);
};

class ENGINE_API UDiffuseAttenuationMaterial : public URenderedMaterial
{
public:
	DECLARE_CLASS(UDiffuseAttenuationMaterial,URenderedMaterial,0,Engine)
	NO_DEFAULT_CONSTRUCTOR(UDiffuseAttenuationMaterial)
};

class ENGINE_API UParticleMaterial : public URenderedMaterial
{
public:
	DECLARE_CLASS(UParticleMaterial,URenderedMaterial,0,Engine)
	NO_DEFAULT_CONSTRUCTOR(UParticleMaterial)
};

class ENGINE_API UTerrainMaterial : public URenderedMaterial
{
public:
	DECLARE_CLASS(UTerrainMaterial,URenderedMaterial,0,Engine)
	// Auto-generated method declarations
	virtual UMaterial * CheckFallback();
	virtual int HasFallback();
};

class ENGINE_API UTexCoordSource : public UTexModifier
{
public:
	DECLARE_CLASS(UTexCoordSource,UTexModifier,0,Engine)
	// Auto-generated method declarations
	virtual void PostEditChange();
};

class ENGINE_API UProxyBitmapMaterial : public UBitmapMaterial
{
public:
	DECLARE_CLASS(UProxyBitmapMaterial,UBitmapMaterial,0,Engine)
	// Auto-generated method declarations
	void SetTextureInterface(FBaseTexture *);
	virtual UBitmapMaterial * Get(double,UViewport *);
	virtual FBaseTexture * GetRenderInterface();
};

class ENGINE_API UShadowBitmapMaterial : public UBitmapMaterial
{
public:
	DECLARE_CLASS(UShadowBitmapMaterial,UBitmapMaterial,0,Engine)
	// Auto-generated method declarations
	virtual void Destroy();
	virtual UBitmapMaterial * Get(double,UViewport *);
	virtual FBaseTexture * GetRenderInterface();
};

class ENGINE_API UMaterialSwitch : public UModifier
{
public:
	DECLARE_CLASS(UMaterialSwitch,UModifier,0,Engine)
	// Auto-generated method declarations
	virtual void PostEditChange();
	virtual int CheckCircularReferences(TArray<UMaterial *> &);
};

class ENGINE_API UKarmaParams : public UKarmaParamsCollision
{
public:
	DECLARE_CLASS(UKarmaParams,UKarmaParamsCollision,0,Engine)
	// Auto-generated method declarations
	virtual void PostEditChange();
};

class ENGINE_API UKarmaParamsRBFull : public UKarmaParams
{
public:
	DECLARE_CLASS(UKarmaParamsRBFull,UKarmaParams,0,Engine)
	NO_DEFAULT_CONSTRUCTOR(UKarmaParamsRBFull)
};

class ENGINE_API UKarmaParamsSkel : public UKarmaParams
{
public:
	DECLARE_CLASS(UKarmaParamsSkel,UKarmaParams,0,Engine)
	NO_DEFAULT_CONSTRUCTOR(UKarmaParamsSkel)
};

class ENGINE_API UKMeshProps : public UObject
{
public:
	DECLARE_CLASS(UKMeshProps,UObject,0,Engine)
	// Auto-generated method declarations
	virtual void Serialize(FArchive &);
	void Draw(FRenderInterface *,int);
};

class ENGINE_API UBeamEmitter : public UParticleEmitter
{
public:
	DECLARE_CLASS(UBeamEmitter,UParticleEmitter,0,Engine)
	// Auto-generated method declarations
	virtual void SpawnParticle(int,float,int,int,FVector const &);
	virtual void UpdateActorHitList();
	virtual int UpdateParticles(float);
	virtual int RenderParticles(FDynamicActor *,FLevelSceneNode *,TList<FDynamicLight *> *,FRenderInterface *);
	virtual void Scale(float);
	virtual void PostEditChange();
	virtual void CleanUp();
	virtual void Initialize(int);
};

class ENGINE_API UMeshEmitter : public UParticleEmitter
{
public:
	DECLARE_CLASS(UMeshEmitter,UParticleEmitter,0,Engine)
	// Auto-generated method declarations
	virtual int UpdateParticles(float);
	virtual int RenderParticles(FDynamicActor *,FLevelSceneNode *,TList<FDynamicLight *> *,FRenderInterface *);
	virtual void PostEditChange();
	virtual void Initialize(int);
};

class ENGINE_API USparkEmitter : public UParticleEmitter
{
public:
	DECLARE_CLASS(USparkEmitter,UParticleEmitter,0,Engine)
	// Auto-generated method declarations
	virtual void SpawnParticle(int,float,int,int,FVector const &);
	virtual int UpdateParticles(float);
	virtual int RenderParticles(FDynamicActor *,FLevelSceneNode *,TList<FDynamicLight *> *,FRenderInterface *);
	virtual void PostEditChange();
	virtual void CleanUp();
	virtual void Initialize(int);
};

class ENGINE_API USpriteEmitter : public UParticleEmitter
{
public:
	DECLARE_CLASS(USpriteEmitter,UParticleEmitter,0,Engine)
	// Auto-generated method declarations
	virtual int UpdateParticles(float);
	virtual int RenderParticles(FDynamicActor *,FLevelSceneNode *,TList<FDynamicLight *> *,FRenderInterface *);
	virtual void PostEditChange();
	virtual void CleanUp();
	virtual int FillVertexBuffer(FSpriteParticleVertex *,FLevelSceneNode *);
	virtual void Initialize(int);
};

class ENGINE_API UAnimNotify_DestroyEffect : public UAnimNotify
{
public:
	DECLARE_CLASS(UAnimNotify_DestroyEffect,UAnimNotify,0,Engine)
	// Auto-generated method declarations
	virtual void Notify(UMeshInstance *,AActor *);
};

class ENGINE_API UAnimNotify_Effect : public UAnimNotify
{
public:
	DECLARE_CLASS(UAnimNotify_Effect,UAnimNotify,0,Engine)
	// Auto-generated method declarations
	virtual void Notify(UMeshInstance *,AActor *);
};

class ENGINE_API UAnimNotify_MatSubAction : public UAnimNotify
{
public:
	DECLARE_CLASS(UAnimNotify_MatSubAction,UAnimNotify,0,Engine)
	// Auto-generated method declarations
	virtual void Notify(UMeshInstance *,AActor *);
};

class ENGINE_API UAnimNotify_Script : public UAnimNotify
{
public:
	DECLARE_CLASS(UAnimNotify_Script,UAnimNotify,0,Engine)
	// Auto-generated method declarations
	virtual void Notify(UMeshInstance *,AActor *);
};

class ENGINE_API UAnimNotify_Scripted : public UAnimNotify
{
public:
	DECLARE_CLASS(UAnimNotify_Scripted,UAnimNotify,0,Engine)
	// Event thunks
	void eventNotify(class AActor*);
	// Auto-generated method declarations
	virtual void Notify(UMeshInstance *,AActor *);
};

class ENGINE_API UAnimNotify_Sound : public UAnimNotify
{
public:
	DECLARE_CLASS(UAnimNotify_Sound,UAnimNotify,0,Engine)
	// Auto-generated method declarations
	virtual void Notify(UMeshInstance *,AActor *);
};

class ENGINE_API UActionMoveCamera : public UMatAction
{
public:
	DECLARE_CLASS(UActionMoveCamera,UMatAction,0,Engine)
	NO_DEFAULT_CONSTRUCTOR(UActionMoveCamera)
};

class ENGINE_API UActionMoveActor : public UActionMoveCamera
{
public:
	DECLARE_CLASS(UActionMoveActor,UActionMoveCamera,0,Engine)
	NO_DEFAULT_CONSTRUCTOR(UActionMoveActor)
};

class ENGINE_API UActionPause : public UMatAction
{
public:
	DECLARE_CLASS(UActionPause,UMatAction,0,Engine)
	NO_DEFAULT_CONSTRUCTOR(UActionPause)
};

class ENGINE_API USubActionCameraEffect : public UMatSubAction
{
public:
	DECLARE_CLASS(USubActionCameraEffect,UMatSubAction,0,Engine)
	// Auto-generated method declarations
	virtual int Update(float,ASceneManager *);
	virtual FString GetStatString();
};

class ENGINE_API USubActionCameraShake : public UMatSubAction
{
public:
	DECLARE_CLASS(USubActionCameraShake,UMatSubAction,0,Engine)
	// Auto-generated method declarations
	virtual int Update(float,ASceneManager *);
	virtual FString GetStatString();
};

class ENGINE_API USubActionFade : public UMatSubAction
{
public:
	DECLARE_CLASS(USubActionFade,UMatSubAction,0,Engine)
	// Auto-generated method declarations
	virtual int Update(float,ASceneManager *);
	virtual FString GetStatString();
};

class ENGINE_API USubActionFOV : public UMatSubAction
{
public:
	DECLARE_CLASS(USubActionFOV,UMatSubAction,0,Engine)
	// Auto-generated method declarations
	virtual int Update(float,ASceneManager *);
	virtual FString GetStatString();
};

class ENGINE_API USubActionGameSpeed : public UMatSubAction
{
public:
	DECLARE_CLASS(USubActionGameSpeed,UMatSubAction,0,Engine)
	// Auto-generated method declarations
	virtual int Update(float,ASceneManager *);
	virtual FString GetStatString();
};

class ENGINE_API USubActionOrientation : public UMatSubAction
{
public:
	DECLARE_CLASS(USubActionOrientation,UMatSubAction,0,Engine)
	// Auto-generated method declarations
	virtual int Update(float,ASceneManager *);
	virtual void PostLoad();
	virtual FString GetStatString();
	virtual int IsRunning();
};

class ENGINE_API USubActionSceneSpeed : public UMatSubAction
{
public:
	DECLARE_CLASS(USubActionSceneSpeed,UMatSubAction,0,Engine)
	// Auto-generated method declarations
	virtual int Update(float,ASceneManager *);
	virtual FString GetStatString();
};

class ENGINE_API USubActionTrigger : public UMatSubAction
{
public:
	DECLARE_CLASS(USubActionTrigger,UMatSubAction,0,Engine)
	// Auto-generated method declarations
	virtual int Update(float,ASceneManager *);
	virtual FString GetStatString();
};

class ENGINE_API ULevelSummary : public UObject
{
public:
	DECLARE_CLASS(ULevelSummary,UObject,0,Engine)
	// Auto-generated method declarations
	virtual void PostLoad();
};

class ENGINE_API UReachSpec : public UObject
{
public:
	DECLARE_CLASS(UReachSpec,UObject,0,Engine)
	// Auto-generated method declarations
	int findBestReachable(AScout *);
	int supports(int,int,int,int);
	int defineFor(ANavigationPoint *,ANavigationPoint *,APawn *);
	FPlane PathColor();
	int PlaceScout(AScout *);
	int operator==(UReachSpec const &);
	UReachSpec * operator+(UReachSpec const &) const;
	int operator<=(UReachSpec const &);
	int BotOnlyPath();
	void Init();
};

class ENGINE_API UTerrainSector : public UObject
{
public:
	DECLARE_CLASS(UTerrainSector,UObject,0,Engine)
	NO_DEFAULT_CONSTRUCTOR(UTerrainSector)
};

class ENGINE_API UI3DL2Listener : public UObject
{
public:
	DECLARE_CLASS(UI3DL2Listener,UObject,0,Engine)
	// Auto-generated method declarations
	virtual void PostEditChange();
};

class ENGINE_API USoundGen : public USound
{
public:
	DECLARE_CLASS(USoundGen,USound,0,Engine)
	// Auto-generated method declarations
	virtual void Serialize(FArchive &);
};

class ENGINE_API UServerCommandlet : public UObject
{
public:
	DECLARE_CLASS(UServerCommandlet,UObject,0,Engine)
};

class ENGINE_API UR6FileManager : public UObject
{
public:
	DECLARE_CLASS(UR6FileManager,UObject,0,Engine)
	DECLARE_FUNCTION(execDeleteFile)
	DECLARE_FUNCTION(execFindFile)
	DECLARE_FUNCTION(execGetFileName)
	DECLARE_FUNCTION(execGetNbFile)
	// Auto-generated method declarations
	virtual int FindFile(FString *);
	virtual void GetFileName(int,FString *);
	virtual int GetNbFile(FString *,FString *);
};

class ENGINE_API UR6GameColors : public UObject
{
public:
	DECLARE_CLASS(UR6GameColors,UObject,0,Engine)
	NO_DEFAULT_CONSTRUCTOR(UR6GameColors)
};

class ENGINE_API UR6GameMenuCom : public UObject
{
public:
	DECLARE_CLASS(UR6GameMenuCom,UObject,0,Engine)
	NO_DEFAULT_CONSTRUCTOR(UR6GameMenuCom)
};

class ENGINE_API UR6Mod : public UObject
{
public:
	DECLARE_CLASS(UR6Mod,UObject,0,Engine)
	NO_DEFAULT_CONSTRUCTOR(UR6Mod)
};

class ENGINE_API UR6AbstractPlanningInfo : public UObject
{
public:
	DECLARE_CLASS(UR6AbstractPlanningInfo,UObject,0,Engine)
	// Auto-generated method declarations
	virtual void TransferFile(FArchive &);
	virtual void AddPoint(AActor *);
	virtual AActor * GetTeamLeader();
};

class UR6AbstractTerroristMgr : public UObject
{
public:
	DECLARE_CLASS(UR6AbstractTerroristMgr,UObject,0,Engine)
	UR6AbstractTerroristMgr() {}
};

// --- Actor subclasses ---

class ENGINE_API ACamera : public APlayerController
{
public:
DECLARE_CLASS(ACamera,APlayerController,0|CLASS_Config|CLASS_NativeReplication,Engine)

virtual void RenderEditorInfo(FLevelSceneNode*, FRenderInterface*, class FDynamicActor*);
virtual void RenderEditorSelected(FLevelSceneNode*, FRenderInterface*, class FDynamicActor*);
};

class ENGINE_API AScout : public APawn
{
public:
	DECLARE_CLASS(AScout,APawn,0|CLASS_Config|CLASS_NativeReplication,Engine)
	// Auto-generated method declarations
	int findStart(FVector);
	virtual int HurtByVolume(AActor *);
	void InitForPathing();
};

class ENGINE_API AStatLogFile : public AStatLog
{
public:
	DECLARE_CLASS(AStatLogFile,AStatLog,0,Engine)
	NO_DEFAULT_CONSTRUCTOR(AStatLogFile)
	DECLARE_FUNCTION(execCloseLog)
	DECLARE_FUNCTION(execFileFlush)
	DECLARE_FUNCTION(execFileLog)
	DECLARE_FUNCTION(execGetChecksum)
	DECLARE_FUNCTION(execOpenLog)
	DECLARE_FUNCTION(execWatermark)
};

class ENGINE_API AActorManager : public ASceneManager
{
public:
	DECLARE_CLASS(AActorManager,ASceneManager,0,Engine)
	NO_DEFAULT_CONSTRUCTOR(AActorManager)
};

class ENGINE_API AAIMarker : public ASmallNavigationPoint
{
public:
	DECLARE_CLASS(AAIMarker,ASmallNavigationPoint,0,Engine)
	// Auto-generated method declarations
	virtual int IsIdentifiedAs(FName);
};

class ENGINE_API AAIScript : public AKeypoint
{
public:
	DECLARE_CLASS(AAIScript,AKeypoint,0,Engine)
	// Auto-generated method declarations
	virtual void AddMyMarker(AActor *);
};

class ENGINE_API ADoor : public ANavigationPoint
{
public:
	DECLARE_CLASS(ADoor,ANavigationPoint,0,Engine)
	// Auto-generated method declarations
	virtual void PostaddReachSpecs(APawn *);
	virtual void PostPath();
	virtual void PrePath();
	virtual AActor * AssociatedLevelGeometry();
	virtual void FindBase();
	virtual int HasAssociatedLevelGeometry(AActor *);
	virtual void InitForPathFinding();
	virtual int IsIdentifiedAs(FName);
};

class ENGINE_API AFluidSurfaceOscillator : public AActor
{
public:
	DECLARE_CLASS(AFluidSurfaceOscillator,AActor,0,Engine)
	// Auto-generated method declarations
	void UpdateOscillation(float);
	virtual void PostEditChange();
	virtual void Destroy();
};

class ENGINE_API AInterpolationPoint : public AKeypoint
{
public:
	DECLARE_CLASS(AInterpolationPoint,AKeypoint,0,Engine)
	// Auto-generated method declarations
	virtual void RenderEditorSelected(FLevelSceneNode *,FRenderInterface *,FDynamicActor *);
	virtual void PostEditChange();
	virtual void PostEditMove();
};

class ENGINE_API AJumpDest : public ANavigationPoint
{
public:
	DECLARE_CLASS(AJumpDest,ANavigationPoint,0,Engine)
	// Auto-generated method declarations
	virtual void SetupForcedPath(APawn *,UReachSpec *);
	virtual void ClearPaths();
};

class ENGINE_API AJumpPad : public ANavigationPoint
{
public:
	DECLARE_CLASS(AJumpPad,ANavigationPoint,0,Engine)
	// Auto-generated method declarations
	virtual void addReachSpecs(APawn *,int);
};

class ENGINE_API AKBSJoint : public AKConstraint
{
public:
	DECLARE_CLASS(AKBSJoint,AKConstraint,0,Engine)
	NO_DEFAULT_CONSTRUCTOR(AKBSJoint)
};

class ENGINE_API AKConeLimit : public AKConstraint
{
public:
	DECLARE_CLASS(AKConeLimit,AKConstraint,0,Engine)
	// Auto-generated method declarations
	virtual void KUpdateConstraintParams();
};

class ENGINE_API AKHinge : public AKConstraint
{
public:
	DECLARE_CLASS(AKHinge,AKConstraint,0,Engine)
	// Auto-generated method declarations
	virtual void preKarmaStep(float);
	virtual void KUpdateConstraintParams();
};

class ENGINE_API ALadder : public ASmallNavigationPoint
{
public:
	DECLARE_CLASS(ALadder,ASmallNavigationPoint,0,Engine)
	// Auto-generated method declarations
	virtual void addReachSpecs(APawn *,int);
	virtual int ProscribedPathTo(ANavigationPoint *);
	virtual void ClearPaths();
	virtual void InitForPathFinding();
};

class ENGINE_API ALadderVolume : public APhysicsVolume
{
public:
	DECLARE_CLASS(ALadderVolume,APhysicsVolume,0,Engine)
	// Auto-generated method declarations
	virtual void RenderEditorInfo(FLevelSceneNode *,FRenderInterface *,FDynamicActor *);
	virtual void AddMyMarker(AActor *);
	FVector FindCenter();
	FVector FindTop(FVector);
};

class ENGINE_API ALiftCenter : public ANavigationPoint
{
public:
	DECLARE_CLASS(ALiftCenter,ANavigationPoint,0,Engine)
	// Auto-generated method declarations
	virtual void addReachSpecs(APawn *,int);
	virtual void FindBase();
};

class ENGINE_API ALiftExit : public ANavigationPoint
{
public:
	DECLARE_CLASS(ALiftExit,ANavigationPoint,0,Engine)
	NO_DEFAULT_CONSTRUCTOR(ALiftExit)
};

class ENGINE_API ALineOfSightTrigger : public ATriggers
{
public:
	DECLARE_CLASS(ALineOfSightTrigger,ATriggers,0,Engine)
	// Event thunks
	void eventPlayerSeesMe(class APlayerController*);
	// Auto-generated method declarations
	virtual void TickAuthoritative(float);
};

class ENGINE_API ALookTarget : public AKeypoint
{
public:
	DECLARE_CLASS(ALookTarget,AKeypoint,0,Engine)
	NO_DEFAULT_CONSTRUCTOR(ALookTarget)
};

class ENGINE_API APathNode : public ANavigationPoint
{
public:
	DECLARE_CLASS(APathNode,ANavigationPoint,0,Engine)
	// Auto-generated method declarations
	virtual int ReviewPath(APawn *);
	virtual void CheckSymmetry(ANavigationPoint *);
};

class ENGINE_API APlayerStart : public ASmallNavigationPoint
{
public:
	DECLARE_CLASS(APlayerStart,ASmallNavigationPoint,0,Engine)
	// Auto-generated method declarations
	virtual void addReachSpecs(APawn *,int);
};

class ENGINE_API APotentialClimbWatcher : public AInfo
{
public:
	DECLARE_CLASS(APotentialClimbWatcher,AInfo,0,Engine)
	NO_DEFAULT_CONSTRUCTOR(APotentialClimbWatcher)
};

class ENGINE_API AR6MapList : public AMapList
{
public:
	DECLARE_CLASS(AR6MapList,AMapList,0,Engine)
	NO_DEFAULT_CONSTRUCTOR(AR6MapList)
};

class ENGINE_API ASavedMove : public AInfo
{
public:
	DECLARE_CLASS(ASavedMove,AInfo,0,Engine)
	NO_DEFAULT_CONSTRUCTOR(ASavedMove)
};

class ENGINE_API ATeleporter : public ASmallNavigationPoint
{
public:
	DECLARE_CLASS(ATeleporter,ASmallNavigationPoint,0,Engine)
	// Auto-generated method declarations
	virtual void addReachSpecs(APawn *,int);
};

class ENGINE_API ATerrainInfo : public AInfo
{
public:
DECLARE_CLASS(ATerrainInfo,AInfo,0,Engine)

void SoftSelect(FLOAT, FLOAT);
void Update(FLOAT, INT, INT, INT, INT, INT);
void UpdateDecorations(INT);
void UpdateTriangles(INT, INT, INT, INT, INT);
void UpdateVertices(FLOAT, INT, INT, INT, INT);
FVector WorldToHeightmap(FVector);
void Render(FLevelSceneNode*, FRenderInterface*, class FVisibilityInterface*);
void RenderDecorations(FLevelSceneNode*, FRenderInterface*, class FVisibilityInterface*);
INT SelectVertex(FVector);
INT SelectVertexX(INT, INT);
void SelectVerticesInBox(FBox&);
void SetEdgeTurnBitmap(INT, INT, INT);
void SetHeightmap(INT, INT, _WORD);
void SetLayerAlpha(FLOAT, FLOAT, INT, BYTE, UTexture*);
void SetPlanningFloorMap(INT, INT, INT);
void SetQuadVisibilityBitmap(INT, INT, INT);
void SetTextureColor(INT, INT, UTexture*, FColor&);
INT LineCheck(FCheckResult&, FVector, FVector, FVector, INT);
INT LineCheckWithQuad(INT, INT, FCheckResult&, FVector, FVector, FVector, INT);
void MoveVertices(FLOAT);
INT PointCheck(FCheckResult&, FVector, FVector, INT);
void CalcCoords();
void CalcLayerTexCoords();
void CheckComputeDataOnLoad();
void CombineLayerWeights();
void ConvertHeightmapFormat();
INT GetClosestVertex(FVector&, FVector*, INT*, INT*);
INT GetEdgeTurnBitmap(INT, INT);
INT GetGlobalVertex(INT, INT);
_WORD GetHeightmap(INT, INT);
BYTE GetLayerAlpha(INT, INT, INT, UTexture*);
INT GetPlanningFloorMap(INT, INT);
INT GetQuadVisibilityBitmap(INT, INT);
INT GetRenderCombinationNum(TArray<INT>&, ETerrainRenderMethod);
FBox GetSelectedVerticesBounds();
FColor GetTextureColor(INT, INT, UTexture*);
FVector GetVertexNormal(INT, INT);
FVector HeightmapToWorld(FVector);
void SetupSectors();
void SoftDeselect();
void UpdateFromSelectedVertices();
void ResetMove();
void PrecomputeLayerWeights();

virtual void Serialize(FArchive&);
virtual void CheckForErrors();
virtual void Destroy();
virtual UPrimitive* GetPrimitive();
virtual void PostEditChange();
virtual void PostLoad();
};

class ENGINE_API AWarpZoneMarker : public ASmallNavigationPoint
{
public:
	DECLARE_CLASS(AWarpZoneMarker,ASmallNavigationPoint,0,Engine)
	// Auto-generated method declarations
	virtual void addReachSpecs(APawn *,int);
	virtual int IsIdentifiedAs(FName);
};

// --- RVS-specific actor subclasses ---

class ENGINE_API AR6AbstractCircumstantialActionQuery : public AActor
{
public:
	DECLARE_CLASS(AR6AbstractCircumstantialActionQuery,AActor,0,Engine)
	// Auto-generated method declarations
	virtual int * GetOptimizedRepList(BYTE*,FPropertyRetirement *,int *,UPackageMap *,UActorChannel *);
};

class AR6AbstractClimbableObj : public AActor
{
public:
	DECLARE_CLASS(AR6AbstractClimbableObj,AActor,0,Engine)
	AR6AbstractClimbableObj() {}
};

class ENGINE_API AR6ActionPointAbstract : public AActor
{
public:
	DECLARE_CLASS(AR6ActionPointAbstract,AActor,0,Engine)
protected:
	AR6ActionPointAbstract() {}
};

class ENGINE_API AR6ActionSpot : public AActor
{
public:
	DECLARE_CLASS(AR6ActionSpot,AActor,0,Engine)
	// Auto-generated method declarations
	virtual void RenderEditorInfo(FLevelSceneNode *,FRenderInterface *,FDynamicActor *);
	virtual void CheckForErrors();
};

class ENGINE_API AR6ColBox : public AActor
{
public:
	DECLARE_CLASS(AR6ColBox,AActor,0,Engine)
	DECLARE_FUNCTION(execEnableCollision)
	// Auto-generated method declarations
	virtual int ShouldTrace(AActor *,DWORD);
	virtual void SetBase(AActor *,FVector,int);
	int CanStepUp(FVector);
	void EnableCollision(int,int,int);
	void GetColBoxLocationFromOwner(FVector &,float);
	void GetDestination(FVector &,FRotator &);
	float GetMaxStepUp(bool,float);
	virtual APawn * GetPawnOrColBoxOwner() const;
	virtual int IsBlockedBy(AActor const *) const;
};

class ENGINE_API AR6DecalsBase : public AActor
{
public:
	DECLARE_CLASS(AR6DecalsBase,AActor,0,Engine)
	// Auto-generated method declarations
	virtual int IsNetRelevantFor(APlayerController *,AActor *,FVector);
};

class ENGINE_API AR6Decal : public AProjector
{
public:
	DECLARE_CLASS(AR6Decal,AProjector,0,Engine)
	NO_DEFAULT_CONSTRUCTOR(AR6Decal)
};

class ENGINE_API AR6DecalGroup : public AActor
{
public:
	DECLARE_CLASS(AR6DecalGroup,AActor,0,Engine)
	DECLARE_FUNCTION(execActivateGroup)
	DECLARE_FUNCTION(execAddDecal)
	DECLARE_FUNCTION(execDeActivateGroup)
	DECLARE_FUNCTION(execKillDecal)
	// Auto-generated method declarations
	virtual void Spawned();
	void KillDecal(AR6Decal *);
	virtual void PostScriptDestroyed();
	void ActivateGroup();
	int AddDecal(FVector *,FRotator *,UTexture *,int,float,float,float,float,int);
};

class ENGINE_API AR6DecalManager : public AActor
{
public:
	DECLARE_CLASS(AR6DecalManager,AActor,0,Engine)
	DECLARE_FUNCTION(execAddDecal)
	DECLARE_FUNCTION(execKillDecal)
	// Auto-generated method declarations
	virtual void Spawned();
	int AddDecal(FVector *,FRotator *,UTexture *,eDecalType,int,float,float,float,float,int);
	AR6DecalGroup * FindGroup(eDecalType);
};

class ENGINE_API AR6EngineFirstPersonWeapon : public AActor
{
public:
	DECLARE_CLASS(AR6EngineFirstPersonWeapon,AActor,0,Engine)
protected:
	AR6EngineFirstPersonWeapon() {}
};

class ENGINE_API AR6EngineWeapon : public AActor
{
public:
	DECLARE_CLASS(AR6EngineWeapon,AActor,0,Engine)
	// Event thunks
	void eventDeployWeaponBipod(DWORD bDeploy);
	DWORD eventIsGoggles();
	void eventPawnIsMoving();
	void eventPawnStoppedMoving();
	void eventSetIdentifyTarget(DWORD bShow, DWORD bFriendly, const FString& Name);
	void eventShowWeaponParticules(BYTE ParticuleType);
	void eventUpdateWeaponAttachment();
	// Auto-generated method declarations
	virtual int GetHeartBeatStatus();
};

class ENGINE_API AR6FootStep : public AActor
{
public:
	DECLARE_CLASS(AR6FootStep,AActor,0,Engine)
	NO_DEFAULT_CONSTRUCTOR(AR6FootStep)
};

class ENGINE_API AR6GlowLight : public ALight
{
public:
	DECLARE_CLASS(AR6GlowLight,ALight,0,Engine)
protected:
	AR6GlowLight() {}
};

class ENGINE_API AR6RainbowStartInfo : public AActor
{
public:
	DECLARE_CLASS(AR6RainbowStartInfo,AActor,0,Engine)
	// Auto-generated method declarations
	void TransferFile(FArchive &);
};

class ENGINE_API AR6StartGameInfo : public AActor
{
public:
	DECLARE_CLASS(AR6StartGameInfo,AActor,0,Engine)
};

class ENGINE_API AR6TeamStartInfo : public AActor
{
public:
	DECLARE_CLASS(AR6TeamStartInfo,AActor,0,Engine)
	// Auto-generated method declarations
	void TransferFile(FArchive &,int);
};

class ENGINE_API AR6WallHit : public AR6DecalsBase
{
public:
	DECLARE_CLASS(AR6WallHit,AR6DecalsBase,0,Engine)
	// Auto-generated method declarations
	virtual void SpawnEffects();
	virtual void SpawnSound();
	virtual void PostBeginPlay();
};

class AR6AbstractHostageMgr : public AActor
{
public:
	DECLARE_CLASS(AR6AbstractHostageMgr,AActor,0,Engine)
	AR6AbstractHostageMgr() {}
	AR6AbstractHostageMgr(const AR6AbstractHostageMgr&) {}
};

struct FR6HUDState
{
	FLOAT fTimeStamp;
	BYTE eDisplay;
	FColor Color;
};

class ENGINE_API FCameraSceneNode;
class ENGINE_API FCanvasUtil;

class UR6MissionObjectiveBase : public UObject
{
public:
	DECLARE_CLASS(UR6MissionObjectiveBase,UObject,0,Engine)
	INT m_iCountdown;
	BITFIELD m_bFailed : 1;
	BITFIELD m_bCompleted : 1;
	BITFIELD m_bVisibleInMenu : 1;
	BITFIELD m_bIfCompletedMissionIsSuccessfull : 1;
	BITFIELD m_bIfFailedMissionIsAborted : 1;
	BITFIELD m_bMoralityObjective : 1;
	BITFIELD m_bEndOfListOfObjectives : 1;
	BITFIELD m_bShowLog : 1;
	BITFIELD m_bFeedbackOnCompletionSend : 1;
	BITFIELD m_bFeedbackOnFailureSend : 1;
	AActor* m_mgr;
	USound* m_sndSoundSuccess;
	USound* m_sndSoundFailure;
	FString m_szDescription;
	FString m_szDescriptionInMenu;
	FString m_szDescriptionFailure;
	FString m_szMissionObjLocalization;
	FString m_szFeedbackOnCompletion;
	FString m_szFeedbackOnFailure;
	UR6MissionObjectiveBase() {}
};

#pragma pack (pop)
#endif
