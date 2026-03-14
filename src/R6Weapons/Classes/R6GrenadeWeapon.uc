//=============================================================================
// R6GrenadeWeapon - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6GrenadeWeapon.uc : "Weapon" used for throwing grenades
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/07/09 * Created by Sebastien Lussier
//    2001/11/07 * taken over by Joel Tremblay
//=============================================================================
class R6GrenadeWeapon extends R6Gadget
    abstract
    native;

var Pawn.eGrenadeThrow m_eThrow;
var bool m_bCanThrowGrenade;
var bool m_bFistPersonAnimFinish;
var bool m_bPinToRemove;
var bool m_bReadyToThrow;

replication
{
	// Pos:0x01A
	unreliable if(__NFUN_150__(int(Role), int(ROLE_Authority)))
		ServerImReadyToThrow, ServerSetThrow;

	// Pos:0x000
	reliable if(__NFUN_154__(int(Role), int(ROLE_Authority)))
		ClientThrowGrenade;

	// Pos:0x00D
	reliable if(__NFUN_150__(int(Role), int(ROLE_Authority)))
		ServerSetGrenade;
}

simulated function PostBeginPlay()
{
	local R6RainbowAI localRainbowAI;

	super(R6Weapons).PostBeginPlay();
	// End:0x25
	if(__NFUN_119__(m_pBulletClass, none))
	{
		SetStaticMesh(m_pBulletClass.default.StaticMesh);
	}
	// End:0xA5
	if(__NFUN_119__(Pawn(Owner), none))
	{
		// End:0xA5
		if(__NFUN_119__(Pawn(Owner).Controller, none))
		{
			localRainbowAI = R6RainbowAI(Pawn(Owner).Controller);
			// End:0xA5
			if(__NFUN_130__(__NFUN_119__(localRainbowAI, none), __NFUN_119__(localRainbowAI.m_TeamManager, none)))
			{
				localRainbowAI.m_TeamManager.UpdateTeamGrenadeStatus();
			}
		}
	}
	return;
}

function ServerImReadyToThrow(bool bReady)
{
	m_bReadyToThrow = bReady;
	return;
}

simulated function DropGrenade()
{
	local R6Grenade aGrenade;
	local Vector vStart;

	// End:0x39
	if(R6Pawn(Owner).m_bIsPlayer)
	{
		vStart = R6Pawn(Owner).GetGrenadeStartLocation(m_eThrow);		
	}
	else
	{
		vStart = R6Pawn(Owner).GetHandLocation();
	}
	aGrenade = R6Grenade(__NFUN_278__(m_pBulletClass, self,, vStart));
	aGrenade.Instigator = Pawn(Owner);
	aGrenade.SetSpeed(0.0000000);
	return;
}

simulated function StartFalling()
{
	// End:0x49
	if(__NFUN_155__(int(m_iNbBulletsInWeapon), 0))
	{
		// End:0x43
		if(__NFUN_242__(m_bReadyToThrow, true))
		{
			bHidden = true;
			// End:0x40
			if(__NFUN_155__(int(Level.NetMode), int(NM_Client)))
			{
				DropGrenade();
			}			
		}
		else
		{
			super(R6Weapons).StartFalling();
		}
	}
	return;
}

function float GetExplosionDelay()
{
	// End:0x14
	if(__NFUN_114__(m_pBulletClass, none))
	{
		return 2.0000000;		
	}
	else
	{
		return m_pBulletClass.default.m_fExplosionDelay;
	}
	return;
}

function Fire(float fValue)
{
	__NFUN_113__('StandByToThrow');
	return;
}

function ServerSetThrow(Pawn.eGrenadeThrow eThrow)
{
	m_eThrow = eThrow;
	return;
}

function ServerSetGrenade(Pawn.eGrenadeThrow eGrenade)
{
	local R6Pawn pawnOwner;

	pawnOwner = R6Pawn(Owner);
	pawnOwner.m_ePlayerIsUsingHands = 0;
	pawnOwner.m_eGrenadeThrow = eGrenade;
	pawnOwner.m_eRepGrenadeThrow = eGrenade;
	pawnOwner.PlayWeaponAnimation();
	// End:0x75
	if(bShowLog)
	{
		__NFUN_231__("ServerSetGrenade");
	}
	return;
}

function DestroyReticules()
{
	local R6Reticule aReticule;

	aReticule = m_ReticuleInstance;
	m_ReticuleInstance = none;
	// End:0x29
	if(__NFUN_119__(aReticule, none))
	{
		aReticule.__NFUN_279__();
	}
	return;
}

function ThrowGrenade()
{
	local Vector vStart;
	local Rotator rFiringDir;
	local R6Grenade aGrenade;
	local R6RainbowAI localRainbowAI;
	local R6Pawn pawnOwner;

	pawnOwner = R6Pawn(Owner);
	// End:0x173
	if(__NFUN_151__(int(m_iNbBulletsInWeapon), 0))
	{
		__NFUN_140__(m_iNbBulletsInWeapon);
		// End:0x97
		if(__NFUN_130__(__NFUN_154__(int(m_iNbBulletsInWeapon), 0), __NFUN_119__(pawnOwner, none)))
		{
			SetStaticMesh(none);
			localRainbowAI = R6RainbowAI(pawnOwner.Controller);
			// End:0x97
			if(__NFUN_130__(__NFUN_119__(localRainbowAI, none), __NFUN_119__(localRainbowAI.m_TeamManager, none)))
			{
				localRainbowAI.m_TeamManager.UpdateTeamGrenadeStatus();
			}
		}
		GetFiringDirection(vStart, rFiringDir);
		// End:0xD6
		if(pawnOwner.m_bIsPlayer)
		{
			vStart = pawnOwner.GetGrenadeStartLocation(m_eThrow);			
		}
		else
		{
			vStart = pawnOwner.GetHandLocation();
		}
		aGrenade = R6Grenade(__NFUN_278__(m_pBulletClass, self,, vStart, rFiringDir));
		aGrenade.Instigator = pawnOwner;
		m_bReadyToThrow = false;
		// End:0x159
		if(__NFUN_242__(pawnOwner.m_bIsProne, true))
		{
			aGrenade.SetSpeed(__NFUN_171__(m_fMuzzleVelocity, 0.5000000));			
		}
		else
		{
			aGrenade.SetSpeed(m_fMuzzleVelocity);
		}
		ClientThrowGrenade();
	}
	return;
}

function ClientThrowGrenade()
{
	m_bCanThrowGrenade = true;
	return;
}

//------------------------------------------------------------------
// GetSaveDistanceToThrow: return the save distance from the grenade
//	to be for avoiding any harm.
//------------------------------------------------------------------
function float GetSaveDistanceToThrow()
{
	// End:0x29
	if(__NFUN_177__(m_pBulletClass.default.m_fKillBlastRadius, float(30)))
	{
		return m_pBulletClass.default.m_fExplosionRadius;		
	}
	else
	{
		return 0.0000000;
	}
	return;
}

simulated function WeaponInitialization(Pawn pawnOwner)
{
	super(R6Weapons).WeaponInitialization(pawnOwner);
	// End:0x26
	if(__NFUN_154__(int(Level.NetMode), int(NM_DedicatedServer)))
	{
		return;
	}
	// End:0x39
	if(__NFUN_154__(int(m_iNbBulletsInWeapon), 0))
	{
		HideAttachment();
	}
	return;
}

simulated event HideAttachment()
{
	super(R6Weapons).HideAttachment();
	// End:0x3A
	if(bShowLog)
	{
		__NFUN_231__(__NFUN_168__(__NFUN_168__("***** HideAttachment for", string(self)), "******"));
	}
	SetDrawType(0);
	return;
}

function bool CanSwitchToWeapon()
{
	// End:0x12
	if(__NFUN_151__(int(m_iNbBulletsInWeapon), 0))
	{
		return true;		
	}
	else
	{
		return false;
	}
	return;
}

state StandByToThrow
{
	function BeginState()
	{
		local R6PlayerController PController;

		R6Pawn(Owner).m_bIsFiringState = false;
		// End:0x44
		if(bShowLog)
		{
			__NFUN_231__("**** IN  STANDBY TO THROW *******");
		}
		// End:0xFE
		if(__NFUN_154__(int(m_iNbBulletsInWeapon), 0))
		{
			// End:0x99
			if(bShowLog)
			{
				__NFUN_231__("**** No more Grenades, Autoswitch to Primary Weapon *******");
			}
			PController = R6PlayerController(Pawn(Owner).Controller);
			// End:0xFE
			if(__NFUN_119__(PController, none))
			{
				// End:0xEF
				if(__NFUN_119__(R6Pawn(Owner).m_WeaponsCarried[0], none))
				{
					PController.PrimaryWeapon();					
				}
				else
				{
					PController.SecondaryWeapon();
				}
			}
		}
		return;
	}

	function Fire(float fValue)
	{
		// End:0x27
		if(bShowLog)
		{
			__NFUN_231__(__NFUN_168__("StandByToThrow =", string(m_bCanThrowGrenade)));
		}
		// End:0x107
		if(__NFUN_130__(__NFUN_151__(int(m_iNbBulletsInWeapon), 0), m_bCanThrowGrenade))
		{
			// End:0xF5
			if(__NFUN_119__(R6PlayerController(Pawn(Owner).Controller), none))
			{
				Pawn(Owner).Controller.m_bLockWeaponActions = true;
				// End:0xED
				if(__NFUN_130__(R6Pawn(Owner).IsPeeking(), __NFUN_129__(R6Pawn(Owner).m_bIsProne)))
				{
					// End:0xE2
					if(__NFUN_154__(int(R6PlayerController(Pawn(Owner).Controller).m_bPeekLeft), 1))
					{
						m_eThrow = 6;						
					}
					else
					{
						m_eThrow = 7;
					}					
				}
				else
				{
					m_eThrow = 1;
				}
			}
			ServerSetThrow(m_eThrow);
			__NFUN_113__('ReadyToThrow');
		}
		return;
	}

	function AltFire(float fValue)
	{
		// End:0xE0
		if(__NFUN_130__(__NFUN_151__(int(m_iNbBulletsInWeapon), 0), m_bCanThrowGrenade))
		{
			// End:0xCE
			if(__NFUN_119__(R6PlayerController(Pawn(Owner).Controller), none))
			{
				Pawn(Owner).Controller.m_bLockWeaponActions = true;
				// End:0xC6
				if(__NFUN_130__(R6Pawn(Owner).IsPeeking(), __NFUN_129__(R6Pawn(Owner).m_bIsProne)))
				{
					// End:0xBB
					if(__NFUN_154__(int(R6PlayerController(Pawn(Owner).Controller).m_bPeekLeft), 1))
					{
						m_eThrow = 4;						
					}
					else
					{
						m_eThrow = 5;
					}					
				}
				else
				{
					m_eThrow = 2;
				}
			}
			ServerSetThrow(m_eThrow);
			__NFUN_113__('ReadyToThrow');
		}
		return;
	}

	function FirstPersonAnimOver()
	{
		Pawn(Owner).Controller.m_bLockWeaponActions = false;
		return;
	}
	stop;
}

state ReadyToThrow
{
	function Fire(float fValue)
	{
		return;
	}

	function AltFire(float fValue)
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

	function BeginState()
	{
		// End:0x2C
		if(bShowLog)
		{
			__NFUN_231__("**** IN  READY TO THROW *******");
		}
		R6Pawn(Owner).m_bIsFiringState = true;
		m_bFistPersonAnimFinish = true;
		ServerImReadyToThrow(true);
		m_bReadyToThrow = true;
		m_PawnWaitAnimLow = 'StandGrenade_nt';
		m_PawnWaitAnimHigh = 'StandGrenade_nt';
		m_PawnWaitAnimProne = 'ProneGrenade_nt';
		// End:0x10F
		if(R6Pawn(Owner).m_bIsPlayer)
		{
			// End:0x10F
			if(__NFUN_242__(R6PlayerController(Pawn(Owner).Controller).bBehindView, false))
			{
				// End:0x10F
				if(__NFUN_119__(m_FPHands, none))
				{
					m_bFistPersonAnimFinish = false;
					m_FPHands.__NFUN_113__('FiringWeapon');
					// End:0x100
					if(bShowLog)
					{
						__NFUN_231__("Calling Fire SingleShot");
					}
					m_FPHands.FireSingleShot();
				}
			}
		}
		// End:0x120
		if(m_bPinToRemove)
		{
			ServerSetGrenade(3);
		}
		return;
	}

	function FirstPersonAnimOver()
	{
		m_bFistPersonAnimFinish = true;
		// End:0x39
		if(bShowLog)
		{
			__NFUN_231__("ReadyToThrow = FirstPersonAnimFinish");
		}
		return;
	}

	simulated function Tick(float fDeltaTime)
	{
		local R6Pawn pawnOwner;

		pawnOwner = R6Pawn(Owner);
		// End:0x180
		if(__NFUN_130__(__NFUN_130__(__NFUN_130__(__NFUN_130__(__NFUN_119__(pawnOwner.Controller, none), __NFUN_154__(int(pawnOwner.Controller.bFire), 0)), __NFUN_154__(int(pawnOwner.Controller.bAltFire), 0)), __NFUN_242__(pawnOwner.m_bWeaponTransition, false)), m_bFistPersonAnimFinish))
		{
			m_bCanThrowGrenade = false;
			m_bFistPersonAnimFinish = false;
			// End:0xD1
			if(bShowLog)
			{
				__NFUN_231__("!!!!!!!!!!!!!!! THROW GRENADE!!!!!!!!!!!!!!!");
			}
			ServerSetGrenade(m_eThrow);
			// End:0x179
			if(pawnOwner.m_bIsPlayer)
			{
				// End:0x179
				if(__NFUN_242__(R6PlayerController(pawnOwner.Controller).bBehindView, false))
				{
					// End:0x179
					if(__NFUN_119__(m_FPHands, none))
					{
						m_bFistPersonAnimFinish = false;
						// End:0x16A
						if(__NFUN_132__(__NFUN_132__(__NFUN_154__(int(m_eThrow), int(1)), __NFUN_154__(int(m_eThrow), int(6))), __NFUN_154__(int(m_eThrow), int(7))))
						{
							m_FPHands.FireGrenadeThrow();							
						}
						else
						{
							m_FPHands.FireGrenadeRoll();
						}
					}
				}
			}
			__NFUN_113__('WaitEndOfThrow');
		}
		return;
	}
	stop;
}

state WaitEndOfThrow
{
	function Fire(float fValue)
	{
		return;
	}

	function AltFire(float fValue)
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

	function FirstPersonAnimOver()
	{
		m_bFistPersonAnimFinish = true;
		// End:0x39
		if(bShowLog)
		{
			__NFUN_231__("ReadyToThrow = FirstPersonAnimFinish");
		}
		return;
	}

	simulated function Tick(float fDeltaTime)
	{
		// End:0xCD
		if(__NFUN_130__(m_bFistPersonAnimFinish, m_bCanThrowGrenade))
		{
			ServerSetGrenade(0);
			// End:0x46
			if(bShowLog)
			{
				__NFUN_231__(__NFUN_168__("ClientThrowGrenade()", string(m_iNbBulletsInWeapon)));
			}
			// End:0x85
			if(__NFUN_154__(int(m_iNbBulletsInWeapon), 0))
			{
				SetStaticMesh(none);
				m_PawnWaitAnimLow = 'StandNoGun_nt';
				m_PawnWaitAnimHigh = 'StandNoGun_nt';
				m_PawnWaitAnimProne = 'StandNoGun_nt';
				__NFUN_113__('NoGrenadeLeft');				
			}
			else
			{
				// End:0xC6
				if(__NFUN_119__(m_FPHands, none))
				{
					// End:0xB6
					if(m_FPHands.__NFUN_281__('RaiseWeapon'))
					{
						m_FPHands.BeginState();						
					}
					else
					{
						m_FPHands.__NFUN_113__('RaiseWeapon');
					}
				}
			}
			__NFUN_113__('StandByToThrow');
		}
		return;
	}

	function BeginState()
	{
		// End:0x3C
		if(bShowLog)
		{
			__NFUN_231__(__NFUN_112__("WEAPON - BeginState of WaitEndOfThrow for ", string(self)));
		}
		return;
	}
	stop;
}

state NoGrenadeLeft
{
	function StopFire(optional bool bSoundOnly)
	{
		return;
	}

	function AltFire(float fValue)
	{
		return;
	}

	function StopAltFire()
	{
		return;
	}

	function BeginState()
	{
		R6Pawn(Owner).m_bIsFiringState = false;
		// End:0x4E
		if(bShowLog)
		{
			__NFUN_231__(__NFUN_112__(string(self), " state NoChargesLeft : BeginState()..."));
		}
		Pawn(Owner).Controller.m_bHideReticule = true;
		Pawn(Owner).Controller.m_bLockWeaponActions = false;
		return;
	}
	stop;
}

state RaiseWeapon
{
	function FirstPersonAnimOver()
	{
		// End:0x30
		if(bShowLog)
		{
			__NFUN_231__("GRENADE - RaiseWeapon Calling SWUAD");
		}
		R6PlayerController(Pawn(Owner).Controller).ServerWeaponUpAnimDone();
		__NFUN_113__('StandByToThrow');
		R6Pawn(Owner).m_fWeaponJump = m_stAccuracyValues.fWeaponJump;
		return;
	}

	simulated function EndState()
	{
		// End:0x31
		if(bShowLog)
		{
			__NFUN_231__("GRENADE - Leaving state Raise Weapon");
		}
		Pawn(Owner).Controller.m_bHideReticule = false;
		Pawn(Owner).Controller.m_bLockWeaponActions = false;
		m_bCanThrowGrenade = true;
		return;
	}

	simulated function BeginState()
	{
		// End:0x39
		if(bShowLog)
		{
			__NFUN_231__(__NFUN_112__("WEAPON - BeginState of RaiseWeapon for ", string(self)));
		}
		Pawn(Owner).Controller.m_bLockWeaponActions = true;
		// End:0xB6
		if(__NFUN_119__(m_FPHands, none))
		{
			// End:0x89
			if(m_FPHands.__NFUN_281__('RaiseWeapon'))
			{
				m_FPHands.BeginState();				
			}
			else
			{
				m_FPHands.__NFUN_113__('RaiseWeapon');
			}
			m_FPWeapon.m_smGun.bHidden = false;			
		}
		else
		{
			FirstPersonAnimOver();
		}
		return;
	}
	stop;
}

state DiscardWeapon
{
	function Fire(float Value)
	{
		return;
	}

	function AltFire(float Value)
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

	function PlayReloading()
	{
		return;
	}

	simulated function BeginState()
	{
		local Pawn aPawn;

		// End:0x36
		if(bShowLog)
		{
			__NFUN_231__(__NFUN_168__(__NFUN_168__("IN:", string(self)), "::DiscardWeapon::BeginState()"));
		}
		// End:0xBF
		if(__NFUN_119__(m_FPHands, none))
		{
			aPawn = Pawn(Owner);
			// End:0x99
			if(__NFUN_119__(aPawn.Controller, none))
			{
				aPawn.Controller.m_bLockWeaponActions = true;
				aPawn.Controller.m_bHideReticule = true;
			}
			// End:0xB9
			if(__NFUN_151__(int(m_iNbBulletsInWeapon), 0))
			{
				m_FPHands.__NFUN_113__('DiscardWeapon');				
			}
			else
			{
				FirstPersonAnimOver();
			}
		}
		return;
	}

	simulated function EndState()
	{
		// End:0x34
		if(bShowLog)
		{
			__NFUN_231__(__NFUN_168__(__NFUN_168__("IN:", string(self)), "::DiscardWeapon::EndState()"));
		}
		return;
	}
	stop;
}

state PutWeaponDown
{
	simulated function BeginState()
	{
		// End:0x47
		if(bShowLog)
		{
			__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__("WEAPON - ", string(self)), " - BeginState of PutWeaponDown for "), string(self)));
		}
		// End:0xB5
		if(__NFUN_119__(m_FPHands, none))
		{
			// End:0x69
			if(__NFUN_154__(int(m_iNbBulletsInWeapon), 0))
			{
				__NFUN_113__('NoGrenadeLeft');				
			}
			else
			{
				// End:0x86
				if(m_FPHands.__NFUN_281__('FiringWeapon'))
				{
					__NFUN_113__('None');
					return;
				}
				Pawn(Owner).Controller.m_bLockWeaponActions = true;
				m_FPHands.__NFUN_113__('PutWeaponDown');
			}
		}
		return;
	}
	stop;
}

state BringWeaponUp
{
	simulated function BeginState()
	{
		// End:0x47
		if(bShowLog)
		{
			__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__("WEAPON - ", string(self)), " - BeginState of BringWeaponUp for "), string(self)));
		}
		// End:0x7C
		if(__NFUN_119__(m_FPHands, none))
		{
			// End:0x69
			if(__NFUN_154__(int(m_iNbBulletsInWeapon), 0))
			{
				__NFUN_113__('NoGrenadeLeft');				
			}
			else
			{
				m_FPHands.__NFUN_113__('BringWeaponUp');
			}			
		}
		else
		{
			FirstPersonAnimOver();
		}
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
			__NFUN_113__('StandByToThrow');
		}
		return;
	}

	simulated function EndState()
	{
		m_bCanThrowGrenade = true;
		Pawn(Owner).Controller.m_bHideReticule = false;
		Pawn(Owner).Controller.m_bLockWeaponActions = false;
		return;
	}
	stop;
}

defaultproperties
{
	m_bCanThrowGrenade=true
	m_bPinToRemove=true
	m_iClipCapacity=3
	m_fMuzzleVelocity=1500.0000000
	m_stWeaponCaps=(bSingle=1)
	m_szReticuleClass="GRENADE"
	m_pFPHandsClass=Class'R61stWeapons.R61stHandsGripGrenade'
	m_eWeaponType=6
	m_bDisplayHudInfo=true
	m_ReloadSnd=Sound'Foley_CommonGrenade.Play_Grenade_Degoupille'
	m_BurstFireStereoSnd=Sound'Foley_CommonGrenade.Play_Grenade_Throw'
	m_PawnWaitAnimLow="StandGrenade_nt"
	m_PawnWaitAnimHigh="StandGrenade_nt"
	m_PawnWaitAnimProne="ProneGrenade_nt"
	m_AttachPoint="TagGrenadeHand"
	bCollideWorld=true
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: function ShowInfo
