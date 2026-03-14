//=============================================================================
//  R6LoneWolfGame.uc : Lone wolf game mode
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/12 * Created by S�bastien Lussier
//=============================================================================
class R6LoneWolfGame extends R6GameInfo;

// --- Variables ---
var Sound m_sndTeamWipedOut;

// --- Functions ---
function InitObjectives() {}
///////////////////////////////////////////////////////////////////////////////
// EndGame()
///////////////////////////////////////////////////////////////////////////////
function EndGame(string Reason, PlayerReplicationInfo Winner) {}

defaultproperties
{
}
