//=============================================================================
// R6NoRules - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
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
	__NFUN_231__(__NFUN_112__("LetPlayerPopIn ", string(aPlayer)));
	R6PlayerController(aPlayer).m_TeamSelection = 2;
	ResetPlayerTeam(aPlayer);
	return;
}

function ResetPlayerTeam(Controller aPlayer)
{
	// End:0x4A
	if(__NFUN_114__(R6Pawn(aPlayer.Pawn), none))
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
		__NFUN_113__('InBetweenRoundMenu');
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
		if(__NFUN_114__(Level.ControllerList, none))
		{
			return;
		}
		P = Level.ControllerList;
		J0x2A:

		// End:0xD7 [Loop If]
		if(__NFUN_119__(P, none))
		{
			// End:0xC0
			if(__NFUN_130__(__NFUN_130__(__NFUN_130__(P.__NFUN_303__('PlayerController'), __NFUN_119__(P.PlayerReplicationInfo, none)), __NFUN_155__(int(R6PlayerController(P).m_TeamSelection), int(0))), __NFUN_155__(int(R6PlayerController(P).m_TeamSelection), int(4))))
			{
				GameReplicationInfo.SetServerState(GameReplicationInfo.1);
				__NFUN_113__('InBetweenRoundMenu');
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
		if(__NFUN_119__(P, none))
		{
			// End:0x7B
			if(__NFUN_130__(__NFUN_114__(P.Pawn, none), __NFUN_129__(R6PlayerController(P).IsPlayerPassiveSpectator())))
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

