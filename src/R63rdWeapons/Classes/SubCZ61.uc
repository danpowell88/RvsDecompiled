//=============================================================================
// SubCZ61 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//============================================================================//
//  SubCZ61.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class SubCZ61 extends R6SubMachineGun
    abstract;

defaultproperties
{
	m_pBulletClass=Class'R6Weapons.ammo765mmAuto'
	m_pEmptyShells=Class'R6SFX.R6Shell765mmAuto'
	m_pMuzzleFlash=Class'R6SFX.R6MuzzleFlashSub'
	m_stWeaponCaps=(bSingle=1,bFullAuto=1,bCMag=1,bSilencer=1,bLight=1)
	m_pFPHandsClass=Class'R61stWeapons.R61stHandsSubCZ61'
	m_pFPWeaponClass=Class'R61stWeapons.R61stSubCZ61'
	m_eGripType=4
	m_bUseMicroAnim=true
	m_HUDTexture=Texture'R6HUD.HUDElements'
	m_PawnWaitAnimLow="StandP90Low_nt"
	m_PawnWaitAnimHigh="StandP90High_nt"
	m_PawnWaitAnimProne="ProneP90_nt"
	m_PawnFiringAnim="StandFireP90"
	m_PawnFiringAnimProne="ProneFireP90"
	m_vPositionOffset=(X=-2.5000000,Y=-4.5000000,Z=6.5000000)
	m_HUDTexturePos=(W=32.0000000,X=400.0000000,Y=320.0000000,Z=100.0000000)
	m_NameID="SubCZ61"
	StaticMesh=StaticMesh'R63rdWeapons_SM.SubGuns.R63rdSubCZ61'
}
