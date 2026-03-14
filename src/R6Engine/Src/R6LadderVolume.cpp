/*=============================================================================
	R6LadderVolume.cpp
=============================================================================*/

#include "R6EnginePrivate.h"

IMPLEMENT_CLASS(AR6LadderVolume)

// --- AR6LadderVolume ---

IMPL_TODO("Needs Ghidra analysis")
void AR6LadderVolume::AddMyMarker(AActor * param_1)
{
	guard(AR6LadderVolume::AddMyMarker);

	// TODO: implement AR6LadderVolume::AddMyMarker (Ghidra 0x20ba0, ~600 bytes: spawns R6Ladder
	// navigation markers at top and bottom; SpawnActor vtable dispatch pattern not reconstructed;
	// AI cannot use ladders until implemented)

	unguard;
}

IMPL_APPROX("Allows volume traversal when actor-trace flag 0x80000 is set, otherwise delegates to AVolume")
INT AR6LadderVolume::ShouldTrace(AActor* Other, DWORD TraceFlags)
{
	guard(AR6LadderVolume::ShouldTrace);

	if (!(TraceFlags & 0x80000))
	{
		if (!AVolume::ShouldTrace(Other, TraceFlags))
			return 0;
	}

	return 1;

	unguard;
}

IMPL_APPROX("Standard UObject event thunk")
void AR6LadderVolume::eventSetPotentialClimber()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_SetPotentialClimber), NULL);
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
