//=============================================================================
// LMGRPD - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//============================================================================//
//  LMGRPD.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class LMGRPD extends R6MachineGun
 abstract;

defaultproperties
{
	m_pBulletClass=Class'R6Weapons.ammo762mmM43'
	m_pEmptyShells=Class'R6SFX.R6Shell762mmm43'
	m_pMuzzleFlash=Class'R6SFX.R6MuzzleFlash762mm'
	m_stWeaponCaps=(bFullAuto=1,bLight=1)
	m_pFPHandsClass=Class'R61stWeapons.R61stHandsLMGRPD'
	m_pFPWeaponClass=Class'R61stWeapons.R61stLMGRPD'
	m_HUDTexture=Texture'R6HUD.HUDElements'
	m_vPositionOffset=(X=-9.5000000,Y=-1.5000000,Z=2.0000000)
	m_HUDTexturePos=(W=32.0000000,X=100.0000000,Y=96.0000000,Z=100.0000000)
	m_NameID="LMGRPD"
	StaticMesh=StaticMesh'R63rdWeapons_SM.MachineGuns.R63rdRPD'
}
