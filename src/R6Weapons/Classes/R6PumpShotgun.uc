//=============================================================================
// R6PumpShotgun - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//============================================================================//
//  R6Shotgun.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class R6PumpShotgun extends R6Shotgun
 abstract;

simulated function bool GunIsFull()
{
	return __NFUN_153__(int(m_iNbBulletsInWeapon), m_iClipCapacity);
	return;
}

simulated function bool IsPumpShotGun()
{
	return true;
	return;
}

//Function called only on client, Add a shell before it's replicated.
//To fix a problem with reload animations and network lag.
function ClientAddShell()
{
	__NFUN_139__(m_iNbBulletsInWeapon);
	// End:0x27
	if(__NFUN_154__(int(Level.NetMode), int(NM_Client)))
	{
		__NFUN_166__(m_iCurrentNbOfClips);
	}
	return;
}

simulated function AddClips(int iNbOfExtraClips)
{
	__NFUN_161__(m_iCurrentNbOfClips, iNbOfExtraClips);
	// End:0x2B
	if(__NFUN_154__(int(Level.NetMode), int(NM_Client)))
	{
		ServerAddClips();
	}
	return;
}

function ServerPutBulletInShotgun()
{
	// End:0x40
	if(__NFUN_129__(GunIsFull()))
	{
		__NFUN_139__(m_iNbBulletsInWeapon);
		// End:0x24
		if(__NFUN_129__(m_bUnlimitedClip))
		{
			__NFUN_166__(m_iCurrentNbOfClips);
		}
		// End:0x40
		if(__NFUN_119__(m_ReloadSnd, none))
		{
			Owner.__NFUN_264__(m_ReloadSnd);
		}
	}
	return;
}

state Reloading
{
	function FirstPersonAnimOver()
	{
		// End:0x1E
		if(bShowLog)
		{
			__NFUN_231__("SHOTGUN - FPAOver");
		}
		// End:0x4C
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

	simulated function ChangeClip()
	{
		// End:0x21
		if(bShowLog)
		{
			__NFUN_231__("SHOTGUN - ChangeClip");
		}
		ServerPutBulletInShotgun();
		return;
	}

	function EndState()
	{
		local R6Pawn pawnOwner;
		local R6PlayerController PlayerCtrl;

		pawnOwner = R6Pawn(Owner);
		PlayerCtrl = R6PlayerController(pawnOwner.Controller);
		// End:0x57
		if(bShowLog)
		{
			__NFUN_231__("SHOTGUN - Leaving State Reloading");
		}
		pawnOwner.ServerSwitchReloadingWeapon(false);
		// End:0xA4
		if(__NFUN_119__(PlayerCtrl, none))
		{
			PlayerCtrl.m_iPlayerCAProgress = 0;
			PlayerCtrl.m_bLockWeaponActions = false;
			PlayerCtrl.m_bHideReticule = false;
		}
		return;
	}

	simulated function BeginState()
	{
		local R6Pawn pawnOwner;
		local R6PlayerController PlayerCtrl;

		pawnOwner = R6Pawn(Owner);
		PlayerCtrl = R6PlayerController(pawnOwner.Controller);
		// End:0x61
		if(bShowLog)
		{
			__NFUN_231__(__NFUN_112__("SHOTGUN - Begin State Reloading! ", string(GetNbOfClips())));
		}
		// End:0x13E
		if(__NFUN_130__(__NFUN_151__(GetNbOfClips(), 0), __NFUN_129__(GunIsFull())))
		{
			// End:0xA1
			if(__NFUN_130__(__NFUN_119__(PlayerCtrl, none), __NFUN_129__(PlayerCtrl.m_bWantTriggerLag)))
			{
				ClientStartChangeClip();
			}
			ServerStartChangeClip();
			// End:0x13B
			if(pawnOwner.m_bIsPlayer)
			{
				// End:0x13B
				if(__NFUN_130__(__NFUN_119__(PlayerCtrl, none), __NFUN_242__(PlayerCtrl.bBehindView, false)))
				{
					// End:0xF9
					if(__NFUN_154__(int(m_iNbBulletsInWeapon), 0))
					{
						m_FPHands.m_bReloadEmpty = true;
					}
					m_FPHands.__NFUN_113__('Reloading');
					PlayerCtrl.m_iPlayerCAProgress = 0;
					PlayerCtrl.m_bHideReticule = true;
					PlayerCtrl.m_bLockWeaponActions = true;
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
		// End:0x3F
		if(__NFUN_255__(Anim, 'Reload_e'))
		{
			return int(__NFUN_171__(fFrame, float(110)));			
		}
		else
		{
			return 0;
		}
		return;
	}

	event Tick(float fDeltaTime)
	{
		local R6PlayerController PlayerCtrl;

		PlayerCtrl = R6PlayerController(R6Pawn(Owner).Controller);
		// End:0x55
		if(__NFUN_130__(__NFUN_119__(PlayerCtrl, none), __NFUN_242__(PlayerCtrl.m_bUseFirstPersonWeapon, false)))
		{
			PlayerCtrl.m_iPlayerCAProgress = GetReloadProgress();
		}
		return;
	}
	stop;
}

state NormalFire
{
	function Fire(float Value)
	{
		return;
	}

	function EndState()
	{
		Pawn(Owner).ServerFinishShotgunAnimation();
		super.EndState();
		return;
	}
	stop;
}

defaultproperties
{
	m_PawnReloadAnim="StandReloadEmptyShotGun"
	m_PawnReloadAnimTactical="StandReloadShotGun"
	m_PawnReloadAnimProne="ProneReloadEmptyShotGun"
	m_PawnReloadAnimProneTactical="ProneReloadShotGun"
}
