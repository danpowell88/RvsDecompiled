/*=============================================================================
	R6EngineClasses.h: R6Engine class declarations.
	Reconstructed from Ravenshield 1.56 SDK and Ghidra analysis.

	50 classes: Core game engine — pawns, AI, interactive objects,
	deployment zones, doors, ragdolls, climbing, stairs, team management.
=============================================================================*/

#if _MSC_VER
#pragma pack(push, 4)
#endif

#ifndef R6ENGINE_API
#define R6ENGINE_API DLL_IMPORT
#endif

// Forward declarations — Engine rendering types (only used as pointers)
class FLevelSceneNode;
class FRenderInterface;
class FDynamicActor;

// Forward declarations — R6Engine classes used before definition
class AR6AIController;
class UR6InteractiveObjectAction;
class AR6Pawn;
class AR6Terrorist;
class AR6Hostage;
class AR6DeploymentZone;
class AR6Ladder;
class AR6Door;
class AR6ClimbableObject;
class AR6ArmPatchGlow;
class AR6TeamMemberReplicationInfo;
class AR6SoundReplicationInfo;
class AR6DZonePathNode;
class AR6HostageMgr;
class AR6HostageAI;
class AR6Rainbow;
class AR6IORotatingDoor;
class AR6GasMask;
class AR6AbstractHelmet;
class AR6NightVision;
class AR6THeadAttachment;
class AR6RainbowTeam;
class AR6LadderCollision;
class AR6StairOrientation;
class AR6DZoneRandomPoints;
class AR6DZonePath;
class UR6RainbowPlayerVoices;
class UR6RainbowMemberVoices;
class UR6RainbowOtherTeamVoices;
class UR6MultiCommonVoices;
class UR6MultiCoopVoices;
class UR6PreRecordedMsgVoices;
class AR6CircumstantialActionQuery;
class UR6InteractionCircumstantialAction;
class UR6InteractionInventoryMnu;
class AR6IOSelfDetonatingBomb;
class UR6GameMenuCom;
class UR6GameColors;
class UR6GameOptions;
class AR6PlayerController;
class UR6CommonRainbowVoices;
class UInteractionMaster;
class AR6TerroristAI;

// Forward declarations — opaque types (pointers/params only)
class UStaticMesh;
class FR6CharTemplate;
enum eBodyPart;

// stResultTable — ballistic damage result table with 3 thresholds.
// Used by R6Charts to determine hit outcomes per body-part group.
// Layout recovered from Ghidra: 3 INT thresholds accessed at offsets 0, 4, 8.
#ifndef _STRESULTTABLE_DEFINED
#define _STRESULTTABLE_DEFINED
struct stResultTable
{
	INT Threshold1;
	INT Threshold2;
	INT Threshold3;
	INT Pad;
};
#endif

// stBodyPart — body-part group damage table used as static member of R6Charts.
// Contains one stResultTable per body-part group:
//   [0] = Head (BP_Head)
//   [1] = Torso (BP_Chest, BP_Abdomen)
//   [2] = Limbs (BP_Legs, BP_Arms)
// Total size: 48 bytes (3 * 16). Verified from retail symbol table gaps.
#ifndef _STBODYPART_DEFINED
#define _STBODYPART_DEFINED
struct stBodyPart
{
	stResultTable BodyPartGroup[3];
};
#endif

// FRange — Core struct (Min/Max float range), exported from Core.dll.
// Definition from CoreClasses.h; only data layout needed for member sizing.
#ifndef _FRANGE_DEFINED
#define _FRANGE_DEFINED
struct FRange
{
	FLOAT Min;
	FLOAT Max;
};
#endif

// FRandomTweenNum — Engine struct (tween min/max/result), exported from Engine.dll.
// Definition from EngineClasses.h (SDK); only data layout needed.
#ifndef _FRANDOMTWEENNUM_DEFINED
#define _FRANDOMTWEENNUM_DEFINED
struct FRandomTweenNum
{
	FLOAT m_fMin;
	FLOAT m_fMax;
	FLOAT m_fResult;
};
#endif

/*==========================================================================
	AUTOGENERATE_NAME / AUTOGENERATE_FUNCTION entries.
==========================================================================*/

#ifndef NAMES_ONLY
#undef  AUTOGENERATE_NAME
#undef  AUTOGENERATE_FUNCTION
#define AUTOGENERATE_NAME(name) extern R6ENGINE_API FName R6ENGINE_##name;
#define AUTOGENERATE_FUNCTION(cls,idx,name)
#endif

AUTOGENERATE_NAME(AdjustPawnForDiagonalStrafing)
AUTOGENERATE_NAME(AnimFinished)
AUTOGENERATE_NAME(AttackTimer)
AUTOGENERATE_NAME(CanOpenDoor)
AUTOGENERATE_NAME(ClientNotifySendMatchResults)
AUTOGENERATE_NAME(ClientNotifySendStartMatch)
AUTOGENERATE_NAME(ClientPlayVoices)
AUTOGENERATE_NAME(ClientUpdateLadderStat)
AUTOGENERATE_NAME(ClientVoteSessionAbort)
AUTOGENERATE_NAME(EndCrawl)
AUTOGENERATE_NAME(EndOfGrenadeEffect)
AUTOGENERATE_NAME(EndPeekingMode)
AUTOGENERATE_NAME(FinishInitialization)
AUTOGENERATE_NAME(GetFiringStartPoint)
AUTOGENERATE_NAME(GetRoundTime)
AUTOGENERATE_NAME(GetStanceReticuleModifier)
AUTOGENERATE_NAME(GetZoomMultiplyFactor)
AUTOGENERATE_NAME(GotoCrouch)
AUTOGENERATE_NAME(GotoFoetus)
AUTOGENERATE_NAME(GotoKneel)
AUTOGENERATE_NAME(GotoPointAndSearch)
AUTOGENERATE_NAME(GotoPointToAttack)
AUTOGENERATE_NAME(GotoProne)
AUTOGENERATE_NAME(GotoStand)
AUTOGENERATE_NAME(GotoStateEngageByThreat)
AUTOGENERATE_NAME(InitBiPodPosture)
AUTOGENERATE_NAME(IsFullPeekingOver)
AUTOGENERATE_NAME(IsPeekingLeft)
AUTOGENERATE_NAME(LoopSpecialAnim)
AUTOGENERATE_NAME(OpenDoorFailed)
AUTOGENERATE_NAME(PlayCrouchToProne)
AUTOGENERATE_NAME(PlayFluidPeekingAnim)
AUTOGENERATE_NAME(PlayPeekingAnim)
AUTOGENERATE_NAME(PlayProneToCrouch)
AUTOGENERATE_NAME(PlaySpecialAnim)
AUTOGENERATE_NAME(PlaySpecialPendingAction)
AUTOGENERATE_NAME(PlaySurfaceSwitch)
AUTOGENERATE_NAME(PlayerTeamSelectionReceived)
AUTOGENERATE_NAME(PostRender)
AUTOGENERATE_NAME(PotentialOpenDoor)
AUTOGENERATE_NAME(R6MakeMovementNoise)
AUTOGENERATE_NAME(R6ResetLookDirection)
AUTOGENERATE_NAME(R6SetMovement)
AUTOGENERATE_NAME(ReinitSimulation)
AUTOGENERATE_NAME(RemovePotentialOpenDoor)
AUTOGENERATE_NAME(RequestFormationChange)
AUTOGENERATE_NAME(ResetBipodPosture)
AUTOGENERATE_NAME(ResetDiagonalStrafing)
AUTOGENERATE_NAME(SequenceChanged)
AUTOGENERATE_NAME(SequenceFinished)
AUTOGENERATE_NAME(SetAnimInfo)
AUTOGENERATE_NAME(SetCrouchBlend)
AUTOGENERATE_NAME(SetNewDamageState)
AUTOGENERATE_NAME(SetPeekingInfo)
AUTOGENERATE_NAME(SetPotentialClimber)
AUTOGENERATE_NAME(SetRotationOffset)
AUTOGENERATE_NAME(SpawnRagDoll)
AUTOGENERATE_NAME(StartCrawl)
AUTOGENERATE_NAME(StartFluidPeeking)
AUTOGENERATE_NAME(StartFullPeeking)
AUTOGENERATE_NAME(StartSimulation)
AUTOGENERATE_NAME(StopAttack)
AUTOGENERATE_NAME(StopSimulation)
AUTOGENERATE_NAME(StopSpecialAnim)
AUTOGENERATE_NAME(TurnToFaceActor)
AUTOGENERATE_NAME(UpdateBipodPosture)
AUTOGENERATE_NAME(UpdateTeamFormation)
AUTOGENERATE_NAME(ZDRSetDamageState)

#ifndef NAMES_ONLY

/*==========================================================================
	Forward declarations.
==========================================================================*/

class APathNode;
class AR6AbstractBullet;
class AR6AbstractBulletManager;
class AR6AbstractCorpse;
class AR6AbstractFirstPersonWeapon;
class AR6AbstractGadget;
class AR6AbstractHelmet;
class AR6AbstractPawn;
class AR6AbstractWeapon;
class AR6ActionSpot;
class AR6Bullet;
class AR6EngineWeapon;
class AR6Gadget;
class AR6MissionObjectiveMgr;
class AR6PawnReplicationInfo;
class AR6Reticule;
class AR6Weapons;
class UInteractionMaster;
class UMaterial;
class UR6AbstractGameService;
class UR6AbstractNoiseMgr;
class UR6AbstractPlanningInfo;
class UR6GameColors;
class UR6GameMenuCom;
class UR6GameOptions;
class UR6MissionDescription;
class UR6MissionObjectiveBase;

/*==========================================================================
	Enums.
==========================================================================*/

enum EInteractiveAction{
	 IA_PlayAnim=0
	,IA_LookAt=1
};

enum eStateIOObejct{
	 SIO_Start=0
	,SIO_Interrupt=1
	,SIO_Complete=2
};

enum eDeviceCircumstantialAction{
	 DCA_None=0
	,DCA_DisarmBomb=1
	,DCA_ArmBomb=2
	,DCA_Device=3
};

enum eDeviceAnimToPlay{
	 BA_ArmBomb=0
	,BA_DisarmBomb=1
	,BA_Keypad=2
	,BA_PlantDevice=3
	,BA_Keyboard=4
	,BA_Custom=5
};

enum EPendingAction{
	 PENDING_None=0
	,PENDING_Coughing=1
	,PENDING_StopCoughing=2
	,PENDING_Blinded=3
	,PENDING_OpenDoor=4
	,PENDING_StartClimbingLadder=5
	,PENDING_PostStartClimbingLadder=6
	,PENDING_EndClimbingLadder=7
	,PENDING_PostEndClimbingLadder=8
	,PENDING_DropWeapon=9
	,PENDING_ProneToCrouch=10
	,PENDING_CrouchToProne=11
	,PENDING_MoveHitBone=12
	,PENDING_StartClimbingObject=13
	,PENDING_PostStartClimbingObject=14
	,PENDING_SetRemoteCharge=15
	,PENDING_SetBreachingCharge=16
	,PENDING_SetClaymore=17
	,PENDING_InteractWithDevice=18
	,PENDING_LockPickDoor=19
	,PENDING_ComFollowMe=20
	,PENDING_ComCover=21
	,PENDING_ComGo=22
	,PENDING_ComRegroup=23
	,PENDING_ComHold=24
	,PENDING_ActivateNightVision=25
	,PENDING_DeactivateNightVision=26
	,PENDING_SecureWeapon=27
	,PENDING_EquipWeapon=28
	,PENDING_SecureTerrorist=29
	,PENDING_ThrowGrenade=30
	,PENDING_Surrender=31
	,PENDING_Kneeling=32
	,PENDING_Arrest=33
	,PENDING_CallBackup=34
	,PENDING_SpecialAnim=35
	,PENDING_LoopSpecialAnim=36
	,PENDING_StopSpecialAnim=37
	,PENDING_HostageAnim=38
	,PENDING_EndSurrender=39
	,PENDING_StartSurrender=40
	,PENDING_PostEndSurrender=41
	,PENDING_SetFree=42
	,PENDING_ArrestKneel=43
	,PENDING_ArrestWaiting=44
	,PENDING_EndArrest=45
	,PENDING_Custom=46
};

enum eMovementDirection{
	 MOVEDIR_Forward=0
	,MOVEDIR_Backward=1
	,MOVEDIR_Strafe=2
};

enum EHostagePersonality{
	 HPERSO_Coward=0
	,HPERSO_Normal=1
	,HPERSO_Brave=2
	,HPERSO_Bait=3
	,HPERSO_None=4
};

enum eHands{
	 HANDS_None=0
	,HANDS_Right=1
	,HANDS_Left=2
	,HANDS_Both=3
};

enum eMovementPace{
	 PACE_None=0
	,PACE_Prone=1
	,PACE_CrouchWalk=2
	,PACE_CrouchRun=3
	,PACE_Walk=4
	,PACE_Run=5
};

enum eArmor{
	 ARMOR_None=0
	,ARMOR_Light=1
	,ARMOR_Medium=2
	,ARMOR_Heavy=3
};

enum ETerroristType{
	 TTYPE_B1T1=0
	,TTYPE_B1T3=1
	,TTYPE_B2T2=2
	,TTYPE_B2T4=3
	,TTYPE_M1T1=4
	,TTYPE_M1T3=5
	,TTYPE_M2T2=6
	,TTYPE_M2T4=7
	,TTYPE_P1T1=8
	,TTYPE_P2T2=9
	,TTYPE_P3T3=10
	,TTYPE_P1T4=11
	,TTYPE_P2T5=12
	,TTYPE_P3T6=13
	,TTYPE_P1T7=14
	,TTYPE_P2T8=15
	,TTYPE_P3T9=16
	,TTYPE_P1T10=17
	,TTYPE_P2T11=18
	,TTYPE_P3T12=19
	,TTYPE_P4T13=20
	,TTYPE_D1T1=21
	,TTYPE_D1T2=22
	,TTYPE_GOSP=23
	,TTYPE_GUTI=24
	,TTYPE_S1T1=25
	,TTYPE_S1T2=26
	,TTYPE_TXIC=27
	,TTYPE_T1T1=28
	,TTYPE_T2T2=29
	,TTYPE_T1T3=30
	,TTYPE_T2T4=31
};

enum EHeadAttachmentType{
	 ATTACH_Glasses=0
	,ATTACH_Sunglasses=1
	,ATTACH_GasMask=2
	,ATTACH_None=3
};

enum eStrafeDirection{
	 STRAFE_None=0
	,STRAFE_ForwardRight=1
	,STRAFE_ForwardLeft=2
	,STRAFE_BackwardRight=3
	,STRAFE_BackwardLeft=4
};

enum eBodyPart{
	 BP_Head=0
	,BP_Chest=1
	,BP_Abdomen=2
	,BP_Legs=3
	,BP_Arms=4
};

enum EActionType{
	 ET_Goto=0
	,ET_PlayAnim=1
	,ET_LookAt=2
	,ET_LoopAnim=3
	,ET_LoopRandomAnim=4
	,ET_ToggleDevice=5
};

enum ESoundBeepBomb{
	 SBB_Normal=0
	,SBB_Fast=1
	,SBB_Faster=2
};

enum EStartingPosition{
	 POS_Stand=0
	,POS_Kneel=1
	,POS_Prone=2
	,POS_Foetus=3
	,POS_Crouch=4
	,POS_Random=5
};

enum EStandWalkingAnim{
	 eStandWalkingAnim_default=0
	,eStandWalkingAnim_scared=1
};

enum ECivPatrolType{
	 CIVPATROL_None=0
	,CIVPATROL_Path=1
	,CIVPATROL_Area=2
	,CIVPATROL_Point=3
};

enum EHandsUpType{
	 HANDSUP_none=0
	,HANDSUP_kneeling=1
	,HANDSUP_standing=2
};

enum eHostageOrder{
	 HOrder_None=0
	,HOrder_ComeWithMe=1
	,HOrder_StayHere=2
	,HOrder_Surrender=3
	,HOrder_GotoExtraction=4
};

enum eComAnimation{
	 COM_None=0
	,COM_FollowMe=1
	,COM_Cover=2
	,COM_Go=3
	,COM_Regroup=4
	,COM_Hold=5
};

enum eRainbowCircumstantialAction{
	 CAR_None=0
	,CAR_Secure=1
	,CAR_Free=2
};

enum eEquipWeapon{
	 EQUIP_SecureWeapon=0
	,EQUIP_EquipWeapon=1
	,EQUIP_NoWeapon=2
	,EQUIP_Armed=3
};

enum eLadderSlide{
	 SLIDE_Start=0
	,SLIDE_Sliding=1
	,SLIDE_End=2
	,SLIDE_None=3
};

enum ETerroPersonality{
	 PERSO_Coward=0
	,PERSO_DeskJockey=1
	,PERSO_Normal=2
	,PERSO_Hardened=3
	,PERSO_SuicideBomber=4
	,PERSO_Sniper=5
};

enum EStrategy{
	 STRATEGY_PatrolPath=0
	,STRATEGY_PatrolArea=1
	,STRATEGY_GuardPoint=2
	,STRATEGY_Hunt=3
	,STRATEGY_Test=4
};

enum ENetworkSpecialAnim{
	 NWA_NonValid=0
	,NWA_Playing=1
	,NWA_Looping=2
};

enum ETerroristCircumstantialAction{
	 CAT_None=0
	,CAT_Secure=1
};

enum EDefCon{
	 DEFCON_0=0
	,DEFCON_1=1
	,DEFCON_2=2
	,DEFCON_3=3
	,DEFCON_4=4
	,DEFCON_5=5
};

enum EZDRStat{
	 ZDRS_None=0
	,ZDRS_Contact=1
};

enum EZDRType{
	 ZDRT_None=0
	,ZDRT_Break=1
};

enum EReactionType{
	 RT_None=0
	,RT_Break=1
	,RT_Karma=2
	,RT_KarmaAndBreak=3
};

enum eClimbableObjectCircumstantialAction{
	 COBJ_None=0
	,COBJ_Climb=1
};

enum EClimbHeight{
	 EClimbNone=0
	,EClimb64=1
	,EClimb96=2
};

enum eDoorCircumstantialAction{
	 CA_None=0
	,CA_Open=1
	,CA_OpenAndClear=2
	,CA_OpenAndGrenade=3
	,CA_OpenGrenadeAndClear=4
	,CA_Close=5
	,CA_Clear=6
	,CA_Grenade=7
	,CA_GrenadeAndClear=8
	,CA_GrenadeFrag=9
	,CA_GrenadeGas=10
	,CA_GrenadeFlash=11
	,CA_GrenadeSmoke=12
	,CA_Unlock=13
	,CA_Lock=14
	,CA_LockPickStop=15
};

enum eLadderCircumstantialAction{
	 CAL_None=0
	,CAL_Climb=1
};

enum eLadderEndDirection{
	 LDR_Forward=0
	,LDR_Right=1
	,LDR_Left=2
};

enum ECoverShotDir{
	 COVERDIR_Over=0
	,COVERDIR_Left=1
	,COVERDIR_Right=2
};

enum EInformTeam{
	 INFO_EnterPath=0
	,INFO_ReachNode=1
	,INFO_FinishWaiting=2
	,INFO_Engage=3
	,INFO_ExitPath=4
	,INFO_Dead=5
};

enum eRoomLayout{
	 ROOM_OpensCenter=0
	,ROOM_OpensLeft=1
	,ROOM_OpensRight=2
	,ROOM_None=3
};

enum eTeamState{
	 TS_None=0
	,TS_Waiting=1
	,TS_Holding=2
	,TS_Moving=3
	,TS_Following=4
	,TS_Regrouping=5
	,TS_Engaging=6
	,TS_Sniping=7
	,TS_LockPicking=8
	,TS_OpeningDoor=9
	,TS_ClosingDoor=10
	,TS_Opening=11
	,TS_Closing=12
	,TS_ClearingRoom=13
	,TS_Grenading=14
	,TS_DisarmingBomb=15
	,TS_InteractWithDevice=16
	,TS_SecuringTerrorist=17
	,TS_ClimbingLadder=18
	,TS_WaitingForOrders=19
	,TS_SettingBreach=20
	,TS_Retired=21
};

enum ePlayerRoomEntry{
	 PRE_Center=0
	,PRE_Left=1
	,PRE_Right=2
};

enum EEngageReaction{
	 EREACT_Random=0
	,EREACT_AimedFire=1
	,EREACT_SprayFire=2
	,EREACT_RunAway=3
	,EREACT_Surrender=4
};

enum EReactionStatus{
	 REACTION_HearAndSeeAll=0
	,REACTION_SeeHostage=1
	,REACTION_HearBullet=2
	,REACTION_SeeRainbow=3
	,REACTION_Grenade=4
	,REACTION_HearAndSeeNothing=5
};

enum EEventState{
	 EVSTATE_DefaultState=0
	,EVSTATE_RunAway=1
	,EVSTATE_Attack=2
	,EVSTATE_FindHostage=3
	,EVSTATE_AttackHostage=4
};

enum EAttackMode{
	 ATTACK_NotEngaged=0
	,ATTACK_AimedFire=1
	,ATTACK_SprayFire=2
	,ATTACK_SprayFireNoStop=3
	,ATTACK_SprayFireMove=4
};

enum EFollowMode{
	 FMODE_Hostage=0
	,FMODE_Path=1
};

enum eFormation{
	 FORM_SingleFile=0
	,FORM_SingleFileWallBothSides=1
	,FORM_SingleFileWallRight=2
	,FORM_SingleFileWallLeft=3
	,FORM_SingleFileNoWalls=4
	,FORM_OrientedSingleFile=5
	,FORM_Diamond=6
};

enum ePawnOrientation{
	 PO_Front=0
	,PO_FrontRight=1
	,PO_Right=2
	,PO_Left=3
	,PO_FrontLeft=4
	,PO_Back=5
	,PO_PeekLeft=6
	,PO_PeekRight=7
};
typedef enum ePawnOrientation EPawnOrientation;

enum eCoverDirection{
	 COVER_Left=0
	,COVER_Center=1
	,COVER_Right=2
	,COVER_None=3
};

enum eGamePasswordRes{
	 GPR_None=0
	,GPR_MissingPasswd=1
	,GPR_PasswdSet=2
	,GPR_PasswdCleared=3
};

enum eDefaultCircumstantialAction{
	 PCA_None=0
	,PCA_TeamRegroup=1
	,PCA_TeamMoveTo=2
	,PCA_MoveAndGrenade=3
	,PCA_GrenadeFrag=4
	,PCA_GrenadeGas=5
	,PCA_GrenadeFlash=6
	,PCA_GrenadeSmoke=7
};

enum eDeathCameraMode{
	 eDCM_FIRSTPERSON=0
	,eDCM_THIRDPERSON=1
	,eDCM_FREETHIRDPERSON=2
	,eDCM_GHOST=3
	,eDCM_FADETOBLACK=4
};

enum eCircumstantialActionPerformer{
	 CACTION_Player=0
	,CACTION_Team=1
	,CACTION_TeamFromList=2
	,CACTION_TeamFromListZulu=3
};

enum EThreatType{
	 THREAT_none=0
	,THREAT_friend=1
	,THREAT_sound=2
	,THREAT_surrender=3
	,THREAT_enemy=4
	,THREAT_underFire=5
	,THREAT_neutral=6
	,THREAT_misc=7
};

enum EAnimTransType{
	 eAnimTrans_none=0
	,eAnimTrans_animTransInfo=1
	,eAnimTrans_groupTransition=2
	,eAnimTrans_manual=3
};

enum EGroupAnimType{
	 eGroupAnim_none=0
	,eGroupAnim_transition=1
	,eGroupAnim_wait=2
	,eGroupAnim_reaction=3
};

enum EPlayAnimType{
	 ePlayType_Default=0
	,ePlayType_Random=1
};

enum EOpeningSide{
	 Top=0
	,Bottom=1
	,Left=2
	,Right=3
};

enum eWindowCircumstantialAction{
	 WCA_None=0
	,WCA_Open=1
	,WCA_Close=2
	,WCA_Climb=3
	,WCA_Grenade=4
	,WCA_OpenAndGrenade=5
	,WCA_GrenadeFrag=6
	,WCA_GrenadeGas=7
	,WCA_GrenadeFlash=8
	,WCA_GrenadeSmoke=9
};

/*==========================================================================
	Structs.
==========================================================================*/

struct FstSpawnedActor
{
public:
	class UClass* ActorToSpawn;
	class FString HelperName;
};

struct FstRandomMesh
{
public:
	FLOAT fPercentage;
	class UStaticMesh* Mesh;
};

struct FstRandomSkin
{
public:
	FLOAT fPercentage;
	TArray<class UMaterial*> Skin;
};

struct FstDamageState
{
public:
	FLOAT fDamagePercentage;
	TArray<struct FstRandomMesh> RandomMeshes;
	TArray<struct FstRandomSkin> RandomSkins;
	TArray<struct FstSpawnedActor> ActorList;
	TArray<class USound*> SoundList;
	class USound* NewAmbientSound;
	class USound* NewAmbientSoundStop;
};

struct PA_ExecuteGotoEnding
{
};

struct PA_Execute
{
};

struct PA_ExecutePlayEnding
{
};

struct PA_ExecuteLoopRandomAnim
{
};

struct PA_ExecuteLoopAnim
{
};

struct PA_ExecutePlayAnim
{
};

struct PA_ExecuteToggleDevice
{
};

struct PA_ExecuteGoto
{
};

struct PA_ExecuteLookAt
{
};

struct PA_ExecuteStartInteraction
{
};

struct FSTWeaponAnim
{
public:
	FName nAnimToPlay;
	FName nBlendName;
	FLOAT fTweenTime;
	FLOAT fRate;
	BITFIELD bPlayOnce : 1;
	BITFIELD bBackward : 1;
};

struct FSTTemplate
{
public:
	class FString m_szName;
	INT m_iChance;
};

struct FAnimInfo
{
public:
	FName m_name;
	INT m_id;
	FLOAT m_fRate;
	BYTE m_ePlayType;
	BYTE m_eGroupAnim;
};

struct Foetus
{
};

struct Prone
{
};

struct Kneeling
{
};

struct Crouching
{
};

struct FSTRepHostageAnim
{
public:
	BYTE m_eRepStandWalkingAnim;
	BITFIELD m_bRepPlayMoving : 1;
};

struct PA_LoopAnim
{
};

struct PA_Interaction
{
};

struct PA_PlayAnim
{
};

struct PA_Goto
{
};

struct PA_LookAt
{
};

struct PA_StartInteraction
{
};

struct TestMakePath
{
};

struct TestMakePathEnd
{
};

struct OpenDoor
{
};

struct BumpBackUp
{
};

struct Dispatcher
{
};

struct EndClimbingLadder
{
};

struct BeginClimbingLadder
{
};

struct ApproachLadder
{
};

struct WaitToClimbLadder
{
};

struct MenuDisplayed
{
};

struct FstActorReactionState
{
public:
	FLOAT fDamagePercentage;
	INT iActorStat;
	class AActor* m_actor;
};

struct FstZDRSound
{
public:
	BYTE m_eZDRGroupe;
	BYTE m_eZDRSoundType;
	class USound* m_aZDRSound;
	class AActor* m_aZDRActor;
	FLOAT m_fZDRVolume;
};

struct FstZDR
{
public:
	BYTE m_eZDRType;
	BYTE m_eZDRStat;
	FLOAT m_fZDRRadius;
	class FVector m_vZDRLocation;
	TArray<struct FstZDRSound> m_ZDRSoundList;
	INT m_iZDRDamageStat;
	FLOAT m_fZDRImpactInterval;
	FLOAT m_fZDRLastImpactTime;
};

struct PotentialClimb
{
};

struct FSTHostage
{
public:
	class AR6Hostage* hostage;
	class AR6TerroristAI* terro;
	INT bInZone;
};

struct FThreatInfo
{
public:
	INT m_id;
	INT m_iThreatLevel;
	class APawn* m_pawn;
	class AActor* m_actorExt;
	INT m_bornTime;
	class FVector m_originalLocation;
	FName m_state;
};

struct FOrderInfo
{
public:
	BITFIELD m_bOrderedByRainbow : 1;
	class AR6Pawn* m_pawn1;
	BYTE m_eOrder;
	FLOAT m_fTime;
	class AActor* m_actor;
};

struct Extracted
{
};

struct GotoExtraction
{
};

struct FPlaySndInfo
{
public:
	INT m_iLastTime;
	INT m_iInBetweenTime;
};

struct DbgHostage
{
};

struct GoHstRunForCover
{
};

struct GoHstRunTowardRainbow
{
};

struct GoHstFreedButSeeEnemy
{
};

struct ReactToGrenade
{
};

struct CivSurrender
{
};

struct CivRunTowardRainbow
{
};

struct CMCivStayHere
{
};

struct Civilian
{
};

struct CMCivStayKneel
{
};

struct CivMovingTo
{
};

struct CivRunForCover
{
};

struct CivScareToDeath
{
};

struct GoCivScareToDeath
{
};

struct CivStayHere
{
};

struct EscortedByEnemy
{
};

struct CivPatrolPath
{
};

struct WaitForSomeTime
{
};

struct CivGuardPoint
{
};

struct CivPatrolArea
{
};

struct RunForCover
{
};

struct FollowingPawn
{
};

struct FollowingPaceTransition
{
};

struct Freed
{
};

struct Guarded_frozen
{
};

struct Guarded
{
};

struct GoGuarded_frozen
{
};

struct Guarded_foetus
{
};

struct GoGuarded_Foetus
{
};

struct Configuration
{
};

struct HuntRainbow
{
};

struct PatrolPath
{
};

struct PatrolArea
{
};

struct FollowPawn
{
};

struct FindHostage
{
};

struct Sniping
{
};

struct GuardPoint
{
};

struct AttackHostage
{
};

struct Attack
{
};

struct WaitForEnemy
{
};

struct RunAway
{
};

struct Surrender
{
};

struct SeeADead
{
};

struct EngageBySound
{
};

struct EngageByThreat
{
};

struct MovingTo
{
};

struct NoThreat
{
};

struct ThrowingGrenade
{
};

struct PrecombatAction
{
};

struct LostSight
{
};

struct MovingToAttack
{
};

struct TransientStateCode
{
};

struct test
{
};

struct WatchPlayer
{
};

struct TestBoneRotation
{
};

struct WaitForGameToStart
{
};

struct FollowLeader
{
};

struct TeamClimbLadder
{
};

struct TeamClimbEndNoLeader
{
};

struct TeamClimbStartNoLeader
{
};

struct PauseSniping
{
};

struct SnipeUntilGoCode
{
};

struct LeadRoomEntry
{
};

struct DetonateBreachingCharge
{
};

struct PlaceBreachingCharge
{
};

struct Patrol
{
};

struct WaitForTeam
{
};

struct TeamMoveTo
{
};

struct TeamSecureTerrorist
{
};

struct HoldPosition
{
};

struct RoomEntry
{
};

struct FindPathToTarget
{
};

struct PerformAction
{
};

struct LockPickDoor
{
};

struct WaitForPaceMember
{
};

struct RunAwayFromGrenade
{
};

struct FSTBanPage
{
public:
	class FString szBanID[10];
};

struct FSTImpactShake
{
public:
	INT iBlurIntensity;
	FLOAT fWaveTime;
	FLOAT fRollMax;
	FLOAT fRollSpeed;
	FLOAT fReturnTime;
};

struct PlayerEndClimbingLadder
{
};

struct PlayerBeginClimbingLadder
{
};

struct PreBeginClimbingLadder
{
};

struct PlayerSetExplosive
{
};

struct PlayerSecureTerrorist
{
};

struct PlayerActionProgress
{
};

struct PlayerSetFree
{
};

struct CameraPlayer
{
};

struct PlayerArrested
{
};

struct PlayerStartArrest
{
};

struct PlayerSecureRainbow
{
};

struct PlayerEndSurrended
{
};

struct PlayerSurrended
{
};

struct PlayerStartSurrending
{
};

struct PlayerPreBeginSurrending
{
};

struct PlayerFinishReloadingBeforeSurrender
{
};

struct PlayerStartSurrenderSequence
{
};

struct WaitForGameRepInfo
{
};

struct PauseController
{
};

struct PenaltyBox
{
};

struct FstSoundPriorityPtr
{
public:
	INT Ptr;
};

struct FstSoundPriority
{
public:
	class AR6SoundReplicationInfo* aSoundRepInfo;
	class USound* sndPlayVoice;
	INT iPriority;
	BYTE eSlotUse;
	BYTE EPawnType;
	FLOAT fTimeStart;
	BITFIELD bIsPlaying : 1;
	BITFIELD bWaitToFinishSound : 1;
};

struct FSTSpring
{
public:
	INT iFirst;
	INT iSecond;
	FLOAT fMinSquared;
	FLOAT fMaxSquared;
};

struct FSTParticle
{
public:
	class FCoords cCurrentPos;
	class FVector vPreviousOrigin;
	class FVector vBonePosition;
	FLOAT fMass;
	INT iToward;
	INT iRefBone;
	FName BoneName;
};

struct FCommandInfo
{
public:
	FName m_functionName;
	class FString m_szDescription;
};

struct ActionProgress
{
};

struct FThreatDefinition
{
public:
	FName m_groupName;
	class FString m_szName;
	BYTE m_eThreatType;
	BYTE m_eNoiseType;
	INT m_iThreatLevel;
	INT m_iCaringDistance;
	FName m_considerThreat;
};

struct FAnimTransInfo
{
public:
	FName m_AIState;
	FName m_pawnState;
	FName m_sourceAnimName;
	INT m_iSourceAnim;
	FName m_targetAnimName;
	INT m_iTargetAnim;
	FLOAT m_fTime;
	FLOAT m_fTargetAnimRate;
};

struct FHstSndEventInfo
{
public:
	INT m_iHstSndEvent;
	BYTE m_ePerso;
	BYTE m_eVoice;
};

struct FReactionInfo
{
public:
	FName m_groupName;
	INT m_iThreatLevel;
	INT m_iChance;
	FName m_gotoState;
};

class R6ENGINE_API R6Charts
{
public:
	INT BulletGoesThroughCharacter(INT, INT, INT, INT);
	struct stResultTable * GetKillTable(enum eBodyPart);
	struct stResultTable * GetStunTable(enum eBodyPart);
	R6Charts();
	static struct stBodyPart m_stKillChart;
	static struct stBodyPart m_stStunChart;
	class R6Charts & operator=(class R6Charts const &);
private:
	static float (*m_fHumanSidePenetrationFactors)[2];
	static int (*m_iHumanPenetrationTresholds)[3];
};

/*==========================================================================
	AR6InteractiveObject
==========================================================================*/

class R6ENGINE_API AR6InteractiveObject : public AActor
{
public:
	DECLARE_CLASS(AR6InteractiveObject, AActor, 0, R6Engine)

	BYTE m_HearNoiseType;
	INT m_iActionNumber;
	INT m_iActionIndex;
	INT m_iHitPoints;
	INT m_iCurrentHitPoints;
	INT m_iCurrentState;
	BITFIELD m_bCollisionRemovedFromActor : 1;
	BITFIELD m_bOriginalCollideActors : 1;
	BITFIELD m_bOriginalBlockActors : 1;
	BITFIELD m_bOriginalBlockPlayers : 1;
	BITFIELD m_bPawnDied : 1;
	BITFIELD bShowLog : 1;
	BITFIELD m_bBroken : 1;
	BITFIELD m_bRainbowCanInteract : 1;
	BITFIELD m_bEndAction : 1;
	BITFIELD m_bBlockCoronas : 1;
	BITFIELD m_bBreakableByFlashBang : 1;
	FLOAT m_fRadius;
	FLOAT m_fProbability;
	FLOAT m_fActionInterval;
	FLOAT m_fTimeSinceAction;
	FLOAT m_fTimeForNextSound;
	FLOAT m_fTimerInterval;
	FLOAT m_fPlayerCAStartTime;
	FLOAT m_HearNoiseLoudness;
	FLOAT m_fNetDamagePercentage;
	FLOAT m_fAIBreakNoiseRadius;
	AR6AIController* m_InteractionOwner;
	AActor* m_RemoveCollisionFromActor;
	ANavigationPoint* m_Anchor;
	AActor* m_vEndActionGoto;
	UR6InteractiveObjectAction* m_CurrentInteractiveObject;
	APawn* m_SeePlayerPawn;
	AActor* m_HearNoiseNoiseMaker;
	UMaterial* m_aOldSkins[4];
	UMaterial* m_aRepSkins[4];
	UStaticMesh* sm_staticMesh;
	AR6Pawn* m_User;
	USound* sm_AmbientSound;
	USound* sm_AmbientSoundStop;
	FName m_vEndActionAnimName;
	TArray<UR6InteractiveObjectAction*> m_ActionList;
	TArray<UMaterial*> sm_aSkins;
	TArray<FstDamageState> m_StateList;
	TArray<AActor*> m_AttachedActors;

	virtual void PreNetReceive();
	virtual void PostNetReceive();
	virtual void PostScriptDestroyed();
	virtual INT ShouldTrace(AActor *, DWORD);
	virtual void RenderEditorInfo(FLevelSceneNode *, FRenderInterface *, FDynamicActor *);
	virtual void CheckForErrors();
	void eventSetNewDamageState(FLOAT);

public:
	AR6InteractiveObject() {}
};

/*==========================================================================
	AR6IActionObject
==========================================================================*/

class R6ENGINE_API AR6IActionObject : public AR6InteractiveObject
{
public:
	DECLARE_CLASS(AR6IActionObject, AR6InteractiveObject, 0, R6Engine)

	FLOAT m_fMinMouseMove;
	FLOAT m_fMaxMouseMove;
	AActor* m_ActionInstigator;


protected:
	AR6IActionObject() {}
};

/*==========================================================================
	AR6IOObject
==========================================================================*/

class R6ENGINE_API AR6IOObject : public AR6IActionObject
{
public:
	DECLARE_CLASS(AR6IOObject, AR6IActionObject, 0, R6Engine)

	BYTE m_eAnimToPlay;
	BYTE m_ObjectState;
	BITFIELD m_bToggleType : 1;
	BITFIELD sm_bToggleType : 1;
	BITFIELD m_bIsActivated : 1;
	BITFIELD sm_bIsActivated : 1;
	FLOAT m_fGainTimeWithElectronicsKit;
	FLOAT m_fLockObjectTime;
	USound* m_StartSnd;
	USound* m_InterruptedSnd;
	USound* m_CompletedSnd;


protected:
	AR6IOObject() {}
};

/*==========================================================================
	AR6Pawn
==========================================================================*/

class R6ENGINE_API AR6Pawn : public AR6AbstractPawn
{
public:
	DECLARE_CLASS(AR6Pawn, AR6AbstractPawn, 0, R6Engine)

	BYTE m_eMovementPace;
	BYTE m_ePendingAction[5];
	BYTE m_iNetCurrentActionIndex;
	BYTE m_iLocalCurrentActionIndex;
	BYTE m_ePlayerIsUsingHands;
	BYTE m_eDeviceAnim;
	BYTE m_eLastUsingHands;
	BYTE m_ePawnIsUsingHand;
	BYTE m_eArmorType;
	BYTE m_eOldPeekingMode;
	BYTE m_bSuicideType;
	BYTE m_eLastHitPart;
	BYTE m_eStrafeDirection;
	BYTE m_bRepPlayWaitAnim;
	BYTE m_bSavedPlayWaitAnim;
	BYTE m_byRemainingWaitZero;
	INT m_iPendingActionInt[5];
	INT m_iID;
	INT m_iPermanentID;
	INT m_iVisibilityTest;
	INT m_iForceKill;
	INT m_iForceStun;
	INT m_iMaxRotationOffset;
	INT m_iRepBipodRotationRatio;
	INT m_iLastBipodRotation;
	INT m_iUniqueID;
	INT m_hLipSynchData;
	INT m_iDesignRandomTweak;
	INT m_iDesignLightTweak;
	INT m_iDesignMediumTweak;
	INT m_iDesignHeavyTweak;
	BITFIELD m_bIsClimbingStairs : 1;
	BITFIELD m_bIsMovingUpStairs : 1;
	BITFIELD m_bIsClimbingLadder : 1;
	BITFIELD m_bSlideEnd : 1;
	BITFIELD m_bCanClimbObject : 1;
	BITFIELD m_bOldCanWalkOffLedges : 1;
	BITFIELD m_bActivateHeatVision : 1;
	BITFIELD m_bActivateNightVision : 1;
	BITFIELD m_bActivateScopeVision : 1;
	BITFIELD m_bWeaponGadgetActivated : 1;
	BITFIELD m_bIsKneeling : 1;
	BITFIELD m_bIsSniping : 1;
	BITFIELD m_bPlayingComAnimation : 1;
	BITFIELD m_bDontKill : 1;
	BITFIELD m_bPreviousAnimPlayOnce : 1;
	BITFIELD m_bToggleServerCancelPlacingCharge : 1;
	BITFIELD m_bOldServerCancelPlacingCharge : 1;
	BITFIELD m_bReAttachToRightHand : 1;
	BITFIELD m_bReloadingWeapon : 1;
	BITFIELD m_bReloadAnimLoop : 1;
	BITFIELD m_bChangingWeapon : 1;
	BITFIELD m_bIsFiringState : 1;
	BITFIELD m_bPawnIsReloading : 1;
	BITFIELD m_bPawnIsChangingWeapon : 1;
	BITFIELD m_bPawnReloadShotgunLoop : 1;
	BITFIELD m_bPeekingReturnToCenter : 1;
	BITFIELD m_bWasPeeking : 1;
	BITFIELD m_bWasPeekingLeft : 1;
	BITFIELD m_bAutoClimbLadders : 1;
	BITFIELD m_bAim : 1;
	BITFIELD m_bPostureTransition : 1;
	BITFIELD m_bWeaponTransition : 1;
	BITFIELD m_bPawnSpecificAnimInProgress : 1;
	BITFIELD m_bSoundChangePosture : 1;
	BITFIELD m_bNightVisionAnimation : 1;
	BITFIELD m_bSuicided : 1;
	BITFIELD m_bAvoidFacingWalls : 1;
	BITFIELD m_bWallAdjustmentDone : 1;
	BITFIELD m_bDontSeePlayer : 1;
	BITFIELD m_bDontHearPlayer : 1;
	BITFIELD m_bUseKarmaRagdoll : 1;
	BITFIELD m_bTerroSawMeDead : 1;
	BITFIELD m_bInteractingWithDevice : 1;
	BITFIELD m_bCanDisarmBomb : 1;
	BITFIELD m_bCanArmBomb : 1;
	BITFIELD m_bUsingBipod : 1;
	BITFIELD m_bLeftFootDown : 1;
	BITFIELD m_bModifyBones : 1;
	BITFIELD m_bHelmetWasHit : 1;
	BITFIELD m_bMovingDiagonally : 1;
	BITFIELD m_bEngaged : 1;
	BITFIELD m_bHasArmPatches : 1;
	BITFIELD m_bCanFireFriends : 1;
	BITFIELD m_bCanFireNeutrals : 1;
	BITFIELD m_bDesignToggleLog : 1;
	FLOAT m_fSkillAssault;
	FLOAT m_fSkillDemolitions;
	FLOAT m_fSkillElectronics;
	FLOAT m_fSkillSniper;
	FLOAT m_fSkillStealth;
	FLOAT m_fSkillSelfControl;
	FLOAT m_fSkillLeadership;
	FLOAT m_fSkillObservation;
	FLOAT m_fReloadSpeedMultiplier;
	FLOAT m_fGunswitchSpeedMultiplier;
	FLOAT m_fGadgetSpeedMultiplier;
	FLOAT m_fWalkingSpeed;
	FLOAT m_fWalkingBackwardStrafeSpeed;
	FLOAT m_fRunningSpeed;
	FLOAT m_fRunningBackwardStrafeSpeed;
	FLOAT m_fCrouchedWalkingSpeed;
	FLOAT m_fCrouchedWalkingBackwardStrafeSpeed;
	FLOAT m_fCrouchedRunningSpeed;
	FLOAT m_fCrouchedRunningBackwardStrafeSpeed;
	FLOAT m_fProneSpeed;
	FLOAT m_fProneStrafeSpeed;
	FLOAT m_fLastValidPeeking;
	FLOAT m_fOldCrouchBlendRate;
	FLOAT m_fOldPeekBlendRate;
	FLOAT m_fPeekingGoalModifier;
	FLOAT m_fPeekingGoal;
	FLOAT m_fPeeking;
	FLOAT m_fWallCheckDistance;
	FLOAT m_fStunShakeTime;
	FLOAT m_fWeaponJump;
	FLOAT m_fZoomJumpReturn;
	FLOAT m_fNoiseTimer;
	FLOAT m_fLastFSPUpdate;
	FLOAT m_fLastVRPUpdate;
	FLOAT m_fBipodRotation;
	FLOAT m_fTimeStartBodyFallSound;
	FLOAT m_fFiringTimer;
	FLOAT m_fHBTime;
	FLOAT m_fHBMove;
	FLOAT m_fHBWound;
	FLOAT m_fHBDefcon;
	FLOAT m_fPrePivotLastUpdate;
	FLOAT m_fLeftDirtyFootStepRemainingTime;
	FLOAT m_fRightDirtyFootStepRemainingTime;
	FLOAT m_fTimeGrenadeEffectBeforeSound;
	AR6AbstractBulletManager* m_pBulletManager;
	AR6Ladder* m_Ladder;
	AActor* m_potentialActionActor;
	AR6Door* m_Door;
	AR6Door* m_Door2;
	AR6ClimbableObject* m_climbObject;
	USound* m_sndNightVisionActivation;
	USound* m_sndNightVisionDeactivation;
	USound* m_sndCrouchToStand;
	USound* m_sndStandToCrouch;
	USound* m_sndThermalScopeActivation;
	USound* m_sndThermalScopeDeactivation;
	USound* m_sndDeathClothes;
	USound* m_sndDeathClothesStop;
	AR6AbstractCorpse* m_ragdoll;
	AR6Pawn* m_KilledBy;
	AActor* m_TrackActor;
	AActor* m_FOV;
	AEmitter* m_BreathingEmitter;
	AR6ArmPatchGlow* m_ArmPatches[2];
	AR6TeamMemberReplicationInfo* m_TeamMemberRepInfo;
	AR6SoundReplicationInfo* m_SoundRepInfo;
	FName m_WeaponAnimPlaying;
	FName m_standRunForwardName;
	FName m_standRunLeftName;
	FName m_standRunBackName;
	FName m_standRunRightName;
	FName m_standWalkForwardName;
	FName m_standWalkBackName;
	FName m_standWalkLeftName;
	FName m_standWalkRightName;
	FName m_hurtStandWalkLeftName;
	FName m_hurtStandWalkRightName;
	FName m_standTurnLeftName;
	FName m_standTurnRightName;
	FName m_standFallName;
	FName m_standLandName;
	FName m_crouchFallName;
	FName m_crouchLandName;
	FName m_crouchWalkForwardName;
	FName m_standStairWalkUpName;
	FName m_standStairWalkUpBackName;
	FName m_standStairWalkUpRightName;
	FName m_standStairWalkDownName;
	FName m_standStairWalkDownBackName;
	FName m_standStairWalkDownRightName;
	FName m_standStairRunUpName;
	FName m_standStairRunUpBackName;
	FName m_standStairRunUpRightName;
	FName m_standStairRunDownName;
	FName m_standStairRunDownBackName;
	FName m_standStairRunDownRightName;
	FName m_crouchStairWalkDownName;
	FName m_crouchStairWalkDownBackName;
	FName m_crouchStairWalkDownRightName;
	FName m_crouchStairWalkUpName;
	FName m_crouchStairWalkUpBackName;
	FName m_crouchStairWalkUpRightName;
	FName m_crouchStairRunUpName;
	FName m_crouchStairRunDownName;
	FName m_crouchDefaultAnimName;
	FName m_standDefaultAnimName;
	FName m_standClimb64DefaultAnimName;
	FName m_standClimb96DefaultAnimName;
	UClass* m_FOVClass;
	UClass* m_LeftDirtyFootStep;
	UClass* m_RightDirtyFootStep;
	FVector m_vStairDirection;
	FRotator m_rHitDirection;
	FRotator m_rPrevRotationOffset;
	FVector m_vFiringStartPoint;
	FRotator m_rViewRotation;
	FRotator m_rRoot;
	FRotator m_rPelvis;
	FRotator m_rSpine;
	FRotator m_rSpine1;
	FRotator m_rSpine2;
	FRotator m_rNeck;
	FRotator m_rHead;
	FRotator m_rPonyTail1;
	FRotator m_rPonyTail2;
	FRotator m_rJaw;
	FRotator m_rLClavicle;
	FRotator m_rLUpperArm;
	FRotator m_rLForeArm;
	FRotator m_rLHand;
	FRotator m_rLFinger0;
	FRotator m_rRClavicle;
	FRotator m_rRUpperArm;
	FRotator m_rRForeArm;
	FRotator m_rRHand;
	FRotator m_rRFinger0;
	FRotator m_rLThigh;
	FRotator m_rLCalf;
	FRotator m_rLFoot;
	FRotator m_rLToe;
	FRotator m_rRThigh;
	FRotator m_rRCalf;
	FRotator m_rRFoot;
	FRotator m_rRToe;
	FVector m_vPrePivotProneBackup;

	virtual void PreNetReceive();
	virtual void PostNetReceive();
	virtual void UpdateColBox(FVector &, INT, INT, INT);
	virtual void BeginTouch(AActor *);
	virtual FRotator GetViewRotation();
	virtual void TickSpecial(FLOAT);
	virtual void performPhysics(FLOAT);
	virtual INT IsRelevantToPawnHeatVision(APawn *);
	virtual INT IsRelevantToPawnHeartBeat(APawn *);
	virtual INT moveToward(FVector const &, AActor *);
	virtual INT HurtByVolume(AActor *);
	virtual void SetPrePivot(FVector);
	virtual FVector CheckForLedges(AActor *, FVector, FVector, FVector, INT &, INT &, FLOAT);
	virtual void physLadder(FLOAT, INT);
	virtual void physicsRotation(FLOAT, FVector);
	virtual void UpdateMovementAnimation(FLOAT);
	virtual DWORD R6SeePawn(APawn *, INT);
	virtual DWORD R6LineOfSightTo(AActor *, INT);
	virtual void calcVelocity(FVector, FLOAT, FLOAT, FLOAT, INT, INT, INT);
	virtual INT IsOverLedge(AActor *, FVector, FLOAT);
	virtual BYTE GetTeamColor();
	virtual BYTE GetStatusOtherTeam();
	void eventAdjustPawnForDiagonalStrafing();
	void eventEndCrawl();
	void eventEndOfGrenadeEffect(BYTE);
	void eventEndPeekingMode(BYTE);
	FLOAT eventGetStanceReticuleModifier();
	void eventInitBiPodPosture(DWORD);
	void eventPlayCrouchToProne(DWORD);
	void eventPlayFluidPeekingAnim(FLOAT, FLOAT, FLOAT);
	void eventPlayPeekingAnim(DWORD);
	void eventPlayProneToCrouch(DWORD);
	void eventPlaySpecialPendingAction(BYTE, INT);
	void eventPlaySurfaceSwitch();
	void eventPotentialOpenDoor(AR6Door *);
	void eventR6MakeMovementNoise();
	void eventR6ResetLookDirection();
	void eventRemovePotentialOpenDoor(AR6Door *);
	void eventResetBipodPosture();
	void eventResetDiagonalStrafing();
	void eventSetCrouchBlend(FLOAT);
	void eventSetPeekingInfo(BYTE, FLOAT, DWORD);
	void eventSetRotationOffset(INT, INT, INT);
	void eventSpawnRagDoll();
	void eventStartCrawl();
	void eventStartFluidPeeking();
	void eventStartFullPeeking();
	void eventTurnToFaceActor(AActor *);
	void eventUpdateBipodPosture();
	void execAdjustFluidCollisionCylinder(struct FFrame &, void * const);
	void execCheckCylinderTranslation(struct FFrame &, void * const);
	void execFootStep(struct FFrame &, void * const);
	void execGetKillResult(struct FFrame &, void * const);
	void execGetMaxRotationOffset(struct FFrame &, void * const);
	void execGetMovementDirection(struct FFrame &, void * const);
	void execGetPeekingRatioNorm(struct FFrame &, void * const);
	void execGetRotationOffset(struct FFrame &, void * const);
	void execGetStunResult(struct FFrame &, void * const);
	void execGetThroughResult(struct FFrame &, void * const);
	void execMoveHitBone(struct FFrame &, void * const);
	void execPawnCanBeHurtFrom(struct FFrame &, void * const);
	void execPawnLook(struct FFrame &, void * const);
	void execPawnLookAbsolute(struct FFrame &, void * const);
	void execPawnLookAt(struct FFrame &, void * const);
	void execPawnTrackActor(struct FFrame &, void * const);
	void execPlayVoices(struct FFrame &, void * const);
	void execR6GetViewRotation(struct FFrame &, void * const);
	void execSendPlaySound(struct FFrame &, void * const);
	void execSetAudioInfo(struct FFrame &, void * const);
	void execSetPawnScale(struct FFrame &, void * const);
	void execStartLipSynch(struct FFrame &, void * const);
	void execStopLipSynch(struct FFrame &, void * const);
	void execToggleHeatProperties(struct FFrame &, void * const);
	void execToggleNightProperties(struct FFrame &, void * const);
	void execToggleScopeProperties(struct FFrame &, void * const);
	void execUpdatePawnTrackActor(struct FFrame &, void * const);
	INT AdjustFluidCollisionCylinder(FLOAT, INT);
	FLOAT AdjustMaxFluidPeeking(FLOAT, FLOAT);
	INT CheckLineOfSight(AActor *, FVector &, INT, AActor *, FVector &, AActor *, FVector &);
	DWORD CheckSeePawn(AR6Pawn *, FVector &, INT);
	FLOAT ComputeCrouchBlendRate(FLOAT, FLOAT);
	void Crawl(INT);
	INT DirectionHasChanged(FLOAT);
	BYTE GetAnimState();
	BYTE GetCurrentMaterial();
	void GetDefaultHeightAndRadius(FLOAT &, FLOAT &, FLOAT &);
	FVector GetFootLocation(AActor *);
	FVector GetHeadLocation(AActor *);
	FLOAT GetMaxFluidPeeking(FLOAT, INT);
	FVector GetMidSectionLocation(AActor *);
	enum eMovementDirection GetMovementDirection();
	FLOAT GetPeekingRatioNorm(FLOAT);
	INT GetRotValueCenteredAroundZero(INT);
	FRotator GetRotationOffset();
	BYTE GetSoundGunType(INT);
	INT IsCrawling();
	INT IsUsingHeartBeatSensor();
	void PawnLook(FRotator, INT, INT);
	void PawnLookAbsolute(FRotator, INT, INT);
	void PawnLookAt(FVector, INT, INT);
	void PawnSetBoneRotation(FName, INT, INT, INT, FLOAT);
	void PawnTrackActor(AActor *, INT);
	INT PickActorAdjust(AActor *);
	void ResetColBox();
	INT SetAudioInfo();
	void SetPawnLookAndAimDirection(FRotator, INT);
	void SetPawnLookDirection(FRotator, INT);
	void UnCrawl(INT);
	FLOAT UpdateColBoxPeeking(FLOAT);
	void UpdateFullPeekingMode(FLOAT);
	void UpdatePawnTrackActor(INT);
	void UpdatePeeking(FLOAT);
	void WeaponFollow(INT, FLOAT);
	INT WeaponIsAGadget();
	void WeaponLock(INT, FLOAT, FLOAT);
	INT WeaponShouldFollowHead();
	INT actorReachableFromLocation(AActor *, FVector);
	FVector eventGetFiringStartPoint();
	DWORD eventIsFullPeekingOver();
	DWORD eventIsPeekingLeft();
	INT getMaxRotationOffset(INT);
	void initCrawlMode(bool);
	void m_vExecuteLipsSynch(FLOAT);
	void m_vInitNewLipSynch(USound *, USound *);
	INT moveToPosition(FVector const &);

public:
	AR6Pawn() {}
};

/*==========================================================================
	UR6Voices
==========================================================================*/

class R6ENGINE_API UR6Voices : public UObject
{
public:

protected:
	UR6Voices() {}
};

/*==========================================================================
	UR6InteractiveObjectAction
==========================================================================*/

class R6ENGINE_API UR6InteractiveObjectAction : public UObject
{
public:
	BYTE m_eType;
	USound* m_eSoundToPlay;
	USound* m_eSoundToPlayStop;
	FRange m_SoundRange;


protected:
	UR6InteractiveObjectAction() {}
};

/*==========================================================================
	AR6IOBomb
==========================================================================*/

class R6ENGINE_API AR6IOBomb : public AR6IOObject
{
public:
	DECLARE_CLASS(AR6IOBomb, AR6IOObject, 0, R6Engine)

	BYTE m_eBeepState;
	INT m_iEnergy;
	BITFIELD bShowLog : 1;
	BITFIELD m_bExploded : 1;
	FLOAT m_fTimeOfExplosion;
	FLOAT m_fTimeLeft;
	FLOAT m_fRepTimeLeft;
	FLOAT m_fLastLevelTime;
	FLOAT m_fDisarmBombTimeMin;
	FLOAT m_fDisarmBombTimeMax;
	FLOAT m_fExplosionRadius;
	FLOAT m_fKillBlastRadius;
	UMaterial* m_ArmedTexture;
	USound* m_sndActivationBomb;
	USound* m_sndPlayBeepNormal;
	USound* m_sndStopBeepNormal;
	USound* m_sndPlayBeepFast;
	USound* m_sndStopBeepFast;
	USound* m_sndPlayBeepFaster;
	USound* m_sndStopBeepFaster;
	USound* m_sndExplosion;
	USound* m_sndEarthQuake;
	AEmitter* m_pEmmiter;
	UClass* m_pExplosionLight;
	FVector m_vOffset;
	FString m_szIdentityID;
	FString m_szIdentity;
	FString m_szMsgArmedID;
	FString m_szMsgDisarmedID;
	FString m_szMissionObjLocalization;


protected:
	AR6IOBomb() {}
};

/*==========================================================================
	AR6DeploymentZone
==========================================================================*/

class R6ENGINE_API AR6DeploymentZone : public AActor
{
public:
	DECLARE_CLASS(AR6DeploymentZone, AActor, 0, R6Engine)

	BYTE m_eDefCon;
	BYTE m_eEngageReaction;
	INT m_iGroupID;
	INT m_HostageShootChance;
	INT m_iMinTerrorist;
	INT m_iMaxTerrorist;
	INT m_iChanceToUseGrenadeAtFirstReaction;
	INT m_iMinHostage;
	INT m_iMaxHostage;
	INT m_iPrisonerTeam;
	BITFIELD m_bDontSeePlayer : 1;
	BITFIELD m_bDontHearPlayer : 1;
	BITFIELD m_bHearNothing : 1;
	BITFIELD m_bAllowLeave : 1;
	BITFIELD m_bPreventCrouching : 1;
	BITFIELD m_bKnowInPlanning : 1;
	BITFIELD m_bHuntDisallowed : 1;
	BITFIELD m_bHuntFromStart : 1;
	BITFIELD m_bAlreadyInitialized : 1;
	BITFIELD m_bUseGrenade : 1;
	BITFIELD m_bClassicMissionCivilian : 1;
	AR6InteractiveObject* m_InteractiveObject;
	TArray<INT> m_iGroupIDsToCall;
	TArray<AR6DeploymentZone*> m_HostageZoneToCheck;
	TArray<APathNode*> m_pListOfCoverNodes;
	TArray<AR6Terrorist*> m_aTerrorist;
	TArray<AR6Hostage*> m_aHostage;
	FSTTemplate m_Template[5];
	FSTTemplate m_HostageTemplates[5];

	virtual void Spawned();
	virtual void RenderEditorInfo(FLevelSceneNode *, FRenderInterface *, FDynamicActor *);
	virtual void CheckForErrors();
	virtual INT GetNbOfTerroristToSpawn();
	virtual void FirstInit();
	virtual FVector FindRandomPointInArea();
	virtual FVector FindSpawningPoint(FRotator *, INT *, enum EStance *, INT *);
	virtual INT IsPointInZone(FVector const &);
	virtual FVector FindClosestPointTo(FVector const &);
	virtual void InitTerroristAI(FR6CharTemplate *, AR6Terrorist *);
	void execAddHostage(struct FFrame &, void * const);
	void execFindClosestPointTo(struct FFrame &, void * const);
	void execFindRandomPointInArea(struct FFrame &, void * const);
	void execFirstInit(struct FFrame &, void * const);
	void execGetClosestHostage(struct FFrame &, void * const);
	void execHaveHostage(struct FFrame &, void * const);
	void execHaveTerrorist(struct FFrame &, void * const);
	void execIsPointInZone(struct FFrame &, void * const);
	void execOrderTerroListFromDistanceTo(struct FFrame &, void * const);
	void CheckForErrors(bool);
	INT HaveHostage();
	INT HavePlaceForPawnAt(FVector &);
	INT HaveTerrorist();
	void InitHostageAI(FR6CharTemplate *, AR6Hostage *);
	void SpawnAHostage();
	void SpawnATerrorist();
	INT getChanceFromArrayTemplates(struct FSTTemplate *, INT);

public:
	AR6DeploymentZone() {}
};

/*==========================================================================
	AR6Hostage
==========================================================================*/

class R6ENGINE_API AR6Hostage : public AR6Pawn
{
public:
	DECLARE_CLASS(AR6Hostage, AR6Pawn, 0, R6Engine)

	BYTE m_ePersonality;
	BYTE m_ePosition;
	BYTE m_eCivPatrol;
	BYTE m_eHandsUpType;
	BYTE m_bRepWaitAnimIndex;
	BYTE m_bSavedRepWaitAnimIndex;
	INT m_iIndex;
	INT m_iPrisonierTeam;
	BITFIELD m_bInitFinished : 1;
	BITFIELD m_bStartAsCivilian : 1;
	BITFIELD m_bCivilian : 1;
	BITFIELD m_bPatrolForward : 1;
	BITFIELD m_bPoliceManMp1 : 1;
	BITFIELD m_bPoliceManHasWeapon : 1;
	BITFIELD m_bPoliceManCanSeeRainbows : 1;
	BITFIELD m_bIsKneeling : 1;
	BITFIELD m_bIsFoetus : 1;
	BITFIELD m_bFrozen : 1;
	BITFIELD m_bReactionAnim : 1;
	BITFIELD m_bCrouchToScaredStandBegin : 1;
	BITFIELD m_bFreed : 1;
	BITFIELD m_bEscorted : 1;
	BITFIELD m_bExtracted : 1;
	BITFIELD m_bFeedbackExtracted : 1;
	BITFIELD m_bClassicMissionCivilian : 1;
	AR6DeploymentZone* m_DZone;
	AR6DZonePathNode* m_currentNode;
	AR6HostageMgr* m_mgr;
	AR6HostageAI* m_controller;
	AR6Rainbow* m_escortedByRainbow;
	FName m_NocsWaitingName;
	FName m_NocsSeeRainbowsName;
	FName m_globalState;
	FRandomTweenNum m_stayInFoetusTime;
	FRandomTweenNum m_stayFrozenTime;
	FRandomTweenNum m_stayProneTime;
	FRandomTweenNum m_stayCautiousGuardedStateTime;
	FRandomTweenNum m_patrolAreaWaitTween;
	FRandomTweenNum m_changeOrientationTween;
	FRandomTweenNum m_sightRadiusTween;
	FRandomTweenNum m_updatePaceTween;
	FRandomTweenNum m_waitingGoCrouchTween;
	FSTRepHostageAnim m_eSavedRepHostageAnim;
	FSTRepHostageAnim m_eCurrentRepHostageAnim;
	FString m_szUsedTemplate;

	void eventFinishInitialization();
	void eventGotoCrouch();
	void eventGotoFoetus();
	void eventGotoKneel();
	void eventGotoProne();
	void eventGotoStand();
	void eventSetAnimInfo(INT);

protected:
	AR6Hostage() {}
};

/*==========================================================================
	AR6AIController
==========================================================================*/

class R6ENGINE_API AR6AIController : public AAIController
{
public:
	DECLARE_CLASS(AR6AIController, AAIController, 0, R6Engine)

	INT c_iDistanceBumpBackUp;
	INT m_iCurrentRouteCache;
	BITFIELD m_bStateBackupAvoidFacingWalls : 1;
	BITFIELD m_bIgnoreBackupBump : 1;
	BITFIELD m_bGetOffLadder : 1;
	BITFIELD bShowLog : 1;
	BITFIELD bShowInteractionLog : 1;
	BITFIELD m_bChangingState : 1;
	BITFIELD m_bCantInterruptIO : 1;
	BITFIELD m_bMoveTargetAlreadySet : 1;
	FLOAT m_fLastBump;
	FLOAT m_fLoopAnimTime;
	AR6Pawn* m_r6pawn;
	AR6Ladder* m_TargetLadder;
	AActor* m_BumpedBy;
	AR6ClimbableObject* m_climbingObject;
	AR6InteractiveObject* m_InteractionObject;
	AActor* m_ActorTarget;
	AR6IORotatingDoor* m_closeDoor;
	FName m_bumpBackUpNextState;
	FName m_openDoorNextState;
	FName m_climbingObjectNextState;
	FName m_AnimName;
	FName m_StateAfterInteraction;
	FVector m_vTargetPosition;
	FVector m_vPreviousPosition;
	FVector m_vBumpedByLocation;
	FVector m_vBumpedByVelocity;

	virtual INT CanHear(FVector, FLOAT, AActor *, enum ENoiseType, enum EPawnType);
	virtual void AdjustFromWall(FVector, AActor *);
	void eventOpenDoorFailed();
	void eventR6SetMovement(BYTE);
	void execActorReachableFromLocation(struct FFrame &, void * const);
	void execCanWalkTo(struct FFrame &, void * const);
	void execFindGrenadeDirectionToHitActor(struct FFrame &, void * const);
	void execFindInvestigationPoint(struct FFrame &, void * const);
	void execFindNearbyWaitSpot(struct FFrame &, void * const);
	void execFindPlaceToFire(struct FFrame &, void * const);
	void execFindPlaceToTakeCover(struct FFrame &, void * const);
	void execFollowPath(struct FFrame &, void * const);
	void execFollowPathTo(struct FFrame &, void * const);
	void execGotoOpenDoorState(struct FFrame &, void * const);
	void execMakePathToRun(struct FFrame &, void * const);
	void execMoveToPosition(struct FFrame &, void * const);
	void execNeedToOpenDoor(struct FFrame &, void * const);
	void execPickActorAdjust(struct FFrame &, void * const);
	void execPollFollowPath(struct FFrame &, void * const);
	void execPollFollowPathBlocked(struct FFrame &, void * const);
	void execPollMoveToPosition(struct FFrame &, void * const);
	INT CanWalkTo(FVector, INT);
	void ClearActionSpot();
	AR6ActionSpot * FindNearestActionSpot(FLOAT, FVector, INT (CDECL*)(AR6Pawn *, AR6ActionSpot *, struct STActionSpotCheck &), struct STActionSpotCheck &);
	void FollowPath(enum eMovementPace, FName, INT);
	void GotoOpenDoorState(AActor *);
	INT HearingCheck(FVector, FVector);
	INT NeedToOpenDoor(AActor *);
	INT SetDestinationToNextInCache();
	DWORD eventCanOpenDoor(AR6IORotatingDoor *);

public:
	AR6AIController() {}
};

/*==========================================================================
	AR6Rainbow
==========================================================================*/

class R6ENGINE_API AR6Rainbow : public AR6Pawn
{
public:
	DECLARE_CLASS(AR6Rainbow, AR6Pawn, 0, R6Engine)

	BYTE m_u8DesiredPitch;
	BYTE m_u8CurrentPitch;
	BYTE m_u8DesiredYaw;
	BYTE m_u8CurrentYaw;
	BYTE m_eLadderSlide;
	BYTE m_eEquipWeapon;
	INT m_iOperativeID;
	INT m_iCurrentWeapon;
	INT m_iKills;
	INT m_iBulletsFired;
	INT m_iBulletsHit;
	INT m_iExtraPrimaryClips;
	INT m_iExtraSecondaryClips;
	INT m_iRainbowFaceID;
	BITFIELD m_bHasDataObject : 1;
	BITFIELD m_bIsTheIntruder : 1;
	BITFIELD m_bTweenFirstTimeOnly : 1;
	BITFIELD m_bHasLockPickKit : 1;
	BITFIELD m_bHasDiffuseKit : 1;
	BITFIELD m_bHasElectronicsKit : 1;
	BITFIELD m_bWeaponIsSecured : 1;
	BITFIELD m_bThrowGrenadeWithLeftHand : 1;
	BITFIELD m_bIsLockPicking : 1;
	BITFIELD m_bReloadToFullAmmo : 1;
	BITFIELD m_bScaleGasMaskForFemale : 1;
	BITFIELD m_bInitRainbow : 1;
	BITFIELD m_bGettingOnLadder : 1;
	BITFIELD m_bRainbowIsFemale : 1;
	BITFIELD m_bIsSurrended : 1;
	BITFIELD m_bIsUnderArrest : 1;
	BITFIELD m_bIsBeingArrestedOrFreed : 1;
	UMaterial* m_FaceTexture;
	AR6GasMask* m_GasMask;
	AR6AbstractHelmet* m_Helmet;
	AR6NightVision* m_NightVision;
	AR6EngineWeapon* m_preSwitchWeapon;
	AR6Hostage* m_aEscortedHostage[4];
	UClass* m_GasMaskClass;
	UClass* m_NightVisionClass;
	FRotator m_rFiringRotation;
	FPlane m_FaceCoords;
	FVector m_vStartLocation;
	FString m_szPrimaryWeapon;
	FString m_szPrimaryGadget;
	FString m_szPrimaryBulletType;
	FString m_szSecondaryWeapon;
	FString m_szSecondaryGadget;
	FString m_szSecondaryBulletType;
	FString m_szPrimaryItem;
	FString m_szSecondaryItem;
	FString m_szSpecialityID;

	void UpdateAiming();

public:
	AR6Rainbow() {}
};

/*==========================================================================
	AR6Terrorist
==========================================================================*/

class R6ENGINE_API AR6Terrorist : public AR6Pawn
{
public:
	DECLARE_CLASS(AR6Terrorist, AR6Pawn, 0, R6Engine)

	BYTE m_eDefCon;
	BYTE m_ePersonality;
	BYTE m_eStrategy;
	BYTE m_eStartingStance;
	BYTE m_eHeadAttachmentType;
	BYTE m_eTerroType;
	BYTE m_eSpecialAnimValid;
	BYTE m_wWantedAimingPitch;
	BYTE m_wWantedHeadYaw;
	INT m_iGroupID;
	INT m_iCurrentAimingPitch;
	INT m_iCurrentHeadYaw;
	INT m_iDiffLevel;
	BITFIELD m_bBoltActionRifle : 1;
	BITFIELD m_bHaveAGrenade : 1;
	BITFIELD m_bInitFinished : 1;
	BITFIELD m_bAllowLeave : 1;
	BITFIELD m_bPreventCrouching : 1;
	BITFIELD m_bHearNothing : 1;
	BITFIELD m_bSprayFire : 1;
	BITFIELD m_bPreventWeaponAnimation : 1;
	BITFIELD m_bIsUnderArrest : 1;
	BITFIELD m_bPatrolForward : 1;
	BITFIELD m_bEnteringView : 1;
	FLOAT m_fPlayerCAStartTime;
	AR6THeadAttachment* m_HeadAttachment;
	AActor* m_Radio;
	AR6TerroristAI* m_controller;
	AR6DeploymentZone* m_DZone;
	FName m_szSpecialAnimName;
	FRotator m_rFiringRotation;
	FString m_szUsedTemplate;
	FString m_szPrimaryWeapon;
	FString m_szGrenadeWeapon;
	FString m_szGadget;

	virtual void PreNetReceive();
	virtual void PostNetReceive();
	void eventFinishInitialization();
	void eventLoopSpecialAnim();
	void eventPlaySpecialAnim();
	void eventStopSpecialAnim();
	void UpdateAiming(FLOAT);

public:
	AR6Terrorist() {}
};

/*==========================================================================
	AR6GenericHB
==========================================================================*/

class R6ENGINE_API AR6GenericHB : public AR6InteractiveObject
{
public:
	DECLARE_CLASS(AR6GenericHB, AR6InteractiveObject, 0, R6Engine)

	BITFIELD m_bFirstImpact : 1;
	USound* m_ImpactSound;
	USound* m_ImpactGroundSound;
	USound* m_ImpactWaterSound;


protected:
	AR6GenericHB() {}
};

/*==========================================================================
	UR6InteractionRoseDesVents
==========================================================================*/

class R6ENGINE_API UR6InteractionRoseDesVents : public UInteraction
{
public:
	INT m_iCurrentMnuChoice;
	INT m_iCurrentSubMnuChoice;
	INT C_iMouseDelta;
	BITFIELD m_bActionKeyDown : 1;
	BITFIELD m_bIgnoreNextActionKeyRelease : 1;
	BITFIELD bShowLog : 1;
	FLOAT m_iTextureWidth;
	FLOAT m_iTextureHeight;
	AR6PlayerController* m_Player;
	UTexture* m_TexMNU;
	UTexture* m_TexMNUItemNormalTop;
	UTexture* m_TexMNUItemNormalLeft;
	UTexture* m_TexMNUItemNormalSubTop;
	UTexture* m_TexMNUItemNormalSubLeft;
	UTexture* m_TexMNUItemSelectedSubTop;
	UTexture* m_TexMNUItemSelectedSubLeft;
	UTexture* m_TexMNUItemSelectedTop;
	UTexture* m_TexMNUItemSelectedLeft;
	UFont* m_Font;
	USound* m_RoseOpenSnd;
	USound* m_RoseSelectSnd;
	FColor m_color;
	FString m_ActionKey;


protected:
	UR6InteractionRoseDesVents() {}
};

/*==========================================================================
	AR6ReferenceIcons
==========================================================================*/

class R6ENGINE_API AR6ReferenceIcons : public AActor
{
public:

protected:
	AR6ReferenceIcons() {}
};

/*==========================================================================
	UR6CommonRainbowVoices
==========================================================================*/

class R6ENGINE_API UR6CommonRainbowVoices : public UR6Voices
{
public:
	USound* m_sndTerroristDown;
	USound* m_sndTakeWound;
	USound* m_sndGoesDown;
	USound* m_sndEntersSmoke;
	USound* m_sndEntersGas;
	USound* m_sndCoughOxygene;
	USound* m_sndSuffocation;


protected:
	UR6CommonRainbowVoices() {}
};

/*==========================================================================
	UR6MultiCoopVoices
==========================================================================*/

class R6ENGINE_API UR6MultiCoopVoices : public UR6Voices
{
public:
	USound* m_sndPlacingBug;
	USound* m_sndBugActivated;
	USound* m_sndAccessingComputer;
	USound* m_sndComputerHacked;
	USound* m_sndEscortingHostage;
	USound* m_sndHostageSecured;
	USound* m_sndPlacingExplosives;
	USound* m_sndExplosivesReady;
	USound* m_sndDesactivatingSecurity;
	USound* m_sndSecurityDeactivated;


protected:
	UR6MultiCoopVoices() {}
};

/*==========================================================================
	UR6RainbowOtherTeamVoices
==========================================================================*/

class R6ENGINE_API UR6RainbowOtherTeamVoices : public UR6Voices
{
public:
	USound* m_sndSniperHasTarget;
	USound* m_sndSniperLooseTarget;
	USound* m_sndSniperTangoDown;
	USound* m_sndMemberDown;
	USound* m_sndRainbowHitRainbow;
	USound* m_sndObjective1;
	USound* m_sndObjective2;
	USound* m_sndObjective3;
	USound* m_sndObjective4;
	USound* m_sndObjective5;
	USound* m_sndObjective6;
	USound* m_sndObjective7;
	USound* m_sndObjective8;
	USound* m_sndObjective9;
	USound* m_sndObjective10;
	USound* m_sndWaitAlpha;
	USound* m_sndWaitBravo;
	USound* m_sndWaitCharlie;
	USound* m_sndWaitZulu;
	USound* m_sndEntersSmoke;
	USound* m_sndEntersGas;
	USound* m_sndPlacingBug;
	USound* m_sndBugActivated;
	USound* m_sndAccessingComputer;
	USound* m_sndComputerHacked;
	USound* m_sndEscortingHostage;
	USound* m_sndHostageSecured;
	USound* m_sndPlacingExplosives;
	USound* m_sndExplosivesReady;
	USound* m_sndDesactivatingSecurity;
	USound* m_sndSecurityDeactivated;
	USound* m_sndStatusEngaging;
	USound* m_sndStatusMoving;
	USound* m_sndStatusWaiting;
	USound* m_sndStatusWaitAlpha;
	USound* m_sndStatusWaitBravo;
	USound* m_sndStatusWaitCharlie;
	USound* m_sndStatusWaitZulu;
	USound* m_sndStatusSniperWaitAlpha;
	USound* m_sndStatusSniperWaitBravo;
	USound* m_sndStatusSniperWaitCharlie;
	USound* m_sndStatusSniperUntilAlpha;
	USound* m_sndStatusSniperUntilBravo;
	USound* m_sndStatusSniperUntilCharlie;


protected:
	UR6RainbowOtherTeamVoices() {}
};

/*==========================================================================
	AR6BloodSplat
==========================================================================*/

class R6ENGINE_API AR6BloodSplat : public AR6DecalsBase
{
public:
	UTexture* m_BloodSplatTexture;


protected:
	AR6BloodSplat() {}
};

/*==========================================================================
	UR6TerroristVoices
==========================================================================*/

class R6ENGINE_API UR6TerroristVoices : public UR6Voices
{
public:
	USound* m_sndWounded;
	USound* m_sndTaunt;
	USound* m_sndSurrender;
	USound* m_sndSeesTearGas;
	USound* m_sndRunAway;
	USound* m_sndGrenade;
	USound* m_sndCoughsSmoke;
	USound* m_sndCoughsGas;
	USound* m_sndBackup;
	USound* m_sndSeesSurrenderedHostage;
	USound* m_sndSeesRainbow_LowAlert;
	USound* m_sndSeesRainbow_HighAlert;
	USound* m_sndSeesFreeHostage;
	USound* m_sndHearsNoize;


protected:
	UR6TerroristVoices() {}
};

/*==========================================================================
	UR6InteractiveObjectActionPlayAnim
==========================================================================*/

class R6ENGINE_API UR6InteractiveObjectActionPlayAnim : public UR6InteractiveObjectAction
{
public:
	FName m_vAnimName;


protected:
	UR6InteractiveObjectActionPlayAnim() {}
};

/*==========================================================================
	UR6HostageVoices
==========================================================================*/

class R6ENGINE_API UR6HostageVoices : public UR6Voices
{
public:
	USound* m_sndRun;
	USound* m_sndFrozen;
	USound* m_sndFoetal;
	USound* m_sndHears_Shooting;
	USound* m_sndRnbFollow;
	USound* m_sndRndStayPut;
	USound* m_sndRnbHurt;
	USound* m_sndEntersGas;
	USound* m_sndEntersSmoke;
	USound* m_sndClarkReprimand;


protected:
	UR6HostageVoices() {}
};

/*==========================================================================
	UR6PlayAnim
==========================================================================*/

class R6ENGINE_API UR6PlayAnim : public UObject
{
public:
	DECLARE_CLASS(UR6PlayAnim, UObject, 0, R6Engine)

	INT m_MaxPlayTime;
	INT m_PlayedTime;
	INT m_iFrameNumber;
	BITFIELD m_bLoopAnim : 1;
	BITFIELD m_bStarted : 1;
	BITFIELD m_bFirstTime : 1;
	FLOAT m_Rate;
	FLOAT m_TweenTime;
	FLOAT m_fBeginPct;
	FLOAT m_fEndPct;
	AActor* m_AttachActor;
	FName m_Sequence;
	FName m_PawnTag;
	FString m_StaticMeshTag;

	void eventAnimFinished();

public:
	UR6PlayAnim() {}
};

/*==========================================================================
	UR6MatineeAttach
==========================================================================*/

class R6ENGINE_API UR6MatineeAttach : public UObject
{
public:
	DECLARE_CLASS(UR6MatineeAttach, UObject, 0, R6Engine)

	BITFIELD m_bInitialized : 1;
	AActor* m_AttachActor;
	AR6Pawn* m_AttachPawn;
	FName m_PawnTag;
	FName m_BoneName;
	FVector m_InteractionPos;
	FRotator m_InteractionRot;
	FVector m_OffsetPos;
	FRotator m_OffsetRot;
	FString m_StaticMeshTag;

	void execGetBoneInformation(struct FFrame &, void * const);
	void execTestLocation(struct FFrame &, void * const);

protected:
	UR6MatineeAttach() {}
};

/*==========================================================================
	UR6SubActionAnimSequence
==========================================================================*/

class R6ENGINE_API UR6SubActionAnimSequence : public UMatSubAction
{
public:
	DECLARE_CLASS(UR6SubActionAnimSequence, UMatSubAction, 0, R6Engine)

	INT m_CurIndex;
	BITFIELD m_bUseRootMotion : 1;
	BITFIELD m_bFirstTime : 1;
	BITFIELD m_bResetAnimation : 1;
	AR6Pawn* m_AffectedPawn;
	AActor* m_AffectedActor;
	UR6PlayAnim* m_CurSequence;
	TArray<UR6PlayAnim*> m_Sequences;

	virtual INT Update(FLOAT, ASceneManager *);
	virtual FString GetStatString();
	virtual void PreBeginPreview();
	virtual INT UpdateGame(FLOAT, ASceneManager *);
	void eventSequenceChanged();
	void eventSequenceFinished();
	FLOAT GetAnimDuration(UR6PlayAnim *);
	UR6PlayAnim * GetAnimation(FLOAT);
	FLOAT GetCurAnimPct(FLOAT);
	FLOAT GetTotalLength();
	INT IncrementSequence();
	INT IsAnimAtFrame(INT, INT);
	INT LaunchSequence();
	FLOAT PctToFrameNumber(UR6PlayAnim *, FLOAT);

public:
	UR6SubActionAnimSequence() {}
};

/*==========================================================================
	UR6SubActionLookAt
==========================================================================*/

class R6ENGINE_API UR6SubActionLookAt : public UMatSubAction
{
public:
	DECLARE_CLASS(UR6SubActionLookAt, UMatSubAction, 0, R6Engine)

	BITFIELD m_bAim : 1;
	BITFIELD m_bNoBlend : 1;
	AR6Pawn* m_AffectedPawn;
	AActor* m_TargetActor;

	virtual INT Update(FLOAT, ASceneManager *);
	virtual FString GetStatString();

public:
	UR6SubActionLookAt() {}
};

/*==========================================================================
	AMP2IOKarma
==========================================================================*/

class R6ENGINE_API AMP2IOKarma : public AR6InteractiveObject
{
public:
	DECLARE_CLASS(AMP2IOKarma, AR6InteractiveObject, 0, R6Engine)

	BYTE m_eReactionType;
	BYTE SavePhysics;
	BYTE SaveReactionType;
	BITFIELD bCollideRagDoll : 1;
	BITFIELD bUseSafeTimeWithLevel : 1;
	BITFIELD bUseSafeTimeWithSM : 1;
	BITFIELD bHideBefore : 1;
	BITFIELD bHideAfter : 1;
	BITFIELD bHideCollision : 1;
	BITFIELD bSimulationActive : 1;
	BITFIELD m_bOneTime : 1;
	BITFIELD SavebCollideActors : 1;
	BITFIELD SavebBlockActors : 1;
	BITFIELD SavebBlockPlayers : 1;
	FLOAT m_fMaxSimAge;
	FLOAT m_fLoseTime;
	FLOAT m_fCurrentLoseTime;
	FLOAT m_fCurrentSimAge;
	FLOAT m_fZMin;
	FLOAT m_fScaleStartLinVel;
	FLOAT ImpactVolume;
	FLOAT ImpactInterval;
	TArray<FstZDR> m_ZDRList;
	TArray<USound*> ImpactSounds;
	TArray<FstActorReactionState> m_ActorReactionList;
	FVector SaveLocation;
	FRotator SaveRotation;
	FLOAT LastImpactTime;

	virtual void CheckForErrors();
	virtual void RenderEditorInfo(FLevelSceneNode *, FRenderInterface *, FDynamicActor *);
	virtual INT KMP2DynKarmaInterface(INT, FVector, FRotator, AActor *);
	void eventReinitSimulation(INT);
	void eventStartSimulation(INT);
	void eventStopSimulation(INT);
	void eventZDRSetDamageState(INT, FLOAT, FVector);
	void execMP2IOKarmaAllNativeFct(struct FFrame &, void * const);

public:
	AMP2IOKarma() {}
};

/*==========================================================================
	AR6GameReplicationInfo
==========================================================================*/

class R6ENGINE_API AR6GameReplicationInfo : public AGameReplicationInfo
{
public:
	DECLARE_CLASS(AR6GameReplicationInfo, AGameReplicationInfo, 0, R6Engine)

	INT m_iDeathCameraMode;
	INT m_MaxPlayers;
	INT m_iCurrentRound;
	INT m_iRoundsPerMatch;
	INT m_iDiffLevel;
	INT m_iNbOfTerro;
	INT m_iMenuCountDownTime;
	INT m_aTeamScore[2];
	INT c_iTeamNumBravo;
	BITFIELD bShowLog : 1;
	BITFIELD m_bPasswordReq : 1;
	BITFIELD m_bAdminPasswordReq : 1;
	BITFIELD m_bFriendlyFire : 1;
	BITFIELD m_bAutoBalance : 1;
	BITFIELD m_bTKPenalty : 1;
	BITFIELD m_bMenuTKPenaltySetting : 1;
	BITFIELD m_bShowNames : 1;
	BITFIELD m_bInternetSvr : 1;
	BITFIELD m_bFFPWeapon : 1;
	BITFIELD m_bDedicatedSvr : 1;
	BITFIELD m_bAIBkp : 1;
	BITFIELD m_bRotateMap : 1;
	BITFIELD m_bRepMenuCountDownTimePaused : 1;
	BITFIELD m_bRepMenuCountDownTimeUnlimited : 1;
	BITFIELD m_bIsWritableMapAllowed : 1;
	FLOAT m_fTimeBetRounds;
	FLOAT m_fBombTime;
	FLOAT m_fRepMenuCountDownTime;
	FLOAT m_fRepMenuCountDownTimeLastUpdate;
	AR6RainbowTeam* m_RainbowTeam[3];
	UR6GameMenuCom* m_MenuCommunication;
	FString m_szCurrGameType;
	FString m_mapArray[32];
	FString m_gameModeArray[32];
	FString m_szSubMachineGunsRes[32];
	FString m_szShotGunRes[32];
	FString m_szAssRifleRes[32];
	FString m_szMachGunRes[32];
	FString m_szSnipRifleRes[32];
	FString m_szPistolRes[32];
	FString m_szMachPistolRes[32];
	FString m_szGadgPrimaryRes[32];
	FString m_szGadgSecondayRes[32];
	FString m_szGadgMiscRes[32];

	FLOAT eventGetRoundTime();

protected:
	AR6GameReplicationInfo() {}
};

/*==========================================================================
	AR6ClimbablePoint
==========================================================================*/

class R6ENGINE_API AR6ClimbablePoint : public ANavigationPoint
{
public:
	DECLARE_CLASS(AR6ClimbablePoint, ANavigationPoint, 0, R6Engine)

	AR6ClimbableObject* m_climbableObj;
	AR6ClimbablePoint* m_connectedClimbablePoint;
	FVector m_vLookDir;

	virtual INT ProscribedPathTo(ANavigationPoint *);
	virtual void addReachSpecs(APawn *, INT);
	virtual void InitForPathFinding();
	virtual void ClearPaths();

public:
	AR6ClimbablePoint() {}
};

/*==========================================================================
	AR6ClimbableObject
==========================================================================*/

class R6ENGINE_API AR6ClimbableObject : public AR6AbstractClimbableObj
{
public:
	DECLARE_CLASS(AR6ClimbableObject, AR6AbstractClimbableObj, 0, R6Engine)

	BYTE m_eClimbHeight;
	AR6ClimbablePoint* m_climbablePoint;
	AR6ClimbablePoint* m_insideClimbablePoint;
	FVector m_vClimbDir;

	virtual void PostScriptDestroyed();
	virtual INT ShouldTrace(AActor *, DWORD);
	virtual void AddMyMarker(AActor *);
	virtual void CheckForErrors();

public:
	AR6ClimbableObject() {}
};

/*==========================================================================
	AR6IOSound
==========================================================================*/

class R6ENGINE_API AR6IOSound : public AActor
{
public:
	DECLARE_CLASS(AR6IOSound, AActor, 0, R6Engine)


protected:
	AR6IOSound() {}
};

/*==========================================================================
	AR6IORotatingDoor
==========================================================================*/

class R6ENGINE_API AR6IORotatingDoor : public AR6IActionObject
{
public:
	DECLARE_CLASS(AR6IORotatingDoor, AR6IActionObject, 0, R6Engine)

	INT m_iLockHP;
	INT m_iCurrentLockHP;
	INT m_iMaxOpeningDeg;
	INT m_iInitialOpeningDeg;
	INT m_iYawInit;
	INT m_iYawMax;
	INT m_iMaxOpening;
	INT m_iInitialOpening;
	INT m_iCurrentOpening;
	BITFIELD m_bTreatDoorAsWindow : 1;
	BITFIELD bShowLog : 1;
	BITFIELD m_bInProcessOfClosing : 1;
	BITFIELD m_bInProcessOfOpening : 1;
	BITFIELD m_bUseWheel : 1;
	BITFIELD m_bForceNoFormation : 1;
	BITFIELD m_bIsOpeningClockWise : 1;
	BITFIELD m_bIsDoorLocked : 1;
	BITFIELD sm_bIsDoorLocked : 1;
	BITFIELD m_bIsDoorClosed : 1;
	FLOAT m_fWindowWidth;
	FLOAT m_fUnlockBaseTime;
	AR6Door* m_DoorActorA;
	AR6Door* m_DoorActorB;
	USound* m_OpeningSound;
	USound* m_OpeningWheelSound;
	USound* m_ClosingSound;
	USound* m_ClosingWheelSound;
	USound* m_LockSound;
	USound* m_UnlockSound;
	USound* m_MoveAmbientSound;
	USound* m_MoveAmbientSoundStop;
	USound* m_LockPickSound;
	USound* m_LockPickSoundStop;
	USound* m_ExplosionSound;
	TArray<AR6AbstractBullet*> m_BreachAttached;
	FVector m_vNormal;
	FVector m_vCenterOfDoor;
	FVector m_vDoorADir2D;

	virtual void PreNetReceive();
	virtual void PostNetReceive();
	virtual void PostScriptDestroyed();
	virtual INT ShouldTrace(AActor *, DWORD);
	virtual INT IsMovingBrush() const;
	virtual void RenderEditorInfo(FLevelSceneNode *, FRenderInterface *, FDynamicActor *);
	virtual void AddMyMarker(AActor *);
	void execAddBreach(struct FFrame &, void * const);
	void execRemoveBreach(struct FFrame &, void * const);
	void execWillOpenOnTouch(struct FFrame &, void * const);
	INT DoorOpenTowards(FVector);
	INT WillOpenOnTouch(AR6Pawn *);

public:
	AR6IORotatingDoor() {}
};

/*==========================================================================
	AR6LadderVolume
==========================================================================*/

class R6ENGINE_API AR6LadderVolume : public ALadderVolume
{
public:
	DECLARE_CLASS(AR6LadderVolume, ALadderVolume, 0, R6Engine)

	BYTE m_eLadderEndDirection;
	BITFIELD bShowLog : 1;
	FLOAT m_fBottomLadderActionRange;
	AR6Ladder* m_TopLadder;
	AR6Ladder* m_BottomLadder;
	AR6LadderCollision* m_TopCollision;
	AR6LadderCollision* m_BottomCollision;
	AR6Pawn* m_Climber[6];
	USound* m_SlideSound;
	USound* m_SlideSoundStop;
	USound* m_HandSound;
	USound* m_FootSound;

	virtual INT ShouldTrace(AActor *, DWORD);
	virtual void AddMyMarker(AActor *);
	void eventSetPotentialClimber();

public:
	AR6LadderVolume() {}
};

/*==========================================================================
	UR6TerroristMgr
==========================================================================*/

class R6ENGINE_API UR6TerroristMgr : public UR6AbstractTerroristMgr
{
public:
	DECLARE_CLASS(UR6TerroristMgr, UR6AbstractTerroristMgr, 0, R6Engine)

	INT m_iCurrentMax;
	INT m_iCurrentGroupID;
	TArray<AR6DeploymentZone*> m_aDeploymentZoneWithHostage;
	FSTHostage m_ArrayHostage[16];

	void execFindNearestZoneForHostage(struct FFrame &, void * const);
	void execInit(struct FFrame &, void * const);

protected:
	UR6TerroristMgr() {}
};

/*==========================================================================
	AR6CoverSpot
==========================================================================*/

class R6ENGINE_API AR6CoverSpot : public ANavigationPoint
{
public:
	DECLARE_CLASS(AR6CoverSpot, ANavigationPoint, 0, R6Engine)

	BYTE m_eShotDir;

	virtual void RenderEditorInfo(FLevelSceneNode *, FRenderInterface *, FDynamicActor *);

public:
	AR6CoverSpot() {}
};

/*==========================================================================
	AR6StairVolume
==========================================================================*/

class R6ENGINE_API AR6StairVolume : public APhysicsVolume
{
public:
	DECLARE_CLASS(AR6StairVolume, APhysicsVolume, 0, R6Engine)

	BITFIELD m_bCreateIcon : 1;
	BITFIELD m_bRestrictedSpaceAtStairLimits : 1;
	BITFIELD m_bShowLog : 1;
	AR6StairOrientation* m_pStairOrientation;
	FVector m_vOrientationNorm;

	virtual void Spawned();
	virtual void PostScriptDestroyed();
	virtual void RenderEditorInfo(FLevelSceneNode *, FRenderInterface *, FDynamicActor *);
	virtual void AddMyMarker(AActor *);
	virtual void CheckForErrors();

public:
	AR6StairVolume() {}
};

/*==========================================================================
	AR6StairOrientation
==========================================================================*/

class R6ENGINE_API AR6StairOrientation : public AActor
{
public:
	DECLARE_CLASS(AR6StairOrientation, AActor, 0, R6Engine)

	AR6StairVolume* m_pStairVolume;

	virtual void PostScriptDestroyed();
	void linkWithStair(AR6StairVolume *);

public:
	AR6StairOrientation() {}
};

/*==========================================================================
	AR6DZoneRandomPointNode
==========================================================================*/

class R6ENGINE_API AR6DZoneRandomPointNode : public AActor
{
public:
	DECLARE_CLASS(AR6DZoneRandomPointNode, AActor, 0, R6Engine)

	BYTE m_eStance;
	INT m_iGroupID;
	BITFIELD m_bHighPriority : 1;
	BITFIELD m_bAllowLeave : 1;
	AR6DZoneRandomPoints* m_pZone;

	virtual void PostScriptDestroyed();
	virtual void RenderEditorInfo(FLevelSceneNode *, FRenderInterface *, FDynamicActor *);
	virtual void CheckForErrors();

public:
	AR6DZoneRandomPointNode() {}
};

/*==========================================================================
	AR6DZoneRandomPoints
==========================================================================*/

class R6ENGINE_API AR6DZoneRandomPoints : public AR6DeploymentZone
{
public:
	DECLARE_CLASS(AR6DZoneRandomPoints, AR6DeploymentZone, 0, R6Engine)

	BITFIELD m_bSelectNodeInEditor : 1;
	BITFIELD m_bUseAllowLeave : 1;
	BITFIELD m_bInInit : 1;
	TArray<AR6DZoneRandomPointNode*> m_aNode;
	TArray<AR6DZoneRandomPointNode*> m_aTempHighPriorityNode;
	TArray<AR6DZoneRandomPointNode*> m_aTempNode;

	virtual void Spawned();
	virtual void PostScriptDestroyed();
	virtual void RenderEditorInfo(FLevelSceneNode *, FRenderInterface *, FDynamicActor *);
	virtual void CheckForErrors();
	virtual INT GetNbOfTerroristToSpawn();
	virtual void FirstInit();
	virtual FVector FindRandomPointInArea();
	virtual FVector FindSpawningPoint(FRotator *, INT *, enum EStance *, INT *);
	virtual INT IsPointInZone(FVector const &);
	virtual FVector FindClosestPointTo(FVector const &);
	void DeleteANode(INT);
	void DeleteANode(AR6DZoneRandomPointNode *);
	void SpawnANewNode(FVector);

public:
	AR6DZoneRandomPoints() {}
};

/*==========================================================================
	AR6DZoneRectangle
==========================================================================*/

class R6ENGINE_API AR6DZoneRectangle : public AR6DeploymentZone
{
public:
	DECLARE_CLASS(AR6DZoneRectangle, AR6DeploymentZone, 0, R6Engine)

	FLOAT m_fX;
	FLOAT m_fY;


protected:
	AR6DZoneRectangle() {}
};

/*==========================================================================
	AR6DZonePoint
==========================================================================*/

class R6ENGINE_API AR6DZonePoint : public AR6DeploymentZone
{
public:
	DECLARE_CLASS(AR6DZonePoint, AR6DeploymentZone, 0, R6Engine)

	BYTE m_eStance;
	BITFIELD m_bUseReactionZone : 1;
	FLOAT m_fReactionZoneX;
	FLOAT m_fReactionZoneY;
	FVector m_vReactionZoneCenter;

	virtual void Spawned();
	virtual void RenderEditorInfo(FLevelSceneNode *, FRenderInterface *, FDynamicActor *);
	virtual FVector FindRandomPointInArea();
	virtual FVector FindSpawningPoint(FRotator *, INT *, enum EStance *, INT *);
	virtual INT IsPointInZone(FVector const &);
	virtual FVector FindClosestPointTo(FVector const &);

public:
	AR6DZonePoint() {}
};

/*==========================================================================
	AR6DZonePathNode
==========================================================================*/

class R6ENGINE_API AR6DZonePathNode : public AActor
{
public:
	DECLARE_CLASS(AR6DZonePathNode, AActor, 0, R6Engine)

	INT m_AnimChance;
	BITFIELD m_bWait : 1;
	FLOAT m_fRadius;
	AR6DZonePath* m_pPath;
	USound* m_SoundToPlay;
	USound* m_SoundToPlayStop;
	FName m_AnimToPlay;

	virtual void PostScriptDestroyed();
	virtual void RenderEditorInfo(FLevelSceneNode *, FRenderInterface *, FDynamicActor *);
	virtual void CheckForErrors();

public:
	AR6DZonePathNode() {}
};

/*==========================================================================
	AR6DZonePath
==========================================================================*/

class R6ENGINE_API AR6DZonePath : public AR6DeploymentZone
{
public:
	DECLARE_CLASS(AR6DZonePath, AR6DeploymentZone, 0, R6Engine)

	BITFIELD m_bCycle : 1;
	BITFIELD m_bSelectNodeInEditor : 1;
	BITFIELD m_bActAsGroup : 1;
	BITFIELD bShowLog : 1;
	TArray<AR6DZonePathNode*> m_aNode;

	virtual void Spawned();
	virtual void PostScriptDestroyed();
	virtual void RenderEditorInfo(FLevelSceneNode *, FRenderInterface *, FDynamicActor *);
	virtual void CheckForErrors();
	virtual FVector FindRandomPointInArea();
	virtual FVector FindSpawningPoint(FRotator *, INT *, enum EStance *, INT *);
	virtual INT IsPointInZone(FVector const &);
	virtual FVector FindClosestPointTo(FVector const &);
	void DeleteANode(INT);
	void DeleteANode(AR6DZonePathNode *);
	void SpawnANewNode(FVector);

public:
	AR6DZonePath() {}
};

/*==========================================================================
	AR6DZoneCircle
==========================================================================*/

class R6ENGINE_API AR6DZoneCircle : public AR6DeploymentZone
{
public:
	DECLARE_CLASS(AR6DZoneCircle, AR6DeploymentZone, 0, R6Engine)

	FLOAT m_fRadius;


protected:
	AR6DZoneCircle() {}
};

/*==========================================================================
	AR6Stairs
==========================================================================*/

class R6ENGINE_API AR6Stairs : public ANavigationPoint
{
public:
	DECLARE_CLASS(AR6Stairs, ANavigationPoint, 0, R6Engine)

	BITFIELD m_bIsTopOfStairs : 1;


protected:
	AR6Stairs() {}
};

/*==========================================================================
	AR6Door
==========================================================================*/

class R6ENGINE_API AR6Door : public ANavigationPoint
{
public:
	DECLARE_CLASS(AR6Door, ANavigationPoint, 0, R6Engine)

	BYTE m_eRoomLayout;
	BITFIELD m_bCloseOnUntouch : 1;
	AR6Door* m_CorrespondingDoor;
	AR6IORotatingDoor* m_RotatingDoor;
	FVector m_vLookDir;

	virtual void RenderEditorInfo(FLevelSceneNode *, FRenderInterface *, FDynamicActor *);
	virtual AActor * AssociatedLevelGeometry();
	virtual void CheckForErrors();
	virtual void addReachSpecs(APawn *, INT);
	virtual INT PrunePaths();

public:
	AR6Door() {}
};

/*==========================================================================
	AR6EnvironmentNode
==========================================================================*/

class R6ENGINE_API AR6EnvironmentNode : public AActor
{
public:
	DECLARE_CLASS(AR6EnvironmentNode, AActor, 0, R6Engine)

	FVector m_vLookDir;


protected:
	AR6EnvironmentNode() {}
};

/*==========================================================================
	AR6Ladder
==========================================================================*/

class R6ENGINE_API AR6Ladder : public ALadder
{
public:
	DECLARE_CLASS(AR6Ladder, ALadder, 0, R6Engine)

	BITFIELD m_bIsTopOfLadder : 1;
	BITFIELD m_bSingleFileFormationOnly : 1;
	BITFIELD bShowLog : 1;
	AR6Ladder* m_pOtherFloor;


protected:
	AR6Ladder() {}
};

/*==========================================================================
	AR6HostageAI
==========================================================================*/

class R6ENGINE_API AR6HostageAI : public AR6AIController
{
public:
	DECLARE_CLASS(AR6HostageAI, AR6AIController, 0, R6Engine)

	BYTE m_eTransitionPosition;
	INT m_iNotGuardedSince;
	INT m_iLastHearNoiseTime;
	INT c_iDistanceMax;
	INT c_iDistanceCatchUp;
	INT c_iDistanceToStartToRun;
	INT m_iPlayReaction1;
	INT m_iPlayReaction2;
	INT m_iWaitingTime;
	INT m_iFacingTime;
	INT m_lastUpdatePaceTime;
	INT m_iNbOrder;
	INT c_iCowardModifier;
	INT c_iNormalModifier;
	INT c_iBraveModifier;
	INT c_iWoundedModifier;
	INT c_iGasModifier;
	INT c_iEnemyNotVisibleTime;
	INT c_iCautiousLastHearNoiseTime;
	INT c_iRunForCoverOfGrenadeMinDist;
	INT m_iDbgRoll;
	INT m_iRandomNumber;
	BITFIELD m_bForceToStayHere : 1;
	BITFIELD m_bRunningToward : 1;
	BITFIELD m_bRunToRainbowSuccess : 1;
	BITFIELD m_bStopDoTransition : 1;
	BITFIELD m_bNeedToRunToCatchUp : 1;
	BITFIELD m_bSlowedPace : 1;
	BITFIELD m_bFollowIncreaseDistance : 1;
	BITFIELD m_bLatentFnStopped : 1;
	BITFIELD m_bDbgIgnoreThreat : 1;
	BITFIELD m_bDbgIgnoreRainbow : 1;
	BITFIELD m_bDbgRoll : 1;
	BITFIELD m_bool : 1;
	BITFIELD bThreatShowLog : 1;
	BITFIELD m_bFirstTimeClarkComment : 1;
	FLOAT m_float;
	AR6Hostage* m_pawn;
	AR6HostageMgr* m_mgr;
	UR6HostageVoices* m_VoicesManager;
	AR6Pawn* m_pawnToFollow;
	AR6Pawn* m_lastSeenPawn;
	AActor* m_runAwayOfGrenade;
	AR6Terrorist* m_terrorist;
	AR6Pawn* m_escort;
	AActor* m_pGotoToExtractionZone;
	AR6EngineWeapon* DefaultWeapon;
	APathNode* m_pCoverNode;
	FName m_threatGroupName;
	FName m_runForCoverStateToGoOnFailure;
	FName m_runForCoverStateToGoOnSuccess;
	FName m_reactToGrenadeStateToReturn;
	FName m_name;
	UClass* DefaultWeaponClass;
	TArray<APathNode*> m_pListOfCoverNodes;
	FRandomTweenNum m_AITickTime;
	FThreatInfo m_threatInfo;
	FVector m_vReactionDirection;
	FOrderInfo m_aOrderInfo[2];
	FRandomTweenNum m_RunForCoverMinTween;
	FRandomTweenNum m_scareToDeathTween;
	FRandomTweenNum m_stayBlindedTweenTime;
	FVector m_vMoveToDest;
	FRotator m_rotator;
	FVector m_vectorTemp;
	FPlaySndInfo m_aPlaySndInfo[12];


protected:
	AR6HostageAI() {}
};

/*==========================================================================
	AR6RainbowTeam
==========================================================================*/

class R6ENGINE_API AR6RainbowTeam : public AActor
{
public:
	DECLARE_CLASS(AR6RainbowTeam, AActor, 0, R6Engine)

	BYTE m_bHasGrenade;
	BYTE m_eFormation;
	BYTE m_eRequestedFormation;
	BYTE m_ePlayerRoomEntry;
	BYTE m_eEntryGrenadeType;
	BYTE m_eMovementMode;
	BYTE m_eMovementSpeed;
	BYTE m_ePlanAction;
	BYTE m_eNextAPAction;
	BYTE m_ePlayerAPAction;
	BYTE m_eTeamState;
	BYTE m_eBackupTeamState;
	BYTE m_eGoCode;
	BYTE m_eBackupGoCode;
	INT m_iMemberCount;
	INT m_iIDVoicesMgr;
	INT m_iFormationDistance;
	INT m_iDiagonalDistance;
	INT m_iTeamHealth[4];
	INT m_iMembersLost;
	INT m_iGrenadeThrower;
	INT m_iIntermLeader;
	INT m_iSpawnDistance;
	INT m_iSpawnDiagDist;
	INT m_iSpawnDiagOther;
	INT m_iSubAction;
	INT m_iRainbowTeamName;
	INT m_iTeamAction;
	BITFIELD m_bLeaderIsAPlayer : 1;
	BITFIELD m_bPlayerHasFocus : 1;
	BITFIELD m_bPlayerInGhostMode : 1;
	BITFIELD m_bTeamIsClimbingLadder : 1;
	BITFIELD m_bTeamIsSeparatedFromLeader : 1;
	BITFIELD m_bGrenadeInProximity : 1;
	BITFIELD m_bGasGrenadeInProximity : 1;
	BITFIELD m_bEntryInProgress : 1;
	BITFIELD m_bDoorOpensTowardTeam : 1;
	BITFIELD m_bDoorOpensClockWise : 1;
	BITFIELD m_bRainbowIsInFrontOfDoor : 1;
	BITFIELD m_bWoundedHostage : 1;
	BITFIELD m_bCAWaitingForZuluGoCode : 1;
	BITFIELD m_bPreventUsingTeam : 1;
	BITFIELD m_bSniperReady : 1;
	BITFIELD m_bSkipAction : 1;
	BITFIELD m_bWasSeparatedFromLeader : 1;
	BITFIELD m_bAllTeamsHold : 1;
	BITFIELD m_bTeamIsHoldingPosition : 1;
	BITFIELD m_bSniperHold : 1;
	BITFIELD m_bTeamIsRegrouping : 1;
	BITFIELD m_bPlayerRequestedTeamReform : 1;
	BITFIELD m_bPendingSnipeUntilGoCode : 1;
	BITFIELD m_bTeamIsEngagingEnemy : 1;
	BITFIELD bShowLog : 1;
	BITFIELD bPlanningLog : 1;
	BITFIELD m_bFirstTimeInGas : 1;
	FLOAT m_fEngagingTimer;
	AR6Rainbow* m_Team[4];
	UR6GameColors* Colors;
	UR6RainbowPlayerVoices* m_PlayerVoicesMgr;
	UR6RainbowMemberVoices* m_MemberVoicesMgr;
	UR6RainbowOtherTeamVoices* m_OtherTeamVoicesMgr;
	UR6MultiCommonVoices* m_MultiCommonVoicesMgr;
	UR6MultiCoopVoices* m_MultiCoopPlayerVoicesMgr;
	UR6MultiCoopVoices* m_MultiCoopMemberVoicesMgr;
	UR6PreRecordedMsgVoices* m_PreRecMsgVoicesMgr;
	AR6Rainbow* m_TeamLeader;
	UR6AbstractPlanningInfo* m_TeamPlanning;
	AR6Pawn* m_PawnControllingDoor;
	AR6Ladder* m_TeamLadder;
	AR6Door* m_Door;
	AR6CircumstantialActionQuery* m_actionRequested;
	AActor* m_PlanActionPoint;
	AR6IORotatingDoor* m_BreachingDoor;
	AActor* m_LastActionPoint;
	AR6Pawn* m_SurrenderedTerrorist;
	AR6Pawn* m_HostageToRescue;
	AActor* m_PlayerLastActionPoint;
	TArray<AR6InteractiveObject*> m_InteractiveObjectList;
	FColor m_TeamColour;
	FRotator m_rTeamDirection;
	FVector m_vActionLocation;
	FVector m_vPlanActionLocation;
	FRotator m_rSnipingDir;
	FVector m_vPreviousPosition;
	FVector m_vNoiseSource;

	void eventRequestFormationChange(BYTE);
	void eventUpdateTeamFormation(BYTE);

protected:
	AR6RainbowTeam() {}
};

/*==========================================================================
	AR6TerroristAI
==========================================================================*/

class R6ENGINE_API AR6TerroristAI : public AR6AIController
{
public:
	DECLARE_CLASS(AR6TerroristAI, AR6AIController, 0, R6Engine)

	BYTE m_eEngageReaction;
	BYTE m_eReactionStatus;
	BYTE m_eStateForEvent;
	BYTE m_eAttackMode;
	BYTE m_eFollowMode;
	BYTE m_wBadMoveCount;
	INT m_iCurrentGroupID;
	INT m_iTerroristInGroup;
	INT m_iRainbowInCombat;
	INT m_iChanceToDetectShooter;
	INT m_iRandomNumber;
	INT m_iStateVariable;
	INT m_iFollowYaw;
	BITFIELD m_bHearInvestigate : 1;
	BITFIELD m_bSeeHostage : 1;
	BITFIELD m_bHearThreat : 1;
	BITFIELD m_bSeeRainbow : 1;
	BITFIELD m_bHearGrenade : 1;
	BITFIELD m_bPreciseMove : 1;
	BITFIELD m_bCanFailMovingTo : 1;
	BITFIELD m_bFireShort : 1;
	BITFIELD m_bInPathMode : 1;
	BITFIELD m_bWaiting : 1;
	BITFIELD m_bAlreadyHeardSound : 1;
	BITFIELD m_bHeardGrenade : 1;
	BITFIELD m_bCalledForBackup : 1;
	FLOAT m_fWaitingTime;
	FLOAT m_fFacingTime;
	FLOAT m_fSearchTime;
	FLOAT m_fPawnDistance;
	FLOAT m_fFollowDist;
	FLOAT m_fLastBumpedTime;
	AR6TerroristAI* m_TerroristLeader;
	AR6Terrorist* m_pawn;
	UR6TerroristMgr* m_Manager;
	UR6TerroristVoices* m_VoicesManager;
	AR6ActionSpot* m_pActionSpot;
	ANavigationPoint* m_aLastNode[10];
	AR6Pawn* m_huntedPawn;
	AR6Hostage* m_Hostage;
	AR6HostageAI* m_HostageAI;
	AR6DeploymentZone* m_ZoneToEscort;
	AR6Pawn* m_pawnToFollow;
	AActor* m_aMovingToDestination;
	AR6Pawn* m_LastBumped;
	AR6DZonePath* m_path;
	AR6DZonePathNode* m_currentNode;
	AR6InteractiveObject* m_TriggeredIO;
	FName m_stateAfterMovingTo;
	FName m_labelAfterMovingTo;
	FName m_PatrolCurrentLabel;
	TArray<AR6TerroristAI*> m_listAvailableBackup;
	FVector m_vThreatLocation;
	FVector m_vHostageReactionDirection;
	FVector m_vMovingDestination;
	FRotator m_rStandRotation;
	FVector m_vSpawningPosition;
	FRotator m_rSpawningRotation;
	FString m_sDebugString;

	virtual INT CanHear(FVector, FLOAT, AActor *, enum ENoiseType, enum EPawnType);
	void eventGotoPointAndSearch(FVector, BYTE, DWORD, FLOAT, BYTE);
	void eventGotoPointToAttack(FVector, AActor *);
	void eventGotoStateEngageByThreat(FVector);
	void execCallBackupForAttack(struct FFrame &, void * const);
	void execCallBackupForInvestigation(struct FFrame &, void * const);
	void execCallVisibleTerrorist(struct FFrame &, void * const);
	void execFindBetterShotLocation(struct FFrame &, void * const);
	void execGetNextRandomNode(struct FFrame &, void * const);
	void execHaveAClearShot(struct FFrame &, void * const);
	void execIsAttackSpotStillValid(struct FFrame &, void * const);
	void execMakeBackupList(struct FFrame &, void * const);
	INT HaveAClearShot(FVector, APawn *);

public:
	AR6TerroristAI() {}
};

/*==========================================================================
	AR6RainbowAI
==========================================================================*/

class R6ENGINE_API AR6RainbowAI : public AR6AIController
{
public:
	DECLARE_CLASS(AR6RainbowAI, AR6AIController, 0, R6Engine)

	BYTE m_eFormation;
	BYTE m_ePawnOrientation;
	BYTE m_eCurrentRoomLayout;
	BYTE m_eCoverDirection;
	INT m_iStateProgress;
	INT m_iTurn;
	INT m_iWaitCounter;
	INT m_iActionUseGadgetGroup;
	BITFIELD m_bTeamMateHasBeenKilled : 1;
	BITFIELD m_bIsCatchingUp : 1;
	BITFIELD m_bIsMovingBackwards : 1;
	BITFIELD m_bSlowedPace : 1;
	BITFIELD m_bAlreadyWaiting : 1;
	BITFIELD m_bReactToNoise : 1;
	BITFIELD m_bUseStaggeredFormation : 1;
	BITFIELD m_bWeaponsDry : 1;
	BITFIELD m_bAimingWeaponAtEnemy : 1;
	BITFIELD m_bEnteredRoom : 1;
	BITFIELD m_bIndividualAttacks : 1;
	BITFIELD m_bStateFlag : 1;
	BITFIELD m_bReorganizationPending : 1;
	FLOAT m_fLastReactionToGas;
	FLOAT m_fGrenadeDangerRadius;
	FLOAT m_fAttackTimerRate;
	FLOAT m_fAttackTimerCounter;
	FLOAT m_fFiringAttackTimer;
	AR6Rainbow* m_pawn;
	AR6RainbowTeam* m_TeamManager;
	AR6Rainbow* m_TeamLeader;
	AR6Rainbow* m_PaceMember;
	AActor* m_NextMoveTarget;
	AR6IORotatingDoor* m_RotatingDoor;
	AActor* m_ActionTarget;
	AActor* m_DesiredTarget;
	UR6CommonRainbowVoices* m_CommonMemberVoicesMgr;
	FName m_PostFindPathToState;
	FName m_PostLockPickState;
	FVector m_vLocationOnTarget;
	FVector m_vGrenadeLocation;
	FVector m_vDesiredLocation;
	FVector m_vNoiseFocalPoint;
	FVector m_vPreEntryPositions[2];

	virtual void UpdateTimers(FLOAT);
	virtual AActor * GetTeamManager();
	void eventAttackTimer();
	void eventStopAttack();
	void execAClearShotIsAvailable(struct FFrame &, void * const);
	void execCheckEnvironment(struct FFrame &, void * const);
	void execClearToSnipe(struct FFrame &, void * const);
	void execFindSafeSpot(struct FFrame &, void * const);
	void execGetEntryPosition(struct FFrame &, void * const);
	void execGetGuardPosition(struct FFrame &, void * const);
	void execGetLadderPosition(struct FFrame &, void * const);
	void execGetTargetPosition(struct FFrame &, void * const);
	void execLookAroundRoom(struct FFrame &, void * const);
	void execSetOrientation(struct FFrame &, void * const);
	INT AClearShotIsAvailable(APawn *, FVector);
	INT ClearToSnipe(FVector, FRotator);
	AActor * FindSafeSpot();
	FVector GetTeamLeftOfDoorPosition(INT, AR6Door *);
	FVector GetTeamRightOfDoorPosition(INT, AR6Door *);
	void LookAroundRoom(INT);
	void checkEnvironment();
	FVector getEntryPosition();
	FVector getGuardPosition();
	FVector getLadderPosition();
	FVector getPreEntryPosition();
	FVector getTargetPosition();
	void resetBoneRotation();
	void setMemberOrientation(enum EPawnOrientation);
	enum ePawnOrientation updatePawnOrientation();

public:
	AR6RainbowAI() {}
};

/*==========================================================================
	AR6PlayerController
==========================================================================*/

class R6ENGINE_API AR6PlayerController : public APlayerController
{
public:
	DECLARE_CLASS(AR6PlayerController, APlayerController, 0, R6Engine)

	BYTE m_bSpecialCrouch;
	BYTE m_bSpeedUpDoor;
	BYTE m_bPeekLeft;
	BYTE m_bPeekRight;
	BYTE m_bReloading;
	BYTE m_bOldPeekLeft;
	BYTE m_bOldPeekRight;
	BYTE m_wAutoAim;
	BYTE m_bPlayerRun;
	BYTE m_ePenaltyForKillingAPawn;
	INT m_iDoorSpeed;
	INT m_iFastDoorSpeed;
	INT m_iFluidMovementSpeed;
	INT m_iSpeedLevels[3];
	INT m_iShakeBlurIntensity;
	INT m_iReturnSpeed;
	INT m_iPitchReturn;
	INT m_iYawReturn;
	INT m_iSpectatorYaw;
	INT m_iSpectatorPitch;
	INT m_iPlayerCAProgress;
	INT m_iTeamId;
	INT m_iVoteResult;
	INT m_iAdmin;
	INT m_iBanPage;
	BITFIELD m_bHelmetCameraOn : 1;
	BITFIELD m_bScopeZoom : 1;
	BITFIELD m_bSniperMode : 1;
	BITFIELD m_bShowFPWeapon : 1;
	BITFIELD m_bShowHitLogs : 1;
	BITFIELD m_bCircumstantialActionInProgress : 1;
	BITFIELD m_bAllTeamsHold : 1;
	BITFIELD m_bFixCamera : 1;
	BITFIELD bShowLog : 1;
	BITFIELD m_bShakeActive : 1;
	BITFIELD m_bDisplayMilestoneMessage : 1;
	BITFIELD m_bUseFirstPersonWeapon : 1;
	BITFIELD m_bPlacedExplosive : 1;
	BITFIELD m_bAttachCameraToEyes : 1;
	BITFIELD m_bCameraGhost : 1;
	BITFIELD m_bCameraFirstPerson : 1;
	BITFIELD m_bCameraThirdPersonFixed : 1;
	BITFIELD m_bCameraThirdPersonFree : 1;
	BITFIELD m_bFadeToBlack : 1;
	BITFIELD m_bSpectatorCameraTeamOnly : 1;
	BITFIELD m_bSkipBeginState : 1;
	BITFIELD m_bPreventTeamMemberUse : 1;
	BITFIELD m_bDisplayMessage : 1;
	BITFIELD m_bEndOfRoundDataReceived : 1;
	BITFIELD m_bInAnOptionsPage : 1;
	BITFIELD m_bPawnInitialized : 1;
	BITFIELD m_bCanChangeMember : 1;
	BITFIELD m_bDisplayActionProgress : 1;
	BITFIELD m_bAMenuIsDisplayed : 1;
	BITFIELD m_bMatineeRunning : 1;
	BITFIELD m_bHasAPenalty : 1;
	BITFIELD m_bPenaltyBox : 1;
	BITFIELD m_bRequestTKPopUp : 1;
	BITFIELD m_bProcessingRequestTKPopUp : 1;
	BITFIELD m_bAlreadyPoppedTKPopUpBox : 1;
	BITFIELD m_bPlayDeathMusic : 1;
	BITFIELD m_bDeadAfterTeamSel : 1;
	BITFIELD m_bShowCompleteHUD : 1;
	BITFIELD m_bWantTriggerLag : 1;
	BITFIELD m_bQuitToUpdateServerDisplayed : 1;
	BITFIELD m_bIsSecuringRainbow : 1;
	BITFIELD m_bBombSearched : 1;
	FLOAT m_fOxygeneLevel;
	FLOAT m_fCompteurFrameDetection;
	FLOAT m_fTeamMoveToDistance;
	FLOAT m_fTimedBlurValue;
	FLOAT m_fBlurReturnTime;
	FLOAT m_fHitEffectTime;
	FLOAT m_fShakeTime;
	FLOAT m_fMaxShake;
	FLOAT m_fCurrentShake;
	FLOAT m_fMaxShakeTime;
	FLOAT m_fPostFluidMovementDelay;
	FLOAT m_fRetLockPosX;
	FLOAT m_fRetLockPosY;
	FLOAT m_fCurrRetPosX;
	FLOAT m_fCurrRetPosY;
	FLOAT m_fRetLockTime;
	FLOAT m_fShakeReturnTime;
	FLOAT m_fDesignerSpeedFactor;
	FLOAT m_fDesignerJumpFactor;
	FLOAT m_fMilestoneMessageDuration;
	FLOAT m_fMilestoneMessageLeft;
	FLOAT m_fCurrentDeltaTime;
	FLOAT LastDoorUpdateTime;
	FLOAT m_fLastUpdateServerCheckTime;
	FLOAT m_fLastVoteTime;
	FLOAT m_fStartSurrenderTime;
	AR6Rainbow* m_pawn;
	AR6RainbowTeam* m_TeamManager;
	AR6Pawn* m_targetedPawn;
	AR6CircumstantialActionQuery* m_CurrentCircumstantialAction;
	AR6CircumstantialActionQuery* m_RequestedCircumstantialAction;
	AR6CircumstantialActionQuery* m_PlayerCurrentCA;
	UInteractionMaster* m_InteractionMaster;
	UR6InteractionCircumstantialAction* m_InteractionCA;
	UR6InteractionInventoryMnu* m_InteractionInventory;
	AR6Rainbow* m_BackupTeamLeader;
	AActor* m_PrevViewTarget;
	ANavigationPoint* StartSpot;
	UR6GameMenuCom* m_MenuCommunication;
	UR6GameOptions* m_GameOptions;
	AR6PlayerController* m_TeamKiller;
	USound* m_sndUpdateWritableMap;
	USound* m_sndDeathMusic;
	USound* m_sndMissionComplete;
	UR6CommonRainbowVoices* m_CommonPlayerVoicesMgr;
	UR6AbstractGameService* m_GameService;
	AR6IOSelfDetonatingBomb* m_pSelfDetonatingBomb;
	AR6Pawn* m_pInteractingRainbow;
	TArray<FstSoundPriorityPtr> m_PlayVoicesPriority;
	FRotator m_rHitRotation;
	FVector m_vAutoAimTarget;
	FVector m_vCameraLocation;
	FRotator m_rCameraRotation;
	FRotator m_rCurrentShakeRotation;
	FRotator m_rTotalShake;
	FSTImpactShake m_stImpactHit;
	FSTImpactShake m_stImpactStun;
	FSTImpactShake m_stImpactDazed;
	FSTImpactShake m_stImpactKO;
	FVector m_vNewReturnValue;
	FRotator m_rLastBulletDirection;
	FVector m_vDefaultLocation;
	FVector m_vRequestedLocation;
	FColor m_SpectatorColor;
	FSTBanPage m_BanPage;
	FString m_szLastAdminPassword;
	FString m_szMileStoneMessage;
	FString m_CharacterName;
	FString m_szBanSearch;
	FLOAT m_fLastBroadcastTimeStamp;
	FLOAT m_fPreviousBroadcastTimeStamp;
	FLOAT m_fEndOfChatLockTime;
	FLOAT m_fLastVoteEmoteTimeStamp;

	virtual void Destroy();
	virtual INT Tick(FLOAT, enum ELevelTick);
	virtual void PreNetReceive();
	virtual void PostNetReceive();
	virtual AActor * GetTeamManager();
	virtual void UpdateCircumstantialAction();
	void eventClientNotifySendMatchResults();
	void eventClientNotifySendStartMatch();
	void eventClientPlayVoices(AR6SoundReplicationInfo *, USound *, BYTE, INT, DWORD, FLOAT);
	void eventClientUpdateLadderStat(FString const &, INT, INT, FLOAT);
	void eventClientVoteSessionAbort(FString const &);
	FLOAT eventGetZoomMultiplyFactor(FLOAT);
	void eventPlayerTeamSelectionReceived();
	void eventPostRender(UCanvas *);
	void eventSetCrouchBlend(FLOAT);
	void execDebugFunction(struct FFrame &, void * const);
	void execFindPlayer(struct FFrame &, void * const);
	void execGetLocStringWithActionKey(struct FFrame &, void * const);
	void execLocalizeTraining(struct FFrame &, void * const);
	void execPlayVoicesPriority(struct FFrame &, void * const);
	void execUpdateCircumstantialAction(struct FFrame &, void * const);
	void execUpdateReticule(struct FFrame &, void * const);
	void execUpdateSpectatorReticule(struct FFrame &, void * const);
	FString GetLocKeyNameByActionKey(TCHAR const *);
	INT PlayPriority(INT);
	void PlayVoicesPriority();
	AActor * SelectActorForSound(AR6SoundReplicationInfo *);
	void StopAndRemoveVoices(INT &);
	void UpdateReticule(FLOAT);
	void UpdateReticuleIdentification(AActor *);
	void UpdateSpectatorReticule();

public:
	AR6PlayerController() {}
};

/*==========================================================================
	AR6MatineeHostage
==========================================================================*/

class R6ENGINE_API AR6MatineeHostage : public AR6Hostage
{
public:
	DECLARE_CLASS(AR6MatineeHostage, AR6Hostage, 0, R6Engine)

	BITFIELD m_bUseHostageTemplate : 1;
	UR6MatineeAttach* m_MatineeAttach;
	UClass* m_HostageTemplate;


protected:
	AR6MatineeHostage() {}
};

/*==========================================================================
	AR6MatineeRainbow
==========================================================================*/

class R6ENGINE_API AR6MatineeRainbow : public AR6Rainbow
{
public:
	DECLARE_CLASS(AR6MatineeRainbow, AR6Rainbow, 0, R6Engine)

	BITFIELD m_bActivateGadget : 1;
	BITFIELD m_bUseRainbowTemplate : 1;
	AR6RainbowAI* m_controller;
	UR6MatineeAttach* m_MatineeAttach;
	UClass* m_PrimaryWeapon;
	UClass* m_SecondaryWeapon;
	UClass* m_PrimaryGadget;
	UClass* m_SecondaryGadget;
	UClass* m_RainbowTemplate;


protected:
	AR6MatineeRainbow() {}
};

/*==========================================================================
	AR6MatineeTerrorist
==========================================================================*/

class R6ENGINE_API AR6MatineeTerrorist : public AR6Terrorist
{
public:
	DECLARE_CLASS(AR6MatineeTerrorist, AR6Terrorist, 0, R6Engine)

	BITFIELD m_bUseTerroristTemplate : 1;
	UR6MatineeAttach* m_MatineeAttach;
	UClass* m_PrimaryWeapon;
	UClass* m_TerroristTemplate;


protected:
	AR6MatineeTerrorist() {}
};

/*==========================================================================
	AR6TeamMemberReplicationInfo
==========================================================================*/

class R6ENGINE_API AR6TeamMemberReplicationInfo : public AActor
{
public:
	DECLARE_CLASS(AR6TeamMemberReplicationInfo, AActor, 0, R6Engine)

	BYTE m_RotationYaw;
	BYTE m_BlinkCounter;
	BYTE m_iTeamPosition;
	BYTE m_eHealth;
	BYTE m_BlinkCounterOld;
	INT m_iTeam;
	INT m_iTeamId;
	BITFIELD m_bIsPrimaryGadgetEmpty : 1;
	BITFIELD m_bIsSecondaryGadgetEmpty : 1;
	BITFIELD m_bIsPilot : 1;
	BITFIELD m_bIsIntruder : 1;
	BITFIELD m_bHasFloppy : 1;
	FLOAT m_fLastCommunicationTime;
	FLOAT m_fClientUpdateFrequency;
	FLOAT m_fClientLastUpdate;
	FLOAT m_fCompteurFrameDetection;
	FVector m_Location;
	FString m_CharacterName;
	FString m_PrimaryWeapon;
	FString m_SecondaryWeapon;
	FString m_PrimaryGadget;
	FString m_SecondaryGadget;

	virtual void TickSpecial(FLOAT);
	virtual INT IsNetRelevantFor(APlayerController *, AActor *, FVector);
	INT IsRelevantToTeamMember(APawn *);

public:
	AR6TeamMemberReplicationInfo() {}
};

/*==========================================================================
	AR6SoundReplicationInfo
==========================================================================*/

class R6ENGINE_API AR6SoundReplicationInfo : public AActor
{
public:
	DECLARE_CLASS(AR6SoundReplicationInfo, AActor, 0, R6Engine)

	BYTE m_CurrentWeapon;
	BYTE m_NewWeaponSound;
	BYTE m_NewPawnState;
	BYTE m_Material;
	BYTE m_pawnState;
	BYTE m_TeamColor;
	BYTE m_GunSoundType;
	BYTE m_StatusOtherTeam;
	BYTE m_LastPlayedWeaponSound;
	BITFIELD m_bInitialize : 1;
	BITFIELD m_bLastSoundFullAuto : 1;
	FLOAT m_fClientUpdateFrequency;
	FLOAT m_fClientLastUpdate;
	AR6Pawn* m_pawnOwner;
	AR6PawnReplicationInfo* m_PawnRepInfo;
	FVector m_Location;

	virtual void PreNetReceive();
	virtual void PostNetReceive();
	virtual void TickSpecial(FLOAT);
	virtual INT IsNetRelevantFor(APlayerController *, AActor *, FVector);
	void execPlayLocalWeaponSound(struct FFrame &, void * const);
	void execPlayWeaponSound(struct FFrame &, void * const);
	void execStopWeaponSound(struct FFrame &, void * const);
	void PlayWeaponSound(enum EWeaponSound, BYTE);
	void StopWeaponSound();

public:
	AR6SoundReplicationInfo() {}
};

/*==========================================================================
	AR6RagDoll
==========================================================================*/

class R6ENGINE_API AR6RagDoll : public AR6AbstractCorpse
{
public:
	DECLARE_CLASS(AR6RagDoll, AR6AbstractCorpse, 0, R6Engine)

	FLOAT m_fAccumulatedTime;
	AR6AbstractPawn* m_pawnOwner;
	TArray<FSTSpring> m_aSpring;
	FSTParticle m_aParticle[16];

	virtual INT Tick(FLOAT, enum ELevelTick);
	virtual void FirstInit(AR6AbstractPawn *);
	virtual void RenderBones(UCanvas *);
	virtual void AddImpulseToBone(INT, FVector);
	void AddSpring(INT, INT, FLOAT, FLOAT);
	void ClipParticleToPlane(INT, FVector const &, FVector const &);
	void CollisionDetection();
	void SatisfyConstraints();
	void VerletIntegration(FLOAT);

public:
	AR6RagDoll() {}
};

/*==========================================================================
	AR6SAHeartBeatJammer
==========================================================================*/

class R6ENGINE_API AR6SAHeartBeatJammer : public AR6GenericHB
{
public:
	DECLARE_CLASS(AR6SAHeartBeatJammer, AR6GenericHB, 0, R6Engine)


protected:
	AR6SAHeartBeatJammer() {}
};

/*==========================================================================
	AR6FalseHeartBeat
==========================================================================*/

class R6ENGINE_API AR6FalseHeartBeat : public AR6GenericHB
{
public:
	DECLARE_CLASS(AR6FalseHeartBeat, AR6GenericHB, 0, R6Engine)

	INT m_iNoCircleBeat;
	FLOAT m_fHeartBeatTime[2];
	FLOAT m_fHeartBeatFrequency;
	APawn* m_HeartBeatPuckOwner;

	virtual INT IsBlockedBy(AActor const *) const;
	virtual INT ShouldTrace(AActor *, DWORD);
	virtual INT IsRelevantToPawnHeartBeat(APawn *);
	virtual INT IsRelevantToPawn(APawn *);

public:
	AR6FalseHeartBeat() {}
};

/*==========================================================================
	UR6CheatManager
==========================================================================*/

class R6ENGINE_API UR6CheatManager : public UCheatManager
{
public:
	INT m_iHostageTestAnimIndex;
	INT m_iGameInfoLevel;
	INT m_iCounterLog;
	INT m_iCounterLogMax;
	INT m_iCurNavPoint;
	INT m_iCommandInfoIndex;
	BITFIELD m_bRenderGunDirection : 1;
	BITFIELD m_bRenderViewDirection : 1;
	BITFIELD m_bRenderBoneCorpse : 1;
	BITFIELD m_bRenderFOV : 1;
	BITFIELD m_bRenderRoute : 1;
	BITFIELD m_bRenderNavPoint : 1;
	BITFIELD m_bToggleHostageLog : 1;
	BITFIELD m_bToggleHostageThreat : 1;
	BITFIELD m_bHostageTestAnim : 1;
	BITFIELD m_bToggleTerroLog : 1;
	BITFIELD m_bRendSpot : 1;
	BITFIELD m_bRendPawnState : 1;
	BITFIELD m_bRendFocus : 1;
	BITFIELD m_bToggleRainbowLog : 1;
	BITFIELD m_bPlayerInvisble : 1;
	BITFIELD m_bHideAll : 1;
	BITFIELD m_bTogglePeek : 1;
	BITFIELD m_bTogglePGDebug : 1;
	BITFIELD m_bToggleThreatInfo : 1;
	BITFIELD m_bToggleGameInfo : 1;
	BITFIELD m_bToggleMissionLog : 1;
	BITFIELD m_bFirstPersonPlayerView : 1;
	BITFIELD m_bTeamGodMode : 1;
	BITFIELD m_bSkipTick : 1;
	BITFIELD m_bNumberLog : 1;
	BITFIELD m_bEnableNavDebug : 1;
	FLOAT m_fNavPointDistance;
	AR6Pawn* m_curPawn;
	AR6Hostage* m_Hostage;
	TArray<FVector> m_aNavPointLocation;
	FCommandInfo m_aCommandInfo[128];


protected:
	UR6CheatManager() {}
};

/*==========================================================================
	AR6IOSelfDetonatingBomb
==========================================================================*/

class R6ENGINE_API AR6IOSelfDetonatingBomb : public AR6IOBomb
{
public:
	FLOAT m_fSelfDetonationTime;
	FLOAT m_fDefusedTimeMessage;


protected:
	AR6IOSelfDetonatingBomb() {}
};

/*==========================================================================
	UR6InteractionCircumstantialAction
==========================================================================*/

class R6ENGINE_API UR6InteractionCircumstantialAction : public UR6InteractionRoseDesVents
{
public:
	UTexture* m_TexProgressCircle;
	UTexture* m_TexProgressItem;
	UTexture* m_TexFakeReticule;
	UFont* m_SmallFont_14pt;


protected:
	UR6InteractionCircumstantialAction() {}
};

/*==========================================================================
	UR6InteractionInventoryMnu
==========================================================================*/

class R6ENGINE_API UR6InteractionInventoryMnu : public UR6InteractionRoseDesVents
{
public:

protected:
	UR6InteractionInventoryMnu() {}
};

/*==========================================================================
	AR6CircumstantialActionQuery
==========================================================================*/

class R6ENGINE_API AR6CircumstantialActionQuery : public AR6AbstractCircumstantialActionQuery
{
public:
	BITFIELD bShowLog : 1;
	BITFIELD m_bNeedsTick : 1;


protected:
	AR6CircumstantialActionQuery() {}
};

/*==========================================================================
	UR6RainbowMemberVoices
==========================================================================*/

class R6ENGINE_API UR6RainbowMemberVoices : public UR6Voices
{
public:
	USound* m_sndContact;
	USound* m_sndContactRear;
	USound* m_sndContactAndEngages;
	USound* m_sndContactRearAndEngages;
	USound* m_sndTeamRegroupOnLead;
	USound* m_sndTeamReformOnLead;
	USound* m_sndTeamReceiveOrder;
	USound* m_sndTeamOrderFromLeadNil;
	USound* m_sndNoMoreFrag;
	USound* m_sndNoMoreSmoke;
	USound* m_sndNoMoreGas;
	USound* m_sndNoMoreFlash;
	USound* m_sndOnLadder;
	USound* m_sndMemberDown;
	USound* m_sndAmmoOut;
	USound* m_sndFragNear;
	USound* m_sndEntersGasCloud;
	USound* m_sndTakingFire;
	USound* m_sndTeamHoldUp;
	USound* m_sndTeamMoveOut;
	USound* m_sndHostageFollow;
	USound* m_sndHostageStay;
	USound* m_sndHostageSafe;
	USound* m_sndHostageSecured;
	USound* m_sndRainbowHitRainbow;
	USound* m_sndRainbowHitHostage;
	USound* m_sndDoorReform;


protected:
	UR6RainbowMemberVoices() {}
};

/*==========================================================================
	UR6RainbowPlayerVoices
==========================================================================*/

class R6ENGINE_API UR6RainbowPlayerVoices : public UR6Voices
{
public:
	USound* m_sndTeamRegroup;
	USound* m_sndTeamMove;
	USound* m_sndTeamHold;
	USound* m_sndAllTeamsHold;
	USound* m_sndAllTeamsMove;
	USound* m_sndTeamMoveAndFrag;
	USound* m_sndTeamMoveAndGas;
	USound* m_sndTeamMoveAndSmoke;
	USound* m_sndTeamMoveAndFlash;
	USound* m_sndTeamOpenDoor;
	USound* m_sndTeamCloseDoor;
	USound* m_sndTeamOpenShudder;
	USound* m_sndTeamCloseShudder;
	USound* m_sndTeamOpenAndClear;
	USound* m_sndTeamOpenAndFrag;
	USound* m_sndTeamOpenAndGas;
	USound* m_sndTeamOpenAndSmoke;
	USound* m_sndTeamOpenAndFlash;
	USound* m_sndTeamOpenFragAndClear;
	USound* m_sndTeamOpenGasAndClear;
	USound* m_sndTeamOpenSmokeAndClear;
	USound* m_sndTeamOpenFlashAndClear;
	USound* m_sndTeamFragAndClear;
	USound* m_sndTeamGasAndClear;
	USound* m_sndTeamSmokeAndClear;
	USound* m_sndTeamFlashAndClear;
	USound* m_sndTeamUseLadder;
	USound* m_sndTeamSecureTerrorist;
	USound* m_sndTeamGoGetHostage;
	USound* m_sndTeamHostageStayPut;
	USound* m_sndTeamStatusReport;
	USound* m_sndTeamUseElectronic;
	USound* m_sndTeamUseDemolition;
	USound* m_sndAlphaGoCode;
	USound* m_sndBravoGoCode;
	USound* m_sndCharlieGoCode;
	USound* m_sndZuluGoCode;
	USound* m_sndOrderTeamWithGoCode;
	USound* m_sndHostageFollow;
	USound* m_sndHostageStay;
	USound* m_sndHostageSafe;
	USound* m_sndHostageSecured;
	USound* m_sndMemberDown;
	USound* m_sndSniperFree;
	USound* m_sndSniperHold;


protected:
	UR6RainbowPlayerVoices() {}
};

/*==========================================================================
	UR6MultiCommonVoices
==========================================================================*/

class R6ENGINE_API UR6MultiCommonVoices : public UR6Voices
{
public:
	USound* m_sndFragThrow;
	USound* m_sndFlashThrow;
	USound* m_sndGasThrow;
	USound* m_sndSmokeThrow;
	USound* m_sndActivatingBomb;
	USound* m_sndBombActivated;
	USound* m_sndDeactivatingBomb;
	USound* m_sndBombDeactivated;


protected:
	UR6MultiCommonVoices() {}
};

/*==========================================================================
	UR6PreRecordedMsgVoices
==========================================================================*/

class R6ENGINE_API UR6PreRecordedMsgVoices : public UR6Voices
{
public:
	TArray<USound*> m_sndPreRecordedMsg;


protected:
	UR6PreRecordedMsgVoices() {}
};

/*==========================================================================
	UR6PlayerInput
==========================================================================*/

class R6ENGINE_API UR6PlayerInput : public UPlayerInput
{
public:
	BITFIELD m_bIgnoreInput : 1;
	BITFIELD m_bFluidMovement : 1;
	BITFIELD m_bWasFluidMovement : 1;


protected:
	UR6PlayerInput() {}
};

/*==========================================================================
	AR6BloodSplatSmall
==========================================================================*/

class R6ENGINE_API AR6BloodSplatSmall : public AR6BloodSplat
{
public:

protected:
	AR6BloodSplatSmall() {}
};

/*==========================================================================
	AR6ArmPatchGlow
==========================================================================*/

class R6ENGINE_API AR6ArmPatchGlow : public AR6GlowLight
{
public:
	FLOAT m_fMatrixMul;
	FName m_AttachedBoneName;


protected:
	AR6ArmPatchGlow() {}
};

/*==========================================================================
	AR6ShadowProjector
==========================================================================*/

class R6ENGINE_API AR6ShadowProjector : public AProjector
{
public:
	BITFIELD m_bAttached : 1;


protected:
	AR6ShadowProjector() {}
};

/*==========================================================================
	AR6GasMask
==========================================================================*/

class R6ENGINE_API AR6GasMask : public AStaticMeshActor
{
public:

protected:
	AR6GasMask() {}
};

/*==========================================================================
	AR6NightVision
==========================================================================*/

class R6ENGINE_API AR6NightVision : public AStaticMeshActor
{
public:

protected:
	AR6NightVision() {}
};

/*==========================================================================
	AR6HostageMgr
==========================================================================*/

class R6ENGINE_API AR6HostageMgr : public AR6AbstractHostageMgr
{
public:
	INT c_iSurrenderRadius;
	INT c_iDetectUnderFireRadius;
	INT c_iDetectThreatSound;
	INT c_iDetectGrenadeRadius;
	INT c_ThreatLevel_Surrender;
	INT ANIM_eBlinded;
	INT ANIM_eCrouchToProne;
	INT ANIM_eCrouchToScaredStand;
	INT ANIM_eCrouchWait01;
	INT ANIM_eCrouchWait02;
	INT ANIM_eCrouchWalkBack;
	INT ANIM_eFoetusToCrouch;
	INT ANIM_eFoetusToKneel;
	INT ANIM_eFoetusToProne;
	INT ANIM_eFoetusToStand;
	INT ANIM_eFoetusWait01;
	INT ANIM_eFoetusWait02;
	INT ANIM_eFoetus_nt;
	INT ANIM_eGazed;
	INT ANIM_eKneelFreeze;
	INT ANIM_eKneelReact01;
	INT ANIM_eKneelReact02;
	INT ANIM_eKneelReact03;
	INT ANIM_eKneelToCrouch;
	INT ANIM_eKneelToFoetus;
	INT ANIM_eKneelToProne;
	INT ANIM_eKneelToStand;
	INT ANIM_eKneelWait01;
	INT ANIM_eKneelWait02;
	INT ANIM_eKneelWait03;
	INT ANIM_eKneel_nt;
	INT ANIM_eScaredStandWait01;
	INT ANIM_eScaredStandWait02;
	INT ANIM_eScaredStand_nt;
	INT ANIM_eStandHandUpFreeze;
	INT ANIM_eStandHandUpReact01;
	INT ANIM_eStandHandUpReact02;
	INT ANIM_eStandHandUpReact03;
	INT ANIM_eStandHandUpToDown;
	INT ANIM_eStandHandDownToUp;
	INT ANIM_eStandHandUpWait01;
	INT ANIM_eStandToFoetus;
	INT ANIM_eStandToKneel;
	INT ANIM_eStandWaitCough;
	INT ANIM_eStandWaitShiftWeight;
	INT ANIM_eProneToCrouch;
	INT ANIM_eProneWaitBreathe;
	INT ANIM_eMAX;
	INT m_iThreatDefinitionIndex;
	INT m_iReactionIndex;
	INT m_iAnimTransIndex;
	BITFIELD bShowLog : 1;
	FName c_ThreatGroup_Civ;
	FName c_ThreatGroup_HstFreed;
	FName c_ThreatGroup_HstGuarded;
	FName c_ThreatGroup_HstBait;
	FName c_ThreatGroup_HstEscorted;
	FName m_noReactionName;
	FHstSndEventInfo m_aHstSndEventInfo[24];
	FAnimInfo m_aAnimInfo[40];
	FThreatDefinition m_aThreatDefinition[27];
	FReactionInfo m_aReactions[24];
	FAnimTransInfo m_aAnimTransInfo[32];


protected:
	AR6HostageMgr() {}
};

/*==========================================================================
	AR6IODevice
==========================================================================*/

class R6ENGINE_API AR6IODevice : public AR6IOObject
{
public:
	BITFIELD bShowLog : 1;
	FLOAT m_fPlantTimeMin;
	FLOAT m_fPlantTimeMax;
	UTexture* m_InteractionIcon;
	USound* m_PhoneBuggingSnd;
	USound* m_PhoneBuggingStopSnd;
	TArray<UMaterial*> m_ArmedTextures;
	FVector m_vOffset;


protected:
	AR6IODevice() {}
};

/*==========================================================================
	AR6THeadAttachment
==========================================================================*/

class R6ENGINE_API AR6THeadAttachment : public AStaticMeshActor
{
public:

protected:
	AR6THeadAttachment() {}
};

/*==========================================================================
	AR6LadderCollision
==========================================================================*/

class R6ENGINE_API AR6LadderCollision : public AActor
{
public:

protected:
	AR6LadderCollision() {}
};

/*==========================================================================
	UR6InteractiveObjectActionLoopRandomAnim
==========================================================================*/

class R6ENGINE_API UR6InteractiveObjectActionLoopRandomAnim : public UR6InteractiveObjectAction
{
public:
	TArray<FName> m_aAnimName;


protected:
	UR6InteractiveObjectActionLoopRandomAnim() {}
};

/*==========================================================================
	UR6InteractiveObjectActionLoopAnim
==========================================================================*/

class R6ENGINE_API UR6InteractiveObjectActionLoopAnim : public UR6InteractiveObjectActionPlayAnim
{
public:
	FRange m_LoopTime;


protected:
	UR6InteractiveObjectActionLoopAnim() {}
};

/*==========================================================================
	UR6InteractiveObjectActionToggleDevice
==========================================================================*/

class R6ENGINE_API UR6InteractiveObjectActionToggleDevice : public UR6InteractiveObjectAction
{
public:
	AR6IODevice* m_iodevice;
	TArray<AR6IOBomb*> m_aIOBombs;


protected:
	UR6InteractiveObjectActionToggleDevice() {}
};

/*==========================================================================
	UR6InteractiveObjectActionGoto
==========================================================================*/

class R6ENGINE_API UR6InteractiveObjectActionGoto : public UR6InteractiveObjectAction
{
public:
	AActor* m_Target;


protected:
	UR6InteractiveObjectActionGoto() {}
};

/*==========================================================================
	UR6InteractiveObjectActionLookAt
==========================================================================*/

class R6ENGINE_API UR6InteractiveObjectActionLookAt : public UR6InteractiveObjectAction
{
public:
	AActor* m_Target;


protected:
	UR6InteractiveObjectActionLookAt() {}
};

/*==========================================================================
	AR6GrenadeDecal
==========================================================================*/

class R6ENGINE_API AR6GrenadeDecal : public AR6DecalsBase
{
public:
	UTexture* m_GrenadeDecalTexture;


protected:
	AR6GrenadeDecal() {}
};

/*==========================================================================
	UR6HostageVoicesFemaleFrench
==========================================================================*/

class R6ENGINE_API UR6HostageVoicesFemaleFrench : public UR6HostageVoices
{
public:

protected:
	UR6HostageVoicesFemaleFrench() {}
};

/*==========================================================================
	UR6HostageVoicesFemaleBritish
==========================================================================*/

class R6ENGINE_API UR6HostageVoicesFemaleBritish : public UR6HostageVoices
{
public:

protected:
	UR6HostageVoicesFemaleBritish() {}
};

/*==========================================================================
	UR6HostageVoicesFemaleSpanish
==========================================================================*/

class R6ENGINE_API UR6HostageVoicesFemaleSpanish : public UR6HostageVoices
{
public:

protected:
	UR6HostageVoicesFemaleSpanish() {}
};

/*==========================================================================
	UR6HostageVoicesFemaleNorwegian
==========================================================================*/

class R6ENGINE_API UR6HostageVoicesFemaleNorwegian : public UR6HostageVoices
{
public:

protected:
	UR6HostageVoicesFemaleNorwegian() {}
};

/*==========================================================================
	UR6HostageVoicesFemalePortuguese
==========================================================================*/

class R6ENGINE_API UR6HostageVoicesFemalePortuguese : public UR6HostageVoices
{
public:

protected:
	UR6HostageVoicesFemalePortuguese() {}
};

/*==========================================================================
	UR6HostageVoicesMaleFrench
==========================================================================*/

class R6ENGINE_API UR6HostageVoicesMaleFrench : public UR6HostageVoices
{
public:

protected:
	UR6HostageVoicesMaleFrench() {}
};

/*==========================================================================
	UR6HostageVoicesMaleBritish
==========================================================================*/

class R6ENGINE_API UR6HostageVoicesMaleBritish : public UR6HostageVoices
{
public:

protected:
	UR6HostageVoicesMaleBritish() {}
};

/*==========================================================================
	UR6HostageVoicesMaleSpanish
==========================================================================*/

class R6ENGINE_API UR6HostageVoicesMaleSpanish : public UR6HostageVoices
{
public:

protected:
	UR6HostageVoicesMaleSpanish() {}
};

/*==========================================================================
	UR6HostageVoicesMaleNorwegian
==========================================================================*/

class R6ENGINE_API UR6HostageVoicesMaleNorwegian : public UR6HostageVoices
{
public:

protected:
	UR6HostageVoicesMaleNorwegian() {}
};

/*==========================================================================
	UR6HostageVoicesMalePortuguese
==========================================================================*/

class R6ENGINE_API UR6HostageVoicesMalePortuguese : public UR6HostageVoices
{
public:

protected:
	UR6HostageVoicesMalePortuguese() {}
};

/*==========================================================================
	UR6TerroristVoicesSpanish1
==========================================================================*/

class R6ENGINE_API UR6TerroristVoicesSpanish1 : public UR6TerroristVoices
{
public:

protected:
	UR6TerroristVoicesSpanish1() {}
};

/*==========================================================================
	UR6TerroristVoicesSpanish2
==========================================================================*/

class R6ENGINE_API UR6TerroristVoicesSpanish2 : public UR6TerroristVoices
{
public:

protected:
	UR6TerroristVoicesSpanish2() {}
};

/*==========================================================================
	UR6TerroristVoicesGerman1
==========================================================================*/

class R6ENGINE_API UR6TerroristVoicesGerman1 : public UR6TerroristVoices
{
public:

protected:
	UR6TerroristVoicesGerman1() {}
};

/*==========================================================================
	UR6TerroristVoicesGerman2
==========================================================================*/

class R6ENGINE_API UR6TerroristVoicesGerman2 : public UR6TerroristVoices
{
public:

protected:
	UR6TerroristVoicesGerman2() {}
};

/*==========================================================================
	UR6TerroristVoicesPortuguese
==========================================================================*/

class R6ENGINE_API UR6TerroristVoicesPortuguese : public UR6TerroristVoices
{
public:

protected:
	UR6TerroristVoicesPortuguese() {}
};

/*==========================================================================
	UR6RainbowOtherTeamVoices1
==========================================================================*/

class R6ENGINE_API UR6RainbowOtherTeamVoices1 : public UR6RainbowOtherTeamVoices
{
public:

protected:
	UR6RainbowOtherTeamVoices1() {}
};

/*==========================================================================
	UR6RainbowOtherTeamVoices2
==========================================================================*/

class R6ENGINE_API UR6RainbowOtherTeamVoices2 : public UR6RainbowOtherTeamVoices
{
public:

protected:
	UR6RainbowOtherTeamVoices2() {}
};

/*==========================================================================
	UR6CommonRainbowMemberVoices
==========================================================================*/

class R6ENGINE_API UR6CommonRainbowMemberVoices : public UR6CommonRainbowVoices
{
public:

protected:
	UR6CommonRainbowMemberVoices() {}
};

/*==========================================================================
	UR6CommonRainbowPlayerVoices
==========================================================================*/

class R6ENGINE_API UR6CommonRainbowPlayerVoices : public UR6CommonRainbowVoices
{
public:

protected:
	UR6CommonRainbowPlayerVoices() {}
};

/*==========================================================================
	UR6MultiCoopMemberVoices
==========================================================================*/

class R6ENGINE_API UR6MultiCoopMemberVoices : public UR6MultiCoopVoices
{
public:
	USound* m_sndGasThreat;
	USound* m_sndGrenadeThreat;


protected:
	UR6MultiCoopMemberVoices() {}
};

/*==========================================================================
	UR6MultiCoopPlayerVoices1
==========================================================================*/

class R6ENGINE_API UR6MultiCoopPlayerVoices1 : public UR6MultiCoopVoices
{
public:

protected:
	UR6MultiCoopPlayerVoices1() {}
};

/*==========================================================================
	UR6MultiCoopPlayerVoices2
==========================================================================*/

class R6ENGINE_API UR6MultiCoopPlayerVoices2 : public UR6MultiCoopVoices
{
public:

protected:
	UR6MultiCoopPlayerVoices2() {}
};

/*==========================================================================
	UR6MultiCoopPlayerVoices3
==========================================================================*/

class R6ENGINE_API UR6MultiCoopPlayerVoices3 : public UR6MultiCoopVoices
{
public:

protected:
	UR6MultiCoopPlayerVoices3() {}
};

/*==========================================================================
	AR6DoorLockedIcon
==========================================================================*/

class R6ENGINE_API AR6DoorLockedIcon : public AR6ReferenceIcons
{
public:

protected:
	AR6DoorLockedIcon() {}
};

/*==========================================================================
	AR6DoorIcon
==========================================================================*/

class R6ENGINE_API AR6DoorIcon : public AR6ReferenceIcons
{
public:

protected:
	AR6DoorIcon() {}
};

/*==========================================================================
	AR6IOSlidingWindow
==========================================================================*/

class R6ENGINE_API AR6IOSlidingWindow : public AR6IActionObject
{
public:
	BYTE eOpening;
	INT m_iInitialOpening;
	INT sm_iInitialOpening;
	BITFIELD m_bIsWindowLocked : 1;
	BITFIELD sm_bIsWindowLocked : 1;
	BITFIELD m_bIsWindowClosed : 1;
	FLOAT C_fWindowOpen;
	FLOAT m_iMaxOpening;
	FLOAT m_TotalMovement;
	FVector sm_Location;


protected:
	AR6IOSlidingWindow() {}
};

/*==========================================================================
	AR6TerroristIcon
==========================================================================*/

class R6ENGINE_API AR6TerroristIcon : public AR6ReferenceIcons
{
public:

protected:
	AR6TerroristIcon() {}
};

/*==========================================================================
	AR6CameraSpot
==========================================================================*/

class R6ENGINE_API AR6CameraSpot : public AActor
{
public:

protected:
	AR6CameraSpot() {}
};

/*==========================================================================
	AR6ExplodingBarel
==========================================================================*/

class R6ENGINE_API AR6ExplodingBarel : public AR6InteractiveObject
{
public:
	INT m_iEnergy;
	FLOAT m_fExplosionRadius;
	FLOAT m_fKillBlastRadius;
	AEmitter* m_pEmmiter;
	UClass* m_pExplosionLight;


protected:
	AR6ExplodingBarel() {}
};

#endif // !NAMES_ONLY

#ifndef NAMES_ONLY
#undef AUTOGENERATE_NAME
#undef AUTOGENERATE_FUNCTION
#endif

#if _MSC_VER
#pragma pack(pop)
#endif
