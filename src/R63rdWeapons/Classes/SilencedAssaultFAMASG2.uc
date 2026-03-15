//=============================================================================
// SilencedAssaultFAMASG2 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//============================================================================//
//  SilencedAssaultFAMASG2.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class SilencedAssaultFAMASG2 extends AssaultFAMASG2;

defaultproperties
{
	m_iClipCapacity=30
	m_iNbOfClips=6
	m_iNbOfExtraClips=3
	m_fMuzzleVelocity=30000.0000000
	m_MuzzleScale=0.2305310
	m_fFireSoundRadius=300.0000000
	m_fRateOfFire=0.0545450
	m_pBulletClass=Class'R6Weapons.ammo556mmNATOSubsonicFMJ'
	m_stAccuracyValues=(fBaseAccuracy=0.6741143,fShuffleAccuracy=2.5036510,fWalkingAccuracy=3.7554770,fWalkingFastAccuracy=15.4913400,fRunningAccuracy=15.4913400,fReticuleTime=1.0748130,fAccuracyChange=3.6310860,fWeaponJump=0.9198397)
	m_szReticuleClass="RIFLE"
	m_bIsSilenced=true
	m_fFireAnimRate=1.8333330
	m_fFPBlend=0.7500000
	m_EquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Equip'
	m_UnEquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Unequip'
	m_ReloadSnd=Sound'Assault_FMASG2_Reloads.Play_FMASG2_Reload'
	m_ReloadEmptySnd=Sound'Assault_FMASG2_Reloads.Play_FMASG2_ReloadEmpty'
	m_ChangeROFSnd=Sound'CommonAssaultRiffles.Play_Assault_ROF'
	m_SingleFireStereoSnd=Sound'Assault_FMASG2_Silenced.Play_FMASG2Sil_SingleShots'
	m_BurstFireStereoSnd=Sound'Assault_FMASG2_Silenced.Play_FMASG2Sil_TripleShots'
	m_FullAutoStereoSnd=Sound'Assault_FMASG2_Silenced.Play_FMASG2Sil_AutoShots'
	m_FullAutoEndStereoSnd=Sound'Assault_FMASG2_Silenced.Stop_FMASG2Sil_AutoShots_Go'
	m_TriggerSnd=Sound'CommonAssaultRiffles.Play_Assault_Trigger'
	m_szMagazineClass="R63rdWeapons.R63rdMAG556mm"
	m_szSilencerClass="R6WeaponGadgets.R63rdSilencerSubGuns2"
}
