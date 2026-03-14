//=============================================================================
// R6DZonePath - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6DZonePath.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/10/11 * Created by Guillaume Borgia
//=============================================================================
class R6DZonePath extends R6DeploymentZone
	native
 placeable;

enum EInformTeam
{
	INFO_EnterPath,                 // 0
	INFO_ReachNode,                 // 1
	INFO_FinishWaiting,             // 2
	INFO_Engage,                    // 3
	INFO_ExitPath,                  // 4
	INFO_Dead                       // 5
};

var(R6DZone) bool m_bCycle;
var(R6DZone) bool m_bSelectNodeInEditor;
// Terro team variable
var(R6DZone) bool m_bActAsGroup;
var(Debug) bool bShowLog;
var(R6DZone) /*0x00000000-0x80000000*/ editinline array</*0x00000000-0x80000000*/ editinline R6DZonePathNode> m_aNode;

//============================================================================
// GetNodeIndex - 
//============================================================================
function int GetNodeIndex(R6DZonePathNode Node)
{
	local int i;

	i = 0;
	J0x07:

	// End:0x3C [Loop If]
	if(__NFUN_150__(i, m_aNode.Length))
	{
		// End:0x32
		if(__NFUN_114__(m_aNode[i], Node))
		{
			return i;
		}
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x07;
	}
	return -1;
	return;
}

//============================================================================
// GetNextNode - 
//============================================================================
function R6DZonePathNode GetNextNode(R6DZonePathNode Node)
{
	local int Index;

	Index = GetNodeIndex(Node);
	// End:0x4A
	if(__NFUN_155__(Index, -1))
	{
		__NFUN_165__(Index);
		// End:0x3E
		if(__NFUN_153__(Index, m_aNode.Length))
		{
			Index = 0;
		}
		return m_aNode[Index];
	}
	return none;
	return;
}

//============================================================================
// GetPreviousNode - 
//============================================================================
function R6DZonePathNode GetPreviousNode(R6DZonePathNode Node)
{
	local int Index;

	Index = GetNodeIndex(Node);
	// End:0x4A
	if(__NFUN_155__(Index, -1))
	{
		// End:0x37
		if(__NFUN_154__(Index, 0))
		{
			Index = m_aNode.Length;
		}
		__NFUN_166__(Index);
		return m_aNode[Index];
	}
	return none;
	return;
}

//============================================================================
// FindNearestNodeInPath - 
//============================================================================
function R6DZonePathNode FindNearestNode(Actor Pawn)
{
	local R6DZonePathNode Best, r6node;
	local float fBestDistSqr, fDistSqr;
	local Vector vDist;
	local int i;

	i = 0;
	J0x07:

	// End:0xBC [Loop If]
	if(__NFUN_150__(i, m_aNode.Length))
	{
		r6node = m_aNode[i];
		vDist = __NFUN_216__(Pawn.Location, r6node.Location);
		fDistSqr = __NFUN_174__(__NFUN_171__(vDist.X, vDist.X), __NFUN_171__(vDist.Y, vDist.Y));
		// End:0xB2
		if(__NFUN_132__(__NFUN_176__(fDistSqr, fBestDistSqr), __NFUN_154__(i, 0)))
		{
			fBestDistSqr = fDistSqr;
			Best = r6node;
		}
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x07;
	}
	return Best;
	return;
}

//============================================================================
// BOOL IsLeader - 
//============================================================================
function bool IsLeader(R6Terrorist terro)
{
	// End:0x0D
	if(__NFUN_129__(m_bActAsGroup))
	{
		return true;
	}
	__NFUN_1834__();
	// End:0x26
	if(__NFUN_114__(m_aTerrorist[0], terro))
	{
		return true;		
	}
	else
	{
		return false;
	}
	return;
}

//============================================================================
// R6Terrorist GetLeader - 
//============================================================================
function R6Terrorist GetLeader()
{
	return m_aTerrorist[0];
	return;
}

function Vector GetRandomPointToNode(R6DZonePathNode Node)
{
	local Rotator R;
	local int iDistance;
	local Vector vDestination;

	R.Yaw = __NFUN_144__(__NFUN_167__(32767), 2);
	iDistance = __NFUN_167__(int(Node.m_fRadius));
	vDestination = __NFUN_215__(Node.Location, __NFUN_212__(Vector(R), float(iDistance)));
	return vDestination;
	return;
}

//============================================================================
// GetNextNodeForTerro - 
//============================================================================
function SetNextNodeForTerro(R6TerroristAI terro)
{
	local int Index;
	local R6DZonePathNode nextNode;

	// End:0x37
	if(__NFUN_114__(terro.m_currentNode, none))
	{
		terro.m_currentNode = FindNearestNode(terro.m_pawn);
	}
	// End:0xAE
	if(__NFUN_129__(m_bCycle))
	{
		Index = GetNodeIndex(terro.m_currentNode);
		// End:0x81
		if(__NFUN_154__(Index, 0))
		{
			terro.m_pawn.m_bPatrolForward = true;
		}
		// End:0xAE
		if(__NFUN_154__(Index, __NFUN_147__(m_aNode.Length, 1)))
		{
			terro.m_pawn.m_bPatrolForward = false;
		}
	}
	// End:0xE6
	if(terro.m_pawn.m_bPatrolForward)
	{
		nextNode = GetNextNode(terro.m_currentNode);		
	}
	else
	{
		nextNode = GetPreviousNode(terro.m_currentNode);
	}
	terro.m_currentNode = nextNode;
	return;
}

//============================================================================
// BOOL IsAllTerroWaiting - 
//============================================================================
function bool IsAllTerroWaiting()
{
	local int i;

	i = 0;
	J0x07:

	// End:0x62 [Loop If]
	if(__NFUN_150__(i, m_aTerrorist.Length))
	{
		// End:0x58
		if(__NFUN_132__(__NFUN_114__(m_aTerrorist[i].m_controller, none), __NFUN_129__(m_aTerrorist[i].m_controller.m_bWaiting)))
		{
			return false;
		}
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x07;
	}
	return true;
	return;
}

//============================================================================
// GoToNextNode - 
//============================================================================
function GoToNextNode(R6TerroristAI terroAI)
{
	local R6TerroristAI leaderAI;
	local int i;
	local Vector vGoal;

	// End:0x3A
	if(__NFUN_130__(m_bActAsGroup, __NFUN_129__(IsAllTerroWaiting())))
	{
		// End:0x38
		if(bShowLog)
		{
			__NFUN_231__("Not all terro waiting");
		}
		return;
	}
	SetNextNodeForTerro(terroAI);
	vGoal = GetRandomPointToNode(terroAI.m_currentNode);
	// End:0x1F4
	if(m_bActAsGroup)
	{
		__NFUN_1837__(terroAI.m_currentNode.Location);
		i = 0;
		J0x89:

		// End:0x1F1 [Loop If]
		if(__NFUN_150__(i, m_aTerrorist.Length))
		{
			m_aTerrorist[i].m_controller.m_currentNode = terroAI.m_currentNode;
			// End:0xF6
			if(__NFUN_154__(i, 0))
			{
				m_aTerrorist[i].m_controller.GotoNode(vGoal);
				// [Explicit Continue]
				goto J0x1E7;
			}
			// End:0x147
			if(__NFUN_180__(__NFUN_173__(float(i), float(3)), float(1)))
			{
				m_aTerrorist[i].m_controller.FollowLeader(m_aTerrorist[__NFUN_147__(i, 1)], vect(75.0000000, 75.0000000, 0.0000000));
				// [Explicit Continue]
				goto J0x1E7;
			}
			// End:0x199
			if(__NFUN_180__(__NFUN_173__(float(i), float(3)), float(2)))
			{
				m_aTerrorist[i].m_controller.FollowLeader(m_aTerrorist[__NFUN_147__(i, 1)], vect(-25.0000000, -150.0000000, 0.0000000));
				// [Explicit Continue]
				goto J0x1E7;
			}
			// End:0x1E7
			if(__NFUN_180__(__NFUN_173__(float(i), float(3)), float(0)))
			{
				m_aTerrorist[i].m_controller.FollowLeader(m_aTerrorist[__NFUN_147__(i, 1)], vect(25.0000000, 75.0000000, 0.0000000));
			}
			J0x1E7:

			__NFUN_165__(i);
			// [Loop Continue]
			goto J0x89;
		}		
	}
	else
	{
		terroAI.GotoNode(vGoal);
	}
	return;
}

//============================================================================
// StartWaiting - 
//============================================================================
function StartWaiting(R6TerroristAI terroAI)
{
	local int iWaitingTime, iFacingTime;
	local Rotator rDirection, rRefDir;
	local int i, iYawOffset;

	// End:0x3A
	if(__NFUN_130__(m_bActAsGroup, __NFUN_129__(IsAllTerroWaiting())))
	{
		// End:0x38
		if(bShowLog)
		{
			__NFUN_231__("Not all terro waiting");
		}
		return;
	}
	// End:0x86
	if(terroAI.m_currentNode.m_bWait)
	{
		iWaitingTime = int(terroAI.GetWaitingTime());
		iFacingTime = int(terroAI.GetFacingTime());		
	}
	else
	{
		iWaitingTime = 0;
		iFacingTime = 0;
	}
	// End:0xCF
	if(terroAI.m_currentNode.bDirectional)
	{
		rRefDir = terroAI.m_currentNode.Rotation;		
	}
	else
	{
		rRefDir = m_aTerrorist[0].Rotation;
	}
	// End:0x1BA
	if(m_bActAsGroup)
	{
		iYawOffset = 8192;
		i = 0;
		J0x100:

		// End:0x1B7 [Loop If]
		if(__NFUN_150__(i, m_aTerrorist.Length))
		{
			rDirection = rRefDir;
			// End:0x17C
			if(__NFUN_155__(i, 0))
			{
				// End:0x15D
				if(__NFUN_181__(__NFUN_173__(float(i), float(2)), float(0)))
				{
					__NFUN_162__(rDirection.Yaw, __NFUN_144__(iYawOffset, __NFUN_145__(__NFUN_146__(i, 1), 2)));					
				}
				else
				{
					__NFUN_161__(rDirection.Yaw, __NFUN_144__(iYawOffset, __NFUN_145__(__NFUN_146__(i, 1), 2)));
				}
			}
			m_aTerrorist[i].m_controller.WaitAtNode(float(iWaitingTime), float(iFacingTime), rDirection);
			__NFUN_165__(i);
			// [Loop Continue]
			goto J0x100;
		}		
	}
	else
	{
		terroAI.WaitAtNode(float(iWaitingTime), float(iFacingTime), rRefDir);
	}
	return;
}

//============================================================================
// InformTerroTeam - 
//============================================================================
function InformTerroTeam(R6DZonePath.EInformTeam eInfo, R6TerroristAI terroAI)
{
	local int i;

	// End:0x43
	if(bShowLog)
	{
		__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__("Received message ", string(eInfo)), " from "), string(terroAI.Name)));
	}
	switch(eInfo)
	{
		// End:0x5D
		case 1:
			StartWaiting(terroAI);
			// End:0xE7
			break;
		// End:0x70
		case 2:
			GoToNextNode(terroAI);
			// End:0xE7
			break;
		// End:0x78
		case 4:
			// End:0xE7
			break;
		// End:0xE1
		case 5:
			__NFUN_1834__();
			i = 0;
			J0x87:

			// End:0xDE [Loop If]
			if(__NFUN_150__(i, m_aTerrorist.Length))
			{
				m_aTerrorist[i].m_controller.GotoPointAndSearch(terroAI.Pawn.Location, 5, false, 30.0000000);
				__NFUN_165__(i);
				// [Loop Continue]
				goto J0x87;
			}
			// End:0xE7
			break;
		// End:0xFFFF
		default:
			// End:0xE7
			break;
			break;
	}
	return;
}

defaultproperties
{
	m_bSelectNodeInEditor=true
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: function GetTerroIndex
