/*=============================================================================
	R6AbstractClasses.h: R6Abstract class declarations.
	Reconstructed from Ravenshield 1.56 SDK and Ghidra analysis.

	13 classes: Abstract base classes for the R6 game systems — pawns,
	weapons, gadgets, game info, HUD, bullet managers, corpses, zones,
	noise, game service, and patch service.
=============================================================================*/

#if _MSC_VER
#pragma pack(push, 4)
#endif

#ifndef R6ABSTRACT_API
#define R6ABSTRACT_API DLL_IMPORT
#endif

/*==========================================================================
	AUTOGENERATE_NAME / AUTOGENERATE_FUNCTION entries.
==========================================================================*/

#ifndef NAMES_ONLY
#define AUTOGENERATE_NAME(name) extern R6ABSTRACT_API FName R6ABSTRACT_##name;
#define AUTOGENERATE_FUNCTION(cls,idx,name)
#endif

AUTOGENERATE_NAME(GetSkill)
AUTOGENERATE_NAME(R6MakeNoise)
AUTOGENERATE_NAME(SpawnSelectedGadget)

#ifndef NAMES_ONLY

/*==========================================================================
	Enums.
==========================================================================*/

enum PatchState
{
	PS_Unknown            = 0,
	PS_Initializing       = 1,
	PS_DownloadVersionFile= 2,
	PS_SelectPatch        = 3,
	PS_DownloadPatch      = 4,
	PS_Terminate          = 5,
	PS_RunPatch           = 6,
};

enum ESkills
{
	SKILL_Assault      = 0,
	SKILL_Demolitions  = 1,
	SKILL_Electronics  = 2,
	SKILL_Sniper       = 3,
	SKILL_Stealth      = 4,
	SKILL_SelfControl  = 5,
	SKILL_Leadership   = 6,
	SKILL_Observation  = 7,
};

enum EMissionObjectiveStatus
{
	eMissionObjStatus_none    = 0,
	eMissionObjStatus_success = 1,
	eMissionObjStatus_failed  = 2,
};

/*==========================================================================
	Forward declarations.
==========================================================================*/

class AR6AbstractPawn;
class AR6AbstractGameInfo;
class AR6AbstractBulletManager;
class AR6AbstractWeapon;
class AR6AbstractFirstPersonWeapon;
class AR6MissionObjectiveMgr;
class UR6MissionObjectiveBase;
class UR6MissionDescription;
class UR6ServerInfo;
class AR6Pawn;
class AR6PlayerController;
class AUdpBeacon;

/*==========================================================================
	Reloading — empty struct exported by R6Abstract.
==========================================================================*/

struct R6ABSTRACT_API Reloading
{
};

/*==========================================================================
	UR6AbstractGameService
==========================================================================*/

class R6ABSTRACT_API UR6AbstractGameService : public UObject
{
public:
	DECLARE_CLASS(UR6AbstractGameService, UObject, 0, R6Abstract)

	BITFIELD m_bServerWaitMatchStartReply : 1;
	BITFIELD m_bClientWaitMatchStartReply : 1;
	BITFIELD m_bClientWillSubmitResult : 1;
	BITFIELD m_bWaitSubmitMatchReply : 1;
	BITFIELD m_bMSClientLobbyDisconnect : 1;
	BITFIELD m_bMSClientRouterDisconnect : 1;
	class APlayerController* m_LocalPlayerController;
	FString m_szUserID;

	// UR6AbstractGameService interface — virtual stubs.
	virtual void Created();
	virtual void DisconnectAllCDKeyPlayers();
	virtual void RequestGSCDKeyAuthID();
	virtual void ResetAuthId();
	virtual void ServerRoundFinish();
	virtual void SubmitMatchResult();
	void UnInitializeGSClientSPW();
	virtual INT GetGroupID();
	virtual INT GetLobbyID();
	virtual INT GetLoggedInUbiDotCom();
	virtual INT GetRegServerInitialized();
	virtual INT GetServerRegistered();
	virtual INT InitGSCDKey();
	virtual INT InitGSClient();
	virtual INT IsMSClientIsInRequest();
	virtual INT IsServerJoined();
	virtual INT MSCLientLeaveServer();
	virtual INT SetGSClientComInterface();
	virtual void GSClientPostMessage(BYTE);
	virtual void ProcessIsLobbyDisconnect(FLOAT*);
	virtual void ProcessIsRouterDisconnect(FLOAT*);
	virtual void ProcessJoinServer(FLOAT*);
	virtual void RequestModCDKeyProcess(INT);
	virtual void ServerRoundStart(INT);
	virtual void SetGSGameState(BYTE);
	virtual void SetGameServiceRequestState(BYTE);
	virtual void SetLoginRegServer(BYTE);
	virtual void SetOwnSvrPort(INT);
	virtual void SetRegServerLoginRequest(BYTE);
	virtual BYTE GetGSGameState();
	virtual BYTE GetLoginRegServer();
	virtual void CDKeyDisconnecUser(FString);
	virtual void GameServiceManager(INT, INT, INT, INT);
	virtual void MasterServerManager(AR6AbstractGameInfo*, ALevelInfo*);
	virtual void ProcessLoginMasterSrv(INT, FLOAT*);
	virtual void ProcessUbiComJoinServer(INT, INT, FString, FLOAT*);
	virtual FString GetAuthID(INT);

	// Exec function.
	void execNativeSubmitMatchResult(FFrame& Stack, RESULT_DECL);
};

/*==========================================================================
	UR6AbstractEviLPatchService
==========================================================================*/

class R6ABSTRACT_API UR6AbstractEviLPatchService : public UObject
{
public:
	DECLARE_CLASS(UR6AbstractEviLPatchService, UObject, 0, R6Abstract)

	void SetFunctionPtr(DWORD (CDECL*)(void));

	// Exec function.
	void execGetState(FFrame& Stack, RESULT_DECL);
};

/*==========================================================================
	AR6AbstractHUD
==========================================================================*/

class R6ABSTRACT_API AR6AbstractHUD : public AHUD
{
public:
	DECLARE_CLASS(AR6AbstractHUD, AHUD, 0, R6Abstract)

	INT    m_iCycleHUDLayer;
	BITFIELD m_bToggleHelmet : 1;
	BITFIELD m_bGetRes : 1;
	FLOAT  m_fNewHUDResX;
	FLOAT  m_fNewHUDResY;
	FString m_szStatusDetail;

protected:
	AR6AbstractHUD() {}
};

/*==========================================================================
	AR6AbstractExtractionZone
==========================================================================*/

class R6ABSTRACT_API AR6AbstractExtractionZone : public ANavigationPoint
{
public:
	DECLARE_CLASS(AR6AbstractExtractionZone, ANavigationPoint, 0, R6Abstract)

	virtual void CheckForErrors();
};

/*==========================================================================
	AR6AbstractInsertionZone
==========================================================================*/

class R6ABSTRACT_API AR6AbstractInsertionZone : public APlayerStart
{
public:
	DECLARE_CLASS(AR6AbstractInsertionZone, APlayerStart, 0, R6Abstract)

	INT m_iInsertionNumber;

	virtual void CheckForErrors();
};

/*==========================================================================
	UR6AbstractNoiseMgr
==========================================================================*/

class R6ABSTRACT_API UR6AbstractNoiseMgr : public UObject
{
public:
	DECLARE_CLASS(UR6AbstractNoiseMgr, UObject, 0, R6Abstract)

	void eventR6MakeNoise(BYTE eType, AActor* Source);

protected:
	UR6AbstractNoiseMgr() {}
};

/*==========================================================================
	AR6AbstractFirstPersonWeapon
	Base class: AR6EngineFirstPersonWeapon (from EngineClasses.h).
==========================================================================*/

class R6ABSTRACT_API AR6AbstractFirstPersonWeapon : public AR6EngineFirstPersonWeapon
{
public:
	DECLARE_CLASS(AR6AbstractFirstPersonWeapon, AR6EngineFirstPersonWeapon, 0, R6Abstract)

	BITFIELD m_bWeaponBipodDeployed : 1;
	BITFIELD m_bReloadEmpty : 1;
	AActor*  m_smGun;
	AActor*  m_smGun2;
	FName    m_Empty;
	FName    m_Fire;
	FName    m_FireEmpty;
	FName    m_FireLast;
	FName    m_Neutral;
	FName    m_Reload;
	FName    m_ReloadEmpty;
	FName    m_BipodRaise;
	FName    m_BipodDeploy;
	FName    m_BipodDiscard;
	FName    m_BipodClose;
	FName    m_BipodNeutral;
	FName    m_BipodReload;
	FName    m_BipodReloadEmpty;
	FName    m_WeaponNeutralAnim;

protected:
	AR6AbstractFirstPersonWeapon() {}
};

/*==========================================================================
	AR6AbstractGadget
==========================================================================*/

class R6ABSTRACT_API AR6AbstractGadget : public AActor
{
public:
	DECLARE_CLASS(AR6AbstractGadget, AActor, 0, R6Abstract)

	BYTE     m_eGadgetType;
	AR6EngineWeapon* m_WeaponOwner;
	APawn*   m_OwnerCharacter;
	FName    m_AttachmentName;
	FString  m_NameID;
	FString  m_GadgetName;
	FString  m_GadgetShortName;

	virtual INT* GetOptimizedRepList(BYTE*, struct FPropertyRetirement*, INT*, UPackageMap*, UActorChannel*);
};

/*==========================================================================
	AR6AbstractCorpse
==========================================================================*/

class R6ABSTRACT_API AR6AbstractCorpse : public AActor
{
public:
	DECLARE_CLASS(AR6AbstractCorpse, AActor, 0, R6Abstract)

	virtual void FirstInit(AR6AbstractPawn*);
	virtual void RenderBones(UCanvas*);
	virtual void AddImpulseToBone(INT, FVector);

	void execAddImpulseToBone(FFrame& Stack, RESULT_DECL);
	void execFirstInit(FFrame& Stack, RESULT_DECL);
	void execRenderBones(FFrame& Stack, RESULT_DECL);
};

/*==========================================================================
	AR6AbstractGameInfo
==========================================================================*/

class R6ABSTRACT_API AR6AbstractGameInfo : public AGameInfo
{
public:
	DECLARE_CLASS(AR6AbstractGameInfo, AGameInfo, 0, R6Abstract)

	INT    m_iNbOfRainbowAIToSpawn;
	INT    m_iNbOfTerroristToSpawn;
	INT    m_iDiffLevel;
	INT    m_fTimerStartTime;
	BITFIELD m_bFriendlyFire : 1;
	BITFIELD m_bEndGameIgnoreGamePlayCheck : 1;
	BITFIELD m_bGameOverButAllowDeath : 1;
	BITFIELD m_bTimerStarted : 1;
	BITFIELD m_bInternetSvr : 1;
	FLOAT  m_fEndingTime;
	FLOAT  m_fTimeBetRounds;
	FLOAT  m_fEndVoteTime;
	APlayerController* m_Player;
	UR6AbstractNoiseMgr* m_noiseMgr;
	AR6MissionObjectiveMgr* m_missionMgr;
	APlayerController* m_PlayerKick;
	APlayerController* m_pCurPlayerCtrlMdfSrvInfo;
	AUdpBeacon* m_UdpBeacon;
	FString m_VoteInstigatorName;
	FString m_szDefaultActionPlan;

protected:
	AR6AbstractGameInfo() {}
};

/*==========================================================================
	AR6AbstractBullet
==========================================================================*/

class R6ABSTRACT_API AR6AbstractBullet : public AActor
{
public:
	DECLARE_CLASS(AR6AbstractBullet, AActor, 0, R6Abstract)

protected:
	AR6AbstractBullet() {}
};

/*==========================================================================
	AR6AbstractWeapon
	Base class: AR6EngineWeapon (from EngineClasses.h).
==========================================================================*/

class R6ABSTRACT_API AR6AbstractWeapon : public AR6EngineWeapon
{
public:
	DECLARE_CLASS(AR6AbstractWeapon, AR6EngineWeapon, 0, R6Abstract)

	BITFIELD m_bHiddenWhenNotInUse : 1;
	AR6AbstractGadget*              m_SelectedWeaponGadget;
	AR6AbstractGadget*              m_ScopeGadget;
	AR6AbstractGadget*              m_BipodGadget;
	AR6AbstractGadget*              m_MuzzleGadget;
	AR6AbstractGadget*              m_MagazineGadget;
	AR6AbstractFirstPersonWeapon*   m_FPHands;
	AR6AbstractFirstPersonWeapon*   m_FPWeapon;
	AR6AbstractGadget*              m_FPGadget;
	UClass*                         m_WeaponGadgetClass;
	UClass*                         m_pFPHandsClass;
	UClass*                         m_pFPWeaponClass;

	virtual void PreNetReceive();
	virtual void PostNetReceive();
	void eventSpawnSelectedGadget();
};

/*==========================================================================
	AR6AbstractPawn
==========================================================================*/

class R6ABSTRACT_API AR6AbstractPawn : public APawn
{
public:
	DECLARE_CLASS(AR6AbstractPawn, APawn, 0, R6Abstract)

	BITFIELD bShowLog : 1;

	FLOAT eventGetSkill(BYTE eSkillName);

protected:
	AR6AbstractPawn() {}
};

/*==========================================================================
	AR6MissionObjectiveMgr
==========================================================================*/

class R6ABSTRACT_API AR6MissionObjectiveMgr : public AActor
{
public:
	BYTE   m_eMissionObjectiveStatus;
	BITFIELD m_bShowLog : 1;
	BITFIELD m_bDontUpdateMgr : 1;
	BITFIELD m_bOnSuccessAllObjectivesAreCompleted : 1;
	BITFIELD m_bEnableCheckForErrors : 1;
	AR6AbstractGameInfo* m_GameInfo;
	TArray<UR6MissionObjectiveBase*> m_aMissionObjectives;
};

/*==========================================================================
	AR6AbstractBulletManager
==========================================================================*/

class R6ABSTRACT_API AR6AbstractBulletManager : public AActor
{
public:
};

/*==========================================================================
	AR6AbstractHelmet
==========================================================================*/

class R6ABSTRACT_API AR6AbstractHelmet : public AStaticMeshActor
{
public:
};

#endif // !NAMES_ONLY

#ifndef NAMES_ONLY
#undef AUTOGENERATE_NAME
#undef AUTOGENERATE_FUNCTION
#endif

#if _MSC_VER
#pragma pack(pop)
#endif
