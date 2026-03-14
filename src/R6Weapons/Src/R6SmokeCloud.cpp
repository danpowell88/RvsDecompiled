/*=============================================================================
	R6SmokeCloud.cpp
=============================================================================*/

#include "R6WeaponsPrivate.h"

IMPLEMENT_CLASS(AR6SmokeCloud)

// --- AR6SmokeCloud ---

IMPL_EMPTY("retail implementation is empty; smoke clouds are never blocked")
INT AR6SmokeCloud::IsBlockedBy(AActor const* Other) const
{
	// retail: empty — smoke clouds are never blocked.
	return 0;
}

IMPL_MATCH("R6Weapons.dll", 0x10002e70)
INT AR6SmokeCloud::ShouldTrace(AActor* Other, DWORD TraceFlags)
{
	if (TraceFlags & 0x80000)
		return 0;
	return TraceFlags & 0x20000;
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
