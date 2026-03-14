//=============================================================================
// R6ArmorDescription - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6ArmorDescription.uc : This is mainly to accelerate the foreach search 
//                           when populating menu lists
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/22 * Created by Alexandre Dionne
//=============================================================================
class R6ArmorDescription extends R6Description;

var bool m_bHideFromMenu;
var name m_LimitedToClass;  // If the armor can only be used by specific operative.

defaultproperties
{
	m_LimitedToClass="R6Operative"
	m_2DMenuTexture=Texture'R6TextureMenuEquipment.ArmorNone'
	m_2dMenuRegion=(Zone=Class'R6Description.R6AssaultDescription',iLeaf=34082,ZoneNumber=0)
	m_NameTag="NONE"
}
