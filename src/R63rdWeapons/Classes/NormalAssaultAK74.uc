//=============================================================================
// NormalAssaultAK74 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//============================================================================//
//  NormalAssaultAK74.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class NormalAssaultAK74 extends AssaultAK74;

defaultproperties
{
	m_iClipCapacity=30
	m_iNbOfClips=6
	m_iNbOfExtraClips=3
	m_fMuzzleVelocity=54000.0000000
	m_MuzzleScale=0.5397380
	m_fFireSoundRadius=3600.0000000
	m_fRateOfFire=0.0923080
	m_pBulletClass=Class'R6Weapons.ammo545mm7N6NormalFMJ'
	m_stAccuracyValues=(fBaseAccuracy=0.8888731,fShuffleAccuracy=2.2244650,fWalkingAccuracy=3.3366970,fWalkingFastAccuracy=13.7638800,fRunningAccuracy=13.7638800,fReticuleTime=0.7991875,fAccuracyChange=5.6631260,fWeaponJump=11.1648600)
	m_szReticuleClass="RIFLE"
	m_fFireAnimRate=1.0833330
	m_fFPBlend=0.1140420
	m_EquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Equip'
	m_UnEquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Unequip'
	m_ReloadSnd=Sound'Assault_AK74_Reloads.Play_AK74_Reload'
	m_ReloadEmptySnd=Sound'Assault_AK74_Reloads.Play_AK74_ReloadEmpty'
	m_ChangeROFSnd=Sound'CommonAssaultRiffles.Play_Assault_ROF'
	m_SingleFireStereoSnd=Sound'Assault_AK74.Play_AK74_SingleShots'
	m_FullAutoStereoSnd=Sound'Assault_AK74.Play_AK74_AutoShots'
	m_FullAutoEndStereoSnd=Sound'Assault_AK74.Stop_AK74_AutoShots_Go'
	m_TriggerSnd=Sound'CommonAssaultRiffles.Play_Assault_Trigger'
	m_szMagazineClass="R63rdWeapons.R63rdMAGAK74"
	m_szMuzzleClass="R6WeaponGadgets.R63rdMuzzleAK74"
}
