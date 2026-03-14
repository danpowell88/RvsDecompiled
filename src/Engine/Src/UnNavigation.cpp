#pragma optimize("", off)
#include "EnginePrivate.h"
// --- AJumpDest ---
void AJumpDest::SetupForcedPath(APawn* Scout, UReachSpec* Spec)
{
	guard(AJumpDest::SetupForcedPath);
	// Retail 0xd67a0, 117B.
	// AJumpDest-specific fields after ANavigationPoint (starting at +0x3E8):
	//   +0x3E8: INT NumForcedPaths
	//   +0x3EC: UReachSpec*[8] ForcedPathSpecs
	//   +0x40C: FVector[8] ForcedPathVelocities (12 bytes each)
	INT& count = *(INT*)((BYTE*)this + 0x3E8);
	if (count > 7)
	{
		GWarn->Logf(TEXT("More than 8 paths to this JumpDest!"));
		return;
	}
	FLOAT* vel = (FLOAT*)((BYTE*)this + count * 0xC + 0x40C);
	vel[0] = 0.0f;
	vel[1] = 0.0f;
	vel[2] = 474.0f;  // 0x43e70000 — default Z velocity
	*(FLOAT*)((BYTE*)Scout + 0x43C) = 10000.0f;  // Scout MaxStepHeight (0x461C4000)
	Scout->SetCollisionSize(40.0f, 85.0f);
	if (XLevel->FarMoveActor(Scout, Spec->Start->Location, 0, 0, 0, 0))  // move to Start, not End
	{
		FVector jv = Scout->SuggestJumpVelocity(Location, 600.0f, 0.0f);
		vel = (FLOAT*)((BYTE*)this + count * 0xC + 0x40C);
		vel[0] = jv.X;
		vel[1] = jv.Y;
		vel[2] = jv.Z;
	}
	*(FLOAT*)((BYTE*)Scout + 0x43C) = 424.0f;  // 0x43d20000 — restore MaxStepHeight
	*(UReachSpec**)((BYTE*)this + count * 4 + 0x3EC) = Spec;
	count++;
	unguard;
}

void AJumpDest::ClearPaths()
{
	// Ghidra 0xd69e0, 24B. Call base, then zero the path-count field at +0x3E8.
	ANavigationPoint::ClearPaths();
	*(DWORD*)((BYTE*)this + 0x3E8) = 0; // NumPaths / jump-destination counter
}


// --- AJumpPad ---
void AJumpPad::addReachSpecs(APawn* Scout, int bOnlyChanged)
{
	guard(AJumpPad::addReachSpecs);
	// Retail 0xd8520
	ANavigationPoint::addReachSpecs(Scout, bOnlyChanged);
	*(FLOAT*)((BYTE*)Scout + 0x43C) = 10000.0f;  // MaxStepHeight = big value
	Scout->SetCollisionSize(40.0f, 85.0f);

	TArray<UReachSpec*>* pathList = (TArray<UReachSpec*>*)((BYTE*)this + 0x3D8);
	if (pathList->Num() > 0 && XLevel->FarMoveActor(Scout, Location, 0, 0, 0, 0))
	{
		ANavigationPoint* dest = (*pathList)(0)->End;
		*(ANavigationPoint**)((BYTE*)this + 0x3E8) = dest;  // JumpDest

		FVector jv = Scout->SuggestJumpVelocity(dest->Location, 600.0f, 0.0f);
		*(FLOAT*)((BYTE*)this + 0x3EC) = jv.X;  // JumpVelocity.X
		*(FLOAT*)((BYTE*)this + 0x3F0) = jv.Y;  // JumpVelocity.Y
		*(FLOAT*)((BYTE*)this + 0x3F4) = jv.Z;  // JumpVelocity.Z

		// Scale X/Y components by dist2D/tFlight; Z gets 210 added
		FLOAT dx = Location.X - dest->Location.X;
		FLOAT dy = Location.Y - dest->Location.Y;
		FLOAT dist2D = appSqrt(dx*dx + dy*dy);
		FLOAT tFlight = 420.0f / (Level->TimeDilation * -0.5f);
		FLOAT scale = dist2D / tFlight;
		*(FLOAT*)((BYTE*)this + 0x3EC) = jv.X * scale;
		*(FLOAT*)((BYTE*)this + 0x3F0) = jv.Y * scale;
		*(FLOAT*)((BYTE*)this + 0x3F4) = jv.Z + 210.0f;
	}
	else
	{
		GWarn->Logf(TEXT("No forced destination for this jumppad!"));
		*(FLOAT*)((BYTE*)this + 0x3EC) = 0.0f;
		*(FLOAT*)((BYTE*)this + 0x3F0) = 0.0f;
		*(FLOAT*)((BYTE*)this + 0x3F4) = 1260.0f;  // 0x449D8000
	}

	*(FLOAT*)((BYTE*)Scout + 0x43C) = 424.0f;  // restore MaxStepHeight (0x43D20000)
	unguard;
}


// --- ALadder ---
void ALadder::addReachSpecs(APawn* Scout, int bOnlyChanged)
{
	guard(ALadder::addReachSpecs);
	// Retail 0xd7b00

	UObject* outer = XLevel->GetOuter();
	UReachSpec* spec = (UReachSpec*)UObject::StaticConstructObject(UReachSpec::StaticClass(), outer, NAME_None, 0, NULL, GError, 0);

	// Toggle bit 0x800 (bOnlyLift) in bitfield at +0x3A4 based on bOnlyChanged:
	// if fully rebuilding (bOnlyChanged==0) always set; if partial, keep existing value
	DWORD uVar1 = *(DWORD*)((BYTE*)this + 0x3A4);
	INT iVar3 = ((uVar1 & 0x800) == 0 && bOnlyChanged != 0) ? 0 : 1;
	*(DWORD*)((BYTE*)this + 0x3A4) = ((DWORD)(iVar3 << 11) ^ uVar1) & 0x800u ^ uVar1;

	ALadderVolume* myLadder = *(ALadderVolume**)((BYTE*)this + 0x3E8);
	if (myLadder)
	{
		for (INT i = 0; i < XLevel->Actors.Num(); i++)
		{
			AActor* actor = XLevel->Actors(i);
			if (!actor) continue;
			if (!actor->IsA(ALadder::StaticClass())) continue;
			if (actor == this) continue;

			ALadder* otherLadder = (ALadder*)actor;
			// Only connect ladders that share the same LadderVolume
			if (*(ALadderVolume**)((BYTE*)otherLadder + 0x3E8) != myLadder) continue;
			// At least one endpoint must have bOnlyLift set
			DWORD thisFlags  = *(DWORD*)((BYTE*)this        + 0x3A4);
			DWORD otherFlags = *(DWORD*)((BYTE*)otherLadder + 0x3A4);
			if (!(thisFlags & 0x800) && !(otherFlags & 0x800)) continue;

			spec->Init();
			spec->CollisionRadius = 40;
			spec->CollisionHeight = 85;
			spec->reachFlags      = 64;   // R_LADDER
			spec->Start           = this;
			spec->End             = otherLadder;
			FVector delta         = Location - otherLadder->Location;
			spec->Distance        = appRound(delta.Size());

			TArray<UReachSpec*>* pl = (TArray<UReachSpec*>*)((BYTE*)this + 0x3D8);
			INT idx = pl->Add(1);
			(*pl)(idx) = spec;

			// Allocate a fresh spec for the next connection
			outer = XLevel->GetOuter();
			spec  = (UReachSpec*)UObject::StaticConstructObject(UReachSpec::StaticClass(), outer, NAME_None, 0, NULL, GError, 0);
		}
	}

	ANavigationPoint::addReachSpecs(Scout, bOnlyChanged);

	// Prune specs that represent a downward jump (falling off the ladder)
	TArray<UReachSpec*>* pathList = (TArray<UReachSpec*>*)((BYTE*)this + 0x3D8);
	for (INT i = 0; i < pathList->Num(); i++)
	{
		UReachSpec* s = (*pathList)(i);
		if (!s) continue;
		if (!(s->reachFlags & 8)) continue;  // only R_JUMP specs
		if (s->End->Location.Z < s->Start->Location.Z - s->Start->CollisionHeight)
			s->bPruned = 1;
	}
	unguard;
}

int ALadder::ProscribedPathTo(ANavigationPoint * Nav)
{
	// Ghidra 0xd7130, 131B: if Nav is ALadder with same MyLadder ptr, proscribed
	if (Nav)
	{
		if (Nav->IsA(ALadder::StaticClass()))
		{
			if (*(INT*)((BYTE*)this + 0x3E8) == *(INT*)((BYTE*)Nav + 0x3E8))
				return 1;
		}
	}
	return ANavigationPoint::ProscribedPathTo(Nav);
}

void ALadder::ClearPaths()
{
	// Ghidra 0xd6a60, 90B: call base, clear ladder reference, zero pointers
	ANavigationPoint::ClearPaths();
	INT* MyLadder = (INT*)((BYTE*)this + 0x3E8);
	if (*MyLadder != 0)
		*(INT*)(*MyLadder + 0x47c) = 0;
	*(INT*)((BYTE*)this + 0x3ec) = 0;
	*MyLadder = 0;
}

void ALadder::InitForPathFinding()
{
	guard(ALadder::InitForPathFinding);
	// Retail 0xd81f0

	*(ALadderVolume**)((BYTE*)this + 0x3E8) = NULL;  // MyLadder = NULL

	for (INT i = 0; i < XLevel->Actors.Num(); i++)
	{
		AActor* actor = XLevel->Actors(i);
		if (!actor) continue;
		if (!actor->IsA(ALadderVolume::StaticClass())) continue;

		ALadderVolume* volume = (ALadderVolume*)actor;
		// Check if this ladder's base or top is inside the volume
		if (volume->Encompasses(Location) ||
		    volume->Encompasses(FVector(Location.X, Location.Y, Location.Z - CollisionHeight)))
		{
			*(ALadderVolume**)((BYTE*)this + 0x3E8) = volume;
			break;
		}
	}

	ALadderVolume* myLadder = *(ALadderVolume**)((BYTE*)this + 0x3E8);
	if (myLadder)
	{
		// Prepend this ladder to the volume's linked list
		*(ALadder**)((BYTE*)this     + 0x3EC) = *(ALadder**)((BYTE*)myLadder + 0x47C);  // NextLadder = head
		*(ALadder**)((BYTE*)myLadder + 0x47C) = this;                                    // head = this
	}
	else
	{
		GWarn->Logf(TEXT("Ladder is not in a LadderVolume"));
	}
	unguard;
}


// --- ALadderVolume ---
void ALadderVolume::RenderEditorInfo(FLevelSceneNode* SceneNode, FRenderInterface* RI, FDynamicActor* DA)
{
	guard(ALadderVolume::RenderEditorInfo);
	// Retail 0x10d250
	AActor::RenderEditorInfo(SceneNode, RI, DA);

	// colorSrc is an object pointer stored as INT at levelOuter+0x2C
	UObject* levelOuter = *(UObject**)((BYTE*)SceneNode + 4);
	levelOuter = levelOuter->GetOuter();
	BYTE* colorSrc = (BYTE*)(DWORD)(*(INT*)((BYTE*)levelOuter + 0x2C));

	FLineBatcher batcher(RI, 1, 0);
	FVector center = FindCenter();
	batcher.DrawDirectionalArrow(
		center,
		FRotator(*(INT*)((BYTE*)this + 0x48C), *(INT*)((BYTE*)this + 0x490), *(INT*)((BYTE*)this + 0x494)),
		*(FColor*)(colorSrc + 0xF4),
		*(FLOAT*)((BYTE*)this + 0xE0)
	);
	unguard;
}

void ALadderVolume::AddMyMarker(AActor* Actor)
{
	guard(ALadderVolume::AddMyMarker);
	// Not present in Ghidra exports; intentionally empty
	unguard;
}

FVector ALadderVolume::FindCenter()
{
	return FVector(0,0,0);
}

FVector ALadderVolume::FindTop(FVector)
{
	return FVector(0,0,0);
}


// --- ALiftCenter ---
void ALiftCenter::addReachSpecs(APawn* Scout, int bOnlyChanged)
{
	guard(ALiftCenter::addReachSpecs);
	// Retail 0xd75f0

	// Toggle bit 0x800 (bOnlyLift) based on bOnlyChanged (same logic as ALadder)
	DWORD uVar10 = *(DWORD*)((BYTE*)this + 0x3A4);
	INT  iVar4  = ((uVar10 & 0x800) == 0 && bOnlyChanged != 0) ? 0 : 1;
	*(DWORD*)((BYTE*)this + 0x3A4) = ((DWORD)(iVar4 << 11) ^ uVar10) & 0x800u ^ uVar10;

	// Resolve MyLift from the Base actor (AActor::Base at +0x15C)
	AActor* baseActor = *(AActor**)((BYTE*)this + 0x15C);
	if (baseActor && baseActor->IsA(AMover::StaticClass()))
		*(AActor**)((BYTE*)this + 0x3EC) = baseActor;
	else
		*(AActor**)((BYTE*)this + 0x3EC) = NULL;

	if (*(AActor**)((BYTE*)this + 0x3EC) == NULL)
	{
		FindBase();
		baseActor = *(AActor**)((BYTE*)this + 0x15C);
		if (baseActor && baseActor->IsA(AMover::StaticClass()))
			*(AActor**)((BYTE*)this + 0x3EC) = baseActor;
		else
			*(AActor**)((BYTE*)this + 0x3EC) = NULL;

		if (*(AActor**)((BYTE*)this + 0x3EC) == NULL)
		{
			GWarn->Logf(TEXT("ALiftCenter has no mover!"));
			// Intentionally fall through to spec building (no mover case)
		}
	}

	AMover* MyLift = *(AMover**)((BYTE*)this + 0x3EC);
	if (MyLift)
	{
		// Warn if mover still has the class-default tag
		AActor* defaultActor = AMover::StaticClass()->GetDefaultActor();
		if (MyLift->Tag == defaultActor->Tag)
			GWarn->Logf(TEXT("LiftCenter mover has default tag!"));
	}

	// Build reach specs connecting this LiftCenter to all matching LiftExits
	UObject* outer = XLevel->GetOuter();
	UReachSpec* spec = (UReachSpec*)UObject::StaticConstructObject(UReachSpec::StaticClass(), outer, NAME_None, 0, NULL, GError, 0);

	INT foundExit = 0;
	for (INT i = 0; i < XLevel->Actors.Num(); i++)
	{
		AActor* actor = XLevel->Actors(i);
		if (!actor) continue;
		if (!actor->IsA(ALiftExit::StaticClass())) continue;

		// LiftTag matching: ALiftExit::LiftTag at +0x3F0, ALiftCenter::LiftTag at +0x3F4
		FName exitLiftTag = *(FName*)((BYTE*)actor + 0x3F0);
		FName thisLiftTag = *(FName*)((BYTE*)this  + 0x3F4);
		if (!(exitLiftTag == thisLiftTag)) continue;

		// At least one of center/exit must have bOnlyLift set
		DWORD exitFlags = *(DWORD*)((BYTE*)actor + 0x3A4);
		DWORD thisFlags = *(DWORD*)((BYTE*)this  + 0x3A4);
		if (!(thisFlags & 0x800) && !(exitFlags & 0x800)) continue;

		foundExit++;
		// Share our mover reference with the exit
		*(AMover**)((BYTE*)actor + 0x3EC) = MyLift;

		// Center -> Exit spec
		spec->Init();
		spec->CollisionRadius = 40;
		spec->CollisionHeight = 85;
		spec->reachFlags      = 32;   // REACHSPEC_LIFT
		spec->Start           = this;
		spec->End             = (ANavigationPoint*)actor;
		spec->Distance        = 500;
		TArray<UReachSpec*>* pathList = (TArray<UReachSpec*>*)((BYTE*)this + 0x3D8);
		INT idx = pathList->Add(1);
		(*pathList)(idx) = spec;

		outer = XLevel->GetOuter();
		spec  = (UReachSpec*)UObject::StaticConstructObject(UReachSpec::StaticClass(), outer, NAME_None, 0, NULL, GError, 0);

		// Exit -> Center spec
		spec->Init();
		spec->CollisionRadius = 40;
		spec->CollisionHeight = 85;
		spec->reachFlags      = 32;
		spec->Start           = (ANavigationPoint*)actor;
		spec->End             = this;
		spec->Distance        = 500;
		TArray<UReachSpec*>* exitPathList = (TArray<UReachSpec*>*)((BYTE*)actor + 0x3D8);
		idx = exitPathList->Add(1);
		(*exitPathList)(idx) = spec;

		outer = XLevel->GetOuter();
		spec  = (UReachSpec*)UObject::StaticConstructObject(UReachSpec::StaticClass(), outer, NAME_None, 0, NULL, GError, 0);

		// Determine which mover keyframe the exit aligns with
		BYTE keyIndex = *(BYTE*)((BYTE*)actor + 0x3E8);
		if (keyIndex != 0xFF)
		{
			*(BYTE*)((BYTE*)actor + 0x3E9) = keyIndex;
			continue;
		}

		// No pre-stored key: find the best keyframe via proximity + line check
		MyLift = *(AMover**)((BYTE*)this + 0x3EC);
		if (!MyLift) continue;

		INT   bestKey  = -1;
		FLOAT bestDist = 1.0e6f;
		BYTE  numKeys  = *(BYTE*)((BYTE*)MyLift + 0x399);
		for (INT k = 0; k < (INT)numKeys; k++)
		{
			FLOAT* kp = (FLOAT*)((BYTE*)MyLift + 0x430 + k * 0xC);
			// World position of this keyframe = mover base + LiftOffset + keyframe delta
			FLOAT wx = kp[0] + MyLift->Location.X + *(FLOAT*)((BYTE*)this + 0x3FC);
			FLOAT wy = kp[1] + MyLift->Location.Y + *(FLOAT*)((BYTE*)this + 0x400);
			FLOAT wz = kp[2] + MyLift->Location.Z + *(FLOAT*)((BYTE*)this + 0x404);

			FLOAT dz = wz - actor->Location.Z;
			if (dz < 0.0f) dz = -dz;
			if (dz >= 33.0f) continue;  // too far vertically

			FLOAT dx2 = wx - actor->Location.X;
			FLOAT dy2 = wy - actor->Location.Y;
			FLOAT d2D = appSqrt(dx2*dx2 + dy2*dy2);
			if (d2D >= bestDist) continue;

			// Verify line of sight between exit and candidate key position
			FCheckResult hit(1.0f);
			FVector extent(CollisionRadius, CollisionRadius, 0.0f);
			FVector endPos(wx, wy, wz);
			XLevel->SingleLineCheck(hit, actor, endPos, actor->Location, 0x86, extent);
			if (hit.Time == 1.0f)  // no obstruction
			{
				bestKey  = k;
				bestDist = d2D;
			}
		}

		if (bestKey >= 0)
			*(BYTE*)((BYTE*)actor + 0x3E9) = (BYTE)bestKey;
		else
			GWarn->Logf(TEXT("LiftCenter: could not find valid keyframe for LiftExit!"));
	}

	if (foundExit == 0)
		GWarn->Logf(TEXT("No LiftExit found for this LiftCenter!"));
	unguard;
}

void ALiftCenter::FindBase()
{
	guard(ALiftCenter::FindBase);
	// Retail 0xd8780 — editor-only; sets MyLift from actors whose Tag matches LiftTag
	if (!GIsEditor) return;

	FName thisLiftTag = *(FName*)((BYTE*)this + 0x3F4);
	if (thisLiftTag == FName(NAME_None)) return;

	for (INT i = 0; i < XLevel->Actors.Num(); i++)
	{
		AActor* actor = XLevel->Actors(i);
		if (!actor) continue;
		if (!(actor->Tag == thisLiftTag)) continue;

		AMover* mover = actor->IsA(AMover::StaticClass()) ? (AMover*)actor : NULL;
		*(AMover**)((BYTE*)this + 0x3EC) = mover;  // MyLift
		if (mover)
		{
			*(ALiftCenter**)((BYTE*)mover + 0x3FC) = this;  // mover->LiftCenter = this
			SetBase(mover, FVector(0.0f, 0.0f, 1.0f), 1);
			mover = *(AMover**)((BYTE*)this + 0x3EC);  // reload in case SetBase changed it
			// Cache our offset from the mover's current position
			*(FLOAT*)((BYTE*)this + 0x3FC) = Location.X - mover->Location.X;
			*(FLOAT*)((BYTE*)this + 0x400) = Location.Y - mover->Location.Y;
			*(FLOAT*)((BYTE*)this + 0x404) = Location.Z - mover->Location.Z;
			return;
		}
	}
	unguard;
}


// --- ALineOfSightTrigger ---
void ALineOfSightTrigger::TickAuthoritative(FLOAT DeltaTime)
{
	guard(ALineOfSightTrigger::TickAuthoritative);
	// Retail 0xc4670
	AActor::TickAuthoritative(DeltaTime);

	DWORD  flags        = *(DWORD*)((BYTE*)this + 0x398);
	UBOOL bEnabled     = (flags & 1) != 0;
	UBOOL bTriggered   = (flags & 2) != 0;
	AActor* triggerActor = *(AActor**)((BYTE*)this + 0x3A8);
	FLOAT sightRange   = *(FLOAT*)((BYTE*)this + 0x39C);
	FLOAT lastSightTime = *(FLOAT*)((BYTE*)this + 0x3A0);
	FLOAT sightDot     = *(FLOAT*)((BYTE*)this + 0x3A4);

	if (bEnabled && !bTriggered && triggerActor &&
	    lastSightTime <= *(FLOAT*)((BYTE*)triggerActor + 0xB4))
	{
		for (AController* controller = Level->ControllerList; controller; controller = controller->nextController)
		{
			if (!controller->LocalPlayerController()) continue;

			APlayerController* playerController = (APlayerController*)controller;
			APawn* pawn = controller->Pawn;
			if (!pawn) continue;

			// Distance check: pawn must be within sightRange of triggerActor
			FLOAT dx = pawn->Location.X - triggerActor->Location.X;
			FLOAT dy = pawn->Location.Y - triggerActor->Location.Y;
			FLOAT dz = pawn->Location.Z - triggerActor->Location.Z;
			if (dx*dx + dy*dy + dz*dz >= sightRange * sightRange) continue;

			// Direction FROM pawn TO triggerActor, normalised
			FVector dir(
				triggerActor->Location.X - pawn->Location.X,
				triggerActor->Location.Y - pawn->Location.Y,
				triggerActor->Location.Z - pawn->Location.Z
			);
			dir = dir.SafeNormal();

			// Controller view direction from raw rotation fields
			FVector viewDir = FRotator(
				*(INT*)((BYTE*)playerController + 0x240),
				*(INT*)((BYTE*)playerController + 0x244),
				*(INT*)((BYTE*)playerController + 0x248)
			).Vector();

			// Dot product must exceed sightDot threshold
			FLOAT dotVal = dir.X * viewDir.X + dir.Y * viewDir.Y + dir.Z * viewDir.Z;
			if (sightDot >= dotVal) continue;

			// Line-of-sight check from triggerActor to the player's view pawn
			APawn* viewPawn = *(APawn**)((BYTE*)playerController + 0x5B8);
			if (!viewPawn) continue;

			FCheckResult hit(1.0f);
			INT traced = XLevel->SingleLineCheck(hit, this, triggerActor->Location, viewPawn->Location, 0x86, FVector(0, 0, 0));
			if (traced == 0)  // 0 = no obstruction
				eventPlayerSeesMe(playerController);
			break;
		}
	}

	// Always refresh the last-sight timestamp
	*(FLOAT*)((BYTE*)this + 0x3A0) = Level->TimeSeconds;
	unguard;
}


// --- ANote ---
void ANote::CheckForErrors()
{
	// Ghidra 0x980f0: log the Note text via GWarn, then call super.
	FString& noteStr = *(FString*)((BYTE*)this + 0x394);
	GWarn->Logf(TEXT("%s"), *noteStr);
	AActor::CheckForErrors();
}


// --- APathNode ---
int APathNode::ReviewPath(APawn* P)
{
	guard(APathNode::ReviewPath);
	// Ghidra 0xd6400, ~100b: for each spec in PathList (TArray<UReachSpec*> at this+0x3d8),
	// read spec->End (ANavigationPoint* at spec+0x4c), then call the function pointer stored
	// at End+0x1ac (as per Ghidra — likely vtable[0x6b] cached or a field fn ptr),
	// passing this APathNode as argument. Then calls ANavigationPoint::ReviewPath. Returns 1.
	TArray<UReachSpec*>* pathList = (TArray<UReachSpec*>*)((BYTE*)this + 0x3d8);
	for (INT i = 0; i < pathList->Num(); i++)
	{
		UReachSpec* spec = (*pathList)(i);
		if (spec != NULL)
		{
			INT endPtr = *(INT*)((BYTE*)spec + 0x4c);
			if (endPtr != 0)
			{
				typedef void (__cdecl* ReviewFn)(APathNode*);
				((ReviewFn)(*(INT*)(endPtr + 0x1ac)))(this);
			}
		}
	}
	ANavigationPoint::ReviewPath(P);
	return 1;
	unguard;
}

void APathNode::CheckSymmetry(ANavigationPoint* param_1)
{
	guard(APathNode::CheckSymmetry);
	// Retail 0xd64b0

	// If there is already a spec in our PathList pointing to param_1, symmetry is fine
	TArray<UReachSpec*>* pathList = (TArray<UReachSpec*>*)((BYTE*)this + 0x3D8);
	for (INT i = 0; i < pathList->Num(); i++)
	{
		UReachSpec* spec = (*pathList)(i);
		if (spec->End == param_1) return;
	}

	// No return path found — measure straight-line distance
	FLOAT dx   = Location.X - param_1->Location.X;
	FLOAT dy   = Location.Y - param_1->Location.Y;
	FLOAT dz   = Location.Z - param_1->Location.Z;
	FLOAT dist = appSqrt(dx*dx + dy*dy + dz*dz);

	// Reset visitedWeight so pathfinding starts fresh
	for (ANavigationPoint* nav = Level->NavigationPointList; nav; nav = nav->nextNavigationPoint)
		nav->visitedWeight = 0;

	// If param_1 is not reachable from here within a generous budget, warn
	if (!ANavigationPoint::CanReach(param_1, dist * 1.8f))
		GWarn->Logf(TEXT("Should be JumpDest for %s!"), *FString(GetName()));
	unguard;
}



// --- APlayerStart ---
void APlayerStart::addReachSpecs(APawn* Scout, int bOnlyChanged)
{
	guard(APlayerStart::addReachSpecs);
	// Retail 0xd7f50
	ANavigationPoint::addReachSpecs(Scout, bOnlyChanged);
	Scout->SetCollisionSize(40.0f, 85.0f);
	// bTest=1: only checks whether the position is useable, does not actually move Scout
	INT result = XLevel->FarMoveActor(Scout, Location, 1, 0, 0, 0);
	if (result == 0)
		GWarn->Logf(TEXT("PlayerStart is not useable"));
	unguard;
}


// --- AScout ---
int AScout::findStart(FVector)
{
	guard(AScout::findStart);
	// TODO: implement AScout::findStart (retail 0xe0940: calls FarMoveActor + walkability test; many internal FUN_ helpers not resolved)
	// GHIDRA REF: 0xe0940 — calls FarMoveActor (Level vtable[0x9c/4]) to try placing
	// the scout at the requested position, then tests walkability and adjusts collision.
	// Many internal FUN_ helpers (path-graph queries, collision trace helpers) not yet
	// resolved. Always returns 0 (no start found) as a safe fallback.
	return 0;
	unguard;
}

int AScout::HurtByVolume(AActor *)
{
	// Ghidra 0x4720: shared stub; returns 0.
	return 0;
}

void AScout::InitForPathing()
{
	// Retail: 0xfc9b0, ordinal 3354. Initialises the scout's pathfinding state:
	// - Sets BYTE at this+0x2C to 1 (bPathfinding flag)
	// - Sets this+0x43C = 0x43D20000 (FLOAT 424.0f — max step height)
	// - Sets this+0x3E0 = (existing value & ~0x00020000) | 0x0005C000 (reach flags)
	// - Sets this+0x428 = 0x44160000 (FLOAT 600.0f — jump Z velocity)
	// - Sets this+0x44C = 0x44138000 (FLOAT 590.0f — ground speed)
	*(BYTE*)((BYTE*)this + 0x2C) = 1;
	*(DWORD*)((BYTE*)this + 0x43C) = 0x43D20000;  // 424.0f
	*(DWORD*)((BYTE*)this + 0x3E0) = (*(DWORD*)((BYTE*)this + 0x3E0) & ~0x00020000u) | 0x0005C000u;
	*(DWORD*)((BYTE*)this + 0x428) = 0x44160000;  // 600.0f
	*(DWORD*)((BYTE*)this + 0x44C) = 0x44138000;  // 590.0f
}



// =============================================================================
// ANavigationPoint (moved from EngineClassImpl.cpp)
// =============================================================================

// ANavigationPoint
// =============================================================================

void ANavigationPoint::Destroy() { Super::Destroy(); }
void ANavigationPoint::PostEditMove() {}
void ANavigationPoint::Spawned()
{
	// Retail (27b, RVA 0xD5B50): clear bit 11 (bPathsChanged) of Zone's flags at +0x450,
	// then mark our own bPathsChanged = 1.
	AZoneInfo* Z = Region.Zone;
	*(DWORD*)((BYTE*)Z + 0x450) &= ~0x800u;
	bPathsChanged = 1;
}
void ANavigationPoint::InitForPathFinding() {}
void ANavigationPoint::CheckSymmetry(ANavigationPoint* Other) {}
void ANavigationPoint::PostaddReachSpecs(APawn* Scout) {}
void ANavigationPoint::SetVolumes(const TArray<AVolume*>& Volumes) {}
void ANavigationPoint::CheckForErrors() { Super::CheckForErrors(); }
INT ANavigationPoint::ProscribedPathTo(ANavigationPoint* Nav) { return 0; }
void ANavigationPoint::addReachSpecs(APawn* Scout, INT bOnlyChanged) {}
void ANavigationPoint::SetupForcedPath(APawn* Scout, UReachSpec* Spec) {}
void ANavigationPoint::ClearPaths()
{
	// Retail: 104b SEH. Zeros the 4 path-chain pointer fields, then empties PathList.
	// PathList confirmed at this+0x3D8 via disassembly; chain ptrs from +0x3A8.
	nextNavigationPoint = NULL;
	nextOrdered         = NULL;
	prevOrdered         = NULL;
	previousPath        = NULL;
	((TArray<UReachSpec*>*)((BYTE*)this + 0x3D8))->Empty();
}
void ANavigationPoint::FindBase() {}
INT ANavigationPoint::PrunePaths() { return 0; }
INT ANavigationPoint::IsIdentifiedAs(FName Name) { return 0; }
INT ANavigationPoint::ReviewPath(APawn* Scout) { return 0; }
INT ANavigationPoint::CanReach(ANavigationPoint* Nav, FLOAT Dist) { return 0; }
void ANavigationPoint::CleanUpPruned()
{
	// Retail: 124b SEH. Iterates PathList backwards, removing specs with bPruned set.
	// Finishes with TArray::Shrink to release excess memory.
	TArray<UReachSpec*>* myPathList = (TArray<UReachSpec*>*)((BYTE*)this + 0x3D8);
	for (INT i = myPathList->Num() - 1; i >= 0; i--)
	{
		UReachSpec* Spec = (*myPathList)(i);
		if (Spec && Spec->bPruned)
			myPathList->Remove(i, 1);
	}
	myPathList->Shrink();
}
INT ANavigationPoint::FindAlternatePath(UReachSpec* Spec, INT bOnlyChanged) { return 0; }
UReachSpec* ANavigationPoint::GetReachSpecTo(ANavigationPoint* Nav)
{
	// Retail: 103b SEH. Linear scan of PathList (at this+0x3D8) for spec->End == Nav.
	TArray<UReachSpec*>* myPathList = (TArray<UReachSpec*>*)((BYTE*)this + 0x3D8);
	for (INT i = 0; i < myPathList->Num(); i++)
	{
		UReachSpec* Spec = (*myPathList)(i);
		if (Spec->End == Nav)
			return Spec;
	}
	return NULL;
}
INT ANavigationPoint::ShouldBeBased()
{
	// Retail: 32b (JNZ at +24 uses shared return-0 epilog 3 bytes past function end).
	// Check the object at this+0x164 (Level): if [Level+0x410] bit 6 is set => always base nav point.
	// Otherwise check bNotBased (bit 10 of bitfield DWORD at this+0x3A4): if set => return 0.
	BYTE* levelObj = *(BYTE**)((BYTE*)this + 0x164);
	if (*(BYTE*)(levelObj + 0x410) & 0x40)
		return 1;
	return bNotBased ? 0 : 1;
}

/*-- UInteraction screen/world transforms ------------------------------*/

void UInteraction::execScreenToWorld( FFrame& Stack, RESULT_DECL )
{
	guard(UInteraction::execScreenToWorld);
	P_GET_VECTOR(ScreenLoc);
	P_GET_VECTOR_REF(WorldLoc);
	P_FINISH;
	*WorldLoc = FVector(0,0,0);
	unguard;
}
IMPLEMENT_FUNCTION( UInteraction, INDEX_NONE, execScreenToWorld );

void UInteraction::execWorldToScreen( FFrame& Stack, RESULT_DECL )
{
	guard(UInteraction::execWorldToScreen);
	P_GET_VECTOR(WorldLoc);
	P_GET_VECTOR_REF(ScreenLoc);
	P_FINISH;
	*ScreenLoc = FVector(0,0,0);
	unguard;
}
IMPLEMENT_FUNCTION( UInteraction, INDEX_NONE, execWorldToScreen );

/*-- UInteractionMaster ------------------------------------------------*/

void UInteractionMaster::execTravel( FFrame& Stack, RESULT_DECL )
{
	guard(UInteractionMaster::execTravel);
	P_GET_STR(URL);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( UInteractionMaster, INDEX_NONE, execTravel );

/*-- UR6AbstractGameManager -------------------------------------------*/

void UR6AbstractGameManager::execClientLeaveServer( FFrame& Stack, RESULT_DECL )
{
	guard(UR6AbstractGameManager::execClientLeaveServer);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( UR6AbstractGameManager, INDEX_NONE, execClientLeaveServer );

void UR6AbstractGameManager::execConnectionInterrupted( FFrame& Stack, RESULT_DECL )
{
	guard(UR6AbstractGameManager::execConnectionInterrupted);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( UR6AbstractGameManager, INDEX_NONE, execConnectionInterrupted );

void UR6AbstractGameManager::execIsGSCreateUbiServer( FFrame& Stack, RESULT_DECL )
{
	guard(UR6AbstractGameManager::execIsGSCreateUbiServer);
	P_FINISH;
	*(DWORD*)Result = 0;
	unguard;
}
IMPLEMENT_FUNCTION( UR6AbstractGameManager, INDEX_NONE, execIsGSCreateUbiServer );

void UR6AbstractGameManager::execLaunchListenSrv( FFrame& Stack, RESULT_DECL )
{
	guard(UR6AbstractGameManager::execLaunchListenSrv);
	P_GET_STR(URL);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( UR6AbstractGameManager, INDEX_NONE, execLaunchListenSrv );

void UR6AbstractGameManager::execSetGSCreateUbiServer( FFrame& Stack, RESULT_DECL )
{
	guard(UR6AbstractGameManager::execSetGSCreateUbiServer);
	P_GET_UBOOL(bCreate);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( UR6AbstractGameManager, INDEX_NONE, execSetGSCreateUbiServer );

void UR6AbstractGameManager::execStartJoinServer( FFrame& Stack, RESULT_DECL )
{
	guard(UR6AbstractGameManager::execStartJoinServer);
	P_GET_STR(URL);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( UR6AbstractGameManager, INDEX_NONE, execStartJoinServer );

void UR6AbstractGameManager::execStartLogInProcedure( FFrame& Stack, RESULT_DECL )
{
	guard(UR6AbstractGameManager::execStartLogInProcedure);
	P_GET_STR(Username);
	P_GET_STR(Password);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( UR6AbstractGameManager, INDEX_NONE, execStartLogInProcedure );

void UR6AbstractGameManager::execStartPreJoinProcedure( FFrame& Stack, RESULT_DECL )
{
	guard(UR6AbstractGameManager::execStartPreJoinProcedure);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( UR6AbstractGameManager, INDEX_NONE, execStartPreJoinProcedure );

void UR6AbstractGameManager::execStopGSClientProcedure( FFrame& Stack, RESULT_DECL )
{
	guard(UR6AbstractGameManager::execStopGSClientProcedure);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( UR6AbstractGameManager, INDEX_NONE, execStopGSClientProcedure );

/*-- UR6FileManager ----------------------------------------------------*/

void UR6FileManager::execDeleteFile( FFrame& Stack, RESULT_DECL )
{
	guard(UR6FileManager::execDeleteFile);
	P_GET_STR(Filename);
	P_FINISH;
	*(DWORD*)Result = GFileManager->Delete( *Filename );
	unguard;
}
IMPLEMENT_FUNCTION( UR6FileManager, 1527, execDeleteFile );

void UR6FileManager::execFindFile( FFrame& Stack, RESULT_DECL )
{
	guard(UR6FileManager::execFindFile);
	P_GET_STR(Pattern);
	P_FINISH;
	TArray<FString> Files = GFileManager->FindFiles( *Pattern, 1, 0 );
	*(INT*)Result = Files.Num();
	unguard;
}
IMPLEMENT_FUNCTION( UR6FileManager, 1528, execFindFile );

void UR6FileManager::execGetFileName( FFrame& Stack, RESULT_DECL )
{
	guard(UR6FileManager::execGetFileName);
	P_GET_INT(Index);
	P_FINISH;
	*(FString*)Result = TEXT("");
	unguard;
}
IMPLEMENT_FUNCTION( UR6FileManager, 1526, execGetFileName );

void UR6FileManager::execGetNbFile( FFrame& Stack, RESULT_DECL )
{
	guard(UR6FileManager::execGetNbFile);
	P_FINISH;
	*(INT*)Result = 0;
	unguard;
}
IMPLEMENT_FUNCTION( UR6FileManager, 1525, execGetNbFile );

/*-- UR6ModMgr ---------------------------------------------------------*/

void UR6ModMgr::execAddNewModExtraPath( FFrame& Stack, RESULT_DECL )
{
	guard(UR6ModMgr::execAddNewModExtraPath);
	P_GET_STR(Path);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( UR6ModMgr, 2020, execAddNewModExtraPath );

void UR6ModMgr::execCallSndEngineInit( FFrame& Stack, RESULT_DECL )
{
	guard(UR6ModMgr::execCallSndEngineInit);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( UR6ModMgr, 3003, execCallSndEngineInit );

void UR6ModMgr::execGetASBuildVersion( FFrame& Stack, RESULT_DECL )
{
	guard(UR6ModMgr::execGetASBuildVersion);
	P_FINISH;
	*(FString*)Result = TEXT("1.60");
	unguard;
}
IMPLEMENT_FUNCTION( UR6ModMgr, INDEX_NONE, execGetASBuildVersion );

void UR6ModMgr::execGetIWBuildVersion( FFrame& Stack, RESULT_DECL )
{
	guard(UR6ModMgr::execGetIWBuildVersion);
	P_FINISH;
	*(FString*)Result = TEXT("1.60");
	unguard;
}
IMPLEMENT_FUNCTION( UR6ModMgr, INDEX_NONE, execGetIWBuildVersion );

void UR6ModMgr::execIsOfficialMod( FFrame& Stack, RESULT_DECL )
{
	guard(UR6ModMgr::execIsOfficialMod);
	P_FINISH;
	*(DWORD*)Result = 0;
	unguard;
}
IMPLEMENT_FUNCTION( UR6ModMgr, INDEX_NONE, execIsOfficialMod );

void UR6ModMgr::execSetGeneralModSettings( FFrame& Stack, RESULT_DECL )
{
	guard(UR6ModMgr::execSetGeneralModSettings);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( UR6ModMgr, INDEX_NONE, execSetGeneralModSettings );

void UR6ModMgr::execSetSystemMod( FFrame& Stack, RESULT_DECL )
{
	guard(UR6ModMgr::execSetSystemMod);
	P_GET_STR(ModName);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( UR6ModMgr, 2021, execSetSystemMod );

// =============================================================================
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



// ============================================================================
// FSortedPathList::findEndAnchor / findStartAnchor / FPathBuilder::operator=
// (moved from EngineStubs.cpp)
// ============================================================================

// ?findEndAnchor@FSortedPathList@@QAEPAVANavigationPoint@@PAVAPawn@@PAVAActor@@VFVector@@H@Z
ANavigationPoint* FSortedPathList::findEndAnchor(APawn* Scout, AActor* End, FVector EndVec, INT bAllowFallback)
{
	ANavigationPoint** Paths = (ANavigationPoint**)Pad;
	INT Count = *(INT*)(Pad + 0x100);
	ANavigationPoint* Best = NULL;
	for (INT i = 0; i < Count; i++)
	{
		ANavigationPoint* Nav = Paths[i];
		if (!Nav) continue;
		if ((*(DWORD*)((BYTE*)Nav + 0x3a4)) & 0x200) continue;
		if (!Scout->actorReachable(Nav, 1, 1)) continue;
		INT EndReachable = End ? Scout->actorReachable(End, 1, 1) : Scout->pointReachable(EndVec, 1);
		if (EndReachable) return Nav;
		if (bAllowFallback && !Best) Best = Nav;
	}
	return Best;
}

// ?findStartAnchor@FSortedPathList@@QAEPAVANavigationPoint@@PAVAPawn@@@Z
ANavigationPoint* FSortedPathList::findStartAnchor(APawn* Scout)
{
	ANavigationPoint** Paths = (ANavigationPoint**)Pad;
	INT Count = *(INT*)(Pad + 0x100);
	for (INT i = 0; i < Count; i++)
	{
		ANavigationPoint* Nav = Paths[i];
		if (!Nav) continue;
		if ((*(DWORD*)((BYTE*)Nav + 0x3a4)) & 0x200) continue;
		if (Scout->actorReachable(Nav, 1, 1)) return Nav;
	}
	return NULL;
}

// ??4FPathBuilder@@QAEAAV0@ABV0@@Z
FPathBuilder & FPathBuilder::operator=(FPathBuilder const & Other) { appMemcpy(this, &Other, 8); return *this; }

// --- Moved from EngineStubs.cpp ---
// ?buildPaths@FPathBuilder@@QAEHPAVULevel@@@Z
int FPathBuilder::buildPaths(ULevel * p0) { return 0; }

// ?removePaths@FPathBuilder@@QAEHPAVULevel@@@Z
// Ghidra: iterate actors, destroy auto-built navigation points, clear bPathsTransient on LevelInfo
int FPathBuilder::removePaths(ULevel* Level)
{
	// Store level pointer at this+0 (first field in Pad)
	*(ULevel**)Pad = Level;

	INT Count = 0;
	for (INT i = 0; i < Level->Actors.Num(); i++)
	{
		AActor* Actor = Level->Actors(i);
		if (Actor && Actor->IsA(ANavigationPoint::StaticClass()))
		{
			// Check bAutoBuilt flag — high bit of byte at AActor+0x3A4
			if (((BYTE*)Actor)[0x3A4] & 0x80)
			{
				Count++;
				Level->DestroyActor(Actor);
			}
		}
	}

	// Verify Actors(0) is ALevelInfo and clear bPathsTransient
	if (!Level->Actors(0))
		appFailAssert("Actors(0)", "d:\\ravenshield\\412\\engine\\inc\\UnLevel.h", 0x1AD);
	if (!Level->Actors(0)->IsA(ALevelInfo::StaticClass()))
		appFailAssert("Actors(0)->IsA(ALevelInfo::StaticClass())", "d:\\ravenshield\\412\\engine\\inc\\UnLevel.h", 0x1AE);

	// Clear bPathsTransient bit (bit 0x800 at offset 0x450 on LevelInfo)
	DWORD& Flags = *(DWORD*)(((BYTE*)Level->Actors(0)) + 0x450);
	Flags &= ~0x800;

	return Count;
}
// ?BuildActionSpotList@FPathBuilder@@QAEXPAVULevel@@@Z
// Ghidra: For each AR6ActionSpot, set CollisionHeight, call PutOnGround,
// find a NavigationPoint anchor within 1200 uu via FSortedPathList, then
// chain into LevelInfo->m_ActionSpotList linked list.
void FPathBuilder::BuildActionSpotList(ULevel* Level) {
	*(ULevel**)Pad = Level;
	// Spawn a scout if one is not already present (local_18 tracks whether we did)
	UBOOL bSpawnedScout = (*(APawn**)(Pad + 4) == NULL);
	if (bSpawnedScout)
		getScout();

	// Mark scout as "is player" for pathing purposes
	APawn* Scout = *(APawn**)(Pad + 4);
	*(BYTE*)((BYTE*)Scout + 0x2c) = 1;

	ALevelInfo* LInfo = (*(ULevel**)Pad)->GetLevelInfo();
	LInfo->m_ActionSpotList = NULL;	// LevelInfo+0x4dc

	for (INT i = 0; i < (*(ULevel**)Pad)->Actors.Num(); i++) {
		AActor* Actor = (*(ULevel**)Pad)->Actors(i);
		if (!Actor) continue;
		// IsA(AR6ActionSpot) && !bAutoBuilt (signed char at Actor+0xa0 >= 0)
		if (!Actor->IsA(AR6ActionSpot::StaticClass())) continue;
		if ((SBYTE)(*(BYTE*)((BYTE*)Actor + 0xa0)) < 0) continue;

		FSortedPathList SortedList;
		// Initialise count field to 0 (at Pad+0x100)
		*(INT*)(SortedList.Pad + 0x100) = 0;

		AR6ActionSpot* Spot = (AR6ActionSpot*)Actor;
		// Set CollisionHeight (Actor+0xfc): 70.0f if m_eFire==2, else 135.0f
		if (Spot->m_eFire == 2)
			*(FLOAT*)((BYTE*)Spot + 0xfc) = 70.0f;
		else
			*(FLOAT*)((BYTE*)Spot + 0xfc) = 135.0f;

		Spot->PutOnGround();

		LInfo = (*(ULevel**)Pad)->GetLevelInfo();
		for (BYTE* Nav = *(BYTE**)((BYTE*)LInfo + 0x4d0); Nav; Nav = *(BYTE**)(Nav + 0x3a8)) {
			// Skip if nav point has bit 2 set at offset 0x3a4
			if ((*(DWORD*)(Nav + 0x3a4) & 2) != 0) continue;
			// Compute squared distance from Spot->Location (FVector at 0x234) to nav point
			FLOAT dx = *(FLOAT*)((BYTE*)Spot + 0x234) - *(FLOAT*)(Nav + 0x234);
			FLOAT dy = *(FLOAT*)((BYTE*)Spot + 0x238) - *(FLOAT*)(Nav + 0x238);
			FLOAT dz = *(FLOAT*)((BYTE*)Spot + 0x23c) - *(FLOAT*)(Nav + 0x23c);
			FLOAT DistSq = dx*dx + dy*dy + dz*dz;
			// 1200 uu radius → 1440000 uu² threshold
			if (DistSq < 1440000.0f)
				SortedList.addPath((ANavigationPoint*)Nav, (INT)DistSq);
		}

		// If list has entries, find the best anchor
		if (*(INT*)(SortedList.Pad + 0x100) > 0) {
			FVector SpotLoc(*(FLOAT*)((BYTE*)Spot+0x234),
			                *(FLOAT*)((BYTE*)Spot+0x238),
			                *(FLOAT*)((BYTE*)Spot+0x23c));
			Spot->m_Anchor = SortedList.findEndAnchor(Scout, Spot, SpotLoc, 0);
		}

		// If an anchor was found, prepend to m_ActionSpotList linked list
		if (Spot->m_Anchor) {
			LInfo = (*(ULevel**)Pad)->GetLevelInfo();
			Spot->m_NextSpot = LInfo->m_ActionSpotList;
			LInfo->m_ActionSpotList = Spot;
		}
	}

	// Clean up scout if we spawned it
	if (bSpawnedScout) {
		Scout = *(APawn**)(Pad + 4);
		AActor* AICtrl = *(AActor**)((BYTE*)Scout + 0x4ec);
		if (AICtrl) (*(ULevel**)Pad)->DestroyActor(AICtrl);
		(*(ULevel**)Pad)->DestroyActor(Scout);
	}
}

// ?ReviewPaths@FPathBuilder@@QAEXPAVULevel@@@Z
// Ghidra: for each NavigationPoint in linked list, call ReviewPath(Scout);
// then warn about movers without associated nav points.
void FPathBuilder::ReviewPaths(ULevel* Level) {
	debugf(NAME_Log, TEXT("Reviewing paths"));
	GWarn->BeginSlowTask(TEXT("Reviewing paths..."), 0, 0);
	*(ULevel**)Pad = Level;

	if (Level) {
		ALevelInfo* LInfo = Level->GetLevelInfo();
		if (LInfo) {
			LInfo = *(ULevel**)Pad ? (*(ULevel**)Pad)->GetLevelInfo() : NULL;
			if (LInfo && *(INT*)((BYTE*)LInfo + 0x4d0) != 0) {
				// Count nav points to display progress
				INT Count = 0;
				for (BYTE* Nav = *(BYTE**)((BYTE*)LInfo + 0x4d0); Nav; Nav = *(BYTE**)(Nav + 0x3a8))
					Count++;

				getScout();
				SetPathCollision(1);

				APawn* Scout = *(APawn**)(Pad + 4);
				LInfo = (*(ULevel**)Pad)->GetLevelInfo();
				// Ghidra: call NavPoint->vtable[0x1a8](Scout) = ReviewPath(Scout)
				typedef void (__thiscall* tReviewPath)(BYTE*, APawn*);
				for (BYTE* Nav = *(BYTE**)((BYTE*)LInfo + 0x4d0); Nav; Nav = *(BYTE**)(Nav + 0x3a8)) {
					GWarn->StatusUpdatef(0, Count, TEXT("Reviewing Paths"));
					tReviewPath fn = *(tReviewPath*)((BYTE*)(*(void**)Nav) + 0x1a8);
					fn(Nav, Scout);
				}

				SetPathCollision(0);
				// Destroy Scout's AIController (Scout+0x4ec) and Scout via Level->DestroyActor
				AActor* AICtrl = *(AActor**)((BYTE*)Scout + 0x4ec);
				if (AICtrl) (*(ULevel**)Pad)->DestroyActor(AICtrl);
				(*(ULevel**)Pad)->DestroyActor(Scout);

				// Check movers for missing associated navigation points
				for (INT i = 0; i < (*(ULevel**)Pad)->Actors.Num(); i++) {
					GWarn->StatusUpdatef(i, (*(ULevel**)Pad)->Actors.Num(), TEXT("Reviewing Movers"));
					AActor* Actor = (*(ULevel**)Pad)->Actors(i);
					if (Actor && Actor->IsA(AMover::StaticClass())) {
						// Skip mover if it has the 0x4000 flag set (bStatic path)
						if ((*(DWORD*)((BYTE*)Actor + 0x3b8) & 0x4000) == 0 &&
							*(INT*)((BYTE*)Actor + 0x3fc) == 0)
						{
							// Mover has no associated nav path - warn
							// Deviation: skip extended GWarn vtable call (slot 0x28 not declared)
							debugf(NAME_Warning, TEXT("No navigation point associated with this mover!"));
						}
					}
				}
				GWarn->EndSlowTask();
				return;
			}
		}
	}

	// No nav point list defined
	debugf(NAME_Warning, TEXT("No navigation point list. Paths define needed."));
	GWarn->EndSlowTask();
}

// ?defineChangedPaths@FPathBuilder@@QAEXPAVULevel@@@Z
// Ghidra: Partial redefinition — re-runs path building only for nav points
// flagged as changed (no 0x800 bit at NavPoint+0x3a4). For unchanged nav
// points, empties their PathList (TArray at +0x3d8). Same scout+pass sequence
// as definePaths but operates on the changed subset and spawns its own scout.
void FPathBuilder::defineChangedPaths(ULevel* Level) {
	*(ULevel**)Pad = Level;

	// Clear NavigationPointList head and the bPathsRebuilt bit
	ALevelInfo* LInfo = Level->GetLevelInfo();
	*(INT*)((BYTE*)LInfo + 0x4d0) = 0;
	LInfo = Level->GetLevelInfo();
	*(DWORD*)((BYTE*)LInfo + 0x94c) &= ~1u;

	// Pass 0: build nav point linked list (no InitForPathFinding here)
	for (INT i = 0; i < Level->Actors.Num(); i++) {
		AActor* Actor = Level->Actors(i);
		if (!Actor) continue;
		if (!Actor->IsA(ANavigationPoint::StaticClass())) continue;
		if ((SBYTE)(*(BYTE*)((BYTE*)Actor + 0xa0)) < 0) continue; // bAutoBuilt
		LInfo = (*(ULevel**)Pad)->GetLevelInfo();
		*(INT*)((BYTE*)Actor + 0x3a8) = *(INT*)((BYTE*)LInfo + 0x4d0);
		*(INT*)((BYTE*)LInfo + 0x4d0) = (INT)Actor;
	}

	// Pre-pass: for each nav point, decide how to handle changed vs unchanged
	LInfo = (*(ULevel**)Pad)->GetLevelInfo();
	for (BYTE* Nav = *(BYTE**)((BYTE*)LInfo + 0x4d0); Nav; Nav = *(BYTE**)(Nav + 0x3a8)) {
		ANavigationPoint* NavPt = (ANavigationPoint*)Nav;
		if ((*(DWORD*)(Nav + 0x3a4) & 0x800) == 0) {
			// Not marked changed: check reachspecs for changed endpoints, prune
			TArray<UReachSpec*>& PathList = *(TArray<UReachSpec*>*)(Nav + 0x3d8);
			for (INT j = 0; j < PathList.Num(); j++) {
				UReachSpec* Spec = PathList(j);
				if (Spec && Spec->End && (*(DWORD*)((BYTE*)Spec->End + 0x3a4) & 0x800) != 0)
					*(BYTE*)((BYTE*)Spec + 0x2c) = 1; // mark pruned
			}
			NavPt->CleanUpPruned();
		} else {
			// Marked changed: empty the path list entirely
			// Ghidra: FArray::Empty(&NavPoint[0x3d8], 4, 0)
			((TArray<UReachSpec*>*)(Nav + 0x3d8))->Empty();
		}
	}

	getScout();
	// Verify Actors(0) is ALevelInfo
	if (!(*(ULevel**)Pad)->Actors(0))
		appFailAssert("Actors(0)", "d:\\ravenshield\\412\\engine\\inc\\UnLevel.h", 0x1AD);
	if (!(*(ULevel**)Pad)->Actors(0)->IsA(ALevelInfo::StaticClass()))
		appFailAssert("Actors(0)->IsA(ALevelInfo::StaticClass())", "d:\\ravenshield\\412\\engine\\inc\\UnLevel.h", 0x1AE);

	// Clear nav list and rebuild it for the main passes
	*(INT*)((BYTE*)(*(ULevel**)Pad)->Actors(0) + 0x4d0) = 0;
	GWarn->BeginSlowTask(TEXT("Defining Paths"), 1, 0);

	SetPathCollision(1);
	INT NavCount = 0;
	// Count NavPoints in first loop
	for (INT i = 0; i < (*(ULevel**)Pad)->Actors.Num(); i++) {
		GWarn->StatusUpdatef(i, (*(ULevel**)Pad)->Actors.Num(), TEXT("Defining"));
		AActor* Actor = (*(ULevel**)Pad)->Actors(i);
		if (Actor && Actor->IsA(ANavigationPoint::StaticClass())) NavCount++;
	}

	// Verify + clear LevelInfo nav list head again
	if (!(*(ULevel**)Pad)->Actors(0))
		appFailAssert("Actors(0)", "d:\\ravenshield\\412\\engine\\inc\\UnLevel.h", 0x1AD);
	if (!(*(ULevel**)Pad)->Actors(0)->IsA(ALevelInfo::StaticClass()))
		appFailAssert("Actors(0)->IsA(ALevelInfo::StaticClass())", "d:\\ravenshield\\412\\engine\\inc\\UnLevel.h", 0x1AE);
	*(INT*)((BYTE*)(*(ULevel**)Pad)->Actors(0) + 0x4d0) = 0;

	INT nc = 0;
	for (INT i = 0; i < (*(ULevel**)Pad)->Actors.Num(); i++) {
		GWarn->StatusUpdatef(nc, NavCount, TEXT("Navigation Points on Bases"));
		AActor* Actor = (*(ULevel**)Pad)->Actors(i);
		if (!Actor) continue;
		if (!Actor->IsA(ANavigationPoint::StaticClass())) continue;
		if ((SBYTE)(*(BYTE*)((BYTE*)Actor + 0xa0)) < 0) continue; // bAutoBuilt
		nc++;
		// Verify + add to list with Actors(0) check
		if (!(*(ULevel**)Pad)->Actors(0))
			appFailAssert("Actors(0)", "d:\\ravenshield\\412\\engine\\inc\\UnLevel.h", 0x1AD);
		if (!(*(ULevel**)Pad)->Actors(0)->IsA(ALevelInfo::StaticClass()))
			appFailAssert("Actors(0)->IsA(ALevelInfo::StaticClass())", "d:\\ravenshield\\412\\engine\\inc\\UnLevel.h", 0x1AE);
		LInfo = (*(ULevel**)Pad)->GetLevelInfo();
		*(INT*)((BYTE*)Actor + 0x3a8) = *(INT*)((BYTE*)LInfo + 0x4d0);
		*(INT*)((BYTE*)LInfo + 0x4d0) = (INT)Actor;
		// InitForPathFinding at vtable[0x19c]
		typedef void (__thiscall* tInitPath)(BYTE*);
		tInitPath fn = *(tInitPath*)((BYTE*)(*(void**)Actor) + 0x19c);
		fn((BYTE*)Actor);
	}

	// Verify Actors(0)
	if (!(*(ULevel**)Pad)->Actors(0))
		appFailAssert("Actors(0)", "d:\\ravenshield\\412\\engine\\inc\\UnLevel.h", 0x1AD);
	if (!(*(ULevel**)Pad)->Actors(0)->IsA(ALevelInfo::StaticClass()))
		appFailAssert("Actors(0)->IsA(ALevelInfo::StaticClass())", "d:\\ravenshield\\412\\engine\\inc\\UnLevel.h", 0x1AE);

	// Pass 2: FindBase on each nav point (vtable[0x190])
	LInfo = (*(ULevel**)Pad)->GetLevelInfo();
	for (BYTE* Nav = *(BYTE**)((BYTE*)LInfo + 0x4d0); Nav; Nav = *(BYTE**)(Nav + 0x3a8)) {
		typedef void (__thiscall* tFindBase)(BYTE*);
		tFindBase fn = *(tFindBase*)((BYTE*)(*(void**)Nav) + 0x190);
		fn(Nav);
	}

	debugf(NAME_Log, TEXT(""));

	// Pass 3: addReachSpecs at vtable[0x188](Scout, 1) — note: 1, not 0
	APawn* Scout = *(APawn**)(Pad + 4);
	INT rs = 0;
	LInfo = (*(ULevel**)Pad)->GetLevelInfo();
	for (BYTE* Nav = *(BYTE**)((BYTE*)LInfo + 0x4d0); Nav; Nav = *(BYTE**)(Nav + 0x3a8)) {
		GWarn->StatusUpdatef(rs, NavCount, TEXT("Adding Reachspecs"));
		typedef void (__thiscall* tAddReach)(BYTE*, APawn*, INT);
		tAddReach fn = *(tAddReach*)((BYTE*)(*(void**)Nav) + 0x188);
		fn(Nav, Scout, 1);	// NOTE: int arg is 1 here (changed paths mode)
		rs++;
	}

	// Pass 4: SetupForcedPath at vtable[0x18c](Scout)
	LInfo = (*(ULevel**)Pad)->GetLevelInfo();
	for (BYTE* Nav = *(BYTE**)((BYTE*)LInfo + 0x4d0); Nav; Nav = *(BYTE**)(Nav + 0x3a8)) {
		typedef void (__thiscall* tSetupForced)(BYTE*, APawn*);
		tSetupForced fn = *(tSetupForced*)((BYTE*)(*(void**)Nav) + 0x18c);
		fn(Nav, Scout);
	}

	debugf(NAME_Log, TEXT(""));

	// Pass 5: PrunePaths at vtable[0x1a0] with StatusUpdatef
	INT pr = 0;
	LInfo = (*(ULevel**)Pad)->GetLevelInfo();
	for (BYTE* Nav = *(BYTE**)((BYTE*)LInfo + 0x4d0); Nav; Nav = *(BYTE**)(Nav + 0x3a8)) {
		GWarn->StatusUpdatef(pr, NavCount, TEXT("Pruning"));
		typedef INT (__thiscall* tPrune)(BYTE*);
		tPrune fn = *(tPrune*)((BYTE*)(*(void**)Nav) + 0x1a0);
		fn(Nav);
		pr++;
	}

	debugf(NAME_Log, TEXT(""));
	SetPathCollision(0);

	// Clear bAutoBuilt flags (0x800 at NavPoint+0x3a4)
	LInfo = (*(ULevel**)Pad)->GetLevelInfo();
	for (BYTE* Nav = *(BYTE**)((BYTE*)LInfo + 0x4d0); Nav; Nav = *(BYTE**)(Nav + 0x3a8))
		*(DWORD*)(Nav + 0x3a4) &= ~0x800u;

	BuildActionSpotList(Level);

	// Destroy Scout and its AIController
	Scout = *(APawn**)(Pad + 4);
	AActor* AICtrl = *(AActor**)((BYTE*)Scout + 0x4ec);
	if (AICtrl) (*(ULevel**)Pad)->DestroyActor(AICtrl);
	(*(ULevel**)Pad)->DestroyActor(Scout);

	debugf(NAME_Log, TEXT("defineChangedPaths done"));
	// Deviation: skip GWarn vtable[0x1c] call (undeclared)
	GWarn->EndSlowTask();
}

// ?definePaths@FPathBuilder@@QAEXPAVULevel@@@Z
// Ghidra: undefinePaths, then spawn scout, build nav-point linked list, run
// addReachSpecs + SetupForcedPath + PrunePaths + ClearPaths passes, destroy scout,
// set bPathsDefined, then BuildActionSpotList + PostPath on all actors.
void FPathBuilder::definePaths(ULevel* Level) {
	undefinePaths(Level);
	*(ULevel**)Pad = Level;
	getScout();

	ALevelInfo* LInfo = (*(ULevel**)Pad)->GetLevelInfo();
	*(INT*)((BYTE*)LInfo + 0x4d0) = 0;	// clear NavigationPointList head
	// Clear bit 0 of LevelInfo+0x94c (bPathsRebuilt or similar)
	LInfo = (*(ULevel**)Pad)->GetLevelInfo();
	*(DWORD*)((BYTE*)LInfo + 0x94c) &= ~1u;

	GWarn->BeginSlowTask(TEXT("Defining Paths"), 1, 0);
	INT NavCount = 0;
	SetPathCollision(1);

	// Pass 1: enumerate actors, build nav-point linked list, call InitForPathFinding
	for (INT i = 0; i < (*(ULevel**)Pad)->Actors.Num(); i++) {
		GWarn->StatusUpdatef(i, (*(ULevel**)Pad)->Actors.Num(), TEXT("Defining"));
		AActor* Actor = (*(ULevel**)Pad)->Actors(i);
		if (!Actor) { i++; continue; }
		if (Actor->IsA(ANavigationPoint::StaticClass())) {
			NavCount++;
			// Add to linked list (LevelInfo[0x4d0] = head), NavPoint[0x3a8] = next
			LInfo = (*(ULevel**)Pad)->GetLevelInfo();
			*(INT*)((BYTE*)Actor + 0x3a8) = *(INT*)((BYTE*)LInfo + 0x4d0);
			*(INT*)((BYTE*)LInfo + 0x4d0) = (INT)Actor;
			// Ghidra: call NavPoint->vtable[0x19c](void) = InitForPathFinding
			typedef void (__thiscall* tInitPath)(BYTE*);
			tInitPath fn = *(tInitPath*)((BYTE*)(*(void**)Actor) + 0x19c);
			fn((BYTE*)Actor);
		} else {
			// Ghidra: call Actor->vtable[0x154](Scout) = AddMyMarker(Scout)
			APawn* Scout = *(APawn**)(Pad + 4);
			typedef void (__thiscall* tAddMarker)(AActor*, APawn*);
			tAddMarker fn = *(tAddMarker*)((BYTE*)(*(void**)Actor) + 0x154);
			fn(Actor, Scout);
		}
	}

	// Verify Actors(0) is LevelInfo
	if (!(*(ULevel**)Pad)->Actors(0))
		appFailAssert("Actors(0)", "d:\\ravenshield\\412\\engine\\inc\\UnLevel.h", 0x1AD);
	if (!(*(ULevel**)Pad)->Actors(0)->IsA(ALevelInfo::StaticClass()))
		appFailAssert("Actors(0)->IsA(ALevelInfo::StaticClass())", "d:\\ravenshield\\412\\engine\\inc\\UnLevel.h", 0x1AE);

	// Pass 2: call FindBase on each nav point (vtable[0x190/4=0x64])
	LInfo = (*(ULevel**)Pad)->GetLevelInfo();
	for (BYTE* Nav = *(BYTE**)((BYTE*)LInfo + 0x4d0); Nav; Nav = *(BYTE**)(Nav + 0x3a8)) {
		typedef void (__thiscall* tFindBase)(BYTE*);
		tFindBase fn = *(tFindBase*)((BYTE*)(*(void**)Nav) + 0x190);
		fn(Nav);
	}

	debugf(NAME_Log, TEXT("Adding reachspecs"));

	// Pass 3: addReachSpecs(Scout, 0) on each nav point (vtable[0x188])
	APawn* Scout = *(APawn**)(Pad + 4);
	INT rs = 0;
	LInfo = (*(ULevel**)Pad)->GetLevelInfo();
	for (BYTE* Nav = *(BYTE**)((BYTE*)LInfo + 0x4d0); Nav; Nav = *(BYTE**)(Nav + 0x3a8)) {
		GWarn->StatusUpdatef(rs, NavCount, TEXT("Adding Reachspecs"));
		typedef void (__thiscall* tAddReach)(BYTE*, APawn*, INT);
		tAddReach fn = *(tAddReach*)((BYTE*)(*(void**)Nav) + 0x188);
		fn(Nav, Scout, 0);
		rs++;
	}

	// Pass 4: SetupForcedPath(Scout) on each nav point (vtable[0x18c])
	LInfo = (*(ULevel**)Pad)->GetLevelInfo();
	for (BYTE* Nav = *(BYTE**)((BYTE*)LInfo + 0x4d0); Nav; Nav = *(BYTE**)(Nav + 0x3a8)) {
		typedef void (__thiscall* tSetupForced)(BYTE*, APawn*);
		tSetupForced fn = *(tSetupForced*)((BYTE*)(*(void**)Nav) + 0x18c);
		fn(Nav, Scout);
	}

	debugf(NAME_Log, TEXT("Pruning paths"));

	// Pass 5: PrunePaths on each nav point (vtable[0x1a0]), count pruned
	INT pruned = 0; INT pr = 0;
	LInfo = (*(ULevel**)Pad)->GetLevelInfo();
	for (BYTE* Nav = *(BYTE**)((BYTE*)LInfo + 0x4d0); Nav; Nav = *(BYTE**)(Nav + 0x3a8)) {
		GWarn->StatusUpdatef(pr, NavCount, TEXT("Pruning"));
		typedef INT (__thiscall* tPrune)(BYTE*);
		tPrune fn = *(tPrune*)((BYTE*)(*(void**)Nav) + 0x1a0);
		pruned += fn(Nav);
		pr++;
	}

	debugf(NAME_Log, TEXT("Paths defined"));
	
	SetPathCollision(0);

	// Clear bAutoBuilt bit (0x800 at NavPoint+0x3a4) on all nav points
	LInfo = (*(ULevel**)Pad)->GetLevelInfo();
	for (BYTE* Nav = *(BYTE**)((BYTE*)LInfo + 0x4d0); Nav; Nav = *(BYTE**)(Nav + 0x3a8))
		*(DWORD*)(Nav + 0x3a4) &= ~0x800u;

	// Destroy Scout's AIController and Scout
	AActor* AICtrl = *(AActor**)((BYTE*)Scout + 0x4ec);
	if (AICtrl) (*(ULevel**)Pad)->DestroyActor(AICtrl);
	(*(ULevel**)Pad)->DestroyActor(Scout);

	// Set bPathsDefined (bit 0x800) on LevelInfo
	if (!(*(ULevel**)Pad)->Actors(0))
		appFailAssert("Actors(0)", "d:\\ravenshield\\412\\engine\\inc\\UnLevel.h", 0x1AD);
	if (!(*(ULevel**)Pad)->Actors(0)->IsA(ALevelInfo::StaticClass()))
		appFailAssert("Actors(0)->IsA(ALevelInfo::StaticClass())", "d:\\ravenshield\\412\\engine\\inc\\UnLevel.h", 0x1AE);
	*(DWORD*)(((BYTE*)(*(ULevel**)Pad)->Actors(0)) + 0x450) |= 0x800;

	BuildActionSpotList(Level);

	// Call vtable[0x174](void) on all actors = PostPath or CheckForErrors
	for (INT i = 0; i < (*(ULevel**)Pad)->Actors.Num(); i++) {
		AActor* Actor = (*(ULevel**)Pad)->Actors(i);
		if (Actor) {
			typedef void (__thiscall* tPostPath)(AActor*);
			tPostPath fn = *(tPostPath*)((BYTE*)(*(void**)Actor) + 0x174);
			fn(Actor);
		}
	}

	debugf(NAME_Log, TEXT("definePaths done"));
	// Deviation: skip GWarn vtable[0x1c] call (slot not declared)
	GWarn->EndSlowTask();
}

// ?undefinePaths@FPathBuilder@@QAEXPAVULevel@@@Z
// Ghidra: destroy all non-transient ANavigationPoints; for transient ones call ClearPaths (vtable[0x66]);
// clear bPathsDefined on LevelInfo.
void FPathBuilder::undefinePaths(ULevel* Level) {
	*(ULevel**)Pad = Level;
	debugf(NAME_Log, TEXT("Undefining paths"));

	ALevelInfo* LInfo = Level->GetLevelInfo();
	*(DWORD*)((BYTE*)LInfo + 0x4d0) = 0;	// clear navigation point linked list head

	GWarn->BeginSlowTask(TEXT("Undefining"), 0, 0);

	INT i = 0;
	for (;;) {
		INT Num = Level->Actors.Num();
		if (i >= Num) {
			// Post-loop: verify Actors(0) and clear bPathsDefined (bit 0x800)
			if (!Level->Actors(0))
				appFailAssert("Actors(0)", "d:\\ravenshield\\412\\engine\\inc\\UnLevel.h", 0x1AD);
			if (!Level->Actors(0)->IsA(ALevelInfo::StaticClass()))
				appFailAssert("Actors(0)->IsA(ALevelInfo::StaticClass())", "d:\\ravenshield\\412\\engine\\inc\\UnLevel.h", 0x1AE);
			*(DWORD*)(((BYTE*)Level->Actors(0)) + 0x450) &= ~0x800u;
			GWarn->EndSlowTask();
			return;
		}
		GWarn->StatusUpdatef(i, Num, TEXT("Undefining"));
		AActor* Actor = Level->Actors(i);
		if (Actor && Actor->IsA(ANavigationPoint::StaticClass())) {
			UClass* Cls = Actor->GetClass();
			if ((*(DWORD*)((BYTE*)Cls + 0x48c) & 0x200) == 0) {
				// Normal nav point: destroy it then keep incrementing i
				Level->DestroyActor(Actor);
				i++;
				continue;
			} else {
				// Transient nav point: call ClearPaths via vtable slot 0x198/4 = 102
				// Deviation: vtable slot determined from Ghidra offset 0x198; likely ClearPaths()
				typedef void (__thiscall *tClearPaths)(AActor*);
				tClearPaths fn = *(tClearPaths*)((BYTE*)(*(void**)Actor) + 0x198);
				fn(Actor);
			}
		}
		i++;
	}
}
// ============================================================================
// FSortedPathList
// ============================================================================
FSortedPathList::FSortedPathList() { appMemzero(this, sizeof(*this)); }
FSortedPathList& FSortedPathList::operator=(const FSortedPathList& Other) { appMemcpy(this, &Other, 260); return *this; } // 65 dwords
void FSortedPathList::addPath(ANavigationPoint* Path, INT Cost)
{
	// Ghidra (172B): Sorted insertion into fixed 32-element array.
	// Layout: Paths[32] at 0x00, Costs[32] at 0x80, Count at 0x100.
	ANavigationPoint** Paths = (ANavigationPoint**)&Pad[0];
	INT* Costs = (INT*)&Pad[0x80];
	INT& Count = *(INT*)&Pad[0x100];

	INT InsertIdx = 0;

	// Quick check: if last element's cost < new cost, start at end
	if (Count > 0 && Costs[Count - 1] < Cost)
		InsertIdx = Count;

	// Linear search for insertion point
	while (InsertIdx < Count && Costs[InsertIdx] <= Cost)
		InsertIdx++;

	// Insert if within max capacity (32)
	if (InsertIdx < 32)
	{
		// Save displaced element
		ANavigationPoint* SavedPath = Paths[InsertIdx];
		INT SavedCost = Costs[InsertIdx];

		// Write new element
		Paths[InsertIdx] = Path;
		Costs[InsertIdx] = Cost;

		// Grow count
		if (Count < 32)
			Count++;

		// Shift remaining elements right
		for (INT i = InsertIdx + 1; i < Count; i++)
		{
			ANavigationPoint* TempPath = Paths[i];
			INT TempCost = Costs[i];
			Paths[i] = SavedPath;
			Costs[i] = SavedCost;
			SavedPath = TempPath;
			SavedCost = TempCost;
		}
	}
}
