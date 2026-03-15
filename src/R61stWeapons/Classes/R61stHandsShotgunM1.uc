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
				if((((int(R6PlayerController(Pawn(Owner.Owner).Controller).m_bReloading) == 1) && (R6AbstractWeapon(Owner).GetNbOfClips() > 0)) && (!R6AbstractWeapon(Owner).GunIsFull())))
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
				// End:0x221
				if((m_bReloadEmpty == true))
				{
					// End:0x1BC
					if((m_bPlayedEnd == false))
					{
						R6AbstractWeapon(Owner).ServerPutBulletInShotgun();
						// End:0x18D
						if((int(Level.NetMode) == int(NM_Client)))
						{
							R6AbstractWeapon(Owner).ClientAddShell();
						}
						PlayAnim('Reload_e', R6Pawn(Owner.Owner).m_fReloadSpeedMultiplier);
						m_bPlayedEnd = true;						
					}
					else
					{
						AssociatedWeapon.PlayAnim(AssociatedWeapon.m_ReloadEmpty, R6Pawn(Owner.Owner).m_fReloadSpeedMultiplier);
						PlayAnim('ReloadEmpty', R6Pawn(Owner.Owner).m_fReloadSpeedMultiplier);
						m_bReloadEmpty = false;
					}					
				}
				else
				{
					// End:0x2B9
					if((((int(R6PlayerController(Pawn(Owner.Owner).Controller).m_bReloading) == 1) && (R6AbstractWeapon(Owner).GetNbOfClips() > 0)) && (!R6AbstractWeapon(Owner).GunIsFull())))
					{
						PlayAnim('Reload_b', R6Pawn(Owner.Owner).m_fReloadSpeedMultiplier);
						m_bReloadCycle = true;						
					}
					else
					{
						LoopAnim('Wait_c');
						GotoState('Waiting');
						R6AbstractWeapon(Owner).FirstPersonAnimOver();
					}
				}
			}
		}
		return;
	}

	simulated function BeginState()
	{
		PlayAnim('Reload_b', R6Pawn(Owner.Owner).m_fReloadSpeedMultiplier);
		// End:0x3B
		if((m_bReloadEmpty == false))
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

