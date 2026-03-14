//=============================================================================
//  R6AdversarialTeamGame.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/12/05 * Created by Aristomenis Kolokathis
//    2002/04/22 * AK: added team selection support for menu system
//=============================================================================
class R6AdversarialTeamGame extends R6MultiPlayerGameInfo;

// --- Structs ---
struct MultiPlayerTeamInfo 
{
    var Array<R6PlayerController>   m_aPlayerController; 
    var INT                         m_iLivingPlayers;
};

// --- Variables ---
// var ? m_aPlayerController; // REMOVED IN 1.60
// var ? m_iLivingPlayers; // REMOVED IN 1.60
var R6MObjDeathmatch m_objDeathmatch;
// must be equal to == c_iMaxTeam
var MultiPlayerTeamInfo m_aTeam[2];
var const int c_iBravoTeam;
var const int c_iAlphaTeam;
var Sound m_sndRedTeamWonRound;
var Sound m_sndGreenTeamWonRound;
var Sound m_sndRoundIsADraw;
var const int c_iMaxTeam;
var bool m_bAddObjDeathmatch;
var Sound m_sndGreenTeamWonMatch;
var Sound m_sndRedTeamWonMatch;
var Sound m_sndMatchIsADraw;

// --- Functions ---
//------------------------------------------------------------------
// InitObjectives
//
//------------------------------------------------------------------
function InitObjectives() {}
//------------------------------------------------------------------
// EndGame
//	send the end of match string
//------------------------------------------------------------------
function EndGame(PlayerReplicationInfo Winner, string Reason) {}
//------------------------------------------------------------------
// SetPawnTeamFriendlies
//
//------------------------------------------------------------------
function SetPawnTeamFriendlies(Pawn aPawn) {}
//------------------------------------------------------------------
// ResetPlayerTeam
//
//------------------------------------------------------------------
function ResetPlayerTeam(Controller aPlayer) {}
event PostBeginPlay() {}
function int GetRainbowTeamColourIndex(int eTeamName) {}
// ^ NEW IN 1.60
function int GetSpawnPointNum(string Options) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// GetLastManStanding
//
//------------------------------------------------------------------
function R6PlayerController GetLastManStanding() {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// GetNbRoundWinner
//	return the teamID of the winner.
//  return -1 if no winner
//------------------------------------------------------------------
function int GetNbRoundWinner() {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// UpdateTeamInfo
//	- update the iLivingPlayers
//------------------------------------------------------------------
function UpdateTeamInfo() {}
function RemoveController(Controller aPlayer) {}
//------------------------------------------------------------------
// RemovePlayerFromTeam: remove player from all teams
//
//------------------------------------------------------------------
function bool RemovePlayerFromTeams(R6PlayerController PController) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// GetTeamIDFromTeamSelection
//	convert a EPlayerTeamSelection to a R6Adversarial team ID
//------------------------------------------------------------------
function int GetTeamIDFromTeamSelection(ePlayerTeamSelection eTeam) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// ResetOriginalData
//
//------------------------------------------------------------------
simulated function ResetOriginalData() {}
//------------------------------------------------------------------
// SetControllerTeamID
//	convert a EPlayerTeamSelection to a  R6AbstractGameInfo team ID
//------------------------------------------------------------------
function SetControllerTeamID(R6PlayerController PController, ePlayerTeamSelection eTeam) {}
// this is a signal from the server that a controller has selected his team/Or that he is ready to start
// we may need to do a round (but not a match) restart
function PlayerReadySelected(PlayerController _Controller) {}
//------------------------------------------------------------------
// IsPlayerInTeam
//
//------------------------------------------------------------------
function bool IsPlayerInTeam(int iTeamId, R6PlayerController PController) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// AddPlayerToTeam
//
//------------------------------------------------------------------
function AddPlayerToTeam(R6PlayerController PController, ePlayerTeamSelection eTeam) {}
//------------------------------------------------------------------
// GetTotalTeamFrag
//
//------------------------------------------------------------------
function int GetTotalTeamFrag(int iTeamId) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// ResetMatchStat
//
//------------------------------------------------------------------
function ResetMatchStat() {}
//------------------------------------------------------------------
// GetDeathMatchWinner
//	return the winner for a deathmatch game.
//  if a draw, return none
//------------------------------------------------------------------
function string GetDeathMatchWinner() {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// AddTeamWonRound
//
//------------------------------------------------------------------
function AddTeamWonRound(int iTeamId) {}

defaultproperties
{
}
