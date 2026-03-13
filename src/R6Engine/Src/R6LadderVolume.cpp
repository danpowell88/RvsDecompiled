/*=============================================================================
	R6LadderVolume.cpp
=============================================================================*/

#include "R6EnginePrivate.h"

IMPLEMENT_CLASS(AR6LadderVolume)

// --- AR6LadderVolume ---

void AR6LadderVolume::AddMyMarker(AActor * param_1)
{
	guard(AR6LadderVolume::AddMyMarker);

	// TODO: Complex function at 0x20ba0 (~600 bytes).
	// Spawns R6Ladder navigation markers at top and bottom of the ladder volume.
	// Involves StaticFindObjectChecked for "R6Ladder" class, calculating entry/exit
	// positions based on volume bounds and ladder direction, and multiple SpawnActor
	// vtable calls via (*(code**)(*(int*)(this+0x328)+0xa8))().

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
