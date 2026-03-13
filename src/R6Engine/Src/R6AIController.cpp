/*=============================================================================
	R6AIController.cpp
	AR6AIController — base R6 AI controller with pathfinding and door handling.
=============================================================================*/

#include "R6EnginePrivate.h"

IMPLEMENT_CLASS(AR6AIController)

IMPLEMENT_FUNCTION(AR6AIController, -1, execActorReachableFromLocation)
IMPLEMENT_FUNCTION(AR6AIController, -1, execCanWalkTo)
IMPLEMENT_FUNCTION(AR6AIController, -1, execFindGrenadeDirectionToHitActor)
IMPLEMENT_FUNCTION(AR6AIController, -1, execFindInvestigationPoint)
IMPLEMENT_FUNCTION(AR6AIController, -1, execFindNearbyWaitSpot)
IMPLEMENT_FUNCTION(AR6AIController, -1, execFindPlaceToFire)
IMPLEMENT_FUNCTION(AR6AIController, -1, execFindPlaceToTakeCover)
IMPLEMENT_FUNCTION(AR6AIController, -1, execFollowPath)
IMPLEMENT_FUNCTION(AR6AIController, -1, execFollowPathTo)
IMPLEMENT_FUNCTION(AR6AIController, -1, execGotoOpenDoorState)
IMPLEMENT_FUNCTION(AR6AIController, -1, execMakePathToRun)
IMPLEMENT_FUNCTION(AR6AIController, -1, execMoveToPosition)
IMPLEMENT_FUNCTION(AR6AIController, -1, execNeedToOpenDoor)
IMPLEMENT_FUNCTION(AR6AIController, -1, execPickActorAdjust)
IMPLEMENT_FUNCTION(AR6AIController, -1, execPollFollowPath)
IMPLEMENT_FUNCTION(AR6AIController, -1, execPollFollowPathBlocked)
IMPLEMENT_FUNCTION(AR6AIController, -1, execPollMoveToPosition)

// --- AR6AIController ---

void AR6AIController::AdjustFromWall(FVector, AActor *)
{
}

INT AR6AIController::CanHear(FVector, FLOAT, AActor *, enum ENoiseType, enum EPawnType)
{
	return 0;
}

INT AR6AIController::CanWalkTo(FVector, INT)
{
	return 0;
}

void AR6AIController::ClearActionSpot()
{
	guard(AR6AIController::ClearActionSpot);
	Pawn->clearPaths();
	for( AR6ActionSpot* Spot = Level->m_ActionSpotList; Spot; Spot = Spot->m_NextSpot )
	{
		Spot->m_bValidTarget = 0;
	}
	unguard;
}

AR6ActionSpot * AR6AIController::FindNearestActionSpot(FLOAT, FVector, INT (CDECL*)(AR6Pawn *, AR6ActionSpot *, struct STActionSpotCheck &), struct STActionSpotCheck &)
{
	return NULL;
}

void AR6AIController::FollowPath(enum eMovementPace Pace, FName Label, INT bResetIndex)
{
	if (Pawn == NULL)
		return;

	NextLabel = Label;

	if (bResetIndex == 0)
	{
		m_iCurrentRouteCache = -1;
	}
	else
	{
		UBOOL bFound = 0;
		if (Pawn->Anchor != RouteCache[m_iCurrentRouteCache])
		{
			m_iCurrentRouteCache++;
			while (m_iCurrentRouteCache < 16 && RouteCache[m_iCurrentRouteCache] != NULL && !bFound)
			{
				if (Pawn->Anchor == RouteCache[m_iCurrentRouteCache])
					bFound = 1;
				m_iCurrentRouteCache++;
			}
			if (RouteCache[m_iCurrentRouteCache] == NULL || m_iCurrentRouteCache > 15)
			{
				if (bFound)
					return;
				AActor* Path = FindPath(FVector(0,0,0), RouteGoal, 1);
				if (Path == NULL)
					return;
				m_iCurrentRouteCache = 0;
			}
		}
	}

	Pawn->bReducedSpeed = 0;
	Pawn->DesiredSpeed = Pawn->MaxDesiredSpeed;
	GetStateFrame()->LatentAction = 602;
	bAdjusting = 0;

	SetDestinationToNextInCache();

	INT MoveType = (INT)Pace;
	if (Pawn->m_eHealth == 1)
	{
		if (Pace == 3)
			MoveType = 2;
		else if (Pace == 5)
			MoveType = 4;
	}

	eventR6SetMovement((BYTE)MoveType);
	Pawn->moveToward(Destination, MoveTarget);
}

void AR6AIController::GotoOpenDoorState(AActor* NavPointToOpenFrom)
{
	guard(AR6AIController::GotoOpenDoorState);

	check(NavPointToOpenFrom->IsA(AR6Door::StaticClass()));

	// Tell pawn about the potential door to open
	m_r6pawn->eventPotentialOpenDoor((AR6Door*)NavPointToOpenFrom);

	// If pawn now has a door reference, verify we can open it
	if (m_r6pawn->m_Door != NULL)
	{
		AR6IORotatingDoor* RotDoor = m_r6pawn->m_Door->m_RotatingDoor;
		if (!eventCanOpenDoor(RotDoor))
		{
			m_r6pawn->eventRemovePotentialOpenDoor((AR6Door*)NavPointToOpenFrom);
			eventOpenDoorFailed();
			return;
		}
	}

	// Save current state name so we can return after the door is opened
	FName CurrentState = (StateFrame && StateFrame->StateNode) ? StateFrame->StateNode->GetFName() : NAME_None;
	if (CurrentState != m_openDoorNextState)
		m_openDoorNextState = CurrentState;

	m_closeDoor = NULL;

	// Transition to the OpenDoor state
	GotoState(FName(TEXT("OpenDoor"), FNAME_Find));
	GotoLabel(NAME_Begin);

	unguard;
}

INT AR6AIController::HearingCheck(FVector SourcePos, FVector TargetPos)
{
	guard(AR6AIController::HearingCheck);
	FCheckResult Hit(1.0f);
	XLevel->SingleLineCheck(Hit, Pawn, TargetPos, SourcePos, 0x40286, FVector(0,0,0));
	return Hit.Actor == NULL;
	unguard;
}

INT AR6AIController::NeedToOpenDoor(AActor* TestActor)
{
	guard(AR6AIController::NeedToOpenDoor);

	if (m_r6pawn->m_ePawnType == 1)
	{
		// Rainbow operative: check the pawn's associated door
		AR6Door* Door = m_r6pawn->m_Door;
		if (Door != NULL && Door->m_RotatingDoor->m_bIsDoorClosed)
		{
			FCheckResult Hit(1.0f);
			XLevel->SingleLineCheck(Hit, Pawn, TestActor->Location, Pawn->Location, 0xBF, FVector(0,0,0));
			if (Hit.Actor != NULL && Hit.Actor->IsA(AR6IORotatingDoor::StaticClass()))
				return 1;
		}
	}
	else if (TestActor != NULL && TestActor->IsA(AR6Door::StaticClass()))
	{
		// Non-rainbow: test if the actor itself is a closed door in our path
		AR6Door* Door = (AR6Door*)TestActor;
		if (!Door->m_RotatingDoor->m_bIsDoorClosed)
			return 0;
		if (Door->m_RotatingDoor->WillOpenOnTouch(m_r6pawn))
			return 0;

		FCheckResult Hit(1.0f);
		XLevel->SingleLineCheck(Hit, Pawn, TestActor->Location, Pawn->Location, 0xBF, FVector(0,0,0));
		if (Hit.Actor != NULL && Hit.Actor->IsA(AR6IORotatingDoor::StaticClass()))
			return 1;
		return 0;
	}

	return 0;

	unguard;
}

INT AR6AIController::SetDestinationToNextInCache()
{
	m_iCurrentRouteCache++;
	if (m_iCurrentRouteCache < 16 && RouteCache[m_iCurrentRouteCache] != NULL)
	{
		Pawn->DesiredSpeed = 1.0f;
		MoveTarget = RouteCache[m_iCurrentRouteCache];
		Destination = MoveTarget->Location;

		FVector Delta = Destination - Pawn->Location;
		FLOAT Dist = Delta.Size();
		Pawn->setMoveTimer(Dist);

		if (Focus == NULL)
			FocalPoint = Destination;

		return 1;
	}
	return 0;
}

DWORD AR6AIController::eventCanOpenDoor(AR6IORotatingDoor * A)
{
	struct {
		AR6IORotatingDoor * A;
		DWORD ReturnValue;
	} Parms;
	Parms.ReturnValue = 0;
	Parms.A = A;
	ProcessEvent(FindFunctionChecked(R6ENGINE_CanOpenDoor), &Parms);
	return Parms.ReturnValue;
}

void AR6AIController::eventOpenDoorFailed()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_OpenDoorFailed), NULL);
}

void AR6AIController::eventR6SetMovement(BYTE A)
{
	struct { BYTE A; } Parms;
	Parms.A = A;
	ProcessEvent(FindFunctionChecked(R6ENGINE_R6SetMovement), &Parms);
}

void AR6AIController::execActorReachableFromLocation(FFrame& Stack, RESULT_DECL)
{
	P_GET_OBJECT(AActor, Target);
	P_GET_STRUCT(FVector, vLocation);
	P_FINISH;
	*(DWORD*)Result = 0;
}

void AR6AIController::execCanWalkTo(FFrame& Stack, RESULT_DECL)
{
	P_GET_STRUCT(FVector, vDestination);
	P_GET_UBOOL(bDebug);
	P_FINISH;
	*(DWORD*)Result = CanWalkTo(vDestination, bDebug);
}

void AR6AIController::execFindGrenadeDirectionToHitActor(FFrame& Stack, RESULT_DECL)
{
	P_GET_OBJECT(AActor, aTarget);
	P_GET_STRUCT(FVector, vTargetLoc);
	P_GET_FLOAT(fGrenadeSpeed);
	P_FINISH;
	*(FRotator*)Result = FRotator(0,0,0);
}

void AR6AIController::execFindInvestigationPoint(FFrame& Stack, RESULT_DECL)
{
	P_GET_INT(iSearchIndex);
	P_GET_FLOAT(fMaxDistance);
	P_GET_UBOOL(bFromThreat);
	P_GET_STRUCT(FVector, vThreatLocation);
	P_FINISH;
	*(UObject**)Result = NULL;
}

void AR6AIController::execFindNearbyWaitSpot(FFrame& Stack, RESULT_DECL)
{
	P_GET_OBJECT(AActor, Node);
	P_GET_STRUCT_REF(FVector, vWaitLocation);
	P_FINISH;
	*vWaitLocation = FVector(0,0,0);
}

void AR6AIController::execFindPlaceToFire(FFrame& Stack, RESULT_DECL)
{
	P_GET_OBJECT(AActor, PTarget);
	P_GET_STRUCT(FVector, vDestination);
	P_GET_FLOAT(fMaxDistance);
	P_FINISH;
	*(UObject**)Result = NULL;
}

void AR6AIController::execFindPlaceToTakeCover(FFrame& Stack, RESULT_DECL)
{
	P_GET_STRUCT(FVector, vThreatLocation);
	P_GET_FLOAT(fMaxDistance);
	P_FINISH;
	*(UObject**)Result = NULL;
}

void AR6AIController::execFollowPath(FFrame& Stack, RESULT_DECL)
{
	P_GET_BYTE(ePace);
	P_GET_NAME(returnLabel);
	P_GET_UBOOL(bContinuePath);
	P_FINISH;
	FollowPath((enum eMovementPace)ePace, returnLabel, bContinuePath);
}

void AR6AIController::execFollowPathTo(FFrame& Stack, RESULT_DECL)
{
	P_GET_STRUCT(FVector, vDestination);
	P_GET_BYTE(ePace);
	P_GET_OBJECT(AActor, aTarget);
	P_FINISH;
}

void AR6AIController::execGotoOpenDoorState(FFrame& Stack, RESULT_DECL)
{
	P_GET_OBJECT(AActor, navPointToOpenFrom);
	P_FINISH;
	GotoOpenDoorState(navPointToOpenFrom);
}

void AR6AIController::execMakePathToRun(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
	*(DWORD*)Result = 0;
}

void AR6AIController::execMoveToPosition(FFrame& Stack, RESULT_DECL)
{
	P_GET_STRUCT(FVector, VPosition);
	P_GET_STRUCT(FRotator, rOrientation);
	P_FINISH;
}

void AR6AIController::execNeedToOpenDoor(FFrame& Stack, RESULT_DECL)
{
	P_GET_OBJECT(AActor, Target);
	P_FINISH;
	*(DWORD*)Result = NeedToOpenDoor(Target);
}

void AR6AIController::execPickActorAdjust(FFrame& Stack, RESULT_DECL)
{
	P_GET_OBJECT(AActor, pActor);
	P_FINISH;
	*(DWORD*)Result = 0;
}

void AR6AIController::execPollFollowPath(FFrame& Stack, RESULT_DECL)
{
	// Poll — no bytecode params; called by VM during latent waits
}

void AR6AIController::execPollFollowPathBlocked(FFrame& Stack, RESULT_DECL)
{
	// Poll — no bytecode params
}

void AR6AIController::execPollMoveToPosition(FFrame& Stack, RESULT_DECL)
{
	// Poll — no bytecode params
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
