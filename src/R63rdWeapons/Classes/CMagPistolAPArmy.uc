//=============================================================================
// CMagPistolAPArmy - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//============================================================================//
//  CMagPistolAPArmy.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class CMagPistolAPArmy extends PistolAPArmy;

defaultproperties
{
	m_iClipCapacity=30
	m_iNbOfClips=2
	m_iNbOfExtraClips=2
	m_fMuzzleVelocity=39000.0000000
	m_MuzzleScale=0.3033410
	m_fFireSoundRadius=2600.0000000
	m_fRateOfFire=0.1000000
	m_pBulletClass=Class'R6Weapons.ammo57x28mmNormalFMJ'
	m_stAccuracyValues=(fBaseAccuracy=1.6057200,fShuffleAccuracy=1.6902760,fWalkingAccuracy=2.1128450,fWalkingFastAccuracy=8.7154860,fRunningAccuracy=8.7154860,fReticuleTime=0.8701250,fAccuracyChange=9.1756620,fWeaponJump=13.4755300)
	m_szReticuleClass="CIRCLE"
	m_fFPBlend=0.3881650
	m_EquipSnd=Sound'CommonPistols.Play_Pistol_Equip'
	m_UnEquipSnd=Sound'CommonPistols.Play_Pistol_Unequip'
	m_ReloadSnd=Sound'Pistol_Belgian_Reloads.Play_Belgian_Reload'
	m_ReloadEmptySnd=Sound'Pistol_Belgian_Reloads.Play_Belgian_ReloadEmpty'
	m_SingleFireStereoSnd=Sound'Pistol_Belgian.Play_Belgian_SingleShots'
	m_EmptyMagSnd=Sound'Pistol_Belgian_Reloads.Play_Belgian_Chamber'
	m_TriggerSnd=Sound'CommonPistols.Play_Pistol_Trigger'
	m_szMagazineClass="R63rdWeapons.R63rdMAGPistolHigh"
}
