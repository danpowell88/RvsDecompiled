//=============================================================================
// GameEngine - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// GameEngine: The game subsystem.
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class GameEngine extends Engine
	transient
	native
	config
 noexport;

struct URL
{
	var string Protocol;  // Protocol, i.e. "unreal" or "http".
// NEW IN 1.60
	var string Host;
	var int Port;  // Optional host port.
	var string Map;  // Map name, i.e. "SkyCity", default is "Index".
	var array<string> Op;  // Options.
	var string Portal;  // Portal to enter through, default is "".
	var bool Valid;
};

var Level GLevel;
// NEW IN 1.60
var Level GEntry;
var PendingLevel GPendingLevel;
var URL LastURL;
var config array<string> ServerActors;
// NEW IN 1.60
var config array<string> ServerPackages;
var bool FramePresentPending;
//#ifdef R6CODE
var string m_MapName;

defaultproperties
{
	ServerActors[0]="IpDrv.UdpBeacon"
	ServerPackages[0]="GamePlay"
	ServerPackages[1]="R6Abstract"
	ServerPackages[2]="R6Engine"
	ServerPackages[3]="R6Characters"
	ServerPackages[4]="R6GameService"
	ServerPackages[5]="R6Game"
	ServerPackages[6]="R61stWeapons"
	ServerPackages[7]="R6Weapons"
	ServerPackages[8]="R6WeaponGadgets"
	ServerPackages[9]="R63rdWeapons"
	CacheSizeMegs=32
}
