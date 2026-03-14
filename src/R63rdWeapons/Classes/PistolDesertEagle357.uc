//=============================================================================
// PistolDesertEagle357 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//============================================================================//
//  PistolDesertEagle357.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class PistolDesertEagle357 extends R6Pistol
 abstract;

defaultproperties
{
	m_pBulletClass=Class'R6Weapons.ammo357calMagnum'
	m_pEmptyShells=Class'R6SFX.R6Shell357calMagnum'
	m_pMuzzleFlash=Class'R6SFX.R6MuzzleFlash9mm'
	m_stWeaponCaps=(bSingle=1,bCMag=1,bSilencer=1,bLight=1)
	m_pFPHandsClass=Class'R61stWeapons.R61stHandsGripPistol'
	m_pFPWeaponClass=Class'R61stWeapons.R61stPistolDesertEagles'
	m_HUDTexture=Texture'R6HUD.HUDElements'
	m_vPositionOffset=(X=4.0000000,Y=-4.5000000,Z=5.0000000)
	m_HUDTexturePos=(W=32.0000000,X=300.0000000,Y=160.0000000,Z=100.0000000)
	m_NameID="PistolDesertEagle357"
	StaticMesh=StaticMesh'R63rdWeapons_SM.Pistols.R63rdDesertEagles'
}
