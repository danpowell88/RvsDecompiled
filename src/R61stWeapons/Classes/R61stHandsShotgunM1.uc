//=============================================================================
// R61stHandsShotgunM1 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//===============================================================================
//  [R61stHandsShotgunM1]   
//===============================================================================
class R61stHandsShotgunM1 extends R61stHandsGripShotgun;

var bool m_bReloadCycle;
var bool m_bPlayedEnd;  // To play Reload_e on reload empty

function PostBeginPlay()
{
	LinkSkelAnim(MeshAnimation'R61stHands_UKX.R61stHandsShotgunM1A');
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
		// End:0x2DC
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
				if(__NFUN_130__(__NFUN_130__(__NFUN_154__(int(R6PlayerController(Pawn(Owner.Owner).Controller).m_bReloading), 1), __NFUN_151__(R6AbstractWeapon(Owner).GetNbOfClips(), 0)), __NFUN_129__(R6AbstractWeapon(Owner).GunIsFull())))
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
				// End:0x221
				if(__NFUN_242__(m_bReloadEmpty, true))
				{
					// End:0x1BC
					if(__NFUN_242__(m_bPlayedEnd, false))
					{
						R6AbstractWeapon(Owner).ServerPutBulletInShotgun();
						// End:0x18D
						if(__NFUN_154__(int(Level.NetMode), int(NM_Client)))
						{
							R6AbstractWeapon(Owner).ClientAddShell();
						}
						__NFUN_259__('Reload_e', R6Pawn(Owner.Owner).m_fReloadSpeedMultiplier);
						m_bPlayedEnd = true;						
					}
					else
					{
						AssociatedWeapon.__NFUN_259__(AssociatedWeapon.m_ReloadEmpty, R6Pawn(Owner.Owner).m_fReloadSpeedMultiplier);
						__NFUN_259__('ReloadEmpty', R6Pawn(Owner.Owner).m_fReloadSpeedMultiplier);
						m_bReloadEmpty = false;
					}					
				}
				else
				{
					// End:0x2B9
					if(__NFUN_130__(__NFUN_130__(__NFUN_154__(int(R6PlayerController(Pawn(Owner.Owner).Controller).m_bReloading), 1), __NFUN_151__(R6AbstractWeapon(Owner).GetNbOfClips(), 0)), __NFUN_129__(R6AbstractWeapon(Owner).GunIsFull())))
					{
						__NFUN_259__('Reload_b', R6Pawn(Owner.Owner).m_fReloadSpeedMultiplier);
						m_bReloadCycle = true;						
					}
					else
					{
						__NFUN_260__('Wait_c');
						__NFUN_113__('Waiting');
						R6AbstractWeapon(Owner).FirstPersonAnimOver();
					}
				}
			}
		}
		return;
	}

	simulated function BeginState()
	{
		__NFUN_259__('Reload_b', R6Pawn(Owner.Owner).m_fReloadSpeedMultiplier);
		// End:0x3B
		if(__NFUN_242__(m_bReloadEmpty, false))
		{
			m_bReloadCycle = true;			
		}
		else
		{
			m_bPlayedEnd = false;
		}
		return;
	}
	stop;
}

