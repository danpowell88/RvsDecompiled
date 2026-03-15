//=============================================================================
// R6MObjGroupMission - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
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
class R6MObjGroupMission extends R6MissionObjectiveBase
	editinlinenew
    hidecategories(Object);

var() int m_iMinSuccessRequired;  // minimum number of mission successful required for having a "mission completed"
var() int m_iMaxFailedAccepted;  // maximum number of mission failed accepted before having "mission failed"
var() editinline array<editinline R6MissionObjectiveBase> m_aSubMissionObjectives;

//------------------------------------------------------------------
// Init
//	
//------------------------------------------------------------------
function Init()
{
	local R6MissionObjectiveMgr mgr;
	local int i, Index;
	local array<R6MissionObjectiveBase> aTempMObj;

	// End:0x118
	if(R6MissionObjectiveMgr(m_mgr).m_bEnableCheckForErrors)
	{
		// End:0x4E
		if((m_aSubMissionObjectives.Length == 0))
		{
			logMObj("m_aSubMissionObjectives.Length == 0");
		}
		// End:0x7B
		if((m_iMinSuccessRequired <= 0))
		{
			logMObj("m_iMinSuccessRequired <= 0");
		}
		// End:0xCB
		if((m_iMinSuccessRequired > m_aSubMissionObjectives.Length))
		{
			logMObj("m_iMinSuccessRequired >  m_aSubMissionObjectives.Length ");
		}
		// End:0x118
		if((m_iMaxFailedAccepted > m_aSubMissionObjectives.Length))
		{
			logMObj("m_iMaxFailedAccepted > m_aSubMissionObjectives.Length");
		}
	}
	m_iMaxFailedAccepted = Clamp(m_iMaxFailedAccepted, 0, m_aSubMissionObjectives.Length);
	m_iMinSuccessRequired = Clamp(m_iMinSuccessRequired, 1, m_aSubMissionObjectives.Length);
	i = 0;
	J0x147:

	// End:0x199 [Loop If]
	if((i < m_aSubMissionObjectives.Length))
	{
		// End:0x18F
		if((!m_aSubMissionObjectives[i].m_bEndOfListOfObjectives))
		{
			aTempMObj[Index] = m_aSubMissionObjectives[i];
			(++Index);
		}
		(++i);
		// [Loop Continue]
		goto J0x147;
	}
	i = 0;
	J0x1A0:

	// End:0x1F0 [Loop If]
	if((i < m_aSubMissionObjectives.Length))
	{
		// End:0x1E6
		if(m_aSubMissionObjectives[i].m_bEndOfListOfObjectives)
		{
			aTempMObj[Index] = m_aSubMissionObjectives[i];
			(++Index);
		}
		(++i);
		// [Loop Continue]
		goto J0x1A0;
	}
	mgr = R6MissionObjectiveMgr(m_mgr);
	i = 0;
	J0x207:

	// End:0x2A7 [Loop If]
	if((i < m_aSubMissionObjectives.Length))
	{
		m_aSubMissionObjectives[i] = aTempMObj[i];
		m_aSubMissionObjectives[i].m_mgr = m_mgr;
		m_aSubMissionObjectives[i].Init();
		// End:0x29D
		if(mgr.m_bShowLog)
		{
			Log(((("    " $ string(i)) $ ": ") $ m_aSubMissionObjectives[i].getDescription()));
		}
		(++i);
		// [Loop Continue]
		goto J0x207;
	}
	return;
}

function ToggleLog(bool bToggle)
{
	local int i;

	super.ToggleLog(bToggle);
	i = 0;
	J0x13:

	// End:0x48 [Loop If]
	if((i < m_aSubMissionObjectives.Length))
	{
		m_aSubMissionObjectives[i].ToggleLog(bToggle);
		(++i);
		// [Loop Continue]
		goto J0x13;
	}
	return;
}

//------------------------------------------------------------------
// PawnKilled
//	
//------------------------------------------------------------------
function PawnKilled(Pawn killedPawn)
{
	local int i;

	i = 0;
	J0x07:

	// End:0x70 [Loop If]
	if((i < m_aSubMissionObjectives.Length))
	{
		// End:0x4C
		if((m_aSubMissionObjectives[i].m_bFailed || m_aSubMissionObjectives[i].m_bCompleted))
		{
			// [Explicit Continue]
			goto J0x66;
		}
		m_aSubMissionObjectives[i].PawnKilled(killedPawn);
		J0x66:

		(++i);
		// [Loop Continue]
		goto J0x07;
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

	i = 0;
	J0x07:

	// End:0x75 [Loop If]
	if((i < m_aSubMissionObjectives.Length))
	{
		// End:0x4C
		if((m_aSubMissionObjectives[i].m_bFailed || m_aSubMissionObjectives[i].m_bCompleted))
		{
			// [Explicit Continue]
			goto J0x6B;
		}
		m_aSubMissionObjectives[i].IObjectInteract(aPawn, anInteractiveObject);
		J0x6B:

		(++i);
		// [Loop Continue]
		goto J0x07;
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

	i = 0;
	J0x07:

	// End:0x75 [Loop If]
	if((i < m_aSubMissionObjectives.Length))
	{
		// End:0x4C
		if((m_aSubMissionObjectives[i].m_bFailed || m_aSubMissionObjectives[i].m_bCompleted))
		{
			// [Explicit Continue]
			goto J0x6B;
		}
		m_aSubMissionObjectives[i].IObjectDestroyed(aPawn, anInteractiveObject);
		J0x6B:

		(++i);
		// [Loop Continue]
		goto J0x07;
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

	i = 0;
	J0x07:

	// End:0x75 [Loop If]
	if((i < m_aSubMissionObjectives.Length))
	{
		// End:0x4C
		if((m_aSubMissionObjectives[i].m_bFailed || m_aSubMissionObjectives[i].m_bCompleted))
		{
			// [Explicit Continue]
			goto J0x6B;
		}
		m_aSubMissionObjectives[i].PawnSeen(seen, witness);
		J0x6B:

		(++i);
		// [Loop Continue]
		goto J0x07;
	}
	return;
}

//------------------------------------------------------------------
// PawnHeard
//	
//------------------------------------------------------------------
function PawnHeard(Pawn seen, Pawn witness)
{
	local int i;

	i = 0;
	J0x07:

	// End:0x75 [Loop If]
	if((i < m_aSubMissionObjectives.Length))
	{
		// End:0x4C
		if((m_aSubMissionObjectives[i].m_bFailed || m_aSubMissionObjectives[i].m_bCompleted))
		{
			// [Explicit Continue]
			goto J0x6B;
		}
		m_aSubMissionObjectives[i].PawnHeard(seen, witness);
		J0x6B:

		(++i);
		// [Loop Continue]
		goto J0x07;
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

	i = 0;
	J0x07:

	// End:0x70 [Loop If]
	if((i < m_aSubMissionObjectives.Length))
	{
		// End:0x4C
		if((m_aSubMissionObjectives[i].m_bFailed || m_aSubMissionObjectives[i].m_bCompleted))
		{
			// [Explicit Continue]
			goto J0x66;
		}
		m_aSubMissionObjectives[i].PawnSecure(securedPawn);
		J0x66:

		(++i);
		// [Loop Continue]
		goto J0x07;
	}
	return;
}

//------------------------------------------------------------------
// EnteredExtractionZone
//	
//------------------------------------------------------------------
function EnteredExtractionZone(Pawn Pawn)
{
	local int i;

	i = 0;
	J0x07:

	// End:0x70 [Loop If]
	if((i < m_aSubMissionObjectives.Length))
	{
		// End:0x4C
		if((m_aSubMissionObjectives[i].m_bFailed || m_aSubMissionObjectives[i].m_bCompleted))
		{
			// [Explicit Continue]
			goto J0x66;
		}
		m_aSubMissionObjectives[i].EnteredExtractionZone(Pawn);
		J0x66:

		(++i);
		// [Loop Continue]
		goto J0x07;
	}
	return;
}

//------------------------------------------------------------------
// ExitExtractionZone
//	
//------------------------------------------------------------------
function ExitExtractionZone(Pawn Pawn)
{
	local int i;

	i = 0;
	J0x07:

	// End:0x70 [Loop If]
	if((i < m_aSubMissionObjectives.Length))
	{
		// End:0x4C
		if((m_aSubMissionObjectives[i].m_bFailed || m_aSubMissionObjectives[i].m_bCompleted))
		{
			// [Explicit Continue]
			goto J0x66;
		}
		m_aSubMissionObjectives[i].ExitExtractionZone(Pawn);
		J0x66:

		(++i);
		// [Loop Continue]
		goto J0x07;
	}
	return;
}

//------------------------------------------------------------------
// isCompleted
//
//------------------------------------------------------------------
function bool isCompleted()
{
	local int i, iNum;

	// End:0x1B
	if((m_bCompleted || m_bFailed))
	{
		return m_bCompleted;
	}
	i = 0;
	J0x22:

	// End:0xDE [Loop If]
	if((i < m_aSubMissionObjectives.Length))
	{
		// End:0xD4
		if(m_aSubMissionObjectives[i].isCompleted())
		{
			// End:0xCD
			if(m_aSubMissionObjectives[i].isMissionCompletedOnSuccess())
			{
				// End:0xB6
				if(m_bShowLog)
				{
					logX((" mission is completed on success because of " $ m_aSubMissionObjectives[i].getDescription()));
				}
				R6MissionObjectiveMgr(m_mgr).SetMissionObjCompleted(self, true, true);
			}
			(iNum++);
		}
		(++i);
		// [Loop Continue]
		goto J0x22;
	}
	// End:0xEE
	if(m_bCompleted)
	{
		return m_bCompleted;
	}
	// End:0x114
	if((iNum >= m_iMinSuccessRequired))
	{
		R6MissionObjectiveMgr(m_mgr).SetMissionObjCompleted(self, true, true);
	}
	// End:0x176
	if((m_bCompleted && m_bShowLog))
	{
		logX(((("is completed. num completed=" $ string(iNum)) $ " minSuccessRequired=") $ string(m_iMinSuccessRequired)));
	}
	return m_bCompleted;
	return;
}

//------------------------------------------------------------------
// isFailed
//
//------------------------------------------------------------------
function bool isFailed()
{
	local int i, iNum;

	// End:0x1B
	if((m_bFailed || m_bCompleted))
	{
		return m_bFailed;
	}
	i = 0;
	J0x22:

	// End:0xDB [Loop If]
	if((i < m_aSubMissionObjectives.Length))
	{
		// End:0xD1
		if(m_aSubMissionObjectives[i].isFailed())
		{
			// End:0xCA
			if(m_aSubMissionObjectives[i].m_bIfFailedMissionIsAborted)
			{
				R6MissionObjectiveMgr(m_mgr).SetMissionObjCompleted(self, false, true);
				// End:0xCA
				if(m_bShowLog)
				{
					logX(("is failed. Mission is aborted because of " $ m_aSubMissionObjectives[i].getDescription()));
				}
			}
			(iNum++);
		}
		(++i);
		// [Loop Continue]
		goto J0x22;
	}
	// End:0xEB
	if(m_bFailed)
	{
		return m_bFailed;
	}
	// End:0xF8
	if((iNum == 0))
	{
		return false;
	}
	// End:0x11E
	if((iNum >= m_iMaxFailedAccepted))
	{
		R6MissionObjectiveMgr(m_mgr).SetMissionObjCompleted(self, false, true);
	}
	// End:0x179
	if((m_bShowLog && m_bFailed))
	{
		logX(((("is failed. num failed=" $ string(iNum)) $ " maxFailedAccepted=") $ string(m_iMaxFailedAccepted)));
	}
	return m_bFailed;
	return;
}

function string GetDescriptionFailure()
{
	local int i, iNum;

	// End:0x0E
	if((!m_bFailed))
	{
		return "";
	}
	i = 0;
	J0x15:

	// End:0x7B [Loop If]
	if((i < m_aSubMissionObjectives.Length))
	{
		// End:0x71
		if((m_aSubMissionObjectives[i].isFailed() && (m_aSubMissionObjectives[i].GetDescriptionFailure() != "")))
		{
			return m_aSubMissionObjectives[i].GetDescriptionFailure();
		}
		(++i);
		// [Loop Continue]
		goto J0x15;
	}
	return;
}

function Sound GetSoundFailure()
{
	local int i;

	// End:0x0D
	if((!m_bFailed))
	{
		return none;
	}
	i = 0;
	J0x14:

	// End:0x5C [Loop If]
	if((i < m_aSubMissionObjectives.Length))
	{
		// End:0x52
		if(m_aSubMissionObjectives[i].isFailed())
		{
			return m_aSubMissionObjectives[i].GetSoundFailure();
		}
		(++i);
		// [Loop Continue]
		goto J0x14;
	}
	return m_sndSoundFailure;
	return;
}

function int GetNumSubMission()
{
	return m_aSubMissionObjectives.Length;
	return;
}

function R6MissionObjectiveBase GetSubMissionObjective(int Index)
{
	return m_aSubMissionObjectives[Index];
	return;
}

function SetMObjMgr(Actor aMObjMgr)
{
	local int i;

	super.SetMObjMgr(aMObjMgr);
	i = 0;
	J0x12:

	// End:0x46 [Loop If]
	if((i < m_aSubMissionObjectives.Length))
	{
		m_aSubMissionObjectives[i].SetMObjMgr(aMObjMgr);
		(++i);
		// [Loop Continue]
		goto J0x12;
	}
	return;
}

function Reset()
{
	local int i;

	super.Reset();
	i = 0;
	J0x0D:

	// End:0x3C [Loop If]
	if((i < m_aSubMissionObjectives.Length))
	{
		m_aSubMissionObjectives[i].Reset();
		(++i);
		// [Loop Continue]
		goto J0x0D;
	}
	return;
}

defaultproperties
{
	m_iMinSuccessRequired=1
	m_szDescription="This a group mission"
}
