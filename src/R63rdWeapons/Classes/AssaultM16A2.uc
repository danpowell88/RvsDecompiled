//=============================================================================
// AssaultM16A2 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//============================================================================//
//  AssaultM16A2.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class AssaultM16A2 extends R6AssaultRifle
    abstract;

defaultproperties
{
	m_pBulletClass=Class'R6Weapons.ammo556mmNATO'
	m_pEmptyShells=Class'R6SFX.R6Shell556mmNATO'
	m_pMuzzleFlash=Class'R6SFX.R6MuzzleFlash556mm'
	m_stWeaponCaps=(bSingle=1,bThreeRound=1,bCMag=1,bSilencer=1,bLight=1,bMiniScope=1)
	m_pFPHandsClass=Class'R61stWeapons.R61stHandsAssaultM16A2'
	m_pFPWeaponClass=Class'R61stWeapons.R61stAssaultM16A2'
	m_HUDTexture=Texture'R6HUD.HUDElements'
	m_vPositionOffset=(X=1.0000000,Y=-1.5000000,Z=-1.0000000)
	m_HUDTexturePos=(W=32.0000000,X=400.0000000,Z=100.0000000)
	m_NameID="AssaultM16A2"
	StaticMesh=StaticMesh'R63rdWeapons_SM.AssaultRifles.R63rdM16A2'
}
