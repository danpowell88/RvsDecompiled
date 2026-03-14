//=============================================================================
// GameReplicationInfo.
//=============================================================================
class GameReplicationInfo extends ReplicationInfo
    native
    nativereplication;

// --- Constants ---
const RSS_EndOfMatch; // value unavailable in binary
const RSS_InGameState; // value unavailable in binary
const RSS_InPreGameState; // value unavailable in binary
const RSS_CountDownStage; // value unavailable in binary
const RSS_PlayersConnectingStage; // value unavailable in binary

// --- Variables ---
// var ? GoalScore; // REMOVED IN 1.60
// var ? Teams; // REMOVED IN 1.60
// var ? Winner; // REMOVED IN 1.60
// var ? bTeamGame; // REMOVED IN 1.60
var /* replicated */ byte m_eCurrectServerState;
var /* replicated */ byte m_bRepMObjSuccess;
var /* replicated */ byte m_bRepMObjInProgress;
var /* replicated */ byte m_aRepMObjFailed[16];
var /* replicated */ byte m_aRepMObjCompleted[16];
var /* replicated */ string m_aRepMObjDescriptionLocFile[16];
// struct did not replicated well...
var /* replicated */ string m_aRepMObjDescription[16];
var config globalconfig /* replicated */ string ServerName;
// ^ NEW IN 1.60
var config globalconfig /* replicated */ string AdminName;
// ^ NEW IN 1.60
var config globalconfig /* replicated */ string AdminEmail;
// ^ NEW IN 1.60
var config globalconfig /* replicated */ string MOTDLine1;
// ^ NEW IN 1.60
var config globalconfig /* replicated */ string MOTDLine2;
// ^ NEW IN 1.60
var config globalconfig /* replicated */ string MOTDLine3;
// ^ NEW IN 1.60
var config globalconfig /* replicated */ string MOTDLine4;
// ^ NEW IN 1.60
var /* replicated */ bool m_bGameOverRep;
var /* replicated */ bool m_bRestartableByJoin;
// Assigned by GameInfo.
var /* replicated */ string GameName;
// Assigned by GameInfo.
var /* replicated */ string GameClass;
var config globalconfig /* replicated */ int ServerRegion;
// ^ NEW IN 1.60
var /* replicated */ string m_szGameTypeFlagRep;
//R6CODE
// are we in the PostBetweenRoundTime state
var /* replicated */ bool m_bInPostBetweenRoundTime;
// 0 = none, 1 = success, 2 = failed
var /* replicated */ byte m_bRepLastRoundSuccess;
//#ifdefR6PUNKBUSTER
// server is a PunkBuster server
var /* replicated */ bool m_bPunkBuster;
// ubi.com lobby ID
var /* replicated */ int m_iGameSvrLobbyID;
// Variables used for connection to ubi.com
// ubi.com group ID
var /* replicated */ int m_iGameSvrGroupID;
var /* replicated */ bool m_bRepAllowRadarOption;
// if the server allow the radar (a game type CAN restrict this EVEN IF the option is checked by the player)
var /* replicated */ bool m_bServerAllowRadar;
var /* replicated */ byte m_iNbWeaponsTerro;
var byte m_eOldServerState;
var bool m_bShowPlayerStates;
// assigned by game info and used by the clients to determine if map changed between rounds
var /* replicated */ int m_iMapIndex;
var byte m_bReceivedGameType;
var config globalconfig /* replicated */ string ShortName;
// ^ NEW IN 1.60
var /* replicated */ int TimeLimit;

// --- Functions ---
simulated function SetRepLastRoundSuccess(byte bLastRoundSuccess) {}
simulated function SetRepMObjSuccess(bool bSuccess) {}
simulated function SetRepMObjInProgress(bool bInProgress) {}
simulated function bool IsRepMObjFailed(int Index) {}
// ^ NEW IN 1.60
simulated function bool IsRepMObjCompleted(int Index) {}
// ^ NEW IN 1.60
simulated function string GetRepMObjString(int Index) {}
// ^ NEW IN 1.60
simulated function string GetRepMObjStringLocFile(int Index) {}
// ^ NEW IN 1.60
function SetServerState(byte NewState) {}
function SetRepMObjString(int Index, string szDesc, string szLocFile) {}
function SetRepMObjInfo(int Index, bool bFailed, bool bCompleted) {}
simulated function ResetRepMObjInfo() {}
simulated function bool IsInAGameState() {}
// ^ NEW IN 1.60
simulated function int GetRepMObjInfoArraySize() {}
// ^ NEW IN 1.60
//#ifdef R6CODE
function RefreshMPlayerInfo() {}
//#ifdef R6CODE
simulated function ResetOriginalData() {}
function Reset() {}
simulated function PostBeginPlay() {}
simulated event SaveRemoteServerSettings(string NewServerFile) {}
simulated event NewServerState() {}
//#ifdef R6CODE
simulated function ControllerStarted(R6GameMenuCom NewMenuCom) {}

defaultproperties
{
}
