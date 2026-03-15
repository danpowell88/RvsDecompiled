//=============================================================================
// R6MissionObjectiveBase - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6MissionObjectiveBase.uc : 
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//=============================================================================
class R6MissionObjectiveBase extends Object
    abstract
	editinlinenew
    hidecategories(Object);

var int m_iCountdown;  // timer countdown
var bool m_bFailed;
var bool m_bCompleted;
var() bool m_bVisibleInMenu;  // if we want to see the description and the status in the menu
var() bool m_bIfCompletedMissionIsSuccessfull;  // if this mission objective is completed, the whole mission is a success and over
var() bool m_bIfFailedMissionIsAborted;  // if this mission objective fails, the whole mission is a failure and over
var() bool m_bMoralityObjective;  // if it's a morality rule
var bool m_bEndOfListOfObjectives;  // special case when this objective should be checked at the end of the list
var() bool m_bShowLog;  // debug show log
var bool m_bFeedbackOnCompletionSend;
var bool m_bFeedbackOnFailureSend;
var Actor m_mgr;  // reference to the manager
var() Sound m_sndSoundSuccess;  // when completed..: snd played
var() Sound m_sndSoundFailure;  // when failed..: snd played
var() string m_szDescription;  // debug description
var() string m_szDescriptionInMenu;  // in the menu and when completed..: keyword for the dictionnary
var() string m_szDescriptionFailure;  // when failed.....: keyword for the dictionnary
var() string m_szMissionObjLocalization;  // 
var() string m_szFeedbackOnCompletion;
var() string m_szFeedbackOnFailure;

// all those MObj event are in the manager
function PawnKilled(Pawn killedPawn)
{
	return;
}

function IObjectInteract(Pawn aPawn, Actor anInteractiveObject)
{
	return;
}

function IObjectDestroyed(Pawn aPawn, Actor anInteractiveObject)
{
	return;
}

function PawnSeen(Pawn seen, Pawn witness)
{
	return;
}

function PawnHeard(Pawn seen, Pawn witness)
{
	return;
}

function PawnSecure(Pawn securedPawn)
{
	return;
}

function EnteredExtractionZone(Pawn Pawn)
{
	return;
}

function ExitExtractionZone(Pawn Pawn)
{
	return;
}

function TimerCallback(float fTime)
{
	return;
}

function ToggleLog(bool bToggle)
{
	m_bShowLog = bToggle;
	return;
}

function logMObj(string szText)
{
	Log(((("WARNING MissionObjective (", string(self.Name)) $ ")" $ ???) $ szText));
	return;
}

function logX(string szText)
{
	Log(((("" $ string(self.Name)) $ ": ") $ szText));
	return;
}

function Init()
{
	return;
}

function bool isVisibleInMenu()
{
	return m_bVisibleInMenu;
	return;
}

function bool isMissionCompletedOnSuccess()
{
	return m_bIfCompletedMissionIsSuccessfull;
	return;
}

function bool isMissionAbortedOnFailure()
{
	return m_bIfFailedMissionIsAborted;
	return;
}

function bool isCompleted()
{
	return m_bCompleted;
	return;
}

function bool isFailed()
{
	return m_bFailed;
	return;
}

function string getDescription()
{
	return m_szDescription;
	return;
}

//------------------------------------------------------------------
// SubMission functions
//	
//------------------------------------------------------------------
function int GetNumSubMission()
{
	return 0;
	return;
}

function R6MissionObjectiveBase GetSubMissionObjective(int Index)
{
	return none;
	return;
}

function string GetDescriptionFailure()
{
	return m_szDescriptionFailure;
	return;
}

function SetMObjMgr(Actor aMObjMgr)
{
	m_mgr = aMObjMgr;
	return;
}

function Sound GetSoundSuccess()
{
	return m_sndSoundSuccess;
	return;
}

function Sound GetSoundFailure()
{
	return m_sndSoundFailure;
	return;
}

function Reset()
{
	m_bFailed = false;
	m_bCompleted = false;
	m_bFeedbackOnCompletionSend = false;
	m_bFeedbackOnFailureSend = false;
	return;
}

defaultproperties
{
	m_bVisibleInMenu=true
}
