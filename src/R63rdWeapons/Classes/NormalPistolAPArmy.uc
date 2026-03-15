//=============================================================================
// NormalPistolAPArmy - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//============================================================================//
//  NormalPistolAPArmy.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class NormalPistolAPArmy extends PistolAPArmy;

defaultproperties
{
	m_iClipCapacity=20
	m_iNbOfClips=3
	m_iNbOfExtraClips=4
	m_fMuzzleVelocity=39000.0000000
	m_MuzzleScale=0.3033410
	m_fFireSoundRadius=2600.0000000
	m_fRateOfFire=0.1000000
	m_pBulletClass=Class'R6Weapons.ammo57x28mmNormalFMJ'
	m_stAccuracyValues=(fBaseAccuracy=1.6057200,fShuffleAccuracy=1.6902760,fWalkingAccuracy=2.1128450,fWalkingFastAccuracy=8.7154860,fRunningAccuracy=8.7154860,fReticuleTime=0.8315000,fAccuracyChange=9.2300960,fWeaponJump=17.2066500)
	m_szReticuleClass="CIRCLE"
	m_fFPBlend=0.2187590
	m_EquipSnd=Sound'CommonPistols.Play_Pistol_Equip'
	m_UnEquipSnd=Sound'CommonPistols.Play_Pistol_Unequip'
	m_ReloadSnd=Sound'Pistol_Belgian_Reloads.Play_Belgian_Reload'
	m_ReloadEmptySnd=Sound'Pistol_Belgian_Reloads.Play_Belgian_ReloadEmpty'
	m_SingleFireStereoSnd=Sound'Pistol_Belgian.Play_Belgian_SingleShots'
	m_EmptyMagSnd=Sound'Pistol_Belgian_Reloads.Play_Belgian_Chamber'
	m_TriggerSnd=Sound'CommonPistols.Play_Pistol_Trigger'
	m_szTacticalLightClass="R6WeaponGadgets.R63rdTACPistol"
}
