//=============================================================================
//  R6AbstractPlanningInfo.uc : This is the abstract class for the R6PlanningInfo class.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    august 8th, 2001 * Created by Chaouky Garram
//=============================================================================
class R6AbstractPlanningInfo extends Object
    native;

// --- Constants ---
const R6InputKey_NewNode =  1025;

// --- Enums ---
enum EGoCodeState
{
    GOCODESTATE_None,
    GOCODESTATE_Waiting,
    GOCODESTATE_Snipe,
    GOCODESTATE_Breach,
    GOCODESTATE_Done
};

// --- Variables ---
// Planning Data
// List of Node
var array<array> m_NodeList;
// Index of current node
var int m_iCurrentNode;
// Current point in the path to the next point.
var int m_iCurrentPathIndex;
//Index of the starting location.
var int m_iStartingPointNumber;
// RainbowTeam having this "path"
var Actor m_pTeamManager;
// State of GoCode of the [EGoCode] team
var EGoCodeState m_eGoCodeState[4];
// Number of ActionPoint in the team path
var int m_iNbNode;
// Number of Milestone in planning.
var int m_iNbMilestone;
// Distance (x,y) between the team and the node to be considerate as reach!
var float m_fReachRange;
// Distance in Z between the team and the node
var float m_fZReachRange;
// Is this path display? -USED IN MENU ONLY
var bool m_bDisplayPath;
// RainbowTeam has finished the planning
var bool m_bPlanningOver;
// Placing first point in insertion zone (used only during Planning phase)
var bool m_bPlacedFirstPoint;
// Default value of ActionPoint
var const EMovementMode m_eDefaultMode;
var const EMovementSpeed m_eDefaultSpeed;
var const EPlanAction m_eDefaultAction;
var const EPlanActionType m_eDefaultActionType;
// Team Data
// Color of the team
var Color m_TeamColor;
// Debug Data
var int DEB_iStartTime;
var bool bShowLog;
// ^ NEW IN 1.60
var bool bDisplayDbgInfo;

// --- Functions ---
function ResetPointsOrientation() {}
function NotifyActionPoint(ENodeNotify eMsg, EGoCode eCode) {}
function EPlanAction GetAction() {}
// ^ NEW IN 1.60
function EMovementMode GetMovementMode() {}
// ^ NEW IN 1.60
function EMovementSpeed GetMovementSpeed() {}
// ^ NEW IN 1.60
function SkipCurrentDestination() {}
function Actor GetFirstActionPoint() {}
// ^ NEW IN 1.60
function Actor GetNextActionPoint() {}
// ^ NEW IN 1.60
function Actor PreviewNextActionPoint() {}
// ^ NEW IN 1.60
function EPlanAction NextActionPointHasAction(Actor aPoint) {}
// ^ NEW IN 1.60
function Actor GetPreviousActor() {}
// ^ NEW IN 1.60
function int GetActionPointID() {}
// ^ NEW IN 1.60
function int GetNbActionPoint() {}
// ^ NEW IN 1.60
function Vector GetActionLocation() {}
// ^ NEW IN 1.60
function PlayerStart GetStartingPoint() {}
// ^ NEW IN 1.60
function GetSnipingCoordinates(out Vector vLocation, out Rotator rRotation) {}
function Actor GetDoorToBreach() {}
// ^ NEW IN 1.60
function Actor GetNextDoorToBreach(Actor aPoint) {}
// ^ NEW IN 1.60
function ResetID() {}
function DeleteAllNode() {}

defaultproperties
{
}
