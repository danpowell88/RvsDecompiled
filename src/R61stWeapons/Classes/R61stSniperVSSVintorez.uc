//=============================================================================
// R61stSniperVSSVintorez - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//===============================================================================
//  [R61stSniperVSSVintorez] 
//===============================================================================
class R61stSniperVSSVintorez extends R61stSniperDragunov;

function PostBeginPlay()
{
	LinkSkelAnim(MeshAnimation'R61stSniper_UKX.R61stSniperVSSVintorezA');
	super.PostBeginPlay();
	// End:0x2A
	if((m_smGun == none))
	{
		m_smGun = Spawn(Class'R61stWeapons.R61stWeaponStaticMesh');
	}
	m_smGun.SetStaticMesh(StaticMesh'R61stWeapons_SM.SniperRifles.R61stSniperVSSVintorezFrame');
	AttachToBone(m_smGun, 'TagFrame');
	return;
}

defaultproperties
{
	Mesh=SkeletalMesh'R61stSniper_UKX.R61stSniperVSSVintorez'
}
