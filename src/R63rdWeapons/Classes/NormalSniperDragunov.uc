//=============================================================================
// NormalSniperDragunov - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//============================================================================//
//  NormalSniperDragunov.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class NormalSniperDragunov extends SniperDragunov;

defaultproperties
{
	m_iClipCapacity=10
	m_iNbOfClips=3
	m_iNbOfExtraClips=2
	m_fMuzzleVelocity=48600.0000000
	m_MuzzleScale=1.0000000
	m_fFireSoundRadius=3240.0000000
	m_fRateOfFire=0.7300000
	m_pBulletClass=Class'R6Weapons.ammo762x54mmRNormalFMJ'
	m_stAccuracyValues=(fBaseAccuracy=0.4320639,fShuffleAccuracy=2.8183170,fWalkingAccuracy=4.2274750,fWalkingFastAccuracy=17.4383400,fRunningAccuracy=17.4383400,fReticuleTime=2.7375000,fAccuracyChange=2.6943510,fWeaponJump=25.0853600)
	m_szReticuleClass="SNIPER"
	m_fFPBlend=0.2479650
	m_EquipSnd=Sound'CommonSniper.Play_Sniper_Equip'
	m_UnEquipSnd=Sound'CommonSniper.Play_Sniper_Unequip'
	m_ReloadSnd=Sound'Sniper_Dragunov_Reloads.Play_Dragunov_Reload'
	m_ReloadEmptySnd=Sound'Sniper_Dragunov_Reloads.Play_Dragunov_ReloadEmpty'
	m_SingleFireStereoSnd=Sound'Sniper_Dragunov.Play_Dragunov_SingleShots'
	m_TriggerSnd=Sound'CommonSniper.Play_Sniper_Trigger'
	m_szMagazineClass="R63rdWeapons.R63rdMAGDragunov"
	m_szMuzzleClass="R6WeaponGadgets.R63rdMuzzleAssault762"
}
