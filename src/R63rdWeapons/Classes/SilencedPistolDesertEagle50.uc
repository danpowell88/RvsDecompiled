//=============================================================================
// SilencedPistolDesertEagle50 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//============================================================================//
//  SilencedPistolDesertEagle50.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class SilencedPistolDesertEagle50 extends PistolDesertEagle50;

defaultproperties
{
	m_iClipCapacity=7
	m_iNbOfClips=4
	m_iNbOfExtraClips=6
	m_fMuzzleVelocity=28500.0000000
	m_MuzzleScale=0.4465570
	m_fFireSoundRadius=285.0000000
	m_fRateOfFire=0.1000000
	m_pBulletClass=Class'R6Weapons.ammo50calPistolSubsonicFMJ'
	m_stAccuracyValues=(fBaseAccuracy=1.3975460,fShuffleAccuracy=2.0441720,fWalkingAccuracy=2.5552150,fWalkingFastAccuracy=10.5402600,fRunningAccuracy=10.5402600,fReticuleTime=1.5954380,fAccuracyChange=8.2939400,fWeaponJump=10.0482700)
	m_szReticuleClass="CIRCLE"
	m_bIsSilenced=true
	m_fFPBlend=0.5437740
	m_EquipSnd=Sound'CommonPistols.Play_Pistol_Equip'
	m_UnEquipSnd=Sound'CommonPistols.Play_Pistol_Unequip'
	m_ReloadSnd=Sound'Pistol_Des50_Reloads.Play_Des50_Reload'
	m_ReloadEmptySnd=Sound'Pistol_Des50_Reloads.Play_Des50_ReloadEmpty'
	m_SingleFireStereoSnd=Sound'Pistol_Des50_Silenced.Play_Des50Sil_SingleShots'
	m_EmptyMagSnd=Sound'Pistol_Des50_Reloads.Play_Des50_Chamber'
	m_TriggerSnd=Sound'CommonPistols.Play_Pistol_Trigger'
	m_szSilencerClass="R6WeaponGadgets.R63rdSilencerPistol"
}
