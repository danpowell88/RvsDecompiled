//=============================================================================
// NormalLMGM60E4 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//============================================================================//
//  NormalLMGM60E4.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class NormalLMGM60E4 extends LMGM60E4;

defaultproperties
{
	m_iClipCapacity=100
	m_iNbOfClips=3
	m_iNbOfExtraClips=2
	m_fMuzzleVelocity=51180.0000000
	m_MuzzleScale=0.9344880
	m_fFireSoundRadius=3412.0000000
	m_fRateOfFire=0.1043480
	m_pBulletClass=Class'R6Weapons.ammo762mmNATONormalFMJ'
	m_stAccuracyValues=(fBaseAccuracy=1.3057530,fShuffleAccuracy=2.2025210,fWalkingAccuracy=7.5986990,fWalkingFastAccuracy=19.9465800,fRunningAccuracy=19.9465800,fReticuleTime=2.5673440,fAccuracyChange=3.7601920,fWeaponJump=8.9530010)
	m_szReticuleClass="WRETICULE"
	m_fFireAnimRate=0.9583330
	m_EquipSnd=Sound'CommonLMGs.Play_LMG_Equip'
	m_UnEquipSnd=Sound'CommonLMGs.Play_LMG_Unequip'
	m_ReloadSnd=Sound'Mach_M60_Reloads.Play_M60_Reload'
	m_ReloadEmptySnd=Sound'Mach_M60_Reloads.Play_M60_ReloadEmpty'
	m_SingleFireStereoSnd=Sound'Mach_M60.Play_M60_SingleShots'
	m_FullAutoStereoSnd=Sound'Mach_M60.Play_M60_AutoShots'
	m_FullAutoEndStereoSnd=Sound'Mach_M60.Stop_M60_AutoShots_Go'
	m_TriggerSnd=Sound'CommonLMGs.Play_LMG_Trigger'
	m_szMagazineClass="R63rdWeapons.R63rdMAGBox762mm"
	m_szMuzzleClass="R6WeaponGadgets.R63rdMuzzleMachineGuns"
}
