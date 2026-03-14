//=============================================================================
// NormalAssaultAK47 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//============================================================================//
//  NormalAssaultAK47.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class NormalAssaultAK47 extends AssaultAK47;

defaultproperties
{
	m_iClipCapacity=30
	m_iNbOfClips=6
	m_iNbOfExtraClips=3
	m_fMuzzleVelocity=42900.0000000
	m_MuzzleScale=0.7565270
	m_fFireSoundRadius=2860.0000000
	m_pBulletClass=Class'R6Weapons.ammo762mmM43NormalFMJ'
	m_stAccuracyValues=(fBaseAccuracy=1.0960600,fShuffleAccuracy=1.9551220,fWalkingAccuracy=2.9326840,fWalkingFastAccuracy=12.0973200,fRunningAccuracy=12.0973200,fReticuleTime=0.8762500,fAccuracyChange=6.3579650,fWeaponJump=14.0884100)
	m_szReticuleClass="RIFLE"
	m_EquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Equip'
	m_UnEquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Unequip'
	m_ReloadSnd=Sound'Assault_AK47_Reloads.Play_AK47_Reload'
	m_ReloadEmptySnd=Sound'Assault_AK47_Reloads.Play_AK47_ReloadEmpty'
	m_ChangeROFSnd=Sound'CommonAssaultRiffles.Play_Assault_ROF'
	m_SingleFireStereoSnd=Sound'Assault_AK47.Play_AK47_SingleShots'
	m_FullAutoStereoSnd=Sound'Assault_AK47.Play_AK47_AutoShots'
	m_FullAutoEndStereoSnd=Sound'Assault_AK47.Stop_AK47_AutoShots_Go'
	m_TriggerSnd=Sound'CommonAssaultRiffles.Play_Assault_Trigger'
	m_szMagazineClass="R63rdWeapons.R63rdMAGAK47"
	m_szMuzzleClass="R6WeaponGadgets.R63rdMuzzleAK47"
}
