#pragma optimize("", off)
#include "EnginePrivate.h"
// --- AStaticMeshActor ---
int AStaticMeshActor::ShouldTrace(AActor * Other, DWORD TraceFlags)
{
	// Ghidra 0x718b0, 32B: check bCollideActors (bit 1 of flags at 0x398)
	if (TraceFlags & 0x2000)
		return (*(DWORD*)((BYTE*)this + 0x398) >> 1) & 1;
	return AActor::ShouldTrace(Other, TraceFlags);
}


