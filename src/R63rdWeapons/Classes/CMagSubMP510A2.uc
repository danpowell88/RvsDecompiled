//=============================================================================
// CMagSubMP510A2 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//============================================================================//
//  CMagSubMP510A2.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class CMagSubMP510A2 extends SubMP510A2;

defaultproperties
{
	m_iClipCapacity=100
	m_iNbOfClips=2
	m_iNbOfExtraClips=1
	m_fMuzzleVelocity=26520.0000000
	m_MuzzleScale=0.4352540
	m_fFireSoundRadius=1768.0000000
	m_fRateOfFire=0.0857140
	m_pBulletClass=Class'R6Weapons.ammo10mmAutoNormalFMJ'
	m_stAccuracyValues=(fBaseAccuracy=1.4088050,fShuffleAccuracy=1.5485530,fWalkingAccuracy=2.3228300,fWalkingFastAccuracy=9.5816750,fRunningAccuracy=9.5816750,fReticuleTime=0.8987500,fAccuracyChange=6.9257770,fWeaponJump=8.1200590)
	m_szReticuleClass="CIRCLEDOTLINE"
	m_fFireAnimRate=1.1666670
	m_fFPBlend=0.7500000
	m_EquipSnd=Sound'CommonSMG.Play_SMG_Equip'
	m_UnEquipSnd=Sound'CommonSMG.Play_SMG_Unequip'
	m_ReloadSnd=Sound'Sub_MP5_10A2_Reloads.Play_MP5_10A2_Reload'
	m_ReloadEmptySnd=Sound'Sub_MP5_10A2_Reloads.Play_MP5_10A2_ReloadEmpty'
	m_ChangeROFSnd=Sound'CommonSMG.Play_SMG_ROF'
	m_SingleFireStereoSnd=Sound'Sub_MP5_10A2.Play_MP5_10A2_SingleShots'
	m_BurstFireStereoSnd=Sound'Sub_MP5_10A2.Play_MP5_10A2_TripleShots'
	m_FullAutoStereoSnd=Sound'Sub_MP5_10A2.Play_MP5_10A2_AutoShots'
	m_FullAutoEndStereoSnd=Sound'Sub_MP5_10A2.Stop_MP5_10A2_AutoShots_Go'
	m_TriggerSnd=Sound'CommonSMG.Play_SMG_Trigger'
	m_szMagazineClass="R63rdWeapons.R63rdCMAG9mmMP5"
}
