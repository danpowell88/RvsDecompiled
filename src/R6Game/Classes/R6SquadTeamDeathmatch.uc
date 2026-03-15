//=============================================================================
// R6SquadTeamDeathmatch - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6SquadTeamDeathmatch.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//=============================================================================
class R6SquadTeamDeathmatch extends R6AdversarialTeamGame
    config
    hidecategories(Movement,Collision,Lighting,LightColor,Karma,Force);

var int m_iNextPlayerTeamID;

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
// GetNbOfRainbowAIToSpawnBaseOnTeamNb
//	
//------------------------------------------------------------------
function int GetNbOfRainbowAIToSpawnBaseOnTeamNb(int iTeamNb)
{
	switch(iTeamNb)
	{
		// End:0x0D
		case 0:
			return 0;
		// End:0x14
		case 1:
			return 3;
		// End:0x1C
		case 2:
			return 3;
		// End:0x24
		case 3:
			return 3;
		// End:0x2C
		case 4:
			return 2;
		// End:0xFFFF
		default:
			return 1;
			break;
	}
	return;
}

//------------------------------------------------------------------
// GetNbOfTeamMemberToSpawn
//	spawn the nb of ai in team. if the nb of player in each team
//  is not equal, adjust the nb of ai for the other team
//------------------------------------------------------------------
function int GetNbOfRainbowAIToSpawn(PlayerController aController)
{
	local int iAlphaNb, iBravoNb, iHumanNb, iAdjustedMax, iNbAssigned, iNbPawnAssignedForThisController,
		iAiMax;

	local Object.ePlayerTeamSelection eTeamToAdjust;
	local Controller P;

	// End:0x40
	if(((int(R6PlayerController(aController).m_TeamSelection) != int(2)) && (int(R6PlayerController(aController).m_TeamSelection) != int(3))))
	{
		return 0;
	}
	GetNbHumanPlayerInTeam(iAlphaNb, iBravoNb);
	// End:0x82
	if((int(R6PlayerController(aController).m_TeamSelection) == int(2)))
	{
		iAiMax = GetNbOfRainbowAIToSpawnBaseOnTeamNb(iAlphaNb);		
	}
	else
	{
		iAiMax = GetNbOfRainbowAIToSpawnBaseOnTeamNb(iBravoNb);
	}
	// End:0xC2
	if((((iAlphaNb == iBravoNb) || (iAlphaNb == 0)) || (iBravoNb == 0)))
	{
		return iAiMax;
	}
	// End:0xF8
	if((int(R6PlayerController(aController).m_TeamSelection) == int(2)))
	{
		// End:0xF5
		if((iAlphaNb < iBravoNb))
		{
			return iAiMax;
		}		
	}
	else
	{
		// End:0x10D
		if((iAlphaNb > iBravoNb))
		{
			return iAiMax;
		}
	}
	// End:0x14A
	if((iAlphaNb > iBravoNb))
	{
		iAdjustedMax = (GetNbOfRainbowAIToSpawnBaseOnTeamNb(iBravoNb) * iBravoNb);
		eTeamToAdjust = 2;
		iHumanNb = iAlphaNb;		
	}
	else
	{
		iAdjustedMax = (GetNbOfRainbowAIToSpawnBaseOnTeamNb(iAlphaNb) * iAlphaNb);
		eTeamToAdjust = 3;
		iHumanNb = iBravoNb;
	}
	(iAdjustedMax -= iHumanNb);
	J0x181:

	// End:0x223 [Loop If]
	if((iAdjustedMax > 0))
	{
		P = Level.ControllerList;
		J0x1A0:

		// End:0x220 [Loop If]
		if((P != none))
		{
			// End:0x1FB
			if(((R6PlayerController(P) != none) && (int(R6PlayerController(P).m_TeamSelection) == int(eTeamToAdjust))))
			{
				// End:0x1F4
				if((aController == P))
				{
					(++iNbPawnAssignedForThisController);
				}
				(iAdjustedMax--);
			}
			// End:0x209
			if((iAdjustedMax == 0))
			{
				// [Explicit Break]
				goto J0x220;
			}
			P = P.nextController;
			// [Loop Continue]
			goto J0x1A0;
		}
		J0x220:

		// [Loop Continue]
		goto J0x181;
	}
	(iNbPawnAssignedForThisController++);
	return iNbPawnAssignedForThisController;
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
	m_szGameTypeFlag="RGM_SquadTeamDeathmatch"
}
