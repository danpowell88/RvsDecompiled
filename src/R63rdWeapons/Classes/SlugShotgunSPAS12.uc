//=============================================================================
// SlugShotgunSPAS12 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//============================================================================//
//  SlugShotgunSPAS12.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class SlugShotgunSPAS12 extends ShotgunSPAS12;

defaultproperties
{
	m_iClipCapacity=8
	m_iNbOfClips=32
	m_iNbOfExtraClips=20
	m_fMuzzleVelocity=28320.0000000
	m_MuzzleScale=0.9702510
	m_fFireSoundRadius=1888.0000000
	m_fRateOfFire=0.6843330
	m_pBulletClass=Class'R6Weapons.ammo12gaugeSlug'
	m_pEmptyShells=Class'R6SFX.R6Shell12GaugeSlug'
	m_stAccuracyValues=(fBaseAccuracy=1.3182390,fShuffleAccuracy=2.1789940,fWalkingAccuracy=2.7237420,fWalkingFastAccuracy=11.2354400,fRunningAccuracy=11.2354400,fReticuleTime=1.0397500,fAccuracyChange=4.5758490,fWeaponJump=20.2984100)
	m_szReticuleClass="CIRCLEDOT"
	m_EquipSnd=Sound'CommonShotguns.Play_Shotgun_Equip'
	m_UnEquipSnd=Sound'CommonShotguns.Play_Shotgun_Unequip'
	m_ReloadEmptySnd=Sound'Shotgun_SPAS12_Reloads.Play_SPAS12_ReloadEmpty'
	m_SingleFireStereoSnd=Sound'Shotgun_SPAS12.Play_SPAS12_SingleShots'
	m_TriggerSnd=Sound'CommonShotguns.Play_Shotgun_Trigger'
}
