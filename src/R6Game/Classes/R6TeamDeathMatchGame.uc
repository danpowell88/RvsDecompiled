//=============================================================================
// R6TeamDeathMatchGame - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6TeamDeathMatchGame.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/12/05 * Created by Aristomenis Kolokathis
//=============================================================================
class R6TeamDeathMatchGame extends R6AdversarialTeamGame
    config
    hidecategories(Movement,Collision,Lighting,LightColor,Karma,Force);

//------------------------------------------------------------------
// InitObjectives
//	
//------------------------------------------------------------------
function InitObjectives()
{
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
	// End:0x115
	if(m_objDeathmatch.m_bCompleted)
	{
		// End:0xA2
		if((m_objDeathmatch.m_iWinningTeam == 2))
		{
			BroadcastGameMsg("", "", "GreenTeamWonRound", m_sndGreenTeamWonRound, int(GetGameMsgLifeTime()));
			BroadcastMissionObjMsg("", "", "GreenNeutralizedRed", none, int(GetGameMsgLifeTime()));
			AddTeamWonRound(c_iAlphaTeam);			
		}
		else
		{
			// End:0x112
			if((m_objDeathmatch.m_iWinningTeam == 3))
			{
				BroadcastGameMsg("", "", "RedTeamWonRound", m_sndRedTeamWonRound, int(GetGameMsgLifeTime()));
				BroadcastMissionObjMsg("", "", "RedNeutralizedGreen", none, int(GetGameMsgLifeTime()));
				AddTeamWonRound(c_iBravoTeam);
			}
		}		
	}
	else
	{
		// End:0x137
		if(bShowLog)
		{
			Log("** Game : it's a draw");
		}
		BroadcastGameMsg("", "", "RoundIsADraw", m_sndRoundIsADraw, int(GetGameMsgLifeTime()));
	}
	super.EndGame(Winner, Reason);
	return;
}

defaultproperties
{
	m_iUbiComGameMode=2
	m_szGameTypeFlag="RGM_TeamDeathmatchMode"
}
