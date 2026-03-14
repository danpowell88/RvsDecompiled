//=============================================================================
// NormalSubMicroUzi - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//============================================================================//
//  NormalSubMicroUzi.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class NormalSubMicroUzi extends SubMicroUzi;

defaultproperties
{
	m_iClipCapacity=32
	m_iNbOfClips=7
	m_iNbOfExtraClips=3
	m_fMuzzleVelocity=21000.0000000
	m_MuzzleScale=0.4605590
	m_fFireSoundRadius=1400.0000000
	m_pBulletClass=Class'R6Weapons.ammo9mmParabellumNormalFMJ'
	m_stAccuracyValues=(fBaseAccuracy=1.7868340,fShuffleAccuracy=1.8371150,fWalkingAccuracy=2.7556730,fWalkingFastAccuracy=11.3671500,fRunningAccuracy=11.3671500,fReticuleTime=0.2295625,fAccuracyChange=7.8532700,fWeaponJump=9.0903380)
	m_szReticuleClass="CIRCLEDOTLINE"
	m_fFPBlend=0.2786600
	m_EquipSnd=Sound'CommonSMG.Play_SMG_Equip'
	m_UnEquipSnd=Sound'CommonSMG.Play_SMG_Unequip'
	m_ReloadSnd=Sound'Mult_UziPistol_Reloads.Play_UZIPistol_Reload'
	m_ReloadEmptySnd=Sound'Mult_UziPistol_Reloads.Play_UZIPistol_ReloadEmpty'
	m_ChangeROFSnd=Sound'CommonSMG.Play_SMG_ROF'
	m_SingleFireStereoSnd=Sound'Mult_UziPistol.Play_UziPistol_SingleShots'
	m_FullAutoStereoSnd=Sound'Mult_UziPistol.Play_UziPistol_AutoShots'
	m_FullAutoEndStereoSnd=Sound'Mult_UziPistol.Stop_UziPistol_AutoShots_Go'
	m_TriggerSnd=Sound'CommonSMG.Play_SMG_Trigger'
	m_szMagazineClass="R63rdWeapons.R63rdMAG9mmStraight"
	m_szTacticalLightClass="R6WeaponGadgets.R63rdTACPistol"
}
