//=============================================================================
// SilencedPistolMk23 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//============================================================================//
//  SilencedPistolMk23.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class SilencedPistolMk23 extends PistolMk23;

defaultproperties
{
	m_iClipCapacity=12
	m_iNbOfClips=4
	m_iNbOfExtraClips=6
	m_fMuzzleVelocity=27000.0000000
	m_MuzzleScale=0.3412730
	m_fFireSoundRadius=270.0000000
	m_fRateOfFire=0.1000000
	m_pBulletClass=Class'R6Weapons.ammo45calAutoSubsonicFMJ'
	m_stAccuracyValues=(fBaseAccuracy=1.4257680,fShuffleAccuracy=1.9961950,fWalkingAccuracy=2.4952440,fWalkingFastAccuracy=10.2928800,fRunningAccuracy=10.2928800,fReticuleTime=1.1718130,fAccuracyChange=8.3065040,fWeaponJump=8.5429690)
	m_szReticuleClass="CIRCLE"
	m_bIsSilenced=true
	m_fFPBlend=0.6121200
	m_EquipSnd=Sound'CommonPistols.Play_Pistol_Equip'
	m_UnEquipSnd=Sound'CommonPistols.Play_Pistol_Unequip'
	m_ReloadSnd=Sound'Pistol_MK23_Reloads.Play_MK23_Reload'
	m_ReloadEmptySnd=Sound'Pistol_MK23_Reloads.Play_MK23_ReloadEmpty'
	m_SingleFireStereoSnd=Sound'Pistol_MK23_Silenced.Play_MK23Sil_SingleShots'
	m_EmptyMagSnd=Sound'Pistol_MK23_Reloads.Play_MK23_Chamber'
	m_TriggerSnd=Sound'CommonPistols.Play_Pistol_Trigger'
	m_szSilencerClass="R6WeaponGadgets.R63rdSilencerPistol"
}
