//=============================================================================
// R6DescSilencerPistol - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//============================================================================//
//  R6DescSilencerPistol.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class R6DescSilencerPistol extends R6WeaponGadgetDescription;

defaultproperties
{
	m_bPriGadgetWAvailable=true
	m_bSecGadgetWAvailable=true
	m_2DMenuTexture=Texture'R6TextureMenuEquipment.Weapons_00'
	m_2dMenuRegion=(Zone=Class'R6Description.R6PistolsDescription',iLeaf=99106,ZoneNumber=0)
	m_NameID="SILENCER"
	m_NameTag="SILENCED"
	m_ClassName="R6WeaponGadgets.R6SilencerGadget"
}
