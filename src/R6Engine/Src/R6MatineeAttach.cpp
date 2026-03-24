/*=============================================================================
	R6MatineeAttach.cpp
=============================================================================*/

#include "R6EnginePrivate.h"

IMPLEMENT_CLASS(UR6MatineeAttach)

IMPLEMENT_FUNCTION(UR6MatineeAttach, -1, execGetBoneInformation)
IMPLEMENT_FUNCTION(UR6MatineeAttach, -1, execTestLocation)

// --- UR6MatineeAttach ---

IMPL_TODO("Ghidra R6Engine.dll 0x10041250: 250 bytes; gets skeletal mesh instance, calls GetBoneName/GetTagPosition, stores position/rotation at this+0x3c..0x6c")
void UR6MatineeAttach::execGetBoneInformation(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

IMPL_TODO("Ghidra R6Engine.dll 0x10040ad0: 95 bytes; needs guard/unguard + P_FINISH with SEH frame")
void UR6MatineeAttach::execTestLocation(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
