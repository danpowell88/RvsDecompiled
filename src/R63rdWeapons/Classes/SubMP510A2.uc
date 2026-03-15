//=============================================================================
// SubMP510A2 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//============================================================================//
//  SubMP510A2.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class SubMP510A2 extends R6SubMachineGun
    abstract;

defaultproperties
{
	m_pBulletClass=Class'R6Weapons.ammo10mmAuto'
	m_pEmptyShells=Class'R6SFX.R6Shell10mmAuto'
	m_pMuzzleFlash=Class'R6SFX.R6MuzzleFlashSub'
	m_stWeaponCaps=(bSingle=1,bThreeRound=1,bFullAuto=1,bCMag=1,bSilencer=1,bLight=1,bMiniScope=1)
	m_pFPHandsClass=Class'R61stWeapons.R61stHandsGripMP5'
	m_pFPWeaponClass=Class'R61stWeapons.R61stSubMp510A2'
	m_HUDTexture=Texture'R6HUD.HUDElements'
	m_PawnWaitAnimLow="StandBullPupLow_nt"
	m_PawnWaitAnimHigh="StandBullPupHigh_nt"
	m_PawnWaitAnimProne="ProneBullPup_nt"
	m_PawnFiringAnim="StandFireBullPup"
	m_PawnFiringAnimProne="ProneFireBullPup"
	m_vPositionOffset=(X=-2.0000000,Y=-1.0000000,Z=0.5000000)
	m_HUDTexturePos=(W=32.0000000,X=143.0000000,Y=417.0000000,Z=100.0000000)
	m_NameID="SubMP510A2"
	StaticMesh=StaticMesh'R63rdWeapons_SM.SubGuns.R63rdMp5A4'
}
