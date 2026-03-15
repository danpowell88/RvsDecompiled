//=============================================================================
// NormalPistolP228 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//============================================================================//
//  NormalPistolP228.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class NormalPistolP228 extends PistolP228;

defaultproperties
{
	m_iClipCapacity=13
	m_iNbOfClips=4
	m_iNbOfExtraClips=6
	m_fMuzzleVelocity=21960.0000000
	m_MuzzleScale=0.3123730
	m_fFireSoundRadius=1464.0000000
	m_fRateOfFire=0.1000000
	m_pBulletClass=Class'R6Weapons.ammo9mmParabellumNormalFMJ'
	m_stAccuracyValues=(fBaseAccuracy=1.6769250,fShuffleAccuracy=1.5692270,fWalkingAccuracy=1.9615340,fWalkingFastAccuracy=8.0913280,fRunningAccuracy=8.0913280,fReticuleTime=0.8725625,fAccuracyChange=9.4383430,fWeaponJump=14.2976000)
	m_szReticuleClass="CIRCLE"
	m_fFPBlend=0.3508400
	m_EquipSnd=Sound'CommonPistols.Play_Pistol_Equip'
	m_UnEquipSnd=Sound'CommonPistols.Play_Pistol_Unequip'
	m_ReloadSnd=Sound'Pistol_P228_Reloads.Play_P228_Reload'
	m_ReloadEmptySnd=Sound'Pistol_P228_Reloads.Play_P228_ReloadEmpty'
	m_SingleFireStereoSnd=Sound'Pistol_P228.Play_P228_SingleShots'
	m_EmptyMagSnd=Sound'Pistol_P228_Reloads.Play_P228_Chamber'
	m_TriggerSnd=Sound'CommonPistols.Play_Pistol_Trigger'
	m_szTacticalLightClass="R6WeaponGadgets.R63rdTACPistol"
}
