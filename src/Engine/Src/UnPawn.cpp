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

IMPL_DIVERGE("Ghidra 0x1038e870; 566 bytes; simplified — retail sets raw timer at +0xdc=4.0f, adjusts walk-speed, and has complex Pawn null path")
void AController::execMoveTo( FFrame& Stack, RESULT_DECL )
{
	guard(AController::execMoveTo);
	P_GET_VECTOR(NewDestination);
	P_GET_OBJECT_OPTX(AActor,ViewFocus,NULL);
	P_GET_UBOOL_OPTX(bShouldWalk,0);
	P_FINISH;
	MoveTarget = NULL;
	Destination = NewDestination;
	Focus = ViewFocus;
	GetStateFrame()->LatentAction = AI_PollMoveTo;
	unguard;
}
IMPLEMENT_FUNCTION( AController, 500, execMoveTo );

IMPL_DIVERGE("Ghidra 0x1038cfe0; 163 bytes; retail has no guard/unguard; uses MoveTimer at +0x3bc, bAdjusting bit, and Pawn->moveToward vtable dispatch")
void AController::execPollMoveTo( FFrame& Stack, RESULT_DECL )
{
	guard(AController::execPollMoveTo);
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
	unguard;
}
IMPLEMENT_FUNCTION( AController, INDEX_NONE, execPollMoveTo );

IMPL_DIVERGE("Ghidra 0x10390940; 1402 bytes; simplified — retail has complex bShouldWalk/MoveTimer/ReachSpec path-following logic")
void AController::execMoveToward( FFrame& Stack, RESULT_DECL )
{
	guard(AController::execMoveToward);
	P_GET_OBJECT(AActor,NewTarget);
	P_GET_OBJECT_OPTX(AActor,ViewFocus,NULL);
	P_GET_UBOOL_OPTX(bShouldWalk,0);
	P_FINISH;
	MoveTarget = NewTarget;
	if( MoveTarget )
		Destination = MoveTarget->Location;
	Focus = ViewFocus;
	GetStateFrame()->LatentAction = AI_PollMoveToward;
	unguard;
}
IMPLEMENT_FUNCTION( AController, 502, execMoveToward );

IMPL_DIVERGE("Ghidra 0x1038d110; 534 bytes; retail has no guard/unguard; uses MoveTimer at +0x3bc, bAdjusting/bPreparingMove bits, Pawn->moveToward vtable, and NavPoint arrival path; PHYS_Climbing/Spider adjustments omitted")
void AController::execPollMoveToward( FFrame& Stack, RESULT_DECL )
{
	guard(AController::execPollMoveToward);
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
		INT bArrived = Pawn->moveToward( AdjustLoc, MoveTarget );
		bAdjusting = (bArrived == 0);
	}
	if( !bAdjusting )
	{
		Destination = MoveTarget->Location;
		if( Pawn->moveToward( Destination, MoveTarget ) )
			GetStateFrame()->LatentAction = 0;
	}
	unguard;
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

IMPL_DIVERGE("Ghidra 0x1038eab0; 112 bytes; logic matches Ghidra exactly; guard/unguard frame overhead diverges")
void AController::execPollFinishRotation( FFrame& Stack, RESULT_DECL )
{
	guard(AController::execPollFinishRotation);
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
	unguard;
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

IMPL_DIVERGE("Ghidra 0x1038dee0; 104b -- logic correct; retail uses ESI-based frame, MSVC 2019 generates EBP+SEH preamble")
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

IMPL_DIVERGE("Ghidra 0x1038e490; 244 bytes; omits rdtsc profiling; default bSinglePath=1 per Ghidra")
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

IMPL_DIVERGE("Ghidra 0x1038e590; 289b — iterates NavigationPointList for exact class match, marks nav+0x3e4 bit0, calls FindPath; omits rdtsc")
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

IMPL_DIVERGE("Ghidra 0x1038e3e0; 172 bytes; omits rdtsc profiling; bSinglePath hardcoded 1 in retail")
void AController::execFindPathTo( FFrame& Stack, RESULT_DECL )
{
	guard(AController::execFindPathTo);
	P_GET_VECTOR(Point);
	P_FINISH;
	*(AActor**)Result = FindPath(Point, NULL, 1);
	unguard;
}
IMPLEMENT_FUNCTION( AController, 518, execFindPathTo );

IMPL_DIVERGE("Ghidra 0x1038e030; 273 bytes; omits rdtsc profiling; falls through to error-log if anActor/Pawn null")
void AController::execactorReachable( FFrame& Stack, RESULT_DECL )
{
	guard(AController::execactorReachable);
	P_GET_OBJECT(AActor,anActor);
	P_FINISH;
	*(DWORD*)Result = (anActor && Pawn) ? Pawn->actorReachable(anActor, 0, 0) : 0;
	unguard;
}
IMPLEMENT_FUNCTION( AController, 520, execactorReachable );

IMPL_DIVERGE("Ghidra 0x1038e150; 286 bytes; omits rdtsc profiling; logs error if Pawn null")
void AController::execpointReachable( FFrame& Stack, RESULT_DECL )
{
	guard(AController::execpointReachable);
	P_GET_VECTOR(aPoint);
	P_FINISH;
	*(DWORD*)Result = Pawn ? Pawn->pointReachable(aPoint, 0) : 0;
	unguard;
}
IMPLEMENT_FUNCTION( AController, 521, execpointReachable );

IMPL_DIVERGE("Ghidra 0x1038e6c0; 131 bytes; omits rdtsc profiling counters around clearPaths call")
void AController::execClearPaths( FFrame& Stack, RESULT_DECL )
{
	guard(AController::execClearPaths);
	P_FINISH;
	if( Pawn )
		Pawn->clearPaths();
	unguard;
}
IMPLEMENT_FUNCTION( AController, 522, execClearPaths );

IMPL_DIVERGE("Ghidra 0x1038ce20; 236b — reads BaseZ/XYSpeed, calls Pawn->SuggestJumpVelocity with dest from this+0x480 (AController FVector field); omits rdtsc")
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

IMPL_DIVERGE("Ghidra 0x10390770; 281b — clearPaths if bClearPaths, findPathToward(NULL,FVector0), returns navpoint at this+0x44c if nav; omits rdtsc")
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

IMPL_DIVERGE("Ghidra 0x1038df50; 209 bytes; omits rdtsc profiling; result unset if Pawn null in retail")
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

IMPL_DIVERGE("Ghidra 0x1038f9e0; 1714b — iterates Level->ControllerList, scores enemy pawns by FireDir angle and dist; alive check at Pawn+0x3a4; targetable flag at Pawn+0xa9 bit7; team filter via PlayerReplicationInfo; secondary-aim scoring path omitted")
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

IMPL_DIVERGE("Ghidra 0x1038dc20; 688b — iterates XLevel->Actors, scores by FireDir dot/dist; checks bit7 of actor+0xa9 (targetable flag); vtable[0x1a] check omitted as DIVERGE; dist < 2000 units (distSq < 4e6)")
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

IMPL_DIVERGE("Ghidra 0x1038d870; 416b — calls findPathToward with inventory scorer at 0x1038cb00, updates MinWeight with path score, calls SetPath(1); DIVERGE: scorer not reconstructed; returns NULL until scorer is decompiled")
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

IMPL_DIVERGE("Ghidra 0x10390890; retail has no guard; checks LatentAction==AI_PollMoveToward+ALadder overlap to set Pawn->Anchor; guard diverges")
void AController::execEndClimbLadder( FFrame& Stack, RESULT_DECL )
{
	guard(AController::execEndClimbLadder);
	P_FINISH;
	if( GetStateFrame()->LatentAction == AI_PollMoveToward && Pawn && MoveTarget )
	{
		if( MoveTarget->IsA( ALadder::StaticClass() ) )
		{
			if( Pawn->IsOverlapping( MoveTarget, NULL ) )
			{
				// FUN_1038ef90: returns MoveTarget as ANavigationPoint* if IsA, else NULL
				if( MoveTarget->IsA( ANavigationPoint::StaticClass() ) )
					Pawn->Anchor = (ANavigationPoint*)MoveTarget;
				else
					Pawn->Anchor = NULL;
			}
			GetStateFrame()->LatentAction = 0;
		}
	}
	unguard;
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

IMPL_DIVERGE("Ghidra 0x103900a0; 1734b -- complex stair-rotation physics calculation (APawn::eventEyePosition, FRotator traces, delta-time blending); our stub only returns Rotation.Pitch")
void APlayerController::execFindStairRotation( FFrame& Stack, RESULT_DECL )
{
	guard(APlayerController::execFindStairRotation);
	P_GET_FLOAT(DeltaTime);
	P_FINISH;
	*(INT*)Result = Rotation.Pitch;
	unguard;
}
IMPLEMENT_FUNCTION( APlayerController, 524, execFindStairRotation );

IMPL_DIVERGE("Ghidra 0x1038f400; 228b -- gets viewport at +0x5b4, resets keyboard (this_00+0x84) and mouse (this_00+0x88) input configs via UObject::ResetConfig+SaveConfig; our stub is empty")
void APlayerController::execResetKeyboard( FFrame& Stack, RESULT_DECL )
{
	guard(APlayerController::execResetKeyboard);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( APlayerController, 544, execResetKeyboard );

IMPL_DIVERGE("Ghidra 0x1038eff0; 372b -- reads 3 params (FString NewOption, FString NewValue, UBOOL bSaveDefault), calls FURL::AddOption on level URL, conditionally calls FURL::SaveURLConfig; our stub reads params but does nothing")
void APlayerController::execUpdateURL( FFrame& Stack, RESULT_DECL )
{
	guard(APlayerController::execUpdateURL);
	P_GET_STR(NewOption);
	P_GET_STR(NewValue);
	P_GET_UBOOL(bSaveDefault);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( APlayerController, 546, execUpdateURL );

IMPL_DIVERGE("Ghidra 0x1038da50; 299b -- routes through player Exec vtable (+0x30) or level engine Exec vtable (+0x2c) and captures output to result FString; our stub diverges in routing and output capture")
void APlayerController::execConsoleCommand( FFrame& Stack, RESULT_DECL )
{
	guard(APlayerController::execConsoleCommand);
	P_GET_STR(Command);
	P_FINISH;
	// UPlayer* is stored in _NativeData[50] (offset 0x5B4, set by SetPlayer).
	UPlayer* P = *(UPlayer**)(&_NativeData[50]);
	if( P )
		P->Exec( *Command, *GLog );
	*(FString*)Result = TEXT("");
	unguard;
}
IMPLEMENT_FUNCTION( APlayerController, INDEX_NONE, execConsoleCommand );

IMPL_DIVERGE("Ghidra 0x103919e0; 330b -- loads DefaultPlayer URL config, calls FURL::GetOption with the option name, returns the value string; our stub returns empty")
void APlayerController::execGetDefaultURL( FFrame& Stack, RESULT_DECL )
{
	guard(APlayerController::execGetDefaultURL);
	P_GET_STR(Option);
	P_FINISH;
	*(FString*)Result = TEXT("");
	unguard;
}
IMPLEMENT_FUNCTION( APlayerController, INDEX_NONE, execGetDefaultURL );

IMPL_DIVERGE("Ghidra 0x1038f1a0; 263b -- asserts XLevel/Engine/GEntry chain then calls ULevel::GetLevelInfo on GEntry; our stub returns NULL")
void APlayerController::execGetEntryLevel( FFrame& Stack, RESULT_DECL )
{
	guard(APlayerController::execGetEntryLevel);
	P_FINISH;
	*(ULevelBase**)Result = NULL;
	unguard;
}
IMPLEMENT_FUNCTION( APlayerController, INDEX_NONE, execGetEntryLevel );

IMPL_DIVERGE("Ghidra 0x1038f2e0; 226b -- sets +0x5b8, calls vtable at +0x18c (UpdateURL), then if viewport canvas has bFading calls UCanvas::StartFade; our stub only sets the view target")
void APlayerController::execSetViewTarget( FFrame& Stack, RESULT_DECL )
{
	guard(APlayerController::execSetViewTarget);
	P_GET_OBJECT(AActor,NewViewTarget);
	P_FINISH;
	// ViewTarget stored at _NativeData[51] (offset 0x5B8), matching GetViewTarget() in EngineStubs.cpp.
	*(AActor**)(&_NativeData[51]) = NewViewTarget;
	unguard;
}
IMPLEMENT_FUNCTION( APlayerController, INDEX_NONE, execSetViewTarget );

IMPL_DIVERGE("Ghidra 0x10425910; 292b -- if player connected: fires PreClientTravel event via FindFunctionChecked, then calls engine ClientTravel vtable (+0xa4) with URL/type/items; our stub is empty")
void APlayerController::execClientTravel( FFrame& Stack, RESULT_DECL )
{
	guard(APlayerController::execClientTravel);
	P_GET_STR(URL);
	P_GET_BYTE(TravelType);
	P_GET_UBOOL(bItems);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( APlayerController, INDEX_NONE, execClientTravel );

IMPL_DIVERGE("Ghidra 0x10425c90; 259b -- if local player and audio system exists, forwards to audio system vtable (+0x84) with Actor, Sound, Location flags; our stub is empty")
void APlayerController::execClientHearSound( FFrame& Stack, RESULT_DECL )
{
	guard(APlayerController::execClientHearSound);
	P_GET_OBJECT(AActor,Actor);
	P_GET_INT(Id);
	P_GET_OBJECT(USound,S);
	P_GET_VECTOR(SoundLocation);
	P_GET_INT(Flags);
	P_FINISH;
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

IMPL_DIVERGE("Ghidra 0x10420760; 190b -- Ghidra shows one FString param read before P_FINISH (discarded, never used); our stub omits that param read; appClipboardPaste()+result assignment matches")
void APlayerController::execPasteFromClipboard( FFrame& Stack, RESULT_DECL )
{
	guard(APlayerController::execPasteFromClipboard);
	P_FINISH;
	*(FString*)Result = appClipboardPaste();
	unguard;
}
IMPLEMENT_FUNCTION( APlayerController, INDEX_NONE, execPasteFromClipboard );

IMPL_DIVERGE("Ghidra 0x10420230; 88b — marks UNetConnection bPendingDestroy when player is about to be destroyed")
void APlayerController::execSpecialDestroy( FFrame& Stack, RESULT_DECL )
{
	guard(APlayerController::execSpecialDestroy);
	P_FINISH;
	// If the player is a net connection, signal it for destruction.
	UPlayer* P = *(UPlayer**)(&_NativeData[50]);  // this+0x5b4
	if( P && P->IsA(UNetConnection::StaticClass()) )
	{
		if( *(INT*)((BYTE*)P + 0x7c) )  // UNetConnection: pending close flag
			*(INT*)((BYTE*)P + 0x80) = 1;  // UNetConnection: bPendingDestroy
	}
	unguard;
}
IMPLEMENT_FUNCTION( APlayerController, INDEX_NONE, execSpecialDestroy );

IMPL_DIVERGE("Ghidra 0x1038cc50; 59b -- Ghidra calls USkeletalMesh::RenderPreProcess on a register-spilled value (Ghidra register-tracking confused); our stub unconditionally returns 1")
void APlayerController::execPB_CanPlayerSpawn( FFrame& Stack, RESULT_DECL )
{
	guard(APlayerController::execPB_CanPlayerSpawn);
	P_FINISH;
	*(DWORD*)Result = 1;
	unguard;
}
IMPLEMENT_FUNCTION( APlayerController, 1320, execPB_CanPlayerSpawn );

IMPL_DIVERGE("Ghidra 0x1042c250; 562b -- queries GetPlayerNetworkAddress or eventGetLocalPlayerIp, calls FUN_1047f210 (PB status lookup) with IP+port+player-name; our stub returns 0")
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

IMPL_DIVERGE("Ghidra 0x1038f520; 299b -- reads FString(KeyName)+INT(device) params and returns UBOOL byte via viewport vtable (+0x88); our stub reads INT and returns FString")
void APlayerController::execGetKey( FFrame& Stack, RESULT_DECL )
{
	guard(APlayerController::execGetKey);
	P_GET_INT(KeyNum);
	P_FINISH;
	*(FString*)Result = TEXT("");
	unguard;
}
IMPLEMENT_FUNCTION( APlayerController, 2706, execGetKey );

IMPL_DIVERGE("Ghidra 0x1038f7a0; 288b -- reads BYTE(device)+INT(action) params and returns FString via viewport vtable (+0x90); our stub reads FString param and returns empty")
void APlayerController::execGetActionKey( FFrame& Stack, RESULT_DECL )
{
	guard(APlayerController::execGetActionKey);
	P_GET_STR(ActionName);
	P_FINISH;
	*(FString*)Result = TEXT("");
	unguard;
}
IMPLEMENT_FUNCTION( APlayerController, 2707, execGetActionKey );

IMPL_DIVERGE("Ghidra 0x1038f680; 231b -- reads BYTE(key)+INT(device) params and returns enum key-name string via viewport vtable (+0x80); falls back to L\"IK_None\"; our stub reads INT and returns empty")
void APlayerController::execGetEnumName( FFrame& Stack, RESULT_DECL )
{
	guard(APlayerController::execGetEnumName);
	P_GET_INT(EnumIndex);
	P_FINISH;
	*(FString*)Result = TEXT("");
	unguard;
}
IMPLEMENT_FUNCTION( APlayerController, 2708, execGetEnumName );

IMPL_DIVERGE("Ghidra 0x1038f900; 168b — forwards InputSet to UViewport::ChangeInputSet if player is a viewport")
void APlayerController::execChangeInputSet( FFrame& Stack, RESULT_DECL )
{
	guard(APlayerController::execChangeInputSet);
	P_GET_INT(InputSet);
	P_FINISH;
	// Forward the input-set change to the viewport if this is a local player.
	UPlayer* P = *(UPlayer**)(&_NativeData[50]);  // this+0x5b4
	if( P && P->IsA(UViewport::StaticClass()) )
		((UViewport*)P)->ChangeInputSet( (BYTE)InputSet );
	unguard;
}
IMPLEMENT_FUNCTION( APlayerController, 2709, execChangeInputSet );

IMPL_DIVERGE("Ghidra 0x10391770; 451b -- reads FString param, ParseCommand dispatches to INPUT vtable (+0x8c) / INPUTPLANNING vtable (+0x8c) / R6GAMEOPTIONS GlobalSetProperty; our stub is empty")
void APlayerController::execSetKey( FFrame& Stack, RESULT_DECL )
{
	guard(APlayerController::execSetKey);
	P_GET_INT(KeyNum);
	P_GET_STR(KeyName);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( APlayerController, 2710, execSetKey );

IMPL_DIVERGE("Ghidra 0x1038cb30; 102b -- reads no params (P_FINISH only), then if audio system exists calls audio vtable (+0x88) with arg 0; our stub reads INT Provider and does nothing")
void APlayerController::execSetSoundOptions( FFrame& Stack, RESULT_DECL )
{
	guard(APlayerController::execSetSoundOptions);
	P_GET_INT(Provider);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( APlayerController, 2713, execSetSoundOptions );

IMPL_DIVERGE("Ghidra 0x1038cba0; 172b -- param reads match (BYTE VolumeType + INT NewVolume), but then calls FUN_1050557c to convert volume and dispatches to audio vtable (+0xa8); our stub reads params and does nothing")
void APlayerController::execChangeVolumeTypeLinear( FFrame& Stack, RESULT_DECL )
{
	guard(APlayerController::execChangeVolumeTypeLinear);
	P_GET_BYTE(VolumeType);
	P_GET_INT(NewVolume);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( APlayerController, 2714, execChangeVolumeTypeLinear );

/*-- AAIController functions -------------------------------------------*/

IMPL_DIVERGE("Ghidra 0x1038cf10; 203b; retail reads 3 optional params (FVector, UBOOL, FLOAT=1.0f) then sets Focus=Enemy; params read but unused; guard/unguard diverge")
void AAIController::execWaitToSeeEnemy( FFrame& Stack, RESULT_DECL )
{
	guard(AAIController::execWaitToSeeEnemy);
	// Retail reads 3 optional params before P_FINISH; they are consumed but unused.
	// Omitting reads here; P_FINISH handles the case where params are not provided.
	P_FINISH;
	if( Pawn && Enemy )
	{
		Focus = Enemy;
		GetStateFrame()->LatentAction = AI_PollWaitToSeeEnemy;
	}
	unguard;
}
IMPLEMENT_FUNCTION( AAIController, INDEX_NONE, execWaitToSeeEnemy );

IMPL_DIVERGE("Ghidra 0x1038e7c0; 163b; logic matches Ghidra exactly (time+rotation checks); guard/unguard frame diverges")
void AAIController::execPollWaitToSeeEnemy( FFrame& Stack, RESULT_DECL )
{
	guard(AAIController::execPollWaitToSeeEnemy);
	if( Pawn && Enemy )
	{
		// Wait until Level->TimeSeconds is at most 0.1s ahead of LastSeenTime
		if( Level->TimeSeconds - LastSeenTime > 0.1f )
			return;
		// Check if pawn has finished rotating toward enemy (same logic as PollFinishRotation)
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
	unguard;
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

IMPL_DIVERGE("Ghidra 0x103e55b0: checks (byte)(this+0x3a2) < 2; m_eHealth enum where 0-1=alive, 2+=dead")
INT APawn::IsAlive()
{
	return m_eHealth < 2;
}

IMPL_DIVERGE("Ghidra 0x103ecae0; 77b — retail NaN-safe equality check: enters body only when CollisionHeight==CrouchHeight (+0x454), then confirms < default->CollisionHeight and m_ePeekingMode (+0x39c) != 2")
INT APawn::IsCrouched()
{
	// Outer check: only consider crouched if currently at exactly CrouchHeight
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

IMPL_DIVERGE("Ghidra 0x103e5600: 34b — correct logic; retail uses direct &PrivateStaticClass ref instead of StaticClass() call")
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

IMPL_DIVERGE("Ghidra 0x103e5000: 35 bytes; parity fails — retail uses no stack frame (ECX-based thiscall, no push ebp), our compiler generates a standard prologue")
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

IMPL_DIVERGE("Ghidra 0x103e5260: 29 bytes; parity fails — retail uses no stack frame (ECX thiscall, integer regs for FVector), our compiler uses SSE2 movq")
void APawn::SetPrePivot( FVector NewPrePivot )
{
	PrePivot = NewPrePivot;
}


/*-----------------------------------------------------------------------------
	APawn method implementations -- batch from .bak reference + stubs.
	Reconstructed from Ghidra decompilation.
-----------------------------------------------------------------------------*/

IMPL_DIVERGE("Ghidra 0x103982c0; after AActor::CheckForErrors retail walks Controller->Scripts array looking for AAIScript whose FName matches this->ScriptTag and returns early if found; our stub omits that validation loop")
void APawn::CheckForErrors()
{
	guard(APawn::CheckForErrors);
	AActor::CheckForErrors();
	unguard;
}

IMPL_DIVERGE("Ghidra catch-only at 0x103ecab6; full body not exported; returns Delta as stub")
FVector APawn::CheckForLedges( AActor* HitActor, FVector Loc, FVector Delta, FVector GravDir, INT& bShouldJump, INT& bCheckedFall, FLOAT DeltaTime )
{
	guard(APawn::CheckForLedges);
	return Delta;
	unguard;
}

IMPL_DIVERGE("Ghidra 0x103ea860; retail walks Controller->PawnList array removing self, then frees object at this+0x3d8 via GMalloc if non-null, then calls AActor::Destroy; our stub nulls Controller->Pawn instead which is wrong")
void APawn::Destroy()
{
	guard(APawn::Destroy);
	if( Controller )
		Controller->Pawn = NULL;
	AActor::Destroy();
	unguard;
}

IMPL_DIVERGE("Ghidra catch at 0x103ec90b is for AActor::FindSlopeRotation; APawn override not found; delegates to AActor")
FRotator APawn::FindSlopeRotation( FVector FloorNormal, FRotator NewRotation )
{
	guard(APawn::FindSlopeRotation);
	return AActor::FindSlopeRotation( FloorNormal, NewRotation );
	unguard;
}

IMPL_DIVERGE("Ghidra 0x103e50c0; retail checks Controller->bIsPlayer, Sent non-null, and several flag/team conditions then computes a vector-distance-based priority; our stub only multiplies NetPriority*(Time+2) for players which misses the full formula")
FLOAT APawn::GetNetPriority( AActor* Sent, FLOAT Time, FLOAT Lag )
{
	guard(APawn::GetNetPriority);
	if( Controller && Controller->bIsPlayer )
		return NetPriority * (Time + 2.0f);
	return AActor::GetNetPriority( Sent, Time, Lag );
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

IMPL_DIVERGE("Ghidra 0x103c4b30; 2176b complex function: checks cached relevancy by TimeSeconds==LastRenderTime, owner/team/audio-radius early-outs, FastLineCheck visibility, then CacheNetRelevancy; our stub delegates to base")
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
	// If Other has a m_CurrentVolumeSound actor and that actor has an AntiPortal,
	// redirect the bump to the volume sound actor (R6 sound zone collision redirect).
	AActor* bump_actor = Other->m_CurrentVolumeSound;
	if( bump_actor && bump_actor->AntiPortal )
		Other = bump_actor;
	if( Controller && Controller->eventNotifyBump( Other ) != 0 )
		return;
	AActor::eventBump( Other );
	unguard;
}

IMPL_DIVERGE("Ghidra 0x103e5280; retail calls AKConstraint::postKarmaStep then conditionally allocates a karma object (0x24 bytes) at this+0x3d8; does NOT call AActor::PostBeginPlay; our stub calls the wrong base and skips karma setup")
void APawn::PostBeginPlay()
{
	guard(APawn::PostBeginPlay);
	AActor::PostBeginPlay();
	unguard;
}

IMPL_DIVERGE("Ghidra 0x1037d840; 501b: copies cached location/rotation/scale fields from pre-net globals, fires script events PostBeginPlay/ReceivedEngineWeapon/ReceivedWeapons when replicated fields change; our stub just calls AActor::PostNetReceive")
void APawn::PostNetReceive()
{
	guard(APawn::PostNetReceive);
	AActor::PostNetReceive();
	unguard;
}

IMPL_DIVERGE("Ghidra 0x10378250; 883b: complex location smoothing/interpolation — saves pre-receive location, then if Physics==PHYS_Walking blends toward replicated position with velocity; our stub just calls AActor::PostNetReceiveLocation")
void APawn::PostNetReceiveLocation()
{
	guard(APawn::PostNetReceiveLocation);
	AActor::PostNetReceiveLocation();
	unguard;
}

IMPL_DIVERGE("Ghidra 0x10377ff0; 210b: saves 9 replicated pawn fields (location/rotation/scale at this+0x63c, EngineWeapon, weapon list, bIsWalking, etc.) to static globals before calling AActor::PreNetReceive; our stub skips the save step")
void APawn::PreNetReceive()
{
	guard(APawn::PreNetReceive);
	AActor::PreNetReceive();
	unguard;
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

IMPL_DIVERGE("Wrong address in claim (0x103c35b0 not in Ghidra); actual ReachedDestination is 0x103e6280 (4240); retail checks NavPoint anchor proximity and per-class default collision radius, not a simple Threshold*Threshold XY check")
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

IMPL_DIVERGE("Ghidra 0x1037c590; 140b — logic matches: skip if m_bIsProne+IsEncroacher, save Floor, delegate; guard/unguard frame diverges")
void APawn::SetBase( AActor* NewBase, FVector NewFloor, INT bNotifyActor )
{
	guard(APawn::SetBase);
	// Retail: if prone and new base is an Encroacher (mover/kactor), skip base change
	if( m_bIsProne && NewBase && NewBase->IsEncroacher() )
		return;
	// Save floor vector before delegating (Ghidra: this+0x590 = Floor)
	Floor = NewFloor;
	AActor::SetBase( NewBase, NewFloor, bNotifyActor );
	unguard;
}

IMPL_DIVERGE("Ghidra 0x103bd4a0; 573b: calls UModel::PointRegion to compute new Zone, fires eventActorLeaving/eventActorEntered on zone transitions, also calls GetPhysicsVolume for body and eye positions; our stub only calls AActor::SetZone")
void APawn::SetZone( INT bTest, INT bForceRefresh )
{
	guard(APawn::SetZone);
	AActor::SetZone( bTest, bForceRefresh );
	unguard;
}

IMPL_DIVERGE("Ghidra 0x103e5630; 204b: checks TRACE_ShadowCast (0x80000) flag → queries GModMgr->IsMissionPack() and returns 0 for team/mission conditions; also checks bHidden, IsEncroacher, TRACE_ProjectActors, TRACE_Pawns; our stub just delegates to base")
INT APawn::ShouldTrace( AActor* SourceActor, DWORD TraceFlags )
{
	guard(APawn::ShouldTrace);
	return AActor::ShouldTrace( SourceActor, TraceFlags );
	unguard;
}

IMPL_DIVERGE("AActor::SmoothHitWall at 0x103f15c0 (38b); APawn override not separately exported; delegates to processHitWall")
void APawn::SmoothHitWall( FVector HitNormal, AActor* HitActor )
{
	guard(APawn::SmoothHitWall);
	processHitWall( HitNormal, HitActor );
	unguard;
}

IMPL_DIVERGE("Ghidra 0x103c36c0; 145b — main path verified: Acceleration=SafeNormal(Velocity)+moveSmooth+eventTick; bInterpolating vtable+0x120 branch unknown; guard/unguard diverges")
void APawn::TickSimulated( FLOAT DeltaTime )
{
	guard(APawn::TickSimulated);
	// Cache movement direction into Acceleration (Ghidra: this+0x258 = Acceleration)
	Acceleration = Velocity.SafeNormal();
	if( bInterpolating )
	{
		// Retail calls vtable+0x120 with DeltaTime here; function not identified
		// Fall back to AActor path to avoid moveSmooth on an interpolating pawn
		AActor::TickSimulated( DeltaTime );
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

IMPL_DIVERGE("body incomplete — Ghidra 0x103E9FF0 not yet fully reconstructed")
void APawn::UpdateMovementAnimation( FLOAT DeltaSeconds )
{
	guard(APawn::UpdateMovementAnimation);
	// TODO: implement APawn::UpdateMovementAnimation (retail: reads Velocity magnitude and Physics state to select animation blend weights)
	// GHIDRA REF: reads Velocity magnitude and Physics state to select animation
	// blend weights. Requires animation blend tree integration not yet reconstructed.
	unguard;
}

IMPL_DIVERGE("Ghidra 0x103ebfe0; 983b: full nav-graph reachability — checks NavigationPoint anchor cache for shortcut, enforces 1200 UU distance limit (not 8*GroundSpeed), checks IsBlockedBy via vtable, tests water/physics, uses eventEyePosition for LOS trace; our stub is approximate")
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

IMPL_DIVERGE("Ghidra 0x103f1a50: 844b — begins with null-check on HitActor, then performs dot-product focus check, CanCrouchWalk eval, wall-slide MoveActor adjustments; our stub only fires eventNotifyHitWall")
void APawn::processHitWall( FVector HitNormal, AActor* HitActor )
{
	guard(APawn::processHitWall);
	if( Controller )
		Controller->eventNotifyHitWall( HitNormal, HitActor );
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

IMPL_DIVERGE("Ghidra 0x103eea80: 2043b — checks AR6ColBox::CanStepUp, adjusts capsule geometry for crouch state before and after calling base stepUp; our stub unconditionally delegates to AActor::stepUp")
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

IMPL_DIVERGE("Ghidra 0x103ef850; raw offsets: CrouchHeight=+0x454, CrouchRadius=+0x458, pawnFlags=+0x3e0, stepFrac=+0x424")
INT APawn::CanCrouchWalk(FVector const& TestLocation, FVector const& FeetLocation)
{
	guard(APawn::CanCrouchWalk);
	// Height delta: CrouchHeight - CollisionHeight (how much to lower Z)
	FLOAT hDelta = *(FLOAT*)((BYTE*)this + 0x454) - CollisionHeight;
	// First trace: zero-extent line at crouch height level
	FVector Start(TestLocation.X, TestLocation.Y, hDelta + TestLocation.Z);
	FVector End(FeetLocation.X,   FeetLocation.Y,  hDelta + FeetLocation.Z);
	FCheckResult Hit(1.0f);
	XLevel->SingleLineCheck(Hit, this, End, Start, 0x286, FVector(0.f,0.f,0.f));
	if (!Hit.Actor)
	{
		FLOAT crouchH = *(FLOAT*)((BYTE*)this + 0x454);  // CrouchHeight
		FLOAT crouchR = *(FLOAT*)((BYTE*)this + 0x458);  // CrouchRadius
		// Second trace: cylinder-extent check at crouch height
		FVector Start2(FeetLocation.X, FeetLocation.Y, hDelta + FeetLocation.Z);
		FVector End2(TestLocation.X,   TestLocation.Y,  hDelta + TestLocation.Z);
		FCheckResult Hit2(1.0f);
		XLevel->SingleLineCheck(Hit2, this, End2, Start2, 0x86, FVector(crouchR, crouchR, crouchH));
		if (Hit2.Time == 1.0f)
		{
			*(DWORD*)((BYTE*)this + 0x3e0) |= 0x50u;   // set bits 4 and 6
			*(FLOAT*)((BYTE*)this + 0x424) = 0.5f;     // step fraction
			return 1;
		}
	}
	return 0;
	unguard;
}

IMPL_DIVERGE("Ghidra 0x103efa30; raw offsets: ProneHeight=+0x464, ProneRadius=+0x468, pawnFlags=+0x3e0, stepFrac=+0x424")
INT APawn::CanProneWalk(FVector const& TestLocation, FVector const& FeetLocation)
{
	guard(APawn::CanProneWalk);
	// Bit 11 of pawn flags must be set (bCanProne capability flag)
	if (!(*(DWORD*)((BYTE*)this + 0x3e0) & 0x800u))
		return 0;
	FLOAT hDelta = *(FLOAT*)((BYTE*)this + 0x464) - CollisionHeight;  // ProneHeight - CollisionHeight
	// First trace: zero-extent line at prone height level
	FVector Start(TestLocation.X, TestLocation.Y, hDelta + TestLocation.Z);
	FVector End(FeetLocation.X,   FeetLocation.Y,  hDelta + FeetLocation.Z);
	FCheckResult Hit(1.0f);
	XLevel->SingleLineCheck(Hit, this, End, Start, 0x286, FVector(0.f,0.f,0.f));
	if (!Hit.Actor)
	{
		FLOAT proneH = *(FLOAT*)((BYTE*)this + 0x464);  // ProneHeight
		FLOAT proneR = *(FLOAT*)((BYTE*)this + 0x468);  // ProneRadius
		// Second trace: cylinder-extent check at prone height
		FVector Start2(FeetLocation.X, FeetLocation.Y, hDelta + FeetLocation.Z);
		FVector End2(TestLocation.X,   TestLocation.Y,  hDelta + TestLocation.Z);
		FCheckResult Hit2(1.0f);
		XLevel->SingleLineCheck(Hit2, this, End2, Start2, 0x86, FVector(proneR, proneR, proneH));
		if (Hit2.Time == 1.0f)
		{
			// Clear bit 4, set bits 8 and 10
			*(DWORD*)((BYTE*)this + 0x3e0) = (*(DWORD*)((BYTE*)this + 0x3e0) & ~0x10u) | 0x500u;
			*(FLOAT*)((BYTE*)this + 0x424) = 1.5f;      // step fraction
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

IMPL_DIVERGE("retail syncs new position via ctrl (this+0x328) net-channel vtable call")
void APawn::Crouch(INT bClientSimulation)
{
	guard(APawn::Crouch);
	// Retail 0xE5DE0 (376b): resize collision to CrouchHeight/CrouchRadius, fire eventStartCrouch.
	// APawn bitfield INT at this+0x3E0: bit5=bIsCrouched(0x20), bit8=m_bWantsToProne(0x100).
	DWORD& flags = *(DWORD*)((BYTE*)this + 0x3E0);

	// Early exit if already at crouch dimensions.
	if (CollisionHeight == CrouchHeight && CollisionRadius == CrouchRadius)
		return;
	// Early exit if m_bWantsToProne (bit 8 in APawn bitflags at this+0x3E0) is set.
	if (flags & 0x100)
		return;

	FLOAT oldHeight = CollisionHeight;
	SetCollisionSize(CrouchRadius, CrouchHeight);

	// Z pivot = heightDelta + current PrePivot.Z (retail: fadd [this+0x2D0] = PrePivot.Z).
	FLOAT heightAdjust = (oldHeight - CrouchHeight) + PrePivot.Z;
	SetPrePivot(FVector(0.f, 0.f, heightAdjust));

	// Divergence: retail syncs new position via ctrl (this+0x328) net-channel vtable call.

	if (bClientSimulation)
		return;

	// Set bIsCrouched (bit 5 = 0x20) and AActor net-relevance flag (bit30 at this+0xA0).
	flags |= 0x20;
	*(DWORD*)((BYTE*)this + 0xA0) |= 0x40000000;
	eventStartCrouch(heightAdjust);
	unguard;
}

IMPL_DIVERGE("Ghidra 0x103e9020: before comparing progress, calls vtable[0x62] (IsWarpZone) on this and gates on bCanSwim (+0x3e2 bit0) or physics-volume flag (+0x164→+0x410 bit6); our code skips those gates")
ETestMoveResult APawn::FindBestJump(FVector Dest)
{
	guard(APawn::FindBestJump);
	FVector SavedLoc = Location;
	FVector JumpVel = SuggestJumpVelocity(Dest, JumpZ, 0.f);
	ETestMoveResult hit = jumpLanding(JumpVel, 1);
	if ( hit == TESTMOVE_Stopped )
		return TESTMOVE_Stopped;

	// DIVERGENCE: Ghidra checks vtable IsWarpZone and bCanSwim/bWaterVolume; simplified
	FVector vDest = Dest - Location;
	FVector vSaved = Dest - SavedLoc;
	if ( vSaved.Size2D() > vDest.Size2D() )
		return (ETestMoveResult)1;

	return TESTMOVE_Stopped;
	unguard;
}

IMPL_DIVERGE("stub body; Ghidra 0x103e8de0 is 513b: iterative jump-velocity search to find highest reachable point via walkMove; not yet reconstructed")
ETestMoveResult APawn::FindJumpUp(FVector Dest)
{
	guard(APawn::FindJumpUp);
	return TESTMOVE_Stopped;
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

IMPL_DIVERGE("stub body (1 line(s)) — Ghidra 0x103e91a0 is 3355 bytes, not fully reconstructed")
INT APawn::Pick3DWallAdjust(FVector WallHitNormal)
{
	guard(APawn::Pick3DWallAdjust);
	return 0;
	unguard;
}

IMPL_DIVERGE("stub body (1 line(s)) — Ghidra 0x103eb2e0 is 2629 bytes, not fully reconstructed")
INT APawn::PickWallAdjust(FVector WallHitNormal)
{
	guard(APawn::PickWallAdjust);
	return 0;
	unguard;
}

IMPL_DIVERGE("stub body — Ghidra 0x103F0AE0 shows 1723-byte implementation not yet reconstructed")
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

IMPL_DIVERGE("stub body; Ghidra 0x103f3e60 is 514b: water-surface line split, MoveActor with water-movement physics, slide on blocking hits; not yet reconstructed")
FLOAT APawn::Swim(FVector Delta, FCheckResult& Hit)
{
	guard(APawn::Swim);
	return 0.f;
	unguard;
}

IMPL_DIVERGE("retail does a collision check via ctrl (this+0x328) net-channel vtable[7];")
void APawn::UnCrouch(INT bClientSimulation)
{
	guard(APawn::UnCrouch);
	// Retail 0xE5F90 (565b): restore collision to class-default dimensions, fire eventEndCrouch.
	// APawn bitfield INT at this+0x3E0: bit5=bIsCrouched(0x20), bit8=m_bWantsToProne(0x100).
	// BYTE at this+0x39C (= APawn+8 = m_ePeekingMode) checked for value 2.
	DWORD& flags = *(DWORD*)((BYTE*)this + 0x3E0);
	if (flags & 0x100) return;                            // m_bWantsToProne set
	if (*(BYTE*)((BYTE*)this + 0x39C) == 2) return;      // m_ePeekingMode == 2

	// Get uncrouched dimensions from class default object.
	UClass* cls = GetClass();
	APawn* deflt = cls ? (APawn*)cls->GetDefaultObject() : NULL;
	if (!deflt) return;
	FLOAT defaultHeight = deflt->CollisionHeight;
	FLOAT defaultRadius = deflt->CollisionRadius;
	FLOAT heightDelta = defaultHeight - CollisionHeight;

	// Retail: SetCollisionSize to default FIRST, then optionally revert if blocked.
	SetCollisionSize(defaultRadius, defaultHeight);

	if (!bClientSimulation)
	{
		// Divergence: retail does a collision check via ctrl (this+0x328) net-channel vtable[7];
		// that check may revert to crouch and set bTryToUncrouch (bit 4 = 0x10 in flags).
		// Simplified: we always succeed. If blocked in server play this may cause visual glitch.

		// Sync position via ctrl network channel (divergence: omitted).

		// Restore PrePivot to initial standing offset.
		SetPrePivot(FVector(0.f, 0.f, m_fPrePivotPawnInitialOffset));
		*(DWORD*)((BYTE*)this + 0xA0) |= 0x40000000;
		flags &= ~0x20u;  // clear bIsCrouched
		eventEndCrouch(heightDelta);
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

IMPL_DIVERGE("Ghidra 0x103e9f00: second loop calls vtable+0x100 on USkeletalMeshInstance with (index,0) after SetAnimRate — vtable slot not yet mapped; first loop also has no null-guard inside body (Ghidra calls unconditionally after top null check)")
void APawn::ZeroMovementAlpha(INT bZeroX, INT bZeroY, FLOAT Alpha)
{
	guard(APawn::ZeroMovementAlpha);
	USkeletalMeshInstance* mi = NULL;
	if ( MeshInstance && MeshInstance->IsA(USkeletalMeshInstance::StaticClass()) )
		mi = (USkeletalMeshInstance*)MeshInstance;

	UBOOL bAllZero = 1;
	for ( INT i = bZeroX; i < bZeroY; i++ )
	{
		if ( mi && mi->GetBlendAlpha(i) > 0.f )
		{
			bAllZero = 0;
			mi->UpdateBlendAlpha(i, 0.f, Alpha);
		}
	}
	if ( bAllZero )
	{
		for ( INT i = bZeroX; i < bZeroY; i++ )
		{
			if ( mi ) mi->SetAnimRate(i, 0.f);
			// DIVERGENCE: Ghidra vtable[0x100] on USkeletalMeshInstance not mapped
		}
	}
	unguard;
}

IMPL_DIVERGE("stub body (1 line(s)) — Ghidra 0x1041c8d0 is 948 bytes, not fully reconstructed")
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

IMPL_DIVERGE("Ghidra 0x103f06e0: passes NULL (not this) as Actor arg; trace flags 0x86 (Movers|Level|LevelGeometry) vs TRACE_AllBlocking; hit dispatch via vtable[0xd0] not processHitWall")
INT APawn::checkFloor(FVector Dir, FCheckResult& Hit)
{
	guard(APawn::checkFloor);
	// Trace 33 units in Dir direction from Location
	FVector End = Location - Dir * 33.f;
	XLevel->SingleLineCheck(Hit, this, End, Location, TRACE_AllBlocking,
		FVector(CollisionRadius, CollisionRadius, CollisionHeight));
	if ( Hit.Time < 1.f )
	{
		processHitWall(Hit.Normal, Hit.Actor);
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

IMPL_DIVERGE("Ghidra 0x103f07e0: velocity displacement calculation from FVector division is approximate; parity fails")
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
			// Velocity from displacement — Ghidra shows FVector division but divisor is unclear; best approximation.
			FVector Delta = Location - OldLocation;
			Velocity.X = Delta.X;
			Velocity.Y = Delta.Y;
		}
		Velocity.Z = SavedVelZ;
		if( RemainingTime > 0.005f )
			physFalling( RemainingTime, Iterations );
	}
	return 0;
	unguard;
}

IMPL_DIVERGE("stub body; Ghidra 0x1041cfa0 is 1916b: A* pathfinding with FSortedPathList open/closed sets; not yet reconstructed")
FLOAT APawn::findPathToward(AActor* Goal, FVector Dest, FLOAT (*WeightFunc)(ANavigationPoint*, APawn*, FLOAT), INT bSinglePath, FLOAT MaxWeight)
{
	guard(APawn::findPathToward);
	return 0.f;
	unguard;
}

IMPL_DIVERGE("Ghidra 0x103f2c70: iterates XLevel ActorList for water volumes, finds water surface intersection; stub returns zero vector here")
FVector APawn::findWaterLine(FVector Start, FVector End)
{
	guard(APawn::findWaterLine);
	return FVector(0,0,0);
	unguard;
}

IMPL_DIVERGE("stub body; Ghidra 0x103e6e50 is 629b: MoveActor in fly direction, wall-slide and reflection on hit; not yet reconstructed")
ETestMoveResult APawn::flyMove(FVector Delta, AActor* HitActor, FLOAT DeltaTime)
{
	guard(APawn::flyMove);
	return TESTMOVE_Stopped;
	unguard;
}

IMPL_DIVERGE("Ghidra 0x103ea940; 685b — fly-step loop: step=SafeNormal(delta)*max(CollisionRadius,200) up to 100 iters; water-zone fallback to swimReachable via bCanSwim check; vtable[0x188] raw call for water-entry gate; WarpZone zone-ptr at raw offsets; 0xf8=CollisionRadius confirmed via SetCollisionSize")
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

IMPL_DIVERGE("stub body; Ghidra 0x103e88b0 is 1264b: iterative gravity integration with floor detection, AScout-specific handling; not yet reconstructed")
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

IMPL_DIVERGE("stub body — Ghidra 0x103EFC30 shows 1653-byte implementation not yet reconstructed")
void APawn::physFlying(FLOAT DeltaTime, INT Iterations)
{
	guard(APawn::physFlying);
	unguard;
}

IMPL_DIVERGE("stub body — Ghidra 0x103F5990 shows 2617-byte implementation not yet reconstructed")
void APawn::physSpider(FLOAT DeltaTime, INT Iterations)
{
	guard(APawn::physSpider);
	unguard;
}

IMPL_DIVERGE("stub body — Ghidra 0x103F40A0 shows 1842-byte implementation not yet reconstructed")
void APawn::physSwimming(FLOAT DeltaTime, INT Iterations)
{
	guard(APawn::physSwimming);
	unguard;
}

IMPL_DIVERGE("stub body — Ghidra 0x103ED370 shows 4353-byte implementation not yet reconstructed")
void APawn::physWalking(FLOAT DeltaTime, INT Iterations)
{
	guard(APawn::physWalking);
	unguard;
}

IMPL_DIVERGE("Ghidra 0x103ec3f0; 516b — GIsEditor 2D range check, LOS SingleLineCheck, FarMoveActor+Reachable; omits rdtsc")
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

IMPL_DIVERGE("Ghidra 0x103E8150, 491b — vtable[0x68] reachability call approximated; Acceleration scale unknown")
void APawn::rotateToward(AActor* Focus, FVector FocalPoint)
{
guard(APawn::rotateToward);

// Skip if bRollToDesired set (bit 11 of pawn bitfield at +0x3e4) or Physics==PHYS_None
if ((*(DWORD*)(this + 0x3e4) & 0x800) || Physics == PHYS_None)
return;

// Swimming/flying without bCanStrafe (bit 19 of +0x3e0): align acceleration with facing.
// DIVERGENCE: Ghidra multiplies the unit vector by an unknown stack float.
if (!(*(DWORD*)(this + 0x3e0) & 0x80000) &&
(Physics == PHYS_Flying || Physics == PHYS_Swimming))
{
Acceleration = Rotation.Vector();
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

IMPL_DIVERGE("stub body — Ghidra 0x103F5640 shows 790-byte implementation not yet reconstructed")
void APawn::startSwimming(FVector OldVelocity, FVector OldAcceleration, FLOAT VelSize, FLOAT AccelSize, INT Iterations)
{
	guard(APawn::startSwimming);
	unguard;
}

IMPL_DIVERGE("stub body — Ghidra 0x103e7100 is 823 bytes: vtable SingleLineCheck, findWaterLine, FVector negation, returns 0/1/5; not yet reconstructed")
ETestMoveResult APawn::swimMove(FVector Delta, AActor* HitActor, FLOAT DeltaTime)
{
	guard(APawn::swimMove);
	return TESTMOVE_Stopped;
	unguard;
}

IMPL_DIVERGE("Ghidra 0x103e8450; 1065b — swim-step loop: step=SafeNormal(delta)*max(CollisionRadius,200) up to 100 iters; exits water: bCanFly->flyReachable; bCanWalk+surface->MoveActor step-up simplified to flyReachable; vtable[0x188] water-blocker check omitted (DIVERGE); WarpZone zone-ptr raw offsets")
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

IMPL_DIVERGE("stub body — Ghidra 0x103e69e0 is 1084 bytes: vtable SingleLineCheck + setBase, step-up slide, FVector negation, returns 0/1/2/5; not yet reconstructed")
ETestMoveResult APawn::walkMove(FVector Delta, FCheckResult& Hit, AActor* HitActor, FLOAT DeltaTime)
{
	guard(APawn::walkMove);
	return TESTMOVE_Stopped;
	unguard;
}

IMPL_DIVERGE("stub body (1 line(s)) — Ghidra 0x103eac30 is 1365 bytes, not fully reconstructed")
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

IMPL_DIVERGE("stub body — Ghidra 0x103c3870 is 977 bytes: bHidden toggle, AI state dispatch (CheckEnemyVisible, rotateToward), MonitoredPawn distance checks, eventMonitoredPawnAlert; does not simply delegate to AActor::Tick")
INT AController::Tick( FLOAT DeltaTime, ELevelTick TickType )
{
	guard(AController::Tick);
	return AActor::Tick( DeltaTime, TickType );
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

IMPL_DIVERGE("Ghidra 0x10420b10; 108b — guard/unguard overhead and struct layout offset shift cause parity failure")
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

IMPL_DIVERGE("stub body (1 line(s)) — Ghidra 0x10390ec0 is 1187 bytes, not fully reconstructed")
INT AController::CanHear( FVector NoiseLoc, FLOAT Loudness, AActor* NoiseMaker, ENoiseType NoiseType, EPawnType PawnType )
{
	guard(AController::CanHear);
	return 0;
	unguard;
}

IMPL_DIVERGE("Ghidra passes Pawn->Location as first FVector arg to CanHearSound,")
void AController::CheckHearSound( AActor* SoundMaker, INT SoundId, USound* Sound, FVector SoundLoc, FLOAT Volume, INT Flags )
{
	guard(AController::CheckHearSound);
	// Retail 0x12cc70: fire eventAIHearSound if Pawn valid and sound is within range.
	if (!Pawn)
		return;
	if (!IsProbing(ENGINE_AIHearSound))
		return;
	FVector OutNoiseLoc;
	// DIVERGENCE: Ghidra passes Pawn->Location as first FVector arg to CanHearSound,
	// indicating it is the listener location (not the sound origin).
	if (CanHearSound(Pawn->Location, SoundMaker, Volume, OutNoiseLoc))
		eventAIHearSound(SoundMaker, SoundId, Sound, Pawn->Location, SoundLoc * Volume, (DWORD)Flags);
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

IMPL_DIVERGE("stub body — Ghidra 0x10391B60 shows 510-byte implementation not yet reconstructed")
void AController::ShowSelf()
{
	guard(AController::ShowSelf);
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
IMPL_DIVERGE("Ghidra 0x1038d500, 476b — DAT_1066ad7c as static sGoalCache[4]; FName 0x15a = NAME_SpecialHandling")
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
// Walk GoalList[1+] to find the last non-null entry
INT i = 1;
while (i < 3 && GoalList[i]) i++;
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

IMPL_DIVERGE("Ghidra 0x1041CCC0; raw offsets: EndPath+0x394=cost, +0x3ac=prevPath, +0x3b4=nextPath; skips FUN_1035a3d0 profiling call")
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
	// Set Pawn->NextPathRadius from reachspec between RouteCache[0] and RouteCache[1]
	if (RouteCache[0] && RouteCache[0]->IsA(ANavigationPoint::StaticClass()) &&
	    RouteCache[1] && RouteCache[1]->IsA(ANavigationPoint::StaticClass()))
	{
		UReachSpec* spec = ((ANavigationPoint*)RouteCache[0])->GetReachSpecTo((ANavigationPoint*)RouteCache[1]);
		if (spec)
		{
			// spec+0x34 = reachability radius (INT cast to float)
			Pawn->NextPathRadius = (FLOAT)*(INT*)((BYTE*)spec + 0x34);
			return;
		}
	}
	if (Pawn) Pawn->NextPathRadius = 0.f;
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

IMPL_DIVERGE("stub body (1 line(s)) — Ghidra 0x10427610 is 335 bytes, not fully reconstructed")
INT AController::CanHearSound( FVector SoundLoc, AActor* SoundMaker, FLOAT Loudness, FVector& OutNoiseLoc )
{
	guard(AController::CanHearSound);
	return 0;
	unguard;
}

IMPL_DIVERGE("Ghidra 0x1038ed20; 173b -- omits rdtsc profiling; adds Enemy->IsValid() assertion matching retail; guard/unguard diverges")
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

IMPL_DIVERGE("Ghidra 0x1038e270: omits rdtsc profiling counters (GScriptCycles, function timer array)")
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

IMPL_DIVERGE("Ghidra 0x1038ee00; 252b — logic verified; guard/unguard frame overhead diverges; rdtsc profiling omitted")
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

