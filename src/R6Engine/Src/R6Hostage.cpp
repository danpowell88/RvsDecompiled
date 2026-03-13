/*=============================================================================
	R6Hostage.cpp
	AR6Hostage — hostage pawn events.
=============================================================================*/

#include "R6EnginePrivate.h"

IMPLEMENT_CLASS(AR6Hostage)
IMPLEMENT_CLASS(AR6HostageAI)

// --- AR6Hostage ---

void AR6Hostage::eventFinishInitialization()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_FinishInitialization), NULL);
}

void AR6Hostage::eventGotoCrouch()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_GotoCrouch), NULL);
}

void AR6Hostage::eventGotoFoetus()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_GotoFoetus), NULL);
}

void AR6Hostage::eventGotoKneel()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_GotoKneel), NULL);
}

void AR6Hostage::eventGotoProne()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_GotoProne), NULL);
}

void AR6Hostage::eventGotoStand()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_GotoStand), NULL);
}

void AR6Hostage::eventSetAnimInfo(INT A)
{
	struct { INT A; } Parms;
	Parms.A = A;
	ProcessEvent(FindFunctionChecked(R6ENGINE_SetAnimInfo), &Parms);
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
