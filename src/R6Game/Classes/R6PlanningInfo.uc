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
class R6PlanningInfo extends R6AbstractPlanningInfo
    native
    transient;

// --- Functions ---
// Message management between the TeamAI and PlayerController
function NotifyActionPoint(EGoCode eCode, ENodeNotify eMsg) {}
function InitPlanning(int iTeamId, R6PlanningCtrl pPlanningCtrl) {}
// Delete the current ActionPoint
function bool DeleteNode() {}
// ^ NEW IN 1.60
function SetLastPointRotation() {}
// Read info in the node
function ReadNode() {}
// And the node in the team and cast the path
function bool AddPoint(R6ActionPoint pNewPoint) {}
// ^ NEW IN 1.60
function SetPointRotation() {}
//-----------------------------------------------------------------------------
//      Action Point Management function
//-----------------------------------------------------------------------------
function bool InsertPoint(R6ActionPoint pNewPoint) {}
// ^ NEW IN 1.60
function SkipCurrentDestination() {}
function SetMovementMode(EMovementMode eNewMode) {}
function SetMovementSpeed(EMovementSpeed eNewSpeed) {}
function SetAction(EPlanAction eNewAction) {}
function SetActionType(EPlanActionType eNewType) {}
function bool SetGrenadeLocation(Vector vHitLocation) {}
// ^ NEW IN 1.60
function GetSnipingCoordinates(out Vector vLocation, out Rotator rRotation) {}
function AjustSnipeDirection(Vector vHitLocation) {}
// Set the Action type of the current ActionPoint , grenades or sniping or other?!
function SetCurrentPointAction(EPlanAction eAction) {}
function SelectTeam(bool bIsSelected) {}
// Set On/Off the display of the team path
function SetPathDisplay(bool bDisplay) {}
function bool SetAsCurrentNode(R6ActionPoint pSelectedNode) {}
// ^ NEW IN 1.60
function bool MoveCurrentPoint() {}
// ^ NEW IN 1.60
// Reset the ID of all the ActionPoint
function ResetID() {}
// Super Function
function Tick(float fDelta) {}
function RemovePointsRefsToCtrl() {}
function EPlanAction NextActionPointHasAction(Actor aPoint) {}
// ^ NEW IN 1.60
function Actor GetNextActionPoint() {}
// ^ NEW IN 1.60
// check if this team has reach this action point
function bool MemberReached(R6ActionPoint PTarget) {}
// ^ NEW IN 1.60
final native function bool FindPathToNextPoint(R6ActionPoint pStartPoint, R6ActionPoint pPointToReach) {}
// ^ NEW IN 1.60
final native function bool InsertToTeam(R6ActionPoint pNewPoint) {}
// ^ NEW IN 1.60
function Actor PreviewNextActionPoint() {}
// ^ NEW IN 1.60
final native function bool AddToTeam(R6ActionPoint pNewPoint) {}
// ^ NEW IN 1.60
function Actor GetNextDoorToBreach(Actor aPoint) {}
// ^ NEW IN 1.60
final native function bool DeletePoint() {}
// ^ NEW IN 1.60
function ResetPointsOrientation() {}
function SetToPrevNode() {}
function SetToNextNode() {}
function SetToStartNode() {}
function SetToEndNode() {}
// Delete all ActionPoint in the Team
function DeleteAllNode() {}
function Actor GetDoorToBreach() {}
// ^ NEW IN 1.60
function R6ActionPoint GetPoint() {}
// ^ NEW IN 1.60
function R6ActionPoint GetNextPoint() {}
// ^ NEW IN 1.60
function EPlanActionType GetActionType() {}
// ^ NEW IN 1.60
function EPlanAction GetAction() {}
// ^ NEW IN 1.60
function EMovementMode GetMovementMode() {}
// ^ NEW IN 1.60
function EMovementSpeed GetMovementSpeed() {}
// ^ NEW IN 1.60
function Actor GetFirstActionPoint() {}
// ^ NEW IN 1.60
function SetToPreviousActionPoint() {}
function int GetActionPointID() {}
// ^ NEW IN 1.60
function int GetNbActionPoint() {}
// ^ NEW IN 1.60
function Vector GetActionLocation() {}
// ^ NEW IN 1.60

defaultproperties
{
}
