//=============================================================================
// CMagPistolDesertEagle50 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//============================================================================//
//  CMagPistolDesertEagle50.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class CMagPistolDesertEagle50 extends PistolDesertEagle50;

defaultproperties
{
	m_iClipCapacity=14
	m_iNbOfClips=2
	m_iNbOfExtraClips=3
	m_fMuzzleVelocity=23700.0000000
	m_MuzzleScale=0.4711650
	m_fFireSoundRadius=1580.0000000
	m_fRateOfFire=0.1000000
	m_pBulletClass=Class'R6Weapons.ammo50calPistolNormalFMJ'
	m_stAccuracyValues=(fBaseAccuracy=1.5816970,fShuffleAccuracy=1.7311160,fWalkingAccuracy=2.1638950,fWalkingFastAccuracy=8.9260650,fRunningAccuracy=8.9260650,fReticuleTime=1.4850000,fAccuracyChange=9.1754120,fWeaponJump=19.5866100)
	m_szReticuleClass="CIRCLE"
	m_fFPBlend=0.1107010
	m_EquipSnd=Sound'CommonPistols.Play_Pistol_Equip'
	m_UnEquipSnd=Sound'CommonPistols.Play_Pistol_Unequip'
	m_ReloadSnd=Sound'Pistol_Des50_Reloads.Play_Des50_Reload'
	m_ReloadEmptySnd=Sound'Pistol_Des50_Reloads.Play_Des50_ReloadEmpty'
	m_SingleFireStereoSnd=Sound'Pistol_Des50.Play_Des50_SingleShots'
	m_EmptyMagSnd=Sound'Pistol_Des50_Reloads.Play_Des50_Chamber'
	m_TriggerSnd=Sound'CommonPistols.Play_Pistol_Trigger'
	m_szMagazineClass="R63rdWeapons.R63rdMAGPistolHigh"
}
