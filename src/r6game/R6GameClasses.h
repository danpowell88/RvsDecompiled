/*=============================================================================
	R6GameClasses.h: R6Game class declarations.
	Reconstructed from Ravenshield 1.56 SDK and Ghidra analysis.
=============================================================================*/

#if _MSC_VER
#pragma pack(push, 4)
#endif

#ifndef R6GAME_API
#define R6GAME_API DLL_IMPORT
#endif

#ifndef NAMES_ONLY
#define AUTOGENERATE_NAME(name) extern R6GAME_API FName R6GAME_##name;
#define AUTOGENERATE_FUNCTION(cls,idx,name)
#endif


#ifndef NAMES_ONLY

class UR6GSServers;
class UR6LanServers;
class UR6Console;
class UR6MObjTimer;
class UR6Campaign;
class AR6TrainingMgr;
class AR6CameraDirection;
class AR6PathFlag;
class AR6ArrowIcon;

enum eLeaveGame{
	 LG_MainMenu=0
	,LG_NextLevel=1
	,LG_Trainning=2
	,LG_MultiPlayerMenu=3
	,LG_RetryPlanningCustomMission=4
	,LG_CustomMissionMenu=5
	,LG_RetryPlanningCampaign=6
	,LG_QuitGame=7
	,LG_MultiPlayerError=8
	,LG_InitMod=9
};

enum ETrainingWeapons{
	 TW_SMG=0
	,TW_Pistol=1
	,TW_Sniper=2
	,TW_HBSensor=3
	,TW_Assault=4
	,TW_AssaultSilenced=5
	,TW_LMG=6
	,TW_Shotgun=7
	,TW_Grenades=8
	,TW_BreachCharge=9
	,TW_RemoteCharge=10
	,TW_Claymore=11
	,TW_MAX=12
};

struct PostBetweenRoundTime
{
};

struct InBetweenRoundMenu
{
};

struct TrainingInstruction
{
};

struct Game
{
};

struct FSTPawnMovement
{
public:
	FLOAT fStandSlow;
	FLOAT fStandFast;
	FLOAT fCrouchSlow;
	FLOAT fCrouchFast;
	FLOAT fProne;
	BYTE eType;
};

struct FSTSound
{
public:
	FLOAT fSndDist;
	BYTE eType;
};

struct FollowPlan
{
};

struct FollowPath
{
};

class R6GAME_API AR6GameInfo : public AR6AbstractGameInfo
{
public:
	DECLARE_CLASS(AR6GameInfo, AR6AbstractGameInfo, 0, R6Game)

	BYTE R6DefaultWeaponInput;
	BYTE m_eEndGameWidgetID;
	BYTE m_bCurrentFemaleId;
	BYTE m_bCurrentMaleId;
	BYTE m_bRainbowFaces[30];
	INT m_iCurrentID;
	INT m_iMaxOperatives;
	INT m_iJumpMapIndex;
	INT m_iRoundsPerMatch;
	INT m_iDeathCameraMode;
	INT m_iSubMachineGunsResMask;
	INT m_iShotGunResMask;
	INT m_iAssRifleResMask;
	INT m_iMachGunResMask;
	INT m_iSnipRifleResMask;
	INT m_iPistolResMask;
	INT m_iMachPistolResMask;
	INT m_iGadgPrimaryResMask;
	INT m_iGadgSecondaryResMask;
	INT m_iGadgMiscResMask;
	INT m_iNbOfRestart;
	INT m_iIDVoicesMgr;
	INT m_iUbiComGameMode;
	BITFIELD bShowLog : 1;
	BITFIELD bNoRestart : 1;
	BITFIELD m_bServerAllowRadarRep : 1;
	BITFIELD m_bRepAllowRadarOption : 1;
	BITFIELD m_bIsRadarAllowed : 1;
	BITFIELD m_bIsWritableMapAllowed : 1;
	BITFIELD m_bUsingPlayerCampaign : 1;
	BITFIELD m_bUsingCampaignBriefing : 1;
	BITFIELD m_bUnlockAllDoors : 1;
	BITFIELD m_bJumpingMaps : 1;
	BITFIELD m_bAutoBalance : 1;
	BITFIELD m_bTKPenalty : 1;
	BITFIELD m_bPWSubMachGunRes : 1;
	BITFIELD m_bPWShotGunRes : 1;
	BITFIELD m_bPWAssRifleRes : 1;
	BITFIELD m_bPWMachGunRes : 1;
	BITFIELD m_bPWSnipRifleRes : 1;
	BITFIELD m_bSWPistolRes : 1;
	BITFIELD m_bSWMachPistolRes : 1;
	BITFIELD m_bGadgPrimaryRes : 1;
	BITFIELD m_bGadgSecondayRes : 1;
	BITFIELD m_bGadgMiscRes : 1;
	BITFIELD m_bShowNames : 1;
	BITFIELD m_bFFPWeapon : 1;
	BITFIELD m_bAdminPasswordReq : 1;
	BITFIELD m_bAIBkp : 1;
	BITFIELD m_bRotateMap : 1;
	BITFIELD m_bFadeStarted : 1;
	BITFIELD m_bFeedbackHostageKilled : 1;
	BITFIELD m_bFeedbackHostageExtracted : 1;
	BITFIELD m_bStopPostBetweenRoundCountdown : 1;
	FLOAT m_fRoundStartTime;
	FLOAT m_fRoundEndTime;
	FLOAT m_fPausedAtTime;
	FLOAT m_fBombTime;
	FLOAT m_fInGameStartTime;
	UR6CommonRainbowVoices* m_CommonRainbowPlayerVoicesMgr;
	UR6CommonRainbowVoices* m_CommonRainbowMemberVoicesMgr;
	UR6RainbowPlayerVoices* m_RainbowPlayerVoicesMgr;
	UR6RainbowMemberVoices* m_RainbowMemberVoicesMgr;
	UR6MultiCoopVoices* m_MultiCoopMemberVoicesMgr;
	UR6PreRecordedMsgVoices* m_PreRecordedMsgVoicesMgr;
	UR6MultiCommonVoices* m_MultiCommonVoicesMgr;
	ANavigationPoint* LastStartSpot;
	UR6GSServers* m_GameService;
	UR6GSServers* m_PersistantGameService;
	UMaterial* DefaultFaceTexture;
	UClass* m_HudClass;
	TArray<UR6RainbowOtherTeamVoices*> m_RainbowOtherTeamVoicesMgr;
	TArray<UR6MultiCoopVoices*> m_MultiCoopPlayerVoicesMgr;
	TArray<UR6TerroristVoices*> m_TerroristVoicesMgr;
	TArray<UR6HostageVoices*> m_HostageVoicesMaleMgr;
	TArray<UR6HostageVoices*> m_HostageVoicesFemaleMgr;
	TArray<AR6Terrorist*> m_listAllTerrorists;
	TArray<AR6RainbowAI*> m_RainbowAIBackup;
	TArray<FString> m_mapList;
	TArray<FString> m_gameModeList;
	FPlane DefaultFaceCoords;
	FString m_szMessageOfDay;
	FString m_szSvrName;

	virtual void PostBeginPlay();
	virtual void InitGameInfoGameService();
	virtual void MasterServerManager();
	virtual void AbortScoreSubmission();
	void execGetSystemUserName(struct FFrame &, void * const);
	void execInitScoreSubmission(struct FFrame &, void * const);
	void execLogoutUpdatePlayersCtrlInfo(struct FFrame &, void * const);
	void execNativeLogout(struct FFrame &, void * const);
	void execSetController(struct FFrame &, void * const);
	void execSubmissionNotifySendStartMatch(struct FFrame &, void * const);
	void execSubmissionSrvRoundFinish(struct FFrame &, void * const);
	void execSubmissionSrvRoundStart(struct FFrame &, void * const);
	void execSubmissionUpdateLadderStat(struct FFrame &, void * const);

	AR6GameInfo() {}
};

class R6GAME_API AR6StoryModeGame : public AR6GameInfo
{
public:

protected:
	AR6StoryModeGame() {}
};

class R6GAME_API UR6Operative : public UObject
{
public:
	DECLARE_CLASS(UR6Operative, UObject, 0, R6Game)

	INT m_iUniqueID;
	INT m_iRookieID;
	INT m_RMenuFaceX;
	INT m_RMenuFaceY;
	INT m_RMenuFaceW;
	INT m_RMenuFaceH;
	INT m_RMenuFaceSmallX;
	INT m_RMenuFaceSmallY;
	INT m_RMenuFaceSmallW;
	INT m_RMenuFaceSmallH;
	INT m_iHealth;
	INT m_iNbMissionPlayed;
	INT m_iTerrokilled;
	INT m_iRoundsfired;
	INT m_iRoundsOntarget;
	FLOAT m_fAssault;
	FLOAT m_fDemolitions;
	FLOAT m_fElectronics;
	FLOAT m_fSniper;
	FLOAT m_fStealth;
	FLOAT m_fSelfControl;
	FLOAT m_fLeadership;
	FLOAT m_fObservation;
	UTexture* m_TMenuFace;
	UTexture* m_TMenuFaceSmall;
	FName m_CanUseArmorType;
	TArray<UTexture*> m_OperativeFaces;
	FString m_szOperativeClass;
	FString m_szCountryID;
	FString m_szCityID;
	FString m_szStateID;
	FString m_szSpecialityID;
	FString m_szHairColorID;
	FString m_szEyesColorID;
	FString m_szGenderID;
	FString m_szGender;
	FString m_szPrimaryWeapon;
	FString m_szPrimaryWeaponGadget;
	FString m_szPrimaryWeaponBullet;
	FString m_szPrimaryGadget;
	FString m_szSecondaryWeapon;
	FString m_szSecondaryWeaponGadget;
	FString m_szSecondaryWeaponBullet;
	FString m_szSecondaryGadget;
	FString m_szArmor;

	void TransferFile(FArchive &);

	UR6Operative() {}
};

class R6GAME_API AR6SoundVolume : public AVolume
{
public:
	DECLARE_CLASS(AR6SoundVolume, AVolume, 0, R6Game)

	BYTE m_eSoundSlot;
	TArray<USound*> m_EntrySound;
	TArray<USound*> m_ExitSound;


protected:
	AR6SoundVolume() {}
};

class R6GAME_API UR6MObjAcceptableLosses : public UR6MissionObjectiveBase
{
public:
	BYTE m_ePawnTypeKiller;
	BYTE m_ePawnTypeDead;
	INT m_iAcceptableLost;
	INT m_iKillerTeamID;
	BITFIELD m_bConsiderSuicide : 1;


protected:
	UR6MObjAcceptableLosses() {}
};

class R6GAME_API AR6PracticeModeGame : public AR6StoryModeGame
{
public:

protected:
	AR6PracticeModeGame() {}
};

class R6GAME_API AR6PlanningRangeGrenade : public AR6ReferenceIcons
{
public:

protected:
	AR6PlanningRangeGrenade() {}
};

class R6GAME_API AR6HUD : public AR6AbstractHUD
{
public:
	DECLARE_CLASS(AR6HUD, AR6AbstractHUD, 0, R6Game)

	BYTE m_eLastMovementMode;
	BYTE m_eLastTeamState;
	BYTE m_eLastOtherTeamState[2];
	BYTE m_eLastPlayerAPAction;
	BYTE m_eLastGoCode;
	INT m_iBulletCount;
	INT m_iMaxBulletCount;
	INT m_iMagCount;
	INT m_iCurrentMag;
	BITFIELD m_bDrawHUDinScript : 1;
	BITFIELD m_bGMIsSinglePlayer : 1;
	BITFIELD m_bGMIsCoop : 1;
	BITFIELD m_bGMIsTeamAdverserial : 1;
	BITFIELD m_bShowCharacterInfo : 1;
	BITFIELD m_bShowCurrentTeamInfo : 1;
	BITFIELD m_bShowOtherTeamInfo : 1;
	BITFIELD m_bShowWeaponInfo : 1;
	BITFIELD m_bShowFPWeapon : 1;
	BITFIELD m_bShowWaypointInfo : 1;
	BITFIELD m_bShowActionIcon : 1;
	BITFIELD m_bShowMPRadar : 1;
	BITFIELD m_bShowTeamMatesNames : 1;
	BITFIELD m_bUpdateHUDInTraining : 1;
	BITFIELD m_bDisplayTimeBomb : 1;
	BITFIELD m_bDisplayRemainingTime : 1;
	BITFIELD m_bNoDeathCamera : 1;
	BITFIELD m_bLastSniperHold : 1;
	BITFIELD m_bShowPressGoCode : 1;
	BITFIELD m_bPressGoCodeCanBlink : 1;
	FLOAT m_fPosX;
	FLOAT m_fPosY;
	FLOAT m_fScaleX;
	FLOAT m_fScaleY;
	FLOAT m_fScale;
	AR6GameReplicationInfo* m_GameRepInfo;
	AR6PlayerController* m_PlayerOwner;
	UTexture* m_FlashbangFlash;
	UTexture* m_TexNightVision;
	UTexture* m_TexHeatVision;
	UMaterial* m_TexHeatVisionActor;
	UMaterial* m_TexHUDElements;
	UMaterial* m_pCurrentMaterial;
	UTexture* m_HeartBeatMaskMul;
	UTexture* m_HeartBeatMaskAdd;
	UTexture* m_Waypoint;
	UTexture* m_WaypointArrow;
	UTexture* m_InGamePlanningPawnIcon;
	UTexture* m_LoadingScreen;
	UTexture* m_TexNoise;
	UMaterial* m_TexProneTrail;
	UFinalBlend* m_pAlphaBlend;
	AActor* m_pNextWayPoint;
	UMaterial* m_TexRadarTextures[10];
	AR6RainbowTeam* m_pLastRainbowTeam;
	TArray<AR6IOBomb*> m_aIOBombs;
	FColor m_iCurrentTeamColor;
	FColor m_CharacterInfoBoxColor;
	FColor m_CharacterInfoOutlineColor;
	FColor m_WeaponBoxColor;
	FColor m_WeaponOutlineColor;
	FColor m_TeamBoxColor;
	FColor m_TeamBoxOutlineColor;
	FColor m_OtherTeamBoxColor;
	FColor m_OtherTeamOutlineColor;
	FColor m_WPIconBox;
	FColor m_WPIconOutlineColor;
	FR6HUDState m_HUDElements[16];
	FString m_szMovementMode;
	FString m_szTeamState;
	FString m_szOtherTeamState[2];
	FString m_aszOtherTeamName[2];
	FString m_szLastPlayerAPAction;
	FString m_szPressGoCode;
	FString m_szTeam;

	virtual void Destroy();
	virtual void Serialize(FArchive &);
	virtual void Spawned();
	virtual void DrawRadar(FCameraSceneNode *, UViewport *);
	virtual void DrawInGameMap(FCameraSceneNode *, UViewport *);
	void execDrawNativeHUD(struct FFrame &, void * const);
	void execHudStep(struct FFrame &, void * const);
	void DisplayOtherTeamInfo(FCanvasUtil &, UCanvas *, INT, AR6RainbowTeam *, FColor &, INT);
	void DrawCharacterInfo(AR6Rainbow *, FLOAT, FLOAT, FColor &, FCanvasUtil *, UCanvas *);
	void DrawSingleCharacterInfo(AR6Rainbow *, FLOAT, FLOAT, FColor &, FCanvasUtil *, UCanvas *);
	void UpdateHUDColors(FColor);

	AR6HUD() {}
};

class R6GAME_API UR6GameManager : public UR6AbstractGameManager
{
public:
	DECLARE_CLASS(UR6GameManager, UR6AbstractGameManager, 0, R6Game)

	UR6GSServers* m_GameMgrGameService;
	UR6Console* m_GameMgrConsole;

	virtual void InitializeGameService(UConsole *);
	virtual void UnInitialize();
	virtual void GameServiceTick(UConsole *);
	virtual void ConnectionInterrupted(INT);
	virtual void ClientLeaveServer();
	virtual void LaunchListenSrv(FString, FString);
	virtual void StartJoinServer(FString, FString, INT);
	virtual void StartPreJoinProcedure(INT);
	virtual INT StartLogInProcedure();
	virtual void SetGSCreateUbiServer(INT);
	virtual INT GetGSCreateUbiServer();
	void DoConsoleCommand(FString, UConsole *);
	void GSClientManager(UConsole *);
	void InitializeGSClient();
	void MSClientManager(UConsole *);
	void MinimizeAndPauseMusic(UConsole *);

	UR6GameManager() {}
};

class R6GAME_API AR6MultiPlayerGameInfo : public AR6GameInfo
{
public:
	DECLARE_CLASS(AR6MultiPlayerGameInfo, AR6GameInfo, 0, R6Game)

	BITFIELD m_TeamSelectionLocked : 1;
	FLOAT m_fNextCheckPlayerReadyTime;
	FLOAT m_fLastUpdateTime;
	UR6MObjTimer* m_missionObjTimer;
	USound* m_sndSoundTimeFailure;


protected:
	AR6MultiPlayerGameInfo() {}
};

class R6GAME_API AR6WaterVolume : public AR6SoundVolume
{
public:
	DECLARE_CLASS(AR6WaterVolume, AR6SoundVolume, 0, R6Game)


protected:
	AR6WaterVolume() {}
};

class R6GAME_API AR6InstructionSoundVolume : public AR6SoundVolume
{
public:
	DECLARE_CLASS(AR6InstructionSoundVolume, AR6SoundVolume, 0, R6Game)

	INT m_iBoxNumber;
	INT m_iSoundIndex;
	INT m_iHudStep;
	INT m_IDHudStep;
	INT m_fTimerStep;
	BITFIELD m_bSoundIsPlaying : 1;
	FLOAT m_fTime;
	FLOAT m_fTimerSound;
	FLOAT m_fTimeHud;
	USound* m_sndIntructionSoundStop;
	AR6TrainingMgr* m_TrainingMgr;

	void execUseSound(struct FFrame &, void * const);

protected:
	AR6InstructionSoundVolume() {}
};

class R6GAME_API UR6MissionRoster : public UObject
{
public:
	DECLARE_CLASS(UR6MissionRoster, UObject, 0, R6Game)

	TArray<UR6Operative*> m_MissionOperatives;

	void TransferFile(FArchive &);

	UR6MissionRoster() {}
};

class R6GAME_API UR6PlayerCampaign : public UObject
{
public:
	DECLARE_CLASS(UR6PlayerCampaign, UObject, 0, R6Game)

	BYTE m_bCampaignCompleted;
	INT m_iDifficultyLevel;
	INT m_iNoMission;
	UR6MissionRoster* m_OperativesMissionDetails;
	FString m_FileName;
	FString m_CampaignFileName;


protected:
	UR6PlayerCampaign() {}
};

class R6GAME_API UR6FileManagerCampaign : public UR6FileManager
{
public:
	DECLARE_CLASS(UR6FileManagerCampaign, UR6FileManager, 0, R6Game)

	void execLoadCampaign(struct FFrame &, void * const);
	void execSaveCampaign(struct FFrame &, void * const);

protected:
	UR6FileManagerCampaign() {}
};

class R6GAME_API UR6FileManagerPlanning : public UR6FileManager
{
public:
	DECLARE_CLASS(UR6FileManagerPlanning, UR6FileManager, 0, R6Game)

	INT m_iCurrentTeam;

	void execGetNumberOfFiles(struct FFrame &, void * const);
	void execLoadPlanning(struct FFrame &, void * const);
	void execSavePlanning(struct FFrame &, void * const);

protected:
	UR6FileManagerPlanning() {}
};

class R6GAME_API UR6PlanningInfo : public UR6AbstractPlanningInfo
{
public:
	DECLARE_CLASS(UR6PlanningInfo, UR6AbstractPlanningInfo, 0, R6Game)

	virtual void AddPoint(AActor *);
	virtual void TransferFile(FArchive &);
	virtual AActor * GetTeamLeader();
	void execAddToTeam(struct FFrame &, void * const);
	void execDeletePoint(struct FFrame &, void * const);
	void execFindPathToNextPoint(struct FFrame &, void * const);
	void execInsertToTeam(struct FFrame &, void * const);
	INT NoStairsBetweenPoints(AActor *);

	UR6PlanningInfo() {}
};

class R6GAME_API AR6PlanningCtrl : public APlayerController
{
public:
	DECLARE_CLASS(AR6PlanningCtrl, APlayerController, 0, R6Game)

	INT m_iCurrentTeam;
	INT m_3DWindowPositionX;
	INT m_3DWindowPositionY;
	INT m_3DWindowPositionW;
	INT m_3DWindowPositionH;
	INT m_iLevelDisplay;
	BITFIELD m_bRender3DView : 1;
	BITFIELD m_bMove3DView : 1;
	BITFIELD m_bActionPointSelected : 1;
	BITFIELD m_bCanMoveFirstPoint : 1;
	BITFIELD m_bClickToFindLocation : 1;
	BITFIELD m_bClickedOnRange : 1;
	BITFIELD m_bSetSnipeDirection : 1;
	BITFIELD m_bPlayMode : 1;
	BITFIELD m_bLockCamera : 1;
	BITFIELD bShowLog : 1;
	BITFIELD m_bFirstTick : 1;
	FLOAT m_fLastMouseX;
	FLOAT m_fLastMouseY;
	FLOAT m_fZoom;
	FLOAT m_fZoomDelta;
	FLOAT m_fZoomRate;
	FLOAT m_fZoomMin;
	FLOAT m_fZoomMax;
	FLOAT m_fZoomFactor;
	FLOAT m_fCameraAngle;
	FLOAT m_fAngleRate;
	FLOAT m_fAngleMax;
	FLOAT m_fRotateDelta;
	FLOAT m_fRotateRate;
	FLOAT m_fCamRate;
	FLOAT m_fCastingHeight;
	FLOAT m_fDebugRangeScale;
	UR6PlanningInfo* m_pTeamInfo[3];
	UR6FileManagerPlanning* m_pFileManager;
	AR6CameraDirection* m_pCameraDirIcon;
	AActor* m_pOldHitActor;
	UTexture* m_pIconTex[12];
	AActor* m_CamSpot;
	USound* m_PlanningBadClickSnd;
	USound* m_PlanningGoodClickSnd;
	USound* m_PlanningRemoveSnd;
	FVector m_vCurrentCameraPos;
	FVector m_vCamPos;
	FVector m_vCamPosNoRot;
	FVector m_vCamDesiredPos;
	FRotator m_rCamRot;
	FVector m_vCamDelta;
	FVector m_vMinLocation;
	FVector m_vMaxLocation;

	void execGetClickResult(struct FFrame &, void * const);
	void execGetXYPoint(struct FFrame &, void * const);
	void execPlanningTrace(struct FFrame &, void * const);

protected:
	AR6PlanningCtrl() {}
};

class R6GAME_API AR6ActionPoint : public AR6ActionPointAbstract
{
public:
	DECLARE_CLASS(AR6ActionPoint, AR6ActionPointAbstract, 0, R6Game)

	BYTE m_eMovementMode;
	BYTE m_eMovementSpeed;
	BYTE m_eAction;
	BYTE m_eActionType;
	INT m_iRainbowTeamName;
	INT m_iMileStoneNum;
	INT m_iNodeID;
	INT m_iInitialMousePosX;
	INT m_iInitialMousePosY;
	BITFIELD m_bActionCompleted : 1;
	BITFIELD m_bActionPointReached : 1;
	BITFIELD m_bDoorInRange : 1;
	BITFIELD bShowLog : 1;
	UTexture* m_pCurrentTexture;
	UTexture* m_pSelected;
	AR6IORotatingDoor* pDoor;
	AR6PlanningCtrl* m_pPlanningCtrl;
	AR6PathFlag* m_pMyPathFlag;
	AR6ReferenceIcons* m_pActionIcon;
	FColor m_CurrentColor;
	FVector m_vActionDirection;
	FRotator m_rActionRotation;

	void SetRotationToward(FVector);
	void TransferFile(FArchive &);

	AR6ActionPoint() {}
};

class R6GAME_API UR6PlayerCustomMission : public UObject
{
public:
	DECLARE_CLASS(UR6PlayerCustomMission, UObject, 0, R6Game)

	TArray<FString> m_aCampaignFileName;
	TArray<INT> m_iNbMapUnlock;


protected:
	UR6PlayerCustomMission() {}
};

class R6GAME_API UR6Console : public UWindowConsole
{
public:
	BYTE m_eNextStep;
	INT m_iLastCheckTime;
	INT m_iLastSuccCheckTime;
	BITFIELD bResetLevel : 1;
	BITFIELD bLaunchWasCalled : 1;
	BITFIELD bLaunchMultiPlayer : 1;
	BITFIELD bReturnToMenu : 1;
	BITFIELD bCancelFire : 1;
	BITFIELD m_bInGamePlanningKeyDown : 1;
	BITFIELD m_bSkipAFrameAndStart : 1;
	BITFIELD m_bRenderMenuOneTime : 1;
	BITFIELD m_bStartR6GameInProgress : 1;
	UR6Campaign* m_CurrentCampaign;
	UR6PlayerCampaign* m_PlayerCampaign;
	UR6GSServers* m_GameService;
	UR6LanServers* m_LanServers;
	UR6PlayerCustomMission* m_playerCustomMission;
	USound* m_StopMainMenuMusic;
	TArray<UR6Campaign*> m_aCampaigns;
	TArray<UR6MissionDescription*> m_aMissionDescriptions;
	TArray<BYTE> m_AWIDList;
	FString m_szLastError;
	FString szStoreGamePassWd;


protected:
	UR6Console() {}
};

class R6GAME_API UR6Campaign : public UObject
{
public:
	TArray<FString> missions;
	TArray<UR6MissionDescription*> m_missions;
	TArray<FString> m_OperativeClassName;
	TArray<FString> m_OperativeBackupClassName;
	FString m_szCampaignFile;
	FString LocalizationFile;


protected:
	UR6Campaign() {}
};

class R6GAME_API UR6RookieAssault : public UR6Operative
{
public:

protected:
	UR6RookieAssault() {}
};

class R6GAME_API UR6MObjAcceptableCivilianLossesByRainbow : public UR6MObjAcceptableLosses
{
public:

protected:
	UR6MObjAcceptableCivilianLossesByRainbow() {}
};

class R6GAME_API UR6MObjAcceptableCivilianLossesByTerro : public UR6MObjAcceptableLosses
{
public:

protected:
	UR6MObjAcceptableCivilianLossesByTerro() {}
};

class R6GAME_API UR6MObjAcceptableHostageLossesByRainbow : public UR6MObjAcceptableLosses
{
public:

protected:
	UR6MObjAcceptableHostageLossesByRainbow() {}
};

class R6GAME_API UR6MObjAcceptableHostageLossesByTerro : public UR6MObjAcceptableLosses
{
public:

protected:
	UR6MObjAcceptableHostageLossesByTerro() {}
};

class R6GAME_API UR6MObjAcceptableRainbowLosses : public UR6MObjAcceptableLosses
{
public:

protected:
	UR6MObjAcceptableRainbowLosses() {}
};

class R6GAME_API AR6ExtractionZone : public AR6AbstractExtractionZone
{
public:

protected:
	AR6ExtractionZone() {}
};

class R6GAME_API UR6NoiseMgr : public UR6AbstractNoiseMgr
{
public:
	BITFIELD bShowLog : 1;
	FSTSound m_SndBulletImpact;
	FSTSound m_SndBulletRicochet;
	FSTSound m_SndGrenadeImpact;
	FSTSound m_SndGrenadeLike;
	FSTSound m_sndExplosion;
	FSTSound m_SndChoking;
	FSTSound m_SndTalking;
	FSTSound m_SndScreaming;
	FSTSound m_SndReload;
	FSTSound m_SndEquipping;
	FSTSound m_SndDead;
	FSTSound m_SndDoor;
	FSTPawnMovement m_Rainbow;
	FSTPawnMovement m_Terro;
	FSTPawnMovement m_Hostage;


protected:
	UR6NoiseMgr() {}
};

class R6GAME_API AR6TrainingMgr : public AR6PracticeModeGame
{
public:
	BYTE m_eCurrentWeapon;
	INT m_WeaponsSlot[12];
	BITFIELD m_bInitialized : 1;
	AR6EngineWeapon* m_Weapons[12];
	FString m_WeaponsName[12];


protected:
	AR6TrainingMgr() {}
};

class R6GAME_API AR6InsertionZone : public AR6AbstractInsertionZone
{
public:

protected:
	AR6InsertionZone() {}
};

class R6GAME_API AR6PlanningPawn : public AR6Pawn
{
public:
	FLOAT m_fSpeed;
	AR6ArrowIcon* m_ArrowInPlanningView;
	UR6PlanningInfo* m_PlanToFollow;
	AActor* m_pActorToReach;
	FRotator m_rDirRot;


protected:
	AR6PlanningPawn() {}
};

class R6GAME_API AR6CameraDirection : public AR6ReferenceIcons
{
public:

protected:
	AR6CameraDirection() {}
};

class R6GAME_API AR6ArrowIcon : public AR6ReferenceIcons
{
public:
	FVector m_vPointToReach;
	FVector m_vStartLocation;


protected:
	AR6ArrowIcon() {}
};

class R6GAME_API UR6PlanningPlayerInput : public UPlayerInput
{
public:

protected:
	UR6PlanningPlayerInput() {}
};

class R6GAME_API AR6PlanningSnipe : public AR6ReferenceIcons
{
public:

protected:
	AR6PlanningSnipe() {}
};

class R6GAME_API AR6PathFlag : public AR6ReferenceIcons
{
public:
	UTexture* m_pIconTex[3];


protected:
	AR6PathFlag() {}
};

class R6GAME_API AR6PlanningGrenade : public AR6ReferenceIcons
{
public:
	UTexture* m_pIconTex[4];


protected:
	AR6PlanningGrenade() {}
};

class R6GAME_API AR6PlanningRangeFragGrenade : public AR6PlanningRangeGrenade
{
public:

protected:
	AR6PlanningRangeFragGrenade() {}
};

class R6GAME_API AR6PlanningBreach : public AR6ReferenceIcons
{
public:

protected:
	AR6PlanningBreach() {}
};

class R6GAME_API UR6MObjTimer : public UR6MissionObjectiveBase
{
public:

protected:
	UR6MObjTimer() {}
};

class R6GAME_API UR6RookieSniper : public UR6Operative
{
public:

protected:
	UR6RookieSniper() {}
};

class R6GAME_API UR6RookieDemolitions : public UR6Operative
{
public:

protected:
	UR6RookieDemolitions() {}
};

class R6GAME_API UR6RookieElectronics : public UR6Operative
{
public:

protected:
	UR6RookieElectronics() {}
};

class R6GAME_API UR6RookieRecon : public UR6Operative
{
public:

protected:
	UR6RookieRecon() {}
};

class R6GAME_API AR6BroadcastHandler : public ABroadcastHandler
{
public:
	BITFIELD m_bShowLog : 1;


protected:
	AR6BroadcastHandler() {}
};

class R6GAME_API UR6Operative29 : public UR6Operative
{
public:

protected:
	UR6Operative29() {}
};

class R6GAME_API UR6Operative28 : public UR6Operative
{
public:

protected:
	UR6Operative28() {}
};

class R6GAME_API UR6Operative27 : public UR6Operative
{
public:

protected:
	UR6Operative27() {}
};

class R6GAME_API UR6Operative26 : public UR6Operative
{
public:

protected:
	UR6Operative26() {}
};

class R6GAME_API UR6Operative25 : public UR6Operative
{
public:

protected:
	UR6Operative25() {}
};

class R6GAME_API UR6Operative24 : public UR6Operative
{
public:

protected:
	UR6Operative24() {}
};

class R6GAME_API UR6Operative23 : public UR6Operative
{
public:

protected:
	UR6Operative23() {}
};

class R6GAME_API UR6Operative22 : public UR6Operative
{
public:

protected:
	UR6Operative22() {}
};

class R6GAME_API UR6Operative21 : public UR6Operative
{
public:

protected:
	UR6Operative21() {}
};

class R6GAME_API UR6Operative20 : public UR6Operative
{
public:

protected:
	UR6Operative20() {}
};

class R6GAME_API UR6Operative19 : public UR6Operative
{
public:

protected:
	UR6Operative19() {}
};

class R6GAME_API UR6Operative18 : public UR6Operative
{
public:

protected:
	UR6Operative18() {}
};

class R6GAME_API UR6Operative17 : public UR6Operative
{
public:

protected:
	UR6Operative17() {}
};

class R6GAME_API UR6Operative16 : public UR6Operative
{
public:

protected:
	UR6Operative16() {}
};

class R6GAME_API UR6Operative15 : public UR6Operative
{
public:

protected:
	UR6Operative15() {}
};

class R6GAME_API UR6Operative14 : public UR6Operative
{
public:

protected:
	UR6Operative14() {}
};

class R6GAME_API UR6Operative13 : public UR6Operative
{
public:

protected:
	UR6Operative13() {}
};

class R6GAME_API UR6Operative12 : public UR6Operative
{
public:

protected:
	UR6Operative12() {}
};

class R6GAME_API UR6Operative11 : public UR6Operative
{
public:

protected:
	UR6Operative11() {}
};

class R6GAME_API UR6Operative10 : public UR6Operative
{
public:

protected:
	UR6Operative10() {}
};

class R6GAME_API UR6Operative9 : public UR6Operative
{
public:

protected:
	UR6Operative9() {}
};

class R6GAME_API UR6Operative8 : public UR6Operative
{
public:

protected:
	UR6Operative8() {}
};

class R6GAME_API UR6Operative7 : public UR6Operative
{
public:

protected:
	UR6Operative7() {}
};

class R6GAME_API UR6Operative6 : public UR6Operative
{
public:

protected:
	UR6Operative6() {}
};

class R6GAME_API UR6Operative5 : public UR6Operative
{
public:

protected:
	UR6Operative5() {}
};

class R6GAME_API UR6Operative4 : public UR6Operative
{
public:

protected:
	UR6Operative4() {}
};

class R6GAME_API UR6Operative3 : public UR6Operative
{
public:

protected:
	UR6Operative3() {}
};

class R6GAME_API UR6Operative2 : public UR6Operative
{
public:

protected:
	UR6Operative2() {}
};

class R6GAME_API UR6Operative1 : public UR6Operative
{
public:

protected:
	UR6Operative1() {}
};

class R6GAME_API UR6MObjNeutralizeTerrorist : public UR6MissionObjectiveBase
{
public:
	INT m_iNeutralizePercentage;
	BITFIELD m_bMustSecureTerroInDepZone : 1;
	AR6DeploymentZone* m_depZone;


protected:
	UR6MObjNeutralizeTerrorist() {}
};

class R6GAME_API AR6PlanningHUD : public AHUD
{
public:

protected:
	AR6PlanningHUD() {}
};

#endif // !NAMES_ONLY

#ifndef NAMES_ONLY
#undef AUTOGENERATE_NAME
#undef AUTOGENERATE_FUNCTION
#endif

#if _MSC_VER
#pragma pack(pop)
#endif
