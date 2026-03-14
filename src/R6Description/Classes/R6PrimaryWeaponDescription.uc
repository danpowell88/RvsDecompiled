//=============================================================================
//  R6PrimaryWeaponDescription.uc : This is mainly to accelerate the foreach search 
//                           when populating menu lists
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/22 * Created by Alexandre Dionne
//=============================================================================
class R6PrimaryWeaponDescription extends R6Description;

// --- Variables ---
//Array of R6BulletDescription classes
var array<array> m_Bullets;
//Array of R6WeaponGadgetDescription classes
var array<array> m_MyGadgets;
var array<array> m_ARangePercent;
var array<array> m_ADamagePercent;
var array<array> m_AAccuracyPercent;
var array<array> m_ARecoilPercent;
var array<array> m_ARecoveryPercent;
//This is used to find the correct class of weapon to spawn
var array<array> m_WeaponTags;
//Class of weapon to spawn according to the tagIg index in m_WeaponTags
var array<array> m_WeaponClasses;
//To retreive the right texture for extra mag
var string m_MagTag;

defaultproperties
{
}
