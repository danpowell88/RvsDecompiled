//=============================================================================
//  R6IORotatingDoor : This should allow action moves on the door
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/05/10 * Created by Alexandre Dionne
//    2001/11/26 * Merged with interactive objects - Jean-Francois Dube
//  Note: if you make R6IORotatingDoor native then you will need to take care so
//  that the names in eDoorCircumstantialAction do not conflict with other enums
//=============================================================================
class R6IORotatingDoor extends R6IActionObject
    native;

#exec OBJ LOAD FILE=..\Textures\R6ActionIcons.utx PACKAGE=R6ActionIcons
#exec OBJ LOAD FILE=..\Textures\R6Planning.utx PACKAGE=R6Planning

// --- Enums ---
enum eDoorCircumstantialAction
{
    CA_None,
        
    // Closed door
    CA_Open,
    CA_OpenAndClear,
    CA_OpenAndGrenade,
    CA_OpenGrenadeAndClear,

    // Open door
    CA_Close,
    CA_Clear,
    CA_Grenade,
    CA_GrenadeAndClear,
	
	// Grenade
	CA_GrenadeFrag,
	CA_GrenadeGas,
	CA_GrenadeFlash,
	CA_GrenadeSmoke,

    // Locked door
    CA_Unlock,

    // Use only for the sound
    CA_Lock,
    CA_LockPickStop
};

// --- Variables ---
//-----------------------------------------------------------------------------
// Internal
//Start Yaw point of the door when it's closed
var /* replicated */ int m_iYawInit;
//End Yaw point of the door when it's fully opened
var /* replicated */ int m_iYawMax;
//Is the door open or not
var /* replicated */ bool m_bIsDoorClosed;
var bool m_bTreatDoorAsWindow;
// ^ NEW IN 1.60
var /* replicated */ bool m_bIsOpeningClockWise;
// ^ NEW IN 1.60
var /* replicated */ bool m_bIsDoorLocked;
// ^ NEW IN 1.60
var /* replicated */ bool m_bInProcessOfOpening;
var /* replicated */ R6Door m_DoorActorA;
// ^ NEW IN 1.60
//Determine how many degrees the door can open (In degrees)
var /* replicated */ int m_iMaxOpening;
var /* replicated */ R6Door m_DoorActorB;
// ^ NEW IN 1.60
var bool m_bUseWheel;
// Current Lock Hit Points
var int m_iCurrentLockHP;
var int m_iCurrentOpening;
//Center of the door (Location is the pivot point)
var Vector m_vCenterOfDoor;
var /* replicated */ bool m_bInProcessOfClosing;
//The direction toward DoorA (direction toward DoorB is -m_vDoorADir2D
var Vector m_vDoorADir2D;
// breach attached to the door (if any)
var array<array> m_BreachAttached;
//Opening of the door at level creation (In degrees)
var /* replicated */ int m_iInitialOpening;
var float m_fUnlockBaseTime;
// ^ NEW IN 1.60
var Sound m_OpeningWheelSound;
// ^ NEW IN 1.60
var Sound m_MoveAmbientSoundStop;
// ^ NEW IN 1.60
var Sound m_MoveAmbientSound;
// ^ NEW IN 1.60
//The normal at the begining of the action
var Vector m_vNormal;
//-----------------------------------------------------------------------------
// Editables.
var bool sm_bIsDoorLocked;
var Sound m_ClosingWheelSound;
// ^ NEW IN 1.60
var Sound m_ClosingSound;
// ^ NEW IN 1.60
var Sound m_OpeningSound;
// ^ NEW IN 1.60
var float m_fWindowWidth;
// ^ NEW IN 1.60
// lock HP to open door with bullets or explosions.
var int m_iLockHP;
var Sound m_LockSound;
// ^ NEW IN 1.60
var Sound m_UnlockSound;
// ^ NEW IN 1.60
var Sound m_LockPickSound;
// ^ NEW IN 1.60
var Sound m_LockPickSoundStop;
// ^ NEW IN 1.60
var Sound m_ExplosionSound;
// ^ NEW IN 1.60
var /* replicated */ int m_iMaxOpeningDeg;
// ^ NEW IN 1.60
var /* replicated */ int m_iInitialOpeningDeg;
// ^ NEW IN 1.60
var bool bShowLog;
// ^ NEW IN 1.60
var bool m_bForceNoFormation;
// ^ NEW IN 1.60

// --- Functions ---
// function ? UnLockDoor(...); // REMOVED IN 1.60
// function ? closeDoor(...); // REMOVED IN 1.60
// function ? dbgLogActor(...); // REMOVED IN 1.60
// function ? openDoor(...); // REMOVED IN 1.60
function SetDoorProcessStates(bool bClosing, bool bOpening) {}
function ClientSetDoor(Rotator rNewRotation, optional bool bForce) {}
//===========================================================================//
// R6GetCircumstantialActionProgress()                                       //
//   Update the door unlocking progress (if it's locked)                     //
//   Should be affected by the skills of the pawn unlocking it               //
//===========================================================================//
function int R6GetCircumstantialActionProgress(Pawn actingPawn, R6AbstractCircumstantialActionQuery Query) {}
// ^ NEW IN 1.60
simulated function CloseDoor(optional int iRotationRate, R6Pawn Pawn) {}
// ^ NEW IN 1.60
function int R6TakeDamage(int iPenetrationFactor, Vector vHitLocation, int iKillValue, Vector vMomentum, Pawn instigatedBy, optional int iBulletGroup, int iStunValue) {}
// ^ NEW IN 1.60
//============================================================================
// Bump -
//============================================================================
event Bump(Actor Other) {}
//===========================================================================//
// R6GetCircumstantialActionString()                                         //
//===========================================================================//
simulated function string R6GetCircumstantialActionString(int iAction) {}
// ^ NEW IN 1.60
simulated function SetDoorState(bool bIsClosed) {}
function bool DoorOpenTowardsActor(Actor aActor) {}
// ^ NEW IN 1.60
final native function RemoveBreach(R6AbstractBullet BreachAttached) {}
// ^ NEW IN 1.60
final native function AddBreach(R6AbstractBullet BreachAttached) {}
// ^ NEW IN 1.60
final native function bool WillOpenOnTouch(R6Pawn R6Pawn) {}
// ^ NEW IN 1.60
function bool HitLock(Vector vHitVector) {}
// ^ NEW IN 1.60
function Vector GetTarget(float fDistanceFromDoor, Actor aActor, optional bool bBackup) {}
// ^ NEW IN 1.60
//============================================================================
// bool ActorIsOnSideA -
//============================================================================
function bool ActorIsOnSideA(Actor aActor) {}
// ^ NEW IN 1.60
simulated event bool EncroachingOn(Actor Other) {}
// ^ NEW IN 1.60
//==============================================================================//
// RBrek - 1 sept 2001                                                          //
// To perform a full opening/closing of a door.                                 //
// either stQuery.iTeamActionID or stQuery.iPlayerActionID should be passed...  //
// TODO : replace SetRotation with use of bRotateToDesired                      //
//==============================================================================//
function performDoorAction(int iActionID) {}
event Tick(float fDelta) {}
//===========================================================================//
// R6ActionCanBeExecuted()												     //
//	Check if the action specified can be executed. Useful to disable choice  //
//	in the rose des vents.													 //
//===========================================================================//
simulated function bool R6ActionCanBeExecuted(int iAction, PlayerController PlayerController) {}
// ^ NEW IN 1.60
function OpenDoor(optional int iRotationRate, Pawn opener) {}
// ^ NEW IN 1.60
function bool updateAction(float fDeltaMouse, Actor actionInstigator) {}
// ^ NEW IN 1.60
function R6FillGrenadeSubAction(int iSubMenu, out R6AbstractCircumstantialActionQuery Query, PlayerController PlayerController) {}
//------------------------------------------------------------------
// ResetOriginalData
//
//------------------------------------------------------------------
simulated function ResetOriginalData() {}
function OpenDoorWhenHit(int YawVariation, bool bExplosion, Vector vBulletDirection, Vector vHitLocation) {}
simulated event R6QueryCircumstantialAction(out R6AbstractCircumstantialActionQuery Query, PlayerController PlayerController, float fDistance) {}
//------------------------------------------------------------------
// SaveOriginalData
//
//------------------------------------------------------------------
simulated function SaveOriginalData() {}
function PostBeginPlay() {}
//This function should always be defined in subclass
function bool startAction(float fDeltaMouse, Actor actionInstigator) {}
// ^ NEW IN 1.60
simulated function R6CircumstantialActionCancel() {}
//------------------------------------------------------------------
// SetBroken
//
//------------------------------------------------------------------
function SetBroken() {}
function bool ShouldBeBreached() {}
// ^ NEW IN 1.60
event EndedRotation() {}
simulated function UnlockDoor() {}
// ^ NEW IN 1.60
//===========================================================================//
// R6CircumstantialActionProgressStart()                                     //
//===========================================================================//
function R6CircumstantialActionProgressStart(R6AbstractCircumstantialActionQuery Query) {}
function PlayLockPickSound() {}

defaultproperties
{
}
