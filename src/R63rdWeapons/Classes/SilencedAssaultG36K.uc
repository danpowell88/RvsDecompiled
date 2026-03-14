//=============================================================================
// SilencedAssaultG36K - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//============================================================================//
//  SilencedAssaultG36K.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class SilencedAssaultG36K extends AssaultG36K;

defaultproperties
{
	m_iClipCapacity=30
	m_iNbOfClips=6
	m_iNbOfExtraClips=3
	m_fMuzzleVelocity=30000.0000000
	m_MuzzleScale=0.2305310
	m_fFireSoundRadius=300.0000000
	m_fRateOfFire=0.0800000
	m_pBulletClass=Class'R6Weapons.ammo556mmNATOSubsonicFMJ'
	m_stAccuracyValues=(fBaseAccuracy=0.6965839,fShuffleAccuracy=2.4744410,fWalkingAccuracy=3.7116620,fWalkingFastAccuracy=15.3106000,fRunningAccuracy=15.3106000,fReticuleTime=1.0033750,fAccuracyChange=3.7180440,fWeaponJump=1.0674420)
	m_szReticuleClass="RIFLE"
	m_bIsSilenced=true
	m_fFireAnimRate=1.2500000
	m_fFPBlend=0.7500000
	m_EquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Equip'
	m_UnEquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Unequip'
	m_ReloadSnd=Sound'Assault_G36K_Reloads.Play_G36K_Reload'
	m_ReloadEmptySnd=Sound'Assault_G36K_Reloads.Play_G36K_ReloadEmpty'
	m_ChangeROFSnd=Sound'CommonAssaultRiffles.Play_Assault_ROF'
	m_SingleFireStereoSnd=Sound'Assault_G36K_Silenced.Play_G36KSil_SingleShots'
	m_BurstFireStereoSnd=Sound'Assault_G36K_Silenced.Play_G36KSil_TripleShots'
	m_FullAutoStereoSnd=Sound'Assault_G36K_Silenced.Play_G36KSil_AutoShots'
	m_FullAutoEndStereoSnd=Sound'Assault_G36K_Silenced.Stop_G36KSil_AutoShots_Go'
	m_TriggerSnd=Sound'CommonAssaultRiffles.Play_Assault_Trigger'
	m_szMagazineClass="R63rdWeapons.R63rdMAG556mm"
	m_szSilencerClass="R6WeaponGadgets.R63rdSilencerSubGuns2"
}
