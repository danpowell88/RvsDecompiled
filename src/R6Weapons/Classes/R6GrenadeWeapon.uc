//=============================================================================
// R6GrenadeWeapon - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
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
	unreliable if((int(Role) < int(ROLE_Authority)))
		ServerImReadyToThrow, ServerSetThrow;

	// Pos:0x000
	reliable if((int(Role) == int(ROLE_Authority)))
		ClientThrowGrenade;

	// Pos:0x00D
	reliable if((int(Role) < int(ROLE_Authority)))
		ServerSetGrenade;
}

simulated function PostBeginPlay()
{
	local R6RainbowAI localRainbowAI;

	super(R6Weapons).PostBeginPlay();
	// End:0x25
	if((m_pBulletClass != none))
	{
		SetStaticMesh(m_pBulletClass.default.StaticMesh);
	}
	// End:0xA5
	if((Pawn(Owner) != none))
	{
		// End:0xA5
		if((Pawn(Owner).Controller != none))
		{
			localRainbowAI = R6RainbowAI(Pawn(Owner).Controller);
			// End:0xA5
			if(((localRainbowAI != none) && (localRainbowAI.m_TeamManager != none)))
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
	aGrenade = R6Grenade(Spawn(m_pBulletClass, self,, vStart));
	aGrenade.Instigator = Pawn(Owner);
	aGrenade.SetSpeed(0.0000000);
	return;
}

simulated function StartFalling()
{
	// End:0x49
	if((int(m_iNbBulletsInWeapon) != 0))
	{
		// End:0x43
		if((m_bReadyToThrow == true))
		{
			bHidden = true;
			// End:0x40
			if((int(Level.NetMode) != int(NM_Client)))
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
	if((m_pBulletClass == none))
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
	GotoState('StandByToThrow');
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
		Log("ServerSetGrenade");
	}
	return;
}

function DestroyReticules()
{
	local R6Reticule aReticule;

	aReticule = m_ReticuleInstance;
	m_ReticuleInstance = none;
	// End:0x29
	if((aReticule != none))
	{
		aReticule.Destroy();
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
	if((int(m_iNbBulletsInWeapon) > 0))
	{
		(m_iNbBulletsInWeapon--);
		// End:0x97
		if(((int(m_iNbBulletsInWeapon) == 0) && (pawnOwner != none)))
		{
			SetStaticMesh(none);
			localRainbowAI = R6RainbowAI(pawnOwner.Controller);
			// End:0x97
			if(((localRainbowAI != none) && (localRainbowAI.m_TeamManager != none)))
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
		aGrenade = R6Grenade(Spawn(m_pBulletClass, self,, vStart, rFiringDir));
		aGrenade.Instigator = pawnOwner;
		m_bReadyToThrow = false;
		// End:0x159
		if((pawnOwner.m_bIsProne == true))
		{
			aGrenade.SetSpeed((m_fMuzzleVelocity * 0.5000000));			
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
	if((m_pBulletClass.default.m_fKillBlastRadius > float(30)))
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
	if((int(Level.NetMode) == int(NM_DedicatedServer)))
	{
		return;
	}
	// End:0x39
	if((int(m_iNbBulletsInWeapon) == 0))
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
		Log((("***** HideAttachment for" @ string(self)) @ "******"));
	}
	SetDrawType(0);
	return;
}

function bool CanSwitchToWeapon()
{
	// End:0x12
	if((int(m_iNbBulletsInWeapon) > 0))
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
			Log("**** IN  STANDBY TO THROW *******");
		}
		// End:0xFE
		if((int(m_iNbBulletsInWeapon) == 0))
		{
			// End:0x99
			if(bShowLog)
			{
				Log("**** No more Grenades, Autoswitch to Primary Weapon *******");
			}
			PController = R6PlayerController(Pawn(Owner).Controller);
			// End:0xFE
			if((PController != none))
			{
				// End:0xEF
				if((R6Pawn(Owner).m_WeaponsCarried[0] != none))
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
			Log(("StandByToThrow =" @ string(m_bCanThrowGrenade)));
		}
		// End:0x107
		if(((int(m_iNbBulletsInWeapon) > 0) && m_bCanThrowGrenade))
		{
			// End:0xF5
			if((R6PlayerController(Pawn(Owner).Controller) != none))
			{
				Pawn(Owner).Controller.m_bLockWeaponActions = true;
				// End:0xED
				if((R6Pawn(Owner).IsPeeking() && (!R6Pawn(Owner).m_bIsProne)))
				{
					// End:0xE2
					if((int(R6PlayerController(Pawn(Owner).Controller).m_bPeekLeft) == 1))
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
			GotoState('ReadyToThrow');
		}
		return;
	}

	function AltFire(float fValue)
	{
		// End:0xE0
		if(((int(m_iNbBulletsInWeapon) > 0) && m_bCanThrowGrenade))
		{
			// End:0xCE
			if((R6PlayerController(Pawn(Owner).Controller) != none))
			{
				Pawn(Owner).Controller.m_bLockWeaponActions = true;
				// End:0xC6
				if((R6Pawn(Owner).IsPeeking() && (!R6Pawn(Owner).m_bIsProne)))
				{
					// End:0xBB
					if((int(R6PlayerController(Pawn(Owner).Controller).m_bPeekLeft) == 1))
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
			GotoState('ReadyToThrow');
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
			Log("**** IN  READY TO THROW *******");
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
			if((R6PlayerController(Pawn(Owner).Controller).bBehindView == false))
			{
				// End:0x10F
				if((m_FPHands != none))
				{
					m_bFistPersonAnimFinish = false;
					m_FPHands.GotoState('FiringWeapon');
					// End:0x100
					if(bShowLog)
					{
						Log("Calling Fire SingleShot");
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
			Log("ReadyToThrow = FirstPersonAnimFinish");
		}
		return;
	}

	simulated function Tick(float fDeltaTime)
	{
		local R6Pawn pawnOwner;

		pawnOwner = R6Pawn(Owner);
		// End:0x180
		if((((((pawnOwner.Controller != none) && (int(pawnOwner.Controller.bFire) == 0)) && (int(pawnOwner.Controller.bAltFire) == 0)) && (pawnOwner.m_bWeaponTransition == false)) && m_bFistPersonAnimFinish))
		{
			m_bCanThrowGrenade = false;
			m_bFistPersonAnimFinish = false;
			// End:0xD1
			if(bShowLog)
			{
				Log("!!!!!!!!!!!!!!! THROW GRENADE!!!!!!!!!!!!!!!");
			}
			ServerSetGrenade(m_eThrow);
			// End:0x179
			if(pawnOwner.m_bIsPlayer)
			{
				// End:0x179
				if((R6PlayerController(pawnOwner.Controller).bBehindView == false))
				{
					// End:0x179
					if((m_FPHands != none))
					{
						m_bFistPersonAnimFinish = false;
						// End:0x16A
						if((((int(m_eThrow) == int(1)) || (int(m_eThrow) == int(6))) || (int(m_eThrow) == int(7))))
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
			GotoState('WaitEndOfThrow');
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
			Log("ReadyToThrow = FirstPersonAnimFinish");
		}
		return;
	}

	simulated function Tick(float fDeltaTime)
	{
		// End:0xCD
		if((m_bFistPersonAnimFinish && m_bCanThrowGrenade))
		{
			ServerSetGrenade(0);
			// End:0x46
			if(bShowLog)
			{
				Log(("ClientThrowGrenade()" @ string(m_iNbBulletsInWeapon)));
			}
			// End:0x85
			if((int(m_iNbBulletsInWeapon) == 0))
			{
				SetStaticMesh(none);
				m_PawnWaitAnimLow = 'StandNoGun_nt';
				m_PawnWaitAnimHigh = 'StandNoGun_nt';
				m_PawnWaitAnimProne = 'StandNoGun_nt';
				GotoState('NoGrenadeLeft');				
			}
			else
			{
				// End:0xC6
				if((m_FPHands != none))
				{
					// End:0xB6
					if(m_FPHands.IsInState('RaiseWeapon'))
					{
						m_FPHands.BeginState();						
					}
					else
					{
						m_FPHands.GotoState('RaiseWeapon');
					}
				}
			}
			GotoState('StandByToThrow');
		}
		return;
	}

	function BeginState()
	{
		// End:0x3C
		if(bShowLog)
		{
			Log(("WEAPON - BeginState of WaitEndOfThrow for " $ string(self)));
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
			Log((string(self) $ " state NoChargesLeft : BeginState()..."));
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
			Log("GRENADE - RaiseWeapon Calling SWUAD");
		}
		R6PlayerController(Pawn(Owner).Controller).ServerWeaponUpAnimDone();
		GotoState('StandByToThrow');
		R6Pawn(Owner).m_fWeaponJump = m_stAccuracyValues.fWeaponJump;
		return;
	}

	simulated function EndState()
	{
		// End:0x31
		if(bShowLog)
		{
			Log("GRENADE - Leaving state Raise Weapon");
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
			Log(("WEAPON - BeginState of RaiseWeapon for " $ string(self)));
		}
		Pawn(Owner).Controller.m_bLockWeaponActions = true;
		// End:0xB6
		if((m_FPHands != none))
		{
			// End:0x89
			if(m_FPHands.IsInState('RaiseWeapon'))
			{
				m_FPHands.BeginState();				
			}
			else
			{
				m_FPHands.GotoState('RaiseWeapon');
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
			Log((("IN:" @ string(self)) @ "::DiscardWeapon::BeginState()"));
		}
		// End:0xBF
		if((m_FPHands != none))
		{
			aPawn = Pawn(Owner);
			// End:0x99
			if((aPawn.Controller != none))
			{
				aPawn.Controller.m_bLockWeaponActions = true;
				aPawn.Controller.m_bHideReticule = true;
			}
			// End:0xB9
			if((int(m_iNbBulletsInWeapon) > 0))
			{
				m_FPHands.GotoState('DiscardWeapon');				
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
			Log((("IN:" @ string(self)) @ "::DiscardWeapon::EndState()"));
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
			Log(((("WEAPON - " $ string(self)) $ " - BeginState of PutWeaponDown for ") $ string(self)));
		}
		// End:0xB5
		if((m_FPHands != none))
		{
			// End:0x69
			if((int(m_iNbBulletsInWeapon) == 0))
			{
				GotoState('NoGrenadeLeft');				
			}
			else
			{
				// End:0x86
				if(m_FPHands.IsInState('FiringWeapon'))
				{
					GotoState('None');
					return;
				}
				Pawn(Owner).Controller.m_bLockWeaponActions = true;
				m_FPHands.GotoState('PutWeaponDown');
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
			Log(((("WEAPON - " $ string(self)) $ " - BeginState of BringWeaponUp for ") $ string(self)));
		}
		// End:0x7C
		if((m_FPHands != none))
		{
			// End:0x69
			if((int(m_iNbBulletsInWeapon) == 0))
			{
				GotoState('NoGrenadeLeft');				
			}
			else
			{
				m_FPHands.GotoState('BringWeaponUp');
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
		if(((Pawn(Owner).Controller != none) && (int(Pawn(Owner).Controller.bFire) == 1)))
		{
			GotoState('NormalFire');			
		}
		else
		{
			GotoState('StandByToThrow');
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
