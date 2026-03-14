//=============================================================================
// CMagPistolSR2 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//============================================================================//
//  CMagPistolSR2.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class CMagPistolSR2 extends PistolSR2;

defaultproperties
{
	m_iClipCapacity=30
	m_iNbOfClips=2
	m_iNbOfExtraClips=2
	m_fMuzzleVelocity=25200.0000000
	m_MuzzleScale=0.6477350
	m_fFireSoundRadius=1680.0000000
	m_fRateOfFire=0.1000000
	m_pBulletClass=Class'R6Weapons.ammo9x21mmRNormalFMJ'
	m_stAccuracyValues=(fBaseAccuracy=1.8374560,fShuffleAccuracy=2.8263240,fWalkingAccuracy=3.5329050,fWalkingFastAccuracy=14.5732300,fRunningAccuracy=14.5732300,fReticuleTime=1.1808120,fAccuracyChange=8.4691210,fWeaponJump=8.3230980)
	m_szReticuleClass="CIRCLE"
	m_fFPBlend=0.3395420
	m_EquipSnd=Sound'CommonSMG.Play_SMG_Equip'
	m_UnEquipSnd=Sound'CommonSMG.Play_SMG_Unequip'
	m_ReloadSnd=Sound'Mult_SR2MP_Reloads.Play_SR2MP_Reload'
	m_ReloadEmptySnd=Sound'Mult_SR2MP_Reloads.Play_SR2MP_ReloadEmpty'
	m_ChangeROFSnd=Sound'CommonSMG.Play_SMG_ROF'
	m_SingleFireStereoSnd=Sound'Mult_SR2MP.Play_SR2MP_SingleShots'
	m_FullAutoStereoSnd=Sound'Mult_SR2MP.Play_SR2MP_AutoShots'
	m_FullAutoEndStereoSnd=Sound'Mult_SR2MP.Stop_SR2MP_AutoShots_Go'
	m_TriggerSnd=Sound'CommonPistols.Play_Pistol_Trigger'
	m_szMagazineClass="R63rdWeapons.R63rdMAGPistolHigh"
}
