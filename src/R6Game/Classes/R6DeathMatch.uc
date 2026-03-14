//=============================================================================
//  R6DeathMatch.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/11/27 * Created by Aristomenis Kolokathis  Adversarial Mode
//=============================================================================
class R6DeathMatch extends R6AdversarialTeamGame;

// --- Variables ---
var int m_iNextPlayerTeamID;

// --- Functions ---
//------------------------------------------------------------------
// EndGame
//
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
//------------------------------------------------------------------
// GetSpawnPointNum
//
//------------------------------------------------------------------
function int GetSpawnPointNum(string Options) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// InitObjectives
//
//------------------------------------------------------------------
function InitObjectives() {}
function BroadcastTeam(optional name type, coerce string Msg, Actor Sender) {}
function int GetRainbowTeamColourIndex(int eTeamName) {}
// ^ NEW IN 1.60

defaultproperties
{
}
