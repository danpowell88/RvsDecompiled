//=============================================================================
// CMagSubMP5A4 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//============================================================================//
//  CMagSubMP5A4.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class CMagSubMP5A4 extends SubMP5A4;

defaultproperties
{
	m_iClipCapacity=100
	m_iNbOfClips=2
	m_iNbOfExtraClips=1
	m_fMuzzleVelocity=24000.0000000
	m_MuzzleScale=0.2761500
	m_fFireSoundRadius=1600.0000000
	m_fRateOfFire=0.0750000
	m_pBulletClass=Class'R6Weapons.ammo9mmParabellumNormalFMJ'
	m_stAccuracyValues=(fBaseAccuracy=1.3962260,fShuffleAccuracy=1.5649060,fWalkingAccuracy=2.3473580,fWalkingFastAccuracy=9.6828540,fRunningAccuracy=9.6828540,fReticuleTime=0.7543750,fAccuracyChange=6.5149840,fWeaponJump=4.2070590)
	m_szReticuleClass="CIRCLEDOTLINE"
	m_fFireAnimRate=1.3333330
	m_fFPBlend=0.7500000
	m_EquipSnd=Sound'CommonSMG.Play_SMG_Equip'
	m_UnEquipSnd=Sound'CommonSMG.Play_SMG_Unequip'
	m_ReloadSnd=Sound'Sub_MP5A4_Reloads.Play_Mp5A4_Reload'
	m_ReloadEmptySnd=Sound'Sub_MP5A4_Reloads.Play_Mp5A4_ReloadEmpty'
	m_ChangeROFSnd=Sound'CommonSMG.Play_SMG_ROF'
	m_SingleFireStereoSnd=Sound'Sub_MP5A4.Play_MP5A4_SingleShots'
	m_BurstFireStereoSnd=Sound'Sub_MP5A4.Play_MP5A4_TripleShots'
	m_FullAutoStereoSnd=Sound'Sub_MP5A4.Play_MP5A4_FullAuto'
	m_FullAutoEndStereoSnd=Sound'Sub_MP5A4.Stop_MP5A4_FullAuto_Go'
	m_TriggerSnd=Sound'CommonSMG.Play_SMG_Trigger'
	m_szMagazineClass="R63rdWeapons.R63rdCMAG9mmMP5"
}
