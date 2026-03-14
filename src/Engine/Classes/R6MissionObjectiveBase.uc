//=============================================================================
//  R6MissionObjectiveBase.uc : 
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//=============================================================================
class R6MissionObjectiveBase extends Object
    abstract;

// --- Variables ---
var string m_szMissionObjLocalization;
// ^ NEW IN 1.60
var bool m_bFailed;
var bool m_bCompleted;
// reference to the manager
var Actor m_mgr;
var string m_szDescription;
// ^ NEW IN 1.60
var string m_szDescriptionFailure;
// ^ NEW IN 1.60
var bool m_bVisibleInMenu;
// ^ NEW IN 1.60
var bool m_bIfCompletedMissionIsSuccessfull;
// ^ NEW IN 1.60
var bool m_bIfFailedMissionIsAborted;
// ^ NEW IN 1.60
var bool m_bShowLog;
// ^ NEW IN 1.60
var Sound m_sndSoundSuccess;
// ^ NEW IN 1.60
var Sound m_sndSoundFailure;
// ^ NEW IN 1.60
var bool m_bFeedbackOnCompletionSend;
var bool m_bFeedbackOnFailureSend;
var string m_szFeedbackOnFailure;
// ^ NEW IN 1.60
var string m_szFeedbackOnCompletion;
// ^ NEW IN 1.60
// timer countdown
var int m_iCountdown;
// special case when this objective should be checked at the end of the list
var bool m_bEndOfListOfObjectives;
var bool m_bMoralityObjective;
// ^ NEW IN 1.60
var string m_szDescriptionInMenu;
// ^ NEW IN 1.60

// --- Functions ---
function ToggleLog(bool bToggle) {}
function logMObj(string szText) {}
function logX(string szText) {}
function SetMObjMgr(Actor aMObjMgr) {}
function Reset() {}
function Sound GetSoundFailure() {}
// ^ NEW IN 1.60
function Sound GetSoundSuccess() {}
// ^ NEW IN 1.60
function string GetDescriptionFailure() {}
// ^ NEW IN 1.60
function R6MissionObjectiveBase GetSubMissionObjective(int Index) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// SubMission functions
//
//------------------------------------------------------------------
function int GetNumSubMission() {}
// ^ NEW IN 1.60
function string getDescription() {}
// ^ NEW IN 1.60
function bool isFailed() {}
// ^ NEW IN 1.60
function bool isCompleted() {}
// ^ NEW IN 1.60
function bool isMissionAbortedOnFailure() {}
// ^ NEW IN 1.60
function bool isMissionCompletedOnSuccess() {}
// ^ NEW IN 1.60
function bool isVisibleInMenu() {}
// ^ NEW IN 1.60
function Init() {}
function TimerCallback(float fTime) {}
function ExitExtractionZone(Pawn Pawn) {}
function EnteredExtractionZone(Pawn Pawn) {}
function PawnSecure(Pawn securedPawn) {}
function PawnHeard(Pawn witness, Pawn seen) {}
function PawnSeen(Pawn witness, Pawn seen) {}
function IObjectDestroyed(Actor anInteractiveObject, Pawn aPawn) {}
function IObjectInteract(Actor anInteractiveObject, Pawn aPawn) {}
// all those MObj event are in the manager
function PawnKilled(Pawn killedPawn) {}

defaultproperties
{
}
