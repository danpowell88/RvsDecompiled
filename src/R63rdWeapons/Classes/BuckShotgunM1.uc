//=============================================================================
// BuckShotgunM1 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//============================================================================//
//  BuckShotgunM1.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class BuckShotgunM1 extends ShotgunM1;

defaultproperties
{
	m_iClipCapacity=6
	m_iNbOfClips=34
	m_iNbOfExtraClips=20
	m_fMuzzleVelocity=24780.0000000
	m_MuzzleScale=0.6464520
	m_fFireSoundRadius=1652.0000000
	m_fRateOfFire=0.3000000
	m_pBulletClass=Class'R6Weapons.ammo12gaugeBuck'
	m_stAccuracyValues=(fBaseAccuracy=3.3556020,fShuffleAccuracy=3.4954360,fWalkingAccuracy=4.3692950,fWalkingFastAccuracy=11.4694000,fRunningAccuracy=11.4694000,fReticuleTime=0.7885000,fAccuracyChange=7.5153530,fWeaponJump=20.0000000)
	m_szReticuleClass="CIRCLEDOT"
	m_EquipSnd=Sound'CommonShotguns.Play_Shotgun_Equip'
	m_UnEquipSnd=Sound'CommonShotguns.Play_Shotgun_Unequip'
	m_ReloadEmptySnd=Sound'Shotgun_M1_Reloads.Play_M1_ReloadEmpty'
	m_SingleFireStereoSnd=Sound'Shotgun_M1.Play_M1_SingleShots'
	m_TriggerSnd=Sound'CommonShotguns.Play_Shotgun_Trigger'
}
