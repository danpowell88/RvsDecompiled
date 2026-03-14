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

// --- Variables ---
// var ? bShowLog; // REMOVED IN 1.60
// var ? iGroupID; // REMOVED IN 1.60
// var ? iLobbySrvID; // REMOVED IN 1.60
// var ? iStatus; // REMOVED IN 1.60
// var ? m_GaveServerID; // REMOVED IN 1.60
// var ? m_PingReqList; // REMOVED IN 1.60
// var ? m_bCDKeyNotUsed; // REMOVED IN 1.60
// var ? m_bConnectedToServer; // REMOVED IN 1.60
// var ? m_bGSClientInitialized; // REMOVED IN 1.60
// var ? m_bGameServiceInit; // REMOVED IN 1.60
// var ? m_bLoggedInToFriendService; // REMOVED IN 1.60
// var ? m_bLoggedInToLobbyService; // REMOVED IN 1.60
// var ? m_bLoggedInToServer; // REMOVED IN 1.60
// var ? m_bMODCDKeyRequest; // REMOVED IN 1.60
// var ? m_bMSRequestFinished; // REMOVED IN 1.60
// var ? m_bPingReceived; // REMOVED IN 1.60
// var ? m_bPingsPending; // REMOVED IN 1.60
// var ? m_bRefreshInProgress; // REMOVED IN 1.60
// var ? m_bRegSrvrConnectionLost; // REMOVED IN 1.60
// var ? m_bServerJoined; // REMOVED IN 1.60
// var ? m_bUpdateServer; // REMOVED IN 1.60
// var ? m_eCDKeyNotUsedRequest; // REMOVED IN 1.60
// var ? m_eCreateAccountRequest; // REMOVED IN 1.60
// var ? m_eCreateGameRequest; // REMOVED IN 1.60
// var ? m_eGSGameState; // REMOVED IN 1.60
// var ? m_eGameConnectedRequest; // REMOVED IN 1.60
// var ? m_eGameReadyRequest; // REMOVED IN 1.60
// var ? m_eGameStartRequest; // REMOVED IN 1.60
// var ? m_eJoinLobbyRequest; // REMOVED IN 1.60
// var ? m_eJoinRoomRequest; // REMOVED IN 1.60
// var ? m_eJoinServerRequest; // REMOVED IN 1.60
// var ? m_eJoinWaitModuleRequest; // REMOVED IN 1.60
// var ? m_eLoginFriendServiceRequest; // REMOVED IN 1.60
// var ? m_eLoginLobbyServiceRequest; // REMOVED IN 1.60
// var ? m_eLoginRouterRequest; // REMOVED IN 1.60
// var ? m_eLoginWaitModuleRequest; // REMOVED IN 1.60
// var ? m_eMSClientInitRequest; // REMOVED IN 1.60
// var ? m_eMenuCDKeyAuthorization; // REMOVED IN 1.60
// var ? m_eMenuCDKeyFailReason; // REMOVED IN 1.60
// var ? m_eMenuCDKeyNotUsed; // REMOVED IN 1.60
// var ? m_eMenuCrAcctFailReason; // REMOVED IN 1.60
// var ? m_eMenuCrGameFailReason; // REMOVED IN 1.60
// var ? m_eMenuCreateAccount; // REMOVED IN 1.60
// var ? m_eMenuCreateGame; // REMOVED IN 1.60
// var ? m_eMenuGetCDKeyActID; // REMOVED IN 1.60
// var ? m_eMenuJoinLobby; // REMOVED IN 1.60
// var ? m_eMenuJoinRoomFailReason; // REMOVED IN 1.60
// var ? m_eMenuJoinServer; // REMOVED IN 1.60
// var ? m_eMenuLogMasSvrFailReason; // REMOVED IN 1.60
// var ? m_eMenuLoginFailReason; // REMOVED IN 1.60
// var ? m_eMenuLoginMasterSvr; // REMOVED IN 1.60
// var ? m_eMenuLoginRegServer; // REMOVED IN 1.60
// var ? m_eMenuLoginUbidotcom; // REMOVED IN 1.60
// var ? m_eMenuUpdateServer; // REMOVED IN 1.60
// var ? m_eMenuUserValidation; // REMOVED IN 1.60
// var ? m_eRSReqState; // REMOVED IN 1.60
// var ? m_eRegServerConnectRequest; // REMOVED IN 1.60
// var ? m_eRegServerGetLobbiesRequest; // REMOVED IN 1.60
// var ? m_eRegServerLoginRequest; // REMOVED IN 1.60
// var ? m_eRegServerLoginRouterRequest; // REMOVED IN 1.60
// var ? m_eRegServerRegOnLobbyRequest; // REMOVED IN 1.60
// var ? m_eRegServerUpdateRequest; // REMOVED IN 1.60
// var ? m_eUserValidationRequest; // REMOVED IN 1.60
// var ? m_fCDKeyGetActIDTime; // REMOVED IN 1.60
// var ? m_fCDKeyGetAuthorizationTime; // REMOVED IN 1.60
// var ? m_fCDKeyStartTime; // REMOVED IN 1.60
// var ? m_fCreateAccountStartTime; // REMOVED IN 1.60
// var ? m_fCreateGameStartTime; // REMOVED IN 1.60
// var ? m_fGameConnectedStartTime; // REMOVED IN 1.60
// var ? m_fGameReadyStartTime; // REMOVED IN 1.60
// var ? m_fGameStartStartTime; // REMOVED IN 1.60
// var ? m_fJoinLobbyStartTime; // REMOVED IN 1.60
// var ? m_fJoinRoomStartTime; // REMOVED IN 1.60
// var ? m_fJoinServerTime; // REMOVED IN 1.60
// var ? m_fJoinWaitModuleStartTime; // REMOVED IN 1.60
// var ? m_fLoginFriendServiceStartTime; // REMOVED IN 1.60
// var ? m_fLoginLobbyServiceStartTime; // REMOVED IN 1.60
// var ? m_fLoginRouterStartTime; // REMOVED IN 1.60
// var ? m_fLoginWaitModuleStartTime; // REMOVED IN 1.60
// var ? m_fMSClientInitStartTime; // REMOVED IN 1.60
// var ? m_fRefreshTime; // REMOVED IN 1.60
// var ? m_fRegServerConnectTime; // REMOVED IN 1.60
// var ? m_fRegServerGetLobbiesTime; // REMOVED IN 1.60
// var ? m_fRegServerLoginTime; // REMOVED IN 1.60
// var ? m_fRegServerRegOnLobbyTime; // REMOVED IN 1.60
// var ? m_fRegServerRouterLoginTime; // REMOVED IN 1.60
// var ? m_fRegServerUpdateTime; // REMOVED IN 1.60
// var ? m_fUserValidationTime; // REMOVED IN 1.60
// var ? m_iGroupID; // REMOVED IN 1.60
// var ? m_iLobbyIndex; // REMOVED IN 1.60
// var ? m_iLobbySrvID; // REMOVED IN 1.60
// var ? m_iMaxAvailPorts; // REMOVED IN 1.60
// var ? m_iOwnGroupID; // REMOVED IN 1.60
// var ? m_iOwnLobbySrvID; // REMOVED IN 1.60
// var ? m_iRetryTime; // REMOVED IN 1.60
// var ? m_iRoomCreatedGroupID; // REMOVED IN 1.60
// var ? m_iWaitModulePort; // REMOVED IN 1.60
// var ? m_szAuthorizationID; // REMOVED IN 1.60
// var ? m_szCDKey; // REMOVED IN 1.60
// var ? m_szCountry; // REMOVED IN 1.60
// var ? m_szEmail; // REMOVED IN 1.60
// var ? m_szFirstName; // REMOVED IN 1.60
// var ? m_szGSClientAltIP; // REMOVED IN 1.60
// var ? m_szLastName; // REMOVED IN 1.60
// var ? m_szModAuthorizationID; // REMOVED IN 1.60
// var ? m_szNetGameName; // REMOVED IN 1.60
// var ? m_szRSAuthorizationID; // REMOVED IN 1.60
// var ? m_szRSGlobalID; // REMOVED IN 1.60
// var ? m_szRegSvrUserID; // REMOVED IN 1.60
// var ? m_szUBIClientVersion; // REMOVED IN 1.60
// var ? m_szUbiGuestAcct; // REMOVED IN 1.60
// var ? m_ucProcessActivationID; // REMOVED IN 1.60
// var ? szAlias; // REMOVED IN 1.60
// var ? szMessage; // REMOVED IN 1.60
// var ? szUserId; // REMOVED IN 1.60
var R6ModGSInfo m_ModGSInfo;
// User password for GameService
var string m_szPassword;
// Auto log in of the player is in progress
var bool m_bAutoLoginInProgress;
// ubi globalID (string)
var config string m_szGlobalID;
// ubi.com remote file URL
var config string m_szUbiRemFileURL;
// The version of the gs-game
var config string m_szGSVersion;
// Saved user password for GameService
var config string m_szSavedPwd;
var config int m_iRSCDKeyPort;
var config int m_iModCDKeyPort;
// Port use for the register server communication
var config int m_iRegSvrPort;
// CDKey validation server activation ID
var config byte m_ucActivationID[16];
// CDKey validation server activation ID valid flag
var config bool m_bValidActivationID;
// Temporary label to disable CDKEY code
var config bool m_bUseCDKey;
// ubi.com home page
var string m_szUbiHomePage;
var string m_szGSInitFileName;
// IP address recieved from ubi.com client
var string m_szGSClientIP;
// Server name recieved from ubi.com client
var string m_szGSServerName;
// Game password recieved from ubi.com client
var string m_szGSPassword;
var float m_fMaxTimeForResponse;
// Max number of players recieved from ubi.com client
var int m_iGSNumPlayers;
// The ubi.com client is not reponding
var bool m_bUbiComClientDied;
// The ubi.com room has been destroyed
var bool m_bUbiComRoomDestroyed;
// Usrename and password for ubi.com account entered
var bool m_bUbiAccntInfoEntered;
// initgame has been called
var bool m_bInitGame;
// Logged in to ubi.com
var bool m_bLoggedInUbiDotCom;
// Auto log in failed, reset in menu system
var bool m_bAutoLoginFailed;
// The list is finished being
var bool m_bRefreshFinished;
var bool m_bStartedByGSClient;

// --- Functions ---
// function ? CopyActivationIDInByteArray(...); // REMOVED IN 1.60
// function ? Created(...); // REMOVED IN 1.60
// function ? GameServiceManager(...); // REMOVED IN 1.60
// function ? InitModInfo(...); // REMOVED IN 1.60
// function ? InitProcessUpdateUbiServer(...); // REMOVED IN 1.60
// function ? LogDebugProcessCDKeyRequest(...); // REMOVED IN 1.60
// function ? LogOutServer(...); // REMOVED IN 1.60
// function ? LoginRegServer(...); // REMOVED IN 1.60
// function ? MasterServerManager(...); // REMOVED IN 1.60
// function ? ProcessInternetSrv(...); // REMOVED IN 1.60
// function ? ProcessJoinServerRequest(...); // REMOVED IN 1.60
// function ? ProcessMSClientInitRequest(...); // REMOVED IN 1.60
// function ? ProcessPC_CDKeyRequest(...); // REMOVED IN 1.60
// function ? ProcessRegServerGetLobbiesRequest(...); // REMOVED IN 1.60
// function ? ProcessRegServerLoginRequest(...); // REMOVED IN 1.60
// function ? ProcessRegServerLoginRouterRequest(...); // REMOVED IN 1.60
// function ? ProcessRegServerRegOnLobbyRequest(...); // REMOVED IN 1.60
// function ? ProcessRegServerUpdateRequest(...); // REMOVED IN 1.60
// function ? RequestModCDKeyProcess(...); // REMOVED IN 1.60
// function ? SetGSGameState(...); // REMOVED IN 1.60
// function ? SetGlobalIDToString(...); // REMOVED IN 1.60
// function ? UpdateServerRegServer(...); // REMOVED IN 1.60
// function ? UpdateServerUbiCom(...); // REMOVED IN 1.60
// function ? joinServer(...); // REMOVED IN 1.60
//=============================================================================
// Set the user ID and password for the ubi.com account
//=============================================================================
function SetUbiAccount(string szPassword, string szUserID) {}
final native function NativeMSCLientJoinServer(int iLobbyID, int iGroupID, string szPassword) {}
// ^ NEW IN 1.60
final native function NativeSetMatchResult(string szUbiUserID, int iValue, int iField) {}
// ^ NEW IN 1.60
final native function NativeMSClientReqAltInfo(int iLobbyID, int iGroupID) {}
// ^ NEW IN 1.60
event string GetConsoleStoreIP(PlayerController _aPlayerController) {}
// ^ NEW IN 1.60
final native function SetLastServerQueried(string szIPAddress) {}
// ^ NEW IN 1.60
event bool IsGlobalIDBanned(string _szGlobalID, R6AbstractGameInfo _GameInfo) {}
// ^ NEW IN 1.60
final native function NativeLogOutServer(GameReplicationInfo _GRI) {}
// ^ NEW IN 1.60
//===========================================================================
// RefreshOneServer - Start process to refresh an indivisual server.
//===========================================================================
final native function RefreshOneServer(int iIdx) {}
final native function EnterCDKey(string _szCDKey) {}
// ^ NEW IN 1.60
final native function bool NativeProcessIcmpPing(string _ServerIpAddress, out int piPingTime) {}
// ^ NEW IN 1.60
function SaveInfo() {}
event string TempGetPBConnectStatus(PlayerController _aPlayerController) {}
// ^ NEW IN 1.60
//===============================================================================
// GetSelectedServerIP:  Return the IP address of the selected server, include
// a check to make sure the server is responding, else try the alternate IP.
// Also remove the port number.
//===============================================================================
function string GetSelectedServerIP() {}
// ^ NEW IN 1.60
function bool CallNativeProcessIcmpPing(string _ServerIpAddress, out int piPingTime) {}
// ^ NEW IN 1.60
event string GetLocallyBoundIpAddr() {}
// ^ NEW IN 1.60
function CallNativeSetMatchResult(int iValue, int iField, string szUbiUserID) {}
//===============================================================================
// DisplayTime: display the time in min (have to be in sec)
//===============================================================================
function string DisplayTime(int _iTimeToConvert) {}
// ^ NEW IN 1.60
event ProcessServerMsg(PlayerController _aPlayerController, string _szErrorMsgKey) {}
// ^ NEW IN 1.60
event HandleNewLobbyConnection(LevelInfo _Level) {}
//=============================================================================
// FillCreateGameInfo Fill the m_CrGameSrvInfo structure with all the
// required data from the gameinfo, levelinfo, and beacon
//=============================================================================
event FillCreateGameInfo(LevelInfo pLevel, GameInfo pGameInfo) {}
//=============================================================================
// Initialize the game service software, call native function to download
// data from ubi.com.
//=============================================================================
final native function bool Initialize() {}
final native function bool InitGSCDKey() {}
// ^ NEW IN 1.60
//=============================================================================
// Establish initial connection to the server
//=============================================================================
final native function bool InitializeMSClient() {}
// ^ NEW IN 1.60
//=============================================================================
// Uninitialize the MSClient SDK (logout)
//=============================================================================
final native function bool UnInitializeMSClient() {}
// ^ NEW IN 1.60
final native function RefreshServers() {}
final native function bool IsRefreshServersInProgress() {}
// ^ NEW IN 1.60
final native function StopRefreshServers() {}
// ^ NEW IN 1.60
final native function float NativeGetSeconds() {}
// ^ NEW IN 1.60
final native function bool NativeGetMSClientInitialized() {}
// ^ NEW IN 1.60
//===============================================================================
// This function returns the maximum allowed size of the server name, this is
// limited by ubi.com
//===============================================================================
final native function int GetMaxUbiServerNameSize() {}
// ^ NEW IN 1.60
final native function bool NativeIsRouterDisconnect() {}
// ^ NEW IN 1.60
final native function bool NativeIsWaitingForGSInit() {}
// ^ NEW IN 1.60
final native function bool NativeIsGSReadyToChangeMod() {}
// ^ NEW IN 1.60
final native function NativeUpdateServer() {}
// ^ NEW IN 1.60
final native function bool HandleAnyLobbyConnectionFail() {}
// ^ NEW IN 1.60
event InitializeMod() {}
// ^ NEW IN 1.60
function StartAutoLogin() {}
function string MyID() {}
// ^ NEW IN 1.60
event int GetMaxAvailPorts() {}
// ^ NEW IN 1.60
function int getServerListSize() {}
// ^ NEW IN 1.60
//===============================================================================
// This function has to inform the server that the end of round (a Ubi match) data
// has been sent to Ubi.com
//===============================================================================
event EndOfRoundDataSent() {}

defaultproperties
{
}
