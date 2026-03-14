//=============================================================================
// CMagAssaultAUG - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//============================================================================//
//  CMagAssaultAUG.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class CMagAssaultAUG extends AssaultAUG;

defaultproperties
{
	m_iClipCapacity=100
	m_iNbOfClips=2
	m_iNbOfExtraClips=1
	m_fMuzzleVelocity=55800.0000000
	m_MuzzleScale=0.5712360
	m_fFireSoundRadius=3720.0000000
	m_fRateOfFire=0.0923080
	m_pBulletClass=Class'R6Weapons.ammo556mmNATONormalFMJ'
	m_stAccuracyValues=(fBaseAccuracy=1.0163340,fShuffleAccuracy=2.0587660,fWalkingAccuracy=3.0881490,fWalkingFastAccuracy=12.7386100,fRunningAccuracy=12.7386100,fReticuleTime=1.0956250,fAccuracyChange=5.5025310,fWeaponJump=7.6846510)
	m_szReticuleClass="RIFLE"
	m_fFireAnimRate=1.0833330
	m_fFPBlend=0.3902050
	m_EquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Equip'
	m_UnEquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Unequip'
	m_ReloadSnd=Sound'Assault_AUG_Reloads.Play_Aug_Reload'
	m_ReloadEmptySnd=Sound'Assault_AUG_Reloads.Play_Aug_ReloadEmpty'
	m_ChangeROFSnd=Sound'CommonAssaultRiffles.Play_Assault_ROF'
	m_SingleFireStereoSnd=Sound'Assault_AUG.Play_Aug_SingleShots'
	m_FullAutoStereoSnd=Sound'Assault_AUG.Play_Aug_AutoShots'
	m_FullAutoEndStereoSnd=Sound'Assault_AUG.Stop_Aug_AutoShots_Go'
	m_TriggerSnd=Sound'CommonAssaultRiffles.Play_Assault_Trigger'
	m_szMagazineClass="R63rdWeapons.R63rdCMAG556mm"
	m_szMuzzleClass="R6WeaponGadgets.R63rdMuzzleAssault556"
}
