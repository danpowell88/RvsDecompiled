//=============================================================================
// SlugShotgunUSAS12 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//============================================================================//
//  SlugShotgunUSAS12.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class SlugShotgunUSAS12 extends ShotgunUSAS12;

defaultproperties
{
	m_eRateOfFire=2
	m_iClipCapacity=20
	m_iNbOfClips=2
	m_iNbOfExtraClips=1
	m_fMuzzleVelocity=28320.0000000
	m_MuzzleScale=0.9702510
	m_fFireSoundRadius=1888.0000000
	m_fRateOfFire=0.2500000
	m_pBulletClass=Class'R6Weapons.ammo12gaugeSlug'
	m_pEmptyShells=Class'R6SFX.R6Shell12GaugeSlug'
	m_stAccuracyValues=(fBaseAccuracy=1.3680010,fShuffleAccuracy=2.0943990,fWalkingAccuracy=2.6179990,fWalkingFastAccuracy=10.7992400,fRunningAccuracy=10.7992400,fReticuleTime=1.5575000,fAccuracyChange=6.0055650,fWeaponJump=13.8029200)
	m_szReticuleClass="CIRCLEDOT"
	m_fFPBlend=0.2510620
	m_EquipSnd=Sound'CommonShotguns.Play_Shotgun_Equip'
	m_UnEquipSnd=Sound'CommonShotguns.Play_Shotgun_Unequip'
	m_ReloadSnd=Sound'Shotgun_USAS12_Reloads.Play_USAS12_Reload'
	m_ReloadEmptySnd=Sound'Shotgun_USAS12_Reloads.Play_USAS12_ReloadEmpty'
	m_ChangeROFSnd=Sound'CommonWeapons.Play_ChangeROF'
	m_SingleFireStereoSnd=Sound'Shotgun_USAS12.Play_USAS12_SingleShots'
	m_FullAutoStereoSnd=Sound'Shotgun_USAS12.Play_USAS12_AutoShots'
	m_FullAutoEndStereoSnd=Sound'Shotgun_USAS12.Stop_USAS12_AutoShots_Go'
	m_TriggerSnd=Sound'CommonShotguns.Play_Shotgun_Trigger'
	m_szMagazineClass="R63rdWeapons.R63rdMAGUSAS12"
}
