//=============================================================================
// CMagPistolCZ61 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//============================================================================//
//  CMagPistolCZ61.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class CMagPistolCZ61 extends PistolCZ61;

defaultproperties
{
	m_iClipCapacity=30
	m_iNbOfClips=2
	m_iNbOfExtraClips=2
	m_fMuzzleVelocity=19080.0000000
	m_MuzzleScale=0.5600420
	m_fFireSoundRadius=318.0000000
	m_fRateOfFire=0.0714290
	m_pBulletClass=Class'R6Weapons.ammo765mmAutoNormalFMJ'
	m_stAccuracyValues=(fBaseAccuracy=1.9633580,fShuffleAccuracy=2.6122920,fWalkingAccuracy=3.2653650,fWalkingFastAccuracy=13.4696300,fRunningAccuracy=13.4696300,fReticuleTime=1.1181880,fAccuracyChange=8.5487350,fWeaponJump=3.4474090)
	m_szReticuleClass="CIRCLE"
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
	m_TriggerSnd=Sound'CommonPistols.Play_Pistol_Trigger'
	m_szMagazineClass="R63rdWeapons.R63rdMAGCZ61High"
}
