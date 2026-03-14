//=============================================================================
// NormalPistolSPP - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//============================================================================//
//  NormalPistolSPP.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class NormalPistolSPP extends PistolSPP;

defaultproperties
{
	m_iClipCapacity=30
	m_iNbOfClips=2
	m_iNbOfExtraClips=3
	m_fMuzzleVelocity=21000.0000000
	m_MuzzleScale=0.3070390
	m_fFireSoundRadius=1400.0000000
	m_fRateOfFire=0.1000000
	m_pBulletClass=Class'R6Weapons.ammo9mmParabellumNormalFMJ'
	m_stAccuracyValues=(fBaseAccuracy=1.9499650,fShuffleAccuracy=2.6350590,fWalkingAccuracy=3.2938240,fWalkingFastAccuracy=13.5870200,fRunningAccuracy=13.5870200,fReticuleTime=1.0242500,fAccuracyChange=8.8615620,fWeaponJump=8.8318550)
	m_szReticuleClass="CIRCLE"
	m_fFPBlend=0.5990040
	m_EquipSnd=Sound'CommonSMG.Play_SMG_Equip'
	m_UnEquipSnd=Sound'CommonSMG.Play_SMG_Unequip'
	m_ReloadSnd=Sound'Pistol_SPP_Reloads.Play_SPP_Reload'
	m_ReloadEmptySnd=Sound'Pistol_SPP_Reloads.Play_SPP_ReloadEmpty'
	m_SingleFireStereoSnd=Sound'Sub_TMP.Play_TMP_SingleShots'
	m_TriggerSnd=Sound'CommonPistols.Play_Pistol_Trigger'
}
