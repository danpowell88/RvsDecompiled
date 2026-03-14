//=============================================================================
//  R6TeamDeathMatchGame.uc : Standard adversarial team deathmatch; two teams compete for the
//                            highest combined kill count before the round ends.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/12/05 * Created by Aristomenis Kolokathis
//=============================================================================
class R6TeamDeathMatchGame extends R6AdversarialTeamGame;

// --- Functions ---
//------------------------------------------------------------------
// EndGame
//
//------------------------------------------------------------------
function EndGame(string Reason, PlayerReplicationInfo Winner) {}
//------------------------------------------------------------------
// InitObjectives
//
//------------------------------------------------------------------
function InitObjectives() {}

defaultproperties
{
}
