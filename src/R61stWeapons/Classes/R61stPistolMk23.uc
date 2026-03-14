//=============================================================================
// R61stPistolMk23 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//===============================================================================
//  [R61stPistolMk23] 
//===============================================================================
class R61stPistolMk23 extends R6AbstractFirstPersonWeapon;

function PostBeginPlay()
{
	LinkSkelAnim(MeshAnimation'R61stPistol_UKX.R61stPistolMk23A');
	super.PostBeginPlay();
	m_smGun = __NFUN_278__(Class'R61stWeapons.R61stWeaponStaticMesh');
	m_smGun.SetStaticMesh(StaticMesh'R61stWeapons_SM.Pistols.R61stPistolMk23Frame');
	AttachToBone(m_smGun, 'TagFrame');
	m_smGun2 = __NFUN_278__(Class'R61stWeapons.R61stWeaponStaticMesh');
	m_smGun2.SetStaticMesh(StaticMesh'R61stWeapons_SM.Pistols.R61stPistolMk23Slide');
	AttachToBone(m_smGun2, 'TagSlide');
	return;
}

defaultproperties
{
	Mesh=SkeletalMesh'R61stPistol_UKX.R61stPistolMk23'
}
