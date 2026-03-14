//=============================================================================
//  R6SquadTeamDeathmatch.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//=============================================================================
class R6SquadTeamDeathmatch extends R6AdversarialTeamGame;

// --- Variables ---
var int m_iNextPlayerTeamID;

// --- Functions ---
//------------------------------------------------------------------
// EndGame
//
//------------------------------------------------------------------
function EndGame(PlayerReplicationInfo Winner, string Reason) {}
//------------------------------------------------------------------
// GetNbOfRainbowAIToSpawnBaseOnTeamNb
//
//------------------------------------------------------------------
function int GetNbOfRainbowAIToSpawnBaseOnTeamNb(int iTeamNb) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// GetNbOfTeamMemberToSpawn
//	spawn the nb of ai in team. if the nb of player in each team
//  is not equal, adjust the nb of ai for the other team
//------------------------------------------------------------------
function int GetNbOfRainbowAIToSpawn(PlayerController aController) {}
// ^ NEW IN 1.60
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

defaultproperties
{
}
