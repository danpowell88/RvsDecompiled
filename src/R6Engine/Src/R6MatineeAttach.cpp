/*=============================================================================
	R6MatineeAttach.cpp
=============================================================================*/

#include "R6EnginePrivate.h"

IMPLEMENT_CLASS(UR6MatineeAttach)

IMPLEMENT_FUNCTION(UR6MatineeAttach, -1, execGetBoneInformation)
IMPLEMENT_FUNCTION(UR6MatineeAttach, -1, execTestLocation)

// --- UR6MatineeAttach ---

IMPL_APPROX("Exec thunk for GetBoneInformation; native body unimplemented — logic resides in UnrealScript")
void UR6MatineeAttach::execGetBoneInformation(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

IMPL_APPROX("Exec thunk for TestLocation; native body unimplemented — logic resides in UnrealScript")
void UR6MatineeAttach::execTestLocation(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
