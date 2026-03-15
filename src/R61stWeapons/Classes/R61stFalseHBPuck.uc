//=============================================================================
// R61stFalseHBPuck - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//===============================================================================
//  [R61stFalseHBPuck]
//===============================================================================
class R61stFalseHBPuck extends R6
    AbstractFirstPersonWeapon;

simulated function PostBeginPlay()
{
	LinkSkelAnim(MeshAnimation'R61stItems_UKX.R61stItemAttachementA');
	super.PostBeginPlay();
	m_smGun = Spawn(Class'R61stWeapons.R61stWeaponStaticMesh');
	m_smGun.SetStaticMesh(StaticMesh'R61stWeapons_SM.Items.R61stFalseHBPuck');
	AttachToBone(m_smGun, 'TagFrame');
	return;
}

defaultproperties
{
	Mesh=SkeletalMesh'R61stItems_UKX.R61stItemAttachement'
}
