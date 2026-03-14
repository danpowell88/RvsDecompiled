//=============================================================================
// CMagPistolDesertEagle357 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//============================================================================//
//  CMagPistolDesertEagle357.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class CMagPistolDesertEagle357 extends PistolDesertEagle357;

defaultproperties
{
	m_iClipCapacity=18
	m_iNbOfClips=2
	m_iNbOfExtraClips=3
	m_fMuzzleVelocity=26160.0000000
	m_MuzzleScale=0.3652460
	m_fFireSoundRadius=1744.0000000
	m_fRateOfFire=0.1000000
	m_pBulletClass=Class'R6Weapons.ammo357calMagnumNormalFMJ'
	m_stAccuracyValues=(fBaseAccuracy=1.5625130,fShuffleAccuracy=1.7637280,fWalkingAccuracy=2.2046600,fWalkingFastAccuracy=9.0942220,fRunningAccuracy=9.0942220,fReticuleTime=1.1600000,fAccuracyChange=8.9868370,fWeaponJump=11.9735800)
	m_szReticuleClass="CIRCLE"
	m_fFPBlend=0.4563590
	m_EquipSnd=Sound'CommonPistols.Play_Pistol_Equip'
	m_UnEquipSnd=Sound'CommonPistols.Play_Pistol_Unequip'
	m_ReloadSnd=Sound'Pistol_Des357_Reloads.Play_Des357_Reload'
	m_ReloadEmptySnd=Sound'Pistol_Des357_Reloads.Play_Des357_ReloadEmpty'
	m_SingleFireStereoSnd=Sound'Pistol_Des357.Play_Des357_SingleShots'
	m_EmptyMagSnd=Sound'Pistol_Des357_Reloads.Play_Des357_Chamber'
	m_TriggerSnd=Sound'CommonPistols.Play_Pistol_Trigger'
	m_szMagazineClass="R63rdWeapons.R63rdMAGPistolHigh"
}
