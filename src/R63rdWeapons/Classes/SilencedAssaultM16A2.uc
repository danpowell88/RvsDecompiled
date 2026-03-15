//=============================================================================
// SilencedAssaultM16A2 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//============================================================================//
//  SilencedAssaultM16A2.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class SilencedAssaultM16A2 extends AssaultM16A2;

defaultproperties
{
	m_eRateOfFire=1
	m_iClipCapacity=30
	m_iNbOfClips=6
	m_iNbOfExtraClips=3
	m_fMuzzleVelocity=30000.0000000
	m_MuzzleScale=0.2305310
	m_fFireSoundRadius=300.0000000
	m_fRateOfFire=0.0727270
	m_pBulletClass=Class'R6Weapons.ammo556mmNATOSubsonicFMJ'
	m_stAccuracyValues=(fBaseAccuracy=0.3403104,fShuffleAccuracy=2.9375970,fWalkingAccuracy=4.4063950,fWalkingFastAccuracy=18.1763800,fRunningAccuracy=18.1763800,fReticuleTime=1.1365000,fAccuracyChange=2.3392650,fWeaponJump=0.9935065)
	m_szReticuleClass="RIFLE"
	m_bIsSilenced=true
	m_fFireAnimRate=1.3750000
	m_fFPBlend=0.7500000
	m_EquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Equip'
	m_UnEquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Unequip'
	m_ReloadSnd=Sound'Assault_M16A2_Reloads.Play_M16A2_Reload'
	m_ReloadEmptySnd=Sound'Assault_M16A2_Reloads.Play_M16A2_ReloadEmpty'
	m_ChangeROFSnd=Sound'CommonAssaultRiffles.Play_Assault_ROF'
	m_SingleFireStereoSnd=Sound'Assault_M16A2_Silenced.Play_M16A2Sil_SingleShots'
	m_BurstFireStereoSnd=Sound'Assault_M16A2_Silenced.Play_M16A2Sil_TripleShots'
	m_FullAutoStereoSnd=Sound'Assault_M16A2_Silenced.Play_M16A2Sil_DoubleShots'
	m_TriggerSnd=Sound'CommonAssaultRiffles.Play_Assault_Trigger'
	m_szMagazineClass="R63rdWeapons.R63rdMAG556mm"
	m_szSilencerClass="R6WeaponGadgets.R63rdSilencerSubGuns2"
}
