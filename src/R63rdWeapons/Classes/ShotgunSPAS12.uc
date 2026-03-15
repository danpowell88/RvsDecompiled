//=============================================================================
// ShotgunSPAS12 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//============================================================================//
//  ShotgunSPAS12.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class ShotgunSPAS12 extends R6PumpShotgun
    abstract;

defaultproperties
{
	m_pBulletClass=Class'R6Weapons.ammo12gauge'
	m_pEmptyShells=Class'R6SFX.R6Shell12GaugeBuck'
	m_pMuzzleFlash=Class'R6SFX.R6MuzzleFlash12Gauge'
	m_stWeaponCaps=(bSingle=1,bLight=1,bMiniScope=1)
	m_pFPHandsClass=Class'R61stWeapons.R61stHandsShotgunSPAS12'
	m_pFPWeaponClass=Class'R61stWeapons.R61stShotgunSPAS12'
	m_HUDTexture=Texture'R6HUD.HUDElements'
	m_vPositionOffset=(X=-11.0000000,Y=-2.5000000,Z=2.0000000)
	m_HUDTexturePos=(W=32.0000000,X=300.0000000,Y=192.0000000,Z=100.0000000)
	m_NameID="ShotgunSPAS12"
	StaticMesh=StaticMesh'R63rdWeapons_SM.Shotguns.R63rdSPAS12'
}
