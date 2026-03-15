//=============================================================================
// NormalAssaultTAR21 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//============================================================================//
//  NormalAssaultTAR21.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class NormalAssaultTAR21 extends AssaultTAR21;

defaultproperties
{
	m_iClipCapacity=30
	m_iNbOfClips=6
	m_iNbOfExtraClips=3
	m_fMuzzleVelocity=53400.0000000
	m_MuzzleScale=0.5294670
	m_fFireSoundRadius=3560.0000000
	m_fRateOfFire=0.0727270
	m_pBulletClass=Class'R6Weapons.ammo556mmNATONormalFMJ'
	m_stAccuracyValues=(fBaseAccuracy=1.0554270,fShuffleAccuracy=2.0079440,fWalkingAccuracy=3.0119170,fWalkingFastAccuracy=12.4241600,fRunningAccuracy=12.4241600,fReticuleTime=0.9115625,fAccuracyChange=6.5900150,fWeaponJump=11.1133700)
	m_szReticuleClass="RIFLE"
	m_fFireAnimRate=1.3750000
	m_fFPBlend=0.1181280
	m_EquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Equip'
	m_UnEquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Unequip'
	m_ReloadSnd=Sound'Assault_TAR21_Reloads.Play_TAR21_Reload'
	m_ReloadEmptySnd=Sound'Assault_TAR21_Reloads.Play_TAR21_ReloadEmpty'
	m_ChangeROFSnd=Sound'CommonAssaultRiffles.Play_Assault_ROF'
	m_SingleFireStereoSnd=Sound'Assault_TAR21.Play_TAR21_SingleShots'
	m_FullAutoStereoSnd=Sound'Assault_TAR21.Play_TAR21_AutoShots'
	m_FullAutoEndStereoSnd=Sound'Assault_TAR21.Stop_TAR21_AutoShots_Go'
	m_TriggerSnd=Sound'CommonAssaultRiffles.Play_Assault_Trigger'
	m_szMagazineClass="R63rdWeapons.R63rdMAG556mm"
	m_szMuzzleClass="R6WeaponGadgets.R63rdMuzzleAssault556"
}
