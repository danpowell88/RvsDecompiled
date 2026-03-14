//=============================================================================
// SilencedAssaultType97 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//============================================================================//
//  SilencedAssaultType97.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class SilencedAssaultType97 extends AssaultType97;

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
	m_stAccuracyValues=(fBaseAccuracy=1.1579110,fShuffleAccuracy=1.8747150,fWalkingAccuracy=2.8120730,fWalkingFastAccuracy=11.5998000,fRunningAccuracy=11.5998000,fReticuleTime=0.6728125,fAccuracyChange=5.5033810,fWeaponJump=1.2679560)
	m_szReticuleClass="RIFLE"
	m_bIsSilenced=true
	m_fFireAnimRate=1.0833330
	m_fFPBlend=0.7500000
	m_EquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Equip'
	m_UnEquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Unequip'
	m_ReloadSnd=Sound'Assault_Type97_Reloads.Play_Type97_Reload'
	m_ReloadEmptySnd=Sound'Assault_Type97_Reloads.Play_Type97_ReloadEmpty'
	m_ChangeROFSnd=Sound'CommonAssaultRiffles.Play_Assault_ROF'
	m_SingleFireStereoSnd=Sound'Assault_Type97_Silenced.Play_Type97Sil_SingleShots'
	m_FullAutoStereoSnd=Sound'Assault_Type97_Silenced.Play_Type97Sil_AutoShots'
	m_FullAutoEndStereoSnd=Sound'Assault_Type97_Silenced.Stop_Type97Sil_AutoShots_Go'
	m_TriggerSnd=Sound'CommonAssaultRiffles.Play_Assault_Trigger'
	m_szMagazineClass="R63rdWeapons.R63rdMAG556mm"
	m_szSilencerClass="R6WeaponGadgets.R63rdSilencerSnipers"
}
