//=============================================================================
// SilencedSniperVSSVintorez - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//============================================================================//
//  SilencedSniperVSSVintorez.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class SilencedSniperVSSVintorez extends SniperVSSVintorez;

defaultproperties
{
	m_eRateOfFire=2
	m_iClipCapacity=10
	m_iNbOfClips=3
	m_iNbOfExtraClips=2
	m_fMuzzleVelocity=29500.0000000
	m_MuzzleScale=0.3857540
	m_fFireSoundRadius=295.0000000
	m_fRateOfFire=0.0705880
	m_pBulletClass=Class'R6Weapons.ammo9x39mmSP6SubsonicFMJ'
	m_stAccuracyValues=(fBaseAccuracy=1.1410200,fShuffleAccuracy=1.8966740,fWalkingAccuracy=2.8450110,fWalkingFastAccuracy=11.7356700,fRunningAccuracy=11.7356700,fReticuleTime=2.1412500,fAccuracyChange=6.1428790,fWeaponJump=5.6093040)
	m_szReticuleClass="SNIPER"
	m_bIsSilenced=true
	m_fFPBlend=0.8318380
	m_EquipSnd=Sound'CommonSniper.Play_Sniper_Equip'
	m_UnEquipSnd=Sound'CommonSniper.Play_Sniper_Unequip'
	m_ReloadSnd=Sound'Sniper_Vintorez_Reloads.Play_Vintorez_Reload'
	m_ReloadEmptySnd=Sound'Sniper_Vintorez_Reloads.Play_Vintorez_ReloadEmpty'
	m_ChangeROFSnd=Sound'CommonWeapons.Play_ChangeROF'
	m_SingleFireStereoSnd=Sound'Sniper_Vintorez.Play_Vintorez_SingleShots'
	m_FullAutoStereoSnd=Sound'Sniper_Vintorez.Play_Vintorez_AutoShots'
	m_FullAutoEndStereoSnd=Sound'Sniper_Vintorez.Stop_Vintorez_AutoShots_Go'
	m_TriggerSnd=Sound'CommonSniper.Play_Sniper_Trigger'
	m_szMagazineClass="R63rdWeapons.R63rdMAGVintorez"
}
