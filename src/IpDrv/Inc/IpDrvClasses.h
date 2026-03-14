/*=============================================================================
	IpDrvClasses.h: IpDrv class declarations.
	Reconstructed from Ravenshield 1.56 SDK and Ghidra analysis.
=============================================================================*/

#if _MSC_VER
#pragma pack(push, 4)
#endif

#ifndef IPDRV_API
#define IPDRV_API DLL_IMPORT
#endif

/*==========================================================================
	AUTOGENERATE_NAME / AUTOGENERATE_FUNCTION entries.
==========================================================================*/

#ifndef NAMES_ONLY
#undef  AUTOGENERATE_NAME
#undef  AUTOGENERATE_FUNCTION
#define AUTOGENERATE_NAME(name) extern IPDRV_API FName IPDRV_##name;
#define AUTOGENERATE_FUNCTION(cls,idx,name)
#endif

AUTOGENERATE_NAME(Accepted)
AUTOGENERATE_NAME(Closed)
AUTOGENERATE_NAME(Opened)
AUTOGENERATE_NAME(ReceivedBinary)
AUTOGENERATE_NAME(ReceivedLine)
AUTOGENERATE_NAME(ReceivedText)
AUTOGENERATE_NAME(ResolveFailed)
AUTOGENERATE_NAME(Resolved)

#ifndef NAMES_ONLY

/*==========================================================================
	Enums.
==========================================================================*/

enum EReceiveMode
{
	RMODE_Manual = 0,
	RMODE_Event  = 1,
};

enum ELinkMode
{
	MODE_Text   = 0,
	MODE_Line   = 1,
	MODE_Binary = 2,
};

enum ELinkState
{
	STATE_Initialized        = 0,
	STATE_Ready              = 1,
	STATE_Listening          = 2,
	STATE_Connecting         = 3,
	STATE_Connected          = 4,
	STATE_ListenClosePending = 5,
	STATE_ConnectClosePending= 6,
	STATE_ListenClosing      = 7,
	STATE_ConnectClosing     = 8,
};

/*==========================================================================
	FIpAddr — Unreal networking IP address struct.
	Mirrors the UnrealScript IpAddr struct (two ints: Addr + Port).
==========================================================================*/

struct FIpAddr
{
	INT Addr;
	INT Port;
};

/*==========================================================================
	AInternetLink
==========================================================================*/

class IPDRV_API AInternetLink : public AInternetInfo
{
public:
	DECLARE_CLASS(AInternetLink, AInternetInfo, CLASS_Transient, IpDrv)

	BYTE  LinkMode;          // ELinkMode
	BYTE  ReceiveMode;       // EReceiveMode
	INT   Socket;
	INT   Port;
	INT   RemoteSocket;
	INT   PrivateResolveInfo;
	INT   DataPending;

	// UObject interface.
	void Destroy();
	INT Tick(FLOAT DeltaTime, enum ELevelTick TickType);

	// AInternetLink interface.
	FResolveInfo*& GetResolveInfo();
	UINT& GetSocket();

	// Script events.
	void eventResolveFailed();
	void eventResolved(FIpAddr Addr);

	// Native exec stubs.
	void execGetLastError(FFrame& Stack, RESULT_DECL);
	void execGetLocalIP(FFrame& Stack, RESULT_DECL);
	void execIpAddrToString(FFrame& Stack, RESULT_DECL);
	void execIsDataPending(FFrame& Stack, RESULT_DECL);
	void execParseURL(FFrame& Stack, RESULT_DECL);
	void execResolve(FFrame& Stack, RESULT_DECL);
	void execStringToIpAddr(FFrame& Stack, RESULT_DECL);
	void execValidate(FFrame& Stack, RESULT_DECL);
};

/*==========================================================================
	ATcpLink
==========================================================================*/

class IPDRV_API ATcpLink : public AInternetLink
{
public:
	DECLARE_CLASS(ATcpLink, AInternetLink, CLASS_Transient, IpDrv)

	BYTE           LinkState;    // ELinkState
	UClass*        AcceptClass;
	TArray<BYTE>   SendFIFO;
	FIpAddr        RemoteAddr;

	// UObject interface.
	INT Tick(FLOAT DeltaTime, enum ELevelTick TickType);
	virtual void PostScriptDestroyed();

	// ATcpLink interface.
	void CheckConnectionAttempt();
	void CheckConnectionQueue();
	INT  FlushSendBuffer();
	void PollConnections();
	void ShutdownConnection();

	// Script events.
	void eventAccepted();
	void eventClosed();
	void eventOpened();
	void eventReceivedBinary(INT Count, BYTE* B);
	void eventReceivedLine(const FString& Line);
	void eventReceivedText(const FString& Text);

	// Native exec stubs.
	void execBindPort(FFrame& Stack, RESULT_DECL);
	void execClose(FFrame& Stack, RESULT_DECL);
	void execIsConnected(FFrame& Stack, RESULT_DECL);
	void execListen(FFrame& Stack, RESULT_DECL);
	void execOpen(FFrame& Stack, RESULT_DECL);
	void execReadBinary(FFrame& Stack, RESULT_DECL);
	void execReadText(FFrame& Stack, RESULT_DECL);
	void execSendBinary(FFrame& Stack, RESULT_DECL);
	void execSendText(FFrame& Stack, RESULT_DECL);
};

/*==========================================================================
	AUdpLink
==========================================================================*/

class IPDRV_API AUdpLink : public AInternetLink
{
public:
	DECLARE_CLASS(AUdpLink, AInternetLink, CLASS_Transient, IpDrv)

	INT BroadcastAddr;

	// UObject interface.
	INT Tick(FLOAT DeltaTime, enum ELevelTick TickType);
	virtual void PostScriptDestroyed();

	// Script events.
	void eventReceivedBinary(FIpAddr Addr, INT Count, BYTE* B);
	void eventReceivedLine(FIpAddr Addr, const FString& Line);
	void eventReceivedText(FIpAddr Addr, const FString& Text);

	// Native exec stubs.
	void execBindPort(FFrame& Stack, RESULT_DECL);
	void execCheckForPlayerTimeouts(FFrame& Stack, RESULT_DECL);
	void execGetMaxAvailPorts(FFrame& Stack, RESULT_DECL);
	void execGetPlayingTime(FFrame& Stack, RESULT_DECL);
	void execReadBinary(FFrame& Stack, RESULT_DECL);
	void execReadText(FFrame& Stack, RESULT_DECL);
	void execSendBinary(FFrame& Stack, RESULT_DECL);
	void execSendText(FFrame& Stack, RESULT_DECL);
	void execSetPlayingTime(FFrame& Stack, RESULT_DECL);
};

/*==========================================================================
	UTcpNetDriver
==========================================================================*/

class UTcpipConnection;

class IPDRV_API UTcpNetDriver : public UNetDriver
{
public:
	DECLARE_CLASS(UTcpNetDriver, UNetDriver, CLASS_Transient, IpDrv)

	BITFIELD AllowPlayerPortUnreach : 1;
	BITFIELD LogPortUnreach : 1;
	INT      MaxConnPerIPPerMinute;
	BITFIELD LogMaxConnPerIPPerMin : 1;

	// UNetDriver interface.
	virtual void LowLevelDestroy();
	virtual FString LowLevelGetNetworkNumber();
	virtual INT InitConnect(FNetworkNotify* InNotify, FURL& ConnectURL, FString& Error);
	virtual INT InitListen(FNetworkNotify* InNotify, FURL& URL, FString& Error);
	virtual void TickDispatch(FLOAT DeltaTime);

	// UTcpNetDriver interface.
	UTcpipConnection* GetServerConnection();
	INT InitBase(INT Reuse, FNetworkNotify* InNotify, FURL& URL, FString& Error);
	void StaticConstructor();
};

/*==========================================================================
	UTcpipConnection
==========================================================================*/

class IPDRV_API UTcpipConnection : public UNetConnection
{
public:
	DECLARE_CLASS(UTcpipConnection, UNetConnection, CLASS_Transient, IpDrv)

	// UNetConnection interface.
	virtual FString LowLevelGetRemoteAddress();
	virtual FString LowLevelDescribe();
	virtual void LowLevelSend(void* Data, INT Count);

	// Constructors.
	UTcpipConnection(UINT InSocket, UNetDriver* InDriver, struct sockaddr_in InRemoteAddr, EConnectionState InState, INT InOpenedLocally, const FURL& InURL);

	NO_DEFAULT_CONSTRUCTOR(UTcpipConnection)
};

/*==========================================================================
	UHTTPDownload
==========================================================================*/

class IPDRV_API UHTTPDownload : public UDownload
{
public:
	DECLARE_CLASS(UHTTPDownload, UDownload, CLASS_Transient | CLASS_Config, IpDrv)

	FString RedirectToURL;
	BITFIELD UseCompression : 1;
	BYTE    Unknown3[0x0410];
	FString ProxyServerHost;
	INT     ProxyServerPort;
};

/*==========================================================================
	Commandlets — simple empty classes, only autoclass pointers exported.
==========================================================================*/

class IPDRV_API UCompressCommandlet : public UCommandlet
{
public:
	DECLARE_CLASS(UCompressCommandlet, UCommandlet, CLASS_Transient, IpDrv)
};

class IPDRV_API UDecompressCommandlet : public UCommandlet
{
public:
	DECLARE_CLASS(UDecompressCommandlet, UCommandlet, CLASS_Transient, IpDrv)
};

class IPDRV_API UMasterServerCommandlet : public UCommandlet
{
public:
	DECLARE_CLASS(UMasterServerCommandlet, UCommandlet, CLASS_Transient, IpDrv)
};

class IPDRV_API UUpdateServerCommandlet : public UCommandlet
{
public:
	DECLARE_CLASS(UUpdateServerCommandlet, UCommandlet, CLASS_Transient, IpDrv)
};

/*==========================================================================
	AUTOGENERATE_FUNCTION entries — native exec function registration.
	Index from .uc source: only GetMaxAvailPorts has explicit native(1221).
	All others use INDEX_NONE for auto-registration by name.
==========================================================================*/

AUTOGENERATE_FUNCTION(AInternetLink, INDEX_NONE, execGetLastError)
AUTOGENERATE_FUNCTION(AInternetLink, INDEX_NONE, execGetLocalIP)
AUTOGENERATE_FUNCTION(AInternetLink, INDEX_NONE, execIpAddrToString)
AUTOGENERATE_FUNCTION(AInternetLink, INDEX_NONE, execIsDataPending)
AUTOGENERATE_FUNCTION(AInternetLink, INDEX_NONE, execParseURL)
AUTOGENERATE_FUNCTION(AInternetLink, INDEX_NONE, execResolve)
AUTOGENERATE_FUNCTION(AInternetLink, INDEX_NONE, execStringToIpAddr)
AUTOGENERATE_FUNCTION(AInternetLink, INDEX_NONE, execValidate)

AUTOGENERATE_FUNCTION(ATcpLink, INDEX_NONE, execBindPort)
AUTOGENERATE_FUNCTION(ATcpLink, INDEX_NONE, execClose)
AUTOGENERATE_FUNCTION(ATcpLink, INDEX_NONE, execIsConnected)
AUTOGENERATE_FUNCTION(ATcpLink, INDEX_NONE, execListen)
AUTOGENERATE_FUNCTION(ATcpLink, INDEX_NONE, execOpen)
AUTOGENERATE_FUNCTION(ATcpLink, INDEX_NONE, execReadBinary)
AUTOGENERATE_FUNCTION(ATcpLink, INDEX_NONE, execReadText)
AUTOGENERATE_FUNCTION(ATcpLink, INDEX_NONE, execSendBinary)
AUTOGENERATE_FUNCTION(ATcpLink, INDEX_NONE, execSendText)

AUTOGENERATE_FUNCTION(AUdpLink, INDEX_NONE, execBindPort)
AUTOGENERATE_FUNCTION(AUdpLink, INDEX_NONE, execCheckForPlayerTimeouts)
AUTOGENERATE_FUNCTION(AUdpLink, 1221,       execGetMaxAvailPorts)
AUTOGENERATE_FUNCTION(AUdpLink, INDEX_NONE, execGetPlayingTime)
AUTOGENERATE_FUNCTION(AUdpLink, INDEX_NONE, execReadBinary)
AUTOGENERATE_FUNCTION(AUdpLink, INDEX_NONE, execReadText)
AUTOGENERATE_FUNCTION(AUdpLink, INDEX_NONE, execSendBinary)
AUTOGENERATE_FUNCTION(AUdpLink, INDEX_NONE, execSendText)
AUTOGENERATE_FUNCTION(AUdpLink, INDEX_NONE, execSetPlayingTime)

#endif // NAMES_ONLY

#undef AUTOGENERATE_NAME
#undef AUTOGENERATE_FUNCTION

#if _MSC_VER
#pragma pack(pop)
#endif
