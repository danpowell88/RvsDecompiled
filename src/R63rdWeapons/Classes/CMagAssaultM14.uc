//=============================================================================
// CMagAssaultM14 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//============================================================================//
//  CMagAssaultM14.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class CMagAssaultM14 extends AssaultM14;

defaultproperties
{
	m_iClipCapacity=100
	m_iNbOfClips=2
	m_iNbOfExtraClips=1
	m_fMuzzleVelocity=51180.0000000
	m_MuzzleScale=0.9344880
	m_fFireSoundRadius=3412.0000000
	m_fRateOfFire=0.0827590
	m_pBulletClass=Class'R6Weapons.ammo762mmNATONormalFMJ'
	m_stAccuracyValues=(fBaseAccuracy=0.5994487,fShuffleAccuracy=2.6007170,fWalkingAccuracy=3.9010750,fWalkingFastAccuracy=16.0919300,fRunningAccuracy=16.0919300,fReticuleTime=1.9112500,fAccuracyChange=4.7987180,fWeaponJump=8.3954890)
	m_szReticuleClass="RIFLE"
	m_fFireAnimRate=1.2083330
	m_fFPBlend=0.3337980
	m_EquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Equip'
	m_UnEquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Unequip'
	m_ReloadSnd=Sound'Assault_M14_Reloads.Play_M14_Reload'
	m_ReloadEmptySnd=Sound'Assault_M14_Reloads.Play_M14_ReloadEmpty'
	m_ChangeROFSnd=Sound'CommonAssaultRiffles.Play_Assault_ROF'
	m_SingleFireStereoSnd=Sound'Assault_M14.Play_M14_SingleShots'
	m_FullAutoStereoSnd=Sound'Assault_M14.Play_M14_AutoShots'
	m_FullAutoEndStereoSnd=Sound'Assault_M14.Stop_M14_AutoShots_Go'
	m_TriggerSnd=Sound'CommonAssaultRiffles.Play_Assault_Trigger'
	m_szMagazineClass="R63rdWeapons.R63rdCMAG762mm"
	m_szMuzzleClass="R6WeaponGadgets.R63rdMuzzleAssault762"
}
