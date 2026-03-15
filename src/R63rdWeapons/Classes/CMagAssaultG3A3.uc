//=============================================================================
// CMagAssaultG3A3 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//============================================================================//
//  CMagAssaultG3A3.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class CMagAssaultG3A3 extends AssaultG3A3;

defaultproperties
{
	m_iClipCapacity=100
	m_iNbOfClips=2
	m_iNbOfExtraClips=1
	m_fMuzzleVelocity=47400.0000000
	m_MuzzleScale=0.8122180
	m_fFireSoundRadius=3160.0000000
	m_fRateOfFire=0.1090910
	m_pBulletClass=Class'R6Weapons.ammo762mmNATONormalFMJ'
	m_stAccuracyValues=(fBaseAccuracy=0.8700094,fShuffleAccuracy=2.2489880,fWalkingAccuracy=3.3734820,fWalkingFastAccuracy=13.9156100,fRunningAccuracy=13.9156100,fReticuleTime=1.7265630,fAccuracyChange=4.7846910,fWeaponJump=7.8012500)
	m_szReticuleClass="RIFLE"
	m_fFireAnimRate=0.9166670
	m_fFPBlend=0.3809520
	m_EquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Equip'
	m_UnEquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Unequip'
	m_ReloadSnd=Sound'Assault_G3A3_Reloads.Play_G3A3_Reload'
	m_ReloadEmptySnd=Sound'Assault_G3A3_Reloads.Play_G3A3_ReloadEmpty'
	m_ChangeROFSnd=Sound'CommonAssaultRiffles.Play_Assault_ROF'
	m_SingleFireStereoSnd=Sound'Assault_G3A3.Play_G3A3_SingleShots'
	m_FullAutoStereoSnd=Sound'Assault_G3A3.Play_G3A3_AutoShots'
	m_FullAutoEndStereoSnd=Sound'Assault_G3A3.Stop_G3A3_AutoShots_Go'
	m_TriggerSnd=Sound'CommonAssaultRiffles.Play_Assault_Trigger'
	m_szMagazineClass="R63rdWeapons.R63rdCMAG762mm"
	m_szMuzzleClass="R6WeaponGadgets.R63rdMuzzleAssault762"
}
