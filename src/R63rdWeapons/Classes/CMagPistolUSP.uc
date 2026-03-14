//=============================================================================
// CMagPistolUSP - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//============================================================================//
//  CMagPistolUSP.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class CMagPistolUSP extends PistolUSP;

defaultproperties
{
	m_iClipCapacity=26
	m_iNbOfClips=2
	m_iNbOfExtraClips=3
	m_fMuzzleVelocity=20400.0000000
	m_MuzzleScale=0.3229730
	m_fFireSoundRadius=1360.0000000
	m_fRateOfFire=0.1000000
	m_pBulletClass=Class'R6Weapons.ammo40calAutoNormalFMJ'
	m_stAccuracyValues=(fBaseAccuracy=1.6917470,fShuffleAccuracy=1.5440310,fWalkingAccuracy=1.9300380,fWalkingFastAccuracy=7.9614080,fRunningAccuracy=7.9614080,fReticuleTime=0.9166250,fAccuracyChange=9.4793150,fWeaponJump=13.4408300)
	m_szReticuleClass="CIRCLE"
	m_fFPBlend=0.3897400
	m_EquipSnd=Sound'CommonPistols.Play_Pistol_Equip'
	m_UnEquipSnd=Sound'CommonPistols.Play_Pistol_Unequip'
	m_ReloadSnd=Sound'Pistol_USP_Reloads.Play_USP_Reload'
	m_ReloadEmptySnd=Sound'Pistol_USP_Reloads.Play_USP_ReloadEmpty'
	m_SingleFireStereoSnd=Sound'Pistol_USP.Play_USP_SingleShots'
	m_EmptyMagSnd=Sound'Pistol_USP_Reloads.Play_USP_Chamber'
	m_TriggerSnd=Sound'CommonPistols.Play_Pistol_Trigger'
	m_szMagazineClass="R63rdWeapons.R63rdMAGPistolHigh"
}
