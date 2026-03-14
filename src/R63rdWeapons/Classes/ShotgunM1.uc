//=============================================================================
// ShotgunM1 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//============================================================================//
//  ShotgunM1.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class ShotgunM1 extends R6PumpShotgun
 abstract;

defaultproperties
{
	m_pBulletClass=Class'R6Weapons.ammo12gauge'
	m_pEmptyShells=Class'R6SFX.R6Shell12GaugeBuck'
	m_pMuzzleFlash=Class'R6SFX.R6MuzzleFlash12Gauge'
	m_stWeaponCaps=(bSingle=1,bLight=1,bMiniScope=1)
	m_pFPHandsClass=Class'R61stWeapons.R61stHandsShotgunM1'
	m_pFPWeaponClass=Class'R61stWeapons.R61stShotgunM1'
	m_HUDTexture=Texture'R6HUD.HUDElements'
	m_vPositionOffset=(X=-13.8000000,Y=-2.5000000,Z=6.0000000)
	m_HUDTexturePos=(W=32.0000000,X=400.0000000,Y=192.0000000,Z=100.0000000)
	m_NameID="ShotgunM1"
	StaticMesh=StaticMesh'R63rdWeapons_SM.Shotguns.R63rdM1'
}
