//=============================================================================
// NormalAssaultM4 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//============================================================================//
//  NormalAssaultM4.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class NormalAssaultM4 extends AssaultM4;

defaultproperties
{
	m_iClipCapacity=30
	m_iNbOfClips=6
	m_iNbOfExtraClips=3
	m_fMuzzleVelocity=55260.0000000
	m_MuzzleScale=0.5616780
	m_fFireSoundRadius=3684.0000000
	m_fRateOfFire=0.0727270
	m_pBulletClass=Class'R6Weapons.ammo556mmNATONormalFMJ'
	m_stAccuracyValues=(fBaseAccuracy=1.2595810,fShuffleAccuracy=1.7425450,fWalkingAccuracy=2.6138170,fWalkingFastAccuracy=10.7819900,fRunningAccuracy=10.7819900,fReticuleTime=0.4900000,fAccuracyChange=7.3317690,fWeaponJump=11.4243700)
	m_szReticuleClass="RIFLE"
	m_fFireAnimRate=1.3750000
	m_EquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Equip'
	m_UnEquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Unequip'
	m_ReloadSnd=Sound'Assault_M4Carb_Reloads.Play_M4Carb_Reload'
	m_ReloadEmptySnd=Sound'Assault_M4Carb_Reloads.Play_M4Carb_ReloadEmpty'
	m_ChangeROFSnd=Sound'CommonAssaultRiffles.Play_Assault_ROF'
	m_SingleFireStereoSnd=Sound'Assault_M4Carb.Play_M4Carb_SingleShots'
	m_FullAutoStereoSnd=Sound'Assault_M4Carb.Play_M4Carb_AutoShots'
	m_FullAutoEndStereoSnd=Sound'Assault_M4Carb.Stop_M4Carb_AutoShots_Go'
	m_TriggerSnd=Sound'CommonAssaultRiffles.Play_Assault_Trigger'
	m_szMagazineClass="R63rdWeapons.R63rdMAG556mm"
	m_szMuzzleClass="R6WeaponGadgets.R63rdMuzzleAssault556"
}
