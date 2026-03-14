//=============================================================================
// R6DescSniperAWCovert - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//============================================================================//
//  R6DescSniperAWCovert.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class R6DescSniperAWCovert extends R6SniperDescription;

defaultproperties
{
	m_ARangePercent[0]=19
	m_ADamagePercent[0]=40
	m_AAccuracyPercent[0]=83
	m_ARecoilPercent[0]=90
	m_ARecoveryPercent[0]=52
	m_WeaponTags[0]="NORMAL"
	m_WeaponClasses[0]="R63rdWeapons.SilencedSniperAWCovert"
	m_MyGadgets[0]=Class'R6Description.R6DescThermalScope'
	m_Bullets[0]=Class'R6Description.R6Desc762mmNATOFMJ'
	m_MagTag="R63RDMAG762MM"
	m_2DMenuTexture=Texture'R6TextureMenuEquipment.Weapons_01'
	m_2dMenuRegion=(Zone=Class'R6Description.R6SecondaryWeaponDescription',iLeaf=39458,ZoneNumber=0)
	m_NameID="SNIPERAWCOVERT"
}
