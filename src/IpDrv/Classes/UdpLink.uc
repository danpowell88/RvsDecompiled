//=============================================================================
// UdpLink: An Internet UDP connectionless socket.
//=============================================================================
class UdpLink extends InternetLink
    native
    transient;

// --- Variables ---
var const int BroadcastAddr;

// --- Functions ---
// ReceivedText: Called when data is received and connection mode is MODE_Text.
event ReceivedText(string Text, IpAddr Addr) {}
//#ifdef R6CODE // added by John Bennett - May 2002
native function float GetPlayingTime(string szIPAddr) {}
// ^ NEW IN 1.60
native function SetPlayingTime(float fCurrentTime, float fLoginTime, string szIPAddr) {}
// BindPort: Binds a free port or optional port specified in argument one.
native function int BindPort(out optional string szLocalBoundIpAddress, optional bool bUseNextAvailable, optional int Port) {}
// ^ NEW IN 1.60
// SendText: Sends text string.
// Appends a cr/lf if LinkMode=MODE_Line .
native function bool SendText(coerce string Str, IpAddr Addr) {}
// ^ NEW IN 1.60
// SendBinary: Send data as a byte array.
native function bool SendBinary(byte B, int Count, IpAddr Addr) {}
// ^ NEW IN 1.60
// ReadText: Reads text string.
// Returns number of bytes read.
native function int ReadText(out string Str, out IpAddr Addr) {}
// ^ NEW IN 1.60
// ReadBinary: Read data as a byte array.
native function int ReadBinary(out byte B, int Count, out IpAddr Addr) {}
// ^ NEW IN 1.60
// ReceivedBinary: Called when data is received and connection mode is MODE_Binary.
event ReceivedBinary(byte B, int Count, IpAddr Addr) {}
// ReceivedLine: Called when data is received and connection mode is MODE_Line.
event ReceivedLine(string Line, IpAddr Addr) {}
static final native function int GetMaxAvailPorts() {}
// ^ NEW IN 1.60
native function CheckForPlayerTimeouts() {}

defaultproperties
{
}
