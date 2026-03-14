//=============================================================================
// SilencedSubMP5KPDW - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//============================================================================//
//  SilencedSubMP5KPDW.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class SilencedSubMP5KPDW extends SubMP5KPDW;

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
	m_stAccuracyValues=(fBaseAccuracy=1.6160030,fShuffleAccuracy=2.5791960,fWalkingAccuracy=3.8687940,fWalkingFastAccuracy=15.9587800,fRunningAccuracy=15.9587800,fReticuleTime=0.7487500,fAccuracyChange=6.0254090,fWeaponJump=3.0569850)
	m_szReticuleClass="CIRCLEDOTLINE"
	m_bIsSilenced=true
	m_fFireAnimRate=1.3333330
	m_fFPBlend=0.7500000
	m_EquipSnd=Sound'CommonSMG.Play_SMG_Equip'
	m_UnEquipSnd=Sound'CommonSMG.Play_SMG_Unequip'
	m_ReloadSnd=Sound'Sub_MP5KPD_Reloads.Play_MP5KPD_Reload'
	m_ReloadEmptySnd=Sound'Sub_MP5KPD_Reloads.Play_MP5KPD_ReloadEmpty'
	m_ChangeROFSnd=Sound'CommonSMG.Play_SMG_ROF'
	m_SingleFireStereoSnd=Sound'Sub_MP5KPD_Silenced.Play_Mp5KPDSil_SingleShots'
	m_BurstFireStereoSnd=Sound'Sub_MP5KPD_Silenced.Play_Mp5KPDSil_TripleShots'
	m_FullAutoStereoSnd=Sound'Sub_MP5KPD_Silenced.Play_Mp5KPDSil_AutoShots'
	m_FullAutoEndStereoSnd=Sound'Sub_MP5KPD_Silenced.Stop_Mp5KPDSil_AutoShots_Go'
	m_TriggerSnd=Sound'CommonSMG.Play_SMG_Trigger'
	m_szMagazineClass="R63rdWeapons.R63rdMAG9mm"
	m_szSilencerClass="R6WeaponGadgets.R63rdSilencerSubGuns"
}
