//=============================================================================
// PistolSPP - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//============================================================================//
//  PistolSPP.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class PistolSPP extends R6Pistol
 abstract;

defaultproperties
{
	m_pBulletClass=Class'R6Weapons.ammo9mmParabellum'
	m_pEmptyShells=Class'R6SFX.R6Shell9mmParabellum'
	m_pMuzzleFlash=Class'R6SFX.R6MuzzleFlash9mm'
	m_stWeaponCaps=(bSingle=1,bSilencer=1,bLight=1)
	m_pFPHandsClass=Class'R61stWeapons.R61stHandsGripSPP'
	m_pFPWeaponClass=Class'R61stWeapons.R61stPistolSPP'
	m_eGripType=6
	m_HUDTexture=Texture'R6HUD.HUDElements'
	m_PawnWaitAnimLow="StandUZILow_nt"
	m_PawnWaitAnimHigh="StandUZIHigh_nt"
	m_PawnWaitAnimProne="ProneUZI_nt"
	m_PawnFiringAnim="StandFireUZI"
	m_PawnFiringAnimProne="ProneFireUZI"
	m_vPositionOffset=(X=-9.0000000,Y=-5.5000000,Z=6.5000000)
	m_HUDTexturePos=(W=32.0000000,X=300.0000000,Y=128.0000000,Z=100.0000000)
	m_NameID="PistolSPP"
	StaticMesh=StaticMesh'R63rdWeapons_SM.Pistols.R63rdSPP'
}
