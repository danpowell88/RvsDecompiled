/*=============================================================================
	UnPawn.cpp: APawn, AController, APlayerController, AAIController stubs.
=============================================================================*/
#include "EnginePrivate.h"

IMPLEMENT_CLASS(APawn);
IMPLEMENT_CLASS(AController);
IMPLEMENT_CLASS(APlayerController);
IMPLEMENT_CLASS(AAIController);

#define EXEC_STUB(cls,func) void cls::func( FFrame& Stack, RESULT_DECL ) { P_FINISH; }

EXEC_STUB(APawn,execReachedDestination)        IMPLEMENT_FUNCTION( APawn, INDEX_NONE, execReachedDestination );
EXEC_STUB(APawn,execIsFriend)                  IMPLEMENT_FUNCTION( APawn, INDEX_NONE, execIsFriend );
EXEC_STUB(APawn,execIsEnemy)                   IMPLEMENT_FUNCTION( APawn, INDEX_NONE, execIsEnemy );
EXEC_STUB(APawn,execIsNeutral)                 IMPLEMENT_FUNCTION( APawn, INDEX_NONE, execIsNeutral );
EXEC_STUB(APawn,execIsAlive)                   IMPLEMENT_FUNCTION( APawn, INDEX_NONE, execIsAlive );
EXEC_STUB(AController,execMoveTo)              IMPLEMENT_FUNCTION( AController, 500, execMoveTo );
EXEC_STUB(AController,execPollMoveTo)          IMPLEMENT_FUNCTION( AController, INDEX_NONE, execPollMoveTo );
EXEC_STUB(AController,execMoveToward)          IMPLEMENT_FUNCTION( AController, 502, execMoveToward );
EXEC_STUB(AController,execPollMoveToward)      IMPLEMENT_FUNCTION( AController, INDEX_NONE, execPollMoveToward );
EXEC_STUB(AController,execFinishRotation)      IMPLEMENT_FUNCTION( AController, 508, execFinishRotation );
EXEC_STUB(AController,execPollFinishRotation)  IMPLEMENT_FUNCTION( AController, INDEX_NONE, execPollFinishRotation );
EXEC_STUB(AController,execWaitForLanding)      IMPLEMENT_FUNCTION( AController, 527, execWaitForLanding );
EXEC_STUB(AController,execPollWaitForLanding)  IMPLEMENT_FUNCTION( AController, INDEX_NONE, execPollWaitForLanding );
EXEC_STUB(AController,execLineOfSightTo)       IMPLEMENT_FUNCTION( AController, 514, execLineOfSightTo );
EXEC_STUB(AController,execCanSee)              IMPLEMENT_FUNCTION( AController, INDEX_NONE, execCanSee );
EXEC_STUB(AController,execFindPathToward)      IMPLEMENT_FUNCTION( AController, 517, execFindPathToward );
EXEC_STUB(AController,execFindPathTowardNearest) IMPLEMENT_FUNCTION( AController, INDEX_NONE, execFindPathTowardNearest );
EXEC_STUB(AController,execFindPathTo)          IMPLEMENT_FUNCTION( AController, 518, execFindPathTo );
EXEC_STUB(AController,execactorReachable)      IMPLEMENT_FUNCTION( AController, 520, execactorReachable );
EXEC_STUB(AController,execpointReachable)      IMPLEMENT_FUNCTION( AController, 521, execpointReachable );
EXEC_STUB(AController,execClearPaths)          IMPLEMENT_FUNCTION( AController, 522, execClearPaths );
EXEC_STUB(AController,execEAdjustJump)         IMPLEMENT_FUNCTION( AController, 523, execEAdjustJump );
EXEC_STUB(AController,execFindRandomDest)      IMPLEMENT_FUNCTION( AController, 525, execFindRandomDest );
EXEC_STUB(AController,execPickWallAdjust)      IMPLEMENT_FUNCTION( AController, 526, execPickWallAdjust );
EXEC_STUB(AController,execAddController)       IMPLEMENT_FUNCTION( AController, 529, execAddController );
EXEC_STUB(AController,execRemoveController)    IMPLEMENT_FUNCTION( AController, 530, execRemoveController );
EXEC_STUB(AController,execPickTarget)          IMPLEMENT_FUNCTION( AController, 531, execPickTarget );
EXEC_STUB(AController,execPickAnyTarget)       IMPLEMENT_FUNCTION( AController, 534, execPickAnyTarget );
EXEC_STUB(AController,execFindBestInventoryPath) IMPLEMENT_FUNCTION( AController, 540, execFindBestInventoryPath );
EXEC_STUB(AController,execEndClimbLadder)      IMPLEMENT_FUNCTION( AController, INDEX_NONE, execEndClimbLadder );
EXEC_STUB(AController,execInLatentExecution)   IMPLEMENT_FUNCTION( AController, INDEX_NONE, execInLatentExecution );
EXEC_STUB(AController,execStopWaiting)         IMPLEMENT_FUNCTION( AController, INDEX_NONE, execStopWaiting );
EXEC_STUB(APlayerController,execFindStairRotation) IMPLEMENT_FUNCTION( APlayerController, 524, execFindStairRotation );
EXEC_STUB(APlayerController,execResetKeyboard)     IMPLEMENT_FUNCTION( APlayerController, 544, execResetKeyboard );
EXEC_STUB(APlayerController,execUpdateURL)         IMPLEMENT_FUNCTION( APlayerController, 546, execUpdateURL );
EXEC_STUB(APlayerController,execConsoleCommand)    IMPLEMENT_FUNCTION( APlayerController, INDEX_NONE, execConsoleCommand );
EXEC_STUB(APlayerController,execGetDefaultURL)     IMPLEMENT_FUNCTION( APlayerController, INDEX_NONE, execGetDefaultURL );
EXEC_STUB(APlayerController,execGetEntryLevel)     IMPLEMENT_FUNCTION( APlayerController, INDEX_NONE, execGetEntryLevel );
EXEC_STUB(APlayerController,execSetViewTarget)     IMPLEMENT_FUNCTION( APlayerController, INDEX_NONE, execSetViewTarget );
EXEC_STUB(APlayerController,execClientTravel)      IMPLEMENT_FUNCTION( APlayerController, INDEX_NONE, execClientTravel );
EXEC_STUB(APlayerController,execClientHearSound)   IMPLEMENT_FUNCTION( APlayerController, INDEX_NONE, execClientHearSound );
EXEC_STUB(APlayerController,execGetPlayerNetworkAddress) IMPLEMENT_FUNCTION( APlayerController, INDEX_NONE, execGetPlayerNetworkAddress );
EXEC_STUB(APlayerController,execCopyToClipboard)   IMPLEMENT_FUNCTION( APlayerController, INDEX_NONE, execCopyToClipboard );
EXEC_STUB(APlayerController,execPasteFromClipboard) IMPLEMENT_FUNCTION( APlayerController, INDEX_NONE, execPasteFromClipboard );
EXEC_STUB(APlayerController,execSpecialDestroy)    IMPLEMENT_FUNCTION( APlayerController, INDEX_NONE, execSpecialDestroy );
EXEC_STUB(APlayerController,execPB_CanPlayerSpawn) IMPLEMENT_FUNCTION( APlayerController, 1320, execPB_CanPlayerSpawn );
EXEC_STUB(APlayerController,execGetPBConnectStatus) IMPLEMENT_FUNCTION( APlayerController, INDEX_NONE, execGetPBConnectStatus );
EXEC_STUB(APlayerController,execIsPBEnabled)       IMPLEMENT_FUNCTION( APlayerController, INDEX_NONE, execIsPBEnabled );
EXEC_STUB(APlayerController,execGetKey)            IMPLEMENT_FUNCTION( APlayerController, 2706, execGetKey );
EXEC_STUB(APlayerController,execGetActionKey)      IMPLEMENT_FUNCTION( APlayerController, 2707, execGetActionKey );
EXEC_STUB(APlayerController,execGetEnumName)       IMPLEMENT_FUNCTION( APlayerController, 2708, execGetEnumName );
EXEC_STUB(APlayerController,execChangeInputSet)    IMPLEMENT_FUNCTION( APlayerController, 2709, execChangeInputSet );
EXEC_STUB(APlayerController,execSetKey)            IMPLEMENT_FUNCTION( APlayerController, 2710, execSetKey );
EXEC_STUB(APlayerController,execSetSoundOptions)   IMPLEMENT_FUNCTION( APlayerController, 2713, execSetSoundOptions );
EXEC_STUB(APlayerController,execChangeVolumeTypeLinear) IMPLEMENT_FUNCTION( APlayerController, 2714, execChangeVolumeTypeLinear );
EXEC_STUB(AAIController,execWaitToSeeEnemy)        IMPLEMENT_FUNCTION( AAIController, INDEX_NONE, execWaitToSeeEnemy );
EXEC_STUB(AAIController,execPollWaitToSeeEnemy)    IMPLEMENT_FUNCTION( AAIController, INDEX_NONE, execPollWaitToSeeEnemy );

#undef EXEC_STUB

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
	return Controller && Controller->bIsPlayer ? (APawn*)this : NULL;
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
	guard(APawn::IsFriend_Pawn);
	if( !Other || !Controller || !Other->Controller )
		return 0;
	return 0;
	unguard;
}

INT APawn::IsFriend( INT TeamIndex )
{
	guard(APawn::IsFriend_Team);
	return 0;
	unguard;
}

INT APawn::IsEnemy( APawn* Other )
{
	guard(APawn::IsEnemy);
	if( !Other || !Controller || !Other->Controller )
		return 0;
	return !IsFriend( Other );
	unguard;
}

INT APawn::IsNeutral( APawn* Other )
{
	guard(APawn::IsNeutral);
	return !IsFriend( Other ) && !IsEnemy( Other );
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
	return AActor::CheckOwnerUpdated();
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
	return 0;
	unguard;
}

INT APawn::IsBlockedBy( const AActor* Other ) const
{
	guardSlow(APawn::IsBlockedBy);
	return AActor::IsBlockedBy( Other );
	unguardSlow;
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
	return 0;
	unguard;
}

INT APawn::ReachedDestination( FVector Dest, AActor* GoalActor )
{
	guard(APawn::ReachedDestination);
	// TODO: Check if pawn reached destination within threshold.
	return 0;
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
	// TODO: Pawn-specific ticking (posture, status effects, breathing).
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
	// TODO: Navigation reachability test.
	return 0;
	unguard;
}

void APawn::calcVelocity( FVector AccelDir, FLOAT DeltaTime, FLOAT MaxSpeed, FLOAT Friction, INT bFluid, INT bBraking, INT bBuoyant )
{
	guard(APawn::calcVelocity);
	// TODO: Calculate velocity from acceleration, friction, max speed.
	unguard;
}

INT APawn::moveToward( const FVector& Dest, AActor* GoalActor )
{
	guard(APawn::moveToward);
	// TODO: Move pawn toward destination / goal actor.
	return 1;
	unguard;
}

void APawn::performPhysics( FLOAT DeltaSeconds )
{
	guard(APawn::performPhysics);
	// TODO: Pawn physics dispatch (walking, falling, swimming, flying, ladder).
	unguard;
}

void APawn::physFalling( FLOAT DeltaTime, INT Iterations )
{
	guard(APawn::physFalling);
	// TODO: Pawn falling physics with air control.
	unguard;
}

void APawn::physLadder( FLOAT DeltaTime, INT Iterations )
{
	guard(APawn::physLadder);
	// TODO: Ladder climbing physics.
	unguard;
}

void APawn::physicsRotation( FLOAT DeltaTime, FVector OldVelocity )
{
	guard(APawn::physicsRotation);
	// TODO: Pawn rotation with controller desired rotation.
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
	return 0;
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
	guard(APawn::ClearSerpentine);
	unguard;
}

void APawn::Crouch(INT bClientSimulation)
{
	guard(APawn::Crouch);
	unguard;
}

ETestMoveResult APawn::FindBestJump(FVector Dest)
{
	guard(APawn::FindBestJump);
	return TESTMOVE_Stopped;
	unguard;
}

ETestMoveResult APawn::FindJumpUp(FVector Dest)
{
	guard(APawn::FindJumpUp);
	return TESTMOVE_Stopped;
	unguard;
}

FVector APawn::NewFallVelocity(FVector OldVelocity, FVector OldAcceleration, FLOAT DeltaTime)
{
	guard(APawn::NewFallVelocity);
	return FVector(0,0,0);
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
	unguard;
}

INT APawn::ValidAnchor()
{
	guard(APawn::ValidAnchor);
	return 0;
	unguard;
}

void APawn::ZeroMovementAlpha(INT bZeroX, INT bZeroY, FLOAT Alpha)
{
	guard(APawn::ZeroMovementAlpha);
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
	return 0;
	unguard;
}

INT APawn::checkFloor(FVector Dir, FCheckResult& Hit)
{
	guard(APawn::checkFloor);
	return 0;
	unguard;
}

void APawn::clearPath(ANavigationPoint* Node)
{
	guard(APawn::clearPath);
	unguard;
}

void APawn::clearPaths()
{
	guard(APawn::clearPaths);
	unguard;
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
	return 0;
	unguard;
}

INT APawn::ladderReachable(FVector Dest, INT bClearPath, AActor* GoalActor)
{
	guard(APawn::ladderReachable);
	return 0;
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
	unguard;
}

void APawn::startNewPhysics(FLOAT DeltaTime, INT Iterations)
{
	guard(APawn::startNewPhysics);
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
	guard(AController::GetTeamManager);
	return NULL;
	unguard;
}

INT AController::LocalPlayerController()
{
	guard(AController::LocalPlayerController);
	return 0;
	unguard;
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
	guard(AController::StartAnimPoll);
	unguard;
}

INT AController::CheckAnimFinished( INT Channel )
{
	guard(AController::CheckAnimFinished);
	return 1;
	unguard;
}

INT AController::AcceptNearbyPath( AActor* Goal )
{
	guard(AController::AcceptNearbyPath);
	return 0;
	unguard;
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
	unguard;
}

AActor* AController::GetViewTarget()
{
	guard(AController::GetViewTarget);
	return this;
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
