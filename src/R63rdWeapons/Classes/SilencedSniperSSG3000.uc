//=============================================================================
// SilencedSniperSSG3000 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//============================================================================//
//  SilencedSniperSSG3000.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class SilencedSniperSSG3000 extends SniperSSG3000;

defaultproperties
{
	m_iClipCapacity=5
	m_iNbOfClips=6
	m_iNbOfExtraClips=4
	m_fMuzzleVelocity=30000.0000000
	m_MuzzleScale=0.3515250
	m_fFireSoundRadius=300.0000000
	m_fRateOfFire=1.0329170
	m_pBulletClass=Class'R6Weapons.ammo762mmNATOSubsonicFMJ'
	m_stAccuracyValues=(fBaseAccuracy=0.1947044,fShuffleAccuracy=3.1268840,fWalkingAccuracy=4.6903260,fWalkingFastAccuracy=19.3476000,fRunningAccuracy=19.3476000,fReticuleTime=3.8734370,fAccuracyChange=1.7757700,fWeaponJump=2.2575480)
	m_szReticuleClass="SNIPER"
	m_bIsSilenced=true
	m_fFPBlend=0.9323210
	m_EquipSnd=Sound'CommonSniper.Play_Sniper_Equip'
	m_UnEquipSnd=Sound'CommonSniper.Play_Sniper_Unequip'
	m_ReloadSnd=Sound'Sniper_SSG3000_Reloads.Play_SSG3000_Reload'
	m_ReloadEmptySnd=Sound'Sniper_SSG3000_Reloads.Play_SSG3000_ReloadEmpty'
	m_SingleFireStereoSnd=Sound'Sniper_SSG3000_Silenced.Play_SSG3000Sil_SingleShots'
	m_TriggerSnd=Sound'CommonSniper.Play_Sniper_Trigger'
	m_szMagazineClass="R63rdWeapons.R63rdMAG762mm"
	m_szSilencerClass="R6WeaponGadgets.R63rdSilencerSnipers"
}
