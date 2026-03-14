//=============================================================================
// R61stHandsShotgunSPAS12 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//===============================================================================
//  [R61stHandsShotgunSPAS12]   
//===============================================================================
class R61stHandsShotgunSPAS12 extends R61stHandsShotgunM1;

function PostBeginPlay()
{
	LinkSkelAnim(MeshAnimation'R61stHands_UKX.R61stHandsShotgunSPAS12A');
	super.PostBeginPlay();
	return;
}

state Reloading
{
	function EndState()
	{
		return;
	}

	simulated event AnimEnd(int Channel)
	{
		// End:0x230
		if(__NFUN_154__(Channel, 0))
		{
			// End:0x134
			if(__NFUN_242__(m_bReloadCycle, true))
			{
				R6AbstractWeapon(Owner).ServerPutBulletInShotgun();
				// End:0x58
				if(__NFUN_154__(int(Level.NetMode), int(NM_Client)))
				{
					R6AbstractWeapon(Owner).ClientAddShell();
				}
				// End:0x105
				if(__NFUN_130__(__NFUN_130__(__NFUN_154__(int(R6PlayerController(Pawn(Owner.Owner).Controller).m_bReloading), 1), __NFUN_155__(R6AbstractWeapon(Owner).GetNbOfClips(), 0)), __NFUN_129__(R6AbstractWeapon(Owner).GunIsFull())))
				{
					R6Pawn(Owner.Owner).ServerPlayReloadAnimAgain();
					__NFUN_259__('Reload_c', R6Pawn(Owner.Owner).m_fReloadSpeedMultiplier);					
				}
				else
				{
					__NFUN_259__('Reload_e', R6Pawn(Owner.Owner).m_fReloadSpeedMultiplier);
					m_bReloadCycle = false;
				}				
			}
			else
			{
				// End:0x205
				if(__NFUN_242__(m_bReloadEmpty, true))
				{
					m_bReloadEmpty = false;
					R6AbstractWeapon(Owner).ServerPutBulletInShotgun();
					// End:0x189
					if(__NFUN_154__(int(Level.NetMode), int(NM_Client)))
					{
						R6AbstractWeapon(Owner).ClientAddShell();
					}
					// End:0x205
					if(__NFUN_130__(__NFUN_154__(int(R6PlayerController(Pawn(Owner.Owner).Controller).m_bReloading), 1), __NFUN_155__(R6AbstractWeapon(Owner).GetNbOfClips(), 0)))
					{
						__NFUN_259__('Reload_b', R6Pawn(Owner.Owner).m_fReloadSpeedMultiplier);
						m_bReloadCycle = true;
						return;
					}
				}
				m_bReloadCycle = false;
				__NFUN_260__('Wait_c');
				__NFUN_113__('Waiting');
				R6AbstractWeapon(Owner).FirstPersonAnimOver();
			}
		}
		return;
	}

	simulated function BeginState()
	{
		// End:0x71
		if(__NFUN_242__(m_bReloadEmpty, true))
		{
			AssociatedWeapon.__NFUN_259__(AssociatedWeapon.m_ReloadEmpty, R6Pawn(Owner.Owner).m_fReloadSpeedMultiplier);
			__NFUN_259__('ReloadEmpty', R6Pawn(Owner.Owner).m_fReloadSpeedMultiplier);
			m_bReloadEmpty = true;			
		}
		else
		{
			__NFUN_259__('Reload_b', R6Pawn(Owner.Owner).m_fReloadSpeedMultiplier);
			m_bReloadCycle = true;
		}
		return;
	}
	stop;
}

