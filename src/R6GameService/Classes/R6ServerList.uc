//=============================================================================
// R6ServerList - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6GameServices.uc : This class is used to manage server lists.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/02/20 * Created by John Bennett
//============================================================================//
class R6ServerList extends R6
    AbstractGameService
    native
    config;

const K_GlobalID_size = 16;

enum eSortCategory
{
	eSG_Favorite,                   // 0
	eSG_Locked,                     // 1
	eSG_Dedicated,                  // 2
	eSG_PunkBuster,                 // 3
	eSG_PingTime,                   // 4
	eSG_Name,                       // 5
	eSG_GameType,                   // 6
	eSG_GameMode,                   // 7
	eSG_Map,                        // 8
	eSG_NumPlayers                  // 9
};

struct stValidationResponse
{
	var int iReqID;
	var Controller.ECDKEYST_STATUS eStatus;
	var bool bSuceeded;
	var bool bTimeout;
// NEW IN 1.60
	var byte ucGlobalID[16];
};

struct IpAddr
{
	var int Addr;
	var int Port;
};

struct stRemotePlayers
{
	var string szAlias;
	var int iPing;
	var int iGroupID;
	var int iLobbySrvID;
	var int iSkills;
	var int iRank;
	var string szTime;
};

struct stGameTypeAndMap
{
	var string szMap;
//    var string szGameLoc;
	var string szGameType;
};

struct stGameData
{
	var bool bUsePassword;
	var bool bDedicatedServer;
//    var INT         iTimeMap;
	var int iRoundsPerMatch;
	var int iRoundTime;
	var int iBetTime;
	var int iBombTime;
	var bool bShowNames;
	var bool bInternetServer;
	var bool bFriendlyFire;
	var bool bAutoBalTeam;
	var bool bTKPenalty;
	var bool bRadar;
	var bool bAdversarial;
	var bool bRotateMap;
	var bool bAIBkp;
	var bool bForceFPWeapon;
//#ifdef R6PUNKBUSTER
	var bool bPunkBuster;
//#endif R6PUNKBUSTER
	var int iNumMaps;
	var int iNumTerro;
	var int iPort;
	var string szName;
	var string szModName;  // MPF
	var int iMaxPlayer;
	var int iNbrPlayer;
	var string szGameDataGameType;
//    var string szGameLoc;
	var string szGameType;
	var string szCurrentMap;
	var string szMessageOfDay;
	var string szGameVersion;
    // Variable portion of game data buffer
//    var array<string> mapList;
	var array<stGameTypeAndMap> gameMapList;
    // List of remote players, filled only for selected server
	var array<stRemotePlayers> PlayerList;
    // Data used only if setting self up as a server
	var string szPassword;
};

struct stGameServer
{
	var int iGroupID;
	var int iLobbySrvID;
	var int iBeaconPort;
	var int iPing;
	var string szIPAddress;
	var string szAltIPAddress;
	var bool bUseAltIP;
    // flags - used mostly for menus
	var bool bDisplay;  // Display to user in server list
	var bool bFavorite;
	var bool bSameVersion;
	var string szOptions;
    // Fixed portion of game data buffer
	var stGameData sGameData;
};

var int m_iSelSrvIndex;
var int m_iIndRefrIndex;  // Index of server on which we are doing an individual refresh
var bool m_bDedicatedServer;
var bool m_bServerListChanged;  // Flag to indicate that a change in the server list was detected
var bool m_bServerInfoChanged;  // Flag to indicate that a change in the server info was detected
var config bool m_bSavePWSave;  // Save password saved value
var config bool m_bAutoLISave;  // Auto login saved value
var ClientBeaconReceiver m_ClientBeacon;
var array<string> m_favoriteServersList;
var array<stGameServer> m_GameServerList;
var array<stValidationResponse> m_ValidResponseList;
var array<stValidationResponse> m_ModValidResponseList;
var array<int> m_GSLSortIdx;
var stGameServer m_CrGameSrvInfo;
var string m_szGameVersion;  // Game version as indicated in R6RSVersion.h

// Export UR6ServerList::execNativeInitFavorites(FFrame&, void* const)
native(1222) final function NativeInitFavorites();

// Export UR6ServerList::execNativeUpdateFavorites(FFrame&, void* const)
native(1223) final function NativeUpdateFavorites();

// Export UR6ServerList::execNativeGetPingTime(FFrame&, void* const)
native(1225) final function int NativeGetPingTime(coerce string IpAddr);

// Export UR6ServerList::execNativeGetPingTimeOut(FFrame&, void* const)
native(1202) final function int NativeGetPingTimeOut();

// Export UR6ServerList::execNativeGetMilliSeconds(FFrame&, void* const)
native(1278) final function int NativeGetMilliSeconds();

// Export UR6ServerList::execSortServers(FFrame&, void* const)
native(1206) final function SortServers(int _iSortType, bool _bAscending);

// Export UR6ServerList::execNativeGetOwnSvrPort(FFrame&, void* const)
native(1292) final function int NativeGetOwnSvrPort();

// Export UR6ServerList::execNativeGetMaxPlayers(FFrame&, void* const)
native(1355) final function int NativeGetMaxPlayers();

// Export UR6ServerList::execGetDisplayListSize(FFrame&, void* const)
native(1314) final function int GetDisplayListSize();

//=============================================================================
// Returns the values that will be displayed in the server list
//=============================================================================
function getServerListItem(int iSortIdx, out stGameServer _stGameServer)
{
	local int Index;

	Index = m_GSLSortIdx[iSortIdx];
	_stGameServer.bFavorite = m_GameServerList[Index].bFavorite;
	_stGameServer.bSameVersion = m_GameServerList[Index].bSameVersion;
	_stGameServer.szIPAddress = m_GameServerList[Index].szIPAddress;
	_stGameServer.iPing = m_GameServerList[Index].iPing;
	_stGameServer.sGameData.szName = m_GameServerList[Index].sGameData.szName;
	_stGameServer.sGameData.szCurrentMap = m_GameServerList[Index].sGameData.szCurrentMap;
	_stGameServer.sGameData.iMaxPlayer = m_GameServerList[Index].sGameData.iMaxPlayer;
	_stGameServer.sGameData.iNbrPlayer = m_GameServerList[Index].sGameData.iNbrPlayer;
	_stGameServer.sGameData.szGameDataGameType = m_GameServerList[Index].sGameData.szGameDataGameType;
	_stGameServer.sGameData.bUsePassword = m_GameServerList[Index].sGameData.bUsePassword;
	_stGameServer.sGameData.bDedicatedServer = m_GameServerList[Index].sGameData.bDedicatedServer;
	_stGameServer.sGameData.bPunkBuster = m_GameServerList[Index].sGameData.bPunkBuster;
	return;
}

//=============================================================================
// IsAFavorite - Checks if the passed server is a member of the 
// favorite server list.
//=============================================================================
function bool IsAFavorite(string szIPAddress)
{
	local int i;
	local bool bFound;

	bFound = false;
	i = 0;
	J0x0F:

	// End:0x53 [Loop If]
	if(((i < m_favoriteServersList.Length) && (!bFound)))
	{
		// End:0x49
		if((szIPAddress == m_favoriteServersList[i]))
		{
			bFound = true;
		}
		(i++);
		// [Loop Continue]
		goto J0x0F;
	}
	return bFound;
	return;
}

//=============================================================================
// AddToFavorites - Add the server to the list of favorite servers.  This
// list is kept in an ini file (r6gameservice.ini).  The function argument is
// the index of the server in the list of servers: m_GameServerList.
//=============================================================================
function AddToFavorites(int sortedListIdx)
{
	local int i;
	local bool Found;
	local int serverListIndex;

	serverListIndex = m_GSLSortIdx[sortedListIdx];
	m_GameServerList[serverListIndex].bFavorite = true;
	Found = false;
	i = 0;
	J0x33:

	// End:0x82 [Loop If]
	if(((i < m_favoriteServersList.Length) && (!Found)))
	{
		// End:0x78
		if((m_GameServerList[serverListIndex].szIPAddress == m_favoriteServersList[i]))
		{
			Found = true;
		}
		(i++);
		// [Loop Continue]
		goto J0x33;
	}
	// End:0xAD
	if((!Found))
	{
		m_favoriteServersList[m_favoriteServersList.Length] = m_GameServerList[serverListIndex].szIPAddress;
		NativeUpdateFavorites();
	}
	return;
}

//=============================================================================
// DelFromFavorites - Remove the server from the list of favorite servers.  This
// list is kept in an ini file (r6gameservice.ini).  The function argument is
// the index of the server in the list of servers: m_GameServerList.
//=============================================================================
function DelFromFavorites(int sortedListIdx)
{
	local int i, favoritesListIndex;
	local bool Found;
	local int serverListIndex;

	serverListIndex = m_GSLSortIdx[sortedListIdx];
	m_GameServerList[serverListIndex].bFavorite = false;
	Found = false;
	i = 0;
	J0x33:

	// End:0x8D [Loop If]
	if(((i < m_favoriteServersList.Length) && (!Found)))
	{
		// End:0x83
		if((m_GameServerList[serverListIndex].szIPAddress == m_favoriteServersList[i]))
		{
			Found = true;
			favoritesListIndex = i;
		}
		(i++);
		// [Loop Continue]
		goto J0x33;
	}
	// End:0xA5
	if(Found)
	{
		m_favoriteServersList.Remove(favoritesListIndex, 1);
		NativeUpdateFavorites();
	}
	return;
}

//=============================================================================
// SetSelectedServer: Set the selcted server to the passed value
//=============================================================================
function SetSelectedServer(int iServerListIndex)
{
	// End:0x20
	if(((iServerListIndex > m_GameServerList.Length) || (m_GameServerList.Length == 0)))
	{
		return;
	}
	m_iSelSrvIndex = m_GSLSortIdx[iServerListIndex];
	return;
}

//=============================================================================
// SetGameVersionRelease: Sets the member variables used to hold the game 
// version name and the game release name
//=============================================================================
function Created()
{
	m_szGameVersion = Class'Engine.Actor'.static.GetGameVersion(false, (!Class'Engine.Actor'.static.GetModMgr().IsRavenShield()));
	return;
}

//=============================================================================
// getSvrData: Get the gamedata of a server from the ClientBeaconReceiver class
//=============================================================================
function stGameData getSvrData(int iBeaconIdx)
{
	local stGameData sGameData;
	local stGameTypeAndMap sMapAndGame;
	local stRemotePlayers remPlayer;
	local int j;

	sGameData.bUsePassword = m_ClientBeacon.GetLocked(iBeaconIdx);
	sGameData.bDedicatedServer = m_ClientBeacon.GetDedicated(iBeaconIdx);
	sGameData.iRoundsPerMatch = int(m_ClientBeacon.GetRoundsPerMap(iBeaconIdx));
	sGameData.iRoundTime = int(m_ClientBeacon.GetRoundTime(iBeaconIdx));
	sGameData.iBetTime = int(m_ClientBeacon.GetBetTime(iBeaconIdx));
	sGameData.iBombTime = int(m_ClientBeacon.GetBombTime(iBeaconIdx));
	sGameData.bShowNames = m_ClientBeacon.GetShowEnemyNames(iBeaconIdx);
	sGameData.bInternetServer = m_ClientBeacon.GetInternetServer(iBeaconIdx);
	sGameData.bFriendlyFire = m_ClientBeacon.GetFriendlyFire(iBeaconIdx);
	sGameData.bAutoBalTeam = m_ClientBeacon.GetAutoBalanceTeam(iBeaconIdx);
	sGameData.bRadar = m_ClientBeacon.GetRadar(iBeaconIdx);
	sGameData.bTKPenalty = m_ClientBeacon.GetTKPenalty(iBeaconIdx);
	sGameData.iPort = m_ClientBeacon.GetPortNumber(iBeaconIdx);
	sGameData.szGameDataGameType = m_ClientBeacon.GetCurrGameType(iBeaconIdx);
	sGameData.szName = m_ClientBeacon.GetSvrName(iBeaconIdx);
	sGameData.szModName = m_ClientBeacon.GetModName(iBeaconIdx);
	sGameData.iNumTerro = m_ClientBeacon.GetNumTerrorists(iBeaconIdx);
	sGameData.bAIBkp = m_ClientBeacon.GetAIBackup(iBeaconIdx);
	sGameData.bRotateMap = m_ClientBeacon.GetRotateMap(iBeaconIdx);
	sGameData.bForceFPWeapon = m_ClientBeacon.GetForceFirstPersonWeapon(iBeaconIdx);
	sGameData.bPunkBuster = m_ClientBeacon.GetPunkBusterEnabled(iBeaconIdx);
	sGameData.szGameVersion = m_ClientBeacon.GetServerGameVersion(iBeaconIdx);
	sGameData.iMaxPlayer = m_ClientBeacon.GetMaxPlayers(iBeaconIdx);
	sGameData.iNbrPlayer = m_ClientBeacon.GetNumPlayers(iBeaconIdx);
	sGameData.szCurrentMap = m_ClientBeacon.GetFirstMapName(iBeaconIdx);
	sGameData.gameMapList.Remove(0, sGameData.gameMapList.Length);
	j = 0;
	J0x339:

	// End:0x3BF [Loop If]
	if((j < m_ClientBeacon.GetMapListSize(iBeaconIdx)))
	{
		sMapAndGame.szMap = m_ClientBeacon.GetOneMapName(iBeaconIdx, j);
		sMapAndGame.szGameType = m_ClientBeacon.GetGameType(iBeaconIdx, j);
		sGameData.gameMapList[j] = sMapAndGame;
		(j++);
		// [Loop Continue]
		goto J0x339;
	}
	sGameData.PlayerList.Remove(0, sGameData.PlayerList.Length);
	j = 0;
	J0x3DD:

	// End:0x4AB [Loop If]
	if((j < m_ClientBeacon.GetPlayerListSize(iBeaconIdx)))
	{
		remPlayer.szAlias = m_ClientBeacon.GetPlayerName(iBeaconIdx, j);
		remPlayer.szTime = m_ClientBeacon.GetPlayerTime(iBeaconIdx, j);
		remPlayer.iPing = m_ClientBeacon.GetPlayerPingTime(iBeaconIdx, j);
		remPlayer.iSkills = m_ClientBeacon.GetPlayerKillCount(iBeaconIdx, j);
		sGameData.PlayerList[j] = remPlayer;
		(j++);
		// [Loop Continue]
		goto J0x3DD;
	}
	return sGameData;
	return;
}

function SortPlayersByKills(bool _bAscending, int _iIdx)
{
	local int i, j;
	local bool bSwap;
	local int iListSize;
	local stRemotePlayers tempPlayer;

	iListSize = m_GameServerList[_iIdx].sGameData.PlayerList.Length;
	i = 0;
	J0x23:

	// End:0x195 [Loop If]
	if((i < (iListSize - 1)))
	{
		j = 0;
		J0x3C:

		// End:0x18B [Loop If]
		if((j < ((iListSize - 1) - i)))
		{
			// End:0xAD
			if(_bAscending)
			{
				bSwap = (m_GameServerList[_iIdx].sGameData.PlayerList[j].iSkills > m_GameServerList[_iIdx].sGameData.PlayerList[(j + 1)].iSkills);				
			}
			else
			{
				bSwap = (m_GameServerList[_iIdx].sGameData.PlayerList[j].iSkills < m_GameServerList[_iIdx].sGameData.PlayerList[(j + 1)].iSkills);
			}
			// End:0x181
			if(bSwap)
			{
				tempPlayer = m_GameServerList[_iIdx].sGameData.PlayerList[j];
				m_GameServerList[_iIdx].sGameData.PlayerList[j] = m_GameServerList[_iIdx].sGameData.PlayerList[(j + 1)];
				m_GameServerList[_iIdx].sGameData.PlayerList[(j + 1)] = tempPlayer;
			}
			(j++);
			// [Loop Continue]
			goto J0x3C;
		}
		(i++);
		// [Loop Continue]
		goto J0x23;
	}
	return;
}

function int GetTotalPlayers()
{
	local int i, iTotal, iMaxPlayers;

	iTotal = 0;
	iMaxPlayers = NativeGetMaxPlayers();
	i = 0;
	J0x17:

	// End:0x89 [Loop If]
	if((i < m_GameServerList.Length))
	{
		// End:0x7F
		if(((m_GameServerList[i].sGameData.iNbrPlayer <= iMaxPlayers) && (m_GameServerList[i].sGameData.iNbrPlayer > 0)))
		{
			(iTotal += m_GameServerList[i].sGameData.iNbrPlayer);
		}
		(i++);
		// [Loop Continue]
		goto J0x17;
	}
	return iTotal;
	return;
}

// NEW IN 1.60
event GetLobbyAndGroupID(out int _iLobbyID, out int _iGroupID)
{
	// End:0x40
	if((m_ClientBeacon != none))
	{
		_iLobbyID = m_ClientBeacon.PreJoinInfo.iLobbyID;
		_iGroupID = m_ClientBeacon.PreJoinInfo.iGroupID;		
	}
	else
	{
		_iLobbyID = 0;
		_iGroupID = 0;
	}
	return;
}


// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var ucGlobalIDK_GlobalID_size
// REMOVED IN 1.60: var bDeathMatch
// REMOVED IN 1.60: var bTeamDeathMatch
// REMOVED IN 1.60: var bDisarmBomb
// REMOVED IN 1.60: var bHostageRescueAdv
// REMOVED IN 1.60: var bEscortPilot
// REMOVED IN 1.60: var bMission
// REMOVED IN 1.60: var bTerroristHunt
// REMOVED IN 1.60: var bTerroristHuntAdv
// REMOVED IN 1.60: var bScatteredHuntAdv
// REMOVED IN 1.60: var bCaptureTheEnemyAdv
// REMOVED IN 1.60: var bKamikaze
// REMOVED IN 1.60: var bHostageRescueCoop
// REMOVED IN 1.60: var bDefend
// REMOVED IN 1.60: var bRecon
// REMOVED IN 1.60: var bSquadDeathMatch
// REMOVED IN 1.60: var bSquadTeamDeathMatch
// REMOVED IN 1.60: var bDebugGameMode
// REMOVED IN 1.60: var bUnlockedOnly
// REMOVED IN 1.60: var bFavoritesOnly
// REMOVED IN 1.60: var bDedicatedServersOnly
// REMOVED IN 1.60: var bServersNotEmpty
// REMOVED IN 1.60: var bServersNotFull
// REMOVED IN 1.60: var bResponding
// REMOVED IN 1.60: var bPunkBusterServerOnly
// REMOVED IN 1.60: var szHasPlayer
// REMOVED IN 1.60: var iFasterThan
// REMOVED IN 1.60: var m_Filters
// REMOVED IN 1.60: var m_bIndRefrInProgress
// REMOVED IN 1.60: function NativeResetSvrContainer
// REMOVED IN 1.60: function NativeFillSvrContainer
// REMOVED IN 1.60: function NativeSetOwnSvrPort
// REMOVED IN 1.60: function NativeGetLobbyID
// REMOVED IN 1.60: function NativeGetGroupID
// REMOVED IN 1.60: function UpdateFilters
