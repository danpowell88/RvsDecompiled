//=============================================================================
// SubMP5KPDW - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//============================================================================//
//  SubMP5KPDW.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class SubMP5KPDW extends R6SubMachineGun
    abstract;

defaultproperties
{
	m_pBulletClass=Class'R6Weapons.ammo9mmParabellum'
	m_pEmptyShells=Class'R6SFX.R6Shell9mmParabellum'
	m_pMuzzleFlash=Class'R6SFX.R6MuzzleFlashSub'
	m_stWeaponCaps=(bSingle=1,bThreeRound=1,bFullAuto=1,bCMag=1,bSilencer=1,bLight=1,bMiniScope=1)
	m_pFPHandsClass=Class'R61stWeapons.R61stHandsSubMp5KPDW'
	m_pFPWeaponClass=Class'R61stWeapons.R61stSubMp5KPDW'
	m_eGripType=1
	m_HUDTexture=Texture'R6HUD.HUDElements'
	m_PawnWaitAnimLow="StandAugLow_nt"
	m_PawnWaitAnimHigh="StandAugHigh_nt"
	m_PawnWaitAnimProne="ProneAug_nt"
	m_PawnFiringAnim="StandFireAug"
	m_PawnFiringAnimProne="ProneFireAug"
	m_PawnReloadAnim="StandReloadAug"
	m_PawnReloadAnimTactical="StandTacReloadAug"
	m_PawnReloadAnimProne="ProneReloadAug"
	m_PawnReloadAnimProneTactical="ProneTacReloadAug"
	m_vPositionOffset=(X=-5.0000000,Y=-4.5000000,Z=4.0000000)
	m_HUDTexturePos=(W=32.0000000,X=400.0000000,Y=288.0000000,Z=100.0000000)
	m_NameID="SubMP5KPDW"
	StaticMesh=StaticMesh'R63rdWeapons_SM.SubGuns.R63rdMp5KPDW'
}
