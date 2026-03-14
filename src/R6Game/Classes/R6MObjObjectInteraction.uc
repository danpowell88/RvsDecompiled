//=============================================================================
// R6MObjObjectInteraction - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6MObjObjectInteraction.uc : 
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
// Only for rainbow human controller
//
//=============================================================================
class R6MObjObjectInteraction extends R6MissionObjectiveBase
	editinlinenew
 hidecategories(Object);

var() bool m_bIfDeviceIsActivatedObjectiveIsCompleted;
var() bool m_bIfDeviceIsActivatedObjectiveIsFailed;
var() bool m_bIfDeviceIsDeactivatedObjectiveIsCompleted;
var() bool m_bIfDeviceIsDeactivatedObjectiveIsFailed;
var() bool m_bIfDestroyedObjectiveIsCompleted;
var() bool m_bIfDestroyedObjectiveIsFailed;
var() R6IOObject m_r6IOObject;

//------------------------------------------------------------------
// Init
//	
//------------------------------------------------------------------
function Init()
{
	// End:0xB8
	if(R6MissionObjectiveMgr(m_mgr).m_bEnableCheckForErrors)
	{
		// End:0x44
		if(__NFUN_114__(m_r6IOObject, none))
		{
			logMObj("m_r6IOObject not specified");
		}
		// End:0xB8
		if(__NFUN_130__(m_bIfDestroyedObjectiveIsCompleted, m_bIfDestroyedObjectiveIsFailed))
		{
			logMObj("both are set to true m_bIfDestroyedObjectiveIsCompleted, m_bIfDestroyedObjectiveIsFailed");
		}
	}
	return;
}

//------------------------------------------------------------------
// IObjectInteract
//	
//------------------------------------------------------------------
function IObjectInteract(Pawn aPawn, Actor anInteractiveObject)
{
	// End:0x11
	if(__NFUN_119__(m_r6IOObject, anInteractiveObject))
	{
		return;
	}
	// End:0x69
	if(m_r6IOObject.m_bIsActivated)
	{
		// End:0x46
		if(m_bIfDeviceIsActivatedObjectiveIsCompleted)
		{
			R6MissionObjectiveMgr(m_mgr).SetMissionObjCompleted(self, true, true);			
		}
		else
		{
			// End:0x66
			if(m_bIfDeviceIsActivatedObjectiveIsFailed)
			{
				R6MissionObjectiveMgr(m_mgr).SetMissionObjCompleted(self, false, true);
			}
		}		
	}
	else
	{
		// End:0x8C
		if(m_bIfDeviceIsDeactivatedObjectiveIsCompleted)
		{
			R6MissionObjectiveMgr(m_mgr).SetMissionObjCompleted(self, true, true);			
		}
		else
		{
			// End:0xAC
			if(m_bIfDeviceIsDeactivatedObjectiveIsFailed)
			{
				R6MissionObjectiveMgr(m_mgr).SetMissionObjCompleted(self, false, true);
			}
		}
	}
	return;
}

//------------------------------------------------------------------
// IObjectDestroyed
//	
//------------------------------------------------------------------
function IObjectDestroyed(Pawn aPawn, Actor anInteractiveObject)
{
	// End:0x11
	if(__NFUN_119__(m_r6IOObject, anInteractiveObject))
	{
		return;
	}
	// End:0x34
	if(m_bIfDestroyedObjectiveIsCompleted)
	{
		R6MissionObjectiveMgr(m_mgr).SetMissionObjCompleted(self, true, true);		
	}
	else
	{
		// End:0x54
		if(m_bIfDestroyedObjectiveIsFailed)
		{
			R6MissionObjectiveMgr(m_mgr).SetMissionObjCompleted(self, false, true);
		}
	}
	return;
}

defaultproperties
{
	m_sndSoundFailure=Sound'Voices_Control_MissionFailed.Play_MissionFailed'
	m_szDescription="Interact with object"
}
