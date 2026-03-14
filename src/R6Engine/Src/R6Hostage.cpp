/*=============================================================================
	R6Hostage.cpp
=============================================================================*/

#include "R6EnginePrivate.h"

IMPLEMENT_CLASS(AR6Hostage)

// --- AR6Hostage ---

IMPL_APPROX("Standard UObject event thunk")
void AR6Hostage::eventFinishInitialization()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_FinishInitialization), NULL);
}

IMPL_APPROX("Standard UObject event thunk")
void AR6Hostage::eventGotoCrouch()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_GotoCrouch), NULL);
}

IMPL_APPROX("Standard UObject event thunk")
void AR6Hostage::eventGotoFoetus()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_GotoFoetus), NULL);
}

IMPL_APPROX("Standard UObject event thunk")
void AR6Hostage::eventGotoKneel()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_GotoKneel), NULL);
}

IMPL_APPROX("Standard UObject event thunk")
void AR6Hostage::eventGotoProne()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_GotoProne), NULL);
}

IMPL_APPROX("Standard UObject event thunk")
void AR6Hostage::eventGotoStand()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_GotoStand), NULL);
}

IMPL_APPROX("Standard UObject event thunk")
void AR6Hostage::eventSetAnimInfo(INT A)
{
	struct { INT A; } Parms;
	Parms.A = A;
	ProcessEvent(FindFunctionChecked(R6ENGINE_SetAnimInfo), &Parms);
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
