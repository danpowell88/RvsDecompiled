/*=============================================================================
	R6GSServers.cpp: UR6GSServers — GameSpy / Ubi.com server browser integration.
	Reconstructed for Ravenshield decompilation project.
=============================================================================*/

#include "R6GameServicePrivate.h"

IMPLEMENT_CLASS(UR6GSServers)

IMPLEMENT_FUNCTION(UR6GSServers, -1, execEnterCDKey)
IMPLEMENT_FUNCTION(UR6GSServers, -1, execGetMaxUbiServerNameSize)
IMPLEMENT_FUNCTION(UR6GSServers, -1, execHandleAnyLobbyConnectionFail)
IMPLEMENT_FUNCTION(UR6GSServers, -1, execInitGSCDKey)
IMPLEMENT_FUNCTION(UR6GSServers, -1, execInitialize)
IMPLEMENT_FUNCTION(UR6GSServers, -1, execInitializeMSClient)
IMPLEMENT_FUNCTION(UR6GSServers, -1, execIsRefreshServersInProgress)
IMPLEMENT_FUNCTION(UR6GSServers, -1, execNativeGetMSClientInitialized)
IMPLEMENT_FUNCTION(UR6GSServers, -1, execNativeGetSeconds)
IMPLEMENT_FUNCTION(UR6GSServers, -1, execNativeIsGSReadyToChangeMod)
IMPLEMENT_FUNCTION(UR6GSServers, -1, execNativeIsRouterDisconnect)
IMPLEMENT_FUNCTION(UR6GSServers, -1, execNativeIsWaitingForGSInit)
IMPLEMENT_FUNCTION(UR6GSServers, -1, execNativeLogOutServer)
IMPLEMENT_FUNCTION(UR6GSServers, -1, execNativeMSCLientJoinServer)
IMPLEMENT_FUNCTION(UR6GSServers, -1, execNativeMSClientReqAltInfo)
IMPLEMENT_FUNCTION(UR6GSServers, -1, execNativeProcessIcmpPing)
IMPLEMENT_FUNCTION(UR6GSServers, -1, execNativeSetMatchResult)
IMPLEMENT_FUNCTION(UR6GSServers, -1, execNativeUpdateServer)
IMPLEMENT_FUNCTION(UR6GSServers, -1, execRefreshOneServer)
IMPLEMENT_FUNCTION(UR6GSServers, -1, execRefreshServers)
IMPLEMENT_FUNCTION(UR6GSServers, -1, execSetLastServerQueried)
IMPLEMENT_FUNCTION(UR6GSServers, -1, execStopRefreshServers)
IMPLEMENT_FUNCTION(UR6GSServers, -1, execUnInitializeMSClient)

/*=============================================================================
	Module-level GameSpy / Ubi.com state globals.
	All correspond to static .data-section variables in the original binary
	(zero-initialised at load time).  Addresses from Ghidra export.
	Names are derived from usage context; see individual function bodies.
=============================================================================*/

// GS client / networking init state
static INT  GsClientInitialized  = 0; // DAT_10091e60 read by InitGSCDKey/InitializeMSClient/InitializeRegServer
static INT  GsLogDebug           = 0; // DAT_10091e70 debug-log gate (read-only in almost all fns)

// MS (Master-Server) client state
static INT  GsServerJoined       = 0; // DAT_10091c00 IsServerJoined(); cleared by MSCLientLeaveServer/UnInitMSClient
static INT  GsMSClientState      = 0; // DAT_10091be4 cleared by MSCLientLeaveServer/UnInitMSClient
static INT  GsMSClientInRequest  = 0; // DAT_10091c14 IsMSClientIsInRequest(); set to 1 by InitializeMSClient
static INT  GsMSClientConnHandle = 0; // DAT_10091c1c passed to FUN_100323c0 in MSCLientLeaveServer
static INT  GsMSClientConnParam  = 0; // DAT_10091bec passed to FUN_100323c0 in MSCLientLeaveServer

// Ubi.com login / session state
static INT  GsLoggedInUbi        = 0; // DAT_10091e68 GetLoggedInUbiDotCom(); set/cleared by InitializeMSClient/UnInitMSClient
static INT  GsUbiState1          = 0; // DAT_10091e64 cleared by UnInitMSClient
static INT  GsUbiLobbyState      = 0; // DAT_10091e6c cleared by UnInitMSClient

// GS game / server state
static BYTE GsGameState          = 0; // DAT_100939d4 GetGSGameState() / SetGSGameState()
static BYTE GsLoginRegServer     = 0; // DAT_10093afc GetLoginRegServer(); set by InitializeRegServer
static INT  GsRegServerInit      = 0; // DAT_10093b08 GetRegServerInitialized(); set by InitializeRegServer
static INT  GsServerRegistered   = 0; // DAT_100939ec GetServerRegistered()
static INT  GsQueryState         = 0; // DAT_10091d30 read in ReceiveServer
static INT  GsMSClientAlt        = 0; // DAT_10091d38 cleared by UnInitMSClient
static FLOAT GsTimestamp         = 0; // DAT_10091d40 rdtsc-derived timestamp in ReceiveServer

// COM / GSClient handle
static INT  GsComInitialized     = 0; // DAT_100939d8 SetGSClientComInterface initialised guard
static void* GsComInterface      = NULL; // DAT_10092ea4 QueryInterface result (IUnknown*)
static void* GsClientHandle      = NULL; // DAT_10091e5c GS client opaque handle

// CDKey state
static INT  GsCDKeyInitialized   = 0; // DAT_100933d0 set to 0 by InitGSCDKey
static INT  GsCDKeyAuthFlag      = 0; // DAT_10093410 checked by InitGSCDKey after InitCDKey
static INT  GsCDKeyConnected     = 0; // DAT_100933cc checked by InitGSCDKey after InitCDKey
static void* GsCDKeyHandle       = NULL; // DAT_100933d8 RS CDKey API handle (FUN_10023270 arg)
static void* GsModCDKeyHandle    = NULL; // DAT_100933dc mod CDKey API handle
static BYTE  GsCDKeyProductType  = 0;   // DAT_10091c04 product-type byte in CDKeyValidateUser
static char* GsCDKeyBuffer       = NULL; // DAT_10091c28 pointer to CDKey name string

// Alternate-info / receive-server buffers (written by GameSpy callbacks)
static INT*  GsAltInfoData       = NULL; // DAT_100923c4 alternate server info buffer (array of INT)
static INT   GsAltInfoCount      = 0;   // DAT_100923c8 0 < this checked by ReceiveAltInfo
static INT   GsReceiveServerCount = 0;  // DAT_100923ec server-receive pending count

// Registration server state
static INT   GsRegServerCount    = 0;   // DAT_100923a0 reg server candidate count
static char* GsRegServerList     = NULL; // DAT_1009239c reg server array (entries of 0x108 bytes)
static INT   GsRegServerIndex    = 0;   // DAT_10091d28 rolling index into GsRegServerList
static INT   GsRegServerState    = 0;   // DAT_10093b24 reg server login FSM state

// Mod name used by IsAuthIDSuccess ("R6RSCUSTOM" check)
static FString GsCustomModName;          // DAT_10092e64 (FString, default empty)
static void*   GsAuthLogDev      = NULL; // DAT_10092e6c secondary log device for auth-ID debug

// PlayerIsInIDList array
static INT   GsIDListCount       = 0;   // DAT_10092e9c
static void* GsIDListArray       = NULL; // DAT_10092e98

// Mod CDKey name FString (used in CDKeyValidateUser when bCheckModKey != 0)
static FString GsModCDKeyName;           // DAT_100923ac (FString, default empty)

// COM CLSIDs/IIDs are hardcoded in the original binary's .rdata section.
// Actual bytes are not yet recovered; GetActiveObject will fail anyway (GameSpy defunct).
static BYTE GsComCLSID[16] = {0}; // DAT_10073074
static BYTE GsComIID[16]   = {0}; // DAT_10072ff8

// --- UR6GSServers ---

IMPL_TODO("Needs Ghidra analysis")
void UR6GSServers::AddPlayerToIDList(FString, FString, FString, INT)
{
	guard(UR6GSServers::AddPlayerToIDList);
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GSServers::CDKeyDisconnecUser(FString)
{
	guard(UR6GSServers::CDKeyDisconnecUser);
	unguard;
}

IMPL_APPROX("CDKey validation logic reconstructed; GameSpy API defunct, returns 0 fail-safe")
INT UR6GSServers::CDKeyValidateUser(FString szCDKey, INT bMod, INT bCheckModKey)
{
	INT iResult = 0;
	guard(UR6GSServers::CDKeyValidateUser);

	// Copy CDKey API product name from global buffer into local stack buffer.
	char szKeyName[220]; // local_dc (0xdc bytes) — CDKey API name string
	char szCDKeyHex[88]; // local_58 — ANSI hex representation of the CD key
	BYTE aucKey[20];     // local_30 — binary decoded CD key (0x28 / 2 = 20 bytes)
	BYTE ucProductType;  // local_5a

	{ const char* src = GsCDKeyBuffer; char* dst = szKeyName; if (src) while ((*dst++ = *src++)) {} else szKeyName[0] = '\0'; }
	ucProductType = GsCDKeyProductType; // DAT_10091c04

	// Convert FString CD key to ANSI hex string then decode byte pairs.
	const TCHAR* pWide = *szCDKey;
	const char*  pAnsi = appToAnsi(pWide);
	{ const char* src = pAnsi; char* dst = szCDKeyHex; while ((*dst++ = *src++)) {} }

	// FUN_10005760 = inline hex nibble decoder — converts single ASCII hex char to 0-15.
	auto hexNibble = [](char c) -> BYTE {
		if (c >= '0' && c <= '9') return (BYTE)(c - '0');
		if (c >= 'A' && c <= 'F') return (BYTE)(c - 'A' + 10);
		if (c >= 'a' && c <= 'f') return (BYTE)(c - 'a' + 10);
		return 0;
	};
	for (INT uVar9 = 0; uVar9 < 0x28; uVar9 += 2)
	{
		BYTE hi = hexNibble(szCDKeyHex[uVar9]);
		BYTE lo = hexNibble(szCDKeyHex[uVar9 + 1]);
		aucKey[uVar9 / 2] = (BYTE)(hi * '\x10' + lo);
	}

	BYTE ucKeyType = 3;
	if (bMod != 0)
		ucKeyType = 6;

	const char* pszGameName;
	void*       pCDKeyHandle;
	if (bCheckModKey == 0)
	{
		pszGameName  = "RAVENSHIELD";
		pCDKeyHandle = GsCDKeyHandle; // DAT_100933d8
	}
	else
	{
		// Mod CDKey path: get mod name from global FString.
		const TCHAR* pWideMod = *GsModCDKeyName; // DAT_100923ac
		pszGameName  = appToAnsi(pWideMod);
		pCDKeyHandle = GsModCDKeyHandle; // DAT_100933dc
	}

	// FUN_10023270 = GSCDKey_AuthenticateUser() — GameSpy CDKey authentication API.
	// DIVERGENCE: GameSpy CDKey servers shut down ~2013; call omitted, returns 0 (fail-safe).
	iResult = 0;

	if (GsLogDebug != 0) GLog->Logf(TEXT("CDKeyValidateUser: GameSpy CDKey API defunct, result=0"));

	(void)ucProductType; // used by original but not yet wired; suppress unused warning
	return iResult;
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GSServers::CancelGSCDKeyActID()
{
	guard(UR6GSServers::CancelGSCDKeyActID);
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GSServers::CancelGSCDKeyAuthID()
{
	guard(UR6GSServers::CancelGSCDKeyAuthID);
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GSServers::CopyActivationIDInByteArray(BYTE *, BYTE *)
{
	guard(UR6GSServers::CopyActivationIDInByteArray);
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GSServers::CreatedCDKey()
{
	guard(UR6GSServers::CreatedCDKey);
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GSServers::Destroy()
{
	guard(UR6GSServers::Destroy);
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GSServers::DisconnectAllCDKeyPlayers()
{
	guard(UR6GSServers::DisconnectAllCDKeyPlayers);
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GSServers::EnterCDKey(FString)
{
	guard(UR6GSServers::EnterCDKey);
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GSServers::GSClientPostMessage(BYTE)
{
	guard(UR6GSServers::GSClientPostMessage);
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GSServers::GSClientUpdateServerInfo()
{
	guard(UR6GSServers::GSClientUpdateServerInfo);
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GSServers::GameServiceManager(INT, INT, INT, INT)
{
	guard(UR6GSServers::GameServiceManager);
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
FString UR6GSServers::GetAuthID(INT)
{
	return TEXT("");
}

IMPL_MATCH("R6GameService.dll", 0x10f00)
BYTE UR6GSServers::GetGSGameState()
{
	// 0x10f00  52  ?GetGSGameState@UR6GSServers@@UAEEXZ — size 6 bytes, no SEH frame.
	return GsGameState;
}

IMPL_TODO("Needs Ghidra analysis")
FString UR6GSServers::GetGlobalIdFromPlayerIDList(FString)
{
	return TEXT("");
}

IMPL_MATCH("R6GameService.dll", 0x6870)
INT UR6GSServers::GetLoggedInUbiDotCom()
{
	// 0x6870  56  ?GetLoggedInUbiDotCom@UR6GSServers@@UAEHXZ — size 6 bytes, no SEH frame.
	return GsLoggedInUbi;
}

IMPL_MATCH("R6GameService.dll", 0x12610)
BYTE UR6GSServers::GetLoginRegServer()
{
	// 0x12610  57  ?GetLoginRegServer@UR6GSServers@@UAEEXZ — size 6 bytes, no SEH frame.
	return GsLoginRegServer;
}

IMPL_MATCH("R6GameService.dll", 0x11fc0)
INT UR6GSServers::GetRegServerInitialized()
{
	// 0x11fc0  59  ?GetRegServerInitialized@UR6GSServers@@UAEHXZ — size 6 bytes, no SEH frame.
	return GsRegServerInit;
}

IMPL_MATCH("R6GameService.dll", 0x123a0)
INT UR6GSServers::GetServerRegistered()
{
	// 0x123a0  60  ?GetServerRegistered@UR6GSServers@@UAEHXZ — size 6 bytes, no SEH frame.
	return GsServerRegistered;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GSServers::Init(FString)
{
	guard(UR6GSServers::Init);
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GSServers::InitCDKey(INT, INT)
{
	guard(UR6GSServers::InitCDKey);
	unguard;
}

IMPL_APPROX("initialises CDKey subsystem, calls Init and InitCDKey, checks CDKey connection globals")
INT UR6GSServers::InitGSCDKey()
{
	INT retval = 0;
	guard(UR6GSServers::InitGSCDKey);

	// DIVERGENCE: vtable[4] call (UObject virtual at +0x10) skipped — GameSpy subsystem defunct.
	// Original called a GameSpy initialisation function via COM dispatch at this offset.

	GsCDKeyInitialized = 0; // DAT_100933d0 = 0

	if (GsClientInitialized == 0) // DAT_10091e60
	{
		FString szIP = eventGetLocallyBoundIpAddr();
		Init(szIP);
	}

	// Pass CDKey port numbers from class fields (this+0x184 = m_iRSCDKeyPort, this+0x188 = m_iModCDKeyPort).
	InitCDKey(m_iRSCDKeyPort, m_iModCDKeyPort); // this+0x184, this+0x188

	if (GsCDKeyAuthFlag != 0 && GsCDKeyConnected != 0) // DAT_10093410, DAT_100933cc
		retval = 1;

	return retval;
	unguard;
}

IMPL_APPROX("GameSpy availability check via two-step API; always returns 0 (servers defunct)")
INT UR6GSServers::InitGSClient()
{
	INT bStep1OK = 0;
	guard(UR6GSServers::InitGSClient);

	// FUN_10018650 = GSClientDll_GSIStartAvailable() — GameSpy availability check step 1.
	// DIVERGENCE: GameSpy servers defunct; returns failure (-1) always.
	INT iVar1 = -1;
	bStep1OK = (INT)(-1 < iVar1); // 1 if iVar1 >= 0

	if (GsLogDebug != 0) GLog->Logf(TEXT("InitGSClient step1=%d"), bStep1OK);

	if (bStep1OK)
	{
		// FUN_100188e0 = GSClientDll_GSIStartAvailableEx() — GameSpy availability check step 2.
		// DIVERGENCE: GameSpy servers defunct; returns failure (-1) always.
		iVar1 = -1;
		bStep1OK = (INT)(-1 < iVar1);
		if (GsLogDebug != 0) GLog->Logf(TEXT("InitGSClient step2=%d"), bStep1OK);
	}

	return bStep1OK;
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GSServers::InitMSClient()
{
	guard(UR6GSServers::InitMSClient);
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GSServers::InitProcessUpdateUbiServer(AGameInfo *, ALevelInfo *)
{
	guard(UR6GSServers::InitProcessUpdateUbiServer);
	unguard;
}

IMPL_APPROX("master server client init: initialises favourites, calls Init, sets MSClientInRequest")
INT UR6GSServers::InitializeMSClient()
{
	INT retval = 0;
	guard(UR6GSServers::InitializeMSClient);

	// Initialise favourites list inherited from UR6ServerList.
	((UR6ServerList*)this)->InitFavorites();

	if (GsClientInitialized == 0) // DAT_10091e60
	{
		FString szIP = eventGetLocallyBoundIpAddr();
		Init(szIP);

		if (GsClientInitialized == 0)
		{
			// Notify game manager: login failed.
			// DIVERGENCE: GR6GameManager event call (UR6AbstractGameManager::eventGMProcessMsg)
			// omitted — GameSpy login always fails when servers are defunct.
			retval = GsClientInitialized; // 0
			return retval;
			// unguard; (unreachable but needed — see unguard at end)
		}
	}

	GsMSClientInRequest = 1; // DAT_10091c14 = 1
	retval = GsClientInitialized; // DAT_10091e60

	return retval;
	unguard;
}

IMPL_APPROX("reg server connect and lobby selection loop; populates GsLoginRegServer and GsRegServerInit")
INT UR6GSServers::InitializeRegServer()
{
	INT retval = 0;
	guard(UR6GSServers::InitializeRegServer);

	if (GsClientInitialized == 0) // DAT_10091e60
	{
		FString szIP = eventGetLocallyBoundIpAddr();
		Init(szIP);
	}

	if (GsClientInitialized == 0) // still 0 after Init?
	{
		return retval; // 0
	}

	BOOL bGotLobby = FALSE;

	if (GsRegServerInit == 0) // DAT_10093b08
	{
		// FUN_1002f220 = GSMasterServer_CreateSendSocket() — connect to Ubi.com reg server.
		// DIVERGENCE: GameSpy/Ubi.com registration servers defunct; always returns 0.
		UINT uVar2 = 0;

		if (GsLogDebug != 0) GLog->Logf(TEXT("InitializeRegServer: reg server connect result=%d"), uVar2 & 0xff);

		if ((uVar2 & 0xff) != 0)
		{
			// FUN_100136d0 = GSMasterServer_InitRegServerList() — populate reg server entry list.
			// DIVERGENCE: omitted; reg server list always empty (defunct).

			for (INT i = 0; i < GsRegServerCount; i++) // DAT_100923a0
			{
				if (bGotLobby)
					break;
				char* pEntry = GsRegServerList + GsRegServerIndex * 0x108; // DAT_1009239c, stride 0x108
				// FUN_1002f290 = GSMasterServer_GetLobby() — attempt to connect to lobby entry.
				// DIVERGENCE: omitted; lobby servers defunct.
				bGotLobby = FALSE;
				GsRegServerIndex++;
				if (GsRegServerCount <= GsRegServerIndex)
					GsRegServerIndex = 0;
				if (GsLogDebug != 0) GLog->Logf(TEXT("InitializeRegServer: lobby idx=%d got=%d"), GsRegServerIndex, (INT)bGotLobby);
			}

			if (bGotLobby)
				GsRegServerInit = 1; // DAT_10093b08 = 1
		}

		if (GsLogDebug != 0) GLog->Logf(TEXT("InitializeRegServer: done, gotLobby=%d"), (INT)bGotLobby);
	}
	else
	{
		bGotLobby = TRUE;
	}

	// Ghidra's LAB_1001395b path.
	if (GsClientInitialized != 0 && bGotLobby)
	{
		GsLoginRegServer = 1; // DAT_10093afc = 1
		retval = 1;
	}
	else
	{
		GsLoginRegServer = 1; // DAT_10093afc = 1 (set on both paths in Ghidra)
		retval = 0;
	}

	return retval;
	unguard;
}

IMPL_APPROX("auth success check: passes for RavenShield base game or R6RSCUSTOM mod name")
INT UR6GSServers::IsAuthIDSuccess()
{
	INT retval = 0;
	guard(UR6GSServers::IsAuthIDSuccess);

	if (GsLogDebug != 0) // DAT_10091e70
		GLog->Logf(TEXT("IsAuthIDSuccess: checking auth"));

	// Always succeeds for the base RavenShield game.
	DWORD bIsRavenShield = GModMgr->eventIsRavenShield();
	if (bIsRavenShield == 0)
	{
		// Non-RavenShield mod: also succeed if mod name is "R6RSCUSTOM".
		const TCHAR* pModName = *GsCustomModName; // DAT_10092e64
		INT cmp = appStricmp(pModName, TEXT("R6RSCUSTOM"));
		if (cmp != 0)
		{
			return retval; // 0
		}
	}

	retval = 1;
	return retval;
	unguard;
}

IMPL_MATCH("R6GameService.dll", 0x6860)
INT UR6GSServers::IsMSClientIsInRequest()
{
	// 0x6860  77  ?IsMSClientIsInRequest@UR6GSServers@@UAEHXZ — size 14 bytes, no SEH frame.
	return (INT)(GsMSClientInRequest != 0);
}

IMPL_MATCH("R6GameService.dll", 0x7520)
INT UR6GSServers::IsServerJoined()
{
	// 0x7520  78  ?IsServerJoined@UR6GSServers@@UAEHXZ — size 6 bytes, no SEH frame.
	return GsServerJoined;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GSServers::LogGSVersion()
{
	guard(UR6GSServers::LogGSVersion);
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GSServers::LogOutServer()
{
	guard(UR6GSServers::LogOutServer);
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GSServers::MSCLientJoinServer(INT, INT, FString)
{
	guard(UR6GSServers::MSCLientJoinServer);
	unguard;
}

IMPL_APPROX("leave GameSpy master server room; clears GsServerJoined and GsMSClientState on success")
INT UR6GSServers::MSCLientLeaveServer()
{
	INT retval = 0;
	guard(UR6GSServers::MSCLientLeaveServer);

	// FUN_100323c0 = GSMasterServer_LeaveRoom() — disconnect from GameSpy master server room.
	// DIVERGENCE: GameSpy master server defunct since ~2013; always returns 0 (fail-safe).
	UINT uVar1 = 0;

	if (GsLogDebug != 0) GLog->Logf(TEXT("MSCLientLeaveServer result=%d"), uVar1 & 0xff);

	if ((uVar1 & 0xff) == 0)
	{
		if (GsLogDebug != 0) GLog->Logf(TEXT("MSCLientLeaveServer: failed"));
		return retval; // 0
	}

	GsServerJoined  = 0; // DAT_10091c00 = 0
	GsMSClientState = 0; // DAT_10091be4 = 0

	retval = (INT)(uVar1 & 0xff);
	return retval;
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GSServers::MSClientServerConnected(INT, INT)
{
	guard(UR6GSServers::MSClientServerConnected);
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GSServers::MasterServerManager(AR6AbstractGameInfo *, ALevelInfo *)
{
	guard(UR6GSServers::MasterServerManager);
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GSServers::NativeCDKeyPlayerStatusReply(FString, BYTE, INT)
{
	guard(UR6GSServers::NativeCDKeyPlayerStatusReply);
	unguard;
}

IMPL_APPROX("subnet check via WSAIoctl SIO_GET_INTERFACE_LIST comparing remote IP against local interfaces")
INT UR6GSServers::OnSameSubNet(FString szIPAddr)
{
	INT retval = 0;
	guard(UR6GSServers::OnSameSubNet);

	// Convert remote IP to network byte order.
	const TCHAR* pWide   = *szIPAddr;
	const char*  pAnsi   = appToAnsi(pWide);
	DWORD remoteIP = inet_addr(pAnsi);

	// Create a temporary UDP socket to query local interface list.
	SOCKET s = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);

	// Buffer for up to 20 INTERFACE_INFO entries (Ghidra: 0x5f0 = 1520 bytes,
	// each entry is 0x4c = 76 bytes per Ghidra stride calculation).
	BYTE  ifaceBuffer[0x5f0];
	DWORD bytesReturned = 0;

	// SIO_GET_INTERFACE_LIST = 0x4004747f
	INT result = WSAIoctl(s, 0x4004747f, NULL, 0,
	                      ifaceBuffer, sizeof(ifaceBuffer),
	                      &bytesReturned, NULL, NULL);

	if (result == SOCKET_ERROR)
	{
		// Ghidra: local_8 = -1 (exception filter path), then FString dtor + return 0.
		closesocket(s);
		return retval; // 0
	}

	// Each INTERFACE_INFO entry is 0x4c bytes.
	// IP address is at entry+0x08 (iiAddress.sin_addr), netmask at entry+0x38 (iiNetmask.sin_addr).
	// These offsets match Ghidra's a_Stack_610[i*0x13].S_un_b and a_Stack_5e0[i*0x13].S_un_b
	// where 0x13 * sizeof(DWORD) = 76 = 0x4c.
	DWORD numIfaces = bytesReturned / 0x4c;
	BOOL  bNotSameSubnet = TRUE;

	for (DWORD i = 0; bNotSameSubnet && i < numIfaces; i++)
	{
		DWORD ifaceIP   = *(DWORD*)(ifaceBuffer + i * 0x4c + 0x08); // iiAddress.sin_addr
		DWORD ifaceMask = *(DWORD*)(ifaceBuffer + i * 0x4c + 0x38); // iiNetmask.sin_addr
		bNotSameSubnet = ((ifaceMask & ifaceIP) != (ifaceIP & remoteIP));
	}

	closesocket(s);

	retval = (INT)(!bNotSameSubnet);
	return retval;
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GSServers::PingRequest(FString, FString)
{
	guard(UR6GSServers::PingRequest);
	unguard;
}

IMPL_APPROX("linear search of player ID array by name and global ID, RS or mod CDKey list")
INT UR6GSServers::PlayerIsInIDList(FString szPlayerName, FString szGlobalID, INT bModList)
{
	INT iFound = 0;
	guard(UR6GSServers::PlayerIsInIDList);

	INT i = 0;

	if (bModList == 0)
	{
		// Regular (RS CDKey) list: name at entry+0x0c, global-ID at entry+0x00.
		while (i < GsIDListCount && iFound == 0) // DAT_10092e9c
		{
			BYTE* pEntry = (BYTE*)GsIDListArray + i * 0x30; // DAT_10092e98, stride 0x30
			if (szPlayerName == *(FString*)(pEntry + 0x0c) &&
			    szGlobalID   == *(FString*)(pEntry + 0x00))
			{
				iFound = 1;
			}
			i++;
		}
	}
	else
	{
		// Mod CDKey list: name at entry+0x18, global-ID at entry+0x00.
		while (i < GsIDListCount && iFound == 0)
		{
			BYTE* pEntry = (BYTE*)GsIDListArray + i * 0x30;
			if (szPlayerName == *(FString*)(pEntry + 0x18) &&
			    szGlobalID   == *(FString*)(pEntry + 0x00))
			{
				iFound = 1;
			}
			i++;
		}
	}

	return iFound;
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GSServers::PollCallbacks(INT, INT, INT, INT)
{
	guard(UR6GSServers::PollCallbacks);
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GSServers::PollClientCDKeyCallbacks(INT, INT, INT)
{
	guard(UR6GSServers::PollClientCDKeyCallbacks);
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GSServers::PollGSClientCallbacks(INT)
{
	guard(UR6GSServers::PollGSClientCallbacks);
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GSServers::PollMSClientCallbacks(INT)
{
	guard(UR6GSServers::PollMSClientCallbacks);
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GSServers::PollPingManager(INT)
{
	guard(UR6GSServers::PollPingManager);
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GSServers::PollRegServerCallbacks(INT)
{
	guard(UR6GSServers::PollRegServerCallbacks);
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GSServers::ProcessAuthIdRequest(AController *)
{
	guard(UR6GSServers::ProcessAuthIdRequest);
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GSServers::ProcessInternetSrv(AR6AbstractGameInfo *, ALevelInfo *)
{
	guard(UR6GSServers::ProcessInternetSrv);
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GSServers::ProcessIsLobbyDisconnect(FLOAT *)
{
	guard(UR6GSServers::ProcessIsLobbyDisconnect);
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GSServers::ProcessIsRouterDisconnect(FLOAT *)
{
	guard(UR6GSServers::ProcessIsRouterDisconnect);
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GSServers::ProcessJoinServer(FLOAT *)
{
	guard(UR6GSServers::ProcessJoinServer);
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GSServers::ProcessJoinServerRequest()
{
	guard(UR6GSServers::ProcessJoinServerRequest);
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GSServers::ProcessLoginMasterSrv(INT, FLOAT *)
{
	guard(UR6GSServers::ProcessLoginMasterSrv);
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GSServers::ProcessMSClientInitRequest()
{
	guard(UR6GSServers::ProcessMSClientInitRequest);
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GSServers::ProcessPC_CDKeyRequest(AR6AbstractGameInfo *, ALevelInfo *, APlayerController *, INT)
{
	guard(UR6GSServers::ProcessPC_CDKeyRequest);
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GSServers::ProcessRegServerGetLobbiesRequest()
{
	guard(UR6GSServers::ProcessRegServerGetLobbiesRequest);
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GSServers::ProcessRegServerLoginRequest()
{
	guard(UR6GSServers::ProcessRegServerLoginRequest);
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GSServers::ProcessRegServerLoginRouterRequest()
{
	guard(UR6GSServers::ProcessRegServerLoginRouterRequest);
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GSServers::ProcessRegServerRegOnLobbyRequest()
{
	guard(UR6GSServers::ProcessRegServerRegOnLobbyRequest);
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GSServers::ProcessRegServerUpdateRequest()
{
	guard(UR6GSServers::ProcessRegServerUpdateRequest);
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GSServers::ProcessSubmitMatchResultReply()
{
	guard(UR6GSServers::ProcessSubmitMatchResultReply);
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GSServers::ProcessUbiComJoinServer(INT, INT, FString, FLOAT *)
{
	guard(UR6GSServers::ProcessUbiComJoinServer);
	unguard;
}

IMPL_APPROX("searches server list for alt-info match by address pair, triggers GameSpy field reads")
INT UR6GSServers::ReceiveAltInfo()
{
	INT iResult = 0;
	guard(UR6GSServers::ReceiveAltInfo);

	INT  iSrvIdx  = -1;
	BOOL bFound   = FALSE;

	if (GsAltInfoCount > 0) // DAT_100923c8
	{
		// Search m_GameServerList for the entry matching the alt-info response.
		// this+0x5c = TArray<FstGameServer>.Data, this+0x60 = TArray<FstGameServer>.Num
		// Each FstGameServer entry is 0xdc bytes.
		INT iNum = *(INT*)((BYTE*)this + 0x60);
		for (INT i = 0; i < iNum; i++)
		{
			if (bFound)
				break;
			INT* pEntry = (INT*)( *(INT*)((BYTE*)this + 0x5c) + i * 0xdc );
			if (pEntry[0] == GsAltInfoData[0] && pEntry[1] == GsAltInfoData[1])
			{
				bFound  = TRUE;
				iSrvIdx = i;
			}
		}

		if (bFound && GsAltInfoData[3] > 0)
		{
			iResult = 1;
			INT iOffset = iSrvIdx * 0xdc;
			BYTE* pBase = (BYTE*)( *(INT*)((BYTE*)this + 0x5c) );

			// FUN_10018b30 = GSClient_ServerGetQueryInfo() — begin reading server alt-info block.
			// FUN_10018ea0 = GSClient_ServerGetIntValue() — read integer field by key index.
			// Fields 0x6f–0x7b are GameSpy server info keys (group ID, flags, etc.).
			// DIVERGENCE: GameSpy master server API defunct; alt-info fields not populated.
			// GHIDRA REF: 0x1000b8d0 — full field-read sequence with ~25 FUN_10018ea0 calls.
			(void)pBase; (void)iOffset; // suppress unused-variable warnings
		}
	}

	return iResult;
	unguard;
}

IMPL_APPROX("server receive loop: rdtsc timestamp capture and up-to-2-entry processing per call")
INT UR6GSServers::ReceiveServer()
{
	INT bHaveServers = 0;
	guard(UR6GSServers::ReceiveServer);

	// local_38 in Ghidra: 1 if servers pending, 0 otherwise.
	bHaveServers = (INT)(0 < GsReceiveServerCount); // DAT_100923ec
	INT iProcessed = 0;

	if (bHaveServers)
	{
		// Record rdtsc-derived timestamp for server-list timeout logic.
		unsigned __int64 tsc = __rdtsc();
		float hi = (float)(int)(tsc >> 32);
		float lo = (float)(int)(tsc & 0xFFFFFFFFull);
		if ((int)(tsc >> 32)           < 0) hi += 4294967296.0f;
		if ((int)(tsc & 0xFFFFFFFFull) < 0) lo += 4294967296.0f;
		GsTimestamp = (lo + hi * 4294967296.0f) * (float)GSecondsPerCycle + 16777216.0f;
	}

	// Process up to 2 pending server entries per call (Ghidra: loop limit = 2).
	while (TRUE)
	{
		if (iProcessed >= 2 || GsReceiveServerCount <= iProcessed)
			break;

		// DIVERGENCE: full server-data parsing via GameSpy SDK helpers omitted.
		// GHIDRA REF: 0x1000ad20 — reads server fields via FUN_10018ea0/FUN_10018c90
		// and populates FstGameServer array entries. GameSpy SDK defunct.

		iProcessed++;
	}

	return bHaveServers;
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GSServers::ReceiveValidation()
{
	guard(UR6GSServers::ReceiveValidation);
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GSServers::RefreshOneServer(INT)
{
	guard(UR6GSServers::RefreshOneServer);
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GSServers::RefreshServers()
{
	guard(UR6GSServers::RefreshServers);
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GSServers::RegServerGetLobbies()
{
	guard(UR6GSServers::RegServerGetLobbies);
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GSServers::RegServerRouterLogin()
{
	guard(UR6GSServers::RegServerRouterLogin);
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GSServers::RegisterServer()
{
	guard(UR6GSServers::RegisterServer);
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GSServers::RequestActivation(FString, INT)
{
	guard(UR6GSServers::RequestActivation);
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GSServers::RequestAuthorization(INT)
{
	guard(UR6GSServers::RequestAuthorization);
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GSServers::RequestGSCDKeyActID()
{
	guard(UR6GSServers::RequestGSCDKeyActID);
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GSServers::RequestGSCDKeyAuthID()
{
	guard(UR6GSServers::RequestGSCDKeyAuthID);
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GSServers::RequestModCDKeyProcess(INT)
{
	guard(UR6GSServers::RequestModCDKeyProcess);
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GSServers::ResetAuthId()
{
	guard(UR6GSServers::ResetAuthId);
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GSServers::RouterDisconnect()
{
	guard(UR6GSServers::RouterDisconnect);
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GSServers::ServerLogin()
{
	guard(UR6GSServers::ServerLogin);
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GSServers::ServerRoundFinish()
{
	guard(UR6GSServers::ServerRoundFinish);
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GSServers::ServerRoundStart(INT)
{
	guard(UR6GSServers::ServerRoundStart);
	unguard;
}

IMPL_APPROX("acquires GameSpy COM interface via GetActiveObject and QueryInterface")
INT UR6GSServers::SetGSClientComInterface()
{
	INT bOK = 0;
	guard(UR6GSServers::SetGSClientComInterface);

	if (GsComInitialized != 0) // DAT_100939d8
	{
		return 1;
	}

	GsComInitialized = 1; // DAT_100939d8 = 1

	// Try to obtain the live GameSpy COM object (defunct since 2014; will fail).
	IUnknown* pInterface = NULL;
	HRESULT hr = GetActiveObject((const CLSID&)GsComCLSID, NULL, &pInterface); // DAT_10073074
	if (FAILED(hr))
	{
		GLog->Logf(TEXT("SetGSClientComInterface: GetActiveObject failed 0x%08x"), hr);
	}

	bOK = (INT)SUCCEEDED(hr);

	if (pInterface != NULL)
	{
		// QueryInterface for the specific GameSpy interface.
		hr = pInterface->QueryInterface((const IID&)GsComIID, (void**)&GsComInterface); // DAT_10072ff8
		if (FAILED(hr))
		{
			GLog->Logf(TEXT("SetGSClientComInterface: QueryInterface failed 0x%08x"), hr);
			bOK = 0;
		}
	}

	return bOK;
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GSServers::SetGSGameState(BYTE)
{
	guard(UR6GSServers::SetGSGameState);
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GSServers::SetGameServiceRequestState(BYTE)
{
	guard(UR6GSServers::SetGameServiceRequestState);
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GSServers::SetLoginRegServer(BYTE)
{
	guard(UR6GSServers::SetLoginRegServer);
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GSServers::SetRegServerLoginRequest(BYTE)
{
	guard(UR6GSServers::SetRegServerLoginRequest);
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GSServers::SubmitMatchResult()
{
	guard(UR6GSServers::SubmitMatchResult);
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GSServers::UnInitCDKey()
{
	guard(UR6GSServers::UnInitCDKey);
	unguard;
}

IMPL_APPROX("disconnects master server, clears all MS client and Ubi.com state globals")
INT UR6GSServers::UnInitMSClient()
{
	INT retval = 0;
	guard(UR6GSServers::UnInitMSClient);

	GsUbiLobbyState = 0; // DAT_10091e6c = 0  (set BEFORE ExceptionList guard in Ghidra)

	// Clear m_bLoggedInUbiDotCom (bit 7 of bitfield DWORD at this+0x194).
	*(UINT*)((BYTE*)this + 0x194) &= 0xffffff7f; // ~(1 << 7) = clear m_bLoggedInUbiDotCom

	GsServerJoined  = 0; // DAT_10091c00 = 0
	GsMSClientState = 0; // DAT_10091be4 = 0
	GsQueryState    = 0; // DAT_10091d30 = 0
	GsMSClientAlt   = 0; // DAT_10091d38 = 0
	GsLoggedInUbi   = 0; // DAT_10091e68 = 0
	GsUbiState1     = 0; // DAT_10091e64 = 0

	if (GsLogDebug != 0) GLog->Logf(TEXT("UnInitMSClient"));

	// FUN_10032300 = GSMasterServer_Disconnect() — disconnect and destroy GameSpy MS client.
	// DIVERGENCE: GameSpy master server API defunct since ~2013; returns 0 (disconnected).
	UINT uVar1 = 0;

	retval = (INT)(uVar1 & 0xff);
	return retval;
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GSServers::UnInitRegServer()
{
	guard(UR6GSServers::UnInitRegServer);
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GSServers::UpdateServer()
{
	guard(UR6GSServers::UpdateServer);
	unguard;
}

IMPL_APPROX("generated UScript event thunk")
void UR6GSServers::eventEndOfRoundDataSent()
{
	ProcessEvent(FindFunctionChecked(R6GAMESERVICE_EndOfRoundDataSent), NULL);
}

IMPL_APPROX("generated UScript event thunk")
void UR6GSServers::eventFillCreateGameInfo(AGameInfo *pGameInfo, ALevelInfo *pLevelInfo)
{
	struct {
		AGameInfo *pGameInfo;
		ALevelInfo *pLevelInfo;
	} Parms;
	Parms.pGameInfo = pGameInfo;
	Parms.pLevelInfo = pLevelInfo;
	ProcessEvent(FindFunctionChecked(R6GAMESERVICE_FillCreateGameInfo), &Parms);
}

IMPL_APPROX("generated UScript event thunk")
FString UR6GSServers::eventGetConsoleStoreIP(APlayerController *pPC)
{
	struct {
		APlayerController *pPC;
		FString ReturnValue;
	} Parms;
	Parms.ReturnValue = TEXT("");
	Parms.pPC = pPC;
	ProcessEvent(FindFunctionChecked(R6GAMESERVICE_GetConsoleStoreIP), &Parms);
	return Parms.ReturnValue;
}

IMPL_APPROX("generated UScript event thunk")
FString UR6GSServers::eventGetLocallyBoundIpAddr()
{
	struct {
		FString ReturnValue;
	} Parms;
	Parms.ReturnValue = TEXT("");
	ProcessEvent(FindFunctionChecked(R6GAMESERVICE_GetLocallyBoundIpAddr), &Parms);
	return Parms.ReturnValue;
}

IMPL_APPROX("generated UScript event thunk")
INT UR6GSServers::eventGetMaxAvailPorts()
{
	struct {
		INT ReturnValue;
	} Parms;
	Parms.ReturnValue = 0;
	ProcessEvent(FindFunctionChecked(R6GAMESERVICE_GetMaxAvailPorts), &Parms);
	return Parms.ReturnValue;
}

IMPL_APPROX("generated UScript event thunk")
void UR6GSServers::eventHandleNewLobbyConnection(ALevelInfo *pLevelInfo)
{
	struct {
		ALevelInfo *pLevelInfo;
	} Parms;
	Parms.pLevelInfo = pLevelInfo;
	ProcessEvent(FindFunctionChecked(R6GAMESERVICE_HandleNewLobbyConnection), &Parms);
}

IMPL_APPROX("generated UScript event thunk")
void UR6GSServers::eventInitializeMod()
{
	ProcessEvent(FindFunctionChecked(R6GAMESERVICE_InitializeMod), NULL);
}

IMPL_APPROX("generated UScript event thunk")
DWORD UR6GSServers::eventIsGlobalIDBanned(AR6AbstractGameInfo *pGameInfo, FString const &szGlobalID)
{
	struct {
		AR6AbstractGameInfo *pGameInfo;
		FString szGlobalID;
		DWORD ReturnValue;
	} Parms;
	Parms.ReturnValue = 0;
	Parms.pGameInfo = pGameInfo;
	Parms.szGlobalID = szGlobalID;
	ProcessEvent(FindFunctionChecked(R6GAMESERVICE_IsGlobalIDBanned), &Parms);
	return Parms.ReturnValue;
}

IMPL_APPROX("generated UScript event thunk")
void UR6GSServers::eventProcessServerMsg(APlayerController *pPC, FString const &szMsg)
{
	struct {
		APlayerController *pPC;
		FString szMsg;
	} Parms;
	Parms.pPC = pPC;
	Parms.szMsg = szMsg;
	ProcessEvent(FindFunctionChecked(R6GAMESERVICE_ProcessServerMsg), &Parms);
}

IMPL_APPROX("generated UScript event thunk")
FString UR6GSServers::eventTempGetPBConnectStatus(APlayerController *pPC)
{
	struct {
		APlayerController *pPC;
		FString ReturnValue;
	} Parms;
	Parms.ReturnValue = TEXT("");
	Parms.pPC = pPC;
	ProcessEvent(FindFunctionChecked(R6GAMESERVICE_TempGetPBConnectStatus), &Parms);
	return Parms.ReturnValue;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GSServers::execEnterCDKey(FFrame& Stack, RESULT_DECL)
{
	guard(UR6GSServers::execEnterCDKey);
	P_GET_STR(CDKey);
	P_FINISH;
	EnterCDKey(CDKey);
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GSServers::execGetMaxUbiServerNameSize(FFrame& Stack, RESULT_DECL)
{
	guard(UR6GSServers::execGetMaxUbiServerNameSize);
	P_FINISH;
	*(INT*)Result = 32;
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GSServers::execHandleAnyLobbyConnectionFail(FFrame& Stack, RESULT_DECL)
{
	guard(UR6GSServers::execHandleAnyLobbyConnectionFail);
	P_FINISH;
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GSServers::execInitGSCDKey(FFrame& Stack, RESULT_DECL)
{
	guard(UR6GSServers::execInitGSCDKey);
	P_FINISH;
	*(INT*)Result = InitGSCDKey();
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GSServers::execInitialize(FFrame& Stack, RESULT_DECL)
{
	guard(UR6GSServers::execInitialize);
	P_FINISH;
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GSServers::execInitializeMSClient(FFrame& Stack, RESULT_DECL)
{
	guard(UR6GSServers::execInitializeMSClient);
	P_FINISH;
	*(INT*)Result = InitializeMSClient();
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GSServers::execIsRefreshServersInProgress(FFrame& Stack, RESULT_DECL)
{
	guard(UR6GSServers::execIsRefreshServersInProgress);
	P_FINISH;
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GSServers::execNativeGetMSClientInitialized(FFrame& Stack, RESULT_DECL)
{
	guard(UR6GSServers::execNativeGetMSClientInitialized);
	P_FINISH;
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GSServers::execNativeGetSeconds(FFrame& Stack, RESULT_DECL)
{
	guard(UR6GSServers::execNativeGetSeconds);
	P_FINISH;
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GSServers::execNativeIsGSReadyToChangeMod(FFrame& Stack, RESULT_DECL)
{
	guard(UR6GSServers::execNativeIsGSReadyToChangeMod);
	P_FINISH;
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GSServers::execNativeIsRouterDisconnect(FFrame& Stack, RESULT_DECL)
{
	guard(UR6GSServers::execNativeIsRouterDisconnect);
	P_FINISH;
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GSServers::execNativeIsWaitingForGSInit(FFrame& Stack, RESULT_DECL)
{
	guard(UR6GSServers::execNativeIsWaitingForGSInit);
	P_FINISH;
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GSServers::execNativeLogOutServer(FFrame& Stack, RESULT_DECL)
{
	guard(UR6GSServers::execNativeLogOutServer);
	P_GET_INT(n);
	P_FINISH;
	LogOutServer();
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GSServers::execNativeMSCLientJoinServer(FFrame& Stack, RESULT_DECL)
{
	guard(UR6GSServers::execNativeMSCLientJoinServer);
	P_FINISH;
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GSServers::execNativeMSClientReqAltInfo(FFrame& Stack, RESULT_DECL)
{
	guard(UR6GSServers::execNativeMSClientReqAltInfo);
	P_FINISH;
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GSServers::execNativeProcessIcmpPing(FFrame& Stack, RESULT_DECL)
{
	guard(UR6GSServers::execNativeProcessIcmpPing);
	P_FINISH;
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GSServers::execNativeSetMatchResult(FFrame& Stack, RESULT_DECL)
{
	guard(UR6GSServers::execNativeSetMatchResult);
	P_FINISH;
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GSServers::execNativeUpdateServer(FFrame& Stack, RESULT_DECL)
{
	guard(UR6GSServers::execNativeUpdateServer);
	P_FINISH;
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GSServers::execRefreshOneServer(FFrame& Stack, RESULT_DECL)
{
	guard(UR6GSServers::execRefreshOneServer);
	P_GET_INT(iServerIndex);
	P_FINISH;
	RefreshOneServer(iServerIndex);
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GSServers::execRefreshServers(FFrame& Stack, RESULT_DECL)
{
	guard(UR6GSServers::execRefreshServers);
	P_FINISH;
	RefreshServers();
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GSServers::execSetLastServerQueried(FFrame& Stack, RESULT_DECL)
{
	guard(UR6GSServers::execSetLastServerQueried);
	P_GET_STR(szServer);
	P_FINISH;
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GSServers::execStopRefreshServers(FFrame& Stack, RESULT_DECL)
{
	guard(UR6GSServers::execStopRefreshServers);
	P_FINISH;
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GSServers::execUnInitializeMSClient(FFrame& Stack, RESULT_DECL)
{
	guard(UR6GSServers::execUnInitializeMSClient);
	P_FINISH;
	*(INT*)Result = UnInitMSClient();
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6GSServers::registerCDKeySDKCallbacks(UR6GSServers *, void *, void *)
{
	guard(UR6GSServers::registerCDKeySDKCallbacks);
	unguard;
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
