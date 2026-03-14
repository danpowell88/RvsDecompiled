//=============================================================================
// R6HostageRescueAdvGame - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6HostageRescueAdvGame.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/11/22 * Created by Aristomenis Kolokathis
//=============================================================================
class R6HostageRescueAdvGame extends R6AdversarialTeamGame
    config
    hidecategories(Movement,Collision,Lighting,LightColor,Karma,Force);

var int m_iIfDeadHostageMinNbToRescue;
var R6MObjRescueHostage m_objRescueHostage;
var R6MObjAcceptableHostageLossesByRainbow m_objHostageLossesByAlpha;
var R6MObjAcceptableHostageLossesByRainbow m_objHostageLossesByBravo;

//------------------------------------------------------------------
// InitObjectives
//	
//------------------------------------------------------------------
function InitObjectives()
{
	local R6Hostage hostage;
	local int iLength, iTotalHostage;

	// End:0x43
	foreach __NFUN_313__(Class'R6Engine.R6Hostage', hostage)
	{
		hostage.m_controller.m_bForceToStayHere = true;
		hostage.m_ePersonality = 0;
		__NFUN_165__(iTotalHostage);		
	}	
	// End:0x9B
	if(__NFUN_130__(__NFUN_154__(iTotalHostage, 0), m_missionMgr.m_bEnableCheckForErrors))
	{
		__NFUN_231__(__NFUN_112__("WARNING: there is no hostage in the game type: ", string(self)));
	}
	m_iIfDeadHostageMinNbToRescue = __NFUN_251__(iTotalHostage, 0, 2);
	m_objRescueHostage = new (none) Class'R6Game.R6MObjRescueHostage';
	m_objRescueHostage.m_szDescriptionInMenu = m_objRescueHostage.GetDescriptionBasedOnNbOfHostages(Level);
	iLength = m_missionMgr.m_aMissionObjectives.Length;
	m_missionMgr.m_aMissionObjectives[iLength] = m_objRescueHostage;
	__NFUN_165__(iLength);
	m_objHostageLossesByAlpha = new (none) Class'R6Game.R6MObjAcceptableHostageLossesByRainbow';
	m_missionMgr.m_aMissionObjectives[iLength] = m_objHostageLossesByAlpha;
	__NFUN_165__(iLength);
	m_objHostageLossesByBravo = new (none) Class'R6Game.R6MObjAcceptableHostageLossesByRainbow';
	m_missionMgr.m_aMissionObjectives[iLength] = m_objHostageLossesByBravo;
	__NFUN_165__(iLength);
	m_objRescueHostage.m_iRescuePercentage = 0;
	m_objRescueHostage.m_bRescueAllRemainingHostage = true;
	m_objRescueHostage.m_bIfFailedMissionIsAborted = true;
	m_objRescueHostage.m_bIfCompletedMissionIsSuccessfull = true;
	m_objRescueHostage.m_bCheckPawnKilled = true;
	InitObjHostageLossesByTeamID(m_objHostageLossesByAlpha, 2, 100);
	InitObjHostageLossesByTeamID(m_objHostageLossesByBravo, 3, 100);
	m_missionMgr.m_bOnSuccessAllObjectivesAreCompleted = false;
	Level.m_bUseDefaultMoralityRules = false;
	super.InitObjectives();
	return;
}

//------------------------------------------------------------------
// InitObjHostageLossesByTeamID
//	
//------------------------------------------------------------------
function InitObjHostageLossesByTeamID(R6MObjAcceptableHostageLossesByRainbow obj, int iTeamId, int iAcceptableLost)
{
	local string szTeamName;

	obj.m_iKillerTeamID = iTeamId;
	obj.m_bMoralityObjective = false;
	obj.m_bIfFailedMissionIsAborted = true;
	obj.m_iAcceptableLost = iAcceptableLost;
	obj.m_bVisibleInMenu = false;
	// End:0x77
	if(__NFUN_154__(iTeamId, 2))
	{
		szTeamName = "Alpha";		
	}
	else
	{
		// End:0x93
		if(__NFUN_154__(iTeamId, 3))
		{
			szTeamName = "Bravo";			
		}
		else
		{
			szTeamName = "Unknow";
		}
	}
	obj.m_szDescription = __NFUN_112__("HostageLossesByTeamID by ", szTeamName);
	obj.m_szDescriptionInMenu = "AvoidHostageCasualities";
	return;
}

//------------------------------------------------------------------
// PawnKilled
//	
//------------------------------------------------------------------
function PawnKilled(Pawn killedPawn)
{
	// End:0x0B
	if(m_bGameOver)
	{
		return;
	}
	super(R6GameInfo).PawnKilled(killedPawn);
	EnteredExtractionZone(killedPawn);
	return;
}

//------------------------------------------------------------------
// EnteredExtractionZone
//	
//------------------------------------------------------------------
function EnteredExtractionZone(Actor anActor)
{
	local int i, iTotalRescued, iTotalAlive, iTotalHostage;
	local bool bSendMsg;
	local R6Pawn aPawn;
	local R6Hostage hostage;

	// End:0x0B
	if(m_bGameOver)
	{
		return;
	}
	aPawn = R6Pawn(anActor);
	// End:0x43
	if(__NFUN_130__(__NFUN_114__(aPawn, none), __NFUN_155__(int(aPawn.m_ePawnType), int(3))))
	{
		return;
	}
	// End:0xE2
	foreach __NFUN_313__(Class'R6Engine.R6Hostage', hostage)
	{
		// End:0xA8
		if(__NFUN_130__(__NFUN_130__(hostage.m_bExtracted, hostage.IsAlive()), __NFUN_129__(hostage.m_bFeedbackExtracted)))
		{
			hostage.m_bFeedbackExtracted = true;
			bSendMsg = true;
		}
		// End:0xDA
		if(hostage.IsAlive())
		{
			__NFUN_163__(iTotalAlive);
			// End:0xDA
			if(hostage.m_bExtracted)
			{
				__NFUN_163__(iTotalRescued);
			}
		}
		__NFUN_165__(iTotalHostage);		
	}	
	// End:0x1CB
	if(bSendMsg)
	{
		// End:0x179
		if(__NFUN_132__(__NFUN_154__(iTotalHostage, iTotalRescued), __NFUN_130__(__NFUN_155__(iTotalAlive, iTotalHostage), __NFUN_153__(iTotalRescued, m_iIfDeadHostageMinNbToRescue))))
		{
			// End:0x150
			if(bShowLog)
			{
				__NFUN_231__(" ** Game: All hostage has been rescued");
			}
			BroadcastMissionObjMsg("", "", "AllHostagesHaveBeenRescued");			
		}
		else
		{
			// End:0x1AA
			if(bShowLog)
			{
				__NFUN_231__(" ** Game: A hostage has been rescued");
			}
			BroadcastMissionObjMsg("", "", "HostageHasBeenRescued");
		}
	}
	super(R6GameInfo).EnteredExtractionZone(aPawn);
	return;
}

//------------------------------------------------------------------
// EndGame
//	
//------------------------------------------------------------------
function EndGame(PlayerReplicationInfo Winner, string Reason)
{
	// End:0x0B
	if(m_bGameOver)
	{
		return;
	}
	// End:0x67
	if(m_objDeathmatch.m_bFailed)
	{
		// End:0x3F
		if(bShowLog)
		{
			__NFUN_231__("** Game : it's a draw");
		}
		BroadcastGameMsg("", "", "RoundIsADraw", m_sndRoundIsADraw, int(GetGameMsgLifeTime()));		
	}
	else
	{
		// End:0x12D
		if(m_objHostageLossesByAlpha.m_bFailed)
		{
			// End:0xC4
			if(bShowLog)
			{
				__NFUN_231__("** Game : bravo win, because alpha eleminated too much hostage");
			}
			BroadcastGameMsg("", "", "RedTeamWonRound", m_sndRedTeamWonRound, int(GetGameMsgLifeTime()));
			BroadcastMissionObjMsg("", "", "GreenEleminatedTooManyHostages", none, int(GetGameMsgLifeTime()));
			AddTeamWonRound(c_iBravoTeam);			
		}
		else
		{
			// End:0x1F3
			if(m_objHostageLossesByBravo.m_bFailed)
			{
				// End:0x18A
				if(bShowLog)
				{
					__NFUN_231__("** Game : alpha win, because bravo eleminated too much hostage");
				}
				BroadcastGameMsg("", "", "GreenTeamWonRound", m_sndGreenTeamWonRound, int(GetGameMsgLifeTime()));
				BroadcastMissionObjMsg("", "", "RedEleminatedTooManyHostages", none, int(GetGameMsgLifeTime()));
				AddTeamWonRound(c_iAlphaTeam);				
			}
			else
			{
				// End:0x24F
				if(m_objRescueHostage.m_bFailed)
				{
					// End:0x227
					if(bShowLog)
					{
						__NFUN_231__("** Game : it's a draw");
					}
					BroadcastGameMsg("", "", "RoundIsADraw", m_sndRoundIsADraw, int(GetGameMsgLifeTime()));					
				}
				else
				{
					// End:0x3A3
					if(m_objDeathmatch.m_bCompleted)
					{
						// End:0x303
						if(__NFUN_154__(m_objDeathmatch.m_iWinningTeam, 2))
						{
							// End:0x2A3
							if(bShowLog)
							{
								__NFUN_231__("** Game : alpha eleminated bravo");
							}
							BroadcastGameMsg("", "", "GreenTeamWonRound", m_sndGreenTeamWonRound, int(GetGameMsgLifeTime()));
							BroadcastMissionObjMsg("", "", "GreenNeutralizedRed", none, int(GetGameMsgLifeTime()));
							AddTeamWonRound(c_iAlphaTeam);							
						}
						else
						{
							// End:0x3A0
							if(__NFUN_154__(m_objDeathmatch.m_iWinningTeam, 3))
							{
								// End:0x345
								if(bShowLog)
								{
									__NFUN_231__("** Game : bravo eleminated alpha");
								}
								BroadcastGameMsg("", "", "RedTeamWonRound", m_sndRedTeamWonRound, int(GetGameMsgLifeTime()));
								BroadcastMissionObjMsg("", "", "RedNeutralizedGreen", none, int(GetGameMsgLifeTime()));
								AddTeamWonRound(c_iBravoTeam);
							}
						}						
					}
					else
					{
						// End:0x44C
						if(m_objRescueHostage.m_bCompleted)
						{
							// End:0x3E8
							if(bShowLog)
							{
								__NFUN_231__("** Game : alpha rescued enough hostage");
							}
							BroadcastGameMsg("", "", "GreenTeamWonRound", m_sndGreenTeamWonRound, int(GetGameMsgLifeTime()));
							BroadcastMissionObjMsg("", "", "HostagesHaveBeenRescued", none, int(GetGameMsgLifeTime()));
							AddTeamWonRound(c_iAlphaTeam);							
						}
						else
						{
							// End:0x484
							if(bShowLog)
							{
								__NFUN_231__("** Game : bravo kept the hostage from Alpha");
							}
							BroadcastGameMsg("", "", "RedTeamWonRound", m_sndRedTeamWonRound, int(GetGameMsgLifeTime()));
							BroadcastMissionObjMsg("", "", "HostagesWhereNotRescued", none, int(GetGameMsgLifeTime()));
							AddTeamWonRound(c_iBravoTeam);
						}
					}
				}
			}
		}
	}
	super.EndGame(Winner, Reason);
	return;
}

function SetPawnTeamFriendlies(Pawn aPawn)
{
	switch(aPawn.m_iTeam)
	{
		// End:0x55
		case 0:
			aPawn.m_iFriendlyTeams = 0;
			aPawn.m_iEnemyTeams = GetTeamNumBit(1);
			__NFUN_161__(aPawn.m_iEnemyTeams, GetTeamNumBit(3));
			// End:0x1C0
			break;
		// End:0xA1
		case 1:
			aPawn.m_iFriendlyTeams = GetTeamNumBit(1);
			aPawn.m_iEnemyTeams = GetTeamNumBit(2);
			__NFUN_161__(aPawn.m_iEnemyTeams, GetTeamNumBit(3));
			// End:0x1C0
			break;
		// End:0xEE
		case 2:
			aPawn.m_iFriendlyTeams = GetTeamNumBit(2);
			aPawn.m_iEnemyTeams = GetTeamNumBit(3);
			__NFUN_161__(aPawn.m_iEnemyTeams, GetTeamNumBit(1));
			// End:0x1C0
			break;
		// End:0x152
		case 3:
			aPawn.m_iFriendlyTeams = GetTeamNumBit(3);
			aPawn.m_iEnemyTeams = GetTeamNumBit(2);
			__NFUN_161__(aPawn.m_iEnemyTeams, GetTeamNumBit(1));
			__NFUN_161__(aPawn.m_iEnemyTeams, GetTeamNumBit(0));
			// End:0x1C0
			break;
		// End:0xFFFF
		default:
			__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__("warning: SetPawnTeamFriendlies team not supported for ", string(aPawn.Name)), " team="), string(aPawn.m_iTeam)));
			// End:0x1C0
			break;
			break;
	}
	return;
}

defaultproperties
{
	m_iUbiComGameMode=4
	m_bFeedbackHostageExtracted=false
	m_szGameTypeFlag="RGM_HostageRescueAdvMode"
}
