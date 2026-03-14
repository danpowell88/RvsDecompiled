//=============================================================================
// R6Desc50calPistolFMJ - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//============================================================================//
//  R6Desc50calPistolFMJ.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class R6Desc50calPistolFMJ extends R6BulletDescription;

defaultproperties
{
	m_SubsonicClassName="R6Weapons.Ammo50calPistolSubsonicFMJ"
	m_2DMenuTexture=Texture'R6TextureMenuEquipment.Weapons_03'
	m_2dMenuRegion=(Zone=Class'R6Description.R6PistolsDescription',iLeaf=32802,ZoneNumber=0)
	m_NameID="50CALPISTOLFMJ"
	m_NameTag="FMJ"
	m_ClassName="R6Weapons.Ammo50calPistolNormalFMJ"
}
