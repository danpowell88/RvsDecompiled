//=============================================================================
// SilencedSubMP5A4 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//============================================================================//
//  SilencedSubMP5A4.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class SilencedSubMP5A4 extends SubMP5A4;

defaultproperties
{
	m_iClipCapacity=30
	m_iNbOfClips=7
	m_iNbOfExtraClips=3
	m_fMuzzleVelocity=28500.0000000
	m_MuzzleScale=0.2725960
	m_fFireSoundRadius=285.0000000
	m_fRateOfFire=0.0750000
	m_pBulletClass=Class'R6Weapons.ammo9mmParabellumSubsonicFMJ'
	m_stAccuracyValues=(fBaseAccuracy=1.1559750,fShuffleAccuracy=1.8772330,fWalkingAccuracy=2.8158490,fWalkingFastAccuracy=11.6153800,fRunningAccuracy=11.6153800,fReticuleTime=0.7052500,fAccuracyChange=5.4958870,fWeaponJump=2.6579480)
	m_szReticuleClass="CIRCLEDOTLINE"
	m_bIsSilenced=true
	m_fFireAnimRate=1.3333330
	m_fFPBlend=0.7500000
	m_EquipSnd=Sound'CommonSMG.Play_SMG_Equip'
	m_UnEquipSnd=Sound'CommonSMG.Play_SMG_Unequip'
	m_ReloadSnd=Sound'Sub_MP5A4_Reloads.Play_Mp5A4_Reload'
	m_ReloadEmptySnd=Sound'Sub_MP5A4_Reloads.Play_Mp5A4_ReloadEmpty'
	m_ChangeROFSnd=Sound'CommonSMG.Play_SMG_ROF'
	m_SingleFireStereoSnd=Sound'Sub_MP5_SD5.Play_Mp5Sd5_SingleShots'
	m_BurstFireStereoSnd=Sound'Sub_MP5_SD5.Play_Mp5Sd5_TripleShots'
	m_FullAutoStereoSnd=Sound'Sub_MP5_SD5.Play_Mp5Sd5_AutoShots'
	m_FullAutoEndStereoSnd=Sound'Sub_MP5_SD5.Stop_Mp5Sd5_AutoShots_Go'
	m_TriggerSnd=Sound'CommonSMG.Play_SMG_Trigger'
	m_szMagazineClass="R63rdWeapons.R63rdMAG9mm"
	m_szSilencerClass="R6WeaponGadgets.R63rdSilencerSubGuns"
}
