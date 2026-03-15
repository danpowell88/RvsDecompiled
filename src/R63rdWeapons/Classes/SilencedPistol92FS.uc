//=============================================================================
// SilencedPistol92FS - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//============================================================================//
//  SilencedPistol92FS.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class SilencedPistol92FS extends Pistol92FS;

defaultproperties
{
	m_iClipCapacity=15
	m_iNbOfClips=4
	m_iNbOfExtraClips=6
	m_fMuzzleVelocity=28500.0000000
	m_MuzzleScale=0.2960120
	m_fFireSoundRadius=285.0000000
	m_fRateOfFire=0.1000000
	m_pBulletClass=Class'R6Weapons.ammo9mmParabellumSubsonicFMJ'
	m_stAccuracyValues=(fBaseAccuracy=1.4344090,fShuffleAccuracy=1.9815040,fWalkingAccuracy=2.4768800,fWalkingFastAccuracy=10.2171300,fRunningAccuracy=10.2171300,fReticuleTime=1.0941870,fAccuracyChange=8.2549550,fWeaponJump=7.5062010)
	m_szReticuleClass="CIRCLE"
	m_bIsSilenced=true
	m_fFPBlend=0.6591930
	m_EquipSnd=Sound'CommonPistols.Play_Pistol_Equip'
	m_UnEquipSnd=Sound'CommonPistols.Play_Pistol_Unequip'
	m_ReloadSnd=Sound'Pistol_92FS_Reloads.Play_92FS_Reload'
	m_ReloadEmptySnd=Sound'Pistol_92FS_Reloads.Play_92FS_ReloadEmpty'
	m_SingleFireStereoSnd=Sound'Pistol_92FS_Silenced.Play_92FSSil_SingleShots'
	m_EmptyMagSnd=Sound'Pistol_92FS_Reloads.Play_92FS_Chamber'
	m_TriggerSnd=Sound'CommonPistols.Play_Pistol_Trigger'
	m_szSilencerClass="R6WeaponGadgets.R63rdSilencerPistol"
}
