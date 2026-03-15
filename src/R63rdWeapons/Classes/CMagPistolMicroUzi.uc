//=============================================================================
// CMagPistolMicroUzi - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//============================================================================//
//  CMagPistolMicroUzi.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class CMagPistolMicroUzi extends PistolMicroUzi;

defaultproperties
{
	m_iClipCapacity=32
	m_iNbOfClips=2
	m_iNbOfExtraClips=2
	m_fMuzzleVelocity=20700.0000000
	m_MuzzleScale=0.6108420
	m_fFireSoundRadius=1380.0000000
	m_fRateOfFire=0.1000000
	m_pBulletClass=Class'R6Weapons.ammo9mmParabellumNormalFMJ'
	m_stAccuracyValues=(fBaseAccuracy=2.0111810,fShuffleAccuracy=2.5309920,fWalkingAccuracy=3.1637400,fWalkingFastAccuracy=13.0504300,fRunningAccuracy=13.0504300,fReticuleTime=1.1286880,fAccuracyChange=8.8736370,fWeaponJump=8.0413840)
	m_szReticuleClass="CIRCLE"
	m_fFPBlend=0.3618970
	m_EquipSnd=Sound'CommonSMG.Play_SMG_Equip'
	m_UnEquipSnd=Sound'CommonSMG.Play_SMG_Unequip'
	m_ReloadSnd=Sound'Mult_UziPistol_Reloads.Play_UZIPistol_Reload'
	m_ReloadEmptySnd=Sound'Mult_UziPistol_Reloads.Play_UZIPistol_ReloadEmpty'
	m_ChangeROFSnd=Sound'CommonSMG.Play_SMG_ROF'
	m_SingleFireStereoSnd=Sound'Mult_UziPistol.Play_UziPistol_SingleShots'
	m_FullAutoStereoSnd=Sound'Mult_UziPistol.Play_UziPistol_AutoShots'
	m_FullAutoEndStereoSnd=Sound'Mult_UziPistol.Stop_UziPistol_AutoShots_Go'
	m_TriggerSnd=Sound'CommonPistols.Play_Pistol_Trigger'
	m_szMagazineClass="R63rdWeapons.R63rdMAGPistolHigh"
}
