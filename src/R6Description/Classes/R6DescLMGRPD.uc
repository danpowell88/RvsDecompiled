//=============================================================================
// R6DescLMGRPD - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//============================================================================//
//  R6DescLMGRPD.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class R6DescLMGRPD extends R6LMGDescription;

defaultproperties
{
	m_ARangePercent[0]=37
	m_ADamagePercent[0]=77
	m_AAccuracyPercent[0]=41
	m_ARecoilPercent[0]=61
	m_ARecoveryPercent[0]=70
	m_WeaponTags[0]="NORMAL"
	m_WeaponClasses[0]="R63rdWeapons.NormalLMGRPD"
	m_Bullets[0]=Class'R6Description.R6Desc762mmM43FMJ'
	m_MagTag="R63RDMAGRPD"
	m_2DMenuTexture=Texture'R6TextureMenuEquipment.Weapons_01'
	m_2dMenuRegion=(Zone=Class'R6Description.R6PistolsDescription',iLeaf=66082,ZoneNumber=0)
	m_NameID="LMGRPD"
}
