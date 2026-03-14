//=============================================================================
// SubUzi - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//============================================================================//
//  SubUzi.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class SubUzi extends R6SubMachineGun
 abstract;

defaultproperties
{
	m_pBulletClass=Class'R6Weapons.ammo9mmParabellum'
	m_pEmptyShells=Class'R6SFX.R6Shell9mmParabellum'
	m_pMuzzleFlash=Class'R6SFX.R6MuzzleFlashSub'
	m_stWeaponCaps=(bSingle=1,bFullAuto=1,bCMag=1,bSilencer=1,bLight=1)
	m_pFPHandsClass=Class'R61stWeapons.R61stHandsGripUZI'
	m_pFPWeaponClass=Class'R61stWeapons.R61stSubUzi'
	m_eGripType=2
	m_bUseMicroAnim=true
	m_HUDTexture=Texture'R6HUD.HUDElements'
	m_PawnWaitAnimLow="StandBullPupLow_nt"
	m_PawnWaitAnimHigh="StandBullPupHigh_nt"
	m_PawnWaitAnimProne="ProneBullPup_nt"
	m_PawnFiringAnim="StandFireBullPup"
	m_PawnFiringAnimProne="ProneFireBullPup"
	m_PawnReloadAnim="StandReloadHandGun"
	m_PawnReloadAnimTactical="StandReloadHandGun"
	m_PawnReloadAnimProne="ProneReloadHandGun"
	m_PawnReloadAnimProneTactical="ProneReloadHandGun"
	m_vPositionOffset=(X=-0.5000000,Y=-2.5000000,Z=3.5000000)
	m_HUDTexturePos=(W=32.0000000,X=200.0000000,Y=256.0000000,Z=100.0000000)
	m_NameID="SubUzi"
	StaticMesh=StaticMesh'R63rdWeapons_SM.SubGuns.R63rdUzi'
}
