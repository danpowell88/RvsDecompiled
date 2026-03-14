//=============================================================================
// BuckShotgunSPAS12 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//============================================================================//
//  BuckShotgunSPAS12.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class BuckShotgunSPAS12 extends ShotgunSPAS12;

defaultproperties
{
	m_iClipCapacity=8
	m_iNbOfClips=32
	m_iNbOfExtraClips=20
	m_fMuzzleVelocity=24780.0000000
	m_MuzzleScale=0.6464520
	m_fFireSoundRadius=1652.0000000
	m_fRateOfFire=0.6843330
	m_pBulletClass=Class'R6Weapons.ammo12gaugeBuck'
	m_stAccuracyValues=(fBaseAccuracy=3.2955980,fShuffleAccuracy=3.6514470,fWalkingAccuracy=4.5643080,fWalkingFastAccuracy=11.9813100,fRunningAccuracy=11.9813100,fReticuleTime=1.0397500,fAccuracyChange=7.3992450,fWeaponJump=17.1768600)
	m_szReticuleClass="CIRCLEDOT"
	m_fFPBlend=0.0679940
	m_EquipSnd=Sound'CommonShotguns.Play_Shotgun_Equip'
	m_UnEquipSnd=Sound'CommonShotguns.Play_Shotgun_Unequip'
	m_ReloadEmptySnd=Sound'Shotgun_SPAS12_Reloads.Play_SPAS12_ReloadEmpty'
	m_SingleFireStereoSnd=Sound'Shotgun_SPAS12.Play_SPAS12_SingleShots'
	m_TriggerSnd=Sound'CommonShotguns.Play_Shotgun_Trigger'
}
