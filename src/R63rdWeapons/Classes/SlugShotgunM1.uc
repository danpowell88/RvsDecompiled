//=============================================================================
// SlugShotgunM1 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//============================================================================//
//  SlugShotgunM1.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class SlugShotgunM1 extends ShotgunM1;

defaultproperties
{
	m_iClipCapacity=6
	m_iNbOfClips=34
	m_iNbOfExtraClips=20
	m_fMuzzleVelocity=28320.0000000
	m_MuzzleScale=0.9702510
	m_fFireSoundRadius=1888.0000000
	m_fRateOfFire=0.3000000
	m_pBulletClass=Class'R6Weapons.ammo12gaugeSlug'
	m_pEmptyShells=Class'R6SFX.R6Shell12GaugeSlug'
	m_stAccuracyValues=(fBaseAccuracy=1.2583510,fShuffleAccuracy=2.2808040,fWalkingAccuracy=2.8510050,fWalkingFastAccuracy=11.7604000,fRunningAccuracy=11.7604000,fReticuleTime=0.7885000,fAccuracyChange=5.8272400,fWeaponJump=23.0000000)
	m_szReticuleClass="CIRCLEDOT"
	m_EquipSnd=Sound'CommonShotguns.Play_Shotgun_Equip'
	m_UnEquipSnd=Sound'CommonShotguns.Play_Shotgun_Unequip'
	m_ReloadEmptySnd=Sound'Shotgun_M1_Reloads.Play_M1_ReloadEmpty'
	m_SingleFireStereoSnd=Sound'Shotgun_M1.Play_M1_SingleShots'
	m_TriggerSnd=Sound'CommonShotguns.Play_Shotgun_Trigger'
}
