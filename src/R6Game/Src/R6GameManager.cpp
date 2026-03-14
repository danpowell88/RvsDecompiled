/*=============================================================================
	R6GameManager.cpp
=============================================================================*/

#include "R6GamePrivate.h"

IMPLEMENT_CLASS(UR6GameManager)

// File-level state for UbiSoft game-service creation flag (DAT_100292d0 in Ghidra)
static INT s_GSCreateUbiServer = 0;

// Raw vtable dispatch helpers (same pattern as R6GameInfo.cpp)
// GameManager calls use this+0x30 as the game-service pointer.
#define GM_GS_CALL(off) \
	((*(void(__thiscall**)(void*))(*(INT**)(*(INT**)((BYTE*)this+0x30)) + (off)/4))(*(void**)((BYTE*)this+0x30)))
#define GM_GS_CALL_INT(off) \
	((*(INT(__thiscall**)(void*))(*(INT**)(*(INT**)((BYTE*)this+0x30)) + (off)/4))(*(void**)((BYTE*)this+0x30)))
#define GM_GS_CALL_1(off, a1) \
	((*(void(__thiscall**)(void*, INT))(*(INT**)(*(INT**)((BYTE*)this+0x30)) + (off)/4))(*(void**)((BYTE*)this+0x30), (INT)(a1)))

// --- UR6GameManager ---

IMPL_INFERRED("Ravenshield-specific; reconstructed from context")
void UR6GameManager::ClientLeaveServer()
{
	// Clear bit 4 (mask 0x10) of the flags field at this+0x2C
	*(DWORD*)((BYTE*)this + 0x2c) &= ~0x10u;

	// If a game service is attached, notify it
	if (*(void**)((BYTE*)this + 0x30))
	{
		// vtable+0xE4: some "leave server" or "disconnect" call — non-zero means success
		INT bOk = GM_GS_CALL_INT(0xe4);
		if (bOk)
			GM_GS_CALL(0xd8);  // vtable+0xD8: follow-up disconnect step
	}
}

IMPL_INFERRED("Ravenshield-specific; reconstructed from context")
void UR6GameManager::ConnectionInterrupted(INT bInterrupted)
{
	if (*(void**)((BYTE*)this + 0x30))
	{
		if (bInterrupted)
			GM_GS_CALL(0x90);  // vtable+0x90: some "connection interrupted" handler
		GM_GS_CALL(0xbc);      // vtable+0xBC: always called (cleanup/reset)
	}
}

IMPL_INFERRED("Ravenshield-specific; reconstructed from context")
void UR6GameManager::DoConsoleCommand(FString Cmd, UConsole* Console)
{
	// Ghidra: in_stack_00000010 = Console; iVar3 tracks the "active console/viewport"
	void* iVar3 = Console;

	if (!Console)
	{
		// Navigate GEngine -> Client -> Viewports.Data[0] -> viewport+0x38 -> console
		if (GEngine)
		{
			void* pClient = *(void**)((BYTE*)GEngine + 0x44);  // GEngine->Client
			if (pClient)
			{
				// Client+0x30 = Viewports.Data (raw pointer to viewport array)
				void* pViewportData = *(void**)((BYTE*)pClient + 0x30);
				if (pViewportData)
				{
					// Dereference once to get first UViewport*
					void* pViewport = *(void**)pViewportData;
					if (pViewport)
					{
						// viewport+0x38 = some embedded console/UI object
						void* pConsoleObj = *(void**)((BYTE*)pViewport + 0x38);
						if (pConsoleObj && *(void**)((BYTE*)pConsoleObj + 0x34))
						{
							iVar3 = pConsoleObj;
							goto found;
						}
					}
				}
			}
		}
		GWarn->Logf(TEXT(""));
		return;
	}

found:
	// iVar3 = console object with +0x30 (out device), +0x34 (InteractionMaster)
	void* pOutPtr = *(void**)((BYTE*)iVar3 + 0x30);
	FOutputDevice* pOut;
	if (!pOutPtr)
	{
		// Fall back: navigate through InteractionMaster chain to find an output device
		void* pIM      = *(void**)((BYTE*)iVar3 + 0x34);
		void* pIMSub   = *(void**)((BYTE*)*(void**)((BYTE*)pIM + 0x34) + 0x30);
		pOutPtr = pIMSub;
		pOut = pOutPtr ? (FOutputDevice*)((BYTE*)pOutPtr + 0x2c) : NULL;
	}
	else
	{
		pOut = (FOutputDevice*)((BYTE*)pOutPtr + 0x2c);
	}

	UInteractionMaster* pMaster = *(UInteractionMaster**)((BYTE*)iVar3 + 0x34);
	if (pOut)
		pMaster->Exec(*Cmd, *pOut);
	else
		pMaster->Exec(*Cmd, *GWarn);  // fallback to GWarn if no output device found
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GameManager::GSClientManager(UConsole *)
{
	guard(UR6GameManager::GSClientManager);
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GameManager::GameServiceTick(UConsole *)
{
	guard(UR6GameManager::GameServiceTick);
	unguard;
}

IMPL_INFERRED("Ravenshield-specific; reconstructed from context")
INT UR6GameManager::GetGSCreateUbiServer()
{
	return s_GSCreateUbiServer;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GameManager::InitializeGSClient()
{
	guard(UR6GameManager::InitializeGSClient);
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GameManager::InitializeGameService(UConsole *)
{
	guard(UR6GameManager::InitializeGameService);
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GameManager::LaunchListenSrv(FString, FString)
{
	guard(UR6GameManager::LaunchListenSrv);
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GameManager::MSClientManager(UConsole *)
{
	guard(UR6GameManager::MSClientManager);
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GameManager::MinimizeAndPauseMusic(UConsole *)
{
	guard(UR6GameManager::MinimizeAndPauseMusic);
	unguard;
}

IMPL_INFERRED("Ravenshield-specific; reconstructed from context")
void UR6GameManager::SetGSCreateUbiServer(INT Param)
{
	s_GSCreateUbiServer = Param;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GameManager::StartJoinServer(FString, FString, INT)
{
	guard(UR6GameManager::StartJoinServer);
	unguard;
}

IMPL_INFERRED("Ravenshield-specific; reconstructed from context")
INT UR6GameManager::StartLogInProcedure()
{
	if (*(void**)((BYTE*)this + 0x30))
	{
		// vtable+0xDC: check if login already in progress
		INT bAlreadyInProgress = GM_GS_CALL_INT(0xdc);
		if (bAlreadyInProgress)
		{
			eventGMProcessMsg(FString(TEXT("LOGIN_ALREADY_IN_PROGRESS")));
			return 0;
		}

		// vtable+0xE0: attempt login start; 0 = started, non-zero = skipped
		INT bSkipped = GM_GS_CALL_INT(0xe0);
		if (!bSkipped)
			eventGMProcessMsg(FString(TEXT("LOGIN_START")));
		else
			eventGMProcessMsg(FString(TEXT("LOGIN_SKIPPED")));
	}
	return 1;
}

IMPL_INFERRED("Ravenshield-specific; reconstructed from context")
void UR6GameManager::StartPreJoinProcedure(INT bModServer)
{
	if (*(void**)((BYTE*)this + 0x30))
	{
		// vtable+0xB4: notify game service of the pre-join phase
		GM_GS_CALL_1(0xb4, bModServer);

		FString Msg;
		if (bModServer == 0)
		{
			void* pGS = *(void**)((BYTE*)this + 0x30);
			if ((*(BYTE*)((BYTE*)pGS + 0x194) & 1) == 0)
			{
				Msg = FString(TEXT("UP_ENTER_CD_KEY"));
			}
			else
			{
				GM_GS_CALL(0xb8);  // vtable+0xB8: request auth-id
				Msg = FString(TEXT("UP_REQUEST_AUTHID"));
			}
		}
		else
		{
			// Mod server path: check a field in the 0x19c sub-object
			void* pGS = *(void**)((BYTE*)this + 0x30);
			void* pSub = *(void**)((BYTE*)pGS + 0x19c);
			if ((*(BYTE*)((BYTE*)pSub + 0x3c) & 1) == 0)
			{
				Msg = FString(TEXT("UP_MOD_ENTER_CD_KEY"));
			}
			else
			{
				GM_GS_CALL(0xb8);
				Msg = FString(TEXT("UP_MOD_REQUEST_AUTHID"));
			}
		}
		eventGMProcessMsg(Msg);
	}
}

IMPL_INFERRED("Ravenshield-specific; reconstructed from context")
void UR6GameManager::UnInitialize()
{
	// Ghidra accesses GR6GameManager_exref (the singleton), which is == this
	if (*(BYTE*)((BYTE*)this + 0x2c) & 1)
		*(DWORD*)((BYTE*)this + 0x2c) &= ~1u;
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
