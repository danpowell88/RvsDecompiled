//=============================================================================
// R6Weapons - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
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

var(R6Clip) byte m_aiNbOfBullets[20];  // Number of bullets in each magazines (The current maximum is 16 (8+4+4))
var byte m_iNbOfRoundsInBurst;  // Number of rounds shot since the trigger was pull
var(R6Firing) R6EngineWeapon.eRateOfFire m_eRateOfFire;  // Current Rate of Fire
var byte m_wNbOfBounce;  // Location the pawn was at when the weapon start falling.  Used to find a location for the falling weapon if everything else fails.
var const int C_iMaxNbOfClips;
var(R6Clip) int m_iClipCapacity;  // Number of round per magazine
var(R6Clip) int m_iNbOfClips;  // This is the number of clip that the guns had at the beginning of the mission
var(R6Clip) int m_iNbOfExtraClips;  // Number of extra clips per EXTRA CLIP gadget
var int m_iCurrentClip;  // Active Clip Number
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
var float m_fEffectiveAccuracy;  // Effective accuracy. This accuracy is compute once a tick
var float m_fDesiredAccuracy;  // Desired accuracy.
var float m_fMaxAngleError;  // Angle that is set depending of the effective accuracy
var float m_fCurrentFireJump;  // 
var float m_fFireSoundRadius;  // Distance (in unit) at wich the fire is heard by the AI
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
	if(Owner.__NFUN_303__('R6Rainbow'))
	{
		// End:0x1D4
		if(__NFUN_123__(m_szReticuleClass, ""))
		{
			// End:0x3E
			if(__NFUN_119__(LocalPlayerController, none))
			{
				pPlayerCtrl = R6PlayerController(LocalPlayerController);				
			}
			else
			{
				pPlayerCtrl = R6PlayerController(Pawn(Owner).Controller);
			}
			// End:0x7A
			if(__NFUN_119__(m_ReticuleInstance, none))
			{
				m_ReticuleInstance.__NFUN_279__();
				m_ReticuleInstance = none;
			}
			GameOptions = Class'Engine.Actor'.static.__NFUN_1009__();
			ReticuleToSpawn = Class'Engine.Actor'.static.__NFUN_1524__().GetCurrentReticule(m_szWithWeaponReticuleClass);
			// End:0x162
			if(__NFUN_132__(__NFUN_132__(__NFUN_154__(int(m_eWeaponType), int(6)), __NFUN_154__(int(m_eWeaponType), int(7))), __NFUN_130__(__NFUN_242__(GameOptions.HUDShowFPWeapon, false), __NFUN_132__(__NFUN_154__(int(Level.NetMode), int(NM_Standalone)), __NFUN_130__(__NFUN_119__(R6GameReplicationInfo(pPlayerCtrl.GameReplicationInfo), none), __NFUN_242__(R6GameReplicationInfo(pPlayerCtrl.GameReplicationInfo).m_bFFPWeapon, false))))))
			{
				ReticuleToSpawn = Class'Engine.Actor'.static.__NFUN_1524__().GetCurrentReticule(m_szReticuleClass);
			}
			m_ReticuleInstance = R6Reticule(__NFUN_278__(ReticuleToSpawn, Owner));
			// End:0x1A7
			if(__NFUN_154__(int(Level.NetMode), int(NM_Standalone)))
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
	if(__NFUN_114__(OwnerFromServer, none))
	{
		ServerWhoIsMyOwner();
		return;
	}
	__NFUN_272__(OwnerFromServer);
	LoadFirstPersonWeapon();
	// End:0x59
	if(__NFUN_242__(R6Pawn(Owner).m_bChangingWeapon, true))
	{
		// End:0x4F
		if(__NFUN_281__('RaiseWeapon'))
		{
			BeginState();			
		}
		else
		{
			__NFUN_113__('RaiseWeapon');
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
	if(__NFUN_130__(__NFUN_130__(__NFUN_130__(__NFUN_119__(m_pFPWeaponClass, none), __NFUN_119__(m_pFPHandsClass, none)), __NFUN_114__(m_FPHands, none)), __NFUN_114__(m_FPWeapon, none)))
	{
		// End:0x48
		if(__NFUN_119__(NetOwner, none))
		{
			__NFUN_272__(NetOwner);			
		}
		else
		{
			// End:0x5B
			if(__NFUN_114__(Owner, none))
			{
				ServerWhoIsMyOwner();
				return false;
			}
		}
		m_FPHands = __NFUN_278__(m_pFPHandsClass, self);
		// End:0xA5
		if(Owner.__NFUN_303__('R6Rainbow'))
		{
			m_FPHands.Skins[0] = R6Rainbow(Owner).Skins[5];
		}
		m_FPWeapon = __NFUN_278__(m_pFPWeaponClass, self);
		R6AbstractFirstPersonHands(m_FPHands).SetAssociatedWeapon(m_FPWeapon);
		// End:0x17E
		if(__NFUN_130__(__NFUN_119__(m_FPWeapon, none), __NFUN_119__(m_FPHands, none)))
		{
			// End:0x10E
			if(__NFUN_154__(NumberOfBulletsLeftInClip(), 0))
			{
				m_FPWeapon.m_WeaponNeutralAnim = m_FPWeapon.m_Empty;
			}
			// End:0x128
			if(__NFUN_119__(m_SelectedWeaponGadget, none))
			{
				m_SelectedWeaponGadget.AttachFPGadget();
			}
			// End:0x142
			if(__NFUN_119__(m_MuzzleGadget, none))
			{
				m_MuzzleGadget.AttachFPGadget();
			}
			AttachEmittersToFPWeapon();
			m_FPWeapon.__NFUN_259__(m_FPWeapon.m_WeaponNeutralAnim);
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
	if(__NFUN_119__(m_pMuzzleFlashEmitter, none))
	{
		m_pMuzzleFlashEmitter.m_bDrawFromBase = false;
		m_pMuzzleFlashEmitter.__NFUN_298__(none);
		m_FPWeapon.AttachToBone(m_pMuzzleFlashEmitter, 'TagMuzzle');
		m_pMuzzleFlashEmitter.SetRelativeLocation(vect(0.0000000, 0.0000000, 0.0000000));
		m_pMuzzleFlashEmitter.SetRelativeRotation(rot(0, 0, 0));
	}
	// End:0x151
	if(__NFUN_119__(m_pEmptyShellsEmitter, none))
	{
		m_pEmptyShellsEmitter.m_bDrawFromBase = false;
		m_pEmptyShellsEmitter.__NFUN_298__(none);
		m_FPWeapon.AttachToBone(m_pEmptyShellsEmitter, 'TagCase');
		m_pEmptyShellsEmitter.SetRelativeLocation(vect(0.0000000, 0.0000000, 0.0000000));
		m_pEmptyShellsEmitter.SetRelativeRotation(rot(0, 0, 0));
		// End:0x151
		if(__NFUN_151__(m_pEmptyShellsEmitter.Emitters.Length, 0))
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
	if(__NFUN_119__(m_pMuzzleFlashEmitter, none))
	{
		__NFUN_2008__("TAGMuzzle", vTagLocation, rTagRotator);
		// End:0x44
		if(__NFUN_119__(m_SelectedWeaponGadget, none))
		{
			__NFUN_223__(vTagLocation, m_SelectedWeaponGadget.GetGadgetMuzzleOffset());
		}
		// End:0x63
		if(__NFUN_119__(m_FPWeapon, none))
		{
			m_FPWeapon.DetachFromBone(m_pMuzzleFlashEmitter);
		}
		m_pMuzzleFlashEmitter.m_bDrawFromBase = true;
		m_pMuzzleFlashEmitter.__NFUN_298__(none);
		m_pMuzzleFlashEmitter.__NFUN_298__(self, Location);
		m_pMuzzleFlashEmitter.SetRelativeLocation(vTagLocation);
		m_pMuzzleFlashEmitter.SetRelativeRotation(rTagRotator);
	}
	// End:0x1B0
	if(__NFUN_119__(m_pEmptyShellsEmitter, none))
	{
		__NFUN_2008__("TagCase", vTagLocation, rTagRotator);
		// End:0xFB
		if(__NFUN_119__(m_FPWeapon, none))
		{
			m_FPWeapon.DetachFromBone(m_pEmptyShellsEmitter);
		}
		m_pEmptyShellsEmitter.m_bDrawFromBase = true;
		m_pEmptyShellsEmitter.__NFUN_298__(none);
		m_pEmptyShellsEmitter.__NFUN_298__(self, Location);
		m_pEmptyShellsEmitter.SetRelativeLocation(vTagLocation);
		m_pEmptyShellsEmitter.SetRelativeRotation(rTagRotator);
		// End:0x1B0
		if(__NFUN_151__(m_pEmptyShellsEmitter.Emitters.Length, 0))
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
	if(__NFUN_119__(m_FPHands, none))
	{
		m_FPHands.SetDrawType(2);
		m_FPHands.__NFUN_113__('Waiting');
		m_FPHands.__NFUN_259__(R6AbstractFirstPersonHands(m_FPHands).m_WaitAnim1);
	}
	__NFUN_113__('None');
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
	if(__NFUN_119__(m_FPHands, none))
	{
		temp = m_FPHands;
		m_FPHands = none;
		temp.__NFUN_279__();
	}
	UpdateAllAttachments();
	AttachEmittersTo3rdWeapon();
	// End:0x6D
	if(__NFUN_119__(m_FPWeapon, none))
	{
		m_FPWeapon.DestroySM();
		temp = m_FPWeapon;
		m_FPWeapon = none;
		temp.__NFUN_279__();
	}
	// End:0x96
	if(__NFUN_119__(m_ReticuleInstance, none))
	{
		temp = m_ReticuleInstance;
		m_ReticuleInstance = none;
		temp.__NFUN_279__();
	}
	// End:0xB0
	if(__NFUN_119__(m_SelectedWeaponGadget, none))
	{
		m_SelectedWeaponGadget.DestroyFPGadget();
	}
	// End:0xCA
	if(__NFUN_119__(m_MuzzleGadget, none))
	{
		m_MuzzleGadget.DestroyFPGadget();
	}
	return;
}

simulated function UpdateAllAttachments()
{
	// End:0x1B
	if(__NFUN_119__(m_SelectedWeaponGadget, none))
	{
		m_SelectedWeaponGadget.UpdateAttachment(self);
	}
	// End:0x36
	if(__NFUN_119__(m_ScopeGadget, none))
	{
		m_ScopeGadget.UpdateAttachment(self);
	}
	// End:0x51
	if(__NFUN_119__(m_MagazineGadget, none))
	{
		m_MagazineGadget.UpdateAttachment(self);
	}
	// End:0x6C
	if(__NFUN_119__(m_BipodGadget, none))
	{
		m_BipodGadget.UpdateAttachment(self);
	}
	// End:0x87
	if(__NFUN_119__(m_MuzzleGadget, none))
	{
		m_MuzzleGadget.UpdateAttachment(self);
	}
	return;
}

simulated function TurnOffEmitters(bool bTurnOff)
{
	// End:0x21
	if(__NFUN_119__(m_pEmptyShellsEmitter, none))
	{
		m_pEmptyShellsEmitter.bHidden = bTurnOff;
	}
	// End:0x42
	if(__NFUN_119__(m_pMuzzleFlashEmitter, none))
	{
		m_pMuzzleFlashEmitter.bHidden = bTurnOff;
	}
	return;
}

function ReloadShotGun()
{
	return;
}

////////////////////////////
// RATE OF FIRE FUNCTIONS //
////////////////////////////
exec function SetNextRateOfFire()
{
	Owner.__NFUN_264__(m_ChangeROFSnd, 2);
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
			if(__NFUN_129__(SetRateOfFire(0)))
			{
				SetRateOfFire(1);
			}
			// End:0x61
			break;
		// End:0x41
		case 1:
			// End:0x3E
			if(__NFUN_129__(SetRateOfFire(2)))
			{
				SetRateOfFire(0);
			}
			// End:0x61
			break;
		// End:0x5E
		case 0:
			// End:0x5B
			if(__NFUN_129__(SetRateOfFire(1)))
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
	if(__NFUN_130__(__NFUN_154__(m_stWeaponCaps.bFullAuto, 1), __NFUN_154__(int(eNewRateOfFire), int(2))))
	{
		m_eRateOfFire = 2;		
	}
	else
	{
		// End:0x5A
		if(__NFUN_130__(__NFUN_154__(m_stWeaponCaps.bThreeRound, 1), __NFUN_154__(int(eNewRateOfFire), int(1))))
		{
			m_eRateOfFire = 1;			
		}
		else
		{
			// End:0x87
			if(__NFUN_130__(__NFUN_154__(m_stWeaponCaps.bSingle, 1), __NFUN_154__(int(eNewRateOfFire), int(0))))
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

function int GetNbOfRoundsForROF()
{
	// End:0x12
	if(__NFUN_152__(int(m_iNbBulletsInWeapon), 0))
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
			// End:0x37
			case 1:
				return __NFUN_249__(3, int(m_iNbBulletsInWeapon));
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

//Called on server and client
simulated function AddClips(int iNbOfExtraClips)
{
	local int i, iNewClipCount;

	i = m_iNbOfClips;
	J0x0B:

	// End:0x57 [Loop If]
	if(__NFUN_150__(i, __NFUN_146__(m_iNbOfClips, iNbOfExtraClips)))
	{
		// End:0x4D
		if(__NFUN_150__(__NFUN_146__(m_iNbOfClips, 1), C_iMaxNbOfClips))
		{
			m_aiNbOfBullets[i] = byte(m_iClipCapacity);
			__NFUN_165__(iNewClipCount);
		}
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x0B;
	}
	__NFUN_161__(m_iNbOfClips, iNewClipCount);
	__NFUN_161__(m_iCurrentNbOfClips, iNewClipCount);
	// End:0x8E
	if(__NFUN_154__(int(Level.NetMode), int(NM_Client)))
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
	if(__NFUN_242__(IsPumpShotGun(), true))
	{
		// End:0x28
		if(__NFUN_176__(float(m_iNbBulletsInWeapon), __NFUN_171__(float(m_iClipCapacity), 0.5000000)))
		{
			return true;
		}		
	}
	else
	{
		i = 0;
		J0x32:

		// End:0x64 [Loop If]
		if(__NFUN_150__(i, m_iNbOfClips))
		{
			// End:0x5A
			if(__NFUN_154__(int(m_aiNbOfBullets[i]), m_iClipCapacity))
			{
				return true;
			}
			__NFUN_165__(i);
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
	return __NFUN_178__(m_fMaxAngleError, m_stAccuracyValues.fBaseAccuracy);
	return;
}

simulated function WeaponInitialization(Pawn pawnOwner)
{
	// End:0x1B
	if(__NFUN_154__(int(Level.NetMode), int(NM_DedicatedServer)))
	{
		return;
	}
	CreateWeaponEmitters();
	// End:0xBD
	if(__NFUN_123__(default.m_NameID, ""))
	{
		// End:0x6B
		if(__NFUN_303__('R6Gadget'))
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
	if(__NFUN_130__(__NFUN_114__(m_pMuzzleFlashEmitter, none), __NFUN_119__(m_pMuzzleFlash, none)))
	{
		m_pMuzzleFlashEmitter = __NFUN_278__(m_pMuzzleFlash);
		// End:0xCA
		if(__NFUN_130__(__NFUN_119__(m_pMuzzleFlashEmitter, none), __NFUN_151__(m_pMuzzleFlashEmitter.Emitters.Length, 4)))
		{
			__NFUN_182__(m_pMuzzleFlashEmitter.Emitters[4].StartSizeRange.X.Min, m_MuzzleScale);
			__NFUN_182__(m_pMuzzleFlashEmitter.Emitters[4].StartSizeRange.X.Max, m_MuzzleScale);
			// End:0xCA
			if(__NFUN_119__(m_FPMuzzleFlashTexture, none))
			{
				m_pMuzzleFlashEmitter.Emitters[4].Texture = m_FPMuzzleFlashTexture;
			}
		}
	}
	// End:0xF0
	if(__NFUN_130__(__NFUN_114__(m_pEmptyShellsEmitter, none), __NFUN_119__(m_pEmptyShells, none)))
	{
		m_pEmptyShellsEmitter = __NFUN_278__(m_pEmptyShells);
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
	if(__NFUN_130__(__NFUN_119__(PlayerOwner, none), __NFUN_119__(PlayerOwner.m_targetedPawn, none)))
	{
		rRotation = Rotator(__NFUN_216__(PlayerOwner.m_vAutoAimTarget, vOrigin));		
	}
	else
	{
		rRotation = pawnOwner.GetFiringRotation();
	}
	// End:0x1A2
	if(__NFUN_154__(iBulletNumber, 0))
	{
		fMaxError = __NFUN_171__(m_fMaxAngleError, 91.0220000);
		fRandValueOne = __NFUN_175__(__NFUN_171__(__NFUN_171__(__NFUN_195__(), float(2)), fMaxError), fMaxError);
		fRandValueTwo = __NFUN_175__(__NFUN_171__(__NFUN_171__(__NFUN_195__(), float(2)), fMaxError), fMaxError);
		__NFUN_161__(rRotation.Pitch, int(fRandValueOne));
		__NFUN_161__(rRotation.Yaw, int(fRandValueTwo));
		// End:0x149
		if(__NFUN_154__(int(m_eWeaponType), int(3)))
		{
			m_rBuckFirstBullet.Pitch = rRotation.Pitch;
			m_rBuckFirstBullet.Yaw = rRotation.Yaw;
		}
		// End:0x19F
		if(__NFUN_119__(PlayerOwner, none))
		{
			PlayerOwner.m_rLastBulletDirection.Pitch = int(fRandValueOne);
			PlayerOwner.m_rLastBulletDirection.Yaw = int(fRandValueTwo);
			PlayerOwner.m_rLastBulletDirection.Roll = 1;
		}		
	}
	else
	{
		rRotation.Pitch = int(__NFUN_174__(float(m_rBuckFirstBullet.Pitch), __NFUN_175__(__NFUN_171__(__NFUN_195__(), float(550)), float(275))));
		rRotation.Yaw = int(__NFUN_174__(float(m_rBuckFirstBullet.Yaw), __NFUN_175__(__NFUN_171__(__NFUN_195__(), float(550)), float(275))));
	}
	return;
}

simulated event RenderOverlays(Canvas Canvas)
{
	local R6PlayerController thePlayerController;
	local Rotator rNewRotation;

	// End:0x17
	if(__NFUN_242__(Level.m_bInGamePlanningActive, true))
	{
		return;
	}
	// End:0x3F
	if(__NFUN_132__(__NFUN_114__(Owner, none), __NFUN_114__(Pawn(Owner).Controller, none)))
	{
		return;
	}
	thePlayerController = R6PlayerController(Pawn(Owner).Controller);
	// End:0x128
	if(__NFUN_119__(thePlayerController, none))
	{
		// End:0x128
		if(__NFUN_130__(__NFUN_242__(thePlayerController.bBehindView, false), __NFUN_242__(thePlayerController.m_bUseFirstPersonWeapon, true)))
		{
			// End:0x128
			if(__NFUN_119__(m_FPHands, none))
			{
				m_FPHands.__NFUN_267__(R6Pawn(Owner).R6CalcDrawLocation(self, rNewRotation, m_vPositionOffset));
				m_FPHands.__NFUN_299__(__NFUN_316__(__NFUN_316__(Pawn(Owner).GetViewRotation(), rNewRotation), thePlayerController.m_rHitRotation));
				// End:0x128
				if(thePlayerController.ShouldDrawWeapon())
				{
					Canvas.__NFUN_467__(m_FPHands, false, true);
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
	if(__NFUN_132__(__NFUN_242__(Level.m_bInGamePlanningActive, true), __NFUN_114__(Owner, none)))
	{
		return;
	}
	aPC = R6PlayerController(Pawn(Owner).Controller);
	// End:0x10A
	if(__NFUN_130__(__NFUN_130__(__NFUN_119__(aPC, none), __NFUN_119__(m_ReticuleInstance, none)), __NFUN_129__(aPC.bBehindView)))
	{
		m_ReticuleInstance.SetReticuleInfo(Canvas);
		// End:0xBC
		if(__NFUN_132__(__NFUN_1009__().HUDShowPlayersName, aPC.m_bShowCompleteHUD))
		{
			m_ReticuleInstance.SetIdentificationReticule(Canvas);
		}
		// End:0x10A
		if(__NFUN_130__(__NFUN_132__(__NFUN_1009__().HUDShowReticule, aPC.m_bShowCompleteHUD), __NFUN_129__(aPC.m_bHideReticule)))
		{
			m_ReticuleInstance.PostRender(Canvas);
		}
	}
	return;
}

// FiringSpeed is used in UW as the rate parameter in playanim.
function Fire(float fValue)
{
	__NFUN_113__('NormalFire');
	return;
}

function ClientStartFiring()
{
	// End:0x49
	if(__NFUN_130__(__NFUN_130__(__NFUN_154__(m_iNbOfRoundsToShoot, 0), __NFUN_154__(int(m_iNbOfRoundsInBurst), 0)), R6Pawn(Owner).m_bIsPlayer))
	{
		R6Pawn(Owner).PlayLocalWeaponSound(2);
	}
	// End:0x6A
	if(__NFUN_154__(int(Level.NetMode), int(NM_Client)))
	{
		m_iNbOfRoundsInBurst = 0;
	}
	return;
}

function ServerStartFiring()
{
	m_iNbOfRoundsToShoot = GetNbOfRoundsForROF();
	// End:0x3C
	if(__NFUN_130__(__NFUN_154__(m_iNbOfRoundsToShoot, 0), __NFUN_154__(int(m_iNbOfRoundsInBurst), 0)))
	{
		R6Pawn(Owner).PlayWeaponSound(2);
	}
	m_iNbOfRoundsInBurst = 0;
	// End:0x8F
	if(__NFUN_132__(__NFUN_114__(R6PlayerController(Pawn(Owner).Controller), none), R6PlayerController(Pawn(Owner).Controller).m_bWantTriggerLag))
	{
		ClientStartFiring();
	}
	return;
}

//Added when trigger lag became an option, non-replicated version of StopFire
function LocalStopFire(optional bool bSoundOnly)
{
	// End:0x5A
	if(__NFUN_119__(R6PlayerController(Pawn(Owner).Controller), none))
	{
		// End:0x4B
		if(__NFUN_129__(R6PlayerController(Pawn(Owner).Controller).m_bWantTriggerLag))
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
function ServerStopFire(optional bool bSoundOnly)
{
	// End:0x46
	if(__NFUN_132__(__NFUN_130__(__NFUN_150__(int(m_iNbOfRoundsInBurst), 3), __NFUN_155__(int(m_eRateOfFire), int(0))), __NFUN_153__(int(m_iNbOfRoundsInBurst), 3)))
	{
		R6Pawn(Owner).PlayWeaponSound(10);
	}
	// End:0x97
	if(__NFUN_132__(__NFUN_114__(R6PlayerController(Pawn(Owner).Controller), none), R6PlayerController(Pawn(Owner).Controller).m_bWantTriggerLag))
	{
		ClientStopFire(bSoundOnly);
	}
	return;
}

//Was simply called StopFire() in the past
function ClientStopFire(optional bool bSoundOnly)
{
	// End:0x46
	if(__NFUN_132__(__NFUN_130__(__NFUN_150__(int(m_iNbOfRoundsInBurst), 3), __NFUN_155__(int(m_eRateOfFire), int(0))), __NFUN_153__(int(m_iNbOfRoundsInBurst), 3)))
	{
		R6Pawn(Owner).PlayLocalWeaponSound(10);
	}
	// End:0x104
	if(__NFUN_129__(bSoundOnly))
	{
		// End:0xE9
		if(__NFUN_119__(m_FPHands, none))
		{
			// End:0xA7
			if(__NFUN_150__(int(m_iNbOfRoundsInBurst), 3))
			{
				// End:0x95
				if(__NFUN_155__(int(Level.NetMode), int(NM_Standalone)))
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
				if(__NFUN_132__(__NFUN_151__(int(m_iNbOfRoundsInBurst), 3), __NFUN_130__(__NFUN_154__(int(m_iNbOfRoundsInBurst), 3), __NFUN_155__(int(m_eRateOfFire), int(1)))))
				{
					m_FPHands.StopFiring();
				}
			}			
		}
		else
		{
			__NFUN_113__('None');
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
	return __NFUN_132__(__NFUN_151__(int(m_iNbBulletsInWeapon), 0), __NFUN_151__(m_iCurrentNbOfClips, 1));
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
	return __NFUN_153__(int(m_iNbBulletsInWeapon), m_iClipCapacity);
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
	if(__NFUN_119__(pOwner, none))
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

function ServerFireBullet(float fMaxAngleErrorFromClient)
{
	local Vector vStartTrace;
	local Rotator rBulletRot;
	local int iCurrentBullet;
	local R6Pawn pawnOwner;
	local R6AbstractBulletManager BulletManager;

	// End:0x0F
	if(__NFUN_154__(int(m_iNbBulletsInWeapon), 0))
	{
		return;
	}
	pawnOwner = R6Pawn(Owner);
	BulletManager = GetBulletManager();
	__NFUN_139__(m_iNbOfRoundsInBurst);
	__NFUN_140__(m_iNbBulletsInWeapon);
	// End:0x95
	if(__NFUN_130__(__NFUN_154__(int(m_iNbBulletsInWeapon), 0), __NFUN_129__(IsPumpShotGun())))
	{
		// End:0x75
		if(__NFUN_129__(__NFUN_130__(__NFUN_154__(m_iCurrentNbOfClips, 1), m_bUnlimitedClip)))
		{
			__NFUN_166__(m_iCurrentNbOfClips);			
		}
		else
		{
			m_bEmptyAllClips = true;
			// End:0x95
			if(__NFUN_119__(R6Rainbow(Owner), none))
			{
				m_iClipCapacity = 5;
			}
		}
	}
	bFiredABullet = true;
	// End:0xCC
	if(__NFUN_130__(pawnOwner.m_bIsProne, GotBipod()))
	{
		pawnOwner.UpdateBipodPosture();		
	}
	else
	{
		pawnOwner.PlayWeaponAnimation();
	}
	m_fMaxAngleError = fMaxAngleErrorFromClient;
	iCurrentBullet = 0;
	J0xED:

	// End:0x142 [Loop If]
	if(__NFUN_150__(iCurrentBullet, NbBulletToShot()))
	{
		GetFiringDirection(vStartTrace, rBulletRot, iCurrentBullet);
		BulletManager.SpawnBullet(vStartTrace, rBulletRot, m_fMuzzleVelocity, __NFUN_154__(iCurrentBullet, 0));
		__NFUN_165__(iCurrentBullet);
		// [Loop Continue]
		goto J0xED;
	}
	// End:0x170
	if(__NFUN_119__(pawnOwner, none))
	{
		R6AbstractGameInfo(Level.Game).IncrementRoundsFired(pawnOwner, false);
	}
	__NFUN_184__(m_fCurrentFireJump, m_stAccuracyValues.fWeaponJump);
	// End:0x1DF
	if(__NFUN_154__(int(m_iNbBulletsInWeapon), 0))
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
				if(__NFUN_154__(int(m_iNbOfRoundsInBurst), 1))
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
		if(__NFUN_154__(int(m_iNbOfRoundsInBurst), 1))
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
					if(__NFUN_153__(m_iNbOfRoundsToShoot, 3))
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
	if(__NFUN_154__(int(Level.NetMode), int(NM_Client)))
	{
		__NFUN_139__(m_iNbOfRoundsInBurst);
	}
	pawnOwner = R6Pawn(Owner);
	PlayerOwner = R6PlayerController(pawnOwner.Controller);
	// End:0x1EE
	if(pawnOwner.m_bIsPlayer)
	{
		// End:0xF3
		if(__NFUN_130__(__NFUN_119__(m_FPHands, none), __NFUN_151__(int(m_iNbBulletsInWeapon), 0)))
		{
			// End:0x97
			if(__NFUN_154__(int(m_eRateOfFire), int(0)))
			{
				m_FPHands.FireSingleShot();				
			}
			else
			{
				// End:0xC8
				if(__NFUN_130__(__NFUN_154__(int(m_eRateOfFire), int(1)), __NFUN_154__(int(m_iNbOfRoundsInBurst), 1)))
				{
					m_FPHands.FireThreeShots();					
				}
				else
				{
					// End:0xE4
					if(__NFUN_154__(int(m_iNbOfRoundsInBurst), 1))
					{
						m_FPHands.StartBurst();
					}
				}
			}
			m_FPWeapon.PlayFireAnim();
		}
		// End:0x1EE
		if(__NFUN_119__(Viewport(PlayerOwner.Player), none))
		{
			// End:0x16A
			if(__NFUN_154__(int(m_iNbBulletsInWeapon), 0))
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
						if(__NFUN_153__(int(m_iNbOfRoundsInBurst), 1))
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
				if(__NFUN_154__(int(m_iNbOfRoundsInBurst), 1))
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
							if(__NFUN_153__(int(m_iNbBulletsInWeapon), 3))
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
		if(__NFUN_155__(int(Role), int(ROLE_Authority)))
		{
			GetFiringDirection(vStartTrace, rBulletRot);
		}
		// End:0x228
		if(__NFUN_119__(PlayerOwner, none))
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
	if(__NFUN_132__(__NFUN_114__(R6PlayerController(Pawn(Owner).Controller), none), R6PlayerController(Pawn(Owner).Controller).m_bWantTriggerLag))
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
		if(__NFUN_119__(m_FPHands, none))
		{
			// End:0xCC
			if(__NFUN_242__(IsLMG(), true))
			{
				// End:0xCC
				if(__NFUN_150__(int(m_iNbBulletsInWeapon), 8))
				{
					m_FPWeapon.HideBullet(int(m_iNbBulletsInWeapon));
				}
			}
			// End:0xF7
			if(__NFUN_154__(int(iBulletNbFired), 0))
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
		if(__NFUN_152__(int(m_iNbBulletsInWeapon), 0))
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
	if(__NFUN_152__(int(m_iNbBulletsInWeapon), 0))
	{
		R6Pawn(Owner).PlayWeaponSound(8);		
	}
	else
	{
		R6Pawn(Owner).PlayWeaponSound(9);
	}
	// End:0x87
	if(__NFUN_132__(__NFUN_114__(R6PlayerController(Pawn(Owner).Controller), none), R6PlayerController(Pawn(Owner).Controller).m_bWantTriggerLag))
	{
		ClientStartChangeClip();
	}
	return;
}

function ServerChangeClip()
{
	local int i, iClipNumber, iMostFullClip, iMaxNbOfRounds, iBulletLeftInWeapon;

	R6MakeNoise(10);
	// End:0x3D
	if(__NFUN_130__(__NFUN_130__(m_bUnlimitedClip, __NFUN_154__(GetNbOfClips(), 1)), __NFUN_242__(m_bEmptyAllClips, true)))
	{
		m_iNbBulletsInWeapon = byte(m_iClipCapacity);		
	}
	else
	{
		m_aiNbOfBullets[m_iCurrentClip] = m_iNbBulletsInWeapon;
		// End:0x6B
		if(__NFUN_154__(int(m_aiNbOfBullets[m_iCurrentClip]), 0))
		{
			iBulletLeftInWeapon = 0;			
		}
		else
		{
			// End:0xFB
			if(__NFUN_129__(IsPumpShotGun()))
			{
				// End:0xBF
				if(IsLMG())
				{
					// End:0xBC
					if(__NFUN_130__(__NFUN_150__(int(m_aiNbOfBullets[m_iCurrentClip]), 8), __NFUN_155__(m_iCurrentNbOfClips, 1)))
					{
						m_aiNbOfBullets[m_iCurrentClip] = 0;
						__NFUN_166__(m_iCurrentNbOfClips);
						iBulletLeftInWeapon = 0;
					}					
				}
				else
				{
					__NFUN_136__(m_aiNbOfBullets[m_iCurrentClip], byte(1));
					// End:0xF4
					if(__NFUN_154__(int(m_aiNbOfBullets[m_iCurrentClip]), 0))
					{
						// End:0xF4
						if(__NFUN_155__(m_iCurrentNbOfClips, 1))
						{
							__NFUN_166__(m_iCurrentNbOfClips);
						}
					}
					iBulletLeftInWeapon = 1;
				}
			}
		}
		iMostFullClip = m_iCurrentClip;
		i = 0;
		J0x10D:

		// End:0x188 [Loop If]
		if(__NFUN_150__(i, m_iNbOfClips))
		{
			iClipNumber = __NFUN_146__(m_iCurrentClip, i);
			// End:0x149
			if(__NFUN_153__(iClipNumber, m_iNbOfClips))
			{
				__NFUN_162__(iClipNumber, m_iNbOfClips);
			}
			// End:0x17E
			if(__NFUN_151__(int(m_aiNbOfBullets[iClipNumber]), iMaxNbOfRounds))
			{
				iMaxNbOfRounds = int(m_aiNbOfBullets[iClipNumber]);
				iMostFullClip = iClipNumber;
			}
			__NFUN_165__(i);
			// [Loop Continue]
			goto J0x10D;
		}
		m_iCurrentClip = iMostFullClip;
		__NFUN_135__(m_aiNbOfBullets[m_iCurrentClip], byte(iBulletLeftInWeapon));
		m_iNbBulletsInWeapon = m_aiNbOfBullets[m_iCurrentClip];
	}
	R6Pawn(Owner).ServerSwitchReloadingWeapon(false);
	return;
}

simulated function PlayReloading()
{
	__NFUN_113__('Reloading');
	return;
}

simulated function WeaponZoomSound(bool bFirstZoom)
{
	// End:0x4B
	if(bFirstZoom)
	{
		// End:0x2A
		if(__NFUN_119__(m_SniperZoomFirstSnd, none))
		{
			Owner.__NFUN_264__(m_SniperZoomFirstSnd, 2);			
		}
		else
		{
			// End:0x48
			if(__NFUN_119__(m_CommonWeaponZoomSnd, none))
			{
				Owner.__NFUN_264__(m_CommonWeaponZoomSnd, 2);
			}
		}		
	}
	else
	{
		// End:0x69
		if(__NFUN_119__(m_SniperZoomSecondSnd, none))
		{
			Owner.__NFUN_264__(m_SniperZoomSecondSnd, 2);
		}
	}
	return;
}

simulated event DeployWeaponBipod(bool bBipodOpen)
{
	// End:0x20
	if(__NFUN_119__(m_BipodGadget, none))
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
	if(__NFUN_155__(int(Level.NetMode), int(NM_Standalone)))
	{
		return;
	}
	m_iNbBulletsInWeapon = 250;
	iClip = 0;
	J0x2A:

	// End:0x51 [Loop If]
	if(__NFUN_150__(iClip, C_iMaxNbOfClips))
	{
		m_aiNbOfBullets[iClip] = 250;
		__NFUN_165__(iClip);
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
	if(__NFUN_119__(aBulletClass, none))
	{
		m_pBulletClass = aBulletClass;
	}
	return;
}

function bool HasBulletType(name strBulletName)
{
	// End:0x0D
	if(__NFUN_114__(m_pBulletClass, none))
	{
		return false;
	}
	return __NFUN_254__(strBulletName, m_pBulletClass.Name);
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
	if(__NFUN_114__(pWeaponGadgetClass, none))
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
				if(__NFUN_119__(m_ScopeGadget, none))
				{
					return;
				}
				// End:0x8C
				break;
			// End:0x4F
			case 2:
				// End:0x4C
				if(__NFUN_119__(m_MagazineGadget, none))
				{
					return;
				}
				// End:0x8C
				break;
			// End:0x64
			case 3:
				// End:0x61
				if(__NFUN_119__(m_BipodGadget, none))
				{
					return;
				}
				// End:0x8C
				break;
			// End:0x79
			case 4:
				// End:0x76
				if(__NFUN_119__(m_MuzzleGadget, none))
				{
					return;
				}
				// End:0x8C
				break;
			// End:0xFFFF
			default:
				// End:0x89
				if(__NFUN_119__(m_SelectedWeaponGadget, none))
				{
					return;
				}
				// End:0x8C
				break;
				break;
		}
		SelectedWeaponGadget = __NFUN_278__(pWeaponGadgetClass);
		// End:0x12C
		if(__NFUN_119__(SelectedWeaponGadget, none))
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
	if(__NFUN_119__(m_MagazineGadget, none))
	{
		m_MagazineGadget.bAlwaysRelevant = bAlwaysRelevant;
	}
	// End:0x4F
	if(__NFUN_119__(m_SelectedWeaponGadget, none))
	{
		m_SelectedWeaponGadget.bAlwaysRelevant = bAlwaysRelevant;
	}
	// End:0x70
	if(__NFUN_119__(m_ScopeGadget, none))
	{
		m_ScopeGadget.bAlwaysRelevant = bAlwaysRelevant;
	}
	// End:0x91
	if(__NFUN_119__(m_BipodGadget, none))
	{
		m_BipodGadget.bAlwaysRelevant = bAlwaysRelevant;
	}
	// End:0xB2
	if(__NFUN_119__(m_MuzzleGadget, none))
	{
		m_MuzzleGadget.bAlwaysRelevant = bAlwaysRelevant;
	}
	return;
}

function SetTearOff(bool bNewTearOff)
{
	bTearOff = bNewTearOff;
	// End:0x2E
	if(__NFUN_119__(m_MagazineGadget, none))
	{
		m_MagazineGadget.bTearOff = bTearOff;
	}
	// End:0x4F
	if(__NFUN_119__(m_SelectedWeaponGadget, none))
	{
		m_SelectedWeaponGadget.bTearOff = bTearOff;
	}
	// End:0x70
	if(__NFUN_119__(m_ScopeGadget, none))
	{
		m_ScopeGadget.bTearOff = bTearOff;
	}
	// End:0x91
	if(__NFUN_119__(m_BipodGadget, none))
	{
		m_BipodGadget.bTearOff = bTearOff;
	}
	// End:0xB2
	if(__NFUN_119__(m_MuzzleGadget, none))
	{
		m_MuzzleGadget.bTearOff = bTearOff;
	}
	return;
}

//============================================================================
// function HitWall - Bounce when the weapon fall of a dead pawn
//============================================================================
simulated function HitWall(Vector HitNormal, Actor Wall)
{
	__NFUN_139__(m_wNbOfBounce);
	RotationRate.Pitch = 0;
	RotationRate.Yaw = int(RandRange(-65535.0000000, 65535.0000000));
	RotationRate.Roll = int(RandRange(-65535.0000000, 65535.0000000));
	// End:0x7F
	if(__NFUN_176__(HitNormal.Z, 0.1000000))
	{
		Velocity = __NFUN_213__(__NFUN_171__(0.7500000, __NFUN_225__(Velocity)), HitNormal);		
	}
	else
	{
		Velocity = __NFUN_213__(0.1500000, __NFUN_300__(Velocity, HitNormal));
		__NFUN_182__(Velocity.Z, float(2));
		// End:0xCD
		if(__NFUN_176__(__NFUN_225__(Velocity), float(10)))
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
	if(__NFUN_151__(int(m_wNbOfBounce), 20))
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

	vNewLocation = __NFUN_216__(Location, vect(0.0000000, 0.0000000, 10.0000000));
	aTraced = __NFUN_1806__(vHitLocation, vNormal, vNewLocation, Location, 0);
	// End:0xB4
	if(__NFUN_114__(aTraced, none))
	{
		// End:0x6A
		if(__NFUN_1800__(vNewLocation))
		{
			// End:0x67
			if(__NFUN_218__(vNewLocation, Location))
			{
				__NFUN_267__(vNewLocation);
				return true;
			}			
		}
		else
		{
			vNewLocation = m_vPawnLocWhenKilled;
			vNewLocation.Z = __NFUN_175__(Location.Z, float(10));
			// End:0xB4
			if(__NFUN_1800__(vNewLocation))
			{
				// End:0xB4
				if(__NFUN_218__(vNewLocation, Location))
				{
					__NFUN_267__(vNewLocation);
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
	__NFUN_3970__(5);
	bBounce = false;
	bRotateToDesired = true;
	DesiredRotation.Yaw = Rotation.Yaw;
	// End:0x6C
	if(__NFUN_177__(__NFUN_186__(float(__NFUN_147__(Rotation.Roll, 13384))), __NFUN_186__(float(__NFUN_147__(Rotation.Roll, 49151)))))
	{
		DesiredRotation.Roll = 49151;		
	}
	else
	{
		DesiredRotation.Roll = 13384;
	}
	// End:0xAB
	if(__NFUN_150__(DesiredRotation.Roll, Rotation.Roll))
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
	__NFUN_267__(m_vPawnLocWhenKilled, true);
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
	if(__NFUN_119__(Owner, none))
	{
		m_vPawnLocWhenKilled = Owner.Location;
		__NFUN_185__(m_vPawnLocWhenKilled.Z, Owner.CollisionHeight);
		Owner.DetachFromBone(self);		
	}
	else
	{
		m_vPawnLocWhenKilled = Location;
	}
	m_iNbParticlesToCreate = 0;
	__NFUN_113__('None');
	__NFUN_283__(35.0000000, 5.0000000);
	vLocation = Location;
	m_bLightingVisibility = true;
	// End:0x1A1
	if(__NFUN_1800__(vLocation))
	{
		__NFUN_267__(vLocation);
		__NFUN_262__(true, false, false);
		bCollideWorld = true;
		bBounce = true;
		__NFUN_117__('HitWall');
		__NFUN_3970__(2);
		vDir = Vector(Rotation);
		__NFUN_184__(vDir.X, RandRange(-0.4000000, 0.4000000));
		__NFUN_184__(vDir.Y, RandRange(-0.4000000, 0.4000000));
		__NFUN_221__(vDir, RandRange(100.0000000, 400.0000000));
		vDir.Z = -600.0000000;
		Acceleration = vDir;
		bFixedRotationDir = true;
		RotationRate.Pitch = 0;
		RotationRate.Yaw = int(RandRange(-65535.0000000, 65535.0000000));
		RotationRate.Roll = int(RandRange(-65535.0000000, 65535.0000000));
		rRot = Rotation;
		rRot.Pitch = 0;
		__NFUN_299__(rRot);		
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
			m_iNbParticlesToCreate = __NFUN_249__(3, int(m_iNbBulletsInWeapon));
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

state NormalFire
{
// FiringSpeed is used in UW as the rate parameter in playanim.
	function Fire(float Value)
	{
		// End:0x12
		if(__NFUN_242__(m_bFireOn, false))
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
		if(__NFUN_242__(m_bFireOn, true))
		{
			m_bFireOn = false;
			__NFUN_280__(0.0000000, false);
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
			__NFUN_113__('None');			
		}
		else
		{
			// End:0x94
			if(__NFUN_130__(__NFUN_154__(int(Pawn(Owner).Controller.bFire), 1), __NFUN_154__(int(m_eRateOfFire), int(2))))
			{
				LocalStopFire(true);
				StartFiring();
				return;				
			}
			else
			{
				// End:0xB6
				if(__NFUN_130__(__NFUN_151__(m_iNbOfRoundsToShoot, 0), __NFUN_154__(int(m_eRateOfFire), int(1))))
				{
					return;					
				}
				else
				{
					__NFUN_113__('None');
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
		m_iNbOfRoundsToShoot = GetNbOfRoundsForROF();
		ServerStartFiring();
		// End:0x5F
		if(__NFUN_130__(__NFUN_119__(R6PlayerController(Pawn(Owner).Controller), none), __NFUN_129__(R6PlayerController(Pawn(Owner).Controller).m_bWantTriggerLag)))
		{
			ClientStartFiring();
		}
		// End:0x9F
		if(__NFUN_119__(R6PlayerController(Pawn(Owner).Controller), none))
		{
			R6PlayerController(Pawn(Owner).Controller).ResetCameraShake();
		}
		// End:0xFF
		if(__NFUN_155__(m_iNbOfRoundsToShoot, 0))
		{
			// End:0xC5
			if(__NFUN_119__(m_FPHands, none))
			{
				m_FPHands.__NFUN_113__('FiringWeapon');
			}
			DoSingleFire();
			// End:0xEA
			if(__NFUN_155__(m_iNbOfRoundsToShoot, 0))
			{
				__NFUN_280__(m_fRateOfFire, true);
				m_bFireOn = true;				
			}
			else
			{
				// End:0xFC
				if(__NFUN_114__(m_FPHands, none))
				{
					__NFUN_113__('None');
				}
			}			
		}
		else
		{
			// End:0x124
			if(m_FPHands.__NFUN_263__('FireEmpty'))
			{
				m_FPHands.__NFUN_259__('FireEmpty');
			}
			__NFUN_113__('None');
		}
		return;
	}

	simulated function Timer()
	{
		__NFUN_166__(m_iNbOfRoundsToShoot);
		// End:0x53
		if(__NFUN_130__(__NFUN_151__(m_iNbOfRoundsToShoot, 0), __NFUN_132__(__NFUN_154__(int(m_eRateOfFire), int(1)), __NFUN_154__(int(Pawn(Owner).Controller.bFire), 1))))
		{
			DoSingleFire();			
		}
		else
		{
			m_bFireOn = false;
			__NFUN_280__(0.0000000, false);
			StopFire(false);
		}
		return;
	}

	function DoSingleFire()
	{
		ServerFireBullet(m_fMaxAngleError);
		// End:0x58
		if(__NFUN_130__(__NFUN_119__(R6PlayerController(Pawn(Owner).Controller), none), __NFUN_129__(R6PlayerController(Pawn(Owner).Controller).m_bWantTriggerLag)))
		{
			ClientShowBulletFire();
		}
		return;
	}
	stop;
}

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
		if(__NFUN_119__(pawnOwner.Controller, none))
		{
			R6Pawn(Owner).ServerSwitchReloadingWeapon(false);
		}
		ServerChangeClip();
		// End:0x7E
		if(__NFUN_130__(__NFUN_119__(pawnOwner.Controller, none), __NFUN_154__(int(pawnOwner.Controller.bFire), 1)))
		{
			__NFUN_113__('NormalFire');			
		}
		else
		{
			__NFUN_113__('None');
		}
		return;
	}

	simulated function ChangeClip()
	{
		R6Pawn(Owner).ServerSwitchReloadingWeapon(false);
		ServerChangeClip();
		// End:0x49
		if(__NFUN_154__(int(Pawn(Owner).Controller.bFire), 1))
		{
			__NFUN_113__('NormalFire');			
		}
		else
		{
			__NFUN_113__('None');
		}
		return;
	}

	function EndState()
	{
		local R6PlayerController PlayerCtrl;

		PlayerCtrl = R6PlayerController(Pawn(Owner).Controller);
		// End:0x5B
		if(__NFUN_119__(PlayerCtrl, none))
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
		if(__NFUN_132__(__NFUN_151__(GetNbOfClips(), 0), __NFUN_130__(__NFUN_155__(int(Level.NetMode), int(NM_Standalone)), __NFUN_154__(int(m_eWeaponType), int(0)))))
		{
			// End:0x8D
			if(__NFUN_119__(PlayerCtrl, none))
			{
				PlayerCtrl.m_bLockWeaponActions = true;
				// End:0x8D
				if(__NFUN_129__(PlayerCtrl.m_bWantTriggerLag))
				{
					ClientStartChangeClip();
				}
			}
			ServerStartChangeClip();
			// End:0x10E
			if(R6Pawn(Owner).m_bIsPlayer)
			{
				// End:0x10E
				if(__NFUN_242__(PlayerCtrl.bBehindView, false))
				{
					// End:0xDD
					if(__NFUN_152__(int(m_iNbBulletsInWeapon), 0))
					{
						m_FPHands.m_bReloadEmpty = true;
					}
					m_FPHands.__NFUN_113__('Reloading');
					PlayerCtrl.m_iPlayerCAProgress = 0;
					PlayerCtrl.m_bHideReticule = true;
				}
			}			
		}
		else
		{
			__NFUN_113__('None');
		}
		return;
	}

	function int GetReloadProgress()
	{
		local name Anim;
		local float fFrame, fRate;

		m_FPHands.GetAnimParams(0, Anim, fFrame, fRate);
		return int(__NFUN_171__(fFrame, float(110)));
		return;
	}

	event Tick(float fDeltaTime)
	{
		local R6PlayerController PlayerCtrl;

		PlayerCtrl = R6PlayerController(Pawn(Owner).Controller);
		// End:0x54
		if(__NFUN_130__(__NFUN_119__(PlayerCtrl, none), __NFUN_129__(PlayerCtrl.ShouldDrawWeapon())))
		{
			PlayerCtrl.m_iPlayerCAProgress = GetReloadProgress();
		}
		return;
	}
	stop;
}

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
		if(__NFUN_119__(Pawn(Owner).Controller, none))
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
		if(__NFUN_119__(m_FPHands, none))
		{
			// End:0x45
			if(__NFUN_119__(PlayerCtrl, none))
			{
				PlayerCtrl.m_bHideReticule = true;
			}
			m_FPHands.__NFUN_113__('DiscardWeapon');
		}
		// End:0x71
		if(__NFUN_119__(PlayerCtrl, none))
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
		if(__NFUN_119__(PlayerCtrl, none))
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
		if(__NFUN_119__(Pawn(Owner).Controller, none))
		{
			R6PlayerController(Pawn(Owner).Controller).ServerWeaponUpAnimDone();
		}
		R6Pawn(Owner).m_bChangingWeapon = false;
		// End:0x9A
		if(__NFUN_130__(__NFUN_119__(Pawn(Owner).Controller, none), __NFUN_154__(int(Pawn(Owner).Controller.bFire), 1)))
		{
			__NFUN_113__('NormalFire');			
		}
		else
		{
			__NFUN_113__('None');
		}
		return;
	}

	simulated function BeginState()
	{
		TurnOffEmitters(false);
		// End:0x75
		if(__NFUN_119__(m_FPHands, none))
		{
			// End:0x30
			if(__NFUN_242__(m_bPawnIsWalking, true))
			{
				m_FPHands.PlayWalkingAnimation();				
			}
			else
			{
				m_FPHands.StopWalkingAnimation();
			}
			// End:0x65
			if(m_FPHands.__NFUN_281__('RaiseWeapon'))
			{
				m_FPHands.BeginState();				
			}
			else
			{
				m_FPHands.__NFUN_113__('RaiseWeapon');
			}
		}
		return;
	}
	stop;
}

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
		if(__NFUN_119__(m_FPHands, none))
		{
			// End:0x28
			if(m_FPHands.__NFUN_281__('FiringWeapon'))
			{
				__NFUN_113__('None');
				return;
			}
			m_FPHands.__NFUN_113__('PutWeaponDown');
		}
		R6Pawn(Owner).m_bWeaponTransition = false;
		// End:0x86
		if(__NFUN_119__(Pawn(Owner).Controller, none))
		{
			Pawn(Owner).Controller.m_bLockWeaponActions = true;
		}
		return;
	}
	stop;
}

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
		if(__NFUN_130__(__NFUN_119__(Pawn(Owner).Controller, none), __NFUN_154__(int(Pawn(Owner).Controller.bFire), 1)))
		{
			__NFUN_113__('NormalFire');			
		}
		else
		{
			__NFUN_113__('None');
		}
		return;
	}

	simulated function BeginState()
	{
		// End:0x1E
		if(__NFUN_119__(m_FPHands, none))
		{
			m_FPHands.__NFUN_113__('BringWeaponUp');			
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
		if(__NFUN_119__(Pawn(Owner).Controller, none))
		{
			Pawn(Owner).Controller.m_bHideReticule = false;
			Pawn(Owner).Controller.m_bLockWeaponActions = false;
		}
		return;
	}
	stop;
}

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
		if(__NFUN_130__(__NFUN_119__(Pawn(Owner).Controller, none), __NFUN_154__(int(Pawn(Owner).Controller.bFire), 1)))
		{
			__NFUN_113__('NormalFire');			
		}
		else
		{
			__NFUN_113__('None');
		}
		return;
	}

	simulated function BeginState()
	{
		// End:0x1B
		if(__NFUN_119__(m_FPHands, none))
		{
			m_FPHands.__NFUN_113__('DeployBipod');
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
		if(__NFUN_130__(__NFUN_119__(Pawn(Owner).Controller, none), __NFUN_154__(int(Pawn(Owner).Controller.bFire), 1)))
		{
			__NFUN_113__('NormalFire');			
		}
		else
		{
			__NFUN_113__('None');
		}
		return;
	}

	simulated function BeginState()
	{
		// End:0x1B
		if(__NFUN_119__(m_FPHands, none))
		{
			m_FPHands.__NFUN_113__('CloseBipod');
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
		if(__NFUN_119__(pawnOwner.Controller, none))
		{
			R6PlayerController(pawnOwner.Controller).DoZoom();
		}
		// End:0x80
		if(__NFUN_130__(__NFUN_119__(pawnOwner.Controller, none), __NFUN_154__(int(pawnOwner.Controller.bFire), 1)))
		{
			__NFUN_113__('NormalFire');			
		}
		else
		{
			__NFUN_113__('None');
		}
		return;
	}

	simulated function BeginState()
	{
		Pawn(Owner).Controller.m_bLockWeaponActions = true;
		WeaponZoomSound(true);
		// End:0x41
		if(__NFUN_119__(m_FPHands, none))
		{
			m_FPHands.__NFUN_113__('ZoomIn');
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
		if(__NFUN_130__(__NFUN_119__(Pawn(Owner).Controller, none), __NFUN_154__(int(Pawn(Owner).Controller.bFire), 1)))
		{
			__NFUN_113__('NormalFire');			
		}
		else
		{
			__NFUN_113__('None');
		}
		return;
	}

	simulated function BeginState()
	{
		// End:0x1B
		if(__NFUN_119__(m_FPHands, none))
		{
			m_FPHands.__NFUN_113__('ZoomOut');
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
