//=============================================================================
// R61stSubCZ61 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  [R61stSubCZ61]
//===============================================================================
class R61stSubCZ61 extends R6
    AbstractFirstPersonWeapon;

function PostBeginPlay()
{
	LinkSkelAnim(MeshAnimation'R61stSub_UKX.R61stSubCZ61A');
	super.PostBeginPlay();
	// End:0x2A
	if((m_smGun == none))
	{
		m_smGun = Spawn(Class'R61stWeapons.R61stWeaponStaticMesh');
	}
	m_smGun.SetStaticMesh(StaticMesh'R61stWeapons_SM.SubGuns.R61stSubCZ61Frame');
	AttachToBone(m_smGun, 'TagFrame');
	return;
}

defaultproperties
{
	Mesh=SkeletalMesh'R61stSub_UKX.R61stSubCZ61'
}
