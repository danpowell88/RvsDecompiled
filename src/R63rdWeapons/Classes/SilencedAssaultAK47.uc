//=============================================================================
// SilencedAssaultAK47 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//============================================================================//
//  SilencedAssaultAK47.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class SilencedAssaultAK47 extends AssaultAK47;

defaultproperties
{
	m_iClipCapacity=30
	m_iNbOfClips=6
	m_iNbOfExtraClips=3
	m_fMuzzleVelocity=29600.0000000
	m_MuzzleScale=0.3328880
	m_fFireSoundRadius=296.0000000
	m_pBulletClass=Class'R6Weapons.ammo762mmM43SubsonicFMJ'
	m_stAccuracyValues=(fBaseAccuracy=0.6809654,fShuffleAccuracy=2.4947450,fWalkingAccuracy=3.7421180,fWalkingFastAccuracy=15.4362400,fRunningAccuracy=15.4362400,fReticuleTime=1.1987500,fAccuracyChange=3.4180240,fWeaponJump=3.0289130)
	m_szReticuleClass="RIFLE"
	m_bIsSilenced=true
	m_fFPBlend=0.7500000
	m_EquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Equip'
	m_UnEquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Unequip'
	m_ReloadSnd=Sound'Assault_AK47_Reloads.Play_AK47_Reload'
	m_ReloadEmptySnd=Sound'Assault_AK47_Reloads.Play_AK47_ReloadEmpty'
	m_ChangeROFSnd=Sound'CommonAssaultRiffles.Play_Assault_ROF'
	m_SingleFireStereoSnd=Sound'Assault_AK47_Silenced.Play_AK47Sil_SingleShots'
	m_FullAutoStereoSnd=Sound'Assault_AK47_Silenced.Play_AK47Sil_AutoShots'
	m_FullAutoEndStereoSnd=Sound'Assault_AK47_Silenced.Stop_AK47Sil_AutoShots_Go'
	m_TriggerSnd=Sound'CommonAssaultRiffles.Play_Assault_Trigger'
	m_szMagazineClass="R63rdWeapons.R63rdMAGAK47"
	m_szSilencerClass="R6WeaponGadgets.R63rdSilencerSubGuns"
}
