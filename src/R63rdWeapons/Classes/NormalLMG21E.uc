//=============================================================================
// NormalLMG21E - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//============================================================================//
//  NormalLMG21E.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class NormalLMG21E extends LMG21E;

defaultproperties
{
	m_iClipCapacity=100
	m_iNbOfClips=3
	m_iNbOfExtraClips=2
	m_fMuzzleVelocity=50400.0000000
	m_MuzzleScale=0.9084900
	m_fFireSoundRadius=1680.0000000
	m_fRateOfFire=0.0750000
	m_pBulletClass=Class'R6Weapons.ammo762mmNATONormalFMJ'
	m_stAccuracyValues=(fBaseAccuracy=1.1472620,fShuffleAccuracy=2.4085590,fWalkingAccuracy=8.3095280,fWalkingFastAccuracy=21.8125100,fRunningAccuracy=21.8125100,fReticuleTime=2.5890620,fAccuracyChange=4.2173610,fWeaponJump=8.7162350)
	m_szReticuleClass="WRETICULE"
	m_fFireAnimRate=1.3333330
	m_fFPBlend=0.0264450
	m_EquipSnd=Sound'CommonLMGs.Play_LMG_Equip'
	m_UnEquipSnd=Sound'CommonLMGs.Play_LMG_Unequip'
	m_ReloadSnd=Sound'Mach_21E3_Reloads.Play_21E3_Reload'
	m_ReloadEmptySnd=Sound'Mach_21E3_Reloads.Play_21E3_ReloadEmpty'
	m_SingleFireStereoSnd=Sound'Mach_21E3.Play_21E3_SingleShots'
	m_FullAutoStereoSnd=Sound'Mach_21E3.Play_21E3_AutoShots'
	m_FullAutoEndStereoSnd=Sound'Mach_21E3.Stop_21E3_AutoShots_Go'
	m_TriggerSnd=Sound'CommonLMGs.Play_LMG_Trigger'
	m_szMagazineClass="R63rdWeapons.R63rdMAGBox762mm"
	m_szMuzzleClass="R6WeaponGadgets.R63rdMuzzleMachineGuns"
}
