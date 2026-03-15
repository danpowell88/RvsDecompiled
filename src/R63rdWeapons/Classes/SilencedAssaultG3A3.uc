//=============================================================================
// SilencedAssaultG3A3 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//============================================================================//
//  SilencedAssaultG3A3.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class SilencedAssaultG3A3 extends AssaultG3A3;

defaultproperties
{
	m_iClipCapacity=20
	m_iNbOfClips=6
	m_iNbOfExtraClips=3
	m_fMuzzleVelocity=28600.0000000
	m_MuzzleScale=0.3365730
	m_fFireSoundRadius=286.0000000
	m_fRateOfFire=0.1090910
	m_pBulletClass=Class'R6Weapons.ammo762mmNATOSubsonicFMJ'
	m_stAccuracyValues=(fBaseAccuracy=0.4549151,fShuffleAccuracy=2.7886100,fWalkingAccuracy=4.1829160,fWalkingFastAccuracy=17.2545300,fRunningAccuracy=17.2545300,fReticuleTime=1.4490620,fAccuracyChange=2.6227380,fWeaponJump=2.6413860)
	m_szReticuleClass="RIFLE"
	m_bIsSilenced=true
	m_fFireAnimRate=0.9166670
	m_fFPBlend=0.7500000
	m_EquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Equip'
	m_UnEquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Unequip'
	m_ReloadSnd=Sound'Assault_G3A3_Reloads.Play_G3A3_Reload'
	m_ReloadEmptySnd=Sound'Assault_G3A3_Reloads.Play_G3A3_ReloadEmpty'
	m_ChangeROFSnd=Sound'CommonAssaultRiffles.Play_Assault_ROF'
	m_SingleFireStereoSnd=Sound'Assault_G3A3_Silenced.Play_G3A3Sil_SingleShots'
	m_FullAutoStereoSnd=Sound'Assault_G3A3_Silenced.Play_G3A3Sil_AutoShot'
	m_FullAutoEndStereoSnd=Sound'Assault_G3A3_Silenced.Stop_G3A3Sil_AutoShot_Go'
	m_TriggerSnd=Sound'CommonAssaultRiffles.Play_Assault_Trigger'
	m_szMagazineClass="R63rdWeapons.R63rdMAG762mm2"
	m_szSilencerClass="R6WeaponGadgets.R63rdSilencerSubGuns2"
}
