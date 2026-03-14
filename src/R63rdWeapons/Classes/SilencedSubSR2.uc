//=============================================================================
// SilencedSubSR2 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//============================================================================//
//  SilencedSubSR2.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class SilencedSubSR2 extends SubSR2;

defaultproperties
{
	m_iClipCapacity=20
	m_iNbOfClips=10
	m_iNbOfExtraClips=4
	m_fMuzzleVelocity=28500.0000000
	m_MuzzleScale=0.2640290
	m_fFireSoundRadius=285.0000000
	m_pBulletClass=Class'R6Weapons.ammo9x21mmRSubsonicFMJ'
	m_stAccuracyValues=(fBaseAccuracy=1.3759330,fShuffleAccuracy=2.3712870,fWalkingAccuracy=3.5569310,fWalkingFastAccuracy=14.6723400,fRunningAccuracy=14.6723400,fReticuleTime=0.4489375,fAccuracyChange=6.0935600,fWeaponJump=3.5445560)
	m_szReticuleClass="CIRCLEDOTLINE"
	m_bIsSilenced=true
	m_fFPBlend=0.7187310
	m_EquipSnd=Sound'CommonSMG.Play_SMG_Equip'
	m_UnEquipSnd=Sound'CommonSMG.Play_SMG_Unequip'
	m_ReloadSnd=Sound'Mult_SR2MP_Reloads.Play_SR2MP_Reload'
	m_ReloadEmptySnd=Sound'Mult_SR2MP_Reloads.Play_SR2MP_ReloadEmpty'
	m_ChangeROFSnd=Sound'CommonSMG.Play_SMG_ROF'
	m_SingleFireStereoSnd=Sound'Mult_SR2MP_Silenced.Play_SR2MPSil_SingleShots'
	m_FullAutoStereoSnd=Sound'Mult_SR2MP_Silenced.Play_SR2MPSil_AutoShots'
	m_FullAutoEndStereoSnd=Sound'Mult_SR2MP_Silenced.Stop_SR2MPSil_AutoShots_Go'
	m_TriggerSnd=Sound'CommonSMG.Play_SMG_Trigger'
	m_szMagazineClass="R63rdWeapons.R63rdMAGPistol"
	m_szSilencerClass="R6WeaponGadgets.R63rdSilencerSubGuns"
}
