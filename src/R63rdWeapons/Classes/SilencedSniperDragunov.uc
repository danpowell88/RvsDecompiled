//=============================================================================
// SilencedSniperDragunov - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//============================================================================//
//  SilencedSniperDragunov.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class SilencedSniperDragunov extends SniperDragunov;

defaultproperties
{
	m_iClipCapacity=10
	m_iNbOfClips=3
	m_iNbOfExtraClips=2
	m_fMuzzleVelocity=30000.0000000
	m_MuzzleScale=0.3773440
	m_fFireSoundRadius=300.0000000
	m_fRateOfFire=0.8550000
	m_pBulletClass=Class'R6Weapons.ammo762x54mmRSubsonicFMJ'
	m_stAccuracyValues=(fBaseAccuracy=0.1364664,fShuffleAccuracy=3.2025940,fWalkingAccuracy=4.8038900,fWalkingFastAccuracy=19.8160500,fRunningAccuracy=19.8160500,fReticuleTime=3.2062500,fAccuracyChange=1.5503890,fWeaponJump=3.6851680)
	m_szReticuleClass="SNIPER"
	m_bIsSilenced=true
	m_fFPBlend=0.8895220
	m_EquipSnd=Sound'CommonSniper.Play_Sniper_Equip'
	m_UnEquipSnd=Sound'CommonSniper.Play_Sniper_Unequip'
	m_ReloadSnd=Sound'Sniper_Dragunov_Reloads.Play_Dragunov_Reload'
	m_ReloadEmptySnd=Sound'Sniper_Dragunov_Reloads.Play_Dragunov_ReloadEmpty'
	m_SingleFireStereoSnd=Sound'Sniper_Dragunov_Silenced.Play_DragunovSil_SingleShots'
	m_TriggerSnd=Sound'CommonSniper.Play_Sniper_Trigger'
	m_szMagazineClass="R63rdWeapons.R63rdMAGDragunov"
	m_szSilencerClass="R6WeaponGadgets.R63rdSilencerSnipers"
	StaticMesh=StaticMesh'R63rdWeapons_SM.SniperRifles.R63rdDragunovForSilencer'
}
