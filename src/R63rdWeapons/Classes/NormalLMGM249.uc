//=============================================================================
// NormalLMGM249 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//============================================================================//
//  NormalLMGM249.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class NormalLMGM249 extends LMGM249;

defaultproperties
{
	m_iClipCapacity=200
	m_iNbOfClips=2
	m_iNbOfExtraClips=1
	m_fMuzzleVelocity=54900.0000000
	m_MuzzleScale=0.5553580
	m_fFireSoundRadius=1830.0000000
	m_fRateOfFire=0.0800000
	m_pBulletClass=Class'R6Weapons.ammo556mmNATONormalFMJ'
	m_stAccuracyValues=(fBaseAccuracy=1.1918010,fShuffleAccuracy=2.3506580,fWalkingAccuracy=8.1097720,fWalkingFastAccuracy=21.2881500,fRunningAccuracy=21.2881500,fReticuleTime=2.0968750,fAccuracyChange=3.3731410,fWeaponJump=6.4694660)
	m_szReticuleClass="WRETICULE"
	m_fFireAnimRate=1.2500000
	m_fFPBlend=0.2773970
	m_EquipSnd=Sound'CommonLMGs.Play_LMG_Equip'
	m_UnEquipSnd=Sound'CommonLMGs.Play_LMG_Unequip'
	m_ReloadSnd=Sound'Mach_M249_Reloads.Play_M249_Reload'
	m_ReloadEmptySnd=Sound'Mach_M249_Reloads.Play_M249_ReloadEmpty'
	m_SingleFireStereoSnd=Sound'Mach_M249.Play_M249_SingleShots'
	m_FullAutoStereoSnd=Sound'Mach_M249.Play_M249_AutoShots'
	m_FullAutoEndStereoSnd=Sound'Mach_M249.Stop_M249_AutoShots_Go'
	m_TriggerSnd=Sound'CommonLMGs.Play_LMG_Trigger'
	m_szMagazineClass="R63rdWeapons.R63rdMAGBox556mm"
	m_szMuzzleClass="R6WeaponGadgets.R63rdMuzzleMachineGuns"
}
