//=============================================================================
// SilencedSubMTAR21 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//============================================================================//
//  SilencedSubMTAR21.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class SilencedSubMTAR21 extends SubMTAR21;

defaultproperties
{
	m_iClipCapacity=30
	m_iNbOfClips=7
	m_iNbOfExtraClips=3
	m_fMuzzleVelocity=28500.0000000
	m_MuzzleScale=0.2725960
	m_fFireSoundRadius=285.0000000
	m_fRateOfFire=0.0727270
	m_pBulletClass=Class'R6Weapons.ammo9mmParabellumSubsonicFMJ'
	m_stAccuracyValues=(fBaseAccuracy=1.2765900,fShuffleAccuracy=1.9804330,fWalkingAccuracy=2.9706500,fWalkingFastAccuracy=12.2539300,fRunningAccuracy=12.2539300,fReticuleTime=0.8810000,fAccuracyChange=5.9626670,fWeaponJump=2.7176330)
	m_szReticuleClass="CIRCLEDOTLINE"
	m_bIsSilenced=true
	m_fFireAnimRate=1.3750000
	m_fFPBlend=0.7500000
	m_EquipSnd=Sound'CommonSMG.Play_SMG_Equip'
	m_UnEquipSnd=Sound'CommonSMG.Play_SMG_Unequip'
	m_ReloadSnd=Sound'Sub_MTAR21_Reloads.Play_MTAR21_Reload'
	m_ReloadEmptySnd=Sound'Sub_MTAR21_Reloads.Play_MTAR21_ReloadEmpty'
	m_ChangeROFSnd=Sound'CommonSMG.Play_SMG_ROF'
	m_SingleFireStereoSnd=Sound'Sub_MTAR21_Silenced.Play_MTAR21Sil_SingleShots'
	m_FullAutoStereoSnd=Sound'Sub_MTAR21_Silenced.Play_MTAR21Sil_AutoShots'
	m_FullAutoEndStereoSnd=Sound'Sub_MTAR21_Silenced.Stop_MTAR21Sil_AutoShots_Go'
	m_TriggerSnd=Sound'CommonSMG.Play_SMG_Trigger'
	m_szMagazineClass="R63rdWeapons.R63rdMAG556mm"
	m_szSilencerClass="R6WeaponGadgets.R63rdSilencerSubGuns"
}
