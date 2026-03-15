//=============================================================================
// R6WeaponGadgetDescription - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6WeaponGadgetDescription.uc : This is mainly to accelerate the foreach search 
//                           when populating menu lists
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/24 * Created by Alexandre Dionne
//=============================================================================
class R6WeaponGadgetDescription extends R6Description;

var bool m_bPriGadgetWAvailable;
var bool m_bSecGadgetWAvailable;

defaultproperties
{
	m_2DMenuTexture=Texture'R6TextureMenuEquipment.PrimaryNone3'
	m_2dMenuRegion=(Zone=Class'R6Description.R6AssaultDescription',iLeaf=16418,ZoneNumber=0)
	m_NameTag="NONE"
}
