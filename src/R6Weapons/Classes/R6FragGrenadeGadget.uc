//=============================================================================
// R6FragGrenadeGadget - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6FragGrenadeGadget.uc 
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//=============================================================================
class R6FragGrenadeGadget extends R6GrenadeWeapon;

function ServerSetGrenade(Pawn.eGrenadeThrow eGrenade)
{
	local Pawn PawnTmp;

	// End:0xF7
	if((Level.IsGameTypeTeamAdversarial(Level.Game.m_szGameTypeFlag) || Level.IsGameTypeCooperative(Level.Game.m_szGameTypeFlag)))
	{
		PawnTmp = Pawn(Owner);
		// End:0xF7
		if((((int(eGrenade) != int(3)) && (int(eGrenade) != int(0))) && ((int(PawnTmp.m_eHealth) == int(0)) || (int(PawnTmp.m_eHealth) == int(1)))))
		{
			R6PlayerController(PawnTmp.Controller).m_TeamManager.m_MultiCommonVoicesMgr.PlayMultiCommonVoices(R6Pawn(Owner), 0);
		}
	}
	super.ServerSetGrenade(eGrenade);
	return;
}

defaultproperties
{
	m_pBulletClass=Class'R6Weapons.R6FragGrenade'
	m_pFPWeaponClass=Class'R61stWeapons.R61stGrenadeHE'
	m_EquipSnd=Sound'Foley_FragGrenade.Play_Frag_Equip'
	m_UnEquipSnd=Sound'Foley_FragGrenade.Play_Frag_Unequip'
	m_SingleFireStereoSnd=Sound'Grenade_Frag.Play_random_Frag_Expl_Metal'
	m_HUDTexture=Texture'R6HUD.HUDElements'
	m_HUDTexturePos=(W=32.0000000,X=400.0000000,Y=352.0000000,Z=100.0000000)
	m_NameID="FragGrenadeGadget"
}
