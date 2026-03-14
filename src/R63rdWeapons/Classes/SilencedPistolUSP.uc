//=============================================================================
// SilencedPistolUSP - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//============================================================================//
//  SilencedPistolUSP.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class SilencedPistolUSP extends PistolUSP;

defaultproperties
{
	m_iClipCapacity=13
	m_iNbOfClips=4
	m_iNbOfExtraClips=6
	m_fMuzzleVelocity=28500.0000000
	m_MuzzleScale=0.3211400
	m_fFireSoundRadius=285.0000000
	m_fRateOfFire=0.1000000
	m_pBulletClass=Class'R6Weapons.ammo40calAutoSubsonicFMJ'
	m_stAccuracyValues=(fBaseAccuracy=1.4985390,fShuffleAccuracy=1.8724830,fWalkingAccuracy=2.3406040,fWalkingFastAccuracy=9.6549930,fRunningAccuracy=9.6549930,fReticuleTime=1.0313750,fAccuracyChange=8.7059010,fWeaponJump=10.6460000)
	m_szReticuleClass="CIRCLE"
	m_bIsSilenced=true
	m_fFPBlend=0.5166350
	m_EquipSnd=Sound'CommonPistols.Play_Pistol_Equip'
	m_UnEquipSnd=Sound'CommonPistols.Play_Pistol_Unequip'
	m_ReloadSnd=Sound'Pistol_USP_Reloads.Play_USP_Reload'
	m_ReloadEmptySnd=Sound'Pistol_USP_Reloads.Play_USP_ReloadEmpty'
	m_SingleFireStereoSnd=Sound'Pistol_USP_Silenced.Play_USPSil_SingleShots'
	m_EmptyMagSnd=Sound'Pistol_USP_Reloads.Play_USP_Chamber'
	m_TriggerSnd=Sound'CommonPistols.Play_Pistol_Trigger'
	m_szSilencerClass="R6WeaponGadgets.R63rdSilencerPistol"
}
