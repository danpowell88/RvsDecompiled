//=============================================================================
//  R6AIController.uc : This is the AI Controller class for all Rainbow6 characters.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/04/03 * Created by Rima Brek
//    2001/05/07  Joel Tremblay : Add the Stun and Kill Tables 
//                                with R6DamageAttitudeTo
//    2001/06/20 - Eric : Add the PatrolNode navigation
//    2001/11/19 - Jean-Francois Dube : Added interactive actions
//=============================================================================
class R6AIController extends AIController
    native
    abstract;

// --- Constants ---
const C_fMaxBumpTime =  1.f;

// --- Variables ---
// var ? m_AttachPos; // REMOVED IN 1.60
// var ? m_AttachRot; // REMOVED IN 1.60
// var ? m_SubActionGoto; // REMOVED IN 1.60
var Vector m_vTargetPosition;
// remove r6pawn() cast
var R6Pawn m_r6pawn;
var R6Ladder m_TargetLadder;
//InteractiveObjects
var R6InteractiveObject m_InteractionObject;
var Actor m_BumpedBy;
// this flag should be set to true during states that should not be interrupted by a notifyBump to backup...
var bool m_bIgnoreBackupBump;
// distance to backup
var const int c_iDistanceBumpBackUp;
// the door too close after opening one
var R6IORotatingDoor m_closeDoor;
// used in state code
var Vector m_vBumpedByVelocity;
var bool m_bCantInterruptIO;
var bool m_bChangingState;
var Actor m_ActorTarget;
var float m_fLoopAnimTime;
var name m_AnimName;
// return state when BumpBackUp state is over
var name m_bumpBackUpNextState;
// used in state code
var Vector m_vBumpedByLocation;
var bool m_bMoveTargetAlreadySet;
var bool m_bGetOffLadder;
// the time where the pawn was bumped
var float m_fLastBump;
var name m_StateAfterInteraction;
var bool bShowLog;               // Enable verbose AI controller debug logging
// ^ NEW IN 1.60
var Vector m_vPreviousPosition;
// backup of the bool when entering a state
var bool m_bStateBackupAvoidFacingWalls;
// return state when OpenDoor state is over
var name m_openDoorNextState;
var R6ClimbableObject m_climbingObject;
var bool bShowInteractionLog;    // Enable verbose interactive-action debug logging
// ^ NEW IN 1.60
var int m_iCurrentRouteCache;
// return state when BumpBackUp state is over
var name m_climbingObjectNextState;

// --- Functions ---
// function ? ClimbObjectStateFinished(...); // REMOVED IN 1.60
// function ? FixLocationAfterClimbing(...); // REMOVED IN 1.60
// function ? GotoClimbObjectState(...); // REMOVED IN 1.60
//------------------------------------------------------------------//
// function NotifyBump()                                            //
//------------------------------------------------------------------//
event bool NotifyBump(Actor Other) {}
// ^ NEW IN 1.60
// Called when killed
function PawnDied() {}
function Tick(float fDeltaTime) {}
function Possess(Pawn aPawn) {}
//------------------------------------------------------------------
// CanClimbLadders
//
//------------------------------------------------------------------
function bool CanClimbLadders(R6Ladder Ladder) {}
// ^ NEW IN 1.60
//============================================================================
// AIAffectedByGrenade -
//============================================================================
function AIAffectedByGrenade(EGrenadeType eType, Actor aGrenade) {}
//------------------------------------------------------------------
// IsBumpBackUpStateFinish: return true if the condition to end the
// state BumpBackUp are reached.
//------------------------------------------------------------------
function bool IsBumpBackUpStateFinish() {}
// ^ NEW IN 1.60
function PerformAction_StopInteraction() {}
//------------------------------------------------------------------
// BumpBackUpStateFinished: function fired if there is not a
//  return state (in m_bumpBackUpState_nextState)
//------------------------------------------------------------------
function BumpBackUpStateFinished() {}
//------------------------------------------------------------------
// GotoBumpBackUpState: initialize and sets the current state to
//  BumpBackUp.
//------------------------------------------------------------------
function GotoBumpBackUpState(name returnState) {}
function bool IsInCrouchedPosture() {}
// ^ NEW IN 1.60
function CheckNeedToClimbLadder() {}
//------------------------------------------------------------------
// ChooseRandomDirection
//
//------------------------------------------------------------------
function Rotator ChooseRandomDirection(int iLookBackChance) {}
// ^ NEW IN 1.60
// the following movement functions will handle moving the pawn in the right direction
// with a desired orientation, and at the right speed/velocity.
// if a focus is not specified,
function R6PreMoveTo(eMovementPace ePace, Vector vTargetPosition, Vector vFocus) {}
function R6PreMoveToward(eMovementPace ePace, Actor Target, Actor pFocus) {}
//------------------------------------------------------------------
// OpenDoorFailed: triggered when the pawn try to go in the state
//  OpenDoor. Usually should go in another state
//------------------------------------------------------------------
event OpenDoorFailed() {}
event R6SetMovement(eMovementPace ePace) {}
function ConfirmLadderActionPointWasReached(R6Ladder Ladder) {}
//===================================================================================================
//   ####              #                                       #      ##
//    ##              ##                                      ##
//    ##    #####    #####   ####   ## ###   ####    ####    #####   ###     ####   #####    #####
//    ##    ##  ##    ##    ##  ##   ### ##     ##  ##  ##    ##      ##    ##  ##  ##  ##  ##
//    ##    ##  ##    ##    ######   ##  ##  #####  ##        ##      ##    ##  ##  ##  ##   ####
//    ##    ##  ##    ## #  ##       ##     ##  ##  ##  ##    ## #    ##    ##  ##  ##  ##      ##
//   ####   ##  ##     ##    ####   ####     ### ##  ####      ##    ####    ####   ##  ##  #####
//===================================================================================================
function bool CanInteractWithObjects(R6InteractiveObject o) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// CanOpenDoor: check if the pawn has the ability to open the door
//  ie: in case it's locked.
//------------------------------------------------------------------
event bool CanOpenDoor(R6IORotatingDoor Door) {}
// ^ NEW IN 1.60
function bool AreClimbingInSameDirection(R6Pawn PlayerPawn, R6Pawn npcPawn) {}
// ^ NEW IN 1.60
//============================================================================
// ChangeOrientationTo -
//============================================================================
function ChangeOrientationTo(Rotator NewRotation) {}
//============================================================================
// IsFacing -
//============================================================================
function bool IsFacing(Actor aGrenade) {}
// ^ NEW IN 1.60
//============================================================================
// GetGrenadeDirection -
//============================================================================
function Rotator GetGrenadeDirection(optional Vector vTargetLoc, Actor aTarget) {}
// ^ NEW IN 1.60
//============================================================================
// BOOL IsFocusLeft -
//============================================================================
function bool IsFocusLeft() {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// DistanceTo: distance to a pawn without considering the Z axis
//
//------------------------------------------------------------------
function float DistanceTo(Actor member, optional bool bIncludeZ) {}
// ^ NEW IN 1.60
final native function R6ActionSpot FindPlaceToTakeCover(Vector vThreatLocation, float fMaxDistance) {}
// ^ NEW IN 1.60
final native function R6ActionSpot FindPlaceToFire(Actor PTarget, Vector vDestination, float fMaxDistance) {}
// ^ NEW IN 1.60
final native function R6ActionSpot FindInvestigationPoint(int iSearchIndex, float fMaxDistance, optional bool bFromThreat, optional Vector vThreatLocation) {}
// ^ NEW IN 1.60
final native function bool PickActorAdjust(Actor pActor) {}
// ^ NEW IN 1.60
final native function MoveToPosition(Vector VPosition, Rotator rOrientation) {}
// ^ NEW IN 1.60
final native function FollowPath(optional eMovementPace ePace, optional name returnLabel, optional bool bContinuePath) {}
// ^ NEW IN 1.60
final native function FollowPathTo(Vector vDestination, optional eMovementPace ePace, optional Actor aTarget) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// CheckPaceForInjury()
//   17 jan 2002 rbrek
//   Rainbow cannot run if injured, walk only...
//------------------------------------------------------------------
function CheckPaceForInjury(out eMovementPace ePace) {}
final native function bool CanWalkTo(Vector vDestination, optional bool bDebug) {}
// ^ NEW IN 1.60
function bool LadderIsAvailable() {}
// ^ NEW IN 1.60
//============================================================================
// FLOAT GetCurrentChanceToHit -
//============================================================================
function float GetCurrentChanceToHit(Actor aTarget) {}
// ^ NEW IN 1.60
final native function Rotator FindGrenadeDirectionToHitActor(Actor aTarget, Vector vTargetLoc, float fGrenadeSpeed) {}
// ^ NEW IN 1.60
//============================================================================
// BOOL IsReadyToFire -
//============================================================================
function bool IsReadyToFire(Actor aTarget) {}
// ^ NEW IN 1.60
// The following function was taken from Bot.uc
// FindBestPathToward() assumes the desired destination is not directly reachable.
// It tries to set Destination to the location of the best waypoint, and returns true if successful
function bool FindBestPathToward(bool bClearPaths, Actor desired) {}
// ^ NEW IN 1.60
final native function bool NeedToOpenDoor(Actor Target) {}
// ^ NEW IN 1.60
final native function GotoOpenDoorState(R6Door navPointToOpenFrom) {}
// ^ NEW IN 1.60
final native function FindNearbyWaitSpot(Actor Node, out Vector vWaitLocation) {}
// ^ NEW IN 1.60
final native function bool ActorReachableFromLocation(Actor Target, Vector vLocation) {}
// ^ NEW IN 1.60
function bool IsActorInView(Actor Actor) {}
// ^ NEW IN 1.60
function bool IsActorRightOfView(Actor Actor) {}
// ^ NEW IN 1.60
// override the version in AIController.uc so that only depend on focalpoint and destination...
function int GetFacingDirection() {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// TestMakePath
//------------------------------------------------------------------
function SetStateTestMakePath(eMovementPace ePace, Pawn anEnemy) {}
function PerformAction_LookAt(Actor Target) {}
function PerformAction_Goto(Actor Target) {}
function PerformAction_PlayAnim(name animName) {}
function PerformAction_LoopAnim(float fLoopAnimTime, name animName) {}
function PerformAction_StartInteraction() {}
//------------------------------------------------------------------
// StopMoving
//
//------------------------------------------------------------------
function StopMoving() {}
//------------------------------------------------------------------
// CanClimbObject: true if the pawn can climb r6ClimableObject.
//  - needed for inheritance
//------------------------------------------------------------------
function bool CanClimbObject() {}
// ^ NEW IN 1.60
final native function bool MakePathToRun() {}
// ^ NEW IN 1.60

state PA_Interaction
{
    event EndState() {}
    event SeePlayer(Pawn seen) {}
    event HearNoise(Actor NoiseMaker, ENoiseType eType, float Loudness, optional ESoundType ESoundType) {}
//------------------------------------------------------------------//
// function NotifyBump()                                            //
//------------------------------------------------------------------//
    event bool NotifyBump(Actor Other) {}
// ^ NEW IN 1.60
    event AnimEnd(int Channel) {}
// Called when killed
    function PawnDied() {}
}

state BumpBackUp
{
    function EndState() {}
    function BeginState() {}
    //------------------------------------------------------------------
    // GetReacheablePoint: get a reacheable pont behind the pawn.
    //	return false if fails to find a point
    //  Test to move away at 90' degree from the bumped actor. Try 4 times from 90 to 180,
    //   0        if fails, try to move away from 90 to 0.
    //   |
    //  pawn-->90
    //   |
    //   180
    //------------------------------------------------------------------
    function bool GetReacheablePoint(bool bNoFail, out Vector vTarget) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------//
// function NotifyBump()                                            //
//------------------------------------------------------------------//
    event bool NotifyBump(Actor Other) {}
// ^ NEW IN 1.60
    function bool MoveRight() {}
// ^ NEW IN 1.60
}

state ApproachLadder
{
    function EndState() {}
    function BeginState() {}
    function bool ReadyToClimbLadder() {}
// ^ NEW IN 1.60
}

state OpenDoor
{
    //------------------------------------------------------------------
    // NeedToMove: return true if the pawn need to move at the best spot
    //  to open the rotatingDoor. the destination is passed in vDest.
    //------------------------------------------------------------------
    function bool NeedToMove(out Vector vDest) {}
// ^ NEW IN 1.60
    // so the pawn won't collide with door
    function int GetFurthestOffsetFromDoor(Actor Actor) {}
// ^ NEW IN 1.60
    function EndState() {}
    function BeginState() {}
}

state WaitToClimbLadder
{
    function EndState() {}
    function BeginState() {}
    function Vector GetWaitPosition() {}
// ^ NEW IN 1.60
}

state PA_LoopAnim
{
}

state PA_PlayAnim
{
}

state EndClimbingLadder
{
    function ClimbLadderIsOver() {}
    function bool NotifyHitWall(Actor Wall, Vector HitNormal) {}
// ^ NEW IN 1.60
    function EndState() {}
    function BeginState() {}
}

state BeginClimbingLadder
{
//------------------------------------------------------------------//
// function NotifyBump()                                            //
//------------------------------------------------------------------//
    event bool NotifyBump(Actor Other) {}
// ^ NEW IN 1.60
    function EndState() {}
    function BeginState() {}
}

state PA_Goto
{
    event EndState() {}
}

state PA_LookAt
{
}

state PA_StartInteraction
{
}

state TestMakePath
{
    function EnemyNotVisible() {}
    function BeginState() {}
}

state TestMakePathEnd
{
    function BeginState() {}
}

state Dead
{
    function BeginState() {}
    delegate R6DamageAttitudeTo(Vector vBulletMomentum, eStunResult eStunFromTable, eKillResult eKillFromTable, Pawn Other) {}
// ^ NEW IN 1.60
}

state Dispatcher
{
    function BeginState() {}
}

defaultproperties
{
}
