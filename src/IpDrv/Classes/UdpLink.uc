//=============================================================================
// UdpLink - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
// UdpLink: An Internet UDP connectionless socket.
//=============================================================================
class UdpLink extends InternetLink
    transient
    native
    hidecategories(Movement,Collision,Lighting,LightColor,Karma,Force);

var() const int BroadcastAddr;

// Export UUdpLink::execGetPlayingTime(FFrame&, void* const)
//#ifdef R6CODE // added by John Bennett - May 2002
native function float GetPlayingTime(string szIPAddr);

// Export UUdpLink::execSetPlayingTime(FFrame&, void* const)
native function SetPlayingTime(string szIPAddr, float fLoginTime, float fCurrentTime);

// Export UUdpLink::execCheckForPlayerTimeouts(FFrame&, void* const)
native function CheckForPlayerTimeouts();

// Export UUdpLink::execGetMaxAvailPorts(FFrame&, void* const)
native(1221) static final function int GetMaxAvailPorts();

// Export UUdpLink::execBindPort(FFrame&, void* const)
// BindPort: Binds a free port or optional port specified in argument one.
native function int BindPort(optional int Port, optional bool bUseNextAvailable, optional out string szLocalBoundIpAddress);

// Export UUdpLink::execSendText(FFrame&, void* const)
// SendText: Sends text string.  
// Appends a cr/lf if LinkMode=MODE_Line .
native function bool SendText(IpAddr Addr, coerce string Str);

// Export UUdpLink::execSendBinary(FFrame&, void* const)
// SendBinary: Send data as a byte array.
native function bool SendBinary(IpAddr Addr, int Count, byte B[255]);

// Export UUdpLink::execReadText(FFrame&, void* const)
// ReadText: Reads text string.
// Returns number of bytes read.  
native function int ReadText(out IpAddr Addr, out string Str);

// Export UUdpLink::execReadBinary(FFrame&, void* const)
// ReadBinary: Read data as a byte array.
native function int ReadBinary(out IpAddr Addr, int Count, out byte B[255]);

// ReceivedText: Called when data is received and connection mode is MODE_Text.
event ReceivedText(IpAddr Addr, string Text)
{
	return;
}

// ReceivedLine: Called when data is received and connection mode is MODE_Line.
event ReceivedLine(IpAddr Addr, string Line)
{
	return;
}

// ReceivedBinary: Called when data is received and connection mode is MODE_Binary.
event ReceivedBinary(IpAddr Addr, int Count, byte B[255])
{
	return;
}

defaultproperties
{
	BroadcastAddr=-1
	bAlwaysTick=true
}
