/*=============================================================================
	R6EviLPatchService.cpp — UeviLPatchService
=============================================================================*/

#include "R6GameServicePrivate.h"

IMPLEMENT_CLASS(UeviLPatchService)

// Stubs for unresolved patch service COM functions
static void* FUN_10035870(void*) { return NULL; }
static void  FUN_10035960(void*, int) {}
static void  FUN_100358e0(void*, const TCHAR*) {}
static void  FUN_10035af0(void*, const wchar_t*, const wchar_t*, const wchar_t*) {}
static void  FUN_10035ad0(void*) {}
static DWORD FUN_10035920(void*) { return 5; }
static DWORD FUN_10035930(void*) { return 0; }
static void  FUN_10004b40(void*) {}

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

// Static members for the patch service (DAT addresses from Ghidra)
static DWORD  PatchState         = 0;     // DAT_10091530
static DWORD  DownloadProgress   = 0;     // DAT_10091534
static void*  PatchServiceHandle = NULL;  // DAT_10091538

void UeviLPatchService::FinalDestroy()
{
	guard(UeviLPatchService::FinalDestroy);
	unguard;
}

DWORD UeviLPatchService::GetPatchServiceState()
{
	guard(UeviLPatchService::GetPatchServiceState);

	if (PatchServiceHandle == NULL)
	{
		HANDLE pvVar2 = OpenEventA(0x1f0003, 0, "UpgradeLauncherUniqueInstance");
		CloseHandle(pvVar2);

		if (pvVar2 != NULL)
		{
			PatchState       = 0;
			DownloadProgress = 0;

			// Allocate service object via GMalloc
			void** puVar3 = (void**)GMalloc->Malloc(4, TEXT("PatchService"));
			if (puVar3 == NULL)
				PatchServiceHandle = NULL;
			else
				// TODO: FUN_10035870 — construct patch service object
				PatchServiceHandle = FUN_10035870(puVar3);

			// TODO: FUN_10035960 — set poll interval (0xfa = 250ms)
			FUN_10035960(PatchServiceHandle, 0xfa);
			// TODO: FUN_100358e0 — set window title
			FUN_100358e0(PatchServiceHandle, (TCHAR*)L"RavenShield");
			// TODO: FUN_10035af0 — launch upgrade executable
			FUN_10035af0(PatchServiceHandle, L"./UpgradeLauncher.exe", NULL, NULL);

			goto LAB_GetPatchState;
		}

		if (PatchServiceHandle == NULL)
			return PatchState;
	}

	{
		HANDLE pvVar2 = OpenEventA(0x1f0003, 0, "UpgradeLauncherUniqueInstance");
		CloseHandle(pvVar2);
		void* piVar1 = PatchServiceHandle;

		if (pvVar2 == NULL)
		{
			PatchState = 5;
			if (PatchServiceHandle != NULL)
			{
				// TODO: FUN_10035ad0 — destroy patch service object
				FUN_10035ad0(PatchServiceHandle);
				GMalloc->Free(piVar1);
			}
			PatchServiceHandle = NULL;
			return PatchState;
		}
	}

LAB_GetPatchState:
	if ((PatchServiceHandle != NULL) && (PatchState != 5) &&
	    // TODO: FUN_10035920 — query current state
	    (PatchState = FUN_10035920(PatchServiceHandle), PatchState == 5))
	{
		// TODO: FUN_10035930 — get download progress
		DownloadProgress = FUN_10035930(PatchServiceHandle);
		// TODO: FUN_10004b40 — notify caller (unaff_EDI saved register)
		FUN_10004b40(NULL);
	}

	return PatchState;

	unguard;
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
