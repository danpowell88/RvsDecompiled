//=============================================================================
// R6PlanningCtrl - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6PlanningCtrl.uc : (top-view camera of the planning)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/05/08 * Created by Chaouky Garram
//    2002/02/02 * Taken over and rewritten by Joel Tremblay
//=============================================================================
class R6PlanningCtrl extends PlayerController
    native
    config(User);

const R6InputKey_ActionPopup = 1024;
const R6InputKey_PathFlagPopup = 1026;

var int m_iCurrentTeam;  // editing which team
var int m_3DWindowPositionX;  // region send by the planning widget to set the 3d window size.
var int m_3DWindowPositionY;  // region send by the planning widget to set the 3d window size.
var int m_3DWindowPositionW;  // region send by the planning widget to set the 3d window size.
var int m_3DWindowPositionH;  // region send by the planning widget to set the 3d window size.
var int m_iLevelDisplay;  // Current floor displayed
var bool m_bRender3DView;  // 3D view is activated
var bool m_bMove3DView;
var bool m_bActionPointSelected;  // to drag drop selected point.
var bool m_bCanMoveFirstPoint;  // When dragging the first point, it must be dropped on an insertion zone
var bool m_bClickToFindLocation;  // Next click is to set an action
var bool m_bClickedOnRange;  // When clicked on range icon, set to true
var bool m_bSetSnipeDirection;  // mouse is moving to set the Sniping direction
var bool m_bPlayMode;  // Play mode has been activated
var bool m_bLockCamera;
var(Debug) bool bShowLog;  // Show debug info
var bool m_bFirstTick;
var float m_fLastMouseX;  // mouse last move location to find the sniping direction
var float m_fLastMouseY;  // mouse last move location to find the sniping direction
var float m_fZoom;  // Zoom
var float m_fZoomDelta;  // Modification request on the zoom
var float m_fZoomRate;  // Zoom speed
var float m_fZoomMin;  // Minimum Zoom of the camera
var float m_fZoomMax;
var float m_fZoomFactor;  // to adapt camera speeds with current zoom
var float m_fCameraAngle;  // Change the camera Angle
var float m_fAngleRate;
var float m_fAngleMax;  // max distance on X to calculate the angle  min is obviously 0
var float m_fRotateDelta;  // Modification request on the rotation
var float m_fRotateRate;  // Speed of the rotation
var float m_fCamRate;  // 
var(R6Planning) const float m_fCastingHeight;  // Height between the ground and the ActionPoint casted
//#ifdefDEBUG
var float m_fDebugRangeScale;
var R6PlanningInfo m_pTeamInfo[3];  // the team's planning
var R6FileManagerPlanning m_pFileManager;  // to load/save planning
var R6CameraDirection m_pCameraDirIcon;  // Icon to show where the camera is looking at.
var Actor m_pOldHitActor;  // not change floor when an actor is selected twice.
var Texture m_pIconTex[12];  // List of the ActionType icon texture
var Actor m_CamSpot;  // camera spot if 3d view is on without action point
var Sound m_PlanningBadClickSnd;
var Sound m_PlanningGoodClickSnd;
var Sound m_PlanningRemoveSnd;
//  camera movement parameters
var Vector m_vCurrentCameraPos;
var Vector m_vCamPos;  // Camera Location for zoom
var Vector m_vCamPosNoRot;  // Camera position Without any rotation.
var Vector m_vCamDesiredPos;  // Camera will reach this direction.
var Rotator m_rCamRot;  // Camera Rotation
var Vector m_vCamDelta;  // Modification request on camera deplacement
var Vector m_vMinLocation;  // Minimum location X,Y of the camera(Restriction from the map)
var Vector m_vMaxLocation;

// Export UR6PlanningCtrl::execGetClickResult(FFrame&, void* const)
native(2013) final function bool GetClickResult(float X, float Y, out Vector HitLocation, out Actor HitActor, out int iChangeLevelTo);

// Export UR6PlanningCtrl::execGetXYPoint(FFrame&, void* const)
//Get a 3d point where z = 0 using the X Y coordinates
native(2016) final function Vector GetXYPoint(float X, float Y, float Height);

// Export UR6PlanningCtrl::execPlanningTrace(FFrame&, void* const)
// returns true if did not hit world geometry, excluding doors and windows.
native(2017) final function bool PlanningTrace(Vector vTraceEnd, Vector vTraceStart);

function PostBeginPlay()
{
	local ZoneInfo PZone;
	local int iCurrentPlanning, iCurrentInsertionNumber;
	local R6InsertionZone anInsertionZone;
	local R6IORotatingDoor aDoor;
	local R6IOSlidingWindow aWindow;
	local R6ReferenceIcons pSpawnedIcon, RefIco;
	local R6AbstractInsertionZone NavPoint;
	local R6AbstractExtractionZone ExtZone;

	SetFOVAngle((m_fZoom * float(90)));
	// End:0x2B
	if((m_pCameraDirIcon == none))
	{
		m_pCameraDirIcon = Spawn(Class'R6Game.R6CameraDirection', self);
	}
	// End:0x45
	if((m_pFileManager == none))
	{
		m_pFileManager = new (none) Class'R6Game.R6FileManagerPlanning';
	}
	iCurrentInsertionNumber = 2147483647;
	// End:0x108
	foreach AllActors(Class'R6Game.R6InsertionZone', anInsertionZone)
	{
		// End:0x107
		if(anInsertionZone.IsAvailableInGameType(R6AbstractGameInfo(Level.Game).m_szGameTypeFlag))
		{
			// End:0x104
			if((anInsertionZone.m_iInsertionNumber < iCurrentInsertionNumber))
			{
				iCurrentInsertionNumber = anInsertionZone.m_iInsertionNumber;
				SetFloorToDraw(anInsertionZone.m_iPlanningFloor_0);
				m_iLevelDisplay = anInsertionZone.m_iPlanningFloor_0;
				m_vCamPosNoRot = anInsertionZone.Location;
				m_vCamDesiredPos = anInsertionZone.Location;
			}
			// End:0x108
			break;
		}		
	}	
	// End:0x227
	foreach AllActors(Class'R6Engine.R6IORotatingDoor', aDoor)
	{
		aDoor.m_eDisplayFlag = 1;
		// End:0x226
		if((aDoor.m_bTreatDoorAsWindow == false))
		{
			// End:0x175
			if((aDoor.m_bIsDoorLocked == true))
			{
				pSpawnedIcon = Spawn(Class'R6Engine.R6DoorLockedIcon',,, aDoor.m_vCenterOfDoor);				
			}
			else
			{
				pSpawnedIcon = Spawn(Class'R6Engine.R6DoorIcon',,, aDoor.m_vCenterOfDoor);
			}
			pSpawnedIcon.m_u8SpritePlanningAngle = byte((aDoor.Rotation.Yaw / 255));
			pSpawnedIcon.m_iPlanningFloor_0 = aDoor.m_iPlanningFloor_0;
			pSpawnedIcon.m_iPlanningFloor_1 = aDoor.m_iPlanningFloor_1;
			// End:0x226
			if((aDoor.m_bIsOpeningClockWise == false))
			{
				pSpawnedIcon.SetDrawScale3D(vect(1.0000000, -1.0000000, 1.0000000));
			}
		}		
	}	
	// End:0x24A
	foreach AllActors(Class'R6Engine.R6ReferenceIcons', RefIco)
	{
		RefIco.bHidden = false;		
	}	
	// End:0x298
	foreach AllActors(Class'R6Abstract.R6AbstractInsertionZone', NavPoint)
	{
		// End:0x297
		if(NavPoint.IsAvailableInGameType(R6AbstractGameInfo(Level.Game).m_szGameTypeFlag))
		{
			NavPoint.bHidden = false;
		}		
	}	
	// End:0x2E6
	foreach AllActors(Class'R6Abstract.R6AbstractExtractionZone', ExtZone)
	{
		// End:0x2E5
		if(ExtZone.IsAvailableInGameType(R6AbstractGameInfo(Level.Game).m_szGameTypeFlag))
		{
			ExtZone.bHidden = false;
		}		
	}	
	m_CamSpot = Level.GetCamSpot(Level.Game.m_szGameTypeFlag);
	Level.m_bAllow3DRendering = false;
	return;
}

function Set3DViewPosition(int NewX, int NewY, int NewH, int NewW)
{
	m_3DWindowPositionX = NewX;
	m_3DWindowPositionY = NewY;
	m_3DWindowPositionW = NewW;
	m_3DWindowPositionH = NewH;
	return;
}

function SetPlanningInfo()
{
	m_pTeamInfo[0] = R6PlanningInfo(Player.Console.Master.m_StartGameInfo.m_TeamInfo[0].m_pPlanning);
	m_pTeamInfo[1] = R6PlanningInfo(Player.Console.Master.m_StartGameInfo.m_TeamInfo[1].m_pPlanning);
	m_pTeamInfo[2] = R6PlanningInfo(Player.Console.Master.m_StartGameInfo.m_TeamInfo[2].m_pPlanning);
	m_pTeamInfo[0].m_pTeamManager = self;
	m_pTeamInfo[1].m_pTeamManager = self;
	m_pTeamInfo[2].m_pTeamManager = self;
	m_pTeamInfo[0].m_iStartingPointNumber = Player.Console.Master.m_StartGameInfo.m_TeamInfo[0].m_iSpawningPointNumber;
	m_pTeamInfo[1].m_iStartingPointNumber = Player.Console.Master.m_StartGameInfo.m_TeamInfo[1].m_iSpawningPointNumber;
	m_pTeamInfo[2].m_iStartingPointNumber = Player.Console.Master.m_StartGameInfo.m_TeamInfo[2].m_iSpawningPointNumber;
	m_pTeamInfo[0].m_TeamColor = WindowConsole(Player.Console).Root.Colors.TeamColorLight[0];
	m_pTeamInfo[1].m_TeamColor = WindowConsole(Player.Console).Root.Colors.TeamColorLight[1];
	m_pTeamInfo[2].m_TeamColor = WindowConsole(Player.Console).Root.Colors.TeamColorLight[2];
	return;
}

//function called after a planning has been loaded to spawn the reference icons and pathflags
function InitNewPlanning(int iSelectedTeam)
{
	m_iCurrentTeam = iSelectedTeam;
	m_pTeamInfo[0].InitPlanning(0, self);
	m_pTeamInfo[1].InitPlanning(1, self);
	m_pTeamInfo[2].InitPlanning(2, self);
	// End:0x5B
	if((m_iCurrentTeam == 0))
	{
		SwitchToRedTeam(true);		
	}
	else
	{
		// End:0x70
		if((m_iCurrentTeam == 1))
		{
			SwitchToGreenTeam(true);			
		}
		else
		{
			// End:0x83
			if((m_iCurrentTeam == 2))
			{
				SwitchToGoldTeam(true);
			}
		}
	}
	return;
}

event Destroyed()
{
	m_pTeamInfo[0].RemovePointsRefsToCtrl();
	m_pTeamInfo[0].m_pTeamManager = none;
	m_pTeamInfo[1].RemovePointsRefsToCtrl();
	m_pTeamInfo[1].m_pTeamManager = none;
	m_pTeamInfo[2].RemovePointsRefsToCtrl();
	m_pTeamInfo[2].m_pTeamManager = none;
	super.Destroyed();
	return;
}

// Update the camera location & rotation changed by the menu
event PlayerTick(float fDeltaTime)
{
	local Vector vAxisX, vAxisY, vAxisZ, vHitLocation;
	local float fMovementX, fMovementY, fAngle;
	local int iCurrentPlanning;
	local R6ActionPoint pCurrentPoint;

	super.PlayerTick(fDeltaTime);
	// End:0x77
	if(WindowConsole(Player.Console).Root.PlanningShouldDrawPath())
	{
		m_pTeamInfo[0].Tick(fDeltaTime);
		m_pTeamInfo[1].Tick(fDeltaTime);
		m_pTeamInfo[2].Tick(fDeltaTime);
	}
	// End:0xD2
	if((m_fZoomDelta != 0.0000000))
	{
		(m_fZoom += (m_fZoomDelta * fDeltaTime));
		m_fZoom = FClamp(m_fZoom, m_fZoomMin, m_fZoomMax);
		m_fZoomFactor = (m_fZoom * float(12));
		FovAngle = (m_fZoom * float(90));
	}
	// End:0x1A9
	if((m_fCameraAngle != float(0)))
	{
		m_vCamPos.X = FClamp((m_vCamPos.X + ((m_fCameraAngle * m_fZoomFactor) * fDeltaTime)), (m_fAngleMax + float(5000)), 1.0000000);
		fAngle = Sin(Acos((m_vCamPos.X / m_fAngleMax)));
		m_vCamPos.Z = (15000.0000000 * fAngle);
		fAngle = Atan((m_vCamPos.Z / m_vCamPos.X));
		(fAngle /= (3.1415930 * 0.5000000));
		m_rCamRot.Pitch = (65536 - int((Abs(fAngle) * float(16384))));
	}
	// End:0x1D2
	if((m_fRotateDelta != 0.0000000))
	{
		(m_rCamRot.Yaw += int((m_fRotateDelta * fDeltaTime)));
	}
	GetAxes(m_rCamRot, vAxisX, vAxisY, vAxisZ);
	vAxisY.Z = 0.0000000;
	vAxisY = Normal(vAxisY);
	vAxisZ.Z = 0.0000000;
	vAxisZ = Normal(vAxisZ);
	// End:0x26C
	if(((m_bPlayMode == true) && (m_bLockCamera == true)))
	{
		m_vCamPosNoRot = R6PlanningPawn(Pawn).m_ArrowInPlanningView.Location;
		m_vCamDesiredPos = m_vCamPosNoRot;		
	}
	else
	{
		fMovementX = ((m_vCamDelta.Y * fDeltaTime) * m_fZoomFactor);
		fMovementY = ((m_vCamDelta.X * fDeltaTime) * m_fZoomFactor);
		// End:0x3A9
		if((((m_vCamDesiredPos == m_vCamPosNoRot) || (fMovementX != float(0))) || (fMovementY != float(0))))
		{
			m_vCamPosNoRot.X = FClamp(((m_vCamPosNoRot.X + (fMovementX * vAxisY.Y)) + (fMovementY * vAxisY.X)), Level.R6PlanningMinVector.X, Level.R6PlanningMaxVector.X);
			m_vCamPosNoRot.Y = FClamp(((m_vCamPosNoRot.Y + (fMovementX * vAxisZ.Y)) + (fMovementY * vAxisZ.X)), Level.R6PlanningMinVector.Y, Level.R6PlanningMaxVector.Y);
			m_vCamDesiredPos = m_vCamPosNoRot;			
		}
		else
		{
			m_vCamPosNoRot.X = FClamp((m_vCamPosNoRot.X + ((m_vCamDesiredPos.X - m_vCamPosNoRot.X) * fDeltaTime)), Level.R6PlanningMinVector.X, Level.R6PlanningMaxVector.X);
			m_vCamPosNoRot.Y = FClamp((m_vCamPosNoRot.Y + ((m_vCamDesiredPos.Y - m_vCamPosNoRot.Y) * fDeltaTime)), Level.R6PlanningMinVector.Y, Level.R6PlanningMaxVector.Y);
			// End:0x483
			if((VSize((m_vCamDesiredPos - m_vCamPosNoRot)) < float(20)))
			{
				m_vCamDesiredPos = m_vCamPosNoRot;
			}
		}
	}
	// End:0x4D0
	if((m_bSetSnipeDirection == true))
	{
		vHitLocation = GetXYPoint(m_fLastMouseX, m_fLastMouseY, GetCurrentPoint().Location.Z);
		m_pTeamInfo[m_iCurrentTeam].AjustSnipeDirection(vHitLocation);
	}
	m_vCurrentCameraPos.X = (m_vCamPosNoRot.X + (m_vCamPos.X * vAxisY.Y));
	m_vCurrentCameraPos.Y = (m_vCamPosNoRot.Y + (m_vCamPos.X * vAxisZ.Y));
	m_vCurrentCameraPos.Z = m_vCamPos.Z;
	// End:0x6AA
	if((m_bRender3DView == true))
	{
		// End:0x599
		if((m_bPlayMode == true))
		{
			m_pCameraDirIcon.bHidden = true;
			R6PlanningPawn(Pawn).m_ArrowInPlanningView.RenderLevelFromMe(m_3DWindowPositionX, m_3DWindowPositionY, m_3DWindowPositionW, m_3DWindowPositionH);			
		}
		else
		{
			pCurrentPoint = GetCurrentPoint();
			// End:0x655
			if((pCurrentPoint != none))
			{
				pCurrentPoint.RenderLevelFromMe(m_3DWindowPositionX, m_3DWindowPositionY, m_3DWindowPositionW, m_3DWindowPositionH);
				m_pCameraDirIcon.bHidden = false;
				m_pCameraDirIcon.SetLocation(pCurrentPoint.Location);
				m_pCameraDirIcon.SetPlanningRotation(pCurrentPoint.Rotation);
				m_pCameraDirIcon.m_iPlanningFloor_0 = pCurrentPoint.m_iPlanningFloor_0;
				m_pCameraDirIcon.m_iPlanningFloor_1 = pCurrentPoint.m_iPlanningFloor_1;				
			}
			else
			{
				m_pCameraDirIcon.bHidden = true;
				// End:0x693
				if((m_CamSpot != none))
				{
					m_CamSpot.RenderLevelFromMe(m_3DWindowPositionX, m_3DWindowPositionY, m_3DWindowPositionW, m_3DWindowPositionH);
					return;
				}
				RenderLevelFromMe(m_3DWindowPositionX, m_3DWindowPositionY, m_3DWindowPositionW, m_3DWindowPositionH);
			}
		}
	}
	return;
}

//=======================================================================================//
//                          INPUT exec() functions (controls)                            //
//=======================================================================================//
exec function DeleteWaypoint()
{
	// End:0x3D
	if(((m_bPlayMode == false) && WindowConsole(Player.Console).Root.PlanningShouldProcessKey()))
	{
		DeleteOneNode();
	}
	return;
}

exec function PrevWaypoint()
{
	// End:0x3D
	if(((m_bPlayMode == false) && WindowConsole(Player.Console).Root.PlanningShouldProcessKey()))
	{
		GotoPrevNode();
	}
	return;
}

exec function NextWaypoint()
{
	// End:0x3D
	if(((m_bPlayMode == false) && WindowConsole(Player.Console).Root.PlanningShouldProcessKey()))
	{
		GoToNextNode();
	}
	return;
}

exec function FirstWaypoint()
{
	// End:0x3D
	if(((m_bPlayMode == false) && WindowConsole(Player.Console).Root.PlanningShouldProcessKey()))
	{
		GotoFirstNode();
	}
	return;
}

exec function LastWaypoint()
{
	// End:0x3D
	if(((m_bPlayMode == false) && WindowConsole(Player.Console).Root.PlanningShouldProcessKey()))
	{
		GotoLastNode();
	}
	return;
}

exec function SwitchToRedTeam(optional bool bForceFunction)
{
	// End:0xDE
	if(((bForceFunction == true) || ((((m_bPlayMode == false) && WindowConsole(Player.Console).Root.PlanningShouldProcessKey()) && (m_bSetSnipeDirection == false)) && (m_bClickToFindLocation == false))))
	{
		m_iCurrentTeam = 0;
		m_pTeamInfo[0].SelectTeam(true);
		m_pTeamInfo[1].SelectTeam(false);
		m_pTeamInfo[2].SelectTeam(false);
		m_pTeamInfo[0].SetPathDisplay(true);
		MoveCamOver();
		WindowConsole(Player.Console).Root.UpdateMenus(0);
	}
	return;
}

exec function SwitchToGreenTeam(optional bool bForceFunction)
{
	// End:0xDE
	if(((bForceFunction == true) || ((((m_bPlayMode == false) && WindowConsole(Player.Console).Root.PlanningShouldProcessKey()) && (m_bSetSnipeDirection == false)) && (m_bClickToFindLocation == false))))
	{
		m_iCurrentTeam = 1;
		m_pTeamInfo[0].SelectTeam(false);
		m_pTeamInfo[1].SelectTeam(true);
		m_pTeamInfo[2].SelectTeam(false);
		m_pTeamInfo[1].SetPathDisplay(true);
		MoveCamOver();
		WindowConsole(Player.Console).Root.UpdateMenus(1);
	}
	return;
}

exec function SwitchToGoldTeam(optional bool bForceFunction)
{
	// End:0xE1
	if(((bForceFunction == true) || ((((m_bPlayMode == false) && WindowConsole(Player.Console).Root.PlanningShouldProcessKey()) && (m_bSetSnipeDirection == false)) && (m_bClickToFindLocation == false))))
	{
		m_iCurrentTeam = 2;
		m_pTeamInfo[0].SelectTeam(false);
		m_pTeamInfo[1].SelectTeam(false);
		m_pTeamInfo[2].SelectTeam(true);
		m_pTeamInfo[2].SetPathDisplay(true);
		MoveCamOver();
		WindowConsole(Player.Console).Root.UpdateMenus(2);
	}
	return;
}

exec function ViewRedTeam()
{
	// End:0x82
	if((WindowConsole(Player.Console).Root.PlanningShouldProcessKey() && (m_iCurrentTeam != 0)))
	{
		m_pTeamInfo[0].SetPathDisplay((!m_pTeamInfo[0].m_bDisplayPath));
		WindowConsole(Player.Console).Root.UpdateMenus(3);
	}
	return;
}

exec function ViewGreenTeam()
{
	// End:0x82
	if((WindowConsole(Player.Console).Root.PlanningShouldProcessKey() && (m_iCurrentTeam != 1)))
	{
		m_pTeamInfo[1].SetPathDisplay((!m_pTeamInfo[1].m_bDisplayPath));
		WindowConsole(Player.Console).Root.UpdateMenus(4);
	}
	return;
}

exec function ViewGoldTeam()
{
	// End:0x85
	if((WindowConsole(Player.Console).Root.PlanningShouldProcessKey() && (m_iCurrentTeam != 2)))
	{
		m_pTeamInfo[2].SetPathDisplay((!m_pTeamInfo[2].m_bDisplayPath));
		WindowConsole(Player.Console).Root.UpdateMenus(5);
	}
	return;
}

// Setup the new Location & Rotation
event PlayerCalcView(out Actor aViewActor, out Vector vCameraLocation, out Rotator rCameraRotation)
{
	rCameraRotation = m_rCamRot;
	vCameraLocation = m_vCurrentCameraPos;
	return;
}

// Empty this function, it change the FOV ... we don't change the FOV here
function FixFOV()
{
	return;
}

// Empty this function, it change the FOV ... we don't change the FOV here
function AdjustView(float DeltaTime)
{
	return;
}

function Toggle3DView()
{
	m_pCameraDirIcon.bHidden = m_bRender3DView;
	m_bRender3DView = (!m_bRender3DView);
	return;
}

function TurnOff3DView()
{
	m_bRender3DView = false;
	m_pCameraDirIcon.bHidden = true;
	return;
}

function TurnOn3DMove(float X, float Y)
{
	m_bMove3DView = (!m_bMove3DView);
	// End:0x40
	if((m_bMove3DView && (GetCurrentPoint() != none)))
	{
		GetCurrentPoint().Init3DView(X, Y);
	}
	return;
}

function TurnOff3DMove()
{
	m_bMove3DView = false;
	return;
}

function Ajust3DRotation(float X, float Y)
{
	// End:0x26
	if((GetCurrentPoint() != none))
	{
		GetCurrentPoint().RotateView(X, Y);
	}
	return;
}

// Toggle the floor display
function ChangeLevelDisplay(int iStep)
{
	// End:0x3A
	if((iStep > 0))
	{
		// End:0x37
		if((m_iLevelDisplay < Level.R6PlanningMaxLevel))
		{
			(m_iLevelDisplay += iStep);
			SetFloorToDraw(m_iLevelDisplay);
		}		
	}
	else
	{
		// End:0x66
		if((m_iLevelDisplay > Level.R6PlanningMinLevel))
		{
			(m_iLevelDisplay += iStep);
			SetFloorToDraw(m_iLevelDisplay);
		}
	}
	return;
}

//-----------------------------------------------------------//
//                      Mouse functions                      //
//-----------------------------------------------------------//
function LMouseDown(float X, float Y)
{
	local Actor pHitActor;
	local Vector vHitLocation, vHitNormal, vSpawnOffset;
	local R6ActionPoint FirstActionPoint;
	local int iChangeLevelTo;
	local R6Ladder aHitActorLadder;
	local R6ActionPoint pCurrentPoint;

	// End:0x0E
	if((m_bPlayMode == true))
	{
		return;
	}
	// End:0x4C
	if((m_bSetSnipeDirection == true))
	{
		m_bSetSnipeDirection = false;
		WindowConsole(Player.Console).Root.m_bUseAimIcon = false;
		return;
	}
	pCurrentPoint = GetCurrentPoint();
	// End:0x770
	if((GetClickResult(X, Y, vHitLocation, pHitActor, iChangeLevelTo) == true))
	{
		// End:0x251
		if((m_bClickToFindLocation == true))
		{
			// End:0x153
			if((m_bClickedOnRange == false))
			{
				// End:0xF0
				if(((pHitActor != none) && pHitActor.IsA('R6PlanningRangeGrenade')))
				{
					m_bClickedOnRange = true;
					pHitActor.bHidden = true;
					LMouseDown(X, Y);
					pHitActor.bHidden = false;					
				}
				else
				{
					// End:0x146
					if(((pHitActor != none) && pHitActor.IsA('R6CameraDirection')))
					{
						pHitActor.bHidden = true;
						LMouseDown(X, Y);
						pHitActor.bHidden = false;						
					}
					else
					{
						PlaySound(m_PlanningBadClickSnd, 9);
					}
				}				
			}
			else
			{
				// End:0x1DA
				if((((pHitActor != none) && (!(pHitActor.IsA('StaticMeshActor') && (pHitActor.m_bIsWalkable == true)))) && (!pHitActor.IsA('TerrainInfo'))))
				{
					pHitActor.bHidden = true;
					LMouseDown(X, Y);
					pHitActor.bHidden = false;					
				}
				else
				{
					// End:0x245
					if(m_pTeamInfo[m_iCurrentTeam].SetGrenadeLocation(vHitLocation))
					{
						pCurrentPoint.bHidden = false;
						m_bClickToFindLocation = false;
						WindowConsole(Player.Console).Root.m_bUseAimIcon = false;
						PlaySound(m_PlanningGoodClickSnd, 9);						
					}
					else
					{
						PlaySound(m_PlanningBadClickSnd, 9);
					}
				}
			}
			return;
		}
		// End:0x74A
		if((pHitActor != none))
		{
			// End:0x2BF
			if(pHitActor.IsA('R6ActionPoint'))
			{
				// End:0x2BC
				if((R6ActionPoint(pHitActor).m_iRainbowTeamName == m_iCurrentTeam))
				{
					m_pTeamInfo[m_iCurrentTeam].SetAsCurrentNode(R6ActionPoint(pHitActor));
					m_bCanMoveFirstPoint = false;
					m_bActionPointSelected = true;
				}				
			}
			else
			{
				// End:0x2D8
				if(pHitActor.IsA('R6PathFlag'))
				{
					return;					
				}
				else
				{
					// End:0x32F
					if((pHitActor.IsA('R6PlanningBreach') || pHitActor.IsA('R6PlanningGrenade')))
					{
						m_pTeamInfo[m_iCurrentTeam].SetAsCurrentNode(R6ActionPoint(pHitActor.Owner));
						return;						
					}
					else
					{
						// End:0x38B
						if(pHitActor.IsA('StaticMeshActor'))
						{
							// End:0x37E
							if((pHitActor.m_bIsWalkable == true))
							{
								CastActionPointAt(vHitLocation, m_iLevelDisplay, iChangeLevelTo, int(X), int(Y));								
							}
							else
							{
								PlaySound(m_PlanningBadClickSnd, 9);
							}							
						}
						else
						{
							// End:0x59A
							if(pHitActor.IsA('R6Ladder'))
							{
								aHitActorLadder = R6Ladder(pHitActor);
								// End:0x40E
								if((aHitActorLadder.m_iPlanningFloor_0 == aHitActorLadder.m_pOtherFloor.m_iPlanningFloor_0))
								{
									pHitActor.bHidden = true;
									LMouseDown(X, Y);
									pHitActor.bHidden = false;									
								}
								else
								{
									// End:0x462
									if((!((m_bPlayMode == true) && (m_bLockCamera == true))))
									{
										ChangeLevelDisplay((aHitActorLadder.m_pOtherFloor.m_iPlanningFloor_0 - aHitActorLadder.m_iPlanningFloor_0));
										m_vCamDesiredPos = m_vCamPosNoRot;
									}
									// End:0x4C4
									if((aHitActorLadder.m_bIsTopOfLadder == true))
									{
										vSpawnOffset = (Vector(aHitActorLadder.m_pOtherFloor.Rotation) * -100.0000000);
										vHitLocation = (aHitActorLadder.m_pOtherFloor.Location + vSpawnOffset);										
									}
									else
									{
										vSpawnOffset = (Vector(aHitActorLadder.m_pOtherFloor.Rotation) * 100.0000000);
										Trace(vHitLocation, vHitNormal, ((aHitActorLadder.m_pOtherFloor.Location + vSpawnOffset) + vect(0.0000000, 0.0000000, -100.0000000)), (aHitActorLadder.m_pOtherFloor.Location + vSpawnOffset), true, vect(0.0000000, 0.0000000, 0.0000000));
									}
									CastActionPointAt(vHitLocation, aHitActorLadder.m_pOtherFloor.m_iPlanningFloor_0, aHitActorLadder.m_pOtherFloor.m_iPlanningFloor_0, int(X), int(Y));
								}								
							}
							else
							{
								// End:0x710
								if(pHitActor.IsA('R6InsertionZone'))
								{
									// End:0x5E3
									if((m_pTeamInfo[m_iCurrentTeam].m_iCurrentNode == -1))
									{
										m_pTeamInfo[m_iCurrentTeam].m_bPlacedFirstPoint = true;
									}
									pHitActor.bHidden = true;
									LMouseDown(X, Y);
									pHitActor.bHidden = false;
									// End:0x70D
									if((m_pTeamInfo[m_iCurrentTeam].m_iCurrentNode == -1))
									{
										// End:0x6F6
										if((m_pTeamInfo[m_iCurrentTeam].m_NodeList.Length > 0))
										{
											pCurrentPoint = R6ActionPoint(m_pTeamInfo[m_iCurrentTeam].m_NodeList[0]);
											m_pTeamInfo[m_iCurrentTeam].m_iStartingPointNumber = R6InsertionZone(pHitActor).m_iInsertionNumber;
											m_pTeamInfo[m_iCurrentTeam].SetAsCurrentNode(pCurrentPoint);
											pCurrentPoint.SetRotation(pHitActor.Rotation);
											pCurrentPoint.m_u8SpritePlanningAngle = byte((pCurrentPoint.Rotation.Yaw / 255));											
										}
										else
										{
											m_pTeamInfo[m_iCurrentTeam].m_bPlacedFirstPoint = false;
										}
									}									
								}
								else
								{
									// End:0x747
									if(pHitActor.IsA('TerrainInfo'))
									{
										CastActionPointAt(vHitLocation, iChangeLevelTo, iChangeLevelTo, int(X), int(Y));
									}
								}
							}
						}
					}
				}
			}			
		}
		else
		{
			CastActionPointAt(vHitLocation, m_iLevelDisplay, iChangeLevelTo, int(X), int(Y));
		}		
	}
	else
	{
		PlaySound(m_PlanningBadClickSnd, 9);
	}
	return;
}

function RMouseUp(float X, float Y)
{
	return;
}

function LMouseUp(float X, float Y)
{
	local Actor pHitActor;
	local Vector vHitLocation;
	local int iChangeLevelTo;

	// End:0x20C
	if(((m_bActionPointSelected == true) && (WindowConsole(Player.Console).Root.m_bUseDragIcon == true)))
	{
		m_pTeamInfo[m_iCurrentTeam].GetPoint().bHidden = true;
		// End:0x1E1
		if((GetClickResult(X, Y, vHitLocation, pHitActor, iChangeLevelTo) == true))
		{
			// End:0x1C9
			if((pHitActor != none))
			{
				// End:0x1C6
				if((!((((pHitActor.IsA('R6ActionPoint') || pHitActor.IsA('R6PathFlag')) || pHitActor.IsA('R6PlanningBreach')) || pHitActor.IsA('R6PlanningGrenade')) || pHitActor.IsA('R6Ladder'))))
				{
					// End:0x137
					if(pHitActor.IsA('StaticMeshActor'))
					{
						// End:0x134
						if((pHitActor.m_bIsWalkable == true))
						{
							MoveActionPointTo(vHitLocation, m_iLevelDisplay, iChangeLevelTo);
						}						
					}
					else
					{
						// End:0x178
						if(pHitActor.IsA('TerrainInfo'))
						{
							// End:0x175
							if((pHitActor.m_bIsWalkable == true))
							{
								MoveActionPointTo(vHitLocation, iChangeLevelTo, iChangeLevelTo);
							}							
						}
						else
						{
							// End:0x194
							if(pHitActor.IsA('R6InsertionZone'))
							{
								m_bCanMoveFirstPoint = true;
							}
							pHitActor.bHidden = true;
							LMouseUp(X, Y);
							pHitActor.bHidden = false;
						}
					}
				}				
			}
			else
			{
				MoveActionPointTo(vHitLocation, m_iLevelDisplay, iChangeLevelTo);
			}			
		}
		else
		{
			PlaySound(m_PlanningBadClickSnd, 9);
		}
		m_pTeamInfo[m_iCurrentTeam].GetPoint().bHidden = false;
	}
	WindowConsole(Player.Console).Root.m_bUseDragIcon = false;
	m_bActionPointSelected = false;
	return;
}

function RMouseDown(float X, float Y)
{
	local Actor pHitActor, pHitActorBackup;
	local Vector vHitLocation, vHitNormal, vSpawnOffset;
	local R6ActionPoint FirstActionPoint;
	local int iChangeLevelTo;
	local R6Ladder aHitActorLadder;
	local R6ActionPoint pCurrentPoint;

	// End:0x0E
	if((m_bPlayMode == true))
	{
		return;
	}
	// End:0x30
	if(((m_bSetSnipeDirection == true) || (m_bClickToFindLocation == true)))
	{
		CancelActionPointAction();
		return;
	}
	pCurrentPoint = GetCurrentPoint();
	// End:0x719
	if((GetClickResult(X, Y, vHitLocation, pHitActor, iChangeLevelTo) == true))
	{
		// End:0x6BB
		if((pHitActor != none))
		{
			// End:0xF1
			if(pHitActor.IsA('R6ActionPoint'))
			{
				// End:0xEE
				if((R6ActionPoint(pHitActor).m_iRainbowTeamName == m_iCurrentTeam))
				{
					m_pTeamInfo[m_iCurrentTeam].SetAsCurrentNode(R6ActionPoint(pHitActor));
					WindowConsole(Player.Console).Root.KeyType(1024, X, Y);
				}				
			}
			else
			{
				// End:0x18B
				if(pHitActor.IsA('R6PathFlag'))
				{
					// End:0x188
					if((R6ActionPoint(pHitActor.Owner).m_iRainbowTeamName == m_iCurrentTeam))
					{
						m_pTeamInfo[m_iCurrentTeam].SetAsCurrentNode(R6ActionPoint(pHitActor.Owner));
						WindowConsole(Player.Console).Root.KeyType(1026, X, Y);
					}					
				}
				else
				{
					// End:0x1E2
					if((pHitActor.IsA('R6PlanningBreach') || pHitActor.IsA('R6PlanningGrenade')))
					{
						m_pTeamInfo[m_iCurrentTeam].SetAsCurrentNode(R6ActionPoint(pHitActor.Owner));
						return;						
					}
					else
					{
						// End:0x276
						if(pHitActor.IsA('StaticMeshActor'))
						{
							// End:0x269
							if((pHitActor.m_bIsWalkable == true))
							{
								// End:0x266
								if(CastActionPointAt(vHitLocation, m_iLevelDisplay, iChangeLevelTo, int(X), int(Y)))
								{
									WindowConsole(Player.Console).Root.KeyType(1024, X, Y);
								}								
							}
							else
							{
								PlaySound(m_PlanningBadClickSnd, 9);
							}							
						}
						else
						{
							// End:0x4BD
							if(pHitActor.IsA('R6Ladder'))
							{
								aHitActorLadder = R6Ladder(pHitActor);
								// End:0x2F9
								if((aHitActorLadder.m_iPlanningFloor_0 == aHitActorLadder.m_pOtherFloor.m_iPlanningFloor_1))
								{
									pHitActor.bHidden = true;
									RMouseDown(X, Y);
									pHitActor.bHidden = false;									
								}
								else
								{
									// End:0x34D
									if((!((m_bPlayMode == true) && (m_bLockCamera == true))))
									{
										ChangeLevelDisplay((aHitActorLadder.m_pOtherFloor.m_iPlanningFloor_0 - aHitActorLadder.m_iPlanningFloor_0));
										m_vCamDesiredPos = m_vCamPosNoRot;
									}
									// End:0x3AF
									if((aHitActorLadder.m_bIsTopOfLadder == true))
									{
										vSpawnOffset = (Vector(aHitActorLadder.m_pOtherFloor.Rotation) * -100.0000000);
										vHitLocation = (aHitActorLadder.m_pOtherFloor.Location + vSpawnOffset);										
									}
									else
									{
										vSpawnOffset = (Vector(aHitActorLadder.m_pOtherFloor.Rotation) * 100.0000000);
										Trace(vHitLocation, vHitNormal, ((aHitActorLadder.m_pOtherFloor.Location + vSpawnOffset) + vect(0.0000000, 0.0000000, -100.0000000)), (aHitActorLadder.m_pOtherFloor.Location + vSpawnOffset), true, vect(0.0000000, 0.0000000, 0.0000000));
									}
									// End:0x4BA
									if(CastActionPointAt(vHitLocation, aHitActorLadder.m_pOtherFloor.m_iPlanningFloor_0, aHitActorLadder.m_pOtherFloor.m_iPlanningFloor_0, int(X), int(Y)))
									{
										WindowConsole(Player.Console).Root.KeyType(1024, X, Y);
									}
								}								
							}
							else
							{
								// End:0x649
								if(pHitActor.IsA('R6InsertionZone'))
								{
									// End:0x506
									if((m_pTeamInfo[m_iCurrentTeam].m_iCurrentNode == -1))
									{
										m_pTeamInfo[m_iCurrentTeam].m_bPlacedFirstPoint = true;
									}
									pHitActor.bHidden = true;
									LMouseDown(X, Y);
									pHitActor.bHidden = false;
									// End:0x611
									if((m_pTeamInfo[m_iCurrentTeam].m_iCurrentNode == -1))
									{
										pCurrentPoint = R6ActionPoint(m_pTeamInfo[m_iCurrentTeam].m_NodeList[0]);
										m_pTeamInfo[m_iCurrentTeam].m_iStartingPointNumber = R6InsertionZone(pHitActor).m_iInsertionNumber;
										m_pTeamInfo[m_iCurrentTeam].SetAsCurrentNode(R6ActionPoint(m_pTeamInfo[m_iCurrentTeam].m_NodeList[0]));
										pCurrentPoint.SetRotation(pHitActor.Rotation);
										pCurrentPoint.m_u8SpritePlanningAngle = byte((pCurrentPoint.Rotation.Yaw / 255));
									}
									WindowConsole(Player.Console).Root.KeyType(1024, X, Y);									
								}
								else
								{
									// End:0x6B8
									if(pHitActor.IsA('TerrainInfo'))
									{
										// End:0x6B8
										if(CastActionPointAt(vHitLocation, iChangeLevelTo, iChangeLevelTo, int(X), int(Y)))
										{
											WindowConsole(Player.Console).Root.KeyType(1024, X, Y);
										}
									}
								}
							}
						}
					}
				}
			}			
		}
		else
		{
			// End:0x716
			if(CastActionPointAt(vHitLocation, m_iLevelDisplay, iChangeLevelTo, int(X), int(Y)))
			{
				WindowConsole(Player.Console).Root.KeyType(1024, X, Y);
			}
		}		
	}
	else
	{
		PlaySound(m_PlanningBadClickSnd, 9);
	}
	return;
}

function MouseMove(float X, float Y)
{
	local Vector vHitLocation;

	// End:0x63
	if((m_bSetSnipeDirection == true))
	{
		m_fLastMouseX = X;
		m_fLastMouseY = Y;
		vHitLocation = GetXYPoint(X, Y, GetCurrentPoint().Location.Z);
		m_pTeamInfo[m_iCurrentTeam].AjustSnipeDirection(vHitLocation);
	}
	// End:0x9A
	if((m_bActionPointSelected == true))
	{
		WindowConsole(Player.Console).Root.m_bUseDragIcon = true;		
	}
	else
	{
		WindowConsole(Player.Console).Root.m_bUseDragIcon = false;
	}
	return;
}

// Cancel setting an action point Action.  (setting grenade or snipe direction.
function CancelActionPointAction()
{
	local R6ActionPoint pCurrentPoint;

	// End:0xA7
	if(((m_bSetSnipeDirection == true) || (m_bClickToFindLocation == true)))
	{
		pCurrentPoint = GetCurrentPoint();
		pCurrentPoint.m_eAction = 0;
		pCurrentPoint.m_pActionIcon.Destroy();
		pCurrentPoint.m_pActionIcon = none;
		pCurrentPoint.bHidden = false;
		m_bClickToFindLocation = false;
		m_bSetSnipeDirection = false;
		WindowConsole(Player.Console).Root.m_bUseAimIcon = false;
		return;
	}
	return;
}

//-----------------------------------------------------------//
//                   ActionPoint functions                   //
//-----------------------------------------------------------//
function ResetAllID()
{
	m_pTeamInfo[0].ResetID();
	m_pTeamInfo[1].ResetID();
	m_pTeamInfo[2].ResetID();
	return;
}

function ResetIDs()
{
	m_pTeamInfo[m_iCurrentTeam].ResetID();
	return;
}

function Texture GetActionTypeTexture(Object.EPlanActionType EActionType, optional int iMilestone)
{
	switch(EActionType)
	{
		// End:0x17
		case 2:
			return m_pIconTex[0];
			// End:0x53
			break;
		// End:0x27
		case 3:
			return m_pIconTex[1];
			// End:0x53
			break;
		// End:0x38
		case 4:
			return m_pIconTex[2];
			// End:0x53
			break;
		// End:0x50
		case 1:
			return m_pIconTex[(2 + iMilestone)];
			// End:0x53
			break;
		// End:0xFFFF
		default:
			break;
	}
	return none;
	return;
}

function MoveActionPointTo(Vector vHitLocation, int iFirstFloor, int iSecondFloor)
{
	local R6ActionPoint pCurrentActionPoint;
	local Vector vBackupLocation;

	// End:0x34
	if(((m_pTeamInfo[m_iCurrentTeam].m_iCurrentNode == 0) && (m_bCanMoveFirstPoint == false)))
	{
		PlaySound(m_PlanningBadClickSnd, 9);
		return;
	}
	(vHitLocation.Z += m_fCastingHeight);
	pCurrentActionPoint = GetCurrentPoint();
	vBackupLocation = pCurrentActionPoint.Location;
	pCurrentActionPoint.SetLocation(vHitLocation);
	// End:0x16E
	if((m_pTeamInfo[m_iCurrentTeam].MoveCurrentPoint() == true))
	{
		pCurrentActionPoint.m_eAction = 0;
		// End:0xDB
		if((pCurrentActionPoint.m_pActionIcon != none))
		{
			pCurrentActionPoint.m_pActionIcon.Destroy();
			pCurrentActionPoint.m_pActionIcon = none;
		}
		m_pTeamInfo[m_iCurrentTeam].SetPointRotation();
		// End:0x12A
		if((iFirstFloor < iSecondFloor))
		{
			pCurrentActionPoint.m_iPlanningFloor_0 = iFirstFloor;
			pCurrentActionPoint.m_iPlanningFloor_1 = iSecondFloor;			
		}
		else
		{
			pCurrentActionPoint.m_iPlanningFloor_0 = iSecondFloor;
			pCurrentActionPoint.m_iPlanningFloor_1 = iFirstFloor;
		}
		pCurrentActionPoint.FindDoor();
		PlaySound(m_PlanningGoodClickSnd, 9);		
	}
	else
	{
		PlaySound(m_PlanningBadClickSnd, 9);
		pCurrentActionPoint.SetLocation(vBackupLocation);
		m_pTeamInfo[m_iCurrentTeam].MoveCurrentPoint();
	}
	return;
}

// Spawn an ActionPoint at the X, Y screen location
// Return true if the ActionPoint is spawned
function bool CastActionPointAt(Vector vLocation, int iFirstFloor, int iSecondFloor, int X, int Y)
{
	local bool bResult, bReturnValue;
	local R6ActionPoint pNewActionPoint;
	local R6PlanningInfo pTeamInfo;
	local R6InsertionZone pInsertionZone;

	bReturnValue = true;
	pTeamInfo = m_pTeamInfo[m_iCurrentTeam];
	// End:0x6B
	if((pTeamInfo.m_bPlacedFirstPoint == false))
	{
		Log("-->First ActionPoint must be on an InsertionZone!");
		bReturnValue = false;
	}
	// End:0xAF
	if((pTeamInfo.m_NodeList.Length > 500))
	{
		Log("-->too Many points in planning!");
		bReturnValue = false;
	}
	// End:0x3AA
	if(bReturnValue)
	{
		(vLocation.Z += m_fCastingHeight);
		bResult = FindSpot(vLocation, vect(42.0000000, 42.0000000, 62.0000000));
		// End:0x374
		if((bResult == true))
		{
			pNewActionPoint = Spawn(Class'R6Game.R6ActionPoint',,, vLocation);
			// End:0x349
			if((pNewActionPoint != none))
			{
				pNewActionPoint.m_pPlanningCtrl = self;
				// End:0x15B
				if((iFirstFloor <= iSecondFloor))
				{
					pNewActionPoint.m_iPlanningFloor_0 = iFirstFloor;
					pNewActionPoint.m_iPlanningFloor_1 = iSecondFloor;					
				}
				else
				{
					pNewActionPoint.m_iPlanningFloor_0 = iSecondFloor;
					pNewActionPoint.m_iPlanningFloor_1 = iFirstFloor;
				}
				// End:0x1AA
				if((pTeamInfo.m_iCurrentNode == -1))
				{
					pNewActionPoint.SetFirstPointTexture();
				}
				pNewActionPoint.FindDoor();
				// End:0x2A2
				if(((pTeamInfo.m_iCurrentNode != -1) && (pTeamInfo.m_iCurrentNode != (pTeamInfo.m_NodeList.Length - 1))))
				{
					// End:0x271
					if((m_pTeamInfo[m_iCurrentTeam].InsertPoint(pNewActionPoint) == true))
					{
						pNewActionPoint.m_iRainbowTeamName = m_iCurrentTeam;
						// End:0x26E
						if(((((X < 100) || (X > 544)) || (Y < 54)) || (Y > 326)))
						{
							MoveCamOver();
						}						
					}
					else
					{
						Log("Could not Insert point at location");
						bReturnValue = false;
					}					
				}
				else
				{
					// End:0x31B
					if((m_pTeamInfo[m_iCurrentTeam].AddPoint(pNewActionPoint) == true))
					{
						pNewActionPoint.m_iRainbowTeamName = m_iCurrentTeam;
						// End:0x318
						if(((((X < 100) || (X > 544)) || (Y < 54)) || (Y > 326)))
						{
							MoveCamOver();
						}						
					}
					else
					{
						Log("Could not add point at location");
						bReturnValue = false;
					}
				}				
			}
			else
			{
				bReturnValue = false;
				Log("Could not spawn action point");
			}			
		}
		else
		{
			bReturnValue = false;
			Log("Could not find place to spawn action point");
		}
	}
	// End:0x3C0
	if(bReturnValue)
	{
		PlaySound(m_PlanningGoodClickSnd, 9);		
	}
	else
	{
		PlaySound(m_PlanningBadClickSnd, 9);
	}
	return bReturnValue;
	return;
}

function DeleteOneNode()
{
	CancelActionPointAction();
	// End:0x2B
	if(m_pTeamInfo[m_iCurrentTeam].DeleteNode())
	{
		PlaySound(m_PlanningRemoveSnd, 9);		
	}
	else
	{
		PlaySound(m_PlanningBadClickSnd, 9);
	}
	// End:0x5E
	if((GetCurrentPoint() != none))
	{
		m_iLevelDisplay = GetCurrentPoint().m_iPlanningFloor_0;
		SetFloorToDraw(m_iLevelDisplay);
	}
	return;
}

function DeleteAllNode()
{
	CancelActionPointAction();
	m_pTeamInfo[m_iCurrentTeam].DeleteAllNode();
	PositionCameraOnInsertionZone();
	return;
}

function PositionCameraOnInsertionZone()
{
	local R6InsertionZone anInsertionZone;

	// End:0x9E
	foreach AllActors(Class'R6Game.R6InsertionZone', anInsertionZone)
	{
		// End:0x9D
		if(((anInsertionZone.m_iInsertionNumber == 0) && anInsertionZone.IsAvailableInGameType(R6AbstractGameInfo(Level.Game).m_szGameTypeFlag)))
		{
			SetFloorToDraw(anInsertionZone.m_iPlanningFloor_0);
			m_iLevelDisplay = anInsertionZone.m_iPlanningFloor_0;
			m_vCamDesiredPos = anInsertionZone.Location;
			m_vCamDesiredPos.Z = 0.0000000;
			// End:0x9E
			break;
		}		
	}	
	return;
}

function DeleteEverySingleNode()
{
	CancelActionPointAction();
	m_pTeamInfo[0].DeleteAllNode();
	m_pTeamInfo[1].DeleteAllNode();
	m_pTeamInfo[2].DeleteAllNode();
	PositionCameraOnInsertionZone();
	return;
}

//Waypoints movement to a specific team.
function GotoFirstNode()
{
	CancelActionPointAction();
	m_pTeamInfo[m_iCurrentTeam].SetToStartNode();
	MoveCamOver();
	return;
}

function GotoLastNode()
{
	CancelActionPointAction();
	m_pTeamInfo[m_iCurrentTeam].SetToEndNode();
	MoveCamOver();
	return;
}

function GoToNextNode()
{
	CancelActionPointAction();
	m_pTeamInfo[m_iCurrentTeam].SetToNextNode();
	MoveCamOver();
	return;
}

function GotoPrevNode()
{
	CancelActionPointAction();
	m_pTeamInfo[m_iCurrentTeam].SetToPrevNode();
	MoveCamOver();
	return;
}

function GotoNode()
{
	CancelActionPointAction();
	MoveCamOver();
	return;
}

function R6ActionPoint GetCurrentPoint()
{
	return m_pTeamInfo[m_iCurrentTeam].GetPoint();
	return;
}

function Object.EPlanActionType GetCurrentActionType()
{
	return m_pTeamInfo[m_iCurrentTeam].GetActionType();
	return;
}

function Object.EMovementMode GetMovementMode()
{
	return m_pTeamInfo[m_iCurrentTeam].GetMovementMode();
	return;
}

// Locate the camera over the current ActionPoint
function MoveCamOver()
{
	// End:0x67
	if((GetCurrentPoint() != none))
	{
		m_vCamDesiredPos.X = GetCurrentPoint().Location.X;
		m_vCamDesiredPos.Y = GetCurrentPoint().Location.Y;
		m_iLevelDisplay = GetCurrentPoint().m_iPlanningFloor_0;
		SetFloorToDraw(m_iLevelDisplay);
	}
	return;
}

function StartPlayingPlanning()
{
	m_bPlayMode = true;
	R6PlanningPawn(Pawn).FollowPlanning(m_pTeamInfo[m_iCurrentTeam]);
	return;
}

function StopPlayingPlanning()
{
	m_bPlayMode = false;
	R6PlanningPawn(Pawn).StopFollowingPlanning();
	return;
}

state PlayerWalking
{
	function ProcessMove(float DeltaTime, Vector NewAccel, Actor.EDoubleClickDir DoubleClickMove, Rotator DeltaRot)
	{
		// End:0x3B
		if(((Pawn == none) || (WindowConsole(Player.Console).Root.PlanningShouldProcessKey() == false)))
		{
			return;
		}
		// End:0x5C
		if((int(m_bRotateCW) == int(m_bRotateCCW)))
		{
			m_fRotateDelta = 0.0000000;			
		}
		else
		{
			// End:0x77
			if((int(m_bRotateCW) == 1))
			{
				m_fRotateDelta = m_fRotateRate;				
			}
			else
			{
				// End:0x91
				if((int(m_bRotateCCW) == 1))
				{
					m_fRotateDelta = (-m_fRotateRate);
				}
			}
		}
		// End:0xB7
		if((int(m_bMoveLeft) == int(m_bMoveRight)))
		{
			m_vCamDelta.X = 0.0000000;			
		}
		else
		{
			// End:0xD7
			if((int(m_bMoveRight) == 1))
			{
				m_vCamDelta.X = m_fCamRate;				
			}
			else
			{
				// End:0xF6
				if((int(m_bMoveLeft) == 1))
				{
					m_vCamDelta.X = (-m_fCamRate);
				}
			}
		}
		// End:0x11C
		if((int(m_bMoveUp) == int(m_bMoveDown)))
		{
			m_vCamDelta.Y = 0.0000000;			
		}
		else
		{
			// End:0x13C
			if((int(m_bMoveUp) == 1))
			{
				m_vCamDelta.Y = m_fCamRate;				
			}
			else
			{
				// End:0x15B
				if((int(m_bMoveDown) == 1))
				{
					m_vCamDelta.Y = (-m_fCamRate);
				}
			}
		}
		// End:0x17C
		if((int(m_bAngleUp) == int(m_bAngleDown)))
		{
			m_fCameraAngle = 0.0000000;			
		}
		else
		{
			// End:0x197
			if((int(m_bAngleUp) == 1))
			{
				m_fCameraAngle = m_fAngleRate;				
			}
			else
			{
				// End:0x1B1
				if((int(m_bAngleDown) == 1))
				{
					m_fCameraAngle = (-m_fAngleRate);
				}
			}
		}
		// End:0x1D2
		if((int(m_bZoomIn) == int(m_bZoomOut)))
		{
			m_fZoomDelta = 0.0000000;			
		}
		else
		{
			// End:0x1EF
			if((int(m_bZoomIn) == 1))
			{
				m_fZoomDelta = (-m_fZoomRate);				
			}
			else
			{
				// End:0x207
				if((int(m_bZoomOut) == 1))
				{
					m_fZoomDelta = m_fZoomRate;
				}
			}
		}
		// End:0x257
		if((int(m_bLevelUp) == 1))
		{
			// End:0x257
			if((int(m_bGoLevelUp) == 1))
			{
				m_bGoLevelUp = 0;
				// End:0x257
				if((!((m_bPlayMode == true) && (m_bLockCamera == true))))
				{
					ChangeLevelDisplay(1);
					m_vCamDesiredPos = m_vCamPosNoRot;
				}
			}
		}
		// End:0x2AB
		if((int(m_bLevelDown) == 1))
		{
			// End:0x2AB
			if((int(m_bGoLevelDown) == 1))
			{
				m_bGoLevelDown = 0;
				// End:0x2AB
				if((!((m_bPlayMode == true) && (m_bLockCamera == true))))
				{
					ChangeLevelDisplay(-1);
					m_vCamDesiredPos = m_vCamPosNoRot;
				}
			}
		}
		return;
	}
	stop;
}

auto state PlayerWaiting
{
	function EndState()
	{
		return;
	}

	function BeginState()
	{
		return;
	}
	stop;
}

defaultproperties
{
	m_bFirstTick=true
	m_fZoom=0.2500000
	m_fZoomRate=0.2000000
	m_fZoomMin=0.0500000
	m_fZoomMax=0.4000000
	m_fZoomFactor=2.0000000
	m_fAngleRate=4000.0000000
	m_fAngleMax=-25000.0000000
	m_fRotateRate=6000.0000000
	m_fCamRate=1000.0000000
	m_fCastingHeight=100.0000000
	m_fDebugRangeScale=1.0000000
	m_pIconTex[0]=Texture'R6Planning.Icons.PlanIcon_Alpha'
	m_pIconTex[1]=Texture'R6Planning.Icons.PlanIcon_Bravo'
	m_pIconTex[2]=Texture'R6Planning.Icons.PlanIcon_Charlie'
	m_pIconTex[3]=Texture'R6Planning.Icons.PlanIcon_Milestone1'
	m_pIconTex[4]=Texture'R6Planning.Icons.PlanIcon_Milestone2'
	m_pIconTex[5]=Texture'R6Planning.Icons.PlanIcon_Milestone3'
	m_pIconTex[6]=Texture'R6Planning.Icons.PlanIcon_Milestone4'
	m_pIconTex[7]=Texture'R6Planning.Icons.PlanIcon_Milestone5'
	m_pIconTex[8]=Texture'R6Planning.Icons.PlanIcon_Milestone6'
	m_pIconTex[9]=Texture'R6Planning.Icons.PlanIcon_Milestone7'
	m_pIconTex[10]=Texture'R6Planning.Icons.PlanIcon_Milestone8'
	m_pIconTex[11]=Texture'R6Planning.Icons.PlanIcon_Milestone9'
	m_PlanningBadClickSnd=Sound'SFX_Menus.Play_Planning_BadClick'
	m_PlanningGoodClickSnd=Sound'SFX_Menus.Play_Planning_GoodClick'
	m_vCurrentCameraPos=(X=1.0000000,Y=0.0000000,Z=15000.0000000)
	m_vCamPos=(X=1.0000000,Y=0.0000000,Z=15000.0000000)
	m_rCamRot=(Pitch=49153,Yaw=0,Roll=0)
	bBehindView=true
	InputClass=Class'R6Game.R6PlanningPlayerInput'
	RemoteRole=0
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: function Coords
// REMOVED IN 1.60: function GetCurrentActionType
// REMOVED IN 1.60: function GetMovementMode
// REMOVED IN 1.60: function dbgDrawPath
// REMOVED IN 1.60: function DesignRange
