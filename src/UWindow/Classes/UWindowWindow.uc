//=============================================================================
// UWindowWindow - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
// UWindowWindow - the parent class for all Window objects
//=============================================================================
class UWindowWindow extends UWindowBase;

const DE_Created = 0;
const DE_Change = 1;
const DE_Click = 2;
const DE_Enter = 3;
const DE_Exit = 4;
const DE_MClick = 5;
const DE_RClick = 6;
const DE_EnterPressed = 7;
const DE_MouseMove = 8;
const DE_MouseLeave = 9;
const DE_LMouseDown = 10;
const DE_DoubleClick = 11;
const DE_MouseEnter = 12;
const DE_HelpChanged = 13;
const DE_WheelUpPressed = 14;
const DE_WheelDownPressed = 15;

enum WinMessage
{
	WM_LMouseDown,                  // 0
	WM_LMouseUp,                    // 1
	WM_MMouseDown,                  // 2
	WM_MMouseUp,                    // 3
	WM_RMouseDown,                  // 4
	WM_RMouseUp,                    // 5
	WM_MouseWheelDown,              // 6
	WM_MouseWheelUp,                // 7
	WM_KeyUp,                       // 8
	WM_KeyDown,                     // 9
	WM_KeyType,                     // 10
	WM_Paint                        // 11
};

enum eR6MenuWidgetMessage
{
	MWM_UBI_LOGIN_SUCCESS,          // 0
	MWM_UBI_LOGIN_FAIL,             // 1
	MWM_UBI_LOGIN_SKIPPED,          // 2
	MWM_CDKEYVAL_SKIPPED,           // 3
	MWM_CDKEYVAL_SUCCESS,           // 4
	MWM_CDKEYVAL_FAIL,              // 5
	MWM_UBI_JOINIP_SUCCESS,         // 6
	MWM_UBI_JOINIP_FAIL,            // 7
	MWM_QUERYSERVER_SUCCESS,        // 8
	MWM_QUERYSERVER_FAIL,           // 9
	MWM_QUERYSERVER_TRYAGAIN        // 10
};

struct MouseCursor
{
	var Texture Tex;
	var int HotX;
	var int HotY;
	var byte WindowsCursor;
};

var int m_BorderStyle;  // Will be cast in ErenderStyle
var bool bWindowVisible;
var bool bNoClip;  // Clipping disabled for this window?
var bool bMouseDown;  // Pressed down in this window?
var bool bRMouseDown;  // Pressed down in this window?
var bool bMMouseDown;  // Pressed down in this window?
var bool bAlwaysBehind;  // Window doesn't bring to front on click.
var bool bAcceptsFocus;  // Accepts key messages
var bool bAlwaysAcceptsFocus;  // Accepts key messages all the time
var bool bAlwaysOnTop;  // Always on top
var bool bLeaveOnscreen;  // Window is left onscreen when UWindow isn't active.
var bool bUWindowActive;  // Is UWindow active?
var bool bTransient;  // Never the active window. Used for combo dropdowns7
var bool bAcceptsHotKeys;  // Does this window accept hotkeys?
var bool bIgnoreLDoubleClick;
var bool bIgnoreMDoubleClick;
var bool bIgnoreRDoubleClick;
var bool m_bNotDisplayBkg;  // Not display the back ground (to avoid heritance of paint(){})
var bool m_bPreCalculatePos;
// Dimensions, offset relative to parent.
var float WinLeft;
var float WinTop;
var float WinWidth;
var float WinHeight;
var float OrgXOffset;
var float OrgYOffset;
var float ClickTime;
var float MClickTime;
var float RClickTime;
var float ClickX;
var float ClickY;
var float MClickX;
var float MClickY;
var float RClickX;
var float RClickY;
// Relationships to other windows
var UWindowWindow ParentWindow;  // Parent window
var UWindowWindow FirstChildWindow;  // First child window - bottom window first
var UWindowWindow LastChildWindow;  // Last child window - WinTop window first
var UWindowWindow NextSiblingWindow;  // sibling window - next window above us
var UWindowWindow PrevSiblingWindow;  // previous sibling window - next window below us
var UWindowWindow ActiveWindow;  // The child of ours which is currently active
var UWindowRootWindow Root;  // The root window
var UWindowWindow OwnerWindow;  // Some arbitary owner window
var UWindowWindow ModalWindow;  // Some window we've opened modally.
var UWindowLookAndFeel LookAndFeel;
var Texture m_BorderTexture;
var Region ClippingRegion;
var Region m_BorderTextureRegion;
var Color m_BorderColor;
var MouseCursor Cursor;
var string ToolTipString;  // Allows any window to have a tooltip

// Ideally Key would be a EInputKey but I can't see that class here.
function WindowEvent(UWindowWindow.WinMessage Msg, Canvas C, float X, float Y, int Key)
{
	switch(Msg)
	{
		// End:0x39
		case 11:
			Paint(C, X, Y);
			PaintClients(C, X, Y);
			// End:0x30A
			break;
		// End:0x89
		case 0:
			// End:0x86
			if((!Root.CheckCaptureMouseDown()))
			{
				// End:0x86
				if((!MessageClients(Msg, C, X, Y, Key)))
				{
					LMouseDown(X, Y);
				}
			}
			// End:0x30A
			break;
		// End:0xD9
		case 1:
			// End:0xD6
			if((!Root.CheckCaptureMouseUp()))
			{
				// End:0xD6
				if((!MessageClients(Msg, C, X, Y, Key)))
				{
					LMouseUp(X, Y);
				}
			}
			// End:0x30A
			break;
		// End:0x115
		case 4:
			// End:0x112
			if((!MessageClients(Msg, C, X, Y, Key)))
			{
				RMouseDown(X, Y);
			}
			// End:0x30A
			break;
		// End:0x151
		case 5:
			// End:0x14E
			if((!MessageClients(Msg, C, X, Y, Key)))
			{
				RMouseUp(X, Y);
			}
			// End:0x30A
			break;
		// End:0x18D
		case 2:
			// End:0x18A
			if((!MessageClients(Msg, C, X, Y, Key)))
			{
				MMouseDown(X, Y);
			}
			// End:0x30A
			break;
		// End:0x1C9
		case 3:
			// End:0x1C6
			if((!MessageClients(Msg, C, X, Y, Key)))
			{
				MMouseUp(X, Y);
			}
			// End:0x30A
			break;
		// End:0x205
		case 6:
			// End:0x202
			if((!MessageClients(Msg, C, X, Y, Key)))
			{
				MouseWheelDown(X, Y);
			}
			// End:0x30A
			break;
		// End:0x241
		case 7:
			// End:0x23E
			if((!MessageClients(Msg, C, X, Y, Key)))
			{
				MouseWheelUp(X, Y);
			}
			// End:0x30A
			break;
		// End:0x282
		case 9:
			// End:0x27F
			if((!PropagateKey(Msg, C, X, Y, Key)))
			{
				KeyDown(Key, X, Y);
			}
			// End:0x30A
			break;
		// End:0x2C3
		case 8:
			// End:0x2C0
			if((!PropagateKey(Msg, C, X, Y, Key)))
			{
				KeyUp(Key, X, Y);
			}
			// End:0x30A
			break;
		// End:0x304
		case 10:
			// End:0x301
			if((!PropagateKey(Msg, C, X, Y, Key)))
			{
				KeyType(Key, X, Y);
			}
			// End:0x30A
			break;
		// End:0xFFFF
		default:
			// End:0x30A
			break;
			break;
	}
	return;
}

function SaveConfigs()
{
	return;
}

final function PlayerController GetPlayerOwner()
{
	return Root.Console.ViewportOwner.Actor;
	return;
}

final function LevelInfo GetLevel()
{
	return Root.Console.ViewportOwner.Actor.Level;
	return;
}

final function float GetTime()
{
	return Class'Engine.Actor'.static.GetTime();
	return;
}

final function LevelInfo GetEntryLevel()
{
	return Root.Console.ViewportOwner.Actor.super(UWindowWindow).GetEntryLevel();
	return;
}

final function UWindowWindow GetButtonsDefinesUnique(Class<UWindowWindow> WndClass)
{
	local UWindowWindow Child;

	Child = Root.FindChildWindow(WndClass, true);
	// End:0x56
	if((Child == none))
	{
		Child = Root.CreateWindow(WndClass, 0.0000000, 0.0000000, 0.0000000, 0.0000000, none, true);
	}
	return Child;
	return;
}

function Resized()
{
	return;
}

function BeforePaint(Canvas C, float X, float Y)
{
	return;
}

function AfterPaint(Canvas C, float X, float Y)
{
	return;
}

function Paint(Canvas C, float X, float Y)
{
	return;
}

function Click(float X, float Y)
{
	return;
}

function MClick(float X, float Y)
{
	return;
}

function RClick(float X, float Y)
{
	return;
}

function DoubleClick(float X, float Y)
{
	return;
}

function MDoubleClick(float X, float Y)
{
	return;
}

function RDoubleClick(float X, float Y)
{
	return;
}

function BeginPlay()
{
	return;
}

function Created()
{
	return;
}

function MouseEnter()
{
	// End:0x17
	if((ToolTipString != ""))
	{
		ToolTip(ToolTipString);
	}
	return;
}

function Activated()
{
	return;
}

function Deactivated()
{
	return;
}

function MouseLeave()
{
	bMouseDown = false;
	bMMouseDown = false;
	bRMouseDown = false;
	// End:0x2C
	if((ToolTipString != ""))
	{
		ToolTip("");
	}
	return;
}

function MouseMove(float X, float Y)
{
	return;
}

function KeyUp(int Key, float X, float Y)
{
	return;
}

function KeyDown(int Key, float X, float Y)
{
	return;
}

//return true to break the chaining of input
//a window should return true when it uses the incomming input
function bool HotKeyDown(int Key, float X, float Y)
{
	return false;
	return;
}

function bool HotKeyUp(int Key, float X, float Y)
{
	return false;
	return;
}

function bool MouseUpDown(int Key, float X, float Y)
{
	return false;
	return;
}

function KeyType(int Key, float X, float Y)
{
	return;
}

function ProcessMenuKey(int Key, string KeyName)
{
	return;
}

function KeyFocusEnter()
{
	return;
}

function KeyFocusExit()
{
	return;
}

function RMouseDown(float X, float Y)
{
	ActivateWindow(0, false);
	bRMouseDown = true;
	return;
}

function RMouseUp(float X, float Y)
{
	// End:0xAD
	if(bRMouseDown)
	{
		// End:0x7B
		if(((((!bIgnoreRDoubleClick) && (Abs((X - RClickX)) <= float(1))) && (Abs((Y - RClickY)) <= float(1))) && (GetTime() < (RClickTime + 0.4000000))))
		{
			RDoubleClick(X, Y);
			RClickTime = 0.0000000;			
		}
		else
		{
			RClickTime = GetTime();
			RClickX = X;
			RClickY = Y;
			RClick(X, Y);
		}
	}
	bRMouseDown = false;
	return;
}

function MMouseDown(float X, float Y)
{
	ActivateWindow(0, false);
	bMMouseDown = true;
	return;
}

function MMouseUp(float X, float Y)
{
	// End:0xAB
	if(bMMouseDown)
	{
		// End:0x79
		if(((((!bIgnoreMDoubleClick) && (Abs((X - MClickX)) <= float(1))) && ((Y - MClickY) <= float(1))) && (GetTime() < (MClickTime + 0.4000000))))
		{
			MDoubleClick(X, Y);
			MClickTime = 0.0000000;			
		}
		else
		{
			MClickTime = GetTime();
			MClickX = X;
			MClickY = Y;
			MClick(X, Y);
		}
	}
	bMMouseDown = false;
	return;
}

function MouseWheelDown(float X, float Y)
{
	return;
}

function MouseWheelUp(float X, float Y)
{
	return;
}

function LMouseDown(float X, float Y)
{
	ActivateWindow(0, false);
	bMouseDown = true;
	return;
}

function LMouseUp(float X, float Y)
{
	// End:0xAB
	if(bMouseDown)
	{
		// End:0x79
		if(((((!bIgnoreLDoubleClick) && (Abs((X - ClickX)) <= float(1))) && ((Y - ClickY) <= float(1))) && (GetTime() < (ClickTime + 0.4000000))))
		{
			DoubleClick(X, Y);
			ClickTime = 0.0000000;			
		}
		else
		{
			ClickTime = GetTime();
			ClickX = X;
			ClickY = Y;
			Click(X, Y);
		}
	}
	bMouseDown = false;
	return;
}

function FocusWindow()
{
	// End:0x43
	if(((Root.FocusedWindow != none) && (Root.FocusedWindow != self)))
	{
		Root.FocusedWindow.FocusOtherWindow(self);
	}
	Root.FocusedWindow = self;
	return;
}

function FocusOtherWindow(UWindowWindow W)
{
	return;
}

function EscClose()
{
	Close();
	return;
}

function Close(optional bool bByParent)
{
	local UWindowWindow Prev, Child;

	Child = LastChildWindow;
	J0x0B:

	// End:0x48 [Loop If]
	if((Child != none))
	{
		Prev = Child.PrevSiblingWindow;
		Child.Close(true);
		Child = Prev;
		// [Loop Continue]
		goto J0x0B;
	}
	SaveConfigs();
	// End:0x5F
	if((!bByParent))
	{
		HideWindow();
	}
	return;
}

final function SetSize(float W, float H)
{
	// End:0x3C
	if(((WinWidth != W) || (WinHeight != H)))
	{
		WinWidth = W;
		WinHeight = H;
		Resized();
	}
	return;
}

function Tick(float Delta)
{
	return;
}

final function DoTick(float Delta)
{
	local UWindowWindow Child;

	Tick(Delta);
	Child = FirstChildWindow;
	J0x16:

	// End:0x99 [Loop If]
	if((Child != none))
	{
		Child.bUWindowActive = bUWindowActive;
		// End:0x51
		if(bLeaveOnscreen)
		{
			Child.bLeaveOnscreen = true;
		}
		// End:0x82
		if((bUWindowActive || Child.bLeaveOnscreen))
		{
			Child.super(UWindowWindow).DoTick(Delta);
		}
		Child = Child.NextSiblingWindow;
		// [Loop Continue]
		goto J0x16;
	}
	return;
}

final function PaintClients(Canvas C, float X, float Y)
{
	local float OrgX, OrgY, ClipX, ClipY;
	local UWindowWindow Child;

	OrgX = C.OrgX;
	OrgY = C.OrgY;
	ClipX = C.ClipX;
	ClipY = C.ClipY;
	Child = FirstChildWindow;
	J0x5B:

	// End:0x617 [Loop If]
	if((Child != none))
	{
		Child.bUWindowActive = bUWindowActive;
		C.SetPos(0.0000000, 0.0000000);
		C.Style = GetPlayerOwner().1;
		C.SetDrawColor(byte(255), byte(255), byte(255));
		C.SpaceX = 0.0000000;
		C.SpaceY = 0.0000000;
		Child.BeforePaint(C, (X - Child.WinLeft), (Y - Child.WinTop));
		// End:0x145
		if(bLeaveOnscreen)
		{
			Child.bLeaveOnscreen = true;
		}
		// End:0x600
		if((bUWindowActive || Child.bLeaveOnscreen))
		{
			C.OrgX = (C.OrgX + (Child.WinLeft * Root.GUIScale));
			C.OrgY = (C.OrgY + (Child.WinTop * Root.GUIScale));
			// End:0x500
			if((!Child.bNoClip))
			{
				C.ClipX = (FMin((WinWidth - Child.WinLeft), Child.WinWidth) * Root.GUIScale);
				C.ClipY = (FMin((WinHeight - Child.WinTop), Child.WinHeight) * Root.GUIScale);
				C.HalfClipX = (C.ClipX * 0.5000000);
				C.HalfClipY = (C.ClipY * 0.5000000);
				Child.ClippingRegion.X = int((float(ClippingRegion.X) - Child.WinLeft));
				Child.ClippingRegion.Y = int((float(ClippingRegion.Y) - Child.WinTop));
				Child.ClippingRegion.W = ClippingRegion.W;
				Child.ClippingRegion.H = ClippingRegion.H;
				// End:0x3B6
				if((Child.ClippingRegion.X < 0))
				{
					(Child.ClippingRegion.W += Child.ClippingRegion.X);
					Child.ClippingRegion.X = 0;
				}
				// End:0x40C
				if((Child.ClippingRegion.Y < 0))
				{
					(Child.ClippingRegion.H += Child.ClippingRegion.Y);
					Child.ClippingRegion.Y = 0;
				}
				// End:0x486
				if((float(Child.ClippingRegion.W) > (Child.WinWidth - float(Child.ClippingRegion.X))))
				{
					Child.ClippingRegion.W = int((Child.WinWidth - float(Child.ClippingRegion.X)));
				}
				// End:0x500
				if((float(Child.ClippingRegion.H) > (Child.WinHeight - float(Child.ClippingRegion.Y))))
				{
					Child.ClippingRegion.H = int((Child.WinHeight - float(Child.ClippingRegion.Y)));
				}
			}
			// End:0x5D8
			if(((Child.ClippingRegion.W > 0) && (Child.ClippingRegion.H > 0)))
			{
				// End:0x5C7
				if((!Child.m_bPreCalculatePos))
				{
					Child.WindowEvent(11, C, (X - Child.WinLeft), (Y - Child.WinTop), 0);
					Child.AfterPaint(C, (X - Child.WinLeft), (Y - Child.WinTop));
				}
				Child.m_bPreCalculatePos = false;
			}
			C.OrgX = OrgX;
			C.OrgY = OrgY;
		}
		Child = Child.NextSiblingWindow;
		// [Loop Continue]
		goto J0x5B;
	}
	C.ClipX = ClipX;
	C.ClipY = ClipY;
	C.HalfClipX = (C.ClipX * 0.5000000);
	C.HalfClipY = (C.ClipY * 0.5000000);
	return;
}

final function UWindowWindow FindWindowUnder(float X, float Y)
{
	local UWindowWindow Child;

	Child = LastChildWindow;
	J0x0B:

	// End:0x17A [Loop If]
	if((Child != none))
	{
		Child.bUWindowActive = bUWindowActive;
		// End:0x46
		if(bLeaveOnscreen)
		{
			Child.bLeaveOnscreen = true;
		}
		// End:0x163
		if((bUWindowActive || Child.bLeaveOnscreen))
		{
			// End:0x163
			if((((((X >= Child.WinLeft) && (X <= (Child.WinLeft + Child.WinWidth))) && (Y >= Child.WinTop)) && (Y <= (Child.WinTop + Child.WinHeight))) && (!Child.CheckMousePassThrough((X - Child.WinLeft), (Y - Child.WinTop)))))
			{
				return Child.super(UWindowWindow).FindWindowUnder((X - Child.WinLeft), (Y - Child.WinTop));
			}
		}
		Child = Child.PrevSiblingWindow;
		// [Loop Continue]
		goto J0x0B;
	}
	return self;
	return;
}

//===============================================================================
// ApplyResolutionOnWindowsPos: Change windows position base on current root resolution
//===============================================================================
function ApplyResolutionOnWindowsPos(float X, float Y)
{
	local UWindowWindow Child;
	local float fX, fY;

	Child = LastChildWindow;
	J0x0B:

	// End:0x1A6 [Loop If]
	if((Child != none))
	{
		Child.bUWindowActive = bUWindowActive;
		// End:0x46
		if(bLeaveOnscreen)
		{
			Child.bLeaveOnscreen = true;
		}
		// End:0x5A
		if(Root.m_bScaleWindowToRoot)
		{
			return;
		}
		// End:0x18F
		if((bUWindowActive || Child.bLeaveOnscreen))
		{
			fX = ((Root.WinWidth - float(640)) * 0.5000000);
			fY = ((Root.WinHeight - float(480)) * 0.5000000);
			// End:0x127
			if((Child.OrgXOffset != fX))
			{
				(Child.WinLeft -= Child.OrgXOffset);
				Child.OrgXOffset = fX;
				(Child.WinLeft += Child.OrgXOffset);
			}
			// End:0x18F
			if((Child.OrgYOffset != fY))
			{
				(Child.WinTop -= Child.OrgYOffset);
				Child.OrgYOffset = fY;
				(Child.WinTop += Child.OrgYOffset);
			}
		}
		Child = Child.PrevSiblingWindow;
		// [Loop Continue]
		goto J0x0B;
	}
	return;
}

//final function bool PropagateKey(WinMessage Msg, Canvas C, float X, float Y, int Key)
function bool PropagateKey(UWindowWindow.WinMessage Msg, Canvas C, float X, float Y, int Key)
{
	local UWindowWindow Child;

	Child = LastChildWindow;
	// End:0x48
	if((((ActiveWindow != none) && (Child != ActiveWindow)) && (!Child.bTransient)))
	{
		Child = ActiveWindow;
	}
	J0x48:

	// End:0x115 [Loop If]
	if((Child != none))
	{
		Child.bUWindowActive = bUWindowActive;
		// End:0x83
		if(bLeaveOnscreen)
		{
			Child.bLeaveOnscreen = true;
		}
		// End:0xFE
		if(((bUWindowActive || Child.bLeaveOnscreen) && Child.bAcceptsFocus))
		{
			Child.WindowEvent(Msg, C, (X - Child.WinLeft), (Y - Child.WinTop), Key);
			return true;
		}
		Child = Child.PrevSiblingWindow;
		// [Loop Continue]
		goto J0x48;
	}
	return false;
	return;
}

final function UWindowWindow CheckKeyFocusWindow()
{
	local UWindowWindow Child;

	Child = LastChildWindow;
	// End:0x48
	if((((ActiveWindow != none) && (Child != ActiveWindow)) && (!Child.bTransient)))
	{
		Child = ActiveWindow;
	}
	J0x48:

	// End:0xD9 [Loop If]
	if((Child != none))
	{
		Child.bUWindowActive = bUWindowActive;
		// End:0x83
		if(bLeaveOnscreen)
		{
			Child.bLeaveOnscreen = true;
		}
		// End:0xC2
		if((bUWindowActive || Child.bLeaveOnscreen))
		{
			// End:0xC2
			if(Child.bAcceptsFocus)
			{
				return Child.super(UWindowWindow).CheckKeyFocusWindow();
			}
		}
		Child = Child.PrevSiblingWindow;
		// [Loop Continue]
		goto J0x48;
	}
	return self;
	return;
}

final function bool MessageClients(UWindowWindow.WinMessage Msg, Canvas C, float X, float Y, int Key)
{
	local UWindowWindow Child;

	Child = LastChildWindow;
	J0x0B:

	// End:0x18A [Loop If]
	if((Child != none))
	{
		Child.bUWindowActive = bUWindowActive;
		// End:0x46
		if(bLeaveOnscreen)
		{
			Child.bLeaveOnscreen = true;
		}
		// End:0x173
		if((bUWindowActive || Child.bLeaveOnscreen))
		{
			// End:0x173
			if((((((X >= Child.WinLeft) && (X <= (Child.WinLeft + Child.WinWidth))) && (Y >= Child.WinTop)) && (Y <= (Child.WinTop + Child.WinHeight))) && (!Child.CheckMousePassThrough((X - Child.WinLeft), (Y - Child.WinTop)))))
			{
				Child.WindowEvent(Msg, C, (X - Child.WinLeft), (Y - Child.WinTop), Key);
				return true;
			}
		}
		Child = Child.PrevSiblingWindow;
		// [Loop Continue]
		goto J0x0B;
	}
	return false;
	return;
}

//This will turn a window Active, it uses recursion through the genealogy
//tree of a window to activate all parents, but set the focus only on the
//topmost window
final function ActivateWindow(int Depth, bool bTransientNoDeactivate)
{
	// End:0x1E
	if((self == Root))
	{
		// End:0x1C
		if((Depth == 0))
		{
			FocusWindow();
		}
		return;
	}
	// End:0x29
	if(WaitModal())
	{
		return;
	}
	// End:0x54
	if((!bAlwaysBehind))
	{
		ParentWindow.HideChildWindow(self);
		ParentWindow.ShowChildWindow(self);
	}
	// End:0xDD
	if((!(bTransient || bTransientNoDeactivate)))
	{
		// End:0xAC
		if(((ParentWindow.ActiveWindow != none) && (ParentWindow.ActiveWindow != self)))
		{
			ParentWindow.ActiveWindow.Deactivated();
		}
		ParentWindow.ActiveWindow = self;
		ParentWindow.super(UWindowWindow).ActivateWindow((Depth + 1), false);
		Activated();		
	}
	else
	{
		ParentWindow.super(UWindowWindow).ActivateWindow((Depth + 1), true);
	}
	// End:0x106
	if((Depth == 0))
	{
		FocusWindow();
	}
	return;
}

//Bring a window to top
final function BringToFront()
{
	// End:0x0D
	if((self == Root))
	{
		return;
	}
	// End:0x45
	if(((!bAlwaysBehind) && (!WaitModal())))
	{
		ParentWindow.HideChildWindow(self);
		ParentWindow.ShowChildWindow(self);
	}
	ParentWindow.super(UWindowWindow).BringToFront();
	return;
}

//Sets a window yo back so it doesn't have focus
final function SendToBack()
{
	ParentWindow.HideChildWindow(self);
	ParentWindow.ShowChildWindow(self, true);
	return;
}

final function HideChildWindow(UWindowWindow Child)
{
	local UWindowWindow Window;

	// End:0x16
	if((!Child.bWindowVisible))
	{
		return;
	}
	Child.bWindowVisible = false;
	// End:0x4D
	if(Child.bAcceptsHotKeys)
	{
		Root.RemoveHotkeyWindow(Child);
	}
	// End:0x98
	if((LastChildWindow == Child))
	{
		LastChildWindow = Child.PrevSiblingWindow;
		// End:0x8E
		if((LastChildWindow != none))
		{
			LastChildWindow.NextSiblingWindow = none;			
		}
		else
		{
			FirstChildWindow = none;
		}		
	}
	else
	{
		// End:0xE3
		if((FirstChildWindow == Child))
		{
			FirstChildWindow = Child.NextSiblingWindow;
			// End:0xD9
			if((FirstChildWindow != none))
			{
				FirstChildWindow.PrevSiblingWindow = none;				
			}
			else
			{
				LastChildWindow = none;
			}			
		}
		else
		{
			Window = FirstChildWindow;
			J0xEE:

			// End:0x165 [Loop If]
			if((Window != none))
			{
				// End:0x14E
				if((Window.NextSiblingWindow == Child))
				{
					Window.NextSiblingWindow = Child.NextSiblingWindow;
					Window.NextSiblingWindow.PrevSiblingWindow = Window;
					// [Explicit Break]
					goto J0x165;
				}
				Window = Window.NextSiblingWindow;
				// [Loop Continue]
				goto J0xEE;
			}
		}
	}
	J0x165:

	ActiveWindow = none;
	Window = LastChildWindow;
	J0x177:

	// End:0x1BB [Loop If]
	if((Window != none))
	{
		// End:0x1A4
		if((!Window.bAlwaysOnTop))
		{
			ActiveWindow = Window;
			// [Explicit Break]
			goto J0x1BB;
		}
		Window = Window.PrevSiblingWindow;
		// [Loop Continue]
		goto J0x177;
	}
	J0x1BB:

	// End:0x1D1
	if((ActiveWindow == none))
	{
		ActiveWindow = LastChildWindow;
	}
	return;
}

//Allow a window to have focus
final function SetAcceptsFocus()
{
	// End:0x09
	if(bAcceptsFocus)
	{
	}
	bAcceptsFocus = true;
	// End:0x2B
	if((self != Root))
	{
		ParentWindow.super(UWindowWindow).SetAcceptsFocus();
	}
	return;
}

final function CancelAcceptsFocus()
{
	// End:0x18
	if(((!bAcceptsFocus) || bAlwaysAcceptsFocus))
	{
		return;
	}
	bAcceptsFocus = false;
	// End:0x3A
	if((self != Root))
	{
		ParentWindow.super(UWindowWindow).CancelAcceptsFocus();
	}
	return;
}

final function GetMouseXY(out float X, out float Y)
{
	local UWindowWindow P;

	X = float(int((Root.MouseX * Root.m_fWindowScaleX)));
	Y = float(int((Root.MouseY * Root.m_fWindowScaleY)));
	P = self;
	J0x57:

	// End:0xB3 [Loop If]
	if((P != Root))
	{
		X = (X - P.WinLeft);
		Y = (Y - P.WinTop);
		P = P.ParentWindow;
		// [Loop Continue]
		goto J0x57;
	}
	return;
}

//Conversion of coordinates since a window coordinadinate is always relative to it's parent
final function GlobalToWindow(float GlobalX, float GlobalY, out float WinX, out float WinY)
{
	local UWindowWindow P;

	WinX = GlobalX;
	WinY = GlobalY;
	P = self;
	J0x1D:

	// End:0x6D [Loop If]
	if((P != Root))
	{
		(WinX -= P.WinLeft);
		(WinY -= P.WinTop);
		P = P.ParentWindow;
		// [Loop Continue]
		goto J0x1D;
	}
	return;
}

final function WindowToGlobal(float WinX, float WinY, out float GlobalX, out float GlobalY)
{
	local UWindowWindow P;

	GlobalX = WinX;
	GlobalY = WinY;
	P = self;
	J0x1D:

	// End:0x6D [Loop If]
	if((P != Root))
	{
		(GlobalX += P.WinLeft);
		(GlobalY += P.WinTop);
		P = P.ParentWindow;
		// [Loop Continue]
		goto J0x1D;
	}
	return;
}

final function ShowChildWindow(UWindowWindow Child, optional bool bAtBack)
{
	local UWindowWindow W;

	// End:0x1F
	if((!Child.bTransient))
	{
		ActiveWindow = Child;
	}
	// End:0x33
	if(Child.bWindowVisible)
	{
		return;
	}
	Child.bWindowVisible = true;
	// End:0x6A
	if(Child.bAcceptsHotKeys)
	{
		Root.AddHotkeyWindow(Child);
	}
	// End:0xFD
	if(bAtBack)
	{
		// End:0xB7
		if((FirstChildWindow == none))
		{
			Child.NextSiblingWindow = none;
			Child.PrevSiblingWindow = none;
			LastChildWindow = Child;
			FirstChildWindow = Child;			
		}
		else
		{
			FirstChildWindow.PrevSiblingWindow = Child;
			Child.NextSiblingWindow = FirstChildWindow;
			Child.PrevSiblingWindow = none;
			FirstChildWindow = Child;
		}		
	}
	else
	{
		W = LastChildWindow;
		J0x108:

		// End:0x274 [Loop If]
		if(true)
		{
			// End:0x25D
			if(((Child.bAlwaysOnTop || (W == none)) || (!W.bAlwaysOnTop)))
			{
				// End:0x1D6
				if((W == none))
				{
					// End:0x190
					if((LastChildWindow == none))
					{
						Child.NextSiblingWindow = none;
						Child.PrevSiblingWindow = none;
						LastChildWindow = Child;
						FirstChildWindow = Child;						
					}
					else
					{
						Child.NextSiblingWindow = FirstChildWindow;
						Child.PrevSiblingWindow = none;
						FirstChildWindow.PrevSiblingWindow = Child;
						FirstChildWindow = Child;
					}					
				}
				else
				{
					Child.NextSiblingWindow = W.NextSiblingWindow;
					Child.PrevSiblingWindow = W;
					// End:0x23B
					if((W.NextSiblingWindow != none))
					{
						W.NextSiblingWindow.PrevSiblingWindow = Child;						
					}
					else
					{
						LastChildWindow = Child;
					}
					W.NextSiblingWindow = Child;
				}
				// [Explicit Break]
				goto J0x274;
			}
			W = W.PrevSiblingWindow;
			// [Loop Continue]
			goto J0x108;
		}
	}
	J0x274:

	return;
}

function ShowWindow()
{
	ParentWindow.ShowChildWindow(self);
	WindowShown();
	return;
}

function HideWindow()
{
	WindowHidden();
	ParentWindow.HideChildWindow(self);
	return;
}

final function UWindowWindow CreateWindow(Class<UWindowWindow> WndClass, float X, float Y, float W, float H, optional UWindowWindow OwnerW, optional bool bUnique, optional name ObjectName)
{
	local UWindowWindow Child;

	// End:0x53
	if(bUnique)
	{
		Child = Root.FindChildWindow(WndClass, true);
		// End:0x53
		if((Child != none))
		{
			Child.ShowWindow();
			Child.BringToFront();
			return Child;
		}
	}
	// End:0x7A
	if((ObjectName != 'None'))
	{
		Child = new (none, string(ObjectName)) WndClass;		
	}
	else
	{
		Child = new (none) WndClass;
	}
	Child.BeginPlay();
	Child.WinTop = float(int(Y));
	Child.WinLeft = float(int(X));
	Child.WinWidth = float(int(W));
	Child.WinHeight = float(int(H));
	Child.Root = Root;
	Child.ParentWindow = self;
	Child.OwnerWindow = OwnerW;
	// End:0x154
	if((Child.OwnerWindow == none))
	{
		Child.OwnerWindow = self;
	}
	Child.Cursor = Cursor;
	Child.bAlwaysBehind = false;
	Child.LookAndFeel = LookAndFeel;
	Child.Created();
	ShowChildWindow(Child);
	return Child;
	return;
}

final function DrawHorizTiledPieces(Canvas C, float DestX, float DestY, float DestW, float DestH, TexRegion T1, TexRegion T2, TexRegion T3, TexRegion T4, TexRegion T5, float Scale)
{
	local TexRegion Pieces[5], R;
	local int PieceCount, j;
	local float X, L;

	Pieces[0] = T1;
	// End:0x24
	if((T1.t != none))
	{
		PieceCount = 1;
	}
	Pieces[1] = T2;
	// End:0x49
	if((T2.t != none))
	{
		PieceCount = 2;
	}
	Pieces[2] = T3;
	// End:0x6F
	if((T3.t != none))
	{
		PieceCount = 3;
	}
	Pieces[3] = T4;
	// End:0x95
	if((T4.t != none))
	{
		PieceCount = 4;
	}
	Pieces[4] = T5;
	// End:0xBB
	if((T5.t != none))
	{
		PieceCount = 5;
	}
	j = 0;
	X = DestX;
	J0xCD:

	// End:0x1D6 [Loop If]
	if((X < (DestX + DestW)))
	{
		L = (DestW - (X - DestX));
		R = Pieces[j];
		DrawStretchedTextureSegment(C, X, DestY, FMin((float(R.W) * Scale), L), (float(R.H) * Scale), float(R.X), float(R.Y), FMin(float(R.W), (L / Scale)), float(R.H), R.t);
		(X += FMin((float(R.W) * Scale), L));
		j = int((float((j + 1)) % float(PieceCount)));
		// [Loop Continue]
		goto J0xCD;
	}
	return;
}

final function DrawVertTiledPieces(Canvas C, float DestX, float DestY, float DestW, float DestH, TexRegion T1, TexRegion T2, TexRegion T3, TexRegion T4, TexRegion T5, float Scale)
{
	local TexRegion Pieces[5], R;
	local int PieceCount, j;
	local float Y, L;

	Pieces[0] = T1;
	// End:0x24
	if((T1.t != none))
	{
		PieceCount = 1;
	}
	Pieces[1] = T2;
	// End:0x49
	if((T2.t != none))
	{
		PieceCount = 2;
	}
	Pieces[2] = T3;
	// End:0x6F
	if((T3.t != none))
	{
		PieceCount = 3;
	}
	Pieces[3] = T4;
	// End:0x95
	if((T4.t != none))
	{
		PieceCount = 4;
	}
	Pieces[4] = T5;
	// End:0xBB
	if((T5.t != none))
	{
		PieceCount = 5;
	}
	j = 0;
	Y = DestY;
	J0xCD:

	// End:0x1D6 [Loop If]
	if((Y < (DestY + DestH)))
	{
		L = (DestH - (Y - DestY));
		R = Pieces[j];
		DrawStretchedTextureSegment(C, DestX, Y, (float(R.W) * Scale), FMin((float(R.H) * Scale), L), float(R.X), float(R.Y), float(R.W), FMin(float(R.H), (L / Scale)), R.t);
		(Y += FMin((float(R.H) * Scale), L));
		j = int((float((j + 1)) % float(PieceCount)));
		// [Loop Continue]
		goto J0xCD;
	}
	return;
}

final function DrawClippedTexture(Canvas C, float X, float Y, Texture Tex)
{
	DrawStretchedTextureSegment(C, X, Y, float(Tex.USize), float(Tex.VSize), 0.0000000, 0.0000000, float(Tex.USize), float(Tex.VSize), Tex);
	return;
}

final function DrawStretchedTexture(Canvas C, float X, float Y, float W, float H, Texture Tex)
{
	DrawStretchedTextureSegment(C, X, Y, W, H, 0.0000000, 0.0000000, float(Tex.USize), float(Tex.VSize), Tex);
	return;
}

final function DrawStretchedTextureSegment(Canvas C, float X, float Y, float W, float H, float tX, float tY, float tW, float tH, Texture Tex)
{
	C.DrawStretchedTextureSegmentNative(X, Y, W, H, tX, tY, tW, tH, Root.GUIScale, ClippingRegion, Tex);
	return;
}

final function DrawStretchedTextureSegmentRot(Canvas C, float X, float Y, float W, float H, float tX, float tY, float tW, float tH, Texture Tex, float fTexRotation)
{
	local float OrgX, OrgY, ClipX, ClipY;

	OrgX = C.OrgX;
	OrgY = C.OrgY;
	ClipX = C.ClipX;
	ClipY = C.ClipY;
	C.SetOrigin((OrgX + (float(ClippingRegion.X) * Root.GUIScale)), (OrgY + (float(ClippingRegion.Y) * Root.GUIScale)));
	C.SetClip((float(ClippingRegion.W) * Root.GUIScale), (float(ClippingRegion.H) * Root.GUIScale));
	C.SetPos(((X - float(ClippingRegion.X)) * Root.GUIScale), ((Y - float(ClippingRegion.Y)) * Root.GUIScale));
	C.DrawTile(Tex, (W * Root.GUIScale), (H * Root.GUIScale), tX, tY, tW, tH, fTexRotation);
	C.SetClip(ClipX, ClipY);
	C.SetOrigin(OrgX, OrgY);
	return;
}

//R6CODE
function DrawSimpleBorder(Canvas C)
{
	C.Style = byte(m_BorderStyle);
	C.SetDrawColor(m_BorderColor.R, m_BorderColor.G, m_BorderColor.B);
	DrawStretchedTextureSegment(C, 0.0000000, 0.0000000, WinWidth, float(m_BorderTextureRegion.H), float(m_BorderTextureRegion.X), float(m_BorderTextureRegion.Y), float(m_BorderTextureRegion.W), float(m_BorderTextureRegion.H), m_BorderTexture);
	DrawStretchedTextureSegment(C, 0.0000000, (WinHeight - float(m_BorderTextureRegion.H)), WinWidth, float(m_BorderTextureRegion.H), float(m_BorderTextureRegion.X), float(m_BorderTextureRegion.Y), float(m_BorderTextureRegion.W), float(m_BorderTextureRegion.H), m_BorderTexture);
	DrawStretchedTextureSegment(C, 0.0000000, float(m_BorderTextureRegion.H), float(m_BorderTextureRegion.W), (WinHeight - float((2 * m_BorderTextureRegion.H))), float(m_BorderTextureRegion.X), float(m_BorderTextureRegion.Y), float(m_BorderTextureRegion.W), float(m_BorderTextureRegion.H), m_BorderTexture);
	DrawStretchedTextureSegment(C, (WinWidth - float(m_BorderTextureRegion.W)), float(m_BorderTextureRegion.H), float(m_BorderTextureRegion.W), (WinHeight - float((2 * m_BorderTextureRegion.H))), float(m_BorderTextureRegion.X), float(m_BorderTextureRegion.Y), float(m_BorderTextureRegion.W), float(m_BorderTextureRegion.H), m_BorderTexture);
	return;
}

function DrawSimpleBackGround(Canvas C, float X, float Y, float W, float H, Color _BGColor, optional byte Alpha)
{
	local Texture BGTexture;
	local Region BGTextureRegion;
	local Color BGColor;

	BGTexture = Texture'R6MenuTextures.Gui_BoxScroll';
	BGTextureRegion.X = 77;
	BGTextureRegion.Y = 31;
	BGTextureRegion.W = 8;
	BGTextureRegion.H = 8;
	C.Style = 5;
	C.SetDrawColor(_BGColor.R, _BGColor.G, _BGColor.B, Alpha);
	DrawStretchedTextureSegment(C, X, Y, W, H, float(BGTextureRegion.X), float(BGTextureRegion.Y), float(BGTextureRegion.W), float(BGTextureRegion.H), BGTexture);
	return;
}

final function ClipText(Canvas C, float X, float Y, coerce string S, optional bool bCheckHotKey)
{
	C.ClipTextNative(X, Y, S, Root.GUIScale, ClippingRegion, bCheckHotKey);
	return;
}

final function int WrapClipText(Canvas C, float X, float Y, coerce string S, optional bool bCheckHotKey, optional int Length, optional int PaddingLength, optional bool bNoDraw)
{
	local float W, H, Xdefault;
	local int SpacePos, CRPos, WordPos, TotalPos;
	local string Out, temp, Padding;
	local bool bCR, bSentry;
	local int i, numLines;
	local float pW, pH;

	Xdefault = X;
	i = InStr(S, "\\n");
	J0x1C:

	// End:0x69 [Loop If]
	if((i != -1))
	{
		S = ((Left(S, i) $ Chr(13)) $ Mid(S, (i + 2)));
		i = InStr(S, "\\n");
		// [Loop Continue]
		goto J0x1C;
	}
	i = 0;
	bSentry = true;
	Out = "";
	numLines = 1;
	J0x87:

	// End:0x345 [Loop If]
	if((bSentry && (Y < WinHeight)))
	{
		// End:0xDF
		if((Out == ""))
		{
			(i++);
			// End:0xD4
			if((Length > 0))
			{
				Out = Left(S, Length);				
			}
			else
			{
				Out = S;
			}
		}
		SpacePos = InStr(Out, " ");
		CRPos = InStr(Out, Chr(13));
		bCR = false;
		// End:0x14F
		if(((CRPos != -1) && ((CRPos < SpacePos) || (SpacePos == -1))))
		{
			WordPos = CRPos;
			bCR = true;			
		}
		else
		{
			WordPos = SpacePos;
		}
		C.SetPos(0.0000000, 0.0000000);
		// End:0x18D
		if((WordPos == -1))
		{
			temp = Out;			
		}
		else
		{
			temp = (Left(Out, WordPos) $ " ");
		}
		(TotalPos += WordPos);
		TextSize(C, temp, W, H);
		// End:0x26C
		if(((Mid(Out, Len(temp)) == "") && (PaddingLength > 0)))
		{
			Padding = Mid(S, Length, PaddingLength);
			TextSize(C, Padding, pW, pH);
			// End:0x269
			if(((((W + X) + pW) > WinWidth) && (X > float(0))))
			{
				X = Xdefault;
				(Y += H);
				(numLines++);
			}			
		}
		else
		{
			// End:0x2AF
			if((((W + X) > WinWidth) && (X > float(0))))
			{
				X = Xdefault;
				(Y += H);
				(numLines++);
			}
		}
		// End:0x2DA
		if((!bNoDraw))
		{
			ClipText(C, X, Y, temp, bCheckHotKey);
		}
		(X += W);
		// End:0x30D
		if(bCR)
		{
			X = Xdefault;
			(Y += H);
			(numLines++);
		}
		Out = Mid(Out, Len(temp));
		// End:0x342
		if(((Out == "") && (i > 0)))
		{
			bSentry = false;
		}
		// [Loop Continue]
		goto J0x87;
	}
	return numLines;
	return;
}

final function ClipTextWidth(Canvas C, float X, float Y, coerce string S, float W)
{
	local float OrgX, OrgY, ClipX, ClipY, finalWidth;

	OrgX = C.OrgX;
	OrgY = C.OrgY;
	ClipX = C.ClipX;
	ClipY = C.ClipY;
	finalWidth = float(Min(int(W), int((WinWidth * Root.GUIScale))));
	C.SetOrigin((OrgX + (float(ClippingRegion.X) * Root.GUIScale)), (OrgY + (float(ClippingRegion.Y) * Root.GUIScale)));
	C.SetClip(finalWidth, (float(ClippingRegion.H) * Root.GUIScale));
	C.SetPos(((X - float(ClippingRegion.X)) * Root.GUIScale), ((Y - float(ClippingRegion.Y)) * Root.GUIScale));
	C.DrawTextClipped(S, false);
	C.SetClip(ClipX, ClipY);
	C.SetOrigin(OrgX, OrgY);
	return;
}

final function DrawUpBevel(Canvas C, float X, float Y, float W, float H, Texture t)
{
	local Region R;

	R = LookAndFeel.BevelUpTL;
	DrawStretchedTextureSegment(C, X, Y, float(R.W), float(R.H), float(R.X), float(R.Y), float(R.W), float(R.H), t);
	R = LookAndFeel.BevelUpT;
	DrawStretchedTextureSegment(C, (X + float(LookAndFeel.BevelUpTL.W)), Y, ((W - float(LookAndFeel.BevelUpTL.W)) - float(LookAndFeel.BevelUpTR.W)), float(R.H), float(R.X), float(R.Y), float(R.W), float(R.H), t);
	R = LookAndFeel.BevelUpTR;
	DrawStretchedTextureSegment(C, ((X + W) - float(R.W)), Y, float(R.W), float(R.H), float(R.X), float(R.Y), float(R.W), float(R.H), t);
	R = LookAndFeel.BevelUpL;
	DrawStretchedTextureSegment(C, X, (Y + float(LookAndFeel.BevelUpTL.H)), float(R.W), ((H - float(LookAndFeel.BevelUpTL.H)) - float(LookAndFeel.BevelUpBL.H)), float(R.X), float(R.Y), float(R.W), float(R.H), t);
	R = LookAndFeel.BevelUpR;
	DrawStretchedTextureSegment(C, ((X + W) - float(R.W)), (Y + float(LookAndFeel.BevelUpTL.H)), float(R.W), ((H - float(LookAndFeel.BevelUpTL.H)) - float(LookAndFeel.BevelUpBL.H)), float(R.X), float(R.Y), float(R.W), float(R.H), t);
	R = LookAndFeel.BevelUpBL;
	DrawStretchedTextureSegment(C, X, ((Y + H) - float(R.H)), float(R.W), float(R.H), float(R.X), float(R.Y), float(R.W), float(R.H), t);
	R = LookAndFeel.BevelUpB;
	DrawStretchedTextureSegment(C, (X + float(LookAndFeel.BevelUpBL.W)), ((Y + H) - float(R.H)), ((W - float(LookAndFeel.BevelUpBL.W)) - float(LookAndFeel.BevelUpBR.W)), float(R.H), float(R.X), float(R.Y), float(R.W), float(R.H), t);
	R = LookAndFeel.BevelUpBR;
	DrawStretchedTextureSegment(C, ((X + W) - float(R.W)), ((Y + H) - float(R.H)), float(R.W), float(R.H), float(R.X), float(R.Y), float(R.W), float(R.H), t);
	R = LookAndFeel.BevelUpArea;
	DrawStretchedTextureSegment(C, (X + float(LookAndFeel.BevelUpTL.W)), (Y + float(LookAndFeel.BevelUpTL.H)), ((W - float(LookAndFeel.BevelUpBL.W)) - float(LookAndFeel.BevelUpBR.W)), ((H - float(LookAndFeel.BevelUpTL.H)) - float(LookAndFeel.BevelUpBL.H)), float(R.X), float(R.Y), float(R.W), float(R.H), t);
	return;
}

final function DrawMiscBevel(Canvas C, float X, float Y, float W, float H, Texture t, int BevelType)
{
	local Region R;

	C.Style = 5;
	C.SetDrawColor(31, 34, 39);
	R = LookAndFeel.MiscBevelArea[BevelType];
	DrawStretchedTextureSegment(C, (X + float(LookAndFeel.MiscBevelTL[BevelType].W)), (Y + float(LookAndFeel.MiscBevelTL[BevelType].H)), ((W - float(LookAndFeel.MiscBevelBL[BevelType].W)) - float(LookAndFeel.MiscBevelBR[BevelType].W)), ((H - float(LookAndFeel.MiscBevelTL[BevelType].H)) - float(LookAndFeel.MiscBevelBL[BevelType].H)), float(R.X), float(R.Y), float(R.W), float(R.H), t);
	return;
}

final function string RemoveAmpersand(string S)
{
	local string Result, Underline;

	ParseAmpersand(S, Result, Underline, false);
	return Result;
	return;
}

final function byte ParseAmpersand(string S, out string Result, out string Underline, bool bCalcUnderline)
{
	local string temp;
	local int pos, NewPos, i;
	local byte HotKey;

	HotKey = 0;
	pos = 0;
	Result = "";
	Underline = "";
	J0x1F:

	// End:0x154 [Loop If]
	if(true)
	{
		temp = Mid(S, pos);
		NewPos = InStr(temp, "&");
		// End:0x57
		if((NewPos == -1))
		{
			// [Explicit Break]
			goto J0x154;
		}
		(pos += NewPos);
		// End:0xBC
		if((Mid(temp, (NewPos + 1), 1) == "&"))
		{
			Result = ((Result $ Left(temp, NewPos)) $ "&");
			// End:0xB2
			if(bCalcUnderline)
			{
				Underline = (Underline $ " ");
			}
			(pos++);
			// [Explicit Continue]
			goto J0x14A;
		}
		// End:0xE5
		if((int(HotKey) == 0))
		{
			HotKey = byte(Asc(Caps(Mid(temp, (NewPos + 1), 1))));
		}
		Result = (Result $ Left(temp, NewPos));
		// End:0x14A
		if(bCalcUnderline)
		{
			i = 0;
			J0x10E:

			// End:0x13A [Loop If]
			if((i < (NewPos - 1)))
			{
				Underline = (Underline $ " ");
				(i++);
				// [Loop Continue]
				goto J0x10E;
			}
			Underline = (Underline $ "_");
		}
		J0x14A:

		(pos++);
		// [Loop Continue]
		goto J0x1F;
	}
	J0x154:

	Result = (Result $ temp);
	return HotKey;
	return;
}

final function bool MouseIsOver()
{
	return (Root.MouseWindow == self);
	return;
}

function ToolTip(string strTip)
{
	// End:0x23
	if((ParentWindow != Root))
	{
		ParentWindow.ToolTip(strTip);
	}
	return;
}

// Sets mouse window for mouse capture.
final function SetMouseWindow()
{
	Root.MouseWindow = self;
	return;
}

function Texture GetLookAndFeelTexture()
{
	return ParentWindow.GetLookAndFeelTexture();
	return;
}

function bool IsActive()
{
	return ParentWindow.IsActive();
	return;
}

function SetAcceptsHotKeys(bool bNewAccpetsHotKeys)
{
	// End:0x31
	if(((bNewAccpetsHotKeys && (!bAcceptsHotKeys)) && bWindowVisible))
	{
		Root.AddHotkeyWindow(self);
	}
	// End:0x62
	if((((!bNewAccpetsHotKeys) && bAcceptsHotKeys) && bWindowVisible))
	{
		Root.RemoveHotkeyWindow(self);
	}
	bAcceptsHotKeys = bNewAccpetsHotKeys;
	return;
}

final function UWindowWindow GetParent(Class<UWindowWindow> ParentClass, optional bool bExactClass)
{
	local UWindowWindow P;

	P = ParentWindow;
	J0x0B:

	// End:0x7A [Loop If]
	if((P != Root))
	{
		// End:0x44
		if(bExactClass)
		{
			// End:0x41
			if((P.Class == ParentClass))
			{
				return P;
			}			
		}
		else
		{
			// End:0x63
			if(ClassIsChildOf(P.Class, ParentClass))
			{
				return P;
			}
		}
		P = P.ParentWindow;
		// [Loop Continue]
		goto J0x0B;
	}
	return none;
	return;
}

final function UWindowWindow FindChildWindow(Class<UWindowWindow> ChildClass, optional bool bExactClass)
{
	local UWindowWindow Child, Found;

	Child = LastChildWindow;
	J0x0B:

	// End:0xA1 [Loop If]
	if((Child != none))
	{
		// End:0x40
		if(bExactClass)
		{
			// End:0x3D
			if((Child.Class == ChildClass))
			{
				return Child;
			}			
		}
		else
		{
			// End:0x5F
			if(ClassIsChildOf(Child.Class, ChildClass))
			{
				return Child;
			}
		}
		Found = Child.super(UWindowWindow).FindChildWindow(ChildClass);
		// End:0x8A
		if((Found != none))
		{
			return Found;
		}
		Child = Child.PrevSiblingWindow;
		// [Loop Continue]
		goto J0x0B;
	}
	return none;
	return;
}

function GetDesiredDimensions(out float W, out float H)
{
	local float MaxW, MaxH, tW, tH;
	local UWindowWindow Child, Found;

	MaxW = 0.0000000;
	MaxH = 0.0000000;
	Child = LastChildWindow;
	J0x21:

	// End:0x90 [Loop If]
	if((Child != none))
	{
		Child.GetDesiredDimensions(tW, tH);
		// End:0x5F
		if((tW > MaxW))
		{
			MaxW = tW;
		}
		// End:0x79
		if((tH > MaxH))
		{
			MaxH = tH;
		}
		Child = Child.PrevSiblingWindow;
		// [Loop Continue]
		goto J0x21;
	}
	W = MaxW;
	H = MaxH;
	return;
}

final function string TextSize(Canvas C, string Text, out float W, out float H, optional int _TotalWidth, optional int _SpaceWidth)
{
	local string szResult;

	C.SetPos(0.0000000, 0.0000000);
	szResult = C.TextSize(Text, W, H, _TotalWidth, _SpaceWidth);
	W = (W / Root.GUIScale);
	H = (H / Root.GUIScale);
	return szResult;
	return;
}

function ResolutionChanged(float W, float H)
{
	local UWindowWindow Child;

	Child = LastChildWindow;
	J0x0B:

	// End:0x46 [Loop If]
	if((Child != none))
	{
		Child.ResolutionChanged(W, H);
		Child = Child.PrevSiblingWindow;
		// [Loop Continue]
		goto J0x0B;
	}
	return;
}

function ShowModal(UWindowWindow W)
{
	ModalWindow = W;
	W.ShowWindow();
	W.BringToFront();
	return;
}

function bool WaitModal()
{
	// End:0x21
	if(((ModalWindow != none) && ModalWindow.bWindowVisible))
	{
		return true;
	}
	ModalWindow = none;
	return false;
	return;
}

function WindowHidden()
{
	local UWindowWindow Child;

	Child = LastChildWindow;
	J0x0B:

	// End:0x3C [Loop If]
	if((Child != none))
	{
		Child.WindowHidden();
		Child = Child.PrevSiblingWindow;
		// [Loop Continue]
		goto J0x0B;
	}
	return;
}

function WindowShown()
{
	local UWindowWindow Child;

	Child = LastChildWindow;
	J0x0B:

	// End:0x3C [Loop If]
	if((Child != none))
	{
		Child.WindowShown();
		Child = Child.PrevSiblingWindow;
		// [Loop Continue]
		goto J0x0B;
	}
	return;
}

// Should mouse events at these co-ordinates be passed through to underlying windows?
function bool CheckMousePassThrough(float X, float Y)
{
	return false;
	return;
}

final function bool WindowIsVisible()
{
	// End:0x0D
	if((self == Root))
	{
		return true;
	}
	// End:0x1A
	if((!bWindowVisible))
	{
		return false;
	}
	return ParentWindow.super(UWindowWindow).WindowIsVisible();
	return;
}

function SetParent(UWindowWindow NewParent)
{
	HideWindow();
	ParentWindow = NewParent;
	ShowWindow();
	return;
}

function UWindowMessageBox MessageBox(string Title, string Message, UWindowBase.MessageBoxButtons Buttons, UWindowBase.MessageBoxResult ESCResult, optional UWindowBase.MessageBoxResult EnterResult, optional int TimeOut)
{
	local UWindowMessageBox W;
	local UWindowFramedWindow f;

	W = UWindowMessageBox(Root.CreateWindow(Class'UWindow.UWindowMessageBox', 100.0000000, 100.0000000, 100.0000000, 100.0000000, self));
	W.SetupMessageBox(Title, Message, Buttons, ESCResult, EnterResult, TimeOut);
	f = UWindowFramedWindow(GetParent(Class'UWindow.UWindowFramedWindow'));
	// End:0x99
	if((f != none))
	{
		f.ShowModal(W);		
	}
	else
	{
		Root.ShowModal(W);
	}
	return W;
	return;
}

//Overload this function to process the message box result.
function MessageBoxDone(UWindowMessageBox W, UWindowBase.MessageBoxResult Result)
{
	return;
}

function PopUpBoxDone(UWindowBase.MessageBoxResult Result, UWindowBase.EPopUpID _ePopUpID)
{
	return;
}

function SendMessage(UWindowWindow.eR6MenuWidgetMessage eMessage)
{
	return;
}

function NotifyQuitUnreal()
{
	local UWindowWindow Child;

	Child = LastChildWindow;
	J0x0B:

	// End:0x3C [Loop If]
	if((Child != none))
	{
		Child.NotifyQuitUnreal();
		Child = Child.PrevSiblingWindow;
		// [Loop Continue]
		goto J0x0B;
	}
	return;
}

function NotifyBeforeLevelChange()
{
	local UWindowWindow Child;

	Child = LastChildWindow;
	J0x0B:

	// End:0x3C [Loop If]
	if((Child != none))
	{
		Child.NotifyBeforeLevelChange();
		Child = Child.PrevSiblingWindow;
		// [Loop Continue]
		goto J0x0B;
	}
	return;
}

function NotifyAfterLevelChange()
{
	local UWindowWindow Child;

	Child = LastChildWindow;
	J0x0B:

	// End:0x3C [Loop If]
	if((Child != none))
	{
		Child.NotifyAfterLevelChange();
		Child = Child.PrevSiblingWindow;
		// [Loop Continue]
		goto J0x0B;
	}
	return;
}

function NotifyWindow(UWindowWindow C, byte E)
{
	return;
}

function SetCursor(MouseCursor C)
{
	local UWindowWindow Child;

	Cursor = C;
	Child = LastChildWindow;
	J0x16:

	// End:0x4C [Loop If]
	if((Child != none))
	{
		Child.SetCursor(C);
		Child = Child.PrevSiblingWindow;
		// [Loop Continue]
		goto J0x16;
	}
	return;
}

final function ReplaceText(out string Text, string Replace, string With)
{
	local int i;
	local string Input;

	Input = Text;
	Text = "";
	i = InStr(Input, Replace);
	J0x25:

	// End:0x84 [Loop If]
	if((i != -1))
	{
		Text = ((Text $ Left(Input, i)) $ With);
		Input = Mid(Input, (i + Len(Replace)));
		i = InStr(Input, Replace);
		// [Loop Continue]
		goto J0x25;
	}
	Text = (Text $ Input);
	return;
}

function StripCRLF(out string Text)
{
	ReplaceText(Text, (Chr(13) $ Chr(10)), "");
	ReplaceText(Text, Chr(13), "");
	ReplaceText(Text, Chr(10), "");
	return;
}

// This is implemented over here because we need an access for the console 
function SetServerOptions()
{
	return;
}

//===========================================================================================
// MenuLoadProfile: A profile was load
//===========================================================================================
function MenuLoadProfile(bool _bServerProfile)
{
	return;
}

function SetBorderColor(Color _NewColor)
{
	return;
}

// NEW IN 1.60
function ProcessGSMsg(string _szMsg)
{
	return;
}

defaultproperties
{
	float WinWidth
	m_BorderStyle=1
	m_BorderTexture=Texture'UWindow.WhiteTexture'
	m_BorderTextureRegion=(Zone=m_BorderTextureRegion=WinWidth,iLeaf=290,ZoneNumber=0)
	m_BorderColor=(R=255,G=255,B=255,A=0)
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var m_bDisplayCheckKeyFocus
// REMOVED IN 1.60: function GetNotifyMsg
// REMOVED IN 1.60: function DrawClippedActor
