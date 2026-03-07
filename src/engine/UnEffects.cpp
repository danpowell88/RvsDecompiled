/*=============================================================================
	UnEffects.cpp: Emitter, Projector, ParticleEmitter stubs.
=============================================================================*/
#include "EnginePrivate.h"

IMPLEMENT_CLASS(AEmitter);
IMPLEMENT_CLASS(AProjector);
IMPLEMENT_CLASS(AShadowProjector);
IMPLEMENT_CLASS(UParticleEmitter);

#define EXEC_STUB(cls,func) void cls::func( FFrame& Stack, RESULT_DECL ) { P_FINISH; }

EXEC_STUB(AEmitter,execKill)                   IMPLEMENT_FUNCTION( AEmitter, INDEX_NONE, execKill );
EXEC_STUB(AProjector,execAbandonProjector)     IMPLEMENT_FUNCTION( AProjector, INDEX_NONE, execAbandonProjector );
EXEC_STUB(AProjector,execAttachActor)          IMPLEMENT_FUNCTION( AProjector, INDEX_NONE, execAttachActor );
EXEC_STUB(AProjector,execAttachProjector)      IMPLEMENT_FUNCTION( AProjector, INDEX_NONE, execAttachProjector );
EXEC_STUB(AProjector,execDetachActor)          IMPLEMENT_FUNCTION( AProjector, INDEX_NONE, execDetachActor );
EXEC_STUB(AProjector,execDetachProjector)      IMPLEMENT_FUNCTION( AProjector, INDEX_NONE, execDetachProjector );
EXEC_STUB(UParticleEmitter,execSpawnParticle)  IMPLEMENT_FUNCTION( UParticleEmitter, INDEX_NONE, execSpawnParticle );

#undef EXEC_STUB
