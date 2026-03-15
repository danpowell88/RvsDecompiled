//=============================================================================
// CMagSubMTAR21 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//============================================================================//
//  CMagSubMTAR21.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class CMagSubMTAR21 extends SubMTAR21;

defaultproperties
{
	m_iClipCapacity=100
	m_iNbOfClips=2
	m_iNbOfExtraClips=1
	m_fMuzzleVelocity=21000.0000000
	m_MuzzleScale=0.2290050
	m_fFireSoundRadius=1400.0000000
	m_fRateOfFire=0.0727270
	m_pBulletClass=Class'R6Weapons.ammo9mmParabellumNormalFMJ'
	m_stAccuracyValues=(fBaseAccuracy=1.6338230,fShuffleAccuracy=1.7760310,fWalkingAccuracy=2.6640460,fWalkingFastAccuracy=10.9891900,fRunningAccuracy=10.9891900,fReticuleTime=0.8825000,fAccuracyChange=7.1080630,fWeaponJump=3.2593750)
	m_szReticuleClass="CIRCLEDOTLINE"
	m_fFireAnimRate=1.3750000
	m_fFPBlend=0.7500000
	m_EquipSnd=Sound'CommonSMG.Play_SMG_Equip'
	m_UnEquipSnd=Sound'CommonSMG.Play_SMG_Unequip'
	m_ReloadSnd=Sound'Sub_MTAR21_Reloads.Play_MTAR21_Reload'
	m_ReloadEmptySnd=Sound'Sub_MTAR21_Reloads.Play_MTAR21_ReloadEmpty'
	m_ChangeROFSnd=Sound'CommonSMG.Play_SMG_ROF'
	m_SingleFireStereoSnd=Sound'Sub_MTAR21.Play_MTAR21_SingleShots'
	m_FullAutoStereoSnd=Sound'Sub_MTAR21.Play_MTAR21_AutoShots'
	m_FullAutoEndStereoSnd=Sound'Sub_MTAR21.Stop_MTAR21_AutoShots_Go'
	m_TriggerSnd=Sound'CommonSMG.Play_SMG_Trigger'
	m_szMagazineClass="R63rdWeapons.R63rdCMAG9mmMTAR21"
	m_szMuzzleClass="R6WeaponGadgets.R63rdMuzzleSub"
}
