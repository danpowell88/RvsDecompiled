//=============================================================================
// R61stPistolAPArmy - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//===============================================================================
//  [R61stPistolAPArmy] 
//===============================================================================
class R61stPistolAPArmy extends R6
    AbstractFirstPersonWeapon;

function PostBeginPlay()
{
	LinkSkelAnim(MeshAnimation'R61stPistol_UKX.R61stPistolAPArmyA');
	super.PostBeginPlay();
	m_smGun = Spawn(Class'R61stWeapons.R61stWeaponStaticMesh');
	m_smGun.SetStaticMesh(StaticMesh'R61stWeapons_SM.Pistols.R61stPistolAPArmyFrame');
	AttachToBone(m_smGun, 'TagFrame');
	m_smGun2 = Spawn(Class'R61stWeapons.R61stWeaponStaticMesh');
	m_smGun2.SetStaticMesh(StaticMesh'R61stWeapons_SM.Pistols.R61stPistolAPArmySlide');
	AttachToBone(m_smGun2, 'TagSlide');
	return;
}

defaultproperties
{
	Mesh=SkeletalMesh'R61stPistol_UKX.R61stPistolAPArmy'
}
