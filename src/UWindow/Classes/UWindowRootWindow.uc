//=============================================================================
// UWindowRootWindow - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// UWindowRootWindow - the root window.
//=============================================================================
class UWindowRootWindow extends UWindowWindow
    config;

enum eRootID
{
	RootID_UWindow,                 // 0
	RootID_R6Menu,                  // 1
	RootID_R6MenuInGame,            // 2
	RootID_R6MenuInGameMulti        // 3
};

enum eGameWidgetID
{
	WidgetID_None,                  // 0
	InGameID_EscMenu,               // 1
	InGameID_Debriefing,            // 2
	InGameID_TrainingInstruction,   // 3
	TrainingWidgetID,               // 4
	SinglePlayerWidgetID,           // 5
	CampaignPlanningID,             // 6
	MainMenuWidgetID,               // 7
	IntelWidgetID,                  // 8
	PlanningWidgetID,               // 9
	RetryCampaignPlanningID,        // 10
	RetryCustomMissionPlanningID,   // 11
	GearRoomWidgetID,               // 12
	ExecuteWidgetID,                // 13
	CustomMissionWidgetID,          // 14
	MultiPlayerWidgetID,            // 15
	OptionsWidgetID,                // 16
	PreviousWidgetID,               // 17
	CreditsWidgetID,                // 18
	MPCreateGameWidgetID,           // 19
	UbiComWidgetID,                 // 20
	UbiComModWidgetID,              // 21
	NonUbiWidgetID,                 // 22
	InGameMPWID_Writable,           // 23
	InGameMPWID_TeamJoin,           // 24
	InGameMPWID_Intermission,       // 25
	InGameMPWID_InterEndRound,      // 26
	InGameMPWID_EscMenu,            // 27
	InGameMpWID_RecMessages,        // 28
	InGameMpWID_MsgOffensive,       // 29
	InGameMpWID_MsgDefensive,       // 30
	InGameMpWID_MsgReply,           // 31
	InGameMpWID_MsgStatus,          // 32
	InGameMPWID_Vote,               // 33
	InGameMPWID_CountDown,          // 34
	InGameID_OperativeSelector,     // 35
	MultiPlayerError,               // 36
	MultiPlayerErrorUbiCom,         // 37
	MenuQuitID                      // 38
};

// NEW IN 1.60
var UWindowRootWindow.eRootID m_eRootId;
var UWindowRootWindow.eGameWidgetID m_eCurWidgetInUse;  // Current widget ID display on screen
var UWindowRootWindow.eGameWidgetID m_ePrevWidgetInUse;  // Previous widget ID display on screen
var bool bMouseCapture;
var bool bRequestQuit;
var bool bAllowConsole;
//R6Code
var bool m_bUseAimIcon;
var bool m_bUseDragIcon;
var bool m_bScaleWindowToRoot;
var bool m_bWidgetResolutionFix;  // this is set in root by a widget to tell to the options if resolution is fix or not
var float MouseX;
// NEW IN 1.60
var float MouseY;
var float OldMouseX;
// NEW IN 1.60
var float OldMouseY;
//var config float		GUIScale;
var float GUIScale;  // Alex- This is to prevent set res call to ovewrite this value in config file
var float RealWidth;
// NEW IN 1.60
var float RealHeight;
var float QuitTime;
var float m_fWindowScaleX;
// NEW IN 1.60
var float m_fWindowScaleY;
var UWindowWindow MouseWindow;  // The window the mouse is over
var WindowConsole Console;
var UWindowWindow FocusedWindow;
var UWindowWindow KeyFocusWindow;  // window with keyboard focus
var UWindowHotkeyWindowList HotkeyWindows;
var Font Fonts[30];
var UWindowLookAndFeel LooksAndFeels[20];
var R6GameColors Colors;
var UWindowMenuClassDefines MenuClassDefines;
// NEW IN 1.60
var UWindowWindow m_NotifyMsgWindow;
var MouseCursor NormalCursor;
// NEW IN 1.60
var MouseCursor MoveCursor;
// NEW IN 1.60
var MouseCursor DiagCursor1;
// NEW IN 1.60
var MouseCursor HandCursor;
// NEW IN 1.60
var MouseCursor HSplitCursor;
// NEW IN 1.60
var MouseCursor VSplitCursor;
// NEW IN 1.60
var MouseCursor DiagCursor2;
// NEW IN 1.60
var MouseCursor NSCursor;
// NEW IN 1.60
var MouseCursor WECursor;
// NEW IN 1.60
var MouseCursor WaitCursor;
var MouseCursor AimCursor;
var MouseCursor DragCursor;
var config string LookAndFeelClass;

function ChangeCurrentWidget(UWindowRootWindow.eGameWidgetID widgetID)
{
	return;
}

function ResetMenus(optional bool _bConnectionFailed)
{
	return;
}

function UpdateMenus(int iWhatToUpdate)
{
	return;
}

function ChangeInstructionWidget(Actor pISV, bool bShow, int iBox, int iParagraph)
{
	return;
}

function StopPlayMode()
{
	return;
}

function bool PlanningShouldProcessKey()
{
	return;
}

function bool PlanningShouldDrawPath()
{
	return;
}

function UWindowBase.EPopUpID GetSimplePopUpID()
{
	return;
}

function SimplePopUp(string _szTitle, string _szText, UWindowBase.EPopUpID _ePopUpID, optional int _iButtonsType, optional bool bAddDisableDlg, optional UWindowWindow OwnerWindow)
{
	return;
}

function ModifyPopUpInsideText(array<string> _ANewText)
{
	return;
}

function bool GetMapNameLocalisation(string _szMapName, out string _szMapNameLoc, optional bool _bReturnInitName)
{
	return;
}

function BeginPlay()
{
	Root = self;
	MouseWindow = self;
	KeyFocusWindow = self;
	return;
}

function UWindowLookAndFeel GetLookAndFeel(string LFClassName)
{
	local int i;
	local Class<UWindowLookAndFeel> LFClass;

	LFClass = Class<UWindowLookAndFeel>(DynamicLoadObject(LFClassName, Class'Core.Class'));
	i = 0;
	J0x22:

	// End:0xA9 [Loop If]
	if(__NFUN_150__(i, 20))
	{
		// End:0x75
		if(__NFUN_114__(LooksAndFeels[i], none))
		{
			LooksAndFeels[i] = new LFClass;
			LooksAndFeels[i].Setup();
			return LooksAndFeels[i];
		}
		// End:0x9F
		if(__NFUN_114__(LooksAndFeels[i].Class, LFClass))
		{
			return LooksAndFeels[i];
		}
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x22;
	}
	__NFUN_231__("Out of LookAndFeel array space!!");
	return none;
	return;
}

function Created()
{
	m_eRootId = 0;
	LookAndFeel = GetLookAndFeel(LookAndFeelClass);
	SetupFonts();
	NormalCursor.Tex = Texture'R6MenuTextures.MouseCursor';
	NormalCursor.HotX = 0;
	NormalCursor.HotY = 0;
	NormalCursor.WindowsCursor = Console.ViewportOwner.0;
	MoveCursor.Tex = Texture'UWindow.Icons.MouseMove';
	MoveCursor.HotX = 8;
	MoveCursor.HotY = 8;
	MoveCursor.WindowsCursor = Console.ViewportOwner.1;
	DiagCursor1.Tex = Texture'UWindow.Icons.MouseDiag1';
	DiagCursor1.HotX = 8;
	DiagCursor1.HotY = 8;
	DiagCursor1.WindowsCursor = Console.ViewportOwner.4;
	HandCursor.Tex = Texture'UWindow.Icons.MouseHand';
	HandCursor.HotX = 11;
	HandCursor.HotY = 1;
	HandCursor.WindowsCursor = Console.ViewportOwner.0;
	HSplitCursor.Tex = Texture'UWindow.Icons.MouseHSplit';
	HSplitCursor.HotX = 9;
	HSplitCursor.HotY = 9;
	HSplitCursor.WindowsCursor = Console.ViewportOwner.5;
	VSplitCursor.Tex = Texture'UWindow.Icons.MouseVSplit';
	VSplitCursor.HotX = 9;
	VSplitCursor.HotY = 9;
	VSplitCursor.WindowsCursor = Console.ViewportOwner.3;
	DiagCursor2.Tex = Texture'UWindow.Icons.MouseDiag2';
	DiagCursor2.HotX = 7;
	DiagCursor2.HotY = 7;
	DiagCursor2.WindowsCursor = Console.ViewportOwner.2;
	NSCursor.Tex = Texture'UWindow.Icons.MouseNS';
	NSCursor.HotX = 3;
	NSCursor.HotY = 7;
	NSCursor.WindowsCursor = Console.ViewportOwner.3;
	WECursor.Tex = Texture'UWindow.Icons.MouseWE';
	WECursor.HotX = 7;
	WECursor.HotY = 3;
	WECursor.WindowsCursor = Console.ViewportOwner.5;
	WaitCursor.Tex = Texture'R6MenuTextures.MouseWait';
	WECursor.HotX = 6;
	WECursor.HotY = 9;
	WECursor.WindowsCursor = Console.ViewportOwner.6;
	AimCursor.Tex = Texture'R6Planning.Cursors.PlanCursor_Aim';
	AimCursor.HotX = 16;
	AimCursor.HotY = 16;
	DragCursor.Tex = Texture'R6Planning.Cursors.PlanCursor_Drag';
	DragCursor.HotX = 5;
	DragCursor.HotY = 5;
	Colors = new (none) Class'Engine.R6GameColors';
	MenuClassDefines = new (none) Class'UWindow.UWindowMenuClassDefines';
	MenuClassDefines.Created();
	HotkeyWindows = new Class'UWindow.UWindowHotkeyWindowList';
	HotkeyWindows.Last = HotkeyWindows;
	HotkeyWindows.Next = none;
	HotkeyWindows.Sentinel = HotkeyWindows;
	Cursor = NormalCursor;
	return;
}

function MoveMouse(float X, float Y)
{
	local UWindowWindow NewMouseWindow;
	local float tX, tY;

	MouseX = X;
	MouseY = Y;
	// End:0x3A
	if(__NFUN_129__(bMouseCapture))
	{
		NewMouseWindow = FindWindowUnder(X, Y);		
	}
	else
	{
		NewMouseWindow = MouseWindow;
	}
	// End:0x7D
	if(__NFUN_119__(NewMouseWindow, MouseWindow))
	{
		MouseWindow.MouseLeave();
		NewMouseWindow.MouseEnter();
		MouseWindow = NewMouseWindow;
	}
	// End:0xE5
	if(__NFUN_132__(__NFUN_181__(MouseX, OldMouseX), __NFUN_181__(MouseY, OldMouseY)))
	{
		OldMouseX = MouseX;
		OldMouseY = MouseY;
		MouseWindow.GetMouseXY(tX, tY);
		MouseWindow.MouseMove(tX, tY);
	}
	return;
}

function DrawMouse(Canvas C)
{
	local float X, Y;

	// End:0x49
	if(Console.ViewportOwner.bWindowsMouseAvailable)
	{
		Console.ViewportOwner.SelectedCursor = MouseWindow.Cursor.WindowsCursor;		
	}
	else
	{
		C.__NFUN_2626__(byte(255), byte(255), byte(255));
		C.__NFUN_2623__(__NFUN_175__(__NFUN_171__(MouseX, GUIScale), float(MouseWindow.Cursor.HotX)), __NFUN_175__(__NFUN_171__(MouseY, GUIScale), float(MouseWindow.Cursor.HotY)));
		C.DrawIcon(MouseWindow.Cursor.Tex, 1.0000000);
	}
	return;
}

function bool CheckCaptureMouseUp()
{
	local float X, Y;

	// End:0x45
	if(bMouseCapture)
	{
		MouseWindow.GetMouseXY(X, Y);
		MouseWindow.LMouseUp(X, Y);
		bMouseCapture = false;
		return true;
	}
	return false;
	return;
}

function bool CheckCaptureMouseDown()
{
	local float X, Y;

	// End:0x45
	if(bMouseCapture)
	{
		MouseWindow.GetMouseXY(X, Y);
		MouseWindow.LMouseDown(X, Y);
		bMouseCapture = false;
		return true;
	}
	return false;
	return;
}

function CancelCapture()
{
	bMouseCapture = false;
	return;
}

function CaptureMouse(optional UWindowWindow W)
{
	bMouseCapture = true;
	// End:0x1E
	if(__NFUN_119__(W, none))
	{
		MouseWindow = W;
	}
	return;
}

function Texture GetLookAndFeelTexture()
{
	return LookAndFeel.Active;
	return;
}

function bool IsActive()
{
	return true;
	return;
}

function AddHotkeyWindow(UWindowWindow W)
{
	UWindowHotkeyWindowList(HotkeyWindows.Insert(Class'UWindow.UWindowHotkeyWindowList')).Window = W;
	return;
}

function RemoveHotkeyWindow(UWindowWindow W)
{
	local UWindowHotkeyWindowList L;

	L = HotkeyWindows.FindWindow(W);
	// End:0x34
	if(__NFUN_119__(L, none))
	{
		L.Remove();
	}
	return;
}

function bool IsAHotKeyWindow(UWindowWindow W)
{
	local UWindowHotkeyWindowList L;

	L = HotkeyWindows.FindWindow(W);
	// End:0x27
	if(__NFUN_119__(L, none))
	{
		return true;
	}
	return false;
	return;
}

function WindowEvent(UWindowWindow.WinMessage Msg, Canvas C, float X, float Y, int Key)
{
	switch(Msg)
	{
		// End:0x29
		case 9:
			// End:0x26
			if(HotKeyDown(Key, X, Y))
			{
				return;
			}
			// End:0x7A
			break;
		// End:0x4B
		case 8:
			// End:0x48
			if(HotKeyUp(Key, X, Y))
			{
				return;
			}
			// End:0x7A
			break;
		// End:0x50
		case 0:
		// End:0x55
		case 2:
		// End:0x77
		case 4:
			// End:0x74
			if(MouseUpDown(Key, X, Y))
			{
				return;
			}
			// End:0x7A
			break;
		// End:0xFFFF
		default:
			break;
	}
	super.WindowEvent(Msg, C, X, Y, Key);
	return;
}

function bool HotKeyDown(int Key, float X, float Y)
{
	local UWindowHotkeyWindowList L;

	L = UWindowHotkeyWindowList(HotkeyWindows.Next);
	J0x19:

	// End:0x82 [Loop If]
	if(__NFUN_119__(L, none))
	{
		// End:0x66
		if(__NFUN_130__(__NFUN_119__(L.Window, self), L.Window.HotKeyDown(Key, X, Y)))
		{
			return true;
		}
		L = UWindowHotkeyWindowList(L.Next);
		// [Loop Continue]
		goto J0x19;
	}
	return false;
	return;
}

function bool HotKeyUp(int Key, float X, float Y)
{
	local UWindowHotkeyWindowList L;

	L = UWindowHotkeyWindowList(HotkeyWindows.Next);
	J0x19:

	// End:0x82 [Loop If]
	if(__NFUN_119__(L, none))
	{
		// End:0x66
		if(__NFUN_130__(__NFUN_119__(L.Window, self), L.Window.HotKeyUp(Key, X, Y)))
		{
			return true;
		}
		L = UWindowHotkeyWindowList(L.Next);
		// [Loop Continue]
		goto J0x19;
	}
	return false;
	return;
}

function bool MouseUpDown(int Key, float X, float Y)
{
	local UWindowHotkeyWindowList L;

	L = UWindowHotkeyWindowList(HotkeyWindows.Next);
	J0x19:

	// End:0x82 [Loop If]
	if(__NFUN_119__(L, none))
	{
		// End:0x66
		if(__NFUN_130__(__NFUN_119__(L.Window, self), L.Window.MouseUpDown(Key, X, Y)))
		{
			return true;
		}
		L = UWindowHotkeyWindowList(L.Next);
		// [Loop Continue]
		goto J0x19;
	}
	return false;
	return;
}

function CloseActiveWindow()
{
	// End:0x1D
	if(__NFUN_119__(ActiveWindow, none))
	{
		ActiveWindow.EscClose();		
	}
	else
	{
		Console.CloseUWindow();
	}
	return;
}

function Resized()
{
	ResolutionChanged(WinWidth, WinHeight);
	return;
}

function SetScale(float NewScale)
{
	WinWidth = __NFUN_172__(RealWidth, NewScale);
	WinHeight = __NFUN_172__(RealHeight, NewScale);
	GUIScale = NewScale;
	ClippingRegion.X = 0;
	ClippingRegion.Y = 0;
	ClippingRegion.W = int(WinWidth);
	ClippingRegion.H = int(WinHeight);
	SetupFonts();
	Resized();
	return;
}

function SetResolution(float _NewWidth, float _NewHeight)
{
	WinWidth = _NewWidth;
	WinHeight = _NewHeight;
	ClippingRegion.X = 0;
	ClippingRegion.Y = 0;
	ClippingRegion.W = int(WinWidth);
	ClippingRegion.H = int(WinHeight);
	Resized();
	return;
}

function SetupFonts()
{
	Fonts[4] = Font'R6Font.Rainbow6_36pt';
	Fonts[5] = Font'R6Font.Rainbow6_14pt';
	Fonts[6] = Font'R6Font.Rainbow6_12pt';
	Fonts[7] = Font'R6Font.Rainbow6_15pt';
	Fonts[8] = Font'R6Font.Rainbow6_15pt';
	Fonts[9] = Font'R6Font.OcraExt_14pt';
	Fonts[10] = Font'R6Font.Arial_10pt';
	Fonts[11] = Font'R6Font.Rainbow6_14pt';
	Fonts[12] = Font'R6Font.Rainbow6_12pt';
	Fonts[14] = Font'R6Font.Rainbow6_36pt';
	Fonts[15] = Font'R6Font.Rainbow6_17pt';
	Fonts[16] = Font'R6Font.Rainbow6_17pt';
	Fonts[17] = Font'R6Font.Rainbow6_12pt';
	Fonts[0] = Font'R6Font.Rainbow6_12pt';
	return;
}

function ChangeLookAndFeel(string NewLookAndFeel)
{
	LookAndFeelClass = NewLookAndFeel;
	__NFUN_536__();
	Console.ResetUWindow();
	return;
}

function HideWindow()
{
	return;
}

function SetMousePos(float X, float Y)
{
	Console.MouseX = X;
	Console.MouseY = Y;
	return;
}

function QuitGame()
{
	bRequestQuit = true;
	QuitTime = 0.0000000;
	NotifyQuitUnreal();
	return;
}

function DoQuitGame()
{
	__NFUN_536__();
	Console.ViewportOwner.Actor.ConsoleCommand("exit");
	return;
}

function Tick(float Delta)
{
	// End:0x2A
	if(bRequestQuit)
	{
		// End:0x1E
		if(__NFUN_177__(QuitTime, 0.2500000))
		{
			DoQuitGame();
		}
		__NFUN_184__(QuitTime, Delta);
	}
	super.Tick(Delta);
	return;
}

//ifdef R6CODE
// MPF Yannick
function SetNewMODS(string _szNewBkgFolder, optional bool _bForceRefresh)
{
	return;
}

function SetLoadRandomBackgroundImage(string _szFolder)
{
	return;
}

function PaintBackground(Canvas C, UWindowWindow _WidgetWindow)
{
	return;
}

//===================================================================
// DrawBackGroundEffect: draw a background fullscreen -- need for pop-up 
//===================================================================
function DrawBackGroundEffect(Canvas C, Color _BGColor)
{
	local float OrgX, OrgY, ClipX, ClipY;

	OrgX = C.OrgX;
	OrgY = C.OrgY;
	ClipX = C.ClipX;
	ClipY = C.ClipY;
	C.__NFUN_2624__(0.0000000, 0.0000000);
	C.__NFUN_2625__(float(C.SizeX), float(C.SizeY));
	C.__NFUN_2626__(_BGColor.R, _BGColor.G, _BGColor.B, _BGColor.A);
	C.__NFUN_2623__(0.0000000, 0.0000000);
	C.__NFUN_466__(Texture'UWindow.WhiteTexture', float(C.SizeX), float(C.SizeY), 0.0000000, 0.0000000, 10.0000000, 10.0000000);
	C.__NFUN_2625__(ClipX, ClipY);
	C.__NFUN_2624__(OrgX, OrgY);
	return;
}

//===================================================================
// TrapKey: Menu trap the key
//===================================================================
function bool TrapKey(bool _bIncludeMouseMove)
{
	return true;
	return;
}

// NEW IN 1.60
function RegisterMsgWindow(UWindowWindow _NotifyMsgWindow)
{
	m_NotifyMsgWindow = _NotifyMsgWindow;
	return;
}

// NEW IN 1.60
function UnRegisterMsgWindow()
{
	m_NotifyMsgWindow = none;
	return;
}

// NEW IN 1.60
function ProcessGSMsg(string _szMsg)
{
	// End:0x1F
	if(__NFUN_119__(m_NotifyMsgWindow, none))
	{
		m_NotifyMsgWindow.ProcessGSMsg(_szMsg);
	}
	return;
}

defaultproperties
{
	bAllowConsole=true
	GUIScale=1.0000000
	m_fWindowScaleX=1.0000000
	m_fWindowScaleY=1.0000000
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var Y
// REMOVED IN 1.60: var r
// REMOVED IN 1.60: var t
// REMOVED IN 1.60: var eRootID
// REMOVED IN 1.60: function SaveTrainingPlanning
// REMOVED IN 1.60: function GetSimplePopUpID
// REMOVED IN 1.60: function GetGameWidgetID
