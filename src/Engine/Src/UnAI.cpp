#pragma optimize("", off)
#include "EnginePrivate.h"
// --- AAIController ---
void AAIController::SetAdjustLocation(FVector NewLoc)
{
	bAdjusting = 1;
	AdjustLoc = NewLoc;
}

int AAIController::AcceptNearbyPath(AActor* Goal)
{
	if( Goal && Goal->IsA(ANavigationPoint::StaticClass()) )
		return 1;
	return 0;
}

void AAIController::AdjustFromWall(FVector NewAdjustLoc, AActor* HitActor)
{
	guard(AAIController::AdjustFromWall);

	// _NativeData[0] bit 1 = bAdjustFromWalls (AIController.uc); bail if not set.
	if (!(_NativeData[0] & 2))
		return;

	// Only active during MoveTo (AI_PollMoveTo=501) or MoveToward (AI_PollMoveToward=503)
	// latent executions.  FStateFrame::LatentAction lives at offset 0x28 in the frame.
	FStateFrame* Frame = GetStateFrame();
	if (Frame->LatentAction != AI_PollMoveTo && Frame->LatentAction != AI_PollMoveToward)
		return;

	if (Pawn && MoveTarget && HitActor && HitActor->IsA(AMover::StaticClass()))
	{
		// Virtual call at MoveTarget->vtable[0x15C/4 = 87], passing HitActor.
		// Exact function unknown; likely a path-blocking or mover-relevance query.
		// ECX = MoveTarget (__thiscall), stack arg = HitActor.
		typedef INT (__thiscall* VFn87)(AActor*, AActor*);
		VFn87 fn = (VFn87)(((DWORD**)MoveTarget)[0][0x15C / 4]);
		if (fn(MoveTarget, HitActor))
		{
			// FUN_1038ef90: returns MoveTarget if IsA(ANavigationPoint), else NULL.
			ANavigationPoint* NavPoint = MoveTarget->IsA(ANavigationPoint::StaticClass())
				? static_cast<ANavigationPoint*>(MoveTarget) : NULL;
			if (NavPoint && NavPoint->eventSuggestMovePreparation(Pawn))
				return;
		}
		eventNotifyHitMover(NewAdjustLoc, static_cast<AMover*>(HitActor));
		return;
	}

	// bAdjusting (AController bitfield bit 6 = 0x40 at 0x3A8): skip vel-negate
	// when the controller is already in the middle of a wall adjustment.
	if (!bAdjusting)
	{
		Pawn->Velocity.X = -Pawn->Velocity.X;
		Pawn->Velocity.Y = -Pawn->Velocity.Y;
		Pawn->Velocity.Z = -Pawn->Velocity.Z;
		if (Pawn->PickWallAdjust(NewAdjustLoc))
			return;
	}

	// Reset move timer so the next tick re-evaluates movement.
	// Ghidra: *(float*)(this+0x3BC) = 0xBF800000 (-1.0f); offset 0x3BC = MoveTimer.
	MoveTimer = -1.0f;

	unguard;
}


// --- AAIMarker ---
int AAIMarker::IsIdentifiedAs(FName Name)
{
	guard(AAIMarker::IsIdentifiedAs);
	FName fn1 = this->GetFName();
	if (Name == fn1) return 1;
	if (*(UObject**)((BYTE*)this + 0x3E8) != NULL)
	{
		FName fn2 = (*(UObject**)((BYTE*)this + 0x3E8))->GetFName();
		if (Name == fn2) return 1;
	}
	return 0;
	unguard;
}


void AAIScript::AddMyMarker(AActor* param_1)
{
	guard(AAIScript::AddMyMarker);

	// bNavigate (AIScript.uc) is bit 0 of the first byte of AAIScript native data
	// at offset 0x394 (immediately after the AActor base, which ends at 0x394).
	if (!(((BYTE*)this)[0x394] & 1))
		return;
	if (!param_1)
		return;
	if (!param_1->IsA(AScout::StaticClass()))
		return;

	AScout* Scout = static_cast<AScout*>(param_1);

	// Try to find a valid navigation start from the scout's current position.
	INT found = Scout->findStart(Scout->Location);

	// If findStart succeeded, check vertical proximity to this AIScript.
	// If the scout is within CollisionHeight of this actor's Z we can spawn
	// right here; otherwise reposition it first.
	FLOAT zDiff = Scout->Location.Z - Location.Z;
	if (zDiff < 0.0f) zDiff = -zDiff;

	if (!found || zDiff > Scout->CollisionHeight)
	{
		// Scout is not at a usable height.  Teleport it to a position at this
		// AIScript's XY with a Z adjusted for 40-unit clearance.
		// Ghidra: XLevel->vtable[0x9C/4 = 39] = FarMoveActor; args inferred from
		// local_2c/local_28/local_24 written to stack just before the call.
		FVector AdjDest(Location.X, Location.Y, (40.0f - CollisionHeight) + Location.Z);
		XLevel->FarMoveActor(Scout, AdjDest, 0, 1, 0, 0);
	}

	// Locate the AIMarker class and spawn one at the scout's current position.
	// Ghidra: XLevel->vtable[0xA8/4 = 42] = SpawnActor.
	UClass* AIMarkerClass = static_cast<UClass*>(
		UObject::StaticFindObjectChecked(UClass::StaticClass(), (UObject*)-1, TEXT("AIMarker"), 0));

	AActor* Spawned = XLevel->SpawnActor(AIMarkerClass, NAME_None, Scout->Location);
	if (Spawned && !Spawned->IsA(AAIMarker::StaticClass()))
		Spawned = NULL;

	// this->myMarker (AIScript.uc) at offset 0x398 from object start.
	*(AAIMarker**)((BYTE*)this + 0x398) = static_cast<AAIMarker*>(Spawned);

	// marker->markedScript (AIMarker.uc) at offset 0x3E8 (= 1000 decimal) from
	// the AAIMarker object start.
	if (Spawned)
		*(AAIScript**)((BYTE*)Spawned + 0x3E8) = this;

	unguard;
}


