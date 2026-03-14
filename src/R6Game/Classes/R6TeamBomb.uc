//=============================================================================
//  R6TeamBomb.uc : Adversarial team mode where one side plants a bomb and the other must defuse it;
//                  manages bomb arm/disarm state and related objectives.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/12/17 * Created by Aristomenis Kolokathis
//=============================================================================
class R6TeamBomb extends R6AdversarialTeamGame;

// --- Functions ---
//------------------------------------------------------------------
// InitObjectives
//
//------------------------------------------------------------------
function InitObjectives() {}
//------------------------------------------------------------------
// IObjectInteract
//
//------------------------------------------------------------------
function IObjectInteract(Actor anInteractiveObject, Pawn aPawn) {}
//------------------------------------------------------------------
// RestartPlayer
//	set the disarming/arming bomb
//------------------------------------------------------------------
function RestartPlayer(Controller aPlayer) {}
//------------------------------------------------------------------
// NotifyMatchStart
//
//------------------------------------------------------------------
function NotifyMatchStart() {}
//------------------------------------------------------------------
// PawnKilled
//
//------------------------------------------------------------------
function PawnKilled(Pawn killedPawn) {}
//------------------------------------------------------------------
// IsBombArmedOrExploded
//
//------------------------------------------------------------------
function bool IsBombArmedOrExploded() {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// EndGame
//
//------------------------------------------------------------------
function EndGame(string Reason, PlayerReplicationInfo Winner) {}

defaultproperties
{
}
