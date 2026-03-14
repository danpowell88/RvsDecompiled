//=============================================================================
// SilencedAssaultAUG - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//============================================================================//
//  SilencedAssaultAUG.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class SilencedAssaultAUG extends AssaultAUG;

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
	m_stAccuracyValues=(fBaseAccuracy=0.6759567,fShuffleAccuracy=2.5012560,fWalkingAccuracy=3.7518840,fWalkingFastAccuracy=15.4765200,fRunningAccuracy=15.4765200,fReticuleTime=1.1252500,fAccuracyChange=3.4004030,fWeaponJump=0.8895349)
	m_szReticuleClass="RIFLE"
	m_bIsSilenced=true
	m_fFireAnimRate=1.0833330
	m_fFPBlend=0.7500000
	m_EquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Equip'
	m_UnEquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Unequip'
	m_ReloadSnd=Sound'Assault_AUG_Reloads.Play_Aug_Reload'
	m_ReloadEmptySnd=Sound'Assault_AUG_Reloads.Play_Aug_ReloadEmpty'
	m_ChangeROFSnd=Sound'CommonAssaultRiffles.Play_Assault_ROF'
	m_SingleFireStereoSnd=Sound'Assault_AUG_Silenced.Play_AugSil_SingleShots'
	m_FullAutoStereoSnd=Sound'Assault_AUG_Silenced.Play_AugSil_AutoShots'
	m_FullAutoEndStereoSnd=Sound'Assault_AUG_Silenced.Stop_AugSil_AutoShots_Go'
	m_TriggerSnd=Sound'CommonAssaultRiffles.Play_Assault_Trigger'
	m_szMagazineClass="R63rdWeapons.R63rdMAG556mm"
	m_szSilencerClass="R6WeaponGadgets.R63rdSilencerSnipers"
}
