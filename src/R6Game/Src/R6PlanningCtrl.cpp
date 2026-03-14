/*=============================================================================
	R6PlanningCtrl.cpp
=============================================================================*/

#include "R6GamePrivate.h"

IMPLEMENT_CLASS(AR6PlanningCtrl)

IMPLEMENT_FUNCTION(AR6PlanningCtrl, -1, execGetClickResult)
IMPLEMENT_FUNCTION(AR6PlanningCtrl, -1, execGetXYPoint)
IMPLEMENT_FUNCTION(AR6PlanningCtrl, -1, execPlanningTrace)

// --- AR6PlanningCtrl ---

IMPL_APPROX("Needs Ghidra analysis")
void AR6PlanningCtrl::execGetClickResult(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

IMPL_APPROX("Needs Ghidra analysis")
void AR6PlanningCtrl::execGetXYPoint(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

IMPL_APPROX("Needs Ghidra analysis")
void AR6PlanningCtrl::execPlanningTrace(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
