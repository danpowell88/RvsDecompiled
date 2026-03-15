//=============================================================================
// R6SquadDeathmatch - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6SquadDeathmatch.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//=============================================================================
class R6SquadDeathmatch extends R6AdversarialTeamGame
    config
    hidecategories(Movement,Collision,Lighting,LightColor,Karma,Force);

var int m_iNextPlayerTeamID;

//------------------------------------------------------------------
// InitObjectives
//	
//------------------------------------------------------------------
function InitObjectives()
{
	m_iNextPlayerTeamID = 2;
	Level.m_bUseDefaultMoralityRules = false;
	super.InitObjectives();
	return;
}

//------------------------------------------------------------------
// GetNbOfRainbowAIToSpawn
//	
//------------------------------------------------------------------
function int GetNbOfRainbowAIToSpawn(PlayerController aController)
{
	// End:0x27
	if((int(R6PlayerController(aController).m_TeamSelection) == int(2)))
	{
		return m_iNbOfRainbowAIToSpawn;		
	}
	else
	{
		return 0;
	}
	return;
}

//------------------------------------------------------------------
// ResetPlayerTeam
//	set pawn's m_iTeam 
//------------------------------------------------------------------
function ResetPlayerTeam(Controller aPlayer)
{
	local R6Pawn aPawn;

	super.ResetPlayerTeam(aPlayer);
	aPawn = R6Pawn(aPlayer.Pawn);
	aPawn.PlayerReplicationInfo.TeamID = m_iNextPlayerTeamID;
	aPawn.m_iTeam = m_iNextPlayerTeamID;
	(m_iNextPlayerTeamID++);
	R6PlayerController(aPlayer).m_TeamManager.SetMemberTeamID(aPawn.m_iTeam);
	return;
}

//------------------------------------------------------------------
// SetPawnTeamFriendlies
//	
//------------------------------------------------------------------
function SetPawnTeamFriendlies(Pawn aPawn)
{
	aPawn.m_iFriendlyTeams = GetTeamNumBit(aPawn.m_iTeam);
	aPawn.m_iEnemyTeams = (~aPawn.m_iFriendlyTeams);
	return;
}

//------------------------------------------------------------------
// EndGame
//	
//------------------------------------------------------------------
function EndGame(PlayerReplicationInfo Winner, string Reason)
{
	local R6GameReplicationInfo gameRepInfo;

	// End:0x0B
	if(m_bGameOver)
	{
		return;
	}
	gameRepInfo = R6GameReplicationInfo(GameReplicationInfo);
	BroadcastGameMsg("", "", "GameOver", none, int(GetGameMsgLifeTime()));
	// End:0xBC
	if(m_objDeathmatch.m_bCompleted)
	{
		// End:0x78
		if(bShowLog)
		{
			Log("** Game : the pilot was extracted");
		}
		BroadcastGameMsg("", m_objDeathmatch.m_winnerCtrl.PlayerReplicationInfo.PlayerName, "HasWonTheRound", none, int(GetGameMsgLifeTime()));		
	}
	else
	{
		// End:0xDE
		if(bShowLog)
		{
			Log("** Game : it's a draw");
		}
		BroadcastGameMsg("", "", "RoundIsADraw", none, int(GetGameMsgLifeTime()));
	}
	super.EndGame(Winner, Reason);
	return;
}

auto state InBetweenRoundMenu
{
	function EndState()
	{
		local int iNbOfPlayer;
		local Controller P;

		P = Level.ControllerList;
		J0x14:

		// End:0x87 [Loop If]
		if((P != none))
		{
			// End:0x70
			if(((P.IsA('PlayerController') && (P.PlayerReplicationInfo != none)) && (int(R6PlayerController(P).m_TeamSelection) == int(2))))
			{
				(++iNbOfPlayer);
			}
			P = P.nextController;
			// [Loop Continue]
			goto J0x14;
		}
		switch(iNbOfPlayer)
		{
			// End:0x9C
			case 0:
				m_iNbOfRainbowAIToSpawn = 0;
				// End:0x141
				break;
			// End:0xAB
			case 1:
				m_iNbOfRainbowAIToSpawn = 4;
				// End:0x141
				break;
			// End:0xBB
			case 2:
				m_iNbOfRainbowAIToSpawn = 3;
				// End:0x141
				break;
			// End:0xCB
			case 3:
				m_iNbOfRainbowAIToSpawn = 3;
				// End:0x141
				break;
			// End:0xDB
			case 4:
				m_iNbOfRainbowAIToSpawn = 3;
				// End:0x141
				break;
			// End:0xEB
			case 5:
				m_iNbOfRainbowAIToSpawn = 2;
				// End:0x141
				break;
			// End:0xFB
			case 6:
				m_iNbOfRainbowAIToSpawn = 2;
				// End:0x141
				break;
			// End:0x10A
			case 7:
				m_iNbOfRainbowAIToSpawn = 1;
				// End:0x141
				break;
			// End:0x119
			case 8:
				m_iNbOfRainbowAIToSpawn = 1;
				// End:0x141
				break;
			// End:0x128
			case 9:
				m_iNbOfRainbowAIToSpawn = 1;
				// End:0x141
				break;
			// End:0x137
			case 10:
				m_iNbOfRainbowAIToSpawn = 1;
				// End:0x141
				break;
			// End:0xFFFF
			default:
				m_iNbOfRainbowAIToSpawn = 0;
				break;
		}
		// End:0x192
		if(bShowLog)
		{
			Log(((("NotifyMatchStart nb of player: " $ string(iNbOfPlayer)) $ " AI in a team: ") $ string(m_iNbOfRainbowAIToSpawn)));
		}
		super.EndState();
		return;
	}
	stop;
}

defaultproperties
{
	m_szGameTypeFlag="RGM_SquadDeathmatch"
}
