//=============================================================================
//  R6GameServices.uc : This class contains all inofrmation and functions 
//  for connecting to a gameservice or master server
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/02/20 * Created by John Bennett
//============================================================================//

class R6GSServers extends R6ServerList
	native;

const K_MAX_SIZE_UBISERVERNAME = 32;
const K_TimeRetryConnect  = 15;   // Time interval for retrying connecting to ubi.com

enum ERegServerRequestState
{
    ERSREQ_NONE,
    ERSREQ_INIT,
    ERSREQ_LOGIN,
    ERSREQ_SUCCESS,
    ERSREQ_FAILURE
};



// States of requests made by game service code to the ubi.com sdk

enum EGSRequestState
{
    EGSREQ_NONE,
	EGSREQ_FIRST_PASS,
	EGSREQ_WAITING_FOR_RESPONSE,
	EGSREQ_FAILED,
    EGSREQ_CONNECT_FAILED,
    EGSREQ_INUSE_FAILED,
    EGSREQ_SUCCESS,
    EGSREQ_PROCESS_FAILURE

};

// States of requests made by the menu system to the game service code

enum EMenuRequestState
{
    EMENU_REQ_NONE,
    EMENU_REQ_PENDING,
    EMENU_REQ_SUCCESS,
    EMENU_REQ_FAILURE,
    EMENU_REQ_TIMEOUT,
    EMENU_REQ_TIMEOUT_ERROR,
    EMENU_REQ_INUSE_ERROR,
    EMENU_REQ_NOTCHALLENGED,
    EMENU_REQ_INT_ERROR
};

// States of game when controlled by the ubi.com client (GS CLIENT SDK)

enum EGSGameState
{
    EGS_WAITING_FOR_GS_INIT,    // Waiting for the GS to initialize the game as either client or server

    EGS_CLIENT_INIT_RCVD,       // The game has received a "Client Init" message from ubi.com client
    EGS_CLIENT_WAITING_CHSTA,   // Waiting for the change state message from ubi.com client
    EGS_CLIENT_CHSTA_RCVD,      // The game has received a "Change State" message from ubi.com client
    EGS_CLIENT_IN_GAME,         // Client is in the game or in the process of joining/quitting game

    EGS_SERVER_INIT_RCVD,       // The game has received a "Server Init" message from ubi.com client
    EGS_SERVER_WAITING_CHSTA,   // Waiting for the change state message from ubi.com client
    EGS_SERVER_CHSTA_RCVD,      // The game has received a "Change State" message from ubi.com client
    EGS_SERVER_SETTING_UP_GAME, // User can set server options, then launch game when ready
    EGS_TERMINATE_RCVD,         // Recieved a command to terminate the game
    EGS_SERVER_READY            // Server ready to accept players
};

enum EGSMESSAGE_ID
{
    EGSMESSAGE_INITMASTERSESSION_AK,
    EGSMESSAGE_MASTERSESSION_AK,
    EGSMESSAGE_READYTORECEIVECONNECTIONS,
    EGSMESSAGE_INITCLIENTSESSION_AK,
    EGSMESSAGE_CLIENTSESSION_AK,
    EGSMESSAGE_SWITCHTOGS
};


enum EFailureReasons
{
    EFAIL_DEFAULT,                  // Reason not known, use default message
    EFAIL_SERVER_CONNECT,           // Cannot connect to the game service (not accessible)
    EFAIL_PASSWORDNOTCORRECT,       // Player has entered incorrect password
    EFAIL_ROOMFULL,                 // Cannot join ubi.com room, room is already full.
    EFAIL_ALREADYCONNECTED,         // Player account is already in use
    EFAIL_NOTREGISTERED,            // Server does not recognise the user ID, account does not exist
    EFAIL_NOTDISCONNECTED,          // Player is already connected to ubi.com
    EFAIL_PLAYERALREADYREGISTERED,  // Player tried to create an accout with a user ID that already exists
    EFAIL_TIMED_OUT,                // No reponse to request, time for respinse too long
    EFAIL_CDKEYUSED,                 // CD Key is already being used on line
    EFAIL_INVALIDCDKEY,
    EFAIL_DATABASEFAILED,
    EFAIL_BANNEDACCOUNT,
    EFAIL_BLOCKEDACCOUNT,
    EFAIL_LOCKEDACCOUNT
};

//--------------------------------------------------------------
// Structures - If any of the fields of these structures are
// changed (or if fields are added), the structure definitions 
// in R6GameService.h must also be changed.
//--------------------------------------------------------------


struct stChatMessage
{
    var string szUserId;
    var string szMessage;
};

struct stFriend
{
    var string szAlias;
    var INT    iStatus;
};

struct stLobby
{
    var INT         iGroupID;
    var INT         iLobbySrvID;
};

//------------------
// Member Lists
//------------------

//var array<stChatMessage>    m_incomingMessagesList;
//var array<stFriend>         m_FriendList;
//var array<stRemotePlayers>  m_PlayerList;
//var array<stLobby>          m_LobbyList;
//var array<INT>              m_OptionDecodeReqList;
var array<INT>              m_PingReqList;
//var array<string>           m_favoriteServersList;

//------------------
// Member variables
//------------------

var R6ModInfo     m_ModGSInfo;

// High level Flags defining the state of system

var BOOL m_bGameServiceInit;         // Game service code has been intialized
var BOOL m_bConnectedToServer;       // Initial connection established
var BOOL m_bLoggedInToServer;        // User fully logged in to server
var BOOL m_bLoggedInToLobbyService;  // User logged in to the lobby service
var BOOL m_bLoggedInToFriendService; // User logged in to the friend service
var BOOL m_bCDKeyNotUsed;            // The CD key is not being used by anyone else
var BOOL m_bMODCDKeyRequest;        // MOD CD-Key request

var BOOL m_bServerJoined;            // Flag to indicate that ubi.com believes we have joined a server
var BOOL m_bRegSrvrConnectionLost;   // The connection for the RegServer library has been lost
var BOOL m_bGSClientInitialized;     // The GG client SDK has been intialized

// Variables used to keep track of refresh status
var BOOL m_bRefreshInProgress;       // The list is currently being refreshed
var BOOL m_bRefreshFinished;         // The list is finished being
var BOOL m_bMSRequestFinished;       // Ubi.com has finished sending us servers
var INT  m_bPingsPending;            // Number of pings left to process

// Feedback labels for interface with menus (to tell menu system when requests have succeeded or failed)

var EMenuRequestState m_eMenuLoginUbidotcom;   // User logged in to ubi.com
var EFailureReasons   m_eMenuLoginFailReason;  // Reason for failure to log in to ubi.com
var EMenuRequestState m_eMenuCreateAccount;    // Create an accout for the user
var EFailureReasons   m_eMenuCrAcctFailReason; // Reason for failure to create an account
var EMenuRequestState m_eMenuCreateGame;       // Create a game (start a server)
var EFailureReasons   m_eMenuCrGameFailReason; // Reason for failure to create a game
var EMenuRequestState m_eMenuCDKeyNotUsed;     // Check that CD key is not already used by someone else
var EFailureReasons   m_eMenuCDKeyFailReason;  // Reason for failure of CD key check
var EMenuRequestState m_eMenuJoinLobby;        // User logged in to ubi.com
var EMenuRequestState m_eMenuLoginMasterSvr;   // User logged in to master server
var EFailureReasons   m_eMenuLogMasSvrFailReason; // Reason for failure to log in to master server
var EMenuRequestState m_eMenuLoginRegServer;   // User logged in to Register Server
var EMenuRequestState m_eMenuUpdateServer;     // Update server information to ubi.com
var EMenuRequestState m_eMenuGetCDKeyActID;     // Get the activation ID for this CD key
var EMenuRequestState m_eMenuCDKeyAuthorization;// Get the authorization ID for this CD key
var EMenuRequestState m_eMenuUserValidation    ;// Validate the users cdkey/authorization id
var EMenuRequestState m_eMenuJoinServer;
var EFailureReasons   m_eMenuJoinRoomFailReason;// Reason for failure to join a room
var EGSGameState      m_eGSGameState;           // Game state when under control of GS client
var ERegServerRequestState	m_eRSReqState;


// Server port numbers

var INT  m_iWaitModulePort;     // Wait module port number

// Information on the router list

//var INT  m_iRouterIndex;        // Index of router in the router list
//var INT  m_iRouterMax;          // Number of routers in the router list

// Information on the lobby list
var INT  m_iLobbyIndex;        // Index of router in the router list



// Temporary label to disable CDKEY code
var config BOOL m_bUseCDKey;

// Information saved in uw.ini file
var string m_szNetGameName;     // The ugly game name 
var string m_szUBIClientVersion;// The version of the client
var config string m_szGSVersion;       // The version of the gs-game 
var string m_szCDKey;                  // CD Key
//moved to base Abstract class for easier access from PlayerController classes.
//var config string m_szUserID;          // User login name for GameService

// Username for guest accout at ubi.com, Ubi.com requested that m_szUbiGuestAcct should not be configurable
var string m_szUbiGuestAcct;            

var config INT    m_iRSCDKeyPort;
var config INT    m_iModCDKeyPort;
var config BOOL   m_bValidActivationID;// CDKey validation server activation ID valid flag
var config BYTE   m_ucActivationID[16];// CDKey validation server activation ID
var BYTE     m_ucProcessActivationID[16];     // to process CDKey validation server activation ID
var config string m_szGlobalID;                      // ubi globalID (string)
var string          m_szRSGlobalID;             // ubi RS globalID -- related to ActID

var config string m_szUbiRemFileURL;   // ubi.com remote file URL
var string          m_szUbiHomePage;     // ubi.com home page
var config INT    m_iRegSvrPort;       // Port use for the register server communication
var config string m_szSavedPwd;        // Saved user password for GameService

// User information

var string m_szFirstName;       // Palyer's first name
var string m_szLastName;        // Palyer's last name
var string m_szCountry;         // Palyer's country
var string m_szEmail;           // Palyer's email address
var INT    m_iOwnGroupID;       // Group ID of the player local to this game
var INT    m_iOwnLobbySrvID;    // Group ID of the player local to this game
//var string m_szOwnIPAddr;       // IP Address of the local machine - Unicode string version
//var INT    m_iOwnIPAddr;        // IP Address of the local machine - Integer version

var string m_szAuthorizationID; // CDKey validation server authorization ID
var string m_szRSAuthorizationID;   // CDKey validation server authorization ID for RS
var string m_szModAuthorizationID;  // MOD CDKey validation server authorization ID

var string m_szRegSvrUserID;    // UserID used to register a server
var string m_szPassword;        // User password for GameService

// Labels to store ID of current room or lobby
var INT    m_iGroupID;
var INT    m_iLobbySrvID;
var INT    m_iRoomCreatedGroupID;

// Flag set when pings are received (so that list can be updated with new information)
var BOOL   m_bPingReceived;

// Usrename and password for ubi.com account entered
var BOOL   m_bUbiAccntInfoEntered;
var BOOL   m_bLoggedInUbiDotCom;     // Logged in to ubi.com
var INT  m_iRetryTime;              // Time at which to retry registereing with ubi.com
var BOOL m_bInitGame;               // initgame has been called
var BOOL   m_bUpdateServer;       // Flag used to indicate that the server info sent to ubi.com needs to be updated


// Details of game sever registered on ubi.com
var stLobby m_GaveServerID;        // ID of server, lobby ID and Group ID

// File used to save ubi.com URL

var string  m_szGSInitFileName;

var INT     m_iMaxAvailPorts;

var string m_szGSClientIP;          // IP address recieved from ubi.com client
var string m_szGSClientAltIP;       // Alternate IP address recieved from ubi.com client
var string m_szGSServerName;        // Server name recieved from ubi.com client
var INT    m_iGSNumPlayers;         // Max number of players recieved from ubi.com client
var string m_szGSPassword;          // Game password recieved from ubi.com client

var BOOL m_bUbiComClientDied;       // The ubi.com client is not reponding
var BOOL m_bUbiComRoomDestroyed;    // The ubi.com room has been destroyed

var BOOL m_bAutoLoginInProgress;    // Auto log in of the player is in progress
var BOOL m_bAutoLoginFailed;        // Auto log in failed, reset in menu system

// State variables for requests made to the game service SDK, used
// to keep track of the state and success/failure of calls made to the SDK

var EGSRequestState   m_eLoginRouterRequest;
var EGSRequestState   m_eLoginWaitModuleRequest;
var EGSRequestState   m_eJoinWaitModuleRequest;
var EGSRequestState   m_eCreateAccountRequest;
var EGSRequestState   m_eLoginFriendServiceRequest;
var EGSRequestState   m_eLoginLobbyServiceRequest;
var EGSRequestState   m_eCreateGameRequest;
var EGSRequestState   m_eCDKeyNotUsedRequest;
var EGSRequestState   m_eJoinLobbyRequest;
var EGSRequestState   m_eJoinRoomRequest;
var EGSRequestState   m_eMSClientInitRequest;
var EGSRequestState   m_eGameStartRequest;
var EGSRequestState   m_eGameReadyRequest;
var EGSRequestState   m_eGameConnectedRequest;
var EGSRequestState   m_eRegServerLoginRouterRequest;
var EGSRequestState   m_eRegServerGetLobbiesRequest;
var EGSRequestState   m_eRegServerRegOnLobbyRequest;
var EGSRequestState   m_eRegServerConnectRequest;
var EGSRequestState   m_eRegServerLoginRequest;
var EGSRequestState   m_eRegServerUpdateRequest;
var EGSRequestState   m_eUserValidationRequest;
var EGSRequestState   m_eJoinServerRequest;

// Time variables used to keep track of waiting time (for timeout failure)

var FLOAT             m_fLoginRouterStartTime;
var FLOAT             m_fLoginWaitModuleStartTime;
var FLOAT             m_fJoinWaitModuleStartTime;
var FLOAT             m_fCreateAccountStartTime;
var FLOAT             m_fLoginFriendServiceStartTime;
var FLOAT             m_fLoginLobbyServiceStartTime;
var FLOAT             m_fCDKeyStartTime;
var FLOAT             m_fCreateGameStartTime;
var FLOAT             m_fMSClientInitStartTime;
var FLOAT             m_fJoinLobbyStartTime;
var FLOAT             m_fJoinRoomStartTime;
var FLOAT             m_fGameStartStartTime;
var FLOAT             m_fGameReadyStartTime;
var FLOAT             m_fGameConnectedStartTime;
var FLOAT             m_fRegServerRouterLoginTime;
var FLOAT             m_fRegServerGetLobbiesTime;
var FLOAT             m_fMaxTimeForResponse;
var FLOAT             m_fRegServerRegOnLobbyTime;
var FLOAT             m_fRegServerConnectTime;
var FLOAT             m_fRegServerLoginTime;
var FLOAT             m_fRegServerUpdateTime;
var FLOAT             m_fCDKeyGetActIDTime;
var FLOAT             m_fCDKeyGetAuthorizationTime;
var FLOAT             m_fUserValidationTime;
var FLOAT             m_fJoinServerTime;
var FLOAT             m_fRefreshTime;
var BOOL              m_bStartedByGSClient;
var BOOL              bShowLog;




//-----------------------------
// Native Function definitions
// ----------------------------

native(1201) final function BOOL  NativeInit(string szLocalBoundIp);
native(1203) final function FLOAT NativeGetSeconds();
native(1205) final function       NativePollCallbacks( BOOL _bMSClient, BOOL _bCDKey, BOOL _bRegServer, BOOL _bGSClient );
native(1214) final function BOOL  NativeReceiveServer();
native(1237) final function BOOL  NativeReceiveAltInfo();
//native(1217) final function       NativeReceivePlayer();
//native(1219) final function       NativeCDKeyNotUsed();
native(1240) final function BOOL  NativeInitRegServer();
native(1241) final function       NativeRegServerRouterLogin();
native(1242) final function       NativeRegServerGetLobbies();
native(1243) final function       NativeRegisterServer();
native(1244) final function       NativeRouterDisconnect();
native(1245) final function       NativeServerLogin();
native(1248) final function BOOL  NativeGetInitialized();
native(1250) final function       NativeUpdateServer();
native(1254) final function       NativePingReq ( string szSvrName, string szIPAddress );

native(1259) final function BOOL  NativeInitCDKey(INT iRSCDKeyPort, INT iModCDKeyPort);
native(1260) final function       NativeUnInitCDKey ();
native(1261) final function INT   NativeCDKeyValidateUser( string szAuthID, BOOL bExtraTime,  BOOL bProcessMod);
//native(1262) final function        NativeCDKeyPlayerStatusReply( string szAuthID,  PlayerController.ECDKEYST_STATUS eStatus );
//native(1287) final function String NativeCDKeyGetOwnAuthID(BOOL bModWanted);
native(1264) final function       NativeReceiveValidation ();
native(1267) final function BOOL  NativeGetMSClientInitialized();
native(1268) final function BOOL  NativeGetLoggedInUbiDotCom();
native(1269) final function       NativeRegServerMemberJoin( string szUbiUserID );
native(1270) final function       NativeRegServerMemberLeave( string szUbiUserID );

native(1235) final function       NativeRequestMSList();
native(1234) final function       NativeInitMSClient();
native(1249) final function BOOL  NativeUnInitMSClient();
//native(1271) final function       NativeMSCLientJoinServer( INT uiID, string szPassword );
native(1272) final function BOOL  NativeMSCLientLeaveServer();
native(1255) final function       NativeRefreshServer ( INT iIdx );
native(1220) final function       NativeMSClientReqAltInfo( INT iLobbyID, INT iGroupID );
native(1274) final function       NativeRegServerServerClose ();
native(1275) final function BOOL  NativeGetRegServerIntialized ();
native(1276) final function       NativeRegServerShutDown ();
native(1277) final function       NativeMSCLientJoinServer( INT iLobbyID, INT iGroupID, string szPassword );
native(1204) final function BOOL  NativeGetServerRegistered();

native(1238) final function        AddPlayerToIDList( string szAuthID, string szIPAddr, string szUbiBanID, BOOL bProcessMod);
native(1239) final function BOOL   PlayerIsInIDList( string szAuthID, string szIPAddr, BOOL bProcessMod );
native(1315) final function string GetGlobalIdFromPlayerIDList( string szAuthID );
native(1290) final function        RemoveFromIDList( INT iIdx );
native(1284) final function string GetIDListIPAddr( INT iIdx );
native(1285) final function string GetIDListAuthID( INT iIdx );
native(1286) final function INT    GetIDListSize();

native(1288) final function BOOL   NativeInitGSClient();
native(1289) final function BOOL   NativeGSClientPostMessage( EGSMESSAGE_ID eMessageID );
native(1293) final function BOOL   NativeGSClientUpdateServerInfo();
native(1350) final function BOOL   NativeCheckGSClientAlive();

// warning RoundStart and Round end refers to RS rounds which is a UBI.com match
native(1294) final function         NativeServerRoundStart(INT uiMode);
native(1295) final function         NativeServerRoundFinish();
native(1296) final function         NativeSetMatchResult(string szUbiUserID, INT iField, INT iValue);
native(1298) final function BOOL    NativeProcessIcmpPing(string _ServerIpAddress, out INT piPingTime);
native(1299) final function BOOL    SetGSClientComInterface();
native(1300) final function         LogGSVersion();
native(1353) final function         TestRegServerLobbyDisconnect();
native(1354) final function         NativeMSClientServerConnected( INT iLobbyID, INT iGroupID );
native(1308) final function         CleanPlayerIDList(Controller _ControllerList);

native(1246) final function SetGameServiceRequestState( ERegServerRequestState eRegServerState );
native(1247) final function ERegServerRequestState GetGameServiceRequestState();
native(1251) final function SetRegisteredWithMS( BOOL bRegisteredWithMS );
native(1252) final function BOOL GetRegisteredWithMS();
native(1265) final function SetCDKeyInitialised( BOOL bCDKeyInitialised );
native(1266) final function BOOL GetCDKeyInitialised();
native(1263) final function NativeCDKeyDisconnecUser ( string szAuthID );
native(1307) final function DisconnectAllCDKeyPlayers();
native(1309) final function ResetAuthId();
native(1310) final function BOOL HandleAnyLobbyConnectionFail();
native(1313) final function BOOL OnSameSubNet(String szIPAddr);
native(1226) final function         RequestGSCDKeyActID();
native(1219) final function         CancelGSCDKeyActID();
native(1218) final function         RequestGSCDKeyAuthID();
native(1253) final function         SetLastServerQueried(string szIPAddress);

native(1217) final function NativeProcessAuthIdRequest(Controller _ControllerList);

function BOOL CallNativeProcessIcmpPing(string _ServerIpAddress, out INT piPingTime)
{
    return NativeProcessIcmpPing(_ServerIpAddress, piPingTime);
}

function CallNativeSetMatchResult(string szUbiUserID, INT iField, INT iValue)
{
    NativeSetMatchResult(szUbiUserID, iField, iValue);
}
function INT getServerListSize()
{
    return m_GameServerList.length;
}

//===========================================================================
// Created - Should be called when this class is spawned
//===========================================================================
function Created()
{
    local string _szEncryptedCdkey;
    GetRegistryKey("SOFTWARE\\Red Storm Entertainment\\RAVENSHIELD", "CDKey", _szEncryptedCdkey);
    if (class'eviLCore'.static.IsCDKeyValidOnMachine(_szEncryptedCdkey) )
        m_szCDKey = class'eviLCore'.static.DecryptCDKey(_szEncryptedCdkey);
    else
    {
        m_szCDKey = "";
        m_bValidActivationID = false;// CDKey validation server activation ID valid flag
    }
    
    Super.Created();
    m_szPassword = m_szSavedPwd;
    // NOTE: could not initialize the  variable m_szGSClientLaunchParam 
    // in the default properties
    // because it uses quotes as part of the string, i.e. \"
    m_bStartedByGSClient = class'Actor'.static.NativeStartedByGSClient();
    LogGSVersion();
    
    
    
    // These variables need to be different for the multiplayer demo and
    // the regular game.  Initialized here because #ifdefMPDEMO does not
    // work in the default properties.
    
    // MPF - Eric
    // retrieve this information in a special class. accessible by the Mod Manager
    InitModInfo();
    
    m_ModGSInfo = new(none) class'R6ModInfo';
    m_ModGSInfo.Created();
    
    /*
    #ifdefMPDEMO
    m_szNetGameName          = "RAVENSHIELD_DEMO";
    m_szUBIClientVersion     = "RSDEMOPC1.0";
    #endif
    #ifndefMPDEMO
    m_szNetGameName          = "RAVENSHIELD";
    m_szUBIClientVersion     = "RSPC1.2";
    #endif
    */
}

// MPF - Eric
function InitModInfo()
{
    local R6ModMgr pModManager;
    pModManager = class'Actor'.static.GetModMgr();
    
    m_szUBIClientVersion     = pModManager.GetUbiComClientVersion();
    m_szNetGameName          = pModManager.GetGameServiceGameName();
    log("UbiClientVersion: " $ m_szUBIClientVersion);
    log("m_szNetGameName: " $m_szNetGameName);
    
}
//===========================================================================
// RefreshOneServer - Start process to refresh an indivisual server.
//===========================================================================
function RefreshOneServer( INT sortedListIdx )
{
    local INT  serverListIndex;
    
    serverListIndex = m_GSLSortIdx[sortedListIdx];
    
    if ( !m_bConnectedToServer || m_bRefreshInProgress || m_bIndRefrInProgress )
        return;
    
    m_fRefreshTime = NativeGetSeconds();
    
    m_bMSRequestFinished = FALSE;
    m_bIndRefrInProgress = TRUE;
    
    m_iIndRefrIndex = serverListIndex;
    
    NativeRefreshServer( serverListIndex );
}

//==============================================================================
// GameServiceManager - Main function for connecting to a game service / 
// master server.  Checks for any feedback from the game service SDK.  
// Processes feedback and keeps track of the state of the system.  Should
// be call regularly when the multi-player pages are active.
//==============================================================================

function GameServiceManager( BOOL _bMSClient, BOOL _bCDKey, BOOL _bRegServer, BOOL _bGSClient )
{
    local FLOAT elapsedTime;       // Elapsed time waiting for response from server
    local INT   i,j;               // counter
    local INT   iIndex;
    local BOOL  bFound;            // Item found in list (i.e. already exists in list)
    local stGameData  sGameData;
    
    // --------------------------------------------------------------
    // If we are not connected to the server, there is nothing to do
    // --------------------------------------------------------------
    
    if ( !NativeGetInitialized() )
        return;
    
    // --------------------------------------
    // Trigger callback from the ubi.com SDK
    // --------------------------------------
    
    NativePollCallbacks( _bMSClient, _bCDKey, _bRegServer, _bGSClient );
    
    // -----------------------------------------------
    // Check if we have received any servers.
    // -----------------------------------------------
    
    if ( NativeReceiveServer() )
        m_bServerListChanged = TRUE;
    
    if ( NativeReceiveAltInfo() )
        m_bServerInfoChanged = TRUE;
    
    if ( m_bPingReceived )
        m_bServerListChanged = TRUE;
    
    // Process lists of pings to be requested
    
    for ( i = 0; i < m_PingReqList.Length; i++ )
    {
        NativePingReq( m_GameServerList[m_PingReqList[i]].sGameData.szName, 
            m_GameServerList[m_PingReqList[i]].szIPAddress );
    }
    m_PingReqList.Remove( 0, m_PingReqList.length );
    
    // ----------------------------------------------
    // Check status of refresh request
    // ----------------------------------------------
    
    if ( m_bRefreshInProgress )
    {
        if ( ( m_bMSRequestFinished || ( NativeGetSeconds() - m_fRefreshTime > m_fMaxTimeForResponse ) ) &&
            m_bPingsPending == 0 )
        {
            m_bRefreshInProgress = FALSE;
            m_bRefreshFinished   = TRUE;
        }
    }
    else if ( m_bIndRefrInProgress )
    {
        if ( m_bMSRequestFinished  || ( NativeGetSeconds() - m_fRefreshTime > m_fMaxTimeForResponse ) )
        {
            m_bIndRefrInProgress = FALSE;
            m_bRefreshFinished   = TRUE;
            m_GameServerList.Remove( m_iIndRefrIndex, 1 );
            m_GSLSortIdx.Remove( m_iIndRefrIndex, 1 );
        }        
    }
    
    // -------------------------------------------------------------
    // Check if we have received any player validation responses
    // -------------------------------------------------------------
    
    if ( _bRegServer )
        NativeReceiveValidation();
    
    // -----------------------------------------------------
    // Process "Initialize Master Server Client" request if active
    // -----------------------------------------------------
    ProcessMSClientInitRequest();
    
    // -----------------------------------------------------
    // Process Login to Reg Server router request
    // -----------------------------------------------------
    ProcessRegServerLoginRouterRequest();
    
    // -----------------------------------------------------
    // Process Reg Server Get Lobbies
    // -----------------------------------------------------
    ProcessRegServerGetLobbiesRequest();
    
    // -----------------------------------------------------
    // Process Reg Server Register Server On Lobby
    // -----------------------------------------------------
    ProcessRegServerRegOnLobbyRequest();
    
    // -----------------------------------------------------
    // Process Reg Server login
    // -----------------------------------------------------
    ProcessRegServerLoginRequest();
    
    // -----------------------------------------------------
    // Process Reg Server Update
    // -----------------------------------------------------
    ProcessRegServerUpdateRequest();
    
    // -----------------------------------------------------
    // Process request for to join a server
    // -----------------------------------------------------
    ProcessJoinServerRequest();
    
    return;
}  

function ProcessMSClientInitRequest()
{
    local FLOAT elapsedTime;       // Elapsed time waiting for response from server
    
    switch ( m_eMSClientInitRequest )
    {
        
        // In the first pass, call the game service SDK,
        // and check the time.  Change state to WAITING.
        
    case EGSREQ_FIRST_PASS:
        m_fMSClientInitStartTime =  NativeGetSeconds();
        m_eMSClientInitRequest = EGSREQ_WAITING_FOR_RESPONSE;
        NativeInitMSClient();
        break;
        
        // While in waiting state, check time, if timed out
        // change state to FAILED.  State is changed to success (or failed) 
        // if feedback received from SDK (done in execNativePollCallbacks)
        
    case EGSREQ_WAITING_FOR_RESPONSE:
        elapsedTime = NativeGetSeconds() - m_fMSClientInitStartTime;
        if ( elapsedTime > m_fMaxTimeForResponse )
        {
            m_eMSClientInitRequest = EGSREQ_FAILED;
        }
        break;
        
        // If failed, set appropriate flags then change state to NONE
        
    case EGSREQ_FAILED:
        NativeUnInitMSClient();
        m_eMSClientInitRequest = EGSREQ_NONE;
        m_eMenuLoginMasterSvr  = EMENU_REQ_FAILURE;
        break;
        
        // If success, set appropriate flags then change state to NONE
        
    case EGSREQ_SUCCESS:
        m_bLoggedInToFriendService = TRUE;
        m_bConnectedToServer       = TRUE;
        m_bLoggedInUbiDotCom       = TRUE;
        m_eMSClientInitRequest = EGSREQ_NONE;
        m_eMenuLoginMasterSvr  = EMENU_REQ_SUCCESS;
        break;
        
        // None means that no request is active - nothing to do
        
    case EGSREQ_NONE:
        break;
        
    }
}

function ProcessRegServerLoginRouterRequest()
{
    local FLOAT elapsedTime;       // Elapsed time waiting for response from server
    
    switch ( m_eRegServerLoginRouterRequest )
    {
        
        // In the first pass, call the game service SDK,
        // and check the time.  Change state to WAITING.
        
    case EGSREQ_FIRST_PASS:
        m_fRegServerRouterLoginTime =  NativeGetSeconds();
        NativeRegServerRouterLogin();
        m_eRegServerLoginRouterRequest = EGSREQ_WAITING_FOR_RESPONSE;
        break;
        
        // While in waiting state, check time, if timed out
        // change state to FAILED.  State is changed to success (or failed) 
        // if feedback received from SDK (done in execNativePollCallbacks)
        
    case EGSREQ_WAITING_FOR_RESPONSE:
        
        elapsedTime = NativeGetSeconds() - m_fRegServerRouterLoginTime;
        if ( elapsedTime > m_fMaxTimeForResponse )
            m_eRegServerLoginRouterRequest = EGSREQ_FAILED;
        break;
        
        // If failed, set appropriate flags then change state to NONE
        
    case EGSREQ_FAILED:
        
        // For dedicated servers, use guest account if user account fails.
        
        if ( m_szRegSvrUserID != m_szUbiGuestAcct && m_CrGameSrvInfo.sGameData.bDedicatedServer )
        {
            m_szRegSvrUserID = m_szUbiGuestAcct;
            m_eRegServerLoginRouterRequest = EGSREQ_FIRST_PASS;
            break;
        }
        m_eMenuLoginRegServer = EMENU_REQ_FAILURE;
        m_eRegServerLoginRouterRequest = EGSREQ_NONE;
        break;
        
        // If success, set appropriate flags then change state to NONE.
        // Start the next request in the login sequence
        
    case EGSREQ_SUCCESS:
        m_eRegServerLoginRouterRequest = EGSREQ_NONE;
        m_eRegServerGetLobbiesRequest = EGSREQ_FIRST_PASS;
        break;
        
    case EGSREQ_NONE:
        break;
    }
}

function ProcessRegServerGetLobbiesRequest()
{
    local FLOAT elapsedTime;       // Elapsed time waiting for response from server
    
    switch ( m_eRegServerGetLobbiesRequest )
    {
        
        // In the first pass, call the game service SDK,
        // and check the time.  Change state to WAITING.
        
    case EGSREQ_FIRST_PASS:
        m_fRegServerGetLobbiesTime =  NativeGetSeconds();
        NativeRegServerGetLobbies();
        m_eRegServerGetLobbiesRequest = EGSREQ_WAITING_FOR_RESPONSE;
        break;
        
        // While in waiting state, check time, if timed out
        // change state to FAILED.  State is changed to success (or failed) 
        // if feedback received from SDK (done in execNativePollCallbacks)
        
    case EGSREQ_WAITING_FOR_RESPONSE:
        elapsedTime = NativeGetSeconds() - m_fRegServerGetLobbiesTime;
        if ( elapsedTime > m_fMaxTimeForResponse )
            m_eRegServerGetLobbiesRequest = EGSREQ_FAILED;
        break;
        
        // If failed, set appropriate flags then change state to NONE
        
    case EGSREQ_FAILED:
        m_eMenuLoginRegServer = EMENU_REQ_FAILURE;
        m_eRegServerGetLobbiesRequest = EGSREQ_NONE;
        break;
        
        // If success, set appropriate flags then change state to NONE.
        // Start the next request in the login sequence
        
    case EGSREQ_SUCCESS:
        m_eRegServerGetLobbiesRequest = EGSREQ_NONE;
        m_eRegServerRegOnLobbyRequest = EGSREQ_FIRST_PASS;
        break;
        
    case EGSREQ_NONE:
        break;
    }
}

function ProcessRegServerRegOnLobbyRequest()
{
    local FLOAT elapsedTime;       // Elapsed time waiting for response from server
    
    switch ( m_eRegServerRegOnLobbyRequest )
    {
        
        // In the first pass, call the game service SDK,
        // and check the time.  Change state to WAITING.
        
    case EGSREQ_FIRST_PASS:
        m_fRegServerRegOnLobbyTime =  NativeGetSeconds();
        NativeResetSvrContainer();
        NativeFillSvrContainer();
        NativeRegisterServer();
        m_eRegServerRegOnLobbyRequest = EGSREQ_WAITING_FOR_RESPONSE;
        break;
        
        // While in waiting state, check time, if timed out
        // change state to FAILED.  State is changed to success (or failed) 
        // if feedback received from SDK (done in execNativePollCallbacks)
        
    case EGSREQ_WAITING_FOR_RESPONSE:
        elapsedTime = NativeGetSeconds() - m_fRegServerRegOnLobbyTime;
        if ( elapsedTime > m_fMaxTimeForResponse )
            m_eRegServerRegOnLobbyRequest = EGSREQ_FAILED;
        break;
        
        // If failed, set appropriate flags then change state to NONE
        
    case EGSREQ_FAILED:
        m_eMenuLoginRegServer = EMENU_REQ_FAILURE;
        m_eRegServerRegOnLobbyRequest = EGSREQ_NONE;
        break;
        
        // If success, set appropriate flags then change state to NONE.
        // Start the next request in the login sequence
        
    case EGSREQ_SUCCESS:
        m_eRegServerRegOnLobbyRequest = EGSREQ_NONE;
        m_eRegServerLoginRequest = EGSREQ_FIRST_PASS;
        break;
        
    case EGSREQ_NONE:
        break;
    }
}

function ProcessRegServerLoginRequest()
{
    local FLOAT elapsedTime;       // Elapsed time waiting for response from server
    
    switch ( m_eRegServerLoginRequest )
    {
        
        // In the first pass, call the game service SDK,
        // and check the time.  Change state to WAITING.
        
    case EGSREQ_FIRST_PASS:
        m_fRegServerLoginTime =  NativeGetSeconds();
        NativeServerLogin();
        m_eRegServerLoginRequest = EGSREQ_WAITING_FOR_RESPONSE;
        break;
        
        // While in waiting state, check time, if timed out
        // change state to FAILED.  State is changed to success (or failed) 
        // if feedback received from SDK (done in execNativePollCallbacks)
        
    case EGSREQ_WAITING_FOR_RESPONSE:
        elapsedTime = NativeGetSeconds() - m_fRegServerLoginTime;
        if ( elapsedTime > m_fMaxTimeForResponse )
            m_eRegServerLoginRequest = EGSREQ_FAILED;
        break;
        
        // If failed, set appropriate flags then change state to NONE
        
    case EGSREQ_FAILED:
        m_eMenuLoginRegServer = EMENU_REQ_FAILURE;
        m_eRegServerLoginRequest = EGSREQ_NONE;
        break;
        
        // If success, set appropriate flags then change state to NONE.
        // Start the next request in the login sequence
        
    case EGSREQ_SUCCESS:
        NativeRouterDisconnect();
        m_eRegServerLoginRequest = EGSREQ_NONE;
        m_eMenuLoginRegServer = EMENU_REQ_SUCCESS;
        break;
        
    case EGSREQ_NONE:
        break;
    }
}

function ProcessRegServerUpdateRequest()
{
    local FLOAT elapsedTime;       // Elapsed time waiting for response from server
    
    switch ( m_eRegServerUpdateRequest )
    {
        
        // In the first pass, call the game service SDK,
        // and check the time.  Change state to WAITING.
        
    case EGSREQ_FIRST_PASS:
        m_fRegServerUpdateTime =  NativeGetSeconds();
        
        NativeUpdateServer();
        m_eRegServerUpdateRequest = EGSREQ_WAITING_FOR_RESPONSE;
        break;
        
        // While in waiting state, check time, if timed out
        // change state to FAILED.  State is changed to success (or failed) 
        // if feedback received from SDK (done in execNativePollCallbacks)
        
    case EGSREQ_WAITING_FOR_RESPONSE:
        elapsedTime = NativeGetSeconds() - m_fRegServerUpdateTime;
        if ( elapsedTime > m_fMaxTimeForResponse )
            m_eRegServerUpdateRequest = EGSREQ_FAILED;
        break;
        
        // If failed, set appropriate flags then change state to NONE
        
    case EGSREQ_FAILED:
        m_eMenuUpdateServer = EMENU_REQ_FAILURE;
        m_eRegServerUpdateRequest = EGSREQ_NONE;
        break;
        
        // If success, set appropriate flags then change state to NONE.
        // Start the next request in the login sequence
        
    case EGSREQ_SUCCESS:
        m_eMenuUpdateServer = EMENU_REQ_SUCCESS;
        m_eRegServerUpdateRequest = EGSREQ_NONE;
        break;
        
    case EGSREQ_NONE:
        break;
    }
}

function ProcessJoinServerRequest()
{
    local FLOAT elapsedTime;       // Elapsed time waiting for response from server
    
    switch ( m_eJoinServerRequest )
    {
        
        // In the first pass, call the game service SDK,
        // and check the time.  Change state to WAITING.
        
    case EGSREQ_FIRST_PASS:
        m_fJoinServerTime =  NativeGetSeconds();
        m_eJoinServerRequest = EGSREQ_WAITING_FOR_RESPONSE;
        break;
        
        // While in waiting state, check time, if timed out
        // change state to FAILED.  State is changed to success (or failed) 
        // if feedback received from SDK (done in execNativePollCallbacks)
        
    case EGSREQ_WAITING_FOR_RESPONSE:
        elapsedTime = NativeGetSeconds() - m_fJoinServerTime;
        if ( elapsedTime > m_fMaxTimeForResponse )
        {
            m_eMenuLogMasSvrFailReason = EFAIL_DEFAULT;
            m_eJoinServerRequest = EGSREQ_FAILED;
        }
        break;
        
        // If failed, set appropriate flags then change state to NONE
        
    case EGSREQ_FAILED:
        m_eMenuJoinServer = EMENU_REQ_FAILURE;
        m_eJoinServerRequest = EGSREQ_NONE;
        break;
        
        // If success, set appropriate flags then change state to NONE.
        // Start the next request in the login sequence
        
    case EGSREQ_SUCCESS:
        m_eMenuJoinServer    = EMENU_REQ_SUCCESS;
        m_eJoinServerRequest = EGSREQ_NONE;
        break;
        
    case EGSREQ_NONE:
        break;
    }
}



function string GetLocallyBoundIpAddr()
{
    local UdpBeacon _UdpBeacon;
    local InternetInfo _info;
    if ( m_ClientBeacon != none )
        return m_ClientBeacon.LocalIpAddress;
    else 
    {
        _UdpBeacon = UdpBeacon(class'Actor'.static.GetServerBeacon());
        if (_UdpBeacon!=none)
            return _UdpBeacon.LocalIpAddress;
    }
    return "";
}

//=============================================================================
// Initialize the game service software, call native function to download 
// data from ubi.com.
//=============================================================================
function Initialize()
{
    if (!m_bGameServiceInit)
        m_bGameServiceInit = NativeInit(GetLocallyBoundIpAddr());
}

//=============================================================================
// Establish initial connection to the server
//=============================================================================
function BOOL InitializeMSClient()
{
    
    local int j;
    
    // Get list of favorites from the ini file
    
    NativeInitFavorites();
    
    // Initialize SDK and connect to game service 
    
    if (!m_bGameServiceInit)
        m_bGameServiceInit = NativeInit(GetLocallyBoundIpAddr());
    
    
    if ( m_bGameServiceInit )
    {
        m_eMSClientInitRequest = EGSREQ_FIRST_PASS;
        m_eMenuLoginMasterSvr  = EMENU_REQ_PENDING;
    }        
    else
    {
        m_eMenuLoginMasterSvr  = EMENU_REQ_FAILURE;
        m_eMenuLogMasSvrFailReason = EFAIL_DEFAULT;
    }
    
    return m_bGameServiceInit;
}


//=============================================================================
// Uninitialize the MSClient SDK (logout)
//=============================================================================
function BOOL UnInitializeMSClient()
{
    m_bLoggedInToFriendService = FALSE;
    m_bConnectedToServer       = FALSE;
    m_bLoggedInUbiDotCom       = FALSE;
    m_bServerJoined            = FALSE;
    m_bIndRefrInProgress       = FALSE;
    m_bRefreshInProgress       = FALSE;
    
    return NativeUnInitMSClient();
}


//=============================================================================
// Set the user ID and password for the ubi.com account
//=============================================================================
function SetUbiAccount( string szUserID, string szPassword )
{
    m_szUserID   = szUserID;
    m_szPassword = szPassword;
}

//=============================================================================
// Establish initial connection to the server
//=============================================================================
function BOOL InitializeRegServer()
{
    
    
    // Initialize SDK and connect to game service 
    
    if (!m_bGameServiceInit)
        m_bGameServiceInit = NativeInit(GetLocallyBoundIpAddr());
    
    if ( m_bGameServiceInit )
    {
        m_bGameServiceInit = NativeInitRegServer();
        m_eMenuLoginRegServer  = EMENU_REQ_PENDING;
    }        
    
    return m_bGameServiceInit;
}





//=============================================================================
// Log in to the Reg server (involves several steps).
//=============================================================================
function LoginRegServer( GameInfo pGameInfo, LevelInfo pLevel)
{
    m_eRegServerLoginRouterRequest  = EGSREQ_FIRST_PASS;
    m_eMenuLoginRegServer           = EMENU_REQ_PENDING;
    
    FillCreateGameInfo( pGameInfo, pLevel);
    
    m_szRegSvrUserID = m_szUbiGuestAcct;
}

//=============================================================================
// Update the server information.
//=============================================================================

function InitProcessUpdateUbiServer(GameInfo pGameInfo, LevelInfo pLevel)
{
    FillCreateGameInfo( pGameInfo, pLevel);
    
    NativeResetSvrContainer();
    NativeFillSvrContainer();
}

function UpdateServerRegServer(GameInfo pGameInfo, LevelInfo pLevel)
{
    InitProcessUpdateUbiServer(pGameInfo, pLevel);
    m_eRegServerUpdateRequest = EGSREQ_FIRST_PASS;
    m_eMenuUpdateServer       = EMENU_REQ_PENDING;
}

function UpdateServerUbiCom(GameInfo pGameInfo, LevelInfo pLevel)
{
    InitProcessUpdateUbiServer(pGameInfo, pLevel);
    NativeGSClientUpdateServerInfo();
}

//=============================================================================
// FillCreateGameInfo Fill the m_CrGameSrvInfo structure with all the
// required data from the gameinfo, levelinfo, and beacon
//=============================================================================
function FillCreateGameInfo( GameInfo pGameInfo, LevelInfo pLevel )
{
    local R6ServerInfo     pServerOptions;
    local PlayerController aPC;             // Local object for foreach loop
    local Controller _PC;
    local INT              iNumPlayers;
    local INT              iNumMaps;
    local R6MapList        mapList;         // Map list to cycle through
    local INT              iCounter;        // Counter
    local stRemotePlayers  sPlayer;
    local stGameTypeAndMap sMapAndGame;
    
    pServerOptions = class'Actor'.static.GetServerOptions();

    iNumPlayers = 0;
    
    m_CrGameSrvInfo.sGameData.playerList.Remove( 0, m_CrGameSrvInfo.sGameData.iNbrPlayer);
    
    for (_PC=pGameInfo.Level.ControllerList; _PC!=None; _PC=_PC.NextController )
    {
        aPC = PlayerController(_PC);
        if (aPC!=none)
        {
            sPlayer.szAlias = aPC.PlayerReplicationInfo.PlayerName;
            
            sPlayer.iPing   = aPC.PlayerReplicationInfo.Ping;
            sPlayer.iSkills  = aPC.PlayerReplicationInfo.m_iKillCount;
            sPlayer.szTime  = DisplayTime( pLevel.TimeSeconds - aPC.PlayerReplicationInfo.StartTime );
            m_CrGameSrvInfo.sGameData.playerList[iNumPlayers] = sPlayer;
            
            iNumPlayers++;
        }
    }
    
    m_CrGameSrvInfo.sGameData.gameMapList.Remove( 0, m_CrGameSrvInfo.sGameData.gameMapList.length );
    mapList = pGameInfo.spawn(class'R6MapList');
    for ( iCounter = 0; iCounter < arraycount(mapList.Maps); iCounter++ )
    {
        if ( mapList.Maps[iCounter] != "" )
        {
            if ( InStr(mapList.Maps[iCounter], ".") == -1 )   // -1 signifies string not found
                sMapAndGame.szMap = mapList.Maps[iCounter];
            else
                sMapAndGame.szMap = left( mapList.Maps[iCounter], InStr(mapList.Maps[iCounter], ".") );
            
            sMapAndGame.szGameType = pLevel.GetGameTypeFromClassName( mapList.GameType[iCounter] );
            //            sMapAndGame.szGameLoc = pLevel.GetGameNameLocalization( pLevel.GetGameTypeFromClassName(mapList.GameType[iCounter]) );
            m_CrGameSrvInfo.sGameData.gameMapList[iNumMaps] = sMapAndGame;
            iNumMaps++;
        }
    }
    
    m_CrGameSrvInfo.sGameData.szCurrentMap      = mapList.CheckCurrentMap();//pLevel.Game.GetURLMap();
    
    mapList.Destroy();
    
    if ( m_ClientBeacon != none )
        m_CrGameSrvInfo.iBeaconPort             = m_ClientBeacon.boundport;
    else if (R6AbstractGameInfo(pGameInfo).m_UdpBeacon!=none)
        m_CrGameSrvInfo.iBeaconPort             = R6AbstractGameInfo(pGameInfo).m_UdpBeacon.boundport;
    else
        m_CrGameSrvInfo.iBeaconPort             = class'UdpBeacon'.Default.ServerBeaconPort;
    
    m_CrGameSrvInfo.sGameData.szName            = pGameInfo.GameReplicationInfo.ServerName;
    m_CrGameSrvInfo.sGameData.szModName         = class'Actor'.static.GetModMgr().m_pCurrentMod.m_szKeyWord; // MPF
    m_CrGameSrvInfo.sGameData.szPassword        = pServerOptions.GamePassword;
    m_CrGameSrvInfo.sGameData.bUsePassword      = pServerOptions.UsePassword;
    m_CrGameSrvInfo.sGameData.iMaxPlayer        = pServerOptions.MaxPlayers;
    m_CrGameSrvInfo.sGameData.bDedicatedServer  = (pLevel.NetMode == NM_DedicatedServer);
    m_CrGameSrvInfo.sGameData.iPort             = int(Mid(pLevel.GetAddressURL(),InStr(pLevel.GetAddressURL(),":")+1));
    m_CrGameSrvInfo.sGameData.bAutoBalTeam      = pServerOptions.Autobalance;
    m_CrGameSrvInfo.sGameData.bFriendlyFire     = pServerOptions.FriendlyFire;
    m_CrGameSrvInfo.sGameData.bInternetServer   = pServerOptions.InternetServer;
    m_CrGameSrvInfo.sGameData.bShowNames        = pServerOptions.ShowNames;
    m_CrGameSrvInfo.sGameData.bTKPenalty        = pServerOptions.TeamKillerPenalty;
    m_CrGameSrvInfo.sGameData.bRadar            = pServerOptions.AllowRadar;
    m_CrGameSrvInfo.sGameData.iRoundsPerMatch   = pServerOptions.RoundsPerMatch;
    m_CrGameSrvInfo.sGameData.szGameDataGameType= pGameInfo.m_szCurrGameType;
    m_CrGameSrvInfo.sGameData.iBetTime          = pServerOptions.BetweenRoundTime;
    m_CrGameSrvInfo.sGameData.iBombTime         = pServerOptions.BombTime;
    m_CrGameSrvInfo.sGameData.iNbrPlayer        = iNumPlayers;
    m_CrGameSrvInfo.sGameData.iNumMaps          = iNumMaps;
    m_CrGameSrvInfo.sGameData.iRoundTime        = pServerOptions.RoundTime;
    m_CrGameSrvInfo.sGameData.szMessageOfDay    = pServerOptions.MOTD;
    m_CrGameSrvInfo.sGameData.szGameType        = pLevel.GetGameNameLocalization( m_CrGameSrvInfo.sGameData.szGameDataGameType );
    m_CrGameSrvInfo.sGameData.bAdversarial      = pLevel.IsGameTypeAdversarial( m_CrGameSrvInfo.sGameData.szGameDataGameType );
    m_CrGameSrvInfo.sGameData.iNumTerro         = pServerOptions.NbTerro;
    m_CrGameSrvInfo.sGameData.bAIBkp            = pServerOptions.AIBkp;
    m_CrGameSrvInfo.sGameData.bRotateMap        = pServerOptions.RotateMap;
    m_CrGameSrvInfo.sGameData.bForceFPWeapon    = pServerOptions.ForceFPersonWeapon;
    //#ifdef R6PUNKBUSTER
    m_CrGameSrvInfo.sGameData.bPunkBuster       = class'Actor'.static.IsPBServerEnabled();
    //#endif
}



//=============================================================================
// Refresh the list of servers
//=============================================================================

function RefreshServers()
{
    if ( !m_bConnectedToServer || m_bIndRefrInProgress || m_bRefreshInProgress)
        return;
    
    m_fRefreshTime = NativeGetSeconds();
    
    m_bRefreshInProgress = TRUE;
    m_bMSRequestFinished = FALSE;
    
    m_GameServerList.Remove(0, m_GameServerList.length);         // Clear entire list
    m_GSLSortIdx.Remove(0, m_GSLSortIdx.length);
    
    //   NativeGetGroupInfo( m_iOwnGroupID, m_iOwnLobbySrvID );  // Replace with master server code
    NativeRequestMSList();
}

//=============================================================================
// The user can right click on a server and get additional information
// on that server (players, maps, etc.).  This function is called to select
// that server from the server list.
//=============================================================================

//function SetSelectedServer( INT iServerListIndex)
//{
//
//    if ( iServerListIndex > m_GameServerList.length )  // Check index is valid
//        return;
//
//    m_iSelSrvIndex = iServerListIndex;
//
//}

//=============================================================================
// Initialize the Game service CDKey SDK
//=============================================================================

function BOOL initGSCDKey( )
{
    local INT iPort;
    local BOOL bCDKInit;
    
    // Get maximum number of avaiable ports
    m_iMaxAvailPorts = class'UdpLink'.static.GetMaxAvailPorts();
    
    if (!m_bGameServiceInit)
        m_bGameServiceInit = NativeInit(GetLocallyBoundIpAddr());
    
    bCDKInit = NativeInitCDKey(m_iRSCDKeyPort, m_iModCDKeyPort);
    return bCDKInit;
}

//=============================================================================
// joinServer - Inform ubi.com that we are joining a server
//=============================================================================

//function joinServer( INT uiID, string szPassword )
//{
//        NativeMSCLientJoinServer( uiID, szPassword );
//        m_eJoinServerRequest  = EGSREQ_FIRST_PASS;
//        m_eMenuJoinServer  = EMENU_REQ_PENDING;
//}
//=============================================================================
// joinServer - Inform ubi.com that we are joining a server
//=============================================================================

function joinServer( INT iLobbyID, INT iGroupID, string szPassword )
{
    NativeMSCLientJoinServer( iLobbyID, iGroupID, szPassword );
    m_eJoinServerRequest  = EGSREQ_FIRST_PASS;
    m_eMenuJoinServer  = EMENU_REQ_PENDING;
}

//=============================================================================
// Request a cd key user validation
//=============================================================================

//function requestUserValidation( string szAuthID )
//{
//    if ( m_bCDKInit )
//    {
//        NativeCDKeyValidateUser( szAuthID );
//        m_eUserValidationRequest  = EGSREQ_FIRST_PASS;
//        m_eMenuUserValidation  = EMENU_REQ_PENDING;
//    }
//    else
//    {
//        if (bShowLog) log("Could not get user validation from ubi.com");
//        m_eMenuUserValidation  = EMENU_REQ_FAILURE;
//    }
//}


//===============================================================================
// DisplayTime: display the time in min (have to be in sec)
//===============================================================================
function string DisplayTime( INT _iTimeToConvert) //, BOOL _bInSec)
{
    local FLOAT fTemp;
    local INT iMin, iSec, iTemp;
    local string szTemp, szTime;
    
    iMin = 0;
    iSec = _iTimeToConvert;
    
    if (_iTimeToConvert >= 60) // 60sec
    {
        fTemp = FLOAT(_iTimeToConvert ) / 60;
        iMin = INT(fTemp);
        iSec = _iTimeToConvert - (iMin * 60);
    }
    
    if (iSec < 10)
    {
        szTime = iMin $ ":0" $ iSec;
    }
    else
    {
        szTemp = string(iSec);
        szTemp = Left( szTemp, 2);
        szTime = iMin $ ":" $ szTemp;
    }
    
    return szTime;
}
//===============================================================================
// GetSelectedServerIP:  Return the IP address of the selected server, include
// a check to make sure the server is responding, else try the alternate IP.
// Also remove the port number.
//===============================================================================
function string GetSelectedServerIP() 
{
    local string szIPAddress;       // Primary IP address
    local string szAltIPAddress;    // Alternate IP address
    
    // Remove the Port number from the IP string: 10.10.10.10:1234 -> 10.10.10.10
    szIPAddress = left( m_GameServerList[m_iSelSrvIndex].szIPAddress, InStr(m_GameServerList[m_iSelSrvIndex].szIPAddress, ":") );
    szAltIPAddress = left( m_GameServerList[m_iSelSrvIndex].szAltIPAddress, InStr(m_GameServerList[m_iSelSrvIndex].szAltIPAddress, ":") );
    
    // If the ping time is not valid, ping now to determine which IP to use
    if ( m_GameServerList[m_iSelSrvIndex].iPing >= NativeGetPingTimeOut() )
    {
        if ( NativeGetPingTime( szIPAddress ) >= NativeGetPingTimeOut() )
        {
            // If there is no response from the first IP, try the alternate IP
            if ( NativeGetPingTime( szAltIPAddress ) < NativeGetPingTimeOut())
                m_GameServerList[m_iSelSrvIndex].bUseAltIP = TRUE;
        }
    }
    
    if ( m_GameServerList[m_iSelSrvIndex].bUseAltIP )
        return m_GameServerList[m_iSelSrvIndex].szAltIPAddress;
    else
        return m_GameServerList[m_iSelSrvIndex].szIPAddress;
    
}

//===============================================================================
// Start the auto log in procedure
//===============================================================================

function StartAutoLogin()
{
    if ( m_szUserID != "" && m_szPassword != "" && m_bAutoLISave )
    {
        InitializeMSClient();
        m_bAutoLoginInProgress = TRUE;
    }
}
//===============================================================================
// This function has to inform the server that the end of round (a Ubi match) data
// has been sent to Ubi.com
//===============================================================================
event EndOfRoundDataSent()
{
    R6PlayerController(m_LocalPlayerController).ServerEndOfRoundDataSent();
}

//===============================================================================
// This function returns the maximum allowed size of the server name, this is 
// limited by ubi.com
//===============================================================================
function INT GetMaxUbiServerNameSize()
{
    return K_MAX_SIZE_UBISERVERNAME;
}



function HandleNewLobbyConnection(LevelInfo _Level)
{
    local Controller P;
    
    for (P=_Level.ControllerList; P!=None; P=P.NextController )
    {
        if ((R6PlayerController(P)!=none) && (Viewport(R6PlayerController(P).Player) == None))
        {
            // these 2 vars may not have been replicated to the client yet
            R6PlayerController(P).ClientNewLobbyConnection(_Level.Game.GameReplicationInfo.m_iGameSvrLobbyID, _Level.Game.GameReplicationInfo.m_iGameSvrGroupID);
        }
    }
}

function LogOutServer(R6GameReplicationInfo _GRI)
{
    _GRI.m_iGameSvrGroupID = 0;
    _GRI.m_iGameSvrLobbyID = 0;
    NativeRegServerShutDown();
    SetRegisteredWithMS( FALSE );
}

//======================================================================
// MasterServerManager - This function handles all of the interfacing
// with the master server (ubi.com) this includes registering the 
// server with ubi.com, validating the CDKey of players as they join,
// informing ubi.com as players join/leave
//======================================================================
function MasterServerManager(R6AbstractGameInfo _GameInfo, LevelInfo _Level)
{
    local Controller _aController;
    local PlayerController aPlayerController;
    local INT    i, jID;
    local BOOL   bFound;
    local string szIPAddr;
    
    m_eRSReqState = GetGameServiceRequestState(); 
    // State machine for registering the server with the master server
    // Do not register server if started by ubi.com client, 
    // the client will register the server  by itself.
    
    if (_GameInfo.m_bInternetSvr)
    {
        ProcessInternetSrv( _GameInfo, _Level);
    }
    
    if ( !GetCDKeyInitialised() )
        SetCDKeyInitialised( initGSCDKey() );
    for (_aController = _Level.ControllerList; _aController!=None; _aController=_aController.NextController)
    {
        aPlayerController = PlayerController(_aController);
        if (aPlayerController != none)
        {
            ProcessPC_CDKeyRequest( _GameInfo, _Level, aPlayerController, false);
            if (!class'Actor'.static.GetModMgr().IsRavenShield())
        {
                ProcessPC_CDKeyRequest( _GameInfo, _Level, aPlayerController, true);
                }
            }
        }
    // Respond to requests for player informations sent from validation server
        
    NativeProcessAuthIdRequest(_Level.ControllerList);
    
    GameServiceManager( FALSE, TRUE, TRUE, FALSE);
    
    SetGameServiceRequestState(m_eRSReqState);
}

function ProcessInternetSrv( R6AbstractGameInfo _GameInfo, LevelInfo _Level)
{
    if ( !class'Actor'.static.NativeStartedByGSClient())
    {
        switch( m_eRSReqState )  
        {
        case ERSREQ_INIT:
            
            if ( InitializeRegServer() )
            {
                LoginRegServer( _GameInfo, _Level);
                m_bUpdateServer = FALSE;
                m_eRSReqState = ERSREQ_LOGIN;
            }
            else
                m_eRSReqState = ERSREQ_FAILURE;
            break;
        case ERSREQ_LOGIN:
            if ( m_eMenuLoginRegServer == EMENU_REQ_SUCCESS )
                m_eRSReqState = ERSREQ_SUCCESS;
            else if ( m_eMenuLoginRegServer == EMENU_REQ_FAILURE )
                m_eRSReqState = ERSREQ_FAILURE;
            break;
        case ERSREQ_SUCCESS:
            m_eRSReqState = ERSREQ_NONE;
            SetRegisteredWithMS( TRUE );
            _GameInfo.GameReplicationInfo.m_iGameSvrGroupID = NativeGetGroupID();
            _GameInfo.GameReplicationInfo.m_iGameSvrLobbyID = NativeGetLobbyID();
            log ( "Server registered with ubi.com master server" );
            // tell any logged in players the groupId and lobbyId (this may be a reconnection to lobby server)
            HandleNewLobbyConnection(_Level);
            break;
        case ERSREQ_FAILURE:
            m_eRSReqState = ERSREQ_NONE;
            m_iRetryTime = NativeGetSeconds() + K_TimeRetryConnect;
            break;
        case ERSREQ_NONE:
            if ( !NativeGetServerRegistered() && 
                NativeGetSeconds() > m_iRetryTime)
            {
                log("try again time "$_Level.TimeSeconds);
                m_eRSReqState = ERSREQ_INIT;
            }
            break;
        }
    }
    
    // Each time the game is restared, make sure the Lobby Id and Group ID
    // are properly set in the replication info.
    if ( m_bInitGame && _Level.Game.GameReplicationInfo != None)
    {
        m_bInitGame = FALSE;
        _Level.Game.GameReplicationInfo.m_iGameSvrGroupID = NativeGetGroupID();
        _Level.Game.GameReplicationInfo.m_iGameSvrLobbyID = NativeGetLobbyID();
    }
    if (m_bUpdateServer)
    {
        if ( GetRegisteredWithMS() )
        {
            m_bUpdateServer = FALSE;
            UpdateServerRegServer( _GameInfo, _Level);
        }
        else if (class'Actor'.static.NativeStartedByGSClient() )
        {
            UpdateServerUbiCom( _GameInfo, _Level);
            m_bUpdateServer = FALSE;
        }
    }
    
    // We have been disconnected from ubi.com
    
    if ( m_bRegSrvrConnectionLost )
    {
        m_iRetryTime = NativeGetSeconds() + K_TimeRetryConnect;
        LogOutServer(R6GameReplicationInfo(_GameInfo.GameReplicationInfo));
        m_bRegSrvrConnectionLost = FALSE;
    }
}

function ProcessPC_CDKeyRequest( R6AbstractGameInfo _GameInfo, 
                                LevelInfo _Level, 
                                OUT PlayerController _aPlayerController, 
                                bool bProcessMod) //, OUT PlayerController _aOutPlayerController)
{
    local INT    i;
    local BOOL   bFound;
    local string szIPAddr;
    local array<stValidationResponse> _ValidResponseList;
    local PlayerController.PlayerVerCDKeyStatus _PlayerStatus;
//#ifdef R6PUNKBUSTER
    local string PBErrorMsg;
//#endif R6PUNKBUSTER	
    
    if (bShowLog) LogDebugProcessCDKeyRequest(_aPlayerController, false);
    
    if (bProcessMod==true)
    {
        _PlayerStatus = _aPlayerController.m_stPlayerVerModCDKeyStatus;
    }
    else
    {
        _PlayerStatus = _aPlayerController.m_stPlayerVerCDKeyStatus;
        _aPlayerController.m_stPlayerVerModCDKeyStatus.m_eCDKeyRequest  = ECDKEY_NONE;
    }


    // The first time the player logs in, inform ubi.com that he has 
    // joined the server 
    
    // State machine for cdkey validation
    

    switch( _PlayerStatus.m_eCDKeyRequest )
    {
    case ECDKEY_FIRSTPASS:
        if (bShowLog) log("ECDKEY_FIRSTPASS for "$_aPlayerController);
        // For a player who has started a non-dedicated server, the authorization ID
        // and IP are not available in the same way as a player who has joined a server.
        // For such a player, get the Authorization ID from GameService and get the
        // IP from the console.
        if ( NetConnection( _aPlayerController.Player) == None )
        {                                                               // started non-dedicated server
//            _PlayerStatus.m_szAuthorizationID = NativeCDKeyGetOwnAuthID(bProcessMod);
            szIPAddr = WindowConsole(_aPlayerController.Player.Console).szStoreIP;
        }
        else
        {                                                               // joined other server
            szIPAddr = _aPlayerController.GetPlayerNetworkAddress();
        }
        
        _aPlayerController.m_szIpAddr = Left( szIPAddr, InStr( szIPAddr, ":" ) );
        
        if (bShowLog) log("ProcessPC_CDKeyRequest ECDKEY_FIRSTPASS: _PlayerStatus.m_szAuthorizationID "$ _PlayerStatus.m_szAuthorizationID$" "$_aPlayerController.m_szIpAddr);
        
        if (PlayerIsInIDList(_PlayerStatus.m_szAuthorizationID, _aPlayerController.m_szIpAddr, bProcessMod))
        {
            if (bShowLog) log("ProcessPC_CDKeyRequest ECDKEY_FIRSTPASS: PlayerIsInIDList");
            if (bProcessMod==false)
            {
                _aPlayerController.m_szGlobalID = GetGlobalIdFromPlayerIDList(_aPlayerController.m_stPlayerVerCDKeyStatus.m_szAuthorizationID);
            }
            _PlayerStatus.m_eCDKeyRequest = ECDKEY_VALID;
        }
        else
        {
            if (bShowLog) log("ProcessPC_CDKeyRequest ECDKEY_FIRSTPASS: NativeCDKeyValidateUser");
            _PlayerStatus.m_iCDKeyReqID = NativeCDKeyValidateUser(_PlayerStatus.m_szAuthorizationID, _PlayerStatus.m_bCDKeyValSecondTry,  bProcessMod);
            if (bShowLog) log("ProcessPC_CDKeyRequest ECDKEY_FIRSTPASS: _PlayerStatus.m_iCDKeyReqID "$_PlayerStatus.m_iCDKeyReqID);
            _PlayerStatus.m_eCDKeyRequest = ECDKEY_WAITING_FOR_RESPONSE;
        }
        break;
    case ECDKEY_WAITING_FOR_RESPONSE:
        bFound = FALSE;
        if (bProcessMod)
            _ValidResponseList = m_ModValidResponseList;
        else
            _ValidResponseList = m_ValidResponseList;

        for ( i = 0; i < _ValidResponseList.Length && !bFound; i++ )
        {
            if (_PlayerStatus.m_iCDKeyReqID == _ValidResponseList[i].iReqID )
            {
                bFound = TRUE;

                if ( _ValidResponseList[i].bSuceeded )
                {
                    if (bProcessMod==false)
                    {
                        _aPlayerController.m_szGlobalID = _aPlayerController.GlobalIDToString(_ValidResponseList[i].ucGlobalID);

                        // check global ID
                        if ( _GameInfo.AccessControl.IsGlobalIDBanned( _aPlayerController.m_szGlobalID ) )
                        {
                            _ValidResponseList[i].eStatus = ECDKEYST_PLAYER_BANNED;
                        }
                        else
                        {
                            //#ifdef R6PUNKBUSTER
                            PBErrorMsg = _aPlayerController.GetPBConnectStatus();

                            if (PBErrorMsg!="")
                            {
                                _ValidResponseList[i].eStatus = ECDKEYST_PLAYER_PB_KICKED;
                                _aPlayerController.ClientPBKickedOutMessage(PBErrorMsg);
                            }
                            //#endif R6PUNKBUSTER
                        }
                    }
                    _PlayerStatus.m_eCDKeyStatus = _ValidResponseList[i].eStatus;
                    if ( _ValidResponseList[i].eStatus == ECDKEYST_PLAYER_INVALID ||
                        _ValidResponseList[i].eStatus == ECDKEYST_PLAYER_UNKNOWN || 
                        _ValidResponseList[i].eStatus == ECDKEYST_PLAYER_BANNED  ||
                        _ValidResponseList[i].eStatus == ECDKEYST_PLAYER_PB_KICKED)
                    {
                        if (bShowLog) log("ProcessPC_CDKeyRequest ECDKEY_WAITING_FOR_RESPONSE: _PlayerStatus.m_eCDKeyRequest = ECDKEY_NOT_VALID");
                        _PlayerStatus.m_eCDKeyRequest = ECDKEY_NOT_VALID;
                    }
                    else
                    {
                        if (bShowLog) log("ProcessPC_CDKeyRequest ECDKEY_WAITING_FOR_RESPONSE: _PlayerStatus.m_eCDKeyRequest = ECDKEY_VALID");
                        _PlayerStatus.m_eCDKeyRequest = ECDKEY_VALID;
                    }
                }
                else if ( _ValidResponseList[i].bTimeout && _PlayerStatus.m_bCDKeyValSecondTry )
                {
                    if (bShowLog) log ("*** TIMEOUT second attempt ***");
                    _PlayerStatus.m_bCDKeyValSecondTry = FALSE;

                    if ((OnSameSubNet(_aPlayerController.m_szIpAddr) == true) || (Viewport(_aPlayerController.Player) != none))
                    {
                        _PlayerStatus.m_eCDKeyRequest = ECDKEY_VALID; //ECDKEY_NOT_VALID;
                    }
                    else
                    {
                        _PlayerStatus.m_eCDKeyRequest = ECDKEY_NONE;
                        _PlayerStatus.m_eCDKeyStatus  = ECDKEYST_PLAYER_UNKNOWN;

#ifdefDEBUG
                        if ( m_bUseCDKey )
                        {
                            log("ServerInfo: Disconnect client "$_aPlayerController.PlayerReplicationInfo.PlayerName$" CDKey invalid Time = "$_Level.TimeSeconds);
#endif                                 

#ifndefMPDEMO
                            R6PlayerController(_aPlayerController).ServerIndicatesInvalidCDKey("ServerAuthNotResponding");
                            if (R6PlayerController(_aPlayerController).m_GameService == none)
                                R6PlayerController(_aPlayerController).m_GameService = self;
                            _aPlayerController.SpecialDestroy();
#endif

#ifdefDEBUG
                        }
#endif
                    }

                }
                else if ( _ValidResponseList[i].bTimeout )
                {
                    if (bShowLog) log ("*** ProcessPC_CDKeyRequest ECDKEY_WAITING_FOR_RESPONSE: TIMEOUT first attempt ***");
                    _PlayerStatus.m_eCDKeyRequest = ECDKEY_FIRSTPASS;
                    _PlayerStatus.m_bCDKeyValSecondTry = TRUE;
                }
                else
                {
                    _PlayerStatus.m_eCDKeyRequest = ECDKEY_NOT_VALID;
                }

            }
        }
        _ValidResponseList.Remove( 0, _ValidResponseList.length );
        break;
    case ECDKEY_NOT_VALID:
#ifdefDEBUG
        if ( m_bUseCDKey )
        {
            if (bShowLog) log("ServerInfo: Disconnect client "$_aPlayerController.PlayerReplicationInfo.PlayerName$" CDKey invalid Time = "$_Level.TimeSeconds);
#endif


#ifndefMPDEMO
            if ( _PlayerStatus.m_eCDKeyStatus == ECDKEYST_PLAYER_BANNED )
                R6PlayerController(_aPlayerController).ServerIndicatesInvalidCDKey("BannedIP");
            else if (_PlayerStatus.m_eCDKeyStatus != ECDKEYST_PLAYER_PB_KICKED)
            {
                R6PlayerController(_aPlayerController).ServerIndicatesInvalidCDKey("CDKeyServerRefused");
            }

            if (R6PlayerController(_aPlayerController).m_GameService == none)
                R6PlayerController(_aPlayerController).m_GameService = self;
            _aPlayerController.SpecialDestroy();  // make sure player is kicked off the server
#endif
        
#ifdefDEBUG
        }
#endif
        _PlayerStatus.m_eCDKeyRequest = ECDKEY_NONE;
        _PlayerStatus.m_eCDKeyStatus  = ECDKEYST_PLAYER_INVALID;
        break;
    case ECDKEY_VALID:
        //                szIPAddr = _aPlayerController.GetPlayerNetworkAddress();
        //                szIPAddr = Left( szIPAddr, InStr( szIPAddr, ":" ) );
        
        AddPlayerToIDList( _PlayerStatus.m_szAuthorizationID, _aPlayerController.m_szIpAddr, 
            _aPlayerController.m_szGlobalID, bProcessMod);
        
        if (bShowLog) log ("*** ProcessPC_CDKeyRequest ECDKEY_VALID:  m_eCDKeyStatus  = ECDKEYST_PLAYER_VALID ***");
        _PlayerStatus.m_eCDKeyRequest = ECDKEY_NONE;
        _PlayerStatus.m_eCDKeyStatus  = ECDKEYST_PLAYER_VALID;

        if (!bProcessMod && !class'Actor'.static.GetModMgr().IsRavenShield() && (_PlayerStatus != _aPlayerController.m_stPlayerVerModCDKeyStatus))
        {
            _aPlayerController.m_stPlayerVerModCDKeyStatus.m_eCDKeyRequest = ECDKEY_FIRSTPASS;
        }


        break;
    case ECDKEY_NONE:
        break;
    }
            
    if (bProcessMod==true)
        _aPlayerController.m_stPlayerVerModCDKeyStatus = _PlayerStatus;
    else
        _aPlayerController.m_stPlayerVerCDKeyStatus = _PlayerStatus;
    
            //	_aOutPlayerController = _aPlayerController;
            if(bShowLog) LogDebugProcessCDKeyRequest(_aPlayerController, true);
}
        
event SetGlobalIDToString(BYTE _globalID[K_GlobalID_size])
{
    local int x;
    m_szGlobalID = class'Actor'.static.GlobalIDToString( _globalID );
}

function string MyID()
{
    return m_szGlobalID;
}

event SetGSGameState(EGSGameState eNewGameState)
{
    //    if (bShowLog)
    //    {
    switch(eNewGameState)
    {
    case EGS_WAITING_FOR_GS_INIT:
        log("SetGSGameState new state is EGS_WAITING_FOR_GS_INIT");
        break;
        
    case EGS_CLIENT_INIT_RCVD:
        log("SetGSGameState new state is EGS_CLIENT_INIT_RCVD");
        break;
        
    case EGS_CLIENT_WAITING_CHSTA:
        log("SetGSGameState new state is EGS_CLIENT_WAITING_CHSTA");
        break;
        
    case EGS_CLIENT_CHSTA_RCVD:
        log("SetGSGameState new state is EGS_CLIENT_CHSTA_RCVD");
        break;
        
    case EGS_CLIENT_IN_GAME:
        log("SetGSGameState new state is EGS_CLIENT_IN_GAME");
        break;
        
    case EGS_SERVER_INIT_RCVD:
        log("SetGSGameState new state is EGS_SERVER_INIT_RCVD");
        break;
        
    case EGS_SERVER_WAITING_CHSTA:
        log("SetGSGameState new state is EGS_SERVER_WAITING_CHSTA");
        break;
        
    case EGS_SERVER_CHSTA_RCVD:
        log("SetGSGameState new state is EGS_SERVER_CHSTA_RCVD");
        break;
        
    case EGS_SERVER_SETTING_UP_GAME:
        log("SetGSGameState new state is EGS_SERVER_SETTING_UP_GAME");
        break;
        
    case EGS_TERMINATE_RCVD:
        log("SetGSGameState new state is EGS_TERMINATE_RCVD");
        break;
        
    case EGS_SERVER_READY:
        log("SetGSGameState new state is EGS_SERVER_READY");
        break;
        
    default:
        log("SetGSGameState new state is ??? "$eNewGameState);
        break;
        
    }
    
    switch(m_eGSGameState)
    {
    case EGS_WAITING_FOR_GS_INIT:
        log("SetGSGameState old state is EGS_WAITING_FOR_GS_INIT");
        break;
        
    case EGS_CLIENT_INIT_RCVD:
        log("SetGSGameState old state is EGS_CLIENT_INIT_RCVD");
        break;
        
    case EGS_CLIENT_WAITING_CHSTA:
        log("SetGSGameState old state is EGS_CLIENT_WAITING_CHSTA");
        break;
        
    case EGS_CLIENT_CHSTA_RCVD:
        log("SetGSGameState old state is EGS_CLIENT_CHSTA_RCVD");
        break;
        
    case EGS_CLIENT_IN_GAME:
        log("SetGSGameState old state is EGS_CLIENT_IN_GAME");
        break;
        
    case EGS_SERVER_INIT_RCVD:
        log("SetGSGameState old state is EGS_SERVER_INIT_RCVD");
        break;
        
    case EGS_SERVER_WAITING_CHSTA:
        log("SetGSGameState old state is EGS_SERVER_WAITING_CHSTA");
        break;
        
    case EGS_SERVER_CHSTA_RCVD:
        log("SetGSGameState old state is EGS_SERVER_CHSTA_RCVD");
        break;
        
    case EGS_SERVER_SETTING_UP_GAME:
        log("SetGSGameState old state is EGS_SERVER_SETTING_UP_GAME");
        break;
        
    case EGS_TERMINATE_RCVD:
        log("SetGSGameState old state is EGS_TERMINATE_RCVD");
        break;
        
    case EGS_SERVER_READY:
        log("SetGSGameState old state is EGS_SERVER_READY");
        break;
        
    default:
        log("SetGSGameState old state is ??? "$eNewGameState);
        break;
        
    }
    
    
    //    }
    m_eGSGameState = eNewGameState;
}
            
function BOOL IsModCDKeyProcess()
{
	return m_bMODCDKeyRequest;
}

function RequestModCDKeyProcess( BOOL _bRequestAS)
{
    local string _szEncryptedCdkey;

    log("MOD CD KEY REQUEST"@_bRequestAS);
    if (_bRequestAS==false)
    {
        GetRegistryKey("SOFTWARE\\Red Storm Entertainment\\RAVENSHIELD", "CDKey", _szEncryptedCdkey);

        if (class'eviLCore'.static.IsCDKeyValidOnMachine(_szEncryptedCdkey) )
            m_szCDKey = class'eviLCore'.static.DecryptCDKey(_szEncryptedCdkey);
        else
        {
            m_szCDKey = "";
            m_bValidActivationID = false;// CDKey validation server activation ID valid flag
        }
    }
    m_bMODCDKeyRequest = _bRequestAS;
}

function LogDebugProcessCDKeyRequest( PlayerController _aPlayerController, BOOL _bExit)
{
    local string szLog;
    
    if (_bExit) 
        szLog = "EXIT fct";
    else
        szLog = "ENTER fct";
    
    if (_aPlayerController.m_stPlayerVerCDKeyStatus.m_eCDKeyRequest != ECDKEY_NONE)
    {
        log("LogDebugProcessCDKeyRequest for RS");
        switch( _aPlayerController.m_stPlayerVerCDKeyStatus.m_eCDKeyRequest )
        {
        case ECDKEY_FIRSTPASS:	log("ProcessPC_CDKeyRequest _aPlayerController.m_stPlayerVerCDKeyStatus.m_eCDKeyRequest: ECDKEY_FIRSTPASS"@szLog);	break;
        case ECDKEY_WAITING_FOR_RESPONSE: log("ProcessPC_CDKeyRequest _aPlayerController.m_stPlayerVerCDKeyStatus.m_eCDKeyRequest: ECDKEY_WAITING_FOR_RESPONSE"@szLog); break;
        case ECDKEY_NOT_VALID: log("ProcessPC_CDKeyRequest _aPlayerController.m_stPlayerVerCDKeyStatus.m_eCDKeyRequest: ECDKEY_NOT_VALID"@szLog); break;
        case ECDKEY_VALID: log("ProcessPC_CDKeyRequest _aPlayerController.m_stPlayerVerCDKeyStatus.m_eCDKeyRequest: ECDKEY_VALID"@szLog); break;
            break;
        }
    }

    if (_aPlayerController.m_stPlayerVerModCDKeyStatus.m_eCDKeyRequest != ECDKEY_NONE)
    {
        log("LogDebugProcessCDKeyRequest for MOD");
        switch( _aPlayerController.m_stPlayerVerModCDKeyStatus.m_eCDKeyRequest )
        {
        case ECDKEY_FIRSTPASS:	log("ProcessPC_CDKeyRequest _aPlayerController.m_stPlayerVerModCDKeyStatus.m_eCDKeyRequest: ECDKEY_FIRSTPASS"@szLog);	break;
        case ECDKEY_WAITING_FOR_RESPONSE: log("ProcessPC_CDKeyRequest _aPlayerController.m_stPlayerVerModCDKeyStatus.m_eCDKeyRequest: ECDKEY_WAITING_FOR_RESPONSE"@szLog); break;
        case ECDKEY_NOT_VALID: log("ProcessPC_CDKeyRequest _aPlayerController.m_stPlayerVerModCDKeyStatus.m_eCDKeyRequest: ECDKEY_NOT_VALID"@szLog); break;
        case ECDKEY_VALID: log("ProcessPC_CDKeyRequest _aPlayerController.m_stPlayerVerModCDKeyStatus.m_eCDKeyRequest: ECDKEY_VALID"@szLog); break;
        break;
    }
}
}

function SaveInfo()
{
    local BYTE ATemp[16];
    local string szFilename;
    
    szFilename = "..\\" $ class'Actor'.static.GetModMgr().GetIniFilesDir() $ "\\" $ class'Actor'.static.GetModMgr().GetModKeyword();
    m_ModGSInfo.SaveConfig(szFilename);
    SaveConfig();
}

function CopyActivationIDInByteArray( BYTE _pArraySrc[16], OUT BYTE _pArrayDest[16])
{
    local INT i;
    
    for (i =0; i < 16; i++)
    {
        _pArrayDest[i] = _pArraySrc[i];
    }
}

defaultproperties
{
     m_ucActivationID(0)=148
     m_ucActivationID(1)=96
     m_ucActivationID(2)=108
     m_ucActivationID(3)=149
     m_ucActivationID(4)=96
     m_ucActivationID(5)=184
     m_ucActivationID(6)=73
     m_ucActivationID(7)=122
     m_ucActivationID(8)=191
     m_ucActivationID(9)=242
     m_ucActivationID(10)=76
     m_ucActivationID(11)=159
     m_ucActivationID(12)=201
     m_ucActivationID(13)=145
     m_ucActivationID(14)=66
     m_ucActivationID(15)=188
     m_iRSCDKeyPort=5777
     m_iModCDKeyPort=10777
     m_iRegSvrPort=6777
     m_bValidActivationID=True
     m_bUpdateServer=True
     m_fMaxTimeForResponse=10.000000
     m_szGSVersion="393"
     m_szUbiGuestAcct="Ubi_Guest"
     m_szUbiRemFileURL="http://gsconnect.ubisoft.com/gsinit.php?user=%s&dp=%s"
     m_szUbiHomePage="http://www.ubi.com/login/newuser?l=%s"
     m_szSavedPwd="bc2333"
     m_szGSInitFileName="./GSRouters.dat"
     m_iSelSrvIndex=-1
     m_bSavePWSave=True
     m_bAutoLISave=True
     m_Filters=(bDeathMatch=True,bTeamDeathMatch=True,bDisarmBomb=True,bHostageRescueAdv=True,bEscortPilot=True,bMission=True,bTerroristHunt=True,bTerroristHuntAdv=True,bScatteredHuntAdv=True,bCaptureTheEnemyAdv=True,bKamikaze=True,bHostageRescueCoop=True,bDefend=True,bRecon=True,bSquadDeathMatch=True,bSquadTeamDeathMatch=True,bDebugGameMode=True)
     m_szUserID="theorem"
}
