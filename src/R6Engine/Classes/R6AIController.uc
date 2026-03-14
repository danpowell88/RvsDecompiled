//=============================================================================
// R6AIController - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
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
    abstract
    native;

const C_fMaxBumpTime = 1.f;

var const int c_iDistanceBumpBackUp;  // distance to backup
var int m_iCurrentRouteCache;
var bool m_bStateBackupAvoidFacingWalls;  // backup of the bool when entering a state
var bool m_bIgnoreBackupBump;  // this flag should be set to true during states that should not be interrupted by a notifyBump to backup...
var bool m_bGetOffLadder;
// For debug purpose
var(Debug) bool bShowLog;
var(Debug) bool bShowInteractionLog;
var bool m_bChangingState;
var bool m_bCantInterruptIO;
var bool m_bMoveTargetAlreadySet;
var float m_fLastBump;  // the time where the pawn was bumped
var float m_fLoopAnimTime;
var R6Pawn m_r6pawn;  // remove r6pawn() cast
var R6Ladder m_TargetLadder;
var Actor m_BumpedBy;
var R6ClimbableObject m_climbingObject;
//InteractiveObjects
var R6InteractiveObject m_InteractionObject;
var Actor m_ActorTarget;
var R6IORotatingDoor m_closeDoor;  // the door too close after opening one
var name m_bumpBackUpNextState;  // return state when BumpBackUp state is over
var name m_openDoorNextState;  // return state when OpenDoor state is over
var name m_climbingObjectNextState;  // return state when BumpBackUp state is over
var name m_AnimName;
var name m_StateAfterInteraction;
var Vector m_vTargetPosition;
var Vector m_vPreviousPosition;
var Vector m_vBumpedByLocation;  // used in state code
var Vector m_vBumpedByVelocity;  // used in state code

// Export UR6AIController::execMakePathToRun(FFrame&, void* const)
// Find the best path to run away from an enemy (you must set Enemy before calling this)
native(1810) final function bool MakePathToRun();

// Export UR6AIController::execFindPlaceToTakeCover(FFrame&, void* const)
// Find the closest available spot
native(1811) final function R6ActionSpot FindPlaceToTakeCover(Vector vThreatLocation, float fMaxDistance);

// Export UR6AIController::execFindPlaceToFire(FFrame&, void* const)
native(1817) final function R6ActionSpot FindPlaceToFire(Actor PTarget, Vector vDestination, float fMaxDistance);

// Export UR6AIController::execFindInvestigationPoint(FFrame&, void* const)
native(1818) final function R6ActionSpot FindInvestigationPoint(int iSearchIndex, float fMaxDistance, optional bool bFromThreat, optional Vector vThreatLocation);

// Export UR6AIController::execPickActorAdjust(FFrame&, void* const)
native(1813) final function bool PickActorAdjust(Actor pActor);

// Export UR6AIController::execMoveToPosition(FFrame&, void* const)
// RBrek 13 Aug 2001 - Latent move function that will gradually move pawn to a certain location and orientation/rotation in
//                      a certain amount of time...
native(2201) final function MoveToPosition(Vector VPosition, Rotator rOrientation);

// Export UR6AIController::execFollowPath(FFrame&, void* const)
// Latent function to follow a path already calculated with function like FindPathTo and FindPathToward
native(1812) final function FollowPath(optional R6Pawn.eMovementPace ePace, optional name returnLabel, optional bool bContinuePath);

// Export UR6AIController::execFollowPathTo(FFrame&, void* const)
native(1814) final function FollowPathTo(Vector vDestination, optional R6Pawn.eMovementPace ePace, optional Actor aTarget);

// Export UR6AIController::execCanWalkTo(FFrame&, void* const)
// Check if the pawn can go to the destination with a MoveTo
native(1815) final function bool CanWalkTo(Vector vDestination, optional bool bDebug);

// Export UR6AIController::execFindGrenadeDirectionToHitActor(FFrame&, void* const)
native(1816) final function Rotator FindGrenadeDirectionToHitActor(Actor aTarget, Vector vTargetLoc, float fGrenadeSpeed);

// Export UR6AIController::execNeedToOpenDoor(FFrame&, void* const)
native(1509) final function bool NeedToOpenDoor(Actor Target);

// Export UR6AIController::execGotoOpenDoorState(FFrame&, void* const)
native(1510) final function GotoOpenDoorState(R6Door navPointToOpenFrom);

// Export UR6AIController::execFindNearbyWaitSpot(FFrame&, void* const)
native(2209) final function FindNearbyWaitSpot(Actor Node, out Vector vWaitLocation);

// Export UR6AIController::execActorReachableFromLocation(FFrame&, void* const)
native(2220) final function bool ActorReachableFromLocation(Actor Target, Vector vLocation);

function Possess(Pawn aPawn)
{
	super(Controller).Possess(aPawn);
	m_r6pawn = R6Pawn(aPawn);
	m_r6pawn.SetFriendlyFire();
	return;
}

function Tick(float fDeltaTime)
{
	super(Actor).Tick(fDeltaTime);
	// End:0x81
	if(__NFUN_119__(Pawn, none))
	{
		Pawn.m_bIsFiringWeapon = bFire;
		// End:0x81
		if(__NFUN_119__(m_r6pawn.m_TrackActor, none))
		{
			// End:0x64
			if(IsActorInView(m_r6pawn.m_TrackActor))
			{
				m_r6pawn.__NFUN_2218__();				
			}
			else
			{
				m_r6pawn.TurnToFaceActor(m_r6pawn.m_TrackActor);
			}
		}
	}
	return;
}

function bool IsActorInView(Actor Actor)
{
	// End:0x3D
	if(__NFUN_176__(__NFUN_219__(__NFUN_216__(Actor.Location, Pawn.Location), Vector(Pawn.Rotation)), float(0)))
	{
		return false;		
	}
	else
	{
		return true;
	}
	return;
}

function bool IsActorRightOfView(Actor Actor)
{
	// End:0x3D
	if(__NFUN_176__(__NFUN_219__(__NFUN_216__(Actor.Location, Pawn.Location), Vector(Pawn.Rotation)), float(0)))
	{
		return false;		
	}
	else
	{
		return true;
	}
	return;
}

event R6SetMovement(R6Pawn.eMovementPace ePace)
{
	// End:0x3A
	if(__NFUN_130__(__NFUN_129__(Pawn.m_bIsProne), __NFUN_154__(int(ePace), int(1))))
	{
		Pawn.m_bWantsToProne = true;		
	}
	else
	{
		// End:0x83
		if(__NFUN_130__(Pawn.m_bIsProne, __NFUN_155__(int(ePace), int(1))))
		{
			Pawn.m_bWantsToProne = false;
			Pawn.bWantsToCrouch = true;			
		}
		else
		{
			// End:0xCB
			if(Pawn.bIsCrouched)
			{
				// End:0xC8
				if(__NFUN_132__(__NFUN_154__(int(ePace), int(4)), __NFUN_154__(int(ePace), int(5))))
				{
					Pawn.bWantsToCrouch = false;
				}				
			}
			else
			{
				// End:0xFE
				if(__NFUN_132__(__NFUN_154__(int(ePace), int(2)), __NFUN_154__(int(ePace), int(3))))
				{
					Pawn.bWantsToCrouch = true;
				}
			}
		}
	}
	// End:0x159
	if(__NFUN_132__(__NFUN_132__(__NFUN_154__(int(ePace), int(4)), __NFUN_154__(int(ePace), int(2))), __NFUN_154__(int(ePace), int(1))))
	{
		// End:0x156
		if(__NFUN_129__(Pawn.bIsWalking))
		{
			Pawn.SetWalking(true);
		}		
	}
	else
	{
		// End:0x19D
		if(__NFUN_132__(__NFUN_154__(int(ePace), int(5)), __NFUN_154__(int(ePace), int(3))))
		{
			// End:0x19D
			if(Pawn.bIsWalking)
			{
				Pawn.SetWalking(false);
			}
		}
	}
	m_r6pawn.m_eMovementPace = ePace;
	return;
}

//------------------------------------------------------------------
// CheckPaceForInjury()                                           
//   17 jan 2002 rbrek                  
//   Rainbow cannot run if injured, walk only...        
//------------------------------------------------------------------
function CheckPaceForInjury(out R6Pawn.eMovementPace ePace)
{
	// End:0x4C
	if(__NFUN_154__(int(m_r6pawn.m_eHealth), int(1)))
	{
		// End:0x34
		if(__NFUN_154__(int(ePace), int(3)))
		{
			ePace = 2;			
		}
		else
		{
			// End:0x4C
			if(__NFUN_154__(int(ePace), int(5)))
			{
				ePace = 4;
			}
		}
	}
	return;
}

// the following movement functions will handle moving the pawn in the right direction
// with a desired orientation, and at the right speed/velocity.
// if a focus is not specified, 
function R6PreMoveTo(Vector vTargetPosition, Vector vFocus, R6Pawn.eMovementPace ePace)
{
	CheckPaceForInjury(ePace);
	R6SetMovement(ePace);
	Focus = none;
	FocalPoint = vFocus;
	Destination = vTargetPosition;
	return;
}

function R6PreMoveToward(Actor Target, Actor pFocus, R6Pawn.eMovementPace ePace)
{
	CheckPaceForInjury(ePace);
	R6SetMovement(ePace);
	Focus = none;
	FocalPoint = pFocus.Location;
	Destination = Target.Location;
	return;
}

// override the version in AIController.uc so that only depend on focalpoint and destination...
function int GetFacingDirection()
{
	local float fStrafeMag;
	local Vector vFocus2D, vLoc2D, vDest2D, vDir, vLookDir, vY;

	// End:0x11
	if(__NFUN_217__(FocalPoint, Destination))
	{
		return 0;
	}
	vFocus2D = FocalPoint;
	vFocus2D.Z = 0.0000000;
	vLoc2D = Pawn.Location;
	vLoc2D.Z = 0.0000000;
	vDest2D = Destination;
	vDest2D.Z = 0.0000000;
	vLookDir = __NFUN_226__(__NFUN_216__(vFocus2D, vLoc2D));
	vDir = __NFUN_226__(__NFUN_216__(vDest2D, vLoc2D));
	fStrafeMag = __NFUN_219__(vLookDir, vDir);
	// End:0x110
	if(__NFUN_176__(fStrafeMag, 0.7500000))
	{
		// End:0xCC
		if(__NFUN_176__(fStrafeMag, -0.7500000))
		{
			return 32768;			
		}
		else
		{
			vY = __NFUN_220__(vLookDir, vect(0.0000000, 0.0000000, 1.0000000));
			// End:0x10A
			if(__NFUN_177__(__NFUN_219__(vY, __NFUN_216__(vDest2D, vLoc2D)), float(0)))
			{
				return 49152;				
			}
			else
			{
				return 16384;
			}
		}
	}
	return 0;
	return;
}

//------------------------------------------------------------------
// CanClimbLadders
//  
//------------------------------------------------------------------
function bool CanClimbLadders(R6Ladder Ladder)
{
	return m_r6pawn.m_bAutoClimbLadders;
	return;
}

//------------------------------------------------------------------
// CanClimbObject: true if the pawn can climb r6ClimableObject. 
//  - needed for inheritance
//------------------------------------------------------------------
function bool CanClimbObject()
{
	return m_r6pawn.m_bCanClimbObject;
	return;
}

function CheckNeedToClimbLadder()
{
	return;
}

function ConfirmLadderActionPointWasReached(R6Ladder Ladder)
{
	return;
}

function bool LadderIsAvailable()
{
	local R6LadderVolume ladderVol;

	ladderVol = R6LadderVolume(m_TargetLadder.MyLadder);
	// End:0x34
	if(__NFUN_129__(ladderVol.IsAvailable(Pawn)))
	{
		return false;
	}
	// End:0x73
	if(__NFUN_130__(__NFUN_130__(m_TargetLadder.m_bIsTopOfLadder, ladderVol.IsAShortLadder()), __NFUN_129__(ladderVol.SpaceIsAvailableAtBottomOfLadder(true))))
	{
		return false;
	}
	return true;
	return;
}

function bool AreClimbingInSameDirection(R6Pawn npcPawn, R6Pawn PlayerPawn)
{
	// End:0x42
	if(__NFUN_181__(PlayerPawn.Velocity.Z, 0.0000000))
	{
		// End:0x42
		if(__NFUN_242__(npcPawn.IsMovingUpLadder(), PlayerPawn.IsMovingUpLadder()))
		{
			return true;
		}
	}
	return false;
	return;
}

// Called when killed
function PawnDied()
{
	__NFUN_113__('Dead');
	return;
}

//------------------------------------------------------------------
// StopMoving
//  
//------------------------------------------------------------------
function StopMoving()
{
	// End:0x0D
	if(__NFUN_114__(Pawn, none))
	{
		return;
	}
	Pawn.Acceleration = vect(0.0000000, 0.0000000, 0.0000000);
	Pawn.Velocity = vect(0.0000000, 0.0000000, 0.0000000);
	MoveTarget = none;
	Pawn.SetWalking(true);
	return;
}

event bool NotifyBump(Actor Other)
{
	// End:0x18
	if(__NFUN_129__(Other.__NFUN_303__('R6Pawn')))
	{
		return false;
	}
	// End:0xA3
	if(__NFUN_132__(m_r6pawn.IsStationary(), __NFUN_129__(m_r6pawn.HasBumpPriority(R6Pawn(Other)))))
	{
		// End:0x9E
		if(__NFUN_130__(__NFUN_129__(m_bIgnoreBackupBump), __NFUN_129__(__NFUN_281__('ApproachLadder'))))
		{
			StopMoving();
			m_BumpedBy = Other;
			// End:0x8E
			if(__NFUN_255__(__NFUN_284__(), 'BumpBackUp'))
			{
				GotoBumpBackUpState(__NFUN_284__());				
			}
			else
			{
				GotoBumpBackUpState(m_bumpBackUpNextState);
			}
			return true;			
		}
		else
		{
			return false;
		}		
	}
	else
	{
		return __NFUN_1813__(Other);
	}
	return;
}

function bool IsInCrouchedPosture()
{
	return Pawn.bIsCrouched;
	return;
}

//------------------------------------------------------------------
// GotoBumpBackUpState: initialize and sets the current state to 
//  BumpBackUp.
//------------------------------------------------------------------
function GotoBumpBackUpState(name returnState)
{
	// End:0x11
	if(__NFUN_254__(returnState, 'BumpBackUp'))
	{
		return;
	}
	m_bumpBackUpNextState = returnState;
	__NFUN_113__('BumpBackUp');
	return;
}

//------------------------------------------------------------------
// IsBumpBackUpStateFinish: return true if the condition to end the
// state BumpBackUp are reached.
//------------------------------------------------------------------
function bool IsBumpBackUpStateFinish()
{
	// End:0x21
	if(__NFUN_176__(__NFUN_174__(m_fLastBump, 1.0000000), Level.TimeSeconds))
	{
		return true;
	}
	return __NFUN_179__(DistanceTo(m_BumpedBy), float(c_iDistanceBumpBackUp));
	return;
}

//------------------------------------------------------------------
// BumpBackUpStateFinished: function fired if there is not a 
//  return state (in m_bumpBackUpState_nextState)
//------------------------------------------------------------------
function BumpBackUpStateFinished()
{
	__NFUN_231__("ScriptWarning: BumpBackUpStateFinished was not inherited");
	return;
}

//------------------------------------------------------------------
// DistanceTo: distance to a pawn without considering the Z axis
//  
//------------------------------------------------------------------
function float DistanceTo(Actor member, optional bool bIncludeZ)
{
	local Vector vDistance;

	// End:0x11
	if(__NFUN_114__(member, none))
	{
		return 0.0000000;
	}
	vDistance = __NFUN_216__(Pawn.Location, member.Location);
	// End:0x50
	if(__NFUN_129__(bIncludeZ))
	{
		vDistance.Z = 0.0000000;
	}
	return __NFUN_225__(vDistance);
	return;
}

//------------------------------------------------------------------
// CanOpenDoor: check if the pawn has the ability to open the door
//  ie: in case it's locked.
//------------------------------------------------------------------
event bool CanOpenDoor(R6IORotatingDoor Door)
{
	return true;
	return;
}

//------------------------------------------------------------------
// OpenDoorFailed: triggered when the pawn try to go in the state 
//  OpenDoor. Usually should go in another state
//------------------------------------------------------------------
event OpenDoorFailed()
{
	m_r6pawn.logWarning("should be overwritted. ie: gotostate('doSomethingIfDoorIsLocked')");
	return;
}

//------------------------------------------------------------------
// TestMakePath
//------------------------------------------------------------------
function SetStateTestMakePath(Pawn anEnemy, R6Pawn.eMovementPace ePace)
{
	Enemy = anEnemy;
	m_r6pawn.m_eMovementPace = ePace;
	LastSeenTime = Level.TimeSeconds;
	__NFUN_113__('TestMakePath');
	return;
}

//============================================================================
// FLOAT GetCurrentChanceToHit - 
//============================================================================
function float GetCurrentChanceToHit(Actor aTarget)
{
	local float fAngle, fDistance, fError;

	// End:0x1A
	if(__NFUN_114__(Pawn.EngineWeapon, none))
	{
		return 0.0000000;
	}
	fAngle = __NFUN_171__(Pawn.EngineWeapon.GetCurrentMaxAngle(), 0.0174533);
	fAngle = __NFUN_189__(fAngle);
	fDistance = __NFUN_225__(__NFUN_216__(Pawn.Location, aTarget.Location));
	fError = __NFUN_171__(fAngle, fDistance);
	return __NFUN_172__(aTarget.CollisionRadius, fError);
	return;
}

//============================================================================
// BOOL IsReadyToFire - 
//============================================================================
function bool IsReadyToFire(Actor aTarget)
{
	local float fNeededChanceToHit, fSelfControl;

	// End:0x1D
	if(Pawn.EngineWeapon.IsAtBestAccuracy())
	{
		return true;
	}
	fSelfControl = m_r6pawn.GetSkill(5);
	fNeededChanceToHit = __NFUN_171__(fSelfControl, fSelfControl);
	// End:0x60
	if(__NFUN_177__(fNeededChanceToHit, 1.0000000))
	{
		fNeededChanceToHit = 1.0000000;
	}
	return __NFUN_177__(GetCurrentChanceToHit(aTarget), fNeededChanceToHit);
	return;
}

//============================================================================
// BOOL IsFocusLeft - 
//============================================================================
function bool IsFocusLeft()
{
	local int iLeft, iRight;
	local Rotator rFocus;

	// End:0x0D
	if(__NFUN_114__(Focus, none))
	{
		return true;
	}
	rFocus = Rotator(__NFUN_216__(Focus.Location, Pawn.Location));
	iLeft = __NFUN_251__(__NFUN_147__(rFocus.Yaw, Pawn.Rotation.Yaw), 0, 65535);
	iRight = __NFUN_251__(__NFUN_146__(rFocus.Yaw, Pawn.Rotation.Yaw), 0, 65535);
	return __NFUN_150__(iLeft, iRight);
	return;
}

//============================================================================
// ChangeOrientationTo - 
//============================================================================
function ChangeOrientationTo(Rotator NewRotation)
{
	Focus = none;
	FocalPoint = __NFUN_215__(Pawn.Location, __NFUN_212__(Vector(NewRotation), float(50)));
	Pawn.DesiredRotation = NewRotation;
	return;
}

//------------------------------------------------------------------
// ChooseRandomDirection
//  
//------------------------------------------------------------------
function Rotator ChooseRandomDirection(int iLookBackChance)
{
	local bool bLookBack, bTurnLeft;
	local int ITemp;
	local Rotator rRot;

	bLookBack = __NFUN_150__(__NFUN_146__(__NFUN_167__(100), 1), iLookBackChance);
	bTurnLeft = __NFUN_154__(__NFUN_167__(2), 1);
	// End:0x43
	if(bLookBack)
	{
		ITemp = __NFUN_146__(__NFUN_167__(16383), 16383);		
	}
	else
	{
		ITemp = __NFUN_146__(__NFUN_167__(8192), 8192);
	}
	rRot = Pawn.Rotation;
	// End:0x88
	if(bTurnLeft)
	{
		__NFUN_162__(rRot.Yaw, ITemp);		
	}
	else
	{
		__NFUN_161__(rRot.Yaw, ITemp);
	}
	return rRot;
	return;
}

// The following function was taken from Bot.uc
// FindBestPathToward() assumes the desired destination is not directly reachable. 
// It tries to set Destination to the location of the best waypoint, and returns true if successful
function bool FindBestPathToward(Actor desired, bool bClearPaths)
{
	local Actor Path;
	local bool bSuccess;

	Path = __NFUN_517__(desired, bClearPaths);
	bSuccess = __NFUN_119__(Path, none);
	// End:0x4B
	if(bSuccess)
	{
		MoveTarget = Path;
		Destination = Path.Location;
	}
	return bSuccess;
	return;
}

//============================================================================
// IsFacing - 
//============================================================================
function bool IsFacing(Actor aGrenade)
{
	local Vector vDir;

	vDir = __NFUN_216__(aGrenade.Location, Pawn.Location);
	// End:0x47
	if(__NFUN_177__(__NFUN_219__(__NFUN_226__(vDir), Vector(Pawn.Rotation)), float(0)))
	{
		return true;
	}
	return false;
	return;
}

//============================================================================
// AIAffectedByGrenade - 
//============================================================================
function AIAffectedByGrenade(Actor aGrenade, Pawn.EGrenadeType eType)
{
	return;
}

//============================================================================
// GetGrenadeDirection - 
//============================================================================
function Rotator GetGrenadeDirection(Actor aTarget, optional Vector vTargetLoc)
{
	local Rotator rFiringRotation;

	rFiringRotation = __NFUN_1816__(aTarget, vTargetLoc, Pawn.EngineWeapon.GetMuzzleVelocity());
	return rFiringRotation;
	return;
}

//===================================================================================================
//   ####              #                                       #      ##                            
//    ##              ##                                      ##                                    
//    ##    #####    #####   ####   ## ###   ####    ####    #####   ###     ####   #####    #####  
//    ##    ##  ##    ##    ##  ##   ### ##     ##  ##  ##    ##      ##    ##  ##  ##  ##  ##      
//    ##    ##  ##    ##    ######   ##  ##  #####  ##        ##      ##    ##  ##  ##  ##   ####   
//    ##    ##  ##    ## #  ##       ##     ##  ##  ##  ##    ## #    ##    ##  ##  ##  ##      ##  
//   ####   ##  ##     ##    ####   ####     ### ##  ####      ##    ####    ####   ##  ##  #####   
//===================================================================================================
function bool CanInteractWithObjects(R6InteractiveObject o)
{
	return false;
	return;
}

function PerformAction_StartInteraction()
{
	m_StateAfterInteraction = __NFUN_284__();
	m_InteractionObject.m_SeePlayerPawn = none;
	m_InteractionObject.m_HearNoiseNoiseMaker = none;
	m_InteractionObject.m_bPawnDied = false;
	m_bChangingState = true;
	__NFUN_113__('PA_StartInteraction');
	return;
}

function PerformAction_LookAt(Actor Target)
{
	m_ActorTarget = Target;
	m_bChangingState = true;
	__NFUN_113__('PA_LookAt');
	return;
}

function PerformAction_Goto(Actor Target)
{
	m_ActorTarget = Target;
	m_bChangingState = true;
	__NFUN_113__('PA_Goto');
	return;
}

function PerformAction_PlayAnim(name animName)
{
	m_AnimName = animName;
	m_bChangingState = true;
	__NFUN_113__('PA_PlayAnim');
	return;
}

function PerformAction_LoopAnim(name animName, float fLoopAnimTime)
{
	m_AnimName = animName;
	m_fLoopAnimTime = fLoopAnimTime;
	m_bChangingState = true;
	__NFUN_113__('PA_LoopAnim');
	return;
}

function PerformAction_StopInteraction()
{
	m_bChangingState = true;
	__NFUN_113__(m_StateAfterInteraction);
	// End:0x2D
	if(__NFUN_242__(m_InteractionObject.m_bPawnDied, true))
	{
		PawnDied();		
	}
	else
	{
		// End:0x55
		if(__NFUN_119__(m_InteractionObject.m_SeePlayerPawn, none))
		{
			SeePlayer(m_InteractionObject.m_SeePlayerPawn);
		}
	}
	// End:0x99
	if(__NFUN_119__(m_InteractionObject.m_HearNoiseNoiseMaker, none))
	{
		HearNoise(m_InteractionObject.m_HearNoiseLoudness, m_InteractionObject.m_HearNoiseNoiseMaker, m_InteractionObject.m_HearNoiseType);
	}
	return;
}

state WaitToClimbLadder
{
	function BeginState()
	{
		return;
	}

	function EndState()
	{
		return;
	}

	function Vector GetWaitPosition()
	{
		// End:0x4C
		if(m_TargetLadder.m_bIsTopOfLadder)
		{
			return __NFUN_215__(m_TargetLadder.Location, __NFUN_213__(float(200), Vector(__NFUN_316__(m_TargetLadder.Rotation, rot(0, 8192, 0)))));			
		}
		else
		{
			return __NFUN_216__(m_TargetLadder.Location, __NFUN_213__(float(200), Vector(__NFUN_316__(m_TargetLadder.Rotation, rot(0, 8192, 0)))));
		}
		return;
	}
Begin:

	Destination = GetWaitPosition();
	R6PreMoveTo(Destination, m_TargetLadder.Location, 4);
	__NFUN_500__(Destination, m_TargetLadder);
	StopMoving();
Wait:


	__NFUN_256__(1.0000000);
	// End:0x68
	if(LadderIsAvailable())
	{
		MoveTarget = m_TargetLadder;
		__NFUN_256__(2.0000000);
		__NFUN_113__('ApproachLadder');		
	}
	else
	{
		goto 'Wait';
	}
	stop;	
}

state ApproachLadder
{
	function BeginState()
	{
		m_TargetLadder = R6Ladder(MoveTarget);
		m_bStateBackupAvoidFacingWalls = m_r6pawn.m_bAvoidFacingWalls;
		m_r6pawn.m_bAvoidFacingWalls = false;
		Pawn.m_bCanProne = false;
		return;
	}

	function EndState()
	{
		Pawn.m_bCanProne = true;
		// End:0x4C
		if(__NFUN_155__(int(Pawn.Physics), int(11)))
		{
			R6LadderVolume(m_TargetLadder.MyLadder).RemoveClimber(m_r6pawn);
		}
		return;
	}

	function bool ReadyToClimbLadder()
	{
		local R6RainbowAI rainbowAI;

		rainbowAI = R6RainbowAI(m_r6pawn.Controller);
		rainbowAI.m_TeamManager.SetTeamIsClimbingLadder(true);
		// End:0x75
		if(__NFUN_130__(__NFUN_151__(__NFUN_156__(rainbowAI.m_TeamManager.m_iTeamAction, 512), 0), rainbowAI.m_TeamManager.m_bCAWaitingForZuluGoCode))
		{
			return false;
		}
		return true;
		return;
	}
Begin:

	Pawn.SetBoneRotation('R6 Spine1', rot(0, 0, 0),, 1.0000000);
	// End:0x39
	if(__NFUN_114__(m_TargetLadder, none))
	{
		__NFUN_113__('Dispatcher');
	}
	// End:0x4B
	if(__NFUN_129__(LadderIsAvailable()))
	{
		__NFUN_113__('WaitToClimbLadder');
	}
	R6LadderVolume(m_TargetLadder.MyLadder).AddClimber(m_r6pawn);
MoveToStartOfLadder:


	CheckNeedToClimbLadder();
	R6PreMoveToward(m_TargetLadder, m_TargetLadder, 4);
	__NFUN_502__(m_TargetLadder);
	// End:0xB5
	if(__NFUN_179__(DistanceTo(m_TargetLadder), float(40)))
	{
		StopMoving();
		__NFUN_256__(1.0000000);
		goto 'MoveToStartOfLadder';
	}
	ConfirmLadderActionPointWasReached(m_TargetLadder);
WaitForZuluGoCode:


	// End:0xF2
	if(__NFUN_154__(int(m_r6pawn.m_ePawnType), int(1)))
	{
		// End:0xF2
		if(__NFUN_129__(ReadyToClimbLadder()))
		{
			__NFUN_256__(0.5000000);
			goto 'WaitForZuluGoCode';
		}
	}
Wait:


	__NFUN_256__(0.5000000);
	// End:0x159
	if(__NFUN_129__(m_TargetLadder.m_bIsTopOfLadder))
	{
		Destination = m_TargetLadder.Location;
		Destination.Z = Pawn.Location.Z;
		__NFUN_2201__(Destination, m_TargetLadder.Rotation);		
	}
	else
	{
		Destination = __NFUN_215__(m_TargetLadder.Location, __NFUN_213__(float(50), Vector(m_TargetLadder.Rotation)));
		Destination.Z = Pawn.Location.Z;
		__NFUN_2201__(Destination, __NFUN_316__(m_TargetLadder.Rotation, rot(0, 32768, 0)));
	}
	// End:0x1F7
	if(__NFUN_179__(__NFUN_225__(__NFUN_216__(Pawn.Location, Destination)), float(10)))
	{
		__NFUN_256__(1.0000000);
		goto 'Wait';
	}
	// End:0x23D
	if(__NFUN_132__(__NFUN_114__(m_r6pawn.m_potentialActionActor, none), __NFUN_129__(m_r6pawn.m_potentialActionActor.__NFUN_303__('R6LadderVolume'))))
	{
		MoveTarget = m_TargetLadder;
		goto 'Wait';
	}
	// End:0x2A1
	if(__NFUN_129__(m_r6pawn.m_bIsClimbingLadder))
	{
		// End:0x27F
		if(__NFUN_129__(R6LadderVolume(m_TargetLadder.MyLadder).IsAvailable(Pawn)))
		{
			__NFUN_113__('WaitToClimbLadder');
		}
		m_r6pawn.ClimbLadder(LadderVolume(m_r6pawn.m_potentialActionActor));
	}
	stop;		
}

state BeginClimbingLadder
{
	function BeginState()
	{
		Pawn.m_bCanProne = false;
		__NFUN_118__('NotifyBump');
		return;
	}

	function EndState()
	{
		Pawn.m_bCanProne = true;
		m_bMoveTargetAlreadySet = false;
		Pawn.LadderSpeed = Pawn.default.LadderSpeed;
		return;
	}

	event bool NotifyBump(Actor Other)
	{
		local R6Pawn bumpingPawn;

		// End:0x18
		if(__NFUN_129__(Other.__NFUN_303__('R6Pawn')))
		{
			return false;
		}
		m_BumpedBy = Other;
		bumpingPawn = R6Pawn(Other);
		// End:0x147
		if(__NFUN_130__(bumpingPawn.m_bIsClimbingLadder, __NFUN_129__(AreClimbingInSameDirection(m_r6pawn, bumpingPawn))))
		{
			// End:0xB6
			if(__NFUN_129__(bumpingPawn.m_bIsPlayer))
			{
				// End:0xB6
				if(__NFUN_176__(R6AIController(bumpingPawn.Controller).DistanceTo(bumpingPawn.m_Ladder), DistanceTo(m_r6pawn.m_Ladder)))
				{
					return false;
				}
			}
			Pawn.LadderSpeed = 200.0000000;
			// End:0x10A
			if(__NFUN_177__(Pawn.Velocity.Z, float(0)))
			{
				MoveTarget = R6LadderVolume(Pawn.OnLadder).m_BottomLadder;				
			}
			else
			{
				MoveTarget = R6LadderVolume(Pawn.OnLadder).m_TopLadder;
			}
			Pawn.bIsWalking = false;
			m_bGetOffLadder = true;
			return true;
		}
		// End:0x169
		if(__NFUN_129__(bumpingPawn.m_bIsClimbingLadder))
		{
			__NFUN_113__('BeginClimbingLadder', 'BlockedAtTop');
			return true;
		}
		return;
	}
Begin:

	// End:0x23
	if(Pawn.bIsCrouched)
	{
		Pawn.bWantsToCrouch = false;
	}
	__NFUN_256__(0.5000000);
	// End:0xC7
	if(__NFUN_154__(int(Pawn.m_ePawnType), int(1)))
	{
		m_r6pawn.SetNextPendingAction(27);
		__NFUN_261__(m_r6pawn.14);
		// End:0xC7
		if(__NFUN_129__(LadderIsAvailable()))
		{
			m_r6pawn.m_bIsClimbingLadder = false;
			R6LadderVolume(m_TargetLadder.MyLadder).RemoveClimber(m_r6pawn);
			Pawn.__NFUN_3970__(1);
			m_r6pawn.SetNextPendingAction(28);
			__NFUN_113__('WaitToClimbLadder');
		}
	}
	m_r6pawn.m_bIsClimbingLadder = true;
	Pawn.LockRootMotion(1, true);
	m_r6pawn.SetNextPendingAction(5);
WaitForStartClimbingAnimToEnd:


	__NFUN_261__();
StartLadder:


	m_r6pawn.SetNextPendingAction(6);
	__NFUN_261__(m_r6pawn.1);
	Pawn.__NFUN_299__(Pawn.OnLadder.LadderList.Rotation);
	__NFUN_299__(Pawn.OnLadder.LadderList.Rotation);
	Focus = none;
	// End:0x18D
	if(__NFUN_130__(m_bMoveTargetAlreadySet, __NFUN_119__(MoveTarget, none)))
	{
		goto 'MoveTowardEndOfLadder';
	}
	// End:0x1FF
	if(m_r6pawn.m_Ladder.m_bIsTopOfLadder)
	{
		Pawn.__NFUN_267__(__NFUN_215__(Pawn.Location, __NFUN_213__(float(15), Vector(Pawn.Rotation))));
		m_TargetLadder = R6LadderVolume(Pawn.OnLadder).m_BottomLadder;		
	}
	else
	{
		// End:0x24A
		if(__NFUN_155__(int(m_r6pawn.m_ePawnType), int(3)))
		{
			Pawn.__NFUN_267__(__NFUN_216__(Pawn.Location, __NFUN_213__(float(20), Vector(Pawn.Rotation))));
		}
		m_TargetLadder = R6LadderVolume(Pawn.OnLadder).m_TopLadder;
	}
	MoveTarget = m_TargetLadder;
MoveTowardEndOfLadder:


	__NFUN_117__('NotifyBump');
	Pawn.Anchor = NavigationPoint(MoveTarget);
	// End:0x2DC
	if(__NFUN_130__(__NFUN_154__(int(m_r6pawn.m_ePawnType), int(1)), __NFUN_154__(int(m_r6pawn.m_eHealth), int(0))))
	{
		Pawn.bIsWalking = false;
	}
	__NFUN_502__(MoveTarget);
	// End:0x30E
	if(__NFUN_154__(int(m_r6pawn.m_ePawnType), int(1)))
	{
		Pawn.bIsWalking = true;
	}
	__NFUN_256__(2.0000000);
	goto 'MoveTowardEndOfLadder';
BlockedAtTop:


	StopMoving();
	__NFUN_256__(1.5000000);
	MoveTarget = m_TargetLadder;
	goto 'MoveTowardEndOfLadder';
	stop;				
}

state EndClimbingLadder
{
	function BeginState()
	{
		Pawn.Acceleration = vect(0.0000000, 0.0000000, 0.0000000);
		__NFUN_118__('NotifyBump');
		return;
	}

	function EndState()
	{
		Pawn.OnLadder = none;
		m_r6pawn.m_bIsClimbingLadder = false;
		Pawn.bCollideWorld = true;
		m_r6pawn.m_bAvoidFacingWalls = m_bStateBackupAvoidFacingWalls;
		return;
	}

	function bool NotifyHitWall(Vector HitNormal, Actor Wall)
	{
		return true;
		return;
	}

	function ClimbLadderIsOver()
	{
		local int i;

		m_r6pawn.m_Ladder = none;
		Pawn.OnLadder = none;
		J0x20:

		// End:0x43 [Loop If]
		if(__NFUN_150__(i, 16))
		{
			RouteCache[i] = none;
			__NFUN_163__(i);
			// [Loop Continue]
			goto J0x20;
		}
		return;
	}
Begin:

	// End:0x1A
	if(__NFUN_129__(m_r6pawn.m_bIsClimbingLadder))
	{
		goto 'End';
	}
	// End:0x75
	if(__NFUN_132__(__NFUN_132__(m_r6pawn.m_Ladder.m_bIsTopOfLadder, Pawn.bIsWalking), __NFUN_155__(int(m_r6pawn.m_ePawnType), int(1))))
	{
		Pawn.LockRootMotion(1, true);
	}
	m_r6pawn.SetNextPendingAction(7);
WaitForEndClimbingAnimToEnd:


	__NFUN_261__(0);
	m_r6pawn.m_bSlideEnd = false;
	ConfirmLadderActionPointWasReached(m_r6pawn.m_Ladder);
EndClimb:


	m_r6pawn.m_ePlayerIsUsingHands = 3;
	Pawn.__NFUN_3970__(1);
	m_TargetLadder = m_r6pawn.m_Ladder;
	// End:0x11E
	if(m_r6pawn.m_Ladder.m_bIsTopOfLadder)
	{
		m_r6pawn.SetNextPendingAction(8);
		__NFUN_261__(m_r6pawn.1);		
	}
	else
	{
		// End:0x169
		if(__NFUN_132__(Pawn.bIsWalking, __NFUN_155__(int(m_r6pawn.m_ePawnType), int(1))))
		{
			m_r6pawn.SetNextPendingAction(8);
			__NFUN_261__(m_r6pawn.1);
		}
	}
	Focus = Pawn.OnLadder;
	FocalPoint = Pawn.OnLadder.Location;
	MoveTarget = none;
	m_r6pawn.m_bIsClimbingLadder = false;
	// End:0x1DC
	if(__NFUN_154__(int(Pawn.m_ePawnType), int(1)))
	{
		m_r6pawn.SetNextPendingAction(28);
	}
	__NFUN_117__('NotifyBump');
End:


	// End:0x24E
	if(m_r6pawn.m_Ladder.m_bIsTopOfLadder)
	{
		Destination = __NFUN_215__(Pawn.Location, __NFUN_213__(float(120), Pawn.OnLadder.LookDir));
		R6PreMoveTo(Destination, Destination, 4);
		__NFUN_500__(Destination);		
	}
	else
	{
		Destination = __NFUN_216__(Pawn.Location, __NFUN_213__(float(120), Pawn.OnLadder.LookDir));
		R6PreMoveTo(Destination, Pawn.OnLadder.Location, 4);
		__NFUN_500__(Destination, Pawn.OnLadder);
	}
	StopMoving();
	// End:0x313
	if(__NFUN_154__(int(m_r6pawn.m_ePawnType), int(1)))
	{
		// End:0x310
		if(__NFUN_129__(m_bGetOffLadder))
		{
			R6RainbowAI(Pawn.Controller).m_TeamManager.MemberFinishedClimbingLadder(m_r6pawn);
		}		
	}
	else
	{
		// End:0x332
		if(__NFUN_154__(int(m_r6pawn.m_ePawnType), int(3)))
		{
			ClimbLadderIsOver();
		}
	}
	// End:0x34D
	if(m_bGetOffLadder)
	{
		m_bGetOffLadder = false;
		__NFUN_113__('WaitToClimbLadder');		
	}
	else
	{
		// End:0x36B
		if(__NFUN_255__(NextState, 'None'))
		{
			__NFUN_113__(NextState, NextLabel);			
		}
		else
		{
			__NFUN_113__('Dispatcher');
		}
	}
	stop;	
}

state Dispatcher
{
	function BeginState()
	{
		return;
	}
Begin:

	__NFUN_256__(3.0000000);
	// End:0x1E
	if(__NFUN_255__(NextState, 'None'))
	{
		__NFUN_113__(NextState);
	}
	goto 'Begin';
	stop;			
}

state Dead
{
	ignores R6DamageAttitudeTo;

	function BeginState()
	{
		StopMoving();
		__NFUN_267__(Pawn.Location);
		return;
	}
	stop;
}

state BumpBackUp
{
	function BeginState()
	{
		return;
	}

	function EndState()
	{
		StopMoving();
		return;
	}

	function bool MoveRight()
	{
		local Vector vProduct;

		m_vBumpedByLocation = m_BumpedBy.Location;
		m_vBumpedByLocation.Z = Pawn.Location.Z;
		vProduct = __NFUN_220__(__NFUN_226__(m_BumpedBy.Velocity), __NFUN_226__(__NFUN_216__(Pawn.Location, m_vBumpedByLocation)));
		// End:0x75
		if(__NFUN_177__(vProduct.Z, float(0)))
		{
			return true;
		}
		return false;
		return;
	}

	event bool NotifyBump(Actor Other)
	{
		// End:0x4E
		if(__NFUN_132__(__NFUN_114__(Other, m_BumpedBy), __NFUN_130__(__NFUN_119__(R6Pawn(Other), none), R6Pawn(Other).m_bIsPlayer)))
		{
			m_BumpedBy = Other;
			__NFUN_113__('BumpBackUp');
			return true;
		}
		return false;
		return;
	}

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
	function bool GetReacheablePoint(out Vector vTarget, bool bNoFail)
	{
		local Rotator rRotation;
		local int iYawIncrement, iStartingYaw, iTry, iTryMax, iTryOnAQuadrantMax;

		local Vector vDest;

		// End:0x24
		if(__NFUN_154__(int(m_r6pawn.m_ePawnType), int(3)))
		{
			iTryMax = 7;			
		}
		else
		{
			iTryMax = 1;
		}
		iStartingYaw = 16384;
		iYawIncrement = __NFUN_145__(16384, 3);
		iTryOnAQuadrantMax = __NFUN_146__(__NFUN_145__(16384, iYawIncrement), 1);
		// End:0x81
		if(__NFUN_129__(MoveRight()))
		{
			__NFUN_159__(iStartingYaw, float(-1));
			__NFUN_159__(iYawIncrement, float(-1));
		}
		J0x81:

		// End:0x14C [Loop If]
		if(__NFUN_150__(iTry, iTryMax))
		{
			// End:0xC0
			if(__NFUN_150__(iTry, iTryOnAQuadrantMax))
			{
				rRotation.Yaw = __NFUN_146__(iStartingYaw, __NFUN_144__(iYawIncrement, iTry));				
			}
			else
			{
				rRotation.Yaw = __NFUN_146__(iStartingYaw, __NFUN_144__(__NFUN_144__(iYawIncrement, __NFUN_147__(__NFUN_146__(iTry, 1), iTryOnAQuadrantMax)), -1));
			}
			vDest = __NFUN_215__(Pawn.Location, __NFUN_213__(float(c_iDistanceBumpBackUp), Vector(__NFUN_316__(Rotator(m_vBumpedByVelocity), rRotation))));
			// End:0x142
			if(__NFUN_132__(__NFUN_1815__(vDest), bNoFail))
			{
				vTarget = vDest;
				return true;
			}
			__NFUN_163__(iTry);
			// [Loop Continue]
			goto J0x81;
		}
		return false;
		return;
	}
Begin:

	// End:0x24
	if(m_BumpedBy.__NFUN_303__('R6IORotatingDoor'))
	{
		__NFUN_118__('NotifyBump');
		goto 'BackupFromDoor';		
	}
	else
	{
		// End:0x47
		if(__NFUN_129__(m_BumpedBy.__NFUN_303__('R6Pawn')))
		{
			__NFUN_118__('NotifyBump');
			goto 'BackupFromActor';
		}
	}
	m_vBumpedByLocation = m_BumpedBy.Location;
	m_vBumpedByLocation.Z = Pawn.Location.Z;
	m_vBumpedByVelocity = m_BumpedBy.Velocity;
	m_vBumpedByVelocity.Z = Pawn.Velocity.Z;
	// End:0xC8
	if(__NFUN_129__(GetReacheablePoint(m_vTargetPosition, false)))
	{
		GetReacheablePoint(m_vTargetPosition, true);
	}
	// End:0xF8
	if(Pawn.m_bIsProne)
	{
		R6PreMoveTo(m_vTargetPosition, m_BumpedBy.Location, 1);		
	}
	else
	{
		// End:0x156
		if(__NFUN_154__(int(m_r6pawn.m_ePawnType), int(3)))
		{
			// End:0x138
			if(IsInCrouchedPosture())
			{
				R6PreMoveTo(m_vTargetPosition, m_BumpedBy.Location, 2);				
			}
			else
			{
				R6PreMoveTo(m_vTargetPosition, m_BumpedBy.Location, 4);
			}			
		}
		else
		{
			// End:0x198
			if(__NFUN_130__(__NFUN_155__(int(m_r6pawn.m_ePawnType), int(1)), IsInCrouchedPosture()))
			{
				R6PreMoveTo(m_vTargetPosition, m_BumpedBy.Location, 3);				
			}
			else
			{
				// End:0x1CF
				if(__NFUN_154__(int(m_r6pawn.m_ePawnType), int(1)))
				{
					R6PreMoveTo(m_vTargetPosition, m_BumpedBy.Location, 5);					
				}
				else
				{
					R6PreMoveTo(m_vTargetPosition, m_BumpedBy.Location, 4);
				}
			}
		}
	}
	__NFUN_500__(m_vTargetPosition, m_BumpedBy);
	Pawn.Acceleration = vect(0.0000000, 0.0000000, 0.0000000);
	m_fLastBump = Level.TimeSeconds;
Wait:


	__NFUN_256__(0.2000000);
	// End:0x241
	if(IsBumpBackUpStateFinish())
	{
		goto 'Finish';		
	}
	else
	{
		goto 'Wait';
	}
	J0x247:

	// End:0x27A
	if(__NFUN_255__(m_bumpBackUpNextState, 'None'))
	{
		// End:0x270
		if(__NFUN_254__(m_bumpBackUpNextState, 'ApproachLadder'))
		{
			MoveTarget = m_TargetLadder;
		}
		__NFUN_113__(m_bumpBackUpNextState);		
	}
	else
	{
		BumpBackUpStateFinished();
	}
	J0x280:

	m_r6pawn.m_bAvoidFacingWalls = false;
	__NFUN_267__(Pawn.Location);
	m_vTargetPosition = R6IORotatingDoor(m_BumpedBy).GetTarget(Pawn, 225.0000000, true);
	R6PreMoveTo(m_vTargetPosition, Location, m_r6pawn.m_eMovementPace);
	__NFUN_500__(m_vTargetPosition, self);
	Pawn.Acceleration = vect(0.0000000, 0.0000000, 0.0000000);
	// End:0x324
	if(__NFUN_254__(m_bumpBackUpNextState, 'OpenDoor'))
	{
		__NFUN_256__(0.2000000);		
	}
	else
	{
		__NFUN_256__(1.0000000);
	}
	goto 'Finish';
BackupFromActor:


	m_r6pawn.m_bAvoidFacingWalls = false;
	__NFUN_267__(Pawn.Location);
	m_vTargetPosition = __NFUN_216__(Pawn.Location, __NFUN_213__(float(120), __NFUN_226__(__NFUN_216__(m_BumpedBy.Location, Pawn.Location))));
	m_vTargetPosition.Z = Pawn.Location.Z;
	R6PreMoveTo(m_vTargetPosition, Location, m_r6pawn.m_eMovementPace);
	__NFUN_500__(m_vTargetPosition, self);
	Pawn.Acceleration = vect(0.0000000, 0.0000000, 0.0000000);
	__NFUN_256__(1.0000000);
	goto 'Finish';
	stop;				
}

state OpenDoor
{
	function BeginState()
	{
		return;
	}

	function EndState()
	{
		return;
	}

    //------------------------------------------------------------------
    // NeedToMove: return true if the pawn need to move at the best spot 
    //  to open the rotatingDoor. the destination is passed in vDest.
    //------------------------------------------------------------------
	function bool NeedToMove(out Vector vDest)
	{
		local Vector vDoorLoc, vSpotToGo;

		// End:0x16
		if(__NFUN_114__(m_r6pawn.m_Door, none))
		{
			return false;
		}
		vDoorLoc = m_r6pawn.m_Door.m_RotatingDoor.GetTarget(Pawn, 0.0000000, true);
		vSpotToGo = m_r6pawn.m_Door.m_RotatingDoor.GetTarget(Pawn, 75.0000000, true);
		vDest = vSpotToGo;
		return true;
		return;
	}

    // so the pawn won't collide with door
	function int GetFurthestOffsetFromDoor(Actor Actor)
	{
		return int(__NFUN_174__(__NFUN_174__(float(128), Actor.CollisionRadius), float(10)));
		return;
	}
Begin:

	// End:0x1A
	if(__NFUN_114__(m_r6pawn.m_Door, none))
	{
		goto 'End';
	}
	// End:0x6D
	if(__NFUN_132__(__NFUN_242__(m_r6pawn.m_Door.m_RotatingDoor.m_bIsDoorClosed, false), m_r6pawn.m_Door.m_RotatingDoor.m_bInProcessOfOpening))
	{
		goto 'End';
	}
	// End:0xC9
	if(NeedToMove(m_vTargetPosition))
	{
		__NFUN_267__(Pawn.Location);
		R6PreMoveTo(m_vTargetPosition, Location, m_r6pawn.m_eMovementPace);
		__NFUN_2201__(m_vTargetPosition, m_r6pawn.m_Door.Rotation);
	}
	ChangeOrientationTo(m_r6pawn.m_Door.Rotation);
	__NFUN_508__();
	// End:0x13C
	if(__NFUN_132__(__NFUN_242__(m_r6pawn.m_Door.m_RotatingDoor.m_bIsDoorClosed, false), m_r6pawn.m_Door.m_RotatingDoor.m_bInProcessOfOpening))
	{
		goto 'End';
	}
	// End:0x180
	if(m_r6pawn.m_Door.m_RotatingDoor.m_bIsDoorLocked)
	{
		m_r6pawn.SetNextPendingAction(4, 1);
		__NFUN_261__(m_r6pawn.16);
	}
	m_r6pawn.SetNextPendingAction(4, 0);
	__NFUN_256__(0.5000000);
	// End:0x1B4
	if(__NFUN_114__(m_r6pawn.m_Door, none))
	{
		goto 'CloseDoor';
	}
	// End:0x295
	if(__NFUN_129__(m_r6pawn.m_Door.m_RotatingDoor.ActorIsOnSideA(Pawn)))
	{
		m_vTargetPosition = m_r6pawn.m_Door.m_RotatingDoor.GetTarget(Pawn, float(GetFurthestOffsetFromDoor(Pawn)), true);
		__NFUN_267__(Pawn.Location);
		R6PreMoveTo(m_vTargetPosition, Location, m_r6pawn.m_eMovementPace);
		m_r6pawn.m_Door.m_RotatingDoor.OpenDoor(m_r6pawn, 10000);
		__NFUN_2201__(m_vTargetPosition, m_r6pawn.m_Door.Rotation);		
	}
	else
	{
		m_r6pawn.m_Door.m_RotatingDoor.OpenDoor(m_r6pawn);
	}
	// End:0x32E
	if(m_r6pawn.m_Door.m_RotatingDoor.ActorIsOnSideA(Pawn))
	{
		// End:0x323
		if(__NFUN_130__(__NFUN_154__(int(m_r6pawn.m_ePawnType), int(3)), __NFUN_154__(int(m_r6pawn.m_eMovementPace), int(5))))
		{
			__NFUN_256__(0.5000000);			
		}
		else
		{
			__NFUN_256__(0.3000000);
		}		
	}
	else
	{
		// End:0x36D
		if(__NFUN_130__(__NFUN_154__(int(m_r6pawn.m_ePawnType), int(3)), __NFUN_154__(int(m_r6pawn.m_eMovementPace), int(5))))
		{
			__NFUN_256__(1.5000000);			
		}
		else
		{
			__NFUN_256__(1.0000000);
		}
	}
	// End:0x3C3
	if(__NFUN_119__(m_r6pawn.m_Door, none))
	{
		m_closeDoor = m_r6pawn.m_Door.m_RotatingDoor;
		m_r6pawn.RemovePotentialOpenDoor(m_r6pawn.m_Door);
	}
CloseDoor:


	// End:0x4EE
	if(__NFUN_130__(__NFUN_130__(__NFUN_130__(__NFUN_119__(m_closeDoor, none), __NFUN_154__(int(m_r6pawn.m_ePawnType), int(2))), __NFUN_155__(int(R6Terrorist(m_r6pawn).m_eDefCon), int(1))), __NFUN_132__(__NFUN_129__(m_closeDoor.m_bIsDoorClosed), m_closeDoor.m_bInProcessOfOpening)))
	{
		// End:0x46E
		if(__NFUN_129__(m_closeDoor.ActorIsOnSideA(Pawn)))
		{
			m_vTargetPosition = m_closeDoor.GetTarget(Pawn, 0.0000000);			
		}
		else
		{
			m_vTargetPosition = m_closeDoor.GetTarget(Pawn, float(GetFurthestOffsetFromDoor(Pawn)));
		}
		__NFUN_267__(Pawn.Location);
		R6PreMoveTo(m_vTargetPosition, Location, m_r6pawn.m_eMovementPace);
		__NFUN_2201__(m_vTargetPosition, m_r6pawn.Rotation);
		m_closeDoor.CloseDoor(m_r6pawn);
	}
	m_closeDoor = none;
End:


	__NFUN_113__(m_openDoorNextState);
	stop;			
}

state TestMakePathEnd
{
	function BeginState()
	{
		logX("begin: TestMakePathEnd");
		StopMoving();
		Enemy = none;
		return;
	}
	stop;
}

state TestMakePath
{
	function BeginState()
	{
		logX(__NFUN_168__("begin. Eneny =", string(Enemy.Name)));
		return;
	}

	function EnemyNotVisible()
	{
		// End:0x5C
		if(__NFUN_177__(__NFUN_175__(Level.TimeSeconds, LastSeenTime), float(20)))
		{
			logX("Not seen for at least 20 seconds. GotoState('')");
			__NFUN_113__('TestMakePathEnd');
		}
		return;
	}
ChooseDestination:

	// End:0x37
	if(__NFUN_129__(__NFUN_1810__()))
	{
		logX("Nowhere to run..., gotostate '' ");
		__NFUN_113__('TestMakePathEnd');
	}
RunToDestination:


	logX(__NFUN_112__("label RunToDestination.  Goal = ", string(RouteGoal)));
	__NFUN_1812__(m_r6pawn.m_eMovementPace, 'ReturnToPath', false);
	goto 'ChooseDestination';
ReturnToPath:


	__NFUN_1812__(m_r6pawn.m_eMovementPace, 'ReturnToPath', true);
	goto 'ChooseDestination';
	stop;	
}

state PA_Interaction
{
	event SeePlayer(Pawn seen)
	{
		// End:0x2D
		if(__NFUN_130__(m_r6pawn.m_bDontSeePlayer, R6Pawn(seen).m_bIsPlayer))
		{
			return;
		}
		// End:0x6F
		if(__NFUN_114__(m_InteractionObject.m_SeePlayerPawn, none))
		{
			m_InteractionObject.m_SeePlayerPawn = seen;
			// End:0x6F
			if(__NFUN_129__(m_bCantInterruptIO))
			{
				m_InteractionObject.StopInteractionWithEndingActions();
			}
		}
		return;
	}

	event HearNoise(float Loudness, Actor NoiseMaker, Actor.ENoiseType eType, optional Actor.ESoundType ESoundType)
	{
		// End:0x2D
		if(__NFUN_130__(m_r6pawn.m_bDontHearPlayer, R6Pawn(NoiseMaker).m_bIsPlayer))
		{
			return;
		}
		// End:0x97
		if(__NFUN_114__(m_InteractionObject.m_HearNoiseNoiseMaker, none))
		{
			m_InteractionObject.m_HearNoiseLoudness = Loudness;
			m_InteractionObject.m_HearNoiseNoiseMaker = NoiseMaker;
			m_InteractionObject.m_HearNoiseType = eType;
			// End:0x97
			if(__NFUN_129__(m_bCantInterruptIO))
			{
				m_InteractionObject.StopInteractionWithEndingActions();
			}
		}
		return;
	}

// Called when killed
	function PawnDied()
	{
		// End:0x46
		if(__NFUN_242__(m_InteractionObject.m_bPawnDied, false))
		{
			m_InteractionObject.m_bPawnDied = true;
			m_r6pawn.m_iTracedBone = 0;
			m_InteractionObject.StopInteraction();
		}
		return;
	}

	event AnimEnd(int Channel)
	{
		return;
	}

	event bool NotifyBump(Actor Other)
	{
		return true;
		return;
	}

	event EndState()
	{
		// End:0x17
		if(__NFUN_242__(m_bChangingState, true))
		{
			m_bChangingState = false;			
		}
		else
		{
			m_InteractionObject.StopInteractionWithEndingActions();
		}
		return;
	}
	stop;
}

state PA_StartInteraction extends PA_Interaction
{Begin:

	m_InteractionObject.FinishAction();
	stop;				
}

state PA_LookAt extends PA_Interaction
{Begin:

	m_r6pawn.__NFUN_2216__(m_ActorTarget.Location);
	m_InteractionObject.FinishAction();
	stop;		
}

state PA_Goto extends PA_Interaction
{
	event EndState()
	{
		StopMoving();
		super.EndState();
		return;
	}
Begin:

	__NFUN_500__(m_ActorTarget.Location);
	__NFUN_2201__(m_ActorTarget.Location, m_ActorTarget.Rotation);
	m_InteractionObject.FinishAction();
	stop;				
}

state PA_PlayAnim extends PA_Interaction
{Begin:

	m_r6pawn.R6PlayAnim(m_AnimName, 1.0000000);
	__NFUN_261__();
	m_InteractionObject.FinishAction();
	stop;				
}

state PA_LoopAnim extends PA_Interaction
{Begin:

	m_r6pawn.R6LoopAnim(m_AnimName, 1.0000000);
	// End:0x2C
	if(__NFUN_180__(m_fLoopAnimTime, 0.0000000))
	{
		stop;		
	}
	else
	{
		__NFUN_256__(m_fLoopAnimTime);
	}
	m_InteractionObject.FinishAction();
	stop;				
}

defaultproperties
{
	c_iDistanceBumpBackUp=80
	MinHitWall=-0.4000000
	bRotateToDesired=true
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var m_SubActionGoto
// REMOVED IN 1.60: var m_AttachPos
// REMOVED IN 1.60: var m_AttachRot
// REMOVED IN 1.60: function GotoClimbObjectState
// REMOVED IN 1.60: function FixLocationAfterClimbing
// REMOVED IN 1.60: function ClimbObjectStateFinished
