//=============================================================================
// NormalAssaultFAL - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//============================================================================//
//  NormalAssaultFAL.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class NormalAssaultFAL extends AssaultFAL;

defaultproperties
{
	m_iClipCapacity=20
	m_iNbOfClips=6
	m_iNbOfExtraClips=3
	m_fMuzzleVelocity=50400.0000000
	m_MuzzleScale=0.9084900
	m_fFireSoundRadius=3360.0000000
	m_fRateOfFire=0.0923080
	m_pBulletClass=Class'R6Weapons.ammo762mmNATONormalFMJ'
	m_stAccuracyValues=(fBaseAccuracy=0.6480629,fShuffleAccuracy=2.5375180,fWalkingAccuracy=3.8062780,fWalkingFastAccuracy=15.7008900,fRunningAccuracy=15.7008900,fReticuleTime=1.1603130,fAccuracyChange=5.4868210,fWeaponJump=14.3303700)
	m_szReticuleClass="RIFLE"
	m_fFireAnimRate=1.0833330
	m_EquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Equip'
	m_UnEquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Unequip'
	m_ReloadSnd=Sound'Assault_FAL_Reloads.Play_FAL_Reload'
	m_ReloadEmptySnd=Sound'Assault_FAL_Reloads.Play_FAL_ReloadEmpty'
	m_ChangeROFSnd=Sound'CommonAssaultRiffles.Play_Assault_ROF'
	m_SingleFireStereoSnd=Sound'Assault_FAL.Play_FAL_SingleShots'
	m_FullAutoStereoSnd=Sound'Assault_FAL.Play_FAL_AutoShots'
	m_FullAutoEndStereoSnd=Sound'Assault_FAL.Stop_FAL_AutoShots_Go'
	m_TriggerSnd=Sound'CommonAssaultRiffles.Play_Assault_Trigger'
	m_szMagazineClass="R63rdWeapons.R63rdMAG762mm2"
	m_szMuzzleClass="R6WeaponGadgets.R63rdMuzzleAssault762"
}
