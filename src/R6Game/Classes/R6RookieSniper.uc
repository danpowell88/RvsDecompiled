//=============================================================================
// R6RookieSniper - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//============================================================================//
//  R6RookieSniper.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class R6RookieSniper extends R6Operative;

defaultproperties
{
	m_RMenuFaceW=187
	m_RMenuFaceSmallX=472
	m_RMenuFaceSmallY=308
	m_fAssault=25.0000000
	m_fDemolitions=20.0000000
	m_fElectronics=20.0000000
	m_fSniper=65.0000000
	m_fStealth=55.0000000
	m_fSelfControl=75.0000000
	m_fLeadership=80.0000000
	m_fObservation=60.0000000
	m_szOperativeClass="R6RookieSniper"
	m_szSpecialityID="ID_SNIPER"
	m_szPrimaryWeapon="R6Description.R6DescSniperPSG1"
	m_szPrimaryWeaponGadget="None"
	m_szPrimaryWeaponBullet="FMJ"
	m_szPrimaryGadget="R6Description.R6DescSmokeGrenadeGadget"
	m_szSecondaryWeapon="R6Description.R6DescPistol92FS"
	m_szSecondaryWeaponGadget="None"
	m_szSecondaryGadget="R6Description.R6DescSmokeGrenadeGadget"
	m_szArmor="R6Description.R6DescLight"
}
