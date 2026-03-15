//=============================================================================
// R6PlanningInfo - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6PlanningInfo.uc : Team info about the planning
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//
//  TODO: PACT_OpenDoor
//
//=============================================================================
class R6PlanningInfo extends R6
    AbstractPlanningInfo
    transient
    native;

// Export UR6PlanningInfo::execAddToTeam(FFrame&, void* const)
native(1411) final function bool AddToTeam(R6ActionPoint pNewPoint);

// Export UR6PlanningInfo::execInsertToTeam(FFrame&, void* const)
private native(1412) final function bool InsertToTeam(R6ActionPoint pNewPoint);

// Export UR6PlanningInfo::execDeletePoint(FFrame&, void* const)
private native(1413) final function bool DeletePoint();

// Export UR6PlanningInfo::execFindPathToNextPoint(FFrame&, void* const)
private native(2007) final function bool FindPathToNextPoint(R6ActionPoint pStartPoint, R6ActionPoint pPointToReach);

// Super Function
function Tick(float fDelta)
{
	local R6GameInfo Game;
	local int iCurrentActionPoint;

	// End:0x5E
	if(((m_iNbNode > 1) && m_NodeList[0].InPlanningMode()))
	{
		iCurrentActionPoint = 1;
		J0x25:

		// End:0x5E [Loop If]
		if((iCurrentActionPoint < m_iNbNode))
		{
			R6ActionPoint(m_NodeList[iCurrentActionPoint]).DrawPath(bDisplayDbgInfo);
			(iCurrentActionPoint++);
			// [Loop Continue]
			goto J0x25;
		}
	}
	// End:0x72
	if((bDisplayDbgInfo == true))
	{
		bDisplayDbgInfo = false;
	}
	return;
}

function InitPlanning(int iTeamId, R6PlanningCtrl pPlanningCtrl)
{
	local int iBackupLastNode, iCurrentActionPoint, iLoadedNumberOfNodes;
	local R6ActionPoint pCurrentPoint, pNextPoint;

	// End:0x0D
	if((m_iNbNode == 0))
	{
		return;
	}
	iBackupLastNode = m_iCurrentNode;
	iLoadedNumberOfNodes = m_iNbNode;
	iCurrentActionPoint = 0;
	J0x2A:

	// End:0x181 [Loop If]
	if((iCurrentActionPoint < iLoadedNumberOfNodes))
	{
		pCurrentPoint = R6ActionPoint(m_NodeList[iCurrentActionPoint]);
		// End:0x78
		if((iCurrentActionPoint == 0))
		{
			pCurrentPoint.SetFirstPointTexture();
			pCurrentPoint.UnselectPoint();
		}
		pCurrentPoint.m_pPlanningCtrl = pPlanningCtrl;
		pCurrentPoint.m_iRainbowTeamName = iTeamId;
		// End:0xEC
		if((iCurrentActionPoint != (iLoadedNumberOfNodes - 1)))
		{
			pNextPoint = R6ActionPoint(m_NodeList[(iCurrentActionPoint + 1)]);
			pNextPoint.prevActionPoint = pCurrentPoint;
			FindPathToNextPoint(pCurrentPoint, pNextPoint);
		}
		pCurrentPoint.SetDrawColor(m_TeamColor);
		// End:0x13C
		if((iCurrentActionPoint != 0))
		{
			pCurrentPoint.prevActionPoint = R6ActionPoint(m_NodeList[(iCurrentActionPoint - 1)]);
			pCurrentPoint.InitMyPathFlag();
		}
		pCurrentPoint.ChangeActionType(pCurrentPoint.m_eActionType);
		pCurrentPoint.SetPointAction(pCurrentPoint.m_eAction, true);
		(iCurrentActionPoint++);
		// [Loop Continue]
		goto J0x2A;
	}
	ResetPointsOrientation();
	// End:0x1AC
	if((iBackupLastNode != -1))
	{
		SetAsCurrentNode(R6ActionPoint(m_NodeList[iBackupLastNode]));
	}
	return;
}

function ResetPointsOrientation()
{
	SetToStartNode();
	J0x06:

	// End:0x21 [Loop If]
	if((GetNextPoint() != none))
	{
		SetPointRotation();
		SetToNextNode();
		// [Loop Continue]
		goto J0x06;
	}
	SetPointRotation();
	SetToStartNode();
	return;
}

// Set On/Off the display of the team path
function SetPathDisplay(bool bDisplay)
{
	local int iCurrentNode;
	local R6ActionPoint pCurrentPoint;

	m_bDisplayPath = bDisplay;
	// End:0xD5
	if((m_iCurrentNode != -1))
	{
		iCurrentNode = 0;
		J0x23:

		// End:0xD5 [Loop If]
		if((iCurrentNode < m_NodeList.Length))
		{
			pCurrentPoint = R6ActionPoint(m_NodeList[iCurrentNode]);
			pCurrentPoint.bHidden = (!bDisplay);
			// End:0x96
			if((pCurrentPoint.m_pMyPathFlag != none))
			{
				pCurrentPoint.m_pMyPathFlag.bHidden = (!bDisplay);
			}
			// End:0xCB
			if((pCurrentPoint.m_pActionIcon != none))
			{
				pCurrentPoint.m_pActionIcon.bHidden = (!bDisplay);
			}
			(iCurrentNode++);
			// [Loop Continue]
			goto J0x23;
		}
	}
	return;
}

function SelectTeam(bool bIsSelected)
{
	local R6ActionPoint pCurrentPoint;

	pCurrentPoint = GetPoint();
	// End:0x6A
	if((pCurrentPoint != none))
	{
		pCurrentPoint.m_PlanningColor = pCurrentPoint.m_CurrentColor;
		// End:0x55
		if((bIsSelected == true))
		{
			pCurrentPoint.SetTimer(0.5000000, true);			
		}
		else
		{
			pCurrentPoint.SetTimer(0.0000000, false);
		}		
	}
	else
	{
		R6PlanningCtrl(m_pTeamManager).PositionCameraOnInsertionZone();
	}
	return;
}

//-----------------------------------------------------------------------------
//      Action Point Management function
//-----------------------------------------------------------------------------
function bool InsertPoint(R6ActionPoint pNewPoint)
{
	local R6ActionPoint BehindMe, FrontMe;

	BehindMe = GetPoint();
	FrontMe = GetNextPoint();
	// End:0x108
	if(((FindPathToNextPoint(BehindMe, pNewPoint) == true) && (FindPathToNextPoint(pNewPoint, FrontMe) == true)))
	{
		InsertToTeam(pNewPoint);
		ResetID();
		FrontMe.m_pMyPathFlag.RefreshLocation();
		pNewPoint.m_eMovementMode = BehindMe.m_eMovementMode;
		pNewPoint.m_eMovementSpeed = BehindMe.m_eMovementSpeed;
		pNewPoint.SetDrawColor(m_TeamColor);
		pNewPoint.InitMyPathFlag();
		BehindMe.UnselectPoint();
		pNewPoint.SelectPoint();
		SetPointRotation();
		SetToNextNode();
		SetPointRotation();
		SetToNextNode();
		SetPointRotation();
		SetToPrevNode();		
	}
	else
	{
		pNewPoint.Destroy();
		pNewPoint = none;
		return false;
	}
	return true;
	return;
}

// And the node in the team and cast the path
function bool AddPoint(R6ActionPoint pNewPoint)
{
	local R6ActionPoint BehindMe;

	// End:0x1B
	if((m_iCurrentNode != -1))
	{
		BehindMe = GetPoint();
	}
	// End:0xD1
	if((BehindMe != none))
	{
		// End:0xB9
		if((FindPathToNextPoint(BehindMe, pNewPoint) == true))
		{
			AddToTeam(pNewPoint);
			ResetID();
			pNewPoint.m_eMovementMode = BehindMe.m_eMovementMode;
			pNewPoint.m_eMovementSpeed = BehindMe.m_eMovementSpeed;
			pNewPoint.SetDrawColor(m_TeamColor);
			pNewPoint.InitMyPathFlag();
			SetPointRotation();
			SetToNextNode();
			SetPointRotation();			
		}
		else
		{
			pNewPoint.Destroy();
			pNewPoint = none;
			return false;
		}		
	}
	else
	{
		AddToTeam(pNewPoint);
		ResetID();
		pNewPoint.SetDrawColor(m_TeamColor);
		pNewPoint.SelectPoint();
	}
	return true;
	return;
}

function bool MoveCurrentPoint()
{
	local R6ActionPoint BehindMe, FrontMe, CurrentPoint;

	CurrentPoint = GetPoint();
	BehindMe = R6ActionPoint(CurrentPoint.prevActionPoint);
	FrontMe = GetNextPoint();
	// End:0x63
	if((BehindMe != none))
	{
		// End:0x61
		if((FindPathToNextPoint(BehindMe, CurrentPoint) == true))
		{
			CurrentPoint.InitMyPathFlag();			
		}
		else
		{
			return false;
		}
	}
	// End:0x95
	if((FrontMe != none))
	{
		// End:0x93
		if((FindPathToNextPoint(CurrentPoint, FrontMe) == true))
		{
			FrontMe.InitMyPathFlag();			
		}
		else
		{
			return false;
		}
	}
	return true;
	return;
}

function SetLastPointRotation()
{
	local Vector vDirection;
	local R6InsertionZone anInsertionZone;
	local Rotator rFirstPointRotation;
	local R6ActionPoint pCurrentPoint;

	pCurrentPoint = GetPoint();
	// End:0x113
	if((m_NodeList.Length > 1))
	{
		// End:0x8B
		if((pCurrentPoint.prevActionPoint.m_PathToNextPoint.Length != 0))
		{
			vDirection = (pCurrentPoint.Location - pCurrentPoint.prevActionPoint.m_PathToNextPoint[(pCurrentPoint.prevActionPoint.m_PathToNextPoint.Length - 1)].Location);			
		}
		else
		{
			vDirection = (pCurrentPoint.Location - pCurrentPoint.prevActionPoint.Location);
		}
		vDirection.Z = 0.0000000;
		vDirection = Normal(vDirection);
		pCurrentPoint.SetRotation(Rotator(vDirection));
		pCurrentPoint.m_u8SpritePlanningAngle = byte((pCurrentPoint.Rotation.Yaw / 255));		
	}
	else
	{
		// End:0x18F
		foreach m_pTeamManager.AllActors(Class'R6Game.R6InsertionZone', anInsertionZone)
		{
			// End:0x18E
			if((anInsertionZone.IsAvailableInGameType(R6AbstractGameInfo(m_pTeamManager.Level.Game).m_szGameTypeFlag) && (anInsertionZone.m_iInsertionNumber == m_iStartingPointNumber)))
			{
				rFirstPointRotation = anInsertionZone.Rotation;
			}			
		}		
		pCurrentPoint.SetRotation(rFirstPointRotation);
		pCurrentPoint.m_u8SpritePlanningAngle = byte((pCurrentPoint.Rotation.Yaw / 255));
	}
	return;
}

function SetPointRotation()
{
	local Vector vDirection;
	local R6ActionPoint pCurrentPoint;

	pCurrentPoint = GetPoint();
	pCurrentPoint.m_bActionCompleted = false;
	pCurrentPoint.m_bActionPointReached = false;
	// End:0x101
	if((GetNextPoint() != none))
	{
		// End:0x81
		if((pCurrentPoint.m_PathToNextPoint.Length != 0))
		{
			vDirection = (pCurrentPoint.m_PathToNextPoint[0].Location - pCurrentPoint.Location);			
		}
		else
		{
			vDirection = (GetNextPoint().Location - pCurrentPoint.Location);
		}
		vDirection.Z = 0.0000000;
		vDirection = Normal(vDirection);
		pCurrentPoint.SetRotation(Rotator(vDirection));
		pCurrentPoint.m_u8SpritePlanningAngle = byte((pCurrentPoint.Rotation.Yaw / 255));		
	}
	else
	{
		SetLastPointRotation();
	}
	return;
}

function SetToPrevNode()
{
	// End:0x32
	if((m_iCurrentNode > 0))
	{
		GetPoint().UnselectPoint();
		(m_iCurrentNode--);
		GetPoint().SelectPoint();
	}
	return;
}

function SetToNextNode()
{
	// End:0x3A
	if((m_iCurrentNode != (m_NodeList.Length - 1)))
	{
		GetPoint().UnselectPoint();
		(m_iCurrentNode++);
		GetPoint().SelectPoint();
	}
	return;
}

function SetToStartNode()
{
	// End:0x4C
	if((m_iNbNode != 0))
	{
		// End:0x2A
		if((m_iCurrentNode != -1))
		{
			GetPoint().UnselectPoint();
		}
		m_iCurrentNode = 0;
		GetPoint().SelectPoint();
		m_iCurrentPathIndex = -1;
	}
	return;
}

function SetToEndNode()
{
	// End:0x3E
	if((m_iCurrentNode != -1))
	{
		GetPoint().UnselectPoint();
		m_iCurrentNode = (m_NodeList.Length - 1);
		GetPoint().SelectPoint();
	}
	return;
}

function RemovePointsRefsToCtrl()
{
	local R6ActionPoint pActionPoint;
	local int iCurrentNode;

	iCurrentNode = 0;
	J0x07:

	// End:0x47 [Loop If]
	if((iCurrentNode < m_NodeList.Length))
	{
		pActionPoint = R6ActionPoint(m_NodeList[iCurrentNode]);
		pActionPoint.m_pPlanningCtrl = none;
		(iCurrentNode++);
		// [Loop Continue]
		goto J0x07;
	}
	return;
}

// Reset the ID of all the ActionPoint
function ResetID()
{
	local R6ActionPoint pNode;

	m_iNbMilestone = 0;
	m_iNbNode = 0;
	J0x0E:

	// End:0x9A [Loop If]
	if((m_iNbNode < m_NodeList.Length))
	{
		pNode = R6ActionPoint(m_NodeList[m_iNbNode]);
		pNode.m_iNodeID = m_iNbNode;
		// End:0x90
		if((int(pNode.m_eActionType) == int(1)))
		{
			(m_iNbMilestone++);
			pNode.m_iMileStoneNum = m_iNbMilestone;
			pNode.SetMileStoneIcon(m_iNbMilestone);
		}
		(m_iNbNode++);
		// [Loop Continue]
		goto J0x0E;
	}
	return;
}

function bool SetAsCurrentNode(R6ActionPoint pSelectedNode)
{
	// End:0x1F
	if((m_iCurrentNode != -1))
	{
		GetPoint().UnselectPoint();
	}
	m_iCurrentNode = 0;
	J0x26:

	// End:0x62 [Loop If]
	if((m_iCurrentNode < m_NodeList.Length))
	{
		// End:0x58
		if((GetPoint() == pSelectedNode))
		{
			GetPoint().SelectPoint();
			return true;
		}
		(m_iCurrentNode++);
		// [Loop Continue]
		goto J0x26;
	}
	m_iCurrentNode = 0;
	Log("WARNING - Could not find current node in Planning Info!!");
	return false;
	return;
}

// Delete the current ActionPoint
function bool DeleteNode()
{
	local R6ActionPoint pCurrentPoint;
	local R6ReferenceIcons tempAI;
	local R6PathFlag tempPF;

	// End:0x11
	if((m_iCurrentNode == -1))
	{
		return false;
	}
	pCurrentPoint = GetPoint();
	// End:0x1BD
	if((!((m_iCurrentNode == 0) && (m_NodeList.Length > 1))))
	{
		// End:0x98
		if((pCurrentPoint.m_pActionIcon != none))
		{
			tempAI = pCurrentPoint.m_pActionIcon;
			pCurrentPoint.m_pActionIcon = none;
			tempAI.Destroy();
			pCurrentPoint.m_vActionDirection = vect(0.0000000, 0.0000000, 0.0000000);
		}
		// End:0xDC
		if((pCurrentPoint.m_pMyPathFlag != none))
		{
			tempPF = pCurrentPoint.m_pMyPathFlag;
			pCurrentPoint.m_pMyPathFlag = none;
			tempPF.Destroy();
		}
		// End:0xEF
		if((m_iCurrentNode == 0))
		{
			m_bPlacedFirstPoint = false;
		}
		DeletePoint();
		ResetID();
		// End:0x144
		if((m_iCurrentNode == m_NodeList.Length))
		{
			(m_iCurrentNode--);
			// End:0x120
			if((m_iCurrentNode == -1))
			{
				return true;
			}
			pCurrentPoint = GetPoint();
			pCurrentPoint.SelectPoint();
			SetPointRotation();			
		}
		else
		{
			(m_iCurrentNode--);
			pCurrentPoint = GetPoint();
			GetNextPoint().prevActionPoint = pCurrentPoint;
			FindPathToNextPoint(pCurrentPoint, GetNextPoint());
			GetNextPoint().m_pMyPathFlag.RefreshLocation();
			pCurrentPoint.SelectPoint();
			SetPointRotation();
			SetToNextNode();
			SetPointRotation();
			SetToPrevNode();
		}		
	}
	else
	{
		Log("Cannot delete start location, when there's other points in the list");
		return false;
	}
	return true;
	return;
}

// Delete all ActionPoint in the Team
function DeleteAllNode()
{
	m_iCurrentNode = (m_NodeList.Length - 1);
	J0x0F:

	// End:0x27 [Loop If]
	if((m_iCurrentNode != -1))
	{
		DeleteNode();
		// [Loop Continue]
		goto J0x0F;
	}
	m_bPlacedFirstPoint = false;
	return;
}

// Set the Action type of the current ActionPoint , grenades or sniping or other?!
function SetCurrentPointAction(Object.EPlanAction eAction)
{
	// End:0x2B
	if((GetPoint() == none))
	{
		Log("WARNING: CurrentNode null");
		return;
	}
	GetPoint().SetPointAction(eAction);
	return;
}

function AjustSnipeDirection(Vector vHitLocation)
{
	// End:0x42
	if((m_iCurrentNode != -1))
	{
		GetPoint().m_rActionRotation = R6PlanningSnipe(GetPoint().m_pActionIcon).SetDirectionRotator(vHitLocation);
	}
	return;
}

function GetSnipingCoordinates(out Vector vLocation, out Rotator rRotation)
{
	vLocation = GetPoint().Location;
	rRotation = GetPoint().m_rActionRotation;
	return;
}

function Actor GetDoorToBreach()
{
	return GetPoint().pDoor;
	return;
}

function Actor GetNextDoorToBreach(Actor aPoint)
{
	local R6ActionPoint nextActionPoint;

	// End:0x24
	if((R6ActionPoint(aPoint) != none))
	{
		return R6ActionPoint(aPoint).pDoor;
	}
	nextActionPoint = GetNextPoint();
	// End:0x4A
	if((nextActionPoint != none))
	{
		return nextActionPoint.pDoor;
	}
	return;
}

function bool SetGrenadeLocation(Vector vHitLocation)
{
	// End:0x32
	if((GetPoint() != none))
	{
		(vHitLocation.Z += float(100));
		return GetPoint().SetGrenade(vHitLocation);
	}
	return false;
	return;
}

function SetActionType(Object.EPlanActionType eNewType)
{
	// End:0x24
	if((m_iCurrentNode != -1))
	{
		GetPoint().ChangeActionType(eNewType);
	}
	return;
}

function R6ActionPoint GetPoint()
{
	// End:0x20
	if((m_iCurrentNode != -1))
	{
		return R6ActionPoint(m_NodeList[m_iCurrentNode]);
	}
	return none;
	return;
}

function R6ActionPoint GetNextPoint()
{
	// End:0x38
	if(((m_iCurrentNode != -1) && ((m_iCurrentNode + 1) != m_NodeList.Length)))
	{
		return R6ActionPoint(m_NodeList[(m_iCurrentNode + 1)]);
	}
	return none;
	return;
}

function Object.EPlanActionType GetActionType()
{
	// End:0x1F
	if((m_iCurrentNode != -1))
	{
		return GetPoint().m_eActionType;
	}
	return m_eDefaultActionType;
	return;
}

function SetAction(Object.EPlanAction eNewAction)
{
	// End:0x24
	if((m_iCurrentNode != -1))
	{
		GetPoint().m_eAction = eNewAction;
	}
	return;
}

function Object.EPlanAction GetAction()
{
	// End:0x1F
	if((m_iCurrentNode != -1))
	{
		return GetPoint().m_eAction;
	}
	return m_eDefaultAction;
	return;
}

function Object.EPlanAction NextActionPointHasAction(Actor aPoint)
{
	local R6ActionPoint actionPoint, nextActionPoint;

	actionPoint = R6ActionPoint(aPoint);
	// End:0x75
	if((actionPoint == none))
	{
		nextActionPoint = GetNextPoint();
		// End:0x72
		if(((nextActionPoint != none) && (VSize((nextActionPoint.Location - aPoint.Location)) < float(300))))
		{
			return nextActionPoint.m_eAction;			
		}
		else
		{
			return 0;
		}
	}
	return actionPoint.m_eAction;
	return;
}

function SetMovementMode(Object.EMovementMode eNewMode)
{
	// End:0x42
	if((m_iCurrentNode != -1))
	{
		GetPoint().m_eMovementMode = eNewMode;
		GetPoint().m_pMyPathFlag.SetModeDisplay(eNewMode);
	}
	return;
}

function Object.EMovementMode GetMovementMode()
{
	// End:0x41
	if((m_iCurrentNode != -1))
	{
		// End:0x31
		if((m_iCurrentPathIndex != -1))
		{
			return GetNextPoint().m_eMovementMode;			
		}
		else
		{
			return GetPoint().m_eMovementMode;
		}
	}
	return m_eDefaultMode;
	return;
}

function SetMovementSpeed(Object.EMovementSpeed eNewSpeed)
{
	// End:0x24
	if((m_iCurrentNode != -1))
	{
		GetPoint().m_eMovementSpeed = eNewSpeed;
	}
	return;
}

function Object.EMovementSpeed GetMovementSpeed()
{
	// End:0x41
	if((m_iCurrentNode != -1))
	{
		// End:0x31
		if((m_iCurrentPathIndex != -1))
		{
			return GetNextPoint().m_eMovementSpeed;			
		}
		else
		{
			return GetPoint().m_eMovementSpeed;
		}
	}
	return m_eDefaultSpeed;
	return;
}

function Actor GetFirstActionPoint()
{
	return GetPoint();
	return;
}

function SkipCurrentDestination()
{
	local R6ActionPoint pPrevPoint, pCurrentPoint;
	local R6RainbowTeam pCurrentTeam;

	pCurrentPoint = GetPoint();
	pCurrentTeam = R6RainbowTeam(m_pTeamManager);
	// End:0x1A9
	if(((m_iCurrentNode != -1) && (m_iCurrentNode != (m_NodeList.Length - 1))))
	{
		// End:0x8D
		if((m_iCurrentPathIndex == (pCurrentPoint.m_PathToNextPoint.Length - 1)))
		{
			pPrevPoint = pCurrentPoint;
			pCurrentPoint.m_bActionCompleted = true;
			m_iCurrentPathIndex = -1;
			(m_iCurrentNode++);			
		}
		else
		{
			(m_iCurrentPathIndex++);
		}
		// End:0x116
		if((m_iCurrentPathIndex == -1))
		{
			// End:0xDB
			if((int(pPrevPoint.m_eMovementMode) != int(pCurrentPoint.m_eMovementMode)))
			{
				pCurrentTeam.TeamNotifyActionPoint(1, 4);
			}
			// End:0x113
			if((int(pPrevPoint.m_eMovementSpeed) != int(pCurrentPoint.m_eMovementSpeed)))
			{
				pCurrentTeam.TeamNotifyActionPoint(2, 4);
			}			
		}
		else
		{
			// End:0x193
			if((m_iCurrentPathIndex == 0))
			{
				// End:0x15A
				if((int(GetNextPoint().m_eMovementMode) != int(pCurrentPoint.m_eMovementMode)))
				{
					pCurrentTeam.TeamNotifyActionPoint(1, 4);
				}
				// End:0x193
				if((int(GetNextPoint().m_eMovementSpeed) != int(pCurrentPoint.m_eMovementSpeed)))
				{
					pCurrentTeam.TeamNotifyActionPoint(2, 4);
				}
			}
		}
		pCurrentTeam.TeamNotifyActionPoint(3, 4);		
	}
	else
	{
		m_iCurrentNode = -1;
	}
	return;
}

function Actor GetNextActionPoint()
{
	local Actor pPointToReturn;
	local R6ActionPoint pCurrentPoint;

	pCurrentPoint = GetPoint();
	// End:0x82
	if(((m_iCurrentNode != -1) && (m_iCurrentNode < m_NodeList.Length)))
	{
		// End:0x74
		if(((m_iCurrentPathIndex != -1) && (m_iCurrentPathIndex < pCurrentPoint.m_PathToNextPoint.Length)))
		{
			pPointToReturn = pCurrentPoint.m_PathToNextPoint[m_iCurrentPathIndex];			
		}
		else
		{
			pPointToReturn = pCurrentPoint;
		}		
	}
	else
	{
		pPointToReturn = none;
	}
	return pPointToReturn;
	return;
}

function Actor PreviewNextActionPoint()
{
	local Actor pPointToReturn;

	// End:0x59
	if((m_iCurrentNode != -1))
	{
		// End:0x4D
		if(((m_iCurrentPathIndex + 1) < GetPoint().m_PathToNextPoint.Length))
		{
			pPointToReturn = GetPoint().m_PathToNextPoint[(m_iCurrentPathIndex + 1)];			
		}
		else
		{
			pPointToReturn = GetNextPoint();
		}
	}
	return pPointToReturn;
	return;
}

function SetToPreviousActionPoint()
{
	// End:0x51
	if((GetPoint().m_bActionPointReached || (VSize((R6RainbowTeam(m_pTeamManager).m_Team[0].Location - GetPoint().Location)) < float(200))))
	{
		return;
	}
	// End:0xBA
	if(((m_iCurrentNode != -1) && (!((m_iCurrentNode == 0) && (m_iCurrentPathIndex == -1)))))
	{
		// End:0x9A
		if((m_iCurrentPathIndex != -1))
		{
			(m_iCurrentPathIndex -= 1);			
		}
		else
		{
			(m_iCurrentNode--);
			m_iCurrentPathIndex = (GetPoint().m_PathToNextPoint.Length - 1);
		}
	}
	return;
}

function int GetActionPointID()
{
	// End:0x1F
	if((m_iCurrentNode != -1))
	{
		return GetPoint().m_iNodeID;
	}
	return -1;
	return;
}

function int GetNbActionPoint()
{
	return m_iNbNode;
	return;
}

function Vector GetActionLocation()
{
	// End:0x1F
	if((m_iCurrentNode != -1))
	{
		return GetPoint().m_vActionDirection;
	}
	return vect(0.0000000, 0.0000000, 0.0000000);
	return;
}

// Message management between the TeamAI and PlayerController
function NotifyActionPoint(Object.ENodeNotify eMsg, Object.EGoCode eCode)
{
	local R6ActionPoint pPrevPoint;
	local R6RainbowTeam pCurrentTeam;
	local R6ActionPoint pCurrentPoint;

	pCurrentTeam = R6RainbowTeam(m_pTeamManager);
	pCurrentPoint = GetPoint();
	// End:0x3D8
	if(((pCurrentTeam != none) && (m_iCurrentNode != -1)))
	{
		switch(eMsg)
		{
			// End:0x46
			case 0:
				return;
			// End:0x4D
			case 1:
				return;
			// End:0x174
			case 4:
				// End:0x6D
				if((int(pCurrentTeam.m_eGoCode) == int(3)))
				{
					return;
				}
				// End:0xE0
				if((int(m_eGoCodeState[int(eCode)]) == int(1)))
				{
					m_eGoCodeState[int(eCode)] = 0;
					// End:0xC4
					if((int(pCurrentPoint.m_eAction) != int(0)))
					{
						pCurrentTeam.TeamNotifyActionPoint(0, 4);						
					}
					else
					{
						NotifyActionPoint(5, 4);
					}
					pCurrentTeam.ResetTeamGoCode();					
				}
				else
				{
					// End:0x129
					if((int(m_eGoCodeState[int(eCode)]) == int(2)))
					{
						m_eGoCodeState[int(eCode)] = 0;
						pCurrentTeam.TeamSnipingOver();
						pCurrentTeam.ResetTeamGoCode();						
					}
					else
					{
						// End:0x172
						if((int(m_eGoCodeState[int(eCode)]) == int(3)))
						{
							m_eGoCodeState[int(eCode)] = 0;
							pCurrentTeam.BreachDoor();
							pCurrentTeam.ResetTeamGoCode();							
						}
					}
				}
				return;
			// End:0x30D
			case 5:
				// End:0x300
				if((m_iCurrentNode != (m_iNbNode - 1)))
				{
					pCurrentPoint.m_bActionCompleted = true;
					pPrevPoint = pCurrentPoint;
					// End:0x1E4
					if((m_iCurrentPathIndex == (pCurrentPoint.m_PathToNextPoint.Length - 1)))
					{
						m_iCurrentPathIndex = -1;
						(m_iCurrentNode++);
						pCurrentPoint = GetPoint();						
					}
					else
					{
						(m_iCurrentPathIndex++);
					}
					// End:0x26D
					if((m_iCurrentPathIndex == -1))
					{
						// End:0x232
						if((int(pPrevPoint.m_eMovementMode) != int(pCurrentPoint.m_eMovementMode)))
						{
							pCurrentTeam.TeamNotifyActionPoint(1, 4);
						}
						// End:0x26A
						if((int(pPrevPoint.m_eMovementSpeed) != int(pCurrentPoint.m_eMovementSpeed)))
						{
							pCurrentTeam.TeamNotifyActionPoint(2, 4);
						}						
					}
					else
					{
						// End:0x2EA
						if((m_iCurrentPathIndex == 0))
						{
							// End:0x2B1
							if((int(GetNextPoint().m_eMovementMode) != int(pCurrentPoint.m_eMovementMode)))
							{
								pCurrentTeam.TeamNotifyActionPoint(1, 4);
							}
							// End:0x2EA
							if((int(GetNextPoint().m_eMovementSpeed) != int(pCurrentPoint.m_eMovementSpeed)))
							{
								pCurrentTeam.TeamNotifyActionPoint(2, 4);
							}
						}
					}
					pCurrentTeam.TeamNotifyActionPoint(3, 4);					
				}
				else
				{
					m_iCurrentNode = -1;
				}
				return;
			// End:0x33A
			case 6:
				m_eGoCodeState[int(eCode)] = 1;
				pCurrentTeam.TeamNotifyActionPoint(6, eCode);
				return;
			// End:0x367
			case 9:
				m_eGoCodeState[int(eCode)] = 2;
				pCurrentTeam.TeamNotifyActionPoint(9, eCode);
				return;
			// End:0x394
			case 10:
				m_eGoCodeState[int(eCode)] = 3;
				pCurrentTeam.TeamNotifyActionPoint(10, eCode);
				return;
			// End:0x3B2
			case 7:
				pCurrentPoint.m_bActionPointReached = true;
				ReadNode();
				return;
			// End:0x3D2
			case 8:
				SetToPreviousActionPoint();
				pCurrentTeam.TeamNotifyActionPoint(3, 4);
				return;
			// End:0xFFFF
			default:
				// End:0x3D8
				break;
				break;
		}
	}
	return;
}

// check if this team has reach this action point
function bool MemberReached(R6ActionPoint PTarget)
{
	local int i;
	local Vector vDiff;
	local float fZDiff;

	// End:0xA3
	if((PTarget != none))
	{
		// End:0xA3
		if((m_pTeamManager != none))
		{
			// End:0xA3
			if(R6RainbowTeam(m_pTeamManager).m_bLeaderIsAPlayer)
			{
				vDiff = (R6RainbowTeam(m_pTeamManager).m_TeamLeader.Location - PTarget.Location);
				fZDiff = vDiff.Z;
				vDiff.Z = 0.0000000;
				// End:0xA3
				if(((VSize(vDiff) < m_fReachRange) && (fZDiff < m_fZReachRange)))
				{
					return true;
				}
			}
		}
	}
	return false;
	return;
}

// Read info in the node
function ReadNode()
{
	local R6PlayerController pMyPlayer;
	local Actor NextPoint;
	local R6RainbowTeam pCurrentTeam;
	local R6ActionPoint pCurrentPoint;

	pCurrentPoint = GetPoint();
	pCurrentTeam = R6RainbowTeam(m_pTeamManager);
	// End:0x1F6
	if((pCurrentPoint.m_bActionCompleted != true))
	{
		switch(pCurrentPoint.m_eActionType)
		{
			// End:0x95
			case 1:
				// End:0x94
				foreach m_pTeamManager.Level.AllActors(Class'R6Engine.R6PlayerController', pMyPlayer)
				{
					pMyPlayer.DisplayMilestoneMessage(pCurrentTeam.m_iRainbowTeamName, pCurrentPoint.m_iMileStoneNum);					
				}				
			// End:0xD6
			case 0:
				// End:0xC9
				if((int(pCurrentPoint.m_eAction) != int(0)))
				{
					pCurrentTeam.TeamNotifyActionPoint(0, 4);					
				}
				else
				{
					NotifyActionPoint(5, 4);
				}
				// End:0x1F3
				break;
			// End:0x134
			case 2:
				// End:0x101
				if((int(pCurrentPoint.m_eAction) == int(5)))
				{
					NotifyActionPoint(9, 0);					
				}
				else
				{
					// End:0x127
					if((int(pCurrentPoint.m_eAction) == int(6)))
					{
						NotifyActionPoint(10, 0);						
					}
					else
					{
						NotifyActionPoint(6, 0);
					}
				}
				// End:0x1F3
				break;
			// End:0x192
			case 3:
				// End:0x15F
				if((int(pCurrentPoint.m_eAction) == int(5)))
				{
					NotifyActionPoint(9, 1);					
				}
				else
				{
					// End:0x185
					if((int(pCurrentPoint.m_eAction) == int(6)))
					{
						NotifyActionPoint(10, 1);						
					}
					else
					{
						NotifyActionPoint(6, 1);
					}
				}
				// End:0x1F3
				break;
			// End:0x1F0
			case 4:
				// End:0x1BD
				if((int(pCurrentPoint.m_eAction) == int(5)))
				{
					NotifyActionPoint(9, 2);					
				}
				else
				{
					// End:0x1E3
					if((int(pCurrentPoint.m_eAction) == int(6)))
					{
						NotifyActionPoint(10, 2);						
					}
					else
					{
						NotifyActionPoint(6, 2);
					}
				}
				// End:0x1F3
				break;
			// End:0xFFFF
			default:
				break;
		}		
	}
	else
	{
		NotifyActionPoint(5, 4);
	}
	return;
}


// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: function GetActionType
// REMOVED IN 1.60: function GetAction
// REMOVED IN 1.60: function NextActionPointHasAction
// REMOVED IN 1.60: function GetMovementMode
// REMOVED IN 1.60: function GetMovementSpeed
