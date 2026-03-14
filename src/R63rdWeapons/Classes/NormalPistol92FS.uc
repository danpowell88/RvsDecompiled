//=============================================================================
// NormalPistol92FS - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//============================================================================//
//  NormalPistol92FS.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class NormalPistol92FS extends Pistol92FS;

defaultproperties
{
	m_iClipCapacity=15
	m_iNbOfClips=4
	m_iNbOfExtraClips=6
	m_fMuzzleVelocity=23400.0000000
	m_MuzzleScale=0.3208220
	m_fFireSoundRadius=1560.0000000
	m_fRateOfFire=0.1000000
	m_pBulletClass=Class'R6Weapons.ammo9mmParabellumNormalFMJ'
	m_stAccuracyValues=(fBaseAccuracy=1.6276170,fShuffleAccuracy=1.6530510,fWalkingAccuracy=2.0663140,fWalkingFastAccuracy=8.5235440,fRunningAccuracy=8.5235440,fReticuleTime=0.9220625,fAccuracyChange=9.2643750,fWeaponJump=14.1643100)
	m_szReticuleClass="CIRCLE"
	m_fFPBlend=0.3568920
	m_EquipSnd=Sound'CommonPistols.Play_Pistol_Equip'
	m_UnEquipSnd=Sound'CommonPistols.Play_Pistol_Unequip'
	m_ReloadSnd=Sound'Pistol_92FS_Reloads.Play_92FS_Reload'
	m_ReloadEmptySnd=Sound'Pistol_92FS_Reloads.Play_92FS_ReloadEmpty'
	m_SingleFireStereoSnd=Sound'Pistol_92FS.Play_92FS_SingleShots'
	m_EmptyMagSnd=Sound'Pistol_92FS_Reloads.Play_92FS_Chamber'
	m_TriggerSnd=Sound'CommonPistols.Play_Pistol_Trigger'
	m_szTacticalLightClass="R6WeaponGadgets.R63rdTACPistol"
}
