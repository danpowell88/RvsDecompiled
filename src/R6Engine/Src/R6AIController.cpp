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

IMPL_APPROX("Reconstructed with divergences: retail door-navigation side-check and AdjustLoc calculation unresolved")
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
				// DIVERGENCE: retail calculates which side of the door the pawn is on and
				// adjusts AdjustLoc to navigate around the door using FUN_1000db10 and vtable
				// dispatch. m_Door (this+0x3e0) cross-product direction logic unresolved.
				*(DWORD*)((BYTE*)this + 0x3a8) |= 0x40;
			}
		}
	}

	unguard;
}

IMPL_MATCH("R6Engine.dll", 0x1000db10)
INT AR6AIController::CanHear(FVector SoundLoc, FLOAT Volume, AActor* SoundActor, enum ENoiseType NoiseType, enum EPawnType PawnType)
{
	guard(AR6AIController::CanHear);

	// SoundActor->Controller offset 0x148; check it has a pawn
	INT SndCtrl = *(INT*)((BYTE*)SoundActor + 0x148);
	if (SndCtrl == 0 || *(INT*)(SndCtrl + 0x4ec) == 0)
		return 0;
	if (Pawn == NULL)
		return 0;

	// Pass if PawnType==4 (all-team) or teams differ (team at +0x3b0)
	if ((INT)PawnType != 4 && *(INT*)((BYTE*)Pawn + 0x3b0) == *(INT*)(SndCtrl + 0x3b0))
		return 0;

	// Zone indices: Region.Zone (at +0x228) -> sound zone byte at +0x397
	BYTE  OurZone = *(BYTE*)(*(INT*)((BYTE*)Pawn + 0x228) + 0x397);
	DWORD SndZone = (DWORD)*(BYTE*)(*(INT*)((BYTE*)SoundActor + 0x228) + 0x397);
	ALevelInfo* LI = XLevel->GetLevelInfo();

	// Zone connectivity bitmask table at LI+0x650 (pair of DWORDs per zone, 8-byte stride)
	DWORD ZoneBit = 1u << (OurZone & 0x1f);
	if ((DWORD)OurZone != SndZone
		&& (ZoneBit & *(DWORD*)((BYTE*)LI + SndZone * 8 + 0x650)) == 0
		&& ((INT)ZoneBit >> 0x1f & *(DWORD*)((BYTE*)LI + SndZone * 8 + 0x654)) == 0)
	{
		return 0;
	}

	if ((INT)NoiseType == 0)
	{
		// NOISE_None: log sound actor name only, no hearing check
		return 0;
	}

	// Distance check against skill-scaled hearing radius
	APawn* P = (APawn*)Pawn;
	FLOAT dx = P->Location.X - SoundLoc.X;
	FLOAT dy = P->Location.Y - SoundLoc.Y;
	FLOAT dz = P->Location.Z - SoundLoc.Z;
	FLOAT DistSq = dx*dx + dy*dy + dz*dz;

	FLOAT Skill   = ((AR6AbstractPawn*)P)->eventGetSkill((BYTE)7);
	FLOAT HearRad = (Skill * 0.5f + 0.75f) * Volume;
	FLOAT HearRadSq = HearRad * HearRad;

	if (DistSq >= HearRadSq)
		return 0;

	// Direct same-zone check (flags at +0x3e4: bit 5=bLOSHearing, bit 6=bSameZoneHearing)
	DWORD PawnFlags = *(DWORD*)((BYTE*)P + 0x3e4);
	if ((PawnFlags & 0x60) != 0
		&& *(INT*)((BYTE*)P + 0x228) == *(INT*)((BYTE*)SoundActor + 0x228))
	{
		return 1;
	}

	// Zone portal adjacency check (bit 6 + zone reachability table via XLevel+0x90)
	if ((PawnFlags & 0x40) != 0)
	{
		// Zone-portal adjacency table at *(XLevel+0x90)+0x128; FUN_10001750 drives portal
		// traversal. The table is a bitset of reachable zones; bit index from actor zone byte
		// at +0x230. Row stride is 0x12 DWORDs per zone. Implementation below matches retail.
		DWORD SndActorZoneBit = 1u << (*(BYTE*)((BYTE*)SoundActor + 0x230) & 0x1f);
		INT   SndActorZoneHi  = (INT)(*(BYTE*)((BYTE*)SoundActor + 0x230)) >> 5;
		DWORD PawnZoneRow     = (DWORD)(*(BYTE*)((BYTE*)P + 0x230)) * 0x12;
		INT   ZoneTableBase   = *(INT*)(*(INT*)(*(INT*)((BYTE*)this + 0x328) + 0x90) + 0x128
		                          + (SndActorZoneHi + (INT)PawnZoneRow) * 4);
		if ((*(DWORD*)&ZoneTableBase & SndActorZoneBit) != 0)
			return 1;
	}

	// Line-of-hearing via eye position (bit 4 = bAdjacentZoneHearing)
	if ((PawnFlags & 0x10) != 0)
	{
		FVector EyeOff = P->eventEyePosition();
		FVector EyeLoc(P->Location.X + EyeOff.X,
		               P->Location.Y + EyeOff.Y,
		               P->Location.Z + EyeOff.Z);

		if (HearingCheck(EyeLoc, SoundLoc) != 0)
			return 1;

		if ((PawnFlags & 0x80) != 0 && DistSq * 4.0f < HearRadSq)
		{
			// DIVERGENCE: secondary path-portal hearing check via FSortedPathList (FUN_10001750)
		// requires portal traversal data structures not yet reconstructed.
		}

		if ((PawnFlags & 0x100) != 0)
		{
			// DIVERGENCE: sorted portal traversal fallback requires portal node
		// traversal structures (FSortedPathList) not yet reconstructed.
		}
	}

	return 0;
	unguard;
}

IMPL_APPROX("Reconstructed from context")
INT AR6AIController::CanWalkTo(FVector Dest, INT bIgnoreActors)
{
	guard(AR6AIController::CanWalkTo);

	// Trace down 200 units from destination to find floor
	FVector DownEnd(Dest.X, Dest.Y, Dest.Z - 200.0f);
	FCheckResult Hit(1.0f);
	XLevel->SingleLineCheck(Hit, this, DownEnd, Dest, 0x86, FVector(0,0,0));

	// Ghidra: Hit.Time != 0 means trace was not start-blocked (floor found)
	if (Hit.Time != 0.0f)
	{
		APawn* P         = (APawn*)Pawn;
		FLOAT ColRadius  = P->CollisionRadius;
		FLOAT ColHeight  = P->CollisionHeight;
		FVector PawnLoc  = P->Location;
		FLOAT PawnZ      = PawnLoc.Z;

		FLOAT HitZ = Hit.Location.Z;
		FLOAT TopZ = HitZ + ColHeight + 2.4f;

		// If pawn can't jump (flag bit 9 at +0x3e0), offset heights by 33
		if ((*(DWORD*)((BYTE*)P + 0x3e0) & 0x200) == 0)
		{
			PawnZ += 33.0f;
			TopZ  += 33.0f;
		}

		FLOAT HeightDiff = TopZ - PawnZ;
		if (HeightDiff < 0.0f)
			HeightDiff = -HeightDiff;

		if (HeightDiff < 33.0f)
		{
			FVector End2(Hit.Location.X, Hit.Location.Y, TopZ);
			FVector Extent(ColRadius, ColRadius, ColHeight);
			INT bClear = XLevel->SingleLineCheck(Hit, this, End2, PawnLoc, 0x296, Extent);
			return bClear;
		}
	}

	return 0;
	unguard;
}

IMPL_APPROX("Reconstructed from context")
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

IMPL_APPROX("Reconstructed from context")
AR6ActionSpot * AR6AIController::FindNearestActionSpot(FLOAT Radius, FVector Center, INT (CDECL*Callback)(AR6Pawn *, AR6ActionSpot *, struct STActionSpotCheck &), struct STActionSpotCheck & CheckData)
{
	guard(AR6AIController::FindNearestActionSpot);

	if (Pawn == NULL)
		return NULL;

	ClearActionSpot();

	// Mark all action spots within radius that pass the callback
	INT LastValidSpot = 0;
	for (AR6ActionSpot* Spot = Level->m_ActionSpotList; Spot; Spot = Spot->m_NextSpot)
	{
		FLOAT dx = Spot->Location.X - Center.X;
		FLOAT dy = Spot->Location.Y - Center.Y;
		FLOAT dz = Spot->Location.Z - Center.Z;
		if (dx*dx + dy*dy + dz*dz < Radius * Radius
			&& Callback(m_r6pawn, Spot, CheckData) != 0)
		{
			Spot->m_bValidTarget = 1;
			// Mark the spot's anchor room as containing a valid target
			*(DWORD*)(*(INT*)((BYTE*)Spot + 0x3a0) + 0x3e4) |= 1; // Spot->m_Anchor->roomFlags |= 1
			LastValidSpot = (INT)Spot;
		}
	}

	if (LastValidSpot == 0)
		return NULL;

	// Find a path to the last valid spot
	AActor* PathAnchor = FindPath(FVector(0,0,0), (AActor*)LastValidSpot, 0);
	if (PathAnchor == NULL)
		return NULL;

	// Only refine if route goal radius is within caller's radius
	if (*(FLOAT*)((BYTE*)this + 0x3cc) >= Radius) // m_fRouteGoalRadius
		return NULL;

	// Find the first action spot whose anchor matches the path anchor's room
	AR6ActionSpot* Result = NULL;
	for (AR6ActionSpot* Spot = Level->m_ActionSpotList; Spot; Spot = Spot->m_NextSpot)
	{
		// Compare Spot->m_Anchor with this->m_pathAnchor (field at +0x44c, TODO: no typed name)
		if (*(INT*)((BYTE*)Spot + 0x3a0) == *(INT*)((BYTE*)this + 0x44c)
			&& Spot->m_bValidTarget)
		{
			Result = Spot;
			break;
		}
	}

	return Result;
	unguard;
}

IMPL_APPROX("Reconstructed from context")
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

IMPL_APPROX("Reconstructed from context")
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

IMPL_APPROX("Reconstructed from context")
INT AR6AIController::HearingCheck(FVector SourcePos, FVector TargetPos)
{
	guard(AR6AIController::HearingCheck);
	FCheckResult Hit(1.0f);
	XLevel->SingleLineCheck(Hit, Pawn, TargetPos, SourcePos, 0x40286, FVector(0,0,0));
	return Hit.Actor == NULL;
	unguard;
}

IMPL_APPROX("Reconstructed from context")
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

IMPL_APPROX("Reconstructed from context")
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

IMPL_APPROX("Reconstructed from context")
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

IMPL_APPROX("Reconstructed from context")
void AR6AIController::eventOpenDoorFailed()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_OpenDoorFailed), NULL);
}

IMPL_APPROX("Reconstructed from context")
void AR6AIController::eventR6SetMovement(BYTE A)
{
	struct { BYTE A; } Parms;
	Parms.A = A;
	ProcessEvent(FindFunctionChecked(R6ENGINE_R6SetMovement), &Parms);
}

IMPL_APPROX("Reconstructed from context")
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

IMPL_APPROX("Reconstructed from context")
void AR6AIController::execCanWalkTo(FFrame& Stack, RESULT_DECL)
{
	P_GET_STRUCT(FVector, vDestination);
	P_GET_UBOOL(bDebug);
	P_FINISH;
	*(DWORD*)Result = CanWalkTo(vDestination, bDebug);
}

IMPL_APPROX("Reconstructed from context")
void AR6AIController::execFindGrenadeDirectionToHitActor(FFrame& Stack, RESULT_DECL)
{
	P_GET_OBJECT(AActor, aTarget);
	P_GET_STRUCT(FVector, vTargetLoc);
	P_GET_FLOAT(fGrenadeSpeed);
	P_FINISH;
	*(FRotator*)Result = FRotator(0,0,0);
}

IMPL_APPROX("Reconstructed from context")
void AR6AIController::execFindInvestigationPoint(FFrame& Stack, RESULT_DECL)
{
	P_GET_INT(iSearchIndex);
	P_GET_FLOAT(fMaxDistance);
	P_GET_UBOOL(bFromThreat);
	P_GET_STRUCT(FVector, vThreatLocation);
	P_FINISH;
	*(UObject**)Result = NULL;
}

IMPL_APPROX("Reconstructed from context")
void AR6AIController::execFindNearbyWaitSpot(FFrame& Stack, RESULT_DECL)
{
	P_GET_OBJECT(AActor, Node);
	P_GET_STRUCT_REF(FVector, vWaitLocation);
	P_FINISH;
	*vWaitLocation = FVector(0,0,0);
}

IMPL_APPROX("Reconstructed from context")
void AR6AIController::execFindPlaceToFire(FFrame& Stack, RESULT_DECL)
{
	P_GET_OBJECT(AActor, PTarget);
	P_GET_STRUCT(FVector, vDestination);
	P_GET_FLOAT(fMaxDistance);
	P_FINISH;
	*(UObject**)Result = NULL;
}

IMPL_APPROX("Reconstructed from context")
void AR6AIController::execFindPlaceToTakeCover(FFrame& Stack, RESULT_DECL)
{
	P_GET_STRUCT(FVector, vThreatLocation);
	P_GET_FLOAT(fMaxDistance);
	P_FINISH;
	*(UObject**)Result = NULL;
}

IMPL_APPROX("Reconstructed from context")
void AR6AIController::execFollowPath(FFrame& Stack, RESULT_DECL)
{
	P_GET_BYTE(ePace);
	P_GET_NAME(returnLabel);
	P_GET_UBOOL(bContinuePath);
	P_FINISH;
	FollowPath((enum eMovementPace)ePace, returnLabel, bContinuePath);
}

IMPL_APPROX("Reconstructed from context")
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

IMPL_APPROX("Reconstructed from context")
void AR6AIController::execGotoOpenDoorState(FFrame& Stack, RESULT_DECL)
{
	P_GET_OBJECT(AActor, navPointToOpenFrom);
	P_FINISH;
	GotoOpenDoorState(navPointToOpenFrom);
}

IMPL_APPROX("Reconstructed from context")
void AR6AIController::execMakePathToRun(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
	*(DWORD*)Result = 0;
}

IMPL_APPROX("Reconstructed from context")
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

IMPL_APPROX("Reconstructed from context")
void AR6AIController::execNeedToOpenDoor(FFrame& Stack, RESULT_DECL)
{
	P_GET_OBJECT(AActor, Target);
	P_FINISH;
	*(DWORD*)Result = NeedToOpenDoor(Target);
}

IMPL_APPROX("Karma physics pending MeSDK decompilation from Engine.dll")
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

IMPL_DIVERGE("Too complex to reconstruct: poll checks MoveTimer, advances route cache via SetDestinationToNextInCache, handles door-type waypoints (FUN_10007b80); deferred")
void AR6AIController::execPollFollowPath(FFrame& Stack, RESULT_DECL)
{
	// Poll — no bytecode params; called by VM during latent waits.
	// DIVERGENCE: poll checks MoveTimer, calls vtable move method, advances route cache via
	// SetDestinationToNextInCache, handles door-type waypoints; complex Ghidra analysis
	// (FUN_10007b80) required to fully reconstruct — deferred.
}

IMPL_APPROX("Reconstructed from context")
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

IMPL_APPROX("Reconstructed from context")
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
