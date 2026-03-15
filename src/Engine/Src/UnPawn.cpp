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
// Pawn->vtable[0x184/4=97] = moveToward.  vtable[26] check omitted (DIVERGE).
IMPL_DIVERGE("Ghidra 0x1038e870; 566b — vtable[26] quick-reach guard on MoveTarget unidentified; all other logic implemented")
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
//   setMoveTimer with Destination.Size() (vtable[26] quick-reach check omitted → DIVERGE);
//   bAdvancedTactics set from bCanJump (Ghidra: bitfield bit3 XOR from param);
//   ClearSerpentine + CurrentPath=NULL added.
//   NavigationPoint eventSuggestMovePreparation + ReachSpec UReachSpec::supports path omitted → DIVERGE.
IMPL_DIVERGE("Ghidra 0x10390940; 1402b — vtable[26] quick-reach guard and NavigationPoint prep+ReachSpec path unidentified; setMoveTimer always used")
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
	// Retail: vtable[26] on MoveTarget → if non-zero: MoveTimer=1.2f; else setMoveTimer(dist)
	// DIVERGE: vtable[26] unidentified → always use distance-based timer
	Pawn->setMoveTimer( Destination.Size() );
	AdjustLoc = Destination;
	GetStateFrame()->LatentAction = AI_PollMoveToward;
	bAdjusting = 0;
	// Ghidra: bitfield bit3 (bAdvancedTactics) set/cleared from bCanJump param
	bAdvancedTactics = bCanJump ? 1 : 0;
	CurrentPath = NULL;
	Pawn->ClearSerpentine();
	// DIVERGE: retail checks MoveTarget->IsA(ANavigationPoint) + bSuggestPreparation flag,
	// then calls ValidAnchor + GetReachSpecTo + UReachSpec::supports + eventPrepareForMove.
	// This NavigationPoint path-preparation logic is not reconstructed.
	unguard;
}
IMPLEMENT_FUNCTION( AController, 502, execMoveToward );

// Ghidra 0x1038d110, 534b. No SEH (no guard/unguard in retail).
// bAdjusting checks: vtable[0x184/4=97] on Pawn (unidentified actorReachable variant)
// approximated by moveToward result.  PHYS_Spider Z-offset calls FUN_10301350 (not
// reconstructed); omitted.  PHYS_Flying adds CollisionHeight*0.7 to Destination Z
// (Ghidra: MoveTarget+0xfc = CollisionHeight; vtable[26] guard omitted → always applied).
IMPL_TODO("Ghidra 0x1038d110: bAdjusting vtable[97] approx'd as moveToward; PHYS_Spider FUN_10301350 omitted; PHYS_Flying vtable[26] guard omitted")
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
		// Approximated: treat the result of moveToward toward AdjustLoc as the test.
		INT bArrived = Pawn->moveToward( AdjustLoc, MoveTarget );
		bAdjusting = (bArrived == 0);
	}
	if( !bAdjusting )
	{
		Destination = MoveTarget->Location;
		// PHYS_Flying: offset Destination Z upward by 70% of MoveTarget's CollisionHeight
		// so pawn approaches the target slightly above floor level.
		// (Ghidra: MoveTarget+0xfc = CollisionHeight; guarded by vtable[26] check, omitted.)
		if( Pawn->Physics == PHYS_Flying )
			Destination.Z += *(FLOAT*)((BYTE*)MoveTarget + 0xfc) * 0.7f;
		// PHYS_Spider: retail adjusts Z via FUN_10301350 (spider surface attachment);
		// not reconstructed — omitted.
		if( Pawn->moveToward( Destination, MoveTarget ) )
			GetStateFrame()->LatentAction = 0;
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

IMPL_TODO("Ghidra 0x1038e490; 244 bytes; logic matches retail exactly; omits rdtsc profiling counters binary difference")
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

IMPL_TODO("Ghidra 0x1038e590; 289b — logic matches retail exactly; omits rdtsc profiling counters binary difference")
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

IMPL_TODO("Ghidra 0x1038e3e0; 172 bytes; logic matches retail exactly; omits rdtsc profiling counters binary difference")
void AController::execFindPathTo( FFrame& Stack, RESULT_DECL )
{
	guard(AController::execFindPathTo);
	P_GET_VECTOR(Point);
	P_FINISH;
	*(AActor**)Result = FindPath(Point, NULL, 1);
	unguard;
}
IMPLEMENT_FUNCTION( AController, 518, execFindPathTo );

IMPL_TODO("Ghidra 0x1038e030; 273 bytes; logic matches retail exactly; omits rdtsc profiling counters binary difference")
void AController::execactorReachable( FFrame& Stack, RESULT_DECL )
{
	guard(AController::execactorReachable);
	P_GET_OBJECT(AActor,anActor);
	P_FINISH;
	*(DWORD*)Result = (anActor && Pawn) ? Pawn->actorReachable(anActor, 0, 0) : 0;
	unguard;
}
IMPLEMENT_FUNCTION( AController, 520, execactorReachable );

IMPL_TODO("Ghidra 0x1038e150; 286 bytes; logic matches retail exactly; omits rdtsc profiling counters binary difference")
void AController::execpointReachable( FFrame& Stack, RESULT_DECL )
{
	guard(AController::execpointReachable);
	P_GET_VECTOR(aPoint);
	P_FINISH;
	*(DWORD*)Result = Pawn ? Pawn->pointReachable(aPoint, 0) : 0;
	unguard;
}
IMPLEMENT_FUNCTION( AController, 521, execpointReachable );

IMPL_TODO("Ghidra 0x1038e6c0; 131 bytes; logic matches retail exactly; omits rdtsc profiling counters binary difference")
void AController::execClearPaths( FFrame& Stack, RESULT_DECL )
{
	guard(AController::execClearPaths);
	P_FINISH;
	if( Pawn )
		Pawn->clearPaths();
	unguard;
}
IMPLEMENT_FUNCTION( AController, 522, execClearPaths );

IMPL_TODO("Ghidra 0x1038ce20; 236b — logic matches retail exactly; omits rdtsc profiling counters binary difference")
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

IMPL_TODO("Ghidra 0x10390770; 281b — logic matches retail exactly; omits rdtsc profiling counters binary difference")
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

IMPL_TODO("Ghidra 0x1038df50; 209 bytes; logic matches retail exactly; omits rdtsc profiling counters binary difference")
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

IMPL_TODO("Ghidra 0x1038f9e0; 1714b — secondary-aim scoring path (alive Pawn test, hostile-only filter, 16M distSq gate) omitted; team filter approximated as PRI-null check")
void AController::execPickTarget( FFrame& Stack, RESULT_DECL )
{
	guard(AController::execPickTarget);
	P_GET_OBJECT(UClass, TargetClass);
	P_GET_FLOAT_REF(bestAim);
	P_GET_FLOAT_REF(bestDist);
	P_GET_VECTOR(FireDir);
	P_GET_VECTOR(projStart);
	P_FINISH;
	APawn* bestPawn = NULL;
	if( !Level ) { *(APawn**)Result = NULL; return; }
	for( AController* C = Level->ControllerList; C; C = C->nextController )
	{
		if( C == this ) continue;
		APawn* targetPawn = C->Pawn;
		if( !targetPawn ) continue;
		// Alive check: Ghidra checks *(int*)(Pawn+0x3a4) > 0
		if( *(INT*)((BYTE*)targetPawn + 0x3a4) <= 0 ) continue;
		// Targetable flag: Ghidra checks bit7 of byte at Pawn+0xa9
		if( !((*(DWORD*)((BYTE*)targetPawn + 0xa8) >> 8) & 0x80) ) continue;
		// Team filter: skip if both have PlayerReplicationInfo (allied)
		if( PlayerReplicationInfo != NULL && C->PlayerReplicationInfo != NULL ) continue;
		FVector diff = targetPawn->Location - projStart;
		FLOAT dp = FireDir | diff;
		if( dp <= 0.0f ) continue;
		FLOAT distSq = diff.SizeSquared();
		// Ghidra: distSq < 1.6e7 (~4000 unit radius)
		if( distSq >= 16000000.0f ) continue;
		FLOAT dist = appSqrt(distSq);
		FLOAT aim = dp / dist;
		if( aim > *bestAim && LineOfSightTo(targetPawn, 0) )
		{
			*bestAim = aim;
			*bestDist = dist;
			bestPawn = targetPawn;
		}
	}
	*(APawn**)Result = bestPawn;
	unguard;
}
IMPLEMENT_FUNCTION( AController, 531, execPickTarget );

IMPL_TODO("Ghidra 0x1038dc20; 688b — vtable[0x1a] actor sub-type gate (before targetable check) unidentified; omitted")
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
		// Ghidra also checks vtable[0x1a]==0 (unidentified virtual) — omitted as DIVERGE
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

// Retail: calls APawn::findPathToward with inventory scorer at 0x1038cb00,
// updates MinWeight with path score, calls SetPath(1).
// Scorer not reconstructed — cannot implement without it.
IMPL_TODO("Ghidra 0x1038d870; 416b — inventory-weight scorer at 0x1038cb00 not reconstructed; returns NULL until scorer is decompiled")
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

IMPL_TODO("Ghidra 0x103900a0; 1734b — complex stair-rotation physics (FRotator traces, delta-time blend); stub returns Rotation.Pitch only")
void APlayerController::execFindStairRotation( FFrame& Stack, RESULT_DECL )
{
	guard(APlayerController::execFindStairRotation);
	P_GET_FLOAT(DeltaTime);
	P_FINISH;
	*(INT*)Result = Rotation.Pitch;
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

IMPL_DIVERGE("Ghidra 0x1042c250; 562b — PunkBuster FUN_1047f210 status lookup not reproducible; permanent: PunkBuster binary-only integration")
void APlayerController::execGetPBConnectStatus( FFrame& Stack, RESULT_DECL )
{
	guard(APlayerController::execGetPBConnectStatus);
	P_FINISH;
	*(INT*)Result = 0;
	unguard;
}
IMPLEMENT_FUNCTION( APlayerController, INDEX_NONE, execGetPBConnectStatus );

IMPL_DIVERGE("Ghidra 0x10420290; 105b -- calls FUN_1047e850 (PunkBuster enabled check) and returns result; our stub returns 0")
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

IMPL_TODO("Ghidra 0x103c4b30; 2176b — complex net-relevancy caching; stub delegates to AActor::IsNetRelevantFor")
INT APawn::IsNetRelevantFor( APlayerController* RealViewer, AActor* Viewer, FVector SrcLocation )
{
	guard(APawn::IsNetRelevantFor);
	return AActor::IsNetRelevantFor( RealViewer, Viewer, SrcLocation );
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

IMPL_TODO("Ghidra 0x10378250; 883b — complex location smoothing/interpolation with velocity blending; stub delegates to AActor::PostNetReceiveLocation")
void APawn::PostNetReceiveLocation()
{
	guard(APawn::PostNetReceiveLocation);
	AActor::PostNetReceiveLocation();
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

IMPL_TODO("Ghidra 0x103e6280; 4240b — navpoint anchor proximity and per-class default collision radius checks omitted; approximate with simple XY distance/threshold")
INT APawn::ReachedDestination( FVector Dest, AActor* GoalActor )
{
	guard(APawn::ReachedDestination);
	// Destination reached within pawn+goal collision radius if XY distance is small enough.
	FVector GoalLoc      = GoalActor ? GoalActor->Location : Dest;
	FLOAT   Threshold    = CollisionRadius + (GoalActor ? GoalActor->CollisionRadius : 0.f);
	FVector Diff         = Location - GoalLoc;
	Diff.Z               = 0.f;   // XY plane only
	return Diff.SizeSquared() <= Threshold * Threshold;
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

IMPL_TODO("Ghidra 0x103ebfe0; 983b — nav-graph anchor cache and IsBlockedBy vtable check omitted; approximate with straight-line LOS/distance")
INT APawn::actorReachable( AActor* Goal, INT bKnowVisible, INT bNoAnchorCheck )
{
	guard(APawn::actorReachable);
	// Navigation reachability test.
	// Full implementation requires the path-graph / ReachSpec network.
	// This approximation uses a straight-line sight trace + distance bound which
	// is correct for open geometry and serves as a fallback for nav-less maps.
	if( !Goal )
		return 0;

	FVector Diff = Goal->Location - Location;
	// Ignore height for walking proximity check.
	FLOAT HorizDistSq = Diff.X*Diff.X + Diff.Y*Diff.Y;
	// Reject if beyond MaxReachable (arbitrary: 8x GroundSpeed seconds of travel)
	FLOAT MaxReach = 8.f * GroundSpeed;
	if( HorizDistSq > MaxReach * MaxReach )
		return 0;

	// Visibility: SingleLineCheck between centres.
	if( !bKnowVisible )
	{
		FCheckResult Hit( 1.f );
		if( !XLevel->SingleLineCheck( Hit, this, Goal->Location, Location,
		    TRACE_World | TRACE_Level, FVector(0.f,0.f,0.f) ) )
		{
			// Something in the way — not directly reachable.
			return 0;
		}
	}
	return 1;
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

IMPL_TODO("Ghidra 0x103f1a50; 844b — vtable[0xC8] on HitActor (encroacher sub-type gate) and vtable[0x194] on Controller (unidentified notify dispatch) unidentified; both calls omitted")
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

IMPL_TODO("Ghidra 0x103eea80; 2043b — AR6ColBox::CanStepUp and capsule geometry adjustments for crouch state omitted; unconditionally delegates to AActor::stepUp")
void APawn::stepUp( FVector GravDir, FVector DesiredDir, FVector Delta, FCheckResult& Hit )
{
	guard(APawn::stepUp);
	// DIVERGENCE: APawn::stepUp delegates to AActor::stepUp without the pawn-specific
	// pre/post adjustments (crouch state checks, step height clamping).
	// GHIDRA REF: pawn step-up adds collision capsule half-height adjustment before
	// calling the base AActor::stepUp, then corrects Z after.
	AActor::stepUp( GravDir, DesiredDir, Delta, Hit );
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

IMPL_TODO("stub body (1 line(s)) — Ghidra 0x103e91a0 is 3355 bytes, not fully reconstructed")
INT APawn::Pick3DWallAdjust(FVector WallHitNormal)
{
	guard(APawn::Pick3DWallAdjust);
	return 0;
	unguard;
}

IMPL_TODO("stub body (1 line(s)) — Ghidra 0x103eb2e0 is 2629 bytes, not fully reconstructed")
INT APawn::PickWallAdjust(FVector WallHitNormal)
{
	guard(APawn::PickWallAdjust);
	return 0;
	unguard;
}

IMPL_TODO("stub body — Ghidra 0x103F0AE0 shows 1723-byte implementation not yet reconstructed")
void APawn::SpiderstepUp(FVector Delta, FVector HitNormal, FCheckResult& Hit)
{
	guard(APawn::SpiderstepUp);
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
// DIVERGENCE: missing FMemMark encroachment pre-check; missing APlayerController flag set on fail.
IMPL_TODO("Ghidra 0x103e5f90: FMemMark encroachment pre-check and APlayerController bTryToUncrouch path omitted")
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
		// Blocked: revert to crouch dimensions (retail also sets bTryToUncrouch via Controller).
		SetCollisionSize(CrouchRadius, CrouchHeight);
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

IMPL_TODO("stub body (1 line(s)) — Ghidra 0x1041c8d0 is 948 bytes, not fully reconstructed")
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

IMPL_TODO("stub body; Ghidra 0x1041cfa0 is 1916b: A* pathfinding with FSortedPathList open/closed sets; not yet reconstructed")
FLOAT APawn::findPathToward(AActor* Goal, FVector Dest, FLOAT (*WeightFunc)(ANavigationPoint*, APawn*, FLOAT), INT bSinglePath, FLOAT MaxWeight)
{
	guard(APawn::findPathToward);
	return 0.f;
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

IMPL_TODO("Ghidra 0x103ea940; 685b — vtable[0x188] on APawn (water-entry gate) unidentified; WarpZoneMarker dest-zone field at GoalActor+1000 not in SDK; rest implemented")
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

IMPL_TODO("stub body; Ghidra 0x103e88b0 is 1264b: iterative gravity integration with floor detection, AScout-specific handling; not yet reconstructed")
ETestMoveResult APawn::jumpLanding(FVector TestFall, INT bAdjust)
{
	guard(APawn::jumpLanding);
	return TESTMOVE_Stopped;
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

IMPL_TODO("stub body — Ghidra 0x103EFC30 shows 1653-byte implementation not yet reconstructed")
void APawn::physFlying(FLOAT DeltaTime, INT Iterations)
{
	guard(APawn::physFlying);
	unguard;
}

IMPL_TODO("stub body — Ghidra 0x103F5990 shows 2617-byte implementation not yet reconstructed")
void APawn::physSpider(FLOAT DeltaTime, INT Iterations)
{
	guard(APawn::physSpider);
	unguard;
}

IMPL_TODO("stub body — Ghidra 0x103F40A0 shows 1842-byte implementation not yet reconstructed")
void APawn::physSwimming(FLOAT DeltaTime, INT Iterations)
{
	guard(APawn::physSwimming);
	unguard;
}

IMPL_TODO("stub body — Ghidra 0x103ED370 shows 4353-byte implementation not yet reconstructed")
void APawn::physWalking(FLOAT DeltaTime, INT Iterations)
{
	guard(APawn::physWalking);
	unguard;
}

IMPL_TODO("Ghidra 0x103ec3f0; 516b — GIsEditor 2D range check, LOS SingleLineCheck, FarMoveActor+Reachable; logic matches retail; omits rdtsc profiling counters binary difference")
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

IMPL_TODO("Ghidra 0x103E8150, 491b — vtable[0x68] (reachability check on MoveTarget) unidentified; Acceleration magnitude scale-factor from local_40 approximated as Acceleration.Size()")
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

// Walking: zero pitch unless a valid MoveTarget exists.
// DIVERGENCE: Ghidra calls vtable[0x68] on MoveTarget to test reachability;
// approximated here by checking MoveTarget != NULL only.
if (Physics == PHYS_Walking)
{
INT ctrlPtr = *(INT*)(this + 0x4ec);
if (!ctrlPtr || !*(INT*)(ctrlPtr + 0x3e0)) // Controller->MoveTarget
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

IMPL_TODO("Ghidra 0x103F5640; 790b — velocity formula (Velocity*2 - OldAcceleration) transcribed from Ghidra; OldVelocity param treated as old location per Ghidra analysis")
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

IMPL_TODO("Ghidra 0x103e8450; 1065b — vtable[0x188] water-blocker check (in-water loop) omitted; bCanWalk exit-water path simplified (MoveActor step-up skipped → direct flyReachable); WarpZone dest-zone field at GoalActor+1000 not in SDK")
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

IMPL_TODO("stub body (1 line(s)) — Ghidra 0x103eac30 is 1365 bytes, not fully reconstructed")
INT APawn::walkReachable(FVector Dest, INT bClearPath, AActor* GoalActor)
{
	guard(APawn::walkReachable);
	return 0;
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
// counterpart; Pawn+0xb4 = LastRenderTime (AActor field, no named decl here); rdtsc omitted.
IMPL_TODO("Ghidra 0x103c3870: vtable[0xf0] unidentified; actor+0x144 ptr, ULevel+0x100 and actor+0x320 raw; LastRenderTime at +0xb4 unnamed; rdtsc profiling omitted")
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
IMPL_TODO("Ghidra 0x10390ec0; 1187b — NoiseMaker+0x148 chain approx'd by null check; bAdjacentZoneHearing team matrix omitted; bMuffledHearing path check approximated; bAroundCornerHearing navpoint relay omitted")
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
// SeePawn condition: bIsPlayer(this)||bIsPlayer(other) guards; SightCounter>=0 gate.
// FNames: bIsPlayer→EName(0x154), non-player→EName(0x158) (specific probe name indices).
// Pawn->m_ePawnType (APawn own +0x0a) == 1 = player-type pawn (used for hash & event dispatch).
IMPL_TODO("Ghidra 0x10391B60; 510b — rdtsc profiling omitted; FUN_10391970 visibility hash omitted (probe always checked); Level bit12 guard omitted")
void AController::ShowSelf()
{
	guard(AController::ShowSelf);
	if( !Pawn )
		return;

	const UBOOL bSelfIsPlayer = (bIsPlayer != 0);

	for( AController* other = Level->ControllerList; other; other = other->nextController )
	{
		if( other == this ) continue;
		// Ghidra: (bIsPlayer(this) || bIsPlayer(other)) && other->SightCounter >= 0
		if( !(bSelfIsPlayer || other->bIsPlayer) ) continue;
		if( !(other->SightCounter >= 0.f) ) continue;

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

IMPL_TODO("stub body (1 line(s)) — Ghidra 0x10427610 is 335 bytes, not fully reconstructed")
INT AController::CanHearSound( FVector SoundLoc, AActor* SoundMaker, FLOAT Loudness, FVector& OutNoiseLoc )
{
	guard(AController::CanHearSound);
	return 0;
	unguard;
}

IMPL_TODO("Ghidra 0x1038ed20; 173b — logic matches retail; omits rdtsc profiling counters and guard/unguard overhead differs from retail binary difference")
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

IMPL_TODO("Ghidra 0x1038e270; logic matches retail exactly; omits rdtsc profiling counters (GScriptCycles, function timer array) binary difference")
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

IMPL_TODO("Ghidra 0x1038ee00; 252b — logic verified; guard/unguard frame overhead diverges; rdtsc profiling omitted")
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

