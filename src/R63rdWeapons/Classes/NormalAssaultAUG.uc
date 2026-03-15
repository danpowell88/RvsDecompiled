//=============================================================================
// NormalAssaultAUG - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//============================================================================//
//  NormalAssaultAUG.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class NormalAssaultAUG extends AssaultAUG;

defaultproperties
{
	m_iClipCapacity=30
	m_iNbOfClips=6
	m_iNbOfExtraClips=3
	m_fMuzzleVelocity=55800.0000000
	m_MuzzleScale=0.5712360
	m_fFireSoundRadius=3720.0000000
	m_fRateOfFire=0.0923080
	m_pBulletClass=Class'R6Weapons.ammo556mmNATONormalFMJ'
	m_stAccuracyValues=(fBaseAccuracy=1.0163340,fShuffleAccuracy=2.0587660,fWalkingAccuracy=3.0881490,fWalkingFastAccuracy=12.7386100,fRunningAccuracy=12.7386100,fReticuleTime=0.8331250,fAccuracyChange=5.8916190,fWeaponJump=10.1635700)
	m_szReticuleClass="RIFLE"
	m_fFireAnimRate=1.0833330
	m_fFPBlend=0.1934970
	m_EquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Equip'
	m_UnEquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Unequip'
	m_ReloadSnd=Sound'Assault_AUG_Reloads.Play_Aug_Reload'
	m_ReloadEmptySnd=Sound'Assault_AUG_Reloads.Play_Aug_ReloadEmpty'
	m_ChangeROFSnd=Sound'CommonAssaultRiffles.Play_Assault_ROF'
	m_SingleFireStereoSnd=Sound'Assault_AUG.Play_Aug_SingleShots'
	m_FullAutoStereoSnd=Sound'Assault_AUG.Play_Aug_AutoShots'
	m_FullAutoEndStereoSnd=Sound'Assault_AUG.Stop_Aug_AutoShots_Go'
	m_TriggerSnd=Sound'CommonAssaultRiffles.Play_Assault_Trigger'
	m_szMagazineClass="R63rdWeapons.R63rdMAG556mm"
	m_szMuzzleClass="R6WeaponGadgets.R63rdMuzzleAssault556"
}
