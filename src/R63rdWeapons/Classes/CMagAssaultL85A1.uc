//=============================================================================
// CMagAssaultL85A1 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//============================================================================//
//  CMagAssaultL85A1.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class CMagAssaultL85A1 extends AssaultL85A1;

defaultproperties
{
	m_iClipCapacity=100
	m_iNbOfClips=2
	m_iNbOfExtraClips=1
	m_fMuzzleVelocity=56400.0000000
	m_MuzzleScale=0.5819660
	m_fFireSoundRadius=3760.0000000
	m_fRateOfFire=0.0869570
	m_pBulletClass=Class'R6Weapons.ammo556mmNATONormalFMJ'
	m_stAccuracyValues=(fBaseAccuracy=0.9211800,fShuffleAccuracy=2.1824660,fWalkingAccuracy=3.2736990,fWalkingFastAccuracy=13.5040100,fRunningAccuracy=13.5040100,fReticuleTime=1.1040630,fAccuracyChange=5.6026810,fWeaponJump=7.7695860)
	m_szReticuleClass="RIFLE"
	m_fFireAnimRate=1.1500000
	m_fFPBlend=0.3834650
	m_EquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Equip'
	m_UnEquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Unequip'
	m_ReloadSnd=Sound'Assault_L85A1_Reloads.Play_L85A1_Reload'
	m_ReloadEmptySnd=Sound'Assault_L85A1_Reloads.Play_L85A1_ReloadEmpty'
	m_ChangeROFSnd=Sound'CommonAssaultRiffles.Play_Assault_ROF'
	m_SingleFireStereoSnd=Sound'Assault_L85A1.Play_L85A1_SingleShots'
	m_BurstFireStereoSnd=Sound'Assault_L85A1.Play_L85A1_TripleShots'
	m_FullAutoStereoSnd=Sound'Assault_L85A1.Play_L85A1_AutoShots'
	m_FullAutoEndStereoSnd=Sound'Assault_L85A1.Stop_L85A1_AutoShots_Go'
	m_TriggerSnd=Sound'CommonAssaultRiffles.Play_Assault_Trigger'
	m_szMagazineClass="R63rdWeapons.R63rdCMAG556mm"
	m_szMuzzleClass="R6WeaponGadgets.R63rdMuzzleAssault556"
}
