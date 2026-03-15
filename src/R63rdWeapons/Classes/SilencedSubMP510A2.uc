//=============================================================================
// SilencedSubMP510A2 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//============================================================================//
//  SilencedSubMP510A2.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class SilencedSubMP510A2 extends SubMP510A2;

defaultproperties
{
	m_iClipCapacity=30
	m_iNbOfClips=6
	m_iNbOfExtraClips=3
	m_fMuzzleVelocity=28500.0000000
	m_MuzzleScale=0.3097180
	m_fFireSoundRadius=285.0000000
	m_fRateOfFire=0.0857140
	m_pBulletClass=Class'R6Weapons.ammo10mmAutoSubsonicFMJ'
	m_stAccuracyValues=(fBaseAccuracy=1.1685530,fShuffleAccuracy=1.8608800,fWalkingAccuracy=2.7913210,fWalkingFastAccuracy=11.5142000,fRunningAccuracy=11.5142000,fReticuleTime=0.7661875,fAccuracyChange=5.5445660,fWeaponJump=4.5314430)
	m_szReticuleClass="CIRCLEDOTLINE"
	m_bIsSilenced=true
	m_fFireAnimRate=1.1666670
	m_fFPBlend=0.7500000
	m_EquipSnd=Sound'CommonSMG.Play_SMG_Equip'
	m_UnEquipSnd=Sound'CommonSMG.Play_SMG_Unequip'
	m_ReloadSnd=Sound'Sub_MP5_10A2_Reloads.Play_MP5_10A2_Reload'
	m_ReloadEmptySnd=Sound'Sub_MP5_10A2_Reloads.Play_MP5_10A2_ReloadEmpty'
	m_ChangeROFSnd=Sound'CommonSMG.Play_SMG_ROF'
	m_SingleFireStereoSnd=Sound'Sub_MP5_10A2_Silenced.Play_MP5_10A2Sil_SingleShots'
	m_BurstFireStereoSnd=Sound'Sub_MP5_10A2_Silenced.Play_MP5_10A2Sil_TripleShots'
	m_FullAutoStereoSnd=Sound'Sub_MP5_10A2_Silenced.Play_MP5_10A2Sil_AutoShots'
	m_FullAutoEndStereoSnd=Sound'Sub_MP5_10A2_Silenced.Stop_MP5_10A2Sil_AutoShots_Go'
	m_TriggerSnd=Sound'CommonSMG.Play_SMG_Trigger'
	m_szMagazineClass="R63rdWeapons.R63rdMAG10mm"
	m_szSilencerClass="R6WeaponGadgets.R63rdSilencerSubGuns"
}
