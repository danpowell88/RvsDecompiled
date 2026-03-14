//=============================================================================
// CMagSubCZ61 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//============================================================================//
//  CMagSubCZ61.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class CMagSubCZ61 extends SubCZ61;

defaultproperties
{
	m_iClipCapacity=50
	m_iNbOfClips=4
	m_iNbOfExtraClips=3
	m_fMuzzleVelocity=19080.0000000
	m_MuzzleScale=0.4200320
	m_fFireSoundRadius=318.0000000
	m_fRateOfFire=0.0714290
	m_pBulletClass=Class'R6Weapons.ammo765mmAutoNormalFMJ'
	m_stAccuracyValues=(fBaseAccuracy=1.7339780,fShuffleAccuracy=1.9058280,fWalkingAccuracy=2.8587420,fWalkingFastAccuracy=11.7923100,fRunningAccuracy=11.7923100,fReticuleTime=0.3201250,fAccuracyChange=7.4132130,fWeaponJump=2.9736220)
	m_szReticuleClass="CIRCLEDOTLINE"
	m_fFireAnimRate=1.4000000
	m_fFPBlend=0.7500000
	m_EquipSnd=Sound'CommonSMG.Play_SMG_Equip'
	m_UnEquipSnd=Sound'CommonSMG.Play_SMG_Unequip'
	m_ReloadSnd=Sound'Mult_CZ61_Reloads.Play_CZ61_Reload'
	m_ReloadEmptySnd=Sound'Mult_CZ61_Reloads.Play_CZ61_ReloadEmpty'
	m_ChangeROFSnd=Sound'CommonSMG.Play_SMG_ROF'
	m_SingleFireStereoSnd=Sound'Mult_CZ61.Play_CZ61_SingleShots'
	m_FullAutoStereoSnd=Sound'Mult_CZ61.Play_CZ61_AutoShots'
	m_FullAutoEndStereoSnd=Sound'Mult_CZ61.Stop_CZ61_AutoShots_Go'
	m_TriggerSnd=Sound'CommonSMG.Play_SMG_Trigger'
	m_szMagazineClass="R63rdWeapons.R63rdMAGCZ61High2"
}
