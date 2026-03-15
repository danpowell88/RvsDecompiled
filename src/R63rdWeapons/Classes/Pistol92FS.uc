//=============================================================================
// Pistol92FS - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//============================================================================//
//  Pistol92FS.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class Pistol92FS extends R6Pistol
    abstract;

defaultproperties
{
	m_pBulletClass=Class'R6Weapons.ammo9mmParabellum'
	m_pEmptyShells=Class'R6SFX.R6Shell9mmParabellum'
	m_pMuzzleFlash=Class'R6SFX.R6MuzzleFlash9mm'
	m_stWeaponCaps=(bSingle=1,bCMag=1,bSilencer=1,bLight=1)
	m_pFPHandsClass=Class'R61stWeapons.R61stHandsGripPistol'
	m_pFPWeaponClass=Class'R61stWeapons.R61stPistol92FS'
	m_HUDTexture=Texture'R6HUD.HUDElements'
	m_vPositionOffset=(X=0.0000000,Y=-5.0000000,Z=4.5000000)
	m_HUDTexturePos=(W=32.0000000,X=100.0000000,Y=192.0000000,Z=100.0000000)
	m_NameID="Pistol92FS"
	StaticMesh=StaticMesh'R63rdWeapons_SM.Pistols.R63rd92FS'
}
