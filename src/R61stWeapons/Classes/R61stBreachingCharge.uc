//=============================================================================
// R61stBreachingCharge - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R61stBreachingCharge.uc : (add small description)
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/05 * Created by Rima Brek
//=============================================================================
class R61stBreachingCharge extends R6
    AbstractFirstPersonWeapon;

simulated function PostBeginPlay()
{
	LinkSkelAnim(MeshAnimation'R61stItems_UKX.R61stItemAttachementA');
	super.PostBeginPlay();
	m_smGun = Spawn(Class'R61stWeapons.R61stWeaponStaticMesh');
	m_smGun.SetStaticMesh(StaticMesh'R61stWeapons_SM.Items.R61stBreachingCharge');
	AttachToBone(m_smGun, 'TagFrame');
	return;
}

defaultproperties
{
	Mesh=SkeletalMesh'R61stItems_UKX.R61stItemAttachement'
}
