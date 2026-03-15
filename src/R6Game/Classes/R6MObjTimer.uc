//=============================================================================
// R6MObjTimer - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6MObjTimer.uc : 
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//=============================================================================
class R6MObjTimer extends R6MissionObjectiveBase
	editinlinenew
    hidecategories(Object);

function TimerCallback(float fTime)
{
	// End:0x30
	if(m_bShowLog)
	{
		logX("failed: timer countdown is zero");
	}
	R6MissionObjectiveMgr(m_mgr).SetMissionObjCompleted(self, false, true);
	return;
}

defaultproperties
{
	m_bIfFailedMissionIsAborted=true
	m_sndSoundFailure=Sound'Voices_Control_MissionFailed.Play_MissionFailed'
	m_szDescription="Timer countdown"
	m_szFeedbackOnFailure="TimeIsUp"
}
