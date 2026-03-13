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

void APawn::execReachedDestination( FFrame& Stack, RESULT_DECL )
{
	guard(APawn::execReachedDestination);
	P_GET_OBJECT(AActor,Goal);
	P_FINISH;
	*(DWORD*)Result = Goal ? (Location - Goal->Location).SizeSquared() < CollisionRadius * CollisionRadius : 0;
	unguard;
}
IMPLEMENT_FUNCTION( APawn, INDEX_NONE, execReachedDestination );

void APawn::execIsFriend( FFrame& Stack, RESULT_DECL )
{
	guard(APawn::execIsFriend);
	P_GET_OBJECT(APawn,Other);
	P_FINISH;
	*(DWORD*)Result = IsFriend( Other );
	unguard;
}
IMPLEMENT_FUNCTION( APawn, INDEX_NONE, execIsFriend );

void APawn::execIsEnemy( FFrame& Stack, RESULT_DECL )
{
	guard(APawn::execIsEnemy);
	P_GET_OBJECT(APawn,Other);
	P_FINISH;
	*(DWORD*)Result = IsEnemy( Other );
	unguard;
}
IMPLEMENT_FUNCTION( APawn, INDEX_NONE, execIsEnemy );

void APawn::execIsNeutral( FFrame& Stack, RESULT_DECL )
{
	guard(APawn::execIsNeutral);
	P_GET_OBJECT(APawn,Other);
	P_FINISH;
	*(DWORD*)Result = IsNeutral( Other );
	unguard;
}
IMPLEMENT_FUNCTION( APawn, INDEX_NONE, execIsNeutral );

void APawn::execIsAlive( FFrame& Stack, RESULT_DECL )
{
	guard(APawn::execIsAlive);
	P_FINISH;
	*(DWORD*)Result = IsAlive();
	unguard;
}
IMPLEMENT_FUNCTION( APawn, INDEX_NONE, execIsAlive );

/*-- AController movement latent functions -----------------------------*/

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

void AController::execPollMoveTo( FFrame& Stack, RESULT_DECL )
{
	guard(AController::execPollMoveTo);
	if( Pawn )
	{
		FVector Dir = Destination - Pawn->Location;
		Dir.Z = 0.f;
		if( Dir.SizeSquared() < Pawn->CollisionRadius * Pawn->CollisionRadius )
			GetStateFrame()->LatentAction = 0;
	}
	else
	{
		GetStateFrame()->LatentAction = 0;
	}
	unguard;
}
IMPLEMENT_FUNCTION( AController, INDEX_NONE, execPollMoveTo );

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

void AController::execPollMoveToward( FFrame& Stack, RESULT_DECL )
{
	guard(AController::execPollMoveToward);
	if( Pawn && MoveTarget )
	{
		FVector Dir = MoveTarget->Location - Pawn->Location;
		Dir.Z = 0.f;
		if( Dir.SizeSquared() < Pawn->CollisionRadius * Pawn->CollisionRadius )
			GetStateFrame()->LatentAction = 0;
	}
	else
	{
		GetStateFrame()->LatentAction = 0;
	}
	unguard;
}
IMPLEMENT_FUNCTION( AController, INDEX_NONE, execPollMoveToward );

void AController::execFinishRotation( FFrame& Stack, RESULT_DECL )
{
	guard(AController::execFinishRotation);
	P_FINISH;
	GetStateFrame()->LatentAction = AI_PollFinishRotation;
	unguard;
}
IMPLEMENT_FUNCTION( AController, 508, execFinishRotation );

void AController::execPollFinishRotation( FFrame& Stack, RESULT_DECL )
{
	guard(AController::execPollFinishRotation);
	// Consider rotation finished when close enough.
	GetStateFrame()->LatentAction = 0;
	unguard;
}
IMPLEMENT_FUNCTION( AController, INDEX_NONE, execPollFinishRotation );

void AController::execWaitForLanding( FFrame& Stack, RESULT_DECL )
{
	guard(AController::execWaitForLanding);
	P_FINISH;
	GetStateFrame()->LatentAction = AI_PollWaitForLanding;
	unguard;
}
IMPLEMENT_FUNCTION( AController, 527, execWaitForLanding );

void AController::execPollWaitForLanding( FFrame& Stack, RESULT_DECL )
{
	guard(AController::execPollWaitForLanding);
	if( Pawn && Pawn->Physics != PHYS_Falling )
		GetStateFrame()->LatentAction = 0;
	unguard;
}
IMPLEMENT_FUNCTION( AController, INDEX_NONE, execPollWaitForLanding );

/*-- AController perception -------------------------------------------*/

void AController::execLineOfSightTo( FFrame& Stack, RESULT_DECL )
{
	guard(AController::execLineOfSightTo);
	P_GET_OBJECT(AActor,Other);
	P_FINISH;
	*(DWORD*)Result = 0;
	if( Other && Pawn && Pawn->XLevel )
	{
		FCheckResult Hit(1.f);
		*(DWORD*)Result = !Pawn->XLevel->SingleLineCheck( Hit, Pawn, Other->Location, Pawn->Location, TRACE_World | TRACE_Level, FVector(0,0,0) );
	}
	unguard;
}
IMPLEMENT_FUNCTION( AController, 514, execLineOfSightTo );

void AController::execCanSee( FFrame& Stack, RESULT_DECL )
{
	guard(AController::execCanSee);
	P_GET_OBJECT(APawn,Other);
	P_FINISH;
	*(DWORD*)Result = 0;
	if( Other && Pawn && Pawn->XLevel )
	{
		FCheckResult Hit(1.f);
		*(DWORD*)Result = !Pawn->XLevel->SingleLineCheck( Hit, Pawn, Other->Location, Pawn->Location, TRACE_World | TRACE_Level, FVector(0,0,0) );
	}
	unguard;
}
IMPLEMENT_FUNCTION( AController, INDEX_NONE, execCanSee );

/*-- AController pathfinding -------------------------------------------*/

void AController::execFindPathToward( FFrame& Stack, RESULT_DECL )
{
	guard(AController::execFindPathToward);
	P_GET_OBJECT(AActor,Goal);
	P_GET_UBOOL_OPTX(bSinglePath,0);
	P_FINISH;
	// Pathfinding stub — returns NULL to indicate no path found.
	*(AActor**)Result = NULL;
	unguard;
}
IMPLEMENT_FUNCTION( AController, 517, execFindPathToward );

void AController::execFindPathTowardNearest( FFrame& Stack, RESULT_DECL )
{
	guard(AController::execFindPathTowardNearest);
	P_GET_OBJECT(UClass,GoalClass);
	P_GET_UBOOL_OPTX(bSinglePath,0);
	P_FINISH;
	*(AActor**)Result = NULL;
	unguard;
}
IMPLEMENT_FUNCTION( AController, INDEX_NONE, execFindPathTowardNearest );

void AController::execFindPathTo( FFrame& Stack, RESULT_DECL )
{
	guard(AController::execFindPathTo);
	P_GET_VECTOR(Point);
	P_FINISH;
	*(AActor**)Result = NULL;
	unguard;
}
IMPLEMENT_FUNCTION( AController, 518, execFindPathTo );

void AController::execactorReachable( FFrame& Stack, RESULT_DECL )
{
	guard(AController::execactorReachable);
	P_GET_OBJECT(AActor,anActor);
	P_FINISH;
	*(DWORD*)Result = 0;
	unguard;
}
IMPLEMENT_FUNCTION( AController, 520, execactorReachable );

void AController::execpointReachable( FFrame& Stack, RESULT_DECL )
{
	guard(AController::execpointReachable);
	P_GET_VECTOR(aPoint);
	P_FINISH;
	*(DWORD*)Result = 0;
	unguard;
}
IMPLEMENT_FUNCTION( AController, 521, execpointReachable );

void AController::execClearPaths( FFrame& Stack, RESULT_DECL )
{
	guard(AController::execClearPaths);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AController, 522, execClearPaths );

void AController::execEAdjustJump( FFrame& Stack, RESULT_DECL )
{
	guard(AController::execEAdjustJump);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AController, 523, execEAdjustJump );

void AController::execFindRandomDest( FFrame& Stack, RESULT_DECL )
{
	guard(AController::execFindRandomDest);
	P_FINISH;
	*(AActor**)Result = NULL;
	unguard;
}
IMPLEMENT_FUNCTION( AController, 525, execFindRandomDest );

void AController::execPickWallAdjust( FFrame& Stack, RESULT_DECL )
{
	guard(AController::execPickWallAdjust);
	P_FINISH;
	*(DWORD*)Result = 0;
	unguard;
}
IMPLEMENT_FUNCTION( AController, 526, execPickWallAdjust );

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

void AController::execPickTarget( FFrame& Stack, RESULT_DECL )
{
	guard(AController::execPickTarget);
	P_GET_OBJECT(UClass,TargetClass);
	P_GET_FLOAT_REF(bestAim);
	P_GET_FLOAT_REF(bestDist);
	P_GET_VECTOR(FireDir);
	P_GET_VECTOR(projStart);
	P_FINISH;
	*(APawn**)Result = NULL;
	unguard;
}
IMPLEMENT_FUNCTION( AController, 531, execPickTarget );

void AController::execPickAnyTarget( FFrame& Stack, RESULT_DECL )
{
	guard(AController::execPickAnyTarget);
	P_GET_FLOAT_REF(bestAim);
	P_GET_FLOAT_REF(bestDist);
	P_GET_VECTOR(FireDir);
	P_GET_VECTOR(projStart);
	P_FINISH;
	*(AActor**)Result = NULL;
	unguard;
}
IMPLEMENT_FUNCTION( AController, 534, execPickAnyTarget );

void AController::execFindBestInventoryPath( FFrame& Stack, RESULT_DECL )
{
	guard(AController::execFindBestInventoryPath);
	P_GET_FLOAT_REF(MinWeight);
	P_FINISH;
	*(AActor**)Result = NULL;
	unguard;
}
IMPLEMENT_FUNCTION( AController, 540, execFindBestInventoryPath );

void AController::execEndClimbLadder( FFrame& Stack, RESULT_DECL )
{
	guard(AController::execEndClimbLadder);
	P_FINISH;
	if( Pawn )
		Pawn->setPhysics( PHYS_Falling, NULL, FVector(0,0,0) );
	unguard;
}
IMPLEMENT_FUNCTION( AController, INDEX_NONE, execEndClimbLadder );

void AController::execInLatentExecution( FFrame& Stack, RESULT_DECL )
{
	guard(AController::execInLatentExecution);
	P_GET_INT(LatentActionNumber);
	P_FINISH;
	*(DWORD*)Result = GetStateFrame() && GetStateFrame()->LatentAction == LatentActionNumber;
	unguard;
}
IMPLEMENT_FUNCTION( AController, INDEX_NONE, execInLatentExecution );

void AController::execStopWaiting( FFrame& Stack, RESULT_DECL )
{
	guard(AController::execStopWaiting);
	P_FINISH;
	GetStateFrame()->LatentAction = 0;
	unguard;
}
IMPLEMENT_FUNCTION( AController, INDEX_NONE, execStopWaiting );

/*-- APlayerController functions ---------------------------------------*/

void APlayerController::execFindStairRotation( FFrame& Stack, RESULT_DECL )
{
	guard(APlayerController::execFindStairRotation);
	P_GET_FLOAT(DeltaTime);
	P_FINISH;
	*(INT*)Result = Rotation.Pitch;
	unguard;
}
IMPLEMENT_FUNCTION( APlayerController, 524, execFindStairRotation );

void APlayerController::execResetKeyboard( FFrame& Stack, RESULT_DECL )
{
	guard(APlayerController::execResetKeyboard);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( APlayerController, 544, execResetKeyboard );

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

void APlayerController::execGetDefaultURL( FFrame& Stack, RESULT_DECL )
{
	guard(APlayerController::execGetDefaultURL);
	P_GET_STR(Option);
	P_FINISH;
	*(FString*)Result = TEXT("");
	unguard;
}
IMPLEMENT_FUNCTION( APlayerController, INDEX_NONE, execGetDefaultURL );

void APlayerController::execGetEntryLevel( FFrame& Stack, RESULT_DECL )
{
	guard(APlayerController::execGetEntryLevel);
	P_FINISH;
	*(ULevelBase**)Result = NULL;
	unguard;
}
IMPLEMENT_FUNCTION( APlayerController, INDEX_NONE, execGetEntryLevel );

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

void APlayerController::execGetPlayerNetworkAddress( FFrame& Stack, RESULT_DECL )
{
	guard(APlayerController::execGetPlayerNetworkAddress);
	P_FINISH;
	*(FString*)Result = TEXT("");
	unguard;
}
IMPLEMENT_FUNCTION( APlayerController, INDEX_NONE, execGetPlayerNetworkAddress );

void APlayerController::execCopyToClipboard( FFrame& Stack, RESULT_DECL )
{
	guard(APlayerController::execCopyToClipboard);
	P_GET_STR(Text);
	P_FINISH;
	appClipboardCopy( *Text );
	unguard;
}
IMPLEMENT_FUNCTION( APlayerController, INDEX_NONE, execCopyToClipboard );

void APlayerController::execPasteFromClipboard( FFrame& Stack, RESULT_DECL )
{
	guard(APlayerController::execPasteFromClipboard);
	P_FINISH;
	*(FString*)Result = appClipboardPaste();
	unguard;
}
IMPLEMENT_FUNCTION( APlayerController, INDEX_NONE, execPasteFromClipboard );

void APlayerController::execSpecialDestroy( FFrame& Stack, RESULT_DECL )
{
	guard(APlayerController::execSpecialDestroy);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( APlayerController, INDEX_NONE, execSpecialDestroy );

void APlayerController::execPB_CanPlayerSpawn( FFrame& Stack, RESULT_DECL )
{
	guard(APlayerController::execPB_CanPlayerSpawn);
	P_FINISH;
	*(DWORD*)Result = 1;
	unguard;
}
IMPLEMENT_FUNCTION( APlayerController, 1320, execPB_CanPlayerSpawn );

void APlayerController::execGetPBConnectStatus( FFrame& Stack, RESULT_DECL )
{
	guard(APlayerController::execGetPBConnectStatus);
	P_FINISH;
	*(INT*)Result = 0;
	unguard;
}
IMPLEMENT_FUNCTION( APlayerController, INDEX_NONE, execGetPBConnectStatus );

void APlayerController::execIsPBEnabled( FFrame& Stack, RESULT_DECL )
{
	guard(APlayerController::execIsPBEnabled);
	P_FINISH;
	*(DWORD*)Result = 0;
	unguard;
}
IMPLEMENT_FUNCTION( APlayerController, INDEX_NONE, execIsPBEnabled );

void APlayerController::execGetKey( FFrame& Stack, RESULT_DECL )
{
	guard(APlayerController::execGetKey);
	P_GET_INT(KeyNum);
	P_FINISH;
	*(FString*)Result = TEXT("");
	unguard;
}
IMPLEMENT_FUNCTION( APlayerController, 2706, execGetKey );

void APlayerController::execGetActionKey( FFrame& Stack, RESULT_DECL )
{
	guard(APlayerController::execGetActionKey);
	P_GET_STR(ActionName);
	P_FINISH;
	*(FString*)Result = TEXT("");
	unguard;
}
IMPLEMENT_FUNCTION( APlayerController, 2707, execGetActionKey );

void APlayerController::execGetEnumName( FFrame& Stack, RESULT_DECL )
{
	guard(APlayerController::execGetEnumName);
	P_GET_INT(EnumIndex);
	P_FINISH;
	*(FString*)Result = TEXT("");
	unguard;
}
IMPLEMENT_FUNCTION( APlayerController, 2708, execGetEnumName );

void APlayerController::execChangeInputSet( FFrame& Stack, RESULT_DECL )
{
	guard(APlayerController::execChangeInputSet);
	P_GET_INT(InputSet);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( APlayerController, 2709, execChangeInputSet );

void APlayerController::execSetKey( FFrame& Stack, RESULT_DECL )
{
	guard(APlayerController::execSetKey);
	P_GET_INT(KeyNum);
	P_GET_STR(KeyName);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( APlayerController, 2710, execSetKey );

void APlayerController::execSetSoundOptions( FFrame& Stack, RESULT_DECL )
{
	guard(APlayerController::execSetSoundOptions);
	P_GET_INT(Provider);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( APlayerController, 2713, execSetSoundOptions );

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

void AAIController::execWaitToSeeEnemy( FFrame& Stack, RESULT_DECL )
{
	guard(AAIController::execWaitToSeeEnemy);
	P_FINISH;
	GetStateFrame()->LatentAction = AI_PollWaitToSeeEnemy;
	unguard;
}
IMPLEMENT_FUNCTION( AAIController, INDEX_NONE, execWaitToSeeEnemy );

void AAIController::execPollWaitToSeeEnemy( FFrame& Stack, RESULT_DECL )
{
	guard(AAIController::execPollWaitToSeeEnemy);
	if( Enemy && Pawn )
	{
		FCheckResult Hit(1.f);
		if( !Pawn->XLevel->SingleLineCheck( Hit, Pawn, Enemy->Location, Pawn->Location, TRACE_World | TRACE_Level, FVector(0,0,0) ) )
			GetStateFrame()->LatentAction = 0;
	}
	unguard;
}
IMPLEMENT_FUNCTION( AAIController, INDEX_NONE, execPollWaitToSeeEnemy );

/*-----------------------------------------------------------------------------
	APawn trivial method implementations.
	Reconstructed from Ghidra decompilation + UT99 reference.
-----------------------------------------------------------------------------*/

APawn* APawn::GetPawnOrColBoxOwner() const
{
	return (APawn*)this;
}

APawn* APawn::GetPlayerPawn() const
{
	// Retail: 8B C1 C3 = mov eax,ecx; ret — APawn always returns itself.
	// The base AActor::GetPlayerPawn returns NULL; APawn overrides to return this.
	return (APawn*)this;
}

INT APawn::PlayerControlled()
{
	return Controller && Controller->bIsPlayer;
}

INT APawn::IsAlive()
{
	return Health > 0;
}

INT APawn::IsCrouched()
{
	return bIsCrouched;
}

INT APawn::IsPlayer()
{
	return Controller && Controller->bIsPlayer;
}

INT APawn::IsHumanControlled()
{
	return Controller && Controller->IsA(APlayerController::StaticClass());
}

INT APawn::IsLocallyControlled()
{
	return Controller && Controller->IsA(APlayerController::StaticClass());
}

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

INT APawn::IsFriend( INT TeamIndex )
{
	// Retail RVA=0xE5370: return m_iFriendlyTeams & (1 << TeamIndex)
	guard(APawn::IsFriend_Team);
	return m_iFriendlyTeams & (1 << (TeamIndex & 0x1F));
	unguard;
}

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

FLOAT APawn::GetMaxSpeed()
{
	guard(APawn::GetMaxSpeed);
	if( Physics == PHYS_Walking )
		return GroundSpeed;
	if( Physics == PHYS_Swimming )
		return WaterSpeed;
	if( Physics == PHYS_Flying )
		return AirSpeed;
	if( Physics == PHYS_Ladder )
		return LadderSpeed;
	return GroundSpeed;
	unguard;
}

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

void APawn::SetPrePivot( FVector NewPrePivot )
{
	guard(APawn::SetPrePivot);
	PrePivot = NewPrePivot;
	unguard;
}


/*-----------------------------------------------------------------------------
	APawn method implementations -- batch from .bak reference + stubs.
	Reconstructed from Ghidra decompilation.
-----------------------------------------------------------------------------*/

void APawn::CheckForErrors()
{
	guard(APawn::CheckForErrors);
	AActor::CheckForErrors();
	unguard;
}

FVector APawn::CheckForLedges( AActor* HitActor, FVector Loc, FVector Delta, FVector GravDir, INT& bShouldJump, INT& bCheckedFall, FLOAT DeltaTime )
{
	guard(APawn::CheckForLedges);
	return Delta;
	unguard;
}

void APawn::Destroy()
{
	guard(APawn::Destroy);
	if( Controller )
		Controller->Pawn = NULL;
	AActor::Destroy();
	unguard;
}

FRotator APawn::FindSlopeRotation( FVector FloorNormal, FRotator NewRotation )
{
	guard(APawn::FindSlopeRotation);
	return AActor::FindSlopeRotation( FloorNormal, NewRotation );
	unguard;
}

FLOAT APawn::GetNetPriority( AActor* Sent, FLOAT Time, FLOAT Lag )
{
	guard(APawn::GetNetPriority);
	if( Controller && Controller->bIsPlayer )
		return NetPriority * (Time + 2.0f);
	return AActor::GetNetPriority( Sent, Time, Lag );
	unguard;
}

INT* APawn::GetOptimizedRepList( BYTE* InDefault, FPropertyRetirement* Retire, INT* Ptr, UPackageMap* Map, UActorChannel* Ch )
{
	guard(APawn::GetOptimizedRepList);
	Ptr = AActor::GetOptimizedRepList( InDefault, Retire, Ptr, Map, Ch );
	return Ptr;
	unguard;
}

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

INT APawn::IsBlockedBy( const AActor* Other ) const
{
	// Retail (21b+tail, RVA 0x79000): if bit 17 of [Other+0xA8] is set, not blocked.
	// Otherwise delegate to AActor::IsBlockedBy via tail call.
	if (*(DWORD*)((BYTE*)Other + 0xA8) & 0x00020000u)
		return 0;
	return AActor::IsBlockedBy(Other);
}

INT APawn::IsNetRelevantFor( APlayerController* RealViewer, AActor* Viewer, FVector SrcLocation )
{
	guard(APawn::IsNetRelevantFor);
	return AActor::IsNetRelevantFor( RealViewer, Viewer, SrcLocation );
	unguard;
}

void APawn::NotifyAnimEnd( INT Channel )
{
	guard(APawn::NotifyAnimEnd);
	AActor::NotifyAnimEnd( Channel );
	unguard;
}

void APawn::NotifyBump( AActor* Other )
{
	guard(APawn::NotifyBump);
	if( Controller )
		Controller->eventNotifyBump( Other );
	AActor::NotifyBump( Other );
	unguard;
}

void APawn::PostBeginPlay()
{
	guard(APawn::PostBeginPlay);
	AActor::PostBeginPlay();
	unguard;
}

void APawn::PostNetReceive()
{
	guard(APawn::PostNetReceive);
	AActor::PostNetReceive();
	unguard;
}

void APawn::PostNetReceiveLocation()
{
	guard(APawn::PostNetReceiveLocation);
	AActor::PostNetReceiveLocation();
	unguard;
}

void APawn::PreNetReceive()
{
	guard(APawn::PreNetReceive);
	AActor::PreNetReceive();
	unguard;
}

DWORD APawn::R6LineOfSightTo( AActor* Other, INT bUnused )
{
	guard(APawn::R6LineOfSightTo);
	return 0;
	unguard;
}

DWORD APawn::R6SeePawn( APawn* Other, INT bMaySkipChecks )
{
	guard(APawn::R6SeePawn);
	return 0;
	unguard;
}

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

void APawn::RenderEditorSelected( FLevelSceneNode* SceneNode, FRenderInterface* RI, FDynamicActor* Actor )
{
	guard(APawn::RenderEditorSelected);
	AActor::RenderEditorSelected( SceneNode, RI, Actor );
	unguard;
}

void APawn::SetBase( AActor* NewBase, FVector NewFloor, INT bNotifyActor )
{
	guard(APawn::SetBase);
	AActor::SetBase( NewBase, NewFloor, bNotifyActor );
	unguard;
}

void APawn::SetZone( INT bTest, INT bForceRefresh )
{
	guard(APawn::SetZone);
	AActor::SetZone( bTest, bForceRefresh );
	unguard;
}

INT APawn::ShouldTrace( AActor* SourceActor, DWORD TraceFlags )
{
	guard(APawn::ShouldTrace);
	return AActor::ShouldTrace( SourceActor, TraceFlags );
	unguard;
}

void APawn::SmoothHitWall( FVector HitNormal, AActor* HitActor )
{
	guard(APawn::SmoothHitWall);
	processHitWall( HitNormal, HitActor );
	unguard;
}

void APawn::TickSimulated( FLOAT DeltaTime )
{
	guard(APawn::TickSimulated);
	AActor::TickSimulated( DeltaTime );
	unguard;
}

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

void APawn::UpdateMovementAnimation( FLOAT DeltaSeconds )
{
	guard(APawn::UpdateMovementAnimation);
	// TODO: Drive movement animation from velocity / physics state.
	unguard;
}

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

void APawn::physicsRotation( FLOAT DeltaTime, FVector OldVelocity )
{
	guard(APawn::physicsRotation);
	// Retail Ghidra 0xf1920: asserts "false" in debug builds — this override
	// should never be reached.  Each concrete pawn (AR6Pawn, APlayerPawn) has its
	// own controller-driven physicsRotation.  Fall through as no-op here.
	unguard;
}

void APawn::processHitWall( FVector HitNormal, AActor* HitActor )
{
	guard(APawn::processHitWall);
	if( Controller )
		Controller->eventNotifyHitWall( HitNormal, HitActor );
	unguard;
}

void APawn::processLanded( FVector HitNormal, AActor* HitActor, FLOAT RemainingTime, INT Iterations )
{
	guard(APawn::processLanded);
	if( Controller )
		Controller->eventNotifyLanded( HitNormal );
	eventLanded( HitNormal );
	unguard;
}

void APawn::stepUp( FVector GravDir, FVector DesiredDir, FVector Delta, FCheckResult& Hit )
{
	guard(APawn::stepUp);
	// TODO: Pawn-specific step-up logic.
	AActor::stepUp( GravDir, DesiredDir, Delta, Hit );
	unguard;
}

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

INT APawn::CanCrouchWalk(FVector const& TestLocation, FVector const& FeetLocation)
{
	guard(APawn::CanCrouchWalk);
	return 0;
	unguard;
}

INT APawn::CanProneWalk(FVector const& TestLocation, FVector const& FeetLocation)
{
	guard(APawn::CanProneWalk);
	return 0;
	unguard;
}

void APawn::ClearSerpentine()
{
	// Retail (21b, RVA 0xE5260): stores 999.0f (0x4479C000) at SerpentineTime (+0x420),
	// clears SerpentineDist (+0x41C) to 0. No guard in retail.
	SerpentineTime = 999.0f;
	SerpentineDist = 0.0f;
}

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

ETestMoveResult APawn::FindJumpUp(FVector Dest)
{
	guard(APawn::FindJumpUp);
	return TESTMOVE_Stopped;
	unguard;
}

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

INT APawn::Pick3DWallAdjust(FVector WallHitNormal)
{
	guard(APawn::Pick3DWallAdjust);
	return 0;
	unguard;
}

INT APawn::PickWallAdjust(FVector WallHitNormal)
{
	guard(APawn::PickWallAdjust);
	return 0;
	unguard;
}

void APawn::SpiderstepUp(FVector Delta, FVector HitNormal, FCheckResult& Hit)
{
	guard(APawn::SpiderstepUp);
	unguard;
}

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

FVector APawn::SuggestJumpVelocity(FVector Dest, FLOAT DesiredSpeed, FLOAT MaxJumpZ)
{
	guard(APawn::SuggestJumpVelocity);
	return FVector(0,0,0);
	unguard;
}

FLOAT APawn::Swim(FVector Delta, FCheckResult& Hit)
{
	guard(APawn::Swim);
	return 0.f;
	unguard;
}

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

ANavigationPoint* APawn::breadthPathTo(FLOAT (CDECL*WeightFunc)(ANavigationPoint*, APawn*, FLOAT), ANavigationPoint* Start, INT MaxPathLength, FLOAT* Weight)
{
	guard(APawn::breadthPathTo);
	return NULL;
	unguard;
}

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

INT APawn::findNewFloor(FVector OldLocation, FLOAT DeltaTime, FLOAT RemainingTime, INT Iterations)
{
	guard(APawn::findNewFloor);
	return 0;
	unguard;
}

FLOAT APawn::findPathToward(AActor* Goal, FVector Dest, FLOAT (*WeightFunc)(ANavigationPoint*, APawn*, FLOAT), INT bSinglePath, FLOAT MaxWeight)
{
	guard(APawn::findPathToward);
	return 0.f;
	unguard;
}

FVector APawn::findWaterLine(FVector Start, FVector End)
{
	guard(APawn::findWaterLine);
	return FVector(0,0,0);
	unguard;
}

ETestMoveResult APawn::flyMove(FVector Delta, AActor* HitActor, FLOAT DeltaTime)
{
	guard(APawn::flyMove);
	return TESTMOVE_Stopped;
	unguard;
}

INT APawn::flyReachable(FVector Dest, INT bClearPath, AActor* GoalActor)
{
	guard(APawn::flyReachable);
	return 0;
	unguard;
}

ETestMoveResult APawn::jumpLanding(FVector TestFall, INT bAdjust)
{
	guard(APawn::jumpLanding);
	return TESTMOVE_Stopped;
	unguard;
}

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

void APawn::physFlying(FLOAT DeltaTime, INT Iterations)
{
	guard(APawn::physFlying);
	unguard;
}

void APawn::physSpider(FLOAT DeltaTime, INT Iterations)
{
	guard(APawn::physSpider);
	unguard;
}

void APawn::physSwimming(FLOAT DeltaTime, INT Iterations)
{
	guard(APawn::physSwimming);
	unguard;
}

void APawn::physWalking(FLOAT DeltaTime, INT Iterations)
{
	guard(APawn::physWalking);
	unguard;
}

INT APawn::pointReachable(FVector Dest, INT bKnowVisible)
{
	guard(APawn::pointReachable);
	return 0;
	unguard;
}

void APawn::rotateToward(AActor* Focus, FVector FocalPoint)
{
	guard(APawn::rotateToward);
	unguard;
}

void APawn::setMoveTimer(FLOAT DeltaTime)
{
	guard(APawn::setMoveTimer);
	if ( !Controller )
		return;

	if ( DesiredSpeed != 0.f )
	{
		FLOAT mult = 2.0f;
		// DIVERGENCE: bIsCrouched (bit5) | bIsWalking (bit2) via named bitfields
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

	// DIVERGENCE: Ghidra checks bit7 of Controller+0x3a8; mapped to bPreparingMove (bit 7 of first bitfield byte)
	if ( Controller->bPreparingMove && Controller->Enemy )
		Controller->MoveTimer += 2.0f;

	unguard;
}

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

void APawn::startSwimming(FVector OldVelocity, FVector OldAcceleration, FLOAT VelSize, FLOAT AccelSize, INT Iterations)
{
	guard(APawn::startSwimming);
	unguard;
}

ETestMoveResult APawn::swimMove(FVector Delta, AActor* HitActor, FLOAT DeltaTime)
{
	guard(APawn::swimMove);
	return TESTMOVE_Stopped;
	unguard;
}

INT APawn::swimReachable(FVector Dest, INT bClearPath, AActor* GoalActor)
{
	guard(APawn::swimReachable);
	return 0;
	unguard;
}

ETestMoveResult APawn::walkMove(FVector Delta, FCheckResult& Hit, AActor* HitActor, FLOAT DeltaTime)
{
	guard(APawn::walkMove);
	return TESTMOVE_Stopped;
	unguard;
}

INT APawn::walkReachable(FVector Dest, INT bClearPath, AActor* GoalActor)
{
	guard(APawn::walkReachable);
	return 0;
	unguard;
}

/*-----------------------------------------------------------------------------
	AController — Virtual methods.
-----------------------------------------------------------------------------*/

INT* AController::GetOptimizedRepList( BYTE* InDefault, FPropertyRetirement* Retire, INT* Ptr, UPackageMap* Map, UActorChannel* Ch )
{
	guard(AController::GetOptimizedRepList);
	Ptr = AActor::GetOptimizedRepList( InDefault, Retire, Ptr, Map, Ch );
	return Ptr;
	unguard;
}

AActor* AController::GetTeamManager()
{
	return NULL;
}

INT AController::LocalPlayerController()
{
	return 0;
}

INT AController::Tick( FLOAT DeltaTime, ELevelTick TickType )
{
	guard(AController::Tick);
	return AActor::Tick( DeltaTime, TickType );
	unguard;
}

void AController::AdjustFromWall( FVector HitNormal, AActor* HitActor )
{
	guard(AController::AdjustFromWall);
	unguard;
}

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

INT AController::CheckAnimFinished( INT Channel )
{
	guard(AController::CheckAnimFinished);
	return 1;
	unguard;
}

INT AController::AcceptNearbyPath( AActor* Goal )
{
	return 0;
}

INT AController::CanHear( FVector NoiseLoc, FLOAT Loudness, AActor* NoiseMaker, ENoiseType NoiseType, EPawnType PawnType )
{
	guard(AController::CanHear);
	return 0;
	unguard;
}

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

AActor* AController::GetViewTarget()
{
	guard(AController::GetViewTarget);
	return Pawn ? (AActor*)Pawn : (AActor*)this;
	unguard;
}

void AController::SetAdjustLocation( FVector NewLoc )
{
	guard(AController::SetAdjustLocation);
	unguard;
}

/*-----------------------------------------------------------------------------
	AController — Non-virtual methods.
-----------------------------------------------------------------------------*/

void AController::ShowSelf()
{
	guard(AController::ShowSelf);
	unguard;
}

DWORD AController::SeePawn( APawn* Seen, INT bMaySkipChecks )
{
	guard(AController::SeePawn);
	if( Seen && Pawn )
		return Pawn->R6SeePawn(Seen, bMaySkipChecks);
	return 0;
	unguard;
}

AActor* AController::SetPath( INT bInitialPath )
{
	guard(AController::SetPath);
	return NULL;
	unguard;
}

void AController::SetRouteCache( ANavigationPoint* EndPath, FLOAT StartDist, FLOAT EndDist )
{
	guard(AController::SetRouteCache);
	unguard;
}

DWORD AController::LineOfSightTo( AActor* Other, INT bUseLOSFlag )
{
	guard(AController::LineOfSightTo);
	if ( Other && Pawn )
		return Pawn->R6LineOfSightTo(Other, bUseLOSFlag);
	return 0;
	unguard;
}

INT AController::CanHearSound( FVector SoundLoc, AActor* SoundMaker, FLOAT Loudness, FVector& OutNoiseLoc )
{
	guard(AController::CanHearSound);
	return 0;
	unguard;
}

void AController::CheckEnemyVisible()
{
	guard(AController::CheckEnemyVisible);
	// DIVERGENCE: Ghidra has rdtsc profiling; omitted
	if ( Enemy )
	{
		if ( !LineOfSightTo(Enemy, 0) )
			eventEnemyNotVisible();
	}
	unguard;
}

AActor* AController::FindPath( FVector Dest, AActor* Goal, INT bSinglePath )
{
	guard(AController::FindPath);
	return NULL;
	unguard;
}

AActor* AController::HandleSpecial( AActor* BestPath )
{
	guard(AController::HandleSpecial);
	return BestPath;
	unguard;
}
