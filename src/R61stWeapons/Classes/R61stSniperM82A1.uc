//=============================================================================
// R61stSniperM82A1 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//===============================================================================
//  [R61stSniperM82A1] 
//===============================================================================
class R61stSniperM82A1 extends R61stSniperDragunov;

function PostBeginPlay()
{
	LinkSkelAnim(MeshAnimation'R61stSniper_UKX.R61stSniperM82A1A');
	super.PostBeginPlay();
	// End:0x2A
	if(__NFUN_114__(m_smGun, none))
	{
		m_smGun = __NFUN_278__(Class'R61stWeapons.R61stWeaponStaticMesh');
	}
	m_smGun.SetStaticMesh(StaticMesh'R61stWeapons_SM.SniperRifles.R61stSniperM82A1Frame');
	AttachToBone(m_smGun, 'TagFrame');
	return;
}

defaultproperties
{
	Mesh=SkeletalMesh'R61stSniper_UKX.R61stSniperM82A1'
}
