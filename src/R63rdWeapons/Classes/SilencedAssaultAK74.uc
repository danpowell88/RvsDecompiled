//=============================================================================
// SilencedAssaultAK74 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//============================================================================//
//  SilencedAssaultAK74.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class SilencedAssaultAK74 extends AssaultAK74;

defaultproperties
{
	m_iClipCapacity=30
	m_iNbOfClips=6
	m_iNbOfExtraClips=3
	m_fMuzzleVelocity=30000.0000000
	m_MuzzleScale=0.2305310
	m_fFireSoundRadius=300.0000000
	m_fRateOfFire=0.0923080
	m_pBulletClass=Class'R6Weapons.ammo545mm7N6SubsonicFMJ'
	m_stAccuracyValues=(fBaseAccuracy=0.5484958,fShuffleAccuracy=2.6669550,fWalkingAccuracy=4.0004330,fWalkingFastAccuracy=16.5017900,fRunningAccuracy=16.5017900,fReticuleTime=1.0913130,fAccuracyChange=2.9519720,fWeaponJump=1.0154870)
	m_szReticuleClass="RIFLE"
	m_bIsSilenced=true
	m_fFireAnimRate=1.0833330
	m_fFPBlend=0.7500000
	m_EquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Equip'
	m_UnEquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Unequip'
	m_ReloadSnd=Sound'Assault_AK74_Reloads.Play_AK74_Reload'
	m_ReloadEmptySnd=Sound'Assault_AK74_Reloads.Play_AK74_ReloadEmpty'
	m_ChangeROFSnd=Sound'CommonAssaultRiffles.Play_Assault_ROF'
	m_SingleFireStereoSnd=Sound'Assault_AK74_Silenced.Play_AK74Sil_SingleShots'
	m_FullAutoStereoSnd=Sound'Assault_AK74_Silenced.Play_AK74Sil_AutoShots'
	m_FullAutoEndStereoSnd=Sound'Assault_AK74_Silenced.Stop_AK74Sil_AutoShots_Go'
	m_TriggerSnd=Sound'CommonAssaultRiffles.Play_Assault_Trigger'
	m_szMagazineClass="R63rdWeapons.R63rdMAGAK74"
	m_szSilencerClass="R6WeaponGadgets.R63rdSilencerSubGuns"
}
