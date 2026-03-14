/*=============================================================================
	R6EviLPatchService.cpp — UeviLPatchService
=============================================================================*/

#include "R6GameServicePrivate.h"

IMPLEMENT_CLASS(UeviLPatchService)

// Stubs for unresolved patch service COM functions
IMPL_INFERRED("Needs Ghidra analysis")
static void* FUN_10035870(void*) { return NULL; }
IMPL_INFERRED("Needs Ghidra analysis")
static void  FUN_10035960(void*, int) {}
IMPL_INFERRED("Needs Ghidra analysis")
static void  FUN_100358e0(void*, const TCHAR*) {}
IMPL_INFERRED("Needs Ghidra analysis")
static void  FUN_10035af0(void*, const wchar_t*, const wchar_t*, const wchar_t*) {}
IMPL_INFERRED("Needs Ghidra analysis")
static void  FUN_10035ad0(void*) {}
IMPL_INFERRED("Needs Ghidra analysis")
static DWORD FUN_10035920(void*) { return 5; }
IMPL_INFERRED("Needs Ghidra analysis")
static DWORD FUN_10035930(void*) { return 0; }
IMPL_INFERRED("Needs Ghidra analysis")
static void  FUN_10004b40(void*) {}

IMPLEMENT_FUNCTION(UeviLPatchService, -1, execAbortPatchService)
IMPLEMENT_FUNCTION(UeviLPatchService, -1, execCanRunUpdateService)
IMPLEMENT_FUNCTION(UeviLPatchService, -1, execGetDownloadProgress)
IMPLEMENT_FUNCTION(UeviLPatchService, -1, execGetExitCause)
IMPLEMENT_FUNCTION(UeviLPatchService, -1, execGetState)
IMPLEMENT_FUNCTION(UeviLPatchService, -1, execStartPatch)

// --- UeviLPatchService ---

IMPL_INFERRED("Needs Ghidra analysis")
void UeviLPatchService::StartPatch()
{
	guard(UeviLPatchService::StartPatch);
	unguard;
}

IMPL_INFERRED("Needs Ghidra analysis")
void UeviLPatchService::execAbortPatchService(FFrame& Stack, RESULT_DECL)
{
	guard(UeviLPatchService::execAbortPatchService);
	P_FINISH;
	unguard;
}

IMPL_INFERRED("Needs Ghidra analysis")
void UeviLPatchService::execCanRunUpdateService(FFrame& Stack, RESULT_DECL)
{
	guard(UeviLPatchService::execCanRunUpdateService);
	P_FINISH;
	unguard;
}

IMPL_INFERRED("Needs Ghidra analysis")
void UeviLPatchService::execGetDownloadProgress(FFrame& Stack, RESULT_DECL)
{
	guard(UeviLPatchService::execGetDownloadProgress);
	P_FINISH;
	unguard;
}

IMPL_INFERRED("Needs Ghidra analysis")
void UeviLPatchService::execGetExitCause(FFrame& Stack, RESULT_DECL)
{
	guard(UeviLPatchService::execGetExitCause);
	P_FINISH;
	unguard;
}

IMPL_INFERRED("Needs Ghidra analysis")
void UeviLPatchService::execGetState(FFrame& Stack, RESULT_DECL)
{
	guard(UeviLPatchService::execGetState);
	P_FINISH;
	unguard;
}

IMPL_INFERRED("Needs Ghidra analysis")
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

IMPL_INFERRED("Needs Ghidra analysis")
void UeviLPatchService::FinalDestroy()
{
	guard(UeviLPatchService::FinalDestroy);
	unguard;
}

IMPL_INFERRED("Reconstructed from Ghidra analysis; DAT addresses identified")
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
				// FUN_10035870 = EviLPatchService_Create() — construct patch service COM object.
				// DIVERGENCE: Ubi.com patch service defunct; stub returns NULL.
				PatchServiceHandle = FUN_10035870(puVar3);

			// FUN_10035960 = EviLPatchService_SetPollInterval() — set 250ms poll interval.
			FUN_10035960(PatchServiceHandle, 0xfa);
			// FUN_100358e0 = EviLPatchService_SetWindowTitle() — set "RavenShield" as title.
			FUN_100358e0(PatchServiceHandle, (TCHAR*)L"RavenShield");
			// FUN_10035af0 = EviLPatchService_LaunchUpgrader() — start UpgradeLauncher.exe.
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
				// FUN_10035ad0 = EviLPatchService_Destroy() — destroy patch service COM object.
				FUN_10035ad0(PatchServiceHandle);
				GMalloc->Free(piVar1);
			}
			PatchServiceHandle = NULL;
			return PatchState;
		}
	}

LAB_GetPatchState:
	if ((PatchServiceHandle != NULL) && (PatchState != 5) &&
	    // FUN_10035920 = EviLPatchService_GetState() — query current patch state (5 = done/error).
	    (PatchState = FUN_10035920(PatchServiceHandle), PatchState == 5))
	{
		// FUN_10035930 = EviLPatchService_GetProgress() — get download progress (0–100).
		DownloadProgress = FUN_10035930(PatchServiceHandle);
		// FUN_10004b40 = EviLPatchService_NotifyCompletion() — callback on patch complete.
		// DIVERGENCE: unaff_EDI (saved register context) not recoverable; passes NULL.
		FUN_10004b40(NULL);
	}

	return PatchState;

	unguard;
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
