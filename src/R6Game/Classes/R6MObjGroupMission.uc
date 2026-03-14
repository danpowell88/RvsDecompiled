//=============================================================================
//  R6MObjGroupMission.uc : 
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
// 
//
// example 1:
//      secure a terro
//      rescue one hostage
//      - the 2 must be completed
//      - if 1 fail, the group objective fails
//=============================================================================
class R6MObjGroupMission extends R6MissionObjectiveBase;

// --- Variables ---
var array<array> m_aSubMissionObjectives;
var int m_iMinSuccessRequired;
var int m_iMaxFailedAccepted;

// --- Functions ---
//------------------------------------------------------------------
// Init
//
//------------------------------------------------------------------
function Init() {}
function R6MissionObjectiveBase GetSubMissionObjective(int Index) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// PawnKilled
//
//------------------------------------------------------------------
function PawnKilled(Pawn killedPawn) {}
//------------------------------------------------------------------
// IObjectInteract
//
//------------------------------------------------------------------
function IObjectInteract(Actor anInteractiveObject, Pawn aPawn) {}
//------------------------------------------------------------------
// IObjectDestroyed
//
//------------------------------------------------------------------
function IObjectDestroyed(Actor anInteractiveObject, Pawn aPawn) {}
//------------------------------------------------------------------
// PawnSeen
//
//------------------------------------------------------------------
function PawnSeen(Pawn witness, Pawn seen) {}
//------------------------------------------------------------------
// PawnHeard
//
//------------------------------------------------------------------
function PawnHeard(Pawn witness, Pawn seen) {}
//------------------------------------------------------------------
// PawnSecure
//
//------------------------------------------------------------------
function PawnSecure(Pawn securedPawn) {}
//------------------------------------------------------------------
// EnteredExtractionZone
//
//------------------------------------------------------------------
function EnteredExtractionZone(Pawn Pawn) {}
//------------------------------------------------------------------
// ExitExtractionZone
//
//------------------------------------------------------------------
function ExitExtractionZone(Pawn Pawn) {}
//------------------------------------------------------------------
// isCompleted
//
//------------------------------------------------------------------
function bool isCompleted() {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// isFailed
//
//------------------------------------------------------------------
function bool isFailed() {}
// ^ NEW IN 1.60
function string GetDescriptionFailure() {}
// ^ NEW IN 1.60
function Sound GetSoundFailure() {}
// ^ NEW IN 1.60
function Reset() {}
function SetMObjMgr(Actor aMObjMgr) {}
function ToggleLog(bool bToggle) {}
function int GetNumSubMission() {}
// ^ NEW IN 1.60

defaultproperties
{
}
