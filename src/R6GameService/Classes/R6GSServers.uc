//=============================================================================
// R6GSServers - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6GameServices.uc : This class contains all inofrmation and functions 
//  for connecting to a gameservice or master server
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/02/20 * Created by John Bennett
//============================================================================//
class R6GSServers extends R6ServerList
    native
    config;

var config byte m_ucActivationID[16];  // CDKey validation server activation ID
var config int m_iRSCDKeyPort;
var config int m_iModCDKeyPort;
var config int m_iRegSvrPort;  // Port use for the register server communication
var int m_iGSNumPlayers;  // Max number of players recieved from ubi.com client
var config bool m_bValidActivationID;  // CDKey validation server activation ID valid flag
// Temporary label to disable CDKEY code
var config bool m_bUseCDKey;
var bool m_bStartedByGSClient;
var bool m_bUbiComClientDied;  // The ubi.com client is not reponding
var bool m_bUbiComRoomDestroyed;  // The ubi.com room has been destroyed
// Usrename and password for ubi.com account entered
var bool m_bUbiAccntInfoEntered;
var bool m_bInitGame;  // initgame has been called
var bool m_bLoggedInUbiDotCom;  // Logged in to ubi.com
var bool m_bAutoLoginInProgress;  // Auto log in of the player is in progress
var bool m_bAutoLoginFailed;  // Auto log in failed, reset in menu system
var bool m_bRefreshFinished;  // The list is finished being
var float m_fMaxTimeForResponse;
var R6ModGSInfo m_ModGSInfo;
var config string m_szUbiRemFileURL;  // ubi.com remote file URL
var config string m_szGSVersion;  // The version of the gs-game
var config string m_szGlobalID;  // ubi globalID (string)
var config string m_szSavedPwd;  // Saved user password for GameService
var string m_szUbiHomePage;  // ubi.com home page
var string m_szPassword;  // User password for GameService
var string m_szGSInitFileName;
var string m_szGSClientIP;  // IP address recieved from ubi.com client
var string m_szGSServerName;  // Server name recieved from ubi.com client
var string m_szGSPassword;  // Game password recieved from ubi.com client

// Export UR6GSServers::execInitialize(FFrame&, void* const)
//=============================================================================
// Initialize the game service software, call native function to download 
// data from ubi.com.
//=============================================================================
native(3500) final function bool Initialize();

// Export UR6GSServers::execInitGSCDKey(FFrame&, void* const)
native(3501) final function bool InitGSCDKey();

// Export UR6GSServers::execInitializeMSClient(FFrame&, void* const)
//=============================================================================
// Establish initial connection to the server
//=============================================================================
native(3502) final function bool InitializeMSClient();

// Export UR6GSServers::execUnInitializeMSClient(FFrame&, void* const)
//=============================================================================
// Uninitialize the MSClient SDK (logout)
//=============================================================================
native(3510) final function bool UnInitializeMSClient();

// Export UR6GSServers::execRefreshServers(FFrame&, void* const)
native(3520) final function RefreshServers();

// Export UR6GSServers::execRefreshOneServer(FFrame&, void* const)
//===========================================================================
// RefreshOneServer - Start process to refresh an indivisual server.
//===========================================================================
native(3521) final function RefreshOneServer(int iIdx);

// Export UR6GSServers::execIsRefreshServersInProgress(FFrame&, void* const)
// NEW IN 1.60
native(3522) final function bool IsRefreshServersInProgress();

// Export UR6GSServers::execStopRefreshServers(FFrame&, void* const)
// NEW IN 1.60
native(3523) final function StopRefreshServers();

// Export UR6GSServers::execNativeGetSeconds(FFrame&, void* const)
native(3530) final function float NativeGetSeconds();

// Export UR6GSServers::execNativeGetMSClientInitialized(FFrame&, void* const)
native(3531) final function bool NativeGetMSClientInitialized();

// Export UR6GSServers::execGetMaxUbiServerNameSize(FFrame&, void* const)
//===============================================================================
// This function returns the maximum allowed size of the server name, this is 
// limited by ubi.com
//===============================================================================
native(3532) final function int GetMaxUbiServerNameSize();

// Export UR6GSServers::execNativeSetMatchResult(FFrame&, void* const)
native(3540) final function NativeSetMatchResult(string szUbiUserID, int iField, int iValue);

// Export UR6GSServers::execSetLastServerQueried(FFrame&, void* const)
native(3541) final function SetLastServerQueried(string szIPAddress);

// Export UR6GSServers::execNativeIsRouterDisconnect(FFrame&, void* const)
// NEW IN 1.60
native(3550) final function bool NativeIsRouterDisconnect();

// Export UR6GSServers::execNativeIsWaitingForGSInit(FFrame&, void* const)
// NEW IN 1.60
native(3551) final function bool NativeIsWaitingForGSInit();

// Export UR6GSServers::execNativeIsGSReadyToChangeMod(FFrame&, void* const)
// NEW IN 1.60
native(3552) final function bool NativeIsGSReadyToChangeMod();

// Export UR6GSServers::execNativeUpdateServer(FFrame&, void* const)
native(3560) final function NativeUpdateServer();

// Export UR6GSServers::execNativeLogOutServer(FFrame&, void* const)
// NEW IN 1.60
native(3561) final function NativeLogOutServer(GameReplicationInfo _GRI);

// Export UR6GSServers::execNativeProcessIcmpPing(FFrame&, void* const)
native(3562) final function bool NativeProcessIcmpPing(string _ServerIpAddress, out int piPingTime);

// Export UR6GSServers::execHandleAnyLobbyConnectionFail(FFrame&, void* const)
native(3563) final function bool HandleAnyLobbyConnectionFail();

// Export UR6GSServers::execEnterCDKey(FFrame&, void* const)
// NEW IN 1.60
native(3564) final function EnterCDKey(string _szCDKey);

// Export UR6GSServers::execNativeMSClientReqAltInfo(FFrame&, void* const)
native(3570) final function NativeMSClientReqAltInfo(int iLobbyID, int iGroupID);

// Export UR6GSServers::execNativeMSCLientJoinServer(FFrame&, void* const)
native(3571) final function NativeMSCLientJoinServer(int iLobbyID, int iGroupID, string szPassword);

function SaveInfo()
{
	local byte ATemp[16];
	local string szFileName;

	szFileName = ((("..\\" $ Class'Engine.Actor'.static.GetModMgr().GetIniFilesDir()) $ "\\") $ Class'Engine.Actor'.static.GetModMgr().GetModKeyword());
	m_ModGSInfo.SaveConfig(szFileName);
	SaveConfig();
	return;
}

// NEW IN 1.60
event InitializeMod()
{
	Created();
	// End:0x20
	if((m_ModGSInfo == none))
	{
		m_ModGSInfo = new (none) Class'R6GameService.R6ModGSInfo';
	}
	m_ModGSInfo.InitGSMod();
	return;
}

function StartAutoLogin()
{
	// End:0x30
	if((((m_szUserID != "") && (m_szPassword != "")) && m_bAutoLISave))
	{
		InitializeMSClient();
		m_bAutoLoginInProgress = true;
	}
	return;
}

//=============================================================================
// Set the user ID and password for the ubi.com account
//=============================================================================
function SetUbiAccount(string szUserID, string szPassword)
{
	m_szUserID = szUserID;
	m_szPassword = szPassword;
	return;
}

function string MyID()
{
	return m_szGlobalID;
	return;
}

// NEW IN 1.60
event int GetMaxAvailPorts()
{
	return Class'IpDrv.UdpLink'.static.GetMaxAvailPorts();
	return;
}

event string GetLocallyBoundIpAddr()
{
	local UdpBeacon _udpBeacon;

	// End:0x1D
	if((m_ClientBeacon != none))
	{
		return m_ClientBeacon.LocalIpAddress;		
	}
	else
	{
		_udpBeacon = UdpBeacon(Class'Engine.Actor'.static.GetServerBeacon());
		// End:0x4E
		if((_udpBeacon != none))
		{
			return _udpBeacon.LocalIpAddress;
		}
	}
	return "";
	return;
}

// NEW IN 1.60
event string GetConsoleStoreIP(PlayerController _aPlayerController)
{
	return WindowConsole(_aPlayerController.Player.Console).szStoreIP;
	return;
}

function int getServerListSize()
{
	return m_GameServerList.Length;
	return;
}

// NEW IN 1.60
event ProcessServerMsg(PlayerController _aPlayerController, string _szErrorMsgKey)
{
	// End:0x30
	if((_szErrorMsgKey == "BannedIP"))
	{
		R6PlayerController(_aPlayerController).ServerIndicatesInvalidCDKey(_szErrorMsgKey);		
	}
	else
	{
		// End:0x69
		if((_szErrorMsgKey != ""))
		{
			R6PlayerController(_aPlayerController).ServerIndicatesInvalidCDKey("ServerAuthNotResponding");
		}
	}
	// End:0x97
	if((R6PlayerController(_aPlayerController).m_GameService == none))
	{
		R6PlayerController(_aPlayerController).m_GameService = self;
	}
	_aPlayerController.SpecialDestroy();
	return;
}

// NEW IN 1.60
event bool IsGlobalIDBanned(R6AbstractGameInfo _GameInfo, string _szGlobalID)
{
	return _GameInfo.AccessControl.IsGlobalIDBanned(_szGlobalID);
	return;
}

// NEW IN 1.60
event string TempGetPBConnectStatus(PlayerController _aPlayerController)
{
	return _aPlayerController.GetPBConnectStatus();
	return;
}

function bool CallNativeProcessIcmpPing(string _ServerIpAddress, out int piPingTime)
{
	return NativeProcessIcmpPing(_ServerIpAddress, piPingTime);
	return;
}

function CallNativeSetMatchResult(string szUbiUserID, int iField, int iValue)
{
	NativeSetMatchResult(szUbiUserID, iField, iValue);
	return;
}

//=============================================================================
// FillCreateGameInfo Fill the m_CrGameSrvInfo structure with all the
// required data from the gameinfo, levelinfo, and beacon
//=============================================================================
event FillCreateGameInfo(GameInfo pGameInfo, LevelInfo pLevel)
{
	local R6ServerInfo pServerOptions;
	local PlayerController aPC;
	local Controller _PC;
	local int iNumPlayers, iNumMaps;
	local R6MapList MapList;
	local int iCounter;
	local stRemotePlayers sPlayer;
	local stGameTypeAndMap sMapAndGame;

	pServerOptions = Class'Engine.Actor'.static.GetServerOptions();
	iNumPlayers = 0;
	m_CrGameSrvInfo.sGameData.PlayerList.Remove(0, m_CrGameSrvInfo.sGameData.iNbrPlayer);
	_PC = pGameInfo.Level.ControllerList;
	J0x56:

	// End:0x157 [Loop If]
	if((_PC != none))
	{
		aPC = PlayerController(_PC);
		// End:0x140
		if((aPC != none))
		{
			sPlayer.szAlias = aPC.PlayerReplicationInfo.PlayerName;
			sPlayer.iPing = aPC.PlayerReplicationInfo.Ping;
			sPlayer.iSkills = aPC.PlayerReplicationInfo.m_iKillCount;
			sPlayer.szTime = DisplayTime(int((pLevel.TimeSeconds - float(aPC.PlayerReplicationInfo.StartTime))));
			m_CrGameSrvInfo.sGameData.PlayerList[iNumPlayers] = sPlayer;
			(iNumPlayers++);
		}
		_PC = _PC.nextController;
		// [Loop Continue]
		goto J0x56;
	}
	m_CrGameSrvInfo.sGameData.gameMapList.Remove(0, m_CrGameSrvInfo.sGameData.gameMapList.Length);
	MapList = pGameInfo.Spawn(Class'Engine.R6MapList');
	iCounter = 0;
	J0x196:

	// End:0x296 [Loop If]
	if((iCounter < 32))
	{
		// End:0x28C
		if((MapList.Maps[iCounter] != ""))
		{
			// End:0x202
			if((InStr(MapList.Maps[iCounter], ".") == -1))
			{
				sMapAndGame.szMap = MapList.Maps[iCounter];				
			}
			else
			{
				sMapAndGame.szMap = Left(MapList.Maps[iCounter], InStr(MapList.Maps[iCounter], "."));
			}
			sMapAndGame.szGameType = pLevel.GetGameTypeFromClassName(MapList.GameType[iCounter]);
			m_CrGameSrvInfo.sGameData.gameMapList[iNumMaps] = sMapAndGame;
			(iNumMaps++);
		}
		(iCounter++);
		// [Loop Continue]
		goto J0x196;
	}
	m_CrGameSrvInfo.sGameData.szCurrentMap = MapList.CheckCurrentMap();
	MapList.Destroy();
	// End:0x2E8
	if((m_ClientBeacon != none))
	{
		m_CrGameSrvInfo.iBeaconPort = m_ClientBeacon.boundport;		
	}
	else
	{
		// End:0x32B
		if((R6AbstractGameInfo(pGameInfo).m_UdpBeacon != none))
		{
			m_CrGameSrvInfo.iBeaconPort = R6AbstractGameInfo(pGameInfo).m_UdpBeacon.boundport;			
		}
		else
		{
			m_CrGameSrvInfo.iBeaconPort = Class'IpDrv.UdpBeacon'.default.ServerBeaconPort;
		}
	}
	m_CrGameSrvInfo.sGameData.szName = pGameInfo.GameReplicationInfo.ServerName;
	m_CrGameSrvInfo.sGameData.szModName = Class'Engine.Actor'.static.GetModMgr().m_pCurrentMod.m_szKeyWord;
	m_CrGameSrvInfo.sGameData.szPassword = pServerOptions.GamePassword;
	m_CrGameSrvInfo.sGameData.bUsePassword = pServerOptions.UsePassword;
	m_CrGameSrvInfo.sGameData.iMaxPlayer = pServerOptions.MaxPlayers;
	m_CrGameSrvInfo.sGameData.bDedicatedServer = (int(pLevel.NetMode) == int(NM_DedicatedServer));
	m_CrGameSrvInfo.sGameData.iPort = int(Mid(pLevel.GetAddressURL(), (InStr(pLevel.GetAddressURL(), ":") + 1)));
	m_CrGameSrvInfo.sGameData.bAutoBalTeam = pServerOptions.Autobalance;
	m_CrGameSrvInfo.sGameData.bFriendlyFire = pServerOptions.FriendlyFire;
	m_CrGameSrvInfo.sGameData.bInternetServer = pServerOptions.InternetServer;
	m_CrGameSrvInfo.sGameData.bShowNames = pServerOptions.ShowNames;
	m_CrGameSrvInfo.sGameData.bTKPenalty = pServerOptions.TeamKillerPenalty;
	m_CrGameSrvInfo.sGameData.bRadar = pServerOptions.AllowRadar;
	m_CrGameSrvInfo.sGameData.iRoundsPerMatch = pServerOptions.RoundsPerMatch;
	m_CrGameSrvInfo.sGameData.szGameDataGameType = pGameInfo.m_szCurrGameType;
	m_CrGameSrvInfo.sGameData.iBetTime = pServerOptions.BetweenRoundTime;
	m_CrGameSrvInfo.sGameData.iBombTime = pServerOptions.BombTime;
	m_CrGameSrvInfo.sGameData.iNbrPlayer = iNumPlayers;
	m_CrGameSrvInfo.sGameData.iNumMaps = iNumMaps;
	m_CrGameSrvInfo.sGameData.iRoundTime = pServerOptions.RoundTime;
	m_CrGameSrvInfo.sGameData.szMessageOfDay = pServerOptions.MOTD;
	m_CrGameSrvInfo.sGameData.szGameType = pLevel.GetGameNameLocalization(m_CrGameSrvInfo.sGameData.szGameDataGameType);
	m_CrGameSrvInfo.sGameData.bAdversarial = pLevel.IsGameTypeAdversarial(m_CrGameSrvInfo.sGameData.szGameDataGameType);
	m_CrGameSrvInfo.sGameData.iNumTerro = pServerOptions.NbTerro;
	m_CrGameSrvInfo.sGameData.bAIBkp = pServerOptions.AIBkp;
	m_CrGameSrvInfo.sGameData.bRotateMap = pServerOptions.RotateMap;
	m_CrGameSrvInfo.sGameData.bForceFPWeapon = pServerOptions.ForceFPersonWeapon;
	m_CrGameSrvInfo.sGameData.bPunkBuster = Class'Engine.Actor'.static.IsPBServerEnabled();
	return;
}

//===============================================================================
// DisplayTime: display the time in min (have to be in sec)
//===============================================================================
function string DisplayTime(int _iTimeToConvert)
{
	local float fTemp;
	local int iMin, iSec, ITemp;
	local string szTemp, szTime;

	iMin = 0;
	iSec = _iTimeToConvert;
	// End:0x54
	if((_iTimeToConvert >= 60))
	{
		fTemp = (float(_iTimeToConvert) / float(60));
		iMin = int(fTemp);
		iSec = (_iTimeToConvert - (iMin * 60));
	}
	// End:0x7F
	if((iSec < 10))
	{
		szTime = ((string(iMin) $ ":0") $ string(iSec));		
	}
	else
	{
		szTemp = string(iSec);
		szTemp = Left(szTemp, 2);
		szTime = ((string(iMin) $ ":") $ szTemp);
	}
	return szTime;
	return;
}

//===============================================================================
// GetSelectedServerIP:  Return the IP address of the selected server, include
// a check to make sure the server is responding, else try the alternate IP.
// Also remove the port number.
//===============================================================================
function string GetSelectedServerIP()
{
	local string szIPAddress, szAltIPAddress;

	szIPAddress = Left(m_GameServerList[m_iSelSrvIndex].szIPAddress, InStr(m_GameServerList[m_iSelSrvIndex].szIPAddress, ":"));
	szAltIPAddress = Left(m_GameServerList[m_iSelSrvIndex].szAltIPAddress, InStr(m_GameServerList[m_iSelSrvIndex].szAltIPAddress, ":"));
	// End:0xA5
	if((m_GameServerList[m_iSelSrvIndex].iPing >= NativeGetPingTimeOut()))
	{
		// End:0xA5
		if((NativeGetPingTime(szIPAddress) >= NativeGetPingTimeOut()))
		{
			// End:0xA5
			if((NativeGetPingTime(szAltIPAddress) < NativeGetPingTimeOut()))
			{
				m_GameServerList[m_iSelSrvIndex].bUseAltIP = true;
			}
		}
	}
	// End:0xCD
	if(m_GameServerList[m_iSelSrvIndex].bUseAltIP)
	{
		return m_GameServerList[m_iSelSrvIndex].szAltIPAddress;		
	}
	else
	{
		return m_GameServerList[m_iSelSrvIndex].szIPAddress;
	}
	return;
}

//===============================================================================
// This function has to inform the server that the end of round (a Ubi match) data
// has been sent to Ubi.com
//===============================================================================
event EndOfRoundDataSent()
{
	R6PlayerController(m_LocalPlayerController).ServerEndOfRoundDataSent();
	return;
}

event HandleNewLobbyConnection(LevelInfo _Level)
{
	local Controller P;

	P = _Level.ControllerList;
	J0x14:

	// End:0xBA [Loop If]
	if((P != none))
	{
		// End:0xA3
		if(((R6PlayerController(P) != none) && (Viewport(R6PlayerController(P).Player) == none)))
		{
			R6PlayerController(P).ClientNewLobbyConnection(_Level.Game.GameReplicationInfo.m_iGameSvrLobbyID, _Level.Game.GameReplicationInfo.m_iGameSvrGroupID);
		}
		P = P.nextController;
		// [Loop Continue]
		goto J0x14;
	}
	return;
}

defaultproperties
{
	m_iRSCDKeyPort=5777
	m_iModCDKeyPort=10777
	m_iRegSvrPort=6777
	m_fMaxTimeForResponse=10.0000000
	m_szUbiRemFileURL="http://gsconnect.ubisoft.com/gsinit.php?user=%s&dp=%s"
	m_szGSVersion="1.0"
	m_szUbiHomePage="http://www.ubi.com/login/newuser?l=%s"
	m_szGSInitFileName="./GSRouters.dat"
	m_iSelSrvIndex=-1
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var szUserId
// REMOVED IN 1.60: var szMessage
// REMOVED IN 1.60: var szAlias
// REMOVED IN 1.60: var iStatus
// REMOVED IN 1.60: var iGroupID
// REMOVED IN 1.60: var iLobbySrvID
// REMOVED IN 1.60: var m_PingReqList
// REMOVED IN 1.60: var m_bGameServiceInit
// REMOVED IN 1.60: var m_bConnectedToServer
// REMOVED IN 1.60: var m_bLoggedInToServer
// REMOVED IN 1.60: var m_bLoggedInToLobbyService
// REMOVED IN 1.60: var m_bLoggedInToFriendService
// REMOVED IN 1.60: var m_bCDKeyNotUsed
// REMOVED IN 1.60: var m_bMODCDKeyRequest
// REMOVED IN 1.60: var m_bServerJoined
// REMOVED IN 1.60: var m_bRegSrvrConnectionLost
// REMOVED IN 1.60: var m_bGSClientInitialized
// REMOVED IN 1.60: var m_bRefreshInProgress
// REMOVED IN 1.60: var m_bMSRequestFinished
// REMOVED IN 1.60: var m_bPingsPending
// REMOVED IN 1.60: var m_eMenuLoginUbidotcom
// REMOVED IN 1.60: var m_eMenuLoginFailReason
// REMOVED IN 1.60: var m_eMenuCreateAccount
// REMOVED IN 1.60: var m_eMenuCrAcctFailReason
// REMOVED IN 1.60: var m_eMenuCreateGame
// REMOVED IN 1.60: var m_eMenuCrGameFailReason
// REMOVED IN 1.60: var m_eMenuCDKeyNotUsed
// REMOVED IN 1.60: var m_eMenuCDKeyFailReason
// REMOVED IN 1.60: var m_eMenuJoinLobby
// REMOVED IN 1.60: var m_eMenuLoginMasterSvr
// REMOVED IN 1.60: var m_eMenuLogMasSvrFailReason
// REMOVED IN 1.60: var m_eMenuLoginRegServer
// REMOVED IN 1.60: var m_eMenuUpdateServer
// REMOVED IN 1.60: var m_eMenuGetCDKeyActID
// REMOVED IN 1.60: var m_eMenuCDKeyAuthorization
// REMOVED IN 1.60: var m_eMenuUserValidation
// REMOVED IN 1.60: var m_eMenuJoinServer
// REMOVED IN 1.60: var m_eMenuJoinRoomFailReason
// REMOVED IN 1.60: var m_eGSGameState
// REMOVED IN 1.60: var m_eRSReqState
// REMOVED IN 1.60: var m_iWaitModulePort
// REMOVED IN 1.60: var m_iLobbyIndex
// REMOVED IN 1.60: var m_szNetGameName
// REMOVED IN 1.60: var m_szUBIClientVersion
// REMOVED IN 1.60: var m_szCDKey
// REMOVED IN 1.60: var m_szUbiGuestAcct
// REMOVED IN 1.60: var m_ucProcessActivationID16
// REMOVED IN 1.60: var m_szRSGlobalID
// REMOVED IN 1.60: var m_szFirstName
// REMOVED IN 1.60: var m_szLastName
// REMOVED IN 1.60: var m_szCountry
// REMOVED IN 1.60: var m_szEmail
// REMOVED IN 1.60: var m_iOwnGroupID
// REMOVED IN 1.60: var m_iOwnLobbySrvID
// REMOVED IN 1.60: var m_szAuthorizationID
// REMOVED IN 1.60: var m_szRSAuthorizationID
// REMOVED IN 1.60: var m_szModAuthorizationID
// REMOVED IN 1.60: var m_szRegSvrUserID
// REMOVED IN 1.60: var m_iGroupID
// REMOVED IN 1.60: var m_iLobbySrvID
// REMOVED IN 1.60: var m_iRoomCreatedGroupID
// REMOVED IN 1.60: var m_bPingReceived
// REMOVED IN 1.60: var m_iRetryTime
// REMOVED IN 1.60: var m_bUpdateServer
// REMOVED IN 1.60: var m_GaveServerID
// REMOVED IN 1.60: var m_iMaxAvailPorts
// REMOVED IN 1.60: var m_szGSClientAltIP
// REMOVED IN 1.60: var m_eLoginRouterRequest
// REMOVED IN 1.60: var m_eLoginWaitModuleRequest
// REMOVED IN 1.60: var m_eJoinWaitModuleRequest
// REMOVED IN 1.60: var m_eCreateAccountRequest
// REMOVED IN 1.60: var m_eLoginFriendServiceRequest
// REMOVED IN 1.60: var m_eLoginLobbyServiceRequest
// REMOVED IN 1.60: var m_eCreateGameRequest
// REMOVED IN 1.60: var m_eCDKeyNotUsedRequest
// REMOVED IN 1.60: var m_eJoinLobbyRequest
// REMOVED IN 1.60: var m_eJoinRoomRequest
// REMOVED IN 1.60: var m_eMSClientInitRequest
// REMOVED IN 1.60: var m_eGameStartRequest
// REMOVED IN 1.60: var m_eGameReadyRequest
// REMOVED IN 1.60: var m_eGameConnectedRequest
// REMOVED IN 1.60: var m_eRegServerLoginRouterRequest
// REMOVED IN 1.60: var m_eRegServerGetLobbiesRequest
// REMOVED IN 1.60: var m_eRegServerRegOnLobbyRequest
// REMOVED IN 1.60: var m_eRegServerConnectRequest
// REMOVED IN 1.60: var m_eRegServerLoginRequest
// REMOVED IN 1.60: var m_eRegServerUpdateRequest
// REMOVED IN 1.60: var m_eUserValidationRequest
// REMOVED IN 1.60: var m_eJoinServerRequest
// REMOVED IN 1.60: var m_fLoginRouterStartTime
// REMOVED IN 1.60: var m_fLoginWaitModuleStartTime
// REMOVED IN 1.60: var m_fJoinWaitModuleStartTime
// REMOVED IN 1.60: var m_fCreateAccountStartTime
// REMOVED IN 1.60: var m_fLoginFriendServiceStartTime
// REMOVED IN 1.60: var m_fLoginLobbyServiceStartTime
// REMOVED IN 1.60: var m_fCDKeyStartTime
// REMOVED IN 1.60: var m_fCreateGameStartTime
// REMOVED IN 1.60: var m_fMSClientInitStartTime
// REMOVED IN 1.60: var m_fJoinLobbyStartTime
// REMOVED IN 1.60: var m_fJoinRoomStartTime
// REMOVED IN 1.60: var m_fGameStartStartTime
// REMOVED IN 1.60: var m_fGameReadyStartTime
// REMOVED IN 1.60: var m_fGameConnectedStartTime
// REMOVED IN 1.60: var m_fRegServerRouterLoginTime
// REMOVED IN 1.60: var m_fRegServerGetLobbiesTime
// REMOVED IN 1.60: var m_fRegServerRegOnLobbyTime
// REMOVED IN 1.60: var m_fRegServerConnectTime
// REMOVED IN 1.60: var m_fRegServerLoginTime
// REMOVED IN 1.60: var m_fRegServerUpdateTime
// REMOVED IN 1.60: var m_fCDKeyGetActIDTime
// REMOVED IN 1.60: var m_fCDKeyGetAuthorizationTime
// REMOVED IN 1.60: var m_fUserValidationTime
// REMOVED IN 1.60: var m_fJoinServerTime
// REMOVED IN 1.60: var m_fRefreshTime
// REMOVED IN 1.60: var bShowLog
// REMOVED IN 1.60: function NativeInit
// REMOVED IN 1.60: function NativePollCallbacks
// REMOVED IN 1.60: function NativeReceiveServer
// REMOVED IN 1.60: function NativeReceiveAltInfo
// REMOVED IN 1.60: function NativeInitRegServer
// REMOVED IN 1.60: function NativeRegServerRouterLogin
// REMOVED IN 1.60: function NativeRegServerGetLobbies
// REMOVED IN 1.60: function NativeRegisterServer
// REMOVED IN 1.60: function NativeRouterDisconnect
// REMOVED IN 1.60: function NativeServerLogin
// REMOVED IN 1.60: function NativeGetInitialized
// REMOVED IN 1.60: function NativePingReq
// REMOVED IN 1.60: function NativeInitCDKey
// REMOVED IN 1.60: function NativeUnInitCDKey
// REMOVED IN 1.60: function NativeCDKeyValidateUser
// REMOVED IN 1.60: function NativeReceiveValidation
// REMOVED IN 1.60: function NativeGetLoggedInUbiDotCom
// REMOVED IN 1.60: function NativeRegServerMemberJoin
// REMOVED IN 1.60: function NativeRegServerMemberLeave
// REMOVED IN 1.60: function NativeRequestMSList
// REMOVED IN 1.60: function NativeInitMSClient
// REMOVED IN 1.60: function NativeUnInitMSClient
// REMOVED IN 1.60: function NativeMSCLientLeaveServer
// REMOVED IN 1.60: function NativeRefreshServer
// REMOVED IN 1.60: function NativeRegServerServerClose
// REMOVED IN 1.60: function NativeGetRegServerIntialized
// REMOVED IN 1.60: function NativeRegServerShutDown
// REMOVED IN 1.60: function NativeGetServerRegistered
// REMOVED IN 1.60: function AddPlayerToIDList
// REMOVED IN 1.60: function PlayerIsInIDList
// REMOVED IN 1.60: function GetGlobalIdFromPlayerIDList
// REMOVED IN 1.60: function RemoveFromIDList
// REMOVED IN 1.60: function GetIDListIPAddr
// REMOVED IN 1.60: function GetIDListAuthID
// REMOVED IN 1.60: function GetIDListSize
// REMOVED IN 1.60: function NativeInitGSClient
// REMOVED IN 1.60: function NativeGSClientPostMessage
// REMOVED IN 1.60: function NativeGSClientUpdateServerInfo
// REMOVED IN 1.60: function NativeCheckGSClientAlive
// REMOVED IN 1.60: function NativeServerRoundStart
// REMOVED IN 1.60: function NativeServerRoundFinish
// REMOVED IN 1.60: function SetGSClientComInterface
// REMOVED IN 1.60: function LogGSVersion
// REMOVED IN 1.60: function TestRegServerLobbyDisconnect
// REMOVED IN 1.60: function NativeMSClientServerConnected
// REMOVED IN 1.60: function CleanPlayerIDList
// REMOVED IN 1.60: function SetGameServiceRequestState
// REMOVED IN 1.60: function GetGameServiceRequestState
// REMOVED IN 1.60: function SetRegisteredWithMS
// REMOVED IN 1.60: function GetRegisteredWithMS
// REMOVED IN 1.60: function SetCDKeyInitialised
// REMOVED IN 1.60: function GetCDKeyInitialised
// REMOVED IN 1.60: function NativeCDKeyDisconnecUser
// REMOVED IN 1.60: function DisconnectAllCDKeyPlayers
// REMOVED IN 1.60: function ResetAuthId
// REMOVED IN 1.60: function OnSameSubNet
// REMOVED IN 1.60: function RequestGSCDKeyActID
// REMOVED IN 1.60: function CancelGSCDKeyActID
// REMOVED IN 1.60: function RequestGSCDKeyAuthID
// REMOVED IN 1.60: function NativeProcessAuthIdRequest
// REMOVED IN 1.60: function Created
// REMOVED IN 1.60: function InitModInfo
// REMOVED IN 1.60: function GameServiceManager
// REMOVED IN 1.60: function ProcessMSClientInitRequest
// REMOVED IN 1.60: function ProcessRegServerLoginRouterRequest
// REMOVED IN 1.60: function ProcessRegServerGetLobbiesRequest
// REMOVED IN 1.60: function ProcessRegServerRegOnLobbyRequest
// REMOVED IN 1.60: function ProcessRegServerLoginRequest
// REMOVED IN 1.60: function ProcessRegServerUpdateRequest
// REMOVED IN 1.60: function ProcessJoinServerRequest
// REMOVED IN 1.60: function InitializeRegServer
// REMOVED IN 1.60: function LoginRegServer
// REMOVED IN 1.60: function InitProcessUpdateUbiServer
// REMOVED IN 1.60: function UpdateServerRegServer
// REMOVED IN 1.60: function UpdateServerUbiCom
// REMOVED IN 1.60: function joinServer
// REMOVED IN 1.60: function LogOutServer
// REMOVED IN 1.60: function MasterServerManager
// REMOVED IN 1.60: function ProcessInternetSrv
// REMOVED IN 1.60: function ProcessPC_CDKeyRequest
// REMOVED IN 1.60: function SetGlobalIDToString
// REMOVED IN 1.60: function SetGSGameState
// REMOVED IN 1.60: function IsModCDKeyProcess
// REMOVED IN 1.60: function RequestModCDKeyProcess
// REMOVED IN 1.60: function LogDebugProcessCDKeyRequest
// REMOVED IN 1.60: function CopyActivationIDInByteArray
