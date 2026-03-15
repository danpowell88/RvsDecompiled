//=============================================================================
// SilencedSubMicroUzi - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//============================================================================//
//  SilencedSubMicroUzi.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class SilencedSubMicroUzi extends SubMicroUzi;

defaultproperties
{
	m_iClipCapacity=32
	m_iNbOfClips=7
	m_iNbOfExtraClips=3
	m_fMuzzleVelocity=28500.0000000
	m_MuzzleScale=0.2960120
	m_fFireSoundRadius=285.0000000
	m_pBulletClass=Class'R6Weapons.ammo9mmParabellumSubsonicFMJ'
	m_stAccuracyValues=(fBaseAccuracy=1.5451360,fShuffleAccuracy=2.1513230,fWalkingAccuracy=3.2269840,fWalkingFastAccuracy=13.3113100,fRunningAccuracy=13.3113100,fReticuleTime=0.3962500,fAccuracyChange=6.5782840,fWeaponJump=6.5847700)
	m_szReticuleClass="CIRCLEDOTLINE"
	m_bIsSilenced=true
	m_fFPBlend=0.4774830
	m_EquipSnd=Sound'CommonSMG.Play_SMG_Equip'
	m_UnEquipSnd=Sound'CommonSMG.Play_SMG_Unequip'
	m_ReloadSnd=Sound'Mult_UziPistol_Reloads.Play_UZIPistol_Reload'
	m_ReloadEmptySnd=Sound'Mult_UziPistol_Reloads.Play_UZIPistol_ReloadEmpty'
	m_ChangeROFSnd=Sound'CommonSMG.Play_SMG_ROF'
	m_SingleFireStereoSnd=Sound'Mult_UziPistol_Silenced.Play_UziPistol_Sil_SingleShots'
	m_FullAutoStereoSnd=Sound'Mult_UziPistol_Silenced.Play_UziPistol_Sil_AutoShots'
	m_FullAutoEndStereoSnd=Sound'Mult_UziPistol_Silenced.Stop_UziPistol_Sil_AutoShots_Go'
	m_TriggerSnd=Sound'CommonSMG.Play_SMG_Trigger'
	m_szMagazineClass="R63rdWeapons.R63rdMAG9mmStraight"
	m_szSilencerClass="R6WeaponGadgets.R63rdSilencerSubGuns"
}
