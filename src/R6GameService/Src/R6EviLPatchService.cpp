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
	guard(UeviLPatchService::StartPatch);
	unguard;
}

void UeviLPatchService::execAbortPatchService(FFrame& Stack, RESULT_DECL)
{
	guard(UeviLPatchService::execAbortPatchService);
	P_FINISH;
	unguard;
}

void UeviLPatchService::execCanRunUpdateService(FFrame& Stack, RESULT_DECL)
{
	guard(UeviLPatchService::execCanRunUpdateService);
	P_FINISH;
	unguard;
}

void UeviLPatchService::execGetDownloadProgress(FFrame& Stack, RESULT_DECL)
{
	guard(UeviLPatchService::execGetDownloadProgress);
	P_FINISH;
	unguard;
}

void UeviLPatchService::execGetExitCause(FFrame& Stack, RESULT_DECL)
{
	guard(UeviLPatchService::execGetExitCause);
	P_FINISH;
	unguard;
}

void UeviLPatchService::execGetState(FFrame& Stack, RESULT_DECL)
{
	guard(UeviLPatchService::execGetState);
	P_FINISH;
	unguard;
}

void UeviLPatchService::execStartPatch(FFrame& Stack, RESULT_DECL)
{
	guard(UeviLPatchService::execStartPatch);
	P_FINISH;
	StartPatch();
	unguard;
}

void UeviLPatchService::FinalDestroy()
{
	guard(UeviLPatchService::FinalDestroy);
	unguard;
}

DWORD UeviLPatchService::GetPatchServiceState()
{
	return 0;
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
