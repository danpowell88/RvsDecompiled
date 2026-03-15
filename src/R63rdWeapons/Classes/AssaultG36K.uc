//=============================================================================
// AssaultG36K - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//============================================================================//
//  AssaultG36K.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class AssaultG36K extends R6AssaultRifle
    abstract;

defaultproperties
{
	m_pBulletClass=Class'R6Weapons.ammo556mmNATO'
	m_pEmptyShells=Class'R6SFX.R6Shell556mmNATO'
	m_pMuzzleFlash=Class'R6SFX.R6MuzzleFlash556mm'
	m_stWeaponCaps=(bSingle=1,bThreeRound=1,bFullAuto=1,bCMag=1,bSilencer=1,bLight=1)
	m_szWithWeaponReticuleClass="WITHWEAPONDOT"
	m_pFPHandsClass=Class'R61stWeapons.R61stHandsAssaultG36K'
	m_pFPWeaponClass=Class'R61stWeapons.R61stAssaultG36K'
	m_fMaxZoom=2.5000000
	m_ScopeTexture=Texture'Inventory_t.Scope.ScopeBlurTex_TAR'
	m_HUDTexture=Texture'R6HUD.HUDElements'
	m_vPositionOffset=(X=9.5000000,Y=-0.5000000,Z=-3.5000000)
	m_HUDTexturePos=(W=32.0000000,X=400.0000000,Y=32.0000000,Z=100.0000000)
	m_NameID="AssaultG36K"
	StaticMesh=StaticMesh'R63rdWeapons_SM.AssaultRifles.R63rdG36K'
}
