//=============================================================================
// NormalSubMTAR21 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//============================================================================//
//  NormalSubMTAR21.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class NormalSubMTAR21 extends SubMTAR21;

defaultproperties
{
	m_iClipCapacity=30
	m_iNbOfClips=7
	m_iNbOfExtraClips=3
	m_fMuzzleVelocity=21000.0000000
	m_MuzzleScale=0.2290050
	m_fFireSoundRadius=1400.0000000
	m_fRateOfFire=0.0727270
	m_pBulletClass=Class'R6Weapons.ammo9mmParabellumNormalFMJ'
	m_stAccuracyValues=(fBaseAccuracy=1.6338230,fShuffleAccuracy=1.7760310,fWalkingAccuracy=2.6640460,fWalkingFastAccuracy=10.9891900,fRunningAccuracy=10.9891900,fReticuleTime=0.6575000,fAccuracyChange=7.5411990,fWeaponJump=4.5631250)
	m_szReticuleClass="CIRCLEDOTLINE"
	m_fFireAnimRate=1.3750000
	m_fFPBlend=0.6379050
	m_EquipSnd=Sound'CommonSMG.Play_SMG_Equip'
	m_UnEquipSnd=Sound'CommonSMG.Play_SMG_Unequip'
	m_ReloadSnd=Sound'Sub_MTAR21_Reloads.Play_MTAR21_Reload'
	m_ReloadEmptySnd=Sound'Sub_MTAR21_Reloads.Play_MTAR21_ReloadEmpty'
	m_ChangeROFSnd=Sound'CommonSMG.Play_SMG_ROF'
	m_SingleFireStereoSnd=Sound'Sub_MTAR21.Play_MTAR21_SingleShots'
	m_FullAutoStereoSnd=Sound'Sub_MTAR21.Play_MTAR21_AutoShots'
	m_FullAutoEndStereoSnd=Sound'Sub_MTAR21.Stop_MTAR21_AutoShots_Go'
	m_TriggerSnd=Sound'CommonSMG.Play_SMG_Trigger'
	m_szMagazineClass="R63rdWeapons.R63rdMAG556mm"
	m_szMuzzleClass="R6WeaponGadgets.R63rdMuzzleSub"
}
