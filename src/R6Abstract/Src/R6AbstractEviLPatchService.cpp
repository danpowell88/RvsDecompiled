/*=============================================================================
	R6AbstractEviLPatchService.cpp
=============================================================================*/

#include "R6AbstractPrivate.h"

IMPLEMENT_CLASS(UR6AbstractEviLPatchService)

IMPLEMENT_FUNCTION(UR6AbstractEviLPatchService, -1, execGetState)

// Global callback pointer stored by SetFunctionPtr, read by execGetState.
// Ghidra: DAT_10010df0 — static storage, not a class member.
static DWORD (CDECL* GEviLPatchCallback)(void) = NULL;

// --- UR6AbstractEviLPatchService ---

IMPL_MATCH("R6Abstract.dll", 0x10003840)
void UR6AbstractEviLPatchService::SetFunctionPtr(DWORD (CDECL* Func)(void))
{
	GEviLPatchCallback = Func;
}

IMPL_MATCH("R6Abstract.dll", 0x10003780)
void UR6AbstractEviLPatchService::execGetState(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
	if (GEviLPatchCallback != NULL)
		*(DWORD*)Result = GEviLPatchCallback();
	else
		*(DWORD*)Result = 0;
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
