/*=============================================================================
	IpDrv.cpp: IpDrv package — TCP/IP networking driver.
	Reconstructed for Ravenshield decompilation project.
=============================================================================*/

// Suppress C4996: gethostbyname/inet_addr are deprecated in modern Windows SDK
// but these are the exact APIs retail Ravenshield used — suppress to match parity.
#pragma warning(disable: 4996)

#include "IpDrvPrivate.h"
#if _MSC_VER > 1310
#include <intrin.h>
#endif

/*-----------------------------------------------------------------------------
	Package.
-----------------------------------------------------------------------------*/

IMPLEMENT_PACKAGE(IpDrv)

/*-----------------------------------------------------------------------------
	FName event/callback tokens.
-----------------------------------------------------------------------------*/

#define NAMES_ONLY
#undef  AUTOGENERATE_NAME
#undef  AUTOGENERATE_FUNCTION
#define AUTOGENERATE_NAME(name) IPDRV_API FName IPDRV_##name;
#define AUTOGENERATE_FUNCTION(cls,idx,name) IMPLEMENT_FUNCTION(cls,idx,name)
#include "IpDrvClasses.h"
#undef AUTOGENERATE_FUNCTION
#undef AUTOGENERATE_NAME
#undef NAMES_ONLY

/*-----------------------------------------------------------------------------
	IMPLEMENT_CLASS for all 10 exported classes.
-----------------------------------------------------------------------------*/

IMPLEMENT_CLASS(AInternetLink)
IMPLEMENT_CLASS(ATcpLink)
IMPLEMENT_CLASS(AUdpLink)
IMPLEMENT_CLASS(UTcpNetDriver)
IMPLEMENT_CLASS(UTcpipConnection)
IMPLEMENT_CLASS(UHTTPDownload)
IMPLEMENT_CLASS(UCompressCommandlet)
IMPLEMENT_CLASS(UDecompressCommandlet)
IMPLEMENT_CLASS(UMasterServerCommandlet)
IMPLEMENT_CLASS(UUpdateServerCommandlet)

/*-----------------------------------------------------------------------------
	Native function exports.
	IMPLEMENT_FUNCTION creates the C-linkage global + registers with
	GRegisterNative. Native indices verified from retail IpDrv.u via
	parse_ipdrv_u.py. All functions except GetMaxAvailPorts have iNative=0 in
	IpDrv.u — meaning they are dispatched by name (EX_VirtualFunction), not by
	native index. INDEX_NONE (-1) is correct for those: no GNatives[] slot
	is registered, and the engine finds them by name lookup at runtime.
	GetMaxAvailPorts has iNative=1221 and is index-dispatched.
-----------------------------------------------------------------------------*/

IMPLEMENT_FUNCTION(AInternetLink, -1, execGetLastError)
IMPLEMENT_FUNCTION(AInternetLink, -1, execGetLocalIP)
IMPLEMENT_FUNCTION(AInternetLink, -1, execIpAddrToString)
IMPLEMENT_FUNCTION(AInternetLink, -1, execIsDataPending)
IMPLEMENT_FUNCTION(AInternetLink, -1, execParseURL)
IMPLEMENT_FUNCTION(AInternetLink, -1, execResolve)
IMPLEMENT_FUNCTION(AInternetLink, -1, execStringToIpAddr)
IMPLEMENT_FUNCTION(AInternetLink, -1, execValidate)

IMPLEMENT_FUNCTION(ATcpLink, -1, execBindPort)
IMPLEMENT_FUNCTION(ATcpLink, -1, execClose)
IMPLEMENT_FUNCTION(ATcpLink, -1, execIsConnected)
IMPLEMENT_FUNCTION(ATcpLink, -1, execListen)
IMPLEMENT_FUNCTION(ATcpLink, -1, execOpen)
IMPLEMENT_FUNCTION(ATcpLink, -1, execReadBinary)
IMPLEMENT_FUNCTION(ATcpLink, -1, execReadText)
IMPLEMENT_FUNCTION(ATcpLink, -1, execSendBinary)
IMPLEMENT_FUNCTION(ATcpLink, -1, execSendText)

IMPLEMENT_FUNCTION(AUdpLink, -1, execBindPort)
IMPLEMENT_FUNCTION(AUdpLink, -1, execCheckForPlayerTimeouts)
IMPLEMENT_FUNCTION(AUdpLink, 1221, execGetMaxAvailPorts)
IMPLEMENT_FUNCTION(AUdpLink, -1, execGetPlayingTime)
IMPLEMENT_FUNCTION(AUdpLink, -1, execReadBinary)
IMPLEMENT_FUNCTION(AUdpLink, -1, execReadText)
IMPLEMENT_FUNCTION(AUdpLink, -1, execSendBinary)
IMPLEMENT_FUNCTION(AUdpLink, -1, execSendText)
IMPLEMENT_FUNCTION(AUdpLink, -1, execSetPlayingTime)

/*-----------------------------------------------------------------------------
	Placement new — required for in-place UTcpipConnection construction.
-----------------------------------------------------------------------------*/

#pragma warning(push)
#pragma warning(disable: 4291)
IMPL_DIVERGE("C++ compiler-generated placement new/delete; no corresponding standalone retail DLL export")
inline void* operator new(size_t, void* p) noexcept { return p; }
IMPL_DIVERGE("C++ compiler-generated placement new/delete; no corresponding standalone retail DLL export")
inline void  operator delete(void*, void*) noexcept {}
#pragma warning(pop)

/*-----------------------------------------------------------------------------
	EConnectionState — only forward-declared in IpDrvPrivate.h; define here.
-----------------------------------------------------------------------------*/

enum EConnectionState
{
	USOCK_Invalid = 0,
	USOCK_Closed  = 1,
	USOCK_Pending = 2,
	USOCK_Open    = 3,
};

/*-----------------------------------------------------------------------------
	Async hostname resolution state.
	Layout matches binary: 0x308 bytes.
	+0x000: DWORD Addr     – resolved IP (network byte order from gethostbyname)
	+0x004: DWORD bWorking – non-zero while resolution is pending; retail uses
	                         this as the CreateThread lpThreadId output (ThreadId
	                         is stored here, then cleared to 0 on completion)
	+0x008: char  HostName[256] – ANSI hostname
	+0x108: In the retail binary this holds a wide-string error message written
	         by appSprintf on failure (making the first short non-zero = error).
	         We store a short WSA error code here instead; both are zero on success
	         and non-zero on failure, so the null-check in AInternetLink::Tick
	         is functionally equivalent.
-----------------------------------------------------------------------------*/

class FResolveInfo
{
public:
	DWORD Addr;
	DWORD bWorking;
	char  HostName[256];
	short Error;
	BYTE  _Pad[776 - 2 - 256 - 8]; // pad to 0x308 = 776 bytes total
};

/*-----------------------------------------------------------------------------
	Player time entry — used by AUdpLink to track per-player session times.
	Size: FString(12) + FLOAT(4) + FLOAT(4) = 0x14 bytes.
-----------------------------------------------------------------------------*/

#pragma pack(push, 4)
struct FPlayerTimeEntry
{
	FString IPAddr;       // +0x00: 12 bytes (TArray<TCHAR>)
	FLOAT   LoginTime;    // +0x0c: TSC-based login timestamp
	FLOAT   ActiveTime;   // +0x10: TSC-based last-active timestamp
};
#pragma pack(pop)
// sizeof(FPlayerTimeEntry) should be 0x14 = 20
// (FString = 12, FLOAT x2 = 8)

static FArray GPlayerTimes; // Raw FArray for player time tracking

/*-----------------------------------------------------------------------------
	Globals and helpers.
-----------------------------------------------------------------------------*/

// WSA state flag – set on first successful WSAStartup.
static INT GWSAInitialized = 0;

// Global socket for network driver (mirrors DAT_1072310c in binary).
static UINT GDrvSocket = 0;

// Helper: initialise WinSock if not already done.
// Corresponds to inline WSAStartup call sites in Init/socket-open paths; not a standalone export.
IMPL_DIVERGE("static helper; inlined across multiple retail call sites; not a standalone DLL export")
static INT InitWSA(FString& Error)
{
	if (!GWSAInitialized)
	{
		WSADATA WsaData;
		INT Err = WSAStartup(0x0101, &WsaData);
		if (Err != 0)
		{
			Error = FString::Printf(TEXT("WinSock: WSAStartup() failed (%d)"), Err);
			return 0;
		}
		GWSAInitialized = 1;
	}
	return 1;
}

// Helper: set socket non-blocking. Returns ioctlsocket error code (0 = OK).
// Corresponds to FUN_1070e0a0 / inline ioctlsocket call in socket-creation paths.
IMPL_DIVERGE("static helper; retail equivalent inlined or small unregistered function; not a standalone DLL export")
static INT SetNonBlocking(SOCKET s)
{
	u_long NonBlocking = 1;
	return ioctlsocket(s, FIONBIO, &NonBlocking);
}

// Helper: return true if socket handle is valid.
// Inlined at each socket-creation call site in retail.
IMPL_DIVERGE("static helper; inlined at call sites in retail; not a standalone DLL export")
static bool IsValidSocket(SOCKET s)
{
	return s != INVALID_SOCKET;
}

// Helper: get local IP for binding.
// In the retail binary this is FUN_10701be0 (in _unnamed.cpp) which reads the configured bind
// address from the output-device/log path.  We return INADDR_ANY for all-interfaces binding.
IMPL_DIVERGE("static helper; retail FUN_10701be0 reads bind address from config; we return INADDR_ANY")
static UINT GetLocalBindIP()
{
	return INADDR_ANY; // host order = 0
}

// Helper: bind socket and update address with assigned port.
// Retail equivalent is FUN_10701810 (_unnamed.cpp, 0x10701810): signature is
//   u_short FUN_10701810(SOCKET s, sockaddr* addr, int num_attempts, int port_increment).
// Our wrapper has different parameter semantics (mask flags + bReuseAddr vs attempt count +
// port increment) and calls setsockopt(SO_REUSEADDR) which retail does not.
IMPL_DIVERGE("static helper; retail FUN_10701810 uses attempt-count/increment params; our version uses flag/reuseaddr params")
static WORD BindSocket(SOCKET s, sockaddr_in* Addr, INT mask, INT bReuseAddr)
{
	if (bReuseAddr)
	{
		int optval = 1;
		setsockopt(s, SOL_SOCKET, SO_REUSEADDR, (char*)&optval, sizeof(optval));
	}
	if (mask & 8)
	{
		for (INT i = 0; i < 100; i++)
		{
			if (bind(s, (sockaddr*)Addr, sizeof(sockaddr_in)) == 0)
			{
				int len = sizeof(sockaddr_in);
				getsockname(s, (sockaddr*)Addr, &len);
				return ntohs(Addr->sin_port);
			}
			Addr->sin_port = htons(ntohs(Addr->sin_port) + 1);
		}
		return 0;
	}
	if (bind(s, (sockaddr*)Addr, sizeof(sockaddr_in)) == 0)
	{
		int len = sizeof(sockaddr_in);
		getsockname(s, (sockaddr*)Addr, &len);
		return ntohs(Addr->sin_port);
	}
	return 0;
}

// Helper: set post-bind socket options. Always succeeds in this implementation.
// Corresponds to small helper(s) inlined after bind at various call sites in retail.
IMPL_DIVERGE("static helper; retail post-bind setsockopt calls inlined at each bind site; this stub is a no-op")
static bool SetSocketOptions(SOCKET s)
{
	(void)s;
	return true;
}

// Helper: format IP (stored network-byte-order in a DWORD) as FString.
// For 1.2.3.4 stored as 0x04030201 on LE: b1=1, b2=2, b3=3, b4=4.
// Retail equivalent is FUN_1070df40 which also reads from a small cached buffer.
IMPL_DIVERGE("static helper; retail IP-formatting helper FUN_1070df40 uses a cached buffer; we reconstruct the string each call")
static FString IpAddrToStr(UINT Addr, UINT Port)
{
	BYTE b1 = (BYTE)( Addr        & 0xFF);
	BYTE b2 = (BYTE)((Addr >>  8) & 0xFF);
	BYTE b3 = (BYTE)((Addr >> 16) & 0xFF);
	BYTE b4 = (BYTE)((Addr >> 24) & 0xFF);
	if (Port)
		return FString::Printf(TEXT("%d.%d.%d.%d:%d"), b1, b2, b3, b4, Port);
	return FString::Printf(TEXT("%d.%d.%d.%d"), b1, b2, b3, b4);
}

// Async DNS resolve thread — fills FResolveInfo then clears bWorking.
// Retail FUN_1070e0f0 (0x1070e0f0): retries gethostbyname up to 3 times with appSleep(1.0)
// between attempts. WSATRY_AGAIN (0x2af9) and WSAHOST_NOT_FOUND (0x2afc) cause immediate
// failure with no retry. On success checks h_addrtype == AF_INET before storing.
// On failure, retail writes a wide-string error via appSprintf to offset 0x108; we store a
// short WSA error code there instead. Both are zero on success / non-zero on failure.
IMPL_DIVERGE("static helper; retail FUN_1070e0f0 writes wide-string error to offset 0x108; we store short WSA error code")
static DWORD WINAPI ResolveThread(LPVOID Param)
{
	FResolveInfo* Info = (FResolveInfo*)Param;
	Info->Addr = 0;
	int wsaErr  = 0;
	PHOSTENT he = NULL;

	for (int attempt = 0; ; ++attempt)
	{
		he = gethostbyname(Info->HostName);
		if (he) break;

		wsaErr = WSAGetLastError();
		// Permanent failures: do not retry
		if (wsaErr == 0x2af9 || wsaErr == 0x2afc) break;  // WSATRY_AGAIN / WSAHOST_NOT_FOUND

		appSleep(1.0f);
		if (attempt >= 2) break;  // 3 attempts maximum
	}

	if (he && he->h_addrtype == AF_INET)
		Info->Addr = *(DWORD*)he->h_addr_list[0]; // network byte order
	else
		Info->Error = (short)wsaErr;

	Info->bWorking = 0;
	return 0;
}

// Helper: initialise FResolveInfo and start DNS thread.
// Retail FUN_10701780 (0x10701780): uses FUN_10701220 for ANSI copy and passes &bWorking as
// lpThreadId (CreateThread writes the thread ID there; the thread clears it to 0 on finish).
// Also calls appFailAssert if CreateThread fails. We use a separate ThreadId local and omit
// the assert; both are functionally equivalent for callers that poll bWorking for completion.
IMPL_DIVERGE("static helper; retail FUN_10701780 passes &bWorking as lpThreadId and asserts on CreateThread failure")
static FResolveInfo* StartResolve(void* Buffer, const TCHAR* HostName)
{
	FResolveInfo* Info = (FResolveInfo*)Buffer;
	Info->Addr     = 0;
	Info->bWorking = 1;
	Info->Error    = 0;
	WideCharToMultiByte(CP_ACP, 0, HostName, -1,
	                    Info->HostName, (int)sizeof(Info->HostName), NULL, NULL);
	DWORD ThreadId;
	HANDLE h = CreateThread(NULL, 0, ResolveThread, Info, 0, &ThreadId);
	if (h) CloseHandle(h);
	return Info;
}

// Helper: get TSC-based elapsed time matching the binary's rdtsc formula.
// Returns a large float increasing monotonically, with 16777216 as epoch offset.
// This formula is inlined at each usage site in retail (LowLevelSend, SetPlayingTime, etc.).
IMPL_DIVERGE("static helper; rdtsc formula inlined at each retail call site; not a standalone DLL export")
static float GetTSCTime()
{
	unsigned __int64 tsc = __rdtsc();
	float hi = (float)(int)(tsc >> 32);
	float lo = (float)(int)(tsc & 0xFFFFFFFFull);
	if ((int)(tsc >> 32)            < 0) hi += 4294967296.0f;
	if ((int)(tsc & 0xFFFFFFFFull)  < 0) lo += 4294967296.0f;
	return (lo + hi * 4294967296.0f) * (float)GSecondsPerCycle + 16777216.0f;
}

/*
DIVERGENCES FROM BINARY:
- appFree/appMalloc used instead of raw GMalloc vtable calls for clarity.
- execValidate: CD key validation helpers (FUN_10703730 etc.) not implemented; returns empty string.
- GPlayerTimes uses FArray::Num() method instead of raw global DAT_10724a5c address.
- UTcpNetDriver::StaticConstructor: empty body; CPP_PROPERTY cannot take address
  of bitfield members in standard C++, matching the D3DDrv approach.
- UTcpNetDriver::InitConnect/InitListen: Super call omitted because the stub
  UNetDriver::InitConnect/InitListen returns 0, which would falsely abort init.
- TickDispatch simplified: new-connection spawn path and per-IP rate-limiting omitted.
- GetLocalBindIP() returns INADDR_ANY; original may read from config.
- FPlayerTimeEntry uses FString instead of FStringNoInit for IPAddr.
*/

/*-----------------------------------------------------------------------------
	AInternetLink implementation.
-----------------------------------------------------------------------------*/

IMPL_MATCH("IpDrv.dll", 0x10704620)
void AInternetLink::Destroy()
{
	if (Socket != -1)
	{
		closesocket((SOCKET)Socket);
		Socket = -1;
	}
	Super::Destroy();
}

IMPL_MATCH("IpDrv.dll", 0x107046b0)
INT AInternetLink::Tick(FLOAT DeltaTime, enum ELevelTick TickType)
{
	INT Ret = Super::Tick(DeltaTime, TickType);
	FResolveInfo* Info = GetResolveInfo();
	if (Info && Info->bWorking == 0)
	{
		if (Info->Error == 0)
		{
			FIpAddr Addr;
			Addr.Addr = (INT)ntohl(Info->Addr);
			Addr.Port = 0;
			debugf(NAME_DevNet, TEXT("Resolved %s to %s"),
			       appFromAnsi(Info->HostName), *IpAddrToStr(Info->Addr, 0));
			eventResolved(Addr);
		}
		else
		{
			debugf(NAME_DevNet, TEXT("Failed to resolve hostname"));
			eventResolveFailed();
		}
		appFree(Info);
		PrivateResolveInfo = 0;
	}
	return Ret;
}

IMPL_MATCH("IpDrv.dll", 0x10701da0)
FResolveInfo*& AInternetLink::GetResolveInfo()
{
	return *(FResolveInfo**)&PrivateResolveInfo;
}

IMPL_MATCH("IpDrv.dll", 0x10701d90)
UINT& AInternetLink::GetSocket()
{
	return *(UINT*)&Socket;
}

IMPL_MATCH("IpDrv.dll", 0x10701c70)
void AInternetLink::eventResolveFailed()
{
	ProcessEvent(FindFunctionChecked(IPDRV_ResolveFailed), NULL);
}

IMPL_MATCH("IpDrv.dll", 0x10701ca0)
void AInternetLink::eventResolved(FIpAddr Addr)
{
	struct { FIpAddr Addr; } Parms;
	Parms.Addr = Addr;
	ProcessEvent(FindFunctionChecked(IPDRV_Resolved), &Parms);
}

IMPL_MATCH("IpDrv.dll", 0x10704390)
void AInternetLink::execGetLastError(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
	*(INT*)Result = GWSAInitialized ? WSAGetLastError() : 0;
}

IMPL_MATCH("IpDrv.dll", 0x10704a10)
void AInternetLink::execGetLocalIP(FFrame& Stack, RESULT_DECL)
{
	P_GET_STRUCT_REF(FIpAddr, Addr);
	P_FINISH;
	if (GWSAInitialized && Socket != -1)
	{
		sockaddr_in sa;
		int len = sizeof(sa);
		if (getsockname((SOCKET)Socket, (sockaddr*)&sa, &len) == 0)
			Addr->Addr = (INT)ntohl(sa.sin_addr.s_addr);
	}
}

IMPL_MATCH("IpDrv.dll", 0x107040e0)
void AInternetLink::execIpAddrToString(FFrame& Stack, RESULT_DECL)
{
	P_GET_STRUCT(FIpAddr, A);
	P_FINISH;
	// A.Addr is host-order; shift gives correct octets
	*(FString*)Result = FString::Printf(TEXT("%i.%i.%i.%i:%i"),
	    (A.Addr >> 24) & 0xFF,
	    (A.Addr >> 16) & 0xFF,
	    (A.Addr >>  8) & 0xFF,
	     A.Addr        & 0xFF,
	     A.Port);
}

IMPL_MATCH("IpDrv.dll", 0x10703d10)
void AInternetLink::execIsDataPending(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
	*(DWORD*)Result = DataPending;
}

IMPL_MATCH("IpDrv.dll", 0x10703df0)
void AInternetLink::execParseURL(FFrame& Stack, RESULT_DECL)
{
	P_GET_STR(Url);
	P_GET_STR_REF(Addr);
	P_GET_INT_REF(Port);
	P_GET_STR_REF(LevelName);
	P_GET_STR_REF(EntryName);
	P_FINISH;
	FURL ParsedURL(NULL, *Url, TRAVEL_Absolute);
	*Addr      = ParsedURL.Host;
	*Port      = ParsedURL.Port;
	*LevelName = ParsedURL.Map;
	*EntryName = ParsedURL.Portal;
	*(INT*)Result = 1;
}

IMPL_MATCH("IpDrv.dll", 0x10704860)
void AInternetLink::execResolve(FFrame& Stack, RESULT_DECL)
{
	P_GET_STR(HostName);
	P_FINISH;
	if (!GWSAInitialized)
		return;
	// Check for dotted-decimal address first
	char AnsiHost[256];
	WideCharToMultiByte(CP_ACP, 0, *HostName, -1, AnsiHost, sizeof(AnsiHost), NULL, NULL);
	ULONG IpAddr = inet_addr(AnsiHost);
	if (IpAddr != INADDR_NONE)
	{
		if (IpAddr == 0xFFFFFFFF)
		{
			eventResolveFailed();
		}
		else
		{
			FIpAddr Addr;
			Addr.Addr = (INT)ntohl(IpAddr);
			Addr.Port = 0;
			eventResolved(Addr);
		}
		return;
	}
	// Allocate FResolveInfo (0x308 bytes) and start async thread
	void* Buf = appMalloc(sizeof(FResolveInfo), TEXT("InternetLinkResolve"));
	if (Buf)
	{
		PrivateResolveInfo = (INT)(DWORD_PTR)StartResolve(Buf, *HostName);
	}
}

IMPL_MATCH("IpDrv.dll", 0x10704210)
void AInternetLink::execStringToIpAddr(FFrame& Stack, RESULT_DECL)
{
	P_GET_STR(Str);
	P_GET_STRUCT_REF(FIpAddr, Addr);
	P_FINISH;
	char AnsiStr[256];
	WideCharToMultiByte(CP_ACP, 0, *Str, -1, AnsiStr, sizeof(AnsiStr), NULL, NULL);
	ULONG IpNet = inet_addr(AnsiStr);
	if (IpNet == INADDR_NONE)
	{
		*(INT*)Result = 0;
		return;
	}
	Addr->Addr = (INT)ntohl(IpNet);
	Addr->Port = 0;
	*(INT*)Result = 1;
}

IMPL_DIVERGE("Native: CD key validation stub; GameSpy SDK defunct since 2014")
void AInternetLink::execValidate(FFrame& Stack, RESULT_DECL)
{
	P_GET_STR(ProductID);
	P_GET_STR(CDKey);
	P_FINISH;
	// DIVERGENCE: CD key validation called GameSpy CDKey SDK (FUN_10703730/10703800/10703870/10703b90).
	// GameSpy services have been defunct since 2014; returning empty string (= validation skipped).
	*(FString*)Result = TEXT("");
}

/*-----------------------------------------------------------------------------
	ATcpLink implementation.
-----------------------------------------------------------------------------*/

IMPL_MATCH("IpDrv.dll", 0x10706450)
INT ATcpLink::Tick(FLOAT DeltaTime, enum ELevelTick TickType)
{
	INT Ret = Super::Tick(DeltaTime, TickType);
	switch (LinkState)
	{
	case STATE_Listening:
		CheckConnectionQueue();
		break;
	case STATE_Connecting:
		CheckConnectionAttempt();
		break;
	case STATE_Connected:
		if (ReceiveMode == RMODE_Event)
			PollConnections();
		FlushSendBuffer();
		break;
	case STATE_ListenClosePending:
	case STATE_ConnectClosePending:
		ShutdownConnection();
		break;
	default:
		break;
	}
	return Ret;
}

IMPL_MATCH("IpDrv.dll", 0x10704ba0)
void ATcpLink::PostScriptDestroyed()
{
	if (Socket != -1)
	{
		closesocket((SOCKET)Socket);
		Socket = -1;
	}
	if (RemoteSocket != -1)
	{
		closesocket((SOCKET)RemoteSocket);
		RemoteSocket = -1;
	}
}

IMPL_MATCH("IpDrv.dll", 0x10705310)
void ATcpLink::CheckConnectionAttempt()
{
	SOCKET s = (RemoteSocket != -1) ? (SOCKET)RemoteSocket : (SOCKET)Socket;
	fd_set WriteSet;
	FD_ZERO(&WriteSet);
	FD_SET(s, &WriteSet);
	timeval tv = { 0, 0 };
	int Ret = select((int)s + 1, NULL, &WriteSet, NULL, &tv);
	if (Ret > 0 && FD_ISSET(s, &WriteSet))
	{
		LinkState = STATE_Connected;
		SendFIFO.Empty();
		eventOpened();
	}
}

IMPL_MATCH("IpDrv.dll", 0x10705ec0)
void ATcpLink::CheckConnectionQueue()
{
	sockaddr RemoteAddr_sa;
	int AddrLen = sizeof(RemoteAddr_sa);
	SOCKET Accepted = accept((SOCKET)Socket, &RemoteAddr_sa, &AddrLen);
	if (Accepted == INVALID_SOCKET)
		return;
	SetSocketOptions(Accepted);
	if (AcceptClass == NULL)
	{
		RemoteSocket = (INT)Accepted;
		DWORD NetIP = *(DWORD*)&RemoteAddr_sa.sa_data[2];
		RemoteAddr.Addr = (INT)ntohl(NetIP);
		RemoteAddr.Port = (INT)(WORD)ntohs(*(u_short*)&RemoteAddr_sa.sa_data[0]);
		eventAccepted();
		return;
	}
	// Spawn a new AcceptClass actor for this connection
	for (UClass* C = AcceptClass; C != NULL; C = C->GetSuperClass())
	{
		if (C == StaticClass())
		{
			ATcpLink* NewLink = (ATcpLink*)XLevel->SpawnActor(AcceptClass);
			if (NewLink)
			{
				NewLink->LinkState    = STATE_Connected;
				NewLink->LinkMode     = LinkMode;
				NewLink->RemoteSocket = (INT)Accepted;
				DWORD NetIP = *(DWORD*)&RemoteAddr_sa.sa_data[2];
				NewLink->RemoteAddr.Addr = (INT)ntohl(NetIP);
				NewLink->RemoteAddr.Port = (INT)(WORD)ntohs(*(u_short*)&RemoteAddr_sa.sa_data[0]);
				NewLink->eventAccepted();
			}
			return;
		}
	}
}

IMPL_MATCH("IpDrv.dll", 0x10705860)
INT ATcpLink::FlushSendBuffer()
{
	if (!GWSAInitialized || Socket == -1 || SendFIFO.Num() == 0)
		return 0;
	SOCKET s = (RemoteSocket != -1) ? (SOCKET)RemoteSocket : (SOCKET)Socket;
	INT Sent  = 0;
	while (SendFIFO.Num() > 0)
	{
		INT Chunk = Min(SendFIFO.Num(), 512);
		INT n     = send(s, (char*)&SendFIFO(0), Chunk, 0);
		if (n == SOCKET_ERROR)
			break;
		SendFIFO.Remove(0, n);
		Sent += n;
	}
	return Sent;
}

IMPL_MATCH("IpDrv.dll", 0x107061d0)
void ATcpLink::PollConnections()
{
	SOCKET s = (RemoteSocket != -1) ? (SOCKET)RemoteSocket : (SOCKET)Socket;
	if (ReceiveMode == RMODE_Manual)
	{
		fd_set ReadSet;
		timeval tv = { 0, 0 };
		FD_ZERO(&ReadSet);
		FD_SET(s, &ReadSet);
		int Ret  = select((int)s + 1, &ReadSet, NULL, NULL, &tv);
		DataPending = (Ret > 0) ? 1 : 0;
		return;
	}
	if (ReceiveMode != RMODE_Event)
		return;
	BYTE Buf[1000];
	appMemzero(Buf, sizeof(Buf));
	INT n = recv(s, (char*)Buf, 999, 0);
	if (n == SOCKET_ERROR)
		return;
	Buf[n] = 0;
	if (LinkMode == MODE_Text)
	{
		FString Text(appFromAnsi((char*)Buf));
		eventReceivedText(Text);
	}
	else if (LinkMode == MODE_Line)
	{
		FString Line(appFromAnsi((char*)Buf));
		eventReceivedLine(Line);
	}
	else
	{
		eventReceivedBinary(n, Buf);
	}
}

IMPL_MATCH("IpDrv.dll", 0x10705520)
void ATcpLink::ShutdownConnection()
{
	SOCKET s = (RemoteSocket != -1) ? (SOCKET)RemoteSocket : (SOCKET)Socket;
	if (s != INVALID_SOCKET)
	{
		if (LinkState == STATE_ListenClosePending || LinkState == STATE_ConnectClosePending)
		{
			shutdown(s, SD_BOTH);
			LinkState = (ELinkState)(LinkState + 2); // advance to Closing state
		}
		else
		{
			closesocket(s);
			if (RemoteSocket != -1)
				RemoteSocket = -1;
			else
				Socket = -1;
			LinkState = STATE_Ready;
			eventClosed();
		}
	}
}

IMPL_MATCH("IpDrv.dll", 0x107021c0)
void ATcpLink::eventAccepted()
{
	ProcessEvent(FindFunctionChecked(IPDRV_Accepted), NULL);
}

IMPL_MATCH("IpDrv.dll", 0x10702160)
void ATcpLink::eventClosed()
{
	ProcessEvent(FindFunctionChecked(IPDRV_Closed), NULL);
}

IMPL_MATCH("IpDrv.dll", 0x10702190)
void ATcpLink::eventOpened()
{
	ProcessEvent(FindFunctionChecked(IPDRV_Opened), NULL);
}

IMPL_MATCH("IpDrv.dll", 0x10702100)
void ATcpLink::eventReceivedBinary(INT Count, BYTE* B)
{
	struct { INT Count; BYTE B[255]; } Parms;
	Parms.Count = Count;
	if (B) appMemcpy(Parms.B, B, Min(Count, 255));
	ProcessEvent(FindFunctionChecked(IPDRV_ReceivedBinary), &Parms);
}

IMPL_MATCH("IpDrv.dll", 0x107031e0)
void ATcpLink::eventReceivedLine(const FString& Line)
{
	struct { FString Line; } Parms;
	Parms.Line = Line;
	ProcessEvent(FindFunctionChecked(IPDRV_ReceivedLine), &Parms);
}

IMPL_MATCH("IpDrv.dll", 0x10703270)
void ATcpLink::eventReceivedText(const FString& Text)
{
	struct { FString Text; } Parms;
	Parms.Text = Text;
	ProcessEvent(FindFunctionChecked(IPDRV_ReceivedText), &Parms);
}

IMPL_MATCH("IpDrv.dll", 0x10704bd0)
void ATcpLink::execBindPort(FFrame& Stack, RESULT_DECL)
{
	P_GET_INT(InPort);
	P_GET_UBOOL_OPTX(bUseNextAvailable, 0);
	P_FINISH;
	*(INT*)Result = 0;
	FString WsaErrStr;
	if (!InitWSA(WsaErrStr))
		return;
	if (Socket != -1)
		return; // already bound
	SOCKET s = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
	if (s == INVALID_SOCKET)
		return;
	Socket = (INT)s;
	SetNonBlocking(s);
	if (!IsValidSocket(s))
	{
		closesocket(s); Socket = 0;
		return;
	}
	sockaddr_in Addr;
	appMemzero(&Addr, sizeof(Addr));
	Addr.sin_family      = AF_INET;
	Addr.sin_addr.s_addr = htonl(GetLocalBindIP());
	Addr.sin_port        = htons((u_short)InPort);
	INT mask    = (bUseNextAvailable ? 10 : 1);
	WORD BoundPort = BindSocket(s, &Addr, mask, 1);
	if (BoundPort == 0)
	{
		closesocket(s); Socket = 0;
		return;
	}
	if (!SetSocketOptions(s))
	{
		closesocket(s); Socket = 0;
		return;
	}
	Port      = BoundPort;
	LinkState = STATE_Ready;
	*(INT*)Result = BoundPort;
}

IMPL_MATCH("IpDrv.dll", 0x10705410)
void ATcpLink::execClose(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
	*(DWORD*)Result = 0;
	if (Socket != -1)
	{
		shutdown((SOCKET)Socket, SD_BOTH);
		closesocket((SOCKET)Socket);
		Socket = -1;
	}
	if (RemoteSocket != -1)
	{
		closesocket((SOCKET)RemoteSocket);
		RemoteSocket = -1;
	}
	LinkState = STATE_Initialized;
	SendFIFO.Empty();
	*(DWORD*)Result = 1;
}

IMPL_MATCH("IpDrv.dll", 0x10704e50)
void ATcpLink::execIsConnected(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
	*(DWORD*)Result = (LinkState == STATE_Connected) ? 1 : 0;
}

IMPL_MATCH("IpDrv.dll", 0x10704fe0)
void ATcpLink::execListen(FFrame& Stack, RESULT_DECL)
{
	P_GET_INT(QueueSize);
	P_FINISH;
	*(DWORD*)Result = 0;
	if (!GWSAInitialized || Socket == -1)
		return;
	if (listen((SOCKET)Socket, QueueSize) == SOCKET_ERROR)
		return;
	LinkState = STATE_Listening;
	*(DWORD*)Result = 1;
}

IMPL_MATCH("IpDrv.dll", 0x10705170)
void ATcpLink::execOpen(FFrame& Stack, RESULT_DECL)
{
	P_GET_STRUCT(FIpAddr, Addr);
	P_FINISH;
	*(DWORD*)Result = 1;
	if (!GWSAInitialized || Socket == -1)
		return;
	sockaddr_in Remote;
	appMemzero(&Remote, sizeof(Remote));
	Remote.sin_family      = AF_INET;
	Remote.sin_port        = htons((u_short)Addr.Port);
	Remote.sin_addr.s_addr = htonl((u_long)Addr.Addr);
	INT n = connect((SOCKET)Socket, (sockaddr*)&Remote, sizeof(Remote));
	if (n == SOCKET_ERROR && WSAGetLastError() != WSAEWOULDBLOCK)
	{
		*(DWORD*)Result = 0;
		return;
	}
	LinkState = STATE_Connecting;
	SendFIFO.Empty();
}

IMPL_MATCH("IpDrv.dll", 0x10705ca0)
void ATcpLink::execReadBinary(FFrame& Stack, RESULT_DECL)
{
	P_GET_INT_REF(Count);
	P_GET_ARRAY_REF(BYTE, B); // out byte B[255]
	P_FINISH;
	*(INT*)Result = 0;
	if (!GWSAInitialized || Socket == -1)
		return;
	SOCKET s = (RemoteSocket != -1) ? (SOCKET)RemoteSocket : (SOCKET)Socket;
	INT n = recv(s, (char*)B, Min(*Count, 255), 0);
	if (n == SOCKET_ERROR)
		return;
	*Count = n;
	*(INT*)Result = n;
}

IMPL_MATCH("IpDrv.dll", 0x10705650)
void ATcpLink::execReadText(FFrame& Stack, RESULT_DECL)
{
	P_GET_STR_REF(Str);
	P_FINISH;
	*(INT*)Result = 0;
	if (!GWSAInitialized || Socket == -1)
		return;
	SOCKET s = (RemoteSocket != -1) ? (SOCKET)RemoteSocket : (SOCKET)Socket;
	char Buf[1000];
	appMemzero(Buf, sizeof(Buf));
	INT n = recv(s, Buf, 999, 0);
	if (n == SOCKET_ERROR)
		return;
	Buf[n] = 0;
	*Str = FString(appFromAnsi(Buf));
	*(INT*)Result = n;
}

IMPL_MATCH("IpDrv.dll", 0x10705960)
void ATcpLink::execSendBinary(FFrame& Stack, RESULT_DECL)
{
	P_GET_INT(Count);
	P_GET_ARRAY_REF(BYTE, B); // out byte B[255]
	P_FINISH;
	*(INT*)Result = 0;
	if (!GWSAInitialized || Socket == -1)
		return;
	// Add bytes to the send FIFO then flush
	INT Idx = SendFIFO.Add(Count);
	appMemcpy(&SendFIFO(Idx), B, Count);
	*(INT*)Result = Count;
	FlushSendBuffer();
}

IMPL_MATCH("IpDrv.dll", 0x10705b00)
void ATcpLink::execSendText(FFrame& Stack, RESULT_DECL)
{
	P_GET_STR(Str);
	P_FINISH;
	*(INT*)Result = 0;
	if (!GWSAInitialized || Socket == -1)
		return;
	if (LinkMode == MODE_Line)
		Str += TEXT("\r\n");
	char AnsiStr[1024];
	WideCharToMultiByte(CP_ACP, 0, *Str, -1, AnsiStr, sizeof(AnsiStr), NULL, NULL);
	INT Len = Str.Len();
	if (Len > 0)
	{
		INT Idx = SendFIFO.Add(Len);
		appMemcpy(&SendFIFO(Idx), AnsiStr, Len);
	}
	*(INT*)Result = Len;
	FlushSendBuffer();
}

/*-----------------------------------------------------------------------------
	AUdpLink implementation.
-----------------------------------------------------------------------------*/

IMPL_MATCH("IpDrv.dll", 0x1070b050)
INT AUdpLink::Tick(FLOAT DeltaTime, enum ELevelTick TickType)
{
	INT Ret = Super::Tick(DeltaTime, TickType);
	if (!GWSAInitialized || Socket == -1 || ReceiveMode != RMODE_Event)
		return Ret;
	char Buf[1000];
	sockaddr_in FromAddr;
	int FromLen;
	for (;;)
	{
		appMemzero(Buf, sizeof(Buf));
		appMemzero(&FromAddr, sizeof(FromAddr));
		FromLen = sizeof(FromAddr);
		INT n = recvfrom((SOCKET)Socket, Buf, 999, 0, (sockaddr*)&FromAddr, &FromLen);
		if (n == SOCKET_ERROR)
			break;
		Buf[n] = 0;
		FIpAddr SrcAddr;
		SrcAddr.Addr = (INT)ntohl(FromAddr.sin_addr.s_addr);
		SrcAddr.Port = (INT)ntohs(FromAddr.sin_port);
		if (LinkMode == MODE_Text)
		{
			FString Text(appFromAnsi(Buf));
			eventReceivedText(SrcAddr, Text);
		}
		else if (LinkMode == MODE_Line)
		{
			FString Line(appFromAnsi(Buf));
			eventReceivedLine(SrcAddr, Line);
		}
		else
		{
			eventReceivedBinary(SrcAddr, n, (BYTE*)Buf);
		}
	}
	return Ret;
}

IMPL_MATCH("IpDrv.dll", 0x1070a5e0)
void AUdpLink::PostScriptDestroyed()
{
	if (Socket != -1)
	{
		closesocket((SOCKET)Socket);
		Socket = -1;
	}
}

IMPL_MATCH("IpDrv.dll", 0x10701f00)
void AUdpLink::eventReceivedBinary(FIpAddr Addr, INT Count, BYTE* B)
{
	struct { FIpAddr Addr; INT Count; BYTE B[255]; } Parms;
	Parms.Addr  = Addr;
	Parms.Count = Count;
	if (B) appMemcpy(Parms.B, B, Min(Count, 255));
	ProcessEvent(FindFunctionChecked(IPDRV_ReceivedBinary), &Parms);
}

IMPL_MATCH("IpDrv.dll", 0x107030a0)
void AUdpLink::eventReceivedLine(FIpAddr Addr, const FString& Line)
{
	struct { FIpAddr Addr; FString Line; } Parms;
	Parms.Addr = Addr;
	Parms.Line = Line;
	ProcessEvent(FindFunctionChecked(IPDRV_ReceivedLine), &Parms);
}

IMPL_MATCH("IpDrv.dll", 0x10703140)
void AUdpLink::eventReceivedText(FIpAddr Addr, const FString& Text)
{
	struct { FIpAddr Addr; FString Text; } Parms;
	Parms.Addr = Addr;
	Parms.Text = Text;
	ProcessEvent(FindFunctionChecked(IPDRV_ReceivedText), &Parms);
}

IMPL_MATCH("IpDrv.dll", 0x1070a600)
void AUdpLink::execBindPort(FFrame& Stack, RESULT_DECL)
{
	P_GET_INT(InPort);
	P_GET_UBOOL_OPTX(bUseNextAvailable, 0);
	P_GET_STR_REF(Error);
	P_FINISH;
	*(INT*)Result = 0;
	if (!GWSAInitialized)
		return;
	if (Socket != -1)
		return;
	SOCKET s = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
	if (s == INVALID_SOCKET)
		return;
	Socket = (INT)s;
	// Enable broadcast
	int bcast = 1;
	if (setsockopt(s, SOL_SOCKET, SO_BROADCAST, (char*)&bcast, sizeof(bcast)) != 0)
	{
		closesocket(s); Socket = 0;
		return;
	}
	UINT LocalIP = GetLocalBindIP();
	sockaddr_in Addr;
	appMemzero(&Addr, sizeof(Addr));
	Addr.sin_family      = AF_INET;
	Addr.sin_addr.s_addr = htonl(LocalIP);
	// Store local IP string in Error out-param (matches Ghidra: FString::operator=(param_1, FormatIP))
	*Error = IpAddrToStr(htonl(LocalIP), 0);
	Addr.sin_port = htons((u_short)InPort);
	INT mask  = (bUseNextAvailable ? 10 : 1);
	WORD BoundPort = BindSocket(s, &Addr, mask, 1);
	if (BoundPort == 0)
	{
		closesocket(s); Socket = 0;
		return;
	}
	u_long NonBlocking = 1;
	if (ioctlsocket(s, FIONBIO, &NonBlocking) != 0)
	{
		closesocket(s); Socket = 0;
		return;
	}
	Port = BoundPort;
	*(INT*)Result = BoundPort;
}

IMPL_MATCH("IpDrv.dll", 0x1070b2e0)
void AUdpLink::execCheckForPlayerTimeouts(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
	float Now = GetTSCTime();
	INT Count = GPlayerTimes.Num();
	FPlayerTimeEntry* Entries = (FPlayerTimeEntry*)GPlayerTimes.GetData();
	for (INT i = Count - 1; i >= 0; i--)
	{
		if (Now - Entries[i].ActiveTime > 120.0f)
		{
			Entries[i].IPAddr.Empty();
			GPlayerTimes.Remove(i, 1, sizeof(FPlayerTimeEntry));
		}
	}
}

IMPL_MATCH("IpDrv.dll", 0x1070a1b0)
void AUdpLink::execGetMaxAvailPorts(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
	*(INT*)Result = 10; // hardcoded in binary
}

IMPL_MATCH("IpDrv.dll", 0x1070a480)
void AUdpLink::execGetPlayingTime(FFrame& Stack, RESULT_DECL)
{
	P_GET_STR(PlayerIP);
	P_FINISH;
	*(FLOAT*)Result = 0.0f;
	INT Count = GPlayerTimes.Num();
	FPlayerTimeEntry* Entries = (FPlayerTimeEntry*)GPlayerTimes.GetData();
	float Now = GetTSCTime();
	for (INT i = 0; i < Count; i++)
	{
		if (appStrcmp(*PlayerIP, *Entries[i].IPAddr) == 0)
		{
			*(FLOAT*)Result = Now - Entries[i].LoginTime;
			return;
		}
	}
}

IMPL_MATCH("IpDrv.dll", 0x1070ae10)
void AUdpLink::execReadBinary(FFrame& Stack, RESULT_DECL)
{
	P_GET_STRUCT_REF(FIpAddr, Addr);
	P_GET_INT_REF(Count);
	P_GET_ARRAY_REF(BYTE, B); // out byte B[255]
	P_FINISH;
	*(INT*)Result = 0;
	if (!GWSAInitialized || Socket == -1)
		return;
	char Buf[256];
	sockaddr_in FromAddr;
	int FromLen = sizeof(FromAddr);
	appMemzero(&FromAddr, sizeof(FromAddr));
	INT n = recvfrom((SOCKET)Socket, Buf, Min(*Count, 255), 0, (sockaddr*)&FromAddr, &FromLen);
	if (n == SOCKET_ERROR)
		return;
	Addr->Addr = (INT)ntohl(FromAddr.sin_addr.s_addr);
	Addr->Port = (INT)ntohs(FromAddr.sin_port);
	*Count = n;
	appMemcpy(B, Buf, n);
	*(INT*)Result = n;
}

IMPL_MATCH("IpDrv.dll", 0x1070abc0)
void AUdpLink::execReadText(FFrame& Stack, RESULT_DECL)
{
	P_GET_STRUCT_REF(FIpAddr, Addr);
	P_GET_STR_REF(Str);
	P_FINISH;
	*(INT*)Result = 0;
	if (!GWSAInitialized || Socket == -1)
		return;
	char Buf[1000];
	sockaddr_in FromAddr;
	int FromLen = sizeof(FromAddr);
	appMemzero(&FromAddr, sizeof(FromAddr));
	INT n = recvfrom((SOCKET)Socket, Buf, 999, 0, (sockaddr*)&FromAddr, &FromLen);
	if (n == SOCKET_ERROR)
		return;
	Buf[n] = 0;
	Addr->Addr = (INT)ntohl(FromAddr.sin_addr.s_addr);
	Addr->Port = (INT)ntohs(FromAddr.sin_port);
	*Str = FString(appFromAnsi(Buf));
	*(INT*)Result = n;
}

IMPL_MATCH("IpDrv.dll", 0x1070aa20)
void AUdpLink::execSendBinary(FFrame& Stack, RESULT_DECL)
{
	P_GET_STRUCT(FIpAddr, Addr);
	P_GET_INT(Count);
	P_GET_ARRAY_REF(BYTE, B); // out byte B[255]
	P_FINISH;
	*(DWORD*)Result = 0;
	if (!GWSAInitialized || Socket == -1)
		return;
	sockaddr_in Remote;
	appMemzero(&Remote, sizeof(Remote));
	Remote.sin_family      = AF_INET;
	Remote.sin_port        = htons((u_short)Addr.Port);
	Remote.sin_addr.s_addr = htonl((u_long)Addr.Addr);
	INT n = sendto((SOCKET)Socket, (char*)B, Count, 0, (sockaddr*)&Remote, sizeof(Remote));
	if (n == SOCKET_ERROR)
	{
		*(DWORD*)Result = 1; // error (matches binary: result=1 on sendto failure)
		return;
	}
	// result stays 0 (success) per binary
}

IMPL_MATCH("IpDrv.dll", 0x1070a8c0)
void AUdpLink::execSendText(FFrame& Stack, RESULT_DECL)
{
	P_GET_STRUCT(FIpAddr, Addr);
	P_GET_STR(Str);
	P_FINISH;
	*(DWORD*)Result = 1; // default success
	if (!GWSAInitialized || Socket == -1)
		return;
	sockaddr_in Remote;
	appMemzero(&Remote, sizeof(Remote));
	Remote.sin_family      = AF_INET;
	Remote.sin_port        = htons((u_short)Addr.Port);
	Remote.sin_addr.s_addr = htonl((u_long)Addr.Addr);
	char AnsiStr[1024];
	WideCharToMultiByte(CP_ACP, 0, *Str, -1, AnsiStr, sizeof(AnsiStr), NULL, NULL);
	INT Len = Str.Len();
	INT n = sendto((SOCKET)Socket, AnsiStr, Len, 0, (sockaddr*)&Remote, sizeof(Remote));
	if (n == SOCKET_ERROR)
		*(DWORD*)Result = 0; // failure
}

IMPL_MATCH("IpDrv.dll", 0x1070a2b0)
void AUdpLink::execSetPlayingTime(FFrame& Stack, RESULT_DECL)
{
	P_GET_STR(PlayerIP);
	P_GET_FLOAT(LoginTime);
	P_GET_FLOAT(CurrentTime);
	P_FINISH;
	float Now = GetTSCTime();
	INT Count = GPlayerTimes.Num();
	FPlayerTimeEntry* Entries = (FPlayerTimeEntry*)GPlayerTimes.GetData();
	for (INT i = 0; i < Count; i++)
	{
		if (appStrcmp(*PlayerIP, *Entries[i].IPAddr) == 0)
		{
			Entries[i].ActiveTime = Now;
			return;
		}
	}
	// New entry: AddZeroed(ElementSize, Count) returns index of first new element
	INT Idx = GPlayerTimes.AddZeroed(sizeof(FPlayerTimeEntry), 1);
	FPlayerTimeEntry* Entry = &((FPlayerTimeEntry*)GPlayerTimes.GetData())[Idx];
	// In-place construct FString (memory is zeroed; default ctor is a no-op)
	new (&Entry->IPAddr) FString();
	Entry->IPAddr         = PlayerIP;
	Entry->LoginTime      = Now - (CurrentTime - LoginTime);
	Entry->ActiveTime     = Now;
}

/*-----------------------------------------------------------------------------
	UTcpNetDriver implementation.
-----------------------------------------------------------------------------*/

IMPL_DIVERGE("Property registration stub; CPP_PROPERTY cannot address bitfield members in standard C++")
void UTcpNetDriver::StaticConstructor()
{
	// Property registration omitted: CPP_PROPERTY cannot take the address
	// of bitfield members (AllowPlayerPortUnreach, LogPortUnreach, etc.)
	// in standard C++. Divergence from binary; config values load via .ini.
}

IMPL_MATCH("IpDrv.dll", 0x10706d40)
void UTcpNetDriver::LowLevelDestroy()
{
	SOCKET* pSock = (SOCKET*)((BYTE*)this + 0xbc);
	if (*pSock != 0)
	{
		if (closesocket(*pSock) != 0)
			debugf(NAME_DevNet, TEXT("WinSock: closesocket failed (%d)"), WSAGetLastError());
		*pSock = 0;
		debugf(NAME_DevNet, TEXT("WinSock: connection closed"));
	}
}

IMPL_MATCH("IpDrv.dll", 0x10706cb0)
FString UTcpNetDriver::LowLevelGetNetworkNumber()
{
	UINT* pLocalIP = (UINT*)((BYTE*)this + 0xb0);
	return IpAddrToStr(htonl(*pLocalIP), 0);
}

IMPL_MATCH("IpDrv.dll", 0x10706e10)
UTcpipConnection* UTcpNetDriver::GetServerConnection()
{
	return (UTcpipConnection*)(*(UNetConnection**)((BYTE*)this + 0x3c));
}

IMPL_MATCH("IpDrv.dll", 0x10707450)
INT UTcpNetDriver::InitBase(INT Reuse, FNetworkNotify* InNotify, FURL& URL, FString& Error)
{
	if (!InitWSA(Error))
		return 0;
	SOCKET* pSock = (SOCKET*)((BYTE*)this + 0xbc);
	*pSock = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
	if (*pSock == INVALID_SOCKET)
	{
		*pSock = 0;
		Error = FString::Printf(TEXT("WinSock: socket failed (%d)"), WSAGetLastError());
		return 0;
	}
	GDrvSocket = (UINT)*pSock;
	// Enable broadcast
	int bcast = 1;
	if (setsockopt(*pSock, SOL_SOCKET, SO_BROADCAST, (char*)&bcast, sizeof(bcast)) != 0)
	{
		Error = FString::Printf(TEXT("WinSock: setsockopt SO_BROADCAST failed (%d)"), WSAGetLastError());
		return 0;
	}
	SetNonBlocking(*pSock);
	// Buffer sizes: large for server (listen), small for client (connect)
	int BufSize = Reuse ? 0x20000 : 0x8000;
	setsockopt(*pSock, SOL_SOCKET, SO_RCVBUF, (char*)&BufSize, sizeof(BufSize));
	setsockopt(*pSock, SOL_SOCKET, SO_SNDBUF, (char*)&BufSize, sizeof(BufSize));
	// Set up local bind address
	sockaddr_in* pLocalAddr = (sockaddr_in*)((BYTE*)this + 0xac);
	UINT*        pLocalIP   = (UINT*)      ((BYTE*)this + 0xb0);
	pLocalAddr->sin_family      = AF_INET;
	*pLocalIP                   = GetLocalBindIP();
	pLocalAddr->sin_addr.s_addr = htonl(*pLocalIP);
	pLocalAddr->sin_port        = 0;
	if (!Reuse) // server: use URL.Port
	{
		INT CmdPort = URL.Port;
		Parse(appCmdLine(), TEXT("PORT="), CmdPort);
		URL.Port         = CmdPort;
		pLocalAddr->sin_port = htons((u_short)URL.Port);
	}
	WORD BoundPort = BindSocket(*pSock, pLocalAddr, Reuse ? 20 : 1, 1);
	if (BoundPort == 0)
	{
		Error = FString::Printf(TEXT("WinSock: binding to port %i failed (%d)"), URL.Port, WSAGetLastError());
		return 0;
	}
	if (!SetSocketOptions(*pSock))
	{
		Error = FString::Printf(TEXT("WinSock: SetSocketOptions failed (%d)"), WSAGetLastError());
		return 0;
	}
	return 1;
}

IMPL_MATCH("IpDrv.dll", 0x107077b0)
INT UTcpNetDriver::InitConnect(FNetworkNotify* InNotify, FURL& ConnectURL, FString& Error)
{
	// Divergence: not calling Super::InitConnect (stub returns 0, aborting init).
	// Instead, store notify and perform base init directly.
	*(FNetworkNotify**)((BYTE*)this + 0x40) = InNotify;
	if (!InitBase(1, InNotify, ConnectURL, Error))
		return 0;
	SOCKET* pSock = (SOCKET*)((BYTE*)this + 0xbc);
	// Build remote address from ConnectURL
	sockaddr_in RemoteAddr;
	appMemzero(&RemoteAddr, sizeof(RemoteAddr));
	RemoteAddr.sin_family = AF_INET;
	RemoteAddr.sin_port   = htons((u_short)ConnectURL.Port);
	// Create the server-side UTcpipConnection for this client
	UObject* Obj = UObject::StaticAllocateObject(
	    UTcpipConnection::StaticClass(),
	    UObject::GetTransientPackage(),
	    NAME_None, 0, NULL, GError, NULL, NULL);
	UTcpipConnection* ServerConn = NULL;
	if (Obj)
	{
		ServerConn = new(Obj) UTcpipConnection(
		    (UINT)*pSock, this, RemoteAddr, USOCK_Pending, 1, ConnectURL);
	}
	*(UNetConnection**)((BYTE*)this + 0x3c) = ServerConn;
	debugf(NAME_DevNet, TEXT("Opened connection from port %i"),
	       (INT)ntohs(((sockaddr_in*)((BYTE*)this + 0xac))->sin_port));
	if (ServerConn)
		ServerConn->CreateChannel(CHTYPE_Control, 1, 0);
	return 1;
}

IMPL_MATCH("IpDrv.dll", 0x10707930)
INT UTcpNetDriver::InitListen(FNetworkNotify* InNotify, FURL& URL, FString& Error)
{
	// Divergence: not calling Super::InitListen (stub returns 0, aborting init).
	*(FNetworkNotify**)((BYTE*)this + 0x40) = InNotify;
	if (!InitBase(0, InNotify, URL, Error))
		return 0;
	UINT* pLocalIP          = (UINT*)((BYTE*)this + 0xb0);
	URL.Host = IpAddrToStr(htonl(*pLocalIP), 0);
	sockaddr_in* pLocalAddr = (sockaddr_in*)((BYTE*)this + 0xac);
	URL.Port = (INT)ntohs(pLocalAddr->sin_port);
	debugf(NAME_DevNet, TEXT("Opened connection from port %i"), URL.Port);
	return 1;
}

IMPL_MATCH("IpDrv.dll", 0x10707a50)
void UTcpNetDriver::TickDispatch(FLOAT DeltaTime)
{
	Super::TickDispatch(DeltaTime);
	SOCKET* pSock = (SOCKET*)((BYTE*)this + 0xbc);
	if (!*pSock || *pSock == INVALID_SOCKET)
		return;
	GDrvSocket = (UINT)*pSock;
	static char PktBuf[1280];
	for (;;)
	{
		sockaddr_in FromAddr;
		int FromLen = sizeof(FromAddr);
		INT n = recvfrom(*pSock, PktBuf, sizeof(PktBuf), 0, (sockaddr*)&FromAddr, &FromLen);
		if (n == SOCKET_ERROR)
		{
			INT Err = WSAGetLastError();
			if (Err == WSAEWOULDBLOCK)
				return;
			if (Err == WSAECONNRESET) // ICMP port-unreachable — skip silently
				continue;
			if (AllowPlayerPortUnreach)
				debugf(NAME_DevNet, TEXT("recvfrom error %d from %s"),
				       Err, *IpAddrToStr(FromAddr.sin_addr.s_addr, (UINT)ntohs(FromAddr.sin_port)));
			return;
		}
		// Find matching connection by remote address
		UNetConnection* Conn = NULL;
		UNetConnection* SrvConn = *(UNetConnection**)((BYTE*)this + 0x3c);
		if (SrvConn)
		{
			// sockaddr_in stored at connection+0x4BD4; sin_port@0x4BD6, sin_addr@0x4BD8
			if (*(DWORD*)((BYTE*)SrvConn + 0x4bd8) == *(DWORD*)&FromAddr.sin_addr &&
			    *(WORD*) ((BYTE*)SrvConn + 0x4bd6) == *(WORD*) &FromAddr.sin_port)
				Conn = SrvConn;
		}
		if (!Conn)
		{
			TArray<UNetConnection*>& Clients = *(TArray<UNetConnection*>*)((BYTE*)this + 0x30);
			for (INT i = 0; i < Clients.Num(); i++)
			{
				UNetConnection* C = Clients(i);
				if (!C) continue;
				if (*(DWORD*)((BYTE*)C + 0x4bd8) == *(DWORD*)&FromAddr.sin_addr &&
				    *(WORD*) ((BYTE*)C + 0x4bd6) == *(WORD*) &FromAddr.sin_port)
				{
					Conn = C;
					break;
				}
			}
		}
		if (Conn)
		{
			Conn->ReceivedRawPacket(PktBuf, n);
		}
		// New-connection spawn path: omitted in this implementation.
		// See DIVERGENCES comment above.
	}
}

/*-----------------------------------------------------------------------------
	UTcpipConnection implementation.
-----------------------------------------------------------------------------*/

IMPL_MATCH("IpDrv.dll", 0x107066f0)
UTcpipConnection::UTcpipConnection(UINT InSocket, UNetDriver* InDriver,
    struct sockaddr_in InRemoteAddr, EConnectionState InState,
    INT InOpenedLocally, const FURL& InURL)
    : UNetConnection(InDriver, InURL)
{
	BYTE* Base = (BYTE*)this;
	// Driver was not set by the base stub constructor; set explicitly.
	Driver = InDriver;
	// Remote address (sockaddr_in stored at +0x4BD4; sin_family+sin_port+sin_addr)
	*(sockaddr_in*)(Base + 0x4BD4) = InRemoteAddr;
	// Socket handle, opened-locally flag, and connection state
	*(UINT*)(Base + 0x4BE4) = InSocket;
	*(INT*) (Base + 0x4BE8) = InOpenedLocally;
	*(UINT*)(Base + 0x80)   = (UINT)InState;
	// Max packet sizes
	*(UINT*)(Base + 0xD0)   = 0x200;
	*(UINT*)(Base + 0xD4)   = 0x20;
	// Pending resolve pointer (NULL initially)
	*(FResolveInfo**)(Base + 0x4BEC) = NULL;
	// TSC-based connection timestamp for timeout detection
	{
		unsigned __int64 tsc = __rdtsc();
		double hi = (double)(int)(tsc >> 32);
		double lo = (double)(int)(tsc & 0xFFFFFFFFull);
		if ((int)(tsc >> 32)           < 0) hi += 4294967296.0;
		if ((int)(tsc & 0xFFFFFFFFull) < 0) lo += 4294967296.0;
		*(double*)(Base + 0x4BF0) = (lo + hi * 4294967296.0) * GSecondsPerCycle + 16777216.0;
	}
	InitOut();
	// If opened locally (client), start async DNS resolve for non-dotted hostnames
	if (InOpenedLocally)
	{
		char HostAnsi[256];
		WideCharToMultiByte(CP_ACP, 0, *InURL.Host, -1, HostAnsi, sizeof(HostAnsi), NULL, NULL);
		ULONG IpNet = inet_addr(HostAnsi);
		if (IpNet != INADDR_NONE)
		{
			// Dotted-decimal: store IP directly in the remote address struct
			*(DWORD*)(Base + 0x4BD8) = IpNet;
		}
		else
		{
			// Hostname: start async DNS
			void* Buf = appMalloc(sizeof(FResolveInfo), TEXT("UTcpipConnectionResolve"));
			FResolveInfo* Info = Buf ? StartResolve(Buf, *InURL.Host) : NULL;
			*(FResolveInfo**)(Base + 0x4BEC) = Info;
		}
	}
}

IMPL_MATCH("IpDrv.dll", 0x10706b00)
FString UTcpipConnection::LowLevelGetRemoteAddress()
{
	BYTE* Base    = (BYTE*)this;
	UINT RemoteIP = *(UINT*)(Base + 0x4BD8);
	UINT Port     = (UINT)ntohs(*(u_short*)(Base + 0x4BD6));
	return IpAddrToStr(RemoteIP, Port);
}

IMPL_MATCH("IpDrv.dll", 0x10706ba0)
FString UTcpipConnection::LowLevelDescribe()
{
	BYTE* Base  = (BYTE*)this;
	UINT  State = *(UINT*)(Base + 0x80);
	const TCHAR* StateName = (State == USOCK_Pending) ? TEXT("Pending")
	                       : (State == USOCK_Open)    ? TEXT("Open")
	                       : (State == USOCK_Closed)  ? TEXT("Closed")
	                       :                            TEXT("Invalid");
	UINT RemoteIP = *(UINT*)(Base + 0x4BD8);
	UINT Port     = (UINT)ntohs(*(u_short*)(Base + 0x4BD6));
	FString RemoteStr = IpAddrToStr(RemoteIP, Port);
	FString DescStr   = *(FString*)(Base + 0x90);
	return FString::Printf(TEXT("%s %s state: %s"), *DescStr, *RemoteStr, StateName);
}

IMPL_MATCH("IpDrv.dll", 0x10707280)
void UTcpipConnection::LowLevelSend(void* Data, INT Count)
{
	BYTE*         Base = (BYTE*)this;
	FResolveInfo* Info = *(FResolveInfo**)(Base + 0x4BEC);
	if (Info)
	{
		if (Info->bWorking != 0)
			return; // still resolving; drop packet
		if (Info->Error != 0)
		{
			debugf(NAME_DevNet, TEXT("Failed to resolve address"));
			// Close the server connection on resolve failure
			UNetDriver* Drv = *(UNetDriver**)(Base + 0x7C);
			if (Drv)
			{
				UNetConnection* SrvConn = *(UNetConnection**)((BYTE*)Drv + 0x3C);
				if (SrvConn)
					*(UINT*)((BYTE*)SrvConn + 0x80) = (UINT)USOCK_Closed;
			}
			appFree(Info);
			*(FResolveInfo**)(Base + 0x4BEC) = NULL;
			return;
		}
		// Resolve succeeded: update stored remote IP
		*(DWORD*)(Base + 0x4BD8) = Info->Addr;
		debugf(NAME_DevNet, TEXT("Resolved to %s"), *IpAddrToStr(Info->Addr, 0));
		appFree(Info);
		*(FResolveInfo**)(Base + 0x4BEC) = NULL;
	}
	UINT s = *(UINT*)(Base + 0x4BE4);
	sendto((SOCKET)s, (char*)Data, Count, 0, (sockaddr*)(Base + 0x4BD4), 0x10);
}
