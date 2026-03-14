//=============================================================================
// R6DescLMGM249 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//============================================================================//
//  R6DescLMGM249.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class R6DescLMGM249 extends R6LMGDescription;

defaultproperties
{
	m_ARangePercent[0]=39
	m_ADamagePercent[0]=55
	m_AAccuracyPercent[0]=52
	m_ARecoilPercent[0]=72
	m_ARecoveryPercent[0]=70
	m_WeaponTags[0]="NORMAL"
	m_WeaponClasses[0]="R63rdWeapons.NormalLMGM249"
	m_Bullets[0]=Class'R6Description.R6Desc556mmNATOFMJ'
	m_MagTag="R63RDMAGBOX556MM"
	m_2DMenuTexture=Texture'R6TextureMenuEquipment.Weapons_01'
	m_NameID="LMGM249"
}
