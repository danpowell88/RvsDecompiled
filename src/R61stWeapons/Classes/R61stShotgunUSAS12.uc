//=============================================================================
// R61stShotgunUSAS12 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//===============================================================================
//  [R61stShotgunUSAS12]  
//===============================================================================
class R61stShotgunUSAS12 extends R6
    AbstractFirstPersonWeapon;

function PostBeginPlay()
{
	LinkSkelAnim(MeshAnimation'R61stShotgun_UKX.R61stShotgunUSAS12A');
	super.PostBeginPlay();
	// End:0x2A
	if((m_smGun == none))
	{
		m_smGun = Spawn(Class'R61stWeapons.R61stWeaponStaticMesh');
	}
	m_smGun.SetStaticMesh(StaticMesh'R61stWeapons_SM.Shotguns.R61stShotgunUSAS12Frame');
	AttachToBone(m_smGun, 'TagFrame');
	// End:0x67
	if((m_smGun2 == none))
	{
		m_smGun2 = Spawn(Class'R61stWeapons.R61stWeaponStaticMesh');
	}
	m_smGun2.SetStaticMesh(StaticMesh'R61stWeapons_SM.Shotguns.R61stShotgunUSAS12Magazine');
	AttachToBone(m_smGun2, 'TagMagazine');
	return;
}

defaultproperties
{
	Mesh=SkeletalMesh'R61stShotgun_UKX.R61stShotgunUSAS12'
}
