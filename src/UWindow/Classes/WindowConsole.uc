	//=============================================================================
// WindowConsole - console replacer to implement UWindow UI System
//=============================================================================
class WindowConsole extends Console;

// --- Constants ---
const TextMsgSize = 128;
const MaxLines = 64;

// --- Variables ---
var UWindowRootWindow Root;
var float MouseX;
var float MouseY;
var bool bShowLog;
var config bool bShowConsole;
var bool bUWindowActive;
var float OldClipX;
var float OldClipY;
var bool bCreatedRoot;
var config float MouseScale;
var bool bLocked;
var bool bLevelChange;
// R6CODE
var name ConsoleState;
var config string RootWindow;
// ^ NEW IN 1.60
var int ConsoleLines;
// String used to store IP of host server
var string szStoreIP;
var string OldLevel;
var bool bUWindowType;
var bool bBlackout;
var class<UWindowConsoleWindow> ConsoleClass;
var bool bTyping;
var bool bNoStuff;
// ^ NEW IN 1.60
var float MsgTick[64];
var string MsgText[64];
var float MsgTickTime;
var float MsgTime;
// ^ NEW IN 1.60
var int TextLines;
var int TopLine;
// ^ NEW IN 1.60
var int numLines;
// ^ NEW IN 1.60
var int Scrollback;
// ^ NEW IN 1.60
// Variables.
var Viewport Viewport;

// --- Functions ---
function bool KeyEvent(EInputAction Action, EInputKey Key, float Delta) {}
// ^ NEW IN 1.60
event Message(float MsgLife, coerce string Msg) {}
//===========================================================================================
// MenuLoadProfile: A profile was load
//===========================================================================================
function MenuLoadProfile(bool _bServerProfile) {}
function RenderUWindow(Canvas Canvas) {}
function CreateRootWindow(Canvas Canvas) {}
function NotifyAfterLevelChange() {}
function NotifyLevelChange() {}
function HistoryDown() {}
function HistoryUp() {}
function UpdateHistory() {}
function CloseUWindow() {}
function LaunchUWindow() {}
function ToggleUWindow() {}
function HideConsole() {}
function ShowConsole() {}
function ResetUWindow() {}
//function class<object> GetRestKitDescName(string WeaponNameTag);
function GetRestKitDescName(R6ServerInfo pServerOptions, GameReplicationInfo _GRI) {}

state UWindow
{
    function PostRender(Canvas Canvas) {}
    function bool KeyType(EInputKey Key) {}
// ^ NEW IN 1.60
    event Tick(float Delta) {}
    function bool KeyEvent(EInputKey Key, EInputAction Action, float Delta) {}
// ^ NEW IN 1.60
}

state UWindowCanPlay
{
    function PostRender(Canvas Canvas) {}
    function bool KeyType(EInputKey Key) {}
// ^ NEW IN 1.60
    event Tick(float Delta) {}
    function bool KeyEvent(EInputKey Key, EInputAction Action, float Delta) {}
// ^ NEW IN 1.60
    function BeginState() {}
}

defaultproperties
{
}
