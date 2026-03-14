//=============================================================================
//  R6MissionObjectiveMgr.uc : Actor that tracks the status of all mission objectives.
//  Stores per-objective status (none/success/failed) and drives mission completion logic. 
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//=============================================================================
class R6MissionObjectiveMgr extends Actor;

// --- Enums ---
enum EMissionObjectiveStatus
{
    eMissionObjStatus_none,
    eMissionObjStatus_success,
    eMissionObjStatus_failed
};

// --- Variables ---
// var ? m_gameInfo; // REMOVED IN 1.60
var array<array> m_aMissionObjectives;
var EMissionObjectiveStatus m_eMissionObjectiveStatus;
var R6AbstractGameInfo m_GameInfo;
// ^ NEW IN 1.60
var bool m_bShowLog;
var bool m_bOnSuccessAllObjectivesAreCompleted;
var bool m_bDontUpdateMgr;
var bool m_bEnableCheckForErrors;

// --- Functions ---
// function ? Timer(...); // REMOVED IN 1.60
function SetMissionObjStatus(EMissionObjectiveStatus eStatus) {}
simulated event Destroyed() {}
//------------------------------------------------------------------
// ToggleLog
//
//------------------------------------------------------------------
function ToggleLog(bool bToggle) {}
//------------------------------------------------------------------
// AbortMission: Force to abord the mission
//  set all mission objective to false except morality
//------------------------------------------------------------------
function AbortMission() {}
//------------------------------------------------------------------
// CompleteMission
//	set all not failed mission to completed
//------------------------------------------------------------------
function CompleteMission() {}
//------------------------------------------------------------------
// IObjectDestroyed
//
//------------------------------------------------------------------
function IObjectDestroyed(Actor anInteractiveObject, Pawn aPawn) {}
//------------------------------------------------------------------
// EnteredExtractionZone
//
//------------------------------------------------------------------
function EnteredExtractionZone(Pawn aPawn) {}
//------------------------------------------------------------------
// PawnSecure
//
//------------------------------------------------------------------
function PawnSecure(Pawn securedPawn) {}
//------------------------------------------------------------------
// ExitExtractionZone
//
//------------------------------------------------------------------
function ExitExtractionZone(Pawn aPawn) {}
//------------------------------------------------------------------
// PawnHeard
//
//------------------------------------------------------------------
function PawnHeard(Pawn witness, Pawn heard) {}
//------------------------------------------------------------------
// PawnKilled
//
//------------------------------------------------------------------
function PawnKilled(Pawn killedPawn) {}
//------------------------------------------------------------------
// PawnSeen
//
//------------------------------------------------------------------
function PawnSeen(Pawn witness, Pawn seen) {}
//------------------------------------------------------------------
// IObjectInteract
//
//------------------------------------------------------------------
function IObjectInteract(Actor anInteractiveObject, Pawn aPawn) {}
function Init(R6AbstractGameInfo GameInfo) {}
//------------------------------------------------------------------
// Update: update the mission objective manager. check if mission
//	have failed or has been completed
//------------------------------------------------------------------
function EMissionObjectiveStatus Update() {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// SetMissionObjCompleted
//	set completed or failed and check he need to send a feedback
//------------------------------------------------------------------
function SetMissionObjCompleted(R6MissionObjectiveBase mobj, bool bFeedback, bool bCompleted) {}
//------------------------------------------------------------------
// GetMObjFailed
//  We only check for one reason for the failure. This is why
//  the moralities are checked last.
//------------------------------------------------------------------
function R6MissionObjectiveBase GetMObjFailed() {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// TimerCallback
//
//------------------------------------------------------------------
function TimerCallback(float fTime) {}
//------------------------------------------------------------------
// RemoveObjectives
//
//------------------------------------------------------------------
function RemoveObjectives() {}

defaultproperties
{
}
