//=============================================================================
// NormalSniperWA2000 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//============================================================================//
//  NormalSniperWA2000.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class NormalSniperWA2000 extends SniperWA2000;

defaultproperties
{
	m_iClipCapacity=6
	m_iNbOfClips=5
	m_iNbOfExtraClips=3
	m_fMuzzleVelocity=62160.0000000
	m_MuzzleScale=1.0000000
	m_fFireSoundRadius=4144.0000000
	m_fRateOfFire=0.8587500
	m_pBulletClass=Class'R6Weapons.ammo30calMagnumNormalFMJ'
	m_stAccuracyValues=(fBaseAccuracy=0.8098021,fShuffleAccuracy=2.3272570,fWalkingAccuracy=3.4908860,fWalkingFastAccuracy=14.3999000,fRunningAccuracy=14.3999000,fReticuleTime=3.2203130,fAccuracyChange=4.1561980,fWeaponJump=21.7196900)
	m_szReticuleClass="SNIPER"
	m_fFPBlend=0.3488640
	m_EquipSnd=Sound'CommonSniper.Play_Sniper_Equip'
	m_UnEquipSnd=Sound'CommonSniper.Play_Sniper_Unequip'
	m_ReloadSnd=Sound'Sniper_WA2000_Reloads.Play_WA2000_Reload'
	m_ReloadEmptySnd=Sound'Sniper_WA2000_Reloads.Play_WA2000_ReloadEmpty'
	m_SingleFireStereoSnd=Sound'Sniper_WA2000.Play_WA2000_SingleShots'
	m_TriggerSnd=Sound'CommonSniper.Play_Sniper_Trigger'
	m_szMagazineClass="R63rdWeapons.R63rdMAG762mm"
	m_szMuzzleClass="R6WeaponGadgets.R63rdMuzzleAssault762"
}
