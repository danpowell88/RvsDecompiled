//=============================================================================
// SilencedSubUzi - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//============================================================================//
//  SilencedSubUzi.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class SilencedSubUzi extends SubUzi;

defaultproperties
{
	m_iClipCapacity=32
	m_iNbOfClips=7
	m_iNbOfExtraClips=3
	m_fMuzzleVelocity=28500.0000000
	m_MuzzleScale=0.2725960
	m_fFireSoundRadius=285.0000000
	m_pBulletClass=Class'R6Weapons.ammo9mmParabellumSubsonicFMJ'
	m_stAccuracyValues=(fBaseAccuracy=1.1100210,fShuffleAccuracy=2.4569730,fWalkingAccuracy=3.6854590,fWalkingFastAccuracy=15.2025200,fRunningAccuracy=15.2025200,fReticuleTime=0.9328750,fAccuracyChange=5.1134840,fWeaponJump=2.7598660)
	m_szReticuleClass="CIRCLEDOTLINE"
	m_bIsSilenced=true
	m_fFPBlend=0.7500000
	m_EquipSnd=Sound'CommonSMG.Play_SMG_Equip'
	m_UnEquipSnd=Sound'CommonSMG.Play_SMG_Unequip'
	m_ReloadSnd=Sound'Mult_Uzi_Reloads.Play_UZI_Reload'
	m_ReloadEmptySnd=Sound'Mult_Uzi_Reloads.Play_UZI_ReloadEmpty'
	m_ChangeROFSnd=Sound'CommonSMG.Play_SMG_ROF'
	m_SingleFireStereoSnd=Sound'Mult_Uzi_Silenced.Play_UZI_Sil_SingleShots'
	m_FullAutoStereoSnd=Sound'Mult_Uzi_Silenced.Play_UZI_Sil_AutoShots'
	m_FullAutoEndStereoSnd=Sound'Mult_Uzi_Silenced.Stop_UZI_Sil_AutoShots_Go'
	m_TriggerSnd=Sound'CommonSMG.Play_SMG_Trigger'
	m_szMagazineClass="R63rdWeapons.R63rdMAG9mmStraight"
	m_szSilencerClass="R6WeaponGadgets.R63rdSilencerSubGuns"
}
