//=============================================================================
//  R6ActionPoint.uc : A planning waypoint placed in the pre-mission planning screen; holds team, speed,
//                     movement mode, and action settings for each step of a team's plan.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//=============================================================================
class R6ActionPoint extends R6ActionPointAbstract
    native;

#exec OBJ LOAD FILE=..\Textures\R6Planning.utx PACKAGE=R6Planning

// --- Variables ---
// exist only in the planning
var R6ReferenceIcons m_pActionIcon;
// Pointer to the Planning controller
var R6PlanningCtrl m_pPlanningCtrl;
// Speed mode to reach the next ActionPoint
var EMovementSpeed m_eMovementSpeed;
// Action to do here
var EPlanAction m_eAction;
// Movement mode to reach the next ActionPoint
var EMovementMode m_eMovementMode;
// PathFlag in the planning
var R6PathFlag m_pMyPathFlag;
var Texture m_pSelected;
// Current texture depending on the point properties
var Texture m_pCurrentTexture;
// kind of ActionPoint
var EPlanActionType m_eActionType;
// Original color used when flashing
var Color m_CurrentColor;
var R6IORotatingDoor pDoor;
// team owner
var int m_iRainbowTeamName;
// Direction of the Action from the ActionPoint... ei: grenade direction
var Vector m_vActionDirection;
// Debug
var bool bShowLog;
var bool m_bActionCompleted;
// Action Rotator, for sniping direction
var Rotator m_rActionRotation;
var bool m_bActionPointReached;
var int m_iInitialMousePosY;
// R6-3DVIEWPORT
var int m_iInitialMousePosX;
var bool m_bDoorInRange;
// # of this node in its team path
var int m_iNodeID;
// # of the milesstone for its team, valid if m_eActionType & PACTTYP_Milestone
var int m_iMileStoneNum;

// --- Functions ---
function Init3DView(float X, float Y) {}
function SetMileStoneIcon(int iMilestone) {}
// Set texture color
function SetDrawColor(Color NewColor) {}
function bool CanIDrawLine(int iDisplayingFloor, Actor FromPoint, Actor ToPoint, bool bDisplayInfo) {}
// ^ NEW IN 1.60
function DrawPath(bool bDisplayInfo) {}
function FindDoor() {}
// Set the Action type of the current ActionPoint , grenades or sniping or other?!
function SetPointAction(EPlanAction eAction, optional bool bLoading) {}
function bool SetGrenade(Vector vHitLocation) {}
// ^ NEW IN 1.60
function bool CanIThrowGrenadeThroughDoor(Vector vHitLocation) {}
// ^ NEW IN 1.60
function ChangeActionType(EPlanActionType eNewType) {}
// Move the pNode ActionPoint at the screen coordinate X, Y
function RotateView(float X, float Y) {}
function InitMyPathFlag() {}
function SetFirstPointTexture() {}
function UnselectPoint() {}
function SelectPoint() {}
function Timer() {}

defaultproperties
{
}
