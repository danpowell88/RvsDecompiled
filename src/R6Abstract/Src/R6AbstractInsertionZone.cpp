/*=============================================================================
	R6AbstractInsertionZone.cpp
=============================================================================*/

#include "R6AbstractPrivate.h"

IMPLEMENT_CLASS(AR6AbstractInsertionZone)

// --- AR6AbstractInsertionZone ---

IMPL_MATCH("R6Abstract.dll", 0x100032a0)
void AR6AbstractInsertionZone::CheckForErrors()
{
	Super::CheckForErrors();
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
