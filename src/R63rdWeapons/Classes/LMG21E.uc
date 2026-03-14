//=============================================================================
// LMG21E - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//============================================================================//
//  LMG21E.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class LMG21E extends R6MachineGun
 abstract;

defaultproperties
{
	m_pBulletClass=Class'R6Weapons.ammo762mmNATO'
	m_pEmptyShells=Class'R6SFX.R6Shell762mmNATO'
	m_pMuzzleFlash=Class'R6SFX.R6MuzzleFlash762mm'
	m_stWeaponCaps=(bFullAuto=1,bLight=1)
	m_pFPHandsClass=Class'R61stWeapons.R61stHandsLMG21E'
	m_pFPWeaponClass=Class'R61stWeapons.R61stLMG21E'
	m_HUDTexture=Texture'R6HUD.HUDElements'
	m_vPositionOffset=(X=-3.0000000,Y=-0.5000000,Z=-1.0000000)
	m_HUDTexturePos=(W=32.0000000,Y=128.0000000,Z=100.0000000)
	m_NameID="LMG21E"
	StaticMesh=StaticMesh'R63rdWeapons_SM.MachineGuns.R63rd21E'
}
