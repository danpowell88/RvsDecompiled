//=============================================================================
//  R6HostageRescueAdvGame.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/11/22 * Created by Aristomenis Kolokathis
//=============================================================================
class R6HostageRescueAdvGame extends R6AdversarialTeamGame;

// --- Variables ---
var R6MObjRescueHostage m_objRescueHostage;
var R6MObjAcceptableHostageLossesByRainbow m_objHostageLossesByAlpha;
var R6MObjAcceptableHostageLossesByRainbow m_objHostageLossesByBravo;
var int m_iIfDeadHostageMinNbToRescue;

// --- Functions ---
//------------------------------------------------------------------
// EndGame
//
//------------------------------------------------------------------
function EndGame(string Reason, PlayerReplicationInfo Winner) {}
//------------------------------------------------------------------
// PawnKilled
//
//------------------------------------------------------------------
function PawnKilled(Pawn killedPawn) {}
function SetPawnTeamFriendlies(Pawn aPawn) {}
//------------------------------------------------------------------
// EnteredExtractionZone
//
//------------------------------------------------------------------
function EnteredExtractionZone(Actor anActor) {}
//------------------------------------------------------------------
// InitObjHostageLossesByTeamID
//
//------------------------------------------------------------------
function InitObjHostageLossesByTeamID(R6MObjAcceptableHostageLossesByRainbow obj, int iTeamId, int iAcceptableLost) {}
//------------------------------------------------------------------
// InitObjectives
//
//------------------------------------------------------------------
function InitObjectives() {}

defaultproperties
{
}
