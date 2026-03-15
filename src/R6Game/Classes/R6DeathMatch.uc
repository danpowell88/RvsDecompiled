//=============================================================================
// R6DeathMatch - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6DeathMatch.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/11/27 * Created by Aristomenis Kolokathis  Adversarial Mode
//=============================================================================
class R6DeathMatch extends R6AdversarialTeamGame
    config
    hidecategories(Movement,Collision,Lighting,LightColor,Karma,Force);

var int m_iNextPlayerTeamID;

function int GetRainbowTeamColourIndex(int eTeamName)
{
	return 1;
	return;
}

function BroadcastTeam(Actor Sender, coerce string Msg, optional name type)
{
	return;
}

//------------------------------------------------------------------
// InitObjectives
//	
//------------------------------------------------------------------
function InitObjectives()
{
	m_iNextPlayerTeamID = (4 + 1);
	m_missionMgr.m_bOnSuccessAllObjectivesAreCompleted = false;
	Level.m_bUseDefaultMoralityRules = false;
	super.InitObjectives();
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
	// End:0xD3
	if((m_objDeathmatch.m_bCompleted && (m_bCompilingStats == true)))
	{
		// End:0x6D
		if(bShowLog)
		{
			Log("** Game : someone won the deathmatch ");
		}
		(m_objDeathmatch.m_winnerCtrl.PlayerReplicationInfo.m_iRoundsWon++);
		BroadcastGameMsg("", m_objDeathmatch.m_winnerCtrl.PlayerReplicationInfo.PlayerName, "HasWonTheRound", none, int(GetGameMsgLifeTime()));		
	}
	else
	{
		BroadcastGameMsg("", "", "RoundIsADraw", none, int(GetGameMsgLifeTime()));
		// End:0x116
		if(bShowLog)
		{
			Log("** Game : it's a draw");
		}
	}
	super.EndGame(Winner, Reason);
	return;
}

//------------------------------------------------------------------
// GetSpawnPointNum
//	
//------------------------------------------------------------------
function int GetSpawnPointNum(string Options)
{
	return 0;
	return;
}

//------------------------------------------------------------------
// ResetPlayerTeam
//	
//------------------------------------------------------------------
function ResetPlayerTeam(Controller aPlayer)
{
	super.ResetPlayerTeam(aPlayer);
	aPlayer.Pawn.PlayerReplicationInfo.TeamID = m_iNextPlayerTeamID;
	R6Pawn(aPlayer.Pawn).m_iTeam = m_iNextPlayerTeamID;
	(m_iNextPlayerTeamID++);
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

defaultproperties
{
	m_iUbiComGameMode=1
	m_bIsRadarAllowed=false
	m_bIsWritableMapAllowed=false
	m_szGameTypeFlag="RGM_DeathmatchMode"
}
