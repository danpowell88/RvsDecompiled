//=============================================================================
// SilencedAssaultL85A1 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//============================================================================//
//  SilencedAssaultL85A1.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class SilencedAssaultL85A1 extends AssaultL85A1;

defaultproperties
{
	m_iClipCapacity=30
	m_iNbOfClips=6
	m_iNbOfExtraClips=3
	m_fMuzzleVelocity=30000.0000000
	m_MuzzleScale=0.2305310
	m_fFireSoundRadius=300.0000000
	m_fRateOfFire=0.0869570
	m_pBulletClass=Class'R6Weapons.ammo556mmNATOSubsonicFMJ'
	m_stAccuracyValues=(fBaseAccuracy=0.6117461,fShuffleAccuracy=2.5847300,fWalkingAccuracy=3.8770950,fWalkingFastAccuracy=15.9930200,fRunningAccuracy=15.9930200,fReticuleTime=1.1336870,fAccuracyChange=3.3897210,fWeaponJump=0.8793104)
	m_szReticuleClass="RIFLE"
	m_bIsSilenced=true
	m_fFireAnimRate=1.1500000
	m_fFPBlend=0.7500000
	m_EquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Equip'
	m_UnEquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Unequip'
	m_ReloadSnd=Sound'Assault_L85A1_Reloads.Play_L85A1_Reload'
	m_ReloadEmptySnd=Sound'Assault_L85A1_Reloads.Play_L85A1_ReloadEmpty'
	m_ChangeROFSnd=Sound'CommonAssaultRiffles.Play_Assault_ROF'
	m_SingleFireStereoSnd=Sound'Assault_L85A1_Silenced.Play_L85A1Sil_SingleShots'
	m_BurstFireStereoSnd=Sound'Assault_L85A1_Silenced.Play_L85A1Sil_TripleShots'
	m_FullAutoStereoSnd=Sound'Assault_L85A1_Silenced.Play_L85A1Sil_AutoShots'
	m_FullAutoEndStereoSnd=Sound'Assault_L85A1_Silenced.Stop_L85A1Sil_AutoShots_Go'
	m_TriggerSnd=Sound'CommonAssaultRiffles.Play_Assault_Trigger'
	m_szMagazineClass="R63rdWeapons.R63rdMAG556mm"
	m_szSilencerClass="R6WeaponGadgets.R63rdSilencerSubGuns"
}
