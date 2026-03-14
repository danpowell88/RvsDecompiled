//=============================================================================
// SubMP5A4 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//============================================================================//
//  SubMP5A4.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class SubMP5A4 extends R6SubMachineGun
    abstract;

defaultproperties
{
	m_pBulletClass=Class'R6Weapons.ammo9mmParabellum'
	m_pEmptyShells=Class'R6SFX.R6Shell9mmParabellum'
	m_pMuzzleFlash=Class'R6SFX.R6MuzzleFlashSub'
	m_stWeaponCaps=(bSingle=1,bThreeRound=1,bFullAuto=1,bCMag=1,bSilencer=1,bLight=1,bMiniScope=1)
	m_pFPHandsClass=Class'R61stWeapons.R61stHandsGripMP5'
	m_pFPWeaponClass=Class'R61stWeapons.R61stSubMp5A4'
	m_HUDTexture=Texture'R6HUD.HUDElements'
	m_PawnWaitAnimLow="StandBullPupLow_nt"
	m_PawnWaitAnimHigh="StandBullPupHigh_nt"
	m_PawnWaitAnimProne="ProneBullPup_nt"
	m_PawnFiringAnim="StandFireBullPup"
	m_PawnFiringAnimProne="ProneFireBullPup"
	m_vPositionOffset=(X=-2.5000000,Y=-0.5000000,Z=0.5000000)
	m_HUDTexturePos=(W=32.0000000,Y=320.0000000,Z=100.0000000)
	m_NameID="SubMP5A4"
	StaticMesh=StaticMesh'R63rdWeapons_SM.SubGuns.R63rdMp5A4'
}
