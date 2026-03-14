/*=============================================================================
	UnEffects.cpp: AEmitter, AProjector, UParticleEmitter implementation.
	Reconstructed for Ravenshield decompilation project.

	Provides IMPLEMENT_CLASS() registrations and native-function stubs
	for the visual effects classes (emitters, projectors, shadow
	projectors, particle emitters).

	The EXEC_STUB macro creates a trivial native-function body that
	only calls P_FINISH (popping the UnrealScript bytecode stack frame)
	and does nothing else. Each stub is paired with IMPLEMENT_FUNCTION()
	which permanently registers the native function index with the VM.
	When the real implementation is decompiled, the EXEC_STUB body will
	be replaced with the real code but the IMPLEMENT_FUNCTION() stays.

	This file is permanent and will grow as effects code is decompiled.
=============================================================================*/
#include "EnginePrivate.h"

IMPLEMENT_CLASS(AEmitter);
IMPLEMENT_CLASS(AProjector);
IMPLEMENT_CLASS(AShadowProjector);
IMPLEMENT_CLASS(UParticleEmitter);

/*-----------------------------------------------------------------------------
	Exec function implementations.
-----------------------------------------------------------------------------*/

IMPL_APPROX("Reconstructed from context")
void AEmitter::execKill( FFrame& Stack, RESULT_DECL )
{
	guard(AEmitter::execKill);
	P_FINISH;
	// Mark emitter for cleanup — stop spawning particles and destroy when finished.
	bDeleteMe = 1;
	unguard;
}
IMPLEMENT_FUNCTION( AEmitter, INDEX_NONE, execKill );

IMPL_APPROX("Reconstructed from context")
void AProjector::execAbandonProjector( FFrame& Stack, RESULT_DECL )
{
	guard(AProjector::execAbandonProjector);
	P_GET_FLOAT_OPTX(Lifetime,0.f);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AProjector, INDEX_NONE, execAbandonProjector );

IMPL_APPROX("Reconstructed from context")
void AProjector::execAttachActor( FFrame& Stack, RESULT_DECL )
{
	guard(AProjector::execAttachActor);
	P_GET_OBJECT(AActor,ActorToAttach);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AProjector, INDEX_NONE, execAttachActor );

IMPL_APPROX("Reconstructed from context")
void AProjector::execAttachProjector( FFrame& Stack, RESULT_DECL )
{
	guard(AProjector::execAttachProjector);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AProjector, INDEX_NONE, execAttachProjector );

IMPL_APPROX("Reconstructed from context")
void AProjector::execDetachActor( FFrame& Stack, RESULT_DECL )
{
	guard(AProjector::execDetachActor);
	P_GET_OBJECT(AActor,ActorToDetach);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AProjector, INDEX_NONE, execDetachActor );

IMPL_APPROX("Reconstructed from context")
void AProjector::execDetachProjector( FFrame& Stack, RESULT_DECL )
{
	guard(AProjector::execDetachProjector);
	P_GET_UBOOL_OPTX(bForce,0);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AProjector, INDEX_NONE, execDetachProjector );

IMPL_APPROX("Reconstructed from context")
void UParticleEmitter::execSpawnParticle( FFrame& Stack, RESULT_DECL )
{
	guard(UParticleEmitter::execSpawnParticle);
	P_GET_INT_OPTX(Count,1);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( UParticleEmitter, INDEX_NONE, execSpawnParticle );
