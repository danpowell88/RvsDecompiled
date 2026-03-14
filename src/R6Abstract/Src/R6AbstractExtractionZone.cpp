/*=============================================================================
	R6AbstractExtractionZone.cpp
=============================================================================*/

#include "R6AbstractPrivate.h"

IMPLEMENT_CLASS(AR6AbstractExtractionZone)

// --- AR6AbstractExtractionZone ---

IMPL_MATCH("R6Abstract.dll", 0x100031e0)
void AR6AbstractExtractionZone::CheckForErrors()
{
	Super::CheckForErrors();
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
