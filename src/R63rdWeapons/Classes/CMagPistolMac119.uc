//=============================================================================
// CMagPistolMac119 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//============================================================================//
//  CMagPistolMac119.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class CMagPistolMac119 extends PistolMac119;

defaultproperties
{
	m_eRateOfFire=2
	m_iClipCapacity=32
	m_iNbOfClips=2
	m_iNbOfExtraClips=2
	m_fMuzzleVelocity=21960.0000000
	m_MuzzleScale=0.6247470
	m_fFireSoundRadius=1464.0000000
	m_fRateOfFire=0.0500000
	m_pBulletClass=Class'R6Weapons.ammo9mmParabellumNormalFMJ'
	m_stAccuracyValues=(fBaseAccuracy=2.5324950,fShuffleAccuracy=3.3447590,fWalkingAccuracy=4.1809490,fWalkingFastAccuracy=17.2464100,fRunningAccuracy=17.2464100,fReticuleTime=1.1436870,fAccuracyChange=9.2133830,fWeaponJump=6.3242850)
	m_szReticuleClass="CIRCLE"
	m_fFireAnimRate=2.0000000
	m_fFPBlend=0.4981530
	m_EquipSnd=Sound'CommonSMG.Play_SMG_Equip'
	m_UnEquipSnd=Sound'CommonSMG.Play_SMG_Unequip'
	m_ReloadSnd=Sound'Mult_Mac11_Reloads.Play_Mac11_Reload'
	m_ReloadEmptySnd=Sound'Mult_Mac11_Reloads.Play_Mac11_ReloadEmpty'
	m_FullAutoStereoSnd=Sound'Mult_Mac11.Play_Ingram_AutoShots'
	m_FullAutoEndStereoSnd=Sound'Mult_Mac11.Stop_Ingram_AutoShots_Go'
	m_TriggerSnd=Sound'CommonPistols.Play_Pistol_Trigger'
	m_szMagazineClass="R63rdWeapons.R63rdMAGPistolHigh"
}
