/*=============================================================================
	R6EviLPatchService.cpp — UeviLPatchService
=============================================================================*/

#include "R6GameServicePrivate.h"

IMPLEMENT_CLASS(UeviLPatchService)

IMPLEMENT_FUNCTION(UeviLPatchService, -1, execAbortPatchService)
IMPLEMENT_FUNCTION(UeviLPatchService, -1, execCanRunUpdateService)
IMPLEMENT_FUNCTION(UeviLPatchService, -1, execGetDownloadProgress)
IMPLEMENT_FUNCTION(UeviLPatchService, -1, execGetExitCause)
IMPLEMENT_FUNCTION(UeviLPatchService, -1, execGetState)
IMPLEMENT_FUNCTION(UeviLPatchService, -1, execStartPatch)

// --- UeviLPatchService ---

void UeviLPatchService::StartPatch()
{
}

void UeviLPatchService::execAbortPatchService(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void UeviLPatchService::execCanRunUpdateService(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void UeviLPatchService::execGetDownloadProgress(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void UeviLPatchService::execGetExitCause(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void UeviLPatchService::execGetState(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void UeviLPatchService::execStartPatch(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void UeviLPatchService::FinalDestroy()
{
}

DWORD UeviLPatchService::GetPatchServiceState()
{
	return 0;
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
