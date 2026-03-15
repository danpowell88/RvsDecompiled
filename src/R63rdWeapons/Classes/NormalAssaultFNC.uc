//=============================================================================
// NormalAssaultFNC - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//============================================================================//
//  NormalAssaultFNC.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class NormalAssaultFNC extends AssaultFNC;

defaultproperties
{
	m_iClipCapacity=30
	m_iNbOfClips=6
	m_iNbOfExtraClips=3
	m_fMuzzleVelocity=57900.0000000
	m_MuzzleScale=0.6092900
	m_fFireSoundRadius=3860.0000000
	m_fRateOfFire=0.0923080
	m_pBulletClass=Class'R6Weapons.ammo556mmNATONormalFMJ'
	m_stAccuracyValues=(fBaseAccuracy=0.6980861,fShuffleAccuracy=2.4724880,fWalkingAccuracy=3.7087320,fWalkingFastAccuracy=15.2985200,fRunningAccuracy=15.2985200,fReticuleTime=1.0836250,fAccuracyChange=5.1180380,fWeaponJump=9.4795360)
	m_szReticuleClass="RIFLE"
	m_fFireAnimRate=1.0833330
	m_fFPBlend=0.2477760
	m_EquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Equip'
	m_UnEquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Unequip'
	m_ReloadSnd=Sound'Assault_FNC_Reloads.Play_FNC_Reload'
	m_ReloadEmptySnd=Sound'Assault_FNC_Reloads.Play_FNC_ReloadEmpty'
	m_ChangeROFSnd=Sound'CommonAssaultRiffles.Play_Assault_ROF'
	m_SingleFireStereoSnd=Sound'Assault_FNC.Play_FNC_SingleShots'
	m_FullAutoStereoSnd=Sound'Assault_FNC.Play_FNC_AutoShots'
	m_FullAutoEndStereoSnd=Sound'Assault_FNC.Stop_FNC_AutoShots_Go'
	m_TriggerSnd=Sound'CommonAssaultRiffles.Play_Assault_Trigger'
	m_szMagazineClass="R63rdWeapons.R63rdMAG556mm"
	m_szMuzzleClass="R6WeaponGadgets.R63rdMuzzleAssault556"
}
