//=============================================================================
// LMGM60E4 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//============================================================================//
//  LMGM60E4.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class LMGM60E4 extends R6MachineGun
    abstract;

defaultproperties
{
	m_pBulletClass=Class'R6Weapons.ammo762mmNATO'
	m_pEmptyShells=Class'R6SFX.R6Shell762mmNATO'
	m_pMuzzleFlash=Class'R6SFX.R6MuzzleFlash762mm'
	m_stWeaponCaps=(bFullAuto=1,bLight=1)
	m_pFPHandsClass=Class'R61stWeapons.R61stHandsLMGM60E4'
	m_pFPWeaponClass=Class'R61stWeapons.R61stLMGM60E4'
	m_eGripType=1
	m_HUDTexture=Texture'R6HUD.HUDElements'
	m_PawnWaitAnimLow="StandM60Low_nt"
	m_PawnWaitAnimHigh="StandM60High_nt"
	m_PawnFiringAnim="StandFireM60"
	m_vPositionOffset=(X=-2.5000000,Y=-0.5000000,Z=-1.5000000)
	m_HUDTexturePos=(W=32.0000000,X=200.0000000,Y=96.0000000,Z=100.0000000)
	m_NameID="LMGM60E4"
	StaticMesh=StaticMesh'R63rdWeapons_SM.MachineGuns.R63rdM60E4'
}
