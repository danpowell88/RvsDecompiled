//=============================================================================
// InternetLink: Parent class for Internet connection classes
//=============================================================================
class InternetLink extends InternetInfo
    native
    transient;

// --- Enums ---
enum ELinkMode
{
    // enum values not recoverable from binary — see 1.56 source
};
enum EReceiveMode
{
    // enum values not recoverable from binary — see 1.56 source
};

// --- Structs ---
struct IpAddr
{
	var int Addr;
	var int Port;
};

// --- Variables ---
// var ? Addr; // REMOVED IN 1.60
var EReceiveMode ReceiveMode;
// ^ NEW IN 1.60
var const int DataPending;
var native const int PrivateResolveInfo;
var const int RemoteSocket;
var const int Port;
// Internal
var const int Socket;
var ELinkMode LinkMode;
// ^ NEW IN 1.60

// --- Functions ---
// Validate: Takes a challenge string and returns an encoded validation string.
native function string Validate(string ValidationString, string GameName) {}
// ^ NEW IN 1.60
native function GetLocalIP(out IpAddr Arg) {}
// Convert a string to an IP
native function bool StringToIpAddr(string Str, out IpAddr Addr) {}
// ^ NEW IN 1.60
// Convert an IP address to a string.
native function string IpAddrToString(IpAddr Arg) {}
// ^ NEW IN 1.60
// Resolve a domain or dotted IP.
// Nonblocking operation.
// Triggers Resolved event if successful.
// Triggers ResolveFailed event if unsuccessful.
native function Resolve(coerce string Domain) {}
native function bool ParseURL(coerce string URL, out string Addr, out int Port, out string LevelName, out string EntryName) {}
// ^ NEW IN 1.60
// Called when domain resolution fails.
event ResolveFailed() {}
// Called when domain resolution is successful.
// The IpAddr struct Addr contains the valid address.
event Resolved(IpAddr Addr) {}
// Returns most recent winsock error.
native function int GetLastError() {}
// ^ NEW IN 1.60
// Returns true if data is pending on the socket.
native function bool IsDataPending() {}
// ^ NEW IN 1.60

defaultproperties
{
}
