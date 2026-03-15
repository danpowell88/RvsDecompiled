//=============================================================================
// SubMicroUzi - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//============================================================================//
//  SubMicroUzi.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class SubMicroUzi extends R6SubMachineGun
    abstract;

defaultproperties
{
	m_pBulletClass=Class'R6Weapons.ammo9mmParabellum'
	m_pEmptyShells=Class'R6SFX.R6Shell9mmParabellum'
	m_pMuzzleFlash=Class'R6SFX.R6MuzzleFlashSub'
	m_stWeaponCaps=(bSingle=1,bFullAuto=1,bCMag=1,bSilencer=1,bLight=1)
	m_pFPHandsClass=Class'R61stWeapons.R61stHandsSubMicroUzi'
	m_pFPWeaponClass=Class'R61stWeapons.R61stSubMicroUzi'
	m_eGripType=6
	m_bUseMicroAnim=true
	m_HUDTexture=Texture'R6HUD.HUDElements'
	m_PawnWaitAnimLow="StandUZILow_nt"
	m_PawnWaitAnimHigh="StandUZIHigh_nt"
	m_PawnWaitAnimProne="ProneUZI_nt"
	m_PawnFiringAnim="StandFireUZI"
	m_PawnFiringAnimProne="ProneFireUZI"
	m_PawnReloadAnim="StandReloadHandGun"
	m_PawnReloadAnimTactical="StandReloadHandGun"
	m_PawnReloadAnimProne="ProneReloadHandGun"
	m_PawnReloadAnimProneTactical="ProneReloadHandGun"
	m_vPositionOffset=(X=-1.5000000,Y=-4.5000000,Z=2.5000000)
	m_HUDTexturePos=(W=32.0000000,X=100.0000000,Y=320.0000000,Z=100.0000000)
	m_NameID="SubMicroUzi"
	StaticMesh=StaticMesh'R63rdWeapons_SM.SubGuns.R63rdSubMicroUzi'
}
