//=============================================================================
// NormalSniperSSG3000 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//============================================================================//
//  NormalSniperSSG3000.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class NormalSniperSSG3000 extends SniperSSG3000;

defaultproperties
{
	m_iClipCapacity=5
	m_iNbOfClips=6
	m_iNbOfExtraClips=4
	m_fMuzzleVelocity=45000.0000000
	m_MuzzleScale=0.7394530
	m_fFireSoundRadius=3000.0000000
	m_fRateOfFire=0.8612500
	m_pBulletClass=Class'R6Weapons.ammo762mmNATONormalFMJ'
	m_stAccuracyValues=(fBaseAccuracy=0.4903019,fShuffleAccuracy=2.7426080,fWalkingAccuracy=4.1139110,fWalkingFastAccuracy=16.9698800,fRunningAccuracy=16.9698800,fReticuleTime=3.2296870,fAccuracyChange=2.9197330,fWeaponJump=9.2357310)
	m_szReticuleClass="SNIPER"
	m_fFPBlend=0.7231220
	m_EquipSnd=Sound'CommonSniper.Play_Sniper_Equip'
	m_UnEquipSnd=Sound'CommonSniper.Play_Sniper_Unequip'
	m_ReloadSnd=Sound'Sniper_SSG3000_Reloads.Play_SSG3000_Reload'
	m_ReloadEmptySnd=Sound'Sniper_SSG3000_Reloads.Play_SSG3000_ReloadEmpty'
	m_SingleFireStereoSnd=Sound'Sniper_SSG3000.Play_SSG3000_SingleShots'
	m_TriggerSnd=Sound'CommonSniper.Play_Sniper_Trigger'
	m_szMagazineClass="R63rdWeapons.R63rdMAG762mm"
	m_szMuzzleClass="R6WeaponGadgets.R63rdMuzzleAssault762"
}
