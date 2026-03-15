//=============================================================================
// R61stSniperDragunov - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  [R61stSniperDragunov] 
//===============================================================================
class R61stSniperDragunov extends R61stSniperSSG3000;

function PostBeginPlay()
{
	LinkSkelAnim(MeshAnimation'R61stSniper_UKX.R61stSniperDragunovA');
	super.PostBeginPlay();
	// End:0x2A
	if((m_smGun == none))
	{
		m_smGun = Spawn(Class'R61stWeapons.R61stWeaponStaticMesh');
	}
	m_smGun.SetStaticMesh(StaticMesh'R61stWeapons_SM.SniperRifles.R61stSniperDragunovFrame');
	AttachToBone(m_smGun, 'TagFrame');
	return;
}

defaultproperties
{
	Mesh=SkeletalMesh'R61stSniper_UKX.R61stSniperDragunov'
}
