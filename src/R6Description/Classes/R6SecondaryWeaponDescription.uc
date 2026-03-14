//=============================================================================
// R6SecondaryWeaponDescription - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6SecondaryWeaponDescription.uc : This is mainly to accelerate the foreach search 
//                           when populating menu lists
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/22 * Created by Alexandre Dionne
//=============================================================================
class R6SecondaryWeaponDescription extends R6Description;

var array<int> m_ARangePercent;
var array<int> m_ADamagePercent;
var array<int> m_AAccuracyPercent;
var array<int> m_ARecoilPercent;
var array<int> m_ARecoveryPercent;
var array<string> m_WeaponTags;  // This is used to find the correct class of weapon to spawn
var array<string> m_WeaponClasses;  // Class of weapon to spawn according to the tagIg index in m_WeaponTags
var array< Class > m_MyGadgets;  // Array of R6WeaponGadgetDescription classes
var array< Class > m_Bullets;  // Array of R6BulletDescription classes
var string m_MagTag;  // To retreive the right texture for extra mag

defaultproperties
{
	m_MyGadgets[0]=Class'R6Description.R6DescWeaponGadgetNone'
	m_Bullets[0]=Class'R6Description.R6DescBulletNone'
	m_2DMenuTexture=Texture'R6TextureMenuEquipment.SecondaryNone1'
	m_2dMenuRegion=(Zone=Class'R6Description.R6AssaultDescription',iLeaf=25634,ZoneNumber=0)
	m_NameTag="NONE"
}
