//=============================================================================
//  R6RainbowAI.uc : (Rainbow 6 Base Class) This is the AI Controller class for 
//                   all non player members of the Rainbow team.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/05/01 * Created by Rima Brek
//=============================================================================
class R6RainbowAI extends R6AIController
    native;

// --- Enums ---
enum eFormation
{
    // enum values not recoverable from binary — see 1.56 source
};
enum ePawnOrientation
{
    // enum values not recoverable from binary — see 1.56 source
};
enum eCoverDirection
{
    // enum values not recoverable from binary — see 1.56 source
};

// --- Variables ---
var R6RainbowTeam m_TeamManager;
var R6Rainbow m_pawn;
// -- INTERACTION attributes -- //
var Actor m_ActionTarget;
// this is the member that is directly ahead of this controller's pawn.
var R6Rainbow m_PaceMember;
var int m_iStateProgress;
var R6IORotatingDoor m_RotatingDoor;
// it might be sufficient to hold this info in the teamManager
var R6Rainbow m_TeamLeader;
var Vector m_vPreEntryPositions[2];
// location on target to aim at
var Vector m_vLocationOnTarget;
// for miscellaneous usage
var bool m_bStateFlag;
var int m_iWaitCounter;
var Actor m_NextMoveTarget;
var int m_iActionUseGadgetGroup;
var bool m_bReactToNoise;
var Vector m_vNoiseFocalPoint;
// -- MOVEMENT attributes -- //
// used to allow a member walking backwards to turn around periodically
var int m_iTurn;
var bool m_bIsMovingBackwards;
var bool m_bSlowedPace;
var ePawnOrientation m_ePawnOrientation; // Intended facing orientation relative to the player/formation leader
// ^ NEW IN 1.60
var bool m_bIndividualAttacks;
var R6CommonRainbowVoices m_CommonMemberVoicesMgr;
var eFormation m_eFormation;      // Current formation slot assigned to this Rainbow AI
// ^ NEW IN 1.60
var Vector m_vDesiredLocation;
var bool m_bReorganizationPending;
var bool m_bWeaponsDry;
var bool m_bEnteredRoom;
var Actor m_DesiredTarget;
var Vector m_vGrenadeLocation;
var bool m_bAlreadyWaiting;
var bool m_bIsCatchingUp;
var float m_fGrenadeDangerRadius;
var name m_PostFindPathToState;
var bool m_bTeamMateHasBeenKilled;
var bool m_bUseStaggeredFormation;
var bool m_bAimingWeaponAtEnemy;
var float m_fLastReactionToGas;
var eRoomLayout m_eCurrentRoomLayout;
var eCoverDirection m_eCoverDirection; // Direction the AI leans/peeks when taking cover
// ^ NEW IN 1.60
var name m_PostLockPickState;
// Timer event, 0=no timer.
var float m_fAttackTimerRate;
// Counts up until it reaches m_fAttackTimerRate.
var float m_fAttackTimerCounter;
var float m_fFiringAttackTimer;

// --- Functions ---
//------------------------------------------------------------------
// SeePlayer()
//------------------------------------------------------------------
event SeePlayer(Pawn seen) {}
//------------------------------------------------------------------
// EnemyNotVisible()
//------------------------------------------------------------------
event EnemyNotVisible() {}
//------------------------------------------------------------------
// AttackTimer()
//------------------------------------------------------------------
event AttackTimer() {}
function DetonateBreach() {}
//------------------------------------------------------------------
// GetTeamLeaderPace()
//------------------------------------------------------------------
function eMovementPace GetPace(bool bRun) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// IsMoving()
//------------------------------------------------------------------
function bool IsMoving(Pawn P) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// IsBumpBackUpStateFinish: return true if the condition to end the
// state BumpBackUp are reached.
// - inherited
// c_iDistanceBumpBackUp depends on m_TeamManager.m_iFormationDistance
//------------------------------------------------------------------
function bool IsBumpBackUpStateFinish() {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// AimingAt()
//------------------------------------------------------------------
function bool AimingAt(Pawn Enemy) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// PlayVoiceTerroristSpotted()
//------------------------------------------------------------------
function PlayVoiceTerroristSpotted(R6Terrorist aTerro) {}
//------------------------------------------------------------------
// CanBeSeen()
//------------------------------------------------------------------
function bool CanBeSeen(Pawn seen) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// PlaySoundActionCompleted()
//------------------------------------------------------------------
function PlaySoundActionCompleted(eDeviceAnimToPlay eAnimToPlay) {}
//------------------------------------------------------------------
// AIAffectedByGrenade()
//------------------------------------------------------------------
function AIAffectedByGrenade(EGrenadeType eType, Actor aGrenade) {}
//------------------------------------------------------------------
// ReactToFragGrenade()
//------------------------------------------------------------------
function ReactToFragGrenade(float fGrenadeDangerRadius, Vector vGrenadeLocation, float fTimeLeft) {}
//------------------------------------------------------------------
// FragGrenadeInProximity()
//------------------------------------------------------------------
function FragGrenadeInProximity(Vector vGrenadeLocation, float fTimeLeft, float fGrenadeDangerRadius) {}
//------------------------------------------------------------------
// Possess()
//   BEWARE : could this cause a problem when changing pawns?
//------------------------------------------------------------------
function Possess(Pawn aPawn) {}
//------------------------------------------------------------------
// R6PreMoveTo()
//   ePace is optional so for NPC members who's pace should be set
//   according to team leader...
//------------------------------------------------------------------
function R6PreMoveTo(optional eMovementPace ePace, Vector vTargetPosition, Vector vFocus) {}
//------------------------------------------------------------------
// R6PreMoveToward()
//   ePace is optional so for NPC members who's pace should be set
//   according to team leader...
//------------------------------------------------------------------
function R6PreMoveToward(optional eMovementPace ePace, Actor Target, Actor pFocus) {}
//------------------------------------------------------------------
// PlaySoundCurrentAction()
//------------------------------------------------------------------
function PlaySoundCurrentAction(ERainbowTeamVoices eVoices) {}
//------------------------------------------------------------------
// HearNoise()
//------------------------------------------------------------------
event HearNoise(Actor aNoiseMaker, ENoiseType eType, float Loudness, optional ESoundType ESoundType) {}
//------------------------------------------------------------------
// OnRightSideOfDoor()
//------------------------------------------------------------------
function bool OnRightSideOfDoor(Actor aTarget) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// TooCloseToThrowGrenade: check if we are too close to throw the grenade
//	the distance decrease when it's taking too much time
//------------------------------------------------------------------
function bool TooCloseToThrowGrenade(Vector vPawnLocation) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// ClearThrowIsAvailable()
//------------------------------------------------------------------
function bool ClearThrowIsAvailable(Vector vTarget) {}
// ^ NEW IN 1.60
function bool NextActionPointIsThroughDoor(Actor nextActionPoint) {}
// ^ NEW IN 1.60
function bool TargetIsLadderToClimb(R6Ladder Target) {}
// ^ NEW IN 1.60
function ForceCurrentDoor(R6Door aDoor) {}
function bool PawnIsOnTheSameEndOfLadderAsMember(R6LadderVolume LadderVolume, R6Rainbow aRainbow) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// NeedToReload()
//------------------------------------------------------------------
function bool NeedToReload() {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// CanThrowGrenade: if all conditions are okay, returns true if the
//  rainbow can throw a grenade from vPawnLocation.
// bTest: used to evaluate if the rainbow is gonna be damaged
//                 by the grenade
//------------------------------------------------------------------
function bool CanThrowGrenade(Vector vPawnLocation, bool bTraceActors, bool bCheckTooClose) {}
// ^ NEW IN 1.60
function SwitchWeapon(int f) {}
//------------------------------------------------------------------
// CanThrowGrenadeIntoRoom()
//------------------------------------------------------------------
function bool CanThrowGrenadeIntoRoom(R6Door aDoor, optional Vector vTestTarget) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// GetLeadershipReactionTime()
//------------------------------------------------------------------
function float GetLeadershipReactionTime() {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// IsBeingAttacked()
//------------------------------------------------------------------
function IsBeingAttacked(Pawn attacker) {}
//------------------------------------------------------------------
// PlaySoundDamage()
//------------------------------------------------------------------
function PlaySoundDamage(Pawn instigatedBy) {}
//------------------------------------------------------------------
// CanSeeGrenade()
//------------------------------------------------------------------
function bool CanSeeGrenade(Vector vGrenadeLocation) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// VerifyWeaponInventory()
//------------------------------------------------------------------
function VerifyWeaponInventory() {}
//------------------------------------------------------------------
// IsANeutralPawnNoise()
//------------------------------------------------------------------
function bool IsANeutralPawnNoise(Actor aNoiseMaker) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// SetFocusToDoorKnob()
//------------------------------------------------------------------
function SetFocusToDoorKnob(R6IORotatingDoor aDoor) {}
function Tick(float fDeltaTime) {}
//------------------------------------------------------------------
// SetNoiseFocus()
//------------------------------------------------------------------
function SetNoiseFocus(Vector vSource) {}
function ConfirmLadderActionPointWasReached(R6Ladder Ladder) {}
function SetGrenadeParameters(bool bPeeking, optional bool bThrowOverhand) {}
function FindPathToTargetLocation(Vector vTarget, optional Actor aTarget) {}
//////////////////////////////////////////////////////////////////////////////////////////
//                          RAINBOW AI TEAM LEADER                                      //
//////////////////////////////////////////////////////////////////////////////////////////
function eMovementPace GetTeamPace() {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// GotoLockPickState()
//------------------------------------------------------------------
function GotoLockPickState(R6IORotatingDoor Door) {}
//------------------------------------------------------------------
// SetEnemy()
//------------------------------------------------------------------
function SetEnemy(Pawn newEnemy) {}
//------------------------------------------------------------------
// PlaySoundInflictedDamage()
//------------------------------------------------------------------
function PlaySoundInflictedDamage(Pawn DeadPawn) {}
//------------------------------------------------------------------
// SetGunDirection -
//------------------------------------------------------------------
function SetGunDirection(Actor aTarget) {}
//------------------------------------------------------------------
// PlaySoundAffectedByGrenade()
//------------------------------------------------------------------
function PlaySoundAffectedByGrenade(EGrenadeType eType) {}
//------------------------------------------------------------------
// R6SetMovement()
//------------------------------------------------------------------
function R6SetMovement(eMovementPace ePace) {}
final native function bool ClearToSnipe(Vector vStart, Rotator rSnipingDir) {}
// ^ NEW IN 1.60
final native function bool AClearShotIsAvailable(Pawn PTarget, Vector vStart) {}
// ^ NEW IN 1.60
final native function LookAroundRoom(bool bIsLeadingRoomEntry) {}
// ^ NEW IN 1.60
final native function SetOrientation(optional ePawnOrientation eOverrideOrientation) {}
// ^ NEW IN 1.60
final native function Vector GetEntryPosition(bool bInsideRoom) {}
// ^ NEW IN 1.60
final native function Vector GetTargetPosition() {}
// ^ NEW IN 1.60
final native function Vector GetLadderPosition() {}
// ^ NEW IN 1.60
final native function Vector GetGuardPosition() {}
// ^ NEW IN 1.60
final native function Vector CheckEnvironment() {}
// ^ NEW IN 1.60
final native function Actor FindSafeSpot() {}
// ^ NEW IN 1.60
event PostBeginPlay() {}
//------------------------------------------------------------------
// UpdatePosture()
//------------------------------------------------------------------
function UpdatePosture() {}
//------------------------------------------------------------------
// PostureHasChanged()
//------------------------------------------------------------------
function bool PostureHasChanged() {}
// ^ NEW IN 1.60
function FreeBackupPromote() {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// ResetStateProgress()
//------------------------------------------------------------------
function ResetStateProgress() {}
//------------------------------------------------------------------
// CanClimbLadders()
//------------------------------------------------------------------
function bool CanClimbLadders(R6Ladder Ladder) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// EnemyIsStillAThreat()
//------------------------------------------------------------------
function bool EnemyIsAThreat() {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// EndAttack()
//------------------------------------------------------------------
function EndAttack() {}
//------------------------------------------------------------------
// StartFiring()
//------------------------------------------------------------------
function StartFiring() {}
//------------------------------------------------------------------
// StopFiring()
//------------------------------------------------------------------
function StopFiring() {}
//------------------------------------------------------------------
// PreEntryRoomIsAcceptablyLarge()
//------------------------------------------------------------------
function bool PreEntryRoomIsAcceptablyLarge() {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// PostEntryRoomIsAcceptablyLarge()
//------------------------------------------------------------------
function bool PostEntryRoomIsAcceptablyLarge() {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
//  ResetGadgetGroup()
//------------------------------------------------------------------
function ResetGadgetGroup() {}
//------------------------------------------------------------------
// StopAttack()
//------------------------------------------------------------------
event StopAttack() {}
//------------------------------------------------------------------
// RainbowCannotCompleteOrders()
//------------------------------------------------------------------
function RainbowCannotCompleteOrders() {}
function ReInitEntryPositions() {}
//------------------------------------------------------------------
// ResetTeamMoveTo()
//------------------------------------------------------------------
function ResetTeamMoveTo() {}
function GotoStateLeadRoomEntry() {}
function DispatchOrder(int iOrder, optional R6RainbowTeam teamManager) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// GetNextTeamActionState()
//------------------------------------------------------------------
function name GetNextTeamActionState() {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// EnsureRainbowIsArmed()
//------------------------------------------------------------------
function bool EnsureRainbowIsArmed() {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// SniperChangeToPrimaryWeapon()
//------------------------------------------------------------------
function bool SniperChangeToPrimaryWeapon() {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// SniperChangeToSecondaryWeapon()
//------------------------------------------------------------------
function bool SniperChangeToSecondaryWeapon() {}
// ^ NEW IN 1.60
function CheckNeedToClimbLadder() {}
//------------------------------------------------------------------
// GetFormationDistance()
//------------------------------------------------------------------
function float GetFormationDistance() {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// BumpBackUpStateFinished: function fired if there is not a
//	return state (in m_bumpBackUpState_nextState)
// - inherited
//------------------------------------------------------------------
function BumpBackUpStateFinished() {}
//------------------------------------------------------------------
// ResetNoiseFocus()
//------------------------------------------------------------------
function ResetNoiseFocus() {}
//------------------------------------------------------------------
// RainbowReloadWeapon()
//------------------------------------------------------------------
function RainbowReloadWeapon() {}
function SetRainbowOrientation() {}
function ReorganizeTeamAsNeeded() {}
// Right now this is being used when the player decides to relinquish control of the squad
// to his number 2...also used when the current leader of the squad has been killed...
function Promote() {}

state PlaceBreachingCharge
{
    function R6Door GetDoorPathNode() {}
// ^ NEW IN 1.60
    function BeginState() {}
    function EndState() {}
    function DetonateBreach() {}
}

state PerformAction
{
    function Vector FindFloorBelowActor(Actor Target) {}
// ^ NEW IN 1.60
    function BeginState() {}
    function EndState() {}
    function Timer() {}
}

state TeamClimbLadder
{
    function SetPawnFocus() {}
    function bool NeedToFollowTeam() {}
// ^ NEW IN 1.60
    function BeginState() {}
    function EndState() {}
    function bool LeadHasStartedClimbing() {}
// ^ NEW IN 1.60
    function R6Ladder GetLadderMoveTarget() {}
// ^ NEW IN 1.60
}

state SnipeUntilGoCode
{
//------------------------------------------------------------------
// SeePlayer()
//------------------------------------------------------------------
    event SeePlayer(Pawn seen) {}
    function BeginState() {}
    function EndState() {}
//------------------------------------------------------------------
// EnemyNotVisible()
//------------------------------------------------------------------
    event EnemyNotVisible() {}
//------------------------------------------------------------------
// AttackTimer()
//------------------------------------------------------------------
    event AttackTimer() {}
    function bool NoiseSourceIsVisible() {}
// ^ NEW IN 1.60
    event Timer() {}
}

state LeadRoomEntry
{
    function eMovementPace GetRoomEntryPace(bool bRun) {}
// ^ NEW IN 1.60
    function BeginState() {}
    function EndState() {}
    function Timer() {}
}

state RoomEntry
{
    function Vector GetSingleFilePosition() {}
// ^ NEW IN 1.60
    function bool HasEnteredRoom(R6Pawn member) {}
// ^ NEW IN 1.60
    function eMovementPace GetRoomEntryPace(bool bRun) {}
// ^ NEW IN 1.60
    function float DistanceToLocation(Vector vTarget) {}
// ^ NEW IN 1.60
    function BeginState() {}
    function EndState() {}
    function Timer() {}
    function SetMemberFocus() {}
    function CoverRear() {}
}

state FollowLeader
{
    function EngageLadderIfNeeded(R6LadderVolume aVolume) {}
    function bool RainbowShouldWait() {}
// ^ NEW IN 1.60
    function Vector GetNextTargetPosition() {}
// ^ NEW IN 1.60
    function BeginState() {}
    function EndState() {}
    function Timer() {}
}

state RunAwayFromGrenade
{
    function Vector SafeLocation() {}
// ^ NEW IN 1.60
    function BeginState() {}
    function EndState() {}
    event Timer() {}
}

state BumpBackUp
{
    event bool NotifyBump(Actor Other) {}
// ^ NEW IN 1.60
    function bool GetReacheablePoint(out Vector vTarget, bool bNoFail) {}
// ^ NEW IN 1.60
    function Vector GetTargetLocation(bool bRight, optional int iTry) {}
// ^ NEW IN 1.60
}

state TeamMoveTo
{
    //------------------------------------------------------------------
    // FindRandomNavPointToThrowGrenade:
    //	try to find a spot to throw a grenade. Not too far from where he's
    //  standing.
    //------------------------------------------------------------------
    function bool FindRandomNavPointToThrowGrenade() {}
// ^ NEW IN 1.60
    function BeginState() {}
	// this code was moved into a function because the BeginState() is not called again when a GotoState() is done on the current state.
    function SetUpTeamMoveTo() {}
    function EndState() {}
    function Timer() {}
}

state Patrol
{
    function bool CornerMovement() {}
// ^ NEW IN 1.60
    function bool IsCloseEnoughToInteractWith(Actor actionTarget) {}
// ^ NEW IN 1.60
    function bool ActionIsGrenade(EPlanAction eAPAction) {}
// ^ NEW IN 1.60
    function Actor CheckForPossibleInteractions() {}
// ^ NEW IN 1.60
    function DispatchInteractions() {}
    function BeginState() {}
    function EndState() {}
    function Timer() {}
    function bool ConfirmActionPointReached() {}
// ^ NEW IN 1.60
    function Actor GetFocus() {}
// ^ NEW IN 1.60
}

state WaitForPaceMember
{
}

state LockPickDoor
{
    function BeginState() {}
    function EndState() {}
}

state FindPathToTarget
{
    function EndState() {}
    function Timer() {}
}

state HoldPosition
{
    function BeginState() {}
    function EndState() {}
    function Timer() {}
}

state TeamSecureTerrorist
{
    function BeginState() {}
    function EndState() {}
}

state WaitForTeam
{
    function BeginState() {}
    function EndState() {}
}

state DetonateBreachingCharge
{
}

state PauseSniping
{
}

state TeamClimbStartNoLeader
{
    function BeginState() {}
    function EndState() {}
}

state TeamClimbEndNoLeader
{
}

state WaitForGameToStart
{
}

state TestBoneRotation
{
}

state WatchPlayer
{
    function BeginState() {}
    function EndState() {}
}

defaultproperties
{
}
