/*=============================================================================
	R6SmokeCloud.cpp
=============================================================================*/

#include "R6WeaponsPrivate.h"

IMPLEMENT_CLASS(AR6SmokeCloud)

// --- AR6SmokeCloud ---

INT AR6SmokeCloud::IsBlockedBy(AActor const* Other) const
{
	return 0;
}

INT AR6SmokeCloud::ShouldTrace(AActor* Other, DWORD TraceFlags)
{
	if (TraceFlags & 0x80000)
		return 0;
	return TraceFlags & 0x20000;
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
