//=============================================================================
// R6MissionObjectiveMgr - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6MissionObjectiveMgr.uc : 
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//=============================================================================

// to put in game info
class R6MissionObjectiveMgr extends Actor
    notplaceable;

enum EMissionObjectiveStatus
{
	eMissionObjStatus_none,         // 0
	eMissionObjStatus_success,      // 1
	eMissionObjStatus_failed        // 2
};

var R6MissionObjectiveMgr.EMissionObjectiveStatus m_eMissionObjectiveStatus;
var bool m_bShowLog;
var bool m_bDontUpdateMgr;
var bool m_bOnSuccessAllObjectivesAreCompleted;
var bool m_bEnableCheckForErrors;
var R6AbstractGameInfo m_GameInfo;
var array<R6MissionObjectiveBase> m_aMissionObjectives;

function SetMissionObjStatus(R6MissionObjectiveMgr.EMissionObjectiveStatus eStatus)
{
	m_eMissionObjectiveStatus = eStatus;
	m_GameInfo.UpdateRepMissionObjectivesStatus();
	return;
}

function Init(R6AbstractGameInfo GameInfo)
{
	local int i, Index, iTimer;

	// End:0x27
	if(m_bShowLog)
	{
		Log("*** Mission Objectives ***");
	}
	m_GameInfo = GameInfo;
	SetMissionObjStatus(0);
	i = 0;
	J0x41:

	// End:0xBB [Loop If]
	if((i < m_aMissionObjectives.Length))
	{
		m_aMissionObjectives[i].m_mgr = self;
		// End:0x9C
		if(m_bShowLog)
		{
			Log(((("  " $ string(i)) $ ": ") $ m_aMissionObjectives[i].getDescription()));
		}
		m_aMissionObjectives[i].Init();
		(++i);
		// [Loop Continue]
		goto J0x41;
	}
	return;
}

//------------------------------------------------------------------
// RemoveObjectives
//	
//------------------------------------------------------------------
function RemoveObjectives()
{
	// End:0x27
	if(m_bShowLog)
	{
		Log("Mission objective: removed");
	}
	// End:0x40
	if((m_aMissionObjectives.Length > 0))
	{
		m_aMissionObjectives.Remove(0, m_aMissionObjectives.Length);
	}
	m_GameInfo.ResetRepMissionObjectives();
	return;
}

//------------------------------------------------------------------
// TimerCallback
//	
//------------------------------------------------------------------
function TimerCallback(float fTime)
{
	return;
}

//------------------------------------------------------------------
// PawnKilled
//	
//------------------------------------------------------------------
function PawnKilled(Pawn killedPawn)
{
	local int i;

	// End:0x1F
	if(((int(m_eMissionObjectiveStatus) != int(0)) || (killedPawn == none)))
	{
		return;
	}
	// End:0xE3
	if(m_bShowLog)
	{
		// End:0xB0
		if(((PlayerController(killedPawn.Controller) != none) && (PlayerController(killedPawn.Controller).PlayerReplicationInfo != none)))
		{
			Log(("MissionObjective: PawnKilled " $ PlayerController(killedPawn.Controller).PlayerReplicationInfo.PlayerName));			
		}
		else
		{
			Log(("MissionObjective: PawnKilled " $ string(killedPawn.Name)));
		}
	}
	i = 0;
	J0xEA:

	// End:0x153 [Loop If]
	if((i < m_aMissionObjectives.Length))
	{
		// End:0x12F
		if((m_aMissionObjectives[i].m_bFailed || m_aMissionObjectives[i].m_bCompleted))
		{
			// [Explicit Continue]
			goto J0x149;
		}
		m_aMissionObjectives[i].PawnKilled(killedPawn);
		J0x149:

		(++i);
		// [Loop Continue]
		goto J0xEA;
	}
	return;
}

//------------------------------------------------------------------
// IObjectInteract
//	
//------------------------------------------------------------------
function IObjectInteract(Pawn aPawn, Actor anInteractiveObject)
{
	local int i;

	// End:0x12
	if((int(m_eMissionObjectiveStatus) != int(0)))
	{
		return;
	}
	i = 0;
	J0x19:

	// End:0x87 [Loop If]
	if((i < m_aMissionObjectives.Length))
	{
		// End:0x5E
		if((m_aMissionObjectives[i].m_bFailed || m_aMissionObjectives[i].m_bCompleted))
		{
			// [Explicit Continue]
			goto J0x7D;
		}
		m_aMissionObjectives[i].IObjectInteract(aPawn, anInteractiveObject);
		J0x7D:

		(++i);
		// [Loop Continue]
		goto J0x19;
	}
	return;
}

//------------------------------------------------------------------
// IObjectDestroyed
//	
//------------------------------------------------------------------
function IObjectDestroyed(Pawn aPawn, Actor anInteractiveObject)
{
	local int i;

	// End:0x12
	if((int(m_eMissionObjectiveStatus) != int(0)))
	{
		return;
	}
	i = 0;
	J0x19:

	// End:0x87 [Loop If]
	if((i < m_aMissionObjectives.Length))
	{
		// End:0x5E
		if((m_aMissionObjectives[i].m_bFailed || m_aMissionObjectives[i].m_bCompleted))
		{
			// [Explicit Continue]
			goto J0x7D;
		}
		m_aMissionObjectives[i].IObjectDestroyed(aPawn, anInteractiveObject);
		J0x7D:

		(++i);
		// [Loop Continue]
		goto J0x19;
	}
	return;
}

//------------------------------------------------------------------
// PawnSeen
//	
//------------------------------------------------------------------
function PawnSeen(Pawn seen, Pawn witness)
{
	local int i;

	// End:0x12
	if((int(m_eMissionObjectiveStatus) != int(0)))
	{
		return;
	}
	i = 0;
	J0x19:

	// End:0x87 [Loop If]
	if((i < m_aMissionObjectives.Length))
	{
		// End:0x5E
		if((m_aMissionObjectives[i].m_bFailed || m_aMissionObjectives[i].m_bCompleted))
		{
			// [Explicit Continue]
			goto J0x7D;
		}
		m_aMissionObjectives[i].PawnSeen(seen, witness);
		J0x7D:

		(++i);
		// [Loop Continue]
		goto J0x19;
	}
	return;
}

//------------------------------------------------------------------
// PawnHeard
//	
//------------------------------------------------------------------
function PawnHeard(Pawn heard, Pawn witness)
{
	local int i;

	// End:0x12
	if((int(m_eMissionObjectiveStatus) != int(0)))
	{
		return;
	}
	i = 0;
	J0x19:

	// End:0x87 [Loop If]
	if((i < m_aMissionObjectives.Length))
	{
		// End:0x5E
		if((m_aMissionObjectives[i].m_bFailed || m_aMissionObjectives[i].m_bCompleted))
		{
			// [Explicit Continue]
			goto J0x7D;
		}
		m_aMissionObjectives[i].PawnHeard(heard, witness);
		J0x7D:

		(++i);
		// [Loop Continue]
		goto J0x19;
	}
	return;
}

//------------------------------------------------------------------
// PawnSecure
//	
//------------------------------------------------------------------
function PawnSecure(Pawn securedPawn)
{
	local int i;

	// End:0x12
	if((int(m_eMissionObjectiveStatus) != int(0)))
	{
		return;
	}
	i = 0;
	J0x19:

	// End:0x82 [Loop If]
	if((i < m_aMissionObjectives.Length))
	{
		// End:0x5E
		if((m_aMissionObjectives[i].m_bFailed || m_aMissionObjectives[i].m_bCompleted))
		{
			// [Explicit Continue]
			goto J0x78;
		}
		m_aMissionObjectives[i].PawnSecure(securedPawn);
		J0x78:

		(++i);
		// [Loop Continue]
		goto J0x19;
	}
	return;
}

//------------------------------------------------------------------
// EnteredExtractionZone
//	
//------------------------------------------------------------------
function EnteredExtractionZone(Pawn aPawn)
{
	local int i;

	// End:0x0D
	if((aPawn == none))
	{
		return;
	}
	// End:0x1F
	if((int(m_eMissionObjectiveStatus) != int(0)))
	{
		return;
	}
	i = 0;
	J0x26:

	// End:0x8F [Loop If]
	if((i < m_aMissionObjectives.Length))
	{
		// End:0x6B
		if((m_aMissionObjectives[i].m_bFailed || m_aMissionObjectives[i].m_bCompleted))
		{
			// [Explicit Continue]
			goto J0x85;
		}
		m_aMissionObjectives[i].EnteredExtractionZone(aPawn);
		J0x85:

		(++i);
		// [Loop Continue]
		goto J0x26;
	}
	return;
}

//------------------------------------------------------------------
// ExitExtractionZone
//	
//------------------------------------------------------------------
function ExitExtractionZone(Pawn aPawn)
{
	local int i;

	// End:0x0D
	if((aPawn == none))
	{
		return;
	}
	// End:0x1F
	if((int(m_eMissionObjectiveStatus) != int(0)))
	{
		return;
	}
	i = 0;
	J0x26:

	// End:0x8F [Loop If]
	if((i < m_aMissionObjectives.Length))
	{
		// End:0x6B
		if((m_aMissionObjectives[i].m_bFailed || m_aMissionObjectives[i].m_bCompleted))
		{
			// [Explicit Continue]
			goto J0x85;
		}
		m_aMissionObjectives[i].ExitExtractionZone(aPawn);
		J0x85:

		(++i);
		// [Loop Continue]
		goto J0x26;
	}
	return;
}

function R6MissionObjectiveMgr.EMissionObjectiveStatus Update()
{
	local int i, iTotalMissionToComplete, iCompleted, iTotalMissionFailed;

	// End:0x2A
	if((m_bDontUpdateMgr || (InPlanningMode() && (!Level.m_bInGamePlanningActive))))
	{
		return 0;
	}
	// End:0x40
	if((int(m_eMissionObjectiveStatus) != int(0)))
	{
		return m_eMissionObjectiveStatus;
	}
	i = 0;
	J0x47:

	// End:0xBA [Loop If]
	if((i < m_aMissionObjectives.Length))
	{
		// End:0xB0
		if(m_aMissionObjectives[i].isFailed())
		{
			// End:0x90
			if((!m_aMissionObjectives[i].m_bMoralityObjective))
			{
				(++iTotalMissionFailed);
			}
			// End:0xB0
			if(m_aMissionObjectives[i].isMissionAbortedOnFailure())
			{
				SetMissionObjStatus(2);
			}
		}
		(++i);
		// [Loop Continue]
		goto J0x47;
	}
	// End:0xD0
	if((int(m_eMissionObjectiveStatus) == int(2)))
	{
		return m_eMissionObjectiveStatus;
	}
	i = 0;
	J0xD7:

	// End:0x16E [Loop If]
	if((i < m_aMissionObjectives.Length))
	{
		// End:0x102
		if(m_aMissionObjectives[i].m_bMoralityObjective)
		{
			// [Explicit Continue]
			goto J0x164;
		}
		(++iTotalMissionToComplete);
		// End:0x164
		if(((!m_aMissionObjectives[i].isFailed()) && m_aMissionObjectives[i].isCompleted()))
		{
			(++iCompleted);
			// End:0x164
			if(m_aMissionObjectives[i].isMissionCompletedOnSuccess())
			{
				SetMissionObjStatus(1);
			}
		}
		J0x164:

		(++i);
		// [Loop Continue]
		goto J0xD7;
	}
	// End:0x18A
	if((int(m_eMissionObjectiveStatus) == int(1)))
	{
		CompleteMission();
		return m_eMissionObjectiveStatus;
	}
	// End:0x1D0
	if((iTotalMissionToComplete > 0))
	{
		// End:0x1B5
		if((iTotalMissionFailed == iTotalMissionToComplete))
		{
			SetMissionObjStatus(2);
			return m_eMissionObjectiveStatus;			
		}
		else
		{
			// End:0x1D0
			if((iCompleted == iTotalMissionToComplete))
			{
				CompleteMission();
				return m_eMissionObjectiveStatus;
			}
		}
	}
	return 0;
	return;
}

//------------------------------------------------------------------
// AbortMission: Force to abord the mission
//  set all mission objective to false except morality
//------------------------------------------------------------------
function AbortMission()
{
	local int i;

	i = 0;
	J0x07:

	// End:0x4F [Loop If]
	if((i < m_aMissionObjectives.Length))
	{
		// End:0x32
		if(m_aMissionObjectives[i].m_bMoralityObjective)
		{
			// [Explicit Continue]
			goto J0x45;
		}
		SetMissionObjCompleted(m_aMissionObjectives[i], false, false);
		J0x45:

		(++i);
		// [Loop Continue]
		goto J0x07;
	}
	SetMissionObjStatus(2);
	m_GameInfo.UpdateRepMissionObjectives();
	return;
}

//------------------------------------------------------------------
// CompleteMission
//	set all not failed mission to completed
//------------------------------------------------------------------
function CompleteMission()
{
	local int i;

	// End:0x57
	if(m_bOnSuccessAllObjectivesAreCompleted)
	{
		i = 0;
		J0x10:

		// End:0x57 [Loop If]
		if((i < m_aMissionObjectives.Length))
		{
			// End:0x4D
			if((!m_aMissionObjectives[i].m_bFailed))
			{
				SetMissionObjCompleted(m_aMissionObjectives[i], true, false);
			}
			(++i);
			// [Loop Continue]
			goto J0x10;
		}
	}
	SetMissionObjStatus(1);
	m_GameInfo.UpdateRepMissionObjectives();
	return;
}

//------------------------------------------------------------------
// ToggleLog
//	
//------------------------------------------------------------------
function ToggleLog(bool bToggle)
{
	local int i;

	m_bShowLog = bToggle;
	i = 0;
	J0x14:

	// End:0x49 [Loop If]
	if((i < m_aMissionObjectives.Length))
	{
		m_aMissionObjectives[i].ToggleLog(bToggle);
		(++i);
		// [Loop Continue]
		goto J0x14;
	}
	return;
}

//------------------------------------------------------------------
// GetMObjFailed
//  We only check for one reason for the failure. This is why
//  the moralities are checked last.
//------------------------------------------------------------------
function R6MissionObjectiveBase GetMObjFailed()
{
	local int i;
	local string szFailure;

	i = 0;
	J0x07:

	// End:0x81 [Loop If]
	if((i < m_aMissionObjectives.Length))
	{
		// End:0x34
		if((!m_aMissionObjectives[i].isFailed()))
		{
			// [Explicit Continue]
			goto J0x77;
		}
		// End:0x4F
		if(m_aMissionObjectives[i].m_bMoralityObjective)
		{
			// [Explicit Continue]
			goto J0x77;
		}
		// End:0x77
		if((m_aMissionObjectives[i].GetDescriptionFailure() != ""))
		{
			return m_aMissionObjectives[i];
		}
		J0x77:

		(++i);
		// [Loop Continue]
		goto J0x07;
	}
	i = 0;
	J0x88:

	// End:0x104 [Loop If]
	if((i < m_aMissionObjectives.Length))
	{
		// End:0xB5
		if((!m_aMissionObjectives[i].isFailed()))
		{
			// [Explicit Continue]
			goto J0xFA;
		}
		// End:0xD2
		if((!m_aMissionObjectives[i].m_bMoralityObjective))
		{
			// [Explicit Continue]
			goto J0xFA;
		}
		// End:0xFA
		if((m_aMissionObjectives[i].GetDescriptionFailure() != ""))
		{
			return m_aMissionObjectives[i];
		}
		J0xFA:

		(++i);
		// [Loop Continue]
		goto J0x88;
	}
	return;
}

simulated event Destroyed()
{
	local int i;

	super.Destroyed();
	i = 0;
	J0x0D:

	// End:0x3D [Loop If]
	if((i < m_aMissionObjectives.Length))
	{
		m_aMissionObjectives[i].SetMObjMgr(none);
		(++i);
		// [Loop Continue]
		goto J0x0D;
	}
	m_GameInfo = none;
	return;
}

//------------------------------------------------------------------
// SetMissionObjCompleted
//	set completed or failed and check he need to send a feedback
//------------------------------------------------------------------
function SetMissionObjCompleted(R6MissionObjectiveBase mobj, bool bCompleted, bool bFeedback)
{
	// End:0x1E
	if((InPlanningMode() && (!Level.m_bInGamePlanningActive)))
	{
		return;
	}
	// End:0x3B
	if(bCompleted)
	{
		mobj.m_bCompleted = true;		
	}
	else
	{
		mobj.m_bFailed = true;
	}
	// End:0x81
	if((((!bFeedback) || mobj.m_bFeedbackOnCompletionSend) || mobj.m_bFeedbackOnFailureSend))
	{
		return;
	}
	// End:0xEF
	if(mobj.m_bCompleted)
	{
		// End:0xEC
		if((mobj.m_szFeedbackOnCompletion != ""))
		{
			m_GameInfo.BroadcastMissionObjMsg(Level.GetMissionObjLocFile(mobj), "", mobj.m_szFeedbackOnCompletion);
			mobj.m_bFeedbackOnCompletionSend = true;
		}		
	}
	else
	{
		// End:0x148
		if((mobj.m_szFeedbackOnFailure != ""))
		{
			m_GameInfo.BroadcastMissionObjMsg(Level.GetMissionObjLocFile(mobj), "", mobj.m_szFeedbackOnFailure);
			mobj.m_bFeedbackOnFailureSend = true;
		}
	}
	return;
}

defaultproperties
{
	m_bOnSuccessAllObjectivesAreCompleted=true
	bHidden=true
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: function Timer
// REMOVED IN 1.60: function Update
