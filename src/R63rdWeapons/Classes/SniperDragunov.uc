//=============================================================================
// SniperDragunov - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//============================================================================//
//  SniperDragunov.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class SniperDragunov extends R6SniperRifle
    abstract;

defaultproperties
{
	m_pBulletClass=Class'R6Weapons.ammo762x54mmR'
	m_pEmptyShells=Class'R6SFX.R6Shell762mmNATO'
	m_pMuzzleFlash=Class'R6SFX.R6MuzzleFlash762mm'
	m_stWeaponCaps=(bSingle=1,bSilencer=1,bLight=1,bHeatVision=1)
	m_pFPHandsClass=Class'R61stWeapons.R61stHandsSniperDragunov'
	m_pFPWeaponClass=Class'R61stWeapons.R61stSniperDragunov'
	m_HUDTexture=Texture'R6HUD.HUDElements'
	m_PawnWaitAnimLow="StandLMGLow_nt"
	m_PawnWaitAnimHigh="StandLMGHigh_nt"
	m_PawnWaitAnimProne="ProneSniper_nt"
	m_PawnFiringAnim="StandFireLmg"
	m_PawnFiringAnimProne="ProneBipodFireSniper"
	m_PawnReloadAnimProne="ProneReloadSniper"
	m_PawnReloadAnimProneTactical="ProneTacReloadSniper"
	m_vPositionOffset=(X=0.0000000,Y=0.0000000,Z=-2.0000000)
	m_HUDTexturePos=(W=32.0000000,Y=256.0000000,Z=100.0000000)
	m_NameID="SniperDragunov"
	StaticMesh=StaticMesh'R63rdWeapons_SM.SniperRifles.R63rdDragunov'
}
