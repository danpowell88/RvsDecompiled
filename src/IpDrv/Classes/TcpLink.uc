//=============================================================================
// TcpLink - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// TcpLink: An Internet TCP/IP connection.
//=============================================================================
class TcpLink extends InternetLink
	transient
	native
 hidecategories(Movement,Collision,Lighting,LightColor,Karma,Force);

enum ELinkState
{
	STATE_Initialized,              // 0
	STATE_Ready,                    // 1
	STATE_Listening,                // 2
	STATE_Connecting,               // 3
	STATE_Connected,                // 4
	STATE_ListenClosePending,       // 5
	STATE_ConnectClosePending,      // 6
	STATE_ListenClosing,            // 7
	STATE_ConnectClosing            // 8
};

// NEW IN 1.60
var TcpLink.ELinkState LinkState;
// If AcceptClass is not None, an actor of class AcceptClass will be spawned when an
// incoming connecting is accepted, leaving the listener open to accept more connections.
// Accepted() is called only in the child class.  You can use the LostChild() and GainedChild()
// events to track your children.
var Class<TcpLink> AcceptClass;
var const array<byte> SendFIFO;  // send fifo
var IpAddr RemoteAddr;  // Contains address of peer connected to from a Listen()

// Export UTcpLink::execBindPort(FFrame&, void* const)
// BindPort: Binds a free port or optional port specified in argument one.
 native function int BindPort(optional int Port, optional bool bUseNextAvailable);

// Export UTcpLink::execListen(FFrame&, void* const)
// Listen: Listen for connections.  Can handle up to 5 simultaneous connections.
// Returns false if failed to place socket in listen mode.
 native function bool Listen();

// Export UTcpLink::execOpen(FFrame&, void* const)
// Open: Open a connection to a foreign host.
 native function bool Open(IpAddr Addr);

// Export UTcpLink::execClose(FFrame&, void* const)
// Close: Closes the current connection.   
 native function bool Close();

// Export UTcpLink::execIsConnected(FFrame&, void* const)
// IsConnected: Returns true if connected.
 native function bool IsConnected();

// Export UTcpLink::execSendText(FFrame&, void* const)
// SendText: Sends text string. 
// Appends a cr/lf if LinkMode=MODE_Line.  Returns number of bytes sent.
 native function int SendText(coerce string Str);

// Export UTcpLink::execSendBinary(FFrame&, void* const)
// SendBinary: Send data as a byte array.
 native function int SendBinary(int Count, byte B[255]);

// Export UTcpLink::execReadText(FFrame&, void* const)
// ReadText: Reads text string.
// Returns number of bytes read.  
 native function int ReadText(out string Str);

// Export UTcpLink::execReadBinary(FFrame&, void* const)
// ReadBinary: Read data as a byte array.
 native function int ReadBinary(int Count, out byte B[255]);

// Accepted: Called during STATE_Listening when a new connection is accepted.
event Accepted()
{
	return;
}

// Opened: Called when socket successfully connects.
event Opened()
{
	return;
}

// Closed: Called when Close() completes or the connection is dropped.
event Closed()
{
	return;
}

// ReceivedText: Called when data is received and connection mode is MODE_Text.
event ReceivedText(string Text)
{
	return;
}

// ReceivedLine: Called when data is received and connection mode is MODE_Line.
event ReceivedLine(string Line)
{
	return;
}

// ReceivedBinary: Called when data is received and connection mode is MODE_Binary.
event ReceivedBinary(int Count, byte B[255])
{
	return;
}

defaultproperties
{
	bAlwaysTick=true
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var ELinkState
