//=============================================================================
// PlayerController
//
// PlayerControllers are used by human players to control pawns.
//
// This is a built-in Unreal class and it shouldn't be modified.
// for the change in Possess().
//=============================================================================
class PlayerController extends Controller
    native
    nativereplication
    config(user);

// --- Constants ---
const K_GlobalID_size =  16;

// --- Enums ---
enum eCameraMode
{
    // enum values not recoverable from binary — see 1.56 source
};

// --- Structs ---
struct PlayerPrefInfo
{
    var string m_CharacterName;
    var string m_ArmorName;

    var string m_WeaponName1;
    var string m_WeaponName2;

    var string m_WeaponGadgetName1;
    var string m_WeaponGadgetName2;
    
    var string m_BulletType1;
    var string m_BulletType2;

    var string m_GadgetName1;
    var string m_GadgetName2;
};

// --- Variables ---
// var ? OldClientWeapon; // REMOVED IN 1.60
// var ? m_ArmorName; // REMOVED IN 1.60
// var ? m_BulletType1; // REMOVED IN 1.60
// var ? m_BulletType2; // REMOVED IN 1.60
// var ? m_CharacterName; // REMOVED IN 1.60
// var ? m_GadgetName1; // REMOVED IN 1.60
// var ? m_GadgetName2; // REMOVED IN 1.60
// var ? m_WeaponGadgetName1; // REMOVED IN 1.60
// var ? m_WeaponGadgetName2; // REMOVED IN 1.60
// var ? m_WeaponName1; // REMOVED IN 1.60
// var ? m_WeaponName2; // REMOVED IN 1.60
var const /* replicated */ Actor ViewTarget;
// Move buffering for network games.  Clients save their un-acknowledged moves in order to replay them
// when they get position updates from the server.
// buffered moves pending position updates
var SavedMove SavedMoves;
// Player control flags
// Outside-the-player view.
var bool bBehindView;
var bool bPressedJump;
// direction of movement key double click (for special moves)
var EDoubleClickDir DoubleClickDir;
// Player info.
var const Player Player;
var SavedMove PendingMove;
// heads up display info
var HUD myHUD;
// freed moves, available for buffering
var SavedMove FreeMoves;
//#ifdef R6CODE
var float DesiredFOV;
var float aLookUp;
// ^ NEW IN 1.60
var float aStrafe;
// ^ NEW IN 1.60
// Object within playercontroller that manages player input.
var transient PlayerInput PlayerInput;
// This controller is not allowed to possess pawns
var /* replicated */ bool bOnlySpectator;
var float aForward;
// ^ NEW IN 1.60
// used by PlayerSpider mode - floor for which old rotation was based;
var Vector OldFloor;
var float CurrentTimeStamp;
// ^ NEW IN 1.60
// Screen flashes
var Vector FlashFog;
var float DefaultFOV;
var Vector ShakeOffsetRate;
//current magnitude to offset camera from shake
var Vector ShakeOffset;
var float aTurn;
// ^ NEW IN 1.60
var bool bUpdating;
// set when game ends or player dies to temporarily prevent player from restarting (until cleared by timer)
var bool bFrozen;
// Components ( inner classes )
//R6CODE
// Object within playercontroller that manages "cheat" commands
var CheatManager CheatManager;
var Vector FlashScale;
// ^ NEW IN 1.60
// A stack of camera effects.
var transient array<array> CameraEffects;
var float aBaseY;
// ^ NEW IN 1.60
var int GroundPitch;
// no snapping when true
var config globalconfig bool bKeyboardLook;
// max magnitude to offset camera position
var Vector MaxShakeOffset;
var float TimeMargin;
// ^ NEW IN 1.60
var config globalconfig bool bAlwaysMouseLook;
var bool bCenterView;
//#else
//var globalconfig float DesiredFOV;
//var globalconfig float DefaultFOV;
//#endif R6CODE
var float ZoomLevel;
var float aMouseY;
// ^ NEW IN 1.60
var Vector ShakeOffsetTime;
// rate to change roll
var float ShakeRollRate;
var float ProgressTimeOut;
var config globalconfig float MaxTimeMargin;
var float ClientUpdateTime;
var float ServerTimeStamp;
// ^ NEW IN 1.60
var float LastUpdateTime;
// ^ NEW IN 1.60
var Vector DesiredFlashFog;
// ^ NEW IN 1.60
var float DesiredFlashScale;
// ^ NEW IN 1.60
var bool bZooming;
//#ifndef R6CODE
//var globalconfig bool bAlwaysLevel;
//#endif // #ifndef R6CODE
var bool bSetTurnRot;
var float aMouseX;
// ^ NEW IN 1.60
var bool bUpdatePosition;
var /* replicated */ ePlayerTeamSelection m_TeamSelection;
// last time change name was requested
var int m_iChangeNameLastTime;
var Rotator TurnRot180;
// how long to roll.  if value is < 1.0, then MaxShakeOffset gets damped by this, else if > 1 then its the number of times to repeat undamped
var float ShakeRollTime;
// view shaking (affects roll, and offsets camera position)
// max magnitude to roll camera
var float MaxShakeRoll;
// ReplicationInfo
var /* replicated */ GameReplicationInfo GameReplicationInfo;
// player input control
// look up/down stairs (player)
var config globalconfig bool bLookUpStairs;
var Vector InstantFog;
var float InstantFlash;
// used to fix camera in position (to view animations)
var bool bFixedCamera;
// multiplier for behindview camera dist
var float CameraDist;
var byte bLook;
// ^ NEW IN 1.60
var float aUp;
// ^ NEW IN 1.60
var float aBaseX;
// ^ NEW IN 1.60
// Snap to level eyeheight when not mouselooking
var config globalconfig bool bSnapToLevel;
// instantly stop in flying mode
var bool bCheatFlying;
// Delay time until can restart
var float WaitDelay;
var byte bStrafe;
// ^ NEW IN 1.60
var float ConstantGlowScale;
// ^ NEW IN 1.60
var Vector ConstantGlowFog;
// ^ NEW IN 1.60
// Remote Pawn ViewTargets
var /* replicated */ Rotator TargetViewRotation;
// Progess Indicator - used by the engine to provide status messages (HUD is responsible for displaying these).
var string ProgressMessage[4];
var localized string ViewingFrom;
var localized string OwnCamera;
// ngWorldStats Logging
var config globalconfig string ngWorldSecret;
var Pawn TurnTarget;
var float m_fNextUpdateTime;
var Actor m_SaveOldClientBase;
var bool m_bLoadSoundGun;
var bool bIsTyping;
//#ifdef R6CODE
var bool m_bReadyToEnterSpectatorMode;
// free camera when in behindview mode (for checking out player models and animations)
var bool bFreeCamera;
var bool bZeroRoll;
var bool bCameraPositionLocked;
//#ifndef R6CODE
//var globalconfig bool ngSecretSet;
//#endif // #ifndef R6CODE
var bool ReceivedSecretChecksum;
var byte bSnapLevel;
// ^ NEW IN 1.60
var bool m_bHeatVisionActive;
//R6CODE
var /* replicated */ bool m_bRadarActive;
//R6CODE
var string m_szGlobalID;
var config globalconfig float NetClientMaxTickRate;
// class of my PlayerInput
var class<PlayerInput> InputClass;
//var private CheatManager	CheatManager;	// Object within playercontroller that manages "cheat" commands
// class of my CheatManager
var class<CheatManager> CheatClass;
var Color ProgressColor[4];
var EMusicTransition Transition;
// Music info.
var string Song;
var byte bYAxis;
// ^ NEW IN 1.60
var byte bXAxis;
// ^ NEW IN 1.60
var byte bTurnToNearest;
// ^ NEW IN 1.60
var byte bTurn180;
// ^ NEW IN 1.60
var byte bFreeLook;
// ^ NEW IN 1.60
// used in net games
var bool bJumpStatus;
var float AimingHelp;
var float aBaseZ;
// ^ NEW IN 1.60
//#ifdef R6CODE
var bool m_bInitFirstTick;
// Camera info.
var int ShowFlags;
var int Misc1;
// ^ NEW IN 1.60
var int Misc2;
var int RendMap;
// Orthogonal/map view zoom factor.
var float OrthoZoom;
var /* replicated */ float TargetEyeHeight;
var /* replicated */ Vector TargetWeaponViewOffset;
var float LastPlaySound;
var int WeaponUpdate;
// Localized strings
var localized string QuickSaveString;
var localized string NoPauseMessage;
var class<LocalMessage> LocalMessageClass;
var config int EnemyTurnSpeed;
// Demo recording view rotation
var /* replicated */ int DemoViewPitch;
var /* replicated */ int DemoViewYaw;
var PlayerVerCDKeyStatus m_stPlayerVerCDKeyStatus;
var PlayerVerCDKeyStatus m_stPlayerVerModCDKeyStatus;
// this controller is about to be destroyed
var bool m_PreLogOut;
var PlayerPrefInfo m_PlayerPrefs;
var R6RainbowStartInfo m_PlayerStartInfo;
var float m_fLoginTime;
// IP address withou port number used to identfy players in beacon code
var string m_szIpAddr;
//#ifdef R6PUNKBUSTER
//__WITH_PB__
var int iPBEnabled;
// Use in the traning to start the text.
var bool m_bInstructionTouch;
var /* replicated */ eCameraMode m_eCameraMode;
// ^ NEW IN 1.60

// --- Functions ---
// function ? ActivateInventoryItem(...); // REMOVED IN 1.60
// function ? ActivateItem(...); // REMOVED IN 1.60
// function ? ChangeTeam(...); // REMOVED IN 1.60
// function ? ChangedWeapon(...); // REMOVED IN 1.60
// function ? ClearProgressMessages(...); // REMOVED IN 1.60
// function ? ClientRestart(...); // REMOVED IN 1.60
// function ? CreateCameraEffect(...); // REMOVED IN 1.60
// function ? FOV(...); // REMOVED IN 1.60
// function ? ForceReload(...); // REMOVED IN 1.60
// function ? GetWeapon(...); // REMOVED IN 1.60
// function ? HandlePickup(...); // REMOVED IN 1.60
// function ? LocalTravel(...); // REMOVED IN 1.60
// function ? NextWeapon(...); // REMOVED IN 1.60
// function ? PrevItem(...); // REMOVED IN 1.60
// function ? PrevWeapon(...); // REMOVED IN 1.60
// function ? QuickLoad(...); // REMOVED IN 1.60
// function ? QuickSave(...); // REMOVED IN 1.60
// function ? RestartLevel(...); // REMOVED IN 1.60
// function ? ServerReStartGame(...); // REMOVED IN 1.60
// function ? ServerRestartPlayer(...); // REMOVED IN 1.60
// function ? ServerUse(...); // REMOVED IN 1.60
// function ? SetProgressMessage(...); // REMOVED IN 1.60
// function ? Speech(...); // REMOVED IN 1.60
// function ? SwitchLevel(...); // REMOVED IN 1.60
// function ? SwitchTeam(...); // REMOVED IN 1.60
// function ? SwitchWeapon(...); // REMOVED IN 1.60
// function ? ThrowWeapon(...); // REMOVED IN 1.60
// function ? Use(...); // REMOVED IN 1.60
// function ? damageAttitudeTo(...); // REMOVED IN 1.60
final native function SetViewTarget(Actor NewViewTarget) {}
function PlayerMove(float DeltaTime) {}
	// Return to spectator's own camera.
exec function AltFire(optional float f) {}
	// FIXME - IF HIT FIRE, AND NOT bInterpolating, Leave script
exec function Fire(optional float f) {}
final native function string GetDefaultURL(string Option) {}
// ^ NEW IN 1.60
function ProcessMove(Vector NewAccel, float DeltaTime, EDoubleClickDir DoubleClickMove, Rotator DeltaRot) {}
function Suicide() {}
final function MoveAutonomous(float DeltaTime, Rotator DeltaRot, Vector NewAccel, EDoubleClickDir DoubleClickMove, bool NewbCrawl, bool NewbDuck, bool NewbRun) {}
// ^ NEW IN 1.60
delegate ServerMove(Vector ClientLoc, float TimeStamp, optional int OldAccel, int View, int iNewRotOffset, optional byte OldTimeDelta, bool NewbCrawl, bool NewbDuck, bool NewbRun, Vector InAccel) {}
// ^ NEW IN 1.60
event PostBeginPlay() {}
function bool NotifyLanded(Vector HitNormal) {}
// ^ NEW IN 1.60
delegate ClientMessage(optional name type, coerce string S) {}
function ClientVoiceMessage(PlayerReplicationInfo Sender, byte messageID, name messagetype, PlayerReplicationInfo Recipient) {}
event PlayerTick(float DeltaTime) {}
final function SavedMove GetFreeMove() {}
// ^ NEW IN 1.60
delegate LongClientAdjustPosition(Actor NewBase, EPhysics newPhysics, float TimeStamp, name NewState, float NewFloorZ, float NewFloorY, float NewFloorX, float NewVelZ, float NewVelY, float NewVelX, float NewLocZ, float NewLocY, float NewLocX) {}
// ^ NEW IN 1.60
	// if spider mode, update rotation based on floor
function UpdateRotation(float DeltaTime, float maxPitch) {}
delegate ReceiveLocalizedMessage(optional Object OptionalObject, optional PlayerReplicationInfo RelatedPRI_2, optional PlayerReplicationInfo RelatedPRI_1, optional int Switch, class<LocalMessage> Message) {}
function ClientReStart() {}
// ^ NEW IN 1.60
exec function Jump(optional float f) {}
function ServerRestartGame() {}
function ClientTravel(bool bItems, ETravelType TravelType, string URL) {}
final native function UpdateURL(bool bSaveDefault, string NewValue, string NewOption) {}
// ^ NEW IN 1.60
// Execute a console command in the context of this player, then forward to Actor.ConsoleCommand.
native function CopyToClipboard(string Text) {}
final native function int FindStairRotation(float DeltaTime) {}
// ^ NEW IN 1.60
final native function byte GetKey(optional bool bPlanningInput, string szActionKey) {}
// ^ NEW IN 1.60
final native function string GetActionKey(optional bool bPlanningInput, byte Key) {}
// ^ NEW IN 1.60
final native function string GetEnumName(optional bool bPlanningInput, byte Key) {}
// ^ NEW IN 1.60
final native function ChangeInputSet(byte iInputSet) {}
// ^ NEW IN 1.60
final native function SetKey(string szKeyAndAction) {}
// ^ NEW IN 1.60
final native function ChangeVolumeTypeLinear(float fVolumeLinear, ESoundSlot eVolumeLine) {}
// ^ NEW IN 1.60
function ClientHearSound(ESoundSlot ID, Sound S, Actor Actor) {}
function ClientGotoState(name NewLabel, name NewState) {}
//R6CODE+
function ClientErrorMessageLocalized(coerce string szKeyID) {}
function ClientReliablePlaySound(Sound ASound, optional bool bVolumeControl) {}
function ClientSetMusic(EMusicTransition NewTransition, string NewSong) {}
exec function SetSensitivity(float f) {}
function ClientSetFixedCamera(bool B) {}
function ClientSetBehindView(bool B) {}
function ClientReplicateSkins(optional Material Skin4, optional Material Skin3, optional Material Skin2, Material Skin1) {}
delegate ShorterServerMove(int iNewRotOffset, int View, Vector ClientLoc, float TimeStamp) {}
// ^ NEW IN 1.60
delegate ShortServerMove(int iNewRotOffset, int View, bool NewbCrawl, bool NewbDuck, bool NewbRun, Vector ClientLoc, float TimeStamp) {}
// ^ NEW IN 1.60
delegate SetFOVAngle(float NewFOV) {}
delegate ClientFlash(Vector fog, float Scale) {}
delegate ClientSetFlash(Vector fog, Vector Scale) {}
delegate ClientInstantFlash(Vector fog, float Scale) {}
function ClientAdjustGlow(Vector fog, float Scale) {}
function bool SetPause(bool bPause) {}
// ^ NEW IN 1.60
// R6CODE+
event HandleServerMsg(optional int iLifeTime, string _szServerMsg) {}
exec function Name(coerce string S) {}
exec function SetName(coerce string S) {}
function SetProgressTime(float t) {}
exec function BehindView(bool B) {}
function SetNGSecret(string newSecret) {}
//------------------------------------------------------------------------------
// Control options
function ChangeStairLook(bool B) {}
function ChangeAlwaysMouseLook(bool B) {}
//R6Radar begin
event ToggleRadar(bool _bRadar) {}
function ServerToggleRadar(bool _bRadar) {}
function ServerToggleHeatVision(bool bHeatVisionActive) {}
function ClientPBKickedOutMessage(string PBMessage) {}
//
function ClientPBKickMsg(string PBMessage) {}
event AddCameraEffect(CameraEffect NewEffect, optional bool RemoveExisting) {}
function CalcFirstPersonView(out Vector CameraLocation, out Rotator CameraRotation) {}
function ServerChangeName(string S) {}
exec function SetOption(string szKeyAndCommand) {}
delegate TeamSay(string Msg) {}
// Send a message to all players.
delegate Say(string Msg) {}
function SetFOV(float NewFOV) {}
function ClientStopSound(Sound ASound) {}
//R6CODE
function ClientPlaySound(Sound ASound, ESoundSlot eSlot) {}
function AdjustView(float DeltaTime) {}
function EAttitude AttitudeTo(Pawn Other) {}
// ^ NEW IN 1.60
function Typing(bool bTyping) {}
function ClientAdjustBase(Actor newClientBase) {}
delegate TeamMessage(coerce string S, name type, PlayerReplicationInfo PRI) {}
function ClientSetHUD(class<HUD> newHUDType, class<ScoreBoard> newScoringType) {}
// Possess a pawn
function Possess(Pawn aPawn) {}
function GivePawn(Pawn NewPawn) {}
function int GetFacingDirection() {}
// ^ NEW IN 1.60
simulated event Destroyed() {}
delegate VeryShortClientAdjustPosition(Actor NewBase, float NewLocZ, float NewLocY, float NewLocX, float TimeStamp) {}
// ^ NEW IN 1.60
delegate ShortClientAdjustPosition(Actor NewBase, float NewLocZ, float NewLocY, float NewLocX, EPhysics newPhysics, name NewState, float TimeStamp) {}
// ^ NEW IN 1.60
delegate ClientAdjustPosition(Actor NewBase, float NewVelZ, float NewVelY, float NewVelX, float NewLocZ, float NewLocY, float NewLocX, EPhysics newPhysics, name NewState, float TimeStamp) {}
// ^ NEW IN 1.60
function ShakeView(float OffsetTime, Vector OffsetRate, float RollRate, Vector OffsetMag, float RollMag, float shaketime) {}
function EnterStartState() {}
function CalcBehindView(out Vector CameraLocation, float Dist, out Rotator CameraRotation) {}
event RemoveCameraEffect(CameraEffect ExEffect) {}
iterator delegate ClientShake(Vector ShakeRoll, Vector OffsetMag, float OffsetTime, Vector ShakeRate) {}
// ^ NEW IN 1.60
function ViewFlash(float DeltaTime) {}
function int CompressAccel(int C) {}
// ^ NEW IN 1.60
function CheckShake(out float MaxOffset, out float Time, out float Rate, out float offset) {}
//*************************************************************************************
// Normal gameplay execs
// Type the name of the exec function at the console to execute it
// R6CODE
exec function Bind(string szKeyAndCommand) {}
function ViewShake(float DeltaTime) {}
event PlayerCalcView(out Rotator CameraRotation, out Vector CameraLocation, out Actor ViewActor) {}
function AdjustRadius(float MaxMove) {}
delegate ServerViewNextPlayer() {}
function ChangeName(out coerce string S) {}
function ClientChangeName(string S) {}
function ClientUpdatePosition() {}
function ReplicateMove(Vector NewAccel, float DeltaTime, EDoubleClickDir DoubleClickMove, Rotator DeltaRot) {}
// ^ NEW IN 1.60
native function string ConsoleCommand(string Command) {}
// ^ NEW IN 1.60
//#ifdef R6CODE clauzon those functions are called to properly  initialize the
//member variables for matinee.
function InitMatineeCamera() {}
function EndMatineeCamera() {}
// R6CODE
function ResettingLevel(int iNbOfRestart) {}
function ServerSetPlayerReadyStatus(bool _bPlayerReady) {}
delegate ServerTKPopUpDone(bool _bApplyTeamKillerPenalty) {}
function ServerTeamRequested(ePlayerTeamSelection eTeamSelected, optional bool bForceSelection) {}
final native function string GetPBConnectStatus() {}
// ^ NEW IN 1.60
static final native function int IsPBEnabled() {}
// ^ NEW IN 1.60
final native function string GetPlayerNetworkAddress() {}
// ^ NEW IN 1.60
final native function SpecialDestroy() {}
// ^ NEW IN 1.60
final native function LevelInfo GetEntryLevel() {}
// ^ NEW IN 1.60
final native function ResetKeyboard() {}
// ^ NEW IN 1.60
native function string PasteFromClipboard() {}
// ^ NEW IN 1.60
simulated event bool IsPlayerPassiveSpectator() {}
// ^ NEW IN 1.60
//#ifdef R6CODE
function ServerReadyToLoadWeaponSound() {}
function ServerPlayerPref(PlayerPrefInfo newPlayerPrefs) {}
event SetMatchResult(string _UserUbiID, int iField, int iValue) {}
event string GetLocalPlayerIp() {}
// ^ NEW IN 1.60
final native function SetSoundOptions() {}
// ^ NEW IN 1.60
final native function bool PB_CanPlayerSpawn() {}
// ^ NEW IN 1.60
// r6code
function bool ShouldDisplayIncomingMessages() {}
// ^ NEW IN 1.60
// r6code: give access to the private var PlayerInput
simulated function PlayerInput getPlayerInput() {}
// ^ NEW IN 1.60
function PendingStasis() {}
function AddCheats() {}
function SpawnDefaultHUD() {}
function Reset() {}
//R6CODE
event InitMultiPlayerOptions() {}
event InitInputSystem() {}
function UpdateOptions() {}
function AskForPawn() {}
// unpossessed a pawn (not because pawn was killed)
function UnPossess() {}
//#ifdef R6CODE
function bool GetGender() {}
// ^ NEW IN 1.60
// unpossessed a pawn (because pawn was killed)
function PawnDied() {}
simulated function PlayBeepSound() {}
function ToggleZoom() {}
function StartZoom() {}
function StopZoom() {}
function EndZoom() {}
function FixFOV() {}
function ResetFOV() {}
event PreClientTravel() {}
function ForceDeathUpdate() {}
function HandleWalking() {}
function Pause() {}
function ClientCantRequestChangeNameYet() {}
function Restart() {}
event TravelPostAccept() {}
function Rotator GetViewRotation() {}
// ^ NEW IN 1.60
function bool TurnTowardNearestEnemy() {}
// ^ NEW IN 1.60
function TurnAround() {}
function ClearDoubleClick() {}
event ClientSetNewViewTarget() {}
delegate ServerViewSelf() {}
//------------------------------------------------------------------------------
// ngStats Accessors
function string GetNGSecret() {}
// ^ NEW IN 1.60

state BaseSpectating
{
    function ProcessMove(Vector NewAccel, float DeltaTime, EDoubleClickDir DoubleClickMove, Rotator DeltaRot) {}
    function PlayerMove(float DeltaTime) {}
}

state PlayerFlying
{
    function PlayerMove(float DeltaTime) {}
    function BeginState() {}
}

state Scripting
{
	// Return to spectator's own camera.
    exec function AltFire(optional float f) {}
	// FIXME - IF HIT FIRE, AND NOT bInterpolating, Leave script
    exec function Fire(optional float f) {}
}

state WaitingForPawn
{
    function PlayerTick(float DeltaTime) {}
    function KilledBy(Pawn EventInstigator) {}
// ^ NEW IN 1.60
	// FIXME - IF HIT FIRE, AND NOT bInterpolating, Leave script
    exec function Fire(optional float f) {}
	// Return to spectator's own camera.
    exec function AltFire(optional float f) {}
    delegate LongClientAdjustPosition(float TimeStamp, name NewState, EPhysics newPhysics, float NewLocX, float NewLocY, float NewLocZ, float NewVelX, float NewVelY, float NewVelZ, Actor NewBase, float NewFloorX, float NewFloorY, float NewFloorZ) {}
// ^ NEW IN 1.60
    function Timer() {}
    function BeginState() {}
    function EndState() {}
}

state PlayerHelicoptering
{
    function PlayerMove(float DeltaTime) {}
}

state PlayerSwimming
{
    function ProcessMove(Vector NewAccel, float DeltaTime, EDoubleClickDir DoubleClickMove, Rotator DeltaRot) {}
    function bool NotifyPhysicsVolumeChange(PhysicsVolume NewVolume) {}
// ^ NEW IN 1.60
    function PlayerMove(float DeltaTime) {}
    function bool WantsSmoothedView() {}
// ^ NEW IN 1.60
    function bool NotifyLanded(Vector HitNormal) {}
// ^ NEW IN 1.60
    function Timer() {}
    function BeginState() {}
}

state PlayerClimbing
{
    function bool NotifyPhysicsVolumeChange(PhysicsVolume NewVolume) {}
// ^ NEW IN 1.60
    function ProcessMove(Vector NewAccel, float DeltaTime, EDoubleClickDir DoubleClickMove, Rotator DeltaRot) {}
    function PlayerMove(float DeltaTime) {}
    function BeginState() {}
    function EndState() {}
}

state PlayerWalking
{
    function bool NotifyPhysicsVolumeChange(PhysicsVolume NewVolume) {}
// ^ NEW IN 1.60
    function ProcessMove(Vector NewAccel, float DeltaTime, EDoubleClickDir DoubleClickMove, Rotator DeltaRot) {}
    function PlayerMove(float DeltaTime) {}
    function BeginState() {}
    function EndState() {}
}

state Dead
{
	// Return to spectator's own camera.
    exec function AltFire(optional float f) {}
    delegate ServerMove(int iNewRotOffset, int View, Vector ClientLoc, Vector Accel, float TimeStamp, bool NewbRun, bool NewbDuck, bool NewbCrawl, optional byte OldTimeDelta, optional int OldAccel) {}
// ^ NEW IN 1.60
    function EndState() {}
    function BeginState() {}
    function FindGoodView() {}
    function PlayerMove(float DeltaTime) {}
    function KilledBy(Pawn EventInstigator) {}
// ^ NEW IN 1.60
    delegate ServerReStartPlayer() {}
	// FIXME - IF HIT FIRE, AND NOT bInterpolating, Leave script
    exec function Fire(optional float f) {}
    function Timer() {}
}

state GameEnded
{
	// Return to spectator's own camera.
    exec function AltFire(optional float f) {}
    delegate ServerMove(bool NewbCrawl, bool NewbDuck, bool NewbRun, Vector ClientLoc, Vector InAccel, float TimeStamp, int View, int iNewRotOffset, optional byte OldTimeDelta, optional int OldAccel) {}
// ^ NEW IN 1.60
    function BeginState() {}
    function FindGoodView() {}
    function PlayerMove(float DeltaTime) {}
    function KilledBy(Pawn EventInstigator) {}
// ^ NEW IN 1.60
    function int R6TakeDamage(int iKillValue, int iStunValue, Pawn instigatedBy, Vector vHitLocation, Vector vMomentum, int iBulletToArmorModifier, optional int iBulletGoup) {}
// ^ NEW IN 1.60
    delegate Suicide() {}
    delegate ServerRestartGame() {}
	// FIXME - IF HIT FIRE, AND NOT bInterpolating, Leave script
    exec function Fire(optional float f) {}
    function Timer() {}
}

state PlayerSpidering
{
    event bool NotifyHitWall(Actor HitActor, Vector HitNormal) {}
// ^ NEW IN 1.60
    function bool NotifyPhysicsVolumeChange(PhysicsVolume NewVolume) {}
// ^ NEW IN 1.60
    function ProcessMove(Vector NewAccel, float DeltaTime, EDoubleClickDir DoubleClickMove, Rotator DeltaRot) {}
    function PlayerMove(float DeltaTime) {}
	// if spider mode, update rotation based on floor
    function UpdateRotation(float DeltaTime, float maxPitch) {}
    function bool NotifyLanded(Vector HitNormal) {}
// ^ NEW IN 1.60
    function BeginState() {}
    function EndState() {}
}

state Spectating
{
    delegate ClientReStart() {}
// ^ NEW IN 1.60
    delegate Suicide() {}
	// FIXME - IF HIT FIRE, AND NOT bInterpolating, Leave script
    exec function Fire(optional float f) {}
	// Return to spectator's own camera.
    exec function AltFire(optional float f) {}
    function BeginState() {}
    function EndState() {}
}

state PlayerWaiting
{
    function int R6TakeDamage(int iKillValue, int iStunValue, Pawn instigatedBy, Vector vHitLocation, Vector vMomentum, int iBulletToArmorModifier, optional int iBulletGoup) {}
// ^ NEW IN 1.60
    exec function Jump(optional float f) {}
    delegate Suicide() {}
    delegate ServerReStartPlayer() {}
	// FIXME - IF HIT FIRE, AND NOT bInterpolating, Leave script
    exec function Fire(optional float f) {}
	// Return to spectator's own camera.
    exec function AltFire(optional float f) {}
    function EndState() {}
    function BeginState() {}
}

defaultproperties
{
}
