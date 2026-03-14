//=============================================================================
//  R6PlayerController.uc : This is the Player Controller class for all Rainbow 6
//                          characters.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/04/03 * Created by Rima Brek
//    02 May 2001  Aristo Kolokathis        Added varibles for needed by R6Weapons
//    2001/07/24   Joel Tremblay            Add Shake view and Damage Attitude to
//  Note: if you make R6PlayerController native then you will need to take care so
//  that the names in eDefaultCircumstantialAction do not conflict with other enums
//=============================================================================
class R6PlayerController extends PlayerController
    native
    config(User);

// --- Constants ---
const Authority_Max =  1;
const Authority_Admin =  1;
const Authority_None =  0;
const K_KickFreqTime =  300;
const K_MaxVote =  3;
const K_EmptyBallot =  3;
const K_VotedNo =  2;
const K_VotedYes =  1;
const K_CanNotVote =  0;
const K_MinVote =  0;
const MAX_ProneSpeedRotation =  6600;
const MAX_Pitch =  2000;
const K_MaxBanPageSize =  10;

// --- Enums ---
enum eGamePasswordRes
{
    GPR_None,
    GPR_MissingPasswd,
    GPR_PasswdSet,
    GPR_PasswdCleared
};
enum eDefaultCircumstantialAction
{
    PCA_None,
    PCA_TeamRegroup,
    PCA_TeamMoveTo,
    PCA_MoveAndGrenade,
	PCA_GrenadeFrag,
	PCA_GrenadeGas,
	PCA_GrenadeFlash,
	PCA_GrenadeSmoke	
};
enum eDeathCameraMode
{
    eDCM_FIRSTPERSON,
    eDCM_THIRDPERSON,
    eDCM_FREETHIRDPERSON,
    eDCM_GHOST,
    eDCM_FADETOBLACK
};

// --- Structs ---
struct STImpactShake
{
    var() INT    iBlurIntensity;
    var() FLOAT  fWaveTime;     //Time to wave
    var() FLOAT  fRollMax;      //Max Roll Angle �(0-16384)
    var() FLOAT  fRollSpeed;    //Current Roll Speed 
    var() FLOAT  fReturnTime;   //Effect on character Position
};

struct STBanPage
{
    var string szBanID[K_MaxBanPageSize];
};

struct stSoundPriorityPtr { var int Ptr; };

struct stSoundPriority
{
    var R6SoundReplicationInfo  aSoundRepInfo;
    var Sound                   sndPlayVoice;
    var INT                     iPriority;
    var BYTE                    eSlotUse;
    var BYTE                    ePawnType;
    var FLOAT                   fTimeStart;
    var BOOL                    bIsPlaying;
    var BOOL                    bWaitToFinishSound;
};

// --- Variables ---
// var ? aSoundRepInfo; // REMOVED IN 1.60
// var ? bIsPlaying; // REMOVED IN 1.60
// var ? bWaitToFinishSound; // REMOVED IN 1.60
// var ? ePawnType; // REMOVED IN 1.60
// var ? eSlotUse; // REMOVED IN 1.60
// var ? fTimeStart; // REMOVED IN 1.60
// var ? iPriority; // REMOVED IN 1.60
// var ? m_fLastVoteKickTime; // REMOVED IN 1.60
// var ? sndPlayVoice; // REMOVED IN 1.60
// var ? szBanID; // REMOVED IN 1.60
var /* replicated */ R6Rainbow m_pawn;
var /* replicated */ R6RainbowTeam m_TeamManager;
// Player current action
var R6CircumstantialActionQuery m_PlayerCurrentCA;
var R6GameMenuCom m_MenuCommunication;
// Action sent to the team (or to self)
var R6CircumstantialActionQuery m_RequestedCircumstantialAction;
var /* replicated */ bool m_bSkipBeginState;
var bool bShowLog;
// ^ NEW IN 1.60
var /* replicated */ Rotator m_rCurrentShakeRotation;
// Player action progress (0-100)
var /* replicated */ int m_iPlayerCAProgress;
var Rotator m_rTotalShake;
// CA of the object that the player is currently looking at
var /* replicated */ R6CircumstantialActionQuery m_CurrentCircumstantialAction;
// server can't access the client's RoseDesVents class
var R6InteractionCircumstantialAction m_InteractionCA;
// points to the local player's GameService class
var R6AbstractGameService m_GameService;
var R6GameOptions m_GameOptions;
// new pitch the camera will return to when the firing is over.
var Vector m_vNewReturnValue;
var byte m_bPeekRight;
var byte m_bPeekLeft;
var int m_iSpectatorYaw;
var bool m_bSpectatorCameraTeamOnly;
// MissionPack1 2
var R6IOSelfDetonatingBomb m_pSelfDetonatingBomb;
var Actor m_PrevViewTarget;
// false by default: helmet camera for the rainbow 6 player
var bool m_bHelmetCameraOn;
// for spectator camera when player dies and is restricted to team only camera
var int m_iTeamId;
// MPF1
//MissionPack1
var float m_fStartSurrenderTime;
// equal to the pawn which is arresting/rescuing this
var R6Pawn m_pInteractingRainbow;
var STImpactShake m_stImpactDazed;
// ^ NEW IN 1.60
var Rotator m_rHitRotation;
var STImpactShake m_stImpactKO;
// ^ NEW IN 1.60
var float m_fMaxShake;
var bool m_bAttachCameraToEyes;
var STImpactShake m_stImpactStun;
// ^ NEW IN 1.60
var STImpactShake m_stImpactHit;
// ^ NEW IN 1.60
var float m_fShakeTime;
//Time to recover from the intensity
var float m_fBlurReturnTime;
var float m_fLastVoteTime;
// ^ NEW IN 1.60
var float m_fShakeReturnTime;
var R6InteractionInventoryMnu m_InteractionInventory;
var bool m_bShowCompleteHUD;
var int m_iBanPage;
// to switch between 3x and 9x zoom
var bool m_bScopeZoom;
var STBanPage m_BanPage;
var float m_fCurrentShake;
// set to display or not to display the first person weapons.
var bool m_bUseFirstPersonWeapon;
// Interactions (registered to the InteractionMaster)
var InteractionMaster m_InteractionMaster;
//Blur intensity when hit by a bullet
var int m_iShakeBlurIntensity;
var byte m_bSpecialCrouch;
// Character activated the zoom with a sniper rifle
var bool m_bSniperMode;
// True by default: display of not the FP Weapon
var bool m_bShowFPWeapon;
//  Auto Aim
// 0 (off), 1(low), 2(medium) or 3(high)
var byte m_wAutoAim;
// Spam Filter Variables
//Time of last "say"
var transient float m_fLastBroadcastTimeStamp;
//Time of the "say" before the last one
var transient float m_fPreviousBroadcastTimeStamp;
//Set to -1.0 to unlock chatlock
var transient float m_fEndOfChatLockTime;
var R6CommonRainbowVoices m_CommonPlayerVoicesMgr;
var int m_iPitchReturn;
// speed the yaw is returning to his original position
var int m_iYawReturn;
var int m_iSpectatorPitch;
var bool m_bDisplayActionProgress;
// For shake
var float m_fHitEffectTime;
//R6MOTIONBLUR
//Current Blur value with a specific timer to reach 0
var float m_fTimedBlurValue;
var byte m_bOldPeekRight;
// direction of the last bullet to shake the camera in that direction
var Rotator m_rLastBulletDirection;
var float m_fMilestoneMessageLeft;
var bool m_bCameraGhost;
var byte m_bOldPeekLeft;
var bool m_bCanChangeMember;
var float LastDoorUpdateTime;
var Color m_SpectatorColor;
var R6PlayerController m_TeamKiller;
//============================================================================
// END Vars and consts used in kicking
//============================================================================
// this player is logged in as an administrator
var /* replicated */ int m_iAdmin;
var string m_szBanSearch;
// fluid movement key is used to set the posture as well as reset it to normal (double click)... need to make sure that
// the double click does not restart the fluid movement mode.
var float m_fPostFluidMovementDelay;
// True will display all the hit logs
var bool m_bShowHitLogs;
var bool m_bAllTeamsHold;
// R6DEBUG
var bool m_bFixCamera;
//Fire Shake values
// Current Weapon return speed for shake
var int m_iReturnSpeed;
var bool m_bCameraFirstPerson;
var bool m_bCameraThirdPersonFixed;
var bool m_bCameraThirdPersonFree;
// this flag used to keep track of which admins are in the server options or kit restriction page
// only valid for admins
var bool m_bInAnOptionsPage;
var Vector m_vRequestedLocation;
var bool m_bPlayDeathMusic;
//============================================================================
// BEGIN Vars and consts used in kicking
//============================================================================
var int m_iVoteResult;
// MissionPack1 true if is Secure action, false if is Free action
var bool m_bIsSecuringRainbow;
//shake Camera values
var bool m_bShakeActive;
//Tweak shaking
var float m_fDesignerSpeedFactor;
var float m_fMaxShakeTime;
var bool m_bPawnInitialized;
// Used to prevent display two menu at the same time
var bool m_bAMenuIsDisplayed;
//go to dead state after team selection
var bool m_bDeadAfterTeamSel;
var bool m_bWantTriggerLag;
var float m_fLastUpdateServerCheckTime;
// ^ NEW IN 1.60
// true if a self detonating bomb has been detected in the level (temporary? It's like a patch)
var bool m_bBombSearched;
var bool m_bQuitToUpdateServerDisplayed;
// ^ NEW IN 1.60
var Sound m_sndUpdateWritableMap;
// request if this player wants to apply penalty to team-mate killer
var /* replicated */ bool m_bRequestTKPopUp;
var EPawnType m_ePenaltyForKillingAPawn;
var byte m_bPlayerRun;
var string m_CharacterName;
//used to remove an Access None when
var R6Rainbow m_BackupTeamLeader;
//R6Matinee:
var bool m_bMatineeRunning;
// this flag tells the server if the client sent the end of round data to the server
var bool m_bEndOfRoundDataReceived;
var bool m_bFadeToBlack;
var bool m_bPlacedExplosive;
var float m_fCurrentDeltaTime;
var bool m_bDisplayMilestoneMessage;
var float m_fDesignerJumpFactor;
//Time of the last "vote" message sent
var transient float m_fLastVoteEmoteTimeStamp;
var config string m_szLastAdminPassword;
var config int m_iFluidMovementSpeed;
var config int m_iFastDoorSpeed;
var config int m_iDoorSpeed;
// rbrek 30 aug 2001
// this flag will prevent attempting to initiate another circumstantial action while one is in progress...
// also hides the circumstantial info during this time...
var bool m_bCircumstantialActionInProgress;
var byte m_bSpeedUpDoor;
var float m_fOxygeneLevel;
// ^ NEW IN 1.60
var Sound m_sndMissionComplete;
var Sound m_sndDeathMusic;
// denotes if this pop-up box was already popped
var bool m_bAlreadyPoppedTKPopUpBox;
//client side, waiting on pop-up
var bool m_bProcessingRequestTKPopUp;
// this player broke the rules and killed a team-mate
var bool m_bHasAPenalty;
// For default action : Move Team To
var Vector m_vDefaultLocation;
var bool m_bDisplayMessage;
// Variable for the training
var bool m_bPreventTeamMemberUse;
var float m_fMilestoneMessageDuration;
var string m_szMileStoneMessage;
var Rotator m_rCameraRotation;
// DEBUG - for freezing the position of the camera...
var Vector m_vCameraLocation;
var byte m_bReloading;
// at the next round, if m_bHasAPenalty, we set this flag to true
var bool m_bPenaltyBox;
// this is used on server side to remember where controller was spawned so that pawn will be spawned at the same place
var NavigationPoint StartSpot;
var array<array> m_PlayVoicesPriority;
// Position of targeted pawn.  Only valid when target pawn != none
var Vector m_vAutoAimTarget;
// Currently targeted pawn
var R6Pawn m_targetedPawn;
// Time remaining before the reticule hit the lock pos
var float m_fRetLockTime;
// Current Reticule Y position on screen
var float m_fCurrRetPosY;
// Current Reticule X position on screen
var float m_fCurrRetPosX;
// Desired Reticule Y position on screen
var float m_fRetLockPosY;
// Desired Reticule X position on screen
var float m_fRetLockPosX;
var int m_iSpeedLevels[3];
// ^ NEW IN 1.60
// used for the
var config float m_fTeamMoveToDistance;
var float m_fCompteurFrameDetection;
// ^ NEW IN 1.60

// --- Functions ---
// function ? ClientPreBeginSurrending(...); // REMOVED IN 1.60
// function ? LogAllPlayerInfo(...); // REMOVED IN 1.60
// function ? LogPlayerInfo(...); // REMOVED IN 1.60
// function ? LogVoteInfo(...); // REMOVED IN 1.60
// function ? ServerStartSurrending(...); // REMOVED IN 1.60
// function ? ServerUnlockCheat(...); // REMOVED IN 1.60
// function ? SetDeathsStat(...); // REMOVED IN 1.60
// function ? SetFragStat(...); // REMOVED IN 1.60
// function ? SetHealthStat(...); // REMOVED IN 1.60
// function ? SetRoundsFiredStat(...); // REMOVED IN 1.60
// function ? SetRoundsHitStat(...); // REMOVED IN 1.60
// function ? SetRoundsPlayedStat(...); // REMOVED IN 1.60
// function ? SetRoundsWonStat(...); // REMOVED IN 1.60
// function ? ShowMe(...); // REMOVED IN 1.60
// function ? ToggleRestart(...); // REMOVED IN 1.60
// function ? UnlockCheat(...); // REMOVED IN 1.60
    // Nothing to do when we are dead
exec function PlayFiring() {}
    // rbrek : add a timeout - do not stay in this state indefinitely
event Tick(float fDeltaTime) {}
exec function GraduallyCloseDoor() {}
exec function GraduallyOpenDoor() {}
function Timer() {}
function bool PlayerIsFiring() {}
// ^ NEW IN 1.60
delegate ServerChangeTeams(bool bNextTeam) {}
function ChangeTeams(bool bNextTeam) {}
	// MPF_Milan_7_1_2003 - removed override of PlayerMove
	// MPF_Milan_7_1_2003 - override forbidden functions
exec function PreviousMember() {}
exec function NextMember() {}
function EnterSpectatorMode() {}
function ResetCurrentState() {}
function ClientDisableFirstPersonViewEffects(optional bool bChangingPawn) {}
function ClientFadeSound(ESoundSlot eSlot, int iVolume, float fTime) {}
function FreeRainbow(R6Pawn pOther) {}
function SecureRainbow(R6Pawn pOther) {}
simulated function bool TeamMemberHasGrenadeType(eWeaponGrenadeType grenadeType) {}
// ^ NEW IN 1.60
///////////////////////////////////////////////////////////////////////////////
// DEFAULT CIRCUMSTANTIAL ACTIONS
// R6GetCircumstantialActionString()
///////////////////////////////////////////////////////////////////////////////
simulated function string R6GetCircumstantialActionString(int iAction) {}
// ^ NEW IN 1.60
//============================================================================
// DispatchOrder -
//============================================================================
function DispatchOrder(R6Pawn pSource, int iOrder) {}
function Possess(Pawn aPawn) {}
delegate ServerBroadcast(optional name type, coerce string Msg, PlayerController Sender) {}
delegate ServerMove(optional int OldAccel, optional byte OldTimeDelta, int iNewRotOffset, int View, bool NewbCrawl, bool NewbDuck, bool NewbRun, Vector ClientLoc, Vector InAccel, float TimeStamp) {}
delegate ServerSetHelmetParams(float fZoomLevel, bool bScopeZoom) {}
function DoZoom(optional bool bTurnOff) {}
delegate ServerPlayerPref(PlayerPrefInfo newPlayerPrefs) {}
delegate ServerNetLogActor(Actor InActor) {}
delegate ServerLogBandWidth(bool bLogBandWidth) {}
delegate ServerSetPlayerReadyStatus(bool _bPlayerReady) {}
function PlaySoundAffectedByGrenade(EGrenadeType eType) {}
function PlaySoundActionCompleted(eDeviceAnimToPlay eAnimToPlay) {}
function ServerSwitchWeapon(byte u8CurrentWeapon, R6EngineWeapon NewWeapon) {}
function PlaySoundInflictedDamage(Pawn DeadPawn) {}
simulated function bool R6ActionCanBeExecuted(int iAction, PlayerController PlayerController) {}
// ^ NEW IN 1.60
function DoLogActors() {}
function PlaySoundCurrentAction(ERainbowTeamVoices eVoices) {}
exec function AdminLogin(string _Password) {}
function Ban(string szKickName) {}
function BanId(string szKickName) {}
exec function BanList(string szPrefixBanID) {}
delegate ServerUpdatePeeking(bool bPeekRight, bool bPeekLeft) {}
///////////////////////////////////////////////////////////////////////////////////////
// rbrek 27 nov 2001
// UpdatePlayerPeeking()
//   new full peeking controls, now there is one button to peek left and one button
//   to peek right.  a peek button must be held down to continue peeking, when the
//	 button is released, the player returns to normal posture.
// note:  using either the peekleft or peekright buttons while in a
//		  fluid-set position will reset the player's posture.
///////////////////////////////////////////////////////////////////////////////////////
function UpdatePlayerPeeking() {}
function ClientServerMap(string explanation, string _szPlayerName, string szNewMapname) {}
function ClientNextMapVoteMessage(string szRequestingPlayer) {}
// ^ NEW IN 1.60
function ClientRestartRoundMsg(string explanation, string _AdminName) {}
function ClientRestartMatchMsg(string explanation, string _AdminName) {}
//------------------------------------------------------------------
// ServerRequestSkins
//	Client request the skin on the server
//------------------------------------------------------------------
function ServerRequestSkins() {}
// this function is sent and executed directly to the server.
// Basic Command
function VoteKick(string szKickName) {}
function VoteKickID(string szKickName) {}
//------------------------------------------------------------------
// SetCrouchBlend: set peeking info (single player and multiplayed)
//
//------------------------------------------------------------------
event SetCrouchBlend(float fCrouchBlend) {}
function AutoAdminLogin(string _Password) {}
function ServerAdminLogin(string _Password) {}
function ClientAdminLogin(bool _loginRes) {}
// we need to do the appropriate animations for weapons,
simulated event RenderOverlays(Canvas Canvas) {}
function ClientPasswordMessage(eGamePasswordRes iMessageType) {}
function bool CheckAuthority(int _LevelNeeded) {}
// ^ NEW IN 1.60
// this is executed on the server
// Admin Command
function Kick(string szKickName) {}
function KickId(string szKickName) {}
function ServerSetGender(bool bIsFemale) {}
function ClientSetWeaponSound(R6PawnReplicationInfo PawnRepInfo, class<R6EngineWeapon> PrimaryWeaponClass, byte u8CurrentWeapon) {}
delegate ServerExecFire(optional float f) {}
function ClientPlayMusic(Sound Sound) {}
delegate ServerTKPopUpDone(bool _bApplyTeamKillerPenalty) {}
function TKPopUpBox(string _KillerName) {}
// Admin Command
function LoadServer(string FileName) {}
function ClientServerChangingInfo(bool _bCanChangeOptions) {}
function ClientVoteSessionAbort(string _PlayerName) {}
function ClientNewPassword(string _AdminName) {}
function ClientAdminKickOff(string _AdminName, string _KickedName) {}
function ClientAdminBanOff(string _AdminName, string _KickedName) {}
function ClientVoteChangeMap(string _AdminName) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// SetPeekingInfo: set peeking info (single player and multiplayed)
//
//------------------------------------------------------------------
function SetPeekingInfo(ePeekingMode eMode, float fPeekingRatio, optional bool bPeekLeft) {}
function ClientGameMsg(string szLocFile, string szPreMsg, string szMsgID, optional Sound sndSound, optional int iLifeTime) {}
//------------------------------------------------------------------
// Dispatch game msg: Default RavenShield and MissionObjective
//
//------------------------------------------------------------------
function ClientMissionObjMsg(string szLocFile, string szPreMsg, string szMsgID, optional Sound sndSound, optional int iLifeTime) {}
function ClientKickVoteMessage(PlayerReplicationInfo PRIKickPlayer, string szRequestingPlayer) {}
// Admin Command
function RestartRound(string explanation) {}
function RestartMatch(string explanation) {}
delegate ServerGraduallyOpenDoor(byte bSpeedUpDoor) {}
delegate ServerGraduallyCloseDoor(byte bSpeedUpDoor) {}
function CommonUpdatePeeking(byte bPeekLeftButton, byte bPeekRightButton) {}
delegate ServerChangeOperative(int iOperativeID, int iTeamId) {}
function ServerGhost(Pawn aPawn) {}
//client to server
function UnBan(string szPrefixBanID) {}
function ServerWalk(Pawn aPawn) {}
function ServerPlayerInvisible(bool bIsVisible) {}
function NewPassword(string _NewPassword) {}
// Admin Command
function LockServer(optional string _NewPassword, bool _bFlagSetting) {}
// Basic Command
exec function PlayerList() {}
function PossessInit(Pawn aPawn) {}
function ChangeOperative(int iOperativeID, int iTeamId) {}
event float GetZoomMultiplyFactor(float fWeaponMaxZoom) {}
// ^ NEW IN 1.60
function ToggleHelmetCameraZoom(optional bool bTurnOff) {}
// set the zoom level of the camera on the helmet
function HelmetCameraZoom(float fZoomLevel) {}
function ClientChatDisabledMsg(int iTimeRem) {}
// ^ NEW IN 1.60
// 0 is no blur, 100 is full blur
function Blur(int iValue) {}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//R6MOTIONBLUR
function ResetBlur() {}
function ClientChatAbuseMsg(int iChatLockDuration) {}
// ^ NEW IN 1.60
simulated function R6PlayerMove(float DeltaTime) {}
delegate R6DamageAttitudeTo(eStunResult eStunFromTable, eKillResult eKillResultFromTable, Vector vBulletMomentum, Pawn Other) {}
delegate ClientGotoState(name NewState, name NewLabel) {}
function DoDbgLogActor(Actor anActor) {}
//------------------------------------------------------------------
// ServerSetBipodRotation: set the int for replication
//
//------------------------------------------------------------------
delegate ServerSetBipodRotation(float fRotation) {}
function ServerMap(int iGotoMapId, string explanation) {}
function ClientNoBanMatches() {}
exec function UnBanPos(int iPosition) {}
function Admin(string CommandLine) {}
//=======================================
// SendSettingsAndRestartServer: This save new settings and restart the server
//=======================================
function SendSettingsAndRestartServer(bool _bChangeWasMade, bool _bRestrictionKitChange) {}
function bool PlayerLookingAtFirstDoor() {}
// ^ NEW IN 1.60
// Send a message to all players.
delegate Say(string Msg) {}
delegate TeamSay(string Msg) {}
delegate ServerSendGoCode(EGoCode eGo) {}
delegate ServerSetPeekingInfoRight(byte PackedPeekingRatio, ePeekingMode eMode) {}
//------------------------------------------------------------------
// SetPeekingInfo: set peeking info
//
//------------------------------------------------------------------
delegate ServerSetPeekingInfoLeft(byte PackedPeekingRatio, ePeekingMode eMode) {}
function ClientDeathMessage(byte bSuicideType, string Killer, string killed) {}
delegate ServerSetCrouchBlend(float fCrouchBlend) {}
///////////////////////////////////////////////////////////////////////////////////////
// PassedYawLimit()
// rbrek - 10 april 2002
///////////////////////////////////////////////////////////////////////////////////////
simulated function bool PassedYawLimit(Rotator rRotationOffset) {}
// ^ NEW IN 1.60
//
function ClientUpdateLadderStat(string _UserUbiID, int _iKillStat, int _iDeathStat, float fPlayTime) {}
//------------------------------------------------------------------
// SetGameMsg
//	the server broadcast game msg to client
//------------------------------------------------------------------
function SetGameMsg(string szMsgID, optional int iLifeTime, string szPreMsg, optional Sound sndSound, string szLocalization) {}
//------------------------------------------------------------------
// ClientResetGameMsg
//
//------------------------------------------------------------------
function ClientResetGameMsg() {}
function ClientPlayerVoteMessage(string _playerTwo, string _playerOne, int iResult) {}
function SetRestKitWithAsz(out array<array> _szARestKit, string _szNewValue, bool _bRemoveRest) {}
function ClientMPMiscMessage(string szMsgID, string Name, optional string szEndOfMsg) {}
function bool GraduallyControlDoor(out R6Door aDoor) {}
// ^ NEW IN 1.60
function SetRestKitWithAClass(out array<array> _pARestKit, class<Object> _pANewClassValue, bool _bRemoveRest) {}
function R6Shake(float fTime, float fMaxShake, float fMaxShakeTime) {}
function DisableFirstPersonViewEffects(optional bool bChangingPawn) {}
function ShakeView(Vector vImpactDirection, float fReturnTime, float fRollMax, Vector vPositionOffset, float fRollSpeed, float fWaveTime) {}
function CalcFirstPersonView(out Vector CameraLocation, out Rotator CameraRotation) {}
delegate ServerNewPing(int iNewPing) {}
delegate ServerSetPlayerStartInfo(string _armorName, string _WeaponName0, string _WeaponName1, string _BulletName0, string _BulletName1, string _WeaponGadgetName0, string _WeaponGadgetName1, string _GadgetName0, string _GadgetName1) {}
event PlayerTick(float fDeltaTime) {}
exec function ToggleSniperControl() {}
simulated function ProcessVoteKickRequest(R6PlayerController _playerController) {}
///////////////////////////////////////////////////////////////////////////////////////
// GetFacingDirection()
// returns direction faced relative to movement dir
// 0 = forward, 16384 = right, 32768 = back, 49152 = left
// RBrek - 14 Aug 2001 - made a modification so that if player is
//      strafing and moving forward the facing direction is forward...
///////////////////////////////////////////////////////////////////////////////////////
function int GetFacingDirection() {}
// ^ NEW IN 1.60
function ServerDbgLogActor(Actor anActor) {}
//------------------------------------------------------------------
// ClientGameTypeDescription: display the short game type description
//
//------------------------------------------------------------------
function ClientGameTypeDescription(string szGameTypeFlag) {}
function ClientPlayVoices(R6SoundReplicationInfo aAudioRepInfo, ESoundSlot eSlotUse, optional float fTime, optional bool bWaitToFinishSound, int iPriority, Sound sndPlayVoice) {}
function ClientVoteResult(optional string _PlayerName, bool VoteResult) {}
// Admin Command
exec function Map(int iGotoMapId, string explanation) {}
// Basic Command
function Vote(int _bVoteResult) {}
///////////////////////////////////////////////////////////////////////////////////////
// AdjustViewPitch()
///////////////////////////////////////////////////////////////////////////////////////
simulated function AdjustViewPitch(out int iPitch) {}
///////////////////////////////////////////////////////////////////////////////////////
// DirectionChanged()
//   rbrek 25 oct 2001
//   this function determines what the current diagonal direction is and return a bool
//   indicating whether the direction has changed.
///////////////////////////////////////////////////////////////////////////////////////
function bool DirectionChanged() {}
// ^ NEW IN 1.60
function CalcBehindView(out Rotator CameraRotation, out Vector CameraLocation, float Dist) {}
function ClientBanMatches(string _BanPrefix, STBanPage banPage) {}
function ServerPlayRecordedMsg(string Msg, EPreRecordedMsgVoices eRainbowVoices) {}
function SwitchWeapon(byte f) {}
function ServerSetUbiID(string _szUBIUserID) {}
function ReplicateTriggerLagInfo(bool _value) {}
simulated event SetMatchResult(string _UserUbiID, int iField, int iValue) {}
//===========================================================================================
// ServerNewMapsListSettings: This set the new map list settings of the server, values are store in R6ServerInfo unique instance
//===========================================================================================
function ServerNewMapListSettings(int iMapIndex, optional int _iLastItem, optional string _Map, optional string _GameType, optional int iUpdateGameType) {}
function Set1stWeaponDisplay(bool bShowWeapon) {}
function ClientHideReticule(bool bNewReticuleValue) {}
function ServerIndicatesInvalidCDKey(string _szErrorMsgKey) {}
//------------------------------------------------------------------
// GetPrefixToMsg
// "(DEAD) Pago "
// "(DEAD) Pago [ALPHA]"
//------------------------------------------------------------------
function string GetPrefixToMsg(PlayerReplicationInfo PRI, name MsgType) {}
// ^ NEW IN 1.60
function ClientFinalizeLoading(ZoneInfo aZoneInfo) {}
simulated function UpdateWeatherEmitter() {}
function ClientNewLobbyConnection(int iLobbyID, int iGroupID) {}
// Basic Command
exec function MapList() {}
simulated function ProcessKickRequest(R6PlayerController _playerController, optional bool bBan) {}
event PostRender(Canvas Canvas) {}
function ClientFadeCommonSound(int iVolume, float fTime) {}
function R6FillGrenadeSubAction(int iSubMenu, out R6AbstractCircumstantialActionQuery Query) {}
function HandleFluidMovement(float DeltaTime) {}
//------------------------------------------------------------------
// ResettingLevel
//	the server inform the client to reset the level
//------------------------------------------------------------------
delegate ResettingLevel(int iNbOfRestart) {}
final native function PlayVoicesPriority(R6SoundReplicationInfo aAudioRepInfo, Sound sndPlayVoice, ESoundSlot eSlotUse, int iPriority, optional bool bWaitToFinishSound, optional float fTime) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// ClientSetMultiplayerSkins
//	Server set the skin on the client
//------------------------------------------------------------------
function ClientSetMultiplayerSkins(string G, string R, Material GreenMenuSkin, Region GreenMenuRegion, Material RedMenuSkin, Region RedMenuRegion) {}
// --- MissionPack1 2
simulated function RenderTimeLeft(Canvas C) {}
final native function string GetLocStringWithActionKey(string szText, string szActionKey) {}
// ^ NEW IN 1.60
function SetEyeLocation(float fDeltaTime, Pawn pViewTarget) {}
//------------------------------------------------------------------
// TeamMessage: inherited
//
//------------------------------------------------------------------
delegate TeamMessage(coerce string Msg, PlayerReplicationInfo PRI, name MsgType) {}
function DisplayMilestoneMessage(int iMilestoneNumber, int iWhoReached) {}
function SetWeaponSound(string szCurrentWeaponTxt, R6PawnReplicationInfo PawnRepInfo, byte u8CurrentWepon) {}
///////////////////////////////////////////////////////////////////////////////////////
// AdjustViewYaw()
///////////////////////////////////////////////////////////////////////////////////////
simulated function AdjustViewYaw(out int iYaw) {}
final native function string LocalizeTraining(string SectionName, string KeyName, string PackageName, int iBox, int iParagraph) {}
// ^ NEW IN 1.60
//===========================================================================================
// ServerNewKitRestSettings: This set the kit rest settings of the server, values are store in R6ServerInfo unique instance
//							  return true if a value was change
//===========================================================================================
function ServerNewKitRestSettings(bool _bRemoveRest, optional class<Object> _pANewClassValue, optional string _szNewValue, ERestKitID _eKitRestID) {}
simulated event ZoneChange(ZoneInfo NewZone) {}
function R6ViewShake(float fDeltaTime, out Rotator rRotationOffset) {}
///////////////////////////////////////////////////////////////////////////////////////
// CalcSmoothedRotation()
// used for spectator camera to smooth turning
///////////////////////////////////////////////////////////////////////////////////////
function CalcSmoothedRotation() {}
function ServerBanList(string szPrefixBanID, int _iPageNumber) {}
//once a game is started, this function is called once
simulated function HidePlanningActors() {}
exec function TeamsStatus() {}
final native function PlayerController FindPlayer(string inPlayerIdent, bool bIsIdInt) {}
// ^ NEW IN 1.60
delegate ServerTeamRequested(ePlayerTeamSelection eTeamSelected, optional bool bForceSelection) {}
delegate ServerReadyToLoadWeaponSound() {}
final native function UpdateReticule(float fDeltaTime) {}
// ^ NEW IN 1.60
//===========================================================================================
// ServerNewGeneralSettings: This set the new settings of the server, values are store in R6ServerInfo unique instance
//							 return true if a value was change
//===========================================================================================
function bool ServerNewGeneralSettings(optional bool _bNewValue, optional int _iNewValue, EButtonName _eButName) {}
// ^ NEW IN 1.60
///////////////////////////////////////////////////////////////////////////////
// DEFAULT CIRCUMSTANTIAL ACTIONS
// R6QueryCircumstantialAction()
///////////////////////////////////////////////////////////////////////////////
event R6QueryCircumstantialAction(out R6AbstractCircumstantialActionQuery Query, float fDistance, PlayerController PlayerController) {}
///////////////////////////////////////////////////////////////////////////////////////
// UpdateRotation()
///////////////////////////////////////////////////////////////////////////////////////
simulated function UpdateRotation(float DeltaTime, float maxPitch) {}
final native function UpdateCircumstantialAction() {}
// ^ NEW IN 1.60
final native function UpdateSpectatorReticule() {}
// ^ NEW IN 1.60
final native function DebugFunction() {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// ResetOriginalData
//
//------------------------------------------------------------------
simulated function ResetOriginalData() {}
simulated function FirstPassReset() {}
function Reset() {}
function bool ShouldDisplayIncomingMessages() {}
// ^ NEW IN 1.60
function ClientChangeMap() {}
function ClearReferences() {}
event InitInputSystem() {}
event InitMultiPlayerOptions() {}
function ClientShowWeapon() {}
simulated function bool ShouldDrawWeapon() {}
// ^ NEW IN 1.60
exec function ShowWeapon() {}
function ClientNotifySendMatchResults() {}
function ClientNotifySendStartMatch() {}
function ServerEndOfRoundDataSent() {}
simulated event PostBeginPlay() {}
function UpdateTriggerLagInfo() {}
simulated event PostNetBeginPlay() {}
event Destroyed() {}
function InitInteractions() {}
function DestroyInteractions() {}
simulated function SetPlayerStartInfo() {}
function ServerActionKeyPressed() {}
delegate ServerActionKeyReleased() {}
function InitMatineeCamera() {}
function EndMatineeCamera() {}
function ReloadWeapon() {}
delegate ServerReloadWeapon() {}
function CheckBob(float DeltaTime, float Speed2D, Vector Y) {}
// Bobbing is only used for rotation, to bring the weapon down when the character is walking
// All weapons are using only rotation, except pistols, where BobOffset is used
function WeaponBob(float BobDamping, out Rotator BobRotation, out Vector bobOffset) {}
///////////////////////////////////////////////////////////////////////////////////////
// HandleDiagonalStrafing()
// rbrek - 24 oct 2001
//   if the player is both strafing and moving forward/backward, bone rotation is used improve the appearance of the movement.
//   the entire skeleton (using root bone 'R6') is rotated to match the direction of the diagonal movement, and then the torso
//   is rotated back to reflect the direction that the player is looking (which remains straight ahead).
//   returns true if bone rotation is done, false otherwise...
///////////////////////////////////////////////////////////////////////////////////////
function HandleDiagonalStrafing() {}
function ResetFluidPeeking() {}
//---------------------------------------------------------------------------------------//
//                          INPUT exec() functions (controls)                            //
//---------------------------------------------------------------------------------------//
delegate ToggleTeamHold() {}
delegate ToggleAllTeamsHold() {}
exec function GoCodeAlpha() {}
exec function GoCodeBravo() {}
exec function GoCodeCharlie() {}
exec function GoCodeZulu() {}
exec function SkipDestination() {}
exec function NextTeam() {}
exec function PreviousTeam() {}
delegate RegroupOnMe() {}
exec function HideWeapon() {}
// ^ NEW IN 1.60
event string GetLocalPlayerIp() {}
// ^ NEW IN 1.60
exec function MyID() {}
function CountDownPopUpBoxDone() {}
function CountDownPopUpBox() {}
function addToOxygenLevel(float f) {}
// ^ NEW IN 1.60
function ClientStopFadeToBlack() {}
function ClientTeamIsDead() {}
function ServerAbortMission() {}
function ServerCompleteMission() {}
exec function RaisePosture() {}
exec function LowerPosture() {}
exec function Zoom() {}
exec function ToggleAutoAim() {}
exec function ChangeRateOfFire() {}
exec function PrimaryWeapon() {}
exec function SecondaryWeapon() {}
exec function GadgetOne() {}
exec function GadgetTwo() {}
function ClientNoKickAdmin() {}
function ClientCantRequestKickYet() {}
function ClientCantRequestChangeMapYet() {}
// ^ NEW IN 1.60
function ClientVoteInProgress() {}
function ClientNoAuthority() {}
function ClientPasswordTooLong() {}
///////////////////////////////////////////////////////////////////////////////////////
// rbrek 26 oct 2001
// TeamMovementMode()
//   player can change the current movement mode
//   cycles through the ROE: SPEED_Blitz, SPEED_Normal, SPEED_Cautious
///////////////////////////////////////////////////////////////////////////////////////
exec function TeamMovementMode() {}
///////////////////////////////////////////////////////////////////////////////////////
// rbrek 26 oct 2001
// RulesOfEngagement()
//   player can change the current rule of engagement
//   cycles through the ROE: MOVE_Assault, MOVE_Infiltrate, MOVE_Recon
///////////////////////////////////////////////////////////////////////////////////////
exec function RulesOfEngagement() {}
///////////////////////////////////////////////////////////////////////////////////////
// ResetSpecialCrouch()
// reset the Special Crouch mode:  stop peeking, and return to either upright or crouching,
// depending on which position is closer
///////////////////////////////////////////////////////////////////////////////////////
function ResetSpecialCrouch() {}
exec function PlayAltFiring() {}
exec function CycleHUDLayer() {}
exec function ToggleHelmet() {}
function ClientKickBadId() {}
delegate ServerNextMember() {}
//====
// Server Broadcasted messages
//====
function ClientTeamFullMessage() {}
delegate ServerPreviousMember() {}
function UpdatePlayerPostureAfterSwitch() {}
function bool PlayerIsInFrontOfDoubleDoors() {}
// ^ NEW IN 1.60
function HandleWalking() {}
exec function LogRest() {}
function ServerStartChangingInfo() {}
function ServerUnPausePreGameRoundTime() {}
//=================================================================================
// INTERACTION WITH MENU FOR SERVER SETTINGS
//=================================================================================
function ServerPausePreGameRoundTime() {}
exec function NextBanList() {}
//#ifdef R6PUNKBUSTER
function ClientPBVersionMismatch() {}
function ClientPlayerUnbanned() {}
exec function LogSpecialValues() {}
function InitializeMenuCom() {}
function ClientKickedOut() {}
// allows the client to exit gracefully
function ClientBanned() {}
simulated function ProcessVoteNextRequest() {}
// ^ NEW IN 1.60
function VoteNextMap() {}
// ^ NEW IN 1.60
function PlaySoundDamage(Pawn instigatedBy) {}
function UnPossess() {}
function ServerLogActors() {}
function ServerLogPawn() {}
function DoLogPawn() {}
exec function LogPawn() {}
simulated event bool IsPlayerPassiveSpectator() {}
// ^ NEW IN 1.60
event PlayerTeamSelectionReceived() {}
function bool CanIssueTeamOrder() {}
// ^ NEW IN 1.60
///////////////////////////////////////////////////////////////////////////////
// SetRequestedCircumstantialAction()
// rbrek 22 jan 2002
//   Set the current object being pointed to as the requested one so that even
//    if player immediately changes focus, the correct action is done.
///////////////////////////////////////////////////////////////////////////////
function SetRequestedCircumstantialAction() {}
delegate ServerWeaponUpAnimDone() {}
function WeaponUpState() {}
delegate Suicide() {}
function bool PlayerCanSwitchToAIBackup() {}
// ^ NEW IN 1.60
// make camera fall
function PawnDied() {}
//------------------------------------------------------------------
// NotifyLanded
//
//------------------------------------------------------------------
event bool NotifyLanded(Vector HitNormal) {}
// ^ NEW IN 1.60
function R6WeaponShake() {}
iterator function R6ClientWeaponShake() {}
// ^ NEW IN 1.60
function ResetCameraShake() {}
//Force the client to set unlock weapon to false.
function ClientForceUnlockWeapon() {}
function ResetPlayerVisualEffects() {}
function CancelShake() {}
function ExtractMissingLadderInformation() {}
function ServerStartClimbingLadder() {}
delegate ServerActionProgressStop() {}
function ClientActionProgressDone() {}
///////////////////////////////////////////////////////////////////////////////////////
//                     -- state PLAYERACTIONPROGRESS --
///////////////////////////////////////////////////////////////////////////////////////
//function ServerPlayerActionProgress(R6CircumstantialActionQuery newActionQuery)
delegate ServerPlayerActionProgress() {}
function ClientEndSurrended() {}
function ServerStartSurrended() {}
function ServerStartSurrenderSequence() {}

state CameraPlayer
{
    function SpectatorChangeTeams(bool bNextTeam) {}
    event ClientSetNewViewTarget() {}
    simulated function SetNewViewTarget(Actor aViewTarget) {}
    exec function NextMember() {}
	// MPF_Milan_7_1_2003 - removed override of PlayerMove
	// MPF_Milan_7_1_2003 - override forbidden functions
    exec function PreviousMember() {}
    simulated function ChangeTeams(bool bNextTeam) {}
	// MPF_Milan - removed overriding of PlayerMove
    function ValidateCameraTeamId() {}
    //exec function ToggleHelmetCameraZoom(optional BOOL bTurnOff){}
    exec function Fire(optional float f) {}
    delegate ServerChangeTeams(bool bNextTeam) {}
    // overwritten: don't reset should crouch
    simulated function EndState() {}
	// raise the player standing before anything
    simulated function BeginState() {}
    exec function ToggleHelmetCameraZoom(optional bool bTurnOff) {}
    // rbrek : add a timeout - do not stay in this state indefinitely
    simulated function Tick(float fDeltaTime) {}
    function SelectCameraMode(bool bNext) {}
    function ProcessMove(Vector NewAccel, float DeltaTime, EDoubleClickDir DoubleClickMove, Rotator DeltaRot) {}
    simulated function SetSpectatorRotation() {}
    function SetCameraMode() {}
    function DisplayClientMessage() {}
    delegate ServerMove(Vector Accel, int iNewRotOffset, int View, bool NewbRun, Vector ClientLoc, float TimeStamp, bool NewbDuck, bool NewbCrawl, optional byte OldTimeDelta, optional int OldAccel) {}
    function string GetViewTargetName() {}
// ^ NEW IN 1.60
	// MPF_MilanX
    simulated function PlayerMove(float DeltaTime) {}
    function NextCameraMode() {}
    function PreviousCameraMode() {}
    function bool CameraIsAvailable() {}
// ^ NEW IN 1.60
    exec function AltFire(optional float f) {}
}

state PlayerWalking
{
    // overwritten: don't reset should crouch
    function EndState() {}
	// raise the player standing before anything
    function BeginState() {}
	// MPF_MilanX
    function PlayerMove(float DeltaTime) {}
    function ProcessMove(float DeltaTime, Vector NewAccel, EDoubleClickDir DoubleClickMove, Rotator DeltaRot) {}
}

state PlayerBeginClimbingLadder
{
	// MPF_MilanX
    function PlayerMove(float DeltaTime) {}
	// MPF_Milan_7_1_2003 - AnimEnd rewritten , added second animation
    event AnimEnd(int iChannel) {}
    // overwritten: don't reset should crouch
    function EndState() {}
	// raise the player standing before anything
    function BeginState() {}
}

state PlayerActionProgress
{
	// MPF_Milan_7_1_2003 - AnimEnd rewritten , added second animation
    event AnimEnd(int iChannel) {}
	// MPF_MilanX
    function PlayerMove(float fDeltaTime) {}
    delegate LongClientAdjustPosition(float TimeStamp, EPhysics newPhysics, float NewLocX, float NewLocY, float NewLocZ, float NewVelX, float NewVelY, float NewVelZ, Actor NewBase, float NewFloorX, float NewFloorY, float NewFloorZ, name NewState) {}
// ^ NEW IN 1.60
    // rbrek : add a timeout - do not stay in this state indefinitely
    event Tick(float fDeltaTime) {}
    // overwritten: don't reset should crouch
    function EndState() {}
    function StartProgressAction() {}
	// raise the player standing before anything
    function BeginState() {}
}

state WaitForGameRepInfo
{
    // rbrek : add a timeout - do not stay in this state indefinitely
    event Tick(float fDeltaTime) {}
	// raise the player standing before anything
    function BeginState() {}
    function Timer() {}
}

state PlayerEndSurrended
{
	// MPF_Milan_7_1_2003 - AnimEnd rewritten , added second animation
    event AnimEnd(int iChannel) {}
    simulated function SetNewViewTarget(Actor aViewTarget) {}
    event ClientSetNewViewTarget() {}
    function SpectatorChangeTeams(bool bNextTeam) {}
    function ServerChangeTeams(bool bNextTeam) {}
    simulated function ChangeTeams(bool bNextTeam) {}
    exec function NextMember() {}
	// MPF_Milan_7_1_2003 - removed override of PlayerMove
	// MPF_Milan_7_1_2003 - override forbidden functions
    exec function PreviousMember() {}
	// MPF_Milan - removed overriding of PlayerMove
    function ValidateCameraTeamId() {}
    delegate TeamSay(string Msg) {}
// Send a message to all players.
    delegate Say(string Msg) {}
    //exec function ToggleHelmetCameraZoom(optional BOOL bTurnOff){}
    exec function Fire(optional float f) {}
    delegate ServerReStartPlayer() {}
    function AltFiring() {}
    // Nothing to do when we are dead
    function PlayFiring() {}
    function SwitchWeapon(byte f) {}
    function EndSurrenderSetUp() {}
    // overwritten: don't reset should crouch
    function EndState() {}
	// raise the player standing before anything
    function BeginState() {}
}

state PlayerSurrended
{
	// MPF_Milan_7_1_2003 - AnimEnd rewritten , added second animation
    event AnimEnd(int iChannel) {}
    simulated function SetNewViewTarget(Actor aViewTarget) {}
    event ClientSetNewViewTarget() {}
    function SpectatorChangeTeams(bool bNextTeam) {}
	// MPF_Milan - removed overriding of PlayerMove
    function ValidateCameraTeamId() {}
    function ServerChangeTeams(bool bNextTeam) {}
    simulated function ChangeTeams(bool bNextTeam) {}
    exec function NextMember() {}
	// MPF_Milan_7_1_2003 - removed override of PlayerMove
	// MPF_Milan_7_1_2003 - override forbidden functions
    exec function PreviousMember() {}
    // rbrek : add a timeout - do not stay in this state indefinitely
    event Tick(float fDeltaTime) {}
    function SwitchWeapon(byte f) {}
    delegate TeamSay(string Msg) {}
// Send a message to all players.
    delegate Say(string Msg) {}
    //exec function ToggleHelmetCameraZoom(optional BOOL bTurnOff){}
    exec function Fire(optional float f) {}
    exec function ToggleHelmetCameraZoom(optional bool bTurnOff) {}
    delegate ServerReStartPlayer() {}
    function AltFiring() {}
    // Nothing to do when we are dead
    function PlayFiring() {}
    // overwritten: don't reset should crouch
    function EndState() {}
	// raise the player standing before anything
    function BeginState() {}
}

state PlayerStartSurrending
{
	// MPF_Milan_7_1_2003 - AnimEnd rewritten , added second animation
    event AnimEnd(int iChannel) {}
    simulated function SetNewViewTarget(Actor aViewTarget) {}
    event ClientSetNewViewTarget() {}
    function SpectatorChangeTeams(bool bNextTeam) {}
	// MPF_Milan - removed overriding of PlayerMove
    function ValidateCameraTeamId() {}
    function ServerChangeTeams(bool bNextTeam) {}
    simulated function ChangeTeams(bool bNextTeam) {}
    exec function NextMember() {}
	// MPF_Milan_7_1_2003 - removed override of PlayerMove
	// MPF_Milan_7_1_2003 - override forbidden functions
    exec function PreviousMember() {}
    delegate TeamSay(string Msg) {}
// Send a message to all players.
    delegate Say(string Msg) {}
    //exec function ToggleHelmetCameraZoom(optional BOOL bTurnOff){}
    exec function Fire(optional float f) {}
    delegate ServerReStartPlayer() {}
    function AltFiring() {}
    // Nothing to do when we are dead
    function PlayFiring() {}
    function SwitchWeapon(byte f) {}
    // overwritten: don't reset should crouch
    function EndState() {}
	// raise the player standing before anything
    function BeginState() {}
}

state PlayerFinishReloadingBeforeSurrender
{
	// MPF_Milan_7_1_2003 - AnimEnd rewritten , added second animation
    event AnimEnd(int iChannel) {}
	// MPF_MilanX
    function PlayerMove(float DeltaTime) {}
    delegate ServerMove(optional int OldAccel, optional byte OldTimeDelta, int iNewRotOffset, int View, bool NewbCrawl, bool NewbDuck, bool NewbRun, Vector ClientLoc, Vector Accel, float TimeStamp) {}
    //exec function ToggleHelmetCameraZoom(optional BOOL bTurnOff){}
    exec function Fire(optional float f) {}
    delegate TeamSay(string Msg) {}
// Send a message to all players.
    delegate Say(string Msg) {}
    delegate ServerReStartPlayer() {}
    function AltFiring() {}
    // Nothing to do when we are dead
    function PlayFiring() {}
	// raise the player standing before anything
    function BeginState() {}
}

state PlayerStartArrest
{
	// MPF_Milan_7_1_2003 - AnimEnd rewritten , added second animation
    event AnimEnd(int iChannel) {}
    simulated function SetNewViewTarget(Actor aViewTarget) {}
    event ClientSetNewViewTarget() {}
    function SpectatorChangeTeams(bool bNextTeam) {}
	// MPF_Milan - removed overriding of PlayerMove
    function ValidateCameraTeamId() {}
    function ServerChangeTeams(bool bNextTeam) {}
    simulated function ChangeTeams(bool bNextTeam) {}
    exec function NextMember() {}
	// MPF_Milan_7_1_2003 - removed override of PlayerMove
	// MPF_Milan_7_1_2003 - override forbidden functions
    exec function PreviousMember() {}
    function SwitchWeapon(byte f) {}
    delegate TeamSay(string Msg) {}
// Send a message to all players.
    delegate Say(string Msg) {}
    //exec function ToggleHelmetCameraZoom(optional BOOL bTurnOff){}
    exec function Fire(optional float f) {}
    exec function ToggleHelmetCameraZoom(optional bool bTurnOff) {}
    delegate ServerReStartPlayer() {}
    function AltFiring() {}
    // Nothing to do when we are dead
    function PlayFiring() {}
    // overwritten: don't reset should crouch
    function EndState() {}
	// raise the player standing before anything
    function BeginState() {}
}

state PlayerSecureTerrorist
{
    delegate LongClientAdjustPosition(float TimeStamp, EPhysics newPhysics, float NewLocX, float NewLocY, float NewLocZ, float NewVelX, float NewVelY, float NewVelZ, Actor NewBase, float NewFloorX, float NewFloorY, float NewFloorZ, name NewState) {}
// ^ NEW IN 1.60
	// MPF_MilanX
    function PlayerMove(float fDeltaTime) {}
	// MPF_Milan_7_1_2003 - AnimEnd rewritten , added second animation
    event AnimEnd(int iChannel) {}
    // rbrek : add a timeout - do not stay in this state indefinitely
    event Tick(float fDeltaTime) {}
    // overwritten: don't reset should crouch
    function EndState() {}
	// raise the player standing before anything
    function BeginState() {}
}

state PreBeginClimbingLadder
{
	// MPF_Milan_7_1_2003 - AnimEnd rewritten , added second animation
    event AnimEnd(int iChannel) {}
	// MPF_MilanX
    function PlayerMove(float DeltaTime) {}
    function SwitchWeapon(byte f) {}
    //exec function ToggleHelmetCameraZoom(optional BOOL bTurnOff){}
    exec function Fire(optional float f) {}
    exec function ToggleHelmetCameraZoom(optional bool bTurnOff) {}
    delegate ServerReStartPlayer() {}
    function AltFiring() {}
    // Nothing to do when we are dead
    function PlayFiring() {}
    // overwritten: don't reset should crouch
    function EndState() {}
	// raise the player standing before anything
    function BeginState() {}
}

state BaseSpectating
{
    function ProcessMove(float DeltaTime, Vector NewAccel, EDoubleClickDir DoubleClickMove, Rotator DeltaRot) {}
	// MPF_MilanX
    function PlayerMove(float DeltaTime) {}
	// raise the player standing before anything
    simulated function BeginState() {}
    // overwritten: don't reset should crouch
    simulated function EndState() {}
    // rbrek : add a timeout - do not stay in this state indefinitely
    function Tick(float DeltaTime) {}
}

state PlayerEndClimbingLadder
{
	// MPF_MilanX
    function PlayerMove(float DeltaTime) {}
	// MPF_Milan_7_1_2003 - AnimEnd rewritten , added second animation
    event AnimEnd(int iChannel) {}
    function EndClimbingSetUp() {}
    // overwritten: don't reset should crouch
    function EndState() {}
	// raise the player standing before anything
    function BeginState() {}
}

state PlayerClimbing
{
	// MPF_MilanX
    function PlayerMove(float DeltaTime) {}
    function bool NotifyPhysicsVolumeChange(PhysicsVolume NewVolume) {}
// ^ NEW IN 1.60
}

state PlayerSetExplosive
{
	// MPF_Milan_7_1_2003 - AnimEnd rewritten , added second animation
    event AnimEnd(int iChannel) {}
	// MPF_MilanX
    function PlayerMove(float fDeltaTime) {}
    function int GetActionProgress() {}
// ^ NEW IN 1.60
    // rbrek : add a timeout - do not stay in this state indefinitely
    event Tick(float fDeltaTime) {}
    // overwritten: don't reset should crouch
    function EndState() {}
	// raise the player standing before anything
    function BeginState() {}
}

state PlayerSetFree
{
	// MPF_Milan_7_1_2003 - AnimEnd rewritten , added second animation
    event AnimEnd(int iChannel) {}
	// raise the player standing before anything
    function BeginState() {}
    simulated function SetNewViewTarget(Actor aViewTarget) {}
    event ClientSetNewViewTarget() {}
    function SpectatorChangeTeams(bool bNextTeam) {}
	// MPF_Milan - removed overriding of PlayerMove
    function ValidateCameraTeamId() {}
    function ServerChangeTeams(bool bNextTeam) {}
    simulated function ChangeTeams(bool bNextTeam) {}
    exec function NextMember() {}
	// MPF_Milan_7_1_2003 - removed override of PlayerMove
	// MPF_Milan_7_1_2003 - override forbidden functions
    exec function PreviousMember() {}
    function SwitchWeapon(byte f) {}
    // overwritten: don't reset should crouch
    function EndState() {}
    //exec function ToggleHelmetCameraZoom(optional BOOL bTurnOff){}
    exec function Fire(optional float f) {}
    exec function ToggleHelmetCameraZoom(optional bool bTurnOff) {}
    delegate TeamSay(string Msg) {}
// Send a message to all players.
    delegate Say(string Msg) {}
    delegate ServerReStartPlayer() {}
    function AltFiring() {}
    // Nothing to do when we are dead
    function PlayFiring() {}
}

state PlayerArrested
{
	// MPF_Milan_7_1_2003 - AnimEnd rewritten , added second animation
    event AnimEnd(int iChannel) {}
	// raise the player standing before anything
    function BeginState() {}
    simulated function SetNewViewTarget(Actor aViewTarget) {}
    event ClientSetNewViewTarget() {}
    function SpectatorChangeTeams(bool bNextTeam) {}
	// MPF_Milan - removed overriding of PlayerMove
    function ValidateCameraTeamId() {}
    function ServerChangeTeams(bool bNextTeam) {}
    simulated function ChangeTeams(bool bNextTeam) {}
    exec function NextMember() {}
	// MPF_Milan_7_1_2003 - removed override of PlayerMove
	// MPF_Milan_7_1_2003 - override forbidden functions
    exec function PreviousMember() {}
    function SwitchWeapon(byte f) {}
    delegate TeamSay(string Msg) {}
// Send a message to all players.
    delegate Say(string Msg) {}
    //exec function ToggleHelmetCameraZoom(optional BOOL bTurnOff){}
    exec function Fire(optional float f) {}
    exec function ToggleHelmetCameraZoom(optional bool bTurnOff) {}
    delegate ServerReStartPlayer() {}
    function AltFiring() {}
    // Nothing to do when we are dead
    function PlayFiring() {}
    // overwritten: don't reset should crouch
    function EndState() {}
}

state PlayerStartSurrenderSequence
{
	// MPF_MilanX
    function PlayerMove(float DeltaTime) {}
	// MPF_Milan_7_1_2003 - AnimEnd rewritten , added second animation
    event AnimEnd(int iChannel) {}
    delegate VeryShortClientAdjustPosition(float TimeStamp, float NewLocX, float NewLocY, float NewLocZ, Actor NewBase) {}
// ^ NEW IN 1.60
    //exec function ToggleHelmetCameraZoom(optional BOOL bTurnOff){}
    exec function Fire(optional float f) {}
    delegate TeamSay(string Msg) {}
// Send a message to all players.
    delegate Say(string Msg) {}
    delegate ServerReStartPlayer() {}
    function AltFiring() {}
    // Nothing to do when we are dead
    function PlayFiring() {}
    // rbrek : add a timeout - do not stay in this state indefinitely
    event Tick(float fDiffTime) {}
    // overwritten: don't reset should crouch
    function EndState() {}
	// raise the player standing before anything
    function BeginState() {}
}

state PlayerPreBeginSurrending
{
	// MPF_Milan_7_1_2003 - AnimEnd rewritten , added second animation
    event AnimEnd(int iChannel) {}
	// raise the player standing before anything
    function BeginState() {}
    simulated function SetNewViewTarget(Actor aViewTarget) {}
    event ClientSetNewViewTarget() {}
    function SpectatorChangeTeams(bool bNextTeam) {}
	// MPF_Milan - removed overriding of PlayerMove
    function ValidateCameraTeamId() {}
    function ServerChangeTeams(bool bNextTeam) {}
    simulated function ChangeTeams(bool bNextTeam) {}
    exec function NextMember() {}
	// MPF_Milan_7_1_2003 - removed override of PlayerMove
	// MPF_Milan_7_1_2003 - override forbidden functions
    exec function PreviousMember() {}
    function SwitchWeapon(byte f) {}
    //exec function ToggleHelmetCameraZoom(optional BOOL bTurnOff){}
    exec function Fire(optional float f) {}
    delegate TeamSay(string Msg) {}
// Send a message to all players.
    delegate Say(string Msg) {}
    delegate ServerReStartPlayer() {}
    function AltFiring() {}
    // Nothing to do when we are dead
    function PlayFiring() {}
    // overwritten: don't reset should crouch
    function EndState() {}
}

state Dead
{
    //exec function ToggleHelmetCameraZoom(optional BOOL bTurnOff){}
    exec function Fire(optional float f) {}
	// raise the player standing before anything
    simulated function BeginState() {}
    // Nothing to do when we are dead
    function PlayFiring() {}
    function AltFiring() {}
	// MPF_MilanX
    function PlayerMove(float DeltaTime) {}
    delegate ServerReStartPlayer() {}
    exec function GraduallyOpenDoor() {}
    exec function GraduallyCloseDoor() {}
    exec function ToggleHelmetCameraZoom(optional bool bTurnOff) {}
    simulated function ResetCurrentState() {}
    function EnterSpectatorMode() {}
    // overwritten: don't reset should crouch
    function EndState() {}
    function Timer() {}
}

state PauseController
{
	// MPF_MilanX
    function PlayerMove(float DeltaTime) {}
    simulated function ProcessMove(float DeltaTime, Rotator DeltaRot, Vector NewAccel, EDoubleClickDir DoubleClickMove) {}
    delegate VeryShortClientAdjustPosition(float TimeStamp, float NewLocX, float NewLocY, float NewLocZ, Actor NewBase) {}
// ^ NEW IN 1.60
    function KilledBy(Pawn EventInstigator) {}
// ^ NEW IN 1.60
	// raise the player standing before anything
    function BeginState() {}
    // overwritten: don't reset should crouch
    function EndState() {}
    exec function ToggleHelmetCameraZoom(optional bool bTurnOff) {}
    // Nothing to do when we are dead
    simulated function PlayFiring() {}
    simulated function AltFiring() {}
    simulated function bool PlayerIsFiring() {}
// ^ NEW IN 1.60
    //exec function ToggleHelmetCameraZoom(optional BOOL bTurnOff){}
    exec function Fire(optional float f) {}
    // rbrek : add a timeout - do not stay in this state indefinitely
    simulated function Tick(float fDeltaTime) {}
}

state PlayerSecureRainbow
{
	// MPF_MilanX
    function PlayerMove(float fDeltaTime) {}
	// MPF_Milan_7_1_2003 - AnimEnd rewritten , added second animation
    event AnimEnd(int iChannel) {}
    // overwritten: don't reset should crouch
    function EndState() {}
    // rbrek : add a timeout - do not stay in this state indefinitely
    event Tick(float fDeltaTime) {}
	// raise the player standing before anything
    function BeginState() {}
}

state PlayerFlying
{
	// raise the player standing before anything
    function BeginState() {}
}

state GameEnded
{
}

state PenaltyBox
{
    function KilledBy(Pawn EventInstigator) {}
// ^ NEW IN 1.60
	// raise the player standing before anything
    function BeginState() {}
    // Nothing to do when we are dead
    function PlayFiring() {}
    function AltFiring() {}
	// MPF_MilanX
    function PlayerMove(float DeltaTime) {}
    delegate ServerReStartPlayer() {}
    exec function ToggleHelmetCameraZoom(optional bool bTurnOff) {}
    //exec function ToggleHelmetCameraZoom(optional BOOL bTurnOff){}
    exec function Fire(optional float f) {}
    function SwitchWeapon(byte f) {}
}

defaultproperties
{
}
