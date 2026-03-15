//=============================================================================
// SilencedAssaultTAR21 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//============================================================================//
//  SilencedAssaultTAR21.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class SilencedAssaultTAR21 extends AssaultTAR21;

defaultproperties
{
	m_iClipCapacity=30
	m_iNbOfClips=6
	m_iNbOfExtraClips=3
	m_fMuzzleVelocity=30000.0000000
	m_MuzzleScale=0.2305310
	m_fFireSoundRadius=300.0000000
	m_fRateOfFire=0.0727270
	m_pBulletClass=Class'R6Weapons.ammo556mmNATOSubsonicFMJ'
	m_stAccuracyValues=(fBaseAccuracy=0.7459934,fShuffleAccuracy=2.4102090,fWalkingAccuracy=3.6153130,fWalkingFastAccuracy=14.9131700,fRunningAccuracy=14.9131700,fReticuleTime=1.2036880,fAccuracyChange=3.9092590,fWeaponJump=1.0303030)
	m_szReticuleClass="RIFLE"
	m_bIsSilenced=true
	m_fFireAnimRate=1.3750000
	m_fFPBlend=0.7500000
	m_EquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Equip'
	m_UnEquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Unequip'
	m_ReloadSnd=Sound'Assault_TAR21_Reloads.Play_TAR21_Reload'
	m_ReloadEmptySnd=Sound'Assault_TAR21_Reloads.Play_TAR21_ReloadEmpty'
	m_ChangeROFSnd=Sound'CommonAssaultRiffles.Play_Assault_ROF'
	m_SingleFireStereoSnd=Sound'Assault_TAR21_Silenced.Play_TAR21Sil_SingleShots'
	m_FullAutoStereoSnd=Sound'Assault_TAR21_Silenced.Play_TAR21Sil_AutoShots'
	m_FullAutoEndStereoSnd=Sound'Assault_TAR21_Silenced.Stop_TAR21Sil_AutoShots_Go'
	m_TriggerSnd=Sound'CommonAssaultRiffles.Play_Assault_Trigger'
	m_szMagazineClass="R63rdWeapons.R63rdMAG556mm"
	m_szSilencerClass="R6WeaponGadgets.R63rdSilencerSubGuns2"
}
