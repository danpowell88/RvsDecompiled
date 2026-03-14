//=============================================================================
// R61stGrenadeSmoke - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//===============================================================================
//  [R61stGrenadeSmoke] 
//===============================================================================
class R61stGrenadeSmoke extends R6AbstractFirstPersonWeapon;

function PostBeginPlay()
{
	LinkSkelAnim(MeshAnimation'R61stGrenade_UKX.R61stGrenadeA');
	super.PostBeginPlay();
	m_smGun = __NFUN_278__(Class'R61stWeapons.R61stWeaponStaticMesh');
	m_smGun.SetStaticMesh(StaticMesh'R61stWeapons_SM.Grenades.R61stGrenadeSmoke');
	AttachToBone(m_smGun, 'TagFrame');
	return;
}

defaultproperties
{
	Mesh=SkeletalMesh'R61stGrenade_UKX.R61stGrenade'
}
