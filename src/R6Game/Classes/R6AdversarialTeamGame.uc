//=============================================================================
// R6AdversarialTeamGame - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6AdversarialTeamGame.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/12/05 * Created by Aristomenis Kolokathis
//    2002/04/22 * AK: added team selection support for menu system
//=============================================================================
class R6AdversarialTeamGame extends R6MultiPlayerGameInfo
	config
 hidecategories(Movement,Collision,Lighting,LightColor,Karma,Force);

struct MultiPlayerTeamInfo
{
	var array<R6PlayerController> m_aPlayerController;
	var int m_iLivingPlayers;
};

var const int c_iAlphaTeam;
var const int c_iBravoTeam;
var const int c_iMaxTeam;
var bool m_bAddObjDeathmatch;
var R6MObjDeathmatch m_objDeathmatch;
var Sound m_sndGreenTeamWonRound;
var Sound m_sndRedTeamWonRound;
var Sound m_sndRoundIsADraw;
var Sound m_sndGreenTeamWonMatch;
var Sound m_sndRedTeamWonMatch;
var Sound m_sndMatchIsADraw;
var MultiPlayerTeamInfo m_aTeam[2];  // must be equal to == c_iMaxTeam

event PostBeginPlay()
{
	super(R6GameInfo).PostBeginPlay();
	AddSoundBankName("Voices_Control_Multiplayer");
	return;
}

//------------------------------------------------------------------
// InitObjectives
//	
//------------------------------------------------------------------
function InitObjectives()
{
	local int iLength;

	// End:0x5F
	if(m_bAddObjDeathmatch)
	{
		m_objDeathmatch = new (none) Class'R6Game.R6MObjDeathmatch';
		m_objDeathmatch.m_bTeamDeathmatch = true;
		iLength = m_missionMgr.m_aMissionObjectives.Length;
		m_missionMgr.m_aMissionObjectives[iLength] = m_objDeathmatch;
		__NFUN_165__(iLength);
	}
	super.InitObjectives();
	return;
}

//------------------------------------------------------------------
// GetTeamIDFromTeamSelection
//	convert a EPlayerTeamSelection to a R6Adversarial team ID
//------------------------------------------------------------------
function int GetTeamIDFromTeamSelection(Object.ePlayerTeamSelection eTeam)
{
	// End:0x19
	if(__NFUN_154__(int(eTeam), int(2)))
	{
		return c_iAlphaTeam;		
	}
	else
	{
		return c_iBravoTeam;
	}
	return;
}

//------------------------------------------------------------------
// SetControllerTeamID
//	convert a EPlayerTeamSelection to a  R6AbstractGameInfo team ID
//------------------------------------------------------------------
function SetControllerTeamID(R6PlayerController PController, Object.ePlayerTeamSelection eTeam)
{
	// End:0x2D
	if(__NFUN_154__(int(eTeam), int(2)))
	{
		PController.m_pawn.m_iTeam = 2;		
	}
	else
	{
		// End:0x57
		if(__NFUN_154__(int(eTeam), int(3)))
		{
			PController.m_pawn.m_iTeam = 3;
		}
	}
	return;
}

//------------------------------------------------------------------
// IsPlayerInTeam
//	
//------------------------------------------------------------------
function bool IsPlayerInTeam(R6PlayerController PController, int iTeamId)
{
	local int i;

	// End:0x11
	if(__NFUN_153__(iTeamId, c_iMaxTeam))
	{
		return false;
	}
	i = 0;
	J0x18:

	// End:0x5F [Loop If]
	if(__NFUN_150__(i, m_aTeam[iTeamId].m_aPlayerController.Length))
	{
		// End:0x55
		if(__NFUN_114__(m_aTeam[iTeamId].m_aPlayerController[i], PController))
		{
			return true;
		}
		__NFUN_163__(i);
		// [Loop Continue]
		goto J0x18;
	}
	return false;
	return;
}

//------------------------------------------------------------------
// AddPlayerToTeam
//	
//------------------------------------------------------------------
function AddPlayerToTeam(R6PlayerController PController, Object.ePlayerTeamSelection eTeam)
{
	local int iLength, iTeamId;

	iTeamId = GetTeamIDFromTeamSelection(eTeam);
	iLength = m_aTeam[iTeamId].m_aPlayerController.Length;
	m_aTeam[iTeamId].m_aPlayerController[iLength] = PController;
	// End:0x9D
	if(bShowLog)
	{
		__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__("AddPlayerToTeam pController=", string(PController)), " (alpha=0, bravo=1) index="), string(iTeamId)));
	}
	return;
}

//------------------------------------------------------------------
// RemovePlayerFromTeam: remove player from all teams
//	
//------------------------------------------------------------------
function bool RemovePlayerFromTeams(R6PlayerController PController)
{
	local int iTeam, i;
	local bool bRemoved;

	iTeam = 0;
	J0x07:

	// End:0xDC [Loop If]
	if(__NFUN_150__(iTeam, 2))
	{
		i = 0;
		J0x1A:

		// End:0xD2 [Loop If]
		if(__NFUN_150__(i, m_aTeam[iTeam].m_aPlayerController.Length))
		{
			// End:0xC8
			if(__NFUN_114__(m_aTeam[iTeam].m_aPlayerController[i], PController))
			{
				m_aTeam[iTeam].m_aPlayerController.Remove(i, 1);
				__NFUN_164__(i);
				bRemoved = true;
				// End:0xC8
				if(bShowLog)
				{
					__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__("RemovePlayerFromTeam pController=", string(PController)), " in team="), string(iTeam)));
				}
			}
			__NFUN_163__(i);
			// [Loop Continue]
			goto J0x1A;
		}
		__NFUN_163__(iTeam);
		// [Loop Continue]
		goto J0x07;
	}
	return bRemoved;
	return;
}

//------------------------------------------------------------------
// UpdateTeamInfo
//	- update the iLivingPlayers
//------------------------------------------------------------------
function UpdateTeamInfo()
{
	local int iTeam, i;

	iTeam = 0;
	J0x07:

	// End:0x99 [Loop If]
	if(__NFUN_150__(iTeam, 2))
	{
		m_aTeam[iTeam].m_iLivingPlayers = 0;
		i = 0;
		J0x2C:

		// End:0x8F [Loop If]
		if(__NFUN_150__(i, m_aTeam[iTeam].m_aPlayerController.Length))
		{
			// End:0x85
			if(m_aTeam[iTeam].m_aPlayerController[i].m_pawn.IsAlive())
			{
				__NFUN_165__(m_aTeam[iTeam].m_iLivingPlayers);
			}
			__NFUN_163__(i);
			// [Loop Continue]
			goto J0x2C;
		}
		__NFUN_163__(iTeam);
		// [Loop Continue]
		goto J0x07;
	}
	return;
}

//------------------------------------------------------------------
// ResetOriginalData
//	
//------------------------------------------------------------------
simulated function ResetOriginalData()
{
	local int iTeam;

	// End:0x10
	if(m_bResetSystemLog)
	{
		LogResetSystem(false);
	}
	super(R6GameInfo).ResetOriginalData();
	iTeam = 0;
	J0x1D:

	// End:0x68 [Loop If]
	if(__NFUN_150__(iTeam, 2))
	{
		m_aTeam[iTeam].m_aPlayerController.Remove(0, m_aTeam[iTeam].m_aPlayerController.Length);
		m_aTeam[iTeam].m_iLivingPlayers = 0;
		__NFUN_163__(iTeam);
		// [Loop Continue]
		goto J0x1D;
	}
	return;
}

//------------------------------------------------------------------
// GetLastManStanding
//	
//------------------------------------------------------------------
function R6PlayerController GetLastManStanding()
{
	local int iTeam, i;
	local R6PlayerController aController, aPotentialWinnerController;
	local int iPotentialWinner;

	iTeam = 0;
	J0x07:

	// End:0x10C [Loop If]
	if(__NFUN_150__(iTeam, 2))
	{
		m_aTeam[iTeam].m_iLivingPlayers = 0;
		i = 0;
		J0x2C:

		// End:0x102 [Loop If]
		if(__NFUN_150__(i, m_aTeam[iTeam].m_aPlayerController.Length))
		{
			// End:0xD5
			if(__NFUN_130__(__NFUN_119__(m_aTeam[iTeam].m_aPlayerController[i].m_pawn, none), m_aTeam[iTeam].m_aPlayerController[i].m_pawn.IsAlive()))
			{
				// End:0xA7
				if(__NFUN_119__(aController, none))
				{
					return none;
				}
				aController = m_aTeam[iTeam].m_aPlayerController[i];
				__NFUN_165__(m_aTeam[iTeam].m_iLivingPlayers);
			}
			aPotentialWinnerController = m_aTeam[iTeam].m_aPlayerController[i];
			__NFUN_165__(iPotentialWinner);
			__NFUN_163__(i);
			// [Loop Continue]
			goto J0x2C;
		}
		__NFUN_163__(iTeam);
		// [Loop Continue]
		goto J0x07;
	}
	// End:0x11D
	if(__NFUN_154__(iPotentialWinner, 1))
	{
		return aPotentialWinnerController;
	}
	return aController;
	return;
}

function int GetRainbowTeamColourIndex(int eTeamName)
{
	return __NFUN_147__(eTeamName, 1);
	return;
}

function int GetSpawnPointNum(string Options)
{
	return GetIntOption(Options, "SpawnNum", 255);
	return;
}

function RemoveController(Controller aPlayer)
{
	RemovePlayerFromTeams(R6PlayerController(aPlayer));
	return;
}

//------------------------------------------------------------------
// ResetPlayerTeam
//	
//------------------------------------------------------------------
function ResetPlayerTeam(Controller aPlayer)
{
	// End:0x190
	if(__NFUN_129__(IsPlayerInTeam(R6PlayerController(aPlayer), GetTeamIDFromTeamSelection(R6PlayerController(aPlayer).m_TeamSelection))))
	{
		RemovePlayerFromTeams(R6PlayerController(aPlayer));
		// End:0x7F
		if(__NFUN_132__(__NFUN_154__(int(R6PlayerController(aPlayer).m_TeamSelection), int(2)), __NFUN_154__(int(R6PlayerController(aPlayer).m_TeamSelection), int(3))))
		{			
		}
		else
		{
			// End:0xF6
			if(__NFUN_154__(int(R6PlayerController(aPlayer).m_TeamSelection), int(1)))
			{
				// End:0xDD
				if(__NFUN_152__(m_aTeam[c_iAlphaTeam].m_aPlayerController.Length, m_aTeam[c_iBravoTeam].m_aPlayerController.Length))
				{
					R6PlayerController(aPlayer).m_TeamSelection = 2;					
				}
				else
				{
					R6PlayerController(aPlayer).m_TeamSelection = 3;
				}				
			}
			else
			{
				// End:0x14C
				if(bShowLog)
				{
					__NFUN_231__(__NFUN_112__(__NFUN_112__("R6AdversarialTeamGame: not added player ", string(aPlayer.Pawn)), "to Team yet"));
				}
				R6Pawn(aPlayer.Pawn).m_iTeam = 4;
				return;
			}
		}
		AddPlayerToTeam(R6PlayerController(aPlayer), R6PlayerController(aPlayer).m_TeamSelection);
	}
	super.ResetPlayerTeam(aPlayer);
	// End:0x1D7
	if(__NFUN_119__(R6PlayerController(aPlayer).m_pawn, none))
	{
		SetControllerTeamID(R6PlayerController(aPlayer), R6PlayerController(aPlayer).m_TeamSelection);
	}
	return;
}

//------------------------------------------------------------------
// SetPawnTeamFriendlies
//	
//------------------------------------------------------------------
function SetPawnTeamFriendlies(Pawn aPawn)
{
	switch(aPawn.m_iTeam)
	{
		// End:0x5C
		case 0:
			aPawn.m_iFriendlyTeams = GetTeamNumBit(2);
			__NFUN_161__(aPawn.m_iFriendlyTeams, GetTeamNumBit(3));
			aPawn.m_iEnemyTeams = GetTeamNumBit(1);
			// End:0x1B0
			break;
		// End:0xA8
		case 1:
			aPawn.m_iFriendlyTeams = GetTeamNumBit(1);
			aPawn.m_iEnemyTeams = GetTeamNumBit(2);
			__NFUN_161__(aPawn.m_iEnemyTeams, GetTeamNumBit(3));
			// End:0x1B0
			break;
		// End:0xF5
		case 2:
			aPawn.m_iFriendlyTeams = GetTeamNumBit(2);
			aPawn.m_iEnemyTeams = GetTeamNumBit(3);
			__NFUN_161__(aPawn.m_iEnemyTeams, GetTeamNumBit(1));
			// End:0x1B0
			break;
		// End:0x142
		case 3:
			aPawn.m_iFriendlyTeams = GetTeamNumBit(3);
			aPawn.m_iEnemyTeams = GetTeamNumBit(2);
			__NFUN_161__(aPawn.m_iEnemyTeams, GetTeamNumBit(1));
			// End:0x1B0
			break;
		// End:0xFFFF
		default:
			__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__("warning: SetPawnTeamFriendlies team not supported for ", string(aPawn.Name)), " team="), string(aPawn.m_iTeam)));
			// End:0x1B0
			break;
			break;
	}
	return;
}

// this is a signal from the server that a controller has selected his team/Or that he is ready to start
// we may need to do a round (but not a match) restart
function PlayerReadySelected(PlayerController _Controller)
{
	local Controller _aController;
	local int iHumanCountA, iHumanCountB;
	local Object.ePlayerTeamSelection _TeamSelection;

	// End:0x1F
	if(__NFUN_132__(__NFUN_114__(R6PlayerController(_Controller), none), __NFUN_281__('InBetweenRoundMenu')))
	{
		return;
	}
	GetNbHumanPlayerInTeam(iHumanCountA, iHumanCountB);
	_TeamSelection = R6PlayerController(_Controller).m_TeamSelection;
	// End:0x6E
	if(__NFUN_129__(__NFUN_132__(__NFUN_154__(int(_TeamSelection), int(2)), __NFUN_154__(int(_TeamSelection), int(3)))))
	{
		return;
	}
	// End:0xFE
	if(Level.IsGameTypeTeamAdversarial(m_szGameTypeFlag))
	{
		// End:0xFB
		if(__NFUN_132__(__NFUN_132__(__NFUN_130__(__NFUN_130__(__NFUN_154__(int(_TeamSelection), int(2)), __NFUN_154__(iHumanCountA, 1)), __NFUN_151__(iHumanCountB, 0)), __NFUN_130__(__NFUN_130__(__NFUN_154__(int(_TeamSelection), int(3)), __NFUN_154__(iHumanCountB, 1)), __NFUN_151__(iHumanCountA, 0))), __NFUN_154__(__NFUN_146__(iHumanCountA, iHumanCountB), 1)))
		{
			ResetPenalty();
			ResetRound();
		}		
	}
	else
	{
		// End:0x116
		if(__NFUN_152__(iHumanCountA, 2))
		{
			ResetPenalty();
			ResetRound();
		}
	}
	return;
}

//------------------------------------------------------------------
// GetTotalTeamFrag
//	
//------------------------------------------------------------------
function int GetTotalTeamFrag(int iTeamId)
{
	local int i, iFragCount;
	local R6PlayerController PController;

	i = 0;
	J0x07:

	// End:0x99 [Loop If]
	if(__NFUN_150__(i, m_aTeam[iTeamId].m_aPlayerController.Length))
	{
		PController = m_aTeam[iTeamId].m_aPlayerController[i];
		// End:0x8F
		if(__NFUN_130__(__NFUN_119__(PController.m_pawn, none), __NFUN_129__(PController.m_pawn.m_bSuicided)))
		{
			__NFUN_161__(iFragCount, PController.PlayerReplicationInfo.m_iRoundKillCount);
		}
		__NFUN_163__(i);
		// [Loop Continue]
		goto J0x07;
	}
	return iFragCount;
	return;
}

//------------------------------------------------------------------
// AddTeamWonRound
//	
//------------------------------------------------------------------
function AddTeamWonRound(int iTeamId)
{
	// End:0x0E
	if(__NFUN_242__(m_bCompilingStats, false))
	{
		return;
	}
	// End:0x38
	if(__NFUN_150__(iTeamId, 2))
	{
		__NFUN_165__(R6GameReplicationInfo(GameReplicationInfo).m_aTeamScore[iTeamId]);		
	}
	else
	{
		__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__("Warning: AddTeamWonRound teamID=", string(iTeamId)), " and m_aTeamScore size is= "), string(2)));
	}
	return;
}

//------------------------------------------------------------------
// GetNbRoundWinner
//	return the teamID of the winner.
//  return -1 if no winner
//------------------------------------------------------------------
function int GetNbRoundWinner()
{
	local int iTeam, iCurWinner, iCurWinnerScore;
	local bool bDraw;
	local R6GameReplicationInfo repGameInfo;

	repGameInfo = R6GameReplicationInfo(GameReplicationInfo);
	iCurWinner = -1;
	iCurWinnerScore = -1;
	iTeam = 0;
	J0x2D:

	// End:0xB7 [Loop If]
	if(__NFUN_150__(iTeam, 2))
	{
		// End:0x62
		if(__NFUN_154__(repGameInfo.m_aTeamScore[iTeam], iCurWinnerScore))
		{
			bDraw = true;
			// [Explicit Continue]
			goto J0xAD;
		}
		// End:0xAD
		if(__NFUN_151__(repGameInfo.m_aTeamScore[iTeam], iCurWinnerScore))
		{
			iCurWinner = iTeam;
			iCurWinnerScore = repGameInfo.m_aTeamScore[iTeam];
			bDraw = false;
		}
		J0xAD:

		__NFUN_163__(iTeam);
		// [Loop Continue]
		goto J0x2D;
	}
	// End:0xC9
	if(bDraw)
	{
		return -1;		
	}
	else
	{
		return iCurWinner;
	}
	return;
}

//------------------------------------------------------------------
// ResetMatchStat
//	
//------------------------------------------------------------------
function ResetMatchStat()
{
	local int iTeam;
	local R6GameReplicationInfo repGameInfo;

	repGameInfo = R6GameReplicationInfo(GameReplicationInfo);
	iTeam = 0;
	J0x17:

	// End:0x43 [Loop If]
	if(__NFUN_150__(iTeam, 2))
	{
		repGameInfo.m_aTeamScore[iTeam] = 0;
		__NFUN_163__(iTeam);
		// [Loop Continue]
		goto J0x17;
	}
	super(R6GameInfo).ResetMatchStat();
	return;
}

//------------------------------------------------------------------
// GetDeathMatchWinner
//	return the winner for a deathmatch game.
//  if a draw, return none
//------------------------------------------------------------------
function string GetDeathMatchWinner()
{
	local PlayerMenuInfo playerMenuInfo1, playerMenuInfo2;

	R6GameReplicationInfo(GameReplicationInfo).RefreshMPInfoPlayerStats();
	__NFUN_1230__(0, playerMenuInfo1);
	__NFUN_1230__(1, playerMenuInfo2);
	// End:0x4A
	if(__NFUN_151__(playerMenuInfo1.iRoundsWon, playerMenuInfo2.iRoundsWon))
	{
		return playerMenuInfo1.szPlayerName;
	}
	return "";
	return;
}

//------------------------------------------------------------------
// EndGame
//	send the end of match string
//------------------------------------------------------------------
function EndGame(PlayerReplicationInfo Winner, string Reason)
{
	local R6GameReplicationInfo gameRepInfo;
	local int iWinnerID;
	local PlayerController PlayerCtrl;
	local string szWinner;

	// End:0x0B
	if(m_bGameOver)
	{
		return;
	}
	// End:0x1BC
	if(IsLastRoundOfTheMatch())
	{
		gameRepInfo = R6GameReplicationInfo(GameReplicationInfo);
		// End:0x143
		if(Level.IsGameTypeTeamAdversarial(m_szGameTypeFlag))
		{
			iWinnerID = GetNbRoundWinner();
			// End:0x7E
			if(__NFUN_154__(iWinnerID, -1))
			{
				BroadcastGameMsg("", "", "MatchIsADraw", m_sndMatchIsADraw, int(GetGameMsgLifeTime()));				
			}
			else
			{
				// End:0xBA
				if(__NFUN_154__(iWinnerID, c_iAlphaTeam))
				{
					BroadcastGameMsg("", "", "GreenTeamWonMatch", m_sndGreenTeamWonMatch, int(GetGameMsgLifeTime()));					
				}
				else
				{
					// End:0xF4
					if(__NFUN_154__(iWinnerID, c_iBravoTeam))
					{
						BroadcastGameMsg("", "", "RedTeamWonMatch", m_sndRedTeamWonMatch, int(GetGameMsgLifeTime()));						
					}
					else
					{
						__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__("Warning: GetNbRoundWinner unknow id= ", string(iWinnerID)), " in "), string(Class.Name)));
					}
				}
			}			
		}
		else
		{
			// End:0x1BC
			if(Level.IsGameTypeAdversarial(m_szGameTypeFlag))
			{
				szWinner = GetDeathMatchWinner();
				// End:0x196
				if(__NFUN_122__(szWinner, ""))
				{
					BroadcastGameMsg("", "", "MatchIsADraw", none, int(GetGameMsgLifeTime()));					
				}
				else
				{
					BroadcastGameMsg("", szWinner, "HasWonTheMatch", none, int(GetGameMsgLifeTime()));
				}
			}
		}
	}
	super.EndGame(Winner, Reason);
	return;
}

defaultproperties
{
	c_iBravoTeam=1
	c_iMaxTeam=2
	m_bAddObjDeathmatch=true
	m_sndGreenTeamWonRound=Sound'Voices_Control_Multiplayer.Play_Green_Team'
	m_sndRedTeamWonRound=Sound'Voices_Control_Multiplayer.Play_Red_Team'
	m_sndRoundIsADraw=Sound'Voices_Control_Multiplayer.Play_Round_Draw'
	m_sndGreenTeamWonMatch=Sound'Voices_Control_Multiplayer.Play_Green_Team_Match'
	m_sndRedTeamWonMatch=Sound'Voices_Control_Multiplayer.Play_Red_Team_Match'
	m_sndMatchIsADraw=Sound'Voices_Control_Multiplayer.Play_Match_Draw'
	m_bUnlockAllDoors=true
}
