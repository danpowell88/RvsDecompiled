//=============================================================================
// CMagPistol92FS - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//============================================================================//
//  CMagPistol92FS.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class CMagPistol92FS extends Pistol92FS;

defaultproperties
{
	m_iClipCapacity=30
	m_iNbOfClips=2
	m_iNbOfExtraClips=3
	m_fMuzzleVelocity=23400.0000000
	m_MuzzleScale=0.3208220
	m_fFireSoundRadius=1560.0000000
	m_fRateOfFire=0.1000000
	m_pBulletClass=Class'R6Weapons.ammo9mmParabellumNormalFMJ'
	m_stAccuracyValues=(fBaseAccuracy=1.6276170,fShuffleAccuracy=1.6530510,fWalkingAccuracy=2.0663140,fWalkingFastAccuracy=8.5235440,fRunningAccuracy=8.5235440,fReticuleTime=0.9689375,fAccuracyChange=9.2182990,fWeaponJump=11.7221900)
	m_szReticuleClass="CIRCLE"
	m_fFPBlend=0.4677730
	m_EquipSnd=Sound'CommonPistols.Play_Pistol_Equip'
	m_UnEquipSnd=Sound'CommonPistols.Play_Pistol_Unequip'
	m_ReloadSnd=Sound'Pistol_92FS_Reloads.Play_92FS_Reload'
	m_ReloadEmptySnd=Sound'Pistol_92FS_Reloads.Play_92FS_ReloadEmpty'
	m_SingleFireStereoSnd=Sound'Pistol_92FS.Play_92FS_SingleShots'
	m_EmptyMagSnd=Sound'Pistol_92FS_Reloads.Play_92FS_Chamber'
	m_TriggerSnd=Sound'CommonPistols.Play_Pistol_Trigger'
	m_szMagazineClass="R63rdWeapons.R63rdMAGPistolHigh"
}
