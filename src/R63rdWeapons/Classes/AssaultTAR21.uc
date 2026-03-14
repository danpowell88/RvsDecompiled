//=============================================================================
// AssaultTAR21 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//============================================================================//
//  AssaultTAR21.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class AssaultTAR21 extends R6AssaultRifle
 abstract;

defaultproperties
{
	m_pBulletClass=Class'R6Weapons.ammo556mmNATO'
	m_pEmptyShells=Class'R6SFX.R6Shell556mmNATO'
	m_pMuzzleFlash=Class'R6SFX.R6MuzzleFlash556mm'
	m_stWeaponCaps=(bSingle=1,bFullAuto=1,bCMag=1,bSilencer=1,bLight=1,bMiniScope=1)
	m_pFPHandsClass=Class'R61stWeapons.R61stHandsAssaultTAR21'
	m_pFPWeaponClass=Class'R61stWeapons.R61stAssaultTAR21'
	m_eGripType=2
	m_WithScopeSM=StaticMesh'R63rdWeapons_SM.AssaultRifles.R63rdTAR21ForScope'
	m_HUDTexture=Texture'R6HUD.HUDElements'
	m_PawnWaitAnimLow="StandBullPupLow_nt"
	m_PawnWaitAnimHigh="StandBullPupHigh_nt"
	m_PawnWaitAnimProne="ProneBullPup_nt"
	m_PawnFiringAnim="StandFireBullPup"
	m_PawnFiringAnimProne="ProneFireBullPup"
	m_PawnReloadAnim="StandReloadAug"
	m_PawnReloadAnimTactical="StandTacReloadAug"
	m_PawnReloadAnimProne="ProneReloadAug"
	m_PawnReloadAnimProneTactical="ProneTacReloadAug"
	m_vPositionOffset=(X=-1.0000000,Y=-1.0000000,Z=-4.0000000)
	m_HUDTexturePos=(W=32.0000000,X=100.0000000,Z=100.0000000)
	m_NameID="AssaultTAR21"
	StaticMesh=StaticMesh'R63rdWeapons_SM.AssaultRifles.R63rdTAR21'
}
