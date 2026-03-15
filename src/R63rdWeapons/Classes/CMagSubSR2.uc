//=============================================================================
// CMagSubSR2 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//============================================================================//
//  CMagSubSR2.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class CMagSubSR2 extends SubSR2;

defaultproperties
{
	m_iClipCapacity=50
	m_iNbOfClips=4
	m_iNbOfExtraClips=2
	m_fMuzzleVelocity=25200.0000000
	m_MuzzleScale=0.4858010
	m_fFireSoundRadius=1680.0000000
	m_pBulletClass=Class'R6Weapons.ammo9x21mmRNormalFMJ'
	m_stAccuracyValues=(fBaseAccuracy=1.6176310,fShuffleAccuracy=2.0570800,fWalkingAccuracy=3.0856190,fWalkingFastAccuracy=12.7281800,fRunningAccuracy=12.7281800,fReticuleTime=0.3760000,fAccuracyChange=7.3613630,fWeaponJump=7.1978080)
	m_szReticuleClass="CIRCLEDOTLINE"
	m_fFPBlend=0.4288370
	m_EquipSnd=Sound'CommonSMG.Play_SMG_Equip'
	m_UnEquipSnd=Sound'CommonSMG.Play_SMG_Unequip'
	m_ReloadSnd=Sound'Mult_SR2MP_Reloads.Play_SR2MP_Reload'
	m_ReloadEmptySnd=Sound'Mult_SR2MP_Reloads.Play_SR2MP_ReloadEmpty'
	m_ChangeROFSnd=Sound'CommonSMG.Play_SMG_ROF'
	m_SingleFireStereoSnd=Sound'Mult_SR2MP.Play_SR2MP_SingleShots'
	m_FullAutoStereoSnd=Sound'Mult_SR2MP.Play_SR2MP_AutoShots'
	m_FullAutoEndStereoSnd=Sound'Mult_SR2MP.Stop_SR2MP_AutoShots_Go'
	m_TriggerSnd=Sound'CommonSMG.Play_SMG_Trigger'
	m_szMagazineClass="R63rdWeapons.R63rdMAG9mmHigh"
}
