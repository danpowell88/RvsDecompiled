//=============================================================================
// SilencedPistolSPP - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//============================================================================//
//  SilencedPistolSPP.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class SilencedPistolSPP extends PistolSPP;

defaultproperties
{
	m_iClipCapacity=30
	m_iNbOfClips=2
	m_iNbOfExtraClips=3
	m_fMuzzleVelocity=28500.0000000
	m_MuzzleScale=0.2960120
	m_fFireSoundRadius=285.0000000
	m_fRateOfFire=0.1000000
	m_pBulletClass=Class'R6Weapons.ammo9mmParabellumSubsonicFMJ'
	m_stAccuracyValues=(fBaseAccuracy=1.7084560,fShuffleAccuracy=3.0456250,fWalkingAccuracy=3.8070320,fWalkingFastAccuracy=15.7040100,fRunningAccuracy=15.7040100,fReticuleTime=1.1963750,fAccuracyChange=7.7854050,fWeaponJump=6.1176330)
	m_szReticuleClass="CIRCLE"
	m_bIsSilenced=true
	m_fFPBlend=0.7222390
	m_EquipSnd=Sound'CommonSMG.Play_SMG_Equip'
	m_UnEquipSnd=Sound'CommonSMG.Play_SMG_Unequip'
	m_ReloadSnd=Sound'Pistol_SPP_Reloads.Play_SPP_Reload'
	m_ReloadEmptySnd=Sound'Pistol_SPP_Reloads.Play_SPP_ReloadEmpty'
	m_SingleFireStereoSnd=Sound'Sub_TMP_Silenced.Play_TMPSil_SingleShots'
	m_TriggerSnd=Sound'CommonPistols.Play_Pistol_Trigger'
	m_szSilencerClass="R6WeaponGadgets.R63rdSilencerSubGuns"
}
