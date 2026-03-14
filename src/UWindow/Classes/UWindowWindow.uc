//=============================================================================
// UWindowWindow - the parent class for all Window objects
//=============================================================================
class UWindowWindow extends UWindowBase;

#exec TEXTURE IMPORT NAME=BlackTexture FILE=TEXTURES\Black.PCX
#exec TEXTURE IMPORT NAME=WhiteTexture FILE=TEXTURES\White.PCX ALPHA=1

// --- Constants ---
const DE_WheelDownPressed =  15;
const DE_WheelUpPressed =  14;
const DE_HelpChanged =  13;
const DE_MouseEnter =  12;
const DE_DoubleClick =  11;
const DE_LMouseDown =  10;
const DE_MouseLeave =  9;
const DE_MouseMove =  8;
const DE_EnterPressed =  7;
const DE_RClick =  6;
const DE_MClick =  5;
const DE_Exit =  4;
const DE_Enter =  3;
const DE_Click =  2;
const DE_Change =  1;
const DE_Created =  0;

// --- Enums ---
enum WinMessage
{
	WM_LMouseDown,
	WM_LMouseUp,
	WM_MMouseDown,
	WM_MMouseUp,
	WM_RMouseDown,
	WM_RMouseUp,
	WM_MouseWheelDown,
	WM_MouseWheelUp,
	WM_KeyUp,
	WM_KeyDown,
	WM_KeyType,
	WM_Paint	// Window needs painting
};
enum eR6MenuWidgetMessage
{
    MWM_UBI_LOGIN_SUCCESS,  // Login performed successfully
    MWM_UBI_LOGIN_FAIL,     // Login attempted and failed
    MWM_UBI_LOGIN_SKIPPED,  // Login not attempted (already logged in)
    MWM_CDKEYVAL_SKIPPED,   // CD Key validation skipped
    MWM_CDKEYVAL_SUCCESS,   // CD Key validation successfull
    MWM_CDKEYVAL_FAIL,      // CD Key validation failed
    MWM_UBI_JOINIP_SUCCESS, // Join IP procedure successfull
    MWM_UBI_JOINIP_FAIL,    // Join IP procedure failed
    MWM_QUERYSERVER_SUCCESS,// Query server procedure successfull
    MWM_QUERYSERVER_FAIL,   // Query server procedure failed
    MWM_QUERYSERVER_TRYAGAIN
};

// --- Structs ---
struct MouseCursor
{
	var Texture tex;
	var int HotX;
	var int HotY;
	var byte WindowsCursor;
};

// --- Variables ---
// var ? HotX; // REMOVED IN 1.60
// var ? HotY; // REMOVED IN 1.60
// var ? WindowsCursor; // REMOVED IN 1.60
// var ? m_bDisplayCheckKeyFocus; // REMOVED IN 1.60
// var ? tex; // REMOVED IN 1.60
var float WinWidth;
var float WinHeight;
var UWindowLookAndFeel LookAndFeel;
// The root window
var UWindowRootWindow Root;
// Relationships to other windows
// Parent window
var UWindowWindow ParentWindow;
// Dimensions, offset relative to parent.
var float WinLeft;
var float WinTop;
var Region ClippingRegion;
// Pressed down in this window?
var bool bMouseDown;
// previous sibling window - next window below us
var UWindowWindow PrevSiblingWindow;
// Last child window - WinTop window first
var UWindowWindow LastChildWindow;
// Is UWindow active?
var bool bUWindowActive;
var Region m_BorderTextureRegion;
// Window is left onscreen when UWindow isn't active.
var bool bLeaveOnscreen;
var MouseCursor Cursor;
// The child of ours which is currently active
var UWindowWindow ActiveWindow;
// sibling window - next window above us
var UWindowWindow NextSiblingWindow;
// First child window - bottom window first
var UWindowWindow FirstChildWindow;
var bool bWindowVisible;
// Some arbitary owner window
var UWindowWindow OwnerWindow;
var Color m_BorderColor;
// Never the active window. Used for combo dropdowns7
var bool bTransient;
// Always on top
var bool bAlwaysOnTop;
// Some window we've opened modally.
var UWindowWindow ModalWindow;
// Accepts key messages
var bool bAcceptsFocus;
// Does this window accept hotkeys?
var bool bAcceptsHotKeys;
var float OrgXOffset;
var float OrgYOffset;
// Allows any window to have a tooltip
var string ToolTipString;
// Pressed down in this window?
var bool bRMouseDown;
// Pressed down in this window?
var bool bMMouseDown;
var float ClickTime;
var Texture m_BorderTexture;
var float RClickTime;
var float MClickTime;
// Window doesn't bring to front on click.
var bool bAlwaysBehind;
var bool m_bPreCalculatePos;
var float ClickX;
var float ClickY;
var float MClickX;
var float MClickY;
var float RClickX;
var float RClickY;
// Clipping disabled for this window?
var bool bNoClip;
// Accepts key messages all the time
var bool bAlwaysAcceptsFocus;
var bool bIgnoreLDoubleClick;
var bool bIgnoreMDoubleClick;
var bool bIgnoreRDoubleClick;
// Not display the back ground (to avoid heritance of paint(){})
var bool m_bNotDisplayBkg;
//Will be cast in ErenderStyle
var int m_BorderStyle;

// --- Functions ---
// function ? DrawClippedActor(...); // REMOVED IN 1.60
final function DrawStretchedTextureSegment(Texture Tex, float tH, float tW, float tY, float tX, float H, float W, float Y, float X, Canvas C) {}
final function float GetTime() {}
// ^ NEW IN 1.60
function LMouseDown(float Y, float X) {}
final function UWindowWindow CreateWindow(class<UWindowWindow> WndClass, optional name ObjectName, float X, float Y, float W, float H, optional UWindowWindow OwnerW, optional bool bUnique) {}
// ^ NEW IN 1.60
final function DrawStretchedTexture(Texture Tex, float H, float W, float Y, float X, Canvas C) {}
final function string TextSize(out float W, out float H, Canvas C, optional int _SpaceWidth, optional int _TotalWidth, string Text) {}
// ^ NEW IN 1.60
function Paint(float Y, float X, Canvas C) {}
final function SetSize(float W, float H) {}
final function ClipText(optional bool bCheckHotKey, coerce string S, float Y, float X, Canvas C) {}
final function DrawClippedTexture(Texture Tex, float Y, float X, Canvas C) {}
function Close(optional bool bByParent) {}
final function PlayerController GetPlayerOwner() {}
// ^ NEW IN 1.60
function FocusOtherWindow(UWindowWindow W) {}
function BeforePaint(float Y, float X, Canvas C) {}
function Created() {}
function Tick(float Delta) {}
final function bool MessageClients(float Y, float X, WinMessage Msg, Canvas C, int Key) {}
// ^ NEW IN 1.60
final function string RemoveAmpersand(string S) {}
// ^ NEW IN 1.60
final function SetAcceptsFocus() {}
function Resized() {}
final function ActivateWindow(int Depth, bool bTransientNoDeactivate) {}
final function GetMouseXY(out float Y, out float X) {}
final function bool MouseIsOver() {}
// ^ NEW IN 1.60
function DoubleClick(float Y, float X) {}
final function ShowChildWindow(UWindowWindow Child, optional bool bAtBack) {}
final function BringToFront() {}
function MouseMove(float Y, float X) {}
function ShowWindow() {}
final function DrawUpBevel(Texture t, float Y, float X, Canvas C, float H, float W) {}
// Ideally Key would be a EInputKey but I can't see that class here.
function WindowEvent(float Y, float X, int Key, Canvas C, WinMessage Msg) {}
function FocusWindow() {}
function LMouseUp(float Y, float X) {}
function ResolutionChanged(float H, float W) {}
final function HideChildWindow(UWindowWindow Child) {}
function MouseLeave() {}
final function DrawStretchedTextureSegmentRot(Canvas C, float fTexRotation, Texture Tex, float tH, float tW, float tY, float tX, float H, float W, float Y, float X) {}
function Texture GetLookAndFeelTexture() {}
// ^ NEW IN 1.60
function SetBorderColor(Color _NewColor) {}
final function LevelInfo GetEntryLevel() {}
// ^ NEW IN 1.60
final function bool WindowIsVisible() {}
// ^ NEW IN 1.60
function AfterPaint(float Y, float X, Canvas C) {}
function KeyDown(float Y, float X, int Key) {}
final function UWindowWindow FindWindowUnder(float Y, float X) {}
// ^ NEW IN 1.60
final function ReplaceText(out string Text, string Replace, string With) {}
final function CancelAcceptsFocus() {}
final function byte ParseAmpersand(out string Underline, out string Result, bool bCalcUnderline, string S) {}
// ^ NEW IN 1.60
final function DoTick(float Delta) {}
final function UWindowWindow FindChildWindow(class<UWindowWindow> ChildClass, optional bool bExactClass) {}
// ^ NEW IN 1.60
function WindowShown() {}
function WindowHidden() {}
function GetDesiredDimensions(out float H, out float W) {}
function bool HotKeyUp(float Y, float X, int Key) {}
// ^ NEW IN 1.60
//return true to break the chaining of input
//a window should return true when it uses the incomming input
function bool HotKeyDown(float Y, float X, int Key) {}
// ^ NEW IN 1.60
function Click(float Y, float X) {}
final function WindowToGlobal(out float GlobalY, out float GlobalX, float WinX, float WinY) {}
final function DrawMiscBevel(int BevelType, Canvas C, float X, float Y, float W, float H, Texture t) {}
function RMouseDown(float Y, float X) {}
function MouseEnter() {}
function bool IsActive() {}
// ^ NEW IN 1.60
final function ClipTextWidth(Canvas C, float X, float Y, coerce string S, float W) {}
function KeyUp(float Y, float X, int Key) {}
function MouseWheelDown(float Y, float X) {}
final function int WrapClipText(float X, coerce string S, float Y, Canvas C, optional int Length, optional int PaddingLength, optional bool bNoDraw, optional bool bCheckHotKey) {}
// ^ NEW IN 1.60
final function UWindowWindow CheckKeyFocusWindow() {}
// ^ NEW IN 1.60
function MouseWheelUp(float Y, float X) {}
final function PaintClients(Canvas C, float Y, float X) {}
final function UWindowWindow GetParent(class<UWindowWindow> ParentClass, optional bool bExactClass) {}
// ^ NEW IN 1.60
function KeyType(float Y, float X, int Key) {}
final function GlobalToWindow(out float WinY, out float WinX, float GlobalX, float GlobalY) {}
function bool MouseUpDown(float Y, float X, int Key) {}
// ^ NEW IN 1.60
function KeyFocusExit() {}
function KeyFocusEnter() {}
function NotifyAfterLevelChange() {}
function NotifyBeforeLevelChange() {}
function NotifyQuitUnreal() {}
function HideWindow() {}
function ToolTip(string strTip) {}
function RMouseUp(float Y, float X) {}
function ProcessGSMsg(string _szMsg) {}
// ^ NEW IN 1.60
// Should mouse events at these co-ordinates be passed through to underlying windows?
function bool CheckMousePassThrough(float X, float Y) {}
// ^ NEW IN 1.60
function MClick(float Y, float X) {}
function RClick(float Y, float X) {}
function BeginPlay() {}
function SetParent(UWindowWindow NewParent) {}
//===============================================================================
// ApplyResolutionOnWindowsPos: Change windows position base on current root resolution
//===============================================================================
function ApplyResolutionOnWindowsPos(float Y, float X) {}
//final function bool PropagateKey(WinMessage Msg, Canvas C, float X, float Y, int Key)
function bool PropagateKey(WinMessage Msg, Canvas C, float X, float Y, int Key) {}
// ^ NEW IN 1.60
final function DrawHorizTiledPieces(float Scale, float DestX, TexRegion T2, TexRegion T1, TexRegion T3, TexRegion T4, float DestW, TexRegion T5, Canvas C, float DestY, float DestH) {}
final function DrawVertTiledPieces(float Scale, float DestY, float DestH, TexRegion T1, TexRegion T2, TexRegion T3, TexRegion T4, TexRegion T5, float DestX, Canvas C, float DestW) {}
function DrawSimpleBackGround(Canvas C, Color _BGColor, optional byte Alpha, float H, float W, float Y, float X) {}
//R6CODE
function DrawSimpleBorder(Canvas C) {}
function StripCRLF(out string Text) {}
function UWindowMessageBox MessageBox(optional int TimeOut, optional MessageBoxResult EnterResult, MessageBoxResult ESCResult, MessageBoxButtons Buttons, string Message, string Title) {}
// ^ NEW IN 1.60
function SetCursor(MouseCursor C) {}
function SetAcceptsHotKeys(bool bNewAccpetsHotKeys) {}
function ShowModal(UWindowWindow W) {}
function MMouseUp(float Y, float X) {}
final function UWindowWindow GetButtonsDefinesUnique(class<UWindowWindow> WndClass) {}
// ^ NEW IN 1.60
final function SendToBack() {}
function EscClose() {}
function MMouseDown(float Y, float X) {}
function ProcessMenuKey(string KeyName, int Key) {}
final function SetMouseWindow() {}
function Deactivated() {}
function Activated() {}
function RDoubleClick(float Y, float X) {}
function MDoubleClick(float Y, float X) {}
function bool WaitModal() {}
// ^ NEW IN 1.60
//Overload this function to process the message box result.
function MessageBoxDone(UWindowMessageBox W, MessageBoxResult Result) {}
function PopUpBoxDone(MessageBoxResult Result, EPopUpID _ePopUpID) {}
final function LevelInfo GetLevel() {}
// ^ NEW IN 1.60
function SaveConfigs() {}
function SendMessage(eR6MenuWidgetMessage eMessage) {}
function NotifyWindow(UWindowWindow C, byte E) {}
// This is implemented over here because we need an access for the console
function SetServerOptions() {}
//===========================================================================================
// MenuLoadProfile: A profile was load
//===========================================================================================
function MenuLoadProfile(bool _bServerProfile) {}

defaultproperties
{
}
