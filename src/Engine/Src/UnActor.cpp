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

// Globals defined in Engine.cpp
extern ENGINE_API UR6AbstractGameManager* GR6GameManager;
extern ENGINE_API UR6ServerInfo*          GServerOptions;

// STDbgLine: debug line entry— 28 bytes matching binary layout (Ghidra 0x71250)
struct STDbgLine
{
    FVector Start;  // 0x00
    FVector End;    // 0x0c
    FColor  Color;  // 0x18
};

extern ENGINE_API STDbgLine* GDbgLine;
extern ENGINE_API INT        GDbgLineIndex;

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

IMPL_MATCH("Engine.dll", 0x10425850)
void AActor::execError( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execError);
	P_GET_STR(S);
	P_FINISH;
	debugf( NAME_ScriptWarning, TEXT("%s"), *S );
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 233, execError );

IMPL_MATCH("Engine.dll", 0x10420850)
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

IMPL_MATCH("Engine.dll", 0x10420bc0)
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

IMPL_MATCH("Engine.dll", 0x10429950)
void AActor::execDestroy( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execDestroy);
	P_FINISH;
	*(DWORD*)Result = XLevel->DestroyActor( this );
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 279, execDestroy );

IMPL_MATCH("Engine.dll", 0x10429750)
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

IMPL_MATCH("Engine.dll", 0x10428950)
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

IMPL_MATCH("Engine.dll", 0x103f1520)
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

IMPL_MATCH("Engine.dll", 0x10428a60)
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

IMPL_MATCH("Engine.dll", 0x10428d30)
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

IMPL_MATCH("Engine.dll", 0x10428b20)
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

IMPL_MATCH("Engine.dll", 0x10428e40)
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

IMPL_MATCH("Engine.dll", 0x103ec630)
void AActor::execSetPhysics( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execSetPhysics);
	P_GET_BYTE(NewPhysics);
	P_FINISH;
	setPhysics( NewPhysics, NULL, FVector(0,0,0) );
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 3970, execSetPhysics );

IMPL_MATCH("Engine.dll", 0x103ec6d0)
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

IMPL_MATCH("Engine.dll", 0x10424590)
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

IMPL_MATCH("Engine.dll", 0x10424730)
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

IMPL_MATCH("Engine.dll", 0x10424bd0)
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

IMPL_MATCH("Engine.dll", 0x10424b60)
void AActor::execSetOwner( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execSetOwner);
	P_GET_OBJECT(AActor,NewOwner);
	P_FINISH;
	SetOwner( NewOwner );
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 272, execSetOwner );

IMPL_MATCH("Engine.dll", 0x104247d0)
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

IMPL_MATCH("Engine.dll", 0x1042cfa0)
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

IMPL_MATCH("Engine.dll", 0x10429610)
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

IMPL_MATCH("Engine.dll", 0x1042cd60)
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

IMPL_MATCH("Engine.dll", 0x10429350)
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

IMPL_MATCH("Engine.dll", 0x10420d50)
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

IMPL_MATCH("Engine.dll", 0x10420e90)
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

IMPL_MATCH("Engine.dll", 0x10420fd0)
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

IMPL_MATCH("Engine.dll", 0x104208c0)
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

IMPL_MATCH("Engine.dll", 0x10420c00)
void AActor::execPollFinishAnim( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execPollFinishAnim);
	if( !IsAnimating( appRound( LatentFloat ) ) )
		GetStateFrame()->LatentAction = 0;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execPollFinishAnim );

IMPL_MATCH("Engine.dll", 0x10421110)
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

IMPL_MATCH("Engine.dll", 0x104210a0)
void AActor::execIsAnimating( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execIsAnimating);
	P_GET_INT_OPTX(Channel,0);
	P_FINISH;
	*(DWORD*)Result = IsAnimating( Channel );
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 282, execIsAnimating );

IMPL_MATCH("Engine.dll", 0x10421240)
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

IMPL_MATCH("Engine.dll", 0x104212d0)
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

IMPL_MATCH("Engine.dll", 0x10424370)
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

IMPL_MATCH("Engine.dll", 0x10421380)
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

IMPL_MATCH("Engine.dll", 0x10426570)
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

IMPL_MATCH("Engine.dll", 0x104266d0)
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

IMPL_MATCH("Engine.dll", 0x104267c0)
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

IMPL_MATCH("Engine.dll", 0x10424470)
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

IMPL_MATCH("Engine.dll", 0x10421190)
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

IMPL_MATCH("Engine.dll", 0x10426860)
void AActor::execGetNotifyChannel( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execGetNotifyChannel);
	P_FINISH;
	*(INT*)Result = 0;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execGetNotifyChannel );

IMPL_MATCH("Engine.dll", 0x104268d0)
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

IMPL_MATCH("Engine.dll", 0x10424260)
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

IMPL_MATCH("Engine.dll", 0x10425fd0)
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

IMPL_MATCH("Engine.dll", 0x10425e00)
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

IMPL_MATCH("Engine.dll", 0x10425ef0)
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

IMPL_MATCH("Engine.dll", 0x10425f50)
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

IMPL_MATCH("Engine.dll", 0x104264b0)
void AActor::execLockRootMotion( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execLockRootMotion);
	P_GET_INT(Lock);
	P_GET_UBOOL_OPTX(bUseRootRotation,0);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execLockRootMotion );

IMPL_MATCH("Engine.dll", 0x104262b0)
void AActor::execGetRootLocation( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execGetRootLocation);
	P_FINISH;
	*(FVector*)Result = Location;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execGetRootLocation );

IMPL_MATCH("Engine.dll", 0x104263b0)
void AActor::execGetRootLocationDelta( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execGetRootLocationDelta);
	P_FINISH;
	*(FVector*)Result = FVector(0,0,0);
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execGetRootLocationDelta );

IMPL_MATCH("Engine.dll", 0x10426330)
void AActor::execGetRootRotation( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execGetRootRotation);
	P_FINISH;
	*(FRotator*)Result = Rotation;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execGetRootRotation );

IMPL_MATCH("Engine.dll", 0x10426430)
void AActor::execGetRootRotationDelta( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execGetRootRotationDelta);
	P_FINISH;
	*(FRotator*)Result = FRotator(0,0,0);
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execGetRootRotationDelta );

IMPL_MATCH("Engine.dll", 0x104260a0)
void AActor::execGetBoneCoords( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execGetBoneCoords);
	P_GET_NAME(BoneName);
	P_GET_UBOOL_OPTX(bDontCallGetFrame,0);
	P_FINISH;
	*(FCoords*)Result = GMath.UnitCoords;
	if( Mesh )
	{
		Mesh->MeshGetInstance( this );
		if( USkeletalMeshInstance* MI = Cast<USkeletalMeshInstance>( MeshInstance ) )
		{
			INT bi = MI->MatchRefBone( BoneName );
			*(FCoords*)Result = MI->GetBoneCoords( (DWORD)Max(bi, 0), bi >= 0 ? bDontCallGetFrame : 0 );
		}
	}
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execGetBoneCoords );

IMPL_MATCH("Engine.dll", 0x10426190)
void AActor::execGetBoneRotation( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execGetBoneRotation);
	P_GET_NAME(BoneName);
	P_GET_INT_OPTX(Space,0);
	P_FINISH;
	*(FRotator*)Result = FRotator(0,0,0);
	if( Mesh )
	{
		Mesh->MeshGetInstance( this );
		if( USkeletalMeshInstance* MI = Cast<USkeletalMeshInstance>( MeshInstance ) )
			*(FRotator*)Result = MI->GetBoneRotation( BoneName, Space );
	}
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execGetBoneRotation );

IMPL_MATCH("Engine.dll", 0x10426b90)
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
	{
		Mesh->MeshGetInstance( this );
		if( USkeletalMeshInstance* MI = Cast<USkeletalMeshInstance>( MeshInstance ) )
			MI->SetBoneRotation( BoneName, BoneTurn, Space, Alpha, InTime );
	}
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execSetBoneRotation );

IMPL_MATCH("Engine.dll", 0x10426ce0)
void AActor::execSetBoneDirection( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execSetBoneDirection);
	P_GET_NAME(BoneName);
	P_GET_ROTATOR(Dir);
	P_GET_FLOAT_OPTX(Alpha,1.f);
	P_GET_INT_OPTX(Space,0);
	P_FINISH;
	// Note: Space param not forwarded; stub takes (FName,FRotator,FVector,FLOAT).
	if( Mesh )
	{
		Mesh->MeshGetInstance( this );
		if( USkeletalMeshInstance* MI = Cast<USkeletalMeshInstance>( MeshInstance ) )
			MI->SetBoneDirection( BoneName, Dir, FVector(0,0,0), Alpha );
	}
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execSetBoneDirection );

IMPL_MATCH("Engine.dll", 0x10426a80)
void AActor::execSetBoneLocation( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execSetBoneLocation);
	P_GET_NAME(BoneName);
	P_GET_VECTOR_OPTX(BoneTrans,FVector(0,0,0));
	P_GET_FLOAT_OPTX(Alpha,1.f);
	P_FINISH;
	if( Mesh )
	{
		Mesh->MeshGetInstance( this );
		if( USkeletalMeshInstance* MI = Cast<USkeletalMeshInstance>( MeshInstance ) )
			MI->SetBoneLocation( BoneName, BoneTrans, Alpha );
	}
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execSetBoneLocation );

IMPL_MATCH("Engine.dll", 0x10426990)
void AActor::execSetBoneScale( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execSetBoneScale);
	P_GET_INT(Slot);
	P_GET_FLOAT_OPTX(BoneScale,1.f);
	P_GET_NAME_OPTX(BoneName,NAME_None);
	P_FINISH;
	if( Mesh )
	{
		Mesh->MeshGetInstance( this );
		if( USkeletalMeshInstance* MI = Cast<USkeletalMeshInstance>( MeshInstance ) )
			MI->SetBoneScale( Slot, BoneScale, BoneName );
	}
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execSetBoneScale );

IMPL_MATCH("Engine.dll", 0x1042ba90)
void AActor::execGetRenderBoundingSphere( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execGetRenderBoundingSphere);
	P_FINISH;
	*(FVector*)Result = Location;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execGetRenderBoundingSphere );

IMPL_MATCH("Engine.dll", 0x10424a50)
void AActor::execAttachToBone( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execAttachToBone);
	P_GET_OBJECT(AActor,Attachment);
	P_GET_NAME(BoneName);
	P_FINISH;
	*(DWORD*)Result = AttachToBone( Attachment, BoneName ) ? 1 : 0;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execAttachToBone );

IMPL_MATCH("Engine.dll", 0x10424af0)
void AActor::execDetachFromBone( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execDetachFromBone);
	P_GET_OBJECT(AActor,Attachment);
	P_FINISH;
	*(DWORD*)Result = DetachFromBone( Attachment ) ? 1 : 0;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execDetachFromBone );

/*-- Sound dispatch hooks -----------------------------------------------*/

IMPL_DIVERGE("DIVERGENCE: UAudioSubsystem::PlaySound not declared; audio runs through DareAudio/SNDDSound3D at runtime")
void AActor::execPlaySound( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execPlaySound);
	P_GET_OBJECT(USound,Sound);
	P_GET_BYTE_OPTX(Slot,0);
	P_FINISH;
	if( Sound && XLevel && XLevel->Engine )
	{
		// DIVERGENCE: UAudioSubsystem has no PlaySound virtual in our reconstruction.
		// Retail calls XLevel->Engine->Audio->PlaySound(this, Slot, Sound, Location, Volume, Radius, Pitch).
		// Audio plays through the DareAudio / SNDDSound3D subsystem at runtime.
	}
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 264, execPlaySound );

IMPL_DIVERGE("DIVERGENCE: UAudioSubsystem::PlayOwnedSound not declared in reconstruction")
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
	// DIVERGENCE: UAudioSubsystem::PlayOwnedSound not declared in our reconstruction.
	// Retail calls XLevel->Engine->Audio->PlayOwnedSound(this, Sound, ...) via vtable.
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execPlayOwnedSound );

IMPL_DIVERGE("DIVERGENCE: UAudioSubsystem::DemoPlaySound not declared; demo recording audio omitted")
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
	// DIVERGENCE: UAudioSubsystem::DemoPlaySound not declared in our reconstruction.
	// Retail records/plays demo sounds via the audio subsystem vtable.
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execDemoPlaySound );

IMPL_MATCH("Engine.dll", 0x103e58f0)
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

IMPL_DIVERGE("always returns 0 — audio subsystem not implemented")
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

IMPL_DIVERGE("always returns 0 — music playback not implemented")
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

IMPL_DIVERGE("always returns 0 — music stop not implemented")
void AActor::execStopMusic( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execStopMusic);
	P_GET_OBJECT(USound,StopMusic);
	P_FINISH;
	*(DWORD*)Result = 0;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execStopMusic );

IMPL_DIVERGE("no-op stub — audio subsystem not implemented")
void AActor::execStopAllMusic( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execStopAllMusic);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execStopAllMusic );

IMPL_MATCH("Engine.dll", 0x10427fe0)
void AActor::execStopAllSounds( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execStopAllSounds);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 2712, execStopAllSounds );

IMPL_DIVERGE("parses aActor but performs no action — audio subsystem not implemented")
void AActor::execStopAllSoundsActor( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execStopAllSoundsActor);
	P_GET_OBJECT(AActor,aActor);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 2719, execStopAllSoundsActor );

IMPL_DIVERGE("parses Sound but performs no action — audio subsystem not implemented")
void AActor::execStopSound( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execStopSound);
	P_GET_OBJECT(USound,Sound);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 2725, execStopSound );

IMPL_DIVERGE("parses fTime/iFade/eSlot but performs no action — audio subsystem not implemented")
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

IMPL_DIVERGE("parses BankName but performs no action — audio subsystem not implemented")
void AActor::execAddSoundBank( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execAddSoundBank);
	P_GET_STR(BankName);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 2716, execAddSoundBank );

IMPL_MATCH("Engine.dll", 0x104281b0)
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

IMPL_MATCH("Engine.dll", 0x10427b90)
void AActor::execResetVolume_AllTypeSound( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execResetVolume_AllTypeSound);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 2704, execResetVolume_AllTypeSound );

IMPL_MATCH("Engine.dll", 0x10427be0)
void AActor::execResetVolume_TypeSound( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execResetVolume_TypeSound);
	P_GET_BYTE(SoundType);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 2720, execResetVolume_TypeSound );

IMPL_DIVERGE("parses VolumeType and NewVolume but performs no action — audio subsystem not implemented")
void AActor::execChangeVolumeType( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execChangeVolumeType);
	P_GET_BYTE(VolumeType);
	P_GET_INT(NewVolume);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 2705, execChangeVolumeType );

IMPL_MATCH("Engine.dll", 0x10427d30)
void AActor::execSaveCurrentFadeValue( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execSaveCurrentFadeValue);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 2722, execSaveCurrentFadeValue );

IMPL_MATCH("Engine.dll", 0x10427d80)
void AActor::execReturnSavedFadeValue( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execReturnSavedFadeValue);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 2723, execReturnSavedFadeValue );

IMPL_MATCH("Engine.dll", 0x10428840)
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

IMPL_MATCH("Engine.dll", 0x10424890)
void AActor::execSetDrawScale( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execSetDrawScale);
	P_GET_FLOAT(NewScale);
	P_FINISH;
	SetDrawScale( NewScale );
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execSetDrawScale );

IMPL_MATCH("Engine.dll", 0x104249d0)
void AActor::execSetDrawScale3D( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execSetDrawScale3D);
	P_GET_VECTOR(NewScale3D);
	P_FINISH;
	SetDrawScale3D( NewScale3D );
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execSetDrawScale3D );

IMPL_MATCH("Engine.dll", 0x10424970)
void AActor::execSetDrawType( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execSetDrawType);
	P_GET_BYTE(NewDrawType);
	P_FINISH;
	SetDrawType( (EDrawType)NewDrawType );
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execSetDrawType );

IMPL_MATCH("Engine.dll", 0x10424900)
void AActor::execSetStaticMesh( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execSetStaticMesh);
	P_GET_OBJECT(UStaticMesh,NewStaticMesh);
	P_FINISH;
	SetStaticMesh( NewStaticMesh );
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execSetStaticMesh );

IMPL_MATCH("Engine.dll", 0x10424660)
void AActor::execOnlyAffectPawns( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execOnlyAffectPawns);
	P_GET_UBOOL(bNewOnlyAffectPawns);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execOnlyAffectPawns );

IMPL_MATCH("Engine.dll", 0x10420b80)
void AActor::execFinishInterpolation( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execFinishInterpolation);
	P_FINISH;
	GetStateFrame()->LatentAction = EPOLL_FinishInterpolation;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 301, execFinishInterpolation );

IMPL_MATCH("Engine.dll", 0x10420c40)
void AActor::execPollFinishInterpolation( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execPollFinishInterpolation);
	if( Physics != PHYS_Interpolating )
		GetStateFrame()->LatentAction = 0;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execPollFinishInterpolation );

/*-- Actor iterators ---------------------------------------------------*/

IMPL_MATCH("Engine.dll", 0x104299a0)
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

IMPL_MATCH("Engine.dll", 0x10429bc0)
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

IMPL_MATCH("Engine.dll", 0x10429de0)
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

IMPL_MATCH("Engine.dll", 0x10429fb0)
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

IMPL_MATCH("Engine.dll", 0x1042a170)
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

IMPL_MATCH("Engine.dll", 0x1042a310)
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

IMPL_MATCH("Engine.dll", 0x1042a690)
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

IMPL_MATCH("Engine.dll", 0x1042a900)
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

IMPL_MATCH("Engine.dll", 0x1042ac40)
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

IMPL_MATCH("Engine.dll", 0x1042afb0)
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

IMPL_MATCH("Engine.dll", 0x103e7470)
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

IMPL_MATCH("Engine.dll", 0x103b02b0)
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

IMPL_MATCH("Engine.dll", 0x10423880)
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

IMPL_MATCH("Engine.dll", 0x103af5a0)
void AActor::execGetURLMap( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execGetURLMap);
	P_FINISH;
	*(FString*)Result = XLevel->URL.Map;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 547, execGetURLMap );

IMPL_MATCH("Engine.dll", 0x103aff20)
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

IMPL_MATCH("Engine.dll", 0x103afad0)
void AActor::execGetNextInt( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execGetNextInt);
	P_GET_STR(ClassName);
	P_GET_INT(Idx);
	P_FINISH;
	UClass* Class = (UClass*)UObject::StaticFindObjectChecked(
		UClass::StaticClass(), (UObject*)(DWORD)0xFFFFFFFF, *ClassName, 0 );
	TArray<FRegistryObjectInfo> List;
	UObject::GetRegistryObjects( List, UClass::StaticClass(), Class, 0 );
	if( Idx < List.Num() )
		*(FString*)Result = List(Idx).Object;
	else
		*(FString*)Result = TEXT("");
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execGetNextInt );

IMPL_MATCH("Engine.dll", 0x103afc60)
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

IMPL_MATCH("Engine.dll", 0x103b3510)
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

IMPL_TODO("cache.ini file operations via FUN_103b1d90/FUN_103b1980 unresolved (Ghidra 0x103b37d0)")
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

IMPL_MATCH("Engine.dll", 0x10422cb0)
void AActor::execGetTime( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execGetTime);
	P_FINISH;
	*(FLOAT*)Result = Level ? Level->TimeSeconds : 0.f;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 1012, execGetTime );

IMPL_MATCH("Engine.dll", 0x1047cbf0)
void AActor::execGetGameManager( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execGetGameManager);
	P_FINISH;
	*(UR6AbstractGameManager**)Result = GR6GameManager;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 1551, execGetGameManager );

IMPL_MATCH("Engine.dll", 0x10422b70)
void AActor::execGetModMgr( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execGetModMgr);
	P_FINISH;
	*(UR6ModMgr**)Result = GModMgr;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 1524, execGetModMgr );

IMPL_MATCH("Engine.dll", 0x10422c10)
void AActor::execGetGameOptions( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execGetGameOptions);
	P_FINISH;
	*(FString*)Result = XLevel->URL.Op.Num() ? XLevel->URL.Op(0) : TEXT("");
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 1009, execGetGameOptions );

IMPL_MATCH("Engine.dll", 0x10423ec0)
void AActor::execGetServerOptions( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execGetServerOptions);
	P_FINISH;
	*(UR6ServerInfo**)Result = GServerOptions;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 1273, execGetServerOptions );

IMPL_MATCH("Engine.dll", 0x1042ca20)
void AActor::execSaveServerOptions( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execSaveServerOptions);
	P_GET_STR(Options);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 1283, execSaveServerOptions );

IMPL_MATCH("Engine.dll", 0x10423f60)
void AActor::execGetMissionDescription( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execGetMissionDescription);
	P_FINISH;
	*(FString*)Result = TEXT("");
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 1302, execGetMissionDescription );

IMPL_MATCH("Engine.dll", 0x10424000)
void AActor::execSetServerBeacon( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execSetServerBeacon);
	P_GET_STR(Beacon);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 1311, execSetServerBeacon );

IMPL_DIVERGE("returns binary-specific global DAT_10793088 (server beacon string; Ghidra 0x104240c0)")
void AActor::execGetServerBeacon( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execGetServerBeacon);
	P_FINISH;
	// Ghidra 0x104240c0: *(FString*)Result = DAT_10793088 (global beacon string)
	*(FString*)Result = TEXT("");
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 1312, execGetServerBeacon );

IMPL_MATCH("Engine.dll", 0x104239a0)
void AActor::execNativeStartedByGSClient( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execNativeStartedByGSClient);
	P_FINISH;
	*(INT*)Result = NativeStartedByGSClient();
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 1200, execNativeStartedByGSClient );

IMPL_MATCH("Engine.dll", 0x10423be0)
void AActor::execNativeNonUbiMatchMaking( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execNativeNonUbiMatchMaking);
	P_FINISH;
	*(INT*)Result = NativeNonUbiMatchMaking();
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 1303, execNativeNonUbiMatchMaking );

IMPL_MATCH("Engine.dll", 0x10423c80)
void AActor::execNativeNonUbiMatchMakingAddress( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execNativeNonUbiMatchMakingAddress);
	P_GET_STR_REF(Addr);
	P_FINISH;
	Parse(appCmdLine(), TEXT("Ip="), *Addr);
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 1304, execNativeNonUbiMatchMakingAddress );

IMPL_MATCH("Engine.dll", 0x10423da0)
void AActor::execNativeNonUbiMatchMakingPassword( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execNativeNonUbiMatchMakingPassword);
	P_GET_STR_REF(Pwd);
	P_FINISH;
	Parse(appCmdLine(), TEXT("Pwd="), *Pwd);
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 1305, execNativeNonUbiMatchMakingPassword );

IMPL_MATCH("Engine.dll", 0x10423ac0)
void AActor::execNativeNonUbiMatchMakingHost( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execNativeNonUbiMatchMakingHost);
	P_FINISH;
	*(INT*)Result = NativeNonUbiMatchMakingHost();
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 1316, execNativeNonUbiMatchMakingHost );

IMPL_MATCH("Engine.dll", 0x10427410)
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

IMPL_DIVERGE("always returns 0 — PunkBuster client not implemented")
void AActor::execIsPBClientEnabled( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execIsPBClientEnabled);
	P_FINISH;
	*(DWORD*)Result = 0;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 1400, execIsPBClientEnabled );

IMPL_DIVERGE("always returns 0 — PunkBuster server not implemented")
void AActor::execIsPBServerEnabled( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execIsPBServerEnabled);
	P_FINISH;
	*(DWORD*)Result = 0;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 1402, execIsPBServerEnabled );

IMPL_DIVERGE("parses bEnable but performs no action — PunkBuster not implemented")
void AActor::execSetPBStatus( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execSetPBStatus);
	P_GET_UBOOL(bEnable);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 1401, execSetPBStatus );

IMPL_MATCH("Engine.dll", 0x1037c650)
void AActor::execIsAvailableInGameType( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execIsAvailableInGameType);
	P_GET_INT(GameType);
	P_FINISH;
	*(DWORD*)Result = 1;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 1513, execIsAvailableInGameType );

IMPL_MATCH("Engine.dll", 0x10379680)
void AActor::execConvertGameTypeIntToString( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execConvertGameTypeIntToString);
	P_GET_INT(GameType);
	P_FINISH;
	*(FString*)Result = TEXT("");
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 1256, execConvertGameTypeIntToString );

IMPL_MATCH("Engine.dll", 0x10379780)
void AActor::execConvertGameTypeToInt( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execConvertGameTypeToInt);
	P_GET_STR(GameType);
	P_FINISH;
	*(INT*)Result = 0;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 2015, execConvertGameTypeToInt );

IMPL_MATCH("Engine.dll", 0x10423770)
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

IMPL_TODO("byte-array parameter extraction via GPropAddr not yet matched; retail calls GlobalIDToString(16-byte GUID) helper (Ghidra 0x10423380)")
void AActor::execGlobalIDToString( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execGlobalIDToString);
	P_GET_STR(GUID);
	P_FINISH;
	*(FString*)Result = GUID;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 1522, execGlobalIDToString );

IMPL_TODO("hex parsing via FUN_10423060 unresolved; retail parses FString GUID hex chars into byte array at GPropAddr (Ghidra 0x104234a0)")
void AActor::execGlobalIDToBytes( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execGlobalIDToBytes);
	P_GET_STR(GUID);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 1523, execGlobalIDToBytes );

IMPL_TODO("626-byte function; FTags struct, FVector, FRotator params via GPropAddr; unresolved (Ghidra 0x10425250)")
void AActor::execGetTagInformations( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execGetTagInformations);
	P_FINISH;
	*(FString*)Result = TEXT("");
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 2008, execGetTagInformations );

IMPL_MATCH("Engine.dll", 0x10421570)
void AActor::execDbgVectorReset( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execDbgVectorReset);
	P_GET_INT(VectorIndex);
	P_FINISH;
	DbgVectorReset(VectorIndex);
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 1505, execDbgVectorReset );

IMPL_MATCH("Engine.dll", 0x104215e0)
void AActor::execDbgVectorAdd( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execDbgVectorAdd);
	P_GET_VECTOR(Point);
	P_GET_VECTOR(Cylinder);
	P_GET_INT(VectorIndex);
	P_GET_STR(Def);
	P_FINISH;
	DbgVectorAdd(Point, Cylinder, VectorIndex, Def, NULL);
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 1506, execDbgVectorAdd );

IMPL_MATCH("Engine.dll", 0x10426e30)
void AActor::execDbgAddLine( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execDbgAddLine);
	P_GET_VECTOR(Start);
	P_GET_VECTOR(End);
	P_GET_STRUCT(FColor,C);
	P_FINISH;
	DbgAddLine(Start, End, C);
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 1801, execDbgAddLine );

IMPL_TODO("FUN_10421aa0/FUN_10421790 (player menu fill/sort helpers) unresolved (Ghidra 0x10426f70)")
void AActor::execGetFPlayerMenuInfo( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execGetFPlayerMenuInfo);
	P_GET_INT(Index);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 1230, execGetFPlayerMenuInfo );

IMPL_TODO("FUN_10421aa0/FUN_10421790 (player menu fill/sort helpers) unresolved (Ghidra 0x10421b40)")
void AActor::execSetFPlayerMenuInfo( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execSetFPlayerMenuInfo);
	P_GET_INT(Index);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 1231, execSetFPlayerMenuInfo );

IMPL_TODO("Ghidra decompilation failed (1829 bytes at 0x10421c60); binary-specific struct layout")
void AActor::execGetPlayerSetupInfo( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execGetPlayerSetupInfo);
	P_GET_INT(Index);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 1232, execGetPlayerSetupInfo );

IMPL_TODO("Ghidra decompilation failed (2004 bytes at 0x10422390); binary-specific struct layout")
void AActor::execSetPlayerSetupInfo( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execSetPlayerSetupInfo);
	P_GET_INT(Index);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 1233, execSetPlayerSetupInfo );

IMPL_TODO("appQsort on binary-specific global array DAT_10793090 (player menu, stride 0x44); Ghidra 0x10421970")
void AActor::execSortFPlayerMenuInfo( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execSortFPlayerMenuInfo);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 1279, execSortFPlayerMenuInfo );

IMPL_MATCH("Engine.dll", 0x10379990)
void AActor::execSetPlanningMode( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execSetPlanningMode);
	P_GET_UBOOL(bPlanMode);
	P_FINISH;
	// Ghidra 0x79990: XLevel->Engine->Client->Viewports[0]->field_0x1f0 bit0 = bPlanMode
	if( g_pEngine )
	{
		BYTE* pClient = *(BYTE**)((BYTE*)g_pEngine + 0x44);
		if( pClient )
		{
			INT numViewports = *(INT*)(pClient + 0x34);
			if( numViewports > 0 )
			{
				BYTE* pViewport = **(BYTE***)(pClient + 0x30);
				DWORD& f = *(DWORD*)(pViewport + 0x1f0);
				if( bPlanMode ) f |= 1u;
				else            f &= ~1u;
			}
		}
	}
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 2011, execSetPlanningMode );

IMPL_MATCH("Engine.dll", 0x10379be0)
void AActor::execSetFloorToDraw( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execSetFloorToDraw);
	P_GET_INT(Floor);
	P_FINISH;
	// Ghidra 0x79be0: XLevel->Engine->Client->Viewports[0]->field_0x1f4 (decimal 500) = Floor
	if( g_pEngine )
	{
		BYTE* pClient = *(BYTE**)((BYTE*)g_pEngine + 0x44);
		if( pClient )
		{
			INT numViewports = *(INT*)(pClient + 0x34);
			if( numViewports > 0 )
			{
				BYTE* pViewport = **(BYTE***)(pClient + 0x30);
				*(INT*)(pViewport + 500) = Floor;
			}
		}
	}
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 2012, execSetFloorToDraw );

IMPL_MATCH("Engine.dll", 0x10379ac0)
void AActor::execInPlanningMode( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execInPlanningMode);
	P_FINISH;
	// Ghidra 0x79ac0: return XLevel->Engine->Client->Viewports[0]->field_0x1f0 & 1
	*(DWORD*)Result = 0;
	if( g_pEngine )
	{
		BYTE* pClient = *(BYTE**)((BYTE*)g_pEngine + 0x44);
		if( pClient )
		{
			INT numViewports = *(INT*)(pClient + 0x34);
			if( numViewports > 0 )
			{
				BYTE* pViewport = **(BYTE***)(pClient + 0x30);
				*(DWORD*)Result = *(DWORD*)(pViewport + 0x1f0) & 1u;
			}
		}
	}
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 2014, execInPlanningMode );

IMPL_TODO("calls UR6ModMgr::eventGetMapsDir then engine vtable[0xD0/4] to load texture; Ghidra 0x1042cb10")
void AActor::execLoadLoadingScreen( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execLoadLoadingScreen);
	P_GET_STR(ScreenName);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 2613, execLoadLoadingScreen );

IMPL_TODO("calls UR6ModMgr::eventGetBackgroundsRoot and loads random background; Ghidra 0x1042c4c0")
void AActor::execLoadRandomBackgroundImage( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execLoadRandomBackgroundImage);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 2607, execLoadRandomBackgroundImage );

IMPL_DIVERGE("calls vtable chain g_pEngine->Client->??->vtable[0xBC/4]() to populate resolution array (Ghidra 0x1042c6f0); binary vtable layout not portable")
void AActor::execGetNbAvailableResolutions( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execGetNbAvailableResolutions);
	P_FINISH;
	*(INT*)Result = 0;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 2614, execGetNbAvailableResolutions );

IMPL_DIVERGE("DIVERGENCE: retail reads resolution from engine list via vtable for given Index (Ghidra 0x10427090) — binary-specific vtable; hardcoded fallback")
void AActor::execGetAvailableResolution( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execGetAvailableResolution);
	P_GET_INT(Index);
	P_FINISH;
	// Ghidra 0x10427090: queries width/height/depth from engine resolution array at Index.
	*(FString*)Result = TEXT("1024x768");
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 2615, execGetAvailableResolution );

IMPL_DIVERGE("DIVERGENCE: calls UEngine vtable[0xD4/4] with OldTex name (Ghidra 0x10424160) — binary-specific vtable; texture replacement stubbed")
void AActor::execReplaceTexture( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execReplaceTexture);
	P_GET_OBJECT(UMaterial,OldTex);
	P_GET_OBJECT(UMaterial,NewTex);
	P_FINISH;
	// Ghidra 0x10424160: (*(g_pEngine->vtable + 0xD4))(g_pEngine, OldTex->GetName())
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 2616, execReplaceTexture );

IMPL_DIVERGE("retail calls vtable chain g_pEngine->Client->Viewports[0]->vtable[0xC0/4]() and tests >32MB (Ghidra 0x10427350); binary vtable layout not portable; modern GPUs always pass")
void AActor::execIsVideoHardwareAtLeast64M( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execIsVideoHardwareAtLeast64M);
	P_FINISH;
	// Ghidra 0x10427350: g_pEngine->Client->Viewports[0]->inner->vtable[0xC0/4]() > 0x20
	*(DWORD*)Result = 1;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 2617, execIsVideoHardwareAtLeast64M );

IMPL_MATCH("Engine.dll", 0x10427270)
void AActor::execGetCanvas( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execGetCanvas);
	P_FINISH;
	// Ghidra 0x10427270: g_pEngine->Client->Viewports[0]->Canvas
	*(void**)Result = NULL;
	if( g_pEngine )
	{
		BYTE* pClient = *(BYTE**)((BYTE*)g_pEngine + 0x44);
		if( pClient )
		{
			INT numViewports = *(INT*)(pClient + 0x34);
			if( numViewports > 0 )
			{
				BYTE* pViewport = **(BYTE***)(pClient + 0x30);
				*(void**)Result = *(void**)(pViewport + 0x7C);
			}
		}
	}
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 2618, execGetCanvas );

IMPL_MATCH("Engine.dll", 0x10422d50)
void AActor::execEnableLoadingScreen( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execEnableLoadingScreen);
	P_GET_UBOOL(bEnable);
	P_FINISH;
	// Ghidra 0x10422d50: *(g_pEngine+0x120) bit 15 (0x8000) = bEnable
	if( g_pEngine )
	{
		DWORD& flags = *(DWORD*)((BYTE*)g_pEngine + 0x120);
		if( bEnable ) flags |=  0x8000u;
		else          flags &= ~0x8000u;
	}
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 2619, execEnableLoadingScreen );

IMPL_MATCH("Engine.dll", 0x1042da60)
void AActor::execAddMessageToConsole( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execAddMessageToConsole);
	P_GET_STR(Message);
	P_FINISH;
	debugf( TEXT("Console: %s"), *Message );
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 2620, execAddMessageToConsole );

IMPL_MATCH("Engine.dll", 0x10422f20)
void AActor::execUpdateGraphicOptions( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execUpdateGraphicOptions);
	P_FINISH;
	// Ghidra 0x10422f20: g_pEngine->Client->vtable[0x68/4]()
	if( g_pEngine )
	{
		INT* pClient = *(INT**)((BYTE*)g_pEngine + 0x44);
		if( pClient )
			(*(void(**)(INT*))(*pClient + 0x68))(pClient);
	}
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 2621, execUpdateGraphicOptions );

IMPL_MATCH("Engine.dll", 0x10422fc0)
void AActor::execGarbageCollect( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execGarbageCollect);
	P_FINISH;
	UObject::CollectGarbage( RF_Native );
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 2622, execGarbageCollect );

IMPL_DIVERGE("DIVERGENCE: retail appends to global debug ring buffer DAT_1066679c — binary-specific global; dashed line debug rendering stubbed")
void AActor::execDrawDashedLine( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execDrawDashedLine);
	P_GET_VECTOR(Start);
	P_GET_VECTOR(End);
	P_GET_STRUCT(FColor,Color);
	P_FINISH;
	// Ghidra 0x1037b630: FArray::Add(&DAT_1066679c, 1, 4) then fills entry with Start/End/Color.
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 2608, execDrawDashedLine );

IMPL_DIVERGE("DIVERGENCE: retail appends to global debug ring buffer DAT_10666790 — binary-specific global; 3D text debug rendering stubbed")
void AActor::execDrawText3D( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execDrawText3D);
	P_GET_VECTOR(Loc);
	P_GET_STR(Text);
	P_GET_STRUCT(FColor,Color);
	P_FINISH;
	// Ghidra 0x10379ce0: FArray::Add(&DAT_10666790, 1, 4) then fills entry with Loc/Text/Color.
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 2609, execDrawText3D );

IMPL_DIVERGE("DIVERGENCE: retail stores render callback data in binary-specific globals (DAT_1066677c..10666788); render-from-actor stubbed")
void AActor::execRenderLevelFromMe( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execRenderLevelFromMe);
	P_FINISH;
	// Ghidra 0x103716a0: stores this-ptr and params to 5 consecutive global render-callback slots.
	unguard;
}
IMPLEMENT_FUNCTION( AActor, 2610, execRenderLevelFromMe );

IMPL_MATCH("Engine.dll", 0x10425720)
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

IMPL_MATCH("Engine.dll", 0x1042b7b0)
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

IMPL_MATCH("Engine.dll", 0x1042b880)
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

IMPL_MATCH("Engine.dll", 0x1042b950)
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

IMPL_MATCH("Engine.dll", 0x1042b9f0)
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
IMPL_MATCH("Engine.dll", 0x10305bf0)
INT AActor::IsPendingKill()
{
	return bDeleteMe;
}

IMPL_MATCH("Engine.dll", 0x10305c00)
INT AActor::IsPendingDelete()
{
	// Retail (32b RVA=0x5C00): checks bDeleteMe (bit7 @0xA0) first (JS path),
	// then bPendingDelete (bit0 @0xA9). Returns 1 if either is set.
	return bDeleteMe || bPendingDelete;
}

// Brush type queries
IMPL_MATCH("Engine.dll", 0x10314e20)
INT AActor::IsBrush() const
{
	return Brush!=NULL && IsA(ABrush::StaticClass());
}

IMPL_MATCH("Engine.dll", 0x10314e50)
INT AActor::IsStaticBrush() const
{
	return Brush!=NULL && IsA(ABrush::StaticClass()) && bStatic;
}

IMPL_MATCH("Engine.dll", 0x10314ea0)
INT AActor::IsMovingBrush() const
{
	return Brush!=NULL && IsA(ABrush::StaticClass()) && !bStatic;
}

IMPL_MATCH("Engine.dll", 0x10314ed0)
INT AActor::IsVolumeBrush() const
{
	return IsA(AVolume::StaticClass());
}

IMPL_MATCH("Engine.dll", 0x10314f00)
INT AActor::IsEncroacher() const
{
	return bCollideActors && (IsA(AMover::StaticClass()) || IsA(AKActor::StaticClass()));
}

// Editor / octree queries
IMPL_MATCH("Engine.dll", 0x103057e0)
INT AActor::IsHiddenEd()
{
	return bHiddenEd || bHiddenEdGroup;
}

IMPL_MATCH("Engine.dll", 0x10305c20)
INT AActor::IsInOctree()
{
	return OctreeNodes.Num() > 0;
}

IMPL_MATCH("Engine.dll", 0x10314f90)
UBOOL AActor::IsPlayer() const
{
	guardSlow(AActor::IsPlayer);
	if( !IsA(APawn::StaticClass()) )
		return 0;
	return ((APawn*)this)->m_bIsPlayer;
	unguardSlow;
}

// Simple getters
IMPL_MATCH("Engine.dll", 0x10314ff0)
ULevel* AActor::GetLevel() const
{
	return XLevel;
}

IMPL_MATCH("Engine.dll", 0x10301a90)
AActor* AActor::GetHitActor()
{
	return (AActor*)this;
}

IMPL_MATCH("Engine.dll", 0x10314f40)
AActor* AActor::GetTopOwner()
{
	AActor* Top;
	for( Top=(AActor*)this; Top->Owner!=NULL; Top=Top->Owner );
	return Top;
}

IMPL_MATCH("Engine.dll", 0x10305bc0)
FVector AActor::GetCylinderExtent() const
{
	return FVector(CollisionRadius, CollisionRadius, CollisionHeight);
}

IMPL_MATCH("Engine.dll", 0x10305c40)
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

IMPL_MATCH("Engine.dll", 0x10315000)
FRotator AActor::GetViewRotation()
{
	return Rotation;
}

IMPL_MATCH("Engine.dll", 0x10425560)
AActor* AActor::GetProjectorBase()
{
	return (AActor*)this;
}

IMPL_EMPTY("Ghidra VA 0x10414310 (RVA 0x114310) confirms retail body is trivial (3 bytes) — null return")
APawn* AActor::GetPawnOrColBoxOwner() const
{
	// Retail (3b): return NULL
	return NULL;
}

IMPL_EMPTY("Ghidra VA 0x10414310 (RVA 0x114310) confirms retail body is trivial (3 bytes) — null return")
APawn* AActor::GetPlayerPawn() const
{
	// Retail (3b): return NULL (no IsA check in retail)
	return NULL;
}

IMPL_MATCH("Engine.dll", 0x10378de0)
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
IMPL_MATCH("Engine.dll", 0x10378e40)
void AActor::SetOwner( AActor* NewOwner )
{
	guard(AActor::SetOwner);
	Owner = NewOwner;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10378740)
void AActor::SetDrawScale( FLOAT NewScale )
{
	guard(AActor::SetDrawScale);
	DrawScale = NewScale;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10378a60)
void AActor::SetDrawScale3D( FVector NewScale3D )
{
	guard(AActor::SetDrawScale3D);
	DrawScale3D = NewScale3D;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10378990)
void AActor::SetDrawType( EDrawType NewDrawType )
{
	guard(AActor::SetDrawType);
	DrawType = NewDrawType;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10378810)
void AActor::SetStaticMesh( UStaticMesh* NewStaticMesh )
{
	guard(AActor::SetStaticMesh);
	StaticMesh = NewStaticMesh;
	unguard;
}

// Ghidra 0x1037b4d0 (~140 bytes): iterates XLevel+0x5d0 game-type array (stride 0x98),
// calls GetR6AvailabilityPtr for each entry, sets availability flags.
// If GameType=="RGM_AllMode": enable all entries, disable AllMode flag.
// Else: enable all entries, disable the matching GameType entry.
IMPL_TODO("GetR6AvailabilityPtr returns NULL in base class so loop is no-op; XLevel+0x5d0 field not mapped (Ghidra 0x1037b4d0)")
void AActor::SetGameType( FString GameType )
{
	// Ghidra: iterates XLevel->gameTypes array; GetR6AvailabilityPtr is NULL in base class.
	// Until XLevel+0x5d0 field is mapped, the full implementation is deferred.
}


/*-----------------------------------------------------------------------------
	AActor method implementations -- batch from .bak reference.
	Reconstructed from Ghidra decompilation.
-----------------------------------------------------------------------------*/

// Ghidra 0x1037c130 (139 bytes): retail increments binary-specific global DAT_10666b50
// (& 0xF == 0 triggers GEngine->PaintProgress). Logic reproduced; address differs.
IMPL_DIVERGE("loading tick uses local static instead of retail binary global DAT_10666b50 (Ghidra 0x1037c130)")
void AActor::Serialize( FArchive& Ar )
{
	guard(AActor::Serialize);
	UObject::Serialize( Ar );
	if( Ar.LicenseeVer() > 11 )
		Ar << m_OutlineIndices;
	if ( Ar.IsLoading() )
	{
		static INT LoadActorTick = 0;
		if ( (++LoadActorTick & 0xF) == 0 )
			GEngine->PaintProgress();
	}
	unguard;
}

IMPL_MATCH("Engine.dll", 0x1037a860)
void AActor::PostLoad()
{
	guard(AActor::PostLoad);
	UObject::PostLoad();
	unguard;
}

IMPL_MATCH("Engine.dll", 0x1037a6f0)
void AActor::Destroy()
{
	guard(AActor::Destroy);
	UObject::Destroy();
	unguard;
}

IMPL_MATCH("Engine.dll", 0x1037bf60)
void AActor::PostEditChange()
{
	guard(AActor::PostEditChange);
	UObject::PostEditChange();
	unguard;
}

IMPL_MATCH("Engine.dll", 0x104255c0)
void AActor::InitExecution()
{
	guard(AActor::InitExecution);
	UObject::InitExecution();
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10370c00)
void AActor::ProcessEvent( UFunction* Function, void* Parms, void* Result )
{
	guard(AActor::ProcessEvent);
	UObject::ProcessEvent( Function, Parms, Result );
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10425070)
void AActor::ProcessState( FLOAT DeltaSeconds )
{
	guard(AActor::ProcessState);
	UObject::ProcessState( DeltaSeconds );
	unguard;
}

IMPL_MATCH("Engine.dll", 0x1042dd20)
INT AActor::ProcessRemoteFunction( UFunction* Function, void* Parms, FFrame* Stack )
{
	guard(AActor::ProcessRemoteFunction);
	return UObject::ProcessRemoteFunction( Function, Parms, Stack );
	unguard;
}

// Ghidra 0x1042d510 (425 bytes): dispatches to demo-replay system; checks function flags
// (0x74 & 0x2040 == 0x40), sets up FFrame, invokes GNatives. Demo recording omitted.
IMPL_TODO("demo recording omitted; retail dispatches function to replay system via FFrame (Ghidra 0x1042d510)")
void AActor::ProcessDemoRecFunction( UFunction* Function, void* Parms, FFrame* Stack )
{
	guard(AActor::ProcessDemoRecFunction);
	// Demo recording stub — no replay system in this reconstruction.
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10370920)
void AActor::NetDirty( UProperty* Property )
{
	// Retail (27b, RVA 0x70920): only mark bNetDirty if Property is non-null
	// AND has bit 5 of PropertyFlags at +0x40 set (CPF_Net = 0x20 = replicated).
	if (!Property) return;
	if (!(*(BYTE*)((BYTE*)Property + 0x40) & 0x20)) return;
	*(DWORD*)((BYTE*)this + 0xA0) |= 0x40000000u;  // set bNetDirty (bit 30 of bitfield at +0xA0)
}

// Ghidra 0x1037ab0 (RVA): checks global flag DAT_10650414 & 0x800 first — returns Ptr
// immediately if not set. When set, performs cached-property optimisation using
// DAT_106668bc/b8, UProperty::StaticClass(), and per-channel change tracking.
// Our version always returns Ptr (correct for the flag==0 fast path only).
IMPL_DIVERGE("returns Ptr (fast path only); retail also optimises via DAT_10650414&0x800 cache (Ghidra 0x1037ab0)")
INT* AActor::GetOptimizedRepList( BYTE* InDefault, FPropertyRetirement* Retire, INT* Ptr, UPackageMap* Map, UActorChannel* Ch )
{
	guard(AActor::GetOptimizedRepList);
	return Ptr;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10377de0)
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

IMPL_MATCH("Engine.dll", 0x103c4010)
INT AActor::IsNetRelevantFor( APlayerController* RealViewer, AActor* Viewer, FVector SrcLocation )
{
	guard(AActor::IsNetRelevantFor);
	return bAlwaysRelevant || (Owner == Viewer);
	unguard;
}

// Ghidra 0x1037e30 (~90 bytes): snapshots actor fields (Location+0x234, Rotation+0x240,
// DrawScale3D+0x24c, etc.) into binary-specific globals DAT_106666f4..DAT_10666728;
// then calls XLevel replication interface. Requires matching retail binary globals.
IMPL_DIVERGE("retail writes actor state snapshot to binary globals DAT_106666f4-1066672c (Ghidra 0x1037e30)")
void AActor::PreNetReceive()
{
    // STUB: requires binary-specific globals (DAT_106666f4 etc.) from retail Engine.dll
}

// Ghidra 0x103781f0 (~295 bytes): reads snapshot globals saved by PreNetReceive, applies
// position/rotation/physics changes via XLevel. Requires matching PreNetReceive globals.
IMPL_DIVERGE("reads binary globals saved by PreNetReceive; requires matching DAT_106666f4-* (Ghidra 0x103781f0)")
void AActor::PostNetReceive()
{
    // STUB: requires binary-specific globals (DAT_106666f4 etc.) from retail Engine.dll
}

// Ghidra 0x1037c210 (38 bytes): calls XLevel->MoveActor via vtable[0x9c] with
// the pre-receive location saved in DAT_106666f4/f8/fc by PreNetReceive.
IMPL_DIVERGE("calls XLevel MoveActor via vtable[0x9c] with location from DAT_106666f4/f8/fc (Ghidra 0x1037c210)")
void AActor::PostNetReceiveLocation()
{
    // STUB: requires binary-specific globals from PreNetReceive (DAT_106666f4/f8/fc)
}

IMPL_MATCH("Engine.dll", 0x10414310)
INT AActor::PlayerControlled()
{
	guard(AActor::PlayerControlled);
	// Retail: 0x114310 shared null-stub. Base always returns 0; APawn overrides.
	return 0;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10378ef0)
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

IMPL_MATCH("Engine.dll", 0x10378b40)
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

IMPL_MATCH("Engine.dll", 0x103712d0)
INT AActor::ShouldTrace( AActor* SourceActor, DWORD TraceFlags )
{
	guard(AActor::ShouldTrace);
	return (bCollideActors || bBlockActors || bBlockPlayers || bWorldGeometry);
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10314770)
void AActor::UpdateColBox( FVector& NewLocation, INT bTest, INT bForce, INT bIgnoreEncroach )
{
	guard(AActor::UpdateColBox);
	// Retail 0x14770: shared empty-virtual stub; no-op implementation.
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10305820)
FCoords AActor::ToLocal() const
{
	return GMath.UnitCoords / Rotation / Location;
}

IMPL_MATCH("Engine.dll", 0x10305860)
FCoords AActor::ToWorld() const
{
	return GMath.UnitCoords * Location * Rotation;
}

IMPL_MATCH("Engine.dll", 0x103058a0)
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

IMPL_MATCH("Engine.dll", 0x103192f0)
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

IMPL_MATCH("Engine.dll", 0x103c4870)
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

IMPL_MATCH("Engine.dll", 0x103c35c0)
void AActor::TickAuthoritative( FLOAT DeltaTime )
{
	guard(AActor::TickAuthoritative);
	// Advance timer counters, then run physics simulation.
	UpdateTimers( DeltaTime );
	performPhysics( DeltaTime );
	unguard;
}

IMPL_MATCH("Engine.dll", 0x103c33f0)
void AActor::TickSimulated( FLOAT DeltaTime )
{
	// Retail Engine.dll vtable[61]: mov eax,[ecx]; jmp [eax+0xF0]
	// Pure tail-call to TickAuthoritative (vtable slot 60). No guard/unguard in original.
	TickAuthoritative( DeltaTime );
}

IMPL_EMPTY("Retail Engine.dll: ret 4, truly empty function")
void AActor::TickSpecial( FLOAT DeltaTime )
{
	// Retail Engine.dll: ret 4 (truly empty, no SEH frame)
}

IMPL_MATCH("Engine.dll", 0x10371790)
INT AActor::TickThisFrame( FLOAT DeltaTime )
{
	guard(AActor::TickThisFrame);
	if( m_bSkipTick )
		return 0;
	return 1;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x103c3f60)
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

// Ghidra 0x103c3460 (60 bytes): no guard/unguard in retail; uses GEngineMem frame-arena.
// DIVERGE: MSVC 7.1 vs 2019 codegen differs even with identical logic.
IMPL_DIVERGE("codegen differs from retail MSVC 7.1 (Ghidra 0x103c3460); functionally equivalent")
INT AActor::CheckOwnerUpdated()
{
	// Retail: detect owner network-state change and queue actor for replication.
	// this+0x140 = Owner, Owner+0x320 bit0 = network state bit,
	// this+0x328 = replication-node ptr (ctrl), ctrl+0x100 = stored state, ctrl+0xF8 = list head.
	AActor* owner = *(AActor**)((BYTE*)this + 0x140);
	if ( !owner ) return 1;
	DWORD ownerBit = *(DWORD*)((BYTE*)owner + 0x320) & 1;
	BYTE* ctrl    = *(BYTE**)((BYTE*)this + 0x328);
	DWORD  ctrlBit = *(DWORD*)(ctrl + 0x100);
	if ( ownerBit == ctrlBit ) return 1;
	// Retail uses GEngineMem frame-arena (PushBytes(8,8)); we do the same.
	BYTE* node = GEngineMem.PushBytes( 8, 8 );
	if ( node )
	{
		BYTE* oldHead        = *(BYTE**)(ctrl + 0xF8);
		*(AActor**)node      = this;
		*(BYTE**)(node + 4)  = oldHead;
		*(BYTE**)(ctrl + 0xF8) = node;
		return 0;
	}
	*(DWORD*)(ctrl + 0xF8) = 0;
	return 0;
}

IMPL_EMPTY("Retail Engine.dll: ret, truly empty")
void AActor::BoundProjectileVelocity()
{
	// Retail Engine.dll: ret (truly empty)
}

IMPL_EMPTY("Retail Engine.dll: ret, truly empty")
void AActor::PostBeginPlay()
{
	// Retail Engine.dll: ret (truly empty, no SEH frame)
}

IMPL_EMPTY("Retail Engine.dll: ret, truly empty")
void AActor::PostEditLoad()
{
	// Retail Engine.dll: ret (truly empty)
}

IMPL_EMPTY("Retail Engine.dll: ret, truly empty")
void AActor::PostEditMove()
{
	// Retail Engine.dll: ret (truly empty)
}

IMPL_EMPTY("Retail Engine.dll: ret, truly empty")
void AActor::PostPath()
{
	// Retail Engine.dll: ret (truly empty)
}

IMPL_EMPTY("Retail Engine.dll: ret, truly empty")
void AActor::PostRaytrace()
{
	// Retail Engine.dll: ret (truly empty)
}

IMPL_EMPTY("Retail Engine.dll: ret, truly empty")
void AActor::PostScriptDestroyed()
{
	// Retail Engine.dll: ret (truly empty)
}

IMPL_EMPTY("Retail Engine.dll: ret, truly empty")
void AActor::PrePath()
{
	// Retail Engine.dll: ret (truly empty)
}

IMPL_EMPTY("Retail Engine.dll: ret, truly empty")
void AActor::PreRaytrace()
{
	// Retail Engine.dll: ret (truly empty)
}

IMPL_EMPTY("Retail Engine.dll: ret, truly empty")
void AActor::Spawned()
{
	// Retail Engine.dll: ret (truly empty)
}

IMPL_MATCH("Engine.dll", 0x10377d80)
UMaterial* AActor::GetSkin( INT Index )
{
	guard(AActor::GetSkin);
	if( Index < Skins.Num() && Skins(Index) )
		return Skins(Index);
	return Texture;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10377d30)
void AActor::NotifyAnimEnd( INT Channel )
{
	guard(AActor::NotifyAnimEnd);
	eventAnimEnd( Channel );
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10370bd0)
void AActor::UpdateAnimation( FLOAT DeltaSeconds )
{
	guard(AActor::UpdateAnimation);
	// Retail 0x10370bd0: if Mesh, call MeshGetInstance then tail-jump to MeshInstance->UpdateAnimation.
	if( Mesh )
	{
		Mesh->MeshGetInstance( this );
		if( MeshInstance )
			MeshInstance->UpdateAnimation( DeltaSeconds );
	}
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10420930)
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


IMPL_MATCH("Engine.dll", 0x10420AB0)
INT AActor::CheckAnimFinished( INT Channel )
{
	guard(AActor::CheckAnimFinished);
	// Retail 0x10420AB0.
	// Returns 1 (done) when: no mesh, not animating, or animation is looping (never ends).
	// Returns 0 (keep polling) only when animating a non-looping sequence.
	if( !Mesh )
		return 1;
	Mesh->MeshGetInstance( this );
	if( !IsAnimating( Channel ) )
		return 1;
	if( MeshInstance && MeshInstance->IsAnimLooping( Channel ) )
		return 1;
	return 0;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10370b90)
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

IMPL_MATCH("Engine.dll", 0x10420c60)
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

IMPL_MATCH("Engine.dll", 0x10370A80)
void AActor::PlayReplicatedAnim()
{
	guard(AActor::PlayReplicatedAnim);
	// Retail 0x10370A80: decode SimAnim packed bytes and drive MeshInstance->PlayAnim + SetAnimFrame.
	//
	// SimAnim field encoding (set by ReplicateAnim, recovered here):
	//   AnimRate  [+8]  = round((Rate_clamped[-4,4] + 4.0) * 31.0)
	//                     decoded as Rate = (byte - 124.0) / 31.0
	//   AnimFrame [+9]  = round((TweenTime_clamped[-1,1] + 1.0) * 127.0)
	//                     decoded as Frame = (byte - 127.0) / 127.0 for SetAnimFrame
	//   TweenRate [+10] = round(Frame_clamped[0,63] * 4.0)
	//                     decoded as TweenTime = 4.0 / byte for PlayAnim
	if( !Mesh )
		return;
	Mesh->MeshGetInstance( this );
	if( !MeshInstance )
		return;
	INT bLooping = SimAnim.bAnimLoop ? -1 : 0;
	FLOAT Rate     = ((FLOAT)SimAnim.AnimRate - 124.0f) * (1.0f / 31.0f);
	FLOAT TweenTime = (SimAnim.TweenRate != 0) ? (4.0f / (FLOAT)SimAnim.TweenRate) : 0.0f;
	MeshInstance->PlayAnim( 0, SimAnim.AnimSequence, Rate, TweenTime, bLooping, 0, 0 );
	FLOAT Frame    = ((FLOAT)SimAnim.AnimFrame - 127.0f) * (1.0f / 127.0f);
	MeshInstance->SetAnimFrame( 0, Frame );
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10377B40)
void AActor::ReplicateAnim( INT Channel, FName SequenceName, FLOAT Rate, FLOAT TweenTime, FLOAT Frame, FLOAT LastFrame, INT bLooping )
{
	guard(AActor::ReplicateAnim);
	// Retail 0x10377B40: pack animation state into SimAnim for network replication.
	// Only Channel 0 is replicated via SimAnim.
	if( Channel != 0 )
		return;

	// Encode Rate → AnimRate byte: round((clamp(Rate,-4,4) + 4.0) * 31.0).
	// Special case: if LastFrame == 0 (no referece frame) use neutral value 124.
	BYTE NewAnimRate;
	if( LastFrame == 0.0f )
		NewAnimRate = 124;
	else
	{
		FLOAT r = Clamp( Rate, -4.0f, 4.0f );
		NewAnimRate = (BYTE)appRound( (r + 4.0f) * 31.0f );
	}

	// Encode TweenTime → AnimFrame byte: round((clamp(TweenTime,0,1) + 1.0) * 127.0).
	// Negative or zero tween encodes as 0.
	BYTE NewAnimFrame;
	if( TweenTime <= 0.0f )
		NewAnimFrame = 0;
	else
	{
		FLOAT t = Clamp( TweenTime, 0.0f, 1.0f );
		NewAnimFrame = (BYTE)appRound( (t + 1.0f) * 127.0f );
	}

	// Encode Frame → TweenRate byte: round(clamp(Frame,0,63) * 4.0).
	BYTE NewTweenRate = (BYTE)appRound( Clamp( Frame, 0.0f, 63.0f ) * 4.0f );

	// Mark actor dirty for replication if any field changed.
	if( SimAnim.AnimSequence  != SequenceName  ||
	    SimAnim.AnimRate      != NewAnimRate    ||
	    SimAnim.AnimFrame     != NewAnimFrame   ||
	    SimAnim.TweenRate     != NewTweenRate   ||
	    (INT)SimAnim.bAnimLoop != (bLooping != 0 ? 1 : 0) )
	{
		*(DWORD*)((BYTE*)this + 0xA0) |= 0x40000000u;  // set bNetDirty
	}

	SimAnim.AnimSequence  = SequenceName;
	SimAnim.bAnimLoop     = (bLooping != 0) ? 1 : 0;
	SimAnim.AnimRate      = NewAnimRate;
	SimAnim.AnimFrame     = NewAnimFrame;
	SimAnim.TweenRate     = NewTweenRate;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x103798D0)
void AActor::AnimBlendParams( INT Channel, FLOAT BlendAlpha, FLOAT InTime, FLOAT OutTime, FName BoneName )
{
	guard(AActor::AnimBlendParams);
	// Retail 0x103798D0: IsA(USkeletalMesh) check, then MeshGetInstance, then SetBlendParams.
	if( Mesh && Mesh->IsA( USkeletalMesh::StaticClass() ) )
	{
		Mesh->MeshGetInstance( this );
		USkeletalMeshInstance* MI = Cast<USkeletalMeshInstance>( MeshInstance );
		if( MI )
			MI->SetBlendParams( Channel, BlendAlpha, InTime, OutTime, BoneName, INDEX_NONE );
	}
	unguard;
}

IMPL_MATCH("Engine.dll", 0x1037aac0)
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

IMPL_MATCH("Engine.dll", 0x1037c030)
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

IMPL_MATCH("Engine.dll", 0x103b73d0)
void AActor::NotifyBump( AActor* Other )
{
	guard(AActor::NotifyBump);
	eventBump( Other );
	unguard;
}

IMPL_MATCH("Engine.dll", 0x1037c1f0)
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

IMPL_MATCH("Engine.dll", 0x10379020)
INT AActor::AttachToBone( AActor* Attachment, FName BoneName )
{
	guard(AActor::AttachToBone);
	// Retail 0x10379020.
	// Validates mesh is skeletal, finds the bone index via MatchRefBone, stores
	// AttachmentBone on the attachment, then SetBase to anchor it.
	if( !Mesh || !Mesh->IsA( USkeletalMesh::StaticClass() ) )
		return 0;
	Mesh->MeshGetInstance( this );
	USkeletalMeshInstance* MI = Cast<USkeletalMeshInstance>( MeshInstance );
	if( !MI )
		return 0;
	INT BoneIdx = MI->MatchRefBone( BoneName );
	if( BoneIdx <= -1 )
		return 0;
	if( !Attachment )
		return 0;
	Attachment->AttachmentBone = BoneName;
	Attachment->SetBase( this, FVector(0,0,1), 1 );
	return 1;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10379160)
INT AActor::DetachFromBone( AActor* Attachment )
{
	guard(AActor::DetachFromBone);
	// Retail 0x10379160.
	// Calls SetBase(NULL) on the attachment then clears its AttachmentBone.
	if( !Mesh || !Mesh->IsA( USkeletalMesh::StaticClass() ) )
		return 0;
	if( !Attachment )
		return 0;
	Attachment->SetBase( NULL, FVector(0,0,1), 1 );
	Attachment->AttachmentBone = NAME_None;
	return 1;
	unguard;
}

// Ghidra 0x1042dfa0 (~800 bytes): fast path for static mesh instances (type==0x8),
// slow path builds projector render info, iterates mesh primitives, allocates FMatrix.
// Requires full projector render subsystem; binary-specific vtable calls at +0x100/0x7c/0x80.
IMPL_DIVERGE("projector render subsystem not implemented; binary-specific vtable calls (Ghidra 0x1042dfa0)")
void AActor::AttachProjector( AProjector* Proj )
{
    // STUB: requires projector render subsystem and binary-specific vtable slots
}

// Ghidra 0x1042d870 (174 bytes): checks static mesh fast path (type==0x8), then searches
// projector array at +0x344, decrements refcount, frees via FUN_1031f5e0 if 0.
IMPL_DIVERGE("projector render subsystem not implemented; searches +0x344 array and frees via binary-specific FUN_1031f5e0 (Ghidra 0x1042d870)")
void AActor::DetachProjector( AProjector* Proj )
{
    // STUB: requires projector array at +0x344 and binary-specific FUN_1031f5e0
}

IMPL_MATCH("Engine.dll", 0x1037cd20)
void AActor::SetCollision( INT bNewCollideActors, INT bNewBlockActors, INT bNewBlockPlayers )
{
	guard(AActor::SetCollision);
	bCollideActors = bNewCollideActors;
	bBlockActors   = bNewBlockActors;
	bBlockPlayers  = bNewBlockPlayers;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10378660)
void AActor::SetCollisionSize( FLOAT NewRadius, FLOAT NewHeight )
{
	guard(AActor::SetCollisionSize);
	CollisionRadius = NewRadius;
	CollisionHeight = NewHeight;
	unguard;
}

IMPL_DIVERGE("DIVERGENCE: retail rebuilds static mesh batches; render data rebuilt implicitly at draw time")
void AActor::UpdateRenderData()
{
	guard(AActor::UpdateRenderData);
	// DIVERGENCE: retail rebuilds static mesh batches and cached light maps here.
	// Render data is rebuilt implicitly at draw time in our reconstruction.
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10305800)
FLOAT AActor::WorldLightRadius() const
{
	// Retail (19b): LightRadius * 1.0 * 25.0
	return 25.f * LightRadius;
}

// Ghidra 0x1040c960 (2237 bytes): large editor visualization function.
// Renders actor type indicators, collision hulls, and debug annotations.
// Requires render interface types not fully mapped in this reconstruction.
IMPL_TODO("editor rendering subsystem not implemented; 2237 bytes at Ghidra 0x1040c960")
void AActor::RenderEditorInfo( FLevelSceneNode* SceneNode, FRenderInterface* RI, FDynamicActor* Actor )
{
    // STUB: requires editor render subsystem (FRenderInterface, FLevelSceneNode calls)
}

// Ghidra 0x1040b2f0 (1601 bytes): renders selection highlight for selected actors.
// Outlines mesh primitives and calls render interface via binary-specific vtable layout.
IMPL_TODO("editor selection rendering not implemented; 1601 bytes at Ghidra 0x1040b2f0")
void AActor::RenderEditorSelected( FLevelSceneNode* SceneNode, FRenderInterface* RI, FDynamicActor* Actor )
{
    // STUB: requires editor render subsystem (FRenderInterface, FLevelSceneNode calls)
}

IMPL_MATCH("Engine.dll", 0x103bd2a0)
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

IMPL_MATCH("Engine.dll", 0x103bb740)
void AActor::SetVolumes( const TArray<AVolume*>& NewVolumes )
{
	guard(AActor::SetVolumes);
	for( INT i = 0; i < NewVolumes.Num(); i++ )
	{
		AVolume* Vol = NewVolumes(i);
		if( !Vol )
			continue;
		APhysicsVolume* PVol = Vol->IsA(APhysicsVolume::StaticClass()) ? (APhysicsVolume*)Vol : NULL;
		UBOOL bBothCollide = (bCollideWorld && Vol->bCollideWorld);
		if( (bBothCollide || PVol) && Vol->Encompasses(Location) )
		{
			if( bBothCollide )
			{
				Vol->Touching.AddItem(this);
				Touching.AddItem(Vol);
			}
			if( PVol && PVol->Priority > PhysicsVolume->Priority )
				PhysicsVolume = PVol;
		}
	}
	unguard;
}

IMPL_MATCH("Engine.dll", 0x103bb5a0)
void AActor::SetVolumes()
{
	guard(AActor::SetVolumes_void);
	for( INT i = 0; i < XLevel->Actors.Num(); i++ )
	{
		AActor* A = XLevel->Actors(i);
		if( !A || !A->IsA(AVolume::StaticClass()) )
			continue;
		AVolume* Vol = (AVolume*)A;
		APhysicsVolume* PVol = A->IsA(APhysicsVolume::StaticClass()) ? (APhysicsVolume*)A : NULL;
		UBOOL bBothCollide = (bCollideWorld && Vol->bCollideWorld);
		if( (bBothCollide || PVol) && Vol->Encompasses(Location) )
		{
			if( bBothCollide )
			{
				Vol->Touching.AddItem(this);
				Touching.AddItem(Vol);
			}
			if( PVol && PVol->Priority > PhysicsVolume->Priority )
				PhysicsVolume = PVol;
		}
	}
	unguard;
}

IMPL_MATCH("Engine.dll", 0x103f16b0)
void AActor::setPhysics( BYTE NewPhysics, AActor* NewFloor, FVector NewFloorV )
{
	guard(AActor::setPhysics);
	Physics = NewPhysics;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x103f3670)
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

IMPL_MATCH("Engine.dll", 0x103f19b0)
void AActor::processHitWall( FVector HitNormal, AActor* HitActor )
{
	guard(AActor::processHitWall);
	eventHitWall( HitNormal, HitActor );
	unguard;
}

IMPL_MATCH("Engine.dll", 0x103f1dd0)
void AActor::processLanded( FVector HitNormal, AActor* HitActor, FLOAT RemainingTime, INT Iterations )
{
	guard(AActor::processLanded);
	eventLanded( HitNormal );
	unguard;
}

IMPL_MATCH("Engine.dll", 0x103f21c0)
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

IMPL_MATCH("Engine.dll", 0x103f2e80)
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

IMPL_MATCH("Engine.dll", 0x103f11d0)
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

IMPL_MATCH("Engine.dll", 0x103f31f0)
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

IMPL_MATCH("Engine.dll", 0x103ed150)
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

IMPL_MATCH("Engine.dll", 0x103ec7b0)
FRotator AActor::FindSlopeRotation( FVector FloorNormal, FRotator NewRotation )
{
	guard(AActor::FindSlopeRotation);
	return NewRotation;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x103f15c0)
void AActor::SmoothHitWall( FVector HitNormal, AActor* HitActor )
{
	guard(AActor::SmoothHitWall);
	processHitWall( HitNormal, HitActor );
	unguard;
}

IMPL_MATCH("Engine.dll", 0x103ef2f0)
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

IMPL_MATCH("Engine.dll", 0x103ecb30)
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

IMPL_MATCH("Engine.dll", 0x103ed040)
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

IMPL_MATCH("Engine.dll", 0x10305c60)
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

IMPL_MATCH("Engine.dll", 0x103ecf00)
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

IMPL_MATCH("Engine.dll", 0x10379e30)
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

IMPL_MATCH("Engine.dll", 0x10361940)
struct _McdModel* AActor::getKModel() const
{
    // Ghidra 0x61940: KParams at this+0x18c; return KParams->McdModel at KParams+0x48
    if( !KParams ) return NULL;
    return *( struct _McdModel** )( (BYTE*)KParams + 0x48 );
}

IMPL_DIVERGE("Karma physics wrapper; omits binary-specific rdtsc profiling counter update")
void AActor::physKarma( FLOAT DeltaTime )
{
    // DIVERGENCE: omits original rdtsc profiling counter update (binary-specific globals)
    guard(AActor::physKarma);
    physKarma_internal( DeltaTime );
    unguard;
}

IMPL_DIVERGE("Karma physics; stub; too complex to reconstruct without full Karma SDK")
void AActor::physKarma_internal( FLOAT DeltaTime )
{
    // STUB: too complex (complex, Ghidra)
}

IMPL_DIVERGE("Karma ragdoll physics wrapper; omits binary-specific rdtsc profiling counter update")
void AActor::physKarmaRagDoll( FLOAT DeltaTime )
{
    // DIVERGENCE: omits original rdtsc profiling counter update (binary-specific globals)
    guard(AActor::physKarmaRagDoll);
    physKarmaRagDoll_internal( DeltaTime );
    unguard;
}

IMPL_DIVERGE("Karma ragdoll physics; stub; too complex to reconstruct without full Karma SDK")
void AActor::physKarmaRagDoll_internal( FLOAT DeltaTime )
{
    // STUB: too complex (1600 bytes in Ghidra)
}

IMPL_DIVERGE("Karma pre-step; stub; requires full Karma SDK")
void AActor::preKarmaStep( FLOAT DeltaTime )
{
    // STUB: too complex (complex, Ghidra)
}

IMPL_DIVERGE("Karma post-step; stub; requires full Karma SDK")
void AActor::postKarmaStep()
{
    // STUB: too complex (complex, Ghidra)
}

IMPL_DIVERGE("Karma skeletal pre-step; stub; requires full Karma SDK")
void AActor::preKarmaStep_skeletal( FLOAT DeltaTime )
{
    // STUB: too complex (complex, Ghidra)
}

IMPL_DIVERGE("Karma skeletal post-step; stub; requires full Karma SDK")
void AActor::postKarmaStep_skeletal()
{
    // STUB: too complex (complex, Ghidra)
}

IMPL_MATCH("Engine.dll", 0x10305e90)
INT AActor::KMP2DynKarmaInterface( INT Mode, FVector Position, FRotator Rotation, AActor* Other )
{
	guard(AActor::KMP2DynKarmaInterface);
	// Retail: 0x5e90, 6b (xor eax,eax; ret). Base actor has no Karma dynamic interface.
	return 0;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x103d5ad0)
AActor* AActor::AssociatedLevelGeometry()
{
	// Retail Engine.dll vtable[86]: returns this if bWorldGeometry is set, else NULL.
	// mov eax,[ecx+0xA0]; and eax,0x100000; neg; sbb eax,eax; and eax,ecx; ret
	return bWorldGeometry ? this : NULL;
}

IMPL_MATCH("Engine.dll", 0x103d5b00)
INT AActor::HasAssociatedLevelGeometry( AActor* Other )
{
	// Retail Engine.dll: test bWorldGeometry flag; returns 1 only if this actor
	// has bWorldGeometry set AND Other IS this actor.
	return (bWorldGeometry && Other == this) ? 1 : 0;
}

IMPL_DIVERGE("Calls FUN_10367df0 (unresolved Karma internal) and XLevel+0xf0 chain — see Ghidra 0x10361fb0")
void AActor::KFreezeRagdoll()
{
	guard(AActor::KFreezeRagdoll);
	// Retail: checks USkeletalMeshInstance at this+0x324, then calls FUN_10367df0 (unresolved
	// Karma internal) and accesses XLevel+0xf0 (unknown field). Not a no-op in retail.
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10414310)
INT AActor::IsRelevantToPawnHeartBeat( APawn* P )
{
	guard(AActor::IsRelevantToPawnHeartBeat);
	// Retail: 0x114310 shared null-stub. Base actors are not heart-beat relevant.
	return 0;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10414310)
INT AActor::IsRelevantToPawnHeatVision( APawn* P )
{
	guard(AActor::IsRelevantToPawnHeatVision);
	// Retail: 0x114310 shared null-stub. Base actors are not heat-vision relevant.
	return 0;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10414310)
INT AActor::IsRelevantToPawnRadar( APawn* P )
{
	guard(AActor::IsRelevantToPawnRadar);
	// Retail: 0x114310 shared null-stub. Base actors are not radar relevant.
	return 0;
	unguard;
}

// Ghidra 0x103978a0 (2040 bytes): validates actor consistency — checks bDeleteMe, hidden
// default vs instance flags, duplicate locations, broken base links, Karma params.
// Requires XLevel actor list, GWarn, UClass::GetDefaultActor. Deferred.
IMPL_TODO("editor validation function 2040 bytes; requires XLevel actor list and GWarn (Ghidra 0x103978a0)")
void AActor::CheckForErrors()
{
    // STUB: requires full editor environment (GWarn, XLevel actor iteration)
}

IMPL_EMPTY("Retail: shared empty-virtual stub; base AActor no-op")
void AActor::AddMyMarker( AActor* S )
{
	guard(AActor::AddMyMarker);
	// Retail: shared empty-virtual stub; no-op implementation.
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10314f10)
UBOOL AActor::IsOwnedBy( const AActor* TestOwner ) const
{
	guardSlow(AActor::IsOwnedBy);
	for( const AActor* Arg=this; Arg; Arg=Arg->Owner )
		if( Arg == TestOwner )
			return 1;
	return 0;
	unguardSlow;
}

IMPL_MATCH("Engine.dll", 0x10314fc0)
UBOOL AActor::IsBasedOn( const AActor* Other ) const
{
	guard(AActor::IsBasedOn);
	for( const AActor* Test=this; Test!=NULL; Test=Test->Base )
		if( Test == Other )
			return 1;
	return 0;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10314f60)
UBOOL AActor::IsInZone( const AZoneInfo* TestZone ) const
{
	return Region.Zone!=Level ? Region.Zone==TestZone : 1;
}

IMPL_MATCH("Engine.dll", 0x103195f0)
FLOAT AActor::LifeFraction()
{
	return Clamp( 1.f - LifeSpan / GetClass()->GetDefaultActor()->LifeSpan, 0.f, 1.f );
}

IMPL_MATCH("Engine.dll", 0x103710d0)
INT AActor::IsJoinedTo( const AActor* Other ) const
{
    for( const AActor* A = this; A; A = A->Base )
    {
        if( A == Other )
            return 1;
        if( A && Other && A->JoinedTag != 0 && A->JoinedTag == Other->JoinedTag )
            return 1;
    }
    return 0;
}

IMPL_MATCH("Engine.dll", 0x103e5750)
INT AActor::TestCanSeeMe( APlayerController* Viewer )
{
    guard(AActor::TestCanSeeMe);
    if( !Viewer ) return 0;
    // Ghidra 0xe5750: vtable[0x18c/4] = GetViewTarget()
    AActor* viewerTarget = Viewer->GetViewTarget();
    if( viewerTarget == this ) return 1;
    // ViewTarget/camera origin actor at APlayerController+0x5b8
    AActor* viewActor = *(AActor**)((BYTE*)Viewer + 0x5b8);
    FLOAT dX = Location.X - viewActor->Location.X;
    FLOAT dY = Location.Y - viewActor->Location.Y;
    FLOAT dZ = Location.Z - viewActor->Location.Z;
    FLOAT distSq = dX*dX + dY*dY + dZ*dZ;
    // Sight range: (field_0xf8 + 3.6) * 100000 — field_0xf8 is a per-actor visibility modifier
    if( distSq < (*(FLOAT*)((BYTE*)this + 0xf8) + 3.6f) * 100000.f )
    {
        // APlayerController+0x524 bit 0x20 = bBehindView-style flag; if clear, apply FOV check
        if( !(*(BYTE*)((BYTE*)Viewer + 0x524) & 0x20) )
        {
            // Camera look direction from rotation at APlayerController+0x240
            FVector camDir = (*(FRotator*)((BYTE*)Viewer + 0x240)).Vector();
            FLOAT dot = dX * camDir.X + dY * camDir.Y + dZ * camDir.Z;
            // Return 0 if actor is more than 60 degrees outside camera FOV
            if( distSq * 0.25f > dot * dot )
                return 0;
        }
        return Viewer->LineOfSightTo( this, 0 ) ? 1 : 0;
    }
    return 0;
    unguard;
}

IMPL_MATCH("Engine.dll", 0x10370c30)
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

IMPL_MATCH("Engine.dll", 0x1038eb20)
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

IMPL_MATCH("Engine.dll", 0x104294e0)
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

IMPL_MATCH("Engine.dll", 0x103f02e0)
void AActor::GetNetBuoyancy( FLOAT& NetBuoyancy, FLOAT& NetFluidFriction )
{
	guard(AActor::GetNetBuoyancy);
	NetBuoyancy = Buoyancy;
	NetFluidFriction = 0.f;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10379fd0)
void AActor::SafeDestroyActor( AActor* A )
{
	guard(AActor::SafeDestroyActor);
	if( A && !A->bDeleteMe )
		A->eventDestroyed();
	unguard;
}

IMPL_MATCH("Engine.dll", 0x1037b430)
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

IMPL_MATCH("Engine.dll", 0x10423270)
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

IMPL_MATCH("Engine.dll", 0x10423690)
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

// Ghidra 0x1042c8e0 (268 bytes): if FileName is empty, fills it from
// GModMgr->eventGetServerIni() + ".ini"; then calls UObject::SaveConfig(0x4000, filename)
// on GServerOptions and the sub-options object at GServerOptions+0x58.
IMPL_MATCH("Engine.dll", 0x1042c8e0)
void AActor::SaveServerOptions( FString FileName )
{
    guard(AActor::SaveServerOptions);
    // If no filename supplied, derive it from the mod manager's server INI path.
    if( FileName.Len() == 0 )
    {
        FString Base = GModMgr->eventGetServerIni();
        FileName = FString::Printf( TEXT("%s.ini"), *Base );
    }
    if( GServerOptions )
    {
        GServerOptions->SaveConfig( 0x4000, *FileName );
        // Sub-options object lives at offset +0x58 in UR6ServerInfo (not mapped in class
        // decl but confirmed by Ghidra; same SaveConfig call chain as retail).
        UObject* pSub = *(UObject**)( (BYTE*)GServerOptions + 0x58 );
        if( pSub )
            pSub->SaveConfig( 0x4000, *FileName );
    }
    unguard;
}

IMPL_MATCH("Engine.dll", 0x1037aed0)
BYTE* AActor::GetR6AvailabilityPtr( FString GameType, INT Index )
{
	guard(AActor::GetR6AvailabilityPtr);
	return NULL;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x1037b320)
INT AActor::IsAvailableInGameType( FString GameType )
{
	guard(AActor::IsAvailableInGameType);
	if( !m_bUseR6Availability )
		return 1;
	return 1;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10423b60)
INT AActor::NativeNonUbiMatchMaking()
{
    guard(AActor::NativeNonUbiMatchMaking);
    return ParseParam( appCmdLine(), TEXT("Ip=") );
    unguard;
}

IMPL_MATCH("Engine.dll", 0x10423a40)
INT AActor::NativeNonUbiMatchMakingHost()
{
    guard(AActor::NativeNonUbiMatchMakingHost);
    return ParseParam( appCmdLine(), TEXT("Host") );
    unguard;
}

IMPL_MATCH("Engine.dll", 0x10423920)
INT AActor::NativeStartedByGSClient()
{
	guard(AActor::NativeStartedByGSClient);
	// Retail: 0x123920, 27b. Check command-line for GS start flag.
	return ParseParam( appCmdLine(), TEXT("GS:\"StartedByGS\"") );
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10371250)
void AActor::DbgAddLine( FVector Start, FVector End, FColor Color )
{
    if( ++GDbgLineIndex > 99 )
        GDbgLineIndex = 0;
    GDbgLine[ GDbgLineIndex ].Start = Start;
    GDbgLine[ GDbgLineIndex ].End   = End;
    GDbgLine[ GDbgLineIndex ].Color = Color;
}

// Ghidra 0x103794d0 (428 bytes): stores debug vector data at VectorIndex in m_dbgVectorInfo.
// Retail uses a binary-specific color lookup table (DAT_10666b2c, 8-slot pointer array
// indexed by (VectorIndex>>2)&7) when Color==NULL; we fall back to white.
// All other logic (array growth, field assignment, FString copy) matches Ghidra exactly.
IMPL_DIVERGE("default color when Color==NULL differs: retail reads from binary globals DAT_10666b2c table (Ghidra 0x103794d0)")
void AActor::DbgVectorAdd( FVector Point, FVector Cylinder, INT VectorIndex, FString Def, FColor* Color )
{
    if( VectorIndex < 0 )
        return;
    // Retail initialises with 10 zeroed slots on first use, then extends as needed.
    if( m_dbgVectorInfo.Num() == 0 )
        m_dbgVectorInfo.AddZeroed( 10 );
    while( m_dbgVectorInfo.Num() <= VectorIndex )
        m_dbgVectorInfo.AddZeroed( 1 );
    FDbgVectorInfo& info = m_dbgVectorInfo( VectorIndex );
    info.m_bDisplay  = 1;
    info.m_vLocation = Point;
    info.m_vCylinder = Cylinder;
    // Retail: if Color==NULL, reads from a 8-slot binary-global FColor* table.
    // DIVERGENCE: use white as fallback instead of binary-specific table lookup.
    info.m_color     = Color ? *Color : FColor(255,255,255,255);
    info.m_szDef     = Def;
}

// Ghidra 0x103791f0 (681 bytes): iterates m_dbgVectorInfo entries and draws each as a
// cylinder + label via FRenderInterface. Requires render interface not fully mapped.
IMPL_TODO("iterates m_dbgVectorInfo and draws via FRenderInterface; render types not mapped (Ghidra 0x103791f0)")
void AActor::DbgVectorDraw( FLevelSceneNode* SceneNode, FRenderInterface& RI )
{
    // STUB: requires FRenderInterface draw calls (cylinder, text label)
}

IMPL_MATCH("Engine.dll", 0x103794a0)
void AActor::DbgVectorReset( INT VectorIndex )
{
    if( VectorIndex < m_dbgVectorInfo.Num() )
        m_dbgVectorInfo( VectorIndex ).m_bDisplay = 0;
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/

// =============================================================================
// ABrush (moved from EngineClassImpl.cpp)
// =============================================================================

// ABrush
// =============================================================================

IMPL_MATCH("Engine.dll", 0x1037ae60)
void ABrush::PostLoad() { Super::PostLoad(); }
IMPL_MATCH("Engine.dll", 0x103077b0)
void ABrush::PostEditChange() { Super::PostEditChange(); }
IMPL_MATCH("Engine.dll", 0x10307b40)
FCoords ABrush::ToLocal() const
{
	// Retail (112b, RVA 0x7B40):
	// Builds sv = {|TempScale.Scale.Z|, |TempScale.SheerRate|, |TempScale.SheerAxis as FLOAT|}
	// then computes: UnitCoords / sv / (FRotator reinterpret)Location / (FVector reinterpret)Rotation
	FVector sv(
		Abs<FLOAT>(TempScale.Scale.Z),
		Abs<FLOAT>(TempScale.SheerRate),
		Abs<FLOAT>(*(FLOAT*)&TempScale.SheerAxis)
	);
	return GMath.UnitCoords
		/ sv
		/ *(FRotator*)&Location
		/ *(FVector*)&Rotation;
}
IMPL_MATCH("Engine.dll", 0x10307bc0)
FCoords ABrush::ToWorld() const
{
	// Retail (112b, RVA 0x7BC0):
	// Symmetric inverse: UnitCoords * (FVector reinterpret)Rotation * (FRotator reinterpret)Location * sv
	FVector sv(
		Abs<FLOAT>(TempScale.Scale.Z),
		Abs<FLOAT>(TempScale.SheerRate),
		Abs<FLOAT>(*(FLOAT*)&TempScale.SheerAxis)
	);
	return GMath.UnitCoords
		* *(FVector*)&Rotation
		* *(FRotator*)&Location
		* sv;
}
IMPL_MATCH("Engine.dll", 0x10378e20)
UPrimitive* ABrush::GetPrimitive()
{
	// Retail (27b, RVA 0x78E20): check Brush/UModel primitive field, then
	// fall through to the same nested StaticMeshInstance-like chain at +0x328.
	UPrimitive* p;
	if ((p = *(UPrimitive**)((BYTE*)this + 0x178)) != NULL) return p; // Brush/UModel
	void* c = *(void**)((BYTE*)this + 0x328);
	if (!c) return NULL;
	p = *(UPrimitive**)((BYTE*)c + 0x44);
	if (!p) return NULL;
	return *(UPrimitive**)((BYTE*)p + 0x40);
}
IMPL_MATCH("Engine.dll", 0x10398180)
void ABrush::CheckForErrors() { Super::CheckForErrors(); }
IMPL_EMPTY("Retail body is also empty — confirmed no-op")
void ABrush::CopyPosRotScaleFrom(ABrush* Other) {}
IMPL_MATCH("Engine.dll", 0x10371110)
void ABrush::InitPosRotScale()
{
    guard(ABrush::InitPosRotScale);
    check(Brush);
    *(FScale*)((BYTE*)this + 0x3b0) = GMath.UnitScale;
    *(FScale*)((BYTE*)this + 0x3c4) = GMath.UnitScale;
    Location  = FVector(0,0,0);
    Rotation  = FRotator(0,0,0);
    // PrePivot — hidden at raw offset 0x2c8 due to gap in EngineClasses.h reconstruction
    *(FVector*)((BYTE*)this + 0x2c8) = FVector(0,0,0);
    unguard;
}
IMPL_MATCH("Engine.dll", 0x10307c40)
FLOAT ABrush::BuildCoords( FModelCoords* Coords, FModelCoords* UnCoords )
{
	guard(ABrush::BuildCoords);
	if( Coords )
	{
		Coords->PointXform  = GMath.UnitCoords;
		Coords->VectorXform = GMath.UnitCoords.Transpose();
	}
	if( UnCoords )
	{
		UnCoords->PointXform  = GMath.UnitCoords;
		UnCoords->VectorXform = GMath.UnitCoords.Transpose();
	}
	return 0.0f;
	unguard;
}
// Ghidra 0x10307930 (471 bytes): builds model coords from TempScale (FScale at +0x3B0) and
// a second FScale at +0x3C4, combined with Location/Rotation. Returns product of their
// FScale::Orientation() values. FScale field layout at +0x3B0/0x3C4 not yet confirmed.
IMPL_TODO("FScale fields at +0x3B0/0x3C4 not confirmed; falls back to identity transforms (Ghidra 0x10307930)")
FLOAT ABrush::OldBuildCoords( FModelCoords* Coords, FModelCoords* UnCoords )
{
	// Retail RVA 0x7930 (0x10307930): builds model coords from brush TempScale, Location
	// (as FRotator), Rotation (as FVector), and two hidden FScale fields at +0x3B0 and +0x3C4.
	// Returns FScale::Orientation(s3b0) * FScale::Orientation(s3c4).
	// Approximation: fall back to identity transforms until full field layout is confirmed.
	if( Coords )
	{
		Coords->PointXform  = GMath.UnitCoords;
		Coords->VectorXform = GMath.UnitCoords.Transpose();
	}
	if( UnCoords )
	{
		UnCoords->PointXform  = GMath.UnitCoords;
		UnCoords->VectorXform = GMath.UnitCoords.Transpose();
	}
	FScale& s3b0 = *(FScale*)((BYTE*)this + 0x3B0);
	FScale& s3c4 = *(FScale*)((BYTE*)this + 0x3C4);
	return s3b0.Orientation() * s3c4.Orientation();
}
IMPL_MATCH("Engine.dll", 0x103077d0)
FCoords ABrush::OldToLocal() const
{
	// Retail (168b, RVA 0x77D0):
	// Like ToLocal but with two hidden FScale fields (at +0x3B0 and +0x3C4, init'd to GMath.UnitScale):
	// UnitCoords / sv / scale3b0 / (FRotator reinterpret)Location / scale3c4 / (FVector reinterpret)Rotation
	FVector sv(
		Abs<FLOAT>(TempScale.Scale.Z),
		Abs<FLOAT>(TempScale.SheerRate),
		Abs<FLOAT>(*(FLOAT*)&TempScale.SheerAxis)
	);
	const FScale& s3b0 = *(FScale*)((BYTE*)this + 0x3B0);
	const FScale& s3c4 = *(FScale*)((BYTE*)this + 0x3C4);
	return GMath.UnitCoords
		/ sv
		/ s3b0
		/ *(FRotator*)&Location
		/ s3c4
		/ *(FVector*)&Rotation;
}
IMPL_MATCH("Engine.dll", 0x10307880)
FCoords ABrush::OldToWorld() const
{
	// Retail (168b, RVA 0x7880):
	// Symmetric inverse of OldToLocal:
	// UnitCoords * (FVector reinterpret)Rotation * scale3c4 * (FRotator reinterpret)Location * scale3b0 * sv
	FVector sv(
		Abs<FLOAT>(TempScale.Scale.Z),
		Abs<FLOAT>(TempScale.SheerRate),
		Abs<FLOAT>(*(FLOAT*)&TempScale.SheerAxis)
	);
	const FScale& s3b0 = *(FScale*)((BYTE*)this + 0x3B0);
	const FScale& s3c4 = *(FScale*)((BYTE*)this + 0x3C4);
	return GMath.UnitCoords
		* *(FVector*)&Rotation
		* s3c4
		* *(FRotator*)&Location
		* s3b0
		* sv;
}

// =============================================================================
