//=============================================================================
// R6MObjPreventBombDetonation - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6MObjPreventBombDetonation.uc : 
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
// Only for rainbow human controller
//
// fail: if kill, secure, make noise and is seen
//=============================================================================
class R6MObjPreventBombDetonation extends R6MObjObjectInteraction
	editinlinenew
 hidecategories(Object);

var() bool m_bIfDetonateObjectiveIsFailed;
var() bool m_bIfDetonateObjectiveIsCompleted;

//------------------------------------------------------------------
// IObjectDestroyed
//	
//------------------------------------------------------------------
function IObjectDestroyed(Pawn aPawn, Actor anInteractiveObject)
{
	local R6IOBomb bomb;

	// End:0x11
	if(__NFUN_119__(m_r6IOObject, anInteractiveObject))
	{
		return;
	}
	bomb = R6IOBomb(m_r6IOObject);
	// End:0x79
	if(bomb.m_bExploded)
	{
		// End:0x56
		if(m_bIfDetonateObjectiveIsFailed)
		{
			R6MissionObjectiveMgr(m_mgr).SetMissionObjCompleted(self, false, true);			
		}
		else
		{
			// End:0x76
			if(m_bIfDetonateObjectiveIsCompleted)
			{
				R6MissionObjectiveMgr(m_mgr).SetMissionObjCompleted(self, true, true);
			}
		}		
	}
	else
	{
		// End:0x9C
		if(m_bIfDestroyedObjectiveIsCompleted)
		{
			R6MissionObjectiveMgr(m_mgr).SetMissionObjCompleted(self, true, true);			
		}
		else
		{
			// End:0xBC
			if(m_bIfDestroyedObjectiveIsFailed)
			{
				R6MissionObjectiveMgr(m_mgr).SetMissionObjCompleted(self, false, true);
			}
		}
	}
	return;
}

defaultproperties
{
	m_bIfDetonateObjectiveIsFailed=true
	m_bIfDeviceIsDeactivatedObjectiveIsCompleted=true
	m_sndSoundFailure=Sound'Voices_Control_MissionFailed.Play_BombDetonated'
	m_szDescription="Prevent bomb detonation"
	m_szDescriptionInMenu="PreventBombDetonation"
	m_szDescriptionFailure="BombHasDetonated"
}
