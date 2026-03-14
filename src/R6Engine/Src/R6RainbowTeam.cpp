/*=============================================================================
	R6RainbowTeam.cpp
=============================================================================*/

#include "R6EnginePrivate.h"

IMPLEMENT_CLASS(AR6RainbowTeam)

// --- AR6RainbowTeam ---

IMPL_MATCH("R6Engine.dll", 0x10009c20)
void AR6RainbowTeam::eventRequestFormationChange(BYTE A)
{
	struct { BYTE A; } Parms;
	Parms.A = A;
	ProcessEvent(FindFunctionChecked(R6ENGINE_RequestFormationChange), &Parms);
}

IMPL_MATCH("R6Engine.dll", 0x10009c60)
void AR6RainbowTeam::eventUpdateTeamFormation(BYTE A)
{
	struct { BYTE A; } Parms;
	Parms.A = A;
	ProcessEvent(FindFunctionChecked(R6ENGINE_UpdateTeamFormation), &Parms);
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
