//=============================================================================
// SniperWA2000 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//============================================================================//
//  SniperWA2000.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class SniperWA2000 extends R6SniperRifle
 abstract;

defaultproperties
{
	m_pBulletClass=Class'R6Weapons.ammo30calMagnum'
	m_pEmptyShells=Class'R6SFX.R6Shell762mmNATO'
	m_pMuzzleFlash=Class'R6SFX.R6MuzzleFlash762mm'
	m_stWeaponCaps=(bSingle=1,bSilencer=1,bLight=1,bHeatVision=1)
	m_pFPHandsClass=Class'R61stWeapons.R61stHandsSniperWA2000'
	m_pFPWeaponClass=Class'R61stWeapons.R61stSniperWA2000'
	m_HUDTexture=Texture'R6HUD.HUDElements'
	m_PawnWaitAnimLow="StandLMGLow_nt"
	m_PawnWaitAnimHigh="StandLMGHigh_nt"
	m_PawnWaitAnimProne="ProneSniper_nt"
	m_PawnFiringAnim="StandFireLmg"
	m_PawnFiringAnimProne="ProneBipodFireSniper"
	m_PawnReloadAnim="StandReloadAug"
	m_PawnReloadAnimTactical="StandTacReloadAug"
	m_PawnReloadAnimProne="ProneReloadAug"
	m_PawnReloadAnimProneTactical="ProneTacReloadAug"
	m_vPositionOffset=(X=-2.0000000,Y=0.5000000,Z=-5.5000000)
	m_HUDTexturePos=(W=32.0000000,Y=224.0000000,Z=100.0000000)
	m_NameID="SniperWA2000"
	StaticMesh=StaticMesh'R63rdWeapons_SM.SniperRifles.R63rdWA2000'
}
