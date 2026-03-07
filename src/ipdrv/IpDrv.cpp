/*=============================================================================
	IpDrv.cpp: IpDrv package — TCP/IP networking driver.
	Reconstructed for Ravenshield decompilation project.
=============================================================================*/

#include "IpDrvPrivate.h"

/*-----------------------------------------------------------------------------
	Package.
-----------------------------------------------------------------------------*/

IMPLEMENT_PACKAGE(IpDrv)

/*-----------------------------------------------------------------------------
	FName event/callback tokens.
-----------------------------------------------------------------------------*/

#define NAMES_ONLY
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
	AInternetLink implementation.
-----------------------------------------------------------------------------*/

void AInternetLink::Destroy()
{
	Super::Destroy();
}

INT AInternetLink::Tick(FLOAT DeltaTime, enum ELevelTick TickType)
{
	return Super::Tick(DeltaTime, TickType);
}

FResolveInfo*& AInternetLink::GetResolveInfo()
{
	return *(FResolveInfo**)&PrivateResolveInfo;
}

UINT& AInternetLink::GetSocket()
{
	return *(UINT*)&Socket;
}

void AInternetLink::eventResolveFailed()
{
	ProcessEvent(FindFunctionChecked(IPDRV_ResolveFailed), NULL);
}

void AInternetLink::eventResolved(FIpAddr Addr)
{
	struct { FIpAddr Addr; } Parms;
	Parms.Addr = Addr;
	ProcessEvent(FindFunctionChecked(IPDRV_Resolved), &Parms);
}

void AInternetLink::execGetLastError(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
	*(INT*)Result = 0;
}

void AInternetLink::execGetLocalIP(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void AInternetLink::execIpAddrToString(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
	*(FString*)Result = TEXT("");
}

void AInternetLink::execIsDataPending(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
	*(DWORD*)Result = 0;
}

void AInternetLink::execParseURL(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
	*(DWORD*)Result = 0;
}

void AInternetLink::execResolve(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void AInternetLink::execStringToIpAddr(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
	*(DWORD*)Result = 0;
}

void AInternetLink::execValidate(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
	*(FString*)Result = TEXT("");
}

/*-----------------------------------------------------------------------------
	ATcpLink implementation.
-----------------------------------------------------------------------------*/

INT ATcpLink::Tick(FLOAT DeltaTime, enum ELevelTick TickType)
{
	return Super::Tick(DeltaTime, TickType);
}

void ATcpLink::PostScriptDestroyed()
{
}

void ATcpLink::CheckConnectionAttempt()
{
}

void ATcpLink::CheckConnectionQueue()
{
}

INT ATcpLink::FlushSendBuffer()
{
	return 0;
}

void ATcpLink::PollConnections()
{
}

void ATcpLink::ShutdownConnection()
{
}

void ATcpLink::eventAccepted()
{
	ProcessEvent(FindFunctionChecked(IPDRV_Accepted), NULL);
}

void ATcpLink::eventClosed()
{
	ProcessEvent(FindFunctionChecked(IPDRV_Closed), NULL);
}

void ATcpLink::eventOpened()
{
	ProcessEvent(FindFunctionChecked(IPDRV_Opened), NULL);
}

void ATcpLink::eventReceivedBinary(INT Count, BYTE* B)
{
	struct { INT Count; BYTE B[255]; } Parms;
	Parms.Count = Count;
	if(B) appMemcpy(Parms.B, B, Min(Count, 255));
	ProcessEvent(FindFunctionChecked(IPDRV_ReceivedBinary), &Parms);
}

void ATcpLink::eventReceivedLine(const FString& Line)
{
	struct { FString Line; } Parms;
	Parms.Line = Line;
	ProcessEvent(FindFunctionChecked(IPDRV_ReceivedLine), &Parms);
}

void ATcpLink::eventReceivedText(const FString& Text)
{
	struct { FString Text; } Parms;
	Parms.Text = Text;
	ProcessEvent(FindFunctionChecked(IPDRV_ReceivedText), &Parms);
}

void ATcpLink::execBindPort(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
	*(INT*)Result = 0;
}

void ATcpLink::execClose(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
	*(DWORD*)Result = 0;
}

void ATcpLink::execIsConnected(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
	*(DWORD*)Result = 0;
}

void ATcpLink::execListen(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
	*(DWORD*)Result = 0;
}

void ATcpLink::execOpen(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
	*(DWORD*)Result = 0;
}

void ATcpLink::execReadBinary(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
	*(INT*)Result = 0;
}

void ATcpLink::execReadText(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
	*(INT*)Result = 0;
}

void ATcpLink::execSendBinary(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
	*(INT*)Result = 0;
}

void ATcpLink::execSendText(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
	*(INT*)Result = 0;
}

/*-----------------------------------------------------------------------------
	AUdpLink implementation.
-----------------------------------------------------------------------------*/

INT AUdpLink::Tick(FLOAT DeltaTime, enum ELevelTick TickType)
{
	return Super::Tick(DeltaTime, TickType);
}

void AUdpLink::PostScriptDestroyed()
{
}

void AUdpLink::eventReceivedBinary(FIpAddr Addr, INT Count, BYTE* B)
{
	struct { FIpAddr Addr; INT Count; BYTE B[255]; } Parms;
	Parms.Addr = Addr;
	Parms.Count = Count;
	if(B) appMemcpy(Parms.B, B, Min(Count, 255));
	ProcessEvent(FindFunctionChecked(IPDRV_ReceivedBinary), &Parms);
}

void AUdpLink::eventReceivedLine(FIpAddr Addr, const FString& Line)
{
	struct { FIpAddr Addr; FString Line; } Parms;
	Parms.Addr = Addr;
	Parms.Line = Line;
	ProcessEvent(FindFunctionChecked(IPDRV_ReceivedLine), &Parms);
}

void AUdpLink::eventReceivedText(FIpAddr Addr, const FString& Text)
{
	struct { FIpAddr Addr; FString Text; } Parms;
	Parms.Addr = Addr;
	Parms.Text = Text;
	ProcessEvent(FindFunctionChecked(IPDRV_ReceivedText), &Parms);
}

void AUdpLink::execBindPort(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
	*(INT*)Result = 0;
}

void AUdpLink::execCheckForPlayerTimeouts(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void AUdpLink::execGetMaxAvailPorts(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
	*(INT*)Result = 0;
}

void AUdpLink::execGetPlayingTime(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
	*(FLOAT*)Result = 0.0f;
}

void AUdpLink::execReadBinary(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
	*(INT*)Result = 0;
}

void AUdpLink::execReadText(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
	*(INT*)Result = 0;
}

void AUdpLink::execSendBinary(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
	*(DWORD*)Result = 0;
}

void AUdpLink::execSendText(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
	*(DWORD*)Result = 0;
}

void AUdpLink::execSetPlayingTime(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

/*-----------------------------------------------------------------------------
	UTcpNetDriver implementation.
-----------------------------------------------------------------------------*/

void UTcpNetDriver::StaticConstructor()
{
}

void UTcpNetDriver::LowLevelDestroy()
{
}

FString UTcpNetDriver::LowLevelGetNetworkNumber()
{
	return TEXT("");
}

INT UTcpNetDriver::InitConnect(FNetworkNotify* InNotify, FURL& ConnectURL, FString& Error)
{
	return 0;
}

INT UTcpNetDriver::InitListen(FNetworkNotify* InNotify, FURL& URL, FString& Error)
{
	return 0;
}

void UTcpNetDriver::TickDispatch(FLOAT DeltaTime)
{
}

UTcpipConnection* UTcpNetDriver::GetServerConnection()
{
	return NULL;
}

INT UTcpNetDriver::InitBase(INT Reuse, FNetworkNotify* InNotify, FURL& URL, FString& Error)
{
	return 0;
}

/*-----------------------------------------------------------------------------
	UTcpipConnection implementation.
-----------------------------------------------------------------------------*/

UTcpipConnection::UTcpipConnection(UINT InSocket, UNetDriver* InDriver, struct sockaddr_in InRemoteAddr, EConnectionState InState, INT InOpenedLocally, const FURL& InURL)
{
}

FString UTcpipConnection::LowLevelGetRemoteAddress()
{
	return TEXT("");
}

FString UTcpipConnection::LowLevelDescribe()
{
	return TEXT("");
}

void UTcpipConnection::LowLevelSend(void* Data, INT Count)
{
}
