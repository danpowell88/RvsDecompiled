//=============================================================================
// R61stAssaultAK74 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//===============================================================================
//  [R61stAssaultAK74] 
//===============================================================================
class R61stAssaultAK74 extends R61stAssaultAK47;

function PostBeginPlay()
{
	super.PostBeginPlay();
	// End:0x1F
	if(__NFUN_114__(m_smGun, none))
	{
		m_smGun = __NFUN_278__(Class'R61stWeapons.R61stWeaponStaticMesh');
	}
	m_smGun.SetStaticMesh(StaticMesh'R61stWeapons_SM.AssaultRifles.R61stAssaultAK74Frame');
	AttachToBone(m_smGun, 'TagFrame');
	return;
}

defaultproperties
{
	Mesh=SkeletalMesh'R61stAssault_UKX.R61stAssaultAK74'
}
