//=============================================================================
// NormalAssaultGalilARM - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//============================================================================//
//  NormalAssaultGalilARM.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class NormalAssaultGalilARM extends AssaultGalilARM;

defaultproperties
{
	m_iClipCapacity=30
	m_iNbOfClips=6
	m_iNbOfExtraClips=3
	m_fMuzzleVelocity=57000.0000000
	m_MuzzleScale=0.5928090
	m_fFireSoundRadius=3800.0000000
	m_fRateOfFire=0.0923080
	m_pBulletClass=Class'R6Weapons.ammo556mmNATONormalFMJ'
	m_stAccuracyValues=(fBaseAccuracy=0.7296412,fShuffleAccuracy=2.4314660,fWalkingAccuracy=3.6472000,fWalkingFastAccuracy=15.0447000,fRunningAccuracy=15.0447000,fReticuleTime=0.9975625,fAccuracyChange=5.2759960,fWeaponJump=9.8983870)
	m_szReticuleClass="RIFLE"
	m_fFireAnimRate=1.0833330
	m_fFPBlend=0.2145400
	m_EquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Equip'
	m_UnEquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Unequip'
	m_ReloadSnd=Sound'Assault_Galil_Reloads.Play_Galil_Reload'
	m_ReloadEmptySnd=Sound'Assault_Galil_Reloads.Play_Galil_ReloadEmpty'
	m_ChangeROFSnd=Sound'CommonAssaultRiffles.Play_Assault_ROF'
	m_SingleFireStereoSnd=Sound'Assault_Galil.Play_Galil_SingleShots'
	m_FullAutoStereoSnd=Sound'Assault_Galil.Play_Galil_AutoShots'
	m_FullAutoEndStereoSnd=Sound'Assault_Galil.Stop_Galil_AutoShots_Go'
	m_TriggerSnd=Sound'CommonAssaultRiffles.Play_Assault_Trigger'
	m_szMagazineClass="R63rdWeapons.R63rdMAG556mm"
	m_szMuzzleClass="R6WeaponGadgets.R63rdMuzzleAssault556"
}
