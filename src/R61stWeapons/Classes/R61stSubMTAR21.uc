//=============================================================================
// R61stSubMTAR21 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  [R61stSubMTAR21] 
//===============================================================================
class R61stSubMTAR21 extends R6
    AbstractFirstPersonWeapon;

function PostBeginPlay()
{
	LinkSkelAnim(MeshAnimation'R61stSub_UKX.R61stSubMTAR21A');
	super.PostBeginPlay();
	// End:0x2A
	if((m_smGun == none))
	{
		m_smGun = Spawn(Class'R61stWeapons.R61stWeaponStaticMesh');
	}
	m_smGun.SetStaticMesh(StaticMesh'R61stWeapons_SM.SubGuns.R61stSubMTAR21Frame');
	AttachToBone(m_smGun, 'TagFrame');
	return;
}

simulated function SwitchFPMesh()
{
	m_smGun.SetStaticMesh(StaticMesh'R61stWeapons_SM.SubGuns.R61stSubMTAR21ForScopeFrame');
	return;
}

defaultproperties
{
	Mesh=SkeletalMesh'R61stSub_UKX.R61stSubMTAR21'
}
