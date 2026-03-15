//=============================================================================
// AssaultAUG - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//============================================================================//
//  AssaultAUG.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class AssaultAUG extends R6AssaultRifle
    abstract;

defaultproperties
{
	m_pBulletClass=Class'R6Weapons.ammo556mmNATO'
	m_pEmptyShells=Class'R6SFX.R6Shell556mmNATO'
	m_pMuzzleFlash=Class'R6SFX.R6MuzzleFlash556mm'
	m_stWeaponCaps=(bSingle=1,bFullAuto=1,bCMag=1,bSilencer=1,bLight=1)
	m_pFPHandsClass=Class'R61stWeapons.R61stHandsGripAUG'
	m_pFPWeaponClass=Class'R61stWeapons.R61stAssaultAUG'
	m_eGripType=1
	m_fMaxZoom=2.5000000
	m_ScopeTexture=Texture'Inventory_t.Scope.ScopeBlurTex_Aug'
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
	m_vPositionOffset=(X=-2.5000000,Y=-3.5000000,Z=4.5000000)
	m_HUDTexturePos=(W=32.0000000,X=300.0000000,Y=64.0000000,Z=100.0000000)
	m_NameID="AssaultAUG"
	StaticMesh=StaticMesh'R63rdWeapons_SM.AssaultRifles.R63rdAUG'
}
