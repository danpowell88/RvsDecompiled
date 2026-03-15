//=============================================================================
// R6AbstractPlanningInfo - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6AbstractPlanningInfo.uc : This is the abstract class for the R6PlanningInfo class.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    august 8th, 2001 * Created by Chaouky Garram
//=============================================================================
class R6AbstractPlanningInfo extends Object
    native;

const R6InputKey_NewNode = 1025;

enum EGoCodeState
{
	GOCODESTATE_None,               // 0
	GOCODESTATE_Waiting,            // 1
	GOCODESTATE_Snipe,              // 2
	GOCODESTATE_Breach,             // 3
	GOCODESTATE_Done                // 4
};

var R6AbstractPlanningInfo.EGoCodeState m_eGoCodeState[4];  // State of GoCode of the [EGoCode] team
// Default value of ActionPoint
var const Object.EMovementMode m_eDefaultMode;
var const Object.EMovementSpeed m_eDefaultSpeed;
var const Object.EPlanAction m_eDefaultAction;
var const Object.EPlanActionType m_eDefaultActionType;
var int m_iCurrentNode;  // Index of current node
var int m_iCurrentPathIndex;  // Current point in the path to the next point.
var int m_iStartingPointNumber;  // Index of the starting location.
var int m_iNbNode;  // Number of ActionPoint in the team path
var int m_iNbMilestone;  // Number of Milestone in planning.
// Debug Data
var int DEB_iStartTime;
var bool m_bDisplayPath;  // Is this path display? -USED IN MENU ONLY
var bool m_bPlanningOver;  // RainbowTeam has finished the planning
var bool m_bPlacedFirstPoint;  // Placing first point in insertion zone (used only during Planning phase)
var(Debug) bool bShowLog;
var bool bDisplayDbgInfo;
var float m_fReachRange;  // Distance (x,y) between the team and the node to be considerate as reach!
var float m_fZReachRange;  // Distance in Z between the team and the node
var Actor m_pTeamManager;  // RainbowTeam having this "path"
// Planning Data
var array<Actor> m_NodeList;  // List of Node
// Team Data
var Color m_TeamColor;  // Color of the team

function ResetPointsOrientation()
{
	return;
}

function NotifyActionPoint(Object.ENodeNotify eMsg, Object.EGoCode eCode)
{
	return;
}

function Object.EPlanAction GetAction()
{
	return 0;
	return;
}

function Object.EMovementMode GetMovementMode()
{
	return 0;
	return;
}

function Object.EMovementSpeed GetMovementSpeed()
{
	return 1;
	return;
}

function SkipCurrentDestination()
{
	return;
}

function Actor GetFirstActionPoint()
{
	return m_NodeList[0];
	return;
}

function Actor GetNextActionPoint()
{
	return none;
	return;
}

function Actor PreviewNextActionPoint()
{
	return none;
	return;
}

function Object.EPlanAction NextActionPointHasAction(Actor aPoint)
{
	return 0;
	return;
}

function Actor GetPreviousActor()
{
	return none;
	return;
}

function int GetActionPointID()
{
	return 0;
	return;
}

function int GetNbActionPoint()
{
	return 0;
	return;
}

function Vector GetActionLocation()
{
	return vect(0.0000000, 0.0000000, 0.0000000);
	return;
}

function PlayerStart GetStartingPoint()
{
	return none;
	return;
}

function GetSnipingCoordinates(out Vector vLocation, out Rotator rRotation)
{
	return;
}

function Actor GetDoorToBreach()
{
	return none;
	return;
}

function Actor GetNextDoorToBreach(Actor aPoint)
{
	return none;
	return;
}

function ResetID()
{
	return;
}

function DeleteAllNode()
{
	return;
}


// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: function GetAction
// REMOVED IN 1.60: function GetMovementMode
// REMOVED IN 1.60: function GetMovementSpeed
// REMOVED IN 1.60: function NextActionPointHasAction
