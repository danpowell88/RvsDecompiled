//=============================================================================
// InternetLink - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// InternetLink: Parent class for Internet connection classes
//=============================================================================
class InternetLink extends InternetInfo
    transient
    native
    hidecategories(Movement,Collision,Lighting,LightColor,Karma,Force);

enum ELinkMode
{
	MODE_Text,                      // 0
	MODE_Line,                      // 1
	MODE_Binary                     // 2
};

enum EReceiveMode
{
	RMODE_Manual,                   // 0
	RMODE_Event                     // 1
};

struct IpAddr
{
	var int Addr;
	var int Port;
};

// NEW IN 1.60
var InternetLink.ELinkMode LinkMode;
// NEW IN 1.60
var InternetLink.EReceiveMode ReceiveMode;
// Internal
var const int Socket;
var const int Port;
var const int RemoteSocket;
var private native const int PrivateResolveInfo;
var const int DataPending;

// Export UInternetLink::execIsDataPending(FFrame&, void* const)
// Returns true if data is pending on the socket.
native function bool IsDataPending();

// Export UInternetLink::execParseURL(FFrame&, void* const)
// NEW IN 1.60
native function bool ParseURL(coerce string URL, out string Addr, out int Port, out string LevelName, out string EntryName);

// Export UInternetLink::execResolve(FFrame&, void* const)
// Resolve a domain or dotted IP.
// Nonblocking operation.  
// Triggers Resolved event if successful.
// Triggers ResolveFailed event if unsuccessful.
native function Resolve(coerce string Domain);

// Export UInternetLink::execGetLastError(FFrame&, void* const)
// Returns most recent winsock error.
native function int GetLastError();

// Export UInternetLink::execIpAddrToString(FFrame&, void* const)
// Convert an IP address to a string.
native function string IpAddrToString(IpAddr Arg);

// Export UInternetLink::execStringToIpAddr(FFrame&, void* const)
// Convert a string to an IP
native function bool StringToIpAddr(string Str, out IpAddr Addr);

// Export UInternetLink::execValidate(FFrame&, void* const)
// Validate: Takes a challenge string and returns an encoded validation string.
native function string Validate(string ValidationString, string GameName);

// Export UInternetLink::execGetLocalIP(FFrame&, void* const)
native function GetLocalIP(out IpAddr Arg);

// Called when domain resolution is successful.
// The IpAddr struct Addr contains the valid address.
event Resolved(IpAddr Addr)
{
	return;
}

// Called when domain resolution fails.
event ResolveFailed()
{
	return;
}


// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var ELinkMode
// REMOVED IN 1.60: var EReceiveMode
