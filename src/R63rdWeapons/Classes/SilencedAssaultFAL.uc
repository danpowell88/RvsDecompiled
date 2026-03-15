//=============================================================================
// SilencedAssaultFAL - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//============================================================================//
//  SilencedAssaultFAL.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class SilencedAssaultFAL extends AssaultFAL;

defaultproperties
{
	m_iClipCapacity=20
	m_iNbOfClips=6
	m_iNbOfExtraClips=3
	m_fMuzzleVelocity=28600.0000000
	m_MuzzleScale=0.3365730
	m_fFireSoundRadius=286.0000000
	m_fRateOfFire=0.0923080
	m_pBulletClass=Class'R6Weapons.ammo762mmNATOSubsonicFMJ'
	m_stAccuracyValues=(fBaseAccuracy=0.2707044,fShuffleAccuracy=3.0280840,fWalkingAccuracy=4.5421270,fWalkingFastAccuracy=18.7362700,fRunningAccuracy=18.7362700,fReticuleTime=1.4828130,fAccuracyChange=2.0698900,fWeaponJump=2.6546150)
	m_szReticuleClass="RIFLE"
	m_bIsSilenced=true
	m_fFireAnimRate=1.0833330
	m_fFPBlend=0.7500000
	m_EquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Equip'
	m_UnEquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Unequip'
	m_ReloadSnd=Sound'Assault_FAL_Reloads.Play_FAL_Reload'
	m_ReloadEmptySnd=Sound'Assault_FAL_Reloads.Play_FAL_ReloadEmpty'
	m_ChangeROFSnd=Sound'CommonAssaultRiffles.Play_Assault_ROF'
	m_SingleFireStereoSnd=Sound'Assault_FAL_Silenced.Play_FALSil_SingleShots'
	m_FullAutoStereoSnd=Sound'Assault_FAL_Silenced.Play_FALSil_AutoShots'
	m_FullAutoEndStereoSnd=Sound'Assault_FAL_Silenced.Stop_FALSil_AutoShots_Go'
	m_TriggerSnd=Sound'CommonAssaultRiffles.Play_Assault_Trigger'
	m_szMagazineClass="R63rdWeapons.R63rdMAG762mm2"
	m_szSilencerClass="R6WeaponGadgets.R63rdSilencerSubGuns2"
}
