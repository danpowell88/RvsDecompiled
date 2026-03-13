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

void AR6AIController::AdjustFromWall(FVector HitNormal, AActor * HitActor)
{
	guard(AR6AIController::AdjustFromWall);

	// Only adjust when the AI has the appropriate flag set and is in a movement latent action
	if ((((BYTE*)this)[0x4ec] & 2) != 0)
	{
		INT LatentAction = *(INT*)(*(INT*)((BYTE*)this + 0xc) + 0x28);
		if (LatentAction == 0x1f5 || LatentAction == 0x1f7 || LatentAction == 0x25a)
		{
			// If hit actor is a rotating door and we have a pawn and a door reference
			if (HitActor != NULL && HitActor->IsA(AR6IORotatingDoor::StaticClass()) &&
				*(INT*)((BYTE*)this + 0x3d8) != 0 && *(INT*)((BYTE*)this + 0x3e0) != 0)
			{
				// TODO: Full implementation gets the door from m_Door (this+0x3e0),
				// calculates cross product of door-to-pawn direction with door rotation vector,
				// determines which side the pawn is on, and adjusts the AdjustLoc
				// to navigate around the door. Involves FUN_1000db10 and vtable dispatch.
				*(DWORD*)((BYTE*)this + 0x3a8) |= 0x40;
			}
		}
	}

	unguard;
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
	if (Target != NULL && Pawn != NULL)
		*(DWORD*)Result = ((AR6Pawn*)Pawn)->actorReachableFromLocation(Target, vLocation);
	else
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

	// DIVERGENCE: retail calls XLevel vtable[39] on vDestination before FindPath.
	// Exact semantics of this navigation helper are unknown; call is omitted.
	// When a target actor is given, path toward it using a zero origin;
	// otherwise path toward vDestination using the controller as anchor.
	FVector dest(0.f, 0.f, 0.f);
	AActor* pathGoal = aTarget ? aTarget : (AActor*)this;
	if (!aTarget)
		dest = vDestination;

	AActor* found = FindPath(dest, pathGoal, 0);
	MoveTarget = found;

	if (!found)
	{
		GetStateFrame()->LatentAction = 0;
		m_eMoveToResult = 2;
		return;
	}

	// Scan RouteCache for first empty or self-referential slot.
	INT i;
	for (i = 0; i <= 15; i++)
	{
		if (RouteCache[i] == NULL || RouteCache[i] == (AActor*)this)
			break;
	}
	// DIVERGENCE: Ghidra sets sentinel value 1 at the found slot before calling FollowPath.
	if (i <= 15)
		RouteCache[i] = (AActor*)1;

	FollowPath((enum eMovementPace)ePace, NAME_None, 0);
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

	m_eMoveToResult = 0;

	if (!Pawn)
	{
		m_eMoveToResult = 2;
		return;
	}

	FVector delta = VPosition - Pawn->Location;
	FLOAT dist = delta.Size();
	MoveTarget = NULL;
	Focus = NULL;

	// DIVERGENCE: clear unknown bitfield (bit 0x2000) at Pawn+0x3E0.
	*(DWORD*)((BYTE*)Pawn + 0x3E0) &= ~0x2000;
	// DIVERGENCE: copy unknown speed/state field from Pawn+0x3F8 to Pawn+0x3F4.
	*(INT*)((BYTE*)Pawn + 0x3F4) = *(INT*)((BYTE*)Pawn + 0x3F8);

	Pawn->setMoveTimer(dist);
	GetStateFrame()->LatentAction = 0x259;  // execPollMoveToPosition (601)

	Destination = VPosition;
	FocalPoint = Destination + rOrientation.Vector() * 200.0f;
	bAdjusting = 0;

	((AR6Pawn*)Pawn)->moveToPosition(Destination);
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

	if (Pawn != NULL)
	{
		FLOAT dX = Destination.X - pActor->Location.X;
		FLOAT dY = Destination.Y - pActor->Location.Y;
		FLOAT r = pActor->CollisionRadius;
		if (4.0f * r * r <= dX * dX + dY * dY)
		{
			*(INT*)Result = ((AR6Pawn*)Pawn)->PickActorAdjust(pActor);
			return;
		}
		*(INT*)Result = 0;
		INT latent = GetStateFrame()->LatentAction;
		if (latent == 0x25A || latent == 0x25B)  // PollFollowPath or PollFollowPathBlocked
			GetStateFrame()->LatentAction = 0x25B;
		else
			GetStateFrame()->LatentAction = 0;
	}
}

void AR6AIController::execPollFollowPath(FFrame& Stack, RESULT_DECL)
{
	// Poll — no bytecode params; called by VM during latent waits.
	// TODO: checks MoveTimer, calls vtable move, advances route cache via
	// SetDestinationToNextInCache, handles door-type waypoints (complex — see Ghidra)
}

void AR6AIController::execPollFollowPathBlocked(FFrame& Stack, RESULT_DECL)
{
	// Poll function — no bytecode params; called by VM each tick while latent wait is active.
	// If we have a pawn and there's a next cached waypoint, keep following (LatentAction = 602 = 0x25a).
	// Otherwise the path is exhausted or the pawn is gone, so clear the latent action.
	if (Pawn != NULL && SetDestinationToNextInCache())
		GetStateFrame()->LatentAction = 602; // EPOLL_FollowPathBlocked
	else
		GetStateFrame()->LatentAction = 0;
}

void AR6AIController::execPollMoveToPosition(FFrame& Stack, RESULT_DECL)
{
	if (!Pawn)
	{
		m_eMoveToResult = 2;
		GetStateFrame()->LatentAction = 0;
		return;
	}

	INT bSkipMainMove = 0;
	if (bAdjusting)
	{
		bAdjusting = (((AR6Pawn*)Pawn)->moveToPosition(AdjustLoc) == 0) ? 1 : 0;
		bSkipMainMove = bAdjusting;
	}
	if (!bSkipMainMove)
	{
		if (((AR6Pawn*)Pawn)->moveToPosition(Destination))
			GetStateFrame()->LatentAction = 0;
	}
	if (GetStateFrame()->LatentAction == 0 && m_eMoveToResult == 0)
		m_eMoveToResult = 2;
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
