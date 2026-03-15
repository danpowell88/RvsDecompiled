//=============================================================================
// R6FlashBangGadget - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6FlashBangGadget.uc 
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//=============================================================================
class R6FlashBangGadget extends R6GrenadeWeapon;

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
			R6PlayerController(Pawn(Owner).Controller).m_TeamManager.m_MultiCommonVoicesMgr.PlayMultiCommonVoices(R6Pawn(Owner), 1);
		}
	}
	super.ServerSetGrenade(eGrenade);
	return;
}

defaultproperties
{
	m_pBulletClass=Class'R6Weapons.R6FlashBang'
	m_pFPWeaponClass=Class'R61stWeapons.R61stGrenadeFlashBang'
	m_EquipSnd=Sound'Foley_SmokeGrenade.Play_Smoke_Equip'
	m_UnEquipSnd=Sound'Foley_SmokeGrenade.Play_Smoke_Unequip'
	m_SingleFireStereoSnd=Sound'Grenade_FlashBang.Play_FlashBang_Expl'
	m_HUDTexture=Texture'R6HUD.HUDElements'
	m_HUDTexturePos=(W=32.0000000,Y=386.0000000,Z=100.0000000)
	m_NameID="FlashBangGadget"
}
