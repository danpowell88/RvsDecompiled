//=============================================================================
// R61stHandsShotgunSPAS12 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
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
		if((Channel == 0))
		{
			// End:0x134
			if((m_bReloadCycle == true))
			{
				R6AbstractWeapon(Owner).ServerPutBulletInShotgun();
				// End:0x58
				if((int(Level.NetMode) == int(NM_Client)))
				{
					R6AbstractWeapon(Owner).ClientAddShell();
				}
				// End:0x105
				if((((int(R6PlayerController(Pawn(Owner.Owner).Controller).m_bReloading) == 1) && (R6AbstractWeapon(Owner).GetNbOfClips() != 0)) && (!R6AbstractWeapon(Owner).GunIsFull())))
				{
					R6Pawn(Owner.Owner).ServerPlayReloadAnimAgain();
					PlayAnim('Reload_c', R6Pawn(Owner.Owner).m_fReloadSpeedMultiplier);					
				}
				else
				{
					PlayAnim('Reload_e', R6Pawn(Owner.Owner).m_fReloadSpeedMultiplier);
					m_bReloadCycle = false;
				}				
			}
			else
			{
				// End:0x205
				if((m_bReloadEmpty == true))
				{
					m_bReloadEmpty = false;
					R6AbstractWeapon(Owner).ServerPutBulletInShotgun();
					// End:0x189
					if((int(Level.NetMode) == int(NM_Client)))
					{
						R6AbstractWeapon(Owner).ClientAddShell();
					}
					// End:0x205
					if(((int(R6PlayerController(Pawn(Owner.Owner).Controller).m_bReloading) == 1) && (R6AbstractWeapon(Owner).GetNbOfClips() != 0)))
					{
						PlayAnim('Reload_b', R6Pawn(Owner.Owner).m_fReloadSpeedMultiplier);
						m_bReloadCycle = true;
						return;
					}
				}
				m_bReloadCycle = false;
				LoopAnim('Wait_c');
				GotoState('Waiting');
				R6AbstractWeapon(Owner).FirstPersonAnimOver();
			}
		}
		return;
	}

	simulated function BeginState()
	{
		// End:0x71
		if((m_bReloadEmpty == true))
		{
			AssociatedWeapon.PlayAnim(AssociatedWeapon.m_ReloadEmpty, R6Pawn(Owner.Owner).m_fReloadSpeedMultiplier);
			PlayAnim('ReloadEmpty', R6Pawn(Owner.Owner).m_fReloadSpeedMultiplier);
			m_bReloadEmpty = true;			
		}
		else
		{
			PlayAnim('Reload_b', R6Pawn(Owner.Owner).m_fReloadSpeedMultiplier);
			m_bReloadCycle = true;
		}
		return;
	}
	stop;
}

