//=============================================================================
// NormalAssaultType97 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//============================================================================//
//  NormalAssaultType97.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class NormalAssaultType97 extends AssaultType97;

defaultproperties
{
	m_iClipCapacity=30
	m_iNbOfClips=6
	m_iNbOfExtraClips=3
	m_fMuzzleVelocity=54000.0000000
	m_MuzzleScale=0.5397380
	m_fFireSoundRadius=3600.0000000
	m_fRateOfFire=0.0923080
	m_pBulletClass=Class'R6Weapons.ammo556mmNATONormalFMJ'
	m_stAccuracyValues=(fBaseAccuracy=1.4673450,fShuffleAccuracy=1.4724510,fWalkingAccuracy=2.2086770,fWalkingFastAccuracy=9.1107900,fRunningAccuracy=9.1107900,fReticuleTime=0.3806875,fAccuracyChange=7.7458590,fWeaponJump=14.7535700)
	m_szReticuleClass="RIFLE"
	m_fFireAnimRate=1.0833330
	m_EquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Equip'
	m_UnEquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Unequip'
	m_ReloadSnd=Sound'Assault_Type97_Reloads.Play_Type97_Reload'
	m_ReloadEmptySnd=Sound'Assault_Type97_Reloads.Play_Type97_ReloadEmpty'
	m_ChangeROFSnd=Sound'CommonAssaultRiffles.Play_Assault_ROF'
	m_SingleFireStereoSnd=Sound'Assault_Type97.Play_Type97_SingleShots'
	m_FullAutoStereoSnd=Sound'Assault_Type97.Play_Type97_AutoShots'
	m_FullAutoEndStereoSnd=Sound'Assault_Type97.Stop_Type97_AutoShots_Go'
	m_TriggerSnd=Sound'CommonAssaultRiffles.Play_Assault_Trigger'
	m_szMagazineClass="R63rdWeapons.R63rdMAG556mm"
	m_szMuzzleClass="R6WeaponGadgets.R63rdMuzzleType97"
}
