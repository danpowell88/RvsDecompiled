//=============================================================================
// SilencedSniperAWCovert - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//============================================================================//
//  SilencedSniperAWCovert.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class SilencedSniperAWCovert extends SniperAWCovert;

defaultproperties
{
	m_iClipCapacity=10
	m_iNbOfClips=3
	m_iNbOfExtraClips=2
	m_fMuzzleVelocity=30000.0000000
	m_MuzzleScale=0.3515250
	m_fFireSoundRadius=300.0000000
	m_fRateOfFire=0.8666670
	m_pBulletClass=Class'R6Weapons.ammo762mmNATOSubsonicFMJ'
	m_stAccuracyValues=(fBaseAccuracy=0.4275079,fShuffleAccuracy=2.8242400,fWalkingAccuracy=4.2363600,fWalkingFastAccuracy=17.4749800,fRunningAccuracy=17.4749800,fReticuleTime=3.2500000,fAccuracyChange=2.6767200,fWeaponJump=2.7337500)
	m_szReticuleClass="SNIPER"
	m_bIsSilenced=true
	m_fFPBlend=0.9180450
	m_EquipSnd=Sound'CommonSniper.Play_Sniper_Equip'
	m_UnEquipSnd=Sound'CommonSniper.Play_Sniper_Unequip'
	m_ReloadSnd=Sound'Sniper_AWCovert_Reloads.Play_AWCovert_Reload'
	m_ReloadEmptySnd=Sound'Sniper_AWCovert_Reloads.Play_AWCovert_ReloadEmpty'
	m_SingleFireStereoSnd=Sound'Sniper_AWCovert.Play_AWCovert_SingleShots'
	m_TriggerSnd=Sound'CommonSniper.Play_Sniper_Trigger'
	m_szMagazineClass="R63rdWeapons.R63rdMAG762mm"
}
