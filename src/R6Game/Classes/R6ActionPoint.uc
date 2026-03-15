//=============================================================================
// R6ActionPoint - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6ActionPoint.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//=============================================================================
class R6ActionPoint extends R6ActionPoint
    Abstract
    native;

var Object.EMovementMode m_eMovementMode;  // Movement mode to reach the next ActionPoint
var Object.EMovementSpeed m_eMovementSpeed;  // Speed mode to reach the next ActionPoint
var Object.EPlanAction m_eAction;  // Action to do here
var Object.EPlanActionType m_eActionType;  // kind of ActionPoint
var int m_iRainbowTeamName;  // team owner
var int m_iMileStoneNum;  // # of the milesstone for its team, valid if m_eActionType & PACTTYP_Milestone
var int m_iNodeID;  // # of this node in its team path
// R6-3DVIEWPORT
var int m_iInitialMousePosX;
var int m_iInitialMousePosY;
var bool m_bActionCompleted;
var bool m_bActionPointReached;
var bool m_bDoorInRange;
// Debug
var bool bShowLog;
var Texture m_pCurrentTexture;  // Current texture depending on the point properties
var Texture m_pSelected;
var R6IORotatingDoor pDoor;
var R6PlanningCtrl m_pPlanningCtrl;  // Pointer to the Planning controller
var R6PathFlag m_pMyPathFlag;  // PathFlag in the planning
var R6ReferenceIcons m_pActionIcon;  // exist only in the planning
var Color m_CurrentColor;  // Original color used when flashing
var Vector m_vActionDirection;  // Direction of the Action from the ActionPoint... ei: grenade direction
var Rotator m_rActionRotation;  // Action Rotator, for sniping direction

function InitMyPathFlag()
{
	local R6PathFlag pPrevFlag;

	// End:0x87
	if((m_pMyPathFlag == none))
	{
		m_pMyPathFlag = Spawn(Class'R6Game.R6PathFlag', self,, Location);
		// End:0x5F
		if(bShowLog)
		{
			Log(("-->PathFlag spawned at Location " $ string(m_pMyPathFlag.Location)));
		}
		m_pMyPathFlag.m_iPlanningFloor_0 = m_iPlanningFloor_0;
		m_pMyPathFlag.m_iPlanningFloor_1 = m_iPlanningFloor_1;
	}
	m_pMyPathFlag.SetModeDisplay(m_eMovementMode);
	m_pMyPathFlag.SetDrawColor(m_CurrentColor);
	m_pMyPathFlag.RefreshLocation();
	return;
}

function DrawPath(bool bDisplayInfo)
{
	local int iCurrentPoint;
	local Material pLineMaterial;
	local float fDashSize;

	// End:0x0E
	if((bHidden == true))
	{
		return;
	}
	switch(m_eMovementSpeed)
	{
		// End:0x28
		case 0:
			fDashSize = 0.0000000;
			// End:0x51
			break;
		// End:0x3B
		case 1:
			fDashSize = 100.0000000;
			// End:0x51
			break;
		// End:0x4E
		case 2:
			fDashSize = 50.0000000;
			// End:0x51
			break;
		// End:0xFFFF
		default:
			break;
	}
	// End:0xAC
	if((prevActionPoint.m_PathToNextPoint.Length == 0))
	{
		// End:0xA9
		if(CanIDrawLine(prevActionPoint, self, m_pPlanningCtrl.m_iLevelDisplay, bDisplayInfo))
		{
			DrawDashedLine(prevActionPoint.Location, Location, m_CurrentColor, fDashSize);
		}		
	}
	else
	{
		// End:0x112
		if(CanIDrawLine(prevActionPoint, prevActionPoint.m_PathToNextPoint[0], m_pPlanningCtrl.m_iLevelDisplay, bDisplayInfo))
		{
			DrawDashedLine(prevActionPoint.Location, prevActionPoint.m_PathToNextPoint[0].Location, m_CurrentColor, fDashSize);
		}
		iCurrentPoint = 0;
		J0x119:

		// End:0x1D1 [Loop If]
		if((iCurrentPoint < (prevActionPoint.m_PathToNextPoint.Length - 1)))
		{
			// End:0x1C7
			if(CanIDrawLine(prevActionPoint.m_PathToNextPoint[iCurrentPoint], prevActionPoint.m_PathToNextPoint[(iCurrentPoint + 1)], m_pPlanningCtrl.m_iLevelDisplay, bDisplayInfo))
			{
				DrawDashedLine(prevActionPoint.m_PathToNextPoint[iCurrentPoint].Location, prevActionPoint.m_PathToNextPoint[(iCurrentPoint + 1)].Location, m_CurrentColor, fDashSize);
			}
			(iCurrentPoint++);
			// [Loop Continue]
			goto J0x119;
		}
		// End:0x232
		if(CanIDrawLine(prevActionPoint.m_PathToNextPoint[iCurrentPoint], self, m_pPlanningCtrl.m_iLevelDisplay, bDisplayInfo))
		{
			DrawDashedLine(prevActionPoint.m_PathToNextPoint[iCurrentPoint].Location, Location, m_CurrentColor, fDashSize);
		}
	}
	return;
}

function bool CanIDrawLine(Actor FromPoint, Actor ToPoint, int iDisplayingFloor, bool bDisplayInfo)
{
	local R6Stairs StairsFromPoint, StairsToPoint;

	StairsFromPoint = R6Stairs(FromPoint);
	StairsToPoint = R6Stairs(ToPoint);
	// End:0xC1
	if(bDisplayInfo)
	{
		Log(((((((((((("Displaying line from " $ string(FromPoint)) $ " To :") $ string(ToPoint)) $ " : ") $ string(FromPoint.m_iPlanningFloor_0)) $ " : ") $ string(FromPoint.m_iPlanningFloor_1)) $ " : ") $ string(ToPoint.m_iPlanningFloor_0)) $ " : ") $ string(ToPoint.m_iPlanningFloor_1)));
	}
	// End:0x1CD
	if(((StairsFromPoint != none) && (StairsToPoint != none)))
	{
		// End:0x163
		if((StairsFromPoint.m_bIsTopOfStairs == StairsToPoint.m_bIsTopOfStairs))
		{
			// End:0x15E
			if((((StairsFromPoint.m_bIsTopOfStairs == true) && (FromPoint.m_iPlanningFloor_1 != iDisplayingFloor)) || ((StairsFromPoint.m_bIsTopOfStairs == false) && (FromPoint.m_iPlanningFloor_0 != iDisplayingFloor))))
			{
				return false;
			}
			return true;			
		}
		else
		{
			// End:0x1CB
			if((((ToPoint.m_iPlanningFloor_0 == iDisplayingFloor) || (ToPoint.m_iPlanningFloor_1 == iDisplayingFloor)) && ((FromPoint.m_iPlanningFloor_0 == iDisplayingFloor) || (FromPoint.m_iPlanningFloor_1 == iDisplayingFloor))))
			{
				return true;
			}
			return false;
		}
	}
	// End:0x25D
	if(((StairsFromPoint != none) || (StairsToPoint != none)))
	{
		// End:0x227
		if((StairsFromPoint != none))
		{
			// End:0x224
			if(((ToPoint.m_iPlanningFloor_0 == iDisplayingFloor) || (ToPoint.m_iPlanningFloor_1 == iDisplayingFloor)))
			{
				return true;
			}			
		}
		else
		{
			// End:0x25B
			if(((FromPoint.m_iPlanningFloor_0 == iDisplayingFloor) || (FromPoint.m_iPlanningFloor_1 == iDisplayingFloor)))
			{
				return true;
			}
		}
		return false;
	}
	// End:0x291
	if(((FromPoint.m_iPlanningFloor_0 == iDisplayingFloor) && (FromPoint.m_iPlanningFloor_1 == iDisplayingFloor)))
	{
		return true;
	}
	// End:0x2F9
	if((((FromPoint.m_iPlanningFloor_0 <= iDisplayingFloor) && (FromPoint.m_iPlanningFloor_1 >= iDisplayingFloor)) || ((ToPoint.m_iPlanningFloor_0 <= iDisplayingFloor) && (ToPoint.m_iPlanningFloor_1 >= iDisplayingFloor))))
	{
		return true;
	}
	return false;
	return;
}

function ChangeActionType(Object.EPlanActionType eNewType)
{
	local bool bDoIReset;

	// End:0x2A
	if(((int(m_eActionType) == int(1)) || (int(eNewType) == int(1))))
	{
		bDoIReset = true;
	}
	m_eActionType = eNewType;
	// End:0x71
	if((int(m_eActionType) == int(0)))
	{
		m_pCurrentTexture = default.m_pCurrentTexture;
		m_pSelected = default.m_pSelected;
		Texture = m_pSelected;
		m_bSpriteShowFlatInPlanning = true;		
	}
	else
	{
		// End:0xB9
		if((int(m_eActionType) == int(1)))
		{
			// End:0x9B
			if((m_pPlanningCtrl != none))
			{
				m_pPlanningCtrl.ResetIDs();
			}
			bDoIReset = false;
			Texture = m_pSelected;
			m_bSpriteShowFlatInPlanning = false;			
		}
		else
		{
			// End:0xDE
			if((m_pPlanningCtrl != none))
			{
				m_pCurrentTexture = m_pPlanningCtrl.GetActionTypeTexture(m_eActionType);
			}
			m_pSelected = m_pCurrentTexture;
			Texture = m_pSelected;
			m_bSpriteShowFlatInPlanning = false;
		}
	}
	// End:0x121
	if((bDoIReset && (m_pPlanningCtrl != none)))
	{
		m_pPlanningCtrl.ResetIDs();
	}
	return;
}

// Set the Action type of the current ActionPoint , grenades or sniping or other?!
function SetPointAction(Object.EPlanAction eAction, optional bool bLoading)
{
	m_eAction = eAction;
	// End:0x29
	if((m_pActionIcon != none))
	{
		m_pActionIcon.Destroy();
		m_pActionIcon = none;
	}
	// End:0x38
	if(bLoading)
	{
		FindDoor();
	}
	// End:0xAA
	if((int(eAction) == int(1)))
	{
		// End:0x9C
		if((bLoading == false))
		{
			m_pActionIcon = Spawn(Class'R6Game.R6PlanningRangeFragGrenade', self,, Location);
			m_pActionIcon.m_iPlanningFloor_0 = m_iPlanningFloor_0;
			m_pActionIcon.m_iPlanningFloor_1 = m_iPlanningFloor_1;
			bHidden = true;			
		}
		else
		{
			SetGrenade(m_vActionDirection);
		}		
	}
	else
	{
		// End:0x140
		if((((int(eAction) == int(2)) || (int(eAction) == int(3))) || (int(eAction) == int(4))))
		{
			// End:0x132
			if((bLoading == false))
			{
				m_pActionIcon = Spawn(Class'R6Game.R6PlanningRangeGrenade', self,, Location);
				m_pActionIcon.m_iPlanningFloor_0 = m_iPlanningFloor_0;
				m_pActionIcon.m_iPlanningFloor_1 = m_iPlanningFloor_1;
				bHidden = true;				
			}
			else
			{
				SetGrenade(m_vActionDirection);
			}			
		}
		else
		{
			// End:0x1B8
			if((int(eAction) == int(5)))
			{
				m_pActionIcon = Spawn(Class'R6Game.R6PlanningSnipe', self,, Location);
				m_pActionIcon.m_iPlanningFloor_0 = m_iPlanningFloor_0;
				m_pActionIcon.m_iPlanningFloor_1 = m_iPlanningFloor_1;
				// End:0x1B5
				if(bLoading)
				{
					m_pActionIcon.m_u8SpritePlanningAngle = byte((m_rActionRotation.Yaw / 255));
				}				
			}
			else
			{
				// End:0x24B
				if((int(eAction) == int(6)))
				{
					// End:0x243
					if((pDoor != none))
					{
						m_pActionIcon = Spawn(Class'R6Game.R6PlanningBreach', self,, pDoor.m_vCenterOfDoor);
						m_pActionIcon.m_iPlanningFloor_0 = m_iPlanningFloor_0;
						m_pActionIcon.m_iPlanningFloor_1 = m_iPlanningFloor_1;
						R6PlanningBreach(m_pActionIcon).SetSpriteAngle(pDoor.m_iYawInit, Location);						
					}
					else
					{
						m_eAction = 0;
					}
				}
			}
		}
	}
	return;
}

function FindDoor()
{
	local Vector vDistanceVect;
	local int iPreviousDistance;
	local R6IORotatingDoor pRotatingDoor;
	local R6Door pDoorTest;

	iPreviousDistance = 25000;
	m_bDoorInRange = false;
	// End:0x122
	foreach VisibleCollidingActors(Class'R6Engine.R6Door', pDoorTest, 150.0000000, Location)
	{
		// End:0x65
		if(bShowLog)
		{
			Log(((("Found door " $ string(pDoorTest.m_RotatingDoor)) $ " for ") $ string(self)));
		}
		// End:0x121
		if((!pDoorTest.m_RotatingDoor.m_bTreatDoorAsWindow))
		{
			pRotatingDoor = pDoorTest.m_RotatingDoor;
			vDistanceVect = (pDoorTest.Location - Location);
			vDistanceVect.Z = 0.0000000;
			(vDistanceVect *= vDistanceVect);
			// End:0x121
			if(((vDistanceVect.X + vDistanceVect.Y) < float(iPreviousDistance)))
			{
				m_bDoorInRange = true;
				pDoor = pRotatingDoor;
				iPreviousDistance = int((vDistanceVect.X + vDistanceVect.Y));
			}
		}		
	}	
	// End:0x145
	if(bShowLog)
	{
		Log(("Kept door : " $ string(pDoor)));
	}
	return;
}

function SetMileStoneIcon(int iMilestone)
{
	// End:0x71
	if((m_pPlanningCtrl != none))
	{
		// End:0x50
		if((int(m_eActionType) != int(0)))
		{
			m_pCurrentTexture = m_pPlanningCtrl.GetActionTypeTexture(1, iMilestone);
			m_pSelected = m_pCurrentTexture;
			Texture = m_pSelected;			
		}
		else
		{
			m_pCurrentTexture = default.m_pCurrentTexture;
			m_pSelected = default.m_pSelected;
			Texture = m_pSelected;
		}
	}
	return;
}

function bool SetGrenade(Vector vHitLocation)
{
	local R6PlanningGrenade pGrenadeIcon;

	pGrenadeIcon = Spawn(Class'R6Game.R6PlanningGrenade', self,, vHitLocation);
	pGrenadeIcon.SetGrenadeType(m_eAction);
	pGrenadeIcon.m_iPlanningFloor_0 = m_iPlanningFloor_0;
	pGrenadeIcon.m_iPlanningFloor_1 = m_iPlanningFloor_1;
	m_pPlanningCtrl.Pawn.SetLocation(Location);
	// End:0xAF
	if((m_pPlanningCtrl.PlanningTrace(Location, pGrenadeIcon.Location) == false))
	{
		// End:0xAF
		if((CanIThrowGrenadeThroughDoor(vHitLocation) == false))
		{
			pGrenadeIcon.Destroy();
			return false;
		}
	}
	// End:0xC6
	if((m_pActionIcon != none))
	{
		m_pActionIcon.Destroy();
	}
	m_vActionDirection = vHitLocation;
	m_pActionIcon = pGrenadeIcon;
	return true;
	return;
}

function bool CanIThrowGrenadeThroughDoor(Vector vHitLocation)
{
	local R6IORotatingDoor pRotatingDoor;
	local R6Door pDoorNav;

	// End:0xE0
	foreach VisibleCollidingActors(Class'R6Engine.R6IORotatingDoor', pRotatingDoor, 300.0000000, Location)
	{
		// End:0x5F
		if((m_pPlanningCtrl.PlanningTrace(Location, pRotatingDoor.m_DoorActorA.Location) == true))
		{
			pDoorNav = pRotatingDoor.m_DoorActorB;			
		}
		else
		{
			// End:0xA1
			if((m_pPlanningCtrl.PlanningTrace(Location, pRotatingDoor.m_DoorActorB.Location) == true))
			{
				pDoorNav = pRotatingDoor.m_DoorActorA;
			}
		}
		// End:0xDF
		if((pDoorNav != none))
		{
			// End:0xDF
			if((m_pPlanningCtrl.PlanningTrace(vHitLocation, pDoorNav.Location) == true))
			{
				pDoor = pRotatingDoor;				
				return true;
			}
		}		
	}	
	return false;
	return;
}

function SetFirstPointTexture()
{
	m_pCurrentTexture = Texture'R6Planning.Icons.PlanIcon_StartPoint';
	return;
}

function UnselectPoint()
{
	m_PlanningColor = m_CurrentColor;
	Texture = m_pCurrentTexture;
	SetTimer(0.0000000, false);
	return;
}

function SelectPoint()
{
	// End:0x1A
	if((m_pCurrentTexture != m_pSelected))
	{
		Texture = m_pSelected;
	}
	SetTimer(0.5000000, true);
	return;
}

function Timer()
{
	// End:0x20
	if(m_PlanningColor != m_CurrentColor)
	{
		m_PlanningColor = m_CurrentColor;		
	}
	else
	{
		m_PlanningColor.R = byte(255);
		m_PlanningColor.G = byte(255);
		m_PlanningColor.B = byte(255);
	}
	return;
}

// Set texture color 
function SetDrawColor(Color NewColor)
{
	m_CurrentColor = NewColor;
	m_PlanningColor = NewColor;
	return;
}

function Init3DView(float X, float Y)
{
	m_iInitialMousePosX = int(X);
	m_iInitialMousePosY = int(Y);
	return;
}

// Move the pNode ActionPoint at the screen coordinate X, Y
function RotateView(float X, float Y)
{
	local float fDeltaX, fDeltaY;
	local Rotator NodeRotation;

	// End:0x1A
	if(bShowLog)
	{
		Log("-->RotateView");
	}
	fDeltaX = ((float(m_iInitialMousePosX) - X) / 640.0000000);
	fDeltaY = ((float(m_iInitialMousePosY) - Y) / 480.0000000);
	NodeRotation.Pitch = int((float(Rotation.Pitch) + (fDeltaY * 32768.0000000)));
	NodeRotation.Yaw = int((float(Rotation.Yaw) - (fDeltaX * 65536.0000000)));
	SetRotation(NodeRotation);
	return;
}

defaultproperties
{
	m_eMovementSpeed=1
	m_pCurrentTexture=Texture'R6Planning.Icons.PlanIcon_ActionPoint'
	m_pSelected=Texture'R6Planning.Icons.PlanIcon_SelectedPoint'
	m_eDisplayFlag=0
	bProjTarget=true
	m_bSpriteShowFlatInPlanning=true
	DrawScale=1.2500000
	CollisionRadius=20.0000000
	CollisionHeight=20.0000000
}
