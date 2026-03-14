//=============================================================================
// SilencedSniperPSG1 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//============================================================================//
//  SilencedSniperPSG1.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class SilencedSniperPSG1 extends SniperPSG1;

defaultproperties
{
	m_iClipCapacity=10
	m_iNbOfClips=3
	m_iNbOfExtraClips=2
	m_fMuzzleVelocity=30000.0000000
	m_MuzzleScale=0.3515250
	m_fFireSoundRadius=300.0000000
	m_fRateOfFire=1.1520000
	m_pBulletClass=Class'R6Weapons.ammo762mmNATOSubsonicFMJ'
	m_stAccuracyValues=(fBaseAccuracy=0.1330725,fShuffleAccuracy=3.2070060,fWalkingAccuracy=4.8105090,fWalkingFastAccuracy=19.8433500,fRunningAccuracy=19.8433500,fReticuleTime=4.3200000,fAccuracyChange=1.5372550,fWeaponJump=3.8473890)
	m_szReticuleClass="SNIPER"
	m_bIsSilenced=true
	m_fFPBlend=0.8846590
	m_EquipSnd=Sound'CommonSniper.Play_Sniper_Equip'
	m_UnEquipSnd=Sound'CommonSniper.Play_Sniper_Unequip'
	m_ReloadSnd=Sound'Sniper_PSG1_Reloads.Play_PSG1_Reload'
	m_ReloadEmptySnd=Sound'Sniper_PSG1_Reloads.Play_PSG1_ReloadEmpty'
	m_SingleFireStereoSnd=Sound'Sniper_PSG1_Silenced.Play_PSG1Sil_SingleShots'
	m_TriggerSnd=Sound'CommonSniper.Play_Sniper_Trigger'
	m_szMagazineClass="R63rdWeapons.R63rdMAG762mm"
	m_szSilencerClass="R6WeaponGadgets.R63rdSilencerSnipers"
}
