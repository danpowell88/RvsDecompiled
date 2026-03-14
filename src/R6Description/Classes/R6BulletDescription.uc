//=============================================================================
// R6BulletDescription - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6BulletDescription.uc : This is mainly to accelerate the foreach search 
//                           when populating menu lists
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/22 * Created by Alexandre Dionne
//=============================================================================
class R6BulletDescription extends R6Description;

var string m_SubsonicClassName;  // Class of item to spawn if the gun is silenced

defaultproperties
{
	m_2DMenuTexture=Texture'R6TextureMenuEquipment.PrimaryNone2'
	m_2dMenuRegion=(Zone=Class'R6Description.R6AssaultDescription',iLeaf=16418,ZoneNumber=0)
	m_NameTag="NONE"
}
