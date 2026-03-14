/*=============================================================================
	R6GameReplicationInfo.cpp
=============================================================================*/

#include "R6EnginePrivate.h"

IMPLEMENT_CLASS(AR6GameReplicationInfo)

// --- AR6GameReplicationInfo ---

IMPL_MATCH("R6Engine.dll", 0x100017f0)
FLOAT AR6GameReplicationInfo::eventGetRoundTime()
{
	struct {
		FLOAT ReturnValue;
	} Parms;
	Parms.ReturnValue = 0.f;
	ProcessEvent(FindFunctionChecked(R6ENGINE_GetRoundTime), &Parms);
	return Parms.ReturnValue;
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
