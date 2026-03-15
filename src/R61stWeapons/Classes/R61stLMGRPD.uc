//=============================================================================
// R61stLMGRPD - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  [R61stLMGRPD] 
//===============================================================================
class R61stLMGRPD extends R61stLMGWeapon;

function PostBeginPlay()
{
	LinkSkelAnim(MeshAnimation'R61stLMG_UKX.R61stLMGRPDA');
	super.PostBeginPlay();
	// End:0x2A
	if((m_smGun == none))
	{
		m_smGun = Spawn(Class'R61stWeapons.R61stWeaponStaticMesh');
	}
	m_smGun.SetStaticMesh(StaticMesh'R61stWeapons_SM.LMGs.R61stLMGRPDFrame');
	AttachToBone(m_smGun, 'TagFrame');
	return;
}

defaultproperties
{
	m_RWing=StaticMesh'R61stWeapons_SM.LMGs.R61stLMG762Russ_RWing'
	m_2Wing=StaticMesh'R61stWeapons_SM.LMGs.R61stLMG762Russ_2Wing'
	m_LWing=StaticMesh'R61stWeapons_SM.LMGs.R61stLMG762Russ_LWing'
	Mesh=SkeletalMesh'R61stLMG_UKX.R61stLMGRPD'
}
