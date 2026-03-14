//=============================================================================
//  R6GameServices.uc : This class is used to manage server lists.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/02/20 * Created by John Bennett
//============================================================================//
class R6ServerList extends R6AbstractGameService
    native;

// --- Constants ---
const K_GlobalID_size =  16;

// --- Enums ---
enum eSortCategory
{
    eSG_Favorite,
    eSG_Locked,
    eSG_Dedicated,
//#ifdefR6PUNKBUSTER
	eSG_PunkBuster,
//#endif
    eSG_PingTime,
    eSG_Name,
    eSG_GameType,
    eSG_GameMode,
    eSG_Map,
    eSG_NumPlayers
};

// --- Structs ---
struct stRemotePlayers
{
    var string szAlias;
    var INT    iPing;
    var INT    iGroupID;
    var INT    iLobbySrvID;
    var INT    iSkills;
    var INT    iRank;
    var string szTime;
};

struct stGameServer
{
    // Basic information on server
    var INT         iGroupID;
    var INT         iLobbySrvID;
    var INT         iBeaconPort;
//    var INT         iID;
    var INT         iPing;
    var string      szIPAddress;
    var string      szAltIPAddress;
    var BOOL        bUseAltIP;

    // flags - used mostly for menus
    var BOOL        bDisplay;    // Display to user in server list
    var BOOL        bFavorite;
    var BOOL        bSameVersion;
    var string      szOptions;

    // Fixed portion of game data buffer
    var stGameData  sGameData;
};

struct stGameData
{
    var BOOL        bUsePassword;
    var BOOL        bDedicatedServer;
//    var INT         iTimeMap;
    var INT         iRoundsPerMatch;
    var INT         iRoundTime;
    var INT         iBetTime;
    var INT         iBombTime;
    var BOOL        bShowNames;
    var BOOL        bInternetServer;
    var BOOL        bFriendlyFire;
    var BOOL        bAutoBalTeam;
    var BOOL        bTKPenalty;
    var BOOL        bRadar;
    var BOOL        bAdversarial;
    var BOOL        bRotateMap;
    var BOOL        bAIBkp;
    var BOOL        bForceFPWeapon;
//#ifdef R6PUNKBUSTER
    var BOOL        bPunkBuster;
//#endif R6PUNKBUSTER
    var INT         iNumMaps;
    var INT         iNumTerro;
    var INT         iPort;

    var string      szName;
    var string      szModName; // MPF
    var INT         iMaxPlayer; 
    var INT         iNbrPlayer;
	var string      szGameDataGameType;
    var string      szGameType;
    var string      szCurrentMap;
    var string      szMessageOfDay;
    var string      szGameVersion;
    // Variable portion of game data buffer
//    var array<string> mapList;
    var array<stGameTypeAndMap> gameMapList;
    // List of remote players, filled only for selected server
    var array<stRemotePlayers> playerList;
    // Data used only if setting self up as a server
    var string      szPassword;

};

struct stGameTypeAndMap
{
    var string szMap;
//    var string szGameLoc;
    var string szGameType;
};

struct stValidationResponse
{
    var INT     iReqID;
    var PlayerController.ECDKEYST_STATUS eStatus;
    var BOOL    bSuceeded;
    var BOOL    bTimeout;
    var BYTE    ucGlobalID[K_GlobalID_size];
};

struct IpAddr
{
	var int Addr;
	var int Port;
};

// --- Variables ---
// var ? Addr; // REMOVED IN 1.60
// var ? Port; // REMOVED IN 1.60
// var ? bAIBkp; // REMOVED IN 1.60
// var ? bAdversarial; // REMOVED IN 1.60
// var ? bAutoBalTeam; // REMOVED IN 1.60
// var ? bCaptureTheEnemyAdv; // REMOVED IN 1.60
// var ? bDeathMatch; // REMOVED IN 1.60
// var ? bDebugGameMode; // REMOVED IN 1.60
// var ? bDedicatedServer; // REMOVED IN 1.60
// var ? bDedicatedServersOnly; // REMOVED IN 1.60
// var ? bDefend; // REMOVED IN 1.60
// var ? bDisarmBomb; // REMOVED IN 1.60
// var ? bDisplay; // REMOVED IN 1.60
// var ? bEscortPilot; // REMOVED IN 1.60
// var ? bFavorite; // REMOVED IN 1.60
// var ? bFavoritesOnly; // REMOVED IN 1.60
// var ? bForceFPWeapon; // REMOVED IN 1.60
// var ? bFriendlyFire; // REMOVED IN 1.60
// var ? bHostageRescueAdv; // REMOVED IN 1.60
// var ? bHostageRescueCoop; // REMOVED IN 1.60
// var ? bInternetServer; // REMOVED IN 1.60
// var ? bKamikaze; // REMOVED IN 1.60
// var ? bMission; // REMOVED IN 1.60
// var ? bPunkBuster; // REMOVED IN 1.60
// var ? bPunkBusterServerOnly; // REMOVED IN 1.60
// var ? bRadar; // REMOVED IN 1.60
// var ? bRecon; // REMOVED IN 1.60
// var ? bResponding; // REMOVED IN 1.60
// var ? bRotateMap; // REMOVED IN 1.60
// var ? bSameVersion; // REMOVED IN 1.60
// var ? bScatteredHuntAdv; // REMOVED IN 1.60
// var ? bServersNotEmpty; // REMOVED IN 1.60
// var ? bServersNotFull; // REMOVED IN 1.60
// var ? bShowNames; // REMOVED IN 1.60
// var ? bSquadDeathMatch; // REMOVED IN 1.60
// var ? bSquadTeamDeathMatch; // REMOVED IN 1.60
// var ? bSuceeded; // REMOVED IN 1.60
// var ? bTKPenalty; // REMOVED IN 1.60
// var ? bTeamDeathMatch; // REMOVED IN 1.60
// var ? bTerroristHunt; // REMOVED IN 1.60
// var ? bTerroristHuntAdv; // REMOVED IN 1.60
// var ? bTimeout; // REMOVED IN 1.60
// var ? bUnlockedOnly; // REMOVED IN 1.60
// var ? bUseAltIP; // REMOVED IN 1.60
// var ? bUsePassword; // REMOVED IN 1.60
// var ? eStatus; // REMOVED IN 1.60
// var ? gameMapList; // REMOVED IN 1.60
// var ? iBeaconPort; // REMOVED IN 1.60
// var ? iBetTime; // REMOVED IN 1.60
// var ? iBombTime; // REMOVED IN 1.60
// var ? iFasterThan; // REMOVED IN 1.60
// var ? iGroupID; // REMOVED IN 1.60
// var ? iLobbySrvID; // REMOVED IN 1.60
// var ? iMaxPlayer; // REMOVED IN 1.60
// var ? iNbrPlayer; // REMOVED IN 1.60
// var ? iNumMaps; // REMOVED IN 1.60
// var ? iNumTerro; // REMOVED IN 1.60
// var ? iPing; // REMOVED IN 1.60
// var ? iPort; // REMOVED IN 1.60
// var ? iRank; // REMOVED IN 1.60
// var ? iReqID; // REMOVED IN 1.60
// var ? iRoundTime; // REMOVED IN 1.60
// var ? iRoundsPerMatch; // REMOVED IN 1.60
// var ? iSkills; // REMOVED IN 1.60
// var ? m_Filters; // REMOVED IN 1.60
// var ? m_bIndRefrInProgress; // REMOVED IN 1.60
// var ? playerList; // REMOVED IN 1.60
// var ? sGameData; // REMOVED IN 1.60
// var ? szAlias; // REMOVED IN 1.60
// var ? szAltIPAddress; // REMOVED IN 1.60
// var ? szCurrentMap; // REMOVED IN 1.60
// var ? szGameDataGameType; // REMOVED IN 1.60
// var ? szGameType; // REMOVED IN 1.60
// var ? szGameVersion; // REMOVED IN 1.60
// var ? szHasPlayer; // REMOVED IN 1.60
// var ? szIPAddress; // REMOVED IN 1.60
// var ? szMap; // REMOVED IN 1.60
// var ? szMessageOfDay; // REMOVED IN 1.60
// var ? szModName; // REMOVED IN 1.60
// var ? szName; // REMOVED IN 1.60
// var ? szOptions; // REMOVED IN 1.60
// var ? szPassword; // REMOVED IN 1.60
// var ? szTime; // REMOVED IN 1.60
// var ? ucGlobalID; // REMOVED IN 1.60
var array<array> m_GameServerList;
var ClientBeaconReceiver m_ClientBeacon;
var stGameServer m_CrGameSrvInfo;
var array<array> m_GSLSortIdx;
var int m_iSelSrvIndex;
var array<array> m_favoriteServersList;
// Index of server on which we are doing an individual refresh
var int m_iIndRefrIndex;
// Flag to indicate that a change in the server list was detected
var bool m_bServerListChanged;
// Auto login saved value
var config bool m_bAutoLISave;
// Game version as indicated in R6RSVersion.h
var string m_szGameVersion;
// Save password saved value
var config bool m_bSavePWSave;
// Flag to indicate that a change in the server info was detected
var bool m_bServerInfoChanged;
var bool m_bDedicatedServer;
var array<array> m_ModValidResponseList;
var array<array> m_ValidResponseList;

// --- Functions ---
// function ? UpdateFilters(...); // REMOVED IN 1.60
//=============================================================================
// SetGameVersionRelease: Sets the member variables used to hold the game
// version name and the game release name
//=============================================================================
function Created() {}
final native function SortServers(bool _bAscending, int _iSortType) {}
// ^ NEW IN 1.60
final native function int NativeGetPingTime(coerce string IpAddr) {}
// ^ NEW IN 1.60
//=============================================================================
// SetSelectedServer: Set the selcted server to the passed value
//=============================================================================
function SetSelectedServer(int iServerListIndex) {}
event GetLobbyAndGroupID(out int _iGroupID, out int _iLobbyID) {}
// ^ NEW IN 1.60
//=============================================================================
// IsAFavorite - Checks if the passed server is a member of the
// favorite server list.
//=============================================================================
function bool IsAFavorite(string szIPAddress) {}
// ^ NEW IN 1.60
//=============================================================================
// AddToFavorites - Add the server to the list of favorite servers.  This
// list is kept in an ini file (r6gameservice.ini).  The function argument is
// the index of the server in the list of servers: m_GameServerList.
//=============================================================================
function AddToFavorites(int sortedListIdx) {}
//=============================================================================
// DelFromFavorites - Remove the server from the list of favorite servers.  This
// list is kept in an ini file (r6gameservice.ini).  The function argument is
// the index of the server in the list of servers: m_GameServerList.
//=============================================================================
function DelFromFavorites(int sortedListIdx) {}
function int GetTotalPlayers() {}
// ^ NEW IN 1.60
function SortPlayersByKills(int _iIdx, bool _bAscending) {}
//=============================================================================
// Returns the values that will be displayed in the server list
//=============================================================================
function getServerListItem(out stGameServer _stGameServer, int iSortIdx) {}
//=============================================================================
// getSvrData: Get the gamedata of a server from the ClientBeaconReceiver class
//=============================================================================
function stGameData getSvrData(int iBeaconIdx) {}
// ^ NEW IN 1.60
final native function int GetDisplayListSize() {}
// ^ NEW IN 1.60
final native function int NativeGetMaxPlayers() {}
// ^ NEW IN 1.60
final native function int NativeGetOwnSvrPort() {}
// ^ NEW IN 1.60
final native function int NativeGetMilliSeconds() {}
// ^ NEW IN 1.60
final native function int NativeGetPingTimeOut() {}
// ^ NEW IN 1.60
final native function NativeUpdateFavorites() {}
// ^ NEW IN 1.60
final native function NativeInitFavorites() {}
// ^ NEW IN 1.60

defaultproperties
{
}
