//=============================================================================
// R6Weapons - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6Weapons.uc : Base class of all weapons
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/04/20 * Created by Aristomenis Kolokathis
//    2001/05/03 * (AK) Added bullet burst
//    2003/06/12 * Major rework to eliminate "Trigger Lag" (Olivier Rouleau)
//=============================================================================
class R6Weapons extends R6
    AbstractWeapon
    abstract
    native;

// Multiplier applied to worst-case accuracy when the owning pawn is wounded.
const AccuracyLostWhenWounded = 1.2;

struct stWeaponCaps
{
	var() int bSingle;  // caps set to 1 if weapon can fire single shots
	var() int bThreeRound;  // caps set to 1 if weapon can fire 3 bullets bursts
	var() int bFullAuto;  // caps set to 1 if weapon can fire full automatic
	var() int bCMag;  // caps set to 1 if weapon can have a CMag as gadget
	var() int bSilencer;  // caps set to 1 if weapon can have a silencer as gadget
	var() int bLight;  // caps set to 1 if weapon can have a tactical light as gadget
	var() int bMiniScope;  // caps set to 1 if weapon can have a 3.5x mini scope as gadget
	var() int bHeatVision;  // caps set to 1 if weapon can have a heat vision scope (sniper gun only)
};

struct stAccuracyType
{
	var() float fBaseAccuracy;  // Best possible accuracy
	var() float fShuffleAccuracy;  // Worst Possible Accuracy when character is looking around
	var() float fWalkingAccuracy;  // Worst Accuracy when a character is walking
	var() float fWalkingFastAccuracy;  // Worst Accuracy when a characters is walking fast(Rainbow's run)
	var() float fRunningAccuracy;  // Worst Accuracy when a characters is running (Terrorist running), worst overall accuracy
	var() float fReticuleTime;  // Number of seconds it takes to recover from the Running to the base accuracy
	var() float fAccuracyChange;  // Accuracy penalty after the character fires a bullet
	var() float fWeaponJump;  // How much the weapon jumps after each round.
};

// Per-magazine bullet counts; index matches m_iCurrentClip (max 20 magazines total).
var(R6Clip) byte m_aiNbOfBullets[20];  // Number of bullets in each magazines (The current maximum is 16 (8+4+4))
var byte m_iNbOfRoundsInBurst;  // Number of rounds shot since the trigger was pull
// eRateOfFire: 0 = single shot, 1 = three-round burst, 2 = full-auto.
var(R6Firing) R6EngineWeapon.eRateOfFire m_eRateOfFire;  // Current Rate of Fire
var byte m_wNbOfBounce;  // Location the pawn was at when the weapon start falling.  Used to find a location for the falling weapon if everything else fails.
var const int C_iMaxNbOfClips;
var(R6Clip) int m_iClipCapacity;  // Number of round per magazine
var(R6Clip) int m_iNbOfClips;  // This is the number of clip that the guns had at the beginning of the mission
var(R6Clip) int m_iNbOfExtraClips;  // Number of extra clips per EXTRA CLIP gadget
var int m_iCurrentClip;  // Active Clip Number
// Rounds remaining to fire this trigger pull (1 for semi, 3 for burst, full-mag for auto).
var int m_iNbOfRoundsToShoot;  // Number of rounds to be shoot by holding the trigger (safe = 0, Single = 1, ThreeRound = 3, FullAuto=MagazineCapacity)
var int m_iCurrentNbOfClips;  // Number of clip with at least one round in
var int m_iCurrentAverage;
var(Debug) int m_iDbgNextReticule;  // allow to cycle through all the defined reticule in dbgNextReticule
var bool m_bPlayLoopingSound;
var(Debug) bool m_bSoundLog;
var(Debug) bool bShowLog;
var bool m_bFireOn;
var bool m_bEmptyAllClips;  // when set to true, a pistol in MP can always be reloaded with 5 bullets.
var(R6GunProperties) float m_fMuzzleVelocity;  // muzzle velocity of bullet, this may affect the range of bullet, friction is negligible and bullet will travel in a straight line
var(Muzzleflash) float m_MuzzleScale;  // scaling of muzzleflash
var float m_fAverageDegChanges;
var float m_fAverageDegTable[5];
var float m_fStablePercentage;  // Accuracy improvement when you're stable
var float m_fWorstAccuracy;  // Accuracy in worst case.
var float m_fOldWorstAccuracy;  // Old value for worst accuracy, to detect if the value changed
// Smoothed accuracy value interpolated towards m_fDesiredAccuracy each tick.
var float m_fEffectiveAccuracy;  // Effective accuracy. This accuracy is compute once a tick
var float m_fDesiredAccuracy;  // Desired accuracy.
// Current half-angle error in degrees; multiplied by 91.022 to get Unreal rotator units.
var float m_fMaxAngleError;  // Angle that is set depending of the effective accuracy
var float m_fCurrentFireJump;  // 
var float m_fFireSoundRadius;  // Distance (in unit) at wich the fire is heard by the AI
// Seconds between successive rounds; e.g. 0.1 = 10 rounds/s = 600 RPM.
var(R6Firing) float m_fRateOfFire;  // Time between each rounds
var float m_fDisplayFOV;  // weapon's FOV
var(R6GunProperties) Texture m_WeaponIcon;  // icon to display weapon in the hud (must be 128x64)
var R6Reticule m_ReticuleInstance;  // instance of the reticule
var R6SFX m_pEmptyShellsEmitter;
var R6SFX m_pMuzzleFlashEmitter;
var(R6Clip) Class<R6Bullet> m_pBulletClass;  // current class spawned in the game, default bullet for terrorist.
var(R6Clip) Class<R6SFX> m_pEmptyShells;  // empty shell particule spawned when firing
var(R6Clip) Class<R6SFX> m_pMuzzleFlash;  // MuzzleFlash spawned when firing
var(R6GunProperties) stWeaponCaps m_stWeaponCaps;  // use to describe avalaible options in menus and selected options in the game
var Rotator m_rLastRotation;  // Last Pawn.Rotation.  Use to compute the delta angle
var Rotator m_rBuckFirstBullet;  // Inital direction of a buckshot shell
var(R6Firing) stAccuracyType m_stAccuracyValues;
// Variable used for falling
var Vector m_vPawnLocWhenKilled;  // Location the pawn was at when the weapon start falling.  Used to find a location for the falling weapon if everything else fails.
// NEW IN 1.60
var(R6GunProperties) string m_szReticuleClass;
// NEW IN 1.60
var(R6GunProperties) string m_szWithWeaponReticuleClass;

replication
{
	// Pos:0x000
	reliable if((int(Role) == int(ROLE_Authority)))
		ClientShowBulletFire, ClientStartChangeClip, 
		ClientStartFiring, ClientYourOwnerIs, 
		ClientsFireBullet;

	// Pos:0x00D
	reliable if((int(Role) < int(ROLE_Authority)))
		ServerAddClips, ServerChangeClip, 
		ServerFireBullet, ServerSetNextRateOfFire, 
		ServerStartChangeClip, ServerStartFiring, 
		ServerWhoIsMyOwner;

	// Pos:0x01A
	reliable if((int(Role) == int(ROLE_Authority)))
		m_eRateOfFire, m_iCurrentClip, 
		m_iCurrentNbOfClips;

	// Pos:0x027
	reliable if((bNetInitial && (int(Role) == int(ROLE_Authority))))
		m_iClipCapacity, m_pBulletClass;
}

simulated event HideAttachment()
{
	return;
}

function bool HasScope()
{
	return (m_fMaxZoom > 2.0000000);
	return;
}

simulated function UseScopeStaticMesh()
{
	// End:0x16
	if((m_WithScopeSM != none))
	{
		SetStaticMesh(m_WithScopeSM);
	}
	return;
}

simulated function SpawnSelectedGadget()
{
	// End:0x55
	if((int(m_WeaponGadgetClass.default.m_eGadgetType) == int(5)))
	{
		// End:0x37
		if((m_MuzzleGadget != none))
		{
			m_MuzzleGadget.Destroy();
			m_MuzzleGadget = none;
		}
		R6SetGadget(Class<R6AbstractGadget>(DynamicLoadObject(m_szSilencerClass, Class'Core.Class')));		
	}
	else
	{
		// End:0x98
		if((int(m_WeaponGadgetClass.default.m_eGadgetType) == int(6)))
		{
			// End:0x95
			if((m_szTacticalLightClass != ""))
			{
				R6SetGadget(Class<R6AbstractGadget>(DynamicLoadObject(m_szTacticalLightClass, Class'Core.Class')));
			}			
		}
		else
		{
			R6SetGadget(m_WeaponGadgetClass);
		}
	}
	return;
}

simulated function SetGadgets()
{
	// End:0xC7
	if((int(Level.NetMode) != int(NM_Client)))
	{
		// End:0xC7
		if((m_WeaponGadgetClass != none))
		{
			// End:0x79
			if((int(m_WeaponGadgetClass.default.m_eGadgetType) == int(5)))
			{
				// End:0x5B
				if((m_MuzzleGadget != none))
				{
					m_MuzzleGadget.Destroy();
					m_MuzzleGadget = none;
				}
				R6SetGadget(Class<R6AbstractGadget>(DynamicLoadObject(m_szSilencerClass, Class'Core.Class')));				
			}
			else
			{
				// End:0xBC
				if((int(m_WeaponGadgetClass.default.m_eGadgetType) == int(6)))
				{
					// End:0xB9
					if((m_szTacticalLightClass != ""))
					{
						R6SetGadget(Class<R6AbstractGadget>(DynamicLoadObject(m_szTacticalLightClass, Class'Core.Class')));
					}					
				}
				else
				{
					R6SetGadget(m_WeaponGadgetClass);
				}
			}
		}
	}
	// End:0x235
	if((m_InventoryGroup == 1))
	{
		// End:0xFC
		if((m_szMagazineClass != ""))
		{
			R6SetGadget(Class<R6AbstractGadget>(DynamicLoadObject(m_szMagazineClass, Class'Core.Class')));			
		}
		else
		{
			m_MagazineGadget = none;
		}
		// End:0x20B
		if(GotBipod())
		{
			// End:0x1D6
			if(IsA('R6SniperRifle'))
			{
				// End:0x167
				if(Owner.IsA('R6Rainbow'))
				{
					R6SetGadget(Class<R6AbstractGadget>(DynamicLoadObject("R6WeaponGadgets.R63rdRainbowScope", Class'Core.Class')));					
				}
				else
				{
					R6SetGadget(Class<R6AbstractGadget>(DynamicLoadObject("R6WeaponGadgets.R6ScopeGadget", Class'Core.Class')));
				}
				R6SetGadget(Class<R6AbstractGadget>(DynamicLoadObject("R6WeaponGadgets.R63rdSnipeBipod", Class'Core.Class')));				
			}
			else
			{
				R6SetGadget(Class<R6AbstractGadget>(DynamicLoadObject("R6WeaponGadgets.R63rdLMGBipod", Class'Core.Class')));
			}
		}
		// End:0x232
		if((m_szMuzzleClass != ""))
		{
			R6SetGadget(Class<R6AbstractGadget>(DynamicLoadObject(m_szMuzzleClass, Class'Core.Class')));
		}		
	}
	else
	{
		// End:0x283
		if((m_InventoryGroup == 2))
		{
			R6SetGadget(Class<R6AbstractGadget>(DynamicLoadObject(m_szMagazineClass, Class'Core.Class')));
			// End:0x283
			if((m_szMuzzleClass != ""))
			{
				R6SetGadget(Class<R6AbstractGadget>(DynamicLoadObject(m_szMuzzleClass, Class'Core.Class')));
			}
		}
	}
	return;
}

simulated event Destroyed()
{
	// End:0x2F
	if(((R6Pawn(Owner) != none) && R6Pawn(Owner).m_bIsPlayer))
	{
		RemoveFirstPersonWeapon();
	}
	// End:0x4D
	if((m_pMuzzleFlashEmitter != none))
	{
		m_pMuzzleFlashEmitter.Destroy();
		m_pMuzzleFlashEmitter = none;
	}
	// End:0x6B
	if((m_pEmptyShellsEmitter != none))
	{
		m_pEmptyShellsEmitter.Destroy();
		m_pEmptyShellsEmitter = none;
	}
	// End:0x89
	if((m_SelectedWeaponGadget != none))
	{
		m_SelectedWeaponGadget.Destroy();
		m_SelectedWeaponGadget = none;
	}
	// End:0xA7
	if((m_MuzzleGadget != none))
	{
		m_MuzzleGadget.Destroy();
		m_MuzzleGadget = none;
	}
	// End:0xC5
	if((m_ScopeGadget != none))
	{
		m_ScopeGadget.Destroy();
		m_ScopeGadget = none;
	}
	// End:0xE3
	if((m_BipodGadget != none))
	{
		m_BipodGadget.Destroy();
		m_BipodGadget = none;
	}
	// End:0x101
	if((m_MagazineGadget != none))
	{
		m_MagazineGadget.Destroy();
		m_MagazineGadget = none;
	}
	// End:0x11F
	if((m_FPWeapon != none))
	{
		m_FPWeapon.Destroy();
		m_FPWeapon = none;
	}
	super(Actor).Destroyed();
	return;
}

////////////////////////////////////////////////////////////////////////////
// WEAPON INITIALISATION                                                  //
////////////////////////////////////////////////////////////////////////////
// Do not put the PostBeginPlay Simulated because in MultiPlayer when the //
// weapon become relevant the nb of bullet it reset to the clip capacity  //
////////////////////////////////////////////////////////////////////////////
simulated function PostBeginPlay()
{
	super(Actor).PostBeginPlay();
	FillClips();
	// End:0x3F
	if(((int(Level.NetMode) != int(NM_Standalone)) && (int(m_eWeaponType) == int(0))))
	{
		m_bUnlimitedClip = true;
	}
	m_fEffectiveAccuracy = m_stAccuracyValues.fBaseAccuracy;
	m_fDesiredAccuracy = m_stAccuracyValues.fBaseAccuracy;
	m_fWorstAccuracy = m_stAccuracyValues.fBaseAccuracy;
	return;
}

// Fills all magazine slots to capacity at mission start.
simulated function FillClips()
{
	local int i;

	m_iCurrentNbOfClips = m_iNbOfClips;
	// End:0x24
	if(IsPumpShotGun())
	{
		m_iNbBulletsInWeapon = byte(m_iClipCapacity);		
	}
	else
	{
		m_iNbBulletsInWeapon = byte(m_iClipCapacity);
		i = 0;
		J0x38:

		// End:0x64 [Loop If]
		if((i < m_iNbOfClips))
		{
			m_aiNbOfBullets[i] = byte(m_iClipCapacity);
			(i++);
			// [Loop Continue]
			goto J0x38;
		}
		// Non-LMG primary weapons get one extra round chambered on top of the first magazine.
		// End:0x85
		if(((!IsLMG()) && (!IsA('R6Gadget'))))
		{
			(m_iNbBulletsInWeapon++);
		}
	}
	return;
}

function float GetWeaponRange()
{
	return m_pBulletClass.default.m_fRange;
	return;
}

function float GetWeaponJump()
{
	return m_stAccuracyValues.fWeaponJump;
	return;
}

event SetIdentifyTarget(bool bIdentifyCharacter, bool bFriendly, string characterName)
{
	local R6GameOptions GameOptions;

	// End:0x8F
	if((m_ReticuleInstance != none))
	{
		GameOptions = GetGameOptions();
		m_ReticuleInstance.m_bIdentifyCharacter = (bIdentifyCharacter && (GameOptions.HUDShowPlayersName || R6PlayerController(Pawn(Owner).Controller).m_bShowCompleteHUD));
		m_ReticuleInstance.m_CharacterName = characterName;
		m_ReticuleInstance.m_bAimingAtFriendly = bFriendly;
	}
	return;
}

// this sets the reticule instance
simulated function R6SetReticule(optional Controller LocalPlayerController)
{
	local Class<Actor> ReticuleToSpawn;
	local R6GameOptions GameOptions;
	local R6PlayerController pPlayerCtrl;

	// End:0x1D4
	if(Owner.IsA('R6Rainbow'))
	{
		// End:0x1D4
		if((m_szReticuleClass != ""))
		{
			// End:0x3E
			if((LocalPlayerController != none))
			{
				pPlayerCtrl = R6PlayerController(LocalPlayerController);				
			}
			else
			{
				pPlayerCtrl = R6PlayerController(Pawn(Owner).Controller);
			}
			// End:0x7A
			if((m_ReticuleInstance != none))
			{
				m_ReticuleInstance.Destroy();
				m_ReticuleInstance = none;
			}
			GameOptions = Class'Engine.Actor'.static.GetGameOptions();
			ReticuleToSpawn = Class'Engine.Actor'.static.GetModMgr().GetCurrentReticule(m_szWithWeaponReticuleClass);
			// End:0x162
			if((((int(m_eWeaponType) == int(6)) || (int(m_eWeaponType) == int(7))) || ((GameOptions.HUDShowFPWeapon == false) && ((int(Level.NetMode) == int(NM_Standalone)) || ((R6GameReplicationInfo(pPlayerCtrl.GameReplicationInfo) != none) && (R6GameReplicationInfo(pPlayerCtrl.GameReplicationInfo).m_bFFPWeapon == false))))))
			{
				ReticuleToSpawn = Class'Engine.Actor'.static.GetModMgr().GetCurrentReticule(m_szReticuleClass);
			}
			m_ReticuleInstance = R6Reticule(Spawn(ReticuleToSpawn, Owner));
			// End:0x1A7
			if((int(Level.NetMode) == int(NM_Standalone)))
			{
				m_ReticuleInstance.m_bShowNames = true;				
			}
			else
			{
				m_ReticuleInstance.m_bShowNames = R6GameReplicationInfo(pPlayerCtrl.GameReplicationInfo).m_bShowNames;
			}
		}
	}
	return;
}

function ServerWhoIsMyOwner()
{
	ClientYourOwnerIs(Owner);
	return;
}

function ClientYourOwnerIs(Actor OwnerFromServer)
{
	// End:0x13
	if((OwnerFromServer == none))
	{
		ServerWhoIsMyOwner();
		return;
	}
	SetOwner(OwnerFromServer);
	LoadFirstPersonWeapon();
	// End:0x59
	if((R6Pawn(Owner).m_bChangingWeapon == true))
	{
		// End:0x4F
		if(IsInState('RaiseWeapon'))
		{
			BeginState();			
		}
		else
		{
			GotoState('RaiseWeapon');
		}		
	}
	else
	{
		StartLoopingAnims();
	}
	return;
}

//Spawn the FP weapon class and attach it to the Hands
simulated function bool LoadFirstPersonWeapon(optional Pawn NetOwner, optional Controller LocalPlayerController)
{
	// End:0x181
	if(((((m_pFPWeaponClass != none) && (m_pFPHandsClass != none)) && (m_FPHands == none)) && (m_FPWeapon == none)))
	{
		// End:0x48
		if((NetOwner != none))
		{
			SetOwner(NetOwner);			
		}
		else
		{
			// End:0x5B
			if((Owner == none))
			{
				ServerWhoIsMyOwner();
				return false;
			}
		}
		m_FPHands = Spawn(m_pFPHandsClass, self);
		// End:0xA5
		if(Owner.IsA('R6Rainbow'))
		{
			m_FPHands.Skins[0] = R6Rainbow(Owner).Skins[5];
		}
		m_FPWeapon = Spawn(m_pFPWeaponClass, self);
		R6AbstractFirstPersonHands(m_FPHands).SetAssociatedWeapon(m_FPWeapon);
		// End:0x17E
		if(((m_FPWeapon != none) && (m_FPHands != none)))
		{
			// End:0x10E
			if((NumberOfBulletsLeftInClip() == 0))
			{
				m_FPWeapon.m_WeaponNeutralAnim = m_FPWeapon.m_Empty;
			}
			// End:0x128
			if((m_SelectedWeaponGadget != none))
			{
				m_SelectedWeaponGadget.AttachFPGadget();
			}
			// End:0x142
			if((m_MuzzleGadget != none))
			{
				m_MuzzleGadget.AttachFPGadget();
			}
			AttachEmittersToFPWeapon();
			m_FPWeapon.PlayAnim(m_FPWeapon.m_WeaponNeutralAnim);
			m_FPHands.AttachToBone(m_FPWeapon, 'B_R_Wrist_A');			
		}		
	}
	R6SetReticule(LocalPlayerController);
	return true;
	return;
}

simulated function AttachEmittersToFPWeapon()
{
	// End:0x7A
	if((m_pMuzzleFlashEmitter != none))
	{
		m_pMuzzleFlashEmitter.m_bDrawFromBase = false;
		m_pMuzzleFlashEmitter.SetBase(none);
		m_FPWeapon.AttachToBone(m_pMuzzleFlashEmitter, 'TagMuzzle');
		m_pMuzzleFlashEmitter.SetRelativeLocation(vect(0.0000000, 0.0000000, 0.0000000));
		m_pMuzzleFlashEmitter.SetRelativeRotation(rot(0, 0, 0));
	}
	// End:0x151
	if((m_pEmptyShellsEmitter != none))
	{
		m_pEmptyShellsEmitter.m_bDrawFromBase = false;
		m_pEmptyShellsEmitter.SetBase(none);
		m_FPWeapon.AttachToBone(m_pEmptyShellsEmitter, 'TagCase');
		m_pEmptyShellsEmitter.SetRelativeLocation(vect(0.0000000, 0.0000000, 0.0000000));
		m_pEmptyShellsEmitter.SetRelativeRotation(rot(0, 0, 0));
		// End:0x151
		if((m_pEmptyShellsEmitter.Emitters.Length > 0))
		{
			m_pEmptyShellsEmitter.Emitters[0].LifetimeRange.Min = 0.3000000;
			m_pEmptyShellsEmitter.Emitters[0].LifetimeRange.Max = 0.3000000;
		}
	}
	return;
}

simulated function AttachEmittersTo3rdWeapon()
{
	local Vector vTagLocation;
	local Rotator rTagRotator;

	// End:0xBB
	if((m_pMuzzleFlashEmitter != none))
	{
		GetTagInformations("TAGMuzzle", vTagLocation, rTagRotator);
		// End:0x44
		if((m_SelectedWeaponGadget != none))
		{
			(vTagLocation += m_SelectedWeaponGadget.GetGadgetMuzzleOffset());
		}
		// End:0x63
		if((m_FPWeapon != none))
		{
			m_FPWeapon.DetachFromBone(m_pMuzzleFlashEmitter);
		}
		m_pMuzzleFlashEmitter.m_bDrawFromBase = true;
		m_pMuzzleFlashEmitter.SetBase(none);
		m_pMuzzleFlashEmitter.SetBase(self, Location);
		m_pMuzzleFlashEmitter.SetRelativeLocation(vTagLocation);
		m_pMuzzleFlashEmitter.SetRelativeRotation(rTagRotator);
	}
	// End:0x1B0
	if((m_pEmptyShellsEmitter != none))
	{
		GetTagInformations("TagCase", vTagLocation, rTagRotator);
		// End:0xFB
		if((m_FPWeapon != none))
		{
			m_FPWeapon.DetachFromBone(m_pEmptyShellsEmitter);
		}
		m_pEmptyShellsEmitter.m_bDrawFromBase = true;
		m_pEmptyShellsEmitter.SetBase(none);
		m_pEmptyShellsEmitter.SetBase(self, Location);
		m_pEmptyShellsEmitter.SetRelativeLocation(vTagLocation);
		m_pEmptyShellsEmitter.SetRelativeRotation(rTagRotator);
		// End:0x1B0
		if((m_pEmptyShellsEmitter.Emitters.Length > 0))
		{
			m_pEmptyShellsEmitter.Emitters[0].LifetimeRange.Min = 4.0000000;
			m_pEmptyShellsEmitter.Emitters[0].LifetimeRange.Max = 4.0000000;
		}
	}
	return;
}

simulated event PawnIsMoving()
{
	m_bPawnIsWalking = true;
	m_FPHands.PlayWalkingAnimation();
	return;
}

simulated event PawnStoppedMoving()
{
	m_bPawnIsWalking = false;
	m_FPHands.StopWalkingAnimation();
	return;
}

//When changing charter, this is to start playing the wait animations.
function StartLoopingAnims()
{
	// End:0x4B
	if((m_FPHands != none))
	{
		m_FPHands.SetDrawType(2);
		m_FPHands.GotoState('Waiting');
		m_FPHands.PlayAnim(R6AbstractFirstPersonHands(m_FPHands).m_WaitAnim1);
	}
	GotoState('None');
	R6Pawn(Owner).m_bReloadingWeapon = false;
	R6Pawn(Owner).m_bPawnIsReloading = false;
	R6Pawn(Owner).m_bWeaponTransition = false;
	R6Pawn(Owner).m_fWeaponJump = m_stAccuracyValues.fWeaponJump;
	R6Pawn(Owner).m_fZoomJumpReturn = 1.0000000;
	return;
}

//Delete the first person weapon.  To keep only one in memory
simulated function RemoveFirstPersonWeapon()
{
	local Actor temp;

	// End:0x29
	if((m_FPHands != none))
	{
		temp = m_FPHands;
		m_FPHands = none;
		temp.Destroy();
	}
	UpdateAllAttachments();
	AttachEmittersTo3rdWeapon();
	// End:0x6D
	if((m_FPWeapon != none))
	{
		m_FPWeapon.DestroySM();
		temp = m_FPWeapon;
		m_FPWeapon = none;
		temp.Destroy();
	}
	// End:0x96
	if((m_ReticuleInstance != none))
	{
		temp = m_ReticuleInstance;
		m_ReticuleInstance = none;
		temp.Destroy();
	}
	// End:0xB0
	if((m_SelectedWeaponGadget != none))
	{
		m_SelectedWeaponGadget.DestroyFPGadget();
	}
	// End:0xCA
	if((m_MuzzleGadget != none))
	{
		m_MuzzleGadget.DestroyFPGadget();
	}
	return;
}

simulated function UpdateAllAttachments()
{
	// End:0x1B
	if((m_SelectedWeaponGadget != none))
	{
		m_SelectedWeaponGadget.UpdateAttachment(self);
	}
	// End:0x36
	if((m_ScopeGadget != none))
	{
		m_ScopeGadget.UpdateAttachment(self);
	}
	// End:0x51
	if((m_MagazineGadget != none))
	{
		m_MagazineGadget.UpdateAttachment(self);
	}
	// End:0x6C
	if((m_BipodGadget != none))
	{
		m_BipodGadget.UpdateAttachment(self);
	}
	// End:0x87
	if((m_MuzzleGadget != none))
	{
		m_MuzzleGadget.UpdateAttachment(self);
	}
	return;
}

simulated function TurnOffEmitters(bool bTurnOff)
{
	// End:0x21
	if((m_pEmptyShellsEmitter != none))
	{
		m_pEmptyShellsEmitter.bHidden = bTurnOff;
	}
	// End:0x42
	if((m_pMuzzleFlashEmitter != none))
	{
		m_pMuzzleFlashEmitter.bHidden = bTurnOff;
	}
	return;
}

function ReloadShotGun()
{
	return;
}

// Cycles through available fire modes in order: full-auto → burst → semi, wrapping around.
////////////////////////////
// RATE OF FIRE FUNCTIONS //
////////////////////////////
exec function SetNextRateOfFire()
{
	Owner.PlaySound(m_ChangeROFSnd, 2);
	ServerSetNextRateOfFire();
	return;
}

exec function ServerSetNextRateOfFire()
{
	switch(m_eRateOfFire)
	{
		// End:0x24
		case 2:
			// End:0x21
			if((!SetRateOfFire(0)))
			{
				SetRateOfFire(1);
			}
			// End:0x61
			break;
		// End:0x41
		case 1:
			// End:0x3E
			if((!SetRateOfFire(2)))
			{
				SetRateOfFire(0);
			}
			// End:0x61
			break;
		// End:0x5E
		case 0:
			// End:0x5B
			if((!SetRateOfFire(1)))
			{
				SetRateOfFire(2);
			}
			// End:0x61
			break;
		// End:0xFFFF
		default:
			break;
	}
	return;
}

//Change the rate fo fire to a valid one, called by ServerSetNextRateOfFire
function bool SetRateOfFire(R6EngineWeapon.eRateOfFire eNewRateOfFire)
{
	// End:0x2D
	if(((m_stWeaponCaps.bFullAuto == 1) && (int(eNewRateOfFire) == int(2))))
	{
		m_eRateOfFire = 2;		
	}
	else
	{
		// End:0x5A
		if(((m_stWeaponCaps.bThreeRound == 1) && (int(eNewRateOfFire) == int(1))))
		{
			m_eRateOfFire = 1;			
		}
		else
		{
			// End:0x87
			if(((m_stWeaponCaps.bSingle == 1) && (int(eNewRateOfFire) == int(0))))
			{
				m_eRateOfFire = 0;				
			}
			else
			{
				return false;
			}
		}
	}
	return true;
	return;
}

function R6EngineWeapon.eRateOfFire GetRateOfFire()
{
	return m_eRateOfFire;
	return;
}

// Returns the number of rounds that will fire for the current trigger pull based on fire mode.
function int GetNbOfRoundsForROF()
{
	// End:0x12
	if((int(m_iNbBulletsInWeapon) <= 0))
	{
		return 0;		
	}
	else
	{
		switch(m_eRateOfFire)
		{
			// End:0x26
			case 2:
				return int(m_iNbBulletsInWeapon);
			// Burst fires at most 3 rounds, capped by bullets remaining.
			// End:0x37
			case 1:
				return Min(3, int(m_iNbBulletsInWeapon));
			// End:0x3E
			case 0:
				return 1;
			// End:0xFFFF
			default:
				break;
			}
	}
	return;
}

////////////////////////////////
// CLIPS MANAGEMENT FUNCTIONS //
////////////////////////////////
simulated function AddExtraClip()
{
	AddClips(m_iNbOfExtraClips);
	return;
}

simulated function ServerAddClips()
{
	AddClips(m_iNbOfExtraClips);
	return;
}

// Appends extra magazines to the array; used when the player picks up a CMag gadget.
//Called on server and client
simulated function AddClips(int iNbOfExtraClips)
{
	local int i, iNewClipCount;

	i = m_iNbOfClips;
	J0x0B:

	// End:0x57 [Loop If]
	if((i < (m_iNbOfClips + iNbOfExtraClips)))
	{
		// End:0x4D
		if(((m_iNbOfClips + 1) < C_iMaxNbOfClips))
		{
			m_aiNbOfBullets[i] = byte(m_iClipCapacity);
			(iNewClipCount++);
		}
		(i++);
		// [Loop Continue]
		goto J0x0B;
	}
	(m_iNbOfClips += iNewClipCount);
	(m_iCurrentNbOfClips += iNewClipCount);
	// End:0x8E
	if((int(Level.NetMode) == int(NM_Client)))
	{
		ServerAddClips();
	}
	return;
}

//Overloaded from R6AbstractWeapons
function SetTerroristNbOfClips(int iNewNumber)
{
	m_iCurrentNbOfClips = iNewNumber;
	m_bEmptyAllClips = true;
	return;
}

function int GetNbOfClips()
{
	return m_iCurrentNbOfClips;
	return;
}

function bool HasAtLeastOneFullClip()
{
	local int i;

	// End:0x2B
	if((IsPumpShotGun() == true))
	{
		// End:0x28
		if((float(m_iNbBulletsInWeapon) < (float(m_iClipCapacity) * 0.5000000)))
		{
			return true;
		}		
	}
	else
	{
		i = 0;
		J0x32:

		// End:0x64 [Loop If]
		if((i < m_iNbOfClips))
		{
			// End:0x5A
			if((int(m_aiNbOfBullets[i]) == m_iClipCapacity))
			{
				return true;
			}
			(i++);
			// [Loop Continue]
			goto J0x32;
		}
	}
	return false;
	return;
}

//Overloaded from R6AbstractWeapons
function float GetCurrentMaxAngle()
{
	return m_fMaxAngleError;
	return;
}

//Overloaded from R6AbstractWeapons
function bool IsAtBestAccuracy()
{
	return (m_fMaxAngleError <= m_stAccuracyValues.fBaseAccuracy);
	return;
}

simulated function WeaponInitialization(Pawn pawnOwner)
{
	// End:0x1B
	if((int(Level.NetMode) == int(NM_DedicatedServer)))
	{
		return;
	}
	CreateWeaponEmitters();
	// End:0xBD
	if((default.m_NameID != ""))
	{
		// End:0x6B
		if(IsA('R6Gadget'))
		{
			m_WeaponDesc = Localize(m_NameID, "ID_NAME", "R6Gadgets");
			m_WeaponShortName = m_WeaponDesc;			
		}
		else
		{
			m_WeaponDesc = Localize(m_NameID, "ID_NAME", "R6Weapons");
			m_WeaponShortName = Localize(m_NameID, "ID_SHORTNAME", "R6Weapons");
		}		
	}
	else
	{
		m_WeaponDesc = "No Name Set";
	}
	return;
}

simulated function CreateWeaponEmitters()
{
	// End:0xCA
	if(((m_pMuzzleFlashEmitter == none) && (m_pMuzzleFlash != none)))
	{
		m_pMuzzleFlashEmitter = Spawn(m_pMuzzleFlash);
		// End:0xCA
		if(((m_pMuzzleFlashEmitter != none) && (m_pMuzzleFlashEmitter.Emitters.Length > 4)))
		{
			(m_pMuzzleFlashEmitter.Emitters[4].StartSizeRange.X.Min *= m_MuzzleScale);
			(m_pMuzzleFlashEmitter.Emitters[4].StartSizeRange.X.Max *= m_MuzzleScale);
			// End:0xCA
			if((m_FPMuzzleFlashTexture != none))
			{
				m_pMuzzleFlashEmitter.Emitters[4].Texture = m_FPMuzzleFlashTexture;
			}
		}
	}
	// End:0xF0
	if(((m_pEmptyShellsEmitter == none) && (m_pEmptyShells != none)))
	{
		m_pEmptyShellsEmitter = Spawn(m_pEmptyShells);
	}
	AttachEmittersTo3rdWeapon();
	return;
}

//////////////////////
// FIRING DIRECTION //
//////////////////////
function GetFiringDirection(out Vector vOrigin, out Rotator rRotation, optional int iBulletNumber)
{
	local float fMaxAngleError, fRandValueOne, fRandValueTwo, fMaxError;
	local R6PlayerController PlayerOwner;
	local R6Pawn pawnOwner;

	pawnOwner = R6Pawn(Owner);
	PlayerOwner = R6PlayerController(pawnOwner.Controller);
	vOrigin = pawnOwner.GetFiringStartPoint();
	// End:0x7F
	if(((PlayerOwner != none) && (PlayerOwner.m_targetedPawn != none)))
	{
		rRotation = Rotator((PlayerOwner.m_vAutoAimTarget - vOrigin));		
	}
	else
	{
		rRotation = pawnOwner.GetFiringRotation();
	}
	// Only the first pellet/bullet (iBulletNumber == 0) applies fresh random spread.
	// End:0x1A2
	if((iBulletNumber == 0))
	{
		// Convert accuracy (degrees) to Unreal rotator units: 65536 / 720 ≈ 91.022 units per degree.
		fMaxError = (m_fMaxAngleError * 91.0220000);
		fRandValueOne = (((FRand() * float(2)) * fMaxError) - fMaxError);
		fRandValueTwo = (((FRand() * float(2)) * fMaxError) - fMaxError);
		(rRotation.Pitch += int(fRandValueOne));
		(rRotation.Yaw += int(fRandValueTwo));
		// End:0x149
		if((int(m_eWeaponType) == int(3)))
		{
			m_rBuckFirstBullet.Pitch = rRotation.Pitch;
			m_rBuckFirstBullet.Yaw = rRotation.Yaw;
		}
		// End:0x19F
		if((PlayerOwner != none))
		{
			PlayerOwner.m_rLastBulletDirection.Pitch = int(fRandValueOne);
			PlayerOwner.m_rLastBulletDirection.Yaw = int(fRandValueTwo);
			PlayerOwner.m_rLastBulletDirection.Roll = 1;
		}		
	}
	else
	{
		// Subsequent buckshot pellets scatter ±275 rotator units (~1.5°) around the first pellet.
		rRotation.Pitch = int((float(m_rBuckFirstBullet.Pitch) + ((FRand() * float(550)) - float(275))));
		rRotation.Yaw = int((float(m_rBuckFirstBullet.Yaw) + ((FRand() * float(550)) - float(275))));
	}
	return;
}

simulated event RenderOverlays(Canvas Canvas)
{
	local R6PlayerController thePlayerController;
	local Rotator rNewRotation;

	// End:0x17
	if((Level.m_bInGamePlanningActive == true))
	{
		return;
	}
	// End:0x3F
	if(((Owner == none) || (Pawn(Owner).Controller == none)))
	{
		return;
	}
	thePlayerController = R6PlayerController(Pawn(Owner).Controller);
	// End:0x128
	if((thePlayerController != none))
	{
		// End:0x128
		if(((thePlayerController.bBehindView == false) && (thePlayerController.m_bUseFirstPersonWeapon == true)))
		{
			// End:0x128
			if((m_FPHands != none))
			{
				m_FPHands.SetLocation(R6Pawn(Owner).R6CalcDrawLocation(self, rNewRotation, m_vPositionOffset));
				m_FPHands.SetRotation(((Pawn(Owner).GetViewRotation() + rNewRotation) + thePlayerController.m_rHitRotation));
				// End:0x128
				if(thePlayerController.ShouldDrawWeapon())
				{
					Canvas.DrawActor(m_FPHands, false, true);
				}
			}
		}
	}
	return;
}

simulated function PostRender(Canvas Canvas)
{
	local R6PlayerController aPC;

	// End:0x24
	if(((Level.m_bInGamePlanningActive == true) || (Owner == none)))
	{
		return;
	}
	aPC = R6PlayerController(Pawn(Owner).Controller);
	// End:0x10A
	if((((aPC != none) && (m_ReticuleInstance != none)) && (!aPC.bBehindView)))
	{
		m_ReticuleInstance.SetReticuleInfo(Canvas);
		// End:0xBC
		if((GetGameOptions().HUDShowPlayersName || aPC.m_bShowCompleteHUD))
		{
			m_ReticuleInstance.SetIdentificationReticule(Canvas);
		}
		// End:0x10A
		if(((GetGameOptions().HUDShowReticule || aPC.m_bShowCompleteHUD) && (!aPC.m_bHideReticule)))
		{
			m_ReticuleInstance.PostRender(Canvas);
		}
	}
	return;
}

// FiringSpeed is used in UW as the rate parameter in playanim.
function Fire(float fValue)
{
	GotoState('NormalFire');
	return;
}

function ClientStartFiring()
{
	// End:0x49
	if((((m_iNbOfRoundsToShoot == 0) && (int(m_iNbOfRoundsInBurst) == 0)) && R6Pawn(Owner).m_bIsPlayer))
	{
		R6Pawn(Owner).PlayLocalWeaponSound(2);
	}
	// End:0x6A
	if((int(Level.NetMode) == int(NM_Client)))
	{
		m_iNbOfRoundsInBurst = 0;
	}
	return;
}

// Server-side: sets the round count for this burst/auto spray and plays weapon sound.
function ServerStartFiring()
{
	m_iNbOfRoundsToShoot = GetNbOfRoundsForROF();
	// End:0x3C
	if(((m_iNbOfRoundsToShoot == 0) && (int(m_iNbOfRoundsInBurst) == 0)))
	{
		R6Pawn(Owner).PlayWeaponSound(2);
	}
	m_iNbOfRoundsInBurst = 0;
	// End:0x8F
	if(((R6PlayerController(Pawn(Owner).Controller) == none) || R6PlayerController(Pawn(Owner).Controller).m_bWantTriggerLag))
	{
		ClientStartFiring();
	}
	return;
}

//Added when trigger lag became an option, non-replicated version of StopFire
function LocalStopFire(optional bool bSoundOnly)
{
	// End:0x5A
	if((R6PlayerController(Pawn(Owner).Controller) != none))
	{
		// End:0x4B
		if((!R6PlayerController(Pawn(Owner).Controller).m_bWantTriggerLag))
		{
			ClientStopFire();
		}
		ServerStopFire(bSoundOnly);		
	}
	else
	{
		ServerStopFire(bSoundOnly);
	}
	return;
}

//Originally called when the fire button is released, not automacially anymore, see Timer()
//Never call directly.  Allways use localstopfire() instead.  Since trigger lag became an option.
// Plays stop-fire sound and relays to ClientStopFire; never call directly — use LocalStopFire.
function ServerStopFire(optional bool bSoundOnly)
{
	// End:0x46
	if((((int(m_iNbOfRoundsInBurst) < 3) && (int(m_eRateOfFire) != int(0))) || (int(m_iNbOfRoundsInBurst) >= 3)))
	{
		R6Pawn(Owner).PlayWeaponSound(10);
	}
	// End:0x97
	if(((R6PlayerController(Pawn(Owner).Controller) == none) || R6PlayerController(Pawn(Owner).Controller).m_bWantTriggerLag))
	{
		ClientStopFire(bSoundOnly);
	}
	return;
}

//Was simply called StopFire() in the past
function ClientStopFire(optional bool bSoundOnly)
{
	// End:0x46
	if((((int(m_iNbOfRoundsInBurst) < 3) && (int(m_eRateOfFire) != int(0))) || (int(m_iNbOfRoundsInBurst) >= 3)))
	{
		R6Pawn(Owner).PlayLocalWeaponSound(10);
	}
	// End:0x104
	if((!bSoundOnly))
	{
		// End:0xE9
		if((m_FPHands != none))
		{
			// End:0xA7
			if((int(m_iNbOfRoundsInBurst) < 3))
			{
				// End:0x95
				if((int(Level.NetMode) != int(NM_Standalone)))
				{
					m_FPHands.StopFiring();					
				}
				else
				{
					m_FPHands.InterruptFiring();
				}				
			}
			else
			{
				// End:0xE6
				if(((int(m_iNbOfRoundsInBurst) > 3) || ((int(m_iNbOfRoundsInBurst) == 3) && (int(m_eRateOfFire) != int(1)))))
				{
					m_FPHands.StopFiring();
				}
			}			
		}
		else
		{
			GotoState('None');
		}
		R6Pawn(Owner).PlayWeaponAnimation();
	}
	return;
}

//This function is used to send ClientStopFire() to the client immediatly after the bullet-fire-order 
//has been sent to the server without having to wait for server response.
function StopFire(optional bool bSoundOnly)
{
	LocalStopFire(bSoundOnly);
	return;
}

simulated function bool HasAmmo()
{
	return ((int(m_iNbBulletsInWeapon) > 0) || (m_iCurrentNbOfClips > 1));
	return;
}

simulated function int NumberOfBulletsLeftInClip()
{
	return int(m_iNbBulletsInWeapon);
	return;
}

function int GetClipCapacity()
{
	return m_iClipCapacity;
	return;
}

simulated function bool GunIsFull()
{
	return (int(m_iNbBulletsInWeapon) >= m_iClipCapacity);
	return;
}

function float GetMuzzleVelocity()
{
	return m_fMuzzleVelocity;
	return;
}

// For Raven Shield weapons, AltFire will activate the gadget
simulated function bool ClientAltFire(float fValue)
{
	R6Pawn(Owner).ToggleGadget();
	return true;
	return;
}

function R6AbstractBulletManager GetBulletManager()
{
	local R6Pawn pOwner;

	pOwner = R6Pawn(Owner);
	// End:0x2A
	if((pOwner != none))
	{
		return pOwner.m_pBulletManager;
	}
	return;
}

// For MacArthur weapons, AltFire will activate the gadget and roll grenades.
// Still don't know what Value is used for?
simulated function AltFire(float fValue)
{
	ClientAltFire(fValue);
	return;
}

// Authority-side bullet simulation: decrements ammo, spawns bullets, plays sounds, accumulates recoil.
function ServerFireBullet(float fMaxAngleErrorFromClient)
{
	local Vector vStartTrace;
	local Rotator rBulletRot;
	local int iCurrentBullet;
	local R6Pawn pawnOwner;
	local R6AbstractBulletManager BulletManager;

	// End:0x0F
	if((int(m_iNbBulletsInWeapon) == 0))
	{
		return;
	}
	pawnOwner = R6Pawn(Owner);
	BulletManager = GetBulletManager();
	(m_iNbOfRoundsInBurst++);
	// Consume one round from the active magazine.
	(m_iNbBulletsInWeapon--);
	// When the magazine empties, decrement the clip count (unless using unlimited-clip mode).
	// End:0x95
	if(((int(m_iNbBulletsInWeapon) == 0) && (!IsPumpShotGun())))
	{
		// End:0x75
		if((!((m_iCurrentNbOfClips == 1) && m_bUnlimitedClip)))
		{
			(m_iCurrentNbOfClips--);			
		}
		else
		{
			m_bEmptyAllClips = true;
			// End:0x95
			if((R6Rainbow(Owner) != none))
			{
				// Terrorist pistol in MP: when the last unlimited mag empties, cap refill at 5 rounds.
				m_iClipCapacity = 5;
			}
		}
	}
	bFiredABullet = true;
	// End:0xCC
	if((pawnOwner.m_bIsProne && GotBipod()))
	{
		pawnOwner.UpdateBipodPosture();		
	}
	else
	{
		pawnOwner.PlayWeaponAnimation();
	}
	// Accept the client's aim angle so server trajectory matches the client's view.
	m_fMaxAngleError = fMaxAngleErrorFromClient;
	iCurrentBullet = 0;
	J0xED:

	// End:0x142 [Loop If]
	if((iCurrentBullet < NbBulletToShot()))
	{
		GetFiringDirection(vStartTrace, rBulletRot, iCurrentBullet);
		BulletManager.SpawnBullet(vStartTrace, rBulletRot, m_fMuzzleVelocity, (iCurrentBullet == 0));
		(iCurrentBullet++);
		// [Loop Continue]
		goto J0xED;
	}
	// End:0x170
	if((pawnOwner != none))
	{
		R6AbstractGameInfo(Level.Game).IncrementRoundsFired(pawnOwner, false);
	}
	// Accumulate muzzle-jump penalty; drives camera kick and accuracy degradation.
	(m_fCurrentFireJump += m_stAccuracyValues.fWeaponJump);
	// End:0x1DF
	if((int(m_iNbBulletsInWeapon) == 0))
	{
		switch(m_eRateOfFire)
		{
			// End:0x1AE
			case 0:
				pawnOwner.PlayWeaponSound(7);
				// End:0x1DC
				break;
			// End:0x1B3
			case 1:
			// End:0x1D9
			case 2:
				// End:0x1D6
				if((int(m_iNbOfRoundsInBurst) == 1))
				{
					pawnOwner.PlayWeaponSound(3);
				}
				// End:0x1DC
				break;
			// End:0xFFFF
			default:
				break;
		}		
	}
	else
	{
		// End:0x261
		if((int(m_iNbOfRoundsInBurst) == 1))
		{
			switch(m_eRateOfFire)
			{
				// End:0x20C
				case 0:
					pawnOwner.PlayWeaponSound(3);
					// End:0x261
					break;
				// End:0x245
				case 1:
					// End:0x231
					if((m_iNbOfRoundsToShoot >= 3))
					{
						pawnOwner.PlayWeaponSound(5);						
					}
					else
					{
						pawnOwner.PlayWeaponSound(6);
					}
					// End:0x261
					break;
				// End:0x25E
				case 2:
					pawnOwner.PlayWeaponSound(6);
					// End:0x261
					break;
				// End:0xFFFF
				default:
					break;
			}
		}
		else
		{
		}
		ClientsFireBullet(m_iNbBulletsInWeapon);
		R6MakeNoise(1);
		return;
	}
}

//This functions is called *immediatly* when trigger is pulled.  It only displays shooting effects.
//The actual shooting of the bullet is done on the server in ServerFireBullet().
function ClientShowBulletFire()
{
	local Vector vStartTrace;
	local Rotator rBulletRot;
	local R6Pawn pawnOwner;
	local R6PlayerController PlayerOwner;

	// End:0x20
	if((int(Level.NetMode) == int(NM_Client)))
	{
		(m_iNbOfRoundsInBurst++);
	}
	pawnOwner = R6Pawn(Owner);
	PlayerOwner = R6PlayerController(pawnOwner.Controller);
	// End:0x1EE
	if(pawnOwner.m_bIsPlayer)
	{
		// End:0xF3
		if(((m_FPHands != none) && (int(m_iNbBulletsInWeapon) > 0)))
		{
			// End:0x97
			if((int(m_eRateOfFire) == int(0)))
			{
				m_FPHands.FireSingleShot();				
			}
			else
			{
				// End:0xC8
				if(((int(m_eRateOfFire) == int(1)) && (int(m_iNbOfRoundsInBurst) == 1)))
				{
					m_FPHands.FireThreeShots();					
				}
				else
				{
					// End:0xE4
					if((int(m_iNbOfRoundsInBurst) == 1))
					{
						m_FPHands.StartBurst();
					}
				}
			}
			m_FPWeapon.PlayFireAnim();
		}
		// End:0x1EE
		if((Viewport(PlayerOwner.Player) != none))
		{
			// End:0x16A
			if((int(m_iNbBulletsInWeapon) == 0))
			{
				switch(m_eRateOfFire)
				{
					// End:0x139
					case 0:
						pawnOwner.PlayLocalWeaponSound(7);
						// End:0x167
						break;
					// End:0x13E
					case 1:
					// End:0x164
					case 2:
						// End:0x161
						if((int(m_iNbOfRoundsInBurst) >= 1))
						{
							pawnOwner.PlayLocalWeaponSound(3);
						}
						// End:0x167
						break;
					// End:0xFFFF
					default:
						break;
				}				
			}
			else
			{
				// End:0x1EE
				if((int(m_iNbOfRoundsInBurst) == 1))
				{
					switch(m_eRateOfFire)
					{
						// End:0x197
						case 0:
							pawnOwner.PlayLocalWeaponSound(3);
							// End:0x1EE
							break;
						// End:0x1D2
						case 1:
							// End:0x1BE
							if((int(m_iNbBulletsInWeapon) >= 3))
							{
								pawnOwner.PlayLocalWeaponSound(5);								
							}
							else
							{
								pawnOwner.PlayLocalWeaponSound(6);
							}
							// End:0x1EE
							break;
						// End:0x1EB
						case 2:
							pawnOwner.PlayLocalWeaponSound(6);
							// End:0x1EE
							break;
						// End:0xFFFF
						default:
							break;
					}
				}
				else
				{
				}
			}/* !MISMATCHING REMOVE, tried If got Type:Else Position:0x16A! */
		}
		// End:0x20E
		if((int(Role) != int(ROLE_Authority)))
		{
			GetFiringDirection(vStartTrace, rBulletRot);
		}
		// End:0x228
		if((PlayerOwner != none))
		{
			PlayerOwner.R6WeaponShake();
		}
		return;
	}/* !MISMATCHING REMOVE, tried Else got Type:If Position:0x049! */
}

//This function is called *after* the server has handled the shooting of the bullet.
function ClientsFireBullet(byte iBulletNbFired)
{
	local R6Pawn pawnOwner;
	local R6PlayerController PlayerOwner;

	// End:0x4B
	if(((R6PlayerController(Pawn(Owner).Controller) == none) || R6PlayerController(Pawn(Owner).Controller).m_bWantTriggerLag))
	{
		ClientShowBulletFire();
	}
	pawnOwner = R6Pawn(Owner);
	PlayerOwner = R6PlayerController(pawnOwner.Controller);
	m_iNbBulletsInWeapon = iBulletNbFired;
	// End:0xF7
	if(pawnOwner.m_bIsPlayer)
	{
		// End:0xF7
		if((m_FPHands != none))
		{
			// End:0xCC
			if((IsLMG() == true))
			{
				// End:0xCC
				if((int(m_iNbBulletsInWeapon) < 8))
				{
					m_FPWeapon.HideBullet(int(m_iNbBulletsInWeapon));
				}
			}
			// End:0xF7
			if((int(iBulletNbFired) == 0))
			{
				m_FPHands.FireLastBullet();
				m_FPWeapon.PlayFireLastAnim();
			}
		}
	}
	return;
}

function FullCurrentClip()
{
	m_iNbBulletsInWeapon = byte(m_iClipCapacity);
	return;
}

function ClientStartChangeClip()
{
	// End:0x53
	if(R6Pawn(Owner).m_bIsPlayer)
	{
		// End:0x3D
		if((int(m_iNbBulletsInWeapon) <= 0))
		{
			R6Pawn(Owner).PlayLocalWeaponSound(8);			
		}
		else
		{
			R6Pawn(Owner).PlayLocalWeaponSound(9);
		}
	}
	return;
}

function ServerStartChangeClip()
{
	// End:0x26
	if((int(m_iNbBulletsInWeapon) <= 0))
	{
		R6Pawn(Owner).PlayWeaponSound(8);		
	}
	else
	{
		R6Pawn(Owner).PlayWeaponSound(9);
	}
	// End:0x87
	if(((R6PlayerController(Pawn(Owner).Controller) == none) || R6PlayerController(Pawn(Owner).Controller).m_bWantTriggerLag))
	{
		ClientStartChangeClip();
	}
	return;
}

// Server-side reload: finds the fullest available magazine, moves its rounds into the chamber.
function ServerChangeClip()
{
	local int i, iClipNumber, iMostFullClip, iMaxNbOfRounds, iBulletLeftInWeapon;

	R6MakeNoise(10);
	// End:0x3D
	if(((m_bUnlimitedClip && (GetNbOfClips() == 1)) && (m_bEmptyAllClips == true)))
	{
		m_iNbBulletsInWeapon = byte(m_iClipCapacity);		
	}
	else
	{
		// Save the current magazine's remaining rounds back into the array before switching.
		m_aiNbOfBullets[m_iCurrentClip] = m_iNbBulletsInWeapon;
		// End:0x6B
		if((int(m_aiNbOfBullets[m_iCurrentClip]) == 0))
		{
			iBulletLeftInWeapon = 0;			
		}
		else
		{
			// End:0xFB
			if((!IsPumpShotGun()))
			{
				// End:0xBF
				if(IsLMG())
				{
					// LMG discards partial links under 8 rounds rather than doing a tactical reload.
					// End:0xBC
					if(((int(m_aiNbOfBullets[m_iCurrentClip]) < 8) && (m_iCurrentNbOfClips != 1)))
					{
						m_aiNbOfBullets[m_iCurrentClip] = 0;
						(m_iCurrentNbOfClips--);
						iBulletLeftInWeapon = 0;
					}					
				}
				else
				{
					// Non-LMG tactical reload: one round stays chambered, so the old mag loses that round.
					(m_aiNbOfBullets[m_iCurrentClip] -= byte(1));
					// End:0xF4
					if((int(m_aiNbOfBullets[m_iCurrentClip]) == 0))
					{
						// End:0xF4
						if((m_iCurrentNbOfClips != 1))
						{
							(m_iCurrentNbOfClips--);
						}
					}
					iBulletLeftInWeapon = 1;
				}
			}
		}
		// Find the fullest magazine to load next, searching from current clip forward (round-robin).
		iMostFullClip = m_iCurrentClip;
		i = 0;
		J0x10D:

		// End:0x188 [Loop If]
		if((i < m_iNbOfClips))
		{
			iClipNumber = (m_iCurrentClip + i);
			// End:0x149
			if((iClipNumber >= m_iNbOfClips))
			{
				(iClipNumber -= m_iNbOfClips);
			}
			// End:0x17E
			if((int(m_aiNbOfBullets[iClipNumber]) > iMaxNbOfRounds))
			{
				iMaxNbOfRounds = int(m_aiNbOfBullets[iClipNumber]);
				iMostFullClip = iClipNumber;
			}
			(i++);
			// [Loop Continue]
			goto J0x10D;
		}
		// Advance to the fullest available magazine.
		m_iCurrentClip = iMostFullClip;
		// Add the chambered round back into the new magazine (tactical reload carry-over).
		(m_aiNbOfBullets[m_iCurrentClip] += byte(iBulletLeftInWeapon));
		m_iNbBulletsInWeapon = m_aiNbOfBullets[m_iCurrentClip];
	}
	R6Pawn(Owner).ServerSwitchReloadingWeapon(false);
	return;
}

simulated function PlayReloading()
{
	GotoState('Reloading');
	return;
}

simulated function WeaponZoomSound(bool bFirstZoom)
{
	// End:0x4B
	if(bFirstZoom)
	{
		// End:0x2A
		if((m_SniperZoomFirstSnd != none))
		{
			Owner.PlaySound(m_SniperZoomFirstSnd, 2);			
		}
		else
		{
			// End:0x48
			if((m_CommonWeaponZoomSnd != none))
			{
				Owner.PlaySound(m_CommonWeaponZoomSnd, 2);
			}
		}		
	}
	else
	{
		// End:0x69
		if((m_SniperZoomSecondSnd != none))
		{
			Owner.PlaySound(m_SniperZoomSecondSnd, 2);
		}
	}
	return;
}

simulated event DeployWeaponBipod(bool bBipodOpen)
{
	// End:0x20
	if((m_BipodGadget != none))
	{
		m_BipodGadget.Toggle3rdBipod(bBipodOpen);
	}
	return;
}

//Cheat/debug function
function FullAmmo()
{
	local int iClip;

	// End:0x1B
	if((int(Level.NetMode) != int(NM_Standalone)))
	{
		return;
	}
	m_iNbBulletsInWeapon = 250;
	iClip = 0;
	J0x2A:

	// End:0x51 [Loop If]
	if((iClip < C_iMaxNbOfClips))
	{
		m_aiNbOfBullets[iClip] = 250;
		(iClip++);
		// [Loop Continue]
		goto J0x2A;
	}
	m_iCurrentClip = 0;
	m_iCurrentNbOfClips = C_iMaxNbOfClips;
	return;
}

//Cheat/debug function
function PerfectAim()
{
	m_stAccuracyValues.fAccuracyChange = 0.0000000;
	m_stAccuracyValues.fReticuleTime = 0.1000000;
	m_stAccuracyValues.fRunningAccuracy = 0.0000000;
	m_stAccuracyValues.fShuffleAccuracy = 0.0000000;
	m_stAccuracyValues.fWalkingAccuracy = 0.0000000;
	m_stAccuracyValues.fWalkingFastAccuracy = 0.0000000;
	return;
}

function GiveBulletToWeapon(string aBulletName)
{
	local Class<R6Bullet> aBulletClass;

	aBulletClass = Class<R6Bullet>(DynamicLoadObject(aBulletName, Class'Core.Class'));
	// End:0x31
	if((aBulletClass != none))
	{
		m_pBulletClass = aBulletClass;
	}
	return;
}

function bool HasBulletType(name strBulletName)
{
	// End:0x0D
	if((m_pBulletClass == none))
	{
		return false;
	}
	return (strBulletName == m_pBulletClass.Name);
	return;
}

function Texture Get2DIcon()
{
	return m_WeaponIcon;
	return;
}

function bool AffectActor(int BulletGroup, Actor ActorAffected)
{
	return GetBulletManager().AffectActor(BulletGroup, ActorAffected);
	return;
}

simulated function R6SetGadget(Class<R6AbstractGadget> pWeaponGadgetClass)
{
	local R6AbstractGadget SelectedWeaponGadget;

	// End:0x15
	if((pWeaponGadgetClass == none))
	{
		m_SelectedWeaponGadget = none;		
	}
	else
	{
		switch(pWeaponGadgetClass.default.m_eGadgetType)
		{
			// End:0x3A
			case 1:
				// End:0x37
				if((m_ScopeGadget != none))
				{
					return;
				}
				// End:0x8C
				break;
			// End:0x4F
			case 2:
				// End:0x4C
				if((m_MagazineGadget != none))
				{
					return;
				}
				// End:0x8C
				break;
			// End:0x64
			case 3:
				// End:0x61
				if((m_BipodGadget != none))
				{
					return;
				}
				// End:0x8C
				break;
			// End:0x79
			case 4:
				// End:0x76
				if((m_MuzzleGadget != none))
				{
					return;
				}
				// End:0x8C
				break;
			// End:0xFFFF
			default:
				// End:0x89
				if((m_SelectedWeaponGadget != none))
				{
					return;
				}
				// End:0x8C
				break;
				break;
		}
		SelectedWeaponGadget = Spawn(pWeaponGadgetClass);
		// End:0x12C
		if((SelectedWeaponGadget != none))
		{
			SelectedWeaponGadget.InitGadget(self, Pawn(Owner));
			switch(SelectedWeaponGadget.m_eGadgetType)
			{
				// End:0xE2
				case 1:
					m_ScopeGadget = SelectedWeaponGadget;
					// End:0x12C
					break;
				// End:0xF5
				case 2:
					m_MagazineGadget = SelectedWeaponGadget;
					// End:0x12C
					break;
				// End:0x108
				case 3:
					m_BipodGadget = SelectedWeaponGadget;
					// End:0x12C
					break;
				// End:0x11B
				case 4:
					m_MuzzleGadget = SelectedWeaponGadget;
					// End:0x12C
					break;
				// End:0xFFFF
				default:
					m_SelectedWeaponGadget = SelectedWeaponGadget;
					// End:0x12C
					break;
					break;
			}
		}
	}
	return;
}

function float GetExplosionDelay()
{
	return 0.0000000;
	return;
}

function int NbBulletToShot()
{
	return 1;
	return;
}

simulated event UpdateWeaponAttachment()
{
	local Vector vTagLocation;
	local Rotator rTagRotator;

	SetGadgets();
	return;
}

function SetRelevant(bool bNewAlwaysRelevant)
{
	bAlwaysRelevant = bNewAlwaysRelevant;
	// End:0x2E
	if((m_MagazineGadget != none))
	{
		m_MagazineGadget.bAlwaysRelevant = bAlwaysRelevant;
	}
	// End:0x4F
	if((m_SelectedWeaponGadget != none))
	{
		m_SelectedWeaponGadget.bAlwaysRelevant = bAlwaysRelevant;
	}
	// End:0x70
	if((m_ScopeGadget != none))
	{
		m_ScopeGadget.bAlwaysRelevant = bAlwaysRelevant;
	}
	// End:0x91
	if((m_BipodGadget != none))
	{
		m_BipodGadget.bAlwaysRelevant = bAlwaysRelevant;
	}
	// End:0xB2
	if((m_MuzzleGadget != none))
	{
		m_MuzzleGadget.bAlwaysRelevant = bAlwaysRelevant;
	}
	return;
}

function SetTearOff(bool bNewTearOff)
{
	bTearOff = bNewTearOff;
	// End:0x2E
	if((m_MagazineGadget != none))
	{
		m_MagazineGadget.bTearOff = bTearOff;
	}
	// End:0x4F
	if((m_SelectedWeaponGadget != none))
	{
		m_SelectedWeaponGadget.bTearOff = bTearOff;
	}
	// End:0x70
	if((m_ScopeGadget != none))
	{
		m_ScopeGadget.bTearOff = bTearOff;
	}
	// End:0x91
	if((m_BipodGadget != none))
	{
		m_BipodGadget.bTearOff = bTearOff;
	}
	// End:0xB2
	if((m_MuzzleGadget != none))
	{
		m_MuzzleGadget.bTearOff = bTearOff;
	}
	return;
}

// Unreal rotator range ±65535 used here for randomised tumble speed on bounce.
//============================================================================
// function HitWall - Bounce when the weapon fall of a dead pawn
//============================================================================
simulated function HitWall(Vector HitNormal, Actor Wall)
{
	(m_wNbOfBounce++);
	RotationRate.Pitch = 0;
	// Random full-circle tumble on each axis (65535 ≈ 360° in Unreal rotator units).
	RotationRate.Yaw = int(RandRange(-65535.0000000, 65535.0000000));
	RotationRate.Roll = int(RandRange(-65535.0000000, 65535.0000000));
	// End:0x7F
	if((HitNormal.Z < 0.1000000))
	{
		Velocity = ((0.7500000 * VSize(Velocity)) * HitNormal);		
	}
	else
	{
		Velocity = (0.1500000 * MirrorVectorByNormal(Velocity, HitNormal));
		(Velocity.Z *= float(2));
		// End:0xCD
		if((VSize(Velocity) < float(10)))
		{
			// End:0xC7
			if(CheckForPlaceToFall())
			{
				return;				
			}
			else
			{
				StopFallingAndSetCorrectRotation();
			}
		}
	}
	// End:0xE1
	if((int(m_wNbOfBounce) > 20))
	{
		PutAtOwnerFeet();
	}
	return;
}

//============================================================================
// function BOOL CheckForPlaceToFall - 
//============================================================================
simulated function bool CheckForPlaceToFall()
{
	local Vector vNewLocation, vHitLocation, vNormal;
	local Actor aTraced;

	vNewLocation = (Location - vect(0.0000000, 0.0000000, 10.0000000));
	aTraced = R6Trace(vHitLocation, vNormal, vNewLocation, Location, 0);
	// End:0xB4
	if((aTraced == none))
	{
		// End:0x6A
		if(FindSpot(vNewLocation))
		{
			// End:0x67
			if((vNewLocation != Location))
			{
				SetLocation(vNewLocation);
				return true;
			}			
		}
		else
		{
			vNewLocation = m_vPawnLocWhenKilled;
			vNewLocation.Z = (Location.Z - float(10));
			// End:0xB4
			if(FindSpot(vNewLocation))
			{
				// End:0xB4
				if((vNewLocation != Location))
				{
					SetLocation(vNewLocation);
					return true;
				}
			}
		}
	}
	return false;
	return;
}

//============================================================================
// function StopFallingAndSetCorrectRotation - 
//============================================================================
simulated function StopFallingAndSetCorrectRotation()
{
	SetPhysics(5);
	bBounce = false;
	bRotateToDesired = true;
	DesiredRotation.Yaw = Rotation.Yaw;
	// 13384 ≈ 74° roll, 49151 ≈ 270° roll: these are the two "flat on ground" resting orientations.
	// End:0x6C
	if((Abs(float((Rotation.Roll - 13384))) > Abs(float((Rotation.Roll - 49151)))))
	{
		DesiredRotation.Roll = 49151;		
	}
	else
	{
		DesiredRotation.Roll = 13384;
	}
	// End:0xAB
	if((DesiredRotation.Roll < Rotation.Roll))
	{
		RotationRate = rot(0, 0, -100000);		
	}
	else
	{
		RotationRate = rot(0, 0, 100000);
	}
	return;
}

//============================================================================
// function PutAtOwnerFeet - 
//============================================================================
simulated function PutAtOwnerFeet()
{
	SetLocation(m_vPawnLocWhenKilled, true);
	StopFallingAndSetCorrectRotation();
	return;
}

//============================================================================
// function StartFalling - 
//============================================================================
simulated function StartFalling()
{
	local Vector vLocation, vDir;
	local Rotator rRot;

	// End:0x4C
	if((Owner != none))
	{
		m_vPawnLocWhenKilled = Owner.Location;
		(m_vPawnLocWhenKilled.Z -= Owner.CollisionHeight);
		Owner.DetachFromBone(self);		
	}
	else
	{
		m_vPawnLocWhenKilled = Location;
	}
	m_iNbParticlesToCreate = 0;
	GotoState('None');
	SetCollisionSize(35.0000000, 5.0000000);
	vLocation = Location;
	m_bLightingVisibility = true;
	// End:0x1A1
	if(FindSpot(vLocation))
	{
		SetLocation(vLocation);
		SetCollision(true, false, false);
		bCollideWorld = true;
		bBounce = true;
		Enable('HitWall');
		SetPhysics(2);
		vDir = Vector(Rotation);
		(vDir.X += RandRange(-0.4000000, 0.4000000));
		(vDir.Y += RandRange(-0.4000000, 0.4000000));
		(vDir *= RandRange(100.0000000, 400.0000000));
		vDir.Z = -600.0000000;
		Acceleration = vDir;
		bFixedRotationDir = true;
		RotationRate.Pitch = 0;
		RotationRate.Yaw = int(RandRange(-65535.0000000, 65535.0000000));
		RotationRate.Roll = int(RandRange(-65535.0000000, 65535.0000000));
		rRot = Rotation;
		rRot.Pitch = 0;
		SetRotation(rRot);		
	}
	else
	{
		PutAtOwnerFeet();
	}
	return;
}

function bool CanSwitchToWeapon()
{
	return true;
	return;
}

simulated event ShowWeaponParticules(R6EngineWeapon.EWeaponSound EWeaponSound)
{
	m_fTimeDisplayParticule = Level.TimeSeconds;
	switch(EWeaponSound)
	{
		// End:0x20
		case 7:
		// End:0x2F
		case 3:
			m_iNbParticlesToCreate = 1;
			// End:0x6A
			break;
		// End:0x48
		case 5:
			m_iNbParticlesToCreate = Min(3, int(m_iNbBulletsInWeapon));
			// End:0x6A
			break;
		// End:0x5D
		case 6:
			m_iNbParticlesToCreate = int(m_iNbBulletsInWeapon);
			// End:0x6A
			break;
		// End:0xFFFF
		default:
			m_iNbParticlesToCreate = 0;
			// End:0x6A
			break;
			break;
	}
	return;
}

function SetAccuracyOnHit()
{
	m_fEffectiveAccuracy = m_stAccuracyValues.fRunningAccuracy;
	return;
}

// State active while the weapon is firing; Timer() drives inter-shot pacing.
state NormalFire
{
// FiringSpeed is used in UW as the rate parameter in playanim.
	function Fire(float Value)
	{
		// End:0x12
		if((m_bFireOn == false))
		{
			StartFiring();
		}
		return;
	}

// For MacArthur weapons, AltFire will activate the gadget and roll grenades.
// Still don't know what Value is used for?
	function AltFire(float Value)
	{
		return;
	}

	function StopAltFire()
	{
		return;
	}

	function PlayReloading()
	{
		R6Pawn(Owner).ServerSwitchReloadingWeapon(false);
		return;
	}

	function EndState()
	{
		R6Pawn(Owner).m_bIsFiringState = false;
		// End:0x3A
		if((m_bFireOn == true))
		{
			m_bFireOn = false;
			SetTimer(0.0000000, false);
			LocalStopFire(true);
		}
		Pawn(Owner).Controller.m_bLockWeaponActions = false;
		return;
	}

	simulated function FirstPersonAnimOver()
	{
		m_FPHands.StartTimer();
		// End:0x4C
		if(R6GameReplicationInfo(R6PlayerController(Pawn(Owner).Controller).GameReplicationInfo).m_bGameOverRep)
		{
			GotoState('None');			
		}
		else
		{
			// Full-auto: if trigger is still held after an animation cycle, immediately restart firing.
			// End:0x94
			if(((int(Pawn(Owner).Controller.bFire) == 1) && (int(m_eRateOfFire) == int(2))))
			{
				LocalStopFire(true);
				StartFiring();
				return;				
			}
			else
			{
				// Burst: keep state alive while remaining rounds in the burst are queued.
				// End:0xB6
				if(((m_iNbOfRoundsToShoot > 0) && (int(m_eRateOfFire) == int(1))))
				{
					return;					
				}
				else
				{
					GotoState('None');
				}
			}
		}
		return;
	}

	simulated function BeginState()
	{
		Pawn(Owner).Controller.m_bLockWeaponActions = true;
		R6Pawn(Owner).m_bIsFiringState = true;
		StartFiring();
		return;
	}

	simulated function StartFiring()
	{
		// Determine how many rounds this trigger pull will fire (1/3/full-mag).
		m_iNbOfRoundsToShoot = GetNbOfRoundsForROF();
		ServerStartFiring();
		// End:0x5F
		if(((R6PlayerController(Pawn(Owner).Controller) != none) && (!R6PlayerController(Pawn(Owner).Controller).m_bWantTriggerLag)))
		{
			ClientStartFiring();
		}
		// End:0x9F
		if((R6PlayerController(Pawn(Owner).Controller) != none))
		{
			R6PlayerController(Pawn(Owner).Controller).ResetCameraShake();
		}
		// End:0xFF
		if((m_iNbOfRoundsToShoot != 0))
		{
			// End:0xC5
			if((m_FPHands != none))
			{
				m_FPHands.GotoState('FiringWeapon');
			}
			DoSingleFire();
			// End:0xEA
			if((m_iNbOfRoundsToShoot != 0))
			{
				// Start the inter-shot timer; fires once per m_fRateOfFire seconds until burst/auto ends.
				SetTimer(m_fRateOfFire, true);
				m_bFireOn = true;				
			}
			else
			{
				// End:0xFC
				if((m_FPHands == none))
				{
					GotoState('None');
				}
			}			
		}
		else
		{
			// End:0x124
			if(m_FPHands.HasAnim('FireEmpty'))
			{
				m_FPHands.PlayAnim('FireEmpty');
			}
			GotoState('None');
		}
		return;
	}

	// Called each m_fRateOfFire interval; fires the next round or terminates the burst.
	simulated function Timer()
	{
		// Consume one round allocation; if burst is exhausted or trigger released, stop firing.
		(m_iNbOfRoundsToShoot--);
		// End:0x53
		if(((m_iNbOfRoundsToShoot > 0) && ((int(m_eRateOfFire) == int(1)) || (int(Pawn(Owner).Controller.bFire) == 1))))
		{
			DoSingleFire();			
		}
		else
		{
			m_bFireOn = false;
			SetTimer(0.0000000, false);
			StopFire(false);
		}
		return;
	}

	function DoSingleFire()
	{
		ServerFireBullet(m_fMaxAngleError);
		// End:0x58
		if(((R6PlayerController(Pawn(Owner).Controller) != none) && (!R6PlayerController(Pawn(Owner).Controller).m_bWantTriggerLag)))
		{
			ClientShowBulletFire();
		}
		return;
	}
	stop;
}

// State active while a magazine change animation is playing.
state Reloading
{
// FiringSpeed is used in UW as the rate parameter in playanim.
	function Fire(float Value)
	{
		return;
	}

// For MacArthur weapons, AltFire will activate the gadget and roll grenades.
// Still don't know what Value is used for?
	function AltFire(float Value)
	{
		return;
	}

	function StopAltFire()
	{
		return;
	}

	function PlayReloading()
	{
		return;
	}

	function FirstPersonAnimOver()
	{
		local Pawn pawnOwner;

		pawnOwner = Pawn(Owner);
		// End:0x39
		if((pawnOwner.Controller != none))
		{
			R6Pawn(Owner).ServerSwitchReloadingWeapon(false);
		}
		ServerChangeClip();
		// End:0x7E
		if(((pawnOwner.Controller != none) && (int(pawnOwner.Controller.bFire) == 1)))
		{
			GotoState('NormalFire');			
		}
		else
		{
			GotoState('None');
		}
		return;
	}

	simulated function ChangeClip()
	{
		R6Pawn(Owner).ServerSwitchReloadingWeapon(false);
		ServerChangeClip();
		// End:0x49
		if((int(Pawn(Owner).Controller.bFire) == 1))
		{
			GotoState('NormalFire');			
		}
		else
		{
			GotoState('None');
		}
		return;
	}

	function EndState()
	{
		local R6PlayerController PlayerCtrl;

		PlayerCtrl = R6PlayerController(Pawn(Owner).Controller);
		// End:0x5B
		if((PlayerCtrl != none))
		{
			PlayerCtrl.m_iPlayerCAProgress = 0;
			PlayerCtrl.m_bHideReticule = false;
			PlayerCtrl.m_bLockWeaponActions = false;
		}
		R6Pawn(Owner).ServerSwitchReloadingWeapon(false);
		return;
	}

	simulated function BeginState()
	{
		local R6PlayerController PlayerCtrl;

		PlayerCtrl = R6PlayerController(Pawn(Owner).Controller);
		// End:0x111
		if(((GetNbOfClips() > 0) || ((int(Level.NetMode) != int(NM_Standalone)) && (int(m_eWeaponType) == int(0)))))
		{
			// End:0x8D
			if((PlayerCtrl != none))
			{
				PlayerCtrl.m_bLockWeaponActions = true;
				// End:0x8D
				if((!PlayerCtrl.m_bWantTriggerLag))
				{
					ClientStartChangeClip();
				}
			}
			ServerStartChangeClip();
			// End:0x10E
			if(R6Pawn(Owner).m_bIsPlayer)
			{
				// End:0x10E
				if((PlayerCtrl.bBehindView == false))
				{
					// End:0xDD
					if((int(m_iNbBulletsInWeapon) <= 0))
					{
						m_FPHands.m_bReloadEmpty = true;
					}
					m_FPHands.GotoState('Reloading');
					PlayerCtrl.m_iPlayerCAProgress = 0;
					PlayerCtrl.m_bHideReticule = true;
				}
			}			
		}
		else
		{
			GotoState('None');
		}
		return;
	}

	// Maps the reload animation frame [0.0-1.0] to a progress value [0-110] for the HUD indicator.
	function int GetReloadProgress()
	{
		local name Anim;
		local float fFrame, fRate;

		m_FPHands.GetAnimParams(0, Anim, fFrame, fRate);
		return int((fFrame * float(110)));
		return;
	}

	event Tick(float fDeltaTime)
	{
		local R6PlayerController PlayerCtrl;

		PlayerCtrl = R6PlayerController(Pawn(Owner).Controller);
		// End:0x54
		if(((PlayerCtrl != none) && (!PlayerCtrl.ShouldDrawWeapon())))
		{
			PlayerCtrl.m_iPlayerCAProgress = GetReloadProgress();
		}
		return;
	}
	stop;
}

// State played when switching away from this weapon (put-down animation).
state DiscardWeapon
{
// FiringSpeed is used in UW as the rate parameter in playanim.
	function Fire(float Value)
	{
		return;
	}

// For MacArthur weapons, AltFire will activate the gadget and roll grenades.
// Still don't know what Value is used for?
	function AltFire(float Value)
	{
		return;
	}

//This function is used to send ClientStopFire() to the client immediatly after the bullet-fire-order 
//has been sent to the server without having to wait for server response.
	function StopFire(optional bool bSoundOnly)
	{
		return;
	}

	function StopAltFire()
	{
		return;
	}

	function PlayReloading()
	{
		return;
	}

	function FirstPersonAnimOver()
	{
		// End:0x3B
		if((Pawn(Owner).Controller != none))
		{
			R6PlayerController(Pawn(Owner).Controller).WeaponUpState();
		}
		return;
	}

	simulated function BeginState()
	{
		local R6PlayerController PlayerCtrl;

		PlayerCtrl = R6PlayerController(Pawn(Owner).Controller);
		// End:0x55
		if((m_FPHands != none))
		{
			// End:0x45
			if((PlayerCtrl != none))
			{
				PlayerCtrl.m_bHideReticule = true;
			}
			m_FPHands.GotoState('DiscardWeapon');
		}
		// End:0x71
		if((PlayerCtrl != none))
		{
			PlayerCtrl.m_bLockWeaponActions = true;
		}
		return;
	}

	simulated function EndState()
	{
		return;
	}
	stop;
}

// State played when switching to this weapon (raise/bring-up animation).
state RaiseWeapon
{
// FiringSpeed is used in UW as the rate parameter in playanim.
	function Fire(float Value)
	{
		return;
	}

// For MacArthur weapons, AltFire will activate the gadget and roll grenades.
// Still don't know what Value is used for?
	function AltFire(float Value)
	{
		return;
	}

//This function is used to send ClientStopFire() to the client immediatly after the bullet-fire-order 
//has been sent to the server without having to wait for server response.
	function StopFire(optional bool bSoundOnly)
	{
		return;
	}

	function StopAltFire()
	{
		return;
	}

	function PlayReloading()
	{
		return;
	}

	function EndState()
	{
		local R6PlayerController PlayerCtrl;
		local R6Rainbow RainbowPawn;

		RainbowPawn = R6Rainbow(Owner);
		PlayerCtrl = R6PlayerController(RainbowPawn.Controller);
		RainbowPawn.AttachWeapon(self, m_AttachPoint);
		// End:0x6B
		if((PlayerCtrl != none))
		{
			PlayerCtrl.m_bHideReticule = false;
			PlayerCtrl.m_bLockWeaponActions = false;
		}
		RainbowPawn.m_fWeaponJump = m_stAccuracyValues.fWeaponJump;
		RainbowPawn.m_fZoomJumpReturn = 1.0000000;
		return;
	}

	function FirstPersonAnimOver()
	{
		// End:0x3B
		if((Pawn(Owner).Controller != none))
		{
			R6PlayerController(Pawn(Owner).Controller).ServerWeaponUpAnimDone();
		}
		R6Pawn(Owner).m_bChangingWeapon = false;
		// End:0x9A
		if(((Pawn(Owner).Controller != none) && (int(Pawn(Owner).Controller.bFire) == 1)))
		{
			GotoState('NormalFire');			
		}
		else
		{
			GotoState('None');
		}
		return;
	}

	simulated function BeginState()
	{
		TurnOffEmitters(false);
		// End:0x75
		if((m_FPHands != none))
		{
			// End:0x30
			if((m_bPawnIsWalking == true))
			{
				m_FPHands.PlayWalkingAnimation();				
			}
			else
			{
				m_FPHands.StopWalkingAnimation();
			}
			// End:0x65
			if(m_FPHands.IsInState('RaiseWeapon'))
			{
				m_FPHands.BeginState();				
			}
			else
			{
				m_FPHands.GotoState('RaiseWeapon');
			}
		}
		return;
	}
	stop;
}

// State that lowers the weapon to a neutral carry position (e.g. entering planning mode).
state PutWeaponDown
{
// FiringSpeed is used in UW as the rate parameter in playanim.
	function Fire(float Value)
	{
		return;
	}

// For MacArthur weapons, AltFire will activate the gadget and roll grenades.
// Still don't know what Value is used for?
	function AltFire(float Value)
	{
		return;
	}

//This function is used to send ClientStopFire() to the client immediatly after the bullet-fire-order 
//has been sent to the server without having to wait for server response.
	function StopFire(optional bool bSoundOnly)
	{
		return;
	}

	function StopAltFire()
	{
		return;
	}

	function PlayReloading()
	{
		return;
	}

	function FirstPersonAnimOver()
	{
		return;
	}

	simulated function BeginState()
	{
		// End:0x38
		if((m_FPHands != none))
		{
			// End:0x28
			if(m_FPHands.IsInState('FiringWeapon'))
			{
				GotoState('None');
				return;
			}
			m_FPHands.GotoState('PutWeaponDown');
		}
		R6Pawn(Owner).m_bWeaponTransition = false;
		// End:0x86
		if((Pawn(Owner).Controller != none))
		{
			Pawn(Owner).Controller.m_bLockWeaponActions = true;
		}
		return;
	}
	stop;
}

// State that raises the weapon from the carry position back to the ready position.
state BringWeaponUp
{
// FiringSpeed is used in UW as the rate parameter in playanim.
	function Fire(float Value)
	{
		return;
	}

// For MacArthur weapons, AltFire will activate the gadget and roll grenades.
// Still don't know what Value is used for?
	function AltFire(float Value)
	{
		return;
	}

//This function is used to send ClientStopFire() to the client immediatly after the bullet-fire-order 
//has been sent to the server without having to wait for server response.
	function StopFire(optional bool bSoundOnly)
	{
		return;
	}

	function StopAltFire()
	{
		return;
	}

	function PlayReloading()
	{
		return;
	}

	function FirstPersonAnimOver()
	{
		// End:0x49
		if(((Pawn(Owner).Controller != none) && (int(Pawn(Owner).Controller.bFire) == 1)))
		{
			GotoState('NormalFire');			
		}
		else
		{
			GotoState('None');
		}
		return;
	}

	simulated function BeginState()
	{
		// End:0x1E
		if((m_FPHands != none))
		{
			m_FPHands.GotoState('BringWeaponUp');			
		}
		else
		{
			FirstPersonAnimOver();
		}
		return;
	}

	simulated function EndState()
	{
		// End:0x57
		if((Pawn(Owner).Controller != none))
		{
			Pawn(Owner).Controller.m_bHideReticule = false;
			Pawn(Owner).Controller.m_bLockWeaponActions = false;
		}
		return;
	}
	stop;
}

// State played during bipod deployment animation; blocks fire and other actions.
state DeployBipod
{
// FiringSpeed is used in UW as the rate parameter in playanim.
	function Fire(float Value)
	{
		return;
	}

// For MacArthur weapons, AltFire will activate the gadget and roll grenades.
// Still don't know what Value is used for?
	function AltFire(float Value)
	{
		return;
	}

	function StopAltFire()
	{
		return;
	}

	function PlayReloading()
	{
		return;
	}

	function FirstPersonAnimOver()
	{
		// End:0x49
		if(((Pawn(Owner).Controller != none) && (int(Pawn(Owner).Controller.bFire) == 1)))
		{
			GotoState('NormalFire');			
		}
		else
		{
			GotoState('None');
		}
		return;
	}

	simulated function BeginState()
	{
		// End:0x1B
		if((m_FPHands != none))
		{
			m_FPHands.GotoState('DeployBipod');
		}
		return;
	}

	function EndState()
	{
		return;
	}
	stop;
}

state CloseBipod
{
// FiringSpeed is used in UW as the rate parameter in playanim.
	function Fire(float Value)
	{
		return;
	}

// For MacArthur weapons, AltFire will activate the gadget and roll grenades.
// Still don't know what Value is used for?
	function AltFire(float Value)
	{
		return;
	}

	function StopAltFire()
	{
		return;
	}

	function PlayReloading()
	{
		return;
	}

	function FirstPersonAnimOver()
	{
		// End:0x49
		if(((Pawn(Owner).Controller != none) && (int(Pawn(Owner).Controller.bFire) == 1)))
		{
			GotoState('NormalFire');			
		}
		else
		{
			GotoState('None');
		}
		return;
	}

	simulated function BeginState()
	{
		// End:0x1B
		if((m_FPHands != none))
		{
			m_FPHands.GotoState('CloseBipod');
		}
		return;
	}
	stop;
}

state ZoomIn
{
// FiringSpeed is used in UW as the rate parameter in playanim.
	function Fire(float Value)
	{
		return;
	}

// For MacArthur weapons, AltFire will activate the gadget and roll grenades.
// Still don't know what Value is used for?
	function AltFire(float Value)
	{
		return;
	}

	function StopAltFire()
	{
		return;
	}

	function PlayReloading()
	{
		return;
	}

	function FirstPersonAnimOver()
	{
		local Pawn pawnOwner;

		pawnOwner = Pawn(Owner);
		// End:0x41
		if((pawnOwner.Controller != none))
		{
			R6PlayerController(pawnOwner.Controller).DoZoom();
		}
		// End:0x80
		if(((pawnOwner.Controller != none) && (int(pawnOwner.Controller.bFire) == 1)))
		{
			GotoState('NormalFire');			
		}
		else
		{
			GotoState('None');
		}
		return;
	}

	simulated function BeginState()
	{
		Pawn(Owner).Controller.m_bLockWeaponActions = true;
		WeaponZoomSound(true);
		// End:0x41
		if((m_FPHands != none))
		{
			m_FPHands.GotoState('ZoomIn');
		}
		return;
	}

	simulated function EndState()
	{
		Pawn(Owner).Controller.m_bLockWeaponActions = false;
		return;
	}
	stop;
}

state ZoomOut
{
	function FirstPersonAnimOver()
	{
		// End:0x49
		if(((Pawn(Owner).Controller != none) && (int(Pawn(Owner).Controller.bFire) == 1)))
		{
			GotoState('NormalFire');			
		}
		else
		{
			GotoState('None');
		}
		return;
	}

	simulated function BeginState()
	{
		// End:0x1B
		if((m_FPHands != none))
		{
			m_FPHands.GotoState('ZoomOut');
		}
		return;
	}
	stop;
}

defaultproperties
{
	C_iMaxNbOfClips=20
	m_iClipCapacity=9999
	m_iNbOfClips=1
	m_bPlayLoopingSound=true
	m_fMuzzleVelocity=10000.0000000
	m_fStablePercentage=0.5000000
	m_fFireSoundRadius=700.0000000
	m_fRateOfFire=0.1000000
	m_fDisplayFOV=80.0000000
	m_WeaponIcon=Texture'R6WeaponsIcons.Icons.IconTest'
	m_stAccuracyValues=(fBaseAccuracy=1.5000000,fShuffleAccuracy=1.9000000,fWalkingAccuracy=4.7000000,fWalkingFastAccuracy=6.7000000,fRunningAccuracy=11.5000000,fReticuleTime=1.0000000,fAccuracyChange=1.6500000,fWeaponJump=3.3100000)
	m_szWithWeaponReticuleClass="WITHWEAPON"
	m_ScopeAdd=Texture'Inventory_t.Scope.ScopeBlurTexAdd'
	m_CommonWeaponZoomSnd=Sound'CommonWeapons.Play_WeaponZoom'
	m_PawnWaitAnimLow="StandSubGunLow_nt"
	m_PawnWaitAnimHigh="StandSubGunHigh_nt"
	m_PawnWaitAnimProne="ProneSubGun_nt"
	m_PawnFiringAnim="StandFireSubGun"
	m_PawnFiringAnimProne="ProneFireSubGun"
	m_PawnReloadAnim="StandReloadSubGun"
	m_PawnReloadAnimTactical="StandTacReloadSubGun"
	m_PawnReloadAnimProne="ProneReloadSubGun"
	m_PawnReloadAnimProneTactical="ProneTacReloadSubGun"
	DrawType=8
	bReplicateInstigator=true
	bSkipActorPropertyReplication=true
	m_bForceBaseReplication=true
	m_bDeleteOnReset=true
	m_fSoundRadiusActivation=5600.0000000
	StaticMesh=StaticMesh'R6Weapons.RedWeaponStaticMesh'
	DrawScale3D=(X=-1.0000000,Y=-1.0000000,Z=1.0000000)
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var bMuzzle
// REMOVED IN 1.60: var m_pReticuleClass
// REMOVED IN 1.60: var m_pWithWeaponReticuleClass
// REMOVED IN 1.60: function GetRateOfFire
// REMOVED IN 1.60: function DbgNextReticule
// REMOVED IN 1.60: function DisplayWeaponDGBInfo
// REMOVED IN 1.60: function ShowInfo
