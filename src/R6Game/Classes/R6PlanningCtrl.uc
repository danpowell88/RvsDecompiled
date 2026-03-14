//=============================================================================
//  R6PlanningCtrl.uc : (top-view camera of the planning)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/05/08 * Created by Chaouky Garram
//    2002/02/02 * Taken over and rewritten by Joel Tremblay
//=============================================================================
class R6PlanningCtrl extends PlayerController
    native;

// --- Constants ---
const R6InputKey_ActionPopup =  1024;
const R6InputKey_PathFlagPopup =  1026;

// --- Variables ---
// the team's planning
var R6PlanningInfo m_pTeamInfo[3];
// editing which team
var int m_iCurrentTeam;
// Current floor displayed
var int m_iLevelDisplay;
// Camera position Without any rotation.
var Vector m_vCamPosNoRot;
// Play mode has been activated
var bool m_bPlayMode;
// Camera will reach this direction.
var Vector m_vCamDesiredPos;
// Icon to show where the camera is looking at.
var R6CameraDirection m_pCameraDirIcon;
var Sound m_PlanningBadClickSnd;
// mouse is moving to set the Sniping direction
var bool m_bSetSnipeDirection;
// Camera Location for zoom
var Vector m_vCamPos;
// Modification request on camera deplacement
var Vector m_vCamDelta;
// Next click is to set an action
var bool m_bClickToFindLocation;
// Zoom
var float m_fZoom;
var bool m_bLockCamera;
// Modification request on the zoom
var float m_fZoomDelta;
// Change the camera Angle
var float m_fCameraAngle;
// Modification request on the rotation
var float m_fRotateDelta;
// region send by the planning widget to set the 3d window size.
var int m_3DWindowPositionX;
// region send by the planning widget to set the 3d window size.
var int m_3DWindowPositionY;
// region send by the planning widget to set the 3d window size.
var int m_3DWindowPositionW;
// region send by the planning widget to set the 3d window size.
var int m_3DWindowPositionH;
// 3D view is activated
var bool m_bRender3DView;
// List of the ActionType icon texture
var Texture m_pIconTex[12];
//  camera movement parameters
var Vector m_vCurrentCameraPos;
// Camera Rotation
var Rotator m_rCamRot;
// to drag drop selected point.
var bool m_bActionPointSelected;
// to adapt camera speeds with current zoom
var float m_fZoomFactor;
var bool m_bMove3DView;
//
var float m_fCamRate;
var Sound m_PlanningGoodClickSnd;
// When dragging the first point, it must be dropped on an insertion zone
var bool m_bCanMoveFirstPoint;
// camera spot if 3d view is on without action point
var Actor m_CamSpot;
// to load/save planning
var R6FileManagerPlanning m_pFileManager;
// When clicked on range icon, set to true
var bool m_bClickedOnRange;
// mouse last move location to find the sniping direction
var float m_fLastMouseX;
// mouse last move location to find the sniping direction
var float m_fLastMouseY;
// Zoom speed
var float m_fZoomRate;
var float m_fAngleRate;
// max distance on X to calculate the angle  min is obviously 0
var float m_fAngleMax;
// Speed of the rotation
var float m_fRotateRate;
// Height between the ground and the ActionPoint casted
var const float m_fCastingHeight;
var float m_fZoomMax;
// Minimum Zoom of the camera
var float m_fZoomMin;
var Sound m_PlanningRemoveSnd;
// Minimum location X,Y of the camera(Restriction from the map)
var Vector m_vMinLocation;
var Vector m_vMaxLocation;
// not change floor when an actor is selected twice.
var Actor m_pOldHitActor;
var bool bShowLog;
// ^ NEW IN 1.60
//#ifdefDEBUG
var float m_fDebugRangeScale;
var bool m_bFirstTick;

// --- Functions ---
// function ? Coords(...); // REMOVED IN 1.60
// function ? DesignRange(...); // REMOVED IN 1.60
// function ? GotoNextNode(...); // REMOVED IN 1.60
// function ? dbgDrawPath(...); // REMOVED IN 1.60
//-----------------------------------------------------------//
//                      Mouse functions                      //
//-----------------------------------------------------------//
function LMouseDown(float X, float Y) {}
function RMouseDown(float X, float Y) {}
function LMouseUp(float X, float Y) {}
// Spawn an ActionPoint at the X, Y screen location
// Return true if the ActionPoint is spawned
function bool CastActionPointAt(int X, int Y, int iSecondFloor, int iFirstFloor, Vector vLocation) {}
// ^ NEW IN 1.60
function MoveActionPointTo(int iSecondFloor, int iFirstFloor, Vector vHitLocation) {}
// Update the camera location & rotation changed by the menu
event PlayerTick(float fDeltaTime) {}
function PostBeginPlay() {}
function Texture GetActionTypeTexture(EPlanActionType EActionType, optional int iMilestone) {}
// ^ NEW IN 1.60
function MouseMove(float X, float Y) {}
function PositionCameraOnInsertionZone() {}
// Cancel setting an action point Action.  (setting grenade or snipe direction.
function CancelActionPointAction() {}
function Ajust3DRotation(float X, float Y) {}
function TurnOn3DMove(float X, float Y) {}
// Setup the new Location & Rotation
event PlayerCalcView(out Vector vCameraLocation, out Rotator rCameraRotation, out Actor aViewActor) {}
exec function SwitchToGoldTeam(optional bool bForceFunction) {}
exec function SwitchToGreenTeam(optional bool bForceFunction) {}
exec function SwitchToRedTeam(optional bool bForceFunction) {}
//function called after a planning has been loaded to spawn the reference icons and pathflags
function InitNewPlanning(int iSelectedTeam) {}
function Set3DViewPosition(int NewX, int NewY, int NewH, int NewW) {}
final native function bool PlanningTrace(Vector vTraceEnd, Vector vTraceStart) {}
// ^ NEW IN 1.60
final native function Vector GetXYPoint(float X, float Y, float Height) {}
// ^ NEW IN 1.60
final native function bool GetClickResult(float X, float Y, out Vector HitLocation, out Actor HitActor, out int iChangeLevelTo) {}
// ^ NEW IN 1.60
// Toggle the floor display
function ChangeLevelDisplay(int iStep) {}
function SetPlanningInfo() {}
event Destroyed() {}
//=======================================================================================//
//                          INPUT exec() functions (controls)                            //
//=======================================================================================//
exec function DeleteWaypoint() {}
exec function PrevWaypoint() {}
exec function NextWaypoint() {}
exec function FirstWaypoint() {}
exec function LastWaypoint() {}
exec function ViewRedTeam() {}
exec function ViewGreenTeam() {}
exec function ViewGoldTeam() {}
// Empty this function, it change the FOV ... we don't change the FOV here
function FixFOV() {}
// Empty this function, it change the FOV ... we don't change the FOV here
function AdjustView(float DeltaTime) {}
function Toggle3DView() {}
function TurnOff3DView() {}
function TurnOff3DMove() {}
function RMouseUp(float X, float Y) {}
//-----------------------------------------------------------//
//                   ActionPoint functions                   //
//-----------------------------------------------------------//
function ResetAllID() {}
function ResetIDs() {}
function DeleteOneNode() {}
function DeleteAllNode() {}
function DeleteEverySingleNode() {}
//Waypoints movement to a specific team.
function GotoFirstNode() {}
function GotoLastNode() {}
function GoToNextNode() {}
// ^ NEW IN 1.60
function GotoPrevNode() {}
function GotoNode() {}
function R6ActionPoint GetCurrentPoint() {}
// ^ NEW IN 1.60
function EPlanActionType GetCurrentActionType() {}
// ^ NEW IN 1.60
function EMovementMode GetMovementMode() {}
// ^ NEW IN 1.60
// Locate the camera over the current ActionPoint
function MoveCamOver() {}
function StartPlayingPlanning() {}
function StopPlayingPlanning() {}

state PlayerWalking
{
    function ProcessMove(float DeltaTime, Vector NewAccel, EDoubleClickDir DoubleClickMove, Rotator DeltaRot) {}
}

state PlayerWaiting
{
    function EndState() {}
    function BeginState() {}
}

defaultproperties
{
}
