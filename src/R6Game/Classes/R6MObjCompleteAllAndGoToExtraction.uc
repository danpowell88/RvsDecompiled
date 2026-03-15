//=============================================================================
// R6MObjCompleteAllAndGoToExtraction - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6MObjCompleteAllAndGoToExtraction.uc : 
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//
//  Complete all mission objectives (except Morality AND mission objectives 
//  that are flagged with m_bIfCompletedMissionIsSuccessfull).
//  
//  Only valid for a human player
//
//  Special: in the manager, added at the end of the list of mission objectives 
//
//  fail: if one of the objectives fails (excluding exceptions_
//  success: if all MO are compledted 
//=============================================================================
class R6MObjCompleteAllAndGoToExtraction extends R6MissionObjectiveBase
	editinlinenew
    hidecategories(Object);

function Init()
{
	// End:0x3E
	if(R6MissionObjectiveMgr(m_mgr).m_bEnableCheckForErrors)
	{
		R6GameInfo(m_mgr.Level.Game).CheckForExtractionZone(self);
	}
	return;
}

function EnteredExtractionZone(Pawn aPawn)
{
	local R6MissionObjectiveMgr mgr;
	local int i, iTotal, iTotalCompleted;

	// End:0x39
	if((((m_bCompleted || isFailed()) || (aPawn == none)) || (aPawn.Controller == none)))
	{
		return;
	}
	// End:0x4F
	if((!aPawn.IsAlive()))
	{
		return;
	}
	mgr = R6MissionObjectiveMgr(m_mgr);
	i = 0;
	J0x66:

	// End:0x157 [Loop If]
	if((i < mgr.m_aMissionObjectives.Length))
	{
		// End:0x9C
		if((mgr.m_aMissionObjectives[i] == self))
		{
			// [Explicit Continue]
			goto J0x14D;
		}
		// End:0xC0
		if(mgr.m_aMissionObjectives[i].m_bMoralityObjective)
		{
			// [Explicit Continue]
			goto J0x14D;
		}
		// End:0xE4
		if(mgr.m_aMissionObjectives[i].isMissionCompletedOnSuccess())
		{
			// [Explicit Continue]
			goto J0x14D;
		}
		(++iTotal);
		// End:0x125
		if(mgr.m_aMissionObjectives[i].isFailed())
		{
			R6MissionObjectiveMgr(m_mgr).SetMissionObjCompleted(self, false, true);
			return;
		}
		// End:0x14D
		if(mgr.m_aMissionObjectives[i].isCompleted())
		{
			(++iTotalCompleted);
		}
		J0x14D:

		(++i);
		// [Loop Continue]
		goto J0x66;
	}
	// End:0x185
	if(((iTotal == iTotalCompleted) && (iTotal > 0)))
	{
		mgr.SetMissionObjCompleted(self, true, true);
	}
	// End:0x1F0
	if(m_bShowLog)
	{
		Log(((((("EnteredExtractionZone: completed=" $ string(m_bCompleted)) $ " iTotal=") $ string(iTotal)) $ " iTotalCompleted=") $ string(iTotalCompleted)));
	}
	return;
}

//------------------------------------------------------------------
// isCompleted
//
//------------------------------------------------------------------
function bool isCompleted()
{
	local R6ExtractionZone anExtractionZone;
	local R6Rainbow aRainbow;
	local Controller aController;
	local R6PlayerController pR6PlayerController;
	local R6AIController pAIController;

	// End:0x0B
	if(isFailed())
	{
		return false;
	}
	aController = m_mgr.Level.ControllerList;
	J0x28:

	// End:0xFB [Loop If]
	if((aController != none))
	{
		pR6PlayerController = R6PlayerController(aController);
		// End:0x65
		if((pR6PlayerController != none))
		{
			aRainbow = pR6PlayerController.m_pawn;			
		}
		else
		{
			pAIController = R6AIController(aController);
			// End:0x99
			if((pAIController != none))
			{
				aRainbow = R6Rainbow(pAIController.m_r6pawn);
			}
		}
		// End:0xE4
		if((aRainbow != none))
		{
			// End:0xCC
			foreach aRainbow.TouchingActors(Class'R6Game.R6ExtractionZone', anExtractionZone)
			{
				EnteredExtractionZone(aRainbow);
				// End:0xCC
				break;				
			}			
			// End:0xE4
			if((m_bCompleted || m_bFailed))
			{
				// [Explicit Break]
				goto J0xFB;
			}
		}
		aController = aController.nextController;
		// [Loop Continue]
		goto J0x28;
	}
	J0xFB:

	return m_bCompleted;
	return;
}

defaultproperties
{
	m_bIfCompletedMissionIsSuccessfull=true
	m_bIfFailedMissionIsAborted=true
	m_bEndOfListOfObjectives=true
	m_szDescription="Completed all mission objetives"
}
