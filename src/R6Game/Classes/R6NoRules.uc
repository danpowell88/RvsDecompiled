//=============================================================================
// R6NoRules - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6NoRules.uc : (add small description)
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/05/24 * Created by Aristomenis Kolokathis 
//                      No rules for MultiPlayer
//=============================================================================
class R6NoRules extends R6MultiPlayerGameInfo
    config
    hidecategories(Movement,Collision,Lighting,LightColor,Karma,Force);

function PlayerReadySelected(PlayerController _Controller)
{
	return;
	return;
}

function LetPlayerPopIn(Controller aPlayer)
{
	Log(("LetPlayerPopIn " $ string(aPlayer)));
	R6PlayerController(aPlayer).m_TeamSelection = 2;
	ResetPlayerTeam(aPlayer);
	return;
}

function ResetPlayerTeam(Controller aPlayer)
{
	// End:0x4A
	if((R6Pawn(aPlayer.Pawn) == none))
	{
		RestartPlayer(aPlayer);
		aPlayer.Pawn.PlayerReplicationInfo = aPlayer.PlayerReplicationInfo;
	}
	AcceptInventory(aPlayer.Pawn);
	R6AbstractGameInfo(Level.Game).SetPawnTeamFriendlies(aPlayer.Pawn);
	return;
}

// NEW IN 1.60
event PlayerController Login(string Portal, string Options, out string Error)
{
	// End:0x10
	if(m_bGameStarted)
	{
		GotoState('InBetweenRoundMenu');
	}
	return super.Login(Portal, Options, Error);
	return;
}

auto state InMPWaitForPlayersMenu
{
	function BeginState()
	{
		m_bGameStarted = false;
		return;
	}

	function Tick(float DeltaTime)
	{
		local Controller P;

		// End:0x16
		if((Level.ControllerList == none))
		{
			return;
		}
		P = Level.ControllerList;
		J0x2A:

		// End:0xD7 [Loop If]
		if((P != none))
		{
			// End:0xC0
			if((((P.IsA('PlayerController') && (P.PlayerReplicationInfo != none)) && (int(R6PlayerController(P).m_TeamSelection) != int(0))) && (int(R6PlayerController(P).m_TeamSelection) != int(4))))
			{
				GameReplicationInfo.SetServerState(GameReplicationInfo.1);
				GotoState('InBetweenRoundMenu');
			}
			P = P.nextController;
			// [Loop Continue]
			goto J0x2A;
		}
		return;
	}
	stop;
}

auto state InBetweenRoundMenu
{
	function Tick(float DeltaTime)
	{
		local Controller P;

		P = Level.ControllerList;
		J0x14:

		// End:0x92 [Loop If]
		if((P != none))
		{
			// End:0x7B
			if(((P.Pawn == none) && (!R6PlayerController(P).IsPlayerPassiveSpectator())))
			{
				LetPlayerPopIn(P);
				m_bGameStarted = true;
				GameReplicationInfo.SetServerState(GameReplicationInfo.3);
			}
			P = P.nextController;
			// [Loop Continue]
			goto J0x14;
		}
		return;
	}
	stop;
}

