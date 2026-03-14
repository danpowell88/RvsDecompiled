//=============================================================================
// UdpBeacon: Base class of beacon sender and receiver.
//=============================================================================
class UdpBeacon extends UdpLink
    transient
    config;

// --- Variables ---
//#ifdef R6PUNKBUSTER
var string PunkBusterMarker;
// MPF
var string ModNameMarker;
var config globalconfig string BeaconProduct;
// ^ NEW IN 1.60
var string InternetServerMarker;
var string GameVersionMarker;
var string LobbyServerIDMarker;
var string GroupIDMarker;
var string MaxPlayersMarker;
var string LockedMarker;
var string NumPlayersMarker;
var config globalconfig int ServerBeaconPort;
// ^ NEW IN 1.60
var string MapNameMarker;
var string NumTerroMarker;
var string PlayerKillMarker;
var string AIBkpMarker;
var string RotateMapMarker;
var string BeaconPortMarker;
var string GamePortMarker;
var string PreJoinQueryMarker;
var string PlayerPingMarker;
var string PlayerTimeMarker;
var int boundport;
//var                string     MapTimeMarker;
var string RoundsPerMatchMarker;
var string RoundTimeMarker;
var string AllowRadarMarker;
var string BetTimeMarker;
var string TKPenaltyMarker;
var string AutoBalTeamMarker;
var string FriendlyFireMarker;
var string ShowNamesMarker;
var string ForceFPWpnMarker;
var string BombTimeMarker;
//#ifdef R6CODE // added by John Bennett - April 2002
var string KeyWordMarker;
var string PlayerListMarker;
var string GameTypeMarker;
var string MapListMarker;
var string MenuGmNameMarker;
var string DecicatedMarker;
var string SvrNameMarker;
var config globalconfig int BeaconPort;
// ^ NEW IN 1.60
var string LocalIpAddress;
var int UdpServerQueryPort;
var config globalconfig float BeaconTimeout;
// ^ NEW IN 1.60
var string OptionsListMarker;
var config globalconfig bool DoBeacon;
// ^ NEW IN 1.60

// --- Functions ---
function BeginPlay() {}
function BroadcastBeacon(IpAddr Addr) {}
function Timer() {}
event ReceivedText(string Text, IpAddr Addr) {}
function Destroyed() {}
function BroadcastBeaconQuery(IpAddr Addr) {}
//===============================================================================
// BuildBeaconText: Build a string which contains all the game data
// that will be sent to a client.
//===============================================================================
function string BuildBeaconText() {}
// ^ NEW IN 1.60
//===============================================================================
// RespondPreJoinQuery: Used to send some data from server to client before
// the client joins a server, intended for a client that is joining using
// the join IP button.
//===============================================================================
function RespondPreJoinQuery(IpAddr Addr) {}
//===============================================================================
// DisplayTime: display the time in min (have to be in sec)
//===============================================================================
function string DisplayTime(int _iTimeToConvert) {}
// ^ NEW IN 1.60
function InitBeaconProduct() {}

defaultproperties
{
}
