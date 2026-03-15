//=============================================================================
// NormalLMG23E - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//============================================================================//
//  NormalLMG23E.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class NormalLMG23E extends LMG23E;

defaultproperties
{
	m_iClipCapacity=200
	m_iNbOfClips=2
	m_iNbOfExtraClips=1
	m_fMuzzleVelocity=57000.0000000
	m_MuzzleScale=0.5928090
	m_fFireSoundRadius=1900.0000000
	m_fRateOfFire=0.0800000
	m_pBulletClass=Class'R6Weapons.ammo556mmNATONormalFMJ'
	m_stAccuracyValues=(fBaseAccuracy=1.3490790,fShuffleAccuracy=2.1461970,fWalkingAccuracy=7.4043800,fWalkingFastAccuracy=19.4365000,fRunningAccuracy=19.4365000,fReticuleTime=2.3890620,fAccuracyChange=3.3704070,fWeaponJump=5.8509540)
	m_szReticuleClass="WRETICULE"
	m_fFireAnimRate=1.2500000
	m_fFPBlend=0.3464810
	m_EquipSnd=Sound'CommonLMGs.Play_LMG_Equip'
	m_UnEquipSnd=Sound'CommonLMGs.Play_LMG_Unequip'
	m_ReloadSnd=Sound'Mach_23E_Reloads.Play_23E_Reload'
	m_ReloadEmptySnd=Sound'Mach_23E_Reloads.Play_23E_ReloadEmpty'
	m_SingleFireStereoSnd=Sound'Mach_23E.Play_23E_SingleShots'
	m_FullAutoStereoSnd=Sound'Mach_23E.Play_23E_AutoShots'
	m_FullAutoEndStereoSnd=Sound'Mach_23E.Stop_23E_AutoShots_Go'
	m_TriggerSnd=Sound'CommonLMGs.Play_LMG_Trigger'
	m_szMagazineClass="R63rdWeapons.R63rdMAGBox556mm"
	m_szMuzzleClass="R6WeaponGadgets.R63rdMuzzleMachineGuns"
}
