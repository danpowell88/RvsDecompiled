//=============================================================================
// SilencedSubM12S - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//============================================================================//
//  SilencedSubM12S.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class SilencedSubM12S extends SubM12S;

defaultproperties
{
	m_iClipCapacity=40
	m_iNbOfClips=5
	m_iNbOfExtraClips=3
	m_fMuzzleVelocity=28500.0000000
	m_MuzzleScale=0.2725960
	m_fFireSoundRadius=285.0000000
	m_fRateOfFire=0.1090910
	m_pBulletClass=Class'R6Weapons.ammo9mmParabellumSubsonicFMJ'
	m_stAccuracyValues=(fBaseAccuracy=1.3512790,fShuffleAccuracy=2.0133380,fWalkingAccuracy=3.0200060,fWalkingFastAccuracy=12.4575300,fRunningAccuracy=12.4575300,fReticuleTime=0.7888750,fAccuracyChange=6.0026920,fWeaponJump=2.7406080)
	m_szReticuleClass="CIRCLEDOTLINE"
	m_bIsSilenced=true
	m_fFireAnimRate=0.9166670
	m_fFPBlend=0.7500000
	m_EquipSnd=Sound'CommonSMG.Play_SMG_Equip'
	m_UnEquipSnd=Sound'CommonSMG.Play_SMG_Unequip'
	m_ReloadSnd=Sound'Sub_M12_Reloads.Play_M12_Reload'
	m_ReloadEmptySnd=Sound'Sub_M12_Reloads.Play_M12_ReloadEmpty'
	m_ChangeROFSnd=Sound'CommonSMG.Play_SMG_ROF'
	m_SingleFireStereoSnd=Sound'Sub_M12_Silenced.Play_M12Sil_SingleShots'
	m_FullAutoStereoSnd=Sound'Sub_M12_Silenced.Play_M12Sil_AutoShots'
	m_FullAutoEndStereoSnd=Sound'Sub_M12_Silenced.Stop_M12Sil_AutoShots_Go'
	m_TriggerSnd=Sound'CommonSMG.Play_SMG_Trigger'
	m_szMagazineClass="R63rdWeapons.R63rdMAG9mmStraight"
	m_szSilencerClass="R6WeaponGadgets.R63rdSilencerSubGuns"
}
