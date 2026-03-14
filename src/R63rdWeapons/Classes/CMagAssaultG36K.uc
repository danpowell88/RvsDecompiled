//=============================================================================
// CMagAssaultG36K - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//============================================================================//
//  CMagAssaultG36K.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class CMagAssaultG36K extends AssaultG36K;

defaultproperties
{
	m_iClipCapacity=100
	m_iNbOfClips=2
	m_iNbOfExtraClips=1
	m_fMuzzleVelocity=55200.0000000
	m_MuzzleScale=0.5606220
	m_fFireSoundRadius=3680.0000000
	m_fRateOfFire=0.0800000
	m_pBulletClass=Class'R6Weapons.ammo556mmNATONormalFMJ'
	m_stAccuracyValues=(fBaseAccuracy=1.0060180,fShuffleAccuracy=2.0721770,fWalkingAccuracy=3.1082650,fWalkingFastAccuracy=12.8215900,fRunningAccuracy=12.8215900,fReticuleTime=0.9737500,fAccuracyChange=6.1409800,fWeaponJump=8.8455730)
	m_szReticuleClass="RIFLE"
	m_fFireAnimRate=1.2500000
	m_fFPBlend=0.2980830
	m_EquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Equip'
	m_UnEquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Unequip'
	m_ReloadSnd=Sound'Assault_G36K_Reloads.Play_G36K_Reload'
	m_ReloadEmptySnd=Sound'Assault_G36K_Reloads.Play_G36K_ReloadEmpty'
	m_ChangeROFSnd=Sound'CommonAssaultRiffles.Play_Assault_ROF'
	m_SingleFireStereoSnd=Sound'Assault_G36K.Play_G36K_SingleShots'
	m_BurstFireStereoSnd=Sound'Assault_G36K.Play_G36K_TripleShots'
	m_FullAutoStereoSnd=Sound'Assault_G36K.Play_G36K_AutoShots'
	m_FullAutoEndStereoSnd=Sound'Assault_G36K.Stop_G36K_AutoShots_Go'
	m_TriggerSnd=Sound'CommonAssaultRiffles.Play_Assault_Trigger'
	m_szMagazineClass="R63rdWeapons.R63rdCMAG556mm"
	m_szMuzzleClass="R6WeaponGadgets.R63rdMuzzleAssault556"
}
