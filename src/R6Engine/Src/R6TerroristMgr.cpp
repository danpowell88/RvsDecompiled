/*=============================================================================
	R6TerroristMgr.cpp
	UR6TerroristMgr — terrorist manager.
=============================================================================*/

#include "R6EnginePrivate.h"

IMPLEMENT_CLASS(UR6TerroristMgr)

IMPLEMENT_FUNCTION(UR6TerroristMgr, -1, execFindNearestZoneForHostage)
IMPLEMENT_FUNCTION(UR6TerroristMgr, -1, execInit)

// --- UR6TerroristMgr ---

IMPL_APPROX("Returns NULL; full logic searches deployment zones for nearest zone to a hostage terrorist; not reconstructed")
void UR6TerroristMgr::execFindNearestZoneForHostage(FFrame& Stack, RESULT_DECL)
{
	P_GET_OBJECT(AActor, terro);
	P_FINISH;
	*(UObject**)Result = NULL;
}

IMPL_APPROX("Initializes terrorist manager; full logic not reconstructed from Ghidra")
void UR6TerroristMgr::execInit(FFrame& Stack, RESULT_DECL)
{
	P_GET_OBJECT(AActor, dummy);
	P_FINISH;
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
