/*=============================================================================
	UnActor.cpp: AActor and subclass implementation.
	Reconstructed for Ravenshield decompilation project.

	This is the primary home for decompiled AActor method bodies and
	IMPLEMENT_CLASS / IMPLEMENT_FUNCTION registrations for the core
	actor hierarchy (AActor, AInfo, ABrush, AVolume, ALight, etc.).

	The EXEC_STUB / IMPLEMENT_FUNCTION pairs register UnrealScript
	native functions with the VM. The stub bodies are temporary — each
	one will be replaced with the real decompiled implementation as
	work progresses, but the IMPLEMENT_FUNCTION() call beside it will
	remain because it's the permanent registration that tells the VM
	which C++ function to call for a given bytecode index.

	This file is permanent — it mirrors the original Epic source layout
	and will grow as more AActor methods are decompiled.
=============================================================================*/

#include "EnginePrivate.h"

/*-----------------------------------------------------------------------------
	Class registration.
-----------------------------------------------------------------------------*/

IMPLEMENT_CLASS(AActor);
IMPLEMENT_CLASS(AInfo);
IMPLEMENT_CLASS(ABrush);
IMPLEMENT_CLASS(AVolume);
IMPLEMENT_CLASS(AKeypoint);
IMPLEMENT_CLASS(ATriggers);
IMPLEMENT_CLASS(ATrigger);
IMPLEMENT_CLASS(ALight);
IMPLEMENT_CLASS(ANavigationPoint);
IMPLEMENT_CLASS(ASmallNavigationPoint);
IMPLEMENT_CLASS(APhysicsVolume);
IMPLEMENT_CLASS(ADefaultPhysicsVolume);
IMPLEMENT_CLASS(ABlockingVolume);
IMPLEMENT_CLASS(AAntiPortalActor);
IMPLEMENT_CLASS(ANote);
IMPLEMENT_CLASS(APolyMarker);
IMPLEMENT_CLASS(AClipMarker);
IMPLEMENT_CLASS(AStaticMeshActor);
IMPLEMENT_CLASS(AEffects);
IMPLEMENT_CLASS(AAmbientSound);
IMPLEMENT_CLASS(ADecoVolumeObject);
IMPLEMENT_CLASS(ADecorationList);
IMPLEMENT_CLASS(AKActor);
IMPLEMENT_CLASS(AMover);
// AProjector and AShadowProjector registered in UnEffects.cpp
IMPLEMENT_CLASS(AR6MorphMeshActor);
IMPLEMENT_CLASS(AR6ActorSound);
IMPLEMENT_CLASS(AR6Alarm);

/*-----------------------------------------------------------------------------
	AActor native exec function implementations.
	Reconstructed from Ghidra decompilation + SDK parameter signatures.
	P_GET macros extract parameters from the UnrealScript bytecode stack.
	IMPLEMENT_FUNCTION registers each native with the VM at the given index.
-----------------------------------------------------------------------------*/

/*-- Error / Sleep / Lifecycle ------------------------------------------*/

void AActor::execError( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execError);
	P_GET_STR(S);
	P_FINISH;
	debugf( NAME_ScriptWarning, TEXT("%s"), *S );
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 233, execError );

void AActor::execSleep( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execSleep);
	P_GET_FLOAT(Seconds);
	P_FINISH;
	GetStateFrame()->LatentAction = EPOLL_Sleep;
	LatentFloat = Seconds;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 256, execSleep );

void AActor::execPollSleep( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execPollSleep);
	if( LatentFloat <= 0.f )
	{
		GetStateFrame()->LatentAction = 0;
	}
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execPollSleep );

void AActor::execDestroy( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execDestroy);
	P_FINISH;
	*(DWORD*)Result = XLevel->DestroyActor( this );
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 279, execDestroy );

void AActor::execSpawn( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execSpawn);
	P_GET_OBJECT(UClass,SpawnClass);
	P_GET_OBJECT_OPTX(AActor,SpawnOwner,NULL);
	P_GET_NAME_OPTX(SpawnTag,NAME_None);
	P_GET_VECTOR_OPTX(SpawnLocation,Location);
	P_GET_ROTATOR_OPTX(SpawnRotation,Rotation);
	P_GET_UBOOL_OPTX(bNoCollisionFail,0);
	P_FINISH;

	if( !SpawnClass )
	{
		*(AActor**)Result = NULL;
		return;
	}

	AActor* Spawned = XLevel->SpawnActor( SpawnClass, NAME_None, SpawnLocation, SpawnRotation, NULL, bNoCollisionFail, 0, NULL, Instigator );
	if( Spawned && SpawnOwner )
		Spawned->SetOwner( SpawnOwner );
	if( Spawned && SpawnTag != NAME_None )
		Spawned->Tag = SpawnTag;
	*(AActor**)Result = Spawned;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 278, execSpawn );

/*-- Movement & Physics ------------------------------------------------*/

void AActor::execMove( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execMove);
	P_GET_VECTOR(Delta);
	P_FINISH;
	FCheckResult Hit(1.f);
	*(DWORD*)Result = XLevel->MoveActor( this, Delta, Rotation, Hit );
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 266, execMove );

void AActor::execMoveSmooth( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execMoveSmooth);
	P_GET_VECTOR(Delta);
	P_FINISH;
	FCheckResult Hit(1.f);
	*(DWORD*)Result = XLevel->MoveActor( this, Delta, Rotation, Hit );
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 3969, execMoveSmooth );

void AActor::execSetLocation( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execSetLocation);
	P_GET_VECTOR(NewLocation);
	P_GET_UBOOL_OPTX(bNoCheck,0);
	P_FINISH;
	*(DWORD*)Result = XLevel->FarMoveActor( this, NewLocation, 0, bNoCheck );
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 267, execSetLocation );

void AActor::execSetRotation( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execSetRotation);
	P_GET_ROTATOR(NewRotation);
	P_FINISH;
	FCheckResult Hit(1.f);
	*(DWORD*)Result = XLevel->MoveActor( this, FVector(0,0,0), NewRotation, Hit );
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 299, execSetRotation );

void AActor::execSetRelativeLocation( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execSetRelativeLocation);
	P_GET_VECTOR(NewLocation);
	P_FINISH;
	if( Base )
		*(DWORD*)Result = XLevel->FarMoveActor( this, Base->Location + NewLocation );
	else
		*(DWORD*)Result = XLevel->FarMoveActor( this, NewLocation );
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execSetRelativeLocation );

void AActor::execSetRelativeRotation( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execSetRelativeRotation);
	P_GET_ROTATOR(NewRotation);
	P_FINISH;
	FCheckResult Hit(1.f);
	if( Base )
		*(DWORD*)Result = XLevel->MoveActor( this, FVector(0,0,0), Base->Rotation + NewRotation, Hit );
	else
		*(DWORD*)Result = XLevel->MoveActor( this, FVector(0,0,0), NewRotation, Hit );
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execSetRelativeRotation );

void AActor::execSetPhysics( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execSetPhysics);
	P_GET_BYTE(NewPhysics);
	P_FINISH;
	setPhysics( NewPhysics, NULL, FVector(0,0,0) );
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 3970, execSetPhysics );

void AActor::execAutonomousPhysics( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execAutonomousPhysics);
	P_GET_FLOAT(DeltaSeconds);
	P_FINISH;
	// Autonomous physics simulation for client-side prediction.
	performPhysics( DeltaSeconds );
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 3971, execAutonomousPhysics );

/*-- Collision ---------------------------------------------------------*/

void AActor::execSetCollision( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execSetCollision);
	P_GET_UBOOL_OPTX(NewColActors,bCollideActors);
	P_GET_UBOOL_OPTX(NewBlockActors,bBlockActors);
	P_GET_UBOOL_OPTX(NewBlockPlayers,bBlockPlayers);
	P_FINISH;
	SetCollision( NewColActors, NewBlockActors, NewBlockPlayers );
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 262, execSetCollision );

void AActor::execSetCollisionSize( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execSetCollisionSize);
	P_GET_FLOAT(NewRadius);
	P_GET_FLOAT(NewHeight);
	P_FINISH;
	SetCollisionSize( NewRadius, NewHeight );
	*(DWORD*)Result = 1;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 283, execSetCollisionSize );

/*-- Timers ------------------------------------------------------------*/

void AActor::execSetTimer( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execSetTimer);
	P_GET_FLOAT(NewTimerRate);
	P_GET_UBOOL_OPTX(bLoop,0);
	P_FINISH;
	TimerRate    = NewTimerRate;
	TimerCounter = 0.f;
	bTimerLoop   = bLoop;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 280, execSetTimer );

/*-- Owner / Base ------------------------------------------------------*/

void AActor::execSetOwner( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execSetOwner);
	P_GET_OBJECT(AActor,NewOwner);
	P_FINISH;
	SetOwner( NewOwner );
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 272, execSetOwner );

void AActor::execSetBase( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execSetBase);
	P_GET_OBJECT(AActor,NewBase);
	P_GET_VECTOR_OPTX(NewFloor,FVector(0,0,1));
	P_FINISH;
	SetBase( NewBase, NewFloor, 0 );
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 298, execSetBase );

/*-- Trace / Collision queries -----------------------------------------*/

void AActor::execTrace( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execTrace);
	P_GET_VECTOR_REF(HitLocation);
	P_GET_VECTOR_REF(HitNormal);
	P_GET_VECTOR(TraceEnd);
	P_GET_VECTOR_OPTX(TraceStart,Location);
	P_GET_UBOOL_OPTX(bTraceActors,bCollideActors);
	P_GET_VECTOR_OPTX(Extent,FVector(0,0,0));
	P_GET_OBJECT_REF(UMaterial,Material);
	P_FINISH;

	FCheckResult Hit(1.f);
	DWORD TraceFlags = TRACE_World | TRACE_Level;
	if( bTraceActors )
		TraceFlags |= TRACE_Pawns | TRACE_Others;

	AActor* HitActor = XLevel->SingleLineCheck( Hit, this, TraceEnd, TraceStart, TraceFlags, Extent ) ? NULL : Hit.Actor;
	*HitLocation = Hit.Location;
	*HitNormal   = Hit.Normal;
	*Material    = Hit.Material ? Hit.Material->GetOuter() && Hit.Material->IsA(UMaterial::StaticClass()) ? (UMaterial*)Hit.Material : NULL : NULL;
	*(AActor**)Result = HitActor;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 277, execTrace );

void AActor::execFastTrace( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execFastTrace);
	P_GET_VECTOR(TraceEnd);
	P_GET_VECTOR_OPTX(TraceStart,Location);
	P_FINISH;
	FCheckResult Hit(1.f);
	*(DWORD*)Result = !XLevel->SingleLineCheck( Hit, this, TraceEnd, TraceStart, TRACE_World | TRACE_Level, FVector(0,0,0) );
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 548, execFastTrace );

void AActor::execR6Trace( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execR6Trace);
	P_GET_VECTOR_REF(HitLocation);
	P_GET_VECTOR_REF(HitNormal);
	P_GET_VECTOR(TraceEnd);
	P_GET_VECTOR_OPTX(TraceStart,Location);
	P_GET_INT_OPTX(iTraceFlags,0);
	P_GET_VECTOR_OPTX(Extent,FVector(0,0,0));
	P_GET_OBJECT_REF(UMaterial,Material);
	P_FINISH;

	FCheckResult Hit(1.f);
	DWORD TraceFlags = TRACE_World | TRACE_Level | iTraceFlags;

	AActor* HitActor = XLevel->SingleLineCheck( Hit, this, TraceEnd, TraceStart, TraceFlags, Extent ) ? NULL : Hit.Actor;
	*HitLocation = Hit.Location;
	*HitNormal   = Hit.Normal;
	*Material    = NULL;
	*(AActor**)Result = HitActor;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 1806, execR6Trace );

void AActor::execFindSpot( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execFindSpot);
	P_GET_VECTOR_REF(vLocation);
	P_GET_VECTOR(vExtent);
	P_FINISH;
	*(DWORD*)Result = XLevel->FindSpot( vExtent, *vLocation );
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 1800, execFindSpot );

/*-- Animation ---------------------------------------------------------*/

void AActor::execPlayAnim( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execPlayAnim);
	P_GET_NAME(Sequence);
	P_GET_FLOAT_OPTX(Rate,1.f);
	P_GET_FLOAT_OPTX(TweenTime,0.f);
	P_GET_INT_OPTX(Channel,0);
	P_GET_UBOOL_OPTX(bBackward,0);
	P_GET_UBOOL_OPTX(bForceAnimRate,0);
	P_FINISH;
	PlayAnim( Channel, Sequence, Rate, TweenTime, 0, bBackward, bForceAnimRate );
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 259, execPlayAnim );

void AActor::execLoopAnim( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execLoopAnim);
	P_GET_NAME(Sequence);
	P_GET_FLOAT_OPTX(Rate,1.f);
	P_GET_FLOAT_OPTX(TweenTime,0.f);
	P_GET_INT_OPTX(Channel,0);
	P_GET_UBOOL_OPTX(bBackward,0);
	P_GET_UBOOL_OPTX(bForceAnimRate,0);
	P_FINISH;
	PlayAnim( Channel, Sequence, Rate, TweenTime, 1, bBackward, bForceAnimRate );
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 260, execLoopAnim );

void AActor::execTweenAnim( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execTweenAnim);
	P_GET_NAME(Sequence);
	P_GET_FLOAT_OPTX(Time,1.f);
	P_GET_INT_OPTX(Channel,0);
	P_FINISH;
	PlayAnim( Channel, Sequence, 0.0f, Time, 0, 0, 0 );
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 294, execTweenAnim );

void AActor::execFinishAnim( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execFinishAnim);
	P_GET_INT_OPTX(Channel,0);
	P_FINISH;
	LatentFloat = (FLOAT)Channel;
	GetStateFrame()->LatentAction = EPOLL_FinishAnim;
	StartAnimPoll();
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 261, execFinishAnim );

void AActor::execPollFinishAnim( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execPollFinishAnim);
	if( !IsAnimating( appRound( LatentFloat ) ) )
		GetStateFrame()->LatentAction = 0;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execPollFinishAnim );

void AActor::execStopAnimating( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execStopAnimating);
	P_GET_UBOOL_OPTX(ClearAllButBase,0);
	P_FINISH;
	if( Mesh )
	{
		Mesh->MeshGetInstance( this );
		if( MeshInstance )
			MeshInstance->StopAnimating( ClearAllButBase );
	}
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execStopAnimating );

void AActor::execIsAnimating( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execIsAnimating);
	P_GET_INT_OPTX(Channel,0);
	P_FINISH;
	*(DWORD*)Result = IsAnimating( Channel );
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 282, execIsAnimating );

void AActor::execIsTweening( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execIsTweening);
	P_GET_INT_OPTX(Channel,0);
	P_FINISH;
	*(DWORD*)Result = 0;
	if( Mesh )
	{
		Mesh->MeshGetInstance( this );
		if( MeshInstance )
			*(DWORD*)Result = MeshInstance->IsAnimTweening( Channel ) ? 1 : 0;
	}
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execIsTweening );

void AActor::execHasAnim( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execHasAnim);
	P_GET_NAME(Sequence);
	P_FINISH;
	*(UBOOL*)Result = 0;
	if( Mesh )
	{
		Mesh->MeshGetInstance( this );
		if( MeshInstance )
			*(UBOOL*)Result = (MeshInstance->GetAnimNamed( Sequence ) != NULL) ? 1 : 0;
	}
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 263, execHasAnim );

void AActor::execGetAnimGroup( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execGetAnimGroup);
	P_GET_NAME(Sequence);
	P_FINISH;
	*(FName*)Result = NAME_None;
	if( Mesh )
	{
		Mesh->MeshGetInstance( this );
		if( MeshInstance )
		{
			void* seqObj = MeshInstance->GetAnimNamed( Sequence );
			if( seqObj )
				*(FName*)Result = MeshInstance->AnimGetGroup( seqObj );
		}
	}
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 1500, execGetAnimGroup );

void AActor::execGetAnimParams( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execGetAnimParams);
	P_GET_INT_OPTX(Channel,0);
	P_GET_NAME_REF(OutSeqName);
	P_GET_FLOAT_REF(OutAnimFrame);
	P_GET_FLOAT_REF(OutAnimRate);
	P_FINISH;
	if( Mesh )
	{
		Mesh->MeshGetInstance( this );
		if( MeshInstance )
		{
			*OutSeqName   = MeshInstance->GetActiveAnimSequence( Channel );
			*OutAnimFrame = MeshInstance->GetActiveAnimFrame( Channel );
			*OutAnimRate  = MeshInstance->GetActiveAnimRate( Channel );
			return;
		}
	}
	*OutSeqName   = NAME_None;
	*OutAnimFrame = 0.f;
	*OutAnimRate  = 0.f;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execGetAnimParams );

void AActor::execAnimBlendParams( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execAnimBlendParams);
	P_GET_INT(Stage);
	P_GET_FLOAT_OPTX(BlendAlpha,0.f);
	P_GET_FLOAT_OPTX(InTime,0.f);
	P_GET_FLOAT_OPTX(OutTime,0.f);
	P_GET_NAME_OPTX(BoneName,NAME_None);
	P_FINISH;
	if( Mesh )
	{
		Mesh->MeshGetInstance( this );
		if( USkeletalMeshInstance* MI = Cast<USkeletalMeshInstance>( MeshInstance ) )
			MI->SetBlendParams( Stage, BlendAlpha, InTime, OutTime, BoneName, INDEX_NONE );
	}
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execAnimBlendParams );

void AActor::execAnimBlendToAlpha( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execAnimBlendToAlpha);
	P_GET_INT(Stage);
	P_GET_FLOAT(TargetAlpha);
	P_GET_FLOAT(TimeInterval);
	P_FINISH;
	if( Mesh )
	{
		Mesh->MeshGetInstance( this );
		if( USkeletalMeshInstance* MI = Cast<USkeletalMeshInstance>( MeshInstance ) )
			MI->BlendToAlpha( Stage, TargetAlpha, TimeInterval );
	}
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execAnimBlendToAlpha );

void AActor::execGetAnimBlendAlpha( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execGetAnimBlendAlpha);
	P_GET_INT(Stage);
	P_FINISH;
	*(FLOAT*)Result = 0.f;
	if( Mesh )
	{
		Mesh->MeshGetInstance( this );
		if( USkeletalMeshInstance* MI = Cast<USkeletalMeshInstance>( MeshInstance ) )
			*(FLOAT*)Result = MI->GetBlendAlpha( Stage );
	}
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 2208, execGetAnimBlendAlpha );

void AActor::execAnimIsInGroup( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execAnimIsInGroup);
	P_GET_INT_OPTX(Channel,0);
	P_GET_NAME(Group);
	P_FINISH;
	*(DWORD*)Result = 0;
	if( Mesh )
	{
		Mesh->MeshGetInstance( this );
		if( MeshInstance )
		{
			FName seqName = MeshInstance->GetActiveAnimSequence( Channel );
			void* seqObj  = MeshInstance->GetAnimNamed( seqName );
			if( seqObj )
				*(DWORD*)Result = MeshInstance->AnimIsInGroup( seqObj, Group ) ? 1 : 0;
		}
	}
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execAnimIsInGroup );

void AActor::execFreezeAnimAt( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execFreezeAnimAt);
	P_GET_FLOAT(Time);
	P_GET_INT_OPTX(Channel,0);
	P_FINISH;
	if( Mesh )
	{
		Mesh->MeshGetInstance( this );
		if( MeshInstance )
			MeshInstance->FreezeAnimAt( Time, Channel );
	}
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execFreezeAnimAt );

void AActor::execGetNotifyChannel( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execGetNotifyChannel);
	P_FINISH;
	*(INT*)Result = 0;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execGetNotifyChannel );

void AActor::execEnableChannelNotify( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execEnableChannelNotify);
	P_GET_INT(Channel);
	P_GET_INT(Switch);
	P_FINISH;
	if( Mesh )
	{
		Mesh->MeshGetInstance( this );
		if( USkeletalMeshInstance* MI = Cast<USkeletalMeshInstance>( MeshInstance ) )
			MI->EnableChannelNotify( Channel, Switch );
	}
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execEnableChannelNotify );

void AActor::execClearChannel( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execClearChannel);
	P_GET_INT(Channel);
	P_FINISH;
	if( Mesh )
	{
		Mesh->MeshGetInstance( this );
		if( MeshInstance )
			MeshInstance->ClearChannel( Channel );
	}
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 1805, execClearChannel );

/*-- Skeletal mesh / Bone control --------------------------------------*/

void AActor::execLinkMesh( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execLinkMesh);
	P_GET_OBJECT(UMesh,NewMesh);
	P_GET_UBOOL_OPTX(bKeepAnim,0);
	P_FINISH;
	Mesh = NewMesh;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execLinkMesh );

void AActor::execLinkSkelAnim( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execLinkSkelAnim);
	P_GET_OBJECT(UMeshAnimation,Anim);
	P_GET_OBJECT_OPTX(UMesh,NewMesh,NULL);
	P_FINISH;
	if( Mesh )
	{
		Mesh->MeshGetInstance( this );
		if( USkeletalMeshInstance* MI = Cast<USkeletalMeshInstance>( MeshInstance ) )
			MI->SetSkelAnim( Anim, Cast<USkeletalMesh>( NewMesh ) );
	}
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execLinkSkelAnim );

void AActor::execUnLinkSkelAnim( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execUnLinkSkelAnim);
	P_FINISH;
	if( Mesh )
	{
		Mesh->MeshGetInstance( this );
		if( USkeletalMeshInstance* MI = Cast<USkeletalMeshInstance>( MeshInstance ) )
			MI->SetSkelAnim( NULL, NULL );
	}
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 2210, execUnLinkSkelAnim );

void AActor::execWasSkeletonUpdated( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execWasSkeletonUpdated);
	P_FINISH;
	*(DWORD*)Result = 0;
	if( Mesh )
	{
		Mesh->MeshGetInstance( this );
		if( USkeletalMeshInstance* MI = Cast<USkeletalMeshInstance>( MeshInstance ) )
			*(DWORD*)Result = MI->WasSkeletonUpdated() ? 1 : 0;
	}
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 1501, execWasSkeletonUpdated );

void AActor::execLockRootMotion( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execLockRootMotion);
	P_GET_INT(Lock);
	P_GET_UBOOL_OPTX(bUseRootRotation,0);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execLockRootMotion );

void AActor::execGetRootLocation( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execGetRootLocation);
	P_FINISH;
	*(FVector*)Result = Location;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execGetRootLocation );

void AActor::execGetRootLocationDelta( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execGetRootLocationDelta);
	P_FINISH;
	*(FVector*)Result = FVector(0,0,0);
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execGetRootLocationDelta );

void AActor::execGetRootRotation( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execGetRootRotation);
	P_FINISH;
	*(FRotator*)Result = Rotation;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execGetRootRotation );

void AActor::execGetRootRotationDelta( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execGetRootRotationDelta);
	P_FINISH;
	*(FRotator*)Result = FRotator(0,0,0);
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execGetRootRotationDelta );

void AActor::execGetBoneCoords( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execGetBoneCoords);
	P_GET_NAME(BoneName);
	P_GET_UBOOL_OPTX(bDontCallGetFrame,0);
	P_FINISH;
	*(FCoords*)Result = GMath.UnitCoords; // TODO: Mesh ? Mesh->GetBoneCoords( this, BoneName ) : GMath.UnitCoords;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execGetBoneCoords );

void AActor::execGetBoneRotation( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execGetBoneRotation);
	P_GET_NAME(BoneName);
	P_GET_INT_OPTX(Space,0);
	P_FINISH;
	*(FRotator*)Result = FRotator(0,0,0); // TODO: Mesh ? Mesh->GetBoneRotation( this, BoneName, Space ) : FRotator(0,0,0);
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execGetBoneRotation );

void AActor::execSetBoneRotation( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execSetBoneRotation);
	P_GET_NAME(BoneName);
	P_GET_ROTATOR_OPTX(BoneTurn,FRotator(0,0,0));
	P_GET_INT_OPTX(Space,0);
	P_GET_FLOAT_OPTX(Alpha,1.f);
	P_GET_FLOAT_OPTX(InTime,0.f);
	P_FINISH;
	if( Mesh )
		; // TODO: Mesh->SetBoneRotation( this, BoneName, BoneTurn, Space, Alpha );
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execSetBoneRotation );

void AActor::execSetBoneDirection( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execSetBoneDirection);
	P_GET_NAME(BoneName);
	P_GET_ROTATOR(Dir);
	P_GET_FLOAT_OPTX(Alpha,1.f);
	P_GET_INT_OPTX(Space,0);
	P_FINISH;
	if( Mesh )
		; // TODO: Mesh->SetBoneDirection( this, BoneName, Dir, Alpha, Space );
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execSetBoneDirection );

void AActor::execSetBoneLocation( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execSetBoneLocation);
	P_GET_NAME(BoneName);
	P_GET_VECTOR_OPTX(BoneTrans,FVector(0,0,0));
	P_GET_FLOAT_OPTX(Alpha,1.f);
	P_FINISH;
	if( Mesh )
		; // TODO: Mesh->SetBoneLocation( this, BoneName, BoneTrans, Alpha );
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execSetBoneLocation );

void AActor::execSetBoneScale( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execSetBoneScale);
	P_GET_INT(Slot);
	P_GET_FLOAT_OPTX(BoneScale,1.f);
	P_GET_NAME_OPTX(BoneName,NAME_None);
	P_FINISH;
	if( Mesh )
		; // TODO: Mesh->SetBoneScale( this, Slot, BoneScale, BoneName );
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execSetBoneScale );

void AActor::execGetRenderBoundingSphere( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execGetRenderBoundingSphere);
	P_FINISH;
	*(FVector*)Result = Location;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execGetRenderBoundingSphere );

void AActor::execAttachToBone( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execAttachToBone);
	P_GET_OBJECT(AActor,Attachment);
	P_GET_NAME(BoneName);
	P_FINISH;
	*(DWORD*)Result = 0; // TODO: Mesh ? Mesh->AttachToBone( this, Attachment, BoneName ) : 0;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execAttachToBone );

void AActor::execDetachFromBone( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execDetachFromBone);
	P_GET_OBJECT(AActor,Attachment);
	P_FINISH;
	*(DWORD*)Result = 0; // TODO: Mesh ? Mesh->DetachFromBone( this, Attachment ) : 0;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execDetachFromBone );

/*-- Sound dispatch hooks -----------------------------------------------*/

void AActor::execPlaySound( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execPlaySound);
	P_GET_OBJECT(USound,Sound);
	P_GET_BYTE_OPTX(Slot,0);
	P_FINISH;
	if( Sound && XLevel && XLevel->Engine )
	{
		// TODO: Audio subsystem not yet a member of UEngine. Stub.
	}
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 264, execPlaySound );

void AActor::execPlayOwnedSound( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execPlayOwnedSound);
	P_GET_OBJECT(USound,Sound);
	P_GET_BYTE_OPTX(Slot,0);
	P_GET_FLOAT_OPTX(Volume,1.f);
	P_GET_UBOOL_OPTX(bNoOverride,0);
	P_GET_FLOAT_OPTX(Radius,0.f);
	P_GET_FLOAT_OPTX(Pitch,1.f);
	P_GET_UBOOL_OPTX(Attenuate,1);
	P_FINISH;
	// TODO: Audio subsystem not yet a member of UEngine. Stub.
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execPlayOwnedSound );

void AActor::execDemoPlaySound( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execDemoPlaySound);
	P_GET_OBJECT(USound,Sound);
	P_GET_BYTE_OPTX(Slot,0);
	P_GET_FLOAT_OPTX(Volume,1.f);
	P_GET_UBOOL_OPTX(bNoOverride,0);
	P_GET_FLOAT_OPTX(Radius,0.f);
	P_GET_FLOAT_OPTX(Pitch,1.f);
	P_GET_UBOOL_OPTX(Attenuate,1);
	P_FINISH;
	// TODO: Audio subsystem not yet a member of UEngine. Stub.
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execDemoPlaySound );

void AActor::execMakeNoise( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execMakeNoise);
	P_GET_FLOAT(Loudness);
	P_GET_BYTE_OPTX(eNoise,0);
	P_GET_BYTE_OPTX(ePawn,0);
	P_GET_BYTE_OPTX(eSoundType,0);
	P_FINISH;
	// Noise propagation for AI hearing.
	// Update noise fields on the making pawn (if applicable).
	APawn* NoisePawn = Instigator ? Instigator : Cast<APawn>(this);
	if( NoisePawn )
	{
		NoisePawn->noiseTime     = Level->TimeSeconds;
		NoisePawn->noiseLoudness = Loudness;
		NoisePawn->noiseType     = eNoise;
	}
	CheckNoiseHearing( Loudness, (ENoiseType)eNoise, (EPawnType)ePawn, (ESoundType)eSoundType );
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 512, execMakeNoise );

void AActor::execIsPlayingSound( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execIsPlayingSound);
	P_GET_OBJECT(AActor,aActor);
	P_GET_OBJECT(USound,Sound);
	P_FINISH;
	*(DWORD*)Result = 0;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 2703, execIsPlayingSound );

void AActor::execPlayMusic( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execPlayMusic);
	P_GET_OBJECT(USound,Music);
	P_GET_UBOOL_OPTX(bForcePlayMusic,0);
	P_FINISH;
	*(DWORD*)Result = 0;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execPlayMusic );

void AActor::execStopMusic( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execStopMusic);
	P_GET_OBJECT(USound,StopMusic);
	P_FINISH;
	*(DWORD*)Result = 0;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execStopMusic );

void AActor::execStopAllMusic( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execStopAllMusic);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execStopAllMusic );

void AActor::execStopAllSounds( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execStopAllSounds);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 2712, execStopAllSounds );

void AActor::execStopAllSoundsActor( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execStopAllSoundsActor);
	P_GET_OBJECT(AActor,aActor);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 2719, execStopAllSoundsActor );

void AActor::execStopSound( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execStopSound);
	P_GET_OBJECT(USound,Sound);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 2725, execStopSound );

void AActor::execFadeSound( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execFadeSound);
	P_GET_FLOAT(fTime);
	P_GET_INT_OPTX(iFade,0);
	P_GET_BYTE_OPTX(eSlot,0);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 2721, execFadeSound );

void AActor::execAddSoundBank( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execAddSoundBank);
	P_GET_STR(BankName);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 2716, execAddSoundBank );

void AActor::execAddAndFindBankInSound( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execAddAndFindBankInSound);
	P_GET_STR(BankName);
	P_GET_NAME(SoundName);
	P_FINISH;
	*(USound**)Result = NULL;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 2717, execAddAndFindBankInSound );

void AActor::execResetVolume_AllTypeSound( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execResetVolume_AllTypeSound);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 2704, execResetVolume_AllTypeSound );

void AActor::execResetVolume_TypeSound( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execResetVolume_TypeSound);
	P_GET_BYTE(SoundType);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 2720, execResetVolume_TypeSound );

void AActor::execChangeVolumeType( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execChangeVolumeType);
	P_GET_BYTE(VolumeType);
	P_GET_INT(NewVolume);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 2705, execChangeVolumeType );

void AActor::execSaveCurrentFadeValue( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execSaveCurrentFadeValue);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 2722, execSaveCurrentFadeValue );

void AActor::execReturnSavedFadeValue( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execReturnSavedFadeValue);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 2723, execReturnSavedFadeValue );

void AActor::execGetSoundDuration( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execGetSoundDuration);
	P_GET_OBJECT(USound,Sound);
	P_FINISH;
	*(FLOAT*)Result = 0.f;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execGetSoundDuration );

/*-- Visual property setters -------------------------------------------*/

void AActor::execSetDrawScale( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execSetDrawScale);
	P_GET_FLOAT(NewScale);
	P_FINISH;
	SetDrawScale( NewScale );
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execSetDrawScale );

void AActor::execSetDrawScale3D( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execSetDrawScale3D);
	P_GET_VECTOR(NewScale3D);
	P_FINISH;
	SetDrawScale3D( NewScale3D );
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execSetDrawScale3D );

void AActor::execSetDrawType( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execSetDrawType);
	P_GET_BYTE(NewDrawType);
	P_FINISH;
	SetDrawType( (EDrawType)NewDrawType );
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execSetDrawType );

void AActor::execSetStaticMesh( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execSetStaticMesh);
	P_GET_OBJECT(UStaticMesh,NewStaticMesh);
	P_FINISH;
	SetStaticMesh( NewStaticMesh );
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execSetStaticMesh );

void AActor::execOnlyAffectPawns( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execOnlyAffectPawns);
	P_GET_UBOOL(bNewOnlyAffectPawns);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execOnlyAffectPawns );

void AActor::execFinishInterpolation( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execFinishInterpolation);
	P_FINISH;
	GetStateFrame()->LatentAction = EPOLL_FinishInterpolation;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 301, execFinishInterpolation );

void AActor::execPollFinishInterpolation( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execPollFinishInterpolation);
	if( Physics != PHYS_Interpolating )
		GetStateFrame()->LatentAction = 0;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execPollFinishInterpolation );

/*-- Actor iterators ---------------------------------------------------*/

void AActor::execAllActors( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execAllActors);
	P_GET_OBJECT(UClass,BaseClass);
	P_GET_OBJECT_REF(AActor,Actor);
	P_GET_NAME_OPTX(MatchTag,NAME_None);
	P_FINISH;

	INT iActor = 0;
	PRE_ITERATOR;
		*Actor = NULL;
		while( iActor < XLevel->Actors.Num() )
		{
			*Actor = XLevel->Actors(iActor++);
			if( *Actor && (*Actor)->IsA(BaseClass) )
			{
				if( MatchTag == NAME_None || (*Actor)->Tag == MatchTag )
					break;
			}
			*Actor = NULL;
		}
		if( *Actor == NULL )
		{
			Stack.Code = &Stack.Node->Script(wEndOffset + 1);
			break;
		}
	POST_ITERATOR;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 304, execAllActors );

void AActor::execDynamicActors( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execDynamicActors);
	P_GET_OBJECT(UClass,BaseClass);
	P_GET_OBJECT_REF(AActor,Actor);
	P_GET_NAME_OPTX(MatchTag,NAME_None);
	P_FINISH;

	INT iActor = 0;
	PRE_ITERATOR;
		*Actor = NULL;
		while( iActor < XLevel->Actors.Num() )
		{
			*Actor = XLevel->Actors(iActor++);
			if( *Actor && !(*Actor)->bStatic && !(*Actor)->bNoDelete && (*Actor)->IsA(BaseClass) )
			{
				if( MatchTag == NAME_None || (*Actor)->Tag == MatchTag )
					break;
			}
			*Actor = NULL;
		}
		if( *Actor == NULL )
		{
			Stack.Code = &Stack.Node->Script(wEndOffset + 1);
			break;
		}
	POST_ITERATOR;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 313, execDynamicActors );

void AActor::execChildActors( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execChildActors);
	P_GET_OBJECT(UClass,BaseClass);
	P_GET_OBJECT_REF(AActor,Actor);
	P_FINISH;

	INT iActor = 0;
	PRE_ITERATOR;
		*Actor = NULL;
		while( iActor < XLevel->Actors.Num() )
		{
			*Actor = XLevel->Actors(iActor++);
			if( *Actor && (*Actor)->IsOwnedBy(this) && (*Actor)->IsA(BaseClass) )
				break;
			*Actor = NULL;
		}
		if( *Actor == NULL )
		{
			Stack.Code = &Stack.Node->Script(wEndOffset + 1);
			break;
		}
	POST_ITERATOR;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 305, execChildActors );

void AActor::execBasedActors( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execBasedActors);
	P_GET_OBJECT(UClass,BaseClass);
	P_GET_OBJECT_REF(AActor,Actor);
	P_FINISH;

	INT iActor = 0;
	PRE_ITERATOR;
		*Actor = NULL;
		while( iActor < XLevel->Actors.Num() )
		{
			*Actor = XLevel->Actors(iActor++);
			if( *Actor && (*Actor)->Base == this && (*Actor)->IsA(BaseClass) )
				break;
			*Actor = NULL;
		}
		if( *Actor == NULL )
		{
			Stack.Code = &Stack.Node->Script(wEndOffset + 1);
			break;
		}
	POST_ITERATOR;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 306, execBasedActors );

void AActor::execTouchingActors( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execTouchingActors);
	P_GET_OBJECT(UClass,BaseClass);
	P_GET_OBJECT_REF(AActor,Actor);
	P_FINISH;

	INT iTouch = 0;
	PRE_ITERATOR;
		*Actor = NULL;
		while( iTouch < Touching.Num() )
		{
			*Actor = Touching(iTouch++);
			if( *Actor && (*Actor)->IsA(BaseClass) )
				break;
			*Actor = NULL;
		}
		if( *Actor == NULL )
		{
			Stack.Code = &Stack.Node->Script(wEndOffset + 1);
			break;
		}
	POST_ITERATOR;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 307, execTouchingActors );

void AActor::execTraceActors( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execTraceActors);
	P_GET_OBJECT(UClass,BaseClass);
	P_GET_OBJECT_REF(AActor,Actor);
	P_GET_VECTOR_REF(HitLoc);
	P_GET_VECTOR_REF(HitNorm);
	P_GET_VECTOR(End);
	P_GET_VECTOR_OPTX(Start,Location);
	P_GET_VECTOR_OPTX(Extent,FVector(0,0,0));
	P_FINISH;

	// GSceneMem is a rendering-phase allocation stack not yet declared as global;
	// GMem (Core global) is an acceptable substitute for per-call iterator results.
	FCheckResult* Link = XLevel->MultiLineCheck( GMem, End, Start, Extent, XLevel->GetLevelInfo(), TRACE_AllColliding, this );
	FCheckResult* Current = Link;
	PRE_ITERATOR;
		*Actor = NULL;
		while( Current )
		{
			if( Current->Actor && Current->Actor->IsA(BaseClass) )
			{
				*Actor   = Current->Actor;
				*HitLoc  = Current->Location;
				*HitNorm = Current->Normal;
				Current  = Current->GetNext();
				break;
			}
			Current = Current->GetNext();
		}
		if( *Actor == NULL )
		{
			Stack.Code = &Stack.Node->Script(wEndOffset + 1);
			break;
		}
	POST_ITERATOR;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 309, execTraceActors );

void AActor::execRadiusActors( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execRadiusActors);
	P_GET_OBJECT(UClass,BaseClass);
	P_GET_OBJECT_REF(AActor,Actor);
	P_GET_FLOAT(Radius);
	P_GET_VECTOR_OPTX(Loc,Location);
	P_FINISH;

	FLOAT RadiusSq = Radius * Radius;
	INT iActor = 0;
	PRE_ITERATOR;
		*Actor = NULL;
		while( iActor < XLevel->Actors.Num() )
		{
			AActor* Test = XLevel->Actors(iActor++);
			if( Test && Test->IsA(BaseClass) && (Test->Location - Loc).SizeSquared() <= RadiusSq )
			{
				*Actor = Test;
				break;
			}
		}
		if( *Actor == NULL )
		{
			Stack.Code = &Stack.Node->Script(wEndOffset + 1);
			break;
		}
	POST_ITERATOR;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 310, execRadiusActors );

void AActor::execVisibleActors( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execVisibleActors);
	P_GET_OBJECT(UClass,BaseClass);
	P_GET_OBJECT_REF(AActor,Actor);
	P_GET_FLOAT_OPTX(Radius,0.f);
	P_GET_VECTOR_OPTX(Loc,Location);
	P_FINISH;

	FLOAT RadiusSq = Radius > 0.f ? Radius * Radius : 0.f;
	INT iActor = 0;
	PRE_ITERATOR;
		*Actor = NULL;
		while( iActor < XLevel->Actors.Num() )
		{
			AActor* Test = XLevel->Actors(iActor++);
			if( Test && Test->IsA(BaseClass) )
			{
				if( RadiusSq <= 0.f || (Test->Location - Loc).SizeSquared() <= RadiusSq )
				{
					FCheckResult Hit(1.f);
					if( !XLevel->SingleLineCheck( Hit, this, Test->Location, Loc, TRACE_World | TRACE_Level, FVector(0,0,0) ) )
					{
						*Actor = Test;
						break;
					}
				}
			}
		}
		if( *Actor == NULL )
		{
			Stack.Code = &Stack.Node->Script(wEndOffset + 1);
			break;
		}
	POST_ITERATOR;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 311, execVisibleActors );

void AActor::execVisibleCollidingActors( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execVisibleCollidingActors);
	P_GET_OBJECT(UClass,BaseClass);
	P_GET_OBJECT_REF(AActor,Actor);
	P_GET_FLOAT(Radius);
	P_GET_VECTOR_OPTX(Loc,Location);
	P_GET_UBOOL_OPTX(bIgnoreHidden,0);
	P_FINISH;

	FLOAT RadiusSq = Radius * Radius;
	INT iActor = 0;
	PRE_ITERATOR;
		*Actor = NULL;
		while( iActor < XLevel->Actors.Num() )
		{
			AActor* Test = XLevel->Actors(iActor++);
			if( Test && Test->IsA(BaseClass) && Test->bCollideActors )
			{
				if( bIgnoreHidden && Test->bHidden )
				{
					continue;
				}
				if( (Test->Location - Loc).SizeSquared() <= RadiusSq )
				{
					*Actor = Test;
					break;
				}
			}
		}
		if( *Actor == NULL )
		{
			Stack.Code = &Stack.Node->Script(wEndOffset + 1);
			break;
		}
	POST_ITERATOR;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 312, execVisibleCollidingActors );

void AActor::execCollidingActors( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execCollidingActors);
	P_GET_OBJECT(UClass,BaseClass);
	P_GET_OBJECT_REF(AActor,Actor);
	P_GET_FLOAT(Radius);
	P_GET_VECTOR_OPTX(Loc,Location);
	P_FINISH;

	FLOAT RadiusSq = Radius * Radius;
	INT iActor = 0;
	PRE_ITERATOR;
		*Actor = NULL;
		while( iActor < XLevel->Actors.Num() )
		{
			AActor* Test = XLevel->Actors(iActor++);
			if( Test && Test->IsA(BaseClass) && Test->bCollideActors )
			{
				if( (Test->Location - Loc).SizeSquared() <= RadiusSq )
				{
					*Actor = Test;
					break;
				}
			}
		}
		if( *Actor == NULL )
		{
			Stack.Code = &Stack.Node->Script(wEndOffset + 1);
			break;
		}
	POST_ITERATOR;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 321, execCollidingActors );

void AActor::execPlayerCanSeeMe( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execPlayerCanSeeMe);
	P_FINISH;
	*(DWORD*)Result = 0;
	for( INT i=0; i<XLevel->Actors.Num(); i++ )
	{
		APlayerController* PC = Cast<APlayerController>(XLevel->Actors(i));
		if( PC && PC->Pawn )
		{
			FCheckResult Hit(1.f);
			if( !XLevel->SingleLineCheck( Hit, this, Location, PC->Pawn->Location, TRACE_World | TRACE_Level, FVector(0,0,0) ) )
			{
				*(DWORD*)Result = 1;
				break;
			}
		}
	}
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 532, execPlayerCanSeeMe );

/*-- Map / Game queries ------------------------------------------------*/

void AActor::execGetMapName( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execGetMapName);
	P_GET_STR(NameEnding);
	P_GET_STR(MapName);
	P_GET_INT(Dir);
	P_FINISH;
	*(FString*)Result = MapName;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 539, execGetMapName );

void AActor::execGetMapNameExt( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execGetMapNameExt);
	P_GET_STR(NameEnding);
	P_GET_STR(MapName);
	P_GET_INT(Dir);
	P_FINISH;
	*(FString*)Result = MapName;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 1519, execGetMapNameExt );

void AActor::execGetURLMap( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execGetURLMap);
	P_FINISH;
	*(FString*)Result = XLevel->URL.Map;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 547, execGetURLMap );

void AActor::execGetNextSkin( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execGetNextSkin);
	P_GET_STR(Prefix);
	P_GET_STR(CurrentSkin);
	P_GET_INT(Dir);
	P_FINISH;
	*(FString*)Result = CurrentSkin;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 545, execGetNextSkin );

void AActor::execGetNextInt( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execGetNextInt);
	P_GET_STR(ClassName);
	P_GET_INT(Idx);
	P_FINISH;
	*(FString*)Result = TEXT("");
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execGetNextInt );

void AActor::execGetNextIntDesc( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execGetNextIntDesc);
	P_GET_STR(ClassName);
	P_GET_INT(Idx);
	P_GET_STR_REF(Entry);
	P_GET_STR_REF(Description);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execGetNextIntDesc );

void AActor::execGetCacheEntry( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execGetCacheEntry);
	P_GET_INT(Num);
	P_GET_STR_REF(GUID);
	P_GET_STR_REF(Filename);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execGetCacheEntry );

void AActor::execMoveCacheEntry( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execMoveCacheEntry);
	P_GET_STR(GUID);
	P_GET_STR_REF(NewFilename);
	P_FINISH;
	*(DWORD*)Result = 0;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execMoveCacheEntry );

void AActor::execGetTime( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execGetTime);
	P_FINISH;
	*(FLOAT*)Result = Level ? Level->TimeSeconds : 0.f;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 1012, execGetTime );

void AActor::execGetGameManager( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execGetGameManager);
	P_FINISH;
	*(UObject**)Result = NULL;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 1551, execGetGameManager );

void AActor::execGetModMgr( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execGetModMgr);
	P_FINISH;
	*(UObject**)Result = NULL;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 1524, execGetModMgr );

void AActor::execGetGameOptions( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execGetGameOptions);
	P_FINISH;
	*(FString*)Result = XLevel->URL.Op.Num() ? XLevel->URL.Op(0) : TEXT("");
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 1009, execGetGameOptions );

void AActor::execGetServerOptions( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execGetServerOptions);
	P_FINISH;
	*(FString*)Result = TEXT("");
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 1273, execGetServerOptions );

void AActor::execSaveServerOptions( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execSaveServerOptions);
	P_GET_STR(Options);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 1283, execSaveServerOptions );

void AActor::execGetMissionDescription( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execGetMissionDescription);
	P_FINISH;
	*(FString*)Result = TEXT("");
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 1302, execGetMissionDescription );

void AActor::execSetServerBeacon( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execSetServerBeacon);
	P_GET_STR(Beacon);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 1311, execSetServerBeacon );

void AActor::execGetServerBeacon( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execGetServerBeacon);
	P_FINISH;
	*(FString*)Result = TEXT("");
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 1312, execGetServerBeacon );

void AActor::execNativeStartedByGSClient( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execNativeStartedByGSClient);
	P_FINISH;
	*(DWORD*)Result = 0;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 1200, execNativeStartedByGSClient );

void AActor::execNativeNonUbiMatchMaking( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execNativeNonUbiMatchMaking);
	P_FINISH;
	*(DWORD*)Result = 0;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 1303, execNativeNonUbiMatchMaking );

void AActor::execNativeNonUbiMatchMakingAddress( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execNativeNonUbiMatchMakingAddress);
	P_FINISH;
	*(FString*)Result = TEXT("");
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 1304, execNativeNonUbiMatchMakingAddress );

void AActor::execNativeNonUbiMatchMakingPassword( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execNativeNonUbiMatchMakingPassword);
	P_FINISH;
	*(FString*)Result = TEXT("");
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 1305, execNativeNonUbiMatchMakingPassword );

void AActor::execNativeNonUbiMatchMakingHost( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execNativeNonUbiMatchMakingHost);
	P_FINISH;
	*(DWORD*)Result = 0;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 1316, execNativeNonUbiMatchMakingHost );

void AActor::execGetGameVersion( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execGetGameVersion);
	P_GET_UBOOL_OPTX(_bShortVersion,0);
	P_GET_UBOOL_OPTX(_bModVersion,0);
	P_FINISH;
	*(FString*)Result = TEXT("1.60");
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 1419, execGetGameVersion );

void AActor::execIsPBClientEnabled( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execIsPBClientEnabled);
	P_FINISH;
	*(DWORD*)Result = 0;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 1400, execIsPBClientEnabled );

void AActor::execIsPBServerEnabled( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execIsPBServerEnabled);
	P_FINISH;
	*(DWORD*)Result = 0;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 1402, execIsPBServerEnabled );

void AActor::execSetPBStatus( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execSetPBStatus);
	P_GET_UBOOL(bEnable);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 1401, execSetPBStatus );

void AActor::execIsAvailableInGameType( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execIsAvailableInGameType);
	P_GET_INT(GameType);
	P_FINISH;
	*(DWORD*)Result = 1;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 1513, execIsAvailableInGameType );

void AActor::execConvertGameTypeIntToString( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execConvertGameTypeIntToString);
	P_GET_INT(GameType);
	P_FINISH;
	*(FString*)Result = TEXT("");
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 1256, execConvertGameTypeIntToString );

void AActor::execConvertGameTypeToInt( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execConvertGameTypeToInt);
	P_GET_STR(GameType);
	P_FINISH;
	*(INT*)Result = 0;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 2015, execConvertGameTypeToInt );

void AActor::execConvertIntTimeToString( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execConvertIntTimeToString);
	P_GET_INT(Seconds);
	P_FINISH;
	INT Min = Seconds / 60;
	INT Sec = Seconds % 60;
	*(FString*)Result = FString::Printf( TEXT("%02d:%02d"), Min, Sec );
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 1520, execConvertIntTimeToString );

void AActor::execGlobalIDToString( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execGlobalIDToString);
	P_GET_STR(GUID);
	P_FINISH;
	*(FString*)Result = GUID;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 1522, execGlobalIDToString );

void AActor::execGlobalIDToBytes( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execGlobalIDToBytes);
	P_GET_STR(GUID);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 1523, execGlobalIDToBytes );

void AActor::execGetTagInformations( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execGetTagInformations);
	P_FINISH;
	*(FString*)Result = TEXT("");
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 2008, execGetTagInformations );

void AActor::execDbgVectorReset( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execDbgVectorReset);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 1505, execDbgVectorReset );

void AActor::execDbgVectorAdd( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execDbgVectorAdd);
	P_GET_VECTOR(V);
	P_GET_STRUCT(FColor,C);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 1506, execDbgVectorAdd );

void AActor::execDbgAddLine( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execDbgAddLine);
	P_GET_VECTOR(Start);
	P_GET_VECTOR(End);
	P_GET_STRUCT(FColor,C);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 1801, execDbgAddLine );

void AActor::execGetFPlayerMenuInfo( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execGetFPlayerMenuInfo);
	P_GET_INT(Index);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 1230, execGetFPlayerMenuInfo );

void AActor::execSetFPlayerMenuInfo( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execSetFPlayerMenuInfo);
	P_GET_INT(Index);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 1231, execSetFPlayerMenuInfo );

void AActor::execGetPlayerSetupInfo( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execGetPlayerSetupInfo);
	P_GET_INT(Index);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 1232, execGetPlayerSetupInfo );

void AActor::execSetPlayerSetupInfo( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execSetPlayerSetupInfo);
	P_GET_INT(Index);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 1233, execSetPlayerSetupInfo );

void AActor::execSortFPlayerMenuInfo( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execSortFPlayerMenuInfo);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 1279, execSortFPlayerMenuInfo );

void AActor::execSetPlanningMode( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execSetPlanningMode);
	P_GET_UBOOL(bPlanMode);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 2011, execSetPlanningMode );

void AActor::execSetFloorToDraw( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execSetFloorToDraw);
	P_GET_INT(Floor);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 2012, execSetFloorToDraw );

void AActor::execInPlanningMode( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execInPlanningMode);
	P_FINISH;
	*(DWORD*)Result = 0;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 2014, execInPlanningMode );

void AActor::execLoadLoadingScreen( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execLoadLoadingScreen);
	P_GET_STR(ScreenName);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 2613, execLoadLoadingScreen );

void AActor::execLoadRandomBackgroundImage( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execLoadRandomBackgroundImage);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 2607, execLoadRandomBackgroundImage );

void AActor::execGetNbAvailableResolutions( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execGetNbAvailableResolutions);
	P_FINISH;
	*(INT*)Result = 0;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 2614, execGetNbAvailableResolutions );

void AActor::execGetAvailableResolution( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execGetAvailableResolution);
	P_GET_INT(Index);
	P_FINISH;
	*(FString*)Result = TEXT("1024x768");
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 2615, execGetAvailableResolution );

void AActor::execReplaceTexture( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execReplaceTexture);
	P_GET_OBJECT(UMaterial,OldTex);
	P_GET_OBJECT(UMaterial,NewTex);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 2616, execReplaceTexture );

void AActor::execIsVideoHardwareAtLeast64M( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execIsVideoHardwareAtLeast64M);
	P_FINISH;
	*(DWORD*)Result = 1;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 2617, execIsVideoHardwareAtLeast64M );

void AActor::execGetCanvas( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execGetCanvas);
	P_FINISH;
	*(UObject**)Result = NULL;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 2618, execGetCanvas );

void AActor::execEnableLoadingScreen( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execEnableLoadingScreen);
	P_GET_UBOOL(bEnable);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 2619, execEnableLoadingScreen );

void AActor::execAddMessageToConsole( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execAddMessageToConsole);
	P_GET_STR(Message);
	P_FINISH;
	debugf( TEXT("Console: %s"), *Message );
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 2620, execAddMessageToConsole );

void AActor::execUpdateGraphicOptions( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execUpdateGraphicOptions);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 2621, execUpdateGraphicOptions );

void AActor::execGarbageCollect( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execGarbageCollect);
	P_FINISH;
	UObject::CollectGarbage( RF_Native );
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 2622, execGarbageCollect );

void AActor::execDrawDashedLine( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execDrawDashedLine);
	P_GET_VECTOR(Start);
	P_GET_VECTOR(End);
	P_GET_STRUCT(FColor,Color);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 2608, execDrawDashedLine );

void AActor::execDrawText3D( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execDrawText3D);
	P_GET_VECTOR(Loc);
	P_GET_STR(Text);
	P_GET_STRUCT(FColor,Color);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 2609, execDrawText3D );

void AActor::execRenderLevelFromMe( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execRenderLevelFromMe);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 2610, execRenderLevelFromMe );

void AActor::execConsoleCommand( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execConsoleCommand);
	P_GET_STR(Command);
	P_FINISH;
	*(FString*)Result = TEXT("");
	if( XLevel && XLevel->Engine )
		XLevel->Engine->Exec( *Command, *GLog );
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execConsoleCommand );

/*-- Color math operators (called from UnrealScript) --------------------*/

void AActor::execMultiply_ColorFloat( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execMultiply_ColorFloat);
	P_GET_STRUCT(FColor,A);
	P_GET_FLOAT(B);
	P_FINISH;
	*(FColor*)Result = FColor( Clamp<INT>((INT)(A.R*B),0,255), Clamp<INT>((INT)(A.G*B),0,255), Clamp<INT>((INT)(A.B*B),0,255), A.A );
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execMultiply_ColorFloat );

void AActor::execMultiply_FloatColor( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execMultiply_FloatColor);
	P_GET_FLOAT(A);
	P_GET_STRUCT(FColor,B);
	P_FINISH;
	*(FColor*)Result = FColor( Clamp<INT>((INT)(B.R*A),0,255), Clamp<INT>((INT)(B.G*A),0,255), Clamp<INT>((INT)(B.B*A),0,255), B.A );
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execMultiply_FloatColor );

void AActor::execAdd_ColorColor( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execAdd_ColorColor);
	P_GET_STRUCT(FColor,A);
	P_GET_STRUCT(FColor,B);
	P_FINISH;
	*(FColor*)Result = FColor( Min<INT>(A.R+(INT)B.R,255), Min<INT>(A.G+(INT)B.G,255), Min<INT>(A.B+(INT)B.B,255), Min<INT>(A.A+(INT)B.A,255) );
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execAdd_ColorColor );

void AActor::execSubtract_ColorColor( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execSubtract_ColorColor);
	P_GET_STRUCT(FColor,A);
	P_GET_STRUCT(FColor,B);
	P_FINISH;
	*(FColor*)Result = FColor( Max<INT>(A.R-(INT)B.R,0), Max<INT>(A.G-(INT)B.G,0), Max<INT>(A.B-(INT)B.B,0), Max<INT>(A.A-(INT)B.A,0) );
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execSubtract_ColorColor );

/*-----------------------------------------------------------------------------
	AActor trivial method implementations.
	Reconstructed from Ghidra decompilation + UT99 reference.
-----------------------------------------------------------------------------*/

// Pending-state queries
INT AActor::IsPendingKill()
{
	return bDeleteMe;
}

INT AActor::IsPendingDelete()
{
	// Retail (32b RVA=0x5C00): checks bDeleteMe (bit7 @0xA0) first (JS path),
	// then bPendingDelete (bit0 @0xA9). Returns 1 if either is set.
	return bDeleteMe || bPendingDelete;
}

// Brush type queries
INT AActor::IsBrush() const
{
	return Brush!=NULL && IsA(ABrush::StaticClass());
}

INT AActor::IsStaticBrush() const
{
	return Brush!=NULL && IsA(ABrush::StaticClass()) && bStatic;
}

INT AActor::IsMovingBrush() const
{
	return Brush!=NULL && IsA(ABrush::StaticClass()) && !bStatic;
}

INT AActor::IsVolumeBrush() const
{
	return IsA(AVolume::StaticClass());
}

INT AActor::IsEncroacher() const
{
	return bCollideActors && (IsA(AMover::StaticClass()) || IsA(AKActor::StaticClass()));
}

// Editor / octree queries
INT AActor::IsHiddenEd()
{
	return bHiddenEd || bHiddenEdGroup;
}

INT AActor::IsInOctree()
{
	return OctreeNodes.Num() > 0;
}

UBOOL AActor::IsPlayer() const
{
	guardSlow(AActor::IsPlayer);
	if( !IsA(APawn::StaticClass()) )
		return 0;
	return ((APawn*)this)->m_bIsPlayer;
	unguardSlow;
}

// Simple getters
ULevel* AActor::GetLevel() const
{
	return XLevel;
}

AActor* AActor::GetHitActor()
{
	return (AActor*)this;
}

AActor* AActor::GetTopOwner()
{
	AActor* Top;
	for( Top=(AActor*)this; Top->Owner!=NULL; Top=Top->Owner );
	return Top;
}

FVector AActor::GetCylinderExtent() const
{
	return FVector(CollisionRadius, CollisionRadius, CollisionHeight);
}

AActor* AActor::GetAmbientLightingActor()
{
	// Retail: 27b. Follows the ambient lighting relay chain via this+0x15C
	// until an actor without bit 0 of this+0xA8 set, or when the chain ends.
	AActor* actor = this;
	while (*(BYTE*)((BYTE*)actor + 0xA8) & 1)
	{
		AActor* next = *(AActor**)((BYTE*)actor + 0x15C);
		if (!next) break;
		actor = next;
	}
	return actor;
}

FRotator AActor::GetViewRotation()
{
	return Rotation;
}

AActor* AActor::GetProjectorBase()
{
	return (AActor*)this;
}

APawn* AActor::GetPawnOrColBoxOwner() const
{
	// Retail (3b): return NULL
	return NULL;
}

APawn* AActor::GetPlayerPawn() const
{
	// Retail (3b): return NULL (no IsA check in retail)
	return NULL;
}

UPrimitive* AActor::GetPrimitive()
{
	// Retail (47b, RVA 0x78DE0): check 3 direct primitive fields, then a
	// nested StaticMeshInstance-like chain at +0x328.
	UPrimitive* p;
	if ((p = *(UPrimitive**)((BYTE*)this + 0x16C)) != NULL) return p; // Mesh
	if ((p = *(UPrimitive**)((BYTE*)this + 0x170)) != NULL) return p; // StaticMesh
	if ((p = *(UPrimitive**)((BYTE*)this + 0x17C)) != NULL) return p; // AntiPortal
	void* c = *(void**)((BYTE*)this + 0x328);
	if (!c) return NULL;
	p = *(UPrimitive**)((BYTE*)c + 0x44);
	if (!p) return NULL;
	return *(UPrimitive**)((BYTE*)p + 0x40);
}

// Simple setters
void AActor::SetOwner( AActor* NewOwner )
{
	guard(AActor::SetOwner);
	Owner = NewOwner;
	unguard;
}

void AActor::SetDrawScale( FLOAT NewScale )
{
	guard(AActor::SetDrawScale);
	DrawScale = NewScale;
	unguard;
}

void AActor::SetDrawScale3D( FVector NewScale3D )
{
	guard(AActor::SetDrawScale3D);
	DrawScale3D = NewScale3D;
	unguard;
}

void AActor::SetDrawType( EDrawType NewDrawType )
{
	guard(AActor::SetDrawType);
	DrawType = NewDrawType;
	unguard;
}

void AActor::SetStaticMesh( UStaticMesh* NewStaticMesh )
{
	guard(AActor::SetStaticMesh);
	StaticMesh = NewStaticMesh;
	unguard;
}

void AActor::SetGameType( FString GameType )
{
}


/*-----------------------------------------------------------------------------
	AActor method implementations -- batch from .bak reference.
	Reconstructed from Ghidra decompilation.
-----------------------------------------------------------------------------*/

void AActor::Serialize( FArchive& Ar )
{
	guard(AActor::Serialize);
	UObject::Serialize( Ar );
	if( Ar.Ver() >= 12 )
	{
		// Ghidra 0x1037C130: version-gated serialization of a TArray at this+0x210
		// (helper FUN_103218c0 serializes TArray count then GC-marks each element).
		// NOTE: Divergence — TArray field at 0x210 identity-pending; skipped for now.
	}
	// Ghidra: every 16th actor during loading triggers a GC-tick/UI-update;
	// editor-only behaviour, omitted here.
	unguard;
}

void AActor::PostLoad()
{
	guard(AActor::PostLoad);
	UObject::PostLoad();
	unguard;
}

void AActor::Destroy()
{
	guard(AActor::Destroy);
	UObject::Destroy();
	unguard;
}

void AActor::PostEditChange()
{
	guard(AActor::PostEditChange);
	UObject::PostEditChange();
	unguard;
}

void AActor::InitExecution()
{
	guard(AActor::InitExecution);
	UObject::InitExecution();
	unguard;
}

void AActor::ProcessEvent( UFunction* Function, void* Parms, void* Result )
{
	guard(AActor::ProcessEvent);
	UObject::ProcessEvent( Function, Parms, Result );
	unguard;
}

void AActor::ProcessState( FLOAT DeltaSeconds )
{
	guard(AActor::ProcessState);
	UObject::ProcessState( DeltaSeconds );
	unguard;
}

INT AActor::ProcessRemoteFunction( UFunction* Function, void* Parms, FFrame* Stack )
{
	guard(AActor::ProcessRemoteFunction);
	return UObject::ProcessRemoteFunction( Function, Parms, Stack );
	unguard;
}

void AActor::ProcessDemoRecFunction( UFunction* Function, void* Parms, FFrame* Stack )
{
	guard(AActor::ProcessDemoRecFunction);
	// Demo recording stub.
	unguard;
}

void AActor::NetDirty( UProperty* Property )
{
	// Retail (27b, RVA 0x70920): only mark bNetDirty if Property is non-null
	// AND has bit 5 of PropertyFlags at +0x40 set (CPF_Net = 0x20 = replicated).
	if (!Property) return;
	if (!(*(BYTE*)((BYTE*)Property + 0x40) & 0x20)) return;
	*(DWORD*)((BYTE*)this + 0xA0) |= 0x40000000u;  // set bNetDirty (bit 30 of bitfield at +0xA0)
}

INT* AActor::GetOptimizedRepList( BYTE* InDefault, FPropertyRetirement* Retire, INT* Ptr, UPackageMap* Map, UActorChannel* Ch )
{
	guard(AActor::GetOptimizedRepList);
	// TODO: Build optimized replication list from replicated properties.
	return Ptr;
	unguard;
}

FLOAT AActor::GetNetPriority( AActor* Sent, FLOAT Time, FLOAT Lag )
{
	guard(AActor::GetNetPriority);
	// Retail Engine.dll RVA=0x77DE0 (56 bytes):
	// bAlwaysRelevant actors get a priority boost:
	//   max(NetUpdateFrequency * 0.1f, 1.0f) * NetPriority * Time
	// All others: Time * NetPriority
	if( bAlwaysRelevant )
	{
		FLOAT boost = NetUpdateFrequency * 0.1f;
		if( boost < 1.0f )
			boost = 1.0f;
		return boost * NetPriority * Time;
	}
	return Time * NetPriority;
	unguard;
}

INT AActor::IsNetRelevantFor( APlayerController* RealViewer, AActor* Viewer, FVector SrcLocation )
{
	guard(AActor::IsNetRelevantFor);
	return bAlwaysRelevant || (Owner == Viewer);
	unguard;
}

void AActor::PreNetReceive()
{
}

void AActor::PostNetReceive()
{
}

void AActor::PostNetReceiveLocation()
{
}

INT AActor::PlayerControlled()
{
	return 0;
}

INT AActor::IsBlockedBy( const AActor* Other ) const
{
	guardSlow(AActor::IsBlockedBy);
	checkSlow(this!=NULL);
	checkSlow(Other!=NULL);

	if( Other == (AActor*)Level )
		return bCollideWorld;
	else if( Other->IsBrush() )
		return bCollideWorld && Other->bBlockActors;
	else if( IsBrush() )
		return Other->bCollideWorld && bBlockActors;
	else
		return Other->bBlockActors && bBlockActors;
	unguardSlow;
}

UBOOL AActor::IsOverlapping( AActor* Other, FCheckResult* Hit )
{
	guard(AActor::IsOverlapping);
	// Quick-exit guards matching Ghidra 0x78b40:
	// Both actors need collision geometry; exclude self, owner, and joined pairs.
	if( this == Other || Other == Owner )
		return 0;
	if( IsJoinedTo(Other) || Other->IsJoinedTo(this) )
		return 0;
	// Cylinder broad-phase: check Z overlap first (cheap), then XY radius overlap.
	FLOAT dZ  = Location.Z - Other->Location.Z;
	FLOAT hSum = CollisionHeight + Other->CollisionHeight;
	if( dZ*dZ >= hSum*hSum )
		return 0;
	FLOAT dX   = Location.X - Other->Location.X;
	FLOAT dY   = Location.Y - Other->Location.Y;
	FLOAT rSum = CollisionRadius + Other->CollisionRadius;
	if( dX*dX + dY*dY >= rSum*rSum )
		return 0;
	return 1;
	unguard;
}

INT AActor::ShouldTrace( AActor* SourceActor, DWORD TraceFlags )
{
	guard(AActor::ShouldTrace);
	return (bCollideActors || bBlockActors || bBlockPlayers || bWorldGeometry);
	unguard;
}

void AActor::UpdateColBox( FVector& NewLocation, INT bTest, INT bForce, INT bIgnoreEncroach )
{
}

FCoords AActor::ToLocal() const
{
	return GMath.UnitCoords / Rotation / Location;
}

FCoords AActor::ToWorld() const
{
	return GMath.UnitCoords * Location * Rotation;
}

FMatrix AActor::LocalToWorld() const
{
	guard(AActor::LocalToWorld);
	// Build a scale-rotation-translation matrix matching the retail binary (Ghidra-verified).
	// Uses GMath sin/cos lookup tables for accuracy.
	FLOAT SP = GMath.SinTab(Rotation.Pitch), CP = GMath.CosTab(Rotation.Pitch);
	FLOAT SY = GMath.SinTab(Rotation.Yaw),   CY = GMath.CosTab(Rotation.Yaw);
	FLOAT SR = GMath.SinTab(Rotation.Roll),  CR = GMath.CosTab(Rotation.Roll);
	FLOAT Sx = DrawScale3D.X * DrawScale;
	FLOAT Sy = DrawScale3D.Y * DrawScale;
	FLOAT Sz = DrawScale3D.Z * DrawScale;
	// Rotation-scale rows (row-vector convention; translation lives in WPlane)
	FLOAT r00 = CY*CP*Sx,                  r01 = SY*CP*Sx,                  r02 = SP*Sx;
	FLOAT r10 = (CY*SP*SR - SY*CR)*Sy,    r11 = (SY*SP*SR + CY*CR)*Sy,    r12 = -CP*SR*Sy;
	FLOAT r20 = -(CY*SP*CR + SY*SR)*Sz,   r21 = (CY*SR - SY*SP*CR)*Sz,    r22 = CP*CR*Sz;
	// Translation = Location - (rotation-columns dotted with PrePivot)
	FLOAT tx = Location.X - r00*PrePivot.X - r10*PrePivot.Y - r20*PrePivot.Z;
	FLOAT ty = Location.Y - r01*PrePivot.X - r11*PrePivot.Y - r21*PrePivot.Z;
	FLOAT tz = Location.Z - r02*PrePivot.X - r12*PrePivot.Y - r22*PrePivot.Z;
	return FMatrix(
		FPlane(r00, r01, r02, 0.f),
		FPlane(r10, r11, r12, 0.f),
		FPlane(r20, r21, r22, 0.f),
		FPlane(tx,  ty,  tz,  1.f)
	);
	unguard;
}

FMatrix AActor::WorldToLocal() const
{
	guard(AActor::WorldToLocal);
	// Inverse of LocalToWorld: S^-1 * R^T with inverted translation.
	FLOAT SP = GMath.SinTab(Rotation.Pitch), CP = GMath.CosTab(Rotation.Pitch);
	FLOAT SY = GMath.SinTab(Rotation.Yaw),   CY = GMath.CosTab(Rotation.Yaw);
	FLOAT SR = GMath.SinTab(Rotation.Roll),  CR = GMath.CosTab(Rotation.Roll);
	FLOAT invSx = 1.f / (DrawScale3D.X * DrawScale);
	FLOAT invSy = 1.f / (DrawScale3D.Y * DrawScale);
	FLOAT invSz = 1.f / (DrawScale3D.Z * DrawScale);
	// Transposed + inv-scaled rotation rows
	FLOAT w00 = CY*CP*invSx,              w01 = (CY*SP*SR - SY*CR)*invSy,  w02 = -(CY*SP*CR + SY*SR)*invSz;
	FLOAT w10 = SY*CP*invSx,              w11 = (SY*SP*SR + CY*CR)*invSy,  w12 = (CY*SR - SY*SP*CR)*invSz;
	FLOAT w20 = SP*invSx,                 w21 = -CP*SR*invSy,              w22 = CP*CR*invSz;
	// Translation: inverse maps world Location to local PrePivot
	FLOAT wtx = PrePivot.X - (Location.X*w00 + Location.Y*w10 + Location.Z*w20);
	FLOAT wty = PrePivot.Y - (Location.X*w01 + Location.Y*w11 + Location.Z*w21);
	FLOAT wtz = PrePivot.Z - (Location.X*w02 + Location.Y*w12 + Location.Z*w22);
	return FMatrix(
		FPlane(w00, w01, w02, 0.f),
		FPlane(w10, w11, w12, 0.f),
		FPlane(w20, w21, w22, 0.f),
		FPlane(wtx, wty, wtz, 1.f)
	);
	unguard;
}

INT AActor::Tick( FLOAT DeltaTime, ELevelTick TickType )
{
	guard(AActor::Tick);
	// Ghidra 0xc4870: main per-frame actor update.
	//
	// 1. Advance any active latent UnrealScript action (Sleep, FinishAnim etc.).
	//    StateFrame->LatentAction is non-zero while a latent function is pending.
	if( StateFrame && StateFrame->LatentAction )
		ProcessState( DeltaTime );

	// 2. Per-tick culling gate: derived classes can suppress ticking (bSkipTick, etc.).
	if( !TickThisFrame( DeltaTime ) )
		return 0;

	// 3. Authority tick: timers and physics.  Skipped when world is paused
	//    but the viewport still refreshes (ViewportsOnly mode).
	if( TickType != LEVELTICK_ViewportsOnly )
		TickAuthoritative( DeltaTime );

	// 4. Net-simulation and visual update.
	TickSimulated( DeltaTime );

	// 5. Per-actor overlay / effects update.
	TickSpecial( DeltaTime );

	return 1;
	unguard;
}

void AActor::TickAuthoritative( FLOAT DeltaTime )
{
	guard(AActor::TickAuthoritative);
	// Advance timer counters, then run physics simulation.
	UpdateTimers( DeltaTime );
	performPhysics( DeltaTime );
	unguard;
}

void AActor::TickSimulated( FLOAT DeltaTime )
{
	// Retail Engine.dll vtable[61]: mov eax,[ecx]; jmp [eax+0xF0]
	// Pure tail-call to TickAuthoritative (vtable slot 60). No guard/unguard in original.
	TickAuthoritative( DeltaTime );
}

void AActor::TickSpecial( FLOAT DeltaTime )
{
	// Retail Engine.dll: ret 4 (truly empty, no SEH frame)
}

INT AActor::TickThisFrame( FLOAT DeltaTime )
{
	guard(AActor::TickThisFrame);
	if( m_bSkipTick )
		return 0;
	return 1;
	unguard;
}

void AActor::UpdateTimers( FLOAT DeltaSeconds )
{
	guard(AActor::UpdateTimers);
	if( TimerRate > 0.f )
	{
		TimerCounter += DeltaSeconds;
		if( TimerCounter >= TimerRate )
		{
			if( bTimerLoop )
				TimerCounter -= TimerRate;
			else
			{
				TimerCounter = 0.f;
				TimerRate = 0.f;
			}
			eventTimer();
		}
	}
	unguard;
}

INT AActor::CheckOwnerUpdated()
{
	guard(AActor::CheckOwnerUpdated);
	// Retail 0xC3460: detect owner network-state change and queue actor for replication.
	// this+0x140 = Owner, Owner+0x320 bit0 = network state bit,
	// this+0x328 = replication-node ptr (ctrl), ctrl+0x100 = stored state, ctrl+0xF8 = list head.
	// Divergence: retail uses a FMemStack frame-arena allocator; we use appMalloc.
	AActor* owner = *(AActor**)((BYTE*)this + 0x140);
	if ( !owner ) return 1;
	INT ownerBit = *(INT*)((BYTE*)owner + 0x320) & 1;
	BYTE* ctrl   = *(BYTE**)((BYTE*)this + 0x328);
	INT   ctrlBit = *(INT*)(ctrl + 0x100);
	if ( ownerBit == ctrlBit ) return 1;
	struct OwnedActorLink { void* Actor; OwnedActorLink* Prev; };
	OwnedActorLink* node = (OwnedActorLink*)appMalloc( sizeof(OwnedActorLink), TEXT("OwnerUpdateNode") );
	if ( !node )
	{
		*(void**)(ctrl + 0xF8) = NULL;
		return 0;
	}
	node->Actor = this;
	node->Prev  = *(OwnedActorLink**)(ctrl + 0xF8);
	*(OwnedActorLink**)(ctrl + 0xF8) = node;
	return 0;
	unguard;
}

void AActor::BoundProjectileVelocity()
{
	// Retail Engine.dll: ret (truly empty)
}

void AActor::PostBeginPlay()
{
	// Retail Engine.dll: ret (truly empty, no SEH frame)
}

void AActor::PostEditLoad()
{
	// Retail Engine.dll: ret (truly empty)
}

void AActor::PostEditMove()
{
	// Retail Engine.dll: ret (truly empty)
}

void AActor::PostPath()
{
	// Retail Engine.dll: ret (truly empty)
}

void AActor::PostRaytrace()
{
	// Retail Engine.dll: ret (truly empty)
}

void AActor::PostScriptDestroyed()
{
	// Retail Engine.dll: ret (truly empty)
}

void AActor::PrePath()
{
	// Retail Engine.dll: ret (truly empty)
}

void AActor::PreRaytrace()
{
	// Retail Engine.dll: ret (truly empty)
}

void AActor::Spawned()
{
	// Retail Engine.dll: ret (truly empty)
}

UMaterial* AActor::GetSkin( INT Index )
{
	guard(AActor::GetSkin);
	if( Index < Skins.Num() && Skins(Index) )
		return Skins(Index);
	return Texture;
	unguard;
}

void AActor::NotifyAnimEnd( INT Channel )
{
	guard(AActor::NotifyAnimEnd);
	eventAnimEnd( Channel );
	unguard;
}

void AActor::UpdateAnimation( FLOAT DeltaSeconds )
{
	guard(AActor::UpdateAnimation);
	// TODO: Update mesh animation state.
	unguard;
}

void AActor::StartAnimPoll()
{
	// Retail RVA 0x120930.
	// The helper at 0x10370b90 called for the keep-polling check is
	// AActor::IsAnimating itself.  The vtable[0xe8/0xf0] calls dispatch
	// through UMeshInstance (all stubs that return 0 in the base class).
	if( !Mesh )
		return;
	Mesh->MeshGetInstance( this );
	UMeshInstance* mi = MeshInstance;
	INT fi = appRound( LatentFloat );
	if( mi->IsAnimating( fi ) )       // UMeshInstance::IsAnimating, vtable[0xe8]
		mi->IsAnimPastLastFrame( fi ); // vtable[0xf0]
	if( IsAnimating( fi ) )           // AActor::IsAnimating — DT_Mesh/AnimGetNotifyCount check
		if( !mi->IsAnimLooping( fi ) ) // vtable[0xec]
			GetStateFrame()->LatentAction = EPOLL_FinishAnim;
}


INT AActor::CheckAnimFinished( INT Channel )
{
	guard(AActor::CheckAnimFinished);
	// Retail 0x10420AB0: if MeshInstance is NULL, return 1 (no mesh = animation trivially done).
	// Full mesh instance animation poll for non-null case deferred.
	if( !MeshInstance )
		return 1;
	// TODO: poll MeshInstance for animation finish on Channel
	return 0;
	unguard;
}

INT AActor::IsAnimating( INT Channel ) const
{
	// Retail RVA 0x70B90.
	// For DT_Mesh actors: ensures MeshInstance is current via MeshGetInstance
	// then returns UMeshInstance::AnimGetNotifyCount(Channel-as-void*).
	// All other draw types return 0.
	if( DrawType != DT_Mesh )
		return 0;
	if( !Mesh )
		return 0;
	Mesh->MeshGetInstance( this );
	return MeshInstance ? MeshInstance->AnimGetNotifyCount( reinterpret_cast<void*>(Channel) ) : 0;
}

void AActor::PlayAnim( INT Channel, FName SequenceName, FLOAT Rate, FLOAT TweenTime, INT bLooping, INT bOverride, INT bRestart )
{
	guard(AActor::PlayAnim);
	if( !Mesh )
		return;
	Mesh->MeshGetInstance( this );
	if( MeshInstance )
		MeshInstance->PlayAnim( Channel, SequenceName, Rate, TweenTime, bLooping, bOverride, bRestart );
	unguard;
}

void AActor::PlayReplicatedAnim()
{
	guard(AActor::PlayReplicatedAnim);
	// TODO: Apply replicated animation state from SimAnim.
	unguard;
}

void AActor::ReplicateAnim( INT Channel, FName SequenceName, FLOAT Rate, FLOAT TweenTime, FLOAT Frame, FLOAT LastFrame, INT bLooping )
{
	guard(AActor::ReplicateAnim);
	// TODO: Send animation state for network replication.
	unguard;
}

void AActor::AnimBlendParams( INT Channel, FLOAT BlendAlpha, FLOAT InTime, FLOAT OutTime, FName BoneName )
{
	guard(AActor::AnimBlendParams);
	// TODO: Configure animation blend parameters.
	unguard;
}

void AActor::BeginTouch( AActor* Other )
{
	guard(AActor::BeginTouch);
	if( Other )
	{
		// Add to touching array if not already present.
		INT i;
		for( i=0; i<Touching.Num(); i++ )
			if( Touching(i) == Other )
				return;
		Touching.AddItem( Other );
		Other->Touching.AddItem( (AActor*)this );

		// Notify both actors.
		eventTouch( Other );
		Other->eventTouch( (AActor*)this );
	}
	unguard;
}

void AActor::EndTouch( AActor* Other, INT bNoNotifySelf )
{
	guard(AActor::EndTouch);
	if( Other )
	{
		Touching.RemoveItem( Other );
		Other->Touching.RemoveItem( (AActor*)this );
		if( !bNoNotifySelf )
			eventUnTouch( Other );
		Other->eventUnTouch( (AActor*)this );
	}
	unguard;
}

void AActor::NotifyBump( AActor* Other )
{
	guard(AActor::NotifyBump);
	eventBump( Other );
	unguard;
}

void AActor::SetBase( AActor* NewBase, FVector NewFloor, INT bNotifyActor )
{
	guard(AActor::SetBase);
	if( Base != NewBase )
	{
		// Detach from old base.
		if( Base )
			Base->Attached.RemoveItem( (AActor*)this );

		Base = NewBase;

		// Attach to new base.
		if( Base )
			Base->Attached.AddItem( (AActor*)this );

		if( bNotifyActor )
			eventBaseChange();
	}
	unguard;
}

INT AActor::AttachToBone( AActor* Attachment, FName BoneName )
{
	guard(AActor::AttachToBone);
	// TODO: Attach actor to skeletal mesh bone.
	return 0;
	unguard;
}

INT AActor::DetachFromBone( AActor* Attachment )
{
	guard(AActor::DetachFromBone);
	// TODO: Detach actor from skeletal mesh bone.
	return 0;
	unguard;
}

void AActor::AttachProjector( AProjector* Proj )
{
}

void AActor::DetachProjector( AProjector* Proj )
{
}

void AActor::SetCollision( INT bNewCollideActors, INT bNewBlockActors, INT bNewBlockPlayers )
{
	guard(AActor::SetCollision);
	bCollideActors = bNewCollideActors;
	bBlockActors   = bNewBlockActors;
	bBlockPlayers  = bNewBlockPlayers;
	unguard;
}

void AActor::SetCollisionSize( FLOAT NewRadius, FLOAT NewHeight )
{
	guard(AActor::SetCollisionSize);
	CollisionRadius = NewRadius;
	CollisionHeight = NewHeight;
	unguard;
}

void AActor::UpdateRenderData()
{
	guard(AActor::UpdateRenderData);
	// TODO: Rebuild render data (batches, static lighting).
	unguard;
}

FLOAT AActor::WorldLightRadius() const
{
	// Retail (19b): LightRadius * 1.0 * 25.0
	return 25.f * LightRadius;
}

void AActor::RenderEditorInfo( FLevelSceneNode* SceneNode, FRenderInterface* RI, FDynamicActor* Actor )
{
}

void AActor::RenderEditorSelected( FLevelSceneNode* SceneNode, FRenderInterface* RI, FDynamicActor* Actor )
{
}

void AActor::SetZone( INT bTest, INT bForceRefresh )
{
	guard(AActor::SetZone);
	// Ghidra 0xbd2a0: query the BSP model for the zone and leaf this actor
	// occupies, then fire zone/volume events if anything changed.
	// ULevel::Model is at raw offset +0x90 in ULevel (not yet formally declared
	// in EngineClasses.h).  UModel::PointRegion is a stub returning FPointRegion()
	// until the BSP traversal is fully reconstructed.
	if( bDeleteMe )
		return;

	FPointRegion NewRegion;
	if( XLevel )
	{
		UModel* pModel = *(UModel**)( (BYTE*)XLevel + 0x90 );
		NewRegion = pModel ? pModel->PointRegion( Level, Location )
		                   : FPointRegion( Level );
	}
	else
	{
		NewRegion = FPointRegion( Level );
	}

	AZoneInfo* OldZone = Region.Zone;
	AZoneInfo* NewZone = NewRegion.Zone;

	// Store updated region data regardless of bTest.
	Region = NewRegion;

	// Fire zone-transition events (only if not a test query).
	if( !bTest && OldZone != NewZone )
	{
		if( OldZone )
			OldZone->eventActorLeaving( this );
		eventZoneChange( NewZone );
		if( NewZone )
			NewZone->eventActorEntered( this );
	}

	// Update PhysicsVolume (water check only for non-test, non-force-refresh).
	INT bCheckWater  = (!bTest && !bForceRefresh && bProjTarget);
	APhysicsVolume* NewVol = Level->GetPhysicsVolume( Location, this, bCheckWater );
	APhysicsVolume* OldVol = PhysicsVolume;

	if( !bTest && NewVol != OldVol )
	{
		if( OldVol )
			OldVol->eventActorLeavingVolume( this );
		eventPhysicsVolumeChange( NewVol );
		if( NewVol )
			NewVol->eventActorEnteredVolume( this );
	}
	PhysicsVolume = NewVol;
	unguard;
}

void AActor::SetVolumes( const TArray<AVolume*>& NewVolumes )
{
	guard(AActor::SetVolumes);
	// Called from ANavigationPoint and volume-intersection sweeps; for base AActor
	// we don't store the volume list separately — PhysicsVolume is updated by SetZone.
	// Derived classes (ANavigationPoint) have their own override.
	unguard;
}

void AActor::SetVolumes()
{
	guard(AActor::SetVolumes_void);
	// Recalculate volumes: iterate the level's PhysicsVolume list and call the
	// array form. Requires ULevel::PhysicsVolumeList (ALevelInfo line 3633) which
	// is populated at map-load time.  Deferred until volume system is finalised.
	unguard;
}

void AActor::setPhysics( BYTE NewPhysics, AActor* NewFloor, FVector NewFloorV )
{
	guard(AActor::setPhysics);
	Physics = NewPhysics;
	unguard;
}

void AActor::performPhysics( FLOAT DeltaSeconds )
{
	guard(AActor::performPhysics);
	switch( Physics )
	{
	case PHYS_Falling:      physFalling( DeltaSeconds, 0 );      break;
	case PHYS_Projectile:   physProjectile( DeltaSeconds, 0 );   break;
	case PHYS_Trailer:      physTrailer( DeltaSeconds );         break;
	case PHYS_RootMotion:   physRootMotion( DeltaSeconds );      break;
	case PHYS_Karma:        physKarma( DeltaSeconds );           break;
	case PHYS_KarmaRagDoll: physKarmaRagDoll( DeltaSeconds );    break;
	// PHYS_None, PHYS_Walking (APawn-only), PHYS_Rotating, PHYS_Swimming,
	// PHYS_Flying, PHYS_MovingBrush, PHYS_Spider, PHYS_Ladder: no-op for base AActor
	}
	// Apply rotation toward desired rotation if RotationRate is set and actor is not interpolating
	if ( !RotationRate.IsZero() && !bInterpolating )
		physicsRotation( DeltaSeconds );
	// Process one pending touch event (linked list, one per tick)
	if ( PendingTouch )
	{
		AActor* OldTouch    = PendingTouch;
		OldTouch->eventPostTouch( this );
		PendingTouch            = OldTouch->PendingTouch;
		OldTouch->PendingTouch  = NULL;
	}
	unguard;
}

void AActor::processHitWall( FVector HitNormal, AActor* HitActor )
{
	guard(AActor::processHitWall);
	eventHitWall( HitNormal, HitActor );
	unguard;
}

void AActor::processLanded( FVector HitNormal, AActor* HitActor, FLOAT RemainingTime, INT Iterations )
{
	guard(AActor::processLanded);
	eventLanded( HitNormal );
	unguard;
}

void AActor::physFalling( FLOAT DeltaTime, INT Iterations )
{
	guard(AActor::physFalling);
	// Destroy if outside the world and not ignoring out-of-world events
	if ( Region.ZoneNumber == 0 && !bIgnoreOutOfWorld )
	{
		XLevel->DestroyActor( this );
		return;
	}
	// Save current velocity for midpoint integration
	FVector OldVelocity = Velocity;
	FCheckResult Hit( 1.f );
	while ( DeltaTime > 0.f && Iterations < 8 )
	{
		// Clamp step size to max 0.05s for stable integration
		FLOAT dt = Min( DeltaTime, 0.05f );
		DeltaTime -= dt;
		Iterations++;
		FVector OldLoc = Location;
		bJustTeleported = 0;
		// Apply zone gravity to velocity (approximation: use raw zone fields)
		// Zone gravity offsets from Ghidra: Zone+0x450 = GravAcceleration FVector
		// Zone+0x444 = ZoneVelocity FVector (additive wind/flow)
		if ( Region.Zone )
		{
			FVector* ZoneGrav = (FVector*)((BYTE*)Region.Zone + 0x450);
			FVector* ZoneVel  = (FVector*)((BYTE*)Region.Zone + 0x444);
			Velocity += *ZoneVel;
			FVector GravDelta = *ZoneGrav * dt;
			FVector AvgVel    = (Velocity + OldVelocity) * 0.5f;
			Velocity += GravDelta;
			FVector Delta = AvgVel * dt;
			XLevel->MoveActor( this, Delta, Rotation, Hit, 0, 0, 0, 0 );
		}
		else
		{
			// No zone: apply default gravity (1800 UU/s²)
			FVector AvgVel = (Velocity + OldVelocity) * 0.5f;
			Velocity.Z -= 1800.f * dt;
			FVector Delta = AvgVel * dt;
			XLevel->MoveActor( this, Delta, Rotation, Hit, 0, 0, 0, 0 );
		}
		if ( bDeleteMe )
			return;
		if ( Hit.Time < 1.f )
		{
			if ( bBlockPlayers )
				eventHitWall( Hit.Normal, Hit.Actor );
			if ( Physics == PHYS_Falling )
			{
				if ( Hit.Normal.Z >= 0.7f )
				{
					// Landed on a floor – update velocity from actual displacement
					if ( !bJustTeleported && Hit.Time > 0.1f && dt * Hit.Time > 0.003f )
						Velocity = (Location - OldLoc) / (dt * Hit.Time);
					processLanded( Hit.Normal, Hit.Actor, DeltaTime + dt * (1.f - Hit.Time), Iterations );
					return;
				}
				else
				{
					// Slide along a wall; preserve remaining time
					FVector Adj = Hit.Normal;
					FLOAT RemainTime = DeltaTime + dt * (1.f - Hit.Time);
					if ( Iterations < 2 )
						DeltaTime = RemainTime;
					Iterations++;
				}
			}
		}
		OldVelocity = Velocity;
	}
	unguard;
}

void AActor::physProjectile( FLOAT DeltaTime, INT Iterations )
{
	guard(AActor::physProjectile);
	// Destroy if outside the world and not ignoring out-of-world events
	if ( Region.ZoneNumber == 0 && !bIgnoreOutOfWorld )
	{
		XLevel->DestroyActor( this );
		return;
	}
	FVector StartLoc = Location;
	bJustTeleported  = 0;
	FCheckResult Hit( 1.f );
	INT BounceCount  = 0;
	while ( DeltaTime > 0.f )
	{
		BounceCount++;
		// Apply fluid drag from zone (if in a water/fluid zone)
		// Zone+0x410 flag byte, Zone+0x420 = FluidFriction FLOAT (from Ghidra physProjectile)
		FLOAT Drag = 0.f;
		if ( Region.Zone )
		{
			if ( (*(BYTE*)((BYTE*)Region.Zone + 0x410)) & 0x40 )
				Drag = *(FLOAT*)((BYTE*)Region.Zone + 0x420);
		}
		FLOAT DragFactor = 1.f - Drag * DeltaTime * 0.2f;
		Velocity *= DragFactor;
		// Apply acceleration (e.g. homing)
		Velocity += Acceleration * DeltaTime;
		// Move by Velocity * DeltaTime
		FVector Delta = Velocity * DeltaTime;
		FLOAT  RemainingTime = DeltaTime;
		DeltaTime = 0.f;
		XLevel->MoveActor( this, Delta, Rotation, Hit, 0, 0, 0, 0 );
		if ( Hit.Time < 1.f && !bDeleteMe && !bBounce )
		{
			FVector SafeNorm = Hit.Normal.SafeNormal();
			eventHitWall( SafeNorm, Hit.Actor );
			if ( bBlockPlayers && BounceCount < 2 )
				DeltaTime = (1.f - Hit.Time) * RemainingTime;
			if ( Physics == PHYS_Falling )
				physFalling( DeltaTime, Iterations );
		}
	}
	unguard;
}

void AActor::physTrailer( FLOAT DeltaTime )
{
	guard(AActor::physTrailer);
	// Only follow owner when not attached to something else
	if ( !Owner || Base )
		return;
	FCheckResult Hit( 1.f );
	if ( DrawType != DT_Sprite )
	{
		// Non-sprite trailer: snap to owner's position, orient from owner velocity
		XLevel->FarMoveActor( this, Owner->Location, 0, 1, 0, 0 );
		FRotator NewRot( 0, 0, 0 );
		if ( !Owner->Velocity.IsNearlyZero() )
			NewRot = ( -Owner->Velocity ).SafeNormal().Rotation();
		else
			NewRot = Owner->Rotation;
		XLevel->MoveActor( this, FVector(0,0,0), NewRot, Hit, 0, 0, 0, 0 );
	}
	else
	{
		// Sprite trailer: follow owner with relative location offset
		XLevel->FarMoveActor( this, RelativeLocation + Owner->Location, 0, 1, 0, 0 );
	}
	unguard;
}

void AActor::physRootMotion( FLOAT DeltaTime )
{
	guard(AActor::physRootMotion);
	// Root motion requires a SkeletalMesh and a SkeletalMeshInstance
	if ( !Mesh || !Mesh->IsA( USkeletalMesh::StaticClass() ) )
	{
		Velocity     = FVector(0,0,0);
		Acceleration = FVector(0,0,0);
		return;
	}
	USkeletalMeshInstance* SMI = Cast<USkeletalMeshInstance>( MeshInstance );
	if ( !SMI || !SMI->IsA( USkeletalMeshInstance::StaticClass() ) )
	{
		Velocity     = FVector(0,0,0);
		Acceleration = FVector(0,0,0);
		return;
	}
	FVector OldLoc = Location;
	FCheckResult Hit( 1.f );
	// Root motion flag at SMI+0x100 indicates active root motion channel
	if ( *(INT*)((BYTE*)SMI + 0x100) != 0 )
	{
		FRotator RotDelta = SMI->GetRootRotationDelta();
		FVector  LocDelta  = SMI->GetRootLocationDelta();
		XLevel->MoveActor( this, LocDelta, Rotation + RotDelta, Hit, 0, 0, 0, 0 );
	}
	// Keep DesiredRotation in sync with actual rotation after root motion
	DesiredRotation = Rotation;
	// Recompute velocity from actual displacement (unless teleported)
	if ( !bJustTeleported )
	{
		Velocity     = (Location - OldLoc) / Max( DeltaTime, DELTA );
		Acceleration = FVector(0,0,0);
	}
	unguard;
}

void AActor::physicsRotation( FLOAT DeltaTime )
{
	guard(AActor::physicsRotation);
	// Only rotate if either bRotateToDesired or bFixedRotationDir is set
	if ( !bRotateToDesired && !bFixedRotationDir )
		return;
	// If already at the desired rotation there is nothing to do
	if ( bRotateToDesired && Rotation == DesiredRotation )
		return;
	FRotator NewRot = Rotation;
	FRotator Delta  = RotationRate * DeltaTime;
	// For each axis: advance toward desired rotation at the scaled rate
	if ( Delta.Yaw   != 0 && (!bFixedRotationDir || DesiredRotation.Yaw   != NewRot.Yaw) )
		NewRot.Yaw   = fixedTurn( NewRot.Yaw,   DesiredRotation.Yaw,   Delta.Yaw );
	if ( Delta.Pitch != 0 && (!bFixedRotationDir || DesiredRotation.Pitch != NewRot.Pitch) )
		NewRot.Pitch = fixedTurn( NewRot.Pitch, DesiredRotation.Pitch, Delta.Pitch );
	if ( Delta.Roll  != 0 && (!bFixedRotationDir || DesiredRotation.Roll  != NewRot.Roll) )
		NewRot.Roll  = fixedTurn( NewRot.Roll,  DesiredRotation.Roll,  Delta.Roll );
	if ( NewRot != Rotation )
	{
		FCheckResult Hit( 1.f );
		XLevel->MoveActor( this, FVector(0,0,0), NewRot, Hit, 0, 0, 0, 0 );
	}
	// Fire event once the desired rotation is reached
	if ( bRotateToDesired && Rotation == DesiredRotation )
		eventEndedRotation();
	unguard;
}

FRotator AActor::FindSlopeRotation( FVector FloorNormal, FRotator NewRotation )
{
	guard(AActor::FindSlopeRotation);
	return NewRotation;
	unguard;
}

void AActor::SmoothHitWall( FVector HitNormal, AActor* HitActor )
{
	guard(AActor::SmoothHitWall);
	processHitWall( HitNormal, HitActor );
	unguard;
}

void AActor::stepUp( FVector GravDir, FVector DesiredDir, FVector Delta, FCheckResult& Hit )
{
	guard(AActor::stepUp);
	// MaxStepHeight = 33.f (0x42040000) from Ghidra 0xef2f0.
	// Try stepping up by one step height, move forward, then drop back down.
	FVector Down = GravDir * 33.f;
	if( !XLevel->MoveActor(this, -Down, Rotation, Hit) )
		return;
	if( !XLevel->MoveActor(this, Delta, Rotation, Hit) )
	{
		XLevel->MoveActor(this, Down, Rotation, Hit);
		return;
	}
	if( Hit.Time < 1.f )
	{
		// If we hit a wall (not a floor), recurse with a wall-projected delta.
		if( Abs(Hit.Normal.Z) < 0.08f && Delta.SizeSquared() * Hit.Time > 144.f )
		{
			XLevel->MoveActor(this, Down, Rotation, Hit);
			FVector NewDelta = Delta - Hit.Normal * (Delta | Hit.Normal);
			NewDelta = NewDelta - GravDir * (NewDelta | GravDir);
			stepUp(GravDir, DesiredDir, NewDelta * (1.f - Hit.Time), Hit);
			return;
		}
		processHitWall(Hit.Normal, Hit.Actor);
		if( Physics == PHYS_Falling )
		{
			XLevel->MoveActor(this, Down, Rotation, Hit);
			return;
		}
		// Slide along the wall normal projected to horizontal plane.
		FVector OldHitNormal = Hit.Normal;
		Hit.Normal.Z = 0.f;
		Hit.Normal = Hit.Normal.SafeNormal();
		FVector NewDelta = Delta - Hit.Normal * (Delta | Hit.Normal);
		NewDelta = NewDelta - GravDir * (NewDelta | GravDir);
		if( (NewDelta | DesiredDir) > 0.f )
		{
			XLevel->MoveActor(this, NewDelta * (1.f - Hit.Time), Rotation, Hit);
			if( Hit.Time < 1.f )
			{
				processHitWall(Hit.Normal, Hit.Actor);
				if( Physics == PHYS_Falling )
				{
					XLevel->MoveActor(this, Down, Rotation, Hit);
					return;
				}
				TwoWallAdjust(DesiredDir, NewDelta, Hit.Normal, OldHitNormal, Hit.Time);
				XLevel->MoveActor(this, NewDelta, Rotation, Hit);
			}
		}
	}
	// Return to original Z after the step-and-move attempt.
	XLevel->MoveActor(this, Down, Rotation, Hit);
	unguard;
}

INT AActor::moveSmooth( FVector Delta )
{
	guard(AActor::moveSmooth);
	FCheckResult Hit( 1.f );
	INT bResult = XLevel->MoveActor( this, Delta, Rotation, Hit, 0, 0, 0, 0 );
	if ( Hit.Time < 1.0f )
	{
		FVector OldHitNormal = Hit.Normal;
		FVector DesiredDir   = Delta.SafeNormal();
		FLOAT   RemainTime   = 1.0f - Hit.Time;
		// Project remaining delta onto the wall plane and scale by remaining fraction
		Delta = (Delta - Hit.Normal * (Delta | Hit.Normal)) * RemainTime;
		SmoothHitWall( Hit.Normal, Hit.Actor );
		bResult = XLevel->MoveActor( this, Delta, Rotation, Hit, 0, 0, 0, 0 );
		if ( Hit.Time < 1.0f )
		{
			// Two-wall corner: adjust for both normals and try a third move
			TwoWallAdjust( DesiredDir, Delta, Hit.Normal, OldHitNormal, Hit.Time );
			XLevel->MoveActor( this, Delta, Rotation, Hit, 0, 0, 0, 0 );
		}
	}
	return bResult;
	unguard;
}

INT AActor::fixedTurn( INT Current, INT Desired, INT DeltaRate )
{
	guard(AActor::fixedTurn);
	if( DeltaRate == 0 )
		return Current & 0xFFFF;
	if( Current == Desired )
		return Current & 0xFFFF;
	INT Diff = (Desired - Current) & 0xFFFF;
	if( Diff > 0x8000 )
		Diff -= 0x10000;
	if( Diff > DeltaRate )
		Diff = DeltaRate;
	else if( Diff < -DeltaRate )
		Diff = -DeltaRate;
	return (Current + Diff) & 0xFFFF;
	unguard;
}

void AActor::TwoWallAdjust( FVector& DesiredDir, FVector& Delta, FVector& HitNormal, FVector& OldHitNormal, FLOAT HitTime )
{
	guard(AActor::TwoWallAdjust);
	if( (OldHitNormal | HitNormal) <= 0 )
	{
		FVector NewDir = (HitNormal ^ OldHitNormal);
		NewDir = NewDir.SafeNormal();
		Delta = (Delta | NewDir) * (1.f - HitTime) * NewDir;
		if( (DesiredDir | Delta) < 0 )
			Delta = -1 * Delta;
	}
	else
	{
		Delta = (Delta - HitNormal * (Delta | HitNormal)) * (1.f - HitTime);
		if( (Delta | DesiredDir) <= 0 )
			Delta = FVector(0,0,0);
	}
	unguard;
}

void AActor::FindBase()
{
	guard(AActor::FindBase);
	// Ghidra 0xecf00: trace 8 units straight down; SetBase on hit actor.
	FCheckResult Hit(1.f);
	FVector TraceEnd(Location.X, Location.Y, Location.Z - 8.f);
	XLevel->SingleLineCheck(Hit, this, TraceEnd, Location, 0xdf,
		FVector(CollisionRadius, CollisionRadius, CollisionHeight));
	if( Base != Hit.Actor )
		SetBase(Hit.Actor, Hit.Normal, 1);
	unguard;
}

void AActor::PutOnGround()
{
	guard(AActor::PutOnGround);
	// Ghidra 0x79e30: trace down 3*CollisionHeight, snap to surface, set base.
	FCheckResult Hit(1.f);
	FVector TraceEnd(Location.X, Location.Y, Location.Z - CollisionHeight * 3.f);
	XLevel->SingleLineCheck(Hit, this, TraceEnd, Location, 0xdf,
		FVector(CollisionRadius, CollisionRadius, 1.f));
	if( Hit.Actor )
	{
		if( Hit.Normal.Z <= 0.7f )
			Hit.Actor = NULL;
		else
		{
			FVector NewLoc(Hit.Location.X, Hit.Location.Y, Hit.Location.Z + (CollisionHeight - 1.f));
			XLevel->FarMoveActor(this, NewLoc, 0, 1, 0, 0);
		}
	}
	SetBase(Hit.Actor, Hit.Normal, 1);
	unguard;
}

struct _McdModel* AActor::getKModel() const
{
	return NULL;
}

void AActor::physKarma( FLOAT DeltaTime )
{
}

void AActor::physKarma_internal( FLOAT DeltaTime )
{
}

void AActor::physKarmaRagDoll( FLOAT DeltaTime )
{
}

void AActor::physKarmaRagDoll_internal( FLOAT DeltaTime )
{
}

void AActor::preKarmaStep( FLOAT DeltaTime )
{
}

void AActor::postKarmaStep()
{
}

void AActor::preKarmaStep_skeletal( FLOAT DeltaTime )
{
}

void AActor::postKarmaStep_skeletal()
{
}

INT AActor::KMP2DynKarmaInterface( INT Mode, FVector Position, FRotator Rotation, AActor* Other )
{
	return 0;
}

AActor* AActor::AssociatedLevelGeometry()
{
	// Retail Engine.dll vtable[86]: returns this if bWorldGeometry is set, else NULL.
	// mov eax,[ecx+0xA0]; and eax,0x100000; neg; sbb eax,eax; and eax,ecx; ret
	return bWorldGeometry ? this : NULL;
}

INT AActor::HasAssociatedLevelGeometry( AActor* Other )
{
	// Retail Engine.dll: test bWorldGeometry flag; returns 1 only if this actor
	// has bWorldGeometry set AND Other IS this actor.
	return (bWorldGeometry && Other == this) ? 1 : 0;
}

void AActor::KFreezeRagdoll()
{
	guard(AActor::KFreezeRagdoll);
	// TODO: Freeze ragdoll simulation.
	unguard;
}

INT AActor::IsRelevantToPawnHeartBeat( APawn* P )
{
	return 0;
}

INT AActor::IsRelevantToPawnHeatVision( APawn* P )
{
	return 0;
}

INT AActor::IsRelevantToPawnRadar( APawn* P )
{
	return 0;
}

void AActor::CheckForErrors()
{
}

void AActor::AddMyMarker( AActor* S )
{
}

UBOOL AActor::IsOwnedBy( const AActor* TestOwner ) const
{
	guardSlow(AActor::IsOwnedBy);
	for( const AActor* Arg=this; Arg; Arg=Arg->Owner )
		if( Arg == TestOwner )
			return 1;
	return 0;
	unguardSlow;
}

UBOOL AActor::IsBasedOn( const AActor* Other ) const
{
	guard(AActor::IsBasedOn);
	for( const AActor* Test=this; Test!=NULL; Test=Test->Base )
		if( Test == Other )
			return 1;
	return 0;
	unguard;
}

UBOOL AActor::IsInZone( const AZoneInfo* TestZone ) const
{
	return Region.Zone!=Level ? Region.Zone==TestZone : 1;
}

FLOAT AActor::LifeFraction()
{
	return Clamp( 1.f - LifeSpan / GetClass()->GetDefaultActor()->LifeSpan, 0.f, 1.f );
}

INT AActor::IsJoinedTo( const AActor* Other ) const
{
	return 0;
}

INT AActor::TestCanSeeMe( APlayerController* Viewer )
{
	guard(AActor::TestCanSeeMe);
	return 0;
	unguard;
}

void AActor::UpdateRelativeRotation()
{
	guard(AActor::UpdateRelativeRotation);
	if( !Base )
		return;
	// Compute this actor's rotation expressed in Base's local coordinate system.
	// Matches Ghidra 0x70c30: FCoords path when no bone attachment (BoneName == NAME_None).
	RelativeRotation = (GMath.UnitCoords * Rotation / Base->Rotation).OrthoRotation();
	unguard;
}

void AActor::CheckNoiseHearing( FLOAT Loudness, ENoiseType NoiseType, EPawnType PawnType, ESoundType SoundType )
{
	guard(AActor::CheckNoiseHearing);
	// Propagate noise to AI controllers with hearing ability.
	// Iterate the controller list; each AI that returns true from CanHear
	// fires eventHearNoise on its controlling pawn.
	if( !Level ) return;

	for( AController* C = Level->ControllerList; C; C = C->nextController )
	{
		if( C == NULL || C->bDeleteMe )
			continue;
		// CanHear: virtual method — default AController returns 0 for silence.
		if( C->CanHear( Location, Loudness, this, NoiseType, PawnType ) )
		{
			C->eventHearNoise( Loudness, this, (BYTE)NoiseType, (BYTE)PawnType );
		}
	}
	unguard;
}

AActor* AActor::Trace( FVector& HitLocation, FVector& HitNormal, FVector& TraceEnd, FVector& TraceStart, INT bTraceActors, FVector& Extent, UMaterial** HitMaterial )
{
	guard(AActor::Trace);
	FCheckResult Hit(1.f);
	DWORD TraceFlags = TRACE_World | TRACE_Level;
	if( bTraceActors )
		TraceFlags |= TRACE_Pawns | TRACE_Others;
	AActor* HitActor = XLevel->SingleLineCheck(Hit, this, TraceEnd, TraceStart, TraceFlags, Extent) ? NULL : Hit.Actor;
	HitLocation = Hit.Location;
	HitNormal   = Hit.Normal;
	if( HitMaterial )
		*HitMaterial = (Hit.Material && Hit.Material->IsA(UMaterial::StaticClass())) ? (UMaterial*)Hit.Material : NULL;
	return HitActor;
	unguard;
}

void AActor::GetNetBuoyancy( FLOAT& NetBuoyancy, FLOAT& NetFluidFriction )
{
	guard(AActor::GetNetBuoyancy);
	NetBuoyancy = Buoyancy;
	NetFluidFriction = 0.f;
	unguard;
}

void AActor::SafeDestroyActor( AActor* A )
{
	guard(AActor::SafeDestroyActor);
	if( A && !A->bDeleteMe )
		A->eventDestroyed();
	unguard;
}

void AActor::CopyR6Availability( AActor* Src )
{
	guard(AActor::CopyR6Availability);
	if( Src )
	{
		m_eStoryMode           = Src->m_eStoryMode;
		m_eMissionMode         = Src->m_eMissionMode;
		m_eTerroristHunt       = Src->m_eTerroristHunt;
		m_eTerroristHuntCoop   = Src->m_eTerroristHuntCoop;
		m_eHostageRescue       = Src->m_eHostageRescue;
		m_eHostageRescueCoop   = Src->m_eHostageRescueCoop;
		m_eHostageRescueAdv    = Src->m_eHostageRescueAdv;
		m_eDefend              = Src->m_eDefend;
		m_eDefendCoop          = Src->m_eDefendCoop;
		m_eRecon               = Src->m_eRecon;
		m_eReconCoop           = Src->m_eReconCoop;
		m_eDeathmatch          = Src->m_eDeathmatch;
		m_eTeamDeathmatch      = Src->m_eTeamDeathmatch;
		m_eBomb                = Src->m_eBomb;
		m_eEscort              = Src->m_eEscort;
		m_eLoneWolf            = Src->m_eLoneWolf;
		m_eSquadDeathmatch     = Src->m_eSquadDeathmatch;
		m_eSquadTeamDeathmatch = Src->m_eSquadTeamDeathmatch;
		m_eTerroristHuntAdv    = Src->m_eTerroristHuntAdv;
		m_eScatteredHuntAdv    = Src->m_eScatteredHuntAdv;
		m_eCaptureTheEnemyAdv  = Src->m_eCaptureTheEnemyAdv;
		m_eCountDown           = Src->m_eCountDown;
		m_eKamikaze            = Src->m_eKamikaze;
		m_eFreeBackupAdv       = Src->m_eFreeBackupAdv;
		m_eGazAlertAdv         = Src->m_eGazAlertAdv;
		m_eIntruderAdv         = Src->m_eIntruderAdv;
		m_eLimitSeatsAdv       = Src->m_eLimitSeatsAdv;
		m_eVirusUploadAdv      = Src->m_eVirusUploadAdv;
	}
	unguard;
}

FString AActor::GlobalIDToString( BYTE* const Bytes )
{
	guard(AActor::GlobalIDToString);
	// Format a 16-byte binary GUID into the standard UUID text representation.
	return FString::Printf(
		TEXT("%02X%02X%02X%02X-%02X%02X-%02X%02X-%02X%02X-%02X%02X%02X%02X%02X%02X"),
		Bytes[0],  Bytes[1],  Bytes[2],  Bytes[3],
		Bytes[4],  Bytes[5],
		Bytes[6],  Bytes[7],
		Bytes[8],  Bytes[9],
		Bytes[10], Bytes[11], Bytes[12], Bytes[13], Bytes[14], Bytes[15]
	);
	unguard;
}

void AActor::SecondsToString( INT TotalSeconds, INT bAlignMinOnTwoDigits, FString& Result )
{
	guard(AActor::SecondsToString);
	INT Minutes = TotalSeconds / 60;
	INT Seconds = TotalSeconds % 60;
	if( bAlignMinOnTwoDigits )
		Result = FString::Printf( TEXT("%02d:%02d"), Minutes, Seconds );
	else
		Result = FString::Printf( TEXT("%d:%02d"), Minutes, Seconds );
	unguard;
}

void AActor::SaveServerOptions( FString FileName )
{
}

BYTE* AActor::GetR6AvailabilityPtr( FString GameType, INT Index )
{
	guard(AActor::GetR6AvailabilityPtr);
	return NULL;
	unguard;
}

INT AActor::IsAvailableInGameType( FString GameType )
{
	guard(AActor::IsAvailableInGameType);
	if( !m_bUseR6Availability )
		return 1;
	return 1;
	unguard;
}

INT AActor::NativeNonUbiMatchMaking()
{
	return 0;
}

INT AActor::NativeNonUbiMatchMakingHost()
{
	return 0;
}

INT AActor::NativeStartedByGSClient()
{
	return 0;
}

void AActor::DbgAddLine( FVector Start, FVector End, FColor Color )
{
}

void AActor::DbgVectorAdd( FVector Point, FVector Cylinder, INT VectorIndex, FString Def, FColor* Color )
{
}

void AActor::DbgVectorDraw( FLevelSceneNode* SceneNode, FRenderInterface& RI )
{
}

void AActor::DbgVectorReset( INT VectorIndex )
{
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
