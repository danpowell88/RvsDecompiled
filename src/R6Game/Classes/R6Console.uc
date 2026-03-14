//============================================================================//
// Class            R6Console
// Date             20 April 2001
// Description
//
//  Revision history:
//    
//============================================================================//
class R6Console extends WindowConsole;

#exec OBJ LOAD FILE=..\Sounds\Music.uax PACKAGE=Music

// --- Constants ---
const K_CHECKTIME_INTERVAL =  3000;
const K_CHECKTIME_TIMEOUT =  9000;

// --- Enums ---
enum eLeaveGame
{
    // enum values not recoverable from binary — see 1.56 source
};

// --- Variables ---
// var ? bMultiPlayerGameActive; // REMOVED IN 1.60
// var ? m_bAutoLoginFirstPass; // REMOVED IN 1.60
// var ? m_bCreateUbiServer; // REMOVED IN 1.60
// var ? m_bJoinUbiServer; // REMOVED IN 1.60
// var ? m_eLastPreviousWID; // REMOVED IN 1.60
// var ? m_iRetryTime; // REMOVED IN 1.60
var array<array> m_aMissionDescriptions;
//////////////////////////////////////////////////////////////////////////////////
//This Stuff Is single Player Game Specific and Might Need to be moved elsewhere
//This is needed to launch the game with the good operatives and
/////////////////////////////////////////////////////////////////////////////////
var array<array> m_aCampaigns;
// containt all the map unlock for each campaign
var R6PlayerCustomMission m_playerCustomMission;
var eLeaveGame m_eNextStep;
// ^ NEW IN 1.60
var R6PlayerCampaign m_PlayerCampaign;
// Manages servers on the LAN
var R6LanServers m_LanServers;
var bool bLaunchMultiPlayer;
// Manages servers from game service
var R6GSServers m_GameService;
var R6Campaign m_CurrentCampaign;
var bool bLaunchWasCalled;
var bool bResetLevel;
var bool bReturnToMenu;
//R6CODE
var bool m_bInGamePlanningKeyDown;
// To render one last frame before leaving
var bool m_bSkipAFrameAndStart;
// render the menu one time before processing key in the case of and connection interruption
var bool m_bRenderMenuOneTime;
// currently create new menu and load sound bank fct StartR6Game
var bool m_bStartR6GameInProgress;
var array<array> m_AWIDList;
// ^ NEW IN 1.60
var bool bCancelFire;
var Sound m_StopMainMenuMusic;
//var string szStoreIP;           // String used to store IP of host server
// String used to store game password
var string szStoreGamePassWd;
// String used to store error to be later displayed
var string m_szLastError;
// Time at which the last check was made to see if ubi.com client is still responding
var int m_iLastCheckTime;
// Time at which the last check was made to see if ubi.com client is still responding
var int m_iLastSuccCheckTime;

// --- Functions ---
// function ? GameServiceTick(...); // REMOVED IN 1.60
// function ? GoToGame(...); // REMOVED IN 1.60
// function ? MSClientManager(...); // REMOVED IN 1.60
// function ? MinimizeAndPauseMusic(...); // REMOVED IN 1.60
// function ? Tick(...); // REMOVED IN 1.60
// function ? gg(...); // REMOVED IN 1.60
function PostRender(Canvas Canvas) {}
function bool KeyEvent(EInputKey Key, EInputAction Action, float Delta) {}
// ^ NEW IN 1.60
function GetRestKitDescName(R6ServerInfo pServerOptions, GameReplicationInfo gameRepInfo) {}
//------------------------------------------------------------------
// UpdateCurrentMapAvailable
//
//------------------------------------------------------------------
function bool UpdateCurrentMapAvailable(R6PlayerCampaign pCampaign, optional bool bCheckCampaignMission) {}
// ^ NEW IN 1.60
function InitCampaignAndMissionDescription() {}
function LeaveR6Game(eLeaveGame _bwhatToDo) {}
function CreateRootWindow(Canvas Canvas) {}
function Object SetGameServiceLinks(PlayerController _localPlayer) {}
// ^ NEW IN 1.60
event R6ConnectionFailed(string szError) {}
// MPF: LoadCampaignIni
function LoadCampaignIni(string szCampaign) {}
function LaunchInstructionMenu(bool bShow, int iParagraph, int iBox, R6InstructionSoundVolume pISV) {}
//------------------------------------------------------------------
// GetAllMissionDescriptions
//
//------------------------------------------------------------------
function GetAllMissionDescriptions(string szCurrentMapDir) {}
function CleanAndChangeMod(array<array> _AWIDListToUse) {}
function CleanSound(eLeaveGame _bwhatToDo) {}
function CloseR6MainMenu(optional bool bKeepInputSystem) {}
function InitMod() {}
function PreloadMapForPlanning() {}
exec function unlock() {}
//==============================================================================
// GetSpawnNumber -  Helper function, returns the spawning point number.
//==============================================================================
function int GetSpawnNumber() {}
// ^ NEW IN 1.60
function LaunchR6Game(optional bool bSkipFrameAndStart_) {}
//------------------------------------------------------------------
// UnlockMissions
//	- updated every time UpdateCurrentMapAvailable is changed
//------------------------------------------------------------------
function UnlockMissions() {}
function bool MapAlreadyInList(string szIniFilename) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// GetCampaignFromString
//
//------------------------------------------------------------------
function R6Campaign GetCampaignFromString(string szName) {}
// ^ NEW IN 1.60
function SendGoCode(EGoCode eGo) {}
function StartR6Game(optional bool bResetLevel) {}
function CreateInGameMenus() {}
//------------------------------------------------------------------
// Inhereited
//------------------------------------------------------------------
event Message(coerce string Msg, float MsgLife) {}
event R6ProgressMsg(string _Str2, string _Str1, float Seconds) {}
event LaunchR6MainMenu() {}
event Initialized() {}
function InitializedGameService() {}
event UserDisconnected() {}
event ServerDisconnected() {}
event R6ConnectionSuccess() {}
event R6ConnectionInterrupted() {}
event R6ConnectionInProgress() {}
event string GetStoreGamePwd() {}
// ^ NEW IN 1.60
function bool KeyType(EInputKey Key) {}
// ^ NEW IN 1.60
function NotifyLevelChange() {}
function CleanPlanning() {}
function ResetR6Game() {}
function LaunchR6MultiPlayerGame() {}
//=================================================================================
// LaunchTraining(): Launch training map and in-game menu, process is like single player map loading
//=================================================================================
function LaunchTraining() {}

state Game
{
    function bool KeyEvent(EInputAction eAction, float fDelta, EInputKey eKey) {}
// ^ NEW IN 1.60
    function PostRender(Canvas Canvas) {}
    function BeginState() {}
    function EndState() {}
}

state UWindow
{
    function bool KeyEvent(EInputKey eKey, float fDelta, EInputAction eAction) {}
// ^ NEW IN 1.60
    function PostRender(Canvas Canvas) {}
    function BeginState() {}
}

state Typing
{
    function bool KeyEvent(EInputKey Key, EInputAction Action, float Delta) {}
// ^ NEW IN 1.60
    function PostRender(Canvas Canvas) {}
}

state TrainingInstruction
{
    function bool KeyEvent(EInputAction Action, EInputKey Key, float Delta) {}
// ^ NEW IN 1.60
}

defaultproperties
{
}
