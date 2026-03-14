/*=============================================================================
	R6Hostage.cpp
=============================================================================*/

#include "R6EnginePrivate.h"

IMPLEMENT_CLASS(AR6Hostage)

// --- AR6Hostage ---

IMPL_MATCH("R6Engine.dll", 0x10004c60)
void AR6Hostage::eventFinishInitialization()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_FinishInitialization), NULL);
}

IMPL_MATCH("R6Engine.dll", 0x10004bc0)
void AR6Hostage::eventGotoCrouch()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_GotoCrouch), NULL);
}

IMPL_MATCH("R6Engine.dll", 0x10004b60)
void AR6Hostage::eventGotoFoetus()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_GotoFoetus), NULL);
}

IMPL_MATCH("R6Engine.dll", 0x10004b90)
void AR6Hostage::eventGotoKneel()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_GotoKneel), NULL);
}

IMPL_MATCH("R6Engine.dll", 0x10004b30)
void AR6Hostage::eventGotoProne()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_GotoProne), NULL);
}

IMPL_MATCH("R6Engine.dll", 0x10004bf0)
void AR6Hostage::eventGotoStand()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_GotoStand), NULL);
}

IMPL_MATCH("R6Engine.dll", 0x10004c20)
void AR6Hostage::eventSetAnimInfo(INT A)
{
	struct { INT A; } Parms;
	Parms.A = A;
	ProcessEvent(FindFunctionChecked(R6ENGINE_SetAnimInfo), &Parms);
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
