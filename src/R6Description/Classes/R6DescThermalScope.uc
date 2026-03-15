//=============================================================================
// R6DescThermalScope - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//============================================================================//
//  R6DescThermalScope.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class R6DescThermalScope extends R6WeaponGadgetDescription;

defaultproperties
{
	m_bPriGadgetWAvailable=true
	m_2DMenuTexture=Texture'R6TextureMenuEquipment.Weapons_00'
	m_2dMenuRegion=(Zone=Class'R6Description.R6PistolsDescription',iLeaf=99106,ZoneNumber=0)
	m_NameID="THERMALSCOPE"
	m_NameTag="NORMAL"
	m_ClassName="R6WeaponGadgets.R6ThermalScopeGadget"
}
