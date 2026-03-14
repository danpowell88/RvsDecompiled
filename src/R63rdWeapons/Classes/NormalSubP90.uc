//=============================================================================
// NormalSubP90 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//============================================================================//
//  NormalSubP90.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class NormalSubP90 extends SubP90;

defaultproperties
{
	m_iClipCapacity=50
	m_iNbOfClips=4
	m_iNbOfExtraClips=2
	m_fMuzzleVelocity=42900.0000000
	m_MuzzleScale=0.4718130
	m_fFireSoundRadius=2860.0000000
	m_fRateOfFire=0.0666670
	m_pBulletClass=Class'R6Weapons.ammo57x28mmNormalFMJ'
	m_stAccuracyValues=(fBaseAccuracy=1.5162750,fShuffleAccuracy=1.9288430,fWalkingAccuracy=2.8932640,fWalkingFastAccuracy=11.9347100,fRunningAccuracy=11.9347100,fReticuleTime=0.6687500,fAccuracyChange=7.3554190,fWeaponJump=6.4542160)
	m_szReticuleClass="CIRCLEDOTLINE"
	m_fFireAnimRate=1.5000000
	m_fFPBlend=0.4878430
	m_EquipSnd=Sound'CommonSMG.Play_SMG_Equip'
	m_UnEquipSnd=Sound'CommonSMG.Play_SMG_Unequip'
	m_ReloadSnd=Sound'Sub_P90_Reloads.Play_P90_Reload'
	m_ReloadEmptySnd=Sound'Sub_P90_Reloads.Play_P90_ReloadEmpty'
	m_ChangeROFSnd=Sound'CommonSMG.Play_SMG_ROF'
	m_SingleFireStereoSnd=Sound'Sub_P90.Play_P90_SingleShots'
	m_FullAutoStereoSnd=Sound'Sub_P90.Play_P90_AutoShots'
	m_FullAutoEndStereoSnd=Sound'Sub_P90.Stop_P90_AutoShots_Go'
	m_TriggerSnd=Sound'CommonSMG.Play_SMG_Trigger'
	m_szMagazineClass="R63rdWeapons.R63rdMAGP90"
}
