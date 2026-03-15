//=============================================================================
// R6EngineWeapon - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
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
	unreliable if((int(Role) < int(ROLE_Authority)))
		ServerDetonate, ServerPlaceCharge, 
		ServerPlaceChargeAnimation, ServerPutBulletInShotgun, 
		ServerShowInfo;

	// Pos:0x034
	unreliable if((int(Role) == int(ROLE_Authority)))
		WeaponZoomSound;

	// Pos:0x000
	reliable if((int(Role) < int(ROLE_Authority)))
		ServerStopFire;

	// Pos:0x00D
	reliable if((int(Role) == int(ROLE_Authority)))
		ClientStopFire, StopFire;

	// Pos:0x027
	reliable if((int(Role) == int(ROLE_Authority)))
		m_bDeployBipod, m_bUnlimitedClip, 
		m_iNbBulletsInWeapon;

	// Pos:0x041
	reliable if((bNetOwner && (int(Role) == int(ROLE_Authority))))
		m_fMaxZoom;
}

simulated function PostRender(Canvas Canvas)  // Renders weapon overlays onto the HUD canvas
{
	return;
}

simulated event DeployWeaponBipod(bool bBipodOpen)  // Deploys or retracts the weapon bipod
{
	return;
}

simulated function bool ClientFire(float Value)  // Client-side fire trigger; returns true if weapon fired
{
	return;
}

simulated function bool ClientAltFire(float Value)  // Client-side alternate fire trigger
{
	return;
}

function Fire(float Value)  // Server-side primary fire
{
	return;
}

function AltFire(float Value)  // Server-side alternate fire
{
	return;
}

simulated function bool LoadFirstPersonWeapon(optional Pawn NetOwner, optional Controller LocalPlayerController)  // Loads the first-person weapon mesh and emitters; returns false on failure
{
	return false;
	return;
}

simulated function RemoveFirstPersonWeapon()  // Removes the first-person weapon mesh from the scene
{
	return;
}

simulated function AttachEmittersToFPWeapon()  // Attaches particle emitters to the first-person weapon mesh
{
	return;
}

simulated function AttachEmittersTo3rdWeapon()  // Attaches particle emitters to the third-person weapon mesh
{
	return;
}

simulated function DisableWeaponOrGadget()  // Disables this weapon or gadget entirely
{
	return;
}

simulated function TurnOffEmitters(bool bTurnOff)  // Enables or disables all particle emitters on this weapon
{
	return;
}

function GiveMoreAmmo()  // Gives additional ammunition to this weapon
{
	return;
}

function AttachMagazine()  // Attaches the detachable magazine mesh
{
	return;
}

simulated function int NumberOfBulletsLeftInClip()  // Returns the number of rounds remaining in the current clip
{
	return;
}

function float GetCurrentMaxAngle()  // Returns the current maximum spread angle in degrees
{
	return;
}

function bool IsAtBestAccuracy()  // Returns true when the weapon is at its minimum spread angle
{
	return;
}

function float GetWeaponJump()  // Returns the recoil/jump magnitude applied per shot
{
	return;
}

exec function SetNextRateOfFire()  // Cycles to the next available rate-of-fire setting
{
	return;
}

function bool SetRateOfFire(R6EngineWeapon.eRateOfFire eNewRateOfFire)  // Sets the rate of fire; returns true on success
{
	return;
}

function R6EngineWeapon.eRateOfFire GetRateOfFire()  // Returns the current rate-of-fire setting
{
	return;
}

function SetHoldAttachPoint()  // Sets the bone attachment point used when holstering
{
	return;
}

function UseScopeStaticMesh()  // Swaps in the scoped static mesh when a scope gadget is equipped
{
	return;
}

function SetTerroristNbOfClips(int iNewNumber)  // Overrides the clip count for terrorist NPCs
{
	return;
}

function int GetNbOfClips()  // Returns the total number of spare clips
{
	return;
}

function bool HasAtLeastOneFullClip()  // Returns true if at least one completely full spare clip exists
{
	return;
}

function int GetClipCapacity()  // Returns the maximum number of rounds per clip
{
	return;
}

function float GetMuzzleVelocity()  // Returns the projectile muzzle velocity in UU/s
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

simulated function PlayReloading()  // Plays the appropriate reload animation
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

function bool HasAmmo()  // Returns true if any ammunition remains
{
	return;
}

function ChangeClip()  // Swaps the spent clip for a fresh one
{
	return;
}

function FullCurrentClip()  // Tops up the current clip to full capacity
{
	return;
}

function FillClips()  // Fills all spare clips to capacity
{
	return;
}

function AddExtraClip()  // Adds one extra clip to the reserve
{
	return;
}

simulated function AddClips(int iNbOfExtraClips)  // Adds the specified number of clips to the reserve
{
	return;
}

function bool CanSwitchToWeapon()  // Returns true if the player is currently allowed to switch to this weapon
{
	return;
}

function ServerStopFire(optional bool bSoundOnly)  // Server RPC: stops firing (bSoundOnly limits to audio only)
{
	return;
}

function ClientStopFire(optional bool bSoundOnly)  // Client RPC: stops firing on the client
{
	return;
}

function LocalStopFire(optional bool bSoundOnly)  // Stops firing on the local machine only
{
	return;
}

function StopFire(optional bool bSoundOnly)  // Stops primary fire
{
	return;
}

function StopAltFire()  // Stops alternate fire
{
	return;
}

function FullAmmo()  // Debug/cheat: fills all ammo to maximum
{
	return;
}

function PerfectAim()  // Debug/cheat: sets accuracy to perfect for next shot
{
	return;
}

event SetIdentifyTarget(bool bIdentifyCharacter, bool bFriendly, string characterName)  // Updates the target identification display on the HUD reticule
{
	return;
}

simulated function R6SetReticule(optional Controller LocalPlayerController)  // Updates the weapon reticule display for the given controller
{
	return;
}

simulated function UpdateHands()  // Refreshes the first-person hand mesh and animations
{
	return;
}

simulated function WeaponInitialization(Pawn pawnOwner)  // Initialises the weapon for the given pawn owner
{
	return;
}

function StartLoopingAnims()  // Starts any looping animations (e.g. LMG belt feed)
{
	return;
}

simulated function FirstPersonAnimOver()  // Callback: called when a first-person animation finishes
{
	return;
}

function ServerPutBulletInShotgun()  // Server RPC: chambers one shell into a pump-action shotgun
{
	return;
}

function ClientAddShell()  // Client: adds one shell to the shotgun's internal magazine
{
	return;
}

function bool GunIsFull()  // Returns true when the weapon is loaded to its maximum capacity
{
	return false;
	return;
}

simulated function bool GotBipod()  // Returns true if the weapon has a bipod attachment
{
	return m_bBipod;
	return;
}

function Toggle3rdBipod(bool bBipodOpen)  // Toggles the third-person bipod animation
{
	return;
}

//Grenade specific functions
function ThrowGrenade()  // Initiates the grenade throw sequence
{
	return;
}

function float GetSaveDistanceToThrow()  // Returns the minimum safe distance for throwing this grenade
{
	return 0.0000000;
	return;
}

// Charge specific functions
function ServerPlaceCharge(Vector vLocation)  // Server RPC: places an explosive charge at the given world location
{
	return;
}

function ServerDetonate()  // Server RPC: detonates all placed explosive charges
{
	return;
}

function ServerPlaceChargeAnimation()  // Server RPC: plays the charge placement animation without placing
{
	return;
}

function NPCPlaceCharge(Actor aDoor)  // NPC action: places a breaching charge on the specified door actor
{
	return;
}

function NPCDetonateCharge()  // NPC action: detonates the NPC's placed charge
{
	return;
}

function GiveBulletToWeapon(string aBulletName)  // Grants a specific bullet type to this weapon by class name
{
	return;
}

function bool HasBulletType(name strBulletType)  // Returns true if this weapon uses the specified bullet type
{
	return;
}

simulated event bool IsGoggles()  // Returns true if this gadget is a night/heat/scope goggle
{
	return false;
	return;
}

function SetHeartBeatRange(float fRange)  // Sets the detection range for the heartbeat sensor gadget
{
	return;
}

function WeaponZoomSound(bool bFirstZoom)  // Plays the zoom-in sound (bFirstZoom selects first or second zoom level)
{
	return;
}

function Texture Get2DIcon()  // Returns the 2D HUD icon texture for this weapon
{
	return;
}

simulated function StartFalling()  // Called when the owning pawn begins to fall
{
	return;
}

simulated function SetGadgets()  // Attaches and configures any gadget actors for this weapon
{
	return;
}

function bool AffectActor(int BulletGroup, Actor ActorAffected)  // Returns true if this weapon's bullet group can damage ActorAffected
{
	return;
}

simulated function bool IsPumpShotGun()  // Returns true if this is a pump-action shotgun
{
	return false;
	return;
}

function bool IsSniperRifle()  // Returns true if this weapon is a sniper rifle
{
	return (int(m_eWeaponType) == int(4));
	return;
}

simulated function bool IsLMG()  // Returns true if this weapon is a light machine gun
{
	return (int(m_eWeaponType) == int(5));
	return;
}

function bool HasScope()  // Returns true if a scope gadget is currently equipped
{
	return;
}

function float GetExplosionDelay()  // Returns the time in seconds before the explosive detonates
{
	return;
}

function float GetWeaponRange()  // Returns the effective engagement range in Unreal Units
{
	return;
}

simulated event UpdateWeaponAttachment()  // Refreshes visible weapon attachment (scope/silencer/light) state
{
	return;
}

function SetRelevant(bool bNewAlwaysRelevant)  // Sets whether this weapon actor is always network-relevant
{
	return;
}

function SetTearOff(bool bNewTearOff)  // Sets the tear-off replication flag on this weapon
{
	return;
}

simulated event ShowWeaponParticules(R6EngineWeapon.EWeaponSound EWeaponSound)  // Triggers particle effects corresponding to the given weapon sound event
{
	return;
}

function SetAccuracyOnHit()  // Degrades accuracy when the pawn takes a hit
{
	return;
}

simulated function ServerShowInfo()  // Debug only: logs weapon state info on the server
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
