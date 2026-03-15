//=============================================================================
// CMagAssaultM16A2 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//============================================================================//
//  CMagAssaultM16A2.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class CMagAssaultM16A2 extends AssaultM16A2;

defaultproperties
{
	m_eRateOfFire=1
	m_iClipCapacity=100
	m_iNbOfClips=2
	m_iNbOfExtraClips=1
	m_fMuzzleVelocity=59700.0000000
	m_MuzzleScale=0.6430270
	m_fFireSoundRadius=3980.0000000
	m_fRateOfFire=0.0727270
	m_pBulletClass=Class'R6Weapons.ammo556mmNATONormalFMJ'
	m_stAccuracyValues=(fBaseAccuracy=0.6497443,fShuffleAccuracy=2.5353320,fWalkingAccuracy=3.8029990,fWalkingFastAccuracy=15.6873700,fRunningAccuracy=15.6873700,fReticuleTime=1.1068750,fAccuracyChange=5.3258870,fWeaponJump=9.7098610)
	m_szReticuleClass="RIFLE"
	m_fFireAnimRate=1.3750000
	m_fFPBlend=0.2295000
	m_EquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Equip'
	m_UnEquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Unequip'
	m_ReloadSnd=Sound'Assault_M16A2_Reloads.Play_M16A2_Reload'
	m_ReloadEmptySnd=Sound'Assault_M16A2_Reloads.Play_M16A2_ReloadEmpty'
	m_ChangeROFSnd=Sound'CommonAssaultRiffles.Play_Assault_ROF'
	m_SingleFireStereoSnd=Sound'Assault_M16A2.Play_M16A2_SingleShots'
	m_BurstFireStereoSnd=Sound'Assault_M16A2.Play_M16A2_TripleShots'
	m_FullAutoStereoSnd=Sound'Assault_M16A2.Play_M16A2_DoubleShots'
	m_TriggerSnd=Sound'CommonAssaultRiffles.Play_Assault_Trigger'
	m_szMagazineClass="R63rdWeapons.R63rdCMAG556mm"
	m_szMuzzleClass="R6WeaponGadgets.R63rdMuzzleAssault556"
}
