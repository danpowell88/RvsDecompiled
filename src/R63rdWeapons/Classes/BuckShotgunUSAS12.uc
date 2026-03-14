//=============================================================================
// BuckShotgunUSAS12 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//============================================================================//
//  BuckShotgunUSAS12.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class BuckShotgunUSAS12 extends ShotgunUSAS12;

defaultproperties
{
	m_eRateOfFire=2
	m_iClipCapacity=20
	m_iNbOfClips=2
	m_iNbOfExtraClips=1
	m_fMuzzleVelocity=24780.0000000
	m_MuzzleScale=0.6464520
	m_fFireSoundRadius=1652.0000000
	m_fRateOfFire=0.2500000
	m_pBulletClass=Class'R6Weapons.ammo12gaugeBuck'
	m_stAccuracyValues=(fBaseAccuracy=3.4200010,fShuffleAccuracy=3.3279960,fWalkingAccuracy=4.1599960,fWalkingFastAccuracy=10.9199900,fRunningAccuracy=10.9199900,fReticuleTime=1.6587500,fAccuracyChange=7.6399670,fWeaponJump=11.6802700)
	m_szReticuleClass="CIRCLEDOT"
	m_fFPBlend=0.3662360
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
