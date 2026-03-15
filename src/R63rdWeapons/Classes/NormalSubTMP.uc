//=============================================================================
// NormalSubTMP - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//============================================================================//
//  NormalSubTMP.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class NormalSubTMP extends SubTMP;

defaultproperties
{
	m_iClipCapacity=30
	m_iNbOfClips=7
	m_iNbOfExtraClips=3
	m_fMuzzleVelocity=21000.0000000
	m_MuzzleScale=0.4605590
	m_fFireSoundRadius=1400.0000000
	m_fRateOfFire=0.0666670
	m_pBulletClass=Class'R6Weapons.ammo9mmParabellumNormalFMJ'
	m_stAccuracyValues=(fBaseAccuracy=1.7146330,fShuffleAccuracy=1.9309770,fWalkingAccuracy=2.8964650,fWalkingFastAccuracy=11.9479200,fRunningAccuracy=11.9479200,fReticuleTime=0.3066250,fAccuracyChange=7.8603820,fWeaponJump=5.9519020)
	m_szReticuleClass="CIRCLEDOTLINE"
	m_fFireAnimRate=1.5000000
	m_fFPBlend=0.5277030
	m_EquipSnd=Sound'CommonSMG.Play_SMG_Equip'
	m_UnEquipSnd=Sound'CommonSMG.Play_SMG_Unequip'
	m_ReloadSnd=Sound'Sub_TMP_Reloads.Play_TMP_Reload'
	m_ReloadEmptySnd=Sound'Sub_TMP_Reloads.Play_TMP_ReloadEmpty'
	m_ChangeROFSnd=Sound'CommonSMG.Play_SMG_ROF'
	m_SingleFireStereoSnd=Sound'Sub_TMP.Play_TMP_SingleShots'
	m_FullAutoStereoSnd=Sound'Sub_TMP.Play_TMP_AutoShots'
	m_FullAutoEndStereoSnd=Sound'Sub_TMP.Stop_TMP_AutoShots_Go'
	m_TriggerSnd=Sound'CommonSMG.Play_SMG_Trigger'
	m_szMagazineClass="R63rdWeapons.R63rdMAG9mmStraight"
}
