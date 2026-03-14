//=============================================================================
// NormalSniperPSG1 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//============================================================================//
//  NormalSniperPSG1.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class NormalSniperPSG1 extends SniperPSG1;

defaultproperties
{
	m_iClipCapacity=10
	m_iNbOfClips=3
	m_iNbOfExtraClips=2
	m_fMuzzleVelocity=50280.0000000
	m_MuzzleScale=0.8358480
	m_fFireSoundRadius=3352.0000000
	m_fRateOfFire=1.0270000
	m_pBulletClass=Class'R6Weapons.ammo762mmNATONormalFMJ'
	m_stAccuracyValues=(fBaseAccuracy=0.4286700,fShuffleAccuracy=2.8227290,fWalkingAccuracy=4.2340940,fWalkingFastAccuracy=17.4656400,fRunningAccuracy=17.4656400,fReticuleTime=3.8512500,fAccuracyChange=2.6812170,fWeaponJump=17.7676200)
	m_szReticuleClass="SNIPER"
	m_fFPBlend=0.4673440
	m_EquipSnd=Sound'CommonSniper.Play_Sniper_Equip'
	m_UnEquipSnd=Sound'CommonSniper.Play_Sniper_Unequip'
	m_ReloadSnd=Sound'Sniper_PSG1_Reloads.Play_PSG1_Reload'
	m_ReloadEmptySnd=Sound'Sniper_PSG1_Reloads.Play_PSG1_ReloadEmpty'
	m_SingleFireStereoSnd=Sound'Sniper_PSG1.Play_PSG1_SingleShots'
	m_TriggerSnd=Sound'CommonSniper.Play_Sniper_Trigger'
	m_szMagazineClass="R63rdWeapons.R63rdMAG762mm"
}
