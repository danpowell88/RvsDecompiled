//=============================================================================
// SilencedSubP90 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//============================================================================//
//  SilencedSubP90.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class SilencedSubP90 extends SubP90;

defaultproperties
{
	m_iClipCapacity=50
	m_iNbOfClips=4
	m_iNbOfExtraClips=2
	m_fMuzzleVelocity=30000.0000000
	m_MuzzleScale=0.2406560
	m_fFireSoundRadius=300.0000000
	m_fRateOfFire=0.0666670
	m_pBulletClass=Class'R6Weapons.ammo57x28mmSubsonicFMJ'
	m_stAccuracyValues=(fBaseAccuracy=1.2797970,fShuffleAccuracy=2.2362640,fWalkingAccuracy=3.3543960,fWalkingFastAccuracy=13.8368800,fRunningAccuracy=13.8368800,fReticuleTime=0.8813750,fAccuracyChange=5.9750790,fWeaponJump=1.9852940)
	m_szReticuleClass="CIRCLEDOTLINE"
	m_bIsSilenced=true
	m_fFireAnimRate=1.5000000
	m_fFPBlend=0.7500000
	m_EquipSnd=Sound'CommonSMG.Play_SMG_Equip'
	m_UnEquipSnd=Sound'CommonSMG.Play_SMG_Unequip'
	m_ReloadSnd=Sound'Sub_P90_Reloads.Play_P90_Reload'
	m_ReloadEmptySnd=Sound'Sub_P90_Reloads.Play_P90_ReloadEmpty'
	m_ChangeROFSnd=Sound'CommonSMG.Play_SMG_ROF'
	m_SingleFireStereoSnd=Sound'Sub_P90_Silenced.Play_P90Sil_SingleShots'
	m_FullAutoStereoSnd=Sound'Sub_P90_Silenced.Play_P90Sil_AutoShots'
	m_FullAutoEndStereoSnd=Sound'Sub_P90_Silenced.Stop_P90Sil_AutoShots_Go'
	m_TriggerSnd=Sound'CommonSMG.Play_SMG_Trigger'
	m_szMagazineClass="R63rdWeapons.R63rdMAGP90"
	m_szSilencerClass="R6WeaponGadgets.R63rdSilencerSubGuns"
}
