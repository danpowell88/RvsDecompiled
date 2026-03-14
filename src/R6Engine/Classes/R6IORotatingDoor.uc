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
var bool m_bTreatDoorAsWindow;   // Treat this door like a window for breaching/line-of-sight purposes
// ^ NEW IN 1.60
var /* replicated */ bool m_bIsOpeningClockWise;  // True if the door swings clockwise when opening
// ^ NEW IN 1.60
var /* replicated */ bool m_bIsDoorLocked;  // True when the door is locked and cannot be opened normally
// ^ NEW IN 1.60
var /* replicated */ bool m_bInProcessOfOpening;
var /* replicated */ R6Door m_DoorActorA;  // First R6Door actor associated with this rotating door
// ^ NEW IN 1.60
//Determine how many degrees the door can open (In degrees)
var /* replicated */ int m_iMaxOpening;
var /* replicated */ R6Door m_DoorActorB;  // Second R6Door actor (for double doors)
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
var float m_fUnlockBaseTime;      // Base time (seconds) to unlock this door with a lock-pick
// ^ NEW IN 1.60
var Sound m_OpeningWheelSound;   // Sound played while turning the door wheel/handle to open
// ^ NEW IN 1.60
var Sound m_MoveAmbientSoundStop; // Sound played when door movement ambient loop stops
// ^ NEW IN 1.60
var Sound m_MoveAmbientSound;    // Ambient looping sound while the door is in motion
// ^ NEW IN 1.60
//The normal at the begining of the action
var Vector m_vNormal;
//-----------------------------------------------------------------------------
// Editables.
var bool sm_bIsDoorLocked;
var Sound m_ClosingWheelSound;   // Sound played while turning the wheel to close the door
// ^ NEW IN 1.60
var Sound m_ClosingSound;         // Sound played when the door finishes closing
// ^ NEW IN 1.60
var Sound m_OpeningSound;         // Sound played when the door finishes opening
// ^ NEW IN 1.60
var float m_fWindowWidth;         // Width of the window pane within this door (for breaching)
// ^ NEW IN 1.60
// lock HP to open door with bullets or explosions.
var int m_iLockHP;
var Sound m_LockSound;            // Sound played when the door is locked
// ^ NEW IN 1.60
var Sound m_UnlockSound;          // Sound played when the door is unlocked
// ^ NEW IN 1.60
var Sound m_LockPickSound;        // Sound played while lock-picking this door
// ^ NEW IN 1.60
var Sound m_LockPickSoundStop;    // Sound played when lock-picking finishes or is cancelled
// ^ NEW IN 1.60
var Sound m_ExplosionSound;       // Sound played when this door is blown open by an explosion
// ^ NEW IN 1.60
var /* replicated */ int m_iMaxOpeningDeg;  // Maximum opening angle in degrees (replicated to clients)
// ^ NEW IN 1.60
var /* replicated */ int m_iInitialOpeningDeg;  // Starting open angle in degrees at mission start
// ^ NEW IN 1.60
var bool bShowLog;                // Enable verbose door-state debug logging
// ^ NEW IN 1.60
var bool m_bForceNoFormation;    // Disable formation stacking when AI moves through this door
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
