//=============================================================================
// SilencedPistolDesertEagle357 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//============================================================================//
//  SilencedPistolDesertEagle357.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class SilencedPistolDesertEagle357 extends PistolDesertEagle357;

defaultproperties
{
	m_iClipCapacity=9
	m_iNbOfClips=4
	m_iNbOfExtraClips=6
	m_fMuzzleVelocity=28500.0000000
	m_MuzzleScale=0.2982960
	m_fFireSoundRadius=285.0000000
	m_fRateOfFire=0.1000000
	m_pBulletClass=Class'R6Weapons.ammo357calMagnumSubsonicFMJ'
	m_stAccuracyValues=(fBaseAccuracy=1.3783620,fShuffleAccuracy=2.0767850,fWalkingAccuracy=2.5959810,fWalkingFastAccuracy=10.7084200,fRunningAccuracy=10.7084200,fReticuleTime=1.2516880,fAccuracyChange=7.6772440,fWeaponJump=5.2525500)
	m_szReticuleClass="CIRCLE"
	m_bIsSilenced=true
	m_fFPBlend=0.7615160
	m_EquipSnd=Sound'CommonPistols.Play_Pistol_Equip'
	m_UnEquipSnd=Sound'CommonPistols.Play_Pistol_Unequip'
	m_ReloadSnd=Sound'Pistol_Des357_Reloads.Play_Des357_Reload'
	m_ReloadEmptySnd=Sound'Pistol_Des357_Reloads.Play_Des357_ReloadEmpty'
	m_SingleFireStereoSnd=Sound'Pistol_Des357_Silenced.Play_Des357Sil_SingleShots'
	m_EmptyMagSnd=Sound'Pistol_Des357_Reloads.Play_Des357_Chamber'
	m_TriggerSnd=Sound'CommonPistols.Play_Pistol_Trigger'
	m_szSilencerClass="R6WeaponGadgets.R63rdSilencerPistol"
}
