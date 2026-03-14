//=============================================================================
//  R6StoryModeGame.uc : Single player and Coop game info.
//						 See mission objectives and morality design docs.
//
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//	  2002/02/19 * Created by S�bastien Lussier
//=============================================================================
class R6StoryModeGame extends R6GameInfo;

// --- Functions ---
///////////////////////////////////////////////////////////////////////////////
// EndGame()
///////////////////////////////////////////////////////////////////////////////
function EndGame(string Reason, PlayerReplicationInfo Winner) {}
function string GetIntelVideoName(R6MissionDescription Desc) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// UpdatePlayerCampaign()
//
//------------------------------------------------------------------
function UpdatePlayerCampaign() {}
function int GetNextRookieIndex(string _szOperativeClass) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// InitObjectives
//	 Story Mode Objective
//------------------------------------------------------------------
function InitObjectives() {}

defaultproperties
{
}
