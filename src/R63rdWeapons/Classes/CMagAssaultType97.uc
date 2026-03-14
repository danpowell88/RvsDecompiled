//=============================================================================
// CMagAssaultType97 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//============================================================================//
//  CMagAssaultType97.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class CMagAssaultType97 extends AssaultType97;

defaultproperties
{
	m_iClipCapacity=100
	m_iNbOfClips=2
	m_iNbOfExtraClips=1
	m_fMuzzleVelocity=54000.0000000
	m_MuzzleScale=0.5397380
	m_fFireSoundRadius=3600.0000000
	m_fRateOfFire=0.0923080
	m_pBulletClass=Class'R6Weapons.ammo556mmNATONormalFMJ'
	m_stAccuracyValues=(fBaseAccuracy=1.4673450,fShuffleAccuracy=1.4724510,fWalkingAccuracy=2.2086770,fWalkingFastAccuracy=9.1107900,fRunningAccuracy=9.1107900,fReticuleTime=0.6431875,fAccuracyChange=7.4857320,fWeaponJump=9.8357140)
	m_szReticuleClass="RIFLE"
	m_fFireAnimRate=1.0833330
	m_fFPBlend=0.2195130
	m_EquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Equip'
	m_UnEquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Unequip'
	m_ReloadSnd=Sound'Assault_Type97_Reloads.Play_Type97_Reload'
	m_ReloadEmptySnd=Sound'Assault_Type97_Reloads.Play_Type97_ReloadEmpty'
	m_ChangeROFSnd=Sound'CommonAssaultRiffles.Play_Assault_ROF'
	m_SingleFireStereoSnd=Sound'Assault_Type97.Play_Type97_SingleShots'
	m_FullAutoStereoSnd=Sound'Assault_Type97.Play_Type97_AutoShots'
	m_FullAutoEndStereoSnd=Sound'Assault_Type97.Stop_Type97_AutoShots_Go'
	m_TriggerSnd=Sound'CommonAssaultRiffles.Play_Assault_Trigger'
	m_szMagazineClass="R63rdWeapons.R63rdCMAG556mm"
	m_szMuzzleClass="R6WeaponGadgets.R63rdMuzzleType97"
}
