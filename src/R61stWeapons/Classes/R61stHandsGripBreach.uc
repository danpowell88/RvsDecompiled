//=============================================================================
// R61stHandsGripBreach - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R61stHandsGripBreach.uc : (add small description)
//=============================================================================
class R61stHandsGripBreach extends R6
    AbstractFirstPersonHands;

function PostBeginPlay()
{
	LinkSkelAnim(MeshAnimation'R61stHands_UKX.R61stHandsGripBreachA');
	super.PostBeginPlay();
	m_HandFire = 'Fire';
	return;
}

simulated state FiringWeapon
{
	function AnimEnd(int iChannel)
	{
		// End:0x1A
		if(((iChannel != 0) || (Owner == none)))
		{
			return;
		}
		// End:0x41
		if(bShowLog)
		{
			Log("HANDS - EndAnim, goto wait");
		}
		AssociatedWeapon.PlayAnim(AssociatedWeapon.m_WeaponNeutralAnim);
		AnimBlendParams(1, 0.0000000);
		R6AbstractWeapon(Owner).FirstPersonAnimOver();
		m_bCanQuitOnAnimEnd = false;
		m_bCannotPlayEmpty = false;
		m_bInBurst = false;
		GotoState('DiscardWeapon');
		return;
	}
	stop;
}

defaultproperties
{
	DrawType=0
	Mesh=SkeletalMesh'R61stHands_UKX.R61stHands'
}
