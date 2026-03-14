//=============================================================================
// R61stShotgunSPAS12 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//===============================================================================
//  [R61stShotgunSPAS12] 
//===============================================================================
class R61stShotgunSPAS12 extends R6AbstractFirstPersonWeapon;

function PostBeginPlay()
{
	LinkSkelAnim(MeshAnimation'R61stShotgun_UKX.R61stShotgunSPAS12A');
	super.PostBeginPlay();
	m_FireLast = m_Neutral;
	// End:0x35
	if(__NFUN_114__(m_smGun, none))
	{
		m_smGun = __NFUN_278__(Class'R61stWeapons.R61stWeaponStaticMesh');
	}
	m_smGun.SetStaticMesh(StaticMesh'R61stWeapons_SM.Shotguns.R61stShotgunSPAS12Frame');
	AttachToBone(m_smGun, 'TagFrame');
	// End:0x72
	if(__NFUN_114__(m_smGun2, none))
	{
		m_smGun2 = __NFUN_278__(Class'R61stWeapons.R61stWeaponStaticMesh');
	}
	m_smGun2.SetStaticMesh(StaticMesh'R61stWeapons_SM.Shotguns.R61stShotgunSPAS12Pump');
	AttachToBone(m_smGun2, 'TagPump');
	return;
}

defaultproperties
{
	Mesh=SkeletalMesh'R61stShotgun_UKX.R61stShotgunSPAS12'
}
