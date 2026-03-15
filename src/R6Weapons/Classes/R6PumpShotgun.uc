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
	return (int(m_iNbBulletsInWeapon) >= m_iClipCapacity);
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
	(m_iNbBulletsInWeapon++);
	// End:0x27
	if((int(Level.NetMode) == int(NM_Client)))
	{
		(m_iCurrentNbOfClips--);
	}
	return;
}

simulated function AddClips(int iNbOfExtraClips)
{
	(m_iCurrentNbOfClips += iNbOfExtraClips);
	// End:0x2B
	if((int(Level.NetMode) == int(NM_Client)))
	{
		ServerAddClips();
	}
	return;
}

function ServerPutBulletInShotgun()
{
	// End:0x40
	if((!GunIsFull()))
	{
		(m_iNbBulletsInWeapon++);
		// End:0x24
		if((!m_bUnlimitedClip))
		{
			(m_iCurrentNbOfClips--);
		}
		// End:0x40
		if((m_ReloadSnd != none))
		{
			Owner.PlaySound(m_ReloadSnd);
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
			Log("SHOTGUN - FPAOver");
		}
		// End:0x4C
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

	simulated function ChangeClip()
	{
		// End:0x21
		if(bShowLog)
		{
			Log("SHOTGUN - ChangeClip");
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
			Log("SHOTGUN - Leaving State Reloading");
		}
		pawnOwner.ServerSwitchReloadingWeapon(false);
		// End:0xA4
		if((PlayerCtrl != none))
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
			Log(("SHOTGUN - Begin State Reloading! " $ string(GetNbOfClips())));
		}
		// End:0x13E
		if(((GetNbOfClips() > 0) && (!GunIsFull())))
		{
			// End:0xA1
			if(((PlayerCtrl != none) && (!PlayerCtrl.m_bWantTriggerLag)))
			{
				ClientStartChangeClip();
			}
			ServerStartChangeClip();
			// End:0x13B
			if(pawnOwner.m_bIsPlayer)
			{
				// End:0x13B
				if(((PlayerCtrl != none) && (PlayerCtrl.bBehindView == false)))
				{
					// End:0xF9
					if((int(m_iNbBulletsInWeapon) == 0))
					{
						m_FPHands.m_bReloadEmpty = true;
					}
					m_FPHands.GotoState('Reloading');
					PlayerCtrl.m_iPlayerCAProgress = 0;
					PlayerCtrl.m_bHideReticule = true;
					PlayerCtrl.m_bLockWeaponActions = true;
				}
			}			
		}
		else
		{
			GotoState('None');
		}
		return;
	}

	function int GetReloadProgress()
	{
		local name Anim;
		local float fFrame, fRate;

		m_FPHands.GetAnimParams(0, Anim, fFrame, fRate);
		// End:0x3F
		if((Anim != 'Reload_e'))
		{
			return int((fFrame * float(110)));			
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
		if(((PlayerCtrl != none) && (PlayerCtrl.m_bUseFirstPersonWeapon == false)))
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
