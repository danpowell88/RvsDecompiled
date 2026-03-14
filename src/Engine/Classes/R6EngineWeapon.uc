//========================================================================================
//  R6EngineWeapon.uc :     This is the base class for the r6Weapon class.  It's here
//                          to put a pointer in the Pawn Class. and replace the 
//                          weapon/inventory system
//
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    July 18th, 2001 * Created by Joel Tremblay
//=============================================================================
class R6EngineWeapon extends Actor
    native
    abstract;

// --- Enums ---
enum eRateOfFire
{
    ROF_Single,
    ROF_ThreeRound,
    ROF_FullAuto
};
enum EWeaponSound
{
    WSOUND_None,
    WSOUND_Initialize,
    WSOUND_PlayTrigger,
    WSOUND_PlayFireSingleShot,
    WSOUND_PlayFireEndSingleShot,
    WSOUND_PlayFireThreeBurst,
    WSOUND_PlayFireFullAuto,
    WSOUND_PlayEmptyMag,
    WSOUND_PlayReloadEmpty,
    WSOUND_PlayReload,
    WSOUND_StopFireFullAuto
};
enum eGripType
{
	GRIP_None,
	GRIP_Aug,
	GRIP_BullPup,
	GRIP_LMG,
	GRIP_P90,
	GRIP_ShotGun,
	GRIP_Uzi,
	GRIP_SubGun,
	GRIP_HandGun
};
enum eWeaponType
{
    WT_Pistol,
    WT_Sub,
    WT_Assault,
    WT_ShotGun,
    WT_Sniper,
    WT_LMG,
    WT_Grenade,
    WT_Gadget
};
enum eWeaponGrenadeType
{
    GT_GrenadeNone,
	GT_GrenadeFrag,
	GT_GrenadeGas,
	GT_GrenadeFlash,
	GT_GrenadeSmoke
};
enum eGadgetType
{
    GAD_Other,
    GAD_SniperRifleScope,
    GAD_Magazine,
    GAD_Bipod,
    GAD_Muzzle,
    GAD_Silencer,
    GAD_Light
};

// --- Variables ---
// End Full Auto Shell
var Sound m_ShellEndFullAutoSnd;
// Full Auto shell only for LMG
var Sound m_ShellFullAutoSnd;
// 3 rounds burst shell
var Sound m_ShellBurstFireSnd;
// Single Fire Shell
var Sound m_ShellSingleFireSnd;
// Trigger Sound
var Sound m_TriggerSnd;
// Sound when the mag is empty
var Sound m_EmptyMagSnd;
// Last bullet in full auto for stereo sound
var Sound m_FullAutoEndStereoSnd;
// Full Auto Stereo
var Sound m_FullAutoStereoSnd;
// 3 rounds burst stereo
var Sound m_BurstFireStereoSnd;
// Single shot that is interruptible.
var Sound m_SingleFireEndStereoSnd;
// Single shot stereo (for 1st person view)
var Sound m_SingleFireStereoSnd;
// Reload Sound when the mag is empty
var Sound m_ReloadEmptySnd;
// Reload Sound
var Sound m_ReloadSnd;
var eWeaponType m_eWeaponType;
// Use bipod with the gun
var Sound m_BipodSnd;
// Second zoom sound
var Sound m_SniperZoomSecondSnd;
// First zoom sound
var Sound m_SniperZoomFirstSnd;
var Sound m_CommonWeaponZoomSnd;
// Change Rate of Fire sound
var Sound m_ChangeROFSnd;
// Sound when the player store his weapon
var Sound m_UnEquipSnd;
// Sound Stuff
// Sound when the player pick his weapon
var Sound m_EquipSnd;
var bool m_bBipod;
// Rainbow
var name m_PawnReloadAnimProneTactical;
// Rainbow
var name m_PawnReloadAnimProne;
// Rainbow
var name m_PawnReloadAnimTactical;
// Rainbow
var name m_PawnReloadAnim;
// Rainbow
var name m_PawnFiringAnimProne;
// Rainbow
var name m_PawnFiringAnim;
// Rainbow
var name m_PawnWaitAnimProne;
// Rainbow
var name m_PawnWaitAnimHigh;
// Animation names for the Pawn
// Rainbow
var name m_PawnWaitAnimLow;
var float m_fTimeDisplayParticule;
var int m_iNbParticlesToCreate;
var eGripType m_eGripType;
var bool m_bDisplayHudInfo;
//Weapon Management
// The weapon/gadget set, 0-3
var int m_InventoryGroup;
// Weapon Name ID
var string m_NameID;
// Weapon Name
var string m_WeaponDesc;
// Abreviation for this weapon in some menu
var string m_WeaponShortName;
// Attachments
var name m_AttachPoint;
var name m_HoldAttachPoint;
var name m_HoldAttachPoint2;
var string m_szMagazineClass;
var string m_szMuzzleClass;
var string m_szSilencerClass;
var string m_szTacticalLightClass;
var Sound m_ReloadSound;
// Offsets to display the weapon
var Vector m_vPositionOffset;
//Max zoom for gun with integrated scope
var /* replicated */ float m_fMaxZoom;
//Scope texture while zooming.
var Texture m_ScopeTexture;
//Scope add texture (not used in heat or night vision)
var Texture m_ScopeAdd;
//Mesh used when gadget is a scope.
var StaticMesh m_WithScopeSM;
// to override the texture in the emitter.
var Texture m_FPMuzzleFlashTexture;
// m_fRateOfFire / 0.1
var float m_fFireAnimRate;
// anim blending while firing (based on weapon energy).
var float m_fFPBlend;
// how much to damp view bob
var float BobDamping;
var float m_fReloadTime;
var float m_fReloadEmptyTime;
var float m_fPauseWhenChanging;
var /* replicated */ bool m_bDeployBipod;
var bool m_bBipodDeployed;
// To play the firing animation
var bool bFiredABullet;
// To keep the bobing animation after changing weapon.
var bool m_bPawnIsWalking;
// weapon is either inherently silenced or has a weapon gadget added to silence it - 19 feb 2002 rbrek
var bool m_bIsSilenced;
// Weapon have infinite number of clip (for terrorist)
var /* replicated */ bool m_bUnlimitedClip;
// Weapon have use micro animation (for terrorist)
var bool m_bUseMicroAnim;
var Vector m_FPFlashLocation;
//Current Number Of bullets in weapon, to be replicated
var /* replicated */ byte m_iNbBulletsInWeapon;
// Last bullet in full auto for mono sound
var Sound m_FullAutoEndMonoSnd;
var Material m_HUDTexture;
var Plane m_HUDTexturePos;

// --- Functions ---
// function ? ClientShowInfo(...); // REMOVED IN 1.60
// function ? DisplayWeaponDGBInfo(...); // REMOVED IN 1.60
// function ? ShowInfo(...); // REMOVED IN 1.60
simulated function PostRender(Canvas Canvas) {}
simulated event DeployWeaponBipod(bool bBipodOpen) {}
simulated function bool ClientFire(float Value) {}
// ^ NEW IN 1.60
simulated function bool ClientAltFire(float Value) {}
// ^ NEW IN 1.60
function Fire(float Value) {}
function AltFire(float Value) {}
simulated function bool LoadFirstPersonWeapon(optional Pawn NetOwner, optional Controller LocalPlayerController) {}
// ^ NEW IN 1.60
simulated function RemoveFirstPersonWeapon() {}
simulated function AttachEmittersToFPWeapon() {}
simulated function AttachEmittersTo3rdWeapon() {}
simulated function DisableWeaponOrGadget() {}
simulated function TurnOffEmitters(bool bTurnOff) {}
function GiveMoreAmmo() {}
function AttachMagazine() {}
simulated function int NumberOfBulletsLeftInClip() {}
// ^ NEW IN 1.60
function float GetCurrentMaxAngle() {}
// ^ NEW IN 1.60
function bool IsAtBestAccuracy() {}
// ^ NEW IN 1.60
function float GetWeaponJump() {}
// ^ NEW IN 1.60
exec function SetNextRateOfFire() {}
function bool SetRateOfFire(eRateOfFire eNewRateOfFire) {}
// ^ NEW IN 1.60
function eRateOfFire GetRateOfFire() {}
// ^ NEW IN 1.60
function SetHoldAttachPoint() {}
function UseScopeStaticMesh() {}
function SetTerroristNbOfClips(int iNewNumber) {}
function int GetNbOfClips() {}
// ^ NEW IN 1.60
function bool HasAtLeastOneFullClip() {}
// ^ NEW IN 1.60
function int GetClipCapacity() {}
// ^ NEW IN 1.60
function float GetMuzzleVelocity() {}
// ^ NEW IN 1.60
/////////////////////////
// ANIMATION FUNCTIONS //
/////////////////////////
simulated function name GetWaitAnimName() {}
// ^ NEW IN 1.60
simulated function name GetHighWaitAnimName() {}
// ^ NEW IN 1.60
simulated function name GetProneWaitAnimName() {}
// ^ NEW IN 1.60
simulated function name GetFiringAnimName() {}
// ^ NEW IN 1.60
simulated function name GetProneFiringAnimName() {}
// ^ NEW IN 1.60
simulated function name GetReloadAnimName() {}
// ^ NEW IN 1.60
simulated function name GetReloadAnimTacticalName() {}
// ^ NEW IN 1.60
simulated function name GetProneReloadAnimName() {}
// ^ NEW IN 1.60
simulated function name GetProneReloadAnimTacticalName() {}
// ^ NEW IN 1.60
simulated function PlayReloading() {}
//First Person walking animation (bobing)
simulated event PawnIsMoving() {}
simulated event PawnStoppedMoving() {}
function bool HasAmmo() {}
// ^ NEW IN 1.60
function ChangeClip() {}
function FullCurrentClip() {}
function FillClips() {}
function AddExtraClip() {}
simulated function AddClips(int iNbOfExtraClips) {}
function bool CanSwitchToWeapon() {}
// ^ NEW IN 1.60
function ServerStopFire(optional bool bSoundOnly) {}
function ClientStopFire(optional bool bSoundOnly) {}
function LocalStopFire(optional bool bSoundOnly) {}
function StopFire(optional bool bSoundOnly) {}
function StopAltFire() {}
function FullAmmo() {}
function PerfectAim() {}
event SetIdentifyTarget(bool bIdentifyCharacter, bool bFriendly, string characterName) {}
simulated function R6SetReticule(optional Controller LocalPlayerController) {}
simulated function UpdateHands() {}
simulated function WeaponInitialization(Pawn pawnOwner) {}
function StartLoopingAnims() {}
simulated function FirstPersonAnimOver() {}
delegate ServerPutBulletInShotgun() {}
function ClientAddShell() {}
function bool GunIsFull() {}
// ^ NEW IN 1.60
simulated function bool GotBipod() {}
// ^ NEW IN 1.60
function Toggle3rdBipod(bool bBipodOpen) {}
//Grenade specific functions
function ThrowGrenade() {}
function float GetSaveDistanceToThrow() {}
// ^ NEW IN 1.60
// Charge specific functions
delegate ServerPlaceCharge(Vector vLocation) {}
delegate ServerDetonate() {}
delegate ServerPlaceChargeAnimation() {}
function NPCPlaceCharge(Actor aDoor) {}
function NPCDetonateCharge() {}
function GiveBulletToWeapon(string aBulletName) {}
function bool HasBulletType(name strBulletType) {}
// ^ NEW IN 1.60
simulated event bool IsGoggles() {}
// ^ NEW IN 1.60
function SetHeartBeatRange(float fRange) {}
delegate WeaponZoomSound(bool bFirstZoom) {}
function Texture Get2DIcon() {}
// ^ NEW IN 1.60
simulated function StartFalling() {}
simulated function SetGadgets() {}
function bool AffectActor(int BulletGroup, Actor ActorAffected) {}
// ^ NEW IN 1.60
simulated function bool IsPumpShotGun() {}
// ^ NEW IN 1.60
function bool IsSniperRifle() {}
// ^ NEW IN 1.60
simulated function bool IsLMG() {}
// ^ NEW IN 1.60
function bool HasScope() {}
// ^ NEW IN 1.60
function float GetExplosionDelay() {}
// ^ NEW IN 1.60
function float GetWeaponRange() {}
// ^ NEW IN 1.60
simulated event UpdateWeaponAttachment() {}
function SetRelevant(bool bNewAlwaysRelevant) {}
function SetTearOff(bool bNewTearOff) {}
simulated event ShowWeaponParticules(EWeaponSound EWeaponSound) {}
function SetAccuracyOnHit() {}
delegate ServerShowInfo() {}

defaultproperties
{
}
