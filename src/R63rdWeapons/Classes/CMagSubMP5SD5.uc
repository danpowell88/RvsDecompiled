//=============================================================================
// CMagSubMP5SD5 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//============================================================================//
//  CMagSubMP5SD5.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class CMagSubMP5SD5 extends SubMP5SD5;

defaultproperties
{
	m_iClipCapacity=100
	m_iNbOfClips=2
	m_iNbOfExtraClips=1
	m_fMuzzleVelocity=28500.0000000
	m_MuzzleScale=0.2725960
	m_fFireSoundRadius=285.0000000
	m_fRateOfFire=0.0750000
	m_pBulletClass=Class'R6Weapons.ammo9mmParabellumSubsonicFMJ'
	m_stAccuracyValues=(fBaseAccuracy=1.3146050,fShuffleAccuracy=1.6710130,fWalkingAccuracy=2.5065200,fWalkingFastAccuracy=10.3393900,fRunningAccuracy=10.3393900,fReticuleTime=0.8875000,fAccuracyChange=6.1097860,fWeaponJump=1.9478310)
	m_szReticuleClass="CIRCLEDOTLINE"
	m_bIsSilenced=true
	m_fFireAnimRate=1.3333330
	m_fFPBlend=0.7500000
	m_EquipSnd=Sound'CommonSMG.Play_SMG_Equip'
	m_UnEquipSnd=Sound'CommonSMG.Play_SMG_Unequip'
	m_ReloadSnd=Sound'Sub_MP5_SD5_Reloads.Play_Mp5_SD5_Reload'
	m_ReloadEmptySnd=Sound'Sub_MP5_SD5_Reloads.Play_Mp5_SD5_ReloadEmpty'
	m_ChangeROFSnd=Sound'CommonSMG.Play_SMG_ROF'
	m_SingleFireStereoSnd=Sound'Sub_MP5_SD5.Play_Mp5Sd5_SingleShots'
	m_BurstFireStereoSnd=Sound'Sub_MP5_SD5.Play_Mp5Sd5_TripleShots'
	m_FullAutoStereoSnd=Sound'Sub_MP5_SD5.Play_Mp5Sd5_AutoShots'
	m_FullAutoEndStereoSnd=Sound'Sub_MP5_SD5.Stop_Mp5Sd5_AutoShots_Go'
	m_TriggerSnd=Sound'CommonSMG.Play_SMG_Trigger'
	m_szMagazineClass="R63rdWeapons.R63rdCMAG9mmMP5"
}
