//=============================================================================
// SilencedSniperM82A1 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//============================================================================//
//  SilencedSniperM82A1.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class SilencedSniperM82A1 extends SniperM82A1;

defaultproperties
{
	m_iClipCapacity=10
	m_iNbOfClips=3
	m_iNbOfExtraClips=2
	m_fMuzzleVelocity=30000.0000000
	m_MuzzleScale=0.8203130
	m_fFireSoundRadius=300.0000000
	m_fRateOfFire=1.7120000
	m_pBulletClass=Class'R6Weapons.ammo50calM33SubsonicFMJ'
	m_stAccuracyValues=(fBaseAccuracy=0.0262566,fShuffleAccuracy=3.3458660,fWalkingAccuracy=5.0188000,fWalkingFastAccuracy=20.7025500,fRunningAccuracy=20.7025500,fReticuleTime=6.4200000,fAccuracyChange=1.1238770,fWeaponJump=4.4311690)
	m_szReticuleClass="SNIPER"
	m_bIsSilenced=true
	m_fFPBlend=0.8671580
	m_EquipSnd=Sound'CommonSniper.Play_Sniper_Equip'
	m_UnEquipSnd=Sound'CommonSniper.Play_Sniper_Unequip'
	m_ReloadSnd=Sound'Sniper_M82A1_Reloads.Play_M82A1_Reload'
	m_ReloadEmptySnd=Sound'Sniper_M82A1_Reloads.Play_M82A1_ReloadEmpty'
	m_SingleFireStereoSnd=Sound'Sniper_M82A1_Silenced.Play_M82A1Sil_SingleShots'
	m_TriggerSnd=Sound'CommonSniper.Play_Sniper_Trigger'
	m_szMagazineClass="R63rdWeapons.R63rdMAGM82A1"
	m_szSilencerClass="R6WeaponGadgets.R63rdSilencerM82A1"
}
