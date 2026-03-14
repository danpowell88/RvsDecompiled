//=============================================================================
// CMagAssaultFAMASG2 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//============================================================================//
//  CMagAssaultFAMASG2.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class CMagAssaultFAMASG2 extends AssaultFAMASG2;

defaultproperties
{
	m_iClipCapacity=100
	m_iNbOfClips=2
	m_iNbOfExtraClips=1
	m_fMuzzleVelocity=55500.0000000
	m_MuzzleScale=0.5659150
	m_fFireSoundRadius=3700.0000000
	m_fRateOfFire=0.0545450
	m_pBulletClass=Class'R6Weapons.ammo556mmNATONormalFMJ'
	m_stAccuracyValues=(fBaseAccuracy=0.9835483,fShuffleAccuracy=2.1013870,fWalkingAccuracy=3.1520810,fWalkingFastAccuracy=13.0023300,fRunningAccuracy=13.0023300,fReticuleTime=1.0639380,fAccuracyChange=6.3233000,fWeaponJump=7.6960980)
	m_szReticuleClass="RIFLE"
	m_fFireAnimRate=1.8333330
	m_fFPBlend=0.3892960
	m_EquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Equip'
	m_UnEquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Unequip'
	m_ReloadSnd=Sound'Assault_FMASG2_Reloads.Play_FMASG2_Reload'
	m_ReloadEmptySnd=Sound'Assault_FMASG2_Reloads.Play_FMASG2_ReloadEmpty'
	m_ChangeROFSnd=Sound'CommonAssaultRiffles.Play_Assault_ROF'
	m_SingleFireStereoSnd=Sound'Assault_FMASG2.Play_FMASG2_SingleShots'
	m_BurstFireStereoSnd=Sound'Assault_FMASG2.Play_FMASG2_TripleShots'
	m_FullAutoStereoSnd=Sound'Assault_FMASG2.Play_FMASG2_AutoShots'
	m_FullAutoEndStereoSnd=Sound'Assault_FMASG2.Stop_FMASG2_AutoShots_Go'
	m_TriggerSnd=Sound'CommonAssaultRiffles.Play_Assault_Trigger'
	m_szMagazineClass="R63rdWeapons.R63rdCMAG556mm"
	m_szMuzzleClass="R6WeaponGadgets.R63rdMuzzleAssault556"
}
