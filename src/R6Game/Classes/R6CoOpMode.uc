//=============================================================================
//  R6CoOpMode.uc : Base co-operative multiplayer game mode; tracks whether Rainbow or terrorist pawns
//                  remain alive and handles game-start and end-game logic.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/05/21 * Created by Aristomenis Kolokathis
//=============================================================================
class R6CoOpMode extends R6MultiPlayerGameInfo;

// --- Variables ---
var bool bRainbowLeft;
var bool bTerroristLeft;

// --- Functions ---
function SetPawnTeamFriendlies(Pawn aPawn) {}
event InitGame(out string Error, string Options) {}
// ^ NEW IN 1.60
function PlayerReadySelected(PlayerController _Controller) {}
///////////////////////////////////////////////////////////////////////////////
// EndGame()
///////////////////////////////////////////////////////////////////////////////
function EndGame(string Reason, PlayerReplicationInfo Winner) {}
function int GetSpawnPointNum(string Options) {}
// ^ NEW IN 1.60
function int GetRainbowTeamColourIndex(int eTeamName) {}
// ^ NEW IN 1.60

defaultproperties
{
}
