//=============================================================================
// SilencedPistolP228 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//============================================================================//
//  SilencedPistolP228.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class SilencedPistolP228 extends PistolP228;

defaultproperties
{
	m_iClipCapacity=13
	m_iNbOfClips=4
	m_iNbOfExtraClips=6
	m_fMuzzleVelocity=28500.0000000
	m_MuzzleScale=0.2960120
	m_fFireSoundRadius=285.0000000
	m_fRateOfFire=0.1000000
	m_pBulletClass=Class'R6Weapons.ammo9mmParabellumSubsonicFMJ'
	m_stAccuracyValues=(fBaseAccuracy=1.4837180,fShuffleAccuracy=1.8976800,fWalkingAccuracy=2.3721000,fWalkingFastAccuracy=9.7849120,fRunningAccuracy=9.7849120,fReticuleTime=1.0446880,fAccuracyChange=8.5256380,fWeaponJump=8.3330180)
	m_szReticuleClass="CIRCLE"
	m_bIsSilenced=true
	m_fFPBlend=0.6216520
	m_EquipSnd=Sound'CommonPistols.Play_Pistol_Equip'
	m_UnEquipSnd=Sound'CommonPistols.Play_Pistol_Unequip'
	m_ReloadSnd=Sound'Pistol_P228_Reloads.Play_P228_Reload'
	m_ReloadEmptySnd=Sound'Pistol_P228_Reloads.Play_P228_ReloadEmpty'
	m_SingleFireStereoSnd=Sound'Pistol_P228_Silenced.Play_P228Sil_SingleShots'
	m_EmptyMagSnd=Sound'Pistol_P228_Reloads.Play_P228_Chamber'
	m_TriggerSnd=Sound'CommonPistols.Play_Pistol_Trigger'
	m_szSilencerClass="R6WeaponGadgets.R63rdSilencerPistol"
}
