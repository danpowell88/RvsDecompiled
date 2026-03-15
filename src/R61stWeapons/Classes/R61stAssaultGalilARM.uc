//=============================================================================
// R61stAssaultGalilARM - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  [R61stAssaultGalilARM] 
//===============================================================================
class R61stAssaultGalilARM extends R6
    AbstractFirstPersonWeapon;

function PostBeginPlay()
{
	LinkSkelAnim(MeshAnimation'R61stAssault_UKX.R61stAssaultGalilARMA');
	super.PostBeginPlay();
	// End:0x2A
	if((m_smGun == none))
	{
		m_smGun = Spawn(Class'R61stWeapons.R61stWeaponStaticMesh');
	}
	m_smGun.SetStaticMesh(StaticMesh'R61stWeapons_SM.AssaultRifles.R61stAssaultGalilARMFrame');
	AttachToBone(m_smGun, 'TagFrame');
	return;
}

defaultproperties
{
	Mesh=SkeletalMesh'R61stAssault_UKX.R61stAssaultGalilARM'
}
