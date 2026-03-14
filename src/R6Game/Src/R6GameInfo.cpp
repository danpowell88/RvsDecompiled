/*=============================================================================
	R6GameInfo.cpp
=============================================================================*/

#include "R6GamePrivate.h"

IMPLEMENT_CLASS(AR6GameInfo)

IMPLEMENT_FUNCTION(AR6GameInfo, -1, execGetSystemUserName)
IMPLEMENT_FUNCTION(AR6GameInfo, -1, execInitScoreSubmission)
IMPLEMENT_FUNCTION(AR6GameInfo, -1, execLogoutUpdatePlayersCtrlInfo)
IMPLEMENT_FUNCTION(AR6GameInfo, -1, execNativeLogout)
IMPLEMENT_FUNCTION(AR6GameInfo, -1, execSetController)
IMPLEMENT_FUNCTION(AR6GameInfo, -1, execSubmissionNotifySendStartMatch)
IMPLEMENT_FUNCTION(AR6GameInfo, -1, execSubmissionSrvRoundFinish)
IMPLEMENT_FUNCTION(AR6GameInfo, -1, execSubmissionSrvRoundStart)
IMPLEMENT_FUNCTION(AR6GameInfo, -1, execSubmissionUpdateLadderStat)

// File-level state for score-submission tracking (DAT_100241ac in Ghidra)
static INT s_ScoreSubmissionActive = 0;

// Raw vtable dispatch helpers for game-service objects whose vtable order
// cannot be reliably resolved from header declarations alone.
#define GS_CALL(svc, off) \
	((*(void(__thiscall**)(void*))(*(INT**)(svc) + (off)/4))(svc))
#define GS_CALL_INT(svc, off) \
	((*(INT(__thiscall**)(void*))(*(INT**)(svc) + (off)/4))(svc))
#define GS_CALL_1(svc, off, a1) \
	((*(void(__thiscall**)(void*, INT))(*(INT**)(svc) + (off)/4))(svc, (INT)(a1)))
#define GS_CALL_2(svc, off, a1, a2) \
	((*(void(__thiscall**)(void*, void*, void*))(*(INT**)(svc) + (off)/4))((svc), (void*)(a1), (void*)(a2)))

// --- AR6GameInfo ---

IMPL_APPROX("Ravenshield-specific; reconstructed from context")
void AR6GameInfo::AbortScoreSubmission()
{
	if (s_ScoreSubmissionActive)
	{
		s_ScoreSubmissionActive = 0;
		// vtable+0x88 on m_PersistantGameService — per Ghidra offset
		// With UObject=26 virtuals this is GetLoggedInUbiDotCom; semantics suggest
		// it is actually something that cancels/aborts the submission on the service side.
		if (m_PersistantGameService)
			GS_CALL(m_PersistantGameService, 0x88);
	}
}

IMPL_APPROX("Ravenshield-specific; reconstructed from context")
void AR6GameInfo::InitGameInfoGameService()
{
	// Load the R6GSServers class from the GameService package
	UClass* pClass = UObject::StaticLoadClass(
		UR6AbstractGameService::StaticClass(), NULL,
		TEXT("R6GameService.R6GSServers"), NULL, 1, NULL);

	// Validate the loaded class derives from the expected base
	if (!pClass->IsChildOf(UR6AbstractGameService::StaticClass()))
		appFailAssert("Class->IsChildOf(T::StaticClass())",
		              "d:\\ravenshield\\412\\core\\inc\\UnObjBas.h", 0x476);

	// Construct the game-service instance
	m_GameService = (UR6GSServers*)UObject::StaticConstructObject(
		pClass, UObject::GetTransientPackage(), NAME_None, 0, NULL, GError, NULL);

	if (!m_GameService)
	{
		GLog->Logf(TEXT(""));
		return;
	}

	// If the current level URL indicates a non-singleplayer session, call Created()
	// Raw check at this+0x5c8 / engine chain / viewport — Ghidra offset 0x68 = Created()
	// For multiplayer detection, check viewport flags at engine->client->viewport chain
	{
		// engine (g_pEngine): accessed from Ghidra as *(int*)g_pEngine_exref + 0x44 = Client
		// We check GEngine manually here using raw offsets to keep it faithful
		if (GEngine)
		{
			void* pClient = *(void**)((BYTE*)GEngine + 0x44);  // engine->Client
			if (pClient)
			{
				void* pViewport = *(void**)((BYTE*)pClient + 0x30);  // client->Viewport or similar
				if (pViewport)
				{
					void* pVportFlags = *(void**)((BYTE*)pViewport + 0x38);
					if (pVportFlags && *(INT*)((BYTE*)(void*)pVportFlags + 0x4c) & 0xe0)
					{
						// Call Created() on the new game-service instance
						GS_CALL(m_GameService, 0x68);
					}
				}
			}
		}
	}

	// Sync the m_bUseCDKey flag with the level's multiplayer state (Ghidra: offset 0x144 check)
	{
		// this + 0x144 is a pointer to some level-info-like object; +0x425 = some flag
		void* pObj = *(void**)((BYTE*)this + 0x144);
		if (pObj)
		{
			DWORD& svcFlags = *(DWORD*)((BYTE*)m_GameService + 0x48);
			UBOOL flag = (*(BYTE*)((BYTE*)pObj + 0x425) == 1);
			svcFlags = (svcFlags & ~1u) | (flag ? 1u : 0u);
		}
	}

	// If this is a multiplayer game-info, initialise the game service with the listen port
	UClass* pSelfClass = Class;
	while (pSelfClass && pSelfClass != AR6MultiPlayerGameInfo::StaticClass())
		pSelfClass = *(UClass**)((BYTE*)pSelfClass + 0x2c);  // walk parent chain

	if (pSelfClass)
	{
		// vtable+0x6C = DisconnectAllCDKeyPlayers (or similar init), check return
		INT bOk = GS_CALL_INT(m_GameService, 0x6c);
		if (!bOk)
			GS_CALL_1(m_GameService, 0x70, 1);  // vtable+0x70 = RequestGSCDKeyAuthID(1)

		// Set the "initialized" bitflag
		*(DWORD*)((BYTE*)m_GameService + 0x194) |= 0x40;

		// Parse and forward the listen port from the level URL
		ULevel* pLevel = *(ULevel**)((BYTE*)this + 0x328);
		const TCHAR* pUrl = **(FString*)(((BYTE*)pLevel) + 0x54);
		INT listenPort   = *(INT*)(((BYTE*)pLevel) + 0x60);
		FString UrlStr   = FString::Printf( TEXT("%s:%i"), pUrl, listenPort );

		INT colonPos = UrlStr.InStr(TEXT(":"), 0);
		FString PortStr = UrlStr.Mid(colonPos + 1);
		INT port = appAtoi(*PortStr);

		// vtable+0xE8 on game service = SetOwnSvrPort(port) or similar
		GS_CALL_1(m_GameService, 0xe8, port);
	}
}

IMPL_APPROX("Ravenshield-specific; reconstructed from context")
void AR6GameInfo::MasterServerManager()
{
	if (m_GameService)
	{
		ALevelInfo* pLI = (*(ULevel**)((BYTE*)this + 0x328))->GetLevelInfo();
		// vtable+0xB0 = MasterServerManager(gameinfo, levelinfo) — raw dispatch
		GS_CALL_2(m_GameService, 0xb0, this, pLI);
	}
	else
	{
		GLog->Logf(TEXT(""));
	}
}

IMPL_APPROX("Ravenshield-specific; reconstructed from context")
void AR6GameInfo::PostBeginPlay()
{
	if (!m_GameService)
		return;

	// Walk class hierarchy to detect AR6MultiPlayerGameInfo
	UClass* pClass = Class;
	while (pClass && pClass != AR6MultiPlayerGameInfo::StaticClass())
		pClass = *(UClass**)((BYTE*)pClass + 0x2c);

	if (!pClass)
		return;

	// vtable+0xF0 = ProcessUbiComJoinServer check, then 0xEC = ProcessLoginMasterSrv check
	INT bOk = GS_CALL_INT(m_GameService, 0xf0);
	if (bOk)
	{
		bOk = GS_CALL_INT(m_GameService, 0xec);
		if (bOk)
		{
			GS_CALL_1(m_GameService, 0x78, 2);  // ServerRoundStart(2) or similar
			GS_CALL_1(m_GameService, 0x74, 0);  // ResetAuthId(0) or similar
		}
	}
}

IMPL_TODO("Needs Ghidra analysis")
void AR6GameInfo::execGetSystemUserName(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

IMPL_TODO("Needs Ghidra analysis")
void AR6GameInfo::execInitScoreSubmission(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

IMPL_TODO("Needs Ghidra analysis")
void AR6GameInfo::execLogoutUpdatePlayersCtrlInfo(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

IMPL_TODO("Needs Ghidra analysis")
void AR6GameInfo::execNativeLogout(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

IMPL_TODO("Needs Ghidra analysis")
void AR6GameInfo::execSetController(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

IMPL_TODO("Needs Ghidra analysis")
void AR6GameInfo::execSubmissionNotifySendStartMatch(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

IMPL_TODO("Needs Ghidra analysis")
void AR6GameInfo::execSubmissionSrvRoundFinish(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

IMPL_TODO("Needs Ghidra analysis")
void AR6GameInfo::execSubmissionSrvRoundStart(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

IMPL_TODO("Needs Ghidra analysis")
void AR6GameInfo::execSubmissionUpdateLadderStat(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
