//=============================================================================
// NormalSubMP5KPDW - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//============================================================================//
//  NormalSubMP5KPDW.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class NormalSubMP5KPDW extends SubMP5KPDW;

defaultproperties
{
	m_iClipCapacity=30
	m_iNbOfClips=7
	m_iNbOfExtraClips=3
	m_fMuzzleVelocity=22500.0000000
	m_MuzzleScale=0.2517920
	m_fFireSoundRadius=1500.0000000
	m_fRateOfFire=0.0750000
	m_pBulletClass=Class'R6Weapons.ammo9mmParabellumNormalFMJ'
	m_stAccuracyValues=(fBaseAccuracy=1.9163170,fShuffleAccuracy=2.1887870,fWalkingAccuracy=3.2831810,fWalkingFastAccuracy=13.5431200,fRunningAccuracy=13.5431200,fReticuleTime=0.5344375,fAccuracyChange=7.1960250,fWeaponJump=6.2095130)
	m_szReticuleClass="CIRCLEDOTLINE"
	m_fFireAnimRate=1.3333330
	m_fFPBlend=0.5072610
	m_EquipSnd=Sound'CommonSMG.Play_SMG_Equip'
	m_UnEquipSnd=Sound'CommonSMG.Play_SMG_Unequip'
	m_ReloadSnd=Sound'Sub_MP5KPD_Reloads.Play_MP5KPD_Reload'
	m_ReloadEmptySnd=Sound'Sub_MP5KPD_Reloads.Play_MP5KPD_ReloadEmpty'
	m_ChangeROFSnd=Sound'CommonSMG.Play_SMG_ROF'
	m_SingleFireStereoSnd=Sound'Sub_MP5KPD.Play_Mp5KPD_SingleShots'
	m_BurstFireStereoSnd=Sound'Sub_MP5KPD.Play_Mp5KPD_TripleShots'
	m_FullAutoStereoSnd=Sound'Sub_MP5KPD.Play_Mp5KPD_AutoShots'
	m_FullAutoEndStereoSnd=Sound'Sub_MP5KPD.Stop_Mp5KPD_AutoShots_Go'
	m_TriggerSnd=Sound'CommonSMG.Play_SMG_Trigger'
	m_szMagazineClass="R63rdWeapons.R63rdMAG9mm"
}
