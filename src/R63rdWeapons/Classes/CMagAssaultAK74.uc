//=============================================================================
// CMagAssaultAK74 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//============================================================================//
//  CMagAssaultAK74.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class CMagAssaultAK74 extends AssaultAK74;

defaultproperties
{
	m_iClipCapacity=100
	m_iNbOfClips=2
	m_iNbOfExtraClips=1
	m_fMuzzleVelocity=54000.0000000
	m_MuzzleScale=0.5397380
	m_fFireSoundRadius=3600.0000000
	m_fRateOfFire=0.0923080
	m_pBulletClass=Class'R6Weapons.ammo545mm7N6NormalFMJ'
	m_stAccuracyValues=(fBaseAccuracy=0.8888731,fShuffleAccuracy=2.2244650,fWalkingAccuracy=3.3366970,fWalkingFastAccuracy=13.7638800,fRunningAccuracy=13.7638800,fReticuleTime=1.0616870,fAccuracyChange=5.2145430,fWeaponJump=8.1000000)
	m_szReticuleClass="RIFLE"
	m_fFireAnimRate=1.0833330
	m_fFPBlend=0.3572460
	m_EquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Equip'
	m_UnEquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Unequip'
	m_ReloadSnd=Sound'Assault_AK74_Reloads.Play_AK74_Reload'
	m_ReloadEmptySnd=Sound'Assault_AK74_Reloads.Play_AK74_ReloadEmpty'
	m_ChangeROFSnd=Sound'CommonAssaultRiffles.Play_Assault_ROF'
	m_SingleFireStereoSnd=Sound'Assault_AK74.Play_AK74_SingleShots'
	m_FullAutoStereoSnd=Sound'Assault_AK74.Play_AK74_AutoShots'
	m_FullAutoEndStereoSnd=Sound'Assault_AK74.Stop_AK74_AutoShots_Go'
	m_TriggerSnd=Sound'CommonAssaultRiffles.Play_Assault_Trigger'
	m_szMagazineClass="R63rdWeapons.R63rdDrumMAGAK"
	m_szMuzzleClass="R6WeaponGadgets.R63rdMuzzleAK74"
}
