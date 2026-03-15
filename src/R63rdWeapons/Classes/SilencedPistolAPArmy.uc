//=============================================================================
// SilencedPistolAPArmy - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//============================================================================//
//  SilencedPistolAPArmy.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class SilencedPistolAPArmy extends PistolAPArmy;

defaultproperties
{
	m_iClipCapacity=20
	m_iNbOfClips=3
	m_iNbOfExtraClips=4
	m_fMuzzleVelocity=30000.0000000
	m_MuzzleScale=0.2406560
	m_fFireSoundRadius=300.0000000
	m_fRateOfFire=0.1000000
	m_pBulletClass=Class'R6Weapons.ammo57x28mmSubsonicFMJ'
	m_stAccuracyValues=(fBaseAccuracy=1.4125120,fShuffleAccuracy=2.0187290,fWalkingAccuracy=2.5234110,fWalkingFastAccuracy=10.4090700,fRunningAccuracy=10.4090700,fReticuleTime=1.0036250,fAccuracyChange=7.8368530,fWeaponJump=5.2209940)
	m_szReticuleClass="CIRCLE"
	m_bIsSilenced=true
	m_fFPBlend=0.7629490
	m_EquipSnd=Sound'CommonPistols.Play_Pistol_Equip'
	m_UnEquipSnd=Sound'CommonPistols.Play_Pistol_Unequip'
	m_ReloadSnd=Sound'Pistol_Belgian_Reloads.Play_Belgian_Reload'
	m_ReloadEmptySnd=Sound'Pistol_Belgian_Reloads.Play_Belgian_ReloadEmpty'
	m_SingleFireStereoSnd=Sound'Pistol_Belgian_Silenced.Play_BelgianSil_SingleShots'
	m_EmptyMagSnd=Sound'Pistol_Belgian_Reloads.Play_Belgian_Chamber'
	m_TriggerSnd=Sound'CommonPistols.Play_Pistol_Trigger'
	m_szSilencerClass="R6WeaponGadgets.R63rdSilencerPistol"
}
