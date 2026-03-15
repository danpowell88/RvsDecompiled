//=============================================================================
// R6DescSubP90 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//============================================================================//
//  R6DescSubP90.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class R6DescSubP90 extends R6SubGunDescription;

defaultproperties
{
	m_ARangePercent[0]=14
	m_ARangePercent[1]=5
	m_ADamagePercent[0]=17
	m_ADamagePercent[1]=8
	m_AAccuracyPercent[0]=39
	m_AAccuracyPercent[1]=48
	m_ARecoilPercent[0]=72
	m_ARecoilPercent[1]=94
	m_ARecoveryPercent[0]=93
	m_ARecoveryPercent[1]=90
	m_WeaponTags[0]="NORMAL"
	m_WeaponTags[1]="SILENCED"
	m_WeaponClasses[0]="R63rdWeapons.NormalSubP90"
	m_WeaponClasses[1]="R63rdWeapons.SilencedSubP90"
	m_MyGadgets[0]=Class'R6Description.R6DescMiniScope'
	m_MyGadgets[1]=Class'R6Description.R6DescSilencerSubGuns'
	m_Bullets[0]=Class'R6Description.R6Desc57x28mmFMJ'
	m_MagTag="R63RDMAGP90"
	m_2DMenuTexture=Texture'R6TextureMenuEquipment.Weapons_02'
	m_2dMenuRegion=(Zone=Class'R6Description.R6PistolsDescription',iLeaf=66082,ZoneNumber=0)
	m_NameID="SUBP90"
}
