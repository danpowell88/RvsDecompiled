//=============================================================================
// TcpLink: An Internet TCP/IP connection.
//=============================================================================
class TcpLink extends InternetLink
    native
    transient;

// --- Enums ---
enum ELinkState
{
    // enum values not recoverable from binary — see 1.56 source
};

// --- Variables ---
var ELinkState LinkState;
// ^ NEW IN 1.60
// Contains address of peer connected to from a Listen()
var IpAddr RemoteAddr;
// If AcceptClass is not None, an actor of class AcceptClass will be spawned when an
// incoming connecting is accepted, leaving the listener open to accept more connections.
// Accepted() is called only in the child class.  You can use the LostChild() and GainedChild()
// events to track your children.
var class<TcpLink> AcceptClass;
// send fifo
var const array<array> SendFIFO;

// --- Functions ---
// BindPort: Binds a free port or optional port specified in argument one.
native function int BindPort(optional bool bUseNextAvailable, optional int Port) {}
// ^ NEW IN 1.60
// Open: Open a connection to a foreign host.
native function bool Open(IpAddr Addr) {}
// ^ NEW IN 1.60
// SendText: Sends text string.
// Appends a cr/lf if LinkMode=MODE_Line.  Returns number of bytes sent.
native function int SendText(coerce string Str) {}
// ^ NEW IN 1.60
// SendBinary: Send data as a byte array.
native function int SendBinary(byte B, int Count) {}
// ^ NEW IN 1.60
// ReadText: Reads text string.
// Returns number of bytes read.
native function int ReadText(out string Str) {}
// ^ NEW IN 1.60
// ReadBinary: Read data as a byte array.
native function int ReadBinary(int Count, out byte B) {}
// ^ NEW IN 1.60
// Listen: Listen for connections.  Can handle up to 5 simultaneous connections.
// Returns false if failed to place socket in listen mode.
native function bool Listen() {}
// ^ NEW IN 1.60
// Close: Closes the current connection.
native function bool Close() {}
// ^ NEW IN 1.60
// IsConnected: Returns true if connected.
native function bool IsConnected() {}
// ^ NEW IN 1.60
// Accepted: Called during STATE_Listening when a new connection is accepted.
event Accepted() {}
// Opened: Called when socket successfully connects.
event Opened() {}
// Closed: Called when Close() completes or the connection is dropped.
event Closed() {}
// ReceivedText: Called when data is received and connection mode is MODE_Text.
event ReceivedText(string Text) {}
// ReceivedLine: Called when data is received and connection mode is MODE_Line.
event ReceivedLine(string Line) {}
// ReceivedBinary: Called when data is received and connection mode is MODE_Binary.
event ReceivedBinary(int Count, byte B) {}

defaultproperties
{
}
