//=============================================================================
// SilencedSniperWA2000 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//============================================================================//
//  SilencedSniperWA2000.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class SilencedSniperWA2000 extends SniperWA2000;

defaultproperties
{
	m_iClipCapacity=6
	m_iNbOfClips=5
	m_iNbOfExtraClips=3
	m_fMuzzleVelocity=30000.0000000
	m_MuzzleScale=0.3583590
	m_fFireSoundRadius=300.0000000
	m_fRateOfFire=0.9837500
	m_pBulletClass=Class'R6Weapons.ammo30calMagnumSubsonicFMJ'
	m_stAccuracyValues=(fBaseAccuracy=0.5142046,fShuffleAccuracy=2.7115340,fWalkingAccuracy=4.0673010,fWalkingFastAccuracy=16.7776200,fRunningAccuracy=16.7776200,fReticuleTime=3.6890630,fAccuracyChange=3.0122360,fWeaponJump=2.2824040)
	m_szReticuleClass="SNIPER"
	m_bIsSilenced=true
	m_fFPBlend=0.9315760
	m_EquipSnd=Sound'CommonSniper.Play_Sniper_Equip'
	m_UnEquipSnd=Sound'CommonSniper.Play_Sniper_Unequip'
	m_ReloadSnd=Sound'Sniper_WA2000_Reloads.Play_WA2000_Reload'
	m_ReloadEmptySnd=Sound'Sniper_WA2000_Reloads.Play_WA2000_ReloadEmpty'
	m_SingleFireStereoSnd=Sound'Sniper_WA2000_Silenced.Play_WA2000Sil_SingleShots'
	m_TriggerSnd=Sound'CommonSniper.Play_Sniper_Trigger'
	m_szMagazineClass="R63rdWeapons.R63rdMAG762mm"
	m_szSilencerClass="R6WeaponGadgets.R63rdSilencerWA2000"
}
