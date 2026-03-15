//=============================================================================
// SniperM82A1 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//============================================================================//
//  SniperM82A1.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class SniperM82A1 extends R6SniperRifle
    abstract;

defaultproperties
{
	m_pBulletClass=Class'R6Weapons.ammo50calM33'
	m_pEmptyShells=Class'R6SFX.R6Shell50calM33'
	m_pMuzzleFlash=Class'R6SFX.R6MuzzleFlash50M33'
	m_stWeaponCaps=(bSingle=1,bSilencer=1,bLight=1,bHeatVision=1)
	m_pFPHandsClass=Class'R61stWeapons.R61stHandsSniperM82A1'
	m_pFPWeaponClass=Class'R61stWeapons.R61stSniperM82A1'
	m_HUDTexture=Texture'R6HUD.HUDElements'
	m_PawnWaitAnimLow="StandLMGLow_nt"
	m_PawnWaitAnimHigh="StandLMGHigh_nt"
	m_PawnWaitAnimProne="ProneSniper_nt"
	m_PawnFiringAnim="StandFireLmg"
	m_PawnFiringAnimProne="ProneBipodFireSniper"
	m_PawnReloadAnimProne="ProneReloadSniper"
	m_PawnReloadAnimProneTactical="ProneTacReloadSniper"
	m_vPositionOffset=(X=2.0000000,Y=-0.5000000,Z=-3.5000000)
	m_HUDTexturePos=(W=32.0000000,X=400.0000000,Y=224.0000000,Z=100.0000000)
	m_NameID="SniperM82A1"
	StaticMesh=StaticMesh'R63rdWeapons_SM.SniperRifles.R63rdM82A1'
}
