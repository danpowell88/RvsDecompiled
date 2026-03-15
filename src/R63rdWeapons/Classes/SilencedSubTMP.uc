//=============================================================================
// SilencedSubTMP - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//============================================================================//
//  SilencedSubTMP.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class SilencedSubTMP extends SubTMP;

defaultproperties
{
	m_iClipCapacity=30
	m_iNbOfClips=7
	m_iNbOfExtraClips=3
	m_fMuzzleVelocity=28500.0000000
	m_MuzzleScale=0.2725960
	m_fFireSoundRadius=285.0000000
	m_fRateOfFire=0.0666670
	m_pBulletClass=Class'R6Weapons.ammo9mmParabellumSubsonicFMJ'
	m_stAccuracyValues=(fBaseAccuracy=1.3395390,fShuffleAccuracy=2.4186000,fWalkingAccuracy=3.6278990,fWalkingFastAccuracy=14.9650900,fRunningAccuracy=14.9650900,fReticuleTime=0.5301250,fAccuracyChange=5.9024110,fWeaponJump=3.4382170)
	m_szReticuleClass="CIRCLEDOTLINE"
	m_bIsSilenced=true
	m_fFireAnimRate=1.5000000
	m_fFPBlend=0.7271690
	m_EquipSnd=Sound'CommonSMG.Play_SMG_Equip'
	m_UnEquipSnd=Sound'CommonSMG.Play_SMG_Unequip'
	m_ReloadSnd=Sound'Sub_TMP_Reloads.Play_TMP_Reload'
	m_ReloadEmptySnd=Sound'Sub_TMP_Reloads.Play_TMP_ReloadEmpty'
	m_ChangeROFSnd=Sound'CommonSMG.Play_SMG_ROF'
	m_SingleFireStereoSnd=Sound'Sub_TMP_Silenced.Play_TMPSil_SingleShots'
	m_FullAutoStereoSnd=Sound'Sub_TMP_Silenced.Play_TMPSil_AutoShots'
	m_FullAutoEndStereoSnd=Sound'Sub_TMP_Silenced.Stop_TMPSil_AutoShots_Go'
	m_TriggerSnd=Sound'CommonSMG.Play_SMG_Trigger'
	m_szMagazineClass="R63rdWeapons.R63rdMAG9mmStraight"
	m_szSilencerClass="R6WeaponGadgets.R63rdSilencerSubGuns"
}
