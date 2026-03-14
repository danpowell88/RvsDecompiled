//=============================================================================
// R6EngineWeapon - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
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
    abstract
    native
    notplaceable;

enum eWeaponType
{
	WT_Pistol,                      // 0
	WT_Sub,                         // 1
	WT_Assault,                     // 2
	WT_ShotGun,                     // 3
	WT_Sniper,                      // 4
	WT_LMG,                         // 5
	WT_Grenade,                     // 6
	WT_Gadget                       // 7
};

enum eGripType
{
	GRIP_None,                      // 0
	GRIP_Aug,                       // 1
	GRIP_BullPup,                   // 2
	GRIP_LMG,                       // 3
	GRIP_P90,                       // 4
	GRIP_ShotGun,                   // 5
	GRIP_Uzi,                       // 6
	GRIP_SubGun,                    // 7
	GRIP_HandGun                    // 8
};

enum eWeaponGrenadeType
{
	GT_GrenadeNone,                 // 0
	GT_GrenadeFrag,                 // 1
	GT_GrenadeGas,                  // 2
	GT_GrenadeFlash,                // 3
	GT_GrenadeSmoke                 // 4
};

enum eRateOfFire
{
	ROF_Single,                     // 0
	ROF_ThreeRound,                 // 1
	ROF_FullAuto                    // 2
};

enum eGadgetType
{
	GAD_Other,                      // 0
	GAD_SniperRifleScope,           // 1
	GAD_Magazine,                   // 2
	GAD_Bipod,                      // 3
	GAD_Muzzle,                     // 4
	GAD_Silencer,                   // 5
	GAD_Light                       // 6
};

enum EWeaponSound
{
	WSOUND_None,                    // 0
	WSOUND_Initialize,              // 1
	WSOUND_PlayTrigger,             // 2
	WSOUND_PlayFireSingleShot,      // 3
	WSOUND_PlayFireEndSingleShot,   // 4
	WSOUND_PlayFireThreeBurst,      // 5
	WSOUND_PlayFireFullAuto,        // 6
	WSOUND_PlayEmptyMag,            // 7
	WSOUND_PlayReloadEmpty,         // 8
	WSOUND_PlayReload,              // 9
	WSOUND_StopFireFullAuto         // 10
};

var(R6GunProperties) R6EngineWeapon.eWeaponType m_eWeaponType;
var R6EngineWeapon.eGripType m_eGripType;
var byte m_iNbBulletsInWeapon;  // Current Number Of bullets in weapon, to be replicated
var int m_iNbParticlesToCreate;
//Weapon Management
var int m_InventoryGroup;  // The weapon/gadget set, 0-3
var(R6GunProperties) bool m_bDisplayHudInfo;
var(R6GunProperties) bool m_bBipod;
var bool m_bDeployBipod;
var bool m_bBipodDeployed;
var bool bFiredABullet;  // To play the firing animation
var bool m_bPawnIsWalking;  // To keep the bobing animation after changing weapon.
var bool m_bIsSilenced;  // weapon is either inherently silenced or has a weapon gadget added to silence it - 19 feb 2002 rbrek
var bool m_bUnlimitedClip;  // Weapon have infinite number of clip (for terrorist)
var bool m_bUseMicroAnim;  // Weapon have use micro animation (for terrorist)
var float m_fTimeDisplayParticule;
var(R6GunProperties) float m_fMaxZoom;  // Max zoom for gun with integrated scope
var float m_fFireAnimRate;  // m_fRateOfFire / 0.1
var float m_fFPBlend;  // anim blending while firing (based on weapon energy).
var(R6GunProperties) float BobDamping;  // how much to damp view bob
var(R6GunProperties) float m_fReloadTime;
var(R6GunProperties) float m_fReloadEmptyTime;
var float m_fPauseWhenChanging;
var(R6Sounds) Sound m_ReloadSound;
var(R6GunProperties) Texture m_ScopeTexture;  // Scope texture while zooming.
var(R6GunProperties) Texture m_ScopeAdd;  // Scope add texture (not used in heat or night vision)
var(R6GunProperties) StaticMesh m_WithScopeSM;  // Mesh used when gadget is a scope.
var(R6GunProperties) Texture m_FPMuzzleFlashTexture;  // to override the texture in the emitter.
// Sound Stuff
var(R6WeaponSound) Sound m_EquipSnd;  // Sound when the player pick his weapon
var(R6WeaponSound) Sound m_UnEquipSnd;  // Sound when the player store his weapon
var(R6WeaponSound) Sound m_ReloadSnd;  // Reload Sound
var(R6WeaponSound) Sound m_ReloadEmptySnd;  // Reload Sound when the mag is empty
var(R6WeaponSound) Sound m_ChangeROFSnd;  // Change Rate of Fire sound
var(R6WeaponSound) Sound m_SingleFireStereoSnd;  // Single shot stereo (for 1st person view)
var(R6WeaponSound) Sound m_SingleFireEndStereoSnd;  // Single shot that is interruptible.
var(R6WeaponSound) Sound m_BurstFireStereoSnd;  // 3 rounds burst stereo
var(R6WeaponSound) Sound m_FullAutoStereoSnd;  // Full Auto Stereo
var(R6WeaponSound) Sound m_FullAutoEndMonoSnd;  // Last bullet in full auto for mono sound
var(R6WeaponSound) Sound m_FullAutoEndStereoSnd;  // Last bullet in full auto for stereo sound
var(R6WeaponSound) Sound m_EmptyMagSnd;  // Sound when the mag is empty
var(R6WeaponSound) Sound m_TriggerSnd;  // Trigger Sound
var(R6WeaponSound) Sound m_ShellSingleFireSnd;  // Single Fire Shell
var(R6WeaponSound) Sound m_ShellBurstFireSnd;  // 3 rounds burst shell
var(R6WeaponSound) Sound m_ShellFullAutoSnd;  // Full Auto shell only for LMG
var(R6WeaponSound) Sound m_ShellEndFullAutoSnd;  // End Full Auto Shell
var(R6WeaponSound) Sound m_CommonWeaponZoomSnd;
var(R6WeaponSound) Sound m_SniperZoomFirstSnd;  // First zoom sound
var(R6WeaponSound) Sound m_SniperZoomSecondSnd;  // Second zoom sound
var(R6WeaponSound) Sound m_BipodSnd;  // Use bipod with the gun
var Material m_HUDTexture;
// Animation names for the Pawn
var(R6Animation) name m_PawnWaitAnimLow;  // Rainbow
var(R6Animation) name m_PawnWaitAnimHigh;  // Rainbow
var(R6Animation) name m_PawnWaitAnimProne;  // Rainbow
var(R6Animation) name m_PawnFiringAnim;  // Rainbow
var(R6Animation) name m_PawnFiringAnimProne;  // Rainbow
var(R6Animation) name m_PawnReloadAnim;  // Rainbow
var(R6Animation) name m_PawnReloadAnimTactical;  // Rainbow
var(R6Animation) name m_PawnReloadAnimProne;  // Rainbow
var(R6Animation) name m_PawnReloadAnimProneTactical;  // Rainbow
// Attachments
var(R6Attachment) name m_AttachPoint;
var(R6Attachment) name m_HoldAttachPoint;
var(R6Attachment) name m_HoldAttachPoint2;
var(R6GunProperties) Vector m_vPositionOffset;  // Offsets to display the weapon
var Vector m_FPFlashLocation;
var Plane m_HUDTexturePos;
var string m_NameID;  // Weapon Name ID
var string m_WeaponDesc;  // Weapon Name
var string m_WeaponShortName;  // Abreviation for this weapon in some menu
var(R6Attachment) string m_szMagazineClass;
var(R6Attachment) string m_szMuzzleClass;
var(R6Attachment) string m_szSilencerClass;
var(R6Attachment) string m_szTacticalLightClass;

replication
{
	// Pos:0x01A
	unreliable if(__NFUN_150__(int(Role), int(ROLE_Authority)))
		ServerDetonate, ServerPlaceCharge, 
		ServerPlaceChargeAnimation, ServerPutBulletInShotgun, 
		ServerShowInfo;

	// Pos:0x034
	unreliable if(__NFUN_154__(int(Role), int(ROLE_Authority)))
		WeaponZoomSound;

	// Pos:0x000
	reliable if(__NFUN_150__(int(Role), int(ROLE_Authority)))
		ServerStopFire;

	// Pos:0x00D
	reliable if(__NFUN_154__(int(Role), int(ROLE_Authority)))
		ClientStopFire, StopFire;

	// Pos:0x027
	reliable if(__NFUN_154__(int(Role), int(ROLE_Authority)))
		m_bDeployBipod, m_bUnlimitedClip, 
		m_iNbBulletsInWeapon;

	// Pos:0x041
	reliable if(__NFUN_130__(bNetOwner, __NFUN_154__(int(Role), int(ROLE_Authority))))
		m_fMaxZoom;
}

simulated function PostRender(Canvas Canvas)
{
	return;
}

simulated event DeployWeaponBipod(bool bBipodOpen)
{
	return;
}

simulated function bool ClientFire(float Value)
{
	return;
}

simulated function bool ClientAltFire(float Value)
{
	return;
}

function Fire(float Value)
{
	return;
}

function AltFire(float Value)
{
	return;
}

simulated function bool LoadFirstPersonWeapon(optional Pawn NetOwner, optional Controller LocalPlayerController)
{
	return false;
	return;
}

simulated function RemoveFirstPersonWeapon()
{
	return;
}

simulated function AttachEmittersToFPWeapon()
{
	return;
}

simulated function AttachEmittersTo3rdWeapon()
{
	return;
}

simulated function DisableWeaponOrGadget()
{
	return;
}

simulated function TurnOffEmitters(bool bTurnOff)
{
	return;
}

function GiveMoreAmmo()
{
	return;
}

function AttachMagazine()
{
	return;
}

simulated function int NumberOfBulletsLeftInClip()
{
	return;
}

function float GetCurrentMaxAngle()
{
	return;
}

function bool IsAtBestAccuracy()
{
	return;
}

function float GetWeaponJump()
{
	return;
}

exec function SetNextRateOfFire()
{
	return;
}

function bool SetRateOfFire(R6EngineWeapon.eRateOfFire eNewRateOfFire)
{
	return;
}

function R6EngineWeapon.eRateOfFire GetRateOfFire()
{
	return;
}

function SetHoldAttachPoint()
{
	return;
}

function UseScopeStaticMesh()
{
	return;
}

function SetTerroristNbOfClips(int iNewNumber)
{
	return;
}

function int GetNbOfClips()
{
	return;
}

function bool HasAtLeastOneFullClip()
{
	return;
}

function int GetClipCapacity()
{
	return;
}

function float GetMuzzleVelocity()
{
	return;
}

/////////////////////////
// ANIMATION FUNCTIONS //
/////////////////////////
simulated function name GetWaitAnimName()
{
	return m_PawnWaitAnimLow;
	return;
}

simulated function name GetHighWaitAnimName()
{
	return m_PawnWaitAnimHigh;
	return;
}

simulated function name GetProneWaitAnimName()
{
	return m_PawnWaitAnimProne;
	return;
}

simulated function name GetFiringAnimName()
{
	return m_PawnFiringAnim;
	return;
}

simulated function name GetProneFiringAnimName()
{
	return m_PawnFiringAnimProne;
	return;
}

simulated function name GetReloadAnimName()
{
	return m_PawnReloadAnim;
	return;
}

simulated function name GetReloadAnimTacticalName()
{
	return m_PawnReloadAnimTactical;
	return;
}

simulated function name GetProneReloadAnimName()
{
	return m_PawnReloadAnimProne;
	return;
}

simulated function name GetProneReloadAnimTacticalName()
{
	return m_PawnReloadAnimProneTactical;
	return;
}

simulated function PlayReloading()
{
	return;
}

//First Person walking animation (bobing)
simulated event PawnIsMoving()
{
	return;
}

simulated event PawnStoppedMoving()
{
	return;
}

function bool HasAmmo()
{
	return;
}

function ChangeClip()
{
	return;
}

function FullCurrentClip()
{
	return;
}

function FillClips()
{
	return;
}

function AddExtraClip()
{
	return;
}

simulated function AddClips(int iNbOfExtraClips)
{
	return;
}

function bool CanSwitchToWeapon()
{
	return;
}

function ServerStopFire(optional bool bSoundOnly)
{
	return;
}

function ClientStopFire(optional bool bSoundOnly)
{
	return;
}

function LocalStopFire(optional bool bSoundOnly)
{
	return;
}

function StopFire(optional bool bSoundOnly)
{
	return;
}

function StopAltFire()
{
	return;
}

function FullAmmo()
{
	return;
}

function PerfectAim()
{
	return;
}

event SetIdentifyTarget(bool bIdentifyCharacter, bool bFriendly, string characterName)
{
	return;
}

simulated function R6SetReticule(optional Controller LocalPlayerController)
{
	return;
}

simulated function UpdateHands()
{
	return;
}

simulated function WeaponInitialization(Pawn pawnOwner)
{
	return;
}

function StartLoopingAnims()
{
	return;
}

simulated function FirstPersonAnimOver()
{
	return;
}

function ServerPutBulletInShotgun()
{
	return;
}

function ClientAddShell()
{
	return;
}

function bool GunIsFull()
{
	return false;
	return;
}

simulated function bool GotBipod()
{
	return m_bBipod;
	return;
}

function Toggle3rdBipod(bool bBipodOpen)
{
	return;
}

//Grenade specific functions
function ThrowGrenade()
{
	return;
}

function float GetSaveDistanceToThrow()
{
	return 0.0000000;
	return;
}

// Charge specific functions
function ServerPlaceCharge(Vector vLocation)
{
	return;
}

function ServerDetonate()
{
	return;
}

function ServerPlaceChargeAnimation()
{
	return;
}

function NPCPlaceCharge(Actor aDoor)
{
	return;
}

function NPCDetonateCharge()
{
	return;
}

function GiveBulletToWeapon(string aBulletName)
{
	return;
}

function bool HasBulletType(name strBulletType)
{
	return;
}

simulated event bool IsGoggles()
{
	return false;
	return;
}

function SetHeartBeatRange(float fRange)
{
	return;
}

function WeaponZoomSound(bool bFirstZoom)
{
	return;
}

function Texture Get2DIcon()
{
	return;
}

simulated function StartFalling()
{
	return;
}

simulated function SetGadgets()
{
	return;
}

function bool AffectActor(int BulletGroup, Actor ActorAffected)
{
	return;
}

simulated function bool IsPumpShotGun()
{
	return false;
	return;
}

function bool IsSniperRifle()
{
	return __NFUN_154__(int(m_eWeaponType), int(4));
	return;
}

simulated function bool IsLMG()
{
	return __NFUN_154__(int(m_eWeaponType), int(5));
	return;
}

function bool HasScope()
{
	return;
}

function float GetExplosionDelay()
{
	return;
}

function float GetWeaponRange()
{
	return;
}

simulated event UpdateWeaponAttachment()
{
	return;
}

function SetRelevant(bool bNewAlwaysRelevant)
{
	return;
}

function SetTearOff(bool bNewTearOff)
{
	return;
}

simulated event ShowWeaponParticules(R6EngineWeapon.EWeaponSound EWeaponSound)
{
	return;
}

function SetAccuracyOnHit()
{
	return;
}

simulated function ServerShowInfo()
{
	return;
}

defaultproperties
{
	m_eGripType=7
	m_InventoryGroup=1
	m_fMaxZoom=1.5000000
	m_fFireAnimRate=1.0000000
	BobDamping=0.9600000
	m_fReloadTime=2.5000000
	m_fReloadEmptyTime=3.0000000
	m_fPauseWhenChanging=0.5000000
	RemoteRole=2
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: function GetRateOfFire
// REMOVED IN 1.60: function DisplayWeaponDGBInfo
// REMOVED IN 1.60: function ClientShowInfo
// REMOVED IN 1.60: function ShowInfo
