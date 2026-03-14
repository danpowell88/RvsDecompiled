//=============================================================================
// ClientBeaconReceiver: Receives LAN beacons from servers.
//=============================================================================
class ClientBeaconReceiver extends UdpBeacon
    transient;

// --- Structs ---
struct PreJoinResponseInfo
{
    var int iLobbyID;
    var int iGroupID;
    var bool bResponseRcvd;
    var string szGameVersion;
    var int iPunkBusterEnabled;
    var int iMaxPlayers;
    var int iNumPlayers;
    var bool bInternetServer;
    var string szPreJoinModName;
    var bool bLocked;
};

struct BeaconInfo
{
    var IpAddr Addr;
    var string szPlayerName[32];
    var string MapList[32];
    var string szPlayerTime[32];
    var int iPlayerKillCount[32];
    var string szGameType[32];
    var bool bNewData;
    var int iPlayerPingTime[32];
    var bool bPunkBuster;
    var float fBombTime;
    var float fBetTime;
    var float fRndTime;
    var int iRoundsPerMap;
    var bool bShowNames;
    var bool bInternetServer;
    var bool bFriendlyFire;
    var bool bAutoBalTeam;
    var bool bLocked;
    var bool bDedicated;
    var string szSvrName;
    var string szMapName;
    var string szCurrGameType;
    var int iMaxPlayers;
    var int iNumPlayers;
    var string szModName;
    var bool bTKPenalty;
    var bool bRadar;
    var int iPort;
    var string szGameVersion;
    var int iLobbyID;
    var int iGroupID;
    var float Time;
    var string Text;
    var int iBeaconPort;
    var int iNumTerro;
    var bool bAIBkp;
    var bool bRotateMap;
    var bool bForceFPWpn;
};

// --- Variables ---
// var ? Addr; // REMOVED IN 1.60
// var ? Text; // REMOVED IN 1.60
// var ? Time; // REMOVED IN 1.60
// var ? bAIBkp; // REMOVED IN 1.60
// var ? bAutoBalTeam; // REMOVED IN 1.60
// var ? bDedicated; // REMOVED IN 1.60
// var ? bForceFPWpn; // REMOVED IN 1.60
// var ? bFriendlyFire; // REMOVED IN 1.60
// var ? bInternetServer; // REMOVED IN 1.60
// var ? bLocked; // REMOVED IN 1.60
// var ? bNewData; // REMOVED IN 1.60
// var ? bPunkBuster; // REMOVED IN 1.60
// var ? bRadar; // REMOVED IN 1.60
// var ? bResponseRcvd; // REMOVED IN 1.60
// var ? bRotateMap; // REMOVED IN 1.60
// var ? bShowNames; // REMOVED IN 1.60
// var ? bTKPenalty; // REMOVED IN 1.60
// var ? fBetTime; // REMOVED IN 1.60
// var ? fBombTime; // REMOVED IN 1.60
// var ? fRndTime; // REMOVED IN 1.60
// var ? iBeaconPort; // REMOVED IN 1.60
// var ? iGroupID; // REMOVED IN 1.60
// var ? iLobbyID; // REMOVED IN 1.60
// var ? iMaxPlayers; // REMOVED IN 1.60
// var ? iNumPlayers; // REMOVED IN 1.60
// var ? iNumTerro; // REMOVED IN 1.60
// var ? iPlayerKillCount; // REMOVED IN 1.60
// var ? iPlayerPingTime; // REMOVED IN 1.60
// var ? iPort; // REMOVED IN 1.60
// var ? iPunkBusterEnabled; // REMOVED IN 1.60
// var ? iRoundsPerMap; // REMOVED IN 1.60
// var ? mapList; // REMOVED IN 1.60
// var ? szCurrGameType; // REMOVED IN 1.60
// var ? szGameType; // REMOVED IN 1.60
// var ? szGameVersion; // REMOVED IN 1.60
// var ? szMapName; // REMOVED IN 1.60
// var ? szModName; // REMOVED IN 1.60
// var ? szPlayerName; // REMOVED IN 1.60
// var ? szPlayerTime; // REMOVED IN 1.60
// var ? szSvrName; // REMOVED IN 1.60
var BeaconInfo Beacons[32];
// ^ NEW IN 1.60
var PreJoinResponseInfo PreJoinInfo;
// ^ NEW IN 1.60

// --- Functions ---
//#ifdef R6PUNKBUSTER
function bool GetPunkBusterEnabled(int i) {}
// ^ NEW IN 1.60
function bool GetForceFirstPersonWeapon(int i) {}
// ^ NEW IN 1.60
function bool GetRotateMap(int i) {}
// ^ NEW IN 1.60
function bool GetAIBackup(int i) {}
// ^ NEW IN 1.60
function int GetNumTerrorists(int i) {}
// ^ NEW IN 1.60
function int GetBeaconPort(int i) {}
// ^ NEW IN 1.60
function string GetBeaconAddress(int i) {}
// ^ NEW IN 1.60
function string GetOneMapName(int iBeacon, int i) {}
// ^ NEW IN 1.60
function int GetGroupID(int i) {}
// ^ NEW IN 1.60
function int GetLobbyID(int i) {}
// ^ NEW IN 1.60
function string GetBeaconText(int i) {}
// ^ NEW IN 1.60
function SetNewDataFlag(int i, bool bNewData) {}
function string GetServerGameVersion(int i) {}
// ^ NEW IN 1.60
function float GetBombTime(int i) {}
// ^ NEW IN 1.60
function bool GetNewDataFlag(int i) {}
// ^ NEW IN 1.60
function float GetBetTime(int i) {}
// ^ NEW IN 1.60
function string GetCurrGameType(int i) {}
// ^ NEW IN 1.60
function bool GetRadar(int i) {}
// ^ NEW IN 1.60
function bool GetTKPenalty(int i) {}
// ^ NEW IN 1.60
function float GetRoundTime(int i) {}
// ^ NEW IN 1.60
function bool GetAutoBalanceTeam(int i) {}
// ^ NEW IN 1.60
function bool GetFriendlyFire(int i) {}
// ^ NEW IN 1.60
function bool GetInternetServer(int i) {}
// ^ NEW IN 1.60
function bool GetShowEnemyNames(int i) {}
// ^ NEW IN 1.60
function float GetRoundsPerMap(int i) {}
// ^ NEW IN 1.60
//function string GetGameName( INT iBeacon, INT i )
//{
//	return Beacons[iBeacon].szGameName[i];
//}
function string GetGameType(int iBeacon, int i) {}
// ^ NEW IN 1.60
function int GetPlayerKillCount(int iBeacon, int i) {}
// ^ NEW IN 1.60
function string GetPlayerName(int i, int iBeacon) {}
// ^ NEW IN 1.60
function bool GetDedicated(int i) {}
// ^ NEW IN 1.60
function int GetPlayerPingTime(int iBeacon, int i) {}
// ^ NEW IN 1.60
function bool GetLocked(int i) {}
// ^ NEW IN 1.60
function string GetPlayerTime(int iBeacon, int i) {}
// ^ NEW IN 1.60
//=========================================================================
// DecodeKeyWordPair - Given a string containing a keyword pair (keyword
// and associated value) determine which keyword is used, and extract
// the associated value.  Place results in the Beacons array.
//=========================================================================
function DecodeKeyWordPair(string szKeyWord, int iIndex) {}
event ReceivedText(string Text, IpAddr Addr) {}
//-------------------------------------------------------------------------------
// This functio will clear all the information in the beacon
//-------------------------------------------------------------------------------
function ClearBeacon(int i) {}
//
// Grab the next option from a string.
//
function bool GrabOption(out string Options, out string Result) {}
// ^ NEW IN 1.60
// MPF
function string GetModName(int i) {}
// ^ NEW IN 1.60
//=========================================================================
// DecodeKeyWordString - Go through the keyword string and extract
// key word pairs (keyword and associated value).  Call DecodeKeyWordPair
// to decode each pair.
//=========================================================================
function DecodeKeyWordString(string szKewWordString, int iBeaconIdx) {}
function Timer() {}
//
// Break up a key=value pair into its key and value.
//
function GetKeyValue(string Pair, out string Value, out string Key) {}
function int GetMapListSize(int i) {}
// ^ NEW IN 1.60
function string GetSvrName(int i) {}
// ^ NEW IN 1.60
function string GetFirstMapName(int i) {}
// ^ NEW IN 1.60
function int GetPlayerListSize(int i) {}
// ^ NEW IN 1.60
function int GetNumPlayers(int i) {}
// ^ NEW IN 1.60
function bool PreJoinQuery(string szIP, int iBeaconPort) {}
// ^ NEW IN 1.60
function int GetBeaconIntAddress(int i) {}
// ^ NEW IN 1.60
function BroadcastBeacon(IpAddr Addr) {}
function int GetPortNumber(int i) {}
// ^ NEW IN 1.60
function RefreshServers() {}
function int GetMaxPlayers(int i) {}
// ^ NEW IN 1.60
function BeginPlay() {}
function string ParseOption(string InKey, string Options) {}
// ^ NEW IN 1.60
//=========================================================================
// Get functions.  The script compiler would not let me access the Beacon
// member variable from another class because it was too big.  Instead
// I set up these get functions and a ClearBeacon function to clear values
// in the Beacon array.
//=========================================================================
function int GetBeaconListSize() {}
// ^ NEW IN 1.60
function Destroyed() {}

defaultproperties
{
}
