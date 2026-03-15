//=============================================================================
// SilencedAssaultGalilARM - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//============================================================================//
//  SilencedAssaultGalilARM.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class SilencedAssaultGalilARM extends AssaultGalilARM;

defaultproperties
{
	m_iClipCapacity=30
	m_iNbOfClips=6
	m_iNbOfExtraClips=3
	m_fMuzzleVelocity=30000.0000000
	m_MuzzleScale=0.2305310
	m_fFireSoundRadius=300.0000000
	m_fRateOfFire=0.0923080
	m_pBulletClass=Class'R6Weapons.ammo556mmNATOSubsonicFMJ'
	m_stAccuracyValues=(fBaseAccuracy=0.4202072,fShuffleAccuracy=2.8337310,fWalkingAccuracy=4.2505960,fWalkingFastAccuracy=17.5337100,fRunningAccuracy=17.5337100,fReticuleTime=1.2896880,fAccuracyChange=2.6484660,fWeaponJump=0.8391225)
	m_szReticuleClass="RIFLE"
	m_bIsSilenced=true
	m_fFireAnimRate=1.0833330
	m_fFPBlend=0.7500000
	m_EquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Equip'
	m_UnEquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Unequip'
	m_ReloadSnd=Sound'Assault_Galil_Reloads.Play_Galil_Reload'
	m_ReloadEmptySnd=Sound'Assault_Galil_Reloads.Play_Galil_ReloadEmpty'
	m_ChangeROFSnd=Sound'CommonAssaultRiffles.Play_Assault_ROF'
	m_SingleFireStereoSnd=Sound'Assault_Galil_Silenced.Play_GalilSil_SingleShots'
	m_FullAutoStereoSnd=Sound'Assault_Galil_Silenced.Play_GalilSil_AutoShots'
	m_FullAutoEndStereoSnd=Sound'Assault_Galil_Silenced.Stop_GalilSil_AutoShots_Go'
	m_TriggerSnd=Sound'CommonAssaultRiffles.Play_Assault_Trigger'
	m_szMagazineClass="R63rdWeapons.R63rdMAG556mm"
	m_szSilencerClass="R6WeaponGadgets.R63rdSilencerSubGuns2"
}
