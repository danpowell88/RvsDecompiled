//=============================================================================
// CMagSubM12S - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//============================================================================//
//  CMagSubM12S.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class CMagSubM12S extends SubM12S;

defaultproperties
{
	m_iClipCapacity=100
	m_iNbOfClips=2
	m_iNbOfExtraClips=1
	m_fMuzzleVelocity=25800.0000000
	m_MuzzleScale=0.5041410
	m_fFireSoundRadius=1720.0000000
	m_fRateOfFire=0.1090910
	m_pBulletClass=Class'R6Weapons.ammo9mmParabellumNormalFMJ'
	m_stAccuracyValues=(fBaseAccuracy=1.5071280,fShuffleAccuracy=1.8107340,fWalkingAccuracy=2.7161010,fWalkingFastAccuracy=11.2039100,fRunningAccuracy=11.2039100,fReticuleTime=0.8468125,fAccuracyChange=6.5771070,fWeaponJump=5.3775180)
	m_szReticuleClass="CIRCLEDOTLINE"
	m_fFireAnimRate=0.9166670
	m_fFPBlend=0.7500000
	m_EquipSnd=Sound'CommonSMG.Play_SMG_Equip'
	m_UnEquipSnd=Sound'CommonSMG.Play_SMG_Unequip'
	m_ReloadSnd=Sound'Sub_M12_Reloads.Play_M12_Reload'
	m_ReloadEmptySnd=Sound'Sub_M12_Reloads.Play_M12_ReloadEmpty'
	m_ChangeROFSnd=Sound'CommonSMG.Play_SMG_ROF'
	m_SingleFireStereoSnd=Sound'Sub_M12.Play_M12_SingleShots'
	m_FullAutoStereoSnd=Sound'Sub_M12.Play_M12_AutoShots'
	m_FullAutoEndStereoSnd=Sound'Sub_M12.Stop_M12_AutoShots_Go'
	m_TriggerSnd=Sound'CommonSMG.Play_SMG_Trigger'
	m_szMagazineClass="R63rdWeapons.R63rdCMAG9mmUMP"
}
