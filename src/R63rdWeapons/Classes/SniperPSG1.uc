//=============================================================================
// SniperPSG1 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//============================================================================//
//  SniperPSG1.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class SniperPSG1 extends R6SniperRifle
    abstract;

defaultproperties
{
	m_pBulletClass=Class'R6Weapons.ammo762mmNATO'
	m_pEmptyShells=Class'R6SFX.R6Shell762mmNATO'
	m_pMuzzleFlash=Class'R6SFX.R6MuzzleFlash762mm'
	m_stWeaponCaps=(bSingle=1,bSilencer=1,bLight=1,bHeatVision=1)
	m_pFPHandsClass=Class'R61stWeapons.R61stHandsSniperPSG1'
	m_pFPWeaponClass=Class'R61stWeapons.R61stSniperPSG1'
	m_HUDTexture=Texture'R6HUD.HUDElements'
	m_PawnWaitAnimLow="StandLMGLow_nt"
	m_PawnWaitAnimHigh="StandLMGHigh_nt"
	m_PawnWaitAnimProne="ProneSniper_nt"
	m_PawnFiringAnim="StandFireLmg"
	m_PawnFiringAnimProne="ProneBipodFireSniper"
	m_PawnReloadAnimProne="ProneReloadSniper"
	m_PawnReloadAnimProneTactical="ProneTacReloadSniper"
	m_vPositionOffset=(X=2.5000000,Y=0.0000000,Z=-2.5000000)
	m_HUDTexturePos=(W=32.0000000,X=300.0000000,Y=224.0000000,Z=100.0000000)
	m_NameID="SniperPSG1"
	StaticMesh=StaticMesh'R63rdWeapons_SM.SniperRifles.R63rdPSG1'
}
