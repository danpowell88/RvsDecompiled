//=============================================================================
// NormalSubMac119 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//============================================================================//
//  NormalSubMac119.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class NormalSubMac119 extends SubMac119;

defaultproperties
{
	m_iClipCapacity=32
	m_iNbOfClips=7
	m_iNbOfExtraClips=3
	m_fMuzzleVelocity=21000.0000000
	m_MuzzleScale=0.4605590
	m_fFireSoundRadius=1400.0000000
	m_fRateOfFire=0.0500000
	m_pBulletClass=Class'R6Weapons.ammo9mmParabellumNormalFMJ'
	m_stAccuracyValues=(fBaseAccuracy=2.1582810,fShuffleAccuracy=2.7192350,fWalkingAccuracy=4.0788520,fWalkingFastAccuracy=16.8252700,fRunningAccuracy=16.8252700,fReticuleTime=0.2275000,fAccuracyChange=8.3674890,fWeaponJump=6.5187500)
	m_szReticuleClass="CIRCLEDOTLINE"
	m_fFireAnimRate=2.0000000
	m_fFPBlend=0.4827220
	m_EquipSnd=Sound'CommonSMG.Play_SMG_Equip'
	m_UnEquipSnd=Sound'CommonSMG.Play_SMG_Unequip'
	m_ReloadSnd=Sound'Mult_Mac11_Reloads.Play_Mac11_Reload'
	m_ReloadEmptySnd=Sound'Mult_Mac11_Reloads.Play_Mac11_ReloadEmpty'
	m_SingleFireStereoSnd=Sound'Mult_Mac11.Play_Ingram_SingleShots'
	m_FullAutoStereoSnd=Sound'Mult_Mac11.Play_Ingram_AutoShots'
	m_FullAutoEndStereoSnd=Sound'Mult_Mac11.Stop_Ingram_AutoShots_Go'
	m_TriggerSnd=Sound'CommonSMG.Play_SMG_Trigger'
	m_szMagazineClass="R63rdWeapons.R63rdMAG9mmStraight"
	m_szTacticalLightClass="R6WeaponGadgets.R63rdTACPistol"
}
