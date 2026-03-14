//=============================================================================
//  R6Weapons.uc : Base class of all weapons
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/04/20 * Created by Aristomenis Kolokathis
//    2001/05/03 * (AK) Added bullet burst
//    2003/06/12 * Major rework to eliminate "Trigger Lag" (Olivier Rouleau)
//=============================================================================
class R6Weapons extends R6AbstractWeapon
    native
    abstract;

#exec NEW StaticMesh FILE="models\RedWeapon.ASE" NAME="RedWeaponStaticMesh"

// --- Constants ---
const AccuracyLostWhenWounded =  1.2;

// --- Structs ---
struct stAccuracyType
{
	var () FLOAT fBaseAccuracy;			// Best possible accuracy
	var () FLOAT fShuffleAccuracy;		// Worst Possible Accuracy when character is looking around
	var () FLOAT fWalkingAccuracy;		// Worst Accuracy when a character is walking
	var () FLOAT fWalkingFastAccuracy;	// Worst Accuracy when a characters is walking fast(Rainbow's run)
	var () FLOAT fRunningAccuracy;		// Worst Accuracy when a characters is running (Terrorist running), worst overall accuracy
	var () FLOAT fReticuleTime;			// Number of seconds it takes to recover from the Running to the base accuracy
    var () FLOAT fAccuracyChange;       // Accuracy penalty after the character fires a bullet
	var () FLOAT fWeaponJump;			// How much the weapon jumps after each round.
};

struct stWeaponCaps
{
    var () INT bSingle;                 // caps set to 1 if weapon can fire single shots
    var () INT bThreeRound;             // caps set to 1 if weapon can fire 3 bullets bursts
    var () INT bFullAuto;               // caps set to 1 if weapon can fire full automatic
    var () INT bCMag;                   // caps set to 1 if weapon can have a CMag as gadget
    var () INT bMuzzle;                 // caps set to 1 if weapon can have a Muzzle as gadget
    var () INT bSilencer;               // caps set to 1 if weapon can have a silencer as gadget
    var () INT bLight;                  // caps set to 1 if weapon can have a tactical light as gadget
    var () INT bMiniScope;              // caps set to 1 if weapon can have a 3.5x mini scope as gadget
    var () INT bHeatVision;             // caps set to 1 if weapon can have a heat vision scope (sniper gun only)
};

// --- Variables ---
// var ? bCMag; // REMOVED IN 1.60
// var ? bFullAuto; // REMOVED IN 1.60
// var ? bHeatVision; // REMOVED IN 1.60
// var ? bLight; // REMOVED IN 1.60
// var ? bMiniScope; // REMOVED IN 1.60
// var ? bMuzzle; // REMOVED IN 1.60
// var ? bSilencer; // REMOVED IN 1.60
// var ? bSingle; // REMOVED IN 1.60
// var ? bThreeRound; // REMOVED IN 1.60
// var ? fAccuracyChange; // REMOVED IN 1.60
// var ? fBaseAccuracy; // REMOVED IN 1.60
// var ? fReticuleTime; // REMOVED IN 1.60
// var ? fRunningAccuracy; // REMOVED IN 1.60
// var ? fShuffleAccuracy; // REMOVED IN 1.60
// var ? fWalkingAccuracy; // REMOVED IN 1.60
// var ? fWalkingFastAccuracy; // REMOVED IN 1.60
// var ? fWeaponJump; // REMOVED IN 1.60
// var ? m_pReticuleClass; // REMOVED IN 1.60
// var ? m_pWithWeaponReticuleClass; // REMOVED IN 1.60
var bool bShowLog;
// ^ NEW IN 1.60
// instance of the reticule
var R6Reticule m_ReticuleInstance;
var R6SFX m_pEmptyShellsEmitter;
var R6SFX m_pMuzzleFlashEmitter;
//current class spawned in the game, default bullet for terrorist.
var /* replicated */ class<R6Bullet> m_pBulletClass;
// Number of rounds shot since the trigger was pull
var byte m_iNbOfRoundsInBurst;
// Current Rate of Fire
var /* replicated */ eRateOfFire m_eRateOfFire;
var stAccuracyType m_stAccuracyValues;
// Number of clip with at least one round in
var /* replicated */ int m_iCurrentNbOfClips;
// Number of bullets in each magazines (The current maximum is 16 (8+4+4))
var byte m_aiNbOfBullets[20];
// Number of round per magazine
var /* replicated */ int m_iClipCapacity;
// Active Clip Number
var /* replicated */ int m_iCurrentClip;
// This is the number of clip that the guns had at the beginning of the mission
var int m_iNbOfClips;
// Number of rounds to be shoot by holding the trigger (safe = 0, Single = 1, ThreeRound = 3, FullAuto=MagazineCapacity)
var int m_iNbOfRoundsToShoot;
// muzzle velocity of bullet, this may affect the range of bullet, friction is negligible and bullet will travel in a straight line
var float m_fMuzzleVelocity;
// Variable used for falling
// Location the pawn was at when the weapon start falling.  Used to find a location for the falling weapon if everything else fails.
var Vector m_vPawnLocWhenKilled;
var bool m_bFireOn;
// Angle that is set depending of the effective accuracy
var float m_fMaxAngleError;
// Inital direction of a buckshot shell
var Rotator m_rBuckFirstBullet;
var string m_szReticuleClass;
// ^ NEW IN 1.60
// when set to true, a pistol in MP can always be reloaded with 5 bullets.
var bool m_bEmptyAllClips;
//use to describe avalaible options in menus and selected options in the game
var stWeaponCaps m_stWeaponCaps;
var const int C_iMaxNbOfClips;
// Effective accuracy. This accuracy is compute once a tick
var float m_fEffectiveAccuracy;
// Location the pawn was at when the weapon start falling.  Used to find a location for the falling weapon if everything else fails.
var byte m_wNbOfBounce;
var float m_MuzzleScale;
// ^ NEW IN 1.60
// MuzzleFlash spawned when firing
var class<R6SFX> m_pMuzzleFlash;
//empty shell particule spawned when firing
var class<R6SFX> m_pEmptyShells;
// Number of extra clips per EXTRA CLIP gadget
var int m_iNbOfExtraClips;
//Time between each rounds
var float m_fRateOfFire;
//
var float m_fCurrentFireJump;
// Desired accuracy.
var float m_fDesiredAccuracy;
// Accuracy in worst case.
var float m_fWorstAccuracy;
// icon to display weapon in the hud (must be 128x64)
var Texture m_WeaponIcon;
var string m_szWithWeaponReticuleClass;
// ^ NEW IN 1.60
// weapon's FOV
var float m_fDisplayFOV;
var int m_iDbgNextReticule;
// ^ NEW IN 1.60
var bool m_bSoundLog;
// ^ NEW IN 1.60
var bool m_bPlayLoopingSound;
// Distance (in unit) at wich the fire is heard by the AI
var float m_fFireSoundRadius;
// Old value for worst accuracy, to detect if the value changed
var float m_fOldWorstAccuracy;
// Accuracy improvement when you're stable
var float m_fStablePercentage;
var int m_iCurrentAverage;
var float m_fAverageDegTable[5];
var float m_fAverageDegChanges;
// Last Pawn.Rotation.  Use to compute the delta angle
var Rotator m_rLastRotation;

// --- Functions ---
// function ? DbgNextReticule(...); // REMOVED IN 1.60
// function ? DisplayWeaponDGBInfo(...); // REMOVED IN 1.60
// function ? ShowInfo(...); // REMOVED IN 1.60
// For MacArthur weapons, AltFire will activate the gadget and roll grenades.
// Still don't know what Value is used for?
simulated function AltFire(float fValue) {}
// FiringSpeed is used in UW as the rate parameter in playanim.
function Fire(float fValue) {}
//This function is used to send ClientStopFire() to the client immediatly after the bullet-fire-order
//has been sent to the server without having to wait for server response.
delegate StopFire(optional bool bSoundOnly) {}
simulated function PlayReloading() {}
//Spawn the FP weapon class and attach it to the Hands
simulated function bool LoadFirstPersonWeapon(optional Pawn NetOwner, optional Controller LocalPlayerController) {}
// ^ NEW IN 1.60
//Delete the first person weapon.  To keep only one in memory
simulated function RemoveFirstPersonWeapon() {}
////////////////////////////////////////////////////////////////////////////
// WEAPON INITIALISATION                                                  //
////////////////////////////////////////////////////////////////////////////
// Do not put the PostBeginPlay Simulated because in MultiPlayer when the //
// weapon become relevant the nb of bullet it reset to the clip capacity  //
////////////////////////////////////////////////////////////////////////////
simulated function PostBeginPlay() {}
simulated event HideAttachment() {}
simulated function WeaponInitialization(Pawn pawnOwner) {}
//============================================================================
// function StartFalling -
//============================================================================
simulated function StartFalling() {}
function bool CanSwitchToWeapon() {}
// ^ NEW IN 1.60
//When changing charter, this is to start playing the wait animations.
function StartLoopingAnims() {}
////////////////////////////
// RATE OF FIRE FUNCTIONS //
////////////////////////////
exec function SetNextRateOfFire() {}
simulated function TurnOffEmitters(bool bTurnOff) {}
//Called on server and client
simulated function AddClips(int iNbOfExtraClips) {}
// this sets the reticule instance
simulated function R6SetReticule(optional Controller LocalPlayerController) {}
function int NbBulletToShot() {}
// ^ NEW IN 1.60
function float GetExplosionDelay() {}
// ^ NEW IN 1.60
simulated function bool GunIsFull() {}
// ^ NEW IN 1.60
//Added when trigger lag became an option, non-replicated version of StopFire
function LocalStopFire(optional bool bSoundOnly) {}
event SetIdentifyTarget(bool bIdentifyCharacter, bool bFriendly, string characterName) {}
function ClientYourOwnerIs(Actor OwnerFromServer) {}
//Change the rate fo fire to a valid one, called by ServerSetNextRateOfFire
function bool SetRateOfFire(eRateOfFire eNewRateOfFire) {}
// ^ NEW IN 1.60
function R6AbstractBulletManager GetBulletManager() {}
// ^ NEW IN 1.60
//This function is called *after* the server has handled the shooting of the bullet.
function ClientsFireBullet(byte iBulletNbFired) {}
//============================================================================
// function HitWall - Bounce when the weapon fall of a dead pawn
//============================================================================
simulated function HitWall(Vector HitNormal, Actor Wall) {}
//Overloaded from R6AbstractWeapons
function SetTerroristNbOfClips(int iNewNumber) {}
function GiveBulletToWeapon(string aBulletName) {}
simulated event DeployWeaponBipod(bool bBipodOpen) {}
//Originally called when the fire button is released, not automacially anymore, see Timer()
//Never call directly.  Allways use localstopfire() instead.  Since trigger lag became an option.
delegate ServerStopFire(optional bool bSoundOnly) {}
simulated function FillClips() {}
//Was simply called StopFire() in the past
delegate ClientStopFire(optional bool bSoundOnly) {}
function bool HasAtLeastOneFullClip() {}
// ^ NEW IN 1.60
//Cheat/debug function
function FullAmmo() {}
function bool HasBulletType(name strBulletName) {}
// ^ NEW IN 1.60
function bool AffectActor(Actor ActorAffected, int BulletGroup) {}
// ^ NEW IN 1.60
simulated function AttachEmittersTo3rdWeapon() {}
function SetRelevant(bool bNewAlwaysRelevant) {}
function SetTearOff(bool bNewTearOff) {}
function ServerChangeClip() {}
simulated event RenderOverlays(Canvas Canvas) {}
simulated function PostRender(Canvas Canvas) {}
simulated event ShowWeaponParticules(EWeaponSound EWeaponSound) {}
//////////////////////
// FIRING DIRECTION //
//////////////////////
function GetFiringDirection(out Rotator rRotation, out Vector vOrigin, optional int iBulletNumber) {}
//This functions is called *immediatly* when trigger is pulled.  It only displays shooting effects.
//The actual shooting of the bullet is done on the server in ServerFireBullet().
function ClientShowBulletFire() {}
simulated function R6SetGadget(class<R6AbstractGadget> pWeaponGadgetClass) {}
//============================================================================
// function BOOL CheckForPlaceToFall -
//============================================================================
simulated function bool CheckForPlaceToFall() {}
// ^ NEW IN 1.60
function ServerFireBullet(float fMaxAngleErrorFromClient) {}
delegate WeaponZoomSound(bool bFirstZoom) {}
function ServerStartChangeClip() {}
function ClientStartChangeClip() {}
function FullCurrentClip() {}
function SetAccuracyOnHit() {}
//============================================================================
// function PutAtOwnerFeet -
//============================================================================
simulated function PutAtOwnerFeet() {}
//============================================================================
// function StopFallingAndSetCorrectRotation -
//============================================================================
simulated function StopFallingAndSetCorrectRotation() {}
simulated event UpdateWeaponAttachment() {}
// For Raven Shield weapons, AltFire will activate the gadget
simulated function bool ClientAltFire(float fValue) {}
// ^ NEW IN 1.60
function float GetMuzzleVelocity() {}
// ^ NEW IN 1.60
function Texture Get2DIcon() {}
// ^ NEW IN 1.60
function int GetClipCapacity() {}
// ^ NEW IN 1.60
//Cheat/debug function
function PerfectAim() {}
simulated function int NumberOfBulletsLeftInClip() {}
// ^ NEW IN 1.60
simulated function bool HasAmmo() {}
// ^ NEW IN 1.60
function ServerStartFiring() {}
function ClientStartFiring() {}
simulated function CreateWeaponEmitters() {}
//Overloaded from R6AbstractWeapons
function bool IsAtBestAccuracy() {}
// ^ NEW IN 1.60
//Overloaded from R6AbstractWeapons
function float GetCurrentMaxAngle() {}
// ^ NEW IN 1.60
function int GetNbOfClips() {}
// ^ NEW IN 1.60
function ServerAddClips() {}
////////////////////////////////
// CLIPS MANAGEMENT FUNCTIONS //
////////////////////////////////
simulated function AddExtraClip() {}
function int GetNbOfRoundsForROF() {}
// ^ NEW IN 1.60
function eRateOfFire GetRateOfFire() {}
// ^ NEW IN 1.60
function ServerSetNextRateOfFire() {}
function ReloadShotGun() {}
simulated function UpdateAllAttachments() {}
simulated event PawnStoppedMoving() {}
simulated event PawnIsMoving() {}
simulated function AttachEmittersToFPWeapon() {}
function ServerWhoIsMyOwner() {}
function float GetWeaponJump() {}
// ^ NEW IN 1.60
function float GetWeaponRange() {}
// ^ NEW IN 1.60
simulated event Destroyed() {}
simulated function SetGadgets() {}
simulated function SpawnSelectedGadget() {}
simulated function UseScopeStaticMesh() {}
function bool HasScope() {}
// ^ NEW IN 1.60

state BringWeaponUp
{
    function FirstPersonAnimOver() {}
    simulated function BeginState() {}
    simulated function EndState() {}
    function PlayReloading() {}
//    function StopFire() {}
    function StopAltFire() {}
//This function is used to send ClientStopFire() to the client immediatly after the bullet-fire-order
//has been sent to the server without having to wait for server response.
    function StopFire(optional bool bSoundOnly) {}
// For MacArthur weapons, AltFire will activate the gadget and roll grenades.
// Still don't know what Value is used for?
    function AltFire(float Value) {}
// FiringSpeed is used in UW as the rate parameter in playanim.
    function Fire(float Value) {}
}

state NormalFire
{
// FiringSpeed is used in UW as the rate parameter in playanim.
    function Fire(float Value) {}
    function EndState() {}
    simulated function BeginState() {}
    function DoSingleFire() {}
    simulated function Timer() {}
    simulated function StartFiring() {}
    simulated function FirstPersonAnimOver() {}
    function PlayReloading() {}
//    function StopFire() {}
    function StopAltFire() {}
// For MacArthur weapons, AltFire will activate the gadget and roll grenades.
// Still don't know what Value is used for?
    function AltFire(float Value) {}
////////////////////////////
// RATE OF FIRE FUNCTIONS //
////////////////////////////
    exec function SetNextRateOfFire() {}
}

state DiscardWeapon
{
    simulated function BeginState() {}
//    function StopFire() {}
    function StopAltFire() {}
// FiringSpeed is used in UW as the rate parameter in playanim.
    function Fire(float Value) {}
    simulated function EndState() {}
// For MacArthur weapons, AltFire will activate the gadget and roll grenades.
// Still don't know what Value is used for?
    function AltFire(float Value) {}
    function PlayReloading() {}
//This function is used to send ClientStopFire() to the client immediatly after the bullet-fire-order
//has been sent to the server without having to wait for server response.
    function StopFire(optional bool bSoundOnly) {}
    function FirstPersonAnimOver() {}
}

state RaiseWeapon
{
    simulated function BeginState() {}
    function FirstPersonAnimOver() {}
    function EndState() {}
// FiringSpeed is used in UW as the rate parameter in playanim.
    function Fire(float Value) {}
// For MacArthur weapons, AltFire will activate the gadget and roll grenades.
// Still don't know what Value is used for?
    function AltFire(float Value) {}
//This function is used to send ClientStopFire() to the client immediatly after the bullet-fire-order
//has been sent to the server without having to wait for server response.
    function StopFire(optional bool bSoundOnly) {}
//    function StopFire() {}
    function StopAltFire() {}
    function PlayReloading() {}
}

state PutWeaponDown
{
    simulated function BeginState() {}
    function FirstPersonAnimOver() {}
    function PlayReloading() {}
//    function StopFire() {}
    function StopAltFire() {}
//This function is used to send ClientStopFire() to the client immediatly after the bullet-fire-order
//has been sent to the server without having to wait for server response.
    function StopFire(optional bool bSoundOnly) {}
// For MacArthur weapons, AltFire will activate the gadget and roll grenades.
// Still don't know what Value is used for?
    function AltFire(float Value) {}
// FiringSpeed is used in UW as the rate parameter in playanim.
    function Fire(float Value) {}
}

state Reloading
{
    function int GetReloadProgress() {}
// ^ NEW IN 1.60
    simulated function ChangeClip() {}
    simulated function BeginState() {}
    function FirstPersonAnimOver() {}
    function EndState() {}
    event Tick(float fDeltaTime) {}
// FiringSpeed is used in UW as the rate parameter in playanim.
    function Fire(float Value) {}
////////////////////////////
// RATE OF FIRE FUNCTIONS //
////////////////////////////
    exec function SetNextRateOfFire() {}
// For MacArthur weapons, AltFire will activate the gadget and roll grenades.
// Still don't know what Value is used for?
    function AltFire(float Value) {}
//    function StopFire() {}
    function StopAltFire() {}
    function PlayReloading() {}
}

state ZoomIn
{
    function FirstPersonAnimOver() {}
    simulated function EndState() {}
    simulated function BeginState() {}
    function PlayReloading() {}
//    function StopFire() {}
    function StopAltFire() {}
// For MacArthur weapons, AltFire will activate the gadget and roll grenades.
// Still don't know what Value is used for?
    function AltFire(float Value) {}
// FiringSpeed is used in UW as the rate parameter in playanim.
    function Fire(float Value) {}
}

state ZoomOut
{
    simulated function BeginState() {}
    function FirstPersonAnimOver() {}
}

state CloseBipod
{
    simulated function BeginState() {}
    function FirstPersonAnimOver() {}
    function PlayReloading() {}
//    function StopFire() {}
    function StopAltFire() {}
// For MacArthur weapons, AltFire will activate the gadget and roll grenades.
// Still don't know what Value is used for?
    function AltFire(float Value) {}
// FiringSpeed is used in UW as the rate parameter in playanim.
    function Fire(float Value) {}
}

state DeployBipod
{
    function EndState() {}
    simulated function BeginState() {}
    function FirstPersonAnimOver() {}
    function PlayReloading() {}
//    function StopFire() {}
    function StopAltFire() {}
// For MacArthur weapons, AltFire will activate the gadget and roll grenades.
// Still don't know what Value is used for?
    function AltFire(float Value) {}
// FiringSpeed is used in UW as the rate parameter in playanim.
    function Fire(float Value) {}
}

defaultproperties
{
}
