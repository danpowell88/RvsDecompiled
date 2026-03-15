//=============================================================================
// NormalLMGRPD - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//============================================================================//
//  NormalLMGRPD.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class NormalLMGRPD extends LMGRPD;

defaultproperties
{
	m_iClipCapacity=100
	m_iNbOfClips=4
	m_iNbOfExtraClips=2
	m_fMuzzleVelocity=42000.0000000
	m_MuzzleScale=0.7340190
	m_fFireSoundRadius=1400.0000000
	m_fRateOfFire=0.0857140
	m_pBulletClass=Class'R6Weapons.ammo762mmM43NormalFMJ'
	m_stAccuracyValues=(fBaseAccuracy=1.4604000,fShuffleAccuracy=2.0014790,fWalkingAccuracy=6.9051040,fWalkingFastAccuracy=18.1259000,fRunningAccuracy=18.1259000,fReticuleTime=2.1314060,fAccuracyChange=4.4496930,fWeaponJump=8.6715930)
	m_szReticuleClass="WRETICULE"
	m_fFireAnimRate=1.1666670
	m_fFPBlend=0.0314320
	m_EquipSnd=Sound'CommonLMGs.Play_LMG_Equip'
	m_UnEquipSnd=Sound'CommonLMGs.Play_LMG_Unequip'
	m_ReloadSnd=Sound'Mach_RPD_Reloads.Play_RPD_Reload'
	m_ReloadEmptySnd=Sound'Mach_RPD_Reloads.Play_RPD_ReloadEmpty'
	m_SingleFireStereoSnd=Sound'Mach_RPD.Play_RPD_SingleShots'
	m_FullAutoStereoSnd=Sound'Mach_RPD.Play_RPD_AutoShots'
	m_FullAutoEndStereoSnd=Sound'Mach_RPD.Stop_RPD_AutoShots_Go'
	m_TriggerSnd=Sound'CommonLMGs.Play_LMG_Trigger'
	m_szMagazineClass="R63rdWeapons.R63rdMAGRPD"
	m_szMuzzleClass="R6WeaponGadgets.R63rdMuzzleMachineGuns"
}
