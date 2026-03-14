//=============================================================================
// SilencedSubMac119 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//============================================================================//
//  SilencedSubMac119.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class SilencedSubMac119 extends SubMac119;

defaultproperties
{
	m_iClipCapacity=32
	m_iNbOfClips=7
	m_iNbOfExtraClips=3
	m_fMuzzleVelocity=28500.0000000
	m_MuzzleScale=0.2725960
	m_fFireSoundRadius=285.0000000
	m_fRateOfFire=0.0500000
	m_pBulletClass=Class'R6Weapons.ammo9mmParabellumSubsonicFMJ'
	m_stAccuracyValues=(fBaseAccuracy=1.8060800,fShuffleAccuracy=3.1770960,fWalkingAccuracy=4.7656450,fWalkingFastAccuracy=19.6582900,fRunningAccuracy=19.6582900,fReticuleTime=0.4388125,fAccuracyChange=7.0185620,fWeaponJump=3.5526000)
	m_szReticuleClass="CIRCLEDOTLINE"
	m_bIsSilenced=true
	m_fFireAnimRate=2.0000000
	m_fFPBlend=0.7180930
	m_EquipSnd=Sound'CommonSMG.Play_SMG_Equip'
	m_UnEquipSnd=Sound'CommonSMG.Play_SMG_Unequip'
	m_ReloadSnd=Sound'Mult_Mac11_Reloads.Play_Mac11_Reload'
	m_ReloadEmptySnd=Sound'Mult_Mac11_Reloads.Play_Mac11_ReloadEmpty'
	m_SingleFireStereoSnd=Sound'Mult_Mac11_Silenced.Play_Ingram_Sil_SingleShots'
	m_FullAutoStereoSnd=Sound'Mult_Mac11_Silenced.Play_Ingram_Sil_AutoShots'
	m_FullAutoEndStereoSnd=Sound'Mult_Mac11_Silenced.Stop_Ingram_Sil_AutoShots_Go'
	m_TriggerSnd=Sound'CommonSMG.Play_SMG_Trigger'
	m_szMagazineClass="R63rdWeapons.R63rdMAG9mmStraight"
	m_szSilencerClass="R6WeaponGadgets.R63rdSilencerSubGuns"
}
