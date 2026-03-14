//=============================================================================
// R6TearGasGrenadeGadget - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6TearGasGrenadeGadget.uc 
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//=============================================================================
class R6TearGasGrenadeGadget extends R6GrenadeWeapon;

function ServerSetGrenade(Pawn.eGrenadeThrow eGrenade)
{
	local Pawn PawnTmp;

	// End:0xFC
	if(__NFUN_132__(Level.IsGameTypeTeamAdversarial(Level.Game.m_szGameTypeFlag), Level.IsGameTypeCooperative(Level.Game.m_szGameTypeFlag)))
	{
		PawnTmp = Pawn(Owner);
		// End:0xFC
		if(__NFUN_130__(__NFUN_130__(__NFUN_155__(int(eGrenade), int(3)), __NFUN_155__(int(eGrenade), int(0))), __NFUN_132__(__NFUN_154__(int(PawnTmp.m_eHealth), int(0)), __NFUN_154__(int(PawnTmp.m_eHealth), int(1)))))
		{
			R6PlayerController(Pawn(Owner).Controller).m_TeamManager.m_MultiCommonVoicesMgr.PlayMultiCommonVoices(R6Pawn(Owner), 2);
		}
	}
	super.ServerSetGrenade(eGrenade);
	return;
}

defaultproperties
{
	m_pBulletClass=Class'R6Weapons.R6TearGasGrenade'
	m_pFPWeaponClass=Class'R61stWeapons.R61stGrenadeTearGas'
	m_EquipSnd=Sound'Foley_SmokeGrenade.Play_Smoke_Equip'
	m_UnEquipSnd=Sound'Foley_SmokeGrenade.Play_Smoke_Unequip'
	m_SingleFireStereoSnd=Sound'Grenade_Gas.Play_GasGrenade_Expl'
	m_HUDTexture=Texture'R6HUD.HUDElements'
	m_HUDTexturePos=(W=32.0000000,X=200.0000000,Y=352.0000000,Z=100.0000000)
	m_NameID="TearGasGrenadeGadget"
	StaticMesh=StaticMesh'R63rdWeapons_SM.Grenades.R63rdGrenadeTearGas'
}
