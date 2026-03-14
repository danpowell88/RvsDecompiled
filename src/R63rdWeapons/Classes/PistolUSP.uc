//=============================================================================
// PistolUSP - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//============================================================================//
//  PistolUSP.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class PistolUSP extends R6Pistol
    abstract;

defaultproperties
{
	m_pBulletClass=Class'R6Weapons.ammo40calAuto'
	m_pEmptyShells=Class'R6SFX.R6Shell40calAuto'
	m_pMuzzleFlash=Class'R6SFX.R6MuzzleFlash9mm'
	m_stWeaponCaps=(bSingle=1,bCMag=1,bSilencer=1,bLight=1)
	m_pFPHandsClass=Class'R61stWeapons.R61stHandsGripPistol'
	m_pFPWeaponClass=Class'R61stWeapons.R61stPistolUSP'
	m_HUDTexture=Texture'R6HUD.HUDElements'
	m_vPositionOffset=(X=0.0000000,Y=-5.0000000,Z=4.0000000)
	m_HUDTexturePos=(W=32.0000000,X=100.0000000,Y=128.0000000,Z=100.0000000)
	m_NameID="PistolUSP"
	StaticMesh=StaticMesh'R63rdWeapons_SM.Pistols.R63rdUSP'
}
