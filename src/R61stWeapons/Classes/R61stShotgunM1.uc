//=============================================================================
// R61stShotgunM1 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//===============================================================================
//  [R61stShotgunM1] 
//===============================================================================
class R61stShotgunM1 extends R6AbstractFirstPersonWeapon;

function PostBeginPlay()
{
	LinkSkelAnim(MeshAnimation'R61stShotgun_UKX.R61stShotgunM1A');
	super.PostBeginPlay();
	// End:0x2A
	if(__NFUN_114__(m_smGun, none))
	{
		m_smGun = __NFUN_278__(Class'R61stWeapons.R61stWeaponStaticMesh');
	}
	m_smGun.SetStaticMesh(StaticMesh'R61stWeapons_SM.Shotguns.R61stShotgunM1Frame');
	AttachToBone(m_smGun, 'TagFrame');
	return;
}

defaultproperties
{
	Mesh=SkeletalMesh'R61stShotgun_UKX.R61stShotgunM1'
}
