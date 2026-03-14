//=============================================================================
// CMagPistolMk23 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//============================================================================//
//  CMagPistolMk23.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class CMagPistolMk23 extends PistolMk23;

defaultproperties
{
	m_iClipCapacity=24
	m_iNbOfClips=2
	m_iNbOfExtraClips=3
	m_fMuzzleVelocity=16200.0000000
	m_MuzzleScale=0.3183440
	m_fFireSoundRadius=270.0000000
	m_fRateOfFire=0.1000000
	m_pBulletClass=Class'R6Weapons.ammo45calAutoNormalFMJ'
	m_stAccuracyValues=(fBaseAccuracy=1.6028750,fShuffleAccuracy=1.6951130,fWalkingAccuracy=2.1188920,fWalkingFastAccuracy=8.7404280,fRunningAccuracy=8.7404280,fReticuleTime=1.0776880,fAccuracyChange=9.0138550,fWeaponJump=8.4288280)
	m_szReticuleClass="CIRCLE"
	m_fFPBlend=0.6173020
	m_EquipSnd=Sound'CommonPistols.Play_Pistol_Equip'
	m_UnEquipSnd=Sound'CommonPistols.Play_Pistol_Unequip'
	m_ReloadSnd=Sound'Pistol_MK23_Reloads.Play_MK23_Reload'
	m_ReloadEmptySnd=Sound'Pistol_MK23_Reloads.Play_MK23_ReloadEmpty'
	m_SingleFireStereoSnd=Sound'Pistol_MK23.Play_Mk23_SingleShots'
	m_EmptyMagSnd=Sound'Pistol_MK23_Reloads.Play_MK23_Chamber'
	m_TriggerSnd=Sound'CommonPistols.Play_Pistol_Trigger'
	m_szMagazineClass="R63rdWeapons.R63rdMAGPistolHigh"
}
