//=============================================================================
// UWindowWindow - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
// UWindowWindow - the parent class for all Window objects
//=============================================================================
class UWindowWindow extends UWindowBase;

// Dialog event codes passed to NotifyWindow(Source, EventCode) when a child widget fires.
// The parent window receives these to react to child state changes (like WM_NOTIFY in Win32).
const DE_Created = 0;       // widget was just created
const DE_Change = 1;        // value changed (edit text, slider position, etc.)
const DE_Click = 2;         // left-click
const DE_Enter = 3;         // mouse entered the widget
const DE_Exit = 4;          // mouse left the widget
const DE_MClick = 5;        // middle-click
const DE_RClick = 6;        // right-click
const DE_EnterPressed = 7;  // Enter key pressed while focused
const DE_MouseMove = 8;     // mouse moved over widget
const DE_MouseLeave = 9;    // mouse left widget bounds
const DE_LMouseDown = 10;   // left button held down
const DE_DoubleClick = 11;  // left double-click
const DE_MouseEnter = 12;   // mouse entered widget bounds
const DE_HelpChanged = 13;  // tooltip / help text changed
const DE_WheelUpPressed = 14;   // mouse wheel scrolled up
const DE_WheelDownPressed = 15; // mouse wheel scrolled down

// Low-level window messages, analogous to Win32 WM_* messages.
// Dispatched by WindowEvent() — the UWindow equivalent of a Win32 WndProc.
// Note: case labels in WindowEvent use raw integer literals because the decompiler lost
// the enum names from bytecode; the numbers below are the canonical mapping.
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
	WM_KeyType,                     // 10 - printable character typed
	WM_Paint                        // 11
};

// Rainbow Six-specific widget messages for Ubi.com login and CD-key/server query flows.
// Sent via SendMessage() to propagate network authentication state changes up the widget tree.
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

// MouseCursor: defines a software cursor rendered by UWindow.
// HotX/HotY is the "hot spot" — the pixel within Tex that is the actual cursor tip
// (equivalent to XHOTSPOT/YHOTSPOT in a .cur file).
// WindowsCursor is a Win32 OCR_* system cursor index used as a fallback when no texture
// cursor is available (e.g. during loading before textures are ready).
struct MouseCursor
{
	var Texture Tex;        // cursor texture to draw
	var int HotX;           // hot-spot X offset within Tex (pixels from left edge)
	var int HotY;           // hot-spot Y offset within Tex (pixels from top edge)
	var byte WindowsCursor; // fallback Win32 system cursor ID (OCR_NORMAL=32512, etc.)
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
var bool bIgnoreLDoubleClick;  // suppress double-click detection for left button
var bool bIgnoreMDoubleClick;  // suppress double-click detection for middle button
var bool bIgnoreRDoubleClick;  // suppress double-click detection for right button
var bool m_bNotDisplayBkg;  // Not display the back ground (to avoid heritance of paint(){})
// When true, this window skips its WM_Paint call this frame (deferred layout pass).
// PaintClients() clears it back to false after skipping, so it is a one-frame flag.
var bool m_bPreCalculatePos;
// Dimensions, offset relative to parent.
var float WinLeft;    // X position of this window's top-left corner in parent-local pixels
var float WinTop;     // Y position of this window's top-left corner in parent-local pixels
var float WinWidth;   // width in logical (pre-GUIScale) pixels
var float WinHeight;  // height in logical (pre-GUIScale) pixels
// Centering offsets applied by ApplyResolutionOnWindowsPos() when the screen is larger than
// the 640x480 base design resolution; tracks the previously-applied centering delta so it
// can be undone (subtract old, add new) without accumulated drift on resize.
var float OrgXOffset;
var float OrgYOffset;
// Timestamps and positions of the most recent click for each button,
// used to detect double-clicks: a second release within 1px AND 0.4s triggers DoubleClick.
var float ClickTime;   // time of last left-click release
var float MClickTime;  // time of last middle-click release
var float RClickTime;  // time of last right-click release
var float ClickX;    // X position of last left-click (proximity check for double-click)
var float ClickY;    // Y position of last left-click
var float MClickX;   // X position of last middle-click
var float MClickY;   // Y position of last middle-click
var float RClickX;   // X position of last right-click
var float RClickY;   // Y position of last right-click
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
var UWindowLookAndFeel LookAndFeel;  // theming system; controls bevel textures, fonts, colors
var Texture m_BorderTexture;         // texture used by DrawSimpleBorder()
var Region ClippingRegion;           // current draw clip rect in window-local pixels; set by PaintClients()
var Region m_BorderTextureRegion;    // source region within m_BorderTexture for border strips
var Color m_BorderColor;             // tint color applied when drawing the border
var MouseCursor Cursor;              // current cursor shape; inherited by child windows on creation
var string ToolTipString;  // Allows any window to have a tooltip

// WindowEvent: central message dispatcher — the UWindow equivalent of a Win32 WndProc.
// Called by the engine (or parent) for every input event and paint request.
// Coordinates X,Y are in this window's local space (relative to its own top-left corner).
// Key is the raw EInputKey value for keyboard events; 0 for paint/mouse messages.
// Mouse events are first offered to the topmost child under the cursor (MessageClients);
// only if no child claims the event does this window handle it directly.
// Key events route through PropagateKey to reach whichever child has bAcceptsFocus set.
// Ideally Key would be a EInputKey but I can't see that class here.
function WindowEvent(UWindowWindow.WinMessage Msg, Canvas C, float X, float Y, int Key)
{
	switch(Msg)
	{
		// WM_Paint (11): render this window then recursively paint all visible children.
		// Paint() draws this window's own content; PaintClients() iterates children back-to-front.
		// End:0x39
		case 11:
			Paint(C, X, Y);
			PaintClients(C, X, Y);
			// End:0x30A
			break;
		// WM_LMouseDown (0): left mouse button pressed.
		// CheckCaptureMouseDown() lets Root block events while another window has captured input.
		// MessageClients() dispatches to the topmost child under the cursor first; if no child
		// claims the event, LMouseDown() handles it on this window.
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
		// WM_LMouseUp (1): left mouse button released.
		// CheckCaptureMouseUp() mirrors the down-capture guard for release events.
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
		// WM_KeyDown (9): key pressed. PropagateKey walks the child chain looking for
		// a window with bAcceptsFocus; if none claims it, KeyDown() handles it on this window.
		// End:0x282
		case 9:
			// End:0x27F
			if((!PropagateKey(Msg, C, X, Y, Key)))
			{
				KeyDown(Key, X, Y);
			}
			// End:0x30A
			break;
		// WM_KeyUp (8): key released.
		// End:0x2C3
		case 8:
			// End:0x2C0
			if((!PropagateKey(Msg, C, X, Y, Key)))
			{
				KeyUp(Key, X, Y);
			}
			// End:0x30A
			break;
		// WM_KeyType (10): a printable character was typed (Key = ASCII/Unicode code point).
		// Different from KeyDown: KeyType fires only for text-generating keypresses.
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

// SaveConfigs: override in subclasses to persist window/settings state to INI files.
// Called automatically by Close() before the window is hidden.
function SaveConfigs()
{
	return;
}

// GetPlayerOwner: walks Root→Console→Viewport to reach the local PlayerController.
// This is the main bridge from UI code into the game world.
final function PlayerController GetPlayerOwner()
{
	return Root.Console.ViewportOwner.Actor;
	return;
}

// GetLevel: returns the current gameplay LevelInfo (level name, game rules, time, etc.).
final function LevelInfo GetLevel()
{
	return Root.Console.ViewportOwner.Actor.Level;
	return;
}

// GetTime: returns current world time in seconds (monotonically increasing).
// Used for double-click timing and any animation that needs elapsed wall time.
final function float GetTime()
{
	return Class'Engine.Actor'.static.GetTime();
	return;
}

// GetEntryLevel: returns the persistent "entry" level that is always loaded.
// Used to reach game objects that survive level transitions (GameInfo, etc.).
final function LevelInfo GetEntryLevel()
{
	return Root.Console.ViewportOwner.Actor.super(UWindowWindow).GetEntryLevel();
	return;
}

// GetButtonsDefinesUnique: finds or creates a singleton window of WndClass at root level.
// Searches the entire tree first (bExactClass=true); only creates a new instance if none
// found. Used for shared "button definition" windows that should exist only once globally.
final function UWindowWindow GetButtonsDefinesUnique(Class<UWindowWindow> WndClass)
{
	local UWindowWindow Child;

	Child = Root.FindChildWindow(WndClass, true);
	// End:0x56
	if((Child == none))
	{
		// Create at (0,0) with zero size; the window positions itself in Created().
		Child = Root.CreateWindow(WndClass, 0.0000000, 0.0000000, 0.0000000, 0.0000000, none, true);
	}
	return Child;
	return;
}

// Resized: called after WinWidth or WinHeight changes (via SetSize).
// Override to reposition child windows or recalculate layout after a size change.
function Resized()
{
	return;
}

// BeforePaint: called at the start of each paint pass, before this window's Paint().
// Override for pre-draw setup that depends on the current Canvas state (e.g. font metrics).
function BeforePaint(Canvas C, float X, float Y)
{
	return;
}

// AfterPaint: called after WindowEvent(WM_Paint) completes for this window.
// Override to draw overlays on top of all child content, or restore modified canvas state.
function AfterPaint(Canvas C, float X, float Y)
{
	return;
}

// Paint: override to draw this window's content using Canvas C.
// X,Y are the current mouse position in window-local coordinates (not the draw origin).
// Always called before PaintClients(), so children render on top of parent content.
function Paint(Canvas C, float X, float Y)
{
	return;
}

// Click: fired on left mouse button release (single click). X,Y in window-local pixels.
function Click(float X, float Y)
{
	return;
}

// MClick: fired on middle mouse button release (single click).
function MClick(float X, float Y)
{
	return;
}

// RClick: fired on right mouse button release (single click).
function RClick(float X, float Y)
{
	return;
}

// DoubleClick: fired when two left-clicks land within 1px and 0.4s of each other.
function DoubleClick(float X, float Y)
{
	return;
}

// MDoubleClick: middle-button double-click equivalent.
function MDoubleClick(float X, float Y)
{
	return;
}

// RDoubleClick: right-button double-click equivalent.
function RDoubleClick(float X, float Y)
{
	return;
}

// BeginPlay: called once when the window object is first allocated (like UE Actor::BeginPlay).
// Called before geometry and relationships are set; use for very early initialization.
function BeginPlay()
{
	return;
}

// Created: called after WinTop/Left/Width/Height, Root, and ParentWindow are all set.
// Override to create child windows (call CreateWindow() for children here).
function Created()
{
	return;
}

// MouseEnter: fired when the cursor first moves over this window.
// Automatically registers ToolTipString for display if one is set.
function MouseEnter()
{
	// End:0x17
	if((ToolTipString != ""))
	{
		ToolTip(ToolTipString);
	}
	return;
}

// Activated: fired when this window becomes the active (focused) child of its parent.
// Called during ActivateWindow() after the previous active window is deactivated.
function Activated()
{
	return;
}

// Deactivated: fired when another sibling window becomes active instead of this one.
function Deactivated()
{
	return;
}

// MouseLeave: fired when the cursor moves off this window.
// Clears all button-down flags to prevent phantom clicks if the mouse left while held.
// Passes an empty string to ToolTip() to dismiss any active tooltip.
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

// MouseMove: fired each frame the cursor moves while over this window. X,Y in local pixels.
function MouseMove(float X, float Y)
{
	return;
}

// KeyUp: raw key release event. Key is the EInputKey enum value.
function KeyUp(int Key, float X, float Y)
{
	return;
}

// KeyDown: raw key press event. Called when no focused child claimed the key first.
function KeyDown(int Key, float X, float Y)
{
	return;
}

//return true to break the chaining of input
//a window should return true when it uses the incomming input
// HotKeyDown: global hotkey press delivered by Root regardless of focus.
// Return true to consume the event and stop it from reaching other hotkey windows.
// Only called when this window is registered via SetAcceptsHotKeys(true).
function bool HotKeyDown(int Key, float X, float Y)
{
	return false;
	return;
}

// HotKeyUp: global hotkey release. Return true to consume the event.
function bool HotKeyUp(int Key, float X, float Y)
{
	return false;
	return;
}

// MouseUpDown: catchall for mouse button events not handled by the normal flow.
// Return true to consume the event.
function bool MouseUpDown(int Key, float X, float Y)
{
	return false;
	return;
}

// KeyType: a printable character was typed (Key = ASCII/Unicode code point).
// Different from KeyDown: KeyType fires only for text-generating keypresses,
// not for modifiers, arrows, function keys, etc.
function KeyType(int Key, float X, float Y)
{
	return;
}

// ProcessMenuKey: handles keyboard navigation within menus (arrow keys, Enter, Escape).
// KeyName is the string name of the key (e.g. "Up", "Enter").
function ProcessMenuKey(int Key, string KeyName)
{
	return;
}

// KeyFocusEnter: called when this window gains keyboard focus (equivalent to WM_SETFOCUS).
// Override to show a text cursor, highlight, or begin accepting typed input.
function KeyFocusEnter()
{
	return;
}

// KeyFocusExit: called when keyboard focus leaves this window (equivalent to WM_KILLFOCUS).
// Override to hide cursors or commit any pending text input.
function KeyFocusExit()
{
	return;
}

// RMouseDown: right mouse button pressed. Activates this window and records the press.
function RMouseDown(float X, float Y)
{
	ActivateWindow(0, false);
	bRMouseDown = true;
	return;
}

// RMouseUp: right mouse button released.
// Double-click detection: if previous release was within 1px AND 0.4s, fire RDoubleClick.
// The 1px proximity guard accounts for slight cursor movement between clicks.
// Resetting RClickTime to 0 prevents a triple-click from triggering a second double-click.
function RMouseUp(float X, float Y)
{
	// End:0xAD
	if(bRMouseDown)
	{
		// End:0x7B
		if(((((!bIgnoreRDoubleClick) && (Abs((X - RClickX)) <= float(1))) && (Abs((Y - RClickY)) <= float(1))) && (GetTime() < (RClickTime + 0.4000000))))
		{
			RDoubleClick(X, Y);
			RClickTime = 0.0000000; // reset so triple-click won't re-trigger double-click		
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

// MMouseDown: middle mouse button pressed.
function MMouseDown(float X, float Y)
{
	ActivateWindow(0, false);
	bMMouseDown = true;
	return;
}

// MMouseUp: middle mouse button released. Same double-click logic as RMouseUp.
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

// LMouseDown: left mouse button pressed. Activates (brings to front) this window.
function LMouseDown(float X, float Y)
{
	ActivateWindow(0, false);
	bMouseDown = true;
	return;
}

// LMouseUp: left mouse button released.
// Guards with bMouseDown to ignore spurious up events (e.g. if down fired elsewhere).
// Double-click: if previous click was within 1px AND 0.4s, fires DoubleClick instead.
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

// FocusWindow: makes this window the global keyboard-focus window (Root.FocusedWindow).
// If another window currently has focus, notifies it via FocusOtherWindow() first so it
// can react to losing focus before we steal it.
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

// FocusOtherWindow: called on the previously-focused window when W takes focus.
// Override to react to losing keyboard focus (e.g. deselect text, hide caret).
function FocusOtherWindow(UWindowWindow W)
{
	return;
}

// EscClose: default Escape key handler — simply closes this window.
// Override to suppress Escape or show a confirmation dialog.
function EscClose()
{
	Close();
	return;
}

// Close: recursively closes all children (bottom-up) then saves config and hides self.
// bByParent=true means a parent is driving the close; this window skips HideWindow()
// because the parent will handle the visibility change.  bByParent=false = direct close.
// The goto loop is the decompiler's representation of: for(Child = Last; Child != None; Child = Prev)
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

// SetSize: sets window dimensions and fires Resized() only if they actually changed.
// Use this instead of writing WinWidth/WinHeight directly so layout callbacks fire.
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

// Tick: per-frame update callback (Delta = seconds since last frame).
// Override for animations, timers, or any logic that must run every frame.
function Tick(float Delta)
{
	return;
}

// DoTick: engine-facing tick dispatcher. Calls our Tick() then propagates the tick to all
// visible children front-to-back (FirstChildWindow is the bottom/back window).
// bLeaveOnscreen propagates downward: a parent marked to stay visible even when UWindow is
// inactive causes all its children to also stay active (bLeaveOnscreen is inherited).
// Children only tick if UWindow is active OR the child has been marked to stay onscreen.
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

// PaintClients: iterates all visible children back-to-front and paints each one.
// "Back-to-front" means FirstChildWindow (bottom of Z-order) is painted first, so the
// topmost window (LastChildWindow) is drawn last and appears on top.
//
// For each child:
//   1. Shift the canvas origin to the child's top-left corner (scaled by GUIScale so
//      logical pixels map to physical screen pixels).
//   2. Unless bNoClip is set, clip the child to the intersection of its own bounds and the
//      parent's remaining draw area, translating ClippingRegion into child-local space.
//   3. Only fire WM_Paint if the resulting clipping rect has positive area (avoids
//      painting fully-clipped/offscreen children).
//   4. Recursively fires WindowEvent(WM_Paint) so the child renders its own children too.
//   5. Restore canvas origin after each child (clip is restored once after the whole loop).
//
// m_bPreCalculatePos: a one-frame flag used for deferred layout. When true, the child skips
// its WM_Paint call this frame; PaintClients clears the flag after skipping so the child
// paints normally next frame.
final function PaintClients(Canvas C, float X, float Y)
{
	local float OrgX, OrgY, ClipX, ClipY;
	local UWindowWindow Child;

	// Save canvas state so we can restore it after painting all children.
	OrgX = C.OrgX;
	OrgY = C.OrgY;
	ClipX = C.ClipX;
	ClipY = C.ClipY;
	// Start from the back (FirstChildWindow); loop forward so front windows paint on top.
	Child = FirstChildWindow;
	J0x5B:

	// End:0x617 [Loop If]
	if((Child != none))
	{
		Child.bUWindowActive = bUWindowActive;
		// Reset canvas position and style before painting each child so they start clean.
		C.SetPos(0.0000000, 0.0000000);
		C.Style = GetPlayerOwner().1;  // STY_Normal (1); each child sets its own style
		C.SetDrawColor(byte(255), byte(255), byte(255));  // white; child tints as needed
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
			// Shift canvas origin to child's top-left, converting logical to screen pixels.
			C.OrgX = (C.OrgX + (Child.WinLeft * Root.GUIScale));
			C.OrgY = (C.OrgY + (Child.WinTop * Root.GUIScale));
			// End:0x500
			if((!Child.bNoClip))
			{
				// Clip to min(space left in parent, child's own size) so child can't draw outside parent.
				C.ClipX = (FMin((WinWidth - Child.WinLeft), Child.WinWidth) * Root.GUIScale);
				C.ClipY = (FMin((WinHeight - Child.WinTop), Child.WinHeight) * Root.GUIScale);
				C.HalfClipX = (C.ClipX * 0.5000000);
				C.HalfClipY = (C.ClipY * 0.5000000);
				// Translate parent's ClippingRegion into child-local coordinates.
				Child.ClippingRegion.X = int((float(ClippingRegion.X) - Child.WinLeft));
				Child.ClippingRegion.Y = int((float(ClippingRegion.Y) - Child.WinTop));
				Child.ClippingRegion.W = ClippingRegion.W;
				Child.ClippingRegion.H = ClippingRegion.H;
				// End:0x3B6
				// If clipping rect overhangs the left edge of the child, shrink W to compensate.
				if((Child.ClippingRegion.X < 0))
				{
					(Child.ClippingRegion.W += Child.ClippingRegion.X);
					Child.ClippingRegion.X = 0;
				}
				// End:0x40C
				// If clipping rect overhangs the top edge, shrink H to compensate.
				if((Child.ClippingRegion.Y < 0))
				{
					(Child.ClippingRegion.H += Child.ClippingRegion.Y);
					Child.ClippingRegion.Y = 0;
				}
				// End:0x486
				// Clamp W so the rect doesn't exceed the child's right edge.
				if((float(Child.ClippingRegion.W) > (Child.WinWidth - float(Child.ClippingRegion.X))))
				{
					Child.ClippingRegion.W = int((Child.WinWidth - float(Child.ClippingRegion.X)));
				}
				// End:0x500
				// Clamp H so the rect doesn't exceed the child's bottom edge.
				if((float(Child.ClippingRegion.H) > (Child.WinHeight - float(Child.ClippingRegion.Y))))
				{
					Child.ClippingRegion.H = int((Child.WinHeight - float(Child.ClippingRegion.Y)));
				}
			}
			// End:0x5D8
			// Only paint if the clipping rect has positive area; skip fully-clipped windows.
			if(((Child.ClippingRegion.W > 0) && (Child.ClippingRegion.H > 0)))
			{
				// End:0x5C7
				if((!Child.m_bPreCalculatePos))
				{
					// Recursively dispatch WM_Paint (11) into the child.
					Child.WindowEvent(11, C, (X - Child.WinLeft), (Y - Child.WinTop), 0);
					Child.AfterPaint(C, (X - Child.WinLeft), (Y - Child.WinTop));
				}
				// Clear the one-frame deferred-layout flag so the child paints next frame.
				Child.m_bPreCalculatePos = false;
			}
			// Restore canvas origin (clip is restored after the whole loop ends).
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

// FindWindowUnder: hit-test — finds the deepest visible window containing screen point (X,Y).
// Traverses children from topmost (LastChildWindow) to bottommost so the front window wins
// when windows overlap. For each child that contains the point and doesn't pass-through,
// recursively descends (converting to child-local coordinates) to find the deepest hit.
// Returns 'self' if no child claims the point — meaning this window itself is the target.
// Called every frame by Root to keep Root.MouseWindow up-to-date for hover/click routing.
final function UWindowWindow FindWindowUnder(float X, float Y)
{
	local UWindowWindow Child;

	// Start from the front (topmost) child so front windows take priority on overlap.
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
			// Point must lie within the child's rect and not be pass-through to count as a hit.
			if((((((X >= Child.WinLeft) && (X <= (Child.WinLeft + Child.WinWidth))) && (Y >= Child.WinTop)) && (Y <= (Child.WinTop + Child.WinHeight))) && (!Child.CheckMousePassThrough((X - Child.WinLeft), (Y - Child.WinTop)))))
			{
				// Recurse into the child, converting to its local coordinate space.
				return Child.super(UWindowWindow).FindWindowUnder((X - Child.WinLeft), (Y - Child.WinTop));
			}
		}
		Child = Child.PrevSiblingWindow;
		// [Loop Continue]
		goto J0x0B;
	}
	// No child claimed the point — this window itself is the deepest hit.
	return self;
	return;
}

//===============================================================================
// ApplyResolutionOnWindowsPos: Change windows position base on current root resolution
//===============================================================================
// Re-centers child windows when screen resolution changes.
// R6's UI is designed at 640x480; at higher resolutions the UI is offset by half the
// extra space so it appears centered. OrgXOffset/OrgYOffset track the previously-applied
// offset so we subtract it before applying the new one, preventing drift on resize.
// If m_bScaleWindowToRoot is true the entire UI is scaled instead of centered; bail early.
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
			// Center offset = half the extra screen space beyond the 640x480 design resolution.
			fX = ((Root.WinWidth - float(640)) * 0.5000000);
			fY = ((Root.WinHeight - float(480)) * 0.5000000);
			// End:0x127
			// Undo the old X offset, apply the new one: WinLeft = (WinLeft - oldX) + newX.
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

// PropagateKey: walks the child list to find the first child with bAcceptsFocus=true
// and delivers the key event to it. Returns true if a child consumed the event (stop here),
// false if no child accepted focus (caller should handle the key itself).
// HACK: if ActiveWindow is set and the topmost child is not transient, jump straight to
// ActiveWindow — this ensures always-on-top windows don't shadow the intended focus target.
//final function bool PropagateKey(WinMessage Msg, Canvas C, float X, float Y, int Key)
function bool PropagateKey(UWindowWindow.WinMessage Msg, Canvas C, float X, float Y, int Key)
{
	local UWindowWindow Child;

	// Normally start at the topmost child, but apply the ActiveWindow priority hack.
	Child = LastChildWindow;
	// End:0x48
	if((((ActiveWindow != none) && (Child != ActiveWindow)) && (!Child.bTransient)))
	{
		// Skip directly to the previously-active window to preserve intended focus.
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
			// Deliver the key to this child (converting to its local coords) and stop propagation.
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

// CheckKeyFocusWindow: recursively descends to find the deepest child accepting key focus.
// Mirrors the same ActiveWindow priority hack used in PropagateKey.
// Returns 'self' if no child accepts focus — meaning this window should be the keyboard target.
// Called by Root after window activation to determine which window receives typed input.
final function UWindowWindow CheckKeyFocusWindow()
{
	local UWindowWindow Child;

	// Apply the same ActiveWindow priority hack as PropagateKey.
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
				// Recurse — this child might have a deeper focus-accepting descendant.
				return Child.super(UWindowWindow).CheckKeyFocusWindow();
			}
		}
		Child = Child.PrevSiblingWindow;
		// [Loop Continue]
		goto J0x48;
	}
	// No child accepts focus; this window is the keyboard target.
	return self;
	return;
}

// MessageClients: routes a mouse message to whichever topmost child is under (X,Y).
// Scans from front (LastChildWindow) to back; the first child whose bounds contain the
// point and doesn't pass-through receives the event. Returns true if a child handled it
// (caller should not process the event further). This is called first in WindowEvent()
// for all mouse messages — the parent handles it only if no child claims it, mirroring
// the WM_NCHITTEST / WM_SETCURSOR child-dispatch behaviour in Win32.
final function bool MessageClients(UWindowWindow.WinMessage Msg, Canvas C, float X, float Y, int Key)
{
	local UWindowWindow Child;

	// Start from the topmost child so front windows win on overlap.
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
				// Translate to child-local coords and dispatch. The child may recurse further.
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
// ActivateWindow: recursively activates this window and all of its ancestors up to Root.
// Depth tracks the recursion level; keyboard focus is only claimed at Depth==0 (the
// original call site) so inner recursive calls don't redundantly steal focus.
// bTransientNoDeactivate: if the activating window or any ancestor is transient (e.g. a
// combo dropdown), the previously-active sibling is NOT deactivated — transient windows
// appear on top temporarily without disturbing the underlying focus state.
// Non-transient activation: deactivates the previous sibling, updates ActiveWindow,
// recurses up the parent chain, then fires Activated() on the way back down.
// bAlwaysBehind windows skip the hide/show Z-reorder entirely.
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
	// Re-insert into the parent's sibling list at the front (topmost Z-order).
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
// BringToFront: moves this window to the front of the Z-order (topmost sibling).
// Recursively calls itself up the parent chain so all ancestors also move to front.
// Blocked by bAlwaysBehind or if a modal window is blocking (WaitModal()).
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
// SendToBack: moves this window to the bottom of the Z-order (behind all siblings).
// Achieved by HideChildWindow then ShowChildWindow with bAtBack=true.
final function SendToBack()
{
	ParentWindow.HideChildWindow(self);
	ParentWindow.ShowChildWindow(self, true);
	return;
}

// HideChildWindow: removes Child from this window's visible sibling linked list.
// Three cases for removal from the doubly-linked list:
//   1. Child is the topmost  (LastChildWindow)  — update the tail pointer.
//   2. Child is the bottommost (FirstChildWindow) — update the head pointer.
//   3. Child is in the middle — linear scan to find its predecessor and splice it out.
// After removal, scans backwards from the new tail to elect a new ActiveWindow,
// skipping bAlwaysOnTop windows (tooltips etc.) since they can never be the active window.
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
			// Child is in the middle — walk the list to find its predecessor and splice it out.
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

	// Elect a new ActiveWindow, skipping bAlwaysOnTop windows (tooltips etc.).
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
	// Fallback: if all remaining windows are bAlwaysOnTop, just use the topmost one.
	if((ActiveWindow == none))
	{
		ActiveWindow = LastChildWindow;
	}
	return;
}

//Allow a window to have focus
// SetAcceptsFocus: marks this window AND all ancestors as accepting keyboard focus.
// The flag must propagate all the way to Root so PropagateKey/CheckKeyFocusWindow can
// walk the tree and know which branch leads to a focus-accepting window.
// The empty bAcceptsFocus block is a decompiler artifact from a removed debug log.
final function SetAcceptsFocus()
{
	// End:0x09
	if(bAcceptsFocus)
	{
		// already set; empty block is a decompiler artifact (debug log was here in SDK 1.56)
	}
	bAcceptsFocus = true;
	// End:0x2B
	// Propagate up the parent chain so all ancestors advertise the path to focus.
	if((self != Root))
	{
		ParentWindow.super(UWindowWindow).SetAcceptsFocus();
	}
	return;
}

// CancelAcceptsFocus: clears the bAcceptsFocus flag and propagates the clear up the tree.
// bAlwaysAcceptsFocus (set on persistent input widgets like edit boxes) prevents clearing.
// Called when a focusable child is hidden/destroyed so ancestors don't advertise a stale path.
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

// GetMouseXY: returns current mouse position in this window's local coordinate space.
// Root.MouseX/Y are raw screen pixels; scaled by m_fWindowScaleX/Y to get logical GUI
// pixels (the same space as WinLeft/WinTop). Then walks up the parent chain subtracting
// each ancestor's WinLeft/WinTop offset to arrive at this window's local origin.
// The float(int(...)) truncates to integer to avoid sub-pixel wobble each frame.
final function GetMouseXY(out float X, out float Y)
{
	local UWindowWindow P;

	// Convert screen pixels → logical GUI pixels, then truncate to integer.
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
// GlobalToWindow: converts a Root-relative coordinate into this window's local space.
// "Global" means the root's coordinate space (top-left of the whole UI = 0,0).
// Walks up the parent chain subtracting each ancestor's WinLeft/WinTop offset.
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

// WindowToGlobal: inverse of GlobalToWindow — converts this window's local coordinate
// to a Root-relative (global) coordinate by accumulating parent offsets up to Root.
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

// ShowChildWindow: inserts Child into this window's visible sibling list at the correct Z-order.
// bAtBack=true: insert at the very bottom (FirstChildWindow); used by SendToBack().
// bAtBack=false (default): scan backwards from the topmost window to find the correct slot:
//   - bAlwaysOnTop children are inserted at the very top (in front of everything).
//   - Normal children are inserted in front of all non-bAlwaysOnTop windows.
// Transient windows (combo dropdowns etc.) don't update ActiveWindow on show.
// If Child accepts hotkeys, registers it with Root's global hotkey dispatch table.
final function ShowChildWindow(UWindowWindow Child, optional bool bAtBack)
{
	local UWindowWindow W;

	// End:0x1F
	// Transient windows (e.g. dropdowns) don't steal ActiveWindow on show.
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
		// Scan backwards from topmost: stop when we find a valid insertion point.
		// We stop when: child is bAlwaysOnTop (goes above all), or W is None (fell off back),
		// or W is not bAlwaysOnTop (found a normal window to insert after).
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

// ShowWindow: convenience wrapper — asks parent to add this window to the visible list,
// then fires WindowShown() recursively so descendants can refresh their content.
function ShowWindow()
{
	ParentWindow.ShowChildWindow(self);
	WindowShown();
	return;
}

// HideWindow: fires WindowHidden() first (so children can clean up), then removes this
// window from the parent's visible sibling list. Order matters: children must know they
// are being hidden before the parent removes this window from the paint traversal.
function HideWindow()
{
	WindowHidden();
	ParentWindow.HideChildWindow(self);
	return;
}

// CreateWindow: main factory for all child windows.
// WndClass: class to instantiate.  X,Y,W,H: initial geometry in parent-local logical pixels
// (truncated to integer to keep UI on the pixel grid).  OwnerW: semantic "owner" (not
// necessarily the parent); defaults to self if None.  bUnique: if true, searches for an
// existing instance first and raises it instead of creating a duplicate.  ObjectName:
// optional UObject name for INI-persistent windows.
// Sequence: BeginPlay → set geometry/relationships → Created → ShowChildWindow.
final function UWindowWindow CreateWindow(Class<UWindowWindow> WndClass, float X, float Y, float W, float H, optional UWindowWindow OwnerW, optional bool bUnique, optional name ObjectName)
{
	local UWindowWindow Child;

	// End:0x53
	if(bUnique)
	{
		// Singleton: reuse any existing instance rather than creating a duplicate.
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
	// Truncate to integer to keep the window on the pixel grid (no sub-pixel positioning).
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
		Child.OwnerWindow = self;  // default owner is the creating window
	}
	Child.Cursor = Cursor;           // inherit parent's cursor shape
	Child.bAlwaysBehind = false;
	Child.LookAndFeel = LookAndFeel; // inherit parent's theme
	Child.Created();
	ShowChildWindow(Child);          // add to Z-order and mark visible
	return Child;
	return;
}

// DrawHorizTiledPieces: tiles up to 5 texture regions horizontally across DestW pixels.
// Pieces cycle left-to-right (T1, T2, T3...) wrapping around until DestX+DestW is filled.
// Any Ti with a null texture is ignored (PieceCount counts valid pieces only).
// Scale multiplies source region dimensions to compute the on-screen size per tile.
// L = remaining width at each step so the final piece is correctly clipped at the edge.
// Used for variable-width UI elements like scrollbar tracks and tiled panel backgrounds.
final function DrawHorizTiledPieces(Canvas C, float DestX, float DestY, float DestW, float DestH, TexRegion T1, TexRegion T2, TexRegion T3, TexRegion T4, TexRegion T5, float Scale)
{
	local TexRegion Pieces[5], R;
	local int PieceCount, j;
	local float X, L;

	// Build the piece array and count how many valid (non-null) pieces we have.
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

// DrawClippedTexture: draws Tex at (X,Y) at its native pixel dimensions (no stretching).
final function DrawClippedTexture(Canvas C, float X, float Y, Texture Tex)
{
	DrawStretchedTextureSegment(C, X, Y, float(Tex.USize), float(Tex.VSize), 0.0000000, 0.0000000, float(Tex.USize), float(Tex.VSize), Tex);
	return;
}

// DrawStretchedTexture: draws the entire texture scaled to fit the destination (W x H) rect.
final function DrawStretchedTexture(Canvas C, float X, float Y, float W, float H, Texture Tex)
{
	DrawStretchedTextureSegment(C, X, Y, W, H, 0.0000000, 0.0000000, float(Tex.USize), float(Tex.VSize), Tex);
	return;
}

// DrawStretchedTextureSegment: the core UI drawing primitive; all texture calls funnel here.
// tX,tY,tW,tH = source rect within Tex (supports texture atlas / sprite sheet lookups).
// X,Y,W,H = destination rect in window-local logical pixels.
// Delegates to native C++ which applies GUIScale and ClippingRegion for us.
final function DrawStretchedTextureSegment(Canvas C, float X, float Y, float W, float H, float tX, float tY, float tW, float tH, Texture Tex)
{
	C.DrawStretchedTextureSegmentNative(X, Y, W, H, tX, tY, tW, tH, Root.GUIScale, ClippingRegion, Tex);
	return;
}

// DrawStretchedTextureSegmentRot: like DrawStretchedTextureSegment but supports rotation.
// fTexRotation is in degrees.  Cannot use the native fast path — must manually push/pop
// canvas origin and clip rect, transform the draw position, then restore state.
final function DrawStretchedTextureSegmentRot(Canvas C, float X, float Y, float W, float H, float tX, float tY, float tW, float tH, Texture Tex, float fTexRotation)
{
	local float OrgX, OrgY, ClipX, ClipY;

	// Push canvas state.
	OrgX = C.OrgX;
	OrgY = C.OrgY;
	ClipX = C.ClipX;
	ClipY = C.ClipY;
	// Shift origin to ClippingRegion top-left in physical screen pixels.
	C.SetOrigin((OrgX + (float(ClippingRegion.X) * Root.GUIScale)), (OrgY + (float(ClippingRegion.Y) * Root.GUIScale)));
	C.SetClip((float(ClippingRegion.W) * Root.GUIScale), (float(ClippingRegion.H) * Root.GUIScale));
	// Draw position is relative to the new origin, scaled to physical pixels.
	C.SetPos(((X - float(ClippingRegion.X)) * Root.GUIScale), ((Y - float(ClippingRegion.Y)) * Root.GUIScale));
	C.DrawTile(Tex, (W * Root.GUIScale), (H * Root.GUIScale), tX, tY, tW, tH, fTexRotation);
	// Pop canvas state.
	C.SetClip(ClipX, ClipY);
	C.SetOrigin(OrgX, OrgY);
	return;
}

//R6CODE
// DrawSimpleBorder: draws a four-sided border frame using a single tiling texture region.
// Renders four strips (top, bottom, left, right) using m_BorderTexture/m_BorderTextureRegion.
// The left and right strips are inset top and bottom by the border height to avoid
// overdrawing the corners twice.  m_BorderStyle (cast to ERenderStyle) controls blending.
function DrawSimpleBorder(Canvas C)
{
	C.Style = byte(m_BorderStyle);
	C.SetDrawColor(m_BorderColor.R, m_BorderColor.G, m_BorderColor.B);
	// Top strip: full width, border texture height.
	DrawStretchedTextureSegment(C, 0.0000000, 0.0000000, WinWidth, float(m_BorderTextureRegion.H), float(m_BorderTextureRegion.X), float(m_BorderTextureRegion.Y), float(m_BorderTextureRegion.W), float(m_BorderTextureRegion.H), m_BorderTexture);
	// Bottom strip: offset up by border height so it sits flush at the bottom.
	DrawStretchedTextureSegment(C, 0.0000000, (WinHeight - float(m_BorderTextureRegion.H)), WinWidth, float(m_BorderTextureRegion.H), float(m_BorderTextureRegion.X), float(m_BorderTextureRegion.Y), float(m_BorderTextureRegion.W), float(m_BorderTextureRegion.H), m_BorderTexture);
	// Left strip: inset top/bottom by border height to avoid corner overlap.
	DrawStretchedTextureSegment(C, 0.0000000, float(m_BorderTextureRegion.H), float(m_BorderTextureRegion.W), (WinHeight - float((2 * m_BorderTextureRegion.H))), float(m_BorderTextureRegion.X), float(m_BorderTextureRegion.Y), float(m_BorderTextureRegion.W), float(m_BorderTextureRegion.H), m_BorderTexture);
	// Right strip: mirror of left strip, offset right by (WinWidth - border width).
	DrawStretchedTextureSegment(C, (WinWidth - float(m_BorderTextureRegion.W)), float(m_BorderTextureRegion.H), float(m_BorderTextureRegion.W), (WinHeight - float((2 * m_BorderTextureRegion.H))), float(m_BorderTextureRegion.X), float(m_BorderTextureRegion.Y), float(m_BorderTextureRegion.W), float(m_BorderTextureRegion.H), m_BorderTexture);
	return;
}

// DrawSimpleBackGround: fills a rectangle with a solid-color alpha-blended background.
// Samples an 8x8 solid-fill patch from the Gui_BoxScroll atlas at offset (77,31).
// That patch is used purely to enable alpha blending via the DrawTile path; the color
// comes from SetDrawColor.  C.Style = 5 = ERenderStyle.STY_Alpha.
function DrawSimpleBackGround(Canvas C, float X, float Y, float W, float H, Color _BGColor, optional byte Alpha)
{
	local Texture BGTexture;
	local Region BGTextureRegion;
	local Color BGColor;

	BGTexture = Texture'R6MenuTextures.Gui_BoxScroll';
	// (77, 31) is a known 8x8 solid-fill area within the Gui_BoxScroll texture atlas.
	BGTextureRegion.X = 77;
	BGTextureRegion.Y = 31;
	BGTextureRegion.W = 8;  // 8x8 source region tiled/stretched to fill W x H destination
	BGTextureRegion.H = 8;
	C.Style = 5;  // ERenderStyle.STY_Alpha: enables per-pixel alpha blending
	C.SetDrawColor(_BGColor.R, _BGColor.G, _BGColor.B, Alpha);
	DrawStretchedTextureSegment(C, X, Y, W, H, float(BGTextureRegion.X), float(BGTextureRegion.Y), float(BGTextureRegion.W), float(BGTextureRegion.H), BGTexture);
	return;
}

// ClipText: draws string S at (X,Y) in window-local logical pixels, clipped to ClippingRegion.
// bCheckHotKey=true renders "&X" with an underline (Windows-style accelerator key hint).
// Delegates to native C++ which handles GUIScale and clipping.
final function ClipText(Canvas C, float X, float Y, coerce string S, optional bool bCheckHotKey)
{
	C.ClipTextNative(X, Y, S, Root.GUIScale, ClippingRegion, bCheckHotKey);
	return;
}

// WrapClipText: word-wraps string S into WinWidth, drawing each line via ClipText.
// Returns the number of lines rendered.  bNoDraw=true does a dry-run measure without drawing.
// Length > 0: use only the first Length characters of S per line.
// PaddingLength > 0: account for a PaddingLength-character suffix when deciding line breaks.
// Word boundaries are detected at spaces and Chr(13).  "\\n" escape sequences in the string
// are pre-converted to Chr(13) before processing.
// bSentry is the loop guard: set to false when the output string is exhausted.
final function int WrapClipText(Canvas C, float X, float Y, coerce string S, optional bool bCheckHotKey, optional int Length, optional int PaddingLength, optional bool bNoDraw)
{
	local float W, H, Xdefault;
	local int SpacePos, CRPos, WordPos, TotalPos;
	local string Out, temp, Padding;
	local bool bCR, bSentry;
	local int i, numLines;
	local float pW, pH;

	Xdefault = X;
	// Pre-process: convert "\\n" escape sequences to actual carriage return (Chr(13)).
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
		// CR takes priority over space as word boundary when it comes first.
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

// ClipTextWidth: draws S clipped to width W (logical pixels), respecting ClippingRegion.
// Useful for labels that must not overflow a fixed column — text is simply cut off at W.
// finalWidth = min(W, WinWidth*GUIScale) prevents clipping from exceeding the window bounds.
final function ClipTextWidth(Canvas C, float X, float Y, coerce string S, float W)
{
	local float OrgX, OrgY, ClipX, ClipY, finalWidth;

	OrgX = C.OrgX;
	OrgY = C.OrgY;
	ClipX = C.ClipX;
	ClipY = C.ClipY;
	// Clamp to window width in screen pixels so we never set a wider clip than the window.
	finalWidth = float(Min(int(W), int((WinWidth * Root.GUIScale))));
	C.SetOrigin((OrgX + (float(ClippingRegion.X) * Root.GUIScale)), (OrgY + (float(ClippingRegion.Y) * Root.GUIScale)));
	C.SetClip(finalWidth, (float(ClippingRegion.H) * Root.GUIScale));
	C.SetPos(((X - float(ClippingRegion.X)) * Root.GUIScale), ((Y - float(ClippingRegion.Y)) * Root.GUIScale));
	C.DrawTextClipped(S, false);
	C.SetClip(ClipX, ClipY);
	C.SetOrigin(OrgX, OrgY);
	return;
}

// DrawUpBevel: draws a nine-patch (9-slice) beveled rectangle from LookAndFeel regions.
// The nine pieces are: TL, T, TR (top row), L, Area, R (middle row), BL, B, BR (bottom row).
// Edges are stretched to fill the space between the fixed-size corner pieces.
// Used for raised-button and panel backgrounds in the Win95LookAndFeel theme.
final function DrawUpBevel(Canvas C, float X, float Y, float W, float H, Texture t)
{
	local Region R;

	R = LookAndFeel.BevelUpTL;  // top-left corner
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

// DrawMiscBevel: simplified bevel that only draws the center fill area (MiscBevelArea).
// All border/corner draws are commented out in both retail and SDK 1.56 source.
// BevelType selects between multiple bevel style slots defined in LookAndFeel.
// C.Style = 5 = STY_Alpha.  Color (31, 34, 39) = very dark blue-grey panel fill tone.
final function DrawMiscBevel(Canvas C, float X, float Y, float W, float H, Texture t, int BevelType)
{
	local Region R;

	C.Style = 5;  // ERenderStyle.STY_Alpha
	C.SetDrawColor(31, 34, 39);  // dark blue-grey: R6's standard panel interior colour
	R = LookAndFeel.MiscBevelArea[BevelType];
	DrawStretchedTextureSegment(C, (X + float(LookAndFeel.MiscBevelTL[BevelType].W)), (Y + float(LookAndFeel.MiscBevelTL[BevelType].H)), ((W - float(LookAndFeel.MiscBevelBL[BevelType].W)) - float(LookAndFeel.MiscBevelBR[BevelType].W)), ((H - float(LookAndFeel.MiscBevelTL[BevelType].H)) - float(LookAndFeel.MiscBevelBL[BevelType].H)), float(R.X), float(R.Y), float(R.W), float(R.H), t);
	return;
}

// RemoveAmpersand: strips "&X" hotkey markers from a display string (e.g. "&File" → "File").
// Used when you want the clean label text without the accelerator underline.
final function string RemoveAmpersand(string S)
{
	local string Result, Underline;

	ParseAmpersand(S, Result, Underline, false);
	return Result;
	return;
}

// ParseAmpersand: parses Windows-style "&X" hotkey notation in UI label strings.
// Rules: "&&" → literal "&" in Result; "&X" → X stripped from Result, hotkey recorded.
// Returns the ASCII code of the first hotkey character found (0 if none).
// bCalcUnderline=true fills Underline with spaces and "_" to mark the hotkey position.
// This mirrors how Win32 DrawText(DT_NOPREFIX) / menu accelerator parsing works.
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

// MouseIsOver: returns true if the mouse is currently directly over this window.
// Root.MouseWindow is updated every frame by FindWindowUnder(), so this is always current.
final function bool MouseIsOver()
{
	return (Root.MouseWindow == self);
	return;
}

// ToolTip: bubbles the tooltip string up the parent chain until Root handles it.
// UWindowRootWindow overrides this to actually display the tooltip overlay on screen.
// Pass an empty string to dismiss the current tooltip.
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
// SetMouseWindow: forces all mouse events to this window, bypassing normal hit-testing.
// Use for drag operations where you need to track the mouse even when it leaves the window.
final function SetMouseWindow()
{
	Root.MouseWindow = self;
	return;
}

// GetLookAndFeelTexture: returns the texture atlas for the current L&F theme.
// Delegates up to Root which returns the actual theme texture.
// All bevel/border drawing functions use this as their source texture.
function Texture GetLookAndFeelTexture()
{
	return ParentWindow.GetLookAndFeelTexture();
	return;
}

// IsActive: returns true if this window is in the currently active branch of the hierarchy.
// Delegates up to Root which returns whether UWindow itself is currently active.
function bool IsActive()
{
	return ParentWindow.IsActive();
	return;
}

// SetAcceptsHotKeys: enables/disables global hotkey delivery for this window.
// Hotkey windows receive HotKeyDown/HotKeyUp from Root even without keyboard focus.
// Only registers/unregisters with Root if visibility state is correct to avoid stale entries.
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

// GetParent: walks up the parent chain and returns the first ancestor matching ParentClass.
// bExactClass=true: requires an exact class match (no subclasses).
// bExactClass=false (default): accepts any subclass of ParentClass.
// Returns None if no match is found before reaching Root.
// Commonly used to find the enclosing UWindowFramedWindow for modal dialog attachment.
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

// FindChildWindow: recursively searches this window's subtree for a window of ChildClass.
// Scans the sibling list from topmost to bottommost, then recurses into each child.
// bExactClass=true: exact match only; false: accepts any subclass (default).
// Returns None if no match found. Used by CreateWindow(bUnique) and GetButtonsDefinesUnique.
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

// GetDesiredDimensions: returns the bounding box of all children as a layout hint.
// Override to report the minimum size this window needs to display its content.
// Default implementation returns the max W and H across all children (recursive).
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

// TextSize: measures how many logical pixels the given text would occupy with the current font.
// Wraps Canvas.TextSize and divides the result by GUIScale to convert screen → logical pixels.
// _TotalWidth and _SpaceWidth are optional canvas-level formatting hints.
// Returns the raw canvas TextSize result string (usually empty; return value rarely used).
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

// ResolutionChanged: notified when the viewport resolution changes (W x H are new dims).
// Propagates the notification recursively to all children so each can reposition itself.
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

// ShowModal: shows window W as a modal child of this window.
// Stores W in ModalWindow so WaitModal() will block other interactions until W is closed.
function ShowModal(UWindowWindow W)
{
	ModalWindow = W;
	W.ShowWindow();
	W.BringToFront();
	return;
}

// WaitModal: returns true if a modal child window is currently visible, blocking interaction.
// Also clears ModalWindow if the modal window was closed (no longer visible).
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

// WindowHidden: recursive notification fired when this window becomes invisible.
// Called by HideWindow() BEFORE the parent removes this window from the sibling list,
// so children can do cleanup while still part of the active hierarchy.
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

// WindowShown: recursive notification fired when this window becomes visible.
// Called by ShowWindow() AFTER the parent adds this window to the sibling list.
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
// CheckMousePassThrough: override to create transparent / hit-test-invisible regions.
// Return true to allow mouse events to fall through to whatever window is behind this one.
// Used for windows with non-rectangular visible areas (e.g. irregular alpha shapes).
function bool CheckMousePassThrough(float X, float Y)
{
	return false;
	return;
}

// WindowIsVisible: returns true only if this window AND all ancestors are visible.
// Root is always considered visible (it is never in a sibling list).
// Walks up the parent chain — the first invisible ancestor short-circuits to false.
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

// SetParent: reparents this window to NewParent by doing a hide/show cycle.
// HideWindow removes from the old parent's sibling list; ShowWindow adds to the new one.
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
// MessageBoxDone: callback invoked when the user dismisses a MessageBox created by this window.
// Override to react to the dialog result (e.g. Yes/No/Cancel buttons).
function MessageBoxDone(UWindowMessageBox W, UWindowBase.MessageBoxResult Result)
{
	return;
}

// PopUpBoxDone: callback for pop-up dialogs identified by ePopUpID.
// R6-specific variant of MessageBoxDone for distinguishing multiple pop-up types.
function PopUpBoxDone(UWindowBase.MessageBoxResult Result, UWindowBase.EPopUpID _ePopUpID)
{
	return;
}

// SendMessage: broadcasts an R6-specific widget message up the hierarchy.
// Used to propagate Ubi.com auth and server-query results from leaf widgets to top-level menus.
function SendMessage(UWindowWindow.eR6MenuWidgetMessage eMessage)
{
	return;
}

// NotifyQuitUnreal: broadcast when the engine is about to exit.
// Override to flush saves, close network connections, or free resources before shutdown.
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

// NotifyBeforeLevelChange: broadcast just before a level transition begins.
// Override to hide UI or save state before the old level's objects are destroyed.
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

// NotifyAfterLevelChange: broadcast after a level transition completes.
// Override to refresh UI content that depends on the new level's game state.
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

// NotifyWindow: called on a parent window when a child widget fires a DE_* dialog event.
// C = the child window that fired the event; E = the DE_* event code.
// Override in container windows to react to child widget interactions (button clicks, etc.).
function NotifyWindow(UWindowWindow C, byte E)
{
	return;
}

// SetCursor: sets this window's cursor and recursively propagates it to all children.
// Children inherit their parent's cursor on creation (via CreateWindow), but this
// allows a runtime cursor change to cascade through the whole subtree.
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

// ReplaceText: replaces all occurrences of Replace with With in Text (in-place via out).
// Iterates until no more occurrences are found; safer than a single InStr/Mid pass.
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

// StripCRLF: removes all carriage-return and line-feed characters from Text.
// Handles Windows (CR+LF), classic Mac (CR), and Unix (LF) line endings.
function StripCRLF(out string Text)
{
	ReplaceText(Text, (Chr(13) $ Chr(10)), "");
	ReplaceText(Text, Chr(13), "");
	ReplaceText(Text, Chr(10), "");
	return;
}

// SetServerOptions: R6 extension — override to push server config into game state.
// Access to the console is needed here, hence placement in UWindowWindow rather than a child.
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

// ProcessGSMsg: R6 1.60 addition — handles a GameSpy message string passed to the UI.
// Override in menu screens that need to react to GameSpy backend events.
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
