/*=============================================================================
	R6Planning.cpp — UR6PlanningInfo
=============================================================================*/

#include "R6GamePrivate.h"

IMPLEMENT_CLASS(UR6PlanningInfo)

IMPLEMENT_FUNCTION(UR6PlanningInfo, -1, execAddToTeam)
IMPLEMENT_FUNCTION(UR6PlanningInfo, -1, execDeletePoint)
IMPLEMENT_FUNCTION(UR6PlanningInfo, -1, execFindPathToNextPoint)
IMPLEMENT_FUNCTION(UR6PlanningInfo, -1, execInsertToTeam)

// --- UR6PlanningInfo ---

void UR6PlanningInfo::AddPoint(AActor *)
{
}

AActor * UR6PlanningInfo::GetTeamLeader()
{
	return NULL;
}

INT UR6PlanningInfo::NoStairsBetweenPoints(AActor *)
{
	return 0;
}

void UR6PlanningInfo::TransferFile(FArchive &)
{
}

void UR6PlanningInfo::execAddToTeam(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void UR6PlanningInfo::execDeletePoint(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void UR6PlanningInfo::execFindPathToNextPoint(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void UR6PlanningInfo::execInsertToTeam(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
