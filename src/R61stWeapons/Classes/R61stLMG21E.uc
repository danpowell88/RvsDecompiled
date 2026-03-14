//=============================================================================
// R61stLMG21E - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//===============================================================================
//  [R61stLMG21E] 
//===============================================================================
class R61stLMG21E extends R61stLMGWeapon;

function PostBeginPlay()
{
	LinkSkelAnim(MeshAnimation'R61stLMG_UKX.R61stLMG21EA');
	super.PostBeginPlay();
	// End:0x2A
	if(__NFUN_114__(m_smGun, none))
	{
		m_smGun = __NFUN_278__(Class'R61stWeapons.R61stWeaponStaticMesh');
	}
	m_smGun.SetStaticMesh(StaticMesh'R61stWeapons_SM.LMGs.R61stLMG21EFrame');
	AttachToBone(m_smGun, 'TagFrame');
	return;
}

defaultproperties
{
	m_RWing=StaticMesh'R61stWeapons_SM.LMGs.R61stLMG762Nato_RWing'
	m_2Wing=StaticMesh'R61stWeapons_SM.LMGs.R61stLMG762Nato_2Wing'
	m_LWing=StaticMesh'R61stWeapons_SM.LMGs.R61stLMG762Nato_LWing'
	Mesh=SkeletalMesh'R61stLMG_UKX.R61stLMG21E'
}
