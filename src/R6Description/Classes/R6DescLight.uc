//=============================================================================
// R6DescLight - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//============================================================================//
//  R6DescLight.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class R6DescLight extends R6ArmorDescription;

defaultproperties
{
	m_2DMenuTexture=Texture'R6TextureMenuEquipment.Armor00'
	m_2dMenuRegion=(Zone=Class'R6Description.R6PistolsDescription',iLeaf=60962,ZoneNumber=0)
	m_NameID="LIGHT"
	m_NameTag="1"
	m_ClassName="R6Characters.R6RainbowLight"
}
