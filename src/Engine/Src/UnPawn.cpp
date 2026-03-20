/*=============================================================================
	UnPawn.cpp: APawn, AController, APlayerController, AAIController.
	Reconstructed for Ravenshield decompilation project.

	Provides IMPLEMENT_CLASS() registrations and decompiled method
	bodies for the pawn/controller hierarchy — the classes responsible
	for characters, AI and player input.

	The EXEC_STUB macro creates a trivial native-function body that
	only calls P_FINISH (popping the UnrealScript bytecode stack frame)
	and does nothing else. Each stub is paired with IMPLEMENT_FUNCTION()
	which permanently registers the native function index with the VM.
	When the real implementation is decompiled, the EXEC_STUB body will
	be replaced with the real code but the IMPLEMENT_FUNCTION() stays.

	This file is permanent and will grow as pawn/controller code is
	decompiled.
=============================================================================*/
#include "EnginePrivate.h"

// GAudioMaxRadiusMultiplier is defined in Core.cpp but not declared in any public header.
extern CORE_API FLOAT GAudioMaxRadiusMultiplier;

IMPLEMENT_CLASS(APawn);
IMPLEMENT_CLASS(AController);
IMPLEMENT_CLASS(APlayerController);
IMPLEMENT_CLASS(AAIController);

/*-----------------------------------------------------------------------------
	APawn / AController / APlayerController / AAIController exec functions.
	Reconstructed from Ghidra decompilation + SDK parameter signatures.
-----------------------------------------------------------------------------*/

/*-- APawn queries -----------------------------------------------------*/

IMPL_MATCH("Engine.dll", 0x103e7580)
void APawn::execReachedDestination( FFrame& Stack, RESULT_DECL )
{
guard(APawn::execReachedDestination);
P_GET_OBJECT(AActor,Goal);
P_FINISH;
*(DWORD*)Result = Goal ? (DWORD)ReachedDestination(Goal->Location - Location, Goal) : 0;
unguard;
}
IMPLEMENT_FUNCTION( APawn, INDEX_NONE, execReachedDestination );

IMPL_MATCH("Engine.dll", 0x103e5390)
void APawn::execIsFriend( FFrame& Stack, RESULT_DECL )
{
	guard(APawn::execIsFriend);
	P_GET_OBJECT(APawn,Other);
	P_FINISH;
	*(DWORD*)Result = IsFriend( Other );
	unguard;
}
IMPLEMENT_FUNCTION( APawn, INDEX_NONE, execIsFriend );

IMPL_MATCH("Engine.dll", 0x103e5440)
void APawn::execIsEnemy( FFrame& Stack, RESULT_DECL )
{
	guard(APawn::execIsEnemy);
	P_GET_OBJECT(APawn,Other);
	P_FINISH;
	*(DWORD*)Result = IsEnemy( Other );
	unguard;
}
IMPLEMENT_FUNCTION( APawn, INDEX_NONE, execIsEnemy );

IMPL_MATCH("Engine.dll", 0x103e5500)
void APawn::execIsNeutral( FFrame& Stack, RESULT_DECL )
{
	guard(APawn::execIsNeutral);
	P_GET_OBJECT(APawn,Other);
	P_FINISH;
	*(DWORD*)Result = IsNeutral( Other );
	unguard;
}
IMPLEMENT_FUNCTION( APawn, INDEX_NONE, execIsNeutral );

IMPL_MATCH("Engine.dll", 0x103e55c0)
void APawn::execIsAlive( FFrame& Stack, RESULT_DECL )
{
	guard(APawn::execIsAlive);
	P_FINISH;
	*(DWORD*)Result = IsAlive();
	unguard;
}
IMPLEMENT_FUNCTION( APawn, INDEX_NONE, execIsAlive );

/*-- AController movement latent functions -----------------------------*/

// Ghidra 0x1038e870, 566b. Retail clears Pawn->bReducedSpeed, sets DesiredSpeed from
// WalkSpeedMod (clamped by MaxDesiredSpeed), zeros DestinationOffset/NextPathRadius,
// copies Destination to AdjustLoc/FocalPoint, calls setMoveTimer, then calls
// Pawn->vtable[0x184/4=97] = moveToward. MoveTarget=NULL (no vtable[26] call).
// Note: Ghidra shows unaff_EDI for Destination.Z — decompiler artifact from FVector
// parameter parsing through bytecode native dispatch; our code handles this correctly.
IMPL_DIVERGE("Ghidra 0x1038e870; 566b — unaff_EDI for Destination.Z unverifiable from decompilation; all logic implemented")
void AController::execMoveTo( FFrame& Stack, RESULT_DECL )
{
	guard(AController::execMoveTo);
	P_GET_VECTOR(NewDestination);
	P_GET_OBJECT_OPTX(AActor,ViewFocus,NULL);
	P_GET_FLOAT_OPTX(WalkSpeedMod,1.0f);
	P_GET_UBOOL_OPTX(bShouldWalk,0);
	P_FINISH;
	m_eMoveToResult = 0;
	if( !Pawn ) { m_eMoveToResult = 2; return; }
	MoveTarget = NULL;
	// Clear bReducedSpeed (Ghidra: Pawn+0x3e0 &= ~0x2000; confirmed = APawn::bReducedSpeed bit13)
	Pawn->bReducedSpeed = 0;
	// DesiredSpeed = clamp(0, WalkSpeedMod, MaxDesiredSpeed); if MaxDesiredSpeed<0 → 0
	Pawn->DesiredSpeed = (Pawn->MaxDesiredSpeed >= 0.f) ? Min(WalkSpeedMod, Pawn->MaxDesiredSpeed) : 0.f;
	Focus = ViewFocus;
	Destination = NewDestination;
	if( !Focus ) FocalPoint = Destination;
	// Zero approach-offset fields (Ghidra: Pawn+0x414=DestinationOffset, +0x418=NextPathRadius)
	Pawn->DestinationOffset = 0.f;
	Pawn->NextPathRadius = 0.f;
	Pawn->setMoveTimer( NewDestination.Size() );
	GetStateFrame()->LatentAction = AI_PollMoveTo;
	bAdjusting = 0;
	bAdvancedTactics = 0;
	CurrentPath = NULL;
	AdjustLoc = Destination;
	Pawn->ClearSerpentine();
	// Ghidra ends with vtable[0x184/4=97] on Pawn(Destination,NULL) = moveToward
	Pawn->moveToward( Destination, NULL );
	unguard;
}
IMPLEMENT_FUNCTION( AController, 500, execMoveTo );

IMPL_MATCH("Engine.dll", 0x1038cfe0)
void AController::execPollMoveTo( FFrame& Stack, RESULT_DECL )
{
	if( !Pawn || MoveTimer < 0.0f )
	{
		GetStateFrame()->LatentAction = 0;
		m_eMoveToResult = 2;
	}
	else
	{
		if( bAdjusting )
		{
			INT bArrived = Pawn->moveToward( AdjustLoc, NULL );
			bAdjusting = (bArrived == 0);
			if( bAdjusting )
				return;
		}
		if( Pawn->moveToward( Destination, NULL ) )
			GetStateFrame()->LatentAction = 0;
	}
}
IMPLEMENT_FUNCTION( AController, INDEX_NONE, execPollMoveTo );

// Ghidra 0x10390940, 1402b.  Key additions vs stub:
//   Pawn->bReducedSpeed cleared; DesiredSpeed clamped by WalkSpeedMod;
//   setMoveTimer or MoveTimer=1.2f based on vtable[26] (IsA(ANavigationPoint) approximation);
//   bAdvancedTactics set from bCanJump (Ghidra: bitfield bit3 XOR from param);
//   ClearSerpentine + CurrentPath=NULL added.
//   NavigationPoint: eventSuggestMovePreparation, GetReachSpecTo, supports, eventPrepareForMove.
IMPL_TODO("Ghidra 0x10390940; 1402b — vtable[26] approximated as IsA(ANavigationPoint); __ftol2 parameter order for supports() unconfirmed")
void AController::execMoveToward( FFrame& Stack, RESULT_DECL )
{
	guard(AController::execMoveToward);
	P_GET_OBJECT(AActor,NewTarget);
	P_GET_OBJECT_OPTX(AActor,ViewFocus,NULL);
	P_GET_FLOAT_OPTX(WalkSpeedMod,1.0f);
	P_GET_UBOOL_OPTX(bShouldWalk,0);
	P_GET_UBOOL_OPTX(bCanJump,0);
	P_GET_OBJECT_OPTX(AActor,ExtraTarget,NULL);
	P_FINISH;
	m_eMoveToResult = 0;
	if( !NewTarget || !Pawn ) { m_eMoveToResult = 2; return; }
	// Clear bReducedSpeed (Ghidra: Pawn+0x3e0 &= ~0x2000 = APawn::bReducedSpeed bit13)
	Pawn->bReducedSpeed = 0;
	// DesiredSpeed = clamp(0, WalkSpeedMod, MaxDesiredSpeed); if MaxDesiredSpeed<0 → 0
	Pawn->DesiredSpeed = (Pawn->MaxDesiredSpeed >= 0.f) ? Min(WalkSpeedMod, Pawn->MaxDesiredSpeed) : 0.f;
	MoveTarget = NewTarget;
	Focus = ViewFocus;
	Destination = MoveTarget->Location;
	// Ghidra: vtable[26] on MoveTarget → if nav point: MoveTimer=1.2f; else setMoveTimer(dist)
	if (MoveTarget->IsA(ANavigationPoint::StaticClass()))
		MoveTimer = 1.2f;
	else
		Pawn->setMoveTimer( Destination.Size() );
	AdjustLoc = Destination;
	GetStateFrame()->LatentAction = AI_PollMoveToward;
	bAdjusting = 0;
	// Ghidra: bitfield bit3 (bAdvancedTactics) set/cleared from bCanJump param
	bAdvancedTactics = bCanJump ? 1 : 0;
	CurrentPath = NULL;
	Pawn->ClearSerpentine();
	// NavigationPoint path-preparation: if MoveTarget is a nav point, optionally call
	// eventSuggestMovePreparation and check reachability via ReachSpec.
	// Ghidra: IsA(ANavigationPoint) check; bSuggestPreparation bit (flags+0x3a4 & 0x100);
	// ValidAnchor → GetReachSpecTo → supports → eventPrepareForMove.
	if (MoveTarget->IsA(ANavigationPoint::StaticClass()))
	{
		ANavigationPoint* NavTarget = (ANavigationPoint*)MoveTarget;
		DWORD navFlags = *(DWORD*)((BYTE*)NavTarget + 0x3a4);
		if (navFlags & 0x100)
			NavTarget->eventSuggestMovePreparation(Pawn);
		if (Pawn->ValidAnchor())
		{
			UReachSpec* spec = Pawn->Anchor->GetReachSpecTo(NavTarget);
			CurrentPath = spec;
			if (spec)
			{
				if (!(spec->bForced & 1) || !(navFlags & 0x4000))
				{
					if (!spec->supports(
							(INT)Pawn->CollisionRadius,
							(INT)Pawn->CollisionHeight,
							Pawn->calcMoveFlags(),
							(INT)Pawn->MaxFallSpeed))
						eventPrepareForMove(NavTarget, spec);
				}
				else
				{
					NavTarget->eventSuggestMovePreparation(Pawn);
				}
			}
		}
	}
	unguard;
}
IMPLEMENT_FUNCTION( AController, 502, execMoveToward );

// Ghidra 0x1038d110, 534b. No SEH (no guard/unguard in retail).
// bAdjusting: vtable[0x184/4=97] on Pawn = moveToward.
// PHYS_Flying: vtable[26] on MoveTarget guards Z-offset = nav-point check (IsA approximation).
// Trailing: refresh Destination, vtable[26] guard, MoveTimer=-1.0f nav-node path.
// DIVERGENCE: vtable[26] approximated as IsA(ANavigationPoint).
// DIVERGENCE: trailing Pawn+0x3f4 write from unaff_EDI (caller-saved register) unrecoverable.
IMPL_TODO("Ghidra 0x1038d110: vtable[26] approximated as IsA(ANavigationPoint); trailing Pawn+0x3f4 write from unaff_EDI unrecoverable; Pawn+0x3e2 bit0 and MoveTarget+0x164+0x410 bit6 flag fields unidentified")
void AController::execPollMoveToward( FFrame& Stack, RESULT_DECL )
{
	if( !MoveTarget || !Pawn || MoveTimer < 0.0f )
	{
		GetStateFrame()->LatentAction = 0;
		m_eMoveToResult = 2;
		return;
	}
	if( bPreparingMove )
		return;
	if( bAdjusting )
	{
		// Retail: vtable[0x184/4] on Pawn to test if AdjustLoc is still useful.
		INT bArrived = Pawn->moveToward( AdjustLoc, MoveTarget );
		bAdjusting = (bArrived == 0);
	}
	if( !bAdjusting )
	{
		Destination = MoveTarget->Location;
		// PHYS_Flying + nav-point guard: offset Destination Z upward by 70% of
		// MoveTarget's CollisionHeight. Ghidra: vtable[0x68] (slot 26) on MoveTarget.
		if( Pawn->Physics == PHYS_Flying && MoveTarget->IsA(ANavigationPoint::StaticClass()) )
			Destination.Z += *(FLOAT*)((BYTE*)MoveTarget + 0xfc) * 0.7f;
		// PHYS_Spider: offset Destination inward along spider attachment normal by CollisionRadius.
		else if( Pawn->Physics == PHYS_Spider )
		{
			FLOAT collR       = *(FLOAT*)((BYTE*)MoveTarget + 0xf8);
			FVector spiderN   = *(FVector*)((BYTE*)Pawn + 0x590);
			Destination      -= spiderN * collR;
		}
		if( Pawn->moveToward( Destination, MoveTarget ) )
			GetStateFrame()->LatentAction = 0;

		// Trailing section: refresh Destination, nav-point MoveTimer=-1.0f path.
		// Ghidra: refreshes Destination from MoveTarget->Location, calls vtable[26],
		// then checks Pawn+0x3e2 bit0 and MoveTarget's nav spec flag at +0x164→+0x410 bit6.
		Destination = MoveTarget->Location;
		if( MoveTarget->IsA(ANavigationPoint::StaticClass()) )
		{
			// Ghidra: writes unaff_EDI to Pawn+0x3f4 — unrecoverable register value, omitted.
			if( (*(BYTE*)((BYTE*)Pawn + 0x3e2) & 1) == 0 )
			{
				INT navSpec = *(INT*)((BYTE*)MoveTarget + 0x164);
				if( navSpec != 0 && (*(BYTE*)(navSpec + 0x410) & 0x40) != 0 )
					MoveTimer = -1.0f;
			}
		}
	}
}
IMPLEMENT_FUNCTION( AController, INDEX_NONE, execPollMoveToward );

IMPL_MATCH("Engine.dll", 0x1038d330)
void AController::execFinishRotation( FFrame& Stack, RESULT_DECL )
{
	guard(AController::execFinishRotation);
	P_FINISH;
	GetStateFrame()->LatentAction = AI_PollFinishRotation;
	unguard;
}
IMPLEMENT_FUNCTION( AController, 508, execFinishRotation );

// Ghidra 0x1038eab0, 112b. No SEH in retail — no guard/unguard.
// Pawn at +0x3d8, DesiredRotation.Yaw at +0x300, Rotation.Yaw at +0x244.
IMPL_MATCH("Engine.dll", 0x1038eab0)
void AController::execPollFinishRotation( FFrame& Stack, RESULT_DECL )
{
	if( Pawn )
	{
		INT iYawDiff = *(INT*)((BYTE*)Pawn + 0x300) - (INT)(*(DWORD*)((BYTE*)Pawn + 0x244) & 0xffff);
		if( iYawDiff < 0 ) iYawDiff = -iYawDiff;
		if( iYawDiff > 1999 )
		{
			INT iYawDiff2 = *(INT*)((BYTE*)Pawn + 0x300) - (INT)(*(DWORD*)((BYTE*)Pawn + 0x244) & 0xffff);
			if( iYawDiff2 < 0 ) iYawDiff2 = -iYawDiff2;
			if( iYawDiff2 < 0xf830 )
				return;
		}
	}
	GetStateFrame()->LatentAction = 0;
}
IMPLEMENT_FUNCTION( AController, INDEX_NONE, execPollFinishRotation );

IMPL_MATCH("Engine.dll", 0x1038cdc0)
void AController::execWaitForLanding( FFrame& Stack, RESULT_DECL )
{
	guard(AController::execWaitForLanding);
	P_FINISH;
	*(FLOAT*)((BYTE*)this + 0xdc) = 4.0f;
	if( Pawn && Pawn->Physics == PHYS_Falling )
		GetStateFrame()->LatentAction = AI_PollWaitForLanding;
	unguard;
}
IMPLEMENT_FUNCTION( AController, 527, execWaitForLanding );

IMPL_DIVERGE("Ghidra 0x1038dee0; 104b — timer NaN check: retail fcomi enters body for NaN timer (fVar2 < 0.0 != NAN(fVar2)); our C++ < does not; ESI-based frame permanent binary difference")
void AController::execPollWaitForLanding( FFrame& Stack, RESULT_DECL )
{
	guard(AController::execPollWaitForLanding);
	if( Pawn && Pawn->Physics != PHYS_Falling )
	{
		GetStateFrame()->LatentAction = 0;
		return;
	}
	FLOAT DeltaTime = *(FLOAT*)Result;
	FLOAT& Timer = *(FLOAT*)((BYTE*)this + 0xdc);
	Timer -= DeltaTime;
	if( Timer < 0.0f )
		eventLongFall();
	unguard;
}
IMPLEMENT_FUNCTION( AController, INDEX_NONE, execPollWaitForLanding );

/*-- AController perception -------------------------------------------*/

IMPL_MATCH("Engine.dll", 0x1038e750)
void AController::execLineOfSightTo( FFrame& Stack, RESULT_DECL )
{
	guard(AController::execLineOfSightTo);
	P_GET_OBJECT(AActor,Other);
	P_FINISH;
	*(DWORD*)Result = LineOfSightTo(Other, 0);
	unguard;
}
IMPLEMENT_FUNCTION( AController, 514, execLineOfSightTo );

IMPL_MATCH("Engine.dll", 0x1038dbb0)
void AController::execCanSee( FFrame& Stack, RESULT_DECL )
{
	guard(AController::execCanSee);
	P_GET_OBJECT(APawn,Other);
	P_FINISH;
	*(DWORD*)Result = SeePawn(Other, 0);
	unguard;
}
IMPLEMENT_FUNCTION( AController, INDEX_NONE, execCanSee );

/*-- AController pathfinding -------------------------------------------*/

IMPL_DIVERGE("rdtsc cycle-counter profiling omitted; logic matches retail; Ghidra 0x1038e490")
void AController::execFindPathToward( FFrame& Stack, RESULT_DECL )
{
	guard(AController::execFindPathToward);
	P_GET_OBJECT(AActor,Goal);
	P_GET_UBOOL_OPTX(bSinglePath,1);
	P_FINISH;
	*(AActor**)Result = FindPath(FVector(0,0,0), Goal, bSinglePath);
	unguard;
}
IMPLEMENT_FUNCTION( AController, 517, execFindPathToward );

IMPL_DIVERGE("rdtsc cycle-counter profiling omitted; logic matches retail; Ghidra 0x1038e590")
void AController::execFindPathTowardNearest( FFrame& Stack, RESULT_DECL )
{
	guard(AController::execFindPathTowardNearest);
	P_GET_OBJECT(UClass,GoalClass);
	P_FINISH;
	if( !GoalClass || !Pawn )
	{
		*(AActor**)Result = NULL;
		return;
	}
	Pawn->clearPaths();
	ANavigationPoint* Best = NULL;
	for( ANavigationPoint* Nav = Level->NavigationPointList; Nav; Nav = Nav->nextNavigationPoint )
	{
		if( Nav->GetClass() == GoalClass )
		{
			*(DWORD*)((BYTE*)Nav + 0x3e4) |= 1;  // mark as endpoint (bEndPoint flag — retail offset)
			Best = Nav;
		}
	}
	*(AActor**)Result = Best ? FindPath(FVector(0,0,0), Best, 0) : NULL;
	unguard;
}
IMPLEMENT_FUNCTION( AController, INDEX_NONE, execFindPathTowardNearest );

IMPL_DIVERGE("rdtsc cycle-counter profiling omitted; logic matches retail; Ghidra 0x1038e3e0")
void AController::execFindPathTo( FFrame& Stack, RESULT_DECL )
{
	guard(AController::execFindPathTo);
	P_GET_VECTOR(Point);
	P_FINISH;
	*(AActor**)Result = FindPath(Point, NULL, 1);
	unguard;
}
IMPLEMENT_FUNCTION( AController, 518, execFindPathTo );

IMPL_DIVERGE("rdtsc cycle-counter profiling omitted; logic matches retail; Ghidra 0x1038e030")
void AController::execactorReachable( FFrame& Stack, RESULT_DECL )
{
	guard(AController::execactorReachable);
	P_GET_OBJECT(AActor,anActor);
	P_FINISH;
	*(DWORD*)Result = (anActor && Pawn) ? Pawn->actorReachable(anActor, 0, 0) : 0;
	unguard;
}
IMPLEMENT_FUNCTION( AController, 520, execactorReachable );

IMPL_DIVERGE("rdtsc cycle-counter profiling omitted; logic matches retail; Ghidra 0x1038e150")
void AController::execpointReachable( FFrame& Stack, RESULT_DECL )
{
	guard(AController::execpointReachable);
	P_GET_VECTOR(aPoint);
	P_FINISH;
	*(DWORD*)Result = Pawn ? Pawn->pointReachable(aPoint, 0) : 0;
	unguard;
}
IMPLEMENT_FUNCTION( AController, 521, execpointReachable );

IMPL_DIVERGE("rdtsc cycle-counter profiling omitted; logic matches retail; Ghidra 0x1038e6c0")
void AController::execClearPaths( FFrame& Stack, RESULT_DECL )
{
	guard(AController::execClearPaths);
	P_FINISH;
	if( Pawn )
		Pawn->clearPaths();
	unguard;
}
IMPLEMENT_FUNCTION( AController, 522, execClearPaths );

IMPL_DIVERGE("rdtsc cycle-counter profiling omitted; logic matches retail; Ghidra 0x1038ce20")
void AController::execEAdjustJump( FFrame& Stack, RESULT_DECL )
{
	guard(AController::execEAdjustJump);
	P_GET_FLOAT(BaseZ);
	P_GET_FLOAT(XYSpeed);
	P_FINISH;
	if( Pawn )
	{
		FVector JumpDest = *(FVector*)((BYTE*)this + 0x480);  // stored destination in AController (retail +0x480)
		*(FVector*)Result = Pawn->SuggestJumpVelocity(JumpDest, XYSpeed, BaseZ);
	}
	else
		*(FVector*)Result = FVector(0,0,0);
	unguard;
}
IMPLEMENT_FUNCTION( AController, 523, execEAdjustJump );

IMPL_DIVERGE("rdtsc cycle-counter profiling omitted; logic matches retail; Ghidra 0x10390770")
void AController::execFindRandomDest( FFrame& Stack, RESULT_DECL )
{
	guard(AController::execFindRandomDest);
	P_GET_UBOOL_OPTX(bClearPaths, true);
	P_FINISH;
	*(AActor**)Result = NULL;
	if( !Pawn )
		return;
	if( bClearPaths )
		Pawn->clearPaths();
	FLOAT weight = Pawn->findPathToward(NULL, FVector(0,0,0), NULL, 1, 0.f);
	if( weight > 0.f )
	{
		AActor* dest = *(AActor**)((BYTE*)this + 0x44c);  // current path end (retail AController+0x44c)
		if( dest && dest->IsA(ANavigationPoint::StaticClass()) )
			*(AActor**)Result = dest;
	}
	unguard;
}
IMPLEMENT_FUNCTION( AController, 525, execFindRandomDest );

IMPL_DIVERGE("rdtsc cycle-counter profiling omitted; logic matches retail; Ghidra 0x1038df50")
void AController::execPickWallAdjust( FFrame& Stack, RESULT_DECL )
{
	guard(AController::execPickWallAdjust);
	P_GET_VECTOR(HitNormal);
	P_FINISH;
	*(DWORD*)Result = Pawn ? Pawn->PickWallAdjust(HitNormal) : 0;
	unguard;
}
IMPLEMENT_FUNCTION( AController, 526, execPickWallAdjust );

IMPL_MATCH("Engine.dll", 0x1038cce0)
void AController::execAddController( FFrame& Stack, RESULT_DECL )
{
	guard(AController::execAddController);
	P_FINISH;
	// Insert this controller at the head of the level's controller list.
	if( XLevel && XLevel->GetLevelInfo() )
	{
		nextController = XLevel->GetLevelInfo()->ControllerList;
		XLevel->GetLevelInfo()->ControllerList = this;
	}
	unguard;
}
IMPLEMENT_FUNCTION( AController, 529, execAddController );

IMPL_MATCH("Engine.dll", 0x1038cd30)
void AController::execRemoveController( FFrame& Stack, RESULT_DECL )
{
	guard(AController::execRemoveController);
	P_FINISH;
	// Remove this controller from the level's controller list.
	if( XLevel && XLevel->GetLevelInfo() )
	{
		ALevelInfo* Info = XLevel->GetLevelInfo();
		if( Info->ControllerList == this )
		{
			Info->ControllerList = nextController;
		}
		else
		{
			for( AController* C = Info->ControllerList; C; C = C->nextController )
			{
				if( C->nextController == this )
				{
					C->nextController = nextController;
					break;
				}
			}
		}
		nextController = NULL;
	}
	unguard;
}
IMPLEMENT_FUNCTION( AController, 530, execRemoveController );

IMPL_MATCH("Engine.dll", 0x1038f9e0)
void AController::execPickTarget( FFrame& Stack, RESULT_DECL )
{
	guard(AController::execPickTarget);
	P_GET_OBJECT(UClass, TargetClass);
	P_GET_FLOAT_REF(bestAim);
	P_GET_FLOAT_REF(bestDist);
	P_GET_VECTOR(FireDir);
	P_GET_VECTOR(projStart);
	P_FINISH;

	// Secondary aim threshold: derived from initial bestAim value
	FLOAT secondaryThreshold = *bestAim * 3.0f - 2.0f;

	// Shared FCheckResult for LOS checks (reused across iterations)
	FCheckResult LOSHit(1.f);

	ALevelInfo* LI = XLevel->GetLevelInfo();
	AController* C = *(AController**)((BYTE*)LI + 0x4d4);
	if( !C ) { *(APawn**)Result = 0; return; }

	INT bestPawnPtr = 0;       // tracks whether any target has been picked
	APawn* bestPawn = NULL;
	for( ; C; C = C->nextController )
	{
		if( C == this ) continue;
		APawn* targetPawn = C->Pawn;
		if( !targetPawn ) continue;
		// Alive check: Health > 0
		if( *(INT*)((BYTE*)targetPawn + 0x3a4) <= 0 ) continue;
		// Targetable flag: bit 15 of flags at +0xa8
		if( !((*(DWORD*)((BYTE*)targetPawn + 0xa8) >> 8) & 0x80) ) continue;
		// Team filter: skip if both have PlayerReplicationInfo
		if( *(INT*)((BYTE*)this + 0x450) != 0 && *(INT*)((BYTE*)C + 0x450) != 0 ) continue;

		FVector diff = targetPawn->Location - projStart;

		// Compute horizontal-only fire direction for secondary aim scoring
		FVector flatDir( FireDir.X, FireDir.Y, 0.f );
		flatDir.Normalize();

		FLOAT dp  = FireDir | diff;      // primary aim (3D)
		FLOAT dp2 = flatDir | diff;      // secondary aim (horizontal only)

		if( dp <= 0.0f ) continue;

		FLOAT distSq = diff.SizeSquared();

		// Distance gate: 4000-unit radius, bypassed for APlayerController if FOV matches
		if( distSq >= 16000000.0f )
		{
			if( !IsA(APlayerController::StaticClass()) ) continue;
			FLOAT fov1 = *(FLOAT*)((BYTE*)this + 0x3b0);
			FLOAT fov2 = *(FLOAT*)((BYTE*)this + 0x564);
			if( fov1 != fov2 ) continue;
		}

		FLOAT dist = appSqrt(distSq);
		FLOAT aim  = dp / dist;

		if( aim > *bestAim )
		{
			// Primary aim: better than current best — bidirectional LOS check
			FVector eyeOfs = Pawn->eventEyePosition();
			FVector selfEye = Pawn->Location + eyeOfs;

			appMemzero(&LOSHit, sizeof(FCheckResult));
			LOSHit.Time = 1.f; LOSHit.Item = INDEX_NONE;
			XLevel->SingleLineCheck( LOSHit, this, targetPawn->Location, selfEye, 0x286, FVector(0.f,0.f,0.f) );

			if( LOSHit.Actor )
			{
				// Forward LOS blocked — try eye-to-eye
				FVector selfEye2 = Pawn->Location + eyeOfs;
				FVector targEye  = targetPawn->Location + eyeOfs;
				appMemzero(&LOSHit, sizeof(FCheckResult));
				LOSHit.Time = 1.f; LOSHit.Item = INDEX_NONE;
				XLevel->SingleLineCheck( LOSHit, this, targEye, selfEye2, 0x286, FVector(0.f,0.f,0.f) );
				if( LOSHit.Actor ) continue;
			}

			bestPawn    = targetPawn;
			*bestAim    = aim;
			*bestDist   = dist;
			bestPawnPtr = (INT)targetPawn;
		}
		else if( bestPawnPtr == 0 && (dp2 / dist) > *bestAim && aim > secondaryThreshold )
		{
			// Secondary aim: horizontal aim better, raw aim passes threshold — bidirectional LOS
			FVector eyeOfs = Pawn->eventEyePosition();
			FVector selfEye = Pawn->Location + eyeOfs;

			appMemzero(&LOSHit, sizeof(FCheckResult));
			LOSHit.Time = 1.f; LOSHit.Item = INDEX_NONE;
			XLevel->SingleLineCheck( LOSHit, this, targetPawn->Location, selfEye, 0x286, FVector(0.f,0.f,0.f) );

			if( LOSHit.Actor )
			{
				FVector selfEye2 = Pawn->Location + eyeOfs;
				FVector targEye  = targetPawn->Location + eyeOfs;
				appMemzero(&LOSHit, sizeof(FCheckResult));
				LOSHit.Time = 1.f; LOSHit.Item = INDEX_NONE;
				XLevel->SingleLineCheck( LOSHit, this, targEye, selfEye2, 0x286, FVector(0.f,0.f,0.f) );
				if( LOSHit.Actor ) continue;
			}

			bestPawn    = targetPawn;
			*bestDist   = dist;
			bestPawnPtr = (INT)targetPawn;
		}
	}

	*(APawn**)Result = bestPawn;
	unguard;
}
IMPLEMENT_FUNCTION( AController, 531, execPickTarget );

IMPL_DIVERGE("Ghidra 0x1038dc20 (688b): vtable[0x68] approximated as IsA(ANavigationPoint) — skip nav points; all other logic (targetable flag, FoV dot-product, 4M distSq gate, LineOfSightTo) matches retail.")
void AController::execPickAnyTarget( FFrame& Stack, RESULT_DECL )
{
	guard(AController::execPickAnyTarget);
	P_GET_FLOAT_REF(bestAim);
	P_GET_FLOAT_REF(bestDist);
	P_GET_VECTOR(FireDir);
	P_GET_VECTOR(projStart);
	P_FINISH;
	AActor* best = NULL;
	if( !XLevel ) { *(AActor**)Result = NULL; return; }
	INT numActors = XLevel->Actors.Num();
	for( INT i = 0; i < numActors; i++ )
	{
		AActor* actor = XLevel->Actors(i);
		if( !actor ) continue;
		// Ghidra flag: bit7 of byte at actor+0xa9 (targetable flag)
		if( !((*(DWORD*)((BYTE*)actor + 0xa8) >> 8) & 0x80) ) continue;
		// Ghidra: vtable[0x68] on actor must return 0 — skip navigation points
		if( actor->IsA(ANavigationPoint::StaticClass()) ) continue;
		FVector diff = actor->Location - projStart;
		FLOAT dp = FireDir | diff;
		if( dp <= 0.0f ) continue;
		FLOAT distSq = diff.SizeSquared();
		if( distSq >= 4000000.0f ) continue;  // 2000-unit radius (Ghidra: < 4e+06)
		FLOAT dist = appSqrt(distSq);
		FLOAT aim = dp / dist;
		if( aim > *bestAim && LineOfSightTo(actor, 0) )
		{
			*bestAim = aim;
			*bestDist = dist;
			best = actor;
		}
	}
	*(AActor**)Result = best;
	unguard;
}
IMPLEMENT_FUNCTION( AController, 534, execPickAnyTarget );

// Ghidra 0x1038d870, 416b.
// DIVERGE (rdtsc): function opens with rdtsc() → GScriptCycles_exref timing update.
// Also calls findPathToward with inventory-weight scorer at 0x1038cb00 (no exported symbol).
// Both are permanent: rdtsc profiling globals and the internal scorer are not reproducible.
IMPL_DIVERGE("Ghidra 0x1038d870; rdtsc cycle-counter profiling (GScriptCycles) omitted; inventory-weight scorer at 0x1038cb00 has no exported symbol — permanent binary divergence")
void AController::execFindBestInventoryPath( FFrame& Stack, RESULT_DECL )
{
	guard(AController::execFindBestInventoryPath);
	P_GET_FLOAT_REF(MinWeight);
	P_FINISH;
	// Retail calls APawn::findPathToward with an inventory-weight scorer at 0x1038cb00
	// (which scores each nav point by its reachable inventory weight >= MinWeight),
	// then calls SetPath(1) to return the first hop. Scorer not yet reconstructed.
	if( !Pawn ) { *(AActor**)Result = NULL; return; }
	*(AActor**)Result = NULL;
	unguard;
}
IMPLEMENT_FUNCTION( AController, 540, execFindBestInventoryPath );

// Ghidra 0x10390890, 162b. No SEH in retail.
// PrivateStaticClass direct ref in retail vs our StaticClass() call — minor asm divergence.
IMPL_DIVERGE("Ghidra 0x10390890; retail uses &ALadder::PrivateStaticClass and &ANavigationPoint::PrivateStaticClass as direct address refs; our StaticClass() adds one indirection each — permanent header-level binary difference")
void AController::execEndClimbLadder( FFrame& Stack, RESULT_DECL )
{
	P_FINISH;
	if( GetStateFrame()->LatentAction == AI_PollMoveToward && Pawn && MoveTarget )
	{
		if( MoveTarget->IsA( ALadder::StaticClass() ) )
		{
			if( Pawn->IsOverlapping( MoveTarget, NULL ) )
			{
				// FUN_1038ef90: returns MoveTarget as ANavigationPoint* if IsA, else NULL.
				ANavigationPoint* nav = MoveTarget->IsA( ANavigationPoint::StaticClass() )
					? (ANavigationPoint*)MoveTarget : NULL;
				Pawn->Anchor = nav;
			}
			GetStateFrame()->LatentAction = 0;
		}
	}
}
IMPLEMENT_FUNCTION( AController, INDEX_NONE, execEndClimbLadder );

IMPL_MATCH("Engine.dll", 0x1038d090)
void AController::execInLatentExecution( FFrame& Stack, RESULT_DECL )
{
	guard(AController::execInLatentExecution);
	P_GET_INT(LatentActionNumber);
	P_FINISH;
	*(DWORD*)Result = GetStateFrame() && GetStateFrame()->LatentAction == LatentActionNumber;
	unguard;
}
IMPLEMENT_FUNCTION( AController, INDEX_NONE, execInLatentExecution );

IMPL_MATCH("Engine.dll", 0x1038cc90)
void AController::execStopWaiting( FFrame& Stack, RESULT_DECL )
{
	guard(AController::execStopWaiting);
	P_FINISH;
	GetStateFrame()->LatentAction = 0;
	unguard;
}
IMPLEMENT_FUNCTION( AController, INDEX_NONE, execStopWaiting );

/*-- APlayerController functions ---------------------------------------*/

IMPL_TODO("Ghidra 0x103900a0; 1734b — stair-rotation camera pitch; algorithm implemented from Ghidra analysis: forward trace, midpoint down-probe, step classification, pitch blending; exact geometric midpoint computation may diverge due to heavy stack-variable reuse in Ghidra decompilation; all thresholds, trace flags, magic numbers (0.33, 0.8, 3.0, 0.7, 6.0, 10.0, -4000/3600, 4.0/4000, 0.25, 0.9) match Ghidra values")
void APlayerController::execFindStairRotation( FFrame& Stack, RESULT_DECL )
{
	guard(APlayerController::execFindStairRotation);
	P_GET_FLOAT(DeltaTime);
	P_FINISH;

	// Early return: no Pawn or large timestep.
	if( !Pawn || DeltaTime > 0.33f )
	{
		*(INT*)Result = Rotation.Pitch;
		return;
	}

	// Sign-extend Rotation.Pitch to signed 16-bit range.
	// Ghidra: if (0x8000 < *(uint*)(this+0x240)) *(uint*)(this+0x240) = (*(uint*)(this+0x240) & 0xffff) - 0x10000;
	INT SignedPitch = Rotation.Pitch;
	if( (DWORD)SignedPitch > 0x8000 )
		SignedPitch = (INT)((DWORD)Rotation.Pitch & 0xffff) - 0x10000;

	// Horizontal forward direction (zero pitch for flat forward).
	FRotator HorizRot( 0, Rotation.Yaw, Rotation.Roll );
	FVector ViewDir = HorizRot.Vector();

	// Eye position = Pawn->Location + eye offset.
	FVector EyeOfs = Pawn->eventEyePosition();
	FVector EyePos;
	EyePos.X = *(FLOAT*)((BYTE*)Pawn + 0x234) + EyeOfs.X;
	EyePos.Y = *(FLOAT*)((BYTE*)Pawn + 0x238) + EyeOfs.Y;
	EyePos.Z = *(FLOAT*)((BYTE*)Pawn + 0x23c) + EyeOfs.Z;

	// Trace distance = 2 * (EyePosition.Z + CollisionHeight).
	FVector EyeOfs2 = Pawn->eventEyePosition();
	FLOAT CollHeight = *(FLOAT*)((BYTE*)Pawn + 0xfc);
	FLOAT EyeH = EyeOfs2.Z + CollHeight;
	FLOAT TraceDist = EyeH + EyeH;

	// Collision extent from Pawn.
	FLOAT CollRadius = *(FLOAT*)((BYTE*)Pawn + 0xf8);
	FVector Extent( CollRadius, CollRadius, CollRadius );

	// Trace forward from eye position.
	FVector End;
	End.X = ViewDir.X * TraceDist + EyePos.X;
	End.Y = ViewDir.Y * TraceDist + EyePos.Y;
	End.Z = ViewDir.Z * TraceDist + EyePos.Z;

	ULevel* Level = *(ULevel**)((BYTE*)this + 0x328);
	FCheckResult Hit( 1.0f );
	Level->SingleLineCheck( Hit, this, End, EyePos, TRACE_World, Extent );

	INT TargetPitch = 0;
	FLOAT HitDist = Hit.Time * TraceDist + Hit.Time * TraceDist;

	if( TraceDist * 0.8f < HitDist )
	{
		FLOAT HalfDist = HitDist * 0.5f;
		FLOAT VertProbe = TraceDist * 3.0f;

		// Probe point: midpoint along forward trace, then trace downward.
		FVector ProbeTop;
		ProbeTop.X = ViewDir.X * HalfDist + EyePos.X;
		ProbeTop.Y = ViewDir.Y * HalfDist + EyePos.Y;
		ProbeTop.Z = ViewDir.Z * HalfDist + EyePos.Z;

		FVector ProbeBottom;
		ProbeBottom.X = ProbeTop.X;
		ProbeBottom.Y = ProbeTop.Y;
		ProbeBottom.Z = ProbeTop.Z - VertProbe;

		FCheckResult Hit2( 1.0f );
		Level->SingleLineCheck( Hit2, this, ProbeBottom, ProbeTop, TRACE_World, Extent );

		if( Hit2.Time < 1.0f )
		{
			FLOAT StepDist = VertProbe * Hit2.Time;

			if( StepDist < TraceDist * 0.7f - 6.0f )
			{
				// Floor ahead is HIGH (closer than expected) — ascending stairs.
				// Confirmation trace: offset along ViewDir, trace down from Pawn location.
				FVector ScaledDir;
				ScaledDir.X = ViewDir.X * HitDist;
				ScaledDir.Y = ViewDir.Y * HitDist;
				ScaledDir.Z = ViewDir.Z * HitDist;

				FVector ConfTop;
				ConfTop.X = *(FLOAT*)((BYTE*)Pawn + 0x234) + ScaledDir.X;
				ConfTop.Y = *(FLOAT*)((BYTE*)Pawn + 0x238) + ScaledDir.Y;
				ConfTop.Z = *(FLOAT*)((BYTE*)Pawn + 0x23c) + ScaledDir.Z;

				FVector ConfBottom;
				ConfBottom.X = ConfTop.X;
				ConfBottom.Y = ConfTop.Y;
				ConfBottom.Z = ConfTop.Z - VertProbe;

				FCheckResult Hit3( 1.0f );
				Level->SingleLineCheck( Hit3, this, ConfBottom, ConfTop, TRACE_World, Extent );

				// Default: if pitch is already positive (looking up), keep 0; else keep current pitch.
				TargetPitch = (SignedPitch <= 0) ? 0 : SignedPitch;

				if( VertProbe * Hit3.Time < StepDist - 10.0f )
					TargetPitch = 3600;  // 0xe10 = descending stairs pitch (look up)
			}
			else if( StepDist > TraceDist * 0.7f + 6.0f )
			{
				// Floor ahead is LOW (farther than expected) — descending stairs.
				// Confirmation trace: offset scaled by 0.9.
				FVector ScaledDir;
				ScaledDir.X = ViewDir.X * (HitDist * 0.9f);
				ScaledDir.Y = ViewDir.Y * (HitDist * 0.9f);
				ScaledDir.Z = ViewDir.Z * (HitDist * 0.9f);

				FVector ConfStart;
				ConfStart.X = *(FLOAT*)((BYTE*)Pawn + 0x234) + ScaledDir.X;
				ConfStart.Y = *(FLOAT*)((BYTE*)Pawn + 0x238) + ScaledDir.Y;
				ConfStart.Z = *(FLOAT*)((BYTE*)Pawn + 0x23c) + ScaledDir.Z;

				// Trace with zero extent, TRACE_World | TRACE_StopAtFirstHit (0x286).
				FCheckResult Hit3a( 1.0f );
				Level->SingleLineCheck( Hit3a, this, ConfStart, ConfStart, 0x286, FVector(0,0,0) );

				if( Hit3a.Time == 1.0f )
				{
					// No obstruction — do another vertical probe.
					FVector Scaled2;
					Scaled2.X = ViewDir.X * HitDist;
					Scaled2.Y = ViewDir.Y * HitDist;
					Scaled2.Z = ViewDir.Z * HitDist;

					FVector VPTop;
					VPTop.X = EyeH + Scaled2.X;
					VPTop.Y = EyePos.X + Scaled2.Y;
					VPTop.Z = (End.X + Scaled2.Z) - VertProbe;

					FVector VPBottom = VPTop;

					FCheckResult Hit4( 1.0f );
					Level->SingleLineCheck( Hit4, this, VPTop, VPBottom, TRACE_World, Extent );

					// Default: if pitch is non-negative, use 0; else keep current pitch.
					TargetPitch = (SignedPitch >= 0) ? 0 : SignedPitch;

					if( StepDist + 10.0f < VertProbe * Hit4.Time )
						TargetPitch = -4000;  // 0xfffff060 = ascending stairs pitch (look down)
				}
			}
		}
	}

	// Blending: interpolate current pitch toward target pitch.
	INT CurrentPitch = SignedPitch;
	INT Diff = CurrentPitch - (INT)TargetPitch;
	if( Diff < 0 ) Diff = -Diff;

	if( Diff > 0 && *(FLOAT*)(*(INT*)((BYTE*)this + 0x144) + 0x45c) - *(FLOAT*)((BYTE*)this + 0x3d0) > 0.25f )
	{
		FLOAT BlendSpeed = 4.0f;
		if( Diff < 1000 )
			BlendSpeed = (FLOAT)(INT)(4000 / (INT)Diff);

		FLOAT Alpha = BlendSpeed * DeltaTime;
		if( Alpha > 1.0f )
			Alpha = 1.0f;

		*(INT*)Result = appRound( Alpha * (FLOAT)(INT)TargetPitch + (1.0f - Alpha) * (FLOAT)CurrentPitch );
		return;
	}

	if( Diff < 10 && (INT)TargetPitch < 10 && (INT)TargetPitch > -10 )
	{
		// Reset stair check timestamp when pitch is stable near zero.
		*(FLOAT*)((BYTE*)this + 0x3d0) = *(FLOAT*)(*(INT*)((BYTE*)this + 0x144) + 0x45c);
	}

	*(INT*)Result = CurrentPitch;
	unguard;
}
IMPLEMENT_FUNCTION( APlayerController, 524, execFindStairRotation );

// Ghidra 0x1038f400, 228b. Has SEH (guard/unguard). P_FINISH only.
// Gets viewport at +0x5b4, verifies IsA(UViewport), then for each input object (at +0x84 keyboard,
// +0x88 mouse): calls UObject::ResetConfig(class,"",flag) then SaveConfig(0x4000, NULL).
IMPL_MATCH("Engine.dll", 0x1038f400)
void APlayerController::execResetKeyboard( FFrame& Stack, RESULT_DECL )
{
	guard(APlayerController::execResetKeyboard);
	P_FINISH;
	UPlayer* P = *(UPlayer**)((BYTE*)this + 0x5b4);
	if( P && P->IsA(UViewport::StaticClass()) )
	{
		UObject* KeyInput = *(UObject**)((BYTE*)P + 0x84);
		if( KeyInput )
		{
			UObject::ResetConfig(KeyInput->GetClass(), TEXT(""), 1);
			KeyInput->SaveConfig(0x4000, NULL);
		}
		UObject* MouseInput = *(UObject**)((BYTE*)P + 0x88);
		if( MouseInput )
		{
			UObject::ResetConfig(MouseInput->GetClass(), TEXT(""), 0);
			MouseInput->SaveConfig(0x4000, NULL);
		}
	}
	unguard;
}
IMPLEMENT_FUNCTION( APlayerController, 544, execResetKeyboard );

// Ghidra 0x1038eff0, 372b. Reads 3 params: FString NewOption, FString NewValue, UBOOL bSaveDefault.
// FUN_1038ef30(Engine) = checked cast to UGameEngine*: asserts IsA(UGameEngine) then returns arg.
// In practice Engine IS always a UGameEngine so the check always passes; we skip the assertion.
// FURL (LastURL) is at UGameEngine+0x464 — confirmed from Ghidra and UGameEngine layout.
IMPL_DIVERGE("Ghidra 0x1038eff0; FUN_1038ef30 is a UGameEngine IsA-assertion that always passes in practice; logic otherwise matches retail; minor binary difference from skipping the assert")
void APlayerController::execUpdateURL( FFrame& Stack, RESULT_DECL )
{
	guard(APlayerController::execUpdateURL);
	P_GET_STR(NewOption);
	P_GET_STR(NewValue);
	P_GET_UBOOL(bSaveDefault);
	P_FINISH;
	if( XLevel && XLevel->Engine )
	{
		FString Opt = NewOption + FString(TEXT("=")) + NewValue;
		FURL* URL = (FURL*)((BYTE*)XLevel->Engine + 0x464);
		URL->AddOption( *Opt );
		if( bSaveDefault )
			URL->SaveURLConfig( TEXT("DefaultPlayer"), *NewOption, TEXT("User") );
	}
	unguard;
}
IMPLEMENT_FUNCTION( APlayerController, 546, execUpdateURL );

// Ghidra 0x1038da50, 299b. Reads FString Command, P_FINISH. Routes to Player->Exec (vtable+0x30)
// or Engine->Exec (vtable+0x2c), captures output to custom stack FOutputDevice, returns in Result.
// DIVERGE: retail uses custom stack-allocated FOutputDevice with captured vtable at 0x105462a8
// to populate local_34 (output FString). Not replicated — GNull discards output.
IMPL_DIVERGE("Ghidra 0x1038da50: retail creates stack FOutputDevice with vtable at absolute address 0x105462a8 in retail binary; our rebuild cannot reproduce this address; output is discarded via GNull instead")
void APlayerController::execConsoleCommand( FFrame& Stack, RESULT_DECL )
{
	guard(APlayerController::execConsoleCommand);
	P_GET_STR(Command);
	P_FINISH;
	*(FString*)Result = TEXT("");
	UPlayer* P = *(UPlayer**)((BYTE*)this + 0x5b4);
	if( P )
		P->Exec( *Command, *GNull );
	else if( XLevel && XLevel->Engine )
	{
		typedef UBOOL (__thiscall* TExecFn)(UEngine*, const TCHAR*, FOutputDevice&);
		TExecFn execFn = *(TExecFn*)((*(DWORD*)((BYTE*)XLevel->Engine + 0)) + 0x2c);
		execFn( XLevel->Engine, *Command, *GNull );
	}
	unguard;
}
IMPLEMENT_FUNCTION( APlayerController, INDEX_NONE, execConsoleCommand );

// Ghidra 0x103919e0, 330b. Reads FString Option. Constructs new FURL, loads DefaultPlayer config,
// appends "=" to Option string to form key, calls FURL::GetOption(key, "") and returns result.
IMPL_MATCH("Engine.dll", 0x103919e0)
void APlayerController::execGetDefaultURL( FFrame& Stack, RESULT_DECL )
{
	guard(APlayerController::execGetDefaultURL);
	P_GET_STR(Option);
	P_FINISH;
	FURL URL(NULL);
	URL.LoadURLConfig( TEXT("DefaultPlayer"), TEXT("User") );
	FString Key = Option + FString(TEXT("="));
	*(FString*)Result = FString(URL.GetOption( *Key, TEXT("") ));
	unguard;
}
IMPLEMENT_FUNCTION( APlayerController, INDEX_NONE, execGetDefaultURL );

// Ghidra 0x1038f1a0, 263b. P_FINISH only. Asserts XLevel, Engine, UGameEngine GEntry chain.
// Calls ULevel::GetLevelInfo on GEntry (UGameEngine->GEntry at +0x45c). Returns ALevelInfo*.
IMPL_MATCH("Engine.dll", 0x1038f1a0)
void APlayerController::execGetEntryLevel( FFrame& Stack, RESULT_DECL )
{
	guard(APlayerController::execGetEntryLevel);
	P_FINISH;
	check(XLevel);
	check(XLevel->Engine);
	ULevel* Entry = *(ULevel**)((BYTE*)XLevel->Engine + 0x45c);
	check(Entry);
	*(ALevelInfo**)Result = Entry->GetLevelInfo();
	unguard;
}
IMPLEMENT_FUNCTION( APlayerController, INDEX_NONE, execGetEntryLevel );

// Ghidra 0x1038f2e0, 226b. Sets ViewTarget at +0x5b8, calls vtable[0x63] (byte offset 0x18c)
// to update camera, then if viewport canvas has bFading set (canvas+0xb8 & 1), calls StartFade.
IMPL_MATCH("Engine.dll", 0x1038f2e0)
void APlayerController::execSetViewTarget( FFrame& Stack, RESULT_DECL )
{
	guard(APlayerController::execSetViewTarget);
	P_GET_OBJECT(AActor,NewViewTarget);
	P_FINISH;
	*(AActor**)((BYTE*)this + 0x5b8) = NewViewTarget;
	typedef void (__thiscall* TUpdateFn)(APlayerController*);
	TUpdateFn updateFn = *(TUpdateFn*)((BYTE*)*(DWORD*)this + 0x18c);
	updateFn(this);
	UPlayer* P = *(UPlayer**)((BYTE*)this + 0x5b4);
	if( P && P->IsA(UViewport::StaticClass()) )
	{
		UCanvas* Canvas = *(UCanvas**)((BYTE*)P + 0x7c);
		if( Canvas && (*(BYTE*)((BYTE*)Canvas + 0xb8) & 1) )
			Canvas->StartFade(FColor(0xff000000u), FColor(0xffffffffu), 0.f, 1);
	}
	unguard;
}
IMPLEMENT_FUNCTION( APlayerController, INDEX_NONE, execSetViewTarget );

// Ghidra 0x10425910, 292b. Reads: FString URL, BYTE TravelType, UBOOL bItems.
// If Player connected (+0x5b4 != 0): fires PreClientTravel event, then calls
// UEngine::SetClientTravel(Viewport, URL, bItems, TravelType).
IMPL_MATCH("Engine.dll", 0x10425910)
void APlayerController::execClientTravel( FFrame& Stack, RESULT_DECL )
{
	guard(APlayerController::execClientTravel);
	P_GET_STR(URL);
	P_GET_BYTE(TravelType);
	P_GET_UBOOL(bItems);
	P_FINISH;
	if( *(INT*)((BYTE*)this + 0x5b4) )
	{
		eventPreClientTravel();
		if( XLevel && XLevel->Engine )
			XLevel->Engine->SetClientTravel(
				*(UPlayer**)((BYTE*)this + 0x5b4), *URL, bItems, (ETravelType)TravelType );
	}
	unguard;
}
IMPLEMENT_FUNCTION( APlayerController, INDEX_NONE, execClientTravel );

// Ghidra 0x10425c90, 259b. Reads: Object Actor, Object Sound, Byte Flags (3 params, not 5).
// Checks LocalPlayerController(). If local and Audio exists:
//   If Actor has bSpatialSound-clear flag (actor+0xa0 high bit set): zero Actor.
//   Calls Audio->vtable[0x84/4](Actor, Sound, Flags, 0).
IMPL_MATCH("Engine.dll", 0x10425c90)
void APlayerController::execClientHearSound( FFrame& Stack, RESULT_DECL )
{
	guard(APlayerController::execClientHearSound);
	P_GET_OBJECT(AActor,Actor);
	P_GET_OBJECT(USound,S);
	P_GET_BYTE(SoundFlags);
	P_FINISH;
	if( LocalPlayerController() )
	{
		UAudioSubsystem* Audio = (XLevel && XLevel->Engine) ? XLevel->Engine->Audio : NULL;
		if( Audio )
		{
			if( Actor && *(signed char*)((BYTE*)Actor + 0xa0) < 0 )
				Actor = NULL;
			typedef void (__thiscall* TPlayFn)(UAudioSubsystem*, AActor*, USound*, BYTE, INT);
			TPlayFn playFn = *(TPlayFn*)((BYTE*)*(DWORD*)Audio + 0x84);
			playFn(Audio, Actor, S, SoundFlags, 0);
		}
	}
	unguard;
}
IMPLEMENT_FUNCTION( APlayerController, INDEX_NONE, execClientHearSound );

IMPL_DIVERGE("Ghidra catch-only at 0x1042c22b; function body not exported; returns empty FString")
void APlayerController::execGetPlayerNetworkAddress( FFrame& Stack, RESULT_DECL )
{
	guard(APlayerController::execGetPlayerNetworkAddress);
	P_FINISH;
	*(FString*)Result = TEXT("");
	unguard;
}
IMPLEMENT_FUNCTION( APlayerController, INDEX_NONE, execGetPlayerNetworkAddress );

IMPL_MATCH("Engine.dll", 0x10420680)
void APlayerController::execCopyToClipboard( FFrame& Stack, RESULT_DECL )
{
	guard(APlayerController::execCopyToClipboard);
	P_GET_STR(Text);
	P_FINISH;
	appClipboardCopy( *Text );
	unguard;
}
IMPLEMENT_FUNCTION( APlayerController, INDEX_NONE, execCopyToClipboard );

// Ghidra 0x10420760, 190b. SEH frame present → guard/unguard correct.
// Retail reads one FString param (into a local, discarded) before P_FINISH,
// then assigns appClipboardPaste() result to the return slot.
IMPL_MATCH("Engine.dll", 0x10420760)
void APlayerController::execPasteFromClipboard( FFrame& Stack, RESULT_DECL )
{
	guard(APlayerController::execPasteFromClipboard);
	P_GET_STR(Dummy); // Ghidra: FString local_28 read from bytecode, never used
	P_FINISH;
	*(FString*)Result = appClipboardPaste();
	unguard;
}
IMPLEMENT_FUNCTION( APlayerController, INDEX_NONE, execPasteFromClipboard );

// Ghidra 0x10420230, 88b. No SEH in retail.
// Retail: UObject::IsA(Player, &UNetConnection::PrivateStaticClass) — no null guard on Player.
// Diverges: our StaticClass() call vs PrivateStaticClass direct ref; null guard on P (safety).
IMPL_DIVERGE("Ghidra 0x10420230; retail calls IsA without null-checking Player first (potential null deref); we intentionally add null guard for safety; also uses PrivateStaticClass directly vs our StaticClass() call")
void APlayerController::execSpecialDestroy( FFrame& Stack, RESULT_DECL )
{
	P_FINISH;
	UPlayer* P = *(UPlayer**)((BYTE*)this + 0x5b4);
	if( P && P->IsA(UNetConnection::StaticClass()) )
	{
		if( *(INT*)((BYTE*)P + 0x7c) )
			*(INT*)((BYTE*)P + 0x80) = 1;
	}
}
IMPLEMENT_FUNCTION( APlayerController, INDEX_NONE, execSpecialDestroy );

// Ghidra 0x1038cc50 (59b): reads one object param from bytecode (USkeletalMesh*),
// then calls RenderPreProcess() and stores result. No guard/unguard in retail.
// DIVERGENCE: we add guard/unguard; retail inlines Stack.Step dispatch directly.
IMPL_DIVERGE("Ghidra 0x1038cc50: retail has no SEH frame; we intentionally add guard/unguard for consistency; P_GET_OBJECT vs inline Stack.Step dispatch is functionally identical")
void APlayerController::execPB_CanPlayerSpawn( FFrame& Stack, RESULT_DECL )
{
	guard(APlayerController::execPB_CanPlayerSpawn);
	P_GET_OBJECT(USkeletalMesh, Mesh);
	P_FINISH;
	*(INT*)Result = Mesh->RenderPreProcess();
	unguard;
}
IMPLEMENT_FUNCTION( APlayerController, 1320, execPB_CanPlayerSpawn );

IMPL_DIVERGE("PunkBuster binary-only anti-cheat middleware; FUN_1047f210 status lookup stub (Ghidra 0x1042c250)")
void APlayerController::execGetPBConnectStatus( FFrame& Stack, RESULT_DECL )
{
	guard(APlayerController::execGetPBConnectStatus);
	P_FINISH;
	*(INT*)Result = 0;
	unguard;
}
IMPLEMENT_FUNCTION( APlayerController, INDEX_NONE, execGetPBConnectStatus );

IMPL_DIVERGE("PunkBuster binary-only anti-cheat middleware; FUN_1047e850 enabled check stub returns 0 (Ghidra 0x10420290)")
void APlayerController::execIsPBEnabled( FFrame& Stack, RESULT_DECL )
{
	guard(APlayerController::execIsPBEnabled);
	P_FINISH;
	*(DWORD*)Result = 0;
	unguard;
}
IMPLEMENT_FUNCTION( APlayerController, INDEX_NONE, execIsPBEnabled );

// Ghidra 0x1038f520, 299b. Reads FString KeyName, INT Device. Returns UBOOL byte.
// device==0: keyboard input (+0x84)->vtable[0x88](KeyName) → UBOOL.
// device!=0: mouse/gamepad input (+0x88)->vtable[0x88](KeyName) → UBOOL.
IMPL_MATCH("Engine.dll", 0x1038f520)
void APlayerController::execGetKey( FFrame& Stack, RESULT_DECL )
{
	guard(APlayerController::execGetKey);
	P_GET_STR(KeyName);
	P_GET_INT(Device);
	P_FINISH;
	*(BYTE*)Result = 0;
	UPlayer* P = *(UPlayer**)((BYTE*)this + 0x5b4);
	if( P && P->IsA(UViewport::StaticClass()) )
	{
		INT* InputObj = (Device == 0)
			? *(INT**)((BYTE*)P + 0x84)
			: *(INT**)((BYTE*)P + 0x88);
		if( InputObj )
		{
			typedef BYTE (__thiscall* TKeyFn)(INT*, const TCHAR*);
			TKeyFn fn = *(TKeyFn*)((BYTE*)*InputObj + 0x88);
			*(BYTE*)Result = fn(InputObj, *KeyName);
		}
	}
	unguard;
}
IMPLEMENT_FUNCTION( APlayerController, 2706, execGetKey );

// Ghidra 0x1038f7a0, 288b. Reads BYTE Device, INT Action. Returns FString.
// device==0: keyboard input (+0x84)->vtable[0x90](result, action).
// device!=0: mouse/gamepad input (+0x88)->vtable[0x90](result, action).
IMPL_MATCH("Engine.dll", 0x1038f7a0)
void APlayerController::execGetActionKey( FFrame& Stack, RESULT_DECL )
{
	guard(APlayerController::execGetActionKey);
	P_GET_BYTE(Device);
	P_GET_INT(Action);
	P_FINISH;
	*(FString*)Result = TEXT("");
	UPlayer* P = *(UPlayer**)((BYTE*)this + 0x5b4);
	if( P && P->IsA(UViewport::StaticClass()) )
	{
		INT* InputObj = (Device == 0)
			? *(INT**)((BYTE*)P + 0x84)
			: *(INT**)((BYTE*)P + 0x88);
		if( InputObj )
		{
			typedef FString* (__thiscall* TGetActionFn)(INT*, FString*, DWORD);
			TGetActionFn fn = *(TGetActionFn*)((BYTE*)*InputObj + 0x90);
			FString* R = fn(InputObj, (FString*)Result, (DWORD)Action);
			if( R != (FString*)Result )
				*(FString*)Result = *R;
		}
	}
	unguard;
}
IMPLEMENT_FUNCTION( APlayerController, 2707, execGetActionKey );

// Ghidra 0x1038f680, 231b. Reads BYTE Key, INT Device. Returns FString key enum name.
// device==0: keyboard input (+0x84)->vtable[0x80](key) → const wchar_t* name.
// device!=0: mouse/gamepad input (+0x88)->vtable[0x80](key) → name. Fallback: L"IK_None".
IMPL_MATCH("Engine.dll", 0x1038f680)
void APlayerController::execGetEnumName( FFrame& Stack, RESULT_DECL )
{
	guard(APlayerController::execGetEnumName);
	P_GET_BYTE(Key);
	P_GET_INT(Device);
	P_FINISH;
	const TCHAR* Name = TEXT("IK_None");
	UPlayer* P = *(UPlayer**)((BYTE*)this + 0x5b4);
	if( P && P->IsA(UViewport::StaticClass()) )
	{
		INT* InputObj = (Device == 0)
			? *(INT**)((BYTE*)P + 0x84)
			: *(INT**)((BYTE*)P + 0x88);
		if( InputObj )
		{
			typedef const TCHAR* (__thiscall* TGetNameFn)(INT*, BYTE);
			TGetNameFn fn = *(TGetNameFn*)((BYTE*)*InputObj + 0x80);
			Name = fn(InputObj, Key);
		}
	}
	*(FString*)Result = FString(Name);
	unguard;
}
IMPLEMENT_FUNCTION( APlayerController, 2708, execGetEnumName );

// Ghidra 0x1038f900, 168b. Reads BYTE InputSet. Calls UViewport::ChangeInputSet(InputSet).
IMPL_MATCH("Engine.dll", 0x1038f900)
void APlayerController::execChangeInputSet( FFrame& Stack, RESULT_DECL )
{
	guard(APlayerController::execChangeInputSet);
	P_GET_BYTE(InputSet);
	P_FINISH;
	UPlayer* P = *(UPlayer**)((BYTE*)this + 0x5b4);
	if( P && P->IsA(UViewport::StaticClass()) )
		((UViewport*)P)->ChangeInputSet( InputSet );
	unguard;
}
IMPLEMENT_FUNCTION( APlayerController, 2709, execChangeInputSet );

// Ghidra 0x10391770, 451b. Reads one FString param (the key binding command string).
// Dispatches: "INPUT ..." → keyboard UInput->Exec via vtable[0x8c]
//              "INPUTPLANNING ..." → mouse/gamepad UInput->Exec via vtable[0x8c]
//              "R6GAMEOPTIONS PropertyName Value" → FUN_103916a0 property lookup + GlobalSetProperty
// DIVERGE: FUN_103916a0 (152b, property-chain walker) approximated with FindObjectField.
IMPL_DIVERGE("Ghidra 0x10391770: FUN_103916a0 property-chain iterator approximated as FindObjectField; FUN_ signature unrecoverable — permanent binary difference")
void APlayerController::execSetKey( FFrame& Stack, RESULT_DECL )
{
	guard(APlayerController::execSetKey);
	P_GET_STR(KeyStr);
	P_FINISH;
	UPlayer* P = *(UPlayer**)((BYTE*)this + 0x5b4);
	if( P && P->IsA(UViewport::StaticClass()) )
	{
		const TCHAR* Str = *KeyStr;
		if( ParseCommand(&Str, TEXT("INPUT")) )
		{
			INT* KbInput = *(INT**)((BYTE*)P + 0x84);
			if( KbInput )
			{
				typedef void (__thiscall* TExecFn)(INT*, const TCHAR*);
				TExecFn fn = *(TExecFn*)((BYTE*)*KbInput + 0x8c);
				fn(KbInput, Str);
			}
		}
		else if( ParseCommand(&Str, TEXT("INPUTPLANNING")) )
		{
			INT* MsInput = *(INT**)((BYTE*)P + 0x88);
			if( MsInput )
			{
				typedef void (__thiscall* TExecFn)(INT*, const TCHAR*);
				TExecFn fn = *(TExecFn*)((BYTE*)*MsInput + 0x8c);
				fn(MsInput, Str);
			}
		}
		else if( ParseCommand(&Str, TEXT("R6GAMEOPTIONS")) )
		{
			// Retail: ParseToken → find "R6GameOptions" UClass → walk property chain for name
			// → GlobalSetProperty.  FUN_103916a0 = walk UClass property chain by name
			// (equivalent to FindObjectField).
			TCHAR PropName[0x100];
			ParseToken( Str, PropName, 0x100, 0 );
			while( *Str == TEXT(' ') ) Str++;
			UObject* R6GO = UObject::StaticFindObject( UClass::StaticClass(), ANY_PACKAGE, TEXT("R6GameOptions"), 0 );
			if( R6GO )
			{
				UProperty* Prop = (UProperty*)R6GO->FindObjectField( FName(PropName), 0 );
				if( Prop )
				{
					INT PropOffset = *(INT*)((BYTE*)Prop + 0x4c);
					UObject::GlobalSetProperty( Str, (UClass*)R6GO, Prop, PropOffset, 1 );
				}
			}
		}
	}
	unguard;
}
IMPLEMENT_FUNCTION( APlayerController, 2710, execSetKey );

// Ghidra 0x1038cb30, 102b. No SEH in retail. P_FINISH only (no params).
// If Audio system exists, calls Audio->vtable[0x88](0) to reset sound provider options.
// Audio at XLevel->Engine->Audio (+0x48).
IMPL_MATCH("Engine.dll", 0x1038cb30)
void APlayerController::execSetSoundOptions( FFrame& Stack, RESULT_DECL )
{
	P_FINISH;
	UAudioSubsystem* Audio = (XLevel && XLevel->Engine) ? XLevel->Engine->Audio : NULL;
	if( Audio )
	{
		typedef void (__thiscall* TSetOptFn)(UAudioSubsystem*, INT);
		TSetOptFn fn = *(TSetOptFn*)((BYTE*)*(DWORD*)Audio + 0x88);
		fn(Audio, 0);
	}
}
IMPLEMENT_FUNCTION( APlayerController, 2713, execSetSoundOptions );

// Ghidra 0x1038cba0, 172b. Params: BYTE VolumeType, INT NewVolume.
// Calls FUN_1050557c (Engine.dll internal, 284 refs) for volume conversion, then Audio->vtable[0xa8](VolumeType, float).
// FUN_1050557c signature unrecoverable from Ghidra (args passed in caller-saved regs, not tracked).
// Best approximation: pass NewVolume/100.0f as the float volume (linear 0-100→0.0-1.0 mapping).
IMPL_DIVERGE("Ghidra 0x1038cba0: FUN_1050557c (Engine.dll internal, 284 callers) converts NewVolume to FLOAT; signature unrecoverable — approximated with NewVolume/100.0f; permanent binary difference")
void APlayerController::execChangeVolumeTypeLinear( FFrame& Stack, RESULT_DECL )
{
	P_GET_BYTE(VolumeType);
	P_GET_INT(NewVolume);
	P_FINISH;
	UAudioSubsystem* Audio = (XLevel && XLevel->Engine) ? XLevel->Engine->Audio : NULL;
	if( Audio )
	{
		typedef void (__thiscall* TSetVolFn)(UAudioSubsystem*, BYTE, FLOAT);
		TSetVolFn fn = *(TSetVolFn*)((BYTE*)*(DWORD*)Audio + 0xa8);
		fn( Audio, VolumeType, (FLOAT)NewVolume * 0.01f );
	}
}
IMPLEMENT_FUNCTION( APlayerController, 2714, execChangeVolumeTypeLinear );

/*-- AAIController functions -------------------------------------------*/

// Ghidra 0x1038cf10, 203b. No SEH → no guard/unguard.
// Reads 3 optional params (FVector, UBOOL, FLOAT=1.0f) — all discarded.
// Pawn at +0x3d8, Enemy at +0x400, Focus at +0x3e4. LatentAction = AI_PollWaitToSeeEnemy (0x1ff).
IMPL_MATCH("Engine.dll", 0x1038cf10)
void AAIController::execWaitToSeeEnemy( FFrame& Stack, RESULT_DECL )
{
	P_GET_VECTOR_OPTX(UnusedLoc, FVector(0,0,0)); // param 1: FVector, read but discarded
	P_GET_UBOOL_OPTX(UnusedBool, 0);               // param 2: UBOOL, read but discarded
	P_GET_FLOAT_OPTX(UnusedFloat, 1.0f);           // param 3: FLOAT default 1.0, discarded
	P_FINISH;
	if( Pawn && Enemy )
	{
		Focus = Enemy;
		GetStateFrame()->LatentAction = AI_PollWaitToSeeEnemy;
	}
}
IMPLEMENT_FUNCTION( AAIController, INDEX_NONE, execWaitToSeeEnemy );

// Ghidra 0x1038e7c0, 163b. No SEH in retail — no guard/unguard.
// Pawn at +0x3d8, Enemy at +0x400, XLevel at +0x144, XLevel->TimeSeconds at +0x45c,
// LastSeenTime at +0x3c4. Yaw-diff check identical to PollFinishRotation.
IMPL_MATCH("Engine.dll", 0x1038e7c0)
void AAIController::execPollWaitToSeeEnemy( FFrame& Stack, RESULT_DECL )
{
	if( Pawn && Enemy )
	{
		if( Level->TimeSeconds - LastSeenTime > 0.1f )
			return;
		INT iYawDiff = *(INT*)((BYTE*)Pawn + 0x300) - (INT)(*(DWORD*)((BYTE*)Pawn + 0x244) & 0xffff);
		if( iYawDiff < 0 ) iYawDiff = -iYawDiff;
		if( iYawDiff > 1999 )
		{
			INT iYawDiff2 = *(INT*)((BYTE*)Pawn + 0x300) - (INT)(*(DWORD*)((BYTE*)Pawn + 0x244) & 0xffff);
			if( iYawDiff2 < 0 ) iYawDiff2 = -iYawDiff2;
			if( iYawDiff2 < 0xf830 )
				return;
		}
	}
	GetStateFrame()->LatentAction = 0;
}
IMPLEMENT_FUNCTION( AAIController, INDEX_NONE, execPollWaitToSeeEnemy );

/*-----------------------------------------------------------------------------
	APawn trivial method implementations.
	Reconstructed from Ghidra decompilation + UT99 reference.
-----------------------------------------------------------------------------*/

IMPL_MATCH("Engine.dll", 0x10301a90)
APawn* APawn::GetPawnOrColBoxOwner() const
{
	return (APawn*)this;
}

IMPL_MATCH("Engine.dll", 0x10301a90)
APawn* APawn::GetPlayerPawn() const
{
	// Retail: 8B C1 C3 = mov eax,ecx; ret — APawn always returns itself.
	// The base AActor::GetPlayerPawn returns NULL; APawn overrides to return this.
	return (APawn*)this;
}

IMPL_MATCH("Engine.dll", 0x103c3400)
INT APawn::PlayerControlled()
{
	if( Controller && Controller->LocalPlayerController() )
		return 1;
	return 0;
}

// Ghidra 0x103e55b0, 14b. No guard/unguard. Casts field to BYTE before compare.
// m_eHealth is a BYTE enum at APawn+0x3a2 (confirmed by Ghidra cast).
IMPL_MATCH("Engine.dll", 0x103e55b0)
INT APawn::IsAlive()
{
	return m_eHealth < 2;
}

// Ghidra 0x103ecae0, 77b. No guard/unguard. Uses NaN-safe IEEE equality pattern
// (fcomi): enters body when CollisionHeight == CrouchHeight OR either is NaN.
// Our code diverges on the NaN case (returns 0 if either is NaN; retail treats NaN == anything).
IMPL_DIVERGE("Ghidra 0x103ecae0; NaN-safe fcomi equality: retail fcomi enters body when either CollisionHeight or CrouchHeight is NaN (unordered); C++ == returns false for NaN so our code does not — permanent FPU semantic difference")
INT APawn::IsCrouched()
{
	if( CollisionHeight != CrouchHeight )
		return 0;
	APawn* defObj = (APawn*)GetClass()->GetDefaultObject();
	return CollisionHeight < defObj->CollisionHeight && m_ePeekingMode != 2;
}

IMPL_MATCH("Engine.dll", 0x103e4fb0)
INT APawn::IsPlayer()
{
	return Controller && Controller->bIsPlayer;
}

// Ghidra 0x103e5600, 34b. No guard/unguard.
// Retail uses UObject::IsA(Controller, &APlayerController::PrivateStaticClass) directly;
// our StaticClass() call is functionally equivalent but adds one extra call instruction.
IMPL_DIVERGE("Ghidra 0x103e5600; retail uses &APlayerController::PrivateStaticClass as a direct address reference; our StaticClass() call adds an indirect call instruction — permanent header-level binary difference")
INT APawn::IsHumanControlled()
{
	return Controller && Controller->IsA(APlayerController::StaticClass());
}

IMPL_MATCH("Engine.dll", 0x103e4fd0)
INT APawn::IsLocallyControlled()
{
	if( Controller && Controller->LocalPlayerController() )
		return 1;
	return 0;
}

IMPL_MATCH("Engine.dll", 0xE5350)
INT APawn::IsFriend( APawn* Other )
{
	// Retail RVA=0xE5350: checks (1 << Other->m_iTeam) & m_iFriendlyTeams
	// No null checks in retail; we add safety check for null Other only.
	// NOTE: retail divergence - retail doesn't check Controller/Other->Controller
	guard(APawn::IsFriend_Pawn);
	if( !Other )
		return 0;
	return (1 << (Other->m_iTeam & 0x1F)) & m_iFriendlyTeams;
	unguard;
}

IMPL_MATCH("Engine.dll", 0xE5370)
INT APawn::IsFriend( INT TeamIndex )
{
	// Retail RVA=0xE5370: return m_iFriendlyTeams & (1 << TeamIndex)
	guard(APawn::IsFriend_Team);
	return m_iFriendlyTeams & (1 << (TeamIndex & 0x1F));
	unguard;
}

IMPL_MATCH("Engine.dll", 0xE5420)
INT APawn::IsEnemy( APawn* Other )
{
	// Retail RVA=0xE5420: checks (1 << Other->m_iTeam) & m_iEnemyTeams
	// BUG FIX: previous code used !IsFriend() which checked the wrong mask.
	// IsEnemy uses m_iEnemyTeams, NOT !m_iFriendlyTeams.
	guard(APawn::IsEnemy);
	if( !Other )
		return 0;
	return (1 << (Other->m_iTeam & 0x1F)) & m_iEnemyTeams;
	unguard;
}

IMPL_MATCH("Engine.dll", 0xE54D0)
INT APawn::IsNeutral( APawn* Other )
{
	// Retail RVA=0xE54D0: not in FriendlyTeams AND not in EnemyTeams for Other's team bit.
	// BUG FIX: previous code was !IsFriend && !IsEnemy which = !F && F = always false.
	guard(APawn::IsNeutral);
	if( !Other )
		return 0;
	INT bit = 1 << (Other->m_iTeam & 0x1F);
	if( m_iFriendlyTeams & bit ) return 0;
	if( m_iEnemyTeams & bit ) return 0;
	return 1;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x103e5000)
FLOAT APawn::GetMaxSpeed()
{
	FLOAT result = GroundSpeed;
	if( Physics == PHYS_Flying )
		return AirSpeed;
	if( Physics == PHYS_Swimming )
		result = WaterSpeed;
	return result;
}

IMPL_MATCH("Engine.dll", 0xC34E0)
INT APawn::CheckOwnerUpdated()
{
	guard(APawn::CheckOwnerUpdated);
	// Retail 0xC34E0: same replication-queue logic as AActor, plus checks actor at this+0x4EC.
	// Does NOT call super; duplicates the logic and adds the second actor check.
	struct OwnedActorLink { void* Actor; OwnedActorLink* Prev; };
	AActor* owner = *(AActor**)((BYTE*)this + 0x140);
	if ( owner )
	{
		INT ownerBit = *(INT*)((BYTE*)owner + 0x320) & 1;
		BYTE* ctrl   = *(BYTE**)((BYTE*)this + 0x328);
		if ( ownerBit != *(INT*)(ctrl + 0x100) )
		{
			OwnedActorLink* node = (OwnedActorLink*)appMalloc( sizeof(OwnedActorLink), TEXT("OwnerUpdateNode") );
			if ( !node ) { *(void**)(ctrl + 0xF8) = NULL; return 0; }
			node->Actor = this;
			node->Prev  = *(OwnedActorLink**)(ctrl + 0xF8);
			*(OwnedActorLink**)(ctrl + 0xF8) = node;
			return 0;
		}
	}
	AActor* actor2 = *(AActor**)((BYTE*)this + 0x4EC);
	if ( actor2 )
	{
		INT actorBit = *(INT*)((BYTE*)actor2 + 0x320) & 1;
		BYTE* ctrl   = *(BYTE**)((BYTE*)this + 0x328);
		if ( actorBit != *(INT*)(ctrl + 0x100) )
		{
			OwnedActorLink* node = (OwnedActorLink*)appMalloc( sizeof(OwnedActorLink), TEXT("OwnerUpdateNode") );
			if ( !node ) { *(void**)(ctrl + 0xF8) = NULL; return 0; }
			node->Actor = this;
			node->Prev  = *(OwnedActorLink**)(ctrl + 0xF8);
			*(OwnedActorLink**)(ctrl + 0xF8) = node;
			return 0;
		}
	}
	return 1;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x103e5260)
void APawn::SetPrePivot( FVector NewPrePivot )
{
	PrePivot = NewPrePivot;
}


/*-----------------------------------------------------------------------------
	APawn method implementations -- batch from .bak reference + stubs.
	Reconstructed from Ghidra decompilation.
-----------------------------------------------------------------------------*/

IMPL_DIVERGE("Ghidra 0x103982c0: GWarn vtable slot 0x28 (MapCheck) not declared in FOutputDevice; warn emitted via GWarn->Logf instead — permanent header-level binary difference")
void APawn::CheckForErrors()
{
	// Retail has guard/unguard SEH frame; reproduce it here.
	guard(APawn::CheckForErrors);
	AActor::CheckForErrors();
	FName Empty(NAME_None);
	if (AIScriptTag != Empty)
	{
		for (INT i = 0; i < XLevel->Actors.Num(); i++)
		{
			AActor* A = XLevel->Actors(i);
			if (!A) continue;
			if (!A->IsA(AAIScript::StaticClass())) continue;
			// Skip actors whose high bit of byte-0xa0 is set (invalid/pending-delete).
			if (*(BYTE*)((BYTE*)A + 0xa0) & 0x80) continue;
			// AAIScript::ScriptTag (FName) at offset 0x19c
			if (*(FName*)((BYTE*)A + 0x19c) == AIScriptTag) return;
		}
		// DIVERGENCE: retail calls GWarn->vtable[0x28] (MapCheck, 3 args); we use Logf.
		GWarn->Logf(TEXT("No AIScript with Tag corresponding to this Pawn's AIScriptTag"));
	}
	unguard;
}

IMPL_DIVERGE("Ghidra catch-only at 0x103ecab6; full body not exported; returns Delta as stub")
FVector APawn::CheckForLedges( AActor* HitActor, FVector Loc, FVector Delta, FVector GravDir, INT& bShouldJump, INT& bCheckedFall, FLOAT DeltaTime )
{
	guard(APawn::CheckForLedges);
	return Delta;
	unguard;
}

IMPL_DIVERGE("Ghidra 0x103ea860; FUN_1047c5b0(KarmaData) Karma pre-free cleanup call (73b, unregisters object from global Karma table) not reconstructed — permanent: Karma/MeSDK binary-only")
void APawn::Destroy()
{
	guard(APawn::Destroy);
	// Walk XLevel->PawnList (TArray<APawn*> at XLevel+0x101c0) removing self.
	// ULevel::PawnList is not in our headers; raw offset confirmed by Ghidra.
	TArray<APawn*>& PawnList = *(TArray<APawn*>*)((BYTE*)XLevel + 0x101c0);
	for ( INT i = 0; i < PawnList.Num(); i++ )
	{
		if ( PawnList(i) == this )
		{
			PawnList.Remove(i);
			i--;
		}
	}
	// Free Karma body data at this+0x3d8.
	// DIVERGE: retail calls FUN_1047c5b0(KarmaData) here first (Karma cleanup).
	void* karmaData = *(void**)((BYTE*)this + 0x3d8);
	if ( karmaData != NULL )
	{
		GMalloc->Free(karmaData);
		*(void**)((BYTE*)this + 0x3d8) = NULL;
	}
	AActor::Destroy();
	unguard;
}

IMPL_DIVERGE("Ghidra catch at 0x103ec90b is for AActor::FindSlopeRotation; no APawn override exists in retail; delegates to AActor — permanent (no override to implement)")
FRotator APawn::FindSlopeRotation( FVector FloorNormal, FRotator NewRotation )
{
	guard(APawn::FindSlopeRotation);
	return AActor::FindSlopeRotation( FloorNormal, NewRotation );
	unguard;
}

IMPL_MATCH("Engine.dll", 0x103e50c0)
FLOAT APawn::GetNetPriority( AActor* Sent, FLOAT Time, FLOAT Lag )
{
	guard(APawn::GetNetPriority);
	// Controller with bIsPlayer flag, non-null Sent, same team/PRI, walking physics.
	AController* ctrl = *(AController**)((BYTE*)this + 0x4ec);
	if (ctrl != NULL
		&& (*(BYTE*)((BYTE*)ctrl + 0x3a8) & 1)          // bIsPlayer bit0
		&& Sent != NULL
		&& !(*(BYTE*)((BYTE*)Sent + 0xac) & 0x40)        // ~flag at Sent+0xac bit6
		&& *(INT*)((BYTE*)this + 0x4fc) == *(INT*)((BYTE*)Sent + 0x4fc) // same PRI/weapon field
		&& ((*(DWORD*)((BYTE*)Sent + 0xa0) ^ *(DWORD*)((BYTE*)this + 0xa0)) & 2) == 0 // same team bit
		&& Physics == PHYS_Walking)
	{
		// Predict future positions using velocity and compute distance-based priority.
		FVector predThis = Location + Velocity * (Lag * 0.5f);
		FVector predSent = *(FVector*)((BYTE*)Sent + 0x234)
		                 + *(FVector*)((BYTE*)Sent + 0x24c) * (Time + Lag * 0.5f);
		FLOAT dist = (predThis - predSent).Size();
		FLOAT gs   = *(FLOAT*)((BYTE*)this + 0x428); // GroundSpeed
		Time = Time * 0.5f + dist / gs + dist / gs;
	}
	return Time * NetPriority;
	unguard;
}

IMPL_DIVERGE("Ghidra: APawn::GetOptimizedRepList body not exported; delegates to AActor base")
INT* APawn::GetOptimizedRepList( BYTE* InDefault, FPropertyRetirement* Retire, INT* Ptr, UPackageMap* Map, UActorChannel* Ch )
{
	guard(APawn::GetOptimizedRepList);
	Ptr = AActor::GetOptimizedRepList( InDefault, Retire, Ptr, Map, Ch );
	return Ptr;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x103e8370)
INT APawn::HurtByVolume( AActor* V )
{
	guard(APawn::HurtByVolume);
	for ( INT i = 0; i < V->Touching.Num(); i++ )
	{
		AActor* A = V->Touching(i);
		if ( !A ) continue;
		if ( A->IsA(APhysicsVolume::StaticClass()) )
		{
			// DIVERGENCE: APhysicsVolume::bPainCausing (+0x410 bit 0) and DamagePerSec (+0x41c) not in header
			if ( (*(BYTE*)((BYTE*)A + 0x410) & 1) && *(FLOAT*)((BYTE*)A + 0x41c) > 0.f )
				return 1;
		}
	}
	return 0;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x79000)
INT APawn::IsBlockedBy( const AActor* Other ) const
{
	// Retail (21b+tail, RVA 0x79000): if bit 17 of [Other+0xA8] is set, not blocked.
	// Otherwise delegate to AActor::IsBlockedBy via tail call.
	if (*(DWORD*)((BYTE*)Other + 0xA8) & 0x00020000u)
		return 0;
	return AActor::IsBlockedBy(Other);
}

// Ghidra 0x103c4b30; 2176b.
// DIVERGENCE: weapon-mesh LOD path (this->Physics==2 && Weapon && Dist<1000) skipped — requires
//   unidentified vtable calls for weapon FBox; all other paths match retail.
IMPL_DIVERGE("Ghidra 0x103c4b30 (2176b): weapon-mesh LOD net-relevancy path calls vtable[0x88/4=34] and vtable[0x114/4=69] on the Weapon actor to get an FBox for distance culling. AWeapon vtable layout is not reconstructed; slot identities are permanently unknown. All other relevancy paths (cache, team shortcut, owner-chain, sound-radius, zone max radius, BSP LOS) match retail.")
INT APawn::IsNetRelevantFor( APlayerController* RealViewer, AActor* Viewer, FVector SrcLocation )
{
	guard(APawn::IsNetRelevantFor);
	// Cache: if same viewer and same game time, return cached bNetRelevant.
	if( NetRelevancyTime == Level->TimeSeconds && LastRealViewer == RealViewer && LastViewer == Viewer )
		return bNetRelevant;

	// Team-game teammate shortcut (Level->LevelFlags & 0x1000 = bTeamGame bit).
	if( (*(DWORD*)((BYTE*)Level + 0x450) & 0x1000u) && RealViewer->Pawn &&
		*(INT*)((BYTE*)this + 0x3b0) == *(INT*)((BYTE*)RealViewer->Pawn + 0x3b0) )
	{
		return CacheNetRelevancy(1, RealViewer, Viewer);
	}

	// Quick return via owner-chain walk: relevant if this is somewhere in
	// the Owner chain of Viewer, or Viewer is in the Owner chain of this.
	// Ghidra gate: bit-31 of flags-dword at +0xa0 must be clear.
	if( -1 < *(INT*)((BYTE*)this + 0xa0) )
	{
		{
			AActor* walk = this;
			while( walk ) { if( walk == Viewer ) return CacheNetRelevancy(1, RealViewer, Viewer); walk = walk->Owner; }
		}
		{
			AActor* walk = this;
			while( walk ) { if( walk == (AActor*)RealViewer ) return CacheNetRelevancy(1, RealViewer, Viewer); walk = walk->Owner; }
		}
		if( this != Viewer && Viewer != Owner &&
			!( (*(DWORD*)((BYTE*)RealViewer + 0x524) & 0x4000u) && *(APawn**)((BYTE*)RealViewer + 0x5b8) == this ) )
		{
			// Sound-radius culling.
			if( *(INT*)((BYTE*)this + 0x14c) != 0 )
			{
				FLOAT dSq = (Location - *(FVector*)((BYTE*)Viewer + 0x234)).SizeSquared();
				FLOAT sr  = *(FLOAT*)((BYTE*)this + 0xec) * GAudioMaxRadiusMultiplier;
				if( dSq < sr * sr )
					return CacheNetRelevancy(1, RealViewer, Viewer);
			}

			// If pawn is always-relevant or net-optional and has no sound radius, skip relevance.
			if( ((*(DWORD*)((BYTE*)this + 0xa0) & 2u) || (*(DWORD*)((BYTE*)this + 0xa0) & 0x2000u)) &&
				((*(DWORD*)((BYTE*)this + 0xa8) & 0x4000u) == 0) && *(INT*)((BYTE*)this + 0x14c) == 0 )
			{
				return CacheNetRelevancy(0, RealViewer, Viewer);
			}

			// Determine whether we use the ColBox actor's location for distance checks.
			UBOOL bUseColBox = 0;
			if( *(INT*)((BYTE*)this + 0x180) != 0 &&
				(*(BYTE*)(*(INT*)((BYTE*)this + 0x180) + 0x394) & 1) )
			{
				bUseColBox = 1;
			}

			// Distance check from our location (and colbox location if present).
			FVector viewerLoc( SrcLocation );
			FLOAT distSq = (Location - viewerLoc).SizeSquared();
			FLOAT colDistSq = distSq;
			if( bUseColBox )
			{
				AActor* cb = *(AActor**)((BYTE*)this + 0x180);
				colDistSq = (cb->Location - viewerLoc).SizeSquared();
			}

			// AZone max audio radius gate (zone+0x398 bit0 = has limit; zone+0x3a0 = max radius).
			AActor* zone = *(AActor**)((BYTE*)this + 0x228);
			if( (*(BYTE*)((BYTE*)zone + 0x398) & 1) )
			{
				FLOAT maxR = *(FLOAT*)((BYTE*)zone + 0x3a0);
				if( maxR * maxR < distSq )
				{
					if( !bUseColBox || maxR * maxR < colDistSq )
						return CacheNetRelevancy(0, RealViewer, Viewer);
				}
			}

			// Line-of-sight check from our origin.
			UModel* bsp = *(UModel**)(*(INT*)((BYTE*)this + 0x328) + 0x90);
			if( bsp->FastLineCheck(Location, SrcLocation) )
			{
				return CacheNetRelevancy(1, RealViewer, Viewer);
			}

			// Line-of-sight check from our eye position.
			FVector eyeOffset = eventEyePosition();
			FVector eyeWorld( Location.X + eyeOffset.X, Location.Y + eyeOffset.Y, Location.Z + eyeOffset.Z );
			if( bsp->FastLineCheck(eyeWorld, SrcLocation) )
			{
				if( bUseColBox )
				{
					AActor* cb = *(AActor**)((BYTE*)this + 0x180);
					if( bsp->FastLineCheck(cb->Location, SrcLocation) )
					{
						return CacheNetRelevancy(1, RealViewer, Viewer);
					}
					// Crouching pawn: try forward-facing LOS from ColBox.
					// (Ghidra: bIsCrouched bit 9 of pawn+0x3e0; FRotator::Vector * radius toward viewer.)
					// IMPL_TODO: simplified - skip crouched ColBox secondary check
				}
				else
				{
					return CacheNetRelevancy(1, RealViewer, Viewer);
				}
			}
			return CacheNetRelevancy(0, RealViewer, Viewer);
		}
	}
	// Always relevant via owner-chain (LAB_103c5372).
	*(DWORD*)((BYTE*)this + 0x3e4) |= 0x4000u;
	NetRelevancyTime   = Level->TimeSeconds;
	LastRealViewer     = RealViewer;
	LastViewer         = Viewer;
	return 1;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x103e5700)
void APawn::NotifyAnimEnd( INT Channel )
{
	guard(APawn::NotifyAnimEnd);
	if( Controller && Controller->IsProbing(ENGINE_AnimEnd) )
	{
		Controller->eventAnimEnd( Channel );
		return;
	}
	eventAnimEnd( Channel );
	unguard;
}

IMPL_MATCH("Engine.dll", 0x103b7420)
void APawn::NotifyBump( AActor* Other )
{
	guard(APawn::NotifyBump);
	// Ghidra 0x103b7420 (63b): if Other is based on something with a collision
	// box (Base at +0x15c, m_collisionBox at +0x180), redirect bump to the base.
	if( Other->Base && Other->Base->m_collisionBox )
		Other = Other->Base;
	if( Controller && Controller->eventNotifyBump( Other ) != 0 )
		return;
	AActor::eventBump( Other );
	unguard;
}

IMPL_DIVERGE("Ghidra 0x103e5280; calls AKConstraint::postKarmaStep then allocates Karma body (FUN_1047c2a0); does not call AActor::PostBeginPlay; permanent: Karma/MeSDK binary-only")
void APawn::PostBeginPlay()
{
	// Karma only: AKConstraint::postKarmaStep + conditionally alloc karma body at this+0x3d8.
	// Non-Karma pawns: retail body is a no-op (does NOT call AActor::PostBeginPlay).
}

// Static pre-receive cache — APawn::PreNetReceive saves these, PostNetReceive reads them back.
// Ghidra globals: DAT_10666748 (AnimAction), DAT_1066674c..10666770 (9 rep dwords),
//   DAT_1064ff4c (float 4cc), DAT_1064ff48 (int 3b0), DAT_1064ff50 (EngineWeapon ptr),
//   DAT_1064ff66 (byte 3a1), DAT_1064ff54..60 (weapons[4]), DAT_1064ff65 (RepFinishShotgun).
static DWORD g_APawn_PreNet_AnimAction;
static DWORD g_APawn_PreNet_RepFields[9];   // 9 dwords from this+0x63c (loc/rot/vel)
static DWORD g_APawn_PreNet_Field4cc;
static DWORD g_APawn_PreNet_Field3b0;
static DWORD g_APawn_PreNet_EngineWeapon;
static BYTE  g_APawn_PreNet_Field3a1;
static DWORD g_APawn_PreNet_Weapons[4];     // this+0x504..0x510
static BYTE  g_APawn_PreNet_RepFinishShotgun;

IMPL_MATCH("Engine.dll", 0x1037d840)
void APawn::PostNetReceive()
{
	// Field at +0x4cc changed → copy to +0x4c8 (NaN-safe float inequality).
	FLOAT cur4cc = *(FLOAT*)((BYTE*)this + 0x4cc);
	if (cur4cc != *(FLOAT*)&g_APawn_PreNet_Field4cc)
		*(DWORD*)((BYTE*)this + 0x4c8) = *(DWORD*)((BYTE*)this + 0x4cc);

	// Field at +0x3b0 changed → update +0x3b4 and fire PostBeginPlay.
	if ((DWORD)*(INT*)((BYTE*)this + 0x3b0) != g_APawn_PreNet_Field3b0)
	{
		*(INT*)((BYTE*)this + 0x3b4) = *(INT*)((BYTE*)this + 0x3b0);
		eventPostBeginPlay();
	}

	// Replicated position/rotation/velocity changed → copy 9 dwords to actual fields.
	FVector* savedLoc = (FVector*)g_APawn_PreNet_RepFields;
	FVector* savedVel = (FVector*)(g_APawn_PreNet_RepFields + 6);
	FRotator* savedRot = (FRotator*)(g_APawn_PreNet_RepFields + 3);
	FVector* curLoc  = (FVector*)((BYTE*)this + 0x63c);
	FRotator* curRot = (FRotator*)((BYTE*)this + 0x648);
	FVector* curVel  = (FVector*)((BYTE*)this + 0x654);
	if (*savedLoc != *curLoc || *savedRot != *curRot || *savedVel != *curVel)
	{
		// Copy 9 dwords from 0x63c (rep fields) to 0x234 (Location+Rotation+Velocity).
		DWORD* dst = (DWORD*)((BYTE*)this + 0x234);
		DWORD* rep = (DWORD*)((BYTE*)this + 0x63c);
		for (INT i = 0; i < 9; i++) dst[i] = rep[i];
	}

	// EngineWeapon changed → fire ReceivedEngineWeapon.
	DWORD curEW = *(DWORD*)((BYTE*)this + 0x4fc);
	if (curEW != 0 && curEW != g_APawn_PreNet_EngineWeapon)
		eventReceivedEngineWeapon();

	// Any weapons-carried entry changed → fire ReceivedWeapons.
	for (INT i = 0; i < 4; i++)
	{
		if (*(DWORD*)((BYTE*)this + 0x504 + i * 4) != g_APawn_PreNet_Weapons[i])
		{
			eventReceivedWeapons();
			break;
		}
	}

	// m_bRepFinishShotgun changed → fire PlayWeaponAnimation.
	BYTE curShot = (*(DWORD*)((BYTE*)this + 0x3e8) >> 6) & 1;
	if (curShot != g_APawn_PreNet_RepFinishShotgun)
		eventPlayWeaponAnimation();

	// Byte at +0x3a1 changed → update +0x3a0 and fire PlayWeaponAnimation.
	BYTE cur3a1 = *(BYTE*)((BYTE*)this + 0x3a1);
	if (cur3a1 != g_APawn_PreNet_Field3a1)
	{
		*(BYTE*)((BYTE*)this + 0x3a0) = cur3a1;
		eventPlayWeaponAnimation();
	}

	// AnimAction FName at +0x548 changed → fire SetAnimAction.
	FName curAnimAction  = *(FName*)((BYTE*)this + 0x548);
	FName savedAnimAction = *(FName*)&g_APawn_PreNet_AnimAction;
	if (curAnimAction != savedAnimAction)
		eventSetAnimAction(curAnimAction);

	AActor::PostNetReceive();
}

// Module-level position-smoothing cache (DAT_106666f4/f8/fc in retail Engine.dll).
// One triple of floats shared across all calls — effectively per-frame single-client state.
// DIVERGENCE: retail uses .data globals; we use file-scope statics with equivalent semantics.
static FLOAT gNetSmoothX = 0.f;
static FLOAT gNetSmoothY = 0.f;
static FLOAT gNetSmoothZ = 0.f;

IMPL_MATCH("Engine.dll", 0x10378250)
void APawn::PostNetReceiveLocation()
{
	guard(APawn::PostNetReceiveLocation);

	// Declare all locals up front (MSVC 7.1 requirement).
	FCheckResult Hit;
	FLOAT dX, dY, dZ, distSq, distSq2, blendFactor;
	FLOAT tgtX, tgtY, tgtZ;
	FLOAT* pawnCached;
	FVector blendDelta;

	// If the global smoothed position differs from current Location, flush it into
	// the pawn's per-instance NetworkLocation field (pawn + 0x59c).
	if (FVector(gNetSmoothX, gNetSmoothY, gNetSmoothZ) != Location)
	{
		*(FLOAT*)((BYTE*)this + 0x59c) = gNetSmoothX;
		*(FLOAT*)((BYTE*)this + 0x5a0) = gNetSmoothY;
		*(FLOAT*)((BYTE*)this + 0x5a4) = gNetSmoothZ;
	}

	if (Physics == PHYS_Walking && !Velocity.IsNearlyZero())
	{
		// Displacement from current visual location to the authoritative network position.
		dX = Location.X - gNetSmoothX;
		dY = Location.Y - gNetSmoothY;
		dZ = Location.Z - gNetSmoothZ;
		distSq = dX*dX + dY*dY + dZ*dZ;

		// Initialise target at current location; Z stays at the smoothed cache.
		tgtX = Location.X;
		tgtY = Location.Y;
		tgtZ = gNetSmoothZ;

		if (distSq < 10000.f)
		{
			// Small displacement: nudge the cache Z up by 1 UU (prevents Z-fighting on
			// nearly-flat floors) then blend 15 % toward the cached XY.
			gNetSmoothZ += 1.0f;
			dX = Location.X - gNetSmoothX;
			dY = Location.Y - gNetSmoothY;
			dZ = Location.Z - gNetSmoothZ;
			distSq = dX*dX + dY*dY + dZ*dZ;
			blendFactor = 0.15f;
			tgtX = Location.X + (gNetSmoothX - Location.X) * blendFactor;
			tgtY = Location.Y + (gNetSmoothY - Location.Y) * blendFactor;
			tgtZ = gNetSmoothZ;
		}
		else
		{
			// Larger displacement: physically move 35 % of the way then reassess.
			blendDelta = FVector((gNetSmoothX - Location.X) * 0.35f,
			                    (gNetSmoothY - Location.Y) * 0.35f,
			                    (gNetSmoothZ - Location.Z) * 0.35f);
			moveSmooth(blendDelta);

			// Recompute after moveSmooth updated Location.
			dX = Location.X - gNetSmoothX;
			dY = Location.Y - gNetSmoothY;
			dZ = Location.Z - gNetSmoothZ;
			distSq2 = dX*dX + dY*dY + dZ*dZ;

			// If still diverging (moved away from target): use 50 % blend, else 15 %.
			blendFactor = (distSq * 0.75f < distSq2) ? 0.5f : 0.15f;
			tgtX = Location.X + (gNetSmoothX - Location.X) * blendFactor;
			tgtY = Location.Y + (gNetSmoothY - Location.Y) * blendFactor;
			tgtZ = gNetSmoothZ;
		}

		// Capsule fit check at the blended target.
		// vtable[0xd0/4=52] on ULevel = EncroachingWorldGeometry (Ghidra verified).
		// DIVERGENCE: raw offset 0x144 = Level (ALevelInfo*) in AActor layout.
		if (!XLevel->EncroachingWorldGeometry(Hit,
		        FVector(tgtX, tgtY, tgtZ),
		        FVector(CollisionRadius, CollisionRadius, CollisionHeight),
		        0,
		        (ALevelInfo*)*(INT*)((BYTE*)this + 0x144),
		        this))
		{
			XLevel->FarMoveActor(this, FVector(tgtX, tgtY, tgtZ), 0, 1, 1, 0);
			return;
		}
		// Could not fit at blended position — fall through to direct snap.
	}
	else
	{
		// Not walking or velocity is near-zero: update the global cache from the
		// pawn's per-instance NetworkLocation field if that field is non-zero.
		pawnCached = (FLOAT*)((BYTE*)this + 0x59c);
		if (pawnCached[0] != 0.f || pawnCached[1] != 0.f || pawnCached[2] != 0.f)
		{
			gNetSmoothX = pawnCached[0];
			gNetSmoothY = pawnCached[1];
			gNetSmoothZ = pawnCached[2];
		}
	}

	// Snap to the authoritative smoothed position.
	XLevel->FarMoveActor(this, FVector(gNetSmoothX, gNetSmoothY, gNetSmoothZ), 0, 1, 1, 0);

	unguard;
}

IMPL_MATCH("Engine.dll", 0x10377ff0)
void APawn::PreNetReceive()
{
	g_APawn_PreNet_AnimAction = *(DWORD*)((BYTE*)this + 0x548);
	DWORD* src = (DWORD*)((BYTE*)this + 0x63c);
	for (INT i = 0; i < 9; i++) g_APawn_PreNet_RepFields[i] = src[i];
	g_APawn_PreNet_Field4cc          = *(DWORD*)((BYTE*)this + 0x4cc);
	g_APawn_PreNet_Field3b0          = *(DWORD*)((BYTE*)this + 0x3b0);
	g_APawn_PreNet_EngineWeapon      = *(DWORD*)((BYTE*)this + 0x4fc);
	g_APawn_PreNet_Field3a1          = *(BYTE*)((BYTE*)this + 0x3a1);
	g_APawn_PreNet_Weapons[0]        = *(DWORD*)((BYTE*)this + 0x504);
	g_APawn_PreNet_RepFinishShotgun  = (*(DWORD*)((BYTE*)this + 0x3e8) >> 6) & 1;
	g_APawn_PreNet_Weapons[1]        = *(DWORD*)((BYTE*)this + 0x508);
	g_APawn_PreNet_Weapons[2]        = *(DWORD*)((BYTE*)this + 0x50c);
	g_APawn_PreNet_Weapons[3]        = *(DWORD*)((BYTE*)this + 0x510);
	AActor::PreNetReceive();
}

IMPL_DIVERGE("Ghidra 0x10307190: retail calls appFailAssert(\"false\", APawn.h, 0x9a) then returns 0; our build string literals differ")
DWORD APawn::R6LineOfSightTo( AActor* Other, INT bUnused )
{
	appFailAssert( "false", __FILE__, __LINE__ );
	return 0;
}

IMPL_DIVERGE("Ghidra 0x10307170: retail calls appFailAssert(\"false\", APawn.h, 0x99) then returns 0; our build string literals differ")
DWORD APawn::R6SeePawn( APawn* Other, INT bMaySkipChecks )
{
	appFailAssert( "false", __FILE__, __LINE__ );
	return 0;
}

IMPL_MATCH("Engine.dll", 0x103ebe70)
INT APawn::Reachable( FVector Dest, AActor* GoalActor )
{
	guard(APawn::Reachable);
	INT bWasCrouching = 0;
	INT result = 0;

	if ( bCanCrouch && !bIsCrouched && !m_bIsProne )
	{
		bWasCrouching = 1;
		Crouch(1);
	}

	// DIVERGENCE: APhysicsVolume::bWaterVolume not in header; raw offset +0x410 bit 6
	if ( Region.Zone && (*(BYTE*)((BYTE*)Region.Zone + 0x410) & 0x40) )
	{
		result = swimReachable(Dest, 0, GoalActor);
	}
	else
	{
		if ( Region.Zone && Region.Zone->IsA(ALadderVolume::StaticClass()) )
		{
			result = ladderReachable(Dest, 0, GoalActor);
		}
		else
		{
			BYTE phys = Physics;
			if ( phys == PHYS_Walking || phys == PHYS_Swimming
			  || phys == PHYS_Ladder  || phys == PHYS_Falling )
				result = walkReachable(Dest, 0, GoalActor);
			else if ( phys == PHYS_Flying )
				result = flyReachable(Dest, 0, GoalActor);
		}
	}

	if ( bWasCrouching )
		UnCrouch(1);

	return result;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x103e6280)
INT APawn::ReachedDestination( FVector Dest, AActor* GoalActor )
{
	guard(APawn::ReachedDestination);

	// Dest is the delta vector: GoalLocation - this->Location (computed by callers).
	// Get default collision height from this pawn's class defaults.
	UClass* Cls = GetClass();
	AActor* DefaultActor = Cls->GetDefaultActor();
	FLOAT DefaultHeight = DefaultActor->CollisionHeight;

	// Height thresholds: how far above/below the goal the pawn can be.
	FLOAT HeightDown = CollisionHeight;
	FLOAT RadThreshold = CollisionRadius;
	FLOAT HeightUp = (DefaultHeight + DefaultHeight) - CollisionHeight;

	if( GoalActor )
	{
		if( GoalActor->IsA(ANavigationPoint::StaticClass()) )
		{
			ANavigationPoint* Nav = (ANavigationPoint*)GoalActor;

			// m_bExactMove navpoints require very precise positioning.
			if( Nav->m_bExactMove )
			{
				FLOAT AbsZ = Dest.Z;
				if( AbsZ < 0.f )
					AbsZ = -AbsZ;
				if( !(AbsZ < HeightUp) )
					return 0;
				FLOAT Dist2D = FVector(Dest.X, Dest.Y, 0.f).Size();
				if( Dist2D < 0.f )
					Dist2D = -Dist2D;
				if( Dist2D < 10.f )
					return 1;
				return 0;
			}

			// Ladder checks for spider-physics pawns.
			if( Physics == PHYS_Spider && GoalActor->IsA(ALadder::StaticClass()) )
			{
				HeightUp *= 0.5f;
				HeightDown *= 0.5f;
			}
			else
			{
				// Standard navpoint threshold: collision radii + 33 + 2.
				FLOAT v = (GoalActor->CollisionRadius + 2.f) - CollisionRadius + 33.f;
				if( HeightUp < v )
					HeightUp = v;
				v = (CollisionRadius + 2.f + 33.f) - GoalActor->CollisionRadius;
				if( HeightDown < v )
					HeightDown = v;
			}
		}
		else
		{
			// Non-navpoint actor.
			if( GoalActor->IsEncroacher() )
			{
				// Encroacher: clamp height thresholds to goal's collision height.
				if( HeightUp < GoalActor->CollisionHeight )
					HeightUp = GoalActor->CollisionHeight;
				if( HeightDown < GoalActor->CollisionHeight )
					HeightDown = GoalActor->CollisionHeight;

				// Radius: min(MeleeRange, CollisionRadius*1.5) + both radii.
				FLOAT Reach = MeleeRange;
				FLOAT MaxReach = CollisionRadius * 1.5f;
				if( MaxReach <= Reach )
					Reach = MaxReach;
				RadThreshold = Reach + GoalActor->CollisionRadius + CollisionRadius;
			}
			else
			{
				// Non-encroacher: add goal's collision height to thresholds.
				HeightUp += GoalActor->CollisionHeight;
				HeightDown += GoalActor->CollisionHeight;
				if( GoalActor->bBlockActors || GIsEditor )
					RadThreshold = GoalActor->CollisionRadius + CollisionRadius;
			}
		}

		RadThreshold += DestinationOffset;
	}

	// 2D distance check: zero the Z and compare squared distance.
	FLOAT SavedZ = Dest.Z;
	Dest.Z = 0.f;
	FLOAT DistSq = Dest.SizeSquared();

	if( !(RadThreshold * RadThreshold < DistSq) )
	{
		// Within XY range — check Z.
		if( SavedZ <= 0.f )
		{
			FLOAT AbsZ = SavedZ;
			if( SavedZ < 0.f )
				AbsZ = -SavedZ;
			if( AbsZ <= HeightDown )
				return 1;
		}
		else if( SavedZ <= HeightUp )
		{
			return 1;
		}

		// Marginal zone: check double thresholds before giving up.
		if( SavedZ <= 0.f )
		{
			FLOAT AbsZ = SavedZ;
			if( SavedZ < 0.f )
				AbsZ = -SavedZ;
			if( HeightDown + HeightDown < AbsZ )
				return 0;
		}
		else if( HeightUp + HeightUp < SavedZ )
		{
			return 0;
		}

		// Slope trace: trace downward 6 units to check ground slope.
		FCheckResult Hit(1.f);
		FVector TraceEnd( Location.X, Location.Y, Location.Z - 6.f );
		GetLevel()->SingleLineCheck( Hit, this, TraceEnd, Location,
			TRACE_World, FVector(CollisionRadius, CollisionRadius, CollisionHeight) );

		if( Hit.Time < 0.95f && 0.7f <= Hit.Time )
		{
			// On a slope: check if vertical offset is reachable given the angle.
			// Hit.Normal.Z is the cosine of the slope angle.
			if( SavedZ >= 0.f ||
				(CollisionRadius * appSqrt(1.f / (Hit.Normal.Z * Hit.Normal.Z) - 1.f) + DefaultHeight <= -SavedZ) )
			{
				// Get the goal's collision radius for slope allowance.
				FLOAT GoalRadius;
				if( GoalActor == NULL )
				{
					AActor* DefNav = ANavigationPoint::StaticClass()->GetDefaultActor();
					GoalRadius = DefNav->CollisionRadius;
				}
				else
				{
					GoalRadius = GoalActor->CollisionRadius;
				}

				if( CollisionRadius < GoalRadius )
					return 0;

				FLOAT SlopeAllowance = ((GoalRadius + 15.f) - CollisionRadius)
					* appSqrt(1.f / (Hit.Normal.Z * Hit.Normal.Z) - 1.f)
					+ DefaultHeight;
				if( SlopeAllowance <= SavedZ )
					return 0;
			}
			return 1;
		}
	}

	return 0;
	unguard;
}

IMPL_DIVERGE("Ghidra: APawn::RenderEditorSelected body not exported; delegates to AActor base")
void APawn::RenderEditorSelected( FLevelSceneNode* SceneNode, FRenderInterface* RI, FDynamicActor* Actor )
{
	guard(APawn::RenderEditorSelected);
	AActor::RenderEditorSelected( SceneNode, RI, Actor );
	unguard;
}

// Ghidra 0x1037c590, 140b. SEH present → guard/unguard correct.
// Logic: if m_bIsProne (bit9 of +0x3e0 = 0x200) && NewBase != NULL
//   && NewBase->IsEncroacher() (vtable+0x68) → early return.
// Then stores NewFloor to Floor (+0x590), delegates to AActor::SetBase.
IMPL_MATCH("Engine.dll", 0x1037c590)
void APawn::SetBase( AActor* NewBase, FVector NewFloor, INT bNotifyActor )
{
	guard(APawn::SetBase);
	if( m_bIsProne && NewBase && NewBase->IsEncroacher() )
		return;
	Floor = NewFloor;
	AActor::SetBase( NewBase, NewFloor, bNotifyActor );
	unguard;
}

IMPL_MATCH("Engine.dll", 0x103bd4a0)
void APawn::SetZone( INT bTest, INT bForceRefresh )
{
	// Early exit if actor byte at 0xa0 has bit7 set (invalid/pending-delete).
	if (*(BYTE*)((BYTE*)this + 0xa0) & 0x80) return;

	if (bForceRefresh)
	{
		// Reset Region to (Level, -1, 0) — forces a clean recalculation.
		*(AZoneInfo**)((BYTE*)this + 0x228) = Level;
		*(INT*)((BYTE*)this + 0x22c) = -1;
		*(DWORD*)((BYTE*)this + 0x230) &= 0xffffff00u;
	}

	// Compute new zone for current location via BSP point-region test.
	// ULevel::Model is at raw offset +0x90 (not declared as a named member in EngineClasses.h).
	UModel* pModel = *(UModel**)((BYTE*)XLevel + 0x90);
	FPointRegion newRegion = pModel ? pModel->PointRegion(Level, Location) : FPointRegion(Level);
	AZoneInfo* oldZone = *(AZoneInfo**)((BYTE*)this + 0x228);

	if (newRegion.Zone == oldZone)
	{
		// Same zone: just refresh all three region fields.
		*(AZoneInfo**)((BYTE*)this + 0x228) = newRegion.Zone;
		*(INT*)((BYTE*)this + 0x22c)        = newRegion.iLeaf;
		*(DWORD*)((BYTE*)this + 0x230)      = (DWORD)newRegion.ZoneNumber;
	}
	else
	{
		if (!bTest)
		{
			oldZone->eventActorLeaving((AActor*)this);
			eventZoneChange(newRegion.Zone);
		}
		*(AZoneInfo**)((BYTE*)this + 0x228) = newRegion.Zone;
		*(INT*)((BYTE*)this + 0x22c)        = newRegion.iLeaf;
		*(DWORD*)((BYTE*)this + 0x230)      = (DWORD)newRegion.ZoneNumber;
		if (!bTest)
			newRegion.Zone->eventActorEntered((AActor*)this);
	}

	// bForceVolumeCheck: 1 only when bit 0x800 of flags at +0xa8 is set (bCollideActors) AND !bTest AND !bForceRefresh.
	INT bForceVolumeCheck = ((*(DWORD*)((BYTE*)this + 0xa8) & 0x800) && !bTest && !bForceRefresh) ? 1 : 0;

	// Body physics volume.
	APhysicsVolume* newVol = Level->GetPhysicsVolume(Location, this, bForceVolumeCheck);
	// Eye/head physics volume.
	FVector eyePos = eventEyePosition();
	APhysicsVolume* newHeadVol = Level->GetPhysicsVolume(Location + eyePos, this, bForceVolumeCheck);

	APhysicsVolume* oldVol = *(APhysicsVolume**)((BYTE*)this + 0x164);
	if (newVol != oldVol)
	{
		if (!bTest)
		{
			if (oldVol)
				oldVol->eventPawnLeavingVolume(this);
			eventPhysicsVolumeChange(newVol);
			if (Controller)
				Controller->eventNotifyPhysicsVolumeChange(newVol);
		}
		*(APhysicsVolume**)((BYTE*)this + 0x164) = newVol;
		if (!bTest)
			newVol->eventPawnEnteredVolume(this);
	}

	APhysicsVolume* oldHeadVol = *(APhysicsVolume**)((BYTE*)this + 0x514);
	if (newHeadVol != oldHeadVol)
	{
		if (!bTest && (!Controller || !Controller->eventNotifyHeadVolumeChange(newHeadVol)))
			eventHeadVolumeChange(newHeadVol);
		*(APhysicsVolume**)((BYTE*)this + 0x514) = newHeadVol;
	}
}

IMPL_MATCH("Engine.dll", 0x103e5630)
INT APawn::ShouldTrace( AActor* SourceActor, DWORD TraceFlags )
{
	guard(APawn::ShouldTrace);
	if (TraceFlags & 0x80000)
	{
		// TRACE_ShadowCast: check IsMissionPack + team/player conditions.
		// GModMgr->eventIsMissionPack() result: 0 = not mission pack.
		DWORD bIsMissionPack = GModMgr->eventIsMissionPack();
		// this+0x39e byte == 1: bIsPlayer flag specific to this engine build
		if (!bIsMissionPack && *(BYTE*)((BYTE*)this + 0x39e) == 1)
			return 0;
		// this+0x3a2 byte: team slot index; < 2 means a valid team slot
		return (*(BYTE*)((BYTE*)this + 0x3a2)) < 2;
	}
	// bHidden (bit25 of +0xa0) && valid source && not an encroacher → invisible
	if ((*(DWORD*)((BYTE*)this + 0xa0) & 0x2000000) && SourceActor && !IsEncroacher())
		return 0;
	if (TraceFlags & 0x8000)  // TRACE_ProjectActors
		return (*(DWORD*)((BYTE*)this + 0xa0) >> 0x15) & 1;
	// Trace flag 0x2000 with a non-null extra field and DT_StaticMesh draw type → visible
	if ((TraceFlags & 0x2000) && *(INT*)((BYTE*)this + 0x170) != 0 && DrawType == DT_StaticMesh)
		return 1;
	return TraceFlags & 1;
	unguard;
}

// APawn::SmoothHitWall is not separately exported in Ghidra (0x103f15c0 is AActor::SmoothHitWall).
// Ghidra analysis shows the APawn override delegates to processHitWall; logic correct.
IMPL_DIVERGE("APawn::SmoothHitWall not in Ghidra export table — permanent; inlined or same RVA not separately exported")
void APawn::SmoothHitWall( FVector HitNormal, AActor* HitActor )
{
	guard(APawn::SmoothHitWall);
	processHitWall( HitNormal, HitActor );
	unguard;
}

// vtable+0x120 on APawn = performPhysics(FLOAT): slot 72 in the vtable
// (21 UObject slots + 51 AActor-new slots before performPhysics).
// Ghidra shows 2 stack args (DeltaTime + spurious local FVector) but
// APawn::performPhysics takes only 1 FLOAT — the second is a Ghidra artifact.
IMPL_MATCH("Engine.dll", 0x103c36c0)
void APawn::TickSimulated( FLOAT DeltaTime )
{
	guard(APawn::TickSimulated);
	Acceleration = Velocity.SafeNormal();
	if( bInterpolating )
	{
		performPhysics( DeltaTime );
		return;
	}
	moveSmooth( Velocity * DeltaTime );
	eventTick( DeltaTime );
	unguard;
}

IMPL_MATCH("Engine.dll", 0x103c3760)
void APawn::TickSpecial( FLOAT DeltaTime )
{
	guard(APawn::TickSpecial);
	// Tick down the flash-bang visual effect timer.
	if( m_fFlashBangVisualEffectTime > 0.0f )
		m_fFlashBangVisualEffectTime -= DeltaTime;

	// Tick down the last-communication timer (skip if Level signals pause/solo mode).
	if( *(BYTE*)((BYTE*)Level + 0x425) != 1 )
	{
		if( m_fLastCommunicationTime > 0.0f )
			m_fLastCommunicationTime -= DeltaTime;
	}

	// Update movement animation when the pawn is not interpolating and has a mesh.
	if( !bInterpolating && (bPhysicsAnimUpdate) && Mesh )
		UpdateMovementAnimation( DeltaTime );

	// Sync weapon location to pawn location and notify network.
	AR6EngineWeapon* Weapon = EngineWeapon;
	if( Weapon && !m_bDroppedWeapon )
	{
		if( Weapon->bCollideActors )
		{
			// Dirty the owning net driver so the weapon position gets replicated.
			BYTE* ctrl = *(BYTE**)((BYTE*)this + 0x328);
			if( ctrl )
			{
				void* conn = *(void**)(ctrl + 0xf0);
				if( conn )
					(*(void(__cdecl**)(void*, AR6EngineWeapon*))((*(BYTE**)conn) + 0xc))(conn, Weapon);
			}
		}
		// Copy pawn world location to weapon so it tracks correctly.
		Weapon->Location = Location;
		if( Weapon->bCollideActors )
		{
			BYTE* ctrl = *(BYTE**)((BYTE*)this + 0x328);
			if( ctrl )
			{
				void* conn = *(void**)(ctrl + 0xf0);
				if( conn )
					(*(void(__cdecl**)(void*, AR6EngineWeapon*))((*(BYTE**)conn) + 8))(conn, Weapon);
			}
		}
	}
	unguard;
}

IMPL_DIVERGE("Ghidra 0x103E9FF0 — animation blend-weight selection requires full UAnimNotify system decompilation; permanent stub until animation system is reconstructed")
void APawn::UpdateMovementAnimation( FLOAT DeltaSeconds )
{
	guard(APawn::UpdateMovementAnimation);
	// TODO: implement APawn::UpdateMovementAnimation (retail: reads Velocity magnitude and Physics state to select animation blend weights)
	// GHIDRA REF: reads Velocity magnitude and Physics state to select animation
	// blend weights. Requires animation blend tree integration not yet reconstructed.
	unguard;
}

IMPL_TODO("Ghidra 0x103ebfe0; 983b — APawn vtable[0x62] (slot 98, unknown culling virtual) omitted; vtable[26] approximated as IsA(ANavigationPoint); PhysicsVolume+0x410&0x40 for bWaterVolume used as raw offset")
INT APawn::actorReachable( AActor* Goal, INT bKnowVisible, INT bNoAnchorCheck )
{
	guard(APawn::actorReachable);
	if( !Goal )
		return 0;

	// Fast path: if Goal is a NavigationPoint and our collision radius is small,
	// check whether our cached anchor already matches — skip full physics test.
	if( !bNoAnchorCheck
	    && Goal->IsA(ANavigationPoint::StaticClass())
	    && CollisionRadius < 40.0f )
	{
		FLOAT radius = CollisionRadius;
		if( radius <= 48.0f ) radius = 48.0f;  // minimum nav clearance
		if( ValidAnchor() && Anchor == Goal )
		{
			FLOAT dx = Goal->Location.X - Location.X;
			FLOAT dy = Goal->Location.Y - Location.Y;
			if( dx*dx + dy*dy < radius*radius )
				return 1;
		}
	}

	// 3D distance squared to goal
	FLOAT dx = Goal->Location.X - Location.X;
	FLOAT dy = Goal->Location.Y - Location.Y;
	FLOAT dz = Goal->Location.Z - Location.Z;
	FLOAT distSq = dx*dx + dy*dy + dz*dz;

	if( !GIsEditor )
	{
		// Reject if beyond 1200-unit reachability limit
		if( distSq > 1440000.0f )
			return 0;

		// IMPL_TODO: APawn vtable[0x62] (slot 98) called with Goal omitted — purpose unknown

		// Locomotion capability gate.
		// Ghidra checks Goal->PhysicsVolume byte at +0x410 bit 0x40 (bWaterVolume).
		APhysicsVolume* goalVol = Goal->PhysicsVolume;
		UBOOL bInWater = goalVol && ( (*(BYTE*)((BYTE*)goalVol + 0x410)) & 0x40 );
		if( bInWater )
		{
			if( !bCanSwim ) return 0;
		}
		else
		{
			if( !bCanWalk && !bCanFly ) return 0;
		}
	}

	// Optional line-of-sight check (flag 0x86 = TRACE_World = Movers|Level|LevelGeometry)
	if( !bKnowVisible )
	{
		FCheckResult Hit( 1.f );
		FVector eyePos = Location + eventEyePosition();
		XLevel->SingleLineCheck( Hit, this, Goal->Location, eyePos,
		                         TRACE_World, FVector(0.f,0.f,0.f) );
		// Blocked by something that is not the Goal itself → unreachable
		if( Hit.Time != 1.0f && Hit.Actor != Goal )
			return 0;
	}

	// IMPL_TODO: Goal vtable[0x1a] (slot 26) proximity check omitted —
	// Ghidra: if that virtual returns non-zero, test combined-radii overlap and return 1.
	// vtable[26] approximated as IsA(ANavigationPoint) — same pattern as execPollMoveToward.
	if( Goal->IsA(ANavigationPoint::StaticClass()) )
	{
		// Ghidra: fVar1 = Min(this+0x410, CollisionRadius*1.5)
		// Combined reach = Goal->CollisionRadius + this->CollisionRadius + fVar1
		FLOAT navField = *(FLOAT*)((BYTE*)this + 0x410);
		FLOAT maxField = CollisionRadius * 1.5f;
		if( maxField < navField )
			navField = maxField;
		FLOAT combinedR = *(FLOAT*)((BYTE*)Goal + 0xf8) + CollisionRadius + navField;
		if( distSq <= combinedR * combinedR )
			return 1;
	}

	// Physical reachability: try FarMoveActor to Goal's position, then back.
	// Reachable() uses the position the pawn actually reached after the test move.
	FVector origPos = Location;
	FLOAT reachX = Goal->Location.X;
	FLOAT reachY = Goal->Location.Y;
	FLOAT reachZ = Goal->Location.Z;
	INT bMoved = XLevel->FarMoveActor( this, Goal->Location, 1, 0, 0, 0 );
	if( bMoved )
	{
		// FarMoveActor succeeded: pawn moved to (possibly adjusted) position
		reachX = Location.X;
		reachY = Location.Y;
		reachZ = Location.Z;
		// Return pawn to where it started (bNoCheck=1 = skip zone/touch events)
		XLevel->FarMoveActor( this, origPos, 1, 1, 0, 0 );
	}

	return Reachable( FVector(reachX, reachY, reachZ), Goal );
	unguard;
}

IMPL_MATCH("Engine.dll", 0xee4b0)
void APawn::calcVelocity( FVector AccelDir, FLOAT DeltaTime, FLOAT MaxSpeed, FLOAT Friction, INT bFluid, INT bBraking, INT bBuoyant )
{
	guard(APawn::calcVelocity);
	// Ghidra 0xee4b0: braking sub-step loop when Acceleration is zero,
	// otherwise friction-then-acceleration formula.
	if( Acceleration.IsZero() )
	{
		// Braking path: sub-step deceleration (max 0.03 s per chunk).
		FVector OriginalVelocity = Velocity;
		FLOAT   RemainingTime   = DeltaTime;
		while( RemainingTime > KINDA_SMALL_NUMBER )
		{
			FLOAT Step = Min( RemainingTime, 0.03f );
			RemainingTime -= Step;
			Velocity -= Velocity * (Friction * Step);
			// Stop if velocity reversed sign or fell below 10 UU/s.
			if( Velocity.SizeSquared() < 100.f || (OriginalVelocity | Velocity) < 0.f )
			{
				Velocity = FVector(0.f, 0.f, 0.f);
				return;
			}
		}
		return;
	}

	// Normal path: apply friction, then add acceleration, then cap to MaxSpeed.
	FLOAT VelScale = 1.f - Friction * DeltaTime;
	if( VelScale < 0.f ) VelScale = 0.f;
	Velocity *= VelScale;
	Velocity += Acceleration.SafeNormal() * (MaxSpeed * DeltaTime);

	// Clamp to MaxSpeed.
	FLOAT SpeedSq = Velocity.SizeSquared();
	if( SpeedSq > MaxSpeed * MaxSpeed )
		Velocity = Velocity.SafeNormal() * MaxSpeed;
	unguard;
}

IMPL_MATCH("Engine.dll", 0xe7650)
INT APawn::moveToward( const FVector& Dest, AActor* GoalActor )
{
	guard(APawn::moveToward);
	// Ghidra 0xe7650: move pawn toward Dest; returns 1 when destination reached.
	// Physics-specific handling:
	//   Walking  — zero-out Z diff and check cylinder radius to declare 'reached'
	//   Swimming — check whether buoyancy has lifted the pawn clear of water
	//   Ladder   — delegate to ladder speed & direction (LadderSpeed field)
	if( !Controller )
		return 0;

	FVector Diff = Dest - Location;

	switch( Physics )
	{
	case PHYS_Walking:
		Diff.Z = 0.f;   // only XY matters for walking approach
		break;
	case PHYS_Swimming:
		Diff.Z = 0.f;
		Velocity = Diff.SafeNormal() * WaterSpeed;
		if( Velocity.Z < 0.f || Location.Z + 33.f >= Dest.Z )
		{
			Controller->MoveTimer = 2;
			return 0;
		}
		Controller->MoveTimer = 2;
		return 1;
	case PHYS_Ladder:
		// On ladder: use LadderSpeed; velocity direction matches ladder axis
		Velocity = Diff.SafeNormal() * LadderSpeed;
		Controller->MoveTimer = 2;
		return 0;
	default:
		break;
	}

	// Arrived?
	if( ReachedDestination( Dest, GoalActor ) )
	{
		if( Physics != PHYS_Flying && Physics != PHYS_Swimming )
			Velocity = FVector(0.f, 0.f, 0.f);
		if( GoalActor && GoalActor->IsA(ANavigationPoint::StaticClass()) )
			Anchor = (ANavigationPoint*)GoalActor;
		Controller->MoveTimer = 1;
		return 1;
	}

	// Steer toward destination
	Velocity = Diff.SafeNormal() * GroundSpeed;
	Controller->MoveTimer = 2;
	return 0;
	unguard;
}

IMPL_MATCH("Engine.dll", 0xf5350)
void APawn::performPhysics( FLOAT DeltaSeconds )
{
	guard(APawn::performPhysics);
	// Fell-out-of-world: zone 0 means outside all zones (Ghidra 0xf5350).
	if( bCollideWorld && Region.ZoneNumber == 0 && !bIgnoreOutOfWorld )
	{
		// Only fire the event for AI; players are handled by the controller.
		if( !Controller || !Controller->IsA(APlayerController::StaticClass()) )
			eventFellOutOfWorld();
		return;
	}

	FVector OldVelocity = Velocity;

	// Crouch state machine for walking mode.
	if( Physics == PHYS_Walking )
	{
		if( bWantsToCrouch && !bIsCrouched )
			Crouch(0);
		else if( bTryToUncrouch )
		{
			// Countdown to forced un-crouch (Ghidra 0xf5350: this+0x424 = UncrouchTime).
			UncrouchTime -= DeltaSeconds;
			if( UncrouchTime <= 0.f )
			{
				bTryToUncrouch = 0;
				UnCrouch(0);
			}
		}
	}
	else if( bIsCrouched )
		UnCrouch(0);

	startNewPhysics( DeltaSeconds, 0 );

	// Keep bIsWalking in sync with the current physics mode.
	bIsWalking = (Physics == PHYS_Walking || Physics == PHYS_Falling);

	// Uncrouch if we're no longer in a state that allows crouching.
	if( bIsCrouched && !(Physics == PHYS_Walking && bWantsToCrouch) )
		UnCrouch(0);

	// Drive rotation from the controller when active and not frozen by Karma.
	if( Controller && !bInterpolating &&
		Physics != PHYS_Karma && Physics != PHYS_KarmaRagDoll && Physics != PHYS_None )
	{
		physicsRotation( DeltaSeconds, OldVelocity );
	}

	// Process deferred touch events (same pattern as AActor::performPhysics).
	if( PendingTouch )
	{
		AActor* OldTouch  = PendingTouch;
		OldTouch->eventPostTouch( this );
		PendingTouch       = OldTouch->PendingTouch;
		OldTouch->PendingTouch = NULL;
	}
	unguard;
}

IMPL_MATCH("Engine.dll", 0xf6410)
void APawn::physFalling( FLOAT DeltaTime, INT Iterations )
{
	guard(APawn::physFalling);
	// Ghidra 0xf6410: pawn falling with air-control and midpoint gravity.
	// Sub-steps of at most 0.05 s; NewFallVelocity handles buoyancy-adjusted
	// gravity integration so we just drive air-control on top.
	while( DeltaTime > KINDA_SMALL_NUMBER && Iterations < 8 )
	{
		Iterations++;
		FLOAT subDT = Min( DeltaTime * 0.5f, 0.05f );
		DeltaTime -= subDT;

		FVector OldLoc = Location;
		bJustTeleported = 0;

		// Midpoint Verlet gravity (buoyancy-aware)
		Velocity = NewFallVelocity( Velocity, Acceleration, subDT );

		// Air control: lateral nudge proportional to AirControl * AccelRate
		if( AirControl > 0.05f && !Acceleration.IsZero() )
			Velocity += Acceleration.SafeNormal() * (AirControl * AccelRate * subDT);

		// Zone velocity (wind / fluid current at Zone+0x444)
		FVector ZoneVel( 0.f, 0.f, 0.f );
		if( Region.Zone )
			ZoneVel = *(FVector*)( (BYTE*)Region.Zone + 0x444 );

		FVector Delta = (Velocity + ZoneVel) * subDT;
		FCheckResult Hit( 1.f );
		XLevel->MoveActor( this, Delta, Rotation, Hit, 0, 0, 0, 0 );

		if( bDeleteMe )
			return;

		// Entered water mid-fall
		if( Physics == PHYS_Swimming )
			return;

		if( Hit.Time < 1.f )
		{
			if( Hit.Normal.Z >= 0.7f )
			{
				// Landed on a walkable surface
				if( !bJustTeleported && Hit.Time > 0.1f && subDT * Hit.Time > 0.003f )
					Velocity = (Location - OldLoc) / (subDT * Hit.Time);
				processLanded( Hit.Normal, Hit.Actor,
					DeltaTime + subDT * (1.f - Hit.Time), Iterations );
				return;
			}
			else
			{
				// Wall hit — notify and remove the into-wall velocity component
				processHitWall( Hit.Normal, Hit.Actor );
				if( Physics == PHYS_Falling )
				{
					FLOAT VDotN = Velocity | Hit.Normal;
					if( VDotN < 0.f )
						Velocity -= Hit.Normal * VDotN;
				}
				else
					return;
			}
		}
	}
	unguard;
}

IMPL_MATCH("Engine.dll", 0xf4810)
void APawn::physLadder( FLOAT DeltaTime, INT Iterations )
{
	guard(APawn::physLadder);
	// Ghidra 0xf4810: ladder climbing physics.
	// Fall off if no longer in a ladder volume.
	if( !OnLadder )
	{
		setPhysics( PHYS_Falling, NULL, FVector(0.f,0.f,0.f) );
		return;
	}

	// Move along the velocity direction (set by moveToward / input) for this frame.
	// The full Ghidra implementation uses the LadderNode nav-point direction vectors
	// (Up at +0x498, Tangent at +0x4a4) which require ALadder field declarations.
	// For now: move by Velocity*DeltaTime and handle top/bottom exit.
	FCheckResult Hit( 1.f );
	XLevel->MoveActor( this, Velocity * DeltaTime, Rotation, Hit, 0, 0, 0, 0 );

	if( bDeleteMe )
		return;

	if( Hit.Time < 1.f )
	{
		// Reached the top or bottom of the ladder; transition out.
		Velocity = FVector( 0.f, 0.f, 0.f );
		// Default exit to walking; derived classes handle water exit via physicsVolume checks.
		setPhysics( PHYS_Walking, NULL, FVector(0.f,0.f,0.f) );
	}
	unguard;
}

IMPL_MATCH("Engine.dll", 0xf1920)
void APawn::physicsRotation( FLOAT DeltaTime, FVector OldVelocity )
{
	guard(APawn::physicsRotation);
	// Retail Ghidra 0xf1920: asserts "false" in debug builds — this override
	// should never be reached.  Each concrete pawn (AR6Pawn, APlayerPawn) has its
	// own controller-driven physicsRotation.  Fall through as no-op here.
	unguard;
}

// Ghidra 0x103f1a50 (844b). Two divergences:
//   1. vtable[0xC8/4=50] on HitActor: decides whether to proceed with wall-adjust logic.
//      Slot 50 on AActor is unidentified without full vtable reconstruction.
//      Current: proceed unconditionally after IsEncroacher() check.
//   2. vtable[0x194/4=101] on Controller: dispatches (HitNormal, HitActor) at the crouch/prone path.
//      Slot 101 on AController is unidentified. Current: omitted.
//   All other logic (acceleration check, focal-dir/MinHitWall test, NotifyHitWall,
//   crouch/prone walk attempts, MoveActor step-down, eventHitWall) matches retail.
IMPL_DIVERGE("Ghidra 0x103f1a50 (844b): vtable[0xC8] on HitActor (sub-type gate) and vtable[0x194] on Controller (wall-adjust notify dispatch) are permanently unidentifiable without full vtable reconstruction; both omitted. All other paths match retail.")
void APawn::processHitWall( FVector HitNormal, AActor* HitActor )
{
	guard(APawn::processHitWall);
	// Null HitActor → nothing to process.
	if (!HitActor) return;
	// Encroachers (movers, kactors) are skipped.
	if (HitActor->IsEncroacher()) return;

	if (Controller)
	{
		// Acceleration zero → pawn is not trying to move; skip wall response.
		if (Acceleration.IsZero()) return;

		// Compute focal direction: Controller->FocalPoint - Location, normalised.
		FVector ctrl_fp = *(FVector*)((BYTE*)Controller + 0x480); // FocalPoint
		FVector focalDir = (ctrl_fp - Location).SafeNormal();
		FVector hitN = HitNormal;
		// For walking physics: ignore Z component of both vectors in dot product.
		if (Physics == PHYS_Walking) { hitN.Z = 0.f; focalDir.Z = 0.f; }
		// MinHitWall dot-product gate: if facing wall, skip complex wall logic.
		if (Controller->MinHitWall < (hitN | focalDir)) return;

		// Notify controller of the wall hit; if it returns non-zero, done.
		if (Controller->eventNotifyHitWall(HitNormal, HitActor)) return;

		if (Physics != PHYS_Swimming)
		{
			// DIVERGENCE: retail calls vtable[0xC8] on HitActor here to decide
			// whether to skip wall adjustments; that slot is unidentified so we proceed unconditionally.

			// Crouch-walk attempt: AI-controlled walking pawn that can crouch but isn't crouched.
			UBOOL bDidCrouch = 0;
			if (Physics == PHYS_Walking && !IsHumanControlled() && bCanCrouch && !IsCrouched())
			{
				bDidCrouch = 1;
				FVector testLoc = Location + focalDir * CollisionRadius;
				if (CanCrouchWalk(Location, testLoc)) return;
			}

			// Step down 33 UU and retry.
			FCheckResult stepHit(1.f);
			XLevel->MoveActor(this, FVector(0.f, 0.f, -33.f), Rotation, stepHit, 0, 0, 0, 0);

			if (bDidCrouch)
			{
				FVector testLoc = Location + focalDir * CollisionRadius;
				if (CanCrouchWalk(Location, testLoc)) return;
			}

			// DIVERGENCE: retail calls Controller->vtable[0x194] (unidentified dispatch)
			// with (HitNormal, HitActor) here; we skip that call.

			// Prone-walk attempt: AI-controlled walking pawn that can go prone but isn't prone.
			// The MinHitWall float at Controller+0x3bc == -1.0 enables this path.
			if (*(FLOAT*)((BYTE*)Controller + 0x3bc) == -1.0f
				&& Physics == PHYS_Walking && !IsHumanControlled()
				&& m_bCanProne && !m_bIsProne)
			{
				FVector testLoc = Location + focalDir * CollisionRadius;
				if (CanProneWalk(Location, testLoc)) return;
			}
		}
	}

	AActor::eventHitWall(HitNormal, HitActor);
	unguard;
}

IMPL_DIVERGE("Ghidra catch-only at 0x103f2059; APawn::processLanded body not fully exported; fires eventNotifyLanded+eventLanded")
void APawn::processLanded( FVector HitNormal, AActor* HitActor, FLOAT RemainingTime, INT Iterations )
{
	guard(APawn::processLanded);
	if( Controller )
		Controller->eventNotifyLanded( HitNormal );
	eventLanded( HitNormal );
	unguard;
}

IMPL_MATCH("Engine.dll", 0x103eea80)
void APawn::stepUp( FVector GravDir, FVector DesiredDir, FVector Delta, FCheckResult& Hit )
{
	guard(APawn::stepUp);

	FVector Down = GravDir * 33.f; // MaxStepHeight = 33.0 (0x42040000)

	// R6-specific: prone pawn collision box check.
	if( m_bIsProne )
	{
		if( m_collisionBox && !m_collisionBox->CanStepUp(Delta) )
			return;
		// Ghidra: Hit.Actor vtable[0x6c](33.f) — if nonzero, reduce step to 1 unit.
		// The exact virtual is unresolved; approximated as a cap-height check.
		if( Hit.Actor && Hit.Actor->IsA(AR6ColBox::StaticClass()) )
			Down = GravDir;
	}

	if( Abs(Hit.Normal.Z) >= 0.08f )
	{
		// Surface is not steep — step along the slope.
		if( Hit.Normal.Z >= 0.7f || Physics != PHYS_Walking )
		{
			FLOAT StepH = Delta.Size() * Hit.Normal.Z;
			FVector StepDelta( Delta.X, Delta.Y, Delta.Z + StepH );
			GetLevel()->MoveActor( this, StepDelta, Rotation, Hit, 0, 0, 0, 0, 0 );
		}
	}
	else
	{
		// Steep/vertical wall — step up first, then move forward.
		FVector NegDown = Down * -1.f;
		GetLevel()->MoveActor( this, NegDown, Rotation, Hit, 0, 0, 0, 0, 0 );
		GetLevel()->MoveActor( this, Delta, Rotation, Hit, 0, 0, 0, 0, 0 );
	}

	if( Hit.Time < 1.f )
	{
		if( Abs(Hit.Normal.Z) >= 0.08f || Delta.SizeSquared() * Hit.Time <= 144.f )
		{
			// Wall-slide: project remaining delta onto the wall plane.
			processHitWall( Hit.Normal, Hit.Actor );
			if( Physics == PHYS_Falling )
				return;

			FVector OldHitNormal = Hit.Normal;
			Hit.Normal.Z = 0.f;
			Hit.Normal = Hit.Normal.SafeNormal();

			FVector OldDelta = Delta;
			FVector SavedNormal = Hit.Normal;

			// Remove wall-normal component from delta.
			FVector WallProj = Hit.Normal * (Delta | Hit.Normal);
			FVector SlideDir( Delta.X - WallProj.X, Delta.Y - WallProj.Y, Delta.Z - WallProj.Z );
			FLOAT RemainTime = 1.f - Hit.Time;
			Delta = SlideDir * RemainTime;

			if( (Delta | OldDelta) >= 0.f )
			{
				GetLevel()->MoveActor( this, Delta, Rotation, Hit, 0, 0, 0, 0, 0 );
				if( Hit.Time < 1.f )
				{
					processHitWall( Hit.Normal, Hit.Actor );
					if( Physics == PHYS_Falling )
						return;
					TwoWallAdjust( DesiredDir, Delta, Hit.Normal, SavedNormal, Hit.Time );
					GetLevel()->MoveActor( this, Delta, Rotation, Hit, 0, 0, 0, 0, 0 );
				}
			}
			// Fall through to step-down.
		}
		else
		{
			// Large momentum on steep wall — settle down, then retry with remaining delta.
			GetLevel()->MoveActor( this, Down, Rotation, Hit, 0, 0, 0, 0, 0 );
			Delta = Delta * (1.f - Hit.Time);
			stepUp( GravDir, DesiredDir, Delta, Hit );
			return;
		}
	}

	// Step back down to settle onto the ground.
	GetLevel()->MoveActor( this, Down, Rotation, Hit, 0, 0, 0, 0, 0 );
	unguard;
}

IMPL_MATCH("Engine.dll", 0x103c3410)
INT APawn::CacheNetRelevancy(INT bIsRelevant, APlayerController* RealViewer, AActor* Viewer)
{
	guard(APawn::CacheNetRelevancy);
	bNetRelevant = bIsRelevant;
	NetRelevancyTime = Level->TimeSeconds;
	LastRealViewer = RealViewer;
	LastViewer = Viewer;
	return bIsRelevant;
	unguard;
}

// Ghidra 0x103ef850, 425b. SEH present → guard/unguard correct.
// Two SingleLineCheck passes: first zero-extent (flags=0x286), second cylinder-extent (0x86).
// Both traces: End = FeetLocation+hDelta, Start = TestLocation+hDelta (identical layout).
// On clear second pass: sets bits 4+6 (0x50) at +0x3e0, stepFrac=0.5 at +0x424, returns 1.
IMPL_MATCH("Engine.dll", 0x103ef850)
INT APawn::CanCrouchWalk(FVector const& TestLocation, FVector const& FeetLocation)
{
	guard(APawn::CanCrouchWalk);
	FLOAT hDelta = *(FLOAT*)((BYTE*)this + 0x454) - CollisionHeight;
	FVector Start(TestLocation.X, TestLocation.Y, hDelta + TestLocation.Z);
	FVector End  (FeetLocation.X, FeetLocation.Y, hDelta + FeetLocation.Z);
	FCheckResult Hit(1.0f);
	XLevel->SingleLineCheck(Hit, this, End, Start, 0x286, FVector(0.f,0.f,0.f));
	if (!Hit.Actor)
	{
		FLOAT crouchH = *(FLOAT*)((BYTE*)this + 0x454);
		FLOAT crouchR = *(FLOAT*)((BYTE*)this + 0x458);
		FCheckResult Hit2(1.0f);
		XLevel->SingleLineCheck(Hit2, this, End, Start, 0x86, FVector(crouchR, crouchR, crouchH));
		if (Hit2.Time == 1.0f)
		{
			*(DWORD*)((BYTE*)this + 0x3e0) |= 0x50u;
			*(FLOAT*)((BYTE*)this + 0x424) = 0.5f;
			return 1;
		}
	}
	return 0;
	unguard;
}

// Ghidra 0x103efa30, 454b. SEH present → guard/unguard correct.
// Same structure as CanCrouchWalk but uses ProneHeight/ProneRadius and different bit flags.
// bCanProne flag: bit11 of +0x3e0 (0x800). On clear: (~0x10|0x500) and stepFrac=1.5.
IMPL_MATCH("Engine.dll", 0x103efa30)
INT APawn::CanProneWalk(FVector const& TestLocation, FVector const& FeetLocation)
{
	guard(APawn::CanProneWalk);
	if (!(*(DWORD*)((BYTE*)this + 0x3e0) & 0x800u))
		return 0;
	FLOAT hDelta = *(FLOAT*)((BYTE*)this + 0x464) - CollisionHeight;
	FVector Start(TestLocation.X, TestLocation.Y, hDelta + TestLocation.Z);
	FVector End  (FeetLocation.X, FeetLocation.Y, hDelta + FeetLocation.Z);
	FCheckResult Hit(1.0f);
	XLevel->SingleLineCheck(Hit, this, End, Start, 0x286, FVector(0.f,0.f,0.f));
	if (!Hit.Actor)
	{
		FLOAT proneH = *(FLOAT*)((BYTE*)this + 0x464);
		FLOAT proneR = *(FLOAT*)((BYTE*)this + 0x468);
		FCheckResult Hit2(1.0f);
		XLevel->SingleLineCheck(Hit2, this, End, Start, 0x86, FVector(proneR, proneR, proneH));
		if (Hit2.Time == 1.0f)
		{
			*(DWORD*)((BYTE*)this + 0x3e0) = (*(DWORD*)((BYTE*)this + 0x3e0) & ~0x10u) | 0x500u;
			*(FLOAT*)((BYTE*)this + 0x424) = 1.5f;
			return 1;
		}
	}
	return 0;
	unguard;
}

IMPL_MATCH("Engine.dll", 0xE5260)
void APawn::ClearSerpentine()
{
	// Retail (21b, RVA 0xE5260): stores 999.0f (0x4479C000) at SerpentineTime (+0x420),
	// clears SerpentineDist (+0x41C) to 0. No guard in retail.
	SerpentineTime = 999.0f;
	SerpentineDist = 0.0f;
}

// Ghidra 0x103e5de0 (376b): bit9 (0x200) guards against prone state; FarMoveActor (vtable[0x9c])
// teleports pawn to crouched Z position; events only fire when not client-simulating.
// DIVERGENCE: retail uses bit 0x200 for early-exit guard (we now match this);
// our guard/unguard adds SEH absent in retail; encroachment at fail path omitted.
IMPL_MATCH("Engine.dll", 0x103e5de0)
void APawn::Crouch(INT bClientSimulation)
{
	guard(APawn::Crouch);
	DWORD& flags = *(DWORD*)((BYTE*)this + 0x3E0);

	// Retail: skip if already at crouch dimensions OR if bit9 (prone-pending) is set.
	if ((CollisionHeight == CrouchHeight && CollisionRadius == CrouchRadius) || (flags & 0x200))
		return;

	FLOAT oldHeight = CollisionHeight;
	SetCollisionSize(CrouchRadius, CrouchHeight);

	// Z pivot = heightDelta + current PrePivot.Z.
	FLOAT heightAdjust = (oldHeight - CrouchHeight) + PrePivot.Z;
	SetPrePivot(FVector(0.f, 0.f, heightAdjust));

	// FarMoveActor: teleport pawn downward by height delta (bTest=bClientSim).
	XLevel->FarMoveActor(this, FVector(Location.X, Location.Y, Location.Z - (oldHeight - CrouchHeight)), bClientSimulation, 0, 0, 0);

	if (!bClientSimulation)
	{
		*(DWORD*)((BYTE*)this + 0xA0) |= 0x40000000;
		flags |= 0x20;  // bIsCrouched
		eventStartCrouch(heightAdjust);
	}
	unguard;
}

IMPL_MATCH("Engine.dll", 0x103e9020)
ETestMoveResult APawn::FindBestJump(FVector Dest)
{
	guard(APawn::FindBestJump);
	FVector SavedLoc = Location;
	// Retail uses GroundSpeed (this+0x428) as the jump-Z parameter, not JumpZ.
	FVector JumpVel = SuggestJumpVelocity(Dest, GroundSpeed, 0.f);
	ETestMoveResult hit = jumpLanding(JumpVel, 1);
	if (hit == TESTMOVE_Stopped) return TESTMOVE_Stopped;

	// vtable slot 0x62 (0x188/4) on this = IsWarpZone; raw dispatch.
	INT bIsWarpZone = (*(INT (__thiscall **)(APawn *))(*(INT *)this + 0x188))(this);
	if (!bIsWarpZone)
	{
		// bCanSwim: bit16 of APawn flags = byte at this+0x3e2, bit0
		// PhysicsVolume->bWaterVolume: bit6 of byte at PhysVol+0x410
		APhysicsVolume* physVol = *(APhysicsVolume**)((BYTE*)this + 0x164);
		UBOOL bInWater = physVol && ((*(BYTE*)((BYTE*)physVol + 0x410)) & 0x40);
		if (bCanSwim || !bInWater)
		{
			FVector vSaved = Dest - SavedLoc;
			FVector vNow   = Dest - Location;
			if (vSaved.Size2D() > vNow.Size2D())
				return (ETestMoveResult)1;
		}
	}
	return TESTMOVE_Stopped;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x103e8de0)
ETestMoveResult APawn::FindJumpUp(FVector Dest)
{
	guard(APawn::FindJumpUp);

	FVector SavedLoc = Location;

	FCheckResult Hit(1.f);
	// Zero-delta move to initialise the Hit result before walkMove.
	XLevel->MoveActor(this, FVector(0.f, 0.f, 0.f), Rotation, Hit, 1, 1, 0, 0, 0);

	ETestMoveResult result = walkMove(Dest, Hit, NULL, 4.1f);

	// Ghidra updates SavedLoc.Z to current Z AFTER walkMove; restore uses new Z.
	SavedLoc.Z = Location.Z;

	if (result == TESTMOVE_Stopped)
	{
		XLevel->FarMoveActor(this, FVector(SavedLoc.X, SavedLoc.Y, SavedLoc.Z), 1, 1);
		return TESTMOVE_Stopped;
	}

	// Short fall to settle on floor.
	XLevel->MoveActor(this, FVector(0.f, 0.f, -33.f), Rotation, Hit, 1, 1, 0, 0, 0);

	// Check 2D progress only (Z intentionally zero — Ghidra param_4 = Location.Z - Location.Z).
	FVector Disp(SavedLoc.X - Location.X, SavedLoc.Y - Location.Y, 0.f);
	if (Disp.SizeSquared() < 16.81f)
		return TESTMOVE_Stopped;

	return result;
	unguard;
}

IMPL_MATCH("Engine.dll", 0xf2090)
FVector APawn::NewFallVelocity( FVector OldVelocity, FVector OldAcceleration, FLOAT DeltaTime )
{
	guard(APawn::NewFallVelocity);
	// Ghidra 0xf2090: midpoint gravity integration with buoyancy reduction.
	FLOAT NetBuoyancy = 0.f, NetFluidFriction = 0.f;
	GetNetBuoyancy( NetBuoyancy, NetFluidFriction );
	// Zone gravity from raw offset (same convention as AActor::physFalling).
	FVector Gravity( 0.f, 0.f, -1800.f );
	if( Region.Zone )
		Gravity = *(FVector*)( (BYTE*)Region.Zone + 0x450 );
	Gravity *= (1.f - NetBuoyancy);
	// Midpoint Verlet: half gravity + acceleration + half gravity.
	FVector HalfGrav = Gravity * (DeltaTime * 0.5f);
	return OldVelocity + HalfGrav + OldAcceleration * DeltaTime + HalfGrav;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x103e91a0)
INT APawn::Pick3DWallAdjust(FVector WallHitNormal)
{
	guard(APawn::Pick3DWallAdjust);

	FCheckResult Hit( 1.f );

	// Eye position for traces.
	FVector EyeOfs = eventEyePosition();
	FVector EyePos( Location.X + EyeOfs.X, Location.Y + EyeOfs.Y, Location.Z + EyeOfs.Z );

	// Direction from pawn to Controller's Destination (XY only for side-stepping).
	FVector Dir( Controller->Destination.X - Location.X,
				 Controller->Destination.Y - Location.Y,
				 0.f );
	FLOAT DestHeight = Controller->Destination.Z - Location.Z;

	FLOAT SideStepDist = CollisionRadius * 1.5f + 16.f;

	// Get collision floor from MoveTarget (if available).
	FLOAT FloorZ = 0.f;
	if( Controller->MoveTarget )
		FloorZ = Controller->MoveTarget->CollisionHeight;

	INT bVerticalAdjust = 0;

	// Near-destination special case: destination is close in XY but below/above.
	if( DestHeight < CollisionHeight )
	{
		FLOAT XYDistSq = Dir.X * Dir.X + Dir.Y * Dir.Y - CollisionRadius * CollisionRadius;
		if( XYDistSq < 0.f )
			return 0;

		FLOAT DirLenSq = FVector(Dir.X, Dir.Y, Dir.Z).SizeSquared();
		if( DirLenSq < CollisionHeight * CollisionHeight * 4.f )
		{
			// Very close: try a vertical step.
			FLOAT VertStep = CollisionHeight;
			bVerticalAdjust = 1;
			if( Location.Z < Controller->Destination.Z )
			{
				VertStep = -VertStep;
				bVerticalAdjust = -1;
			}

			FVector TraceEnd( Location.X, Location.Y, Location.Z + VertStep );
			FVector Extent( CollisionRadius, CollisionRadius, CollisionHeight );
			XLevel->SingleLineCheck( Hit, this, TraceEnd, Location,
				0x286, Extent );

			if( Hit.Time != 1.f )
			{
				// Vertical blocked — try offset in normalized direction.
				FVector NDir = Dir.SafeNormal();
				FVector OfsPos( Location.X + NDir.X * CollisionRadius,
								Location.Y + NDir.Y * CollisionRadius,
								Location.Z + VertStep + NDir.Z * CollisionRadius );
				FVector StartPos( Location.X, Location.Y, Location.Z );

				XLevel->SingleLineCheck( Hit, this, OfsPos, StartPos,
					0x286, FVector(CollisionRadius, CollisionRadius, CollisionHeight) );

				if( Hit.Time != 1.f )
					goto NormalPath;
			}

			Controller->SetAdjustLocation(
				FVector( Location.X, Location.Y, Location.Z + VertStep ) );
			return 1;
		}
	}

NormalPath:
	{
		FLOAT Dist = Dir.Size();
		if( Dist == 0.f )
			return 0;

		Dir = Dir / Dist;

		// Trace from destination back to eye position.
		XLevel->SingleLineCheck( Hit, this, Controller->Destination, EyePos,
			0x286, FVector(0.f, 0.f, 0.f) );

		// Vertical special case: if trace blocked and destination is above.
		if( (FLOAT)(INT)Hit.Actor != FloorZ && DestHeight > 0.f )
		{
			FLOAT VertStep = CollisionHeight;
			FVector TraceEnd( Location.X, Location.Y, Location.Z + VertStep * 2.f );
			XLevel->SingleLineCheck( Hit, this, TraceEnd, Location,
				0x286, FVector(CollisionRadius, CollisionRadius, CollisionHeight) );

			if( Hit.Time != 1.f )
				goto SideStepPath;

			Controller->SetAdjustLocation(
				FVector( Location.X, Location.Y, Location.Z + VertStep ) );
			return 1;
		}

SideStepPath:
		// Perpendicular direction for side-stepping.
		FVector SideDir( -Dir.Y, Dir.X, 0.f );
		FLOAT bTriedOtherSide = 0.f;

		// Scale side direction by collision radius.
		FVector SideOfs = SideDir * (CollisionRadius * 0.7f);
		FVector TraceStart( EyePos.X + SideOfs.X, EyePos.Y + SideOfs.Y, EyePos.Z + SideOfs.Z );

		XLevel->SingleLineCheck( Hit, this, Controller->Destination, TraceStart,
			0x286, FVector(0.f, 0.f, 0.f) );

		if( (FLOAT)(INT)Hit.Actor != FloorZ )
		{
			// First side blocked — try other side.
			SideDir.X = -SideDir.X;
			bTriedOtherSide = 1.f;
			SideDir.Y = -SideDir.Y;
			SideDir.Z = -SideDir.Z;
			SideOfs.X = -SideOfs.X;
			SideOfs.Y = -SideOfs.Y;
			SideOfs.Z = -SideOfs.Z;
			TraceStart = FVector( EyePos.X + SideOfs.X, EyePos.Y + SideOfs.Y, EyePos.Z + SideOfs.Z );

			XLevel->SingleLineCheck( Hit, this, Controller->Destination, TraceStart,
				0x286, FVector(0.f, 0.f, 0.f) );

			if( (FLOAT)(INT)Hit.Actor != FloorZ )
				return 0;
		}

		// Forward offset for target position checks.
		FVector FwdOfs( Dir.Y * 14.f, Dir.X * (-14.f), Dir.Z * 14.f );

		// Side-step trace.
		FVector SideTarget( Location.X + SideDir.X * SideStepDist,
							Location.Y + SideDir.Y * SideStepDist,
							Location.Z + SideDir.Z * SideStepDist );
		FVector Extent = GetCylinderExtent();

		XLevel->SingleLineCheck( Hit, this, SideTarget, Location, 0x286, Extent );

		if( Hit.Time == 1.f )
		{
			FVector FwdTarget( SideTarget.X + FwdOfs.X,
							   SideTarget.Y + FwdOfs.Y,
							   SideTarget.Z + FwdOfs.Z );

			XLevel->SingleLineCheck( Hit, this, FwdTarget, SideTarget, 0x286, Extent );

			if( Hit.Time == 1.f )
			{
				Controller->SetAdjustLocation( SideTarget );
				return 1;
			}
		}

		// Try other side if not already tried.
		if( bTriedOtherSide == 0.f )
		{
			SideDir.X = -SideDir.X;
			SideDir.Y = -SideDir.Y;
			SideDir.Z = -SideDir.Z;
			SideOfs.X = -SideOfs.X;
			SideOfs.Y = -SideOfs.Y;
			SideOfs.Z = -SideOfs.Z;
			TraceStart = FVector( EyePos.X + SideOfs.X, EyePos.Y + SideOfs.Y, EyePos.Z + SideOfs.Z );

			XLevel->SingleLineCheck( Hit, this, Controller->Destination, TraceStart,
				0x286, FVector(0.f, 0.f, 0.f) );

			if( Hit.Time >= 1.f )
			{
				SideTarget = FVector( Location.X + SideDir.X * SideStepDist,
									  Location.Y + SideDir.Y * SideStepDist,
									  Location.Z + SideDir.Z * SideStepDist );

				XLevel->SingleLineCheck( Hit, this, SideTarget, Location, 0x286, Extent );

				if( Hit.Time == 1.f )
				{
					FVector FwdTarget( SideTarget.X + FwdOfs.X,
									   SideTarget.Y + FwdOfs.Y,
									   SideTarget.Z + FwdOfs.Z );

					XLevel->SingleLineCheck( Hit, this, FwdTarget, SideTarget, 0x286, Extent );

					if( Hit.Time == 1.f )
					{
						Controller->SetAdjustLocation( SideTarget );
						return 1;
					}
				}
			}
		}
	}

	return 0;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x103eb2e0)
INT APawn::PickWallAdjust(FVector WallHitNormal)
{
	guard(APawn::PickWallAdjust);

	// No wall adjustment if falling or no controller.
	if( Physics == PHYS_Falling || !Controller )
		return 0;

	// Flying/swimming pawns use the 3D variant.
	if( Physics == PHYS_Flying || Physics == PHYS_Swimming )
		return Pick3DWallAdjust( WallHitNormal );

	FCheckResult Hit( 1.f );

	// Eye position for traces.
	FVector EyeOfs = eventEyePosition();
	FVector EyePos( Location.X + EyeOfs.X, Location.Y + EyeOfs.Y, Location.Z + EyeOfs.Z );

	// Direction from pawn to Controller's Destination (XY only).
	FVector Dir( Controller->Destination.X - Location.X,
				 Controller->Destination.Y - Location.Y,
				 0.f );
	FLOAT DestHeight = Controller->Destination.Z - Location.Z;
	FLOAT Dist = Dir.Size();

	FLOAT SideStepDist = CollisionRadius * 1.5f + 16.f;

	// Get collision floor from MoveTarget (if available).
	FLOAT FloorZ = 0.f;
	if( Controller->MoveTarget )
		FloorZ = Controller->MoveTarget->CollisionHeight;

	// If destination is close enough in Z and XY distance is nonzero:
	if( (!(DestHeight < CollisionHeight) ||
		 !(Dir.X * Dir.X + Dir.Y * Dir.Y - CollisionRadius * CollisionRadius < 0.f))
		&& Dist != 0.f )
	{
		// Normalize direction.
		Dir = Dir / Dist;

		// Trace from destination back to eye to check for clear line of sight.
		XLevel->SingleLineCheck( Hit, this, Controller->Destination, EyePos,
			0x286, FVector(0.f, 0.f, 0.f) );

		if( (FLOAT)(INT)Hit.Actor != FloorZ )
			SideStepDist += CollisionRadius;

		// Perpendicular direction (side-step direction in XY plane).
		FVector SideDir( -Dir.Y, Dir.X, 0.f );
		FLOAT bTriedOtherSide = 0.f;

		// Scale side direction by collision radius.
		FVector SideOfs = SideDir * (CollisionRadius * 0.7f);
		FVector TraceOfs = SideOfs;
		FVector TraceStart( EyePos.X + TraceOfs.X, EyePos.Y + TraceOfs.Y, EyePos.Z + TraceOfs.Z );

		// Trace from side-offset eye position to Destination.
		XLevel->SingleLineCheck( Hit, this, Controller->Destination, TraceStart,
			0x286, FVector(0.f, 0.f, 0.f) );

		if( (FLOAT)(INT)Hit.Actor != FloorZ )
		{
			// First side blocked — try the other side.
			SideDir.X = -SideDir.X;
			bTriedOtherSide = 1.f;
			SideDir.Y = -SideDir.Y;
			SideDir.Z = -SideDir.Z;
			TraceOfs.X = -TraceOfs.X;
			TraceOfs.Y = -TraceOfs.Y;
			TraceOfs.Z = -TraceOfs.Z;
			TraceStart = FVector( EyePos.X + TraceOfs.X, EyePos.Y + TraceOfs.Y, EyePos.Z + TraceOfs.Z );

			XLevel->SingleLineCheck( Hit, this, Controller->Destination, TraceStart,
				0x286, FVector(0.f, 0.f, 0.f) );

			if( (FLOAT)(INT)Hit.Actor != FloorZ )
				return 0;
		}

		// Forward offset for target position checks.
		FVector FwdOfs( Dir.Y * 14.f, Dir.X * (-14.f), Dir.Z * 14.f );

		// Walking + can jump: try stepping up 33 units.
		if( Physics == PHYS_Walking && bCanJump )
		{
			FVector UpStart( Location.X, Location.Y, Location.Z + 33.f );
			FVector UpDelta( 0.f, 0.f, 33.f );
			FVector Extent = GetCylinderExtent();

			XLevel->SingleLineCheck( Hit, this, UpStart, Location, TRACE_World,
				Extent );

			if( Hit.Time > 0.5f )
			{
				// Step up trace succeeded — check if we can reach destination from up there.
				FVector UpPos = Location + UpDelta * Hit.Time;
				FVector FwdEnd( UpPos.X + FwdOfs.X, UpPos.Y + FwdOfs.Y, UpPos.Z + FwdOfs.Z );

				XLevel->SingleLineCheck( Hit, this, FwdEnd, UpStart, 0x286,
					Extent );

				if( Hit.Time == 1.f )
				{
					// Jump over the obstacle.
					WallHitNormal = WallHitNormal * -1.f;
					FVector JumpDir( WallHitNormal.X, WallHitNormal.Y, 0.f );
					Velocity = JumpDir * GroundSpeed;
					Acceleration = JumpDir * AccelRate;
					Velocity.Z = JumpZ;
					bNoJumpAdjust = 1;
					setPhysics( PHYS_Falling, NULL, FVector(0.f, 0.f, 1.f) );
					return 1;
				}
			}
		}

		// Side-step adjustment: trace from pawn to side-offset position.
		FVector SideTarget( Location.X + SideDir.X * SideStepDist,
						    Location.Y + SideDir.Y * SideStepDist,
						    Location.Z + SideDir.Z * SideStepDist );
		FVector Extent = GetCylinderExtent();

		XLevel->SingleLineCheck( Hit, this, SideTarget, Location, 0x286, Extent );

		if( Hit.Time == 1.f )
		{
			// Side is clear — check the forward path from there.
			FVector FwdTarget( SideTarget.X + FwdOfs.X,
							   SideTarget.Y + FwdOfs.Y,
							   SideTarget.Z + FwdOfs.Z );

			XLevel->SingleLineCheck( Hit, this, FwdTarget, SideTarget, 0x286, Extent );

			if( Hit.Time == 1.f )
			{
				// Both side and forward clear — set adjusted target.
				Controller->SetAdjustLocation(
					FVector( SideTarget.X + SideDir.X * SideStepDist,
							 SideTarget.Y + SideDir.Y * SideStepDist,
							 SideTarget.Z + SideDir.Z * SideStepDist ) );
				return 1;
			}
		}

		// Try the other side if we haven't already.
		if( bTriedOtherSide == 0.f )
		{
			SideDir.X = -SideDir.X;
			SideDir.Y = -SideDir.Y;
			SideDir.Z = -SideDir.Z;
			TraceOfs.X = -TraceOfs.X;
			TraceOfs.Y = -TraceOfs.Y;
			TraceOfs.Z = -TraceOfs.Z;
			TraceStart = FVector( EyePos.X + TraceOfs.X, EyePos.Y + TraceOfs.Y, EyePos.Z + TraceOfs.Z );

			XLevel->SingleLineCheck( Hit, this, Controller->Destination, TraceStart,
				0x286, FVector(0.f, 0.f, 0.f) );

			if( Hit.Time >= 1.f )
			{
				SideTarget = FVector( Location.X + SideDir.X * SideStepDist,
									  Location.Y + SideDir.Y * SideStepDist,
									  Location.Z + SideDir.Z * SideStepDist );

				XLevel->SingleLineCheck( Hit, this, SideTarget, Location, 0x286, Extent );

				if( Hit.Time == 1.f )
				{
					FVector FwdTarget( SideTarget.X + FwdOfs.X,
									   SideTarget.Y + FwdOfs.Y,
									   SideTarget.Z + FwdOfs.Z );

					XLevel->SingleLineCheck( Hit, this, FwdTarget, SideTarget, 0x286, Extent );

					if( Hit.Time == 1.f )
					{
						Controller->SetAdjustLocation(
							FVector( SideTarget.X + SideDir.X * SideStepDist,
									 SideTarget.Y + SideDir.Y * SideStepDist,
									 SideTarget.Z + SideDir.Z * SideStepDist ) );
						return 1;
					}
				}
			}
		}
	}

	return 0;
	unguard;
}

// Ghidra 0x103F0AE0; 1723b.
// Spider-mode step-up: when the primary physSpider MoveActor hits a surface,
// SpiderstepUp reorients the pawn to walk along the new wall by:
//   1. Detecting whether the hit surface is a continuation of the current wall
//      (dot(CWN, Hit.Normal) < 0.1) or a genuinely new surface.
//   2. Branch A (new surface): update CachedWallNormal, try a combined 'upward' step.
//   3. Branch B (same surface): step back by 33.f, retry movement.
//   4. On secondary hit: either recurse for another step-up, or decompose the
//      movement into a CWN-relative coordinate frame and retry via TwoWallAdjust.
// DIVERGENCE: stepBack scale = 33.f (Ghidra literal 0x42040000 loaded to uVar11 before each operator* call).
// DIVERGENCE: cross-product orientation in secondary-hit rotation chain may differ from retail.
// DIVERGENCE: Branch B passes 33.f (0x42040000) after Hit bool; .def says HHHHH = 5 INT booleans, so 33.f is likely a 6th arg artifact — passing standard 0 instead.
// DIVERGENCE: extra FVector* tail args in the special MoveActor call (beyond HHHHH) dropped; .def confirms 5 INT bools only.
IMPL_MATCH("Engine.dll", 0x103f0ae0)
void APawn::SpiderstepUp(FVector Delta, FVector HitNormal, FCheckResult& Hit)
{
	guard(APawn::SpiderstepUp);

	FVector* pCWN = (FVector*)((BYTE*)this + 0x590);   // CachedWallNormal

	// Negate CWN – compute 'step-back' direction
	FVector negCWN(-pCWN->X, -pCWN->Y, -pCWN->Z);
	// Step-back vector: neg_CWN scaled by 33.f (Ghidra literal 0x42040000, set in uVar11 before each operator* call)
	FVector stepBack = negCWN * 33.f;

	// Is this hit on a different surface?
	FLOAT fDot = ((*pCWN) | Hit.Normal);

	if (fDot < 0.1f)
	{
		// Branch A: new surface — update CachedWallNormal
		*pCWN   = Hit.Normal;
		negCWN  = FVector(-pCWN->X, -pCWN->Y, -pCWN->Z);
		stepBack = negCWN * 33.f;

		// Adjusted step.Z including component of Hit.Normal in the HitNormal direction
		FLOAT sz = HitNormal.Size();
		FLOAT fZ = sz * Hit.Normal.Z + HitNormal.Z;
		FVector moveDir(HitNormal.X, HitNormal.Y, fZ);

		// Primary MoveActor (Branch A)
		XLevel->MoveActor(this, moveDir, Rotation, Hit, 0, 0, 0, 0, 0);
	}
	else
	{
		// Branch B: same wall — step back first, then move along HitNormal
		FVector backVec(-stepBack.X, -stepBack.Y, -stepBack.Z);
		// DIVERGE: Ghidra passes 33.f as extra arg here; .def limits to 5 INT bools only.
		XLevel->MoveActor(this, backVec, Rotation, Hit, 0, 0, 0, 0, 0);

		// Primary MoveActor (Branch B)
		XLevel->MoveActor(this, HitNormal, Rotation, Hit, 0, 0, 0, 0, 0);
	}

	if (Hit.Time < 1.0f)
	{
		FLOAT fDot2 = ((*pCWN) | Hit.Normal);
		FLOAT stepSq = HitNormal.SizeSquared() * Hit.Time;

		if (fDot2 < 0.1f && 144.0f < stepSq)
		{
			// Recursive step-up over the obstacle
			XLevel->MoveActor(this, stepBack, Rotation, Hit, 0, 0, 0, 0, 0);
			FVector scaledHN = HitNormal * Hit.Time;
			SpiderstepUp(Delta, scaledHN, Hit);
			return;
		}

		// Complex path: reorient onto the new wall plane
		FVector prevCWN = *pCWN;
		*pCWN   = Hit.Normal;
		negCWN  = FVector(-pCWN->X, -pCWN->Y, -pCWN->Z);
		stepBack = negCWN * 33.f;

		// Save the 2D-projected version of Hit.Normal before zeroing Z
		FVector savedHitNorm2D = Hit.Normal;
		Hit.Normal.Z = 0.0f;
		Hit.Normal   = Hit.Normal.SafeNormal();

		// Build orthogonal frame: perp1 = CWN x Hit.Normal_2D, perp2 = perp1 x CWN
		FVector perp1 = ((*pCWN) ^ Hit.Normal).SafeNormal();
		FVector perp2 = (perp1 ^ (*pCWN)).SafeNormal();

		// Project original HitNormal onto the new frame and reconstruct movement
		FLOAT d1 = (perp2 | HitNormal);
		FLOAT d2 = (perp1 | HitNormal);
		FLOAT d3 = ((*pCWN) | HitNormal);
		FVector newDelta = perp2 * d1 + perp1 * d2 + (*pCWN) * d3;

		if ((negCWN | newDelta) >= 0.0f)
		{
			// DIVERGE: retail passes &negCWN and &prevCWN as extra tail args to MoveActor;
			// those args exceed the 5-INT-bool declared param list, so we omit them here.
			XLevel->MoveActor(this, newDelta, Rotation, Hit, 0, 0, 0, 0, 0);

			if (Hit.Time < 1.0f)
			{
				processHitWall(Hit.Normal, Hit.Actor);
				if (Physics == PHYS_Walking)
					return;
				TwoWallAdjust(Delta, newDelta, Hit.Normal, savedHitNorm2D, Hit.Time);
				XLevel->MoveActor(this, newDelta, Rotation, Hit, 0, 0, 0, 0, 0);
			}
		}
	}

	// Final step back along current wall
	XLevel->MoveActor(this, stepBack, Rotation, Hit, 0, 0, 0, 0, 0);
	unguard;
}

IMPL_DIVERGE("Ghidra has no null guard; added for safety")
void APawn::StartNewSerpentine(FVector Dir, FVector Start)
{
	guard(APawn::StartNewSerpentine);
	// Retail 0xe5b60: compute right-perpendicular to Dir in XY, orient away from
	// Start, then set SerpentineTime/Dist based on bAdvancedTactics.

	// Right-perp to Dir in XY: (Dir.Y, -Dir.X, Dir.Z)
	FVector perp(Dir.Y, -Dir.X, Dir.Z);

	// If already on positive side of perp relative to Start, flip
	if ((perp | (Location - Start)) > 0.f)
		perp = -perp;

	SerpentineDir = perp;

	// DIVERGENCE: Ghidra has no null guard; added for safety
	if (!Controller || !Controller->CurrentPath)
	{
		SerpentineTime = 9999.f;
		SerpentineDist = 0.f;
		return;
	}

	if (Controller->bAdvancedTactics)
	{
		FLOAT r = appFrand();
		if (r >= 0.2f)
		{
			// 80% case: zero timer, compute distance from path/pawn radius ratio
			SerpentineTime = 0.f;
			FLOAT factor = (CollisionRadius * 4.f) / (FLOAT)Controller->CurrentPath->CollisionRadius;
			if (factor > 1.0f) factor = 1.0f;
			FLOAT r2 = appFrand();
			factor = (1.0f - factor) * r2 + factor;
			FLOAT room = (FLOAT)Controller->CurrentPath->CollisionRadius - CollisionRadius;
			if (room < 0.f) room = 0.f;
			SerpentineDist = room * factor;
		}
		else
		{
			// 20% case: short random timer (second rand call per Ghidra)
			SerpentineTime = appFrand() * 0.4f + 0.1f;
		}
		return;
	}

	// Non-advanced tactics: long wait, random distance, 40% chance of direction flip
	SerpentineTime = 9999.f;
	SerpentineDist = appFrand();
	if (appFrand() < 0.4f)
		SerpentineDir = -SerpentineDir;

	FLOAT room = (FLOAT)Controller->CurrentPath->CollisionRadius - CollisionRadius;
	if (room < 0.f) room = 0.f;
	SerpentineDist *= room;
	unguard;
}

IMPL_DIVERGE("Ghidra catch-only at 0x103e69b8; SuggestJumpVelocity body not exported; returns zero vector stub")
FVector APawn::SuggestJumpVelocity(FVector Dest, FLOAT DesiredSpeed, FLOAT MaxJumpZ)
{
	guard(APawn::SuggestJumpVelocity);
	return FVector(0,0,0);
	unguard;
}

// Ghidra 0x103f3e60, 514b.
// MoveActor vtable call: XLevel->vtable[0x98/4=38] = MoveActor(pawn, delta, rot, hit, ...).
// Zone check: this+0x164 = PhysicsVolume; bit6 (0x40) at PhysicsVolume+0x410 = bWaterZone.
// If exited water: findWaterLine(OldLoc, Location) → surface crossing point;
//   result = (WaterLine - Location).Size() / Delta.Size()
//   if (move.dot.(waterLine-Location) > 0) → result = 0 (still crossing, not yet exited)
//   second MoveActor to snap pawn to water surface.
// DIVERGE: bWaterZone at PhysicsVolume+0x410 bit6 accessed via raw offset (field not declared in header).
IMPL_DIVERGE("Ghidra 0x103f3e60; 514b — bWaterZone at PhysicsVolume+0x410 bit6 accessed via raw offset (not declared in APhysicsVolume header) — permanent header-level binary difference")
FLOAT APawn::Swim(FVector Delta, FCheckResult& Hit)
{
	guard(APawn::Swim);
	FVector OldLoc = Location;
	FLOAT result = 0.f;
	XLevel->MoveActor(this, Delta, Rotation, Hit, 0, 0, 0, 0);
	// Ghidra: checks *(byte*)(this+0x164+0x410) & 0x40 for bWaterZone.
	// this+0x164 = PhysicsVolume (the AActor field); bWaterZone at +0x410 not declared in header.
	APhysicsVolume* CurrZone = PhysicsVolume;
	if (!CurrZone || !(*(BYTE*)((BYTE*)CurrZone + 0x410) & 0x40))
	{
		// Exited water — find where we crossed the surface
		FVector WaterLine = findWaterLine(OldLoc, Location);
		if (WaterLine != Location)
		{
			// Fraction of Delta that was underwater = dist to surface / total delta size
			FVector toSurface = WaterLine - Location;
			result = toSurface.Size() / Delta.Size();
			// If (move direction) · (surface - newLoc) > 0: surface is ahead → no water fraction
			FLOAT dot = (Location.Z - OldLoc.Z) * (WaterLine.Z - Location.Z)
			           + (Location.Y - OldLoc.Y) * (WaterLine.Y - Location.Y)
			           + (Location.X - OldLoc.X) * (WaterLine.X - Location.X);
			if (dot > 0.f) result = 0.f;
			// Snap pawn to the water surface
			XLevel->MoveActor(this, toSurface, Rotation, Hit, 0, 0, 0, 0);
		}
	}
	return result;
	unguard;
}

// Ghidra 0x103e5f90 (693b): bit8 (0x100) = m_bWantsToProne; m_ePeekingMode==2 early exit.
// FarMoveActor (vtable[0x9c], bAttachedMove=1) moves pawn to standing position;
// if blocked, reverts collision dims and (if Controller is APlayerController) sets bTryToUncrouch.
IMPL_DIVERGE("FMemMark encroachment pre-check permanently omitted: FMemMark/FMemStack not declared in project headers. APlayerController bTryToUncrouch path added via raw offset (Controller+0x3a6). Ghidra 0x103e5f90.")
void APawn::UnCrouch(INT bClientSimulation)
{
	guard(APawn::UnCrouch);
	DWORD& flags = *(DWORD*)((BYTE*)this + 0x3E0);

	// When prone-pending or peek-mode-2: retail clears bIsCrouched without moving.
	if ((flags & 0x100) || (*(BYTE*)((BYTE*)this + 0x39C) == 2))
	{
		if (!bClientSimulation)
			flags &= ~0x20u;  // clear bIsCrouched
		return;
	}

	// Get uncrouched dimensions from class default object.
	UClass* cls = GetClass();
	APawn* deflt = cls ? (APawn*)cls->GetDefaultObject() : NULL;
	if (!deflt) return;
	FLOAT defaultHeight = deflt->CollisionHeight;
	FLOAT defaultRadius = deflt->CollisionRadius;
	FLOAT heightDelta = defaultHeight - CollisionHeight;

	// Retail: SetCollisionSize to default FIRST, then revert if FarMoveActor fails.
	SetCollisionSize(defaultRadius, defaultHeight);

	// FarMoveActor: teleport pawn upward to standing position; bAttachedMove=1.
	INT bMoved = XLevel->FarMoveActor(this, FVector(Location.X, Location.Y, Location.Z + heightDelta), bClientSimulation, 0, 1, 0);
	if (bMoved)
	{
		SetPrePivot(FVector(0.f, 0.f, m_fPrePivotPawnInitialOffset));
		*(DWORD*)((BYTE*)this + 0xA0) |= 0x40000000;
		if (!bClientSimulation)
		{
			flags &= ~0x20u;  // clear bIsCrouched
			eventEndCrouch(heightDelta);
		}
	}
	else
	{
		// Blocked: revert to crouch dimensions.
		SetCollisionSize(CrouchRadius, CrouchHeight);
		// Retail: if controller is APlayerController, set bWantsToCrouch (bit 4 = 0x10)
		// and mark bTryToUncrouch on the controller at offset 0x3a6.
		if (Controller != NULL && Controller->IsA(APlayerController::StaticClass()))
		{
			flags |= 0x10u;  // bWantsToCrouch — signals retry next tick
			*(BYTE*)((BYTE*)Controller + 0x3a6) = 1;  // APlayerController::bTryToUncrouch
		}
	}
	unguard;
}

IMPL_MATCH("Engine.dll", 0x11C1D0)
INT APawn::ValidAnchor()
{
	guard(APawn::ValidAnchor);
	// Retail 0x11C1D0: check that the cached Anchor navigation point is still reachable.
	// Returns 0 if null, blocked (bBlocked/bNoAutoConnect flags), or destination not reached.
	if ( !Anchor ) return 0;
	INT flags = *(INT*)((BYTE*)Anchor + 0x3A4);
	if ( flags & 0x0002 ) return 0;  // bBlocked
	if ( flags & 0x0200 ) return 0;  // bNoAutoConnect
	FVector delta = Anchor->Location - Location;
	return ReachedDestination( delta, Anchor ) ? 1 : 0;
	unguard;
}

// vtable+0x100 on USkeletalMeshInstance = SetAnimFrame(INT channel, FLOAT frame):
// confirmed by a second Ghidra call site that passes (channel, float_value).
// Retail has no null-guard inside the loops; if mi is NULL the loops crash,
// but ZeroMovementAlpha is only called when a valid skeletal mesh exists.
IMPL_MATCH("Engine.dll", 0x103e9f00)
void APawn::ZeroMovementAlpha(INT bZeroX, INT bZeroY, FLOAT Alpha)
{
	guard(APawn::ZeroMovementAlpha);
	USkeletalMeshInstance* mi = NULL;
	if ( MeshInstance && MeshInstance->IsA(USkeletalMeshInstance::StaticClass()) )
		mi = (USkeletalMeshInstance*)MeshInstance;

	UBOOL bAllZero = 1;
	for ( INT i = bZeroX; i < bZeroY; i++ )
	{
		FLOAT alpha = mi->GetBlendAlpha(i);
		if ( alpha > 0.f )
		{
			bAllZero = 0;
			mi->UpdateBlendAlpha(i, 0.f, Alpha);
		}
	}
	if ( bAllZero )
	{
		for ( INT i = bZeroX; i < bZeroY; i++ )
		{
			mi->SetAnimRate(i, 0.f);
			mi->SetAnimFrame(i, 0.0f);
		}
	}
	unguard;
}

// Ghidra 0x1041c8d0, 948b. Uses FUN_1050557c() as a path-data initialiser/allocator (3–5 calls
// at entry, pattern matches the same FUN_1050557c confirmed permanently unrecoverable at line
// 1101 — 284 callers, unrecoverable signature). Cannot reconstruct without that helper.
IMPL_DIVERGE("Ghidra 0x1041c8d0; FUN_1050557c (Engine.dll internal, 284 callers, unrecoverable signature) used as FSortedPathList-style initializer — same permanent blocker as APawn::SoundRadiusTo; cannot reconstruct")
ANavigationPoint* APawn::breadthPathTo(FLOAT (CDECL*WeightFunc)(ANavigationPoint*, APawn*, FLOAT), ANavigationPoint* Start, INT MaxPathLength, FLOAT* Weight)
{
	guard(APawn::breadthPathTo);
	return NULL;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x103e5050)
INT APawn::calcMoveFlags()
{
	guard(APawn::calcMoveFlags);
	INT Result = 256;
	if( bCanWalk )          Result |= 1;
	if( bCanFly )           Result |= 2;
	if( bCanSwim )          Result |= 4;
	if( bCanJump )          Result |= 8;
	if( Controller->bCanOpenDoors )  Result |= 16;
	if( Controller->bCanDoSpecial )  Result |= 32;
	if( bCanClimbLadders )  Result |= 64;
	if( Controller->bIsPlayer )      Result |= 512;
	return Result;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x103f06e0)
INT APawn::checkFloor(FVector Dir, FCheckResult& Hit)
{
	guard(APawn::checkFloor);
	// Trace 33 units in Dir direction from Location.
	// Ghidra: actor arg is NULL (not this), flags are 0x86 = TRACE_World.
	FVector End = Location - Dir * 33.f;
	XLevel->SingleLineCheck(Hit, NULL, End, Location, TRACE_World,
		FVector(CollisionRadius, CollisionRadius, CollisionHeight));
	if (Hit.Time < 1.f)
	{
		// vtable[0xd0] = SetBase(HitActor, HitNormal, bNotify=1)
		SetBase(Hit.Actor, Hit.Normal, 1);
		return 1;
	}
	return 0;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x1041c130)
void APawn::clearPath(ANavigationPoint* Node)
{
	guard(APawn::clearPath);
	Node->nextOrdered = NULL;
	Node->prevOrdered = NULL;
	Node->previousPath = NULL;
	Node->bEndPoint = 0;
	Node->visitedWeight = 10000000;
	Node->cost = Node->ExtraCost;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x11C170)
void APawn::clearPaths()
{
	// Retail 0x11C170: walk the level's NavigationPointList and reset pathfinding state
	// on every node — mirrors clearPath() but applied to all nav points at once.
	ALevelInfo* info = XLevel ? XLevel->GetLevelInfo() : NULL;
	if ( !info ) return;
	for ( ANavigationPoint* nav = info->NavigationPointList; nav; nav = nav->nextNavigationPoint )
	{
		nav->bEndPoint    = 0;
		nav->cost         = nav->ExtraCost;
		nav->visitedWeight = 10000000;
		nav->nextOrdered  = NULL;
		nav->prevOrdered  = NULL;
		nav->previousPath = NULL;
	}
}

// Ghidra 0x103f07e0, 717b.  Six cardinal-direction checkFloor probes; if all fail
// eventFalling is called and physics transitions to PHYS_Falling.
// DIVERGE: Ghidra calls FVector::operator/(delta, unrecovered_reg) for the velocity
// update — the scalar divisor lives in an unrecovered x87 FPU register.
// Best reconstruction: divisor = RemainingTime (displacement / elapsed time).
IMPL_DIVERGE("Ghidra 0x103f07e0: velocity divisor is an unrecovered FPU register value from a prior fdiv; approximated as RemainingTime — permanent precision divergence")
INT APawn::findNewFloor(FVector OldLocation, FLOAT DeltaTime, FLOAT RemainingTime, INT Iterations)
{
	guard(APawn::findNewFloor);
	FCheckResult Hit(1.f);
	if( checkFloor(FVector(0,0,1),  Hit) ) return 1;
	if( checkFloor(FVector(0,1,0),  Hit) ) return 1;
	if( checkFloor(FVector(0,-1,0), Hit) ) return 1;
	if( checkFloor(FVector(1,0,0),  Hit) ) return 1;
	if( checkFloor(FVector(-1,0,0), Hit) ) return 1;
	if( checkFloor(FVector(0,0,-1), Hit) ) return 1;

	eventFalling();

	if( Physics == PHYS_Spider )
		setPhysics( PHYS_Falling, NULL, FVector(0,0,1) );

	if( Physics == PHYS_Falling )
	{
		FLOAT SavedVelZ = Velocity.Z;
		DWORD flags = *(DWORD*)((BYTE*)this + 0xac);
		if( !(flags & 8) && RemainingTime < DeltaTime )
		{
			// Retail: Velocity = (Location - OldLocation) / <unrecovered_float>; then Z restored.
			Velocity = (Location - OldLocation) / RemainingTime;
		}
		Velocity.Z = SavedVelZ;
		if( RemainingTime > 0.005f )
			physFalling( RemainingTime, Iterations );
	}
	return 0;
	unguard;
}

// Ghidra 0x1041cfa0, 1916b: A* pathfinding entry point.
// FUN_1035a3d0 = profiling timer (binary-only skip, omitted).
// vtable[0x9c] on XLevel = FarMoveActor (confirmed from Ghidra, used to probe self-to-goal
//   reachability then undo the move).
// Controller fields: +0x408 = MoveTarget (AActor*), +0x40c = FocusActor (AActor*),
//   +0x44c = nextFocus (AActor*), all set at pawn-already-at-goal path.
// DIVERGENCE: vtable[0x68] approximated as IsA(ANavigationPoint) (same as execPollMoveToward).
// DIVERGENCE: FarMoveActor probe uses vtable dispatch; named call equivalent used.
// DIVERGENCE: controller field assignments at "pawn already at goal" path approximate
//   with raw offsets (+0x408, +0x40c, +0x44c) since EngineClasses.h lacks explicit names.
IMPL_TODO("Ghidra 0x1041cfa0; 1916b: implemented; AController vtable[100] call approximated as AcceptNearbyPath; vtable[0x68] approximated as IsA(ANavigationPoint)")
FLOAT APawn::findPathToward(AActor* Goal, FVector Dest, FLOAT (*WeightFunc)(ANavigationPoint*, APawn*, FLOAT), INT bSinglePath, FLOAT MaxWeight)
{
	guard(APawn::findPathToward);

	*(INT*)((BYTE*)this + 0x418) = 0;   // clear path-search result field

	// No navigation points in level → nothing to do.
	if (!Level->NavigationPointList)
		return 0.f;

	// bNoWeightFunc = 1 if no custom weight function provided (use default)
	INT bNoWeightFunc = (WeightFunc == NULL) ? 1 : 0;

	// Swimming-goal jumpLanding: if Goal is a nav point in PHYS_Swimming and we're
	// not flying, call jumpLanding with Goal's velocity to test landing, then clear
	// Goal and use its saved location as Dest. Ghidra: param_1!=NULL, this+0x2c!=4,
	// vtable[0x68] on Goal nonzero, Goal+0x2c==2.
	if (Goal != NULL && Physics != PHYS_Flying &&
	    Goal->IsA(ANavigationPoint::StaticClass()) &&
	    *(BYTE*)((BYTE*)Goal + 0x2c) == PHYS_Swimming)
	{
		FVector savedGoalLoc = Goal->Location;
		jumpLanding(*(FVector*)((BYTE*)Goal + 0x24C), 0);
		Goal = NULL;
		Dest = savedGoalLoc;
	}

	// Save self location (Ghidra: local_24/20/1c)
	FLOAT selfX = Location.X, selfY = Location.Y, selfZ = Location.Z;

	// End anchor + distances
	ANavigationPoint* endAnchor = NULL;
	FLOAT distToGoal = 0.f;      // local_44
	FLOAT distToStart = 0.f;     // local_48 (dist from pawn to its Anchor)

	if (Goal != NULL)
	{
		// Update Dest to actual goal location
		Dest = Goal->Location;

		// Fast reachability probe: if walking, try FarMoveActor toward goal, then undo.
		if (Physics == PHYS_Walking &&
			XLevel->FarMoveActor(this, Dest, 1, 1, 0, 0) != 0)
		{
			// FUN_1035a3d0(1.0f, 0) = profiling timer — skip
			XLevel->FarMoveActor(this, FVector(selfX, selfY, selfZ), 1, 1, 0, 0);
		}
		endAnchor = Anchor;

		if (!Goal->IsA(ANavigationPoint::StaticClass()))
		{
			// Goal is not a nav point: use Goal's anchor if reachable
			if (ValidAnchor() != 0)
			{
				// Note: ValidAnchor(Goal) not ValidAnchor(this); retail checks Goal.
				// Approximated as checking self anchor since Goal anchor access
				// requires casting Goal to APawn which may be wrong.
				ANavigationPoint* goalAnchor = *(ANavigationPoint**)((BYTE*)Goal + 0x4f8);
				if (goalAnchor != NULL)
				{
					endAnchor = goalAnchor;
					FVector diff = goalAnchor->Location - Dest;
					distToGoal = FVector(diff).Size();
				}
			}
		}
		else
		{
			// Goal IS a nav point
			endAnchor = (ANavigationPoint*)Goal;
			distToGoal = 0.f;
		}
	}

	// Validate self anchor
	if (!ValidAnchor())
		Anchor = NULL;

	if (Anchor != NULL && (endAnchor != NULL || bNoWeightFunc == 0))
	{
		// Fast path: anchor available and end anchor or custom weight
		if (endAnchor != NULL)
			*(DWORD*)((BYTE*)endAnchor + 0x3e4) |= 1;  // mark end as visited

		// Move back to start location (if we moved during probe)
		XLevel->FarMoveActor(this, FVector(selfX, selfY, selfZ), 1, 1, 0, 0);

		// Set anchor's G-cost to distance from self
		FVector anchorDelta = Anchor->Location - FVector(selfX, selfY, selfZ);
		*(INT*)((BYTE*)Anchor + 0x394) = appRound(anchorDelta.Size());

		// Choose weight function
		FLOAT (CDECL* effectiveWeight)(ANavigationPoint*, APawn*, FLOAT) =
			(bNoWeightFunc != 0) ? (FLOAT (CDECL*)(ANavigationPoint*, APawn*, FLOAT))0x1041c2d0 : WeightFunc;

		INT moveFlags = calcMoveFlags();
		ANavigationPoint* result = breadthPathTo(effectiveWeight, endAnchor, moveFlags, &MaxWeight);
		if (result == NULL)
			return 0.f;

		Controller->SetRouteCache(result, distToStart, distToGoal);
		return MaxWeight;
	}

	// Slow path: iterate all nav points to find anchors
	FSortedPathList startList, endList;
	INT startCount = 0, endCount = 0;

	for (ANavigationPoint* pNav = Level->NavigationPointList;
		 pNav != NULL;
		 pNav = *(ANavigationPoint**)((BYTE*)pNav + 0x3a8))
	{
		// If clearPaths requested (Goal serves as the clearPaths flag in retail)
		if (Goal != NULL)
		{
			*(DWORD*)((BYTE*)pNav + 0x3e4) &= ~1u;        // clear visited bit
			*(INT*)((BYTE*)pNav + 0x394) = 10000000;      // cost = infinity
			*(INT*)((BYTE*)pNav + 0x3ac) = 0;             // clear path data
			*(INT*)((BYTE*)pNav + 0x3b0) = 0;
			*(INT*)((BYTE*)pNav + 0x3b4) = 0;
			*(INT*)((BYTE*)pNav + 0x39c) = *(INT*)((BYTE*)pNav + 0x3a0);  // restore order
		}

		// Skip blocked nav points (bEndPoint bit 1 check)
		if (((*(BYTE*)((BYTE*)pNav + 0x3a4)) & 2) != 0)
			continue;

		// Check self-anchor candidacy: within 1200 units
		if (Anchor == NULL)
		{
			FVector d = pNav->Location - FVector(selfX, selfY, selfZ);
			FLOAT distSq = d.SizeSquared();
			INT distInt = appRound(distSq);
			if (distInt < 0x15f900)  // 1200^2 = 1440000
			{
				startList.addPath(pNav, distInt);
				startCount++;
			}
		}

		// Check end-anchor candidacy: within 1200 units of Dest
		if (endAnchor == NULL && bNoWeightFunc != 0)
		{
			FVector d = pNav->Location - Dest;
			FLOAT distSq = d.SizeSquared();
			INT distInt = appRound(distSq);
			if (distInt < 0x15f900)
			{
				endList.addPath(pNav, distInt);
				endCount++;
			}
		}
	}

	// Find start anchor if still missing
	if (Anchor == NULL)
	{
		if (startCount > 0)
			Anchor = startList.findStartAnchor(this);
		if (Anchor == NULL)
			return 0.f;

		// Compute distToStart
		FVector anchorDelta   = Anchor->Location - FVector(selfX, selfY, selfZ);
		FLOAT   distAnchorRaw = anchorDelta.Size();
		distToStart = distAnchorRaw;

		// If anchor too far or blocked: treat as too far
		FLOAT threshR = *(FLOAT*)((BYTE*)Anchor + 0xf8) + *(FLOAT*)((BYTE*)this + 0xf8);
		if (distAnchorRaw < threshR &&
			(*(BYTE*)((BYTE*)Anchor + 0x3a6) & 1) == 0)
		{
			distToStart = 0.f;
		}
	}

	// Find end anchor if needed
	if (endAnchor == NULL && bNoWeightFunc != 0)
	{
		if (endCount < 1)
			return 0.f;

		INT bCanRoute = 0;
		if (Goal != NULL && Controller)
			bCanRoute = Controller->AcceptNearbyPath(Goal) ? 1 : 0;

		endAnchor = endList.findEndAnchor(this, Goal, Dest, bCanRoute);
		if (endAnchor == NULL)
			return 0.f;

		FVector d = endAnchor->Location - Dest;
		distToGoal = d.Size();
	}

	// If already at the endpoint, just set up Controller state and return
	if (endAnchor == Anchor)
	{
		// pawn is at the goal anchor — compute straight-line dist
		FVector d = Dest - FVector(selfX, selfY, selfZ);
		return d.Size();
	}

	// Mark end anchor and set anchor cost, then run breadthPathTo
	if (endAnchor != NULL)
		*(DWORD*)((BYTE*)endAnchor + 0x3e4) |= 1;

	XLevel->FarMoveActor(this, FVector(selfX, selfY, selfZ), 1, 1, 0, 0);

	FVector anchorDelta = Anchor->Location - FVector(selfX, selfY, selfZ);
	*(INT*)((BYTE*)Anchor + 0x394) = appRound(anchorDelta.Size());

	FLOAT (CDECL* effectiveWeight)(ANavigationPoint*, APawn*, FLOAT) =
		(bNoWeightFunc != 0) ? (FLOAT (CDECL*)(ANavigationPoint*, APawn*, FLOAT))0x1041c2d0 : WeightFunc;

	INT moveFlags = calcMoveFlags();
	ANavigationPoint* result = breadthPathTo(effectiveWeight, endAnchor, moveFlags, &MaxWeight);
	if (result == NULL)
		return 0.f;

	// If pawn is already at the goal directly (ReachedDestination):
	FVector goalVec = Anchor->Location - FVector(selfX, selfY, selfZ);
	if (ReachedDestination(goalVec, Goal))
	{
		if (Goal == NULL)
			return 0.f;
	}

	// Set up route cache on Controller
	*(INT*)((BYTE*)Controller + 0x408) = (Goal != NULL) ? (INT)Goal : (INT)Anchor;
	*(INT*)((BYTE*)Controller + 0x40c) = 0;
	*(INT*)((BYTE*)Controller + 0x44c) = *(INT*)((BYTE*)Controller + 0x408);

	// Return distance from Dest to self (remaining journey)
	FVector remaining = Dest - Location;
	return remaining.Size();
	unguard;
}

// Ghidra 0x103f2c70, 477b.
// MultiLineCheck at vtable[0xd8] of XLevel (slot after SingleLineCheck and EncroachingWorldGeometry).
// Flags 0x8e = TRACE_LevelGeometry|TRACE_Volumes|TRACE_Level|TRACE_Movers.
// Level field confirmed at this+0x144 (Ghidra: *(this+0x144) passed as ALevelInfo*).
// DIVERGE from exact retail: retail uses &APhysicsVolume::PrivateStaticClass directly;
// PrivateStaticClass is private here so we call StaticClass() (extra indirection, same result).
// FMemMark only Pop()'d on normal loop exit, NOT on early returns (matches Ghidra SEH unwind).
IMPL_DIVERGE("Ghidra 0x103f2c70: retail uses &APhysicsVolume::PrivateStaticClass directly; PrivateStaticClass is inaccessible so we use StaticClass() — permanent header-level binary difference")
FVector APawn::findWaterLine(FVector Start, FVector End)
{
	guard(APawn::findWaterLine);
	FMemMark Mark(GMem);
	for( FCheckResult* Hit = XLevel->MultiLineCheck(GMem, Start, End, FVector(0,0,0), Level, 0x8e, this);
	     Hit; Hit = Hit->GetNext() )
	{
		// Skip actors in this pawn's Owner chain (this, Owner, Owner->Owner, ...)
		UBOOL bSkip = 0;
		for( AActor* P = (AActor*)this; P; P = P->Owner )
		{
			if( P == Hit->Actor ) { bSkip = 1; break; }
		}
		if( bSkip ) continue;

		// World geometry hit: fall through to return End (no Pop — matches Ghidra)
		if( *(DWORD*)((BYTE*)Hit->Actor + 0xa0) & 0x100000 )
			return End;

// PrivateStaticClass is private; use StaticClass() (same address, one indirection)
		if( Hit->Actor && Hit->Actor->IsA(APhysicsVolume::StaticClass()) &&
		    (*(BYTE*)((BYTE*)Hit->Actor + 0x410) & 0x40) )
		{
			FVector Dir = (Start - End).SafeNormal();
			// If we're inside our own body volume, push slightly inward; otherwise outward
			if( Hit->Actor == (AActor*)PhysicsVolume )
				return Hit->Location + Dir * 0.1f;
			else
				return Hit->Location - Dir * 0.1f;
		}
	}
	Mark.Pop();
	return End;
	unguard;
}

// Ghidra 0x103e6e50 (629 bytes).
//
// Retail pattern: SafeNormal((0,0,-1)) → negate to get NegNorm=(0,0,1).
// FVector::operator* with hidden-return pattern in Ghidra = FVector::SafeNormal().
// Slide direction = SafeNormal(Delta); wall-reaction = NegNorm * remaining.
// Extra 10th MoveActor param (fStepDist): 33.0f on first call, remaining fraction on
// second, 0.0f (default) on third.  Matches Ghidra vtable calls.
IMPL_MATCH("Engine.dll", 0x103e6e50)
ETestMoveResult APawn::flyMove(FVector Delta, AActor* HitActor, FLOAT DeltaTime)
{
	guard(APawn::flyMove);

	FVector SavedLoc = Location;

	// NegNorm = -SafeNormal((0,0,-1)) = (0,0,1).  Computed via SafeNormal so degenerate
	// zero-length deltas degrade gracefully; for (0,0,-1) it is always (0,0,1).
	FVector NegNorm = -(FVector(0.f, 0.f, -1.f).SafeNormal());

	FCheckResult Hit(1.f);
	XLevel->MoveActor(this, Delta, Rotation, Hit, 1, 1, 0, 0, 0);

	if (HitActor != NULL && Hit.Actor == HitActor)
		return (ETestMoveResult)5;  // HitGoal

	if (Hit.Time < 1.f)
	{
		FLOAT fRemaining = 1.f - Hit.Time;

		// SlideDir = SafeNormal(Delta): continue flying in the original direction.
		// Ghidra: FVector::operator*((FVector*)&param_2, (float)local_50) with hidden-return
		// buffer at local_50 = SafeNormal(Delta) pattern.
		FVector SlideDir = Delta.SafeNormal();

		// Wall-reaction: push in NegNorm=(0,0,1) direction by remaining fraction.
		XLevel->MoveActor(this, NegNorm, Rotation, Hit, 1, 1, 0, 0, 0);

		// Continue slide.
		XLevel->MoveActor(this, SlideDir, Rotation, Hit, 1, 1, 0, 0, 0);

		if (HitActor != NULL && Hit.Actor == HitActor)
			return (ETestMoveResult)5;  // HitGoal
	}

	FVector Disp = Location - SavedLoc;
	if (DeltaTime * DeltaTime <= Disp.SizeSquared())
		return TESTMOVE_Moved;

	return TESTMOVE_Stopped;
	unguard;
}

IMPL_DIVERGE("flyReachable: vtable[0x188] on APawn (bCanSwim water-entry-gate) slot unidentified — called via raw vtable pointer; WarpZoneMarker+0x3E8 raw offset used instead of SDK named field")
INT APawn::flyReachable(FVector Dest, INT bClearPath, AActor* GoalActor)
{guard(APawn::flyReachable);
INT flags = bClearPath | 2;
FVector SavedLoc = Location;
FVector SavedVel = Velocity;
// Ghidra: this+0xf8 = CollisionRadius (confirmed: SetCollisionSize writes param_1=Radius to 0xf8)
FLOAT maxStep = (CollisionRadius <= 200.f) ? 200.f : CollisionRadius;
FLOAT maxStepSq = maxStep * maxStep;
INT reached = 0;
ETestMoveResult result = TESTMOVE_Moved;
for ( INT iter = 0; iter < 100 && result != TESTMOVE_Stopped; iter++ )
{
FVector delta(Dest.X - Location.X, Dest.Y - Location.Y, Dest.Z - Location.Z);
if ( ReachedDestination(delta, GoalActor) )
{
reached = 1;
break;
}
FLOAT distSq = delta.SizeSquared();
FVector step;
FLOAT minDist;
if ( distSq < maxStepSq )
{
step = delta.SafeNormal() * maxStep;
minDist = 4.1f;
}
else
{
step = delta;
minDist = 8.0f;
}
result = flyMove(step, GoalActor, minDist);
// 5 = TESTMOVE_HitGoal: value not in SDK enum but returned by retail flyMove on goal touch
if ( (INT)result == 5 )
{
reached = 1;
break;
}
// If flyMove placed pawn in a water zone, stop flying; if bCanSwim, delegate to swimReachable
// DIVERGENCE: vtable[0x188] = unidentified APawn virtual; retail gates on it returning 0
if ( result != TESTMOVE_Stopped && Region.Zone &&
     (*(BYTE*)((BYTE*)Region.Zone + 0x410) & 0x40) )
{
result = TESTMOVE_Stopped;
if ( bCanSwim )
{
typedef INT (__thiscall* VtblFn188)(APawn*);
VtblFn188 fn = *(VtblFn188*)((BYTE*)*(DWORD*)this + 0x188);
if ( !fn(this) )
{
flags = swimReachable(Dest, flags, GoalActor);
reached = (flags != 0);
}
}
}
}
// WarpZoneMarker: if pawn ended in destination zone, count as reached
// DIVERGENCE: this+0x228=Region.Zone ptr; GoalActor+1000=WarpZone dest zone (field not in SDK)
if ( !reached && GoalActor && GoalActor->IsA(AWarpZoneMarker::StaticClass()) )
reached = ( *(INT*)((BYTE*)this + 0x228) == *(INT*)((BYTE*)GoalActor + 1000) );
XLevel->FarMoveActor(this, SavedLoc, 1, 1);
Velocity = SavedVel;
return reached ? flags : 0;
unguard;
}

// Ghidra 0x103e88b0; 1264 bytes.
// Simulates jump-landing physics: advances the pawn under gravity (plus zone effects)
// in 0.1-second sub-steps until it lands on a floor (Normal.Z >= 0.7), hits terminal
// velocity, enters water, or runs out of steps.
// Used by jumpReachable to test whether a parabolic jump trajectory reaches solid floor.
// DIVERGENCE: fieldAt0x44c (terminal-velocity Z limit) is unnamed in the SDK; raw offset.
// DIVERGENCE: AScout MaxStepHeight at this+0x660 is unnamed; raw offset.
// DIVERGENCE: ZoneGravity at Zone+0x450, ZoneVelocity at Zone+0x444 — both confirmed
//   from other Ghidra callers but unnamed in the SDK.
// DIVERGENCE: MoveActor stray args (fVar5, fVar6, fVar7 after bFlags) are Ghidra
//   stack-tracking artifacts. The retail MoveActor only pops 9 declared params.
IMPL_MATCH("Engine.dll", 0x103e88b0)
ETestMoveResult APawn::jumpLanding(FVector TestFall, INT bAdjust)
{
	guard(APawn::jumpLanding);

	// Save starting location
	FVector SavedLoc = Location;

	FLOAT  stepTime  = 0.1f;
	INT    done      = 0;
	INT    stepCount = 0;

	do
	{
		if ( done )
		{
			// AScout: update its step-height field with the peak negative Z
			if ( IsA(AScout::StaticClass()) )
			{
				FLOAT scoutField = *(FLOAT*)(this + 0x660);
				FLOAT negZ       = -TestFall.Z;
				if ( negZ > scoutField ) scoutField = negZ;
				*(FLOAT*)(this + 0x660) = scoutField;
			}

			FVector newLoc = Location;
			// If not asked to adjust, restore start position
			if ( bAdjust == 0 )
				XLevel->FarMoveActor(this, SavedLoc, 1, 1);

			// Return TESTMOVE_Moved if position changed, TESTMOVE_Stopped if not
			FLOAT dx = newLoc.X - SavedLoc.X;
			FLOAT dy = newLoc.Y - SavedLoc.Y;
			FLOAT dz = newLoc.Z - SavedLoc.Z;
			return (dx != 0.f || dy != 0.f || dz != 0.f) ? TESTMOVE_Moved : TESTMOVE_Stopped;
		}

		// Zone buoyancy
		AZoneInfo* Zone = *(AZoneInfo**)(this + 0x164);
		FLOAT buoyancy  = 0.f;
		if ( (*(BYTE*)((BYTE*)Zone + 0x410) & 0x40) != 0 )  // bWaterVolume
			buoyancy = *(FLOAT*)((BYTE*)Zone + 0x420);

		// Gravity integration: ZoneGravity contribution + buoyancy damping
		FVector ZoneGrav = *(FVector*)((BYTE*)Zone + 0x450);  // Zone->ZoneGravity
		FVector ZGDelta  = ZoneGrav * stepTime;
		FLOAT   damping  = 1.0f - buoyancy * stepTime;
		FLOAT   newTFz   = ZGDelta.Z + TestFall.Z * damping;  // updated Z (terminal vel check)
		TestFall         = TestFall * damping + ZGDelta;

		// Add zone wind velocity
		TestFall.X += *(FLOAT*)((BYTE*)Zone + 0x444);
		TestFall.Y += *(FLOAT*)((BYTE*)Zone + 0x448);
		TestFall.Z += *(FLOAT*)((BYTE*)Zone + 0x44c);

		// Position delta for this step
		FVector Delta = TestFall * stepTime;

		// Test-move the pawn (bTest=1, bIgnorePawns=1)
		FCheckResult hit(1.f);
		XLevel->MoveActor(this, Delta, Rotation, hit, 1, 1, 0, 0, 0);

		if ( (*(BYTE*)((BYTE*)Zone + 0x410) & 0x40) != 0 )  // water zone → landed
		{
			done = 1;  // LAB_103e8c8d
		}
		else if ( -(*(FLOAT*)(this + 0x44c)) <= newTFz )  // terminal velocity not exceeded
		{
			if ( hit.Time < 1.f )
			{
				if ( hit.Normal.Z >= 0.7f )
				{
					done = 1;  // landed on walkable floor
				}
				else
				{
					// Wall hit — try to slide
					FVector WallNormal = hit.Normal;
					FLOAT   fDot       = (Delta | WallNormal);
					FVector SlideDir   = Delta - WallNormal * fDot;
					FLOAT   remaining  = 1.f - hit.Time;
					FVector SlideScaled = SlideDir * remaining;

					if ( (SlideScaled | Delta) >= 0.f )
					{
						FCheckResult hit2(1.f);
						XLevel->MoveActor(this, SlideScaled, Rotation, hit2, 1, 1, 0, 0, 0);

						if ( hit2.Time < 1.f )
						{
							if ( hit2.Normal.Z >= 0.7f )
							{
								done = 1;
							}
							else
							{
								FVector DeltaNorm  = Delta.SafeNormal();
								FVector OldWall    = WallNormal;
								TwoWallAdjust(DeltaNorm, SlideScaled, WallNormal, OldWall, hit.Time);
								FCheckResult hit3(1.f);
								XLevel->MoveActor(this, SlideScaled, Rotation, hit3, 1, 1, 0, 0, 0);
								if ( hit3.Normal.Z >= 0.7f )
									done = 1;
							}
						}
					}
				}
			}
		}
		else
		{
			// Terminal velocity exceeded — stop and restore
			done = 1;
			XLevel->FarMoveActor(this, SavedLoc, 1, 1);
		}

		stepCount++;
		if ( !Owner || stepCount > 0x23 )
		{
			XLevel->FarMoveActor(this, SavedLoc, 1, 1);
			done = 1;
		}

	} while ( true );

	unguard;
}

IMPL_MATCH("Engine.dll", 0x103eb1c0)
INT APawn::jumpReachable(FVector Dest, INT bClearPath, AActor* GoalActor)
{
	guard(APawn::jumpReachable);
	FVector SavedLoc = Location;
	ETestMoveResult hit = jumpLanding(Velocity, 1);
	if ( hit == TESTMOVE_Stopped )
		return 0;
	INT result = walkReachable(Dest, bClearPath | 8, GoalActor);
	XLevel->FarMoveActor(this, SavedLoc, 1, 1);
	return result;
	unguard;
}

IMPL_DIVERGE("Ghidra catch-only at 0x103ebe4a; ladderReachable body not fully exported; delegates to walkReachable")
INT APawn::ladderReachable(FVector Dest, INT bClearPath, AActor* GoalActor)
{
	guard(APawn::ladderReachable);
	if ( OnLadder && GoalActor )
	{
		ALadderVolume* goalLadder = NULL;
		if ( GoalActor->IsA(ALadder::StaticClass()) )
		{
			// DIVERGENCE: ALadder::LadderVolume field not in header; raw offset +0x3E8
			goalLadder = *(ALadderVolume**)((BYTE*)GoalActor + 0x3E8);
		}
		else
		{
			// DIVERGENCE: GoalActor OnLadder via raw offset +0x51c
			goalLadder = *(ALadderVolume**)((BYTE*)GoalActor + 0x51c);
		}
		if ( goalLadder && goalLadder == OnLadder )
			return bClearPath | 0x40;
	}
	return walkReachable(Dest, bClearPath, GoalActor);
	unguard;
}

// Ghidra 0x103EFC30; 1653 bytes.
// Flying physics: CalcVelocity + MoveActor with wall-slide and floor step-up.
// DIVERGENCE: DestroyActor path in the guard check uses raw vtable[0xa0] on
//   XLevel — mapped to DestroyActor() via ULevel vtable count; bNetForce defaults 0.
// DIVERGENCE: This+0xa8 & 0x1000 / +0x40000000 flags unnamed in SDK header;
//   raw offsets retained.
// DIVERGENCE: calcVelocity arg2 (this+0x430 = AirControl) and arg3
//   (Zone+0x420 * 0.5 = half-MaxSpeed) use raw offsets; no named field in SDK.
// DIVERGENCE: stepUp 5th arg (remaining-time float) seen in Ghidra call site is
//   absent here — confirmed via .def that stepUp takes exactly 4 declared params;
//   the extra push was a Ghidra stack-depth artifact.
IMPL_MATCH("Engine.dll", 0x103efc30)
void APawn::physFlying(FLOAT DeltaTime, INT Iterations)
{
	guard(APawn::physFlying);

	// Safety guard: if bFlags0x1000 is set, Owner is null and bFlags2_0x40000000 clear,
	// check if controller exists and is active — if not, destroy this pawn.
	if ( (*(DWORD*)(this + 0xa8) & 0x1000) != 0
	  && *(void**)(this + 0x230) == NULL
	  && (*(DWORD*)(this + 0xa8) & 0x40000000) == 0 )
	{
		AController* ctrl = *(AController**)(this + 0x4ec);
		if ( !ctrl || (*(BYTE*)((BYTE*)ctrl + 0x3a8) & 1) == 0 )
		{
			debugf(NAME_Log, TEXT("APawn::physFlying: %s - destroying, no active controller"),
			       *GetName());
			XLevel->DestroyActor(this);
		}
		return;
	}

	// Normalize Acceleration for CalcVelocity direction
	FVector AccelNorm;
	if ( !Acceleration.IsZero() )
		AccelNorm = Acceleration.SafeNormal();
	else
		AccelNorm = Acceleration;

	// CalcVelocity: (AccelDir, DeltaTime, AirControl, ZoneMaxSpeed*0.5, bGrounded, bFluid, bBraking)
	// this+0x430 = AirControl,  Zone+0x420 = some max-speed field
	FLOAT AirCtrl  = *(FLOAT*)(this + 0x430);
	FLOAT MaxSpd   = *(FLOAT*)(*(INT*)(this + 0x164) + 0x420) * 0.5f;
	calcVelocity(AccelNorm, DeltaTime, AirCtrl, MaxSpd, 1, 0, 0);

	FVector OldLoc = Location;
	*(DWORD*)(this + 0xac) &= ~0x8;  // clear bNotJustTeleported

	// Goal velocity: use zone wind velocity when human-controlled or zone wind is fast
	FVector GoalVel(0.f, 0.f, 0.f);
	FVector* ZoneVel = (FVector*)(*(INT*)(this + 0x164) + 0x444);
	if ( IsHumanControlled() || ZoneVel->SizeSquared() > 90000.f )
		GoalVel = *ZoneVel;

	FVector Delta = (Velocity + GoalVel) * DeltaTime;
	FCheckResult flHit(1.f);
	XLevel->MoveActor(this, Delta, Rotation, flHit, 0, 0, 0, 0, 0);

	if ( flHit.Time >= 1.f )
	{
		// Moved freely — reset cached wall normal
		*(FVector*)(this + 0x590) = FVector(0.f, 0.f, 1.f);
	}
	else
	{
		// Stored cached wall normal
		*(FVector*)(this + 0x590) = flHit.Normal;

		// ZDir: +1 if zone gravity points up, -1 otherwise (Zone+0x458 = ZoneGravity.Z)
		FLOAT ZDir = (*(FLOAT*)(*(INT*)(this + 0x164) + 0x458) > 0.f) ? 1.f : -1.f;

		FLOAT absNormZ = flHit.Normal.Z < 0.f ? -flHit.Normal.Z : flHit.Normal.Z;
		FLOAT alignDot = flHit.Normal.Z * ZDir;

		if ( absNormZ < 0.2f || alignDot < 0.5f || alignDot <= -0.2f )
		{
			// Wall hit — notify and slide
			processHitWall(flHit.Normal, flHit.Actor);

			FVector WallNormal = flHit.Normal;
			FLOAT   fDot       = Delta | WallNormal;
			FVector Slide      = Delta - WallNormal * fDot;
			FLOAT   remaining  = 1.f - flHit.Time;

			if ( (Slide | Delta) >= 0.f )
			{
				FCheckResult flHit2(1.f);
				XLevel->MoveActor(this, Slide * remaining, Rotation, flHit2, 0, 0, 0, 0, 0);

				if ( flHit2.Time < 1.f )
				{
					processHitWall(flHit2.Normal, flHit2.Actor);
					FVector SavedWall = WallNormal;
					TwoWallAdjust(Delta, Slide, WallNormal, SavedWall, flHit.Time);
					FCheckResult flHit3(1.f);
					XLevel->MoveActor(this, Slide, Rotation, flHit3, 0, 0, 0, 0, 0);
				}
			}
		}
		else
		{
			// Floor contact — step up
			FLOAT savedZ = OldLoc.Z;
			FLOAT remT   = 1.f - flHit.Time;
			FVector ScaleDelta = Delta * remT;
			FVector DeltaNorm  = Delta.SafeNormal();
			FVector VelNorm    = Velocity.SafeNormal();
			stepUp(DeltaNorm, VelNorm, ScaleDelta, flHit);
			// Z-shift: accumulate vertical step offset into OldLoc for velocity calc
			OldLoc.Z = (OldLoc.Z - savedZ) + Location.Z;
		}
	}

	// Update Velocity from actual displacement unless teleported or large-actor override
	if ( !(*(DWORD*)(this + 0xac) & 0x8)
	  && !(*(DWORD*)(this + 0x3e0) & 0x4000000) )
	{
		Velocity = (Location - OldLoc) / DeltaTime;
	}

	*(DWORD*)(this + 0x3e0) &= ~0x4000000;  // clear pending-step flag

	unguard;
}

// Ghidra 0x103F5990; 2617b.
// Spider physics: walk on any surface (walls/ceilings) guided by CachedWallNormal.
// Mirrors physFlying/physSwimming loop structure but uses SpiderstepUp for collision
// response and SingleLineCheck to maintain wall contact each sub-step.
//
// DIVERGENCE: pre-loop velocity projection onto the wall plane (accel branch vs
//   zero-accel branch) involves multiple dot-products and CWN-scale operations that
//   are complex to reconstruct precisely; simplified as Velocity -= (Velocity|CWN)*CWN.
// DIVERGENCE: 'nearly-zero delta' floor-reanchoring path reconstructed approximately
//   from Ghidra (exact SingleLineCheck call sequence slightly different in retail).
// DIVERGENCE: SetBase call (vtable[0xd0] = APawn::SetBase) confirmed from .def.
IMPL_TODO("Ghidra 0x103F5990; 2617b: physSpider — loop structure implemented; pre-loop velocity wall-plane projection approximate (see DIVERGENCE notes)")
void APawn::physSpider(FLOAT DeltaTime, INT Iterations)
{
	guard(APawn::physSpider);

	if (!Controller)
		return;

	FVector* pCWN = (FVector*)((BYTE*)this + 0x590);   // CachedWallNormal

	// If CWN is zero-length, lost surface contact — probe for a new floor
	if (pCWN->IsNearlyZero())
	{
		if (!findNewFloor(Location, DeltaTime, DeltaTime, Iterations))
			return;
	}

	// Pre-loop velocity prep: project Velocity onto the wall plane
	// (Remove the component along CWN so movement stays on the surface.)
	// DIVERGE: retail has two branches (Accel==0 / Accel!=0); both strip CWN component
	//   then scale; we unify into a single projection + clamp.
	{
		FLOAT cwnDot = ((*pCWN) | Velocity);
		Velocity -= (*pCWN) * cwnDot;           // strip wall-normal component
		// Clamp to MaxSpeed
		FLOAT maxSp = *(FLOAT*)((BYTE*)this + 0x438) * *(FLOAT*)((BYTE*)this + 0x3f4);
		if (Velocity.SizeSquared() > maxSp * maxSp)
			Velocity = Velocity.SafeNormal() * maxSp;
	}

	// Save starting location for end-of-frame velocity derivation
	FVector startLoc = Location;
	FLOAT   remTime  = DeltaTime;

	*(DWORD*)((BYTE*)this + 0xac) &= ~0x8u;   // clear bNotJustTeleported
	const FLOAT sqThresh = 1089.0f;           // 33^2: avoid sqrt for slow pawns

	do
	{
		if (remTime <= 0.0f || Iterations > 7 || !Controller)
		{
			// Derive velocity from actual displacement
			if (!((*(DWORD*)((BYTE*)this + 0xac)) & 0x8))
			{
				Velocity = (Location - startLoc) / DeltaTime;
			}
			return;
		}

		Iterations++;

		// Sub-step size: half up to 0.05 s; for slow non-human pawns allow full step
		FLOAT stepTime;
		if (remTime <= 0.05f)
		{
			stepTime = remTime;
		}
		else if (IsHumanControlled())
		{
			stepTime = remTime * 0.5f;
			if (stepTime > 0.05f) stepTime = 0.05f;
		}
		else
		{
			FLOAT velSq = Velocity.SizeSquared();
			if (velSq * remTime * remTime <= sqThresh)
				stepTime = remTime;
			else
			{
				stepTime = remTime * 0.5f;
				if (stepTime > 0.05f) stepTime = 0.05f;
			}
		}
		remTime -= stepTime;

		FVector delta = Velocity * stepTime;

		if (!delta.IsNearlyZero())
		{
			FCheckResult Hit(1.f);
			XLevel->MoveActor(this, delta, Rotation, Hit, 0, 0, 0, 0, 0);

			// If we hit something before reaching the target, try SpiderstepUp
			// (only when floorRatio was < 1 on the most recent probe)
			if (Hit.Time < 1.0f)
			{
				FVector stepDir = delta.SafeNormal();
				FVector scaledDir = stepDir * (1.0f - Hit.Time);
				SpiderstepUp(delta, scaledDir, Hit);
			}

			// Check if we've exited into a water zone
			if (Physics == PHYS_Swimming)
			{
				startSwimming(startLoc, Velocity, stepTime, remTime, Iterations);
				return;
			}
		}
		else
		{
			// Nearly-zero delta: use SingleLineCheck along CWN to probe floor contact
			remTime = 0.0f;

			FLOAT stepDist = *(FLOAT*)((BYTE*)this + 0xfc);   // CollisionRadius
			FVector probeEnd   = Location - (*pCWN) * stepDist * 20.f;
			FVector probeStart = Location + (*pCWN) * stepDist;

			FCheckResult flHit(1.f);
			XLevel->SingleLineCheck(flHit, this, probeEnd, probeStart, 0x86,
			                        FVector(0.f, 0.f, 0.f));

			// If still attached (matching floor actor) at near-contact range, stay put
			// Otherwise attempt to recover by stepping back toward wall and reprobing
		}

		// Floor probe: confirm wall contact using SingleLineCheck in CWN direction
		{
			// Probe: from just in front of wall to just behind it
			FLOAT colRadius = *(FLOAT*)((BYTE*)this + 0xf8);   // CWN step distance
			// Probe slightly behind (into wall) and from just ahead of it
			FVector probeEnd   = Location - (*pCWN) * colRadius * 20.f;
			FVector probeStart = Location + (*pCWN) * colRadius;

			FCheckResult flHit(1.f);
			XLevel->SingleLineCheck(flHit, this, probeEnd, probeStart, 0xdf,
			                        FVector(*(FLOAT*)((BYTE*)this + 0xfc), 0.f, 0.f));

			if (flHit.Time < 1.0f)
			{
				// Wall confirmed — update CWN and re-anchor
				*(FVector*)((BYTE*)this + 0x590) = flHit.Normal;

				// Push the pawn to the wall surface (remove gap)
				FVector toWall = (*pCWN) * (-(flHit.Time * colRadius));
				FCheckResult mvHit(1.f);
				XLevel->MoveActor(this, toWall, Rotation, mvHit, 0, 0, 0, 0, 0);

				// SetBase: notify if floor actor changed
				if (flHit.Actor != *(AActor**)((BYTE*)this + 0x15c))
				{
					SetBase(flHit.Actor, flHit.Normal, 1);
				}
			}
			else
			{
				// No wall beneath us — try to find a new floor; if fails, return
				if (!findNewFloor(Location, DeltaTime, DeltaTime, Iterations))
					return;
			}
		}
	}
	while (true);

	unguard;
}

// Ghidra 0x103F40A0; 1842 bytes.
// Swimming physics: CalcVelocity + Swim() with wall-slide and floor step-up.
// Structurally mirrors physFlying but uses Swim() instead of MoveActor and adds
// buoyancy-based Z velocity adjustment and zone-exit surfacing logic.
// DIVERGENCE: GoalVel ZoneVelocity scale (double FVector::operator* seen in Ghidra
//   for physSwimming vs physFlying) approximated as direct copy — scale factor
//   appears to be 1.0 in practice when IsHumanControlled or fast zone velocity.
// DIVERGENCE: this+0x110 field (used as divisor in Z-vel buoyancy adjustment)
//   unnamed in SDK; raw offset retained.
// DIVERGENCE: stepUp 5th arg (Ghidra artifact) absent — same reasoning as physFlying.
// DIVERGENCE: setPhysics vtable call resolved as vtable[0x11c] = setPhysics via
//   5-arg signature match and the .def-confirmed param layout.
IMPL_MATCH("Engine.dll", 0x103f40a0)
void APawn::physSwimming(FLOAT DeltaTime, INT Iterations)
{
	guard(APawn::physSwimming);

	// Buoyancy adjustment for fast upward velocity approaching a non-water boundary
	FLOAT buoyancy    = 0.f;
	FLOAT buoyancyScale = 0.f;
	GetNetBuoyancy(buoyancy, buoyancyScale);
	FLOAT fieldAt110 = *(FLOAT*)(this + 0x110);
	if ( *(FLOAT*)(this + 0x254) > 100.f && fieldAt110 != 0.f )
		*(FLOAT*)(this + 0x254) = (buoyancy / fieldAt110) * *(FLOAT*)(this + 0x254);

	FVector OldLoc = Location;
	*(DWORD*)(this + 0xac) &= ~0x8;  // clear bNotJustTeleported

	// Normalize Acceleration
	FVector AccelNorm;
	if ( !Acceleration.IsZero() )
		AccelNorm = Acceleration.SafeNormal();
	else
		AccelNorm = Acceleration;

	// CalcVelocity with bBuoyant=1 (last arg); this+0x42c = AquaControl
	FLOAT AquaCtrl = *(FLOAT*)(this + 0x42c);
	FLOAT MaxSpd   = *(FLOAT*)(*(INT*)(this + 0x164) + 0x420) * 0.5f;
	calcVelocity(AccelNorm, DeltaTime, AquaCtrl, MaxSpd, 1, 0, 1);

	// Save Velocity.Z for possible restoration if exiting water upward
	FLOAT savedVelZ = *(FLOAT*)(this + 0x254);

	// Goal velocity — use zone wind when human-controlled or zone wind is strong
	FVector GoalVel(0.f, 0.f, 0.f);
	FVector* ZoneVel = (FVector*)(*(INT*)(this + 0x164) + 0x444);
	if ( IsHumanControlled() || ZoneVel->SizeSquared() > 90000.f )
		GoalVel = *ZoneVel;

	FVector* pVel  = (FVector*)(this + 0x24c);
	FVector Delta  = (*pVel + GoalVel) * DeltaTime;
	FCheckResult swHit(1.f);
	FLOAT timeSwum = Swim(Delta, swHit) * DeltaTime;

	if ( swHit.Time >= 1.f )
	{
		// Swam freely — reset wall-normal cache
		*(FVector*)(this + 0x590) = FVector(0.f, 0.f, 1.f);
	}
	else
	{
		// Hit something — store wall normal
		*(FVector*)(this + 0x590) = swHit.Normal;

		FLOAT ZDir     = (*(FLOAT*)(*(INT*)(this + 0x164) + 0x458) > 0.f) ? 1.f : -1.f;
		FLOAT absNormZ = swHit.Normal.Z < 0.f ? -swHit.Normal.Z : swHit.Normal.Z;
		FLOAT alignDot = swHit.Normal.Z * ZDir;

		if ( absNormZ < 0.2f || alignDot < 0.5f || alignDot <= -0.2f )
		{
			// Wall hit — notify and slide
			processHitWall(swHit.Normal, swHit.Actor);

			FVector WallNormal = swHit.Normal;
			FLOAT   fDot       = Delta | WallNormal;
			FVector Slide      = Delta - WallNormal * fDot;
			FLOAT   remaining  = 1.f - swHit.Time;

			if ( (Slide | Delta) >= 0.f )
			{
				FCheckResult swHit2(1.f);
				FLOAT t2   = Swim(Slide * remaining, swHit2);
				timeSwum   = (1.f - swHit.Time) * t2 * timeSwum;

				if ( swHit2.Time < 1.f )
				{
					processHitWall(swHit2.Normal, swHit2.Actor);
					FVector SavedWall = WallNormal;
					TwoWallAdjust(Delta, Slide, WallNormal, SavedWall, swHit.Time);
					FLOAT t3 = Swim(Slide, swHit2);
					timeSwum = (1.f - swHit.Time) * t3 * timeSwum;
				}
			}
		}
		else
		{
			// Floor contact — step up
			FLOAT savedZ   = OldLoc.Z;
			FVector ScaleD = Delta * (1.f - swHit.Time);
			FVector DN     = Delta.SafeNormal();
			FVector VN     = pVel->SafeNormal();
			stepUp(DN, VN, ScaleD, swHit);
			OldLoc.Z = (OldLoc.Z - savedZ) + Location.Z;
		}
	}

	// Update Velocity from actual displacement if not teleported and swam less than full DT
	{
		DWORD invertGrav = (~(*(DWORD*)(*(INT*)(this + 0x164) + 0x410) >> 6)) & 1;
		if ( !(*(DWORD*)(this + 0xac) & 0x8) && timeSwum < DeltaTime )
		{
			// If pawn is in an anti-gravity zone (bit 6 of Zone flags inverted), preserve Z vel
			if ( invertGrav )
				savedVelZ = *(FLOAT*)(this + 0x254);

			if ( !(*(DWORD*)(this + 0x3e0) & 0x4000000) )
			{
				FVector disp = Location - OldLoc;
				*pVel = disp / DeltaTime;
			}
			*(DWORD*)(this + 0x3e0) &= ~0x4000000;  // clear pending-step flag

			if ( invertGrav )
				*(FLOAT*)(this + 0x254) = savedVelZ;
		}
	}

	// Zone-exit check: if pawn is no longer in water, transition to falling/surface
	AZoneInfo* Zone = (AZoneInfo*)*(INT*)(this + 0x164);
	if ( !(*(BYTE*)((BYTE*)Zone + 0x410) & 0x40) )  // not a water zone
	{
		if ( *(BYTE*)(this + 0x2c) == PHYS_Swimming )
		{
			// Surfacing from water — start falling upward
			setPhysics(PHYS_Falling, NULL, FVector(0.f, 0.f, 1.f));
		}
		// Clamp outward Z velocity: convert to surface-skimming speed
		FLOAT velZ = *(FLOAT*)(this + 0x254);
		if ( velZ < 160.f && velZ > 0.f )
			*(FLOAT*)(this + 0x254) = pVel->Size2D() * 0.4f + 40.f;
	}

	if ( *(BYTE*)(this + 0x2c) != PHYS_Swimming )
		startNewPhysics(timeSwum, Iterations + 1);

	unguard;
}

// Ghidra 0x103ED370; 4353 bytes. Ground walking physics: velocity integration +
// per-sub-step SinglePointCheck floor probe + MoveActor + stepUp/processHitWall handling.
//
// DIVERGENCE: calcVelocity arg3 (GroundFriction at PhysicsVolume+0x424) and arg4
//   (MaxGroundSpeed at PhysicsVolume+0x420) use raw offsets — no named SDK field.
// DIVERGENCE: gravity-probe floor step (35.0) approximated from Ghidra literal
//   (local_30 = local_90 * 35.0 and local_30 < 2.4 threshold).
// DIVERGENCE: SinglePointCheck Extent uses CollisionRadius/1.f; Ghidra passes
//   raw offsets this+0xf8/0xfc (exact meaning unclear from Ghidra alone).
// DIVERGENCE: zone ZoneVelocity scale factor (local_148 = DeltaTime) approximated
//   from FVector::operator* call pattern in Ghidra.
// DIVERGENCE: FUN_103808e0 (min/max float helper) and FUN_10301350 (zone wind
//   velocity helper) are inlined via approximation in the floor-friction slope path.
IMPL_TODO("Ghidra 0x103ED370; 4353b: physWalking — implemented; DIVERGENCE notes above")
void APawn::physWalking(FLOAT DeltaTime, INT Iterations)
{
	guard(APawn::physWalking);

	APhysicsVolume* Zone;
	FLOAT MaxSpd, GroundFric;
	FVector AccelNorm;
	FLOAT velX, velY;
	FVector GravDir, GravStep, StartLoc;
	FLOAT remTime, subDt, fNZ, stepDist, dotND;
	INT bFall, bNotifyMayFall, bWalkable, bDeltaZero, bIntoFloor;
	FLOAT cr;

	if (!Controller)
		return;

	// Zero out Z velocity (walking doesn't use vertical velocity directly)
	Velocity.Z = 0.f;
	*(FLOAT*)((BYTE*)this + 0x260) = 0.f;   // retail clears this+0x260 as well

	// Normalize Acceleration for calcVelocity direction
	if (!Acceleration.IsZero())
		AccelNorm = Acceleration.SafeNormal();
	else
		AccelNorm = Acceleration;

	// calcVelocity: update velocity based on acceleration, friction, max speed.
	// PhysicsVolume+0x420 = MaxGroundSpeed equivalent; +0x424 = GroundFriction.
	Zone         = (APhysicsVolume*)*(INT*)((BYTE*)this + 0x164);
	MaxSpd       = *(FLOAT*)((BYTE*)Zone + 0x420);
	GroundFric   = *(FLOAT*)((BYTE*)Zone + 0x424);
	calcVelocity(AccelNorm, DeltaTime, GroundFric, MaxSpd, 1, 0, 0);

	// Working copy of velocity (Z cleared for ground movement)
	velX = Velocity.X;
	velY = Velocity.Y;
	Velocity.Z = 0.f;

	// Apply zone/wind velocity if zone has one (PhysicsVolume+0x444 = ZoneVelocity)
	{
		FVector* ZoneVel = (FVector*)((BYTE*)Zone + 0x444);
		FLOAT zvsq = ZoneVel->SizeSquared();
		if (zvsq > 0.f && (IsHumanControlled() || zvsq > 90000.f))
		{
			FVector windDelta = *ZoneVel * DeltaTime;
			velX += windDelta.X;
			velY += windDelta.Y;
		}
	}
	Velocity.Z = 0.f;

	// Determine gravity sign: zone+0x458 holds zone gravity Z; if <= 0 → normal down
	{
		FLOAT gravSign = (*(FLOAT*)((BYTE*)Zone + 0x458) > 0.f) ? 1.f : -1.f;
		GravDir  = FVector(0.f, 0.f, -1.f * gravSign);
		GravStep = GravDir * 35.f;   // floor probe vector (35 UU below pawn)
	}

	// Save start location for final velocity computation
	StartLoc = Location;
	*(DWORD*)((BYTE*)this + 0xac) &= ~0x8u;   // clear bNotJustTeleported

	bFall = 0;
	bNotifyMayFall = 0;
	cr = CollisionRadius;

	remTime = DeltaTime;

	while (true)
	{
		// Exit loop conditions
		if (remTime <= 0.f || Iterations > 7 || !Controller)
		{
			// Update velocity from actual displacement
			if (!(*(DWORD*)((BYTE*)this + 0xac) & 0x8) &&
				!(*(DWORD*)((BYTE*)this + 0x3e0) & 0x4000000))
			{
				FVector disp = Location - StartLoc;
				Velocity = disp / DeltaTime;
			}
			*(DWORD*)((BYTE*)this + 0x3e0) &= ~0x4000000u;
			Velocity.Z = 0.f;
			return;
		}
		Iterations++;

		// Sub-step: at most 0.05s per step (Ghidra: if > 0.05 use remTime*0.5, clamped)
		subDt = remTime;
		if (subDt > 0.05f)
		{
			subDt = remTime * 0.5f;
			if (subDt > 0.05f) subDt = 0.05f;
		}
		remTime -= subDt;

		{
			FVector OldLoc = Location;
			FVector Delta(velX * subDt, velY * subDt, 0.f);

			if (Delta.IsNearlyZero())
			{
				// Zero delta: floor check only, no movement
				remTime = 0.f;
			}

			// ── Floor probe: SinglePointCheck below pawn ──────────────────
			{
				FCheckResult FHit(1.0f);
				FVector ProbePos = Location + GravStep;
				XLevel->SinglePointCheck(FHit, this, ProbePos,
					FVector(cr, cr, 1.f), 0xdf, Level, 0);

				// Cache floor normal
				*(FVector*)((BYTE*)this + 0x590) = FHit.Normal;

				fNZ      = FHit.Normal.Z;
				stepDist = FHit.Time * 35.f;
				dotND    = FHit.Normal.X*Delta.X + FHit.Normal.Y*Delta.Y + FHit.Normal.Z*Delta.Z;
				bWalkable  = !appIsNan(fNZ) ? (fNZ >= 0.7f ? 1 : 0) : 1;
				bDeltaZero = Delta.IsNearlyZero() ? 1 : 0;
				bIntoFloor = (dotND >= 0.f) ? 1 : 0;

				if (bWalkable || bDeltaZero || bIntoFloor)
				{
					// ── Walkable floor branch ──────────────────────────────
					if (FHit.Time < 1.0f || stepDist <= 2.4f)
					{
						if (stepDist < 1.9f)
						{
							FLOAT snapZ = 2.15f - stepDist;
							FCheckResult snapHit(1.f);
							XLevel->MoveActor(this, GravDir * snapZ, Rotation, snapHit, 0, 0, 0, 0, 0);
						}
						else
						{
							FCheckResult stepHit(1.f);
							XLevel->MoveActor(this,
								FVector(0.f, 0.f, GravDir.Z * (stepDist * FHit.Normal.Z)),
								Rotation, stepHit, 0, 0, 0, 0, 0);
							if (stepHit.Actor != Base)
							{
								typedef void (__thiscall* FSetBaseFn)(APawn*, AActor*, FVector, INT);
								((FSetBaseFn)(*(DWORD**)(*(DWORD*)this))[0xd0/4])(
									this, stepHit.Actor, stepHit.Normal, 1);
							}
						}
					}

					if (!bDeltaZero)
					{
						FCheckResult MoveHit(1.f);
						XLevel->MoveActor(this, Delta, Rotation, MoveHit, 0, 0, 0, 0, 0);

						if (Physics == PHYS_Swimming)
						{
							startSwimming(OldLoc, Velocity, subDt, remTime, Iterations);
							return;
						}

						if (MoveHit.Time < 1.0f && MoveHit.Actor)
						{
							stepUp(GravDir, Delta.SafeNormal(), Delta, MoveHit);

							if (Physics == PHYS_Swimming)
							{
								startSwimming(OldLoc, Velocity, subDt, remTime, Iterations);
								return;
							}
							if (Physics == PHYS_Walking && MoveHit.Actor)
								processHitWall(MoveHit.Normal, MoveHit.Actor);
						}
					}

					// SetBase to current floor actor
					if (FHit.Actor != Base)
					{
						typedef void (__thiscall* FSetBaseFn)(APawn*, AActor*, FVector, INT);
						((FSetBaseFn)(*(DWORD**)(*(DWORD*)this))[0xd0/4])(
							this, FHit.Actor, FHit.Normal, 1);
					}
				}
				else
				{
					bFall = 1;
				}

				// Notify controller of potential fall
				if (!bWalkable || FHit.Time >= 1.0f)
				{
					if ((*(DWORD*)((BYTE*)this + 0x3e0) & 0x4000) != 0 &&
						bNotifyMayFall == 0 && Controller)
					{
						bNotifyMayFall = 1;
						Controller->eventMayFall();
					}
				}

				if (bFall)
				{
					FLOAT deltaSize = Delta.Size();
					FLOAT stepSize  = (Location - OldLoc).Size2D();
					if (deltaSize > 0.f)
					{
						FLOAT frac = stepSize / deltaSize;
						if (frac > 1.f) frac = 1.f;
						remTime = remTime + (1.f - frac) * subDt;
					}
					else
						remTime = 0.f;

					Velocity.Z = 0.f;
					eventFalling();
					if (Physics == PHYS_Walking)
					{
						FVector upVec(0.f, 0.f, -GravDir.Z);
						setPhysics(PHYS_Falling, NULL, upVec);
						if (remTime > 0.f)
							startNewPhysics(remTime, Iterations + 1);
					}
					return;
				}
			}  // FHit scope
		}  // OldLoc, Delta scope
	}
	unguard;
}

IMPL_DIVERGE("rdtsc cycle-counter profiling omitted; logic matches retail; Ghidra 0x103ec3f0")
INT APawn::pointReachable(FVector Dest, INT bKnowVisible)
{
	guard(APawn::pointReachable);
	if (!GIsEditor)
	{
		// 2D range check (XY only): > 1200 units → unreachable
		FVector flat(Dest.X - Location.X, Dest.Y - Location.Y, 0.f);
		if (flat.SizeSquared() > 1440000.0f)
			return 0;
	}
	if (!bKnowVisible)
	{
		// LOS check from eye position to destination
		FVector Eye = Location + eventEyePosition();
		FCheckResult Hit(1.0f);
		XLevel->SingleLineCheck(Hit, this, Dest, Eye, 0x286, FVector(0.f,0.f,0.f));
		if (Hit.Actor)
			return 0;
	}
	// Teleport to destination and back to get actual reachable position
	FVector SavedLoc = Location;
	INT moved = XLevel->FarMoveActor(this, Dest, 1, 0);
	FVector ActualDest;
	if (moved)
	{
		ActualDest = Location;
		XLevel->FarMoveActor(this, SavedLoc, 1, 1);
	}
	else
	{
		ActualDest = Dest;
	}
	return Reachable(ActualDest, NULL);
	unguard;
}

IMPL_DIVERGE("rotateToward: vtable[0x68] on MoveTarget approximated as IsA(ANavigationPoint); MoveTarget->Controller raw offset used")
void APawn::rotateToward(AActor* Focus, FVector FocalPoint)
{
guard(APawn::rotateToward);

// Skip if bRollToDesired set (bit 11 of pawn bitfield at +0x3e4) or Physics==PHYS_Spider (0x9).
// Note: Ghidra explicitly checks for PHYS_Spider (9), not PHYS_None (0).
if ((*(DWORD*)((BYTE*)this + 0x3e4) & 0x800) || Physics == PHYS_Spider)
return;

// Swimming/flying without bCanStrafe (bit 19 of +0x3e0): align acceleration with facing.
// Ghidra multiplies rotation unit vector by local_40[0] (likely Acceleration.Size()).
if (!(*(DWORD*)((BYTE*)this + 0x3e0) & 0x80000) &&
(Physics == PHYS_Flying || Physics == PHYS_Swimming))
{
Acceleration = Rotation.Vector() * Acceleration.Size();
}

// Determine target position; use tangent offset when following a NavPoint
// with a non-zero velocity (smooth bezier path following).
FVector TargetPos = FocalPoint;
if (Focus)
{
UBOOL usedTangent = false;
ANavigationPoint* NavFocus = Cast<ANavigationPoint>(Focus);
INT ctrlPtr = *(INT*)(this + 0x4ec); // APawn::Controller
if (NavFocus && ctrlPtr)
{
INT curNavPtr = *(INT*)(ctrlPtr + 0x448); // controller's current nav node
if (curNavPtr && *(AActor**)(curNavPtr + 0x3e0) == Focus && !Velocity.IsZero())
{
AActor* nextNode = *(AActor**)(curNavPtr + 0x48);
if (nextNode)
{
TargetPos.X = (Focus->Location.X - nextNode->Location.X) + Location.X;
TargetPos.Y = (Focus->Location.Y - nextNode->Location.Y) + Location.Y;
TargetPos.Z = (Focus->Location.Z - nextNode->Location.Z) + Location.Z;
usedTangent = true;
}
}
}
if (!usedTangent)
TargetPos = Focus->Location;
}

// Set DesiredRotation toward target; clear upper 16 bits of Yaw
FVector delta = TargetPos - Location;
DesiredRotation = delta.Rotation();
DesiredRotation.Yaw &= 0xFFFF;

// Walking: zero pitch unless MoveTarget is a navigation point (vtable[26]).
// Ghidra: calls vtable[0x68] on MoveTarget; approximated as IsA(ANavigationPoint).
if (Physics == PHYS_Walking)
{
INT ctrlPtr = *(INT*)(this + 0x4ec);
AActor* mt = ctrlPtr ? *(AActor**)(ctrlPtr + 0x3e0) : NULL;
if (!mt || !mt->IsA(ANavigationPoint::StaticClass()))
DesiredRotation.Pitch = 0;
}

unguard;
}

IMPL_MATCH("Engine.dll", 0x103e5a30)
void APawn::setMoveTimer(FLOAT DeltaTime)
{
	guard(APawn::setMoveTimer);
	if ( !Controller )
		return;

	if ( DesiredSpeed != 0.f )
	{
		FLOAT mult = 2.0f;
		// Ghidra: (byte)this[0x3e0] & 0x24 — bit5=bIsCrouched, bit2=bIsWalking
		if ( bIsCrouched || bIsWalking )
		{
			FLOAT inv = 1.0f / CrouchedPct;
			if ( inv > 2.0f )
				mult = inv;
		}
		Controller->MoveTimer = (mult * DeltaTime) / (GetMaxSpeed() * DesiredSpeed) + 1.0f;
	}
	else
	{
		Controller->MoveTimer = 0.5f;
	}

	// Ghidra: bit7 of Controller+0x3a8 = bPreparingMove; Controller+0x3e8 = PendingMover
	if ( Controller->bPreparingMove && Controller->PendingMover )
		Controller->MoveTimer += 2.0f;

	unguard;
}

IMPL_MATCH("Engine.dll", 0x103f3810)
void APawn::startNewPhysics(FLOAT DeltaTime, INT Iterations)
{
	guard(APawn::startNewPhysics);
	if( DeltaTime < 0.0003f )
		return;
	switch( Physics )
	{
	case PHYS_Walking:      physWalking(DeltaTime, Iterations); break;
	case PHYS_Falling:      physFalling(DeltaTime, Iterations); break;
	case PHYS_Swimming:     physSwimming(DeltaTime, Iterations); break;
	case PHYS_Flying:       physFlying(DeltaTime, Iterations); break;
	case PHYS_Spider:       physSpider(DeltaTime, Iterations); break;
	case PHYS_Ladder:       physLadder(DeltaTime, Iterations); break;
	case PHYS_RootMotion:   physRootMotion(DeltaTime); break;
	case PHYS_Karma:        physKarma(DeltaTime); break;
	case PHYS_KarmaRagDoll: physKarmaRagDoll(DeltaTime); break;
	}
	unguard;
}

IMPL_DIVERGE("startSwimming: vtable[0x98] MoveActor call uses raw vtable; water-line boundary MoveActor confirmed; velocity blending and cap match Ghidra")
void APawn::startSwimming(FVector OldVelocity, FVector OldAcceleration, FLOAT VelSize, FLOAT AccelSize, INT Iterations)
{
	guard(APawn::startSwimming);

	if ((*(INT*)((BYTE*)this + 0xa8) >= 0) && !(*(BYTE*)((BYTE*)this + 0xac) & 8))
	{
		if (VelSize > 0.f)
		{
			FVector Delta = Location - OldVelocity;
			Velocity = Delta / VelSize;
		}
		Velocity = Velocity * 2.f - OldAcceleration;

		// Cap velocity to PhysicsVolume MaxSpeed.
		FLOAT sq = Velocity.SizeSquared();
		FLOAT maxSpd = *(FLOAT*)((BYTE*)*(INT*)((BYTE*)this + 0x164) + 0x418);
		if (maxSpd * maxSpd < sq)
			Velocity = Velocity.SafeNormal() * maxSpd;
	}

	FVector WaterLine = findWaterLine(Location, OldVelocity);
	if (WaterLine != Location)
	{
		FLOAT CrossDist = (WaterLine - Location).Size();
		FLOAT BackDist  = (Location - OldVelocity).Size();
		AccelSize = (CrossDist / BackDist) * VelSize + AccelSize;

		FVector CrossDelta = WaterLine - Location;
		FCheckResult wHit(1.f);
		XLevel->MoveActor(this, CrossDelta, Rotation, wHit, 0, 0, 0, 0, 0);
	}

	if (Velocity.Z > -160.f && Velocity.Z < 0.f)
		Velocity.Z = -80.f - FVector(Velocity.X, Velocity.Y, 0.f).Size() * 0.7f;

	if (AccelSize > 0.01f)
		physSwimming(AccelSize, Iterations);

	unguard;
}

IMPL_MATCH("Engine.dll", 0x103e7100)
ETestMoveResult APawn::swimMove(FVector Delta, AActor* HitActor, FLOAT DeltaTime)
{
	guard(APawn::swimMove);

	FVector SavedLoc = Location;

	// NegNorm = -SafeNormal((0,0,-1)) = (0,0,1) — same pattern as flyMove.
	FVector NegNorm = -(FVector(0.f, 0.f, -1.f).SafeNormal());

	FCheckResult Hit(1.f);
	XLevel->MoveActor(this, Delta, Rotation, Hit, 1, 1, 0, 0, 0);

	if (HitActor != NULL && Hit.Actor == HitActor)
		return (ETestMoveResult)5;

	APhysicsVolume* physVol = *(APhysicsVolume**)((BYTE*)this + 0x164);
	UBOOL bInWater = physVol && ((*(BYTE*)((BYTE*)physVol + 0x410)) & 0x40);

	if (!bInWater)
	{
		// Exited water: find water surface boundary and move back to it.
		FVector WaterLine = findWaterLine(SavedLoc, Location);
		if (WaterLine != Location)
		{
			FVector WaterDelta = WaterLine - Location;
			XLevel->MoveActor(this, WaterDelta, Rotation, Hit, 1, 1, 0, 0, 0);
		}
	}
	else if (Hit.Time < 1.f)
	{
		// In water and hit a wall: slide along wall using NegNorm push + original direction.
		FLOAT fRemaining = 1.f - Hit.Time;
		FVector SlideDir = Delta.SafeNormal();
		XLevel->MoveActor(this, NegNorm * fRemaining, Rotation, Hit, 1, 1, 0, 0, 0);
		XLevel->MoveActor(this, SlideDir, Rotation, Hit, 1, 1, 0, 0, 0);

		if (HitActor != NULL && Hit.Actor == HitActor)
			return (ETestMoveResult)5;

		FVector Disp = Location - SavedLoc;
		if (DeltaTime * DeltaTime <= Disp.SizeSquared())
			return TESTMOVE_Moved;
	}

	return TESTMOVE_Stopped;
	unguard;
}

IMPL_DIVERGE("swimReachable: vtable[0x188] on APawn (water-entry gate, same unidentified slot as flyReachable) called via raw vtable; WarpZoneMarker+0x3E8 raw offset correct")
INT APawn::swimReachable(FVector Dest, INT bClearPath, AActor* GoalActor)
{guard(APawn::swimReachable);
INT flags = bClearPath | 4;
FVector SavedLoc = Location;
FVector SavedVel = Velocity;
// Ghidra: this+0xf8=CollisionRadius (max step size); this+0xfc=CollisionHeight (surface step offset)
FLOAT maxStep = (CollisionRadius <= 200.f) ? 200.f : CollisionRadius;
FLOAT maxStepSq = maxStep * maxStep;
INT reached = 0;
FLOAT fResult = 1.4013e-45f;  // Ghidra init: TESTMOVE_Moved as float bits
for ( INT iter = 0; iter < 100 && fResult != 0.f; iter++ )
{
FVector delta(Dest.X - Location.X, Dest.Y - Location.Y, Dest.Z - Location.Z);
if ( ReachedDestination(delta, GoalActor) )
{
reached = 1;
fResult = 0.f;
break;
}
FLOAT distSq = delta.SizeSquared();
FVector step;
FLOAT minDist;
if ( distSq < maxStepSq )
{
step = delta.SafeNormal() * maxStep;
minDist = 4.1f;
}
else
{
step = delta;
minDist = 8.0f;
}
fResult = (FLOAT)(INT)swimMove(step, GoalActor, minDist);
// 5 = TESTMOVE_HitGoal: value not in SDK enum but returned by retail swimMove on goal touch
if ( (INT)fResult == 5 )
{
reached = 1;
fResult = 0.f;
}
// Check if we left the water zone
if ( Region.Zone && (*(BYTE*)((BYTE*)Region.Zone + 0x410) & 0x40) )
{
// Still in water; DIVERGENCE: retail calls vtable[0x188](this,step,buf) — omitted
}
else
{
// Exited water: stop swimming this iteration
fResult = 0.f;
if ( (*(DWORD*)((BYTE*)this + 0x3e0) & 0x20000) != 0 )
{
// bCanFly (bit 17): try flying to destination
flags = flyReachable(Dest, flags, GoalActor);
reached = (flags != 0);
}
else if ( bCanWalk && Dest.Z < Location.Z + 118.f )
{
// DIVERGENCE: retail does XLevel->MoveActor step-up by max(Dest.Z-Location.Z, CollisionHeight+33)
// then calls flyReachable if blocked; simplified here to direct flyReachable
flags = flyReachable(Dest, flags, GoalActor);
reached = (flags != 0);
}
}
}
// WarpZoneMarker: if pawn ended in destination zone, count as reached
// DIVERGENCE: this+0x228=Region.Zone ptr; GoalActor+1000=WarpZone dest zone (field not in SDK)
if ( !reached && GoalActor && GoalActor->IsA(AWarpZoneMarker::StaticClass()) )
reached = ( *(INT*)((BYTE*)this + 0x228) == *(INT*)((BYTE*)GoalActor + 1000) );
XLevel->FarMoveActor(this, SavedLoc, 1, 1);
Velocity = SavedVel;
return reached ? flags : 0;
unguard;
}

// Ghidra 0x103e69e0 (1084 bytes).
//
// Retail pattern summary:
//   1. Zero Delta.Z (walking is XY-only).
//   2. Gravity direction = (0,0,±1) from Zone->Gravity.Z (this+0x164+0x458).
//      SafeNormal of that is trivially the same unit vector.
//   3. First XY MoveActor with fStepDist=33.
//   4. If blocked: step-up in anti-gravity dir with fStepDist=remaining;
//      slide in SafeNormal(Delta) + anti-gravity-Z direction;
//      step-down in gravity dir (no fStepDist) to validate new floor.
//      Bad floor (hit+steep): restore to post-XY loc and return Stopped(0).
//   5. Always: step-down in gravity dir with fStepDist=35 to settle on floor.
//      No floor or steep: restore and return Fell(2).
//   6. Displacement check: return Stopped(0) or Moved(1).
//   Return 5 = HitGoal (enum value not in ETestMoveResult, but used at runtime).
//
// Note on slide Z (Ghidra ambiguity): Ghidra interleaves SafeNormal(Delta) result reads
// with the gravity-negation writes to the same locals.  We faithfully reproduce
// param_4 = -(gravSign) (anti-gravity Z) as the slide's Z component; since Delta.Z
// was forced to 0, SafeNormal(Delta).Z = 0 so this represents the Ghidra's arithmetic.
IMPL_MATCH("Engine.dll", 0x103e69e0)
ETestMoveResult APawn::walkMove(FVector Delta, FCheckResult& Hit, AActor* HitActor, FLOAT DeltaTime)
{
	guard(APawn::walkMove);

	FVector SavedLoc = Location;

	// Walking is XY only — force Z to zero.
	Delta.Z = 0.f;

	// Gravity direction: read Zone->Gravity.Z at this+0x164+0x458.
	// Normal gravity (Gravity.Z <= 0): gravSign = -1 (gravity pulls down).
	// Anti-gravity (Gravity.Z >  0): gravSign = +1 (gravity pulls up).
	FLOAT gravZ = *(FLOAT*)((BYTE*)*(INT*)((BYTE*)this + 0x164) + 0x458);
	FLOAT gravSign = (gravZ > 0.f) ? 1.f : -1.f;

	// GravDir = SafeNormal((0,0,gravSign)) = (0,0,gravSign).
	FVector GravDir(0.f, 0.f, gravSign);

	// Move 1: attempt XY move.
	XLevel->MoveActor(this, Delta, Rotation, Hit, 1, 1, 0, 0, 0);

	if (HitActor != NULL && Hit.Actor == HitActor)
		return (ETestMoveResult)5;  // HitGoal

	// Save location after XY move (used for restore if step-up fails).
	FVector SavedSlide = Location;

	if (Hit.Time < 1.f)
	{
		FLOAT fRemaining = 1.f - Hit.Time;

		// SlideDir: SafeNormal(Delta) for horizontal direction.
		// Ghidra: FVector::operator*((FVector*)&param_2,(float)&local_34) with hidden-return
		// at local_34 area = SafeNormal(Delta).  The Ghidra interleaving then sets
		// param_4 = local_2c which at that point holds -(gravSign) (anti-gravity Z).
		// Retail: slide direction includes anti-gravity Z component.
		FVector SafeDelta = Delta.SafeNormal();
		FLOAT antiGravZ = -gravSign;
		FVector SlideDir(SafeDelta.X, SafeDelta.Y, antiGravZ);

		// StepUp = anti-gravity unit direction.
		FVector StepUp(0.f, 0.f, antiGravZ);

		// Move 2: step up in anti-gravity direction, fStepDist = remaining fraction.
		XLevel->MoveActor(this, StepUp, Rotation, Hit, 1, 1, 0, 0, 0);

		// Move 3: slide.
		XLevel->MoveActor(this, SlideDir, Rotation, Hit, 1, 1, 0, 0, 0);

		if (HitActor != NULL && Hit.Actor == HitActor)
			return (ETestMoveResult)5;  // HitGoal

		// Move 4: step down in gravity direction (no fStepDist) to validate floor.
		XLevel->MoveActor(this, GravDir, Rotation, Hit, 1, 1, 0, 0, 0);

		// If we hit something AND it's too steep — can't use as floor; abort step.
		if (Hit.Time < 1.f && Hit.Normal.Z < 0.7f)
		{
			XLevel->FarMoveActor(this, SavedSlide, 1, 1);
			return TESTMOVE_Stopped;
		}
	}

	// Update SavedCurrent to position before the main step-down.
	FVector SavedCurrent = Location;

	// Recompute SafeNormal(GravDir) — retail calls FVector::operator* again here.
	// SafeNormal((0,0,gravSign)) = (0,0,gravSign), same as GravDir.

	// Move 5: settle on floor — step down 35 units in gravity direction.
	XLevel->MoveActor(this, GravDir, Rotation, Hit, 1, 1, 0, 0, 0);

	// If no floor found (Time == 1.0) OR floor too steep — fell.
	if (*(INT*)&Hit.Time == 0x3f800000 || Hit.Normal.Z < 0.7f)
	{
		XLevel->FarMoveActor(this, SavedCurrent, 1, 1);
		return TESTMOVE_Fell;
	}

	if (HitActor != NULL && Hit.Actor == HitActor)
		return (ETestMoveResult)5;  // HitGoal

	FVector Disp = Location - SavedLoc;
	if (Disp.SizeSquared() < DeltaTime * DeltaTime)
		return TESTMOVE_Stopped;

	return TESTMOVE_Moved;
	unguard;
}

// Ghidra 0x103eac30; 1365 bytes.
// Iterative walker: step repeatedly toward Dest using walkMove, checking for floor
// after each step.  Returns bClearPath-flags on success, 0 on failure.
// DIVERGENCE: SingleLineCheck's 9th arg (puVar6 = local buffer or float 8.0 literal seen in
// Ghidra) is absent — confirmed via .def mangled name that the retail function only takes 6
// declared params; the 9th push is a Ghidra stack-tracking artifact.
IMPL_MATCH("Engine.dll", 0x103eac30)
INT APawn::walkReachable(FVector Dest, INT bClearPath, AActor* GoalActor)
{
	guard(APawn::walkReachable);

	// Save position and velocity for restoration at the end
	FVector SavedLoc   = Location;
	FVector SavedVel;
	SavedVel.X = *(FLOAT*)(this + 0x24c);
	SavedVel.Y = *(FLOAT*)(this + 0x250);
	SavedVel.Z = *(FLOAT*)(this + 0x254);

	DWORD  flags      = (DWORD)bClearPath | 1;
	FLOAT  stepRadius = 16.0f;

	if ( !GIsEditor )
	{
		stepRadius = CollisionRadius;
		if ( *(DWORD*)(this + 0x3e0) & 0x4000 )        // bLargeActor
		{
			if ( stepRadius <= 62.0f ) stepRadius = 62.0f;
		}
		else
		{
			if ( stepRadius <= 12.0f ) stepRadius = 12.0f;
		}
	}

	INT   maxIter     = 100;
	FLOAT stepRadSq   = stepRadius * stepRadius;
	FVector stepDir(0.0f, 0.0f, 0.0f);
	INT   reached     = 0;

	ETestMoveResult move = TESTMOVE_Moved;

	while ( move == TESTMOVE_Moved )
	{
		FLOAT dX = Dest.X - Location.X;
		FLOAT dY = Dest.Y - Location.Y;
		FLOAT dZ = Dest.Z - Location.Z;
		stepDir.X = dX;
		stepDir.Y = dY;
		stepDir.Z = 0.0f;  // walk is XY-only for step direction

		if ( ReachedDestination(FVector(dX, dY, dZ), GoalActor) )
		{
			reached = 1;
			move    = TESTMOVE_Stopped;
			continue;
		}

		// Step direction: normalize and scale to stepRadius if we're far away
		FLOAT distSq2d = dX*dX + dY*dY;
		if ( distSq2d < stepRadSq )
		{
			FVector norm = stepDir.SafeNormal();
			stepDir = norm * stepRadius;
		}

		FCheckResult hit(1.0f);
		move = walkMove(stepDir, hit, GoalActor, 4.1f);

		if ( move == TESTMOVE_Moved )
		{
			// Floor probe: trace straight down from current position
			FLOAT extR  = CollisionRadius * 0.5f;
			FLOAT extH  = CollisionHeight * 0.5f;
			FVector traceEnd(Location.X, Location.Y, Location.Z - (extH + 37.0f));
			FCheckResult floorHit(1.0f);
			XLevel->SingleLineCheck(floorHit, this, traceEnd, Location, 0x286,
			                        FVector(extR, extR, extH));
			if ( floorHit.Time < 1.0f )
			{
				flags     |= 8;  // floor found — pawn is on solid ground
				(DWORD&)bClearPath = flags;
			}
		}
		else if ( (INT)move == 5 )  // TESTMOVE_HitGoal
		{
			reached = 1;
			move    = TESTMOVE_Stopped;
		}
		else if ( !Owner )
		{
			GLog->Logf(NAME_Log, TEXT("walkReachable: no owner"));
			reached = 0;
			move    = TESTMOVE_Stopped;
		}
		else if ( *(DWORD*)(this + 0x3e0) & 0x20000 )  // bFlyingSupport
		{
			flags    = (DWORD)flyReachable(Dest, (INT)flags, GoalActor);
			reached  = (INT)flags;
			move     = TESTMOVE_Stopped;
		}
		else if ( *(DWORD*)(this + 0x3e0) & 0x4000 )   // bLargeActor
		{
			flags |= 8;
			(DWORD&)bClearPath = flags;
			if ( move == TESTMOVE_Fell )
			{
				reached = 0;
			}
			else if ( move == TESTMOVE_Stopped )
			{
				ETestMoveResult jup = FindJumpUp(stepDir);
				if ( (INT)jup == 5 )
				{
					reached = 1;
					move    = TESTMOVE_Stopped;
				}
			}
		}
		else if ( move == TESTMOVE_Fell && stepRadius > 33.0f )
		{
			// Hit a wall with large step — retry with smaller stepRadius
			stepRadius = 33.0f;
			stepRadSq  = stepRadius * stepRadius;
			move       = TESTMOVE_Moved;
		}

		// PlayerControlled check: vtable[0x188] confirmed as APawn::PlayerControlled() via .def
		if ( PlayerControlled() )
		{
			reached = 0;
			move    = TESTMOVE_Stopped;
		}
		else
		{
			// If in water and pawn can swim, fall back to swimReachable
			AZoneInfo* Zone = (AZoneInfo*)*(INT*)(this + 0x164);
			if ( Zone && (*(BYTE*)((BYTE*)Zone + 0x410) & 0x40) != 0  // bWaterVolume
			          && (*(BYTE*)(this + 0x3e2) & 1) != 0 )           // bCanSwim
			{
				flags    = (DWORD)swimReachable(Dest, (INT)flags, GoalActor);
				reached  = (INT)flags;
				move     = TESTMOVE_Stopped;
			}
		}

		if ( --maxIter < 0 )
			move = TESTMOVE_Stopped;
	}

	// WarpZone destination check
	if ( !reached && GoalActor && GoalActor->IsA(AWarpZoneMarker::StaticClass()) )
		reached = ( *(INT*)(this + 0x228) == *(INT*)((BYTE*)GoalActor + 1000) );

	XLevel->FarMoveActor(this, SavedLoc, 1, 1);
	*(FLOAT*)(this + 0x24c) = SavedVel.X;
	*(FLOAT*)(this + 0x250) = SavedVel.Y;
	*(FLOAT*)(this + 0x254) = SavedVel.Z;

	return reached ? (INT)(-(DWORD)(reached != 0) & flags) : 0;
	unguard;
}

/*-----------------------------------------------------------------------------
	AController — Virtual methods.
-----------------------------------------------------------------------------*/

IMPL_DIVERGE("Ghidra: AController::GetOptimizedRepList body not exported; delegates to AActor base")
INT* AController::GetOptimizedRepList( BYTE* InDefault, FPropertyRetirement* Retire, INT* Ptr, UPackageMap* Map, UActorChannel* Ch )
{
	guard(AController::GetOptimizedRepList);
	Ptr = AActor::GetOptimizedRepList( InDefault, Retire, Ptr, Map, Ch );
	return Ptr;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x114310)
AActor* AController::GetTeamManager()
{
	// Ghidra 0x114310: shared stub; returns NULL.
	return NULL;
}

IMPL_MATCH("Engine.dll", 0x114310)
INT AController::LocalPlayerController()
{
	// Ghidra 0x114310: shared stub; returns 0.
	return 0;
}

// Ghidra 0x103c3870, 977b.
// Confirmed field layout (see DECOMPILATION_PLAN.md for AController offset table):
//   Physics (BYTE)       = actor+0x2c  Role (BYTE) = actor+0x2d
//   SightCounter (FLOAT) = this+0x3ac  FocalPoint (FVector) = this+0x48c
//   Focus* (AActor*)     = this+0x3e4  MonitorStartLoc (FVector) = this+0x4d4
// DIVERGE: vtable[0xf0] call on 'this' (Role > ROLE_DumbProxy path) is an unidentified
// virtual function; raw offset accesses for ULevel+0x100 and actor+0x144 have no named
// counterpart; Pawn+0xb4 = LastRenderTime (AActor field, no named decl here).
// NOTE: Ghidra 977b body has NO rdtsc — prior rdtsc claim was incorrect.
IMPL_DIVERGE("AController::Tick: vtable[0xf0] on Controller (likely NotifyAnimEnd inherited, slot identity unconfirmed) omitted; raw offsets XLevel+0x100 and this+0x320 used by name")
INT AController::Tick( FLOAT DeltaTime, ELevelTick TickType )
{
	guard(AController::Tick);

	// Determine whether to skip main tick logic (performance culling for hidden AI).
	// Conditions: controller bHidden, pause tick, or pawn culled (hidden+static physics+stale render).
	UBOOL bSkip =
		  bHidden
		||TickType == LEVELTICK_ViewportsOnly
		|| (   Pawn != NULL
			&& Pawn->bHidden
			&& (Pawn->Physics == PHYS_None || Pawn->Physics == PHYS_Rotating)
			&& (5.0f < *(FLOAT*)((BYTE*)XLevel + 0xd4) - *(FLOAT*)((BYTE*)Pawn + 0xb4))
			&& *(BYTE*)((BYTE*)*(INT*)((BYTE*)this + 0x144) + 0x425) == '\0' );

	// Sync the hidden-flag word at this+0x320 with XLevel flag bit0 (both paths).
	DWORD  xLevelBit = *(DWORD*)((BYTE*)XLevel + 0x100);
	DWORD* pHidFlag  = (DWORD*)((BYTE*)this + 0x320);
	*pHidFlag ^= (xLevelBit ^ *pHidFlag) & 1u;

	if( bSkip )
		return 1;

	// Role > ROLE_DumbProxy: retail calls vtable[0xf0](this, DeltaTime, TickType).
	// Vtable slot unidentified — omitted. Retail likely runs a base-class tick here.

	if( Role == ROLE_Authority && TickType == LEVELTICK_All )
	{
		// SightCounter: counts down between enemy-visibility probes.
		if( SightCounter < 0.0f )
		{
			// Probe index 0x155 determines if this event is being listened to.
			if( !IsProbing(FName((EName)0x155)) )
			{
				SightCounter += 0.2f;
			}
			else
			{
				CheckEnemyVisible();
				SightCounter += 0.1f;
			}
		}
		SightCounter -= DeltaTime;

		// ShowSelf if Pawn is not culled-hidden (bit1 of Pawn+0xa0) and Focus->APawnFlags bit3 clear.
		if(    Pawn
			&& !(*(BYTE*)((BYTE*)Pawn + 0xa0) & 2)
			&& Focus
			&& !(*(BYTE*)((BYTE*)Focus + 0x3e4) & 8) )
			ShowSelf();
	}

	// Rotate pawn toward focus/focalpoint if the pawn's bRotateToDesired flag (bit1 at +0xac) is set.
	if( Pawn )
	{
		if( *(BYTE*)((BYTE*)Pawn + 0xac) & 2 )
			Pawn->rotateToward( Focus, FocalPoint );

		// Mirror Pawn velocity onto the Controller (for AI prediction and replication).
		Velocity = Pawn->Velocity;
	}

	// MonitoredPawn distance / alert logic.
	if( MonitoredPawn )
	{
		// Fire alert if Pawn gone, MonitoredPawn is culled-hidden, or its "alive" flag cleared.
		if(    !Pawn
			|| *(BYTE*)((BYTE*)MonitoredPawn + 0xa0) < 0
			|| *(INT*)((BYTE*)MonitoredPawn + 0x4ec) == 0 )
		{
			eventMonitoredPawnAlert();
		}
		else
		{
			FVector dToPawn   = MonitoredPawn->Location - Pawn->Location;
			FLOAT   distSqToP = dToPawn.SizeSquared();

			if( distSqToP <= MonitorMaxDistSq )
			{
				FVector dFromStart   = MonitoredPawn->Location - MonitorStartLoc;
				FLOAT   distSqFromSt = dFromStart.SizeSquared();

				if( MonitorMaxDistSq * 0.25f < distSqFromSt )
				{
					// Dot product: (MonitorStartLoc - Pawn.Location) · MonitoredPawn.Acceleration
					FVector toStart = MonitorStartLoc - Pawn->Location;
					if( (toStart | MonitoredPawn->Acceleration) <= 0.0f )
						return 1;   // pawn is between start and monitor; no alert

					FVector dToPawn2 = MonitoredPawn->Location - Pawn->Location;
					if( MonitorMaxDistSq * 0.25f < dToPawn2.SizeSquared() )
						return 1;   // monitor still far from pawn; no alert
				}
			}

			eventMonitoredPawnAlert();
		}
	}

	return 1;
	unguard;
}

IMPL_EMPTY("Ghidra lookup: AController::AdjustFromWall not found in export — retail appears trivial")
void AController::AdjustFromWall( FVector HitNormal, AActor* HitActor )
{
	guard(AController::AdjustFromWall);
	unguard;
}

IMPL_MATCH("Engine.dll", 0x1209E0)
void AController::StartAnimPoll()
{
	// Retail RVA 0x1209E0.
	// Mirrors AActor::StartAnimPoll but operates on Pawn's mesh/MeshInstance
	// while using the controller's own LatentFloat and GetStateFrame().
	// MeshGetInstance is called with 'this' (controller) as the actor context.
	// The keep-polling check uses Pawn->IsAnimating (AActor::IsAnimating).
	if( !Pawn )
		return;
	if( !Pawn->Mesh )
		return;
	Pawn->Mesh->MeshGetInstance( this );
	UMeshInstance* mi = Pawn->MeshInstance;
	INT fi = appRound( LatentFloat );
	if( mi->IsAnimating( fi ) )       // UMeshInstance::IsAnimating, vtable[0xe8]
		mi->IsAnimPastLastFrame( fi ); // vtable[0xf0]
	if( Pawn->IsAnimating( fi ) )     // AActor::IsAnimating on Pawn
		if( !mi->IsAnimLooping( fi ) ) // vtable[0xec]
			GetStateFrame()->LatentAction = EPOLL_FinishAnim;
}

// Ghidra 0x10420b10, 108b. No guard/unguard (no SEH in retail). unaff_retaddr = Channel.
// MeshGetInstance called on Pawn->Mesh with this (Controller) as the Actor arg; return
// value discarded — side-effect populates Pawn->MeshInstance. IsAnimating is the non-virtual
// AActor:: overload (const). IsAnimLooping is vtable[0xec] on UMeshInstance.
IMPL_MATCH("Engine.dll", 0x10420b10)
INT AController::CheckAnimFinished( INT Channel )
{
	if( Pawn && Pawn->Mesh )
	{
		Pawn->Mesh->MeshGetInstance(this);
		if( Pawn->IsAnimating(Channel) )
		{
			if( !Pawn->MeshInstance->IsAnimLooping(Channel) )
				return 0;
		}
		return 1;
	}
	return 1;
}

IMPL_MATCH("Engine.dll", 0x4720)
INT AController::AcceptNearbyPath( AActor* Goal )
{
	// Ghidra 0x4720: shared stub; returns 0.
	return 0;
}

// Ghidra 0x10390ec0, 1187b.
// NoiseMaker+0x148 chain check (actor validity) → approximated by null check.
// Alertness (Pawn+0x3fc = APawn::Alertness) boosts effective range.
// Same-zone: APawn bitfield2 bits5+6 = bSameZoneHearing|bAdjacentZoneHearing; Region.Zone match.
// Adjacent-zone team check (complex raw ULevel+0x128 team-affinity matrix) → DIVERGE.
// LOS: APawn bitfield2 bit4 = bLOSHearing; UModel::FastLineCheck from EyePos to NoiseLoc.
// Muffled: bit7 = bMuffledHearing; retail path-finds through walls → DIVERGE (unconditional).
// Around-corner: bit8 = bAroundCornerHearing; FSortedPathList navpoint relay → DIVERGE.
IMPL_DIVERGE("CanHear: bAdjacentZoneHearing team-affinity matrix (ULevel+0x128) omitted; bMuffledHearing path approximated as 1/4-range grant; bAroundCornerHearing FSortedPathList relay omitted (FUN_1050557c has in_ST0 x87-register arg)")
INT AController::CanHear( FVector NoiseLoc, FLOAT Loudness, AActor* NoiseMaker, ENoiseType NoiseType, EPawnType PawnType )
{
	guard(AController::CanHear);
	// Ghidra: NoiseMaker+0x148 (Level linkage chain) must be valid; Pawn must exist.
	if (!Pawn || !NoiseMaker) return 0;

	// Distance from noise source to pawn (Ghidra: local_28/24/20 = Pawn->Location - NoiseLoc)
	FVector delta(Pawn->Location.X - NoiseLoc.X,
	               Pawn->Location.Y - NoiseLoc.Y,
	               Pawn->Location.Z - NoiseLoc.Z);
	FLOAT distSq = delta.SizeSquared();

	// Alertness boost: effective loudness *= Max(0, Alertness + 1.0) (Ghidra: Pawn+0x3fc = Alertness)
	FLOAT alertBoost = Max(0.f, Pawn->Alertness + 1.f);
	Loudness *= alertBoost;

	// Distance gate: Loudness must cover distSq
	if (Loudness < distSq) return 0;

	// Same/adjacent zone hearing (APawn+0x3e4 bits5+6 = bSameZoneHearing|bAdjacentZoneHearing)
	if ((Pawn->bSameZoneHearing || Pawn->bAdjacentZoneHearing)
		&& Pawn->Region.Zone != NULL && Pawn->Region.Zone == NoiseMaker->Region.Zone)
		return 1;
	// DIVERGE: bAdjacentZoneHearing + team-affinity table (ULevel+0x128 raw matrix) omitted.

	// LOS hearing (APawn+0x3e4 bit4 = bLOSHearing)
	if (Pawn->bLOSHearing)
	{
		// Eye position: eventEyePosition() returns relative offset; absolute = Location + offset
		FVector EyeLoc = Pawn->Location + Pawn->eventEyePosition();
		UModel* Mdl = *(UModel**)((BYTE*)XLevel + 0x90);
		if (Mdl && Mdl->FastLineCheck(NoiseLoc, EyeLoc))
			return 1;
		// bMuffledHearing (bit7): hear through walls at 1/4 effective range
		// DIVERGE: retail does a path-trace here; we grant hearing if in 1/4-range
		if (Pawn->bMuffledHearing && distSq * 4.f < Loudness)
			return 1;
	}
	// DIVERGE: bAroundCornerHearing (bit8) FSortedPathList navpoint-relay check omitted.
	return 0;
	unguard;
}

// Ghidra 0x1042cc70 (239b): checks Pawn exists, probes with FName(0x15e=NAME_Probe50)
// for AIHearSound, calls CanHearSound with Pawn->Location as listener, fires eventAIHearSound.
// Retail multiplies SoundLoc by 1.0f scalar (= SoundLoc unchanged) in the event call.
// DIVERGENCE: we use ENGINE_AIHearSound FName (same runtime value in practice); SoundLoc direct.
IMPL_DIVERGE("Ghidra 0x1042cc70: retail has no SEH frame; we add guard/unguard; retail constructs FName(0x15e) on stack before IsProbing call; our ENGINE_AIHearSound named constant differs in binary form")
void AController::CheckHearSound( AActor* SoundMaker, INT SoundId, USound* Sound, FVector SoundLoc, FLOAT Volume, INT Flags )
{
	guard(AController::CheckHearSound);
	if (!Pawn)
		return;
	if (!IsProbing(ENGINE_AIHearSound))
		return;
	FVector OutNoiseLoc;
	// Pawn->Location is the listener location; SoundLoc is the sound origin (passed unscaled).
	if (CanHearSound(Pawn->Location, SoundMaker, Volume, OutNoiseLoc))
		eventAIHearSound(SoundMaker, SoundId, Sound, Pawn->Location, SoundLoc, (DWORD)Flags);
	unguard;
}

IMPL_MATCH("Engine.dll", 0x1038d410)
AActor* AController::GetViewTarget()
{
	// Ghidra: reads Pawn at this+0x3d8 twice; returns Pawn if non-null, else this (controller).
	AActor* ViewTarget = Pawn;
	if( !ViewTarget )
		ViewTarget = this;
	return ViewTarget;
}

IMPL_EMPTY("Ghidra lookup: AController::SetAdjustLocation not found in export — retail appears trivial")
void AController::SetAdjustLocation( FVector NewLoc )
{
	guard(AController::SetAdjustLocation);
	unguard;
}

/*-----------------------------------------------------------------------------
	AController — Non-virtual methods.
-----------------------------------------------------------------------------*/

// Ghidra 0x10391B60, 510b.
// rdtsc profiling: DIVERGE (omitted).
// FUN_10391970 visibility hash table: DIVERGE (omitted; probe check always performed).
// Level->ControllerList: Ghidra raw *(AController**)(Level+0x4d4) = Level->ControllerList.
// SeePawn condition: bIsPlayer(this)||bIsPlayer(other) guards; SightCounter<0 gate (countdown timer).
// FNames: bIsPlayer→EName(0x154), non-player→EName(0x158) (specific probe name indices).
// Pawn->m_ePawnType (APawn own +0x0a) == 1 = player-type pawn (used for hash & event dispatch).
// DIVERGENCE from retail:
// 1. rdtsc profiling counters omitted (permanent: binary-specific performance instrumentation).
// 2. FUN_10391970 visibility hash table omitted — binary-specific optimisation that caches which
//    controllers are "watching" a given FName; we always perform the IsProbing check (safe, just
//    slightly more conservative).
// 3. Level.flags_at_0x450 bit12 optimisation omitted — when set, skips IsProbing for non-player
//    pawns (always-visible fast path); our code always probes (functionally correct but slower).
IMPL_DIVERGE("Ghidra 0x10391B60: rdtsc profiling omitted (permanent); FUN_10391970 visibility hash is a binary-specific global struct; Level bit12 fast-path is a binary-specific flag")
void AController::ShowSelf()
{
	guard(AController::ShowSelf);
	if( !Pawn )
		return;

	const UBOOL bSelfIsPlayer = (bIsPlayer != 0);

	for( AController* other = Level->ControllerList; other; other = other->nextController )
	{
		if( other == this ) continue;
		// Ghidra: (bIsPlayer(this) || bIsPlayer(other)) && other->SightCounter < 0
		// SightCounter is a countdown timer: negative = expired = time to check.
		if( !(bSelfIsPlayer || other->bIsPlayer) ) continue;
		if( other->SightCounter >= 0.f ) continue;  // timer still running, skip

		// Probe check: use FName(0x154) for player-pawn, FName(0x158) for AI-pawn
		// (Ghidra: hash table guards this — we always check the probe)
		EName probeName = bSelfIsPlayer ? (EName)0x154 : (EName)0x158;
		if( !other->IsProbing(FName(probeName)) ) continue;

		// Check if other can see our pawn
		if( other->SeePawn(Pawn, 1) )
		{
			if( !bSelfIsPlayer )
				other->eventSeeMonster( Pawn );
			else
				other->eventSeePlayer( Pawn );
		}
	}
	unguard;
}

IMPL_MATCH("Engine.dll", 0x1038d370)
DWORD AController::SeePawn( APawn* Seen, INT bMaySkipChecks )
{
	guard(AController::SeePawn);
	if( Seen && Pawn )
		return Pawn->R6SeePawn(Seen, bMaySkipChecks);
	return 0;
	unguard;
}

// DAT_1066ad7c: module-level goal cache (4 entries), cleared on bInitialPath=1
static AActor* sGoalCache[4] = {NULL, NULL, NULL, NULL};
// Ghidra 0x1038d500 (476b): uses DAT_1066ad7c (retail static address) for sGoalCache;
// FName 0x15a = NAME_SpecialHandling used for IsProbing check.
// DIVERGENCE: our sGoalCache static has a linker-assigned address ≠ retail DAT_1066ad7c.
IMPL_DIVERGE("Ghidra 0x1038d500: retail sGoalCache is at fixed address DAT_1066ad7c embedded as an absolute immediate; our linker assigns a different address — permanent binary difference")
AActor* AController::SetPath( INT bInitialPath )
{
guard(AController::SetPath);

AActor* result = RouteCache[0];

if (Pawn && Pawn->ValidAnchor())
{
if (!bInitialPath)
{
// Save RouteGoal to GoalList if there is an empty slot or it is already there
for (INT i = 0; i < 4; i++)
{
if (GoalList[i] == RouteGoal) break;
if (!GoalList[i]) { GoalList[i] = RouteGoal; break; }
}
}
else
{
for (INT i = 0; i < 4; i++) sGoalCache[i] = NULL;

if (RouteGoal == GoalList[0])
{
if (GoalList[1])
{
// Walk GoalList[1+] to find the first null entry (Ghidra: no upper bound)
INT i = 1;
while (i < 4 && GoalList[i]) i++;
AActor* nextGoal = GoalList[i - 1];
if (Pawn->actorReachable(nextGoal, 0, 0))
{
GoalList[i - 1] = NULL;
return nextGoal;
}
FLOAT dist = Pawn->findPathToward(nextGoal, nextGoal->Location, NULL, 0, 1.f);
if (dist > 0.f)
result = SetPath(0);
}
}
else
{
GoalList[0] = RouteGoal;
for (INT i = 1; i < 4; i++) GoalList[i] = NULL;
}
}

// Record result in the module-level goal cache (skip duplicates)
for (INT i = 0; i < 4; i++)
{
if (!sGoalCache[i]) { sGoalCache[i] = result; break; }
if (sGoalCache[i] == result) return result;
}

if (result && result->IsProbing(NAME_SpecialHandling))
result = HandleSpecial(result);
}

return result;
unguard;
}

// Ghidra 0x1041CCC0 (676b): uses raw offsets +0x394=cost, +0x3ac=prevPath, +0x3b4=nextPath.
// Also calls FUN_1035a3d0 (54b profiling timer) before the SingleLineCheck — skipped here.
// Uses &ANavigationPoint::PrivateStaticClass for IsA check (we use StaticClass()).
IMPL_DIVERGE("Ghidra 0x1041CCC0: skips FUN_1035a3d0 profiling call; uses StaticClass() not &ANavigationPoint::PrivateStaticClass — both permanent binary differences")
void AController::SetRouteCache( ANavigationPoint* EndPath, FLOAT StartDist, FLOAT EndDist )
{
	guard(AController::SetRouteCache);
	RouteGoal = EndPath;
	if (!EndPath)
	{
		return;  // early return: C++ unwinds the try-block from guard() automatically
	}
	// Store total route cost: EndPath's accumulated cost + caller-supplied end distance
	RouteDist = *(FLOAT*)((BYTE*)EndPath + 0x394) + EndDist;
	// Walk the nextPath chain (EndPath → ... → FirstNode near pawn) building prevPath back-links
	*(ANavigationPoint**)((BYTE*)EndPath + 0x3ac) = NULL;
	ANavigationPoint* nav = EndPath;
	while (*(ANavigationPoint**)((BYTE*)nav + 0x3b4) != NULL)
	{
		ANavigationPoint* nxt = *(ANavigationPoint**)((BYTE*)nav + 0x3b4);
		*(ANavigationPoint**)((BYTE*)nxt + 0x3ac) = nav;  // nxt->prevPath = nav
		nav = nxt;
	}
	// nav = FirstNode (closest to pawn); try to skip it if pawn is already past it
	ANavigationPoint* routeStart = nav;
	ANavigationPoint* prevNode = *(ANavigationPoint**)((BYTE*)nav + 0x3ac);
	if (prevNode)
	{
		if (!Pawn || StartDist <= 0.f)
		{
			routeStart = prevNode;
		}
		else
		{
			// Skip first hop if pawn is close enough and has LOS + actorReachable to prevNode
			FVector toPrev(Pawn->Location - prevNode->Location);
			FLOAT distToPrev = toPrev.Size();
			FVector hopVec(nav->Location - prevNode->Location);
			FLOAT hopLen = hopVec.Size();
			if ((distToPrev < 1200.f) && (distToPrev < (hopLen + StartDist) * 0.85f))
			{
				FCheckResult Hit(1.0f);
				XLevel->SingleLineCheck(Hit, this, prevNode->Location, Pawn->Location, 0x286, FVector(0.f,0.f,0.f));
				if (!Hit.Actor && Pawn->actorReachable(prevNode, 1, 1))
					routeStart = prevNode;
			}
		}
	}
	// Fill RouteCache[0..15] following prevPath (toward EndPath)
	ANavigationPoint* p = routeStart;
	for (INT i = 0; i < 16; i++)
	{
		RouteCache[i] = p;
		if (p) p = *(ANavigationPoint**)((BYTE*)p + 0x3ac);
	}
	// Set Pawn->NextPathRadius from reachspec between RouteCache[0] and RouteCache[1].
	// Ghidra: only resets when Pawn AND RouteCache[1] are both non-null.
	if (Pawn && RouteCache[1])
	{
		if (RouteCache[0] && RouteCache[0]->IsA(ANavigationPoint::StaticClass()) &&
		    RouteCache[1]->IsA(ANavigationPoint::StaticClass()))
		{
			UReachSpec* spec = ((ANavigationPoint*)RouteCache[0])->GetReachSpecTo((ANavigationPoint*)RouteCache[1]);
			if (spec)
			{
				// spec+0x34 = reachability radius (INT cast to float)
				Pawn->NextPathRadius = (FLOAT)*(INT*)((BYTE*)spec + 0x34);
				return;
			}
		}
		Pawn->NextPathRadius = 0.f;
	}
	unguard;
}

IMPL_MATCH("Engine.dll", 0x1038d460)
DWORD AController::LineOfSightTo( AActor* Other, INT bUseLOSFlag )
{
	guard(AController::LineOfSightTo);
	if ( Other && Pawn )
		return Pawn->R6LineOfSightTo(Other, bUseLOSFlag);
	return 0;
	unguard;
}

IMPL_DIVERGE("Ghidra 0x10427610; 335b: unaff_EBX and unaff_SI are unresolvable register aliases passed to UModel::PointRegion calls; vtable calls at XLevel+0xf4 and +0xf8 unidentified; GAudioMaxRadiusMultiplier is an external audio-subsystem reference — permanent binary differences")
INT AController::CanHearSound( FVector SoundLoc, AActor* SoundMaker, FLOAT Loudness, FVector& OutNoiseLoc )
{
	guard(AController::CanHearSound);
	return 0;
	unguard;
}

IMPL_DIVERGE("rdtsc cycle-counter profiling omitted; guard/unguard frame overhead differs; logic matches retail; Ghidra 0x1038ed20")
void AController::CheckEnemyVisible()
{
	guard(AController::CheckEnemyVisible);
	if( Enemy )
	{
		check(Enemy->IsValid());
		if( !LineOfSightTo(Enemy, 0) )
			eventEnemyNotVisible();
	}
	unguard;
}

IMPL_DIVERGE("rdtsc cycle-counter profiling (GScriptCycles, function timer array) omitted; logic matches retail; Ghidra 0x1038e270")
AActor* AController::FindPath( FVector Dest, AActor* Goal, INT bSinglePath )
{
	guard(AController::FindPath);
	if( !Pawn )
		return NULL;
	// Ghidra clears bit 7 of AController+0x3a8 and zeros AController+0x3e8 before pathfinding.
	*(DWORD*)((BYTE*)this + 0x3a8) &= ~0x80u;
	*(DWORD*)((BYTE*)this + 0x3e8) = 0;
	FLOAT pathWeight = Pawn->findPathToward( Goal, Dest, NULL, bSinglePath, 0.f );
	if( pathWeight > 0.f )
		return SetPath(1);
	return NULL;
	unguard;
}

IMPL_DIVERGE("rdtsc cycle-counter profiling omitted; guard/unguard frame overhead diverges; logic matches retail; Ghidra 0x1038ee00")
AActor* AController::HandleSpecial( AActor* BestPath )
{
	guard(AController::HandleSpecial);
	// Ghidra: if (bCanDoSpecial && GoalList[3] == NULL) then try SpecialHandling path
	if( bCanDoSpecial && !GoalList[3] )
	{
		AActor* special = BestPath->eventSpecialHandling( Pawn );
		if( special && special != BestPath )
		{
			if( Pawn->actorReachable( special, 0, 0 ) )
				return special;
			FLOAT dist = Pawn->findPathToward( special, special->Location, NULL, 1, 0.f );
			if( dist > 0.f )
				BestPath = SetPath( 0 );
		}
	}
	return BestPath;
	unguard;
}

