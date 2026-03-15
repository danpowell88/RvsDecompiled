//=============================================================================
// R6SmokeGrenadeGadget - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6SmokeGrenadeGadget.uc 
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//=============================================================================
class R6SmokeGrenadeGadget extends R6GrenadeWeapon;

function ServerSetGrenade(Pawn.eGrenadeThrow eGrenade)
{
	local Pawn PawnTmp;

	// End:0xFC
	if((Level.IsGameTypeTeamAdversarial(Level.Game.m_szGameTypeFlag) || Level.IsGameTypeCooperative(Level.Game.m_szGameTypeFlag)))
	{
		PawnTmp = Pawn(Owner);
		// End:0xFC
		if((((int(eGrenade) != int(3)) && (int(eGrenade) != int(0))) && ((int(PawnTmp.m_eHealth) == int(0)) || (int(PawnTmp.m_eHealth) == int(1)))))
		{
			R6PlayerController(Pawn(Owner).Controller).m_TeamManager.m_MultiCommonVoicesMgr.PlayMultiCommonVoices(R6Pawn(Owner), 3);
		}
	}
	super.ServerSetGrenade(eGrenade);
	return;
}

defaultproperties
{
	m_pBulletClass=Class'R6Weapons.R6SmokeGrenade'
	m_pFPWeaponClass=Class'R61stWeapons.R61stGrenadeSmoke'
	m_EquipSnd=Sound'Foley_SmokeGrenade.Play_Smoke_Equip'
	m_UnEquipSnd=Sound'Foley_SmokeGrenade.Play_Smoke_Unequip'
	m_SingleFireStereoSnd=Sound'Grenade_Smoke.Play_SmokeGrenade_Expl'
	m_HUDTexture=Texture'R6HUD.HUDElements'
	m_HUDTexturePos=(W=32.0000000,X=200.0000000,Y=384.0000000,Z=100.0000000)
	m_NameID="SmokeGrenadeGadget"
}
