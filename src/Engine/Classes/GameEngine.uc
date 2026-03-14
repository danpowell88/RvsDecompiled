//=============================================================================
// GameEngine: The game subsystem.
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class GameEngine extends Engine
    native
    noexport
    transient;

// --- Structs ---
struct URL
{
	var string			Protocol,	// Protocol, i.e. "unreal" or "http".
						Host;		// Optional hostname, i.e. "204.157.115.40" or "unreal.epicgames.com", blank if local.
	var int				Port;		// Optional host port.
	var string			Map;		// Map name, i.e. "SkyCity", default is "Index".
	var array<string>	Op;			// Options.
	var string			Portal;		// Portal to enter through, default is "".
	var bool			Valid;
};

// --- Variables ---
// var ? Map; // REMOVED IN 1.60
// var ? Op; // REMOVED IN 1.60
// var ? Port; // REMOVED IN 1.60
// var ? Portal; // REMOVED IN 1.60
// var ? Valid; // REMOVED IN 1.60
//#ifdef R6CODE
var string m_MapName;
var bool FramePresentPending;
var config array<array> ServerPackages;
// ^ NEW IN 1.60
var config array<array> ServerActors;
// ^ NEW IN 1.60
var URL LastURL;
var PendingLevel GPendingLevel;
var Level GEntry;
// ^ NEW IN 1.60
var Level GLevel;
// ^ NEW IN 1.60

defaultproperties
{
}
