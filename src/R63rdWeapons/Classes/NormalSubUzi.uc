//=============================================================================
// NormalSubUzi - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//============================================================================//
//  NormalSubUzi.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class NormalSubUzi extends SubUzi;

defaultproperties
{
	m_iClipCapacity=32
	m_iNbOfClips=7
	m_iNbOfExtraClips=3
	m_fMuzzleVelocity=24000.0000000
	m_MuzzleScale=0.4867500
	m_fFireSoundRadius=1600.0000000
	m_pBulletClass=Class'R6Weapons.ammo9mmParabellumNormalFMJ'
	m_stAccuracyValues=(fBaseAccuracy=1.4851150,fShuffleAccuracy=1.9693500,fWalkingAccuracy=2.9540250,fWalkingFastAccuracy=12.1853500,fRunningAccuracy=12.1853500,fReticuleTime=0.7093750,fAccuracyChange=6.1345860,fWeaponJump=5.8873170)
	m_szReticuleClass="CIRCLEDOTLINE"
	m_fFPBlend=0.5328270
	m_EquipSnd=Sound'CommonSMG.Play_SMG_Equip'
	m_UnEquipSnd=Sound'CommonSMG.Play_SMG_Unequip'
	m_ReloadSnd=Sound'Mult_Uzi_Reloads.Play_UZI_Reload'
	m_ReloadEmptySnd=Sound'Mult_Uzi_Reloads.Play_UZI_ReloadEmpty'
	m_ChangeROFSnd=Sound'CommonSMG.Play_SMG_ROF'
	m_SingleFireStereoSnd=Sound'Mult_Uzi.Play_UZI_SingleShots'
	m_FullAutoStereoSnd=Sound'Mult_Uzi.Play_UZI_AutoShots'
	m_FullAutoEndStereoSnd=Sound'Mult_Uzi.Stop_UZI_AutoShots_Go'
	m_TriggerSnd=Sound'CommonSMG.Play_SMG_Trigger'
	m_szMagazineClass="R63rdWeapons.R63rdMAG9mmStraight"
}
