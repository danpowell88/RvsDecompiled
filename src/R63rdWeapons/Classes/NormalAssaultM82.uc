//=============================================================================
// NormalAssaultM82 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//============================================================================//
//  NormalAssaultM82.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class NormalAssaultM82 extends AssaultM82;

defaultproperties
{
	m_iClipCapacity=30
	m_iNbOfClips=6
	m_iNbOfExtraClips=3
	m_fMuzzleVelocity=55800.0000000
	m_MuzzleScale=0.5712360
	m_fFireSoundRadius=3720.0000000
	m_fRateOfFire=0.0800000
	m_pBulletClass=Class'R6Weapons.ammo556mmNATONormalFMJ'
	m_stAccuracyValues=(fBaseAccuracy=1.1042030,fShuffleAccuracy=1.9445350,fWalkingAccuracy=2.9168030,fWalkingFastAccuracy=12.0318100,fRunningAccuracy=12.0318100,fReticuleTime=0.7056250,fAccuracyChange=6.6624960,fWeaponJump=11.3102300)
	m_szReticuleClass="RIFLE"
	m_fFireAnimRate=1.2500000
	m_fFPBlend=0.1025060
	m_EquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Equip'
	m_UnEquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Unequip'
	m_ReloadSnd=Sound'Assault_M82_Reloads.Play_M82_Reload'
	m_ReloadEmptySnd=Sound'Assault_M82_Reloads.Play_M82_ReloadEmpty'
	m_ChangeROFSnd=Sound'CommonAssaultRiffles.Play_Assault_ROF'
	m_SingleFireStereoSnd=Sound'Assault_M82.Play_M82_SingleShots'
	m_FullAutoStereoSnd=Sound'Assault_M82.Play_M82_AutoShots'
	m_FullAutoEndStereoSnd=Sound'Assault_M82.Stop_M82_AutoShots_Go'
	m_TriggerSnd=Sound'CommonAssaultRiffles.Play_Assault_Trigger'
	m_szMagazineClass="R63rdWeapons.R63rdMAG556mm"
	m_szMuzzleClass="R6WeaponGadgets.R63rdMuzzleAssault556"
}
