//=============================================================================
// R61stSubUMP - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//===============================================================================
//  [R61stSubUMP] 
//===============================================================================
class R61stSubUMP extends R6AbstractFirstPersonWeapon;

function PostBeginPlay()
{
	LinkSkelAnim(MeshAnimation'R61stSub_UKX.R61stSubUMPA');
	super.PostBeginPlay();
	// End:0x2A
	if(__NFUN_114__(m_smGun, none))
	{
		m_smGun = __NFUN_278__(Class'R61stWeapons.R61stWeaponStaticMesh');
	}
	m_smGun.SetStaticMesh(StaticMesh'R61stWeapons_SM.SubGuns.R61stSubUMPFrame');
	AttachToBone(m_smGun, 'TagFrame');
	return;
}

simulated function SwitchFPMesh()
{
	m_smGun.SetStaticMesh(StaticMesh'R61stWeapons_SM.SubGuns.R61stSubUMPForScopeFrame');
	return;
}

defaultproperties
{
	Mesh=SkeletalMesh'R61stSub_UKX.R61stSubUMP'
}
