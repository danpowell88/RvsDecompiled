//=============================================================================
// NormalSniperM82A1 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//============================================================================//
//  NormalSniperM82A1.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class NormalSniperM82A1 extends SniperM82A1;

defaultproperties
{
	m_iClipCapacity=10
	m_iNbOfClips=3
	m_iNbOfExtraClips=2
	m_fMuzzleVelocity=51180.0000000
	m_MuzzleScale=1.0000000
	m_fFireSoundRadius=4000.0000000
	m_fRateOfFire=1.5814170
	m_pBulletClass=Class'R6Weapons.ammo50calM33NormalFMJ'
	m_stAccuracyValues=(fBaseAccuracy=0.2639925,fShuffleAccuracy=3.0368100,fWalkingAccuracy=4.5552150,fWalkingFastAccuracy=18.7902600,fRunningAccuracy=18.7902600,fReticuleTime=5.9303130,fAccuracyChange=2.0439150,fWeaponJump=33.3566300)
	m_szReticuleClass="SNIPER"
	m_EquipSnd=Sound'CommonSniper.Play_Sniper_Equip'
	m_UnEquipSnd=Sound'CommonSniper.Play_Sniper_Unequip'
	m_ReloadSnd=Sound'Sniper_M82A1_Reloads.Play_M82A1_Reload'
	m_ReloadEmptySnd=Sound'Sniper_M82A1_Reloads.Play_M82A1_ReloadEmpty'
	m_SingleFireStereoSnd=Sound'Sniper_M82A1.Play_M82A1_SingleShots'
	m_TriggerSnd=Sound'CommonSniper.Play_Sniper_Trigger'
	m_szMagazineClass="R63rdWeapons.R63rdMAGM82A1"
	m_szMuzzleClass="R6WeaponGadgets.R63rdMuzzleM82A1"
}
