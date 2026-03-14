//=============================================================================
// R6MObjGoToExtraction - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6MObjGoToExtraction.uc : 
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  fail: if pawn killed
//  success: if he is in a extraction zone
//=============================================================================
class R6MObjGoToExtraction extends R6MissionObjectiveBase
	editinlinenew
 hidecategories(Object);

var() bool m_bExtractAtLeastOneRainbow;  // at least one rainbow to extract (anyone)
var R6Pawn m_pawnToExtract;  // the pawn to extract OR

function Init()
{
	// End:0x3E
	if(R6MissionObjectiveMgr(m_mgr).m_bEnableCheckForErrors)
	{
		R6GameInfo(m_mgr.Level.Game).CheckForExtractionZone(self);
	}
	return;
}

//------------------------------------------------------------------
// SetPawnToExtract 
//	specify which pawn to extract
//------------------------------------------------------------------
function SetPawnToExtract(R6Pawn aPawn)
{
	m_bExtractAtLeastOneRainbow = false;
	m_pawnToExtract = aPawn;
	return;
}

//------------------------------------------------------------------
// Reset
//	
//------------------------------------------------------------------
function Reset()
{
	super.Reset();
	m_pawnToExtract = none;
	return;
}

//------------------------------------------------------------------
// PawnKilled
//	
//------------------------------------------------------------------
function PawnKilled(Pawn killedPawn)
{
	// End:0x16
	if(__NFUN_119__(R6Pawn(killedPawn), m_pawnToExtract))
	{
		return;
	}
	R6MissionObjectiveMgr(m_mgr).SetMissionObjCompleted(self, false, true);
	// End:0x80
	if(m_bShowLog)
	{
		__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__("PawnKilled: m_pawnToExtract= ", string(m_pawnToExtract.Name)), " bFailed="), string(m_bFailed)));
	}
	return;
}

//------------------------------------------------------------------
// EnteredExtractionZone
//	
//------------------------------------------------------------------
function EnteredExtractionZone(Pawn aPawn)
{
	// End:0x27
	if(m_bExtractAtLeastOneRainbow)
	{
		// End:0x24
		if(__NFUN_155__(int(aPawn.m_ePawnType), int(1)))
		{
			return;
		}		
	}
	else
	{
		// End:0x3D
		if(__NFUN_119__(R6Pawn(aPawn), m_pawnToExtract))
		{
			return;
		}
	}
	R6MissionObjectiveMgr(m_mgr).SetMissionObjCompleted(self, true, true);
	// End:0x128
	if(m_bShowLog)
	{
		// End:0xC3
		if(__NFUN_119__(m_pawnToExtract, none))
		{
			__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__("EnteredExtractionZone: m_pawnToExtract= ", string(m_pawnToExtract.Name)), " bCompleted="), string(m_bCompleted)));			
		}
		else
		{
			__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__("EnteredExtractionZone: m_bExtractAtLeastOneRainbow = ", string(aPawn.Name)), " bCompleted="), string(m_bCompleted)));
		}
	}
	return;
}

defaultproperties
{
	m_bExtractAtLeastOneRainbow=true
	m_bIfCompletedMissionIsSuccessfull=true
	m_bIfFailedMissionIsAborted=true
	m_szDescription="Go to extraction zone"
}
