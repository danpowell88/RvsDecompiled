//=============================================================================
// UWindowFramedWindow - a Windows95 style framed window
//=============================================================================
class UWindowFramedWindow extends UWindowWindow;

// --- Variables ---
var UWindowFrameCloseBox CloseBox;
var UWindowWindow ClientArea;
var bool bStatusBar;
var float MinWinWidth;
// ^ NEW IN 1.60
var float MinWinHeight;
var bool bMoving;
var bool bSizable;
var bool bBRSizing;
var bool bBSizing;
var bool bBLSizing;
var bool bRSizing;
var bool bLSizing;
var bool bTRSizing;
var bool bTSizing;
var bool bTLSizing;
// co-ordinates where the move was requested
var float MoveY;
var float MoveX;
// ^ NEW IN 1.60
var string StatusBarText;
var localized string WindowTitle;
var class<UWindowWindow> ClientClass;

// --- Functions ---
function BeforePaint(Canvas C, float X, float Y) {}
function Created() {}
function ToolTip(string strTip) {}
function Paint(Canvas C, float X, float Y) {}
function MouseMove(float X, float Y) {}
function Resized() {}
function LMouseDown(float Y, float X) {}
function WindowEvent(WinMessage Msg, int Key, float Y, float X, Canvas C) {}
function Texture GetLookAndFeelTexture() {}
// ^ NEW IN 1.60
function bool IsActive() {}
// ^ NEW IN 1.60
function WindowHidden() {}

defaultproperties
{
}
