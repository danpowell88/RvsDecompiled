//=============================================================================
// R6MObjRecon - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6MObjRecon.uc : 
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
// Only for rainbow 
//
// fail: if kill, secure, make noise and is seen
//=============================================================================
class R6MObjRecon extends R6MissionObjectiveBase
	editinlinenew
    hidecategories(Object);

var() bool m_bCanKill;
var() bool m_bCanSecure;
var() bool m_bCanMakeNoise;
var() bool m_bCanSeeMe;

//------------------------------------------------------------------
// Init
//	
//------------------------------------------------------------------
function Init()
{
	m_bIfCompletedMissionIsSuccessfull = true;
	return;
}

//------------------------------------------------------------------
// PawnKilled
//	
//------------------------------------------------------------------
function PawnKilled(Pawn killed)
{
	local R6Pawn P;

	// End:0x0B
	if(m_bCanKill)
	{
		return;
	}
	P = R6Pawn(killed);
	// End:0x31
	if((P.m_KilledBy == none))
	{
		return;
	}
	// End:0x55
	if((int(P.m_KilledBy.m_ePawnType) != int(1)))
	{
		return;
	}
	R6MissionObjectiveMgr(m_mgr).SetMissionObjCompleted(self, false, true);
	// End:0x97
	if(m_bShowLog)
	{
		logX("PawnKilled. mission failed");
	}
	return;
}

//------------------------------------------------------------------
// PawnSecure
//	
//------------------------------------------------------------------
function PawnSecure(Pawn securedPawn)
{
	// End:0x0B
	if(m_bCanSecure)
	{
		return;
	}
	R6MissionObjectiveMgr(m_mgr).SetMissionObjCompleted(self, false, true);
	// End:0x4D
	if(m_bShowLog)
	{
		logX("PawnSecure. mission failed");
	}
	return;
}

//------------------------------------------------------------------
// PawnSeen
//	
//------------------------------------------------------------------
function PawnSeen(Pawn seen, Pawn witness)
{
	// End:0x0B
	if(m_bCanSeeMe)
	{
		return;
	}
	// End:0x26
	if((int(seen.m_ePawnType) != int(1)))
	{
		return;
	}
	R6MissionObjectiveMgr(m_mgr).SetMissionObjCompleted(self, false, true);
	// End:0x66
	if(m_bShowLog)
	{
		logX("PawnSeen. mission failed");
	}
	return;
}

//------------------------------------------------------------------
// PawnHeard
//	
//------------------------------------------------------------------
function PawnHeard(Pawn seen, Pawn witness)
{
	// End:0x0B
	if(m_bCanMakeNoise)
	{
		return;
	}
	// End:0x26
	if((int(seen.m_ePawnType) != int(1)))
	{
		return;
	}
	R6MissionObjectiveMgr(m_mgr).SetMissionObjCompleted(self, false, true);
	// End:0x67
	if(m_bShowLog)
	{
		logX("PawnHeard. mission failed");
	}
	return;
}

defaultproperties
{
	m_bCanMakeNoise=true
	m_bIfCompletedMissionIsSuccessfull=true
	m_bIfFailedMissionIsAborted=true
	m_sndSoundFailure=Sound'Voices_Control_MissionFailed.Play_TeamSpotted'
	m_szDescription="Recon: don't kill anyone and don't get caugh"
	m_szDescriptionInMenu="AvoidDetection"
	m_szDescriptionFailure="YouWereDetected"
}
