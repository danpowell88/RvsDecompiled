//=============================================================================
// NormalSubUMP - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//============================================================================//
//  NormalSubUMP.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class NormalSubUMP extends SubUMP;

defaultproperties
{
	m_iClipCapacity=25
	m_iNbOfClips=6
	m_iNbOfExtraClips=3
	m_fMuzzleVelocity=18720.0000000
	m_MuzzleScale=0.3364020
	m_fFireSoundRadius=312.0000000
	m_fRateOfFire=0.1034480
	m_pBulletClass=Class'R6Weapons.ammo45calAutoNormalFMJ'
	m_stAccuracyValues=(fBaseAccuracy=1.4213950,fShuffleAccuracy=1.5321870,fWalkingAccuracy=2.2982800,fWalkingFastAccuracy=9.4804070,fRunningAccuracy=9.4804070,fReticuleTime=0.5006875,fAccuracyChange=6.9844740,fWeaponJump=7.6394840)
	m_szReticuleClass="CIRCLEDOTLINE"
	m_fFireAnimRate=0.9666670
	m_fFPBlend=0.3937890
	m_EquipSnd=Sound'CommonSMG.Play_SMG_Equip'
	m_UnEquipSnd=Sound'CommonSMG.Play_SMG_Unequip'
	m_ReloadSnd=Sound'Sub_UMP45_Reloads.Play_UMP45_Reload'
	m_ReloadEmptySnd=Sound'Sub_UMP45_Reloads.Play_UMP45_ReloadEmpty'
	m_ChangeROFSnd=Sound'CommonSMG.Play_SMG_ROF'
	m_SingleFireStereoSnd=Sound'Sub_UMP45.Play_UMP45_SingleShots'
	m_BurstFireStereoSnd=Sound'Sub_UMP45.Play_UMP45_TripleShots'
	m_FullAutoStereoSnd=Sound'Sub_UMP45.Play_UMP45_AutoShots'
	m_FullAutoEndStereoSnd=Sound'Sub_UMP45.Stop_UMP45_AutoShots_Go'
	m_TriggerSnd=Sound'CommonSMG.Play_SMG_Trigger'
	m_szMagazineClass="R63rdWeapons.R63rdMAG10mm"
}
