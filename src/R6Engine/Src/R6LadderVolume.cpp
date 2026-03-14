/*=============================================================================
	R6LadderVolume.cpp
=============================================================================*/

#include "R6EnginePrivate.h"

IMPLEMENT_CLASS(AR6LadderVolume)

// --- AR6LadderVolume ---

void AR6LadderVolume::AddMyMarker(AActor * param_1)
{
	guard(AR6LadderVolume::AddMyMarker);

	// DIVERGENCE: Ghidra 0x20ba0 (~600 bytes). Spawns R6Ladder navigation markers at
	// top and bottom of the ladder volume, calculating entry/exit positions from volume
	// bounds and ladder direction. SpawnActor vtable dispatch pattern not reconstructed.
	// Without these markers, AI cannot use ladders in pathfinding — acceptable for current phase.

	unguard;
}

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

void AR6LadderVolume::eventSetPotentialClimber()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_SetPotentialClimber), NULL);
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
