//=============================================================================
// NormalSubCZ61 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//============================================================================//
//  NormalSubCZ61.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class NormalSubCZ61 extends SubCZ61;

defaultproperties
{
	m_iClipCapacity=20
	m_iNbOfClips=10
	m_iNbOfExtraClips=4
	m_fMuzzleVelocity=19080.0000000
	m_MuzzleScale=0.4200320
	m_fFireSoundRadius=318.0000000
	m_fRateOfFire=0.0714290
	m_pBulletClass=Class'R6Weapons.ammo765mmAutoNormalFMJ'
	m_stAccuracyValues=(fBaseAccuracy=1.7339780,fShuffleAccuracy=1.9058280,fWalkingAccuracy=2.8587420,fWalkingFastAccuracy=11.7923100,fRunningAccuracy=11.7923100,fReticuleTime=0.2263750,fAccuracyChange=7.3972670,fWeaponJump=3.7467940)
	m_szReticuleClass="CIRCLEDOTLINE"
	m_fFireAnimRate=1.4000000
	m_fFPBlend=0.7026830
	m_EquipSnd=Sound'CommonSMG.Play_SMG_Equip'
	m_UnEquipSnd=Sound'CommonSMG.Play_SMG_Unequip'
	m_ReloadSnd=Sound'Mult_CZ61_Reloads.Play_CZ61_Reload'
	m_ReloadEmptySnd=Sound'Mult_CZ61_Reloads.Play_CZ61_ReloadEmpty'
	m_ChangeROFSnd=Sound'CommonSMG.Play_SMG_ROF'
	m_SingleFireStereoSnd=Sound'Mult_CZ61.Play_CZ61_SingleShots'
	m_FullAutoStereoSnd=Sound'Mult_CZ61.Play_CZ61_AutoShots'
	m_FullAutoEndStereoSnd=Sound'Mult_CZ61.Stop_CZ61_AutoShots_Go'
	m_TriggerSnd=Sound'CommonSMG.Play_SMG_Trigger'
	m_szMagazineClass="R63rdWeapons.R63rdMAGCZ61"
}
