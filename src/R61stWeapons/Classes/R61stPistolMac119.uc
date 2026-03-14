//=============================================================================
// R61stPistolMac119 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//===============================================================================
//  [R61stPistolMac119] 
//===============================================================================
class R61stPistolMac119 extends R6AbstractFirstPersonWeapon;

function PostBeginPlay()
{
	LinkSkelAnim(MeshAnimation'R61stPistol_UKX.R61stPistolMac119A');
	super.PostBeginPlay();
	m_smGun = __NFUN_278__(Class'R61stWeapons.R61stWeaponStaticMesh');
	m_smGun.SetStaticMesh(StaticMesh'R61stWeapons_SM.Pistols.R61stPistolMac119Frame');
	AttachToBone(m_smGun, 'TagFrame');
	return;
}

defaultproperties
{
	Mesh=SkeletalMesh'R61stPistol_UKX.R61stPistolMac119'
}
