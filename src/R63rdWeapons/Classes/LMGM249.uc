//=============================================================================
// LMGM249 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//============================================================================//
//  LMGM249.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class LMGM249 extends R6MachineGun
    abstract;

defaultproperties
{
	m_pBulletClass=Class'R6Weapons.ammo556mmNATO'
	m_pEmptyShells=Class'R6SFX.R6Shell556mmNATO'
	m_pMuzzleFlash=Class'R6SFX.R6MuzzleFlash556mm'
	m_stWeaponCaps=(bFullAuto=1,bLight=1)
	m_pFPHandsClass=Class'R61stWeapons.R61stHandsGripLMG'
	m_pFPWeaponClass=Class'R61stWeapons.R61stLMGM249'
	m_HUDTexture=Texture'R6HUD.HUDElements'
	m_vPositionOffset=(X=-9.5000000,Y=-2.5000000,Z=2.0000000)
	m_HUDTexturePos=(W=32.0000000,X=300.0000000,Y=96.0000000,Z=100.0000000)
	m_NameID="LMGM249"
	StaticMesh=StaticMesh'R63rdWeapons_SM.MachineGuns.R63rdM249'
}
