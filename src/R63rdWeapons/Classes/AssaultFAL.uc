//=============================================================================
// AssaultFAL - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//============================================================================//
//  AssaultFAL.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class AssaultFAL extends R6AssaultRifle
    abstract;

defaultproperties
{
	m_pBulletClass=Class'R6Weapons.ammo762mmNATO'
	m_pEmptyShells=Class'R6SFX.R6Shell762mmNATO'
	m_pMuzzleFlash=Class'R6SFX.R6MuzzleFlash762mm'
	m_stWeaponCaps=(bSingle=1,bFullAuto=1,bCMag=1,bSilencer=1,bLight=1,bMiniScope=1)
	m_pFPHandsClass=Class'R61stWeapons.R61stHandsAssaultFAL'
	m_pFPWeaponClass=Class'R61stWeapons.R61stAssaultFAL'
	m_HUDTexture=Texture'R6HUD.HUDElements'
	m_vPositionOffset=(X=8.5000000,Y=-1.5000000,Z=0.0000000)
	m_HUDTexturePos=(W=32.0000000,X=200.0000000,Y=64.0000000,Z=100.0000000)
	m_NameID="AssaultFAL"
	StaticMesh=StaticMesh'R63rdWeapons_SM.AssaultRifles.R63rdFAL'
}
