//=============================================================================
// PistolCZ61 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//============================================================================//
//  PistolCZ61.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class PistolCZ61 extends R6Pistol
 abstract;

defaultproperties
{
	m_pBulletClass=Class'R6Weapons.ammo765mmAuto'
	m_pEmptyShells=Class'R6SFX.R6Shell765mmAuto'
	m_pMuzzleFlash=Class'R6SFX.R6MuzzleFlash9mm'
	m_stWeaponCaps=(bSingle=1,bFullAuto=1,bCMag=1,bLight=1)
	m_pFPHandsClass=Class'R61stWeapons.R61stHandsPistolCZ61'
	m_pFPWeaponClass=Class'R61stWeapons.R61stPistolCZ61'
	m_eGripType=4
	m_HUDTexture=Texture'R6HUD.HUDElements'
	m_PawnWaitAnimLow="StandP90Low_nt"
	m_PawnWaitAnimHigh="StandP90High_nt"
	m_PawnWaitAnimProne="ProneP90_nt"
	m_PawnFiringAnim="StandFireP90"
	m_PawnFiringAnimProne="ProneFireP90"
	m_PawnReloadAnim="StandReloadSubGun"
	m_PawnReloadAnimTactical="StandTacReloadSubGun"
	m_PawnReloadAnimProne="ProneReloadSubGun"
	m_PawnReloadAnimProneTactical="ProneTacReloadSubGun"
	m_vPositionOffset=(X=-3.5000000,Y=-4.5000000,Z=6.5000000)
	m_HUDTexturePos=(W=32.0000000,X=400.0000000,Y=160.0000000,Z=100.0000000)
	m_NameID="PistolCZ61"
	StaticMesh=StaticMesh'R63rdWeapons_SM.Pistols.R63rdPistolCZ61'
}
