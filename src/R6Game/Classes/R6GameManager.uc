//=============================================================================
// R6GameManager.uc: game manager object.
//
// Revision history:
//      * 22-04-2003 : Created by Jean-Francois Dube
//=============================================================================
class R6GameManager extends R6AbstractGameManager
    native;

// --- Variables ---
// var ? bShowLog; // REMOVED IN 1.60
// var ? m_GameService; // REMOVED IN 1.60
var R6Console m_GameMgrConsole;
// ^ NEW IN 1.60
var R6GSServers m_GameMgrGameService;
// ^ NEW IN 1.60

// --- Functions ---
// function ? GSClientManager(...); // REMOVED IN 1.60
// function ? InitGameManager(...); // REMOVED IN 1.60
// function ? InitializeGSClient(...); // REMOVED IN 1.60
event GMProcessMsg(string _szMsg) {}
// ^ NEW IN 1.60
function SetLocalPlayerCtrl(PlayerController _localPlayer) {}
// ^ NEW IN 1.60
function SetConsoleInGameMgr(Console _pConsole) {}
// ^ NEW IN 1.60
function Object GetGameMgrGameService() {}
// ^ NEW IN 1.60

defaultproperties
{
}
