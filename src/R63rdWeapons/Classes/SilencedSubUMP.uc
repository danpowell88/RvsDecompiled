//=============================================================================
// SilencedSubUMP - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//============================================================================//
//  SilencedSubUMP.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class SilencedSubUMP extends SubUMP;

defaultproperties
{
	m_iClipCapacity=25
	m_iNbOfClips=6
	m_iNbOfExtraClips=3
	m_fMuzzleVelocity=28500.0000000
	m_MuzzleScale=0.3588340
	m_fFireSoundRadius=285.0000000
	m_fRateOfFire=0.1034480
	m_pBulletClass=Class'R6Weapons.ammo45calAutoSubsonicFMJ'
	m_stAccuracyValues=(fBaseAccuracy=1.1811430,fShuffleAccuracy=1.8445140,fWalkingAccuracy=2.7667710,fWalkingFastAccuracy=11.4129300,fRunningAccuracy=11.4129300,fReticuleTime=0.7150000,fAccuracyChange=5.5242690,fWeaponJump=5.3173190)
	m_szReticuleClass="CIRCLEDOTLINE"
	m_bIsSilenced=true
	m_fFireAnimRate=0.9666670
	m_fFPBlend=0.5780580
	m_EquipSnd=Sound'CommonSMG.Play_SMG_Equip'
	m_UnEquipSnd=Sound'CommonSMG.Play_SMG_Unequip'
	m_ReloadSnd=Sound'Sub_UMP45_Reloads.Play_UMP45_Reload'
	m_ReloadEmptySnd=Sound'Sub_UMP45_Reloads.Play_UMP45_ReloadEmpty'
	m_ChangeROFSnd=Sound'CommonSMG.Play_SMG_ROF'
	m_SingleFireStereoSnd=Sound'Sub_UMP45_Silenced.Play_UMP45Sil_SingleShots'
	m_BurstFireStereoSnd=Sound'Sub_UMP45_Silenced.Play_UMP45Sil_TripleShots'
	m_FullAutoStereoSnd=Sound'Sub_UMP45_Silenced.Play_UMP45Sil_AutoShots'
	m_FullAutoEndStereoSnd=Sound'Sub_UMP45_Silenced.Stop_UMP45Sil_AutoShots_Go'
	m_TriggerSnd=Sound'CommonSMG.Play_SMG_Trigger'
	m_szMagazineClass="R63rdWeapons.R63rdMAG10mm"
	m_szSilencerClass="R6WeaponGadgets.R63rdSilencerSubGuns"
}
