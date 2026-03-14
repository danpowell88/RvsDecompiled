/*=============================================================================
	R6AbstractGadget.cpp
=============================================================================*/

#include "R6AbstractPrivate.h"

IMPLEMENT_CLASS(AR6AbstractGadget)

// --- AR6AbstractGadget ---

IMPL_APPROX("Ravenshield-specific; reconstructed from context")
INT* AR6AbstractGadget::GetOptimizedRepList(BYTE* Recent, FPropertyRetirement* Retire, INT* Ptr, UPackageMap* Map, UActorChannel* Channel)
{
	return Super::GetOptimizedRepList(Recent, Retire, Ptr, Map, Channel);
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
