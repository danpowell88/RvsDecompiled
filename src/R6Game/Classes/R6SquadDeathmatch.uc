//=============================================================================
//  R6SquadDeathmatch.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//=============================================================================
class R6SquadDeathmatch extends R6AdversarialTeamGame;

// --- Variables ---
var int m_iNextPlayerTeamID;

// --- Functions ---
//------------------------------------------------------------------
// GetNbOfRainbowAIToSpawn
//
//------------------------------------------------------------------
function int GetNbOfRainbowAIToSpawn(PlayerController aController) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// EndGame
//
//------------------------------------------------------------------
function EndGame(string Reason, PlayerReplicationInfo Winner) {}
//------------------------------------------------------------------
// ResetPlayerTeam
//	set pawn's m_iTeam
//------------------------------------------------------------------
function ResetPlayerTeam(Controller aPlayer) {}
//------------------------------------------------------------------
// SetPawnTeamFriendlies
//
//------------------------------------------------------------------
function SetPawnTeamFriendlies(Pawn aPawn) {}
//------------------------------------------------------------------
// InitObjectives
//
//------------------------------------------------------------------
function InitObjectives() {}

state InBetweenRoundMenu
{
    function EndState() {}
}

defaultproperties
{
}
