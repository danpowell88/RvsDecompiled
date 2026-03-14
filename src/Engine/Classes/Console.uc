//=============================================================================
// Console - A quick little command line console that accepts most commands.

//=============================================================================
class Console extends Interaction
    native;

#exec TEXTURE IMPORT NAME=ConsoleBK FILE=..\UWindow\TEXTURES\Black.PCX
#exec TEXTURE IMPORT NAME=ConsoleBdr FILE=..\UWindow\TEXTURES\White.PCX

// --- Constants ---
const MaxHistory = 16;

// --- Variables ---
var string TypedStr;
// ^ NEW IN 1.60
var int HistoryCur;
var int HistoryTop;
// ^ NEW IN 1.60
var int HistoryBot;
// ^ NEW IN 1.60
//R6CODE
var bool bShowLog;
// Ignore Key presses until a new KeyDown is received
var bool bIgnoreKeys;
// Holds the current command, and the history
var string History[16];
var bool bShowConsoleLog;
var bool m_bStringIsTooLong;
// Turn when someone is typing on the console
var bool bTyping;
// Key used to bring up the console
var config globalconfig byte ConsoleKey;
// Flag to indicate if the game was launched by the ubi.com client
var bool m_bStartedByGSClient;
// Flag to indicate that this game will not be using UBI.com
var bool m_bNonUbiMatchMaking;
// Flag to indicate that this host will not be using UBI.com
var bool m_bNonUbiMatchMakingHost;
// Flag to indicate that a process is interrupted by user or not
var bool m_bInterruptConnectionProcess;
var bool m_bAutoLoginFirstPass;
// ^ NEW IN 1.60
var bool m_bChangeModInProgress;
// ^ NEW IN 1.60
var config globalconfig int iBrowserMaxNbServerPerPage;

// --- Functions ---
// function ? GameServiceTick(...); // REMOVED IN 1.60
// function ? ListMods(...); // REMOVED IN 1.60
// function ? ListRegObj(...); // REMOVED IN 1.60
// function ? ShowModInfo(...); // REMOVED IN 1.60
// function ? Type(...); // REMOVED IN 1.60
function bool KeyType(EInputKey Key) {}
// ^ NEW IN 1.60
function bool KeyEvent(EInputAction Action, EInputKey Key, float Delta) {}
// ^ NEW IN 1.60
exec function type() {}
// ^ NEW IN 1.60
exec function TeamTalk() {}
function GetAllMissionDescriptions(string szCurrentMapDir) {}
exec function Talk() {}
event Message(coerce string Msg, float MsgLife) {}

state Typing
{
    function bool KeyType(EInputKey Key) {}
// ^ NEW IN 1.60
    function bool KeyEvent(EInputKey Key, EInputAction Action, float Delta) {}
// ^ NEW IN 1.60
    function PostRender(Canvas Canvas) {}
    exec function type() {}
// ^ NEW IN 1.60
    function BeginState() {}
    function EndState() {}
}

defaultproperties
{
}
