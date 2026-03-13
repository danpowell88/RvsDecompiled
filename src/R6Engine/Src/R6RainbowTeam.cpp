/*=============================================================================
	R6RainbowTeam.cpp
=============================================================================*/

#include "R6EnginePrivate.h"

IMPLEMENT_CLASS(AR6RainbowTeam)

// --- AR6RainbowTeam ---

void AR6RainbowTeam::eventRequestFormationChange(BYTE A)
{
	struct { BYTE A; } Parms;
	Parms.A = A;
	ProcessEvent(FindFunctionChecked(R6ENGINE_RequestFormationChange), &Parms);
}

void AR6RainbowTeam::eventUpdateTeamFormation(BYTE A)
{
	struct { BYTE A; } Parms;
	Parms.A = A;
	ProcessEvent(FindFunctionChecked(R6ENGINE_UpdateTeamFormation), &Parms);
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
