//=============================================================================
// UWindowRootWindow - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
// UWindowRootWindow - the root window.
//=============================================================================
// This is the "desktop" of the UWindow GUI system. Every other window is a
// descendant of this one. It owns global state: mouse position, keyboard
// focus, cursor objects, the LookAndFeel theming object, and the hotkey
// window list. The Console actor creates an instance of this class (or a
// subclass such as R6RootWindow) at startup and drives it each frame.
//=============================================================================
class UWindowRootWindow extends UWindowWindow
    config;

// Identifies which subclass of UWindowRootWindow is actually in use.
// Subclasses (R6Menu, R6MenuInGame, etc.) override the stub virtual
// functions below to provide game-specific menu logic.
enum eRootID
{
	RootID_UWindow,                 // 0
	RootID_R6Menu,                  // 1
	RootID_R6MenuInGame,            // 2
	RootID_R6MenuInGameMulti        // 3
};

// Tracks which top-level "widget" (full-screen UI panel) is currently active.
// R6Console uses this to know what menu context is displayed, e.g. to route
// key presses correctly or to decide what to show after a level transition.
// Mainly exists so C++ code (R6Console) can query and change the current widget
// without needing a direct pointer to the concrete menu class.
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
var UWindowRootWindow.eRootID m_eRootId;                          // Which root subclass is active (set in Created())
var UWindowRootWindow.eGameWidgetID m_eCurWidgetInUse;            // Current widget ID display on screen
var UWindowRootWindow.eGameWidgetID m_ePrevWidgetInUse;           // Previous widget ID display on screen
var bool bMouseCapture;    // When true all mouse events are locked to MouseWindow regardless of position
var bool bRequestQuit;     // Set by QuitGame(); deferred so sockets/systems have time to shut down
var bool bAllowConsole;    // Whether the tilde (~) console key is permitted while this UI is open
//R6Code
var bool m_bUseAimIcon;          // Planning mode: show the aim crosshair cursor instead of NormalCursor
var bool m_bUseDragIcon;         // Planning mode: show the drag/hand cursor (waypoint dragging)
var bool m_bScaleWindowToRoot;   // Subwindows should scale themselves to match root dimensions
var bool m_bWidgetResolutionFix;  // this is set in root by a widget to tell to the options if resolution is fix or not
// Current mouse position in logical (unscaled) UI coordinates
var float MouseX;
// NEW IN 1.60
var float MouseY;
// Previous frame mouse position; used to avoid redundant MouseMove events
var float OldMouseX;
// NEW IN 1.60
var float OldMouseY;
//var config float		GUIScale;
var float GUIScale;  // Alex- This is to prevent set res call to ovewrite this value in config file
// Physical pixel dimensions of the viewport; SetScale divides these by GUIScale to get WinWidth/WinHeight
var float RealWidth;
// NEW IN 1.60
var float RealHeight;
var float QuitTime;          // Accumulates delta time after bRequestQuit; exits after 0.25 s grace period
var float m_fWindowScaleX;   // Per-axis scale factors for windows that opt in to m_bScaleWindowToRoot
// NEW IN 1.60
var float m_fWindowScaleY;
var UWindowWindow MouseWindow;  // The window the mouse is over
var WindowConsole Console;      // The engine console that owns this root and drives the paint/input loop
var UWindowWindow FocusedWindow;    // Currently focused (active) window for input purposes
var UWindowWindow KeyFocusWindow;  // window with keyboard focus
// Linked list of windows that receive hotkey notifications globally, regardless of focus.
// Windows register with AddHotkeyWindow to intercept keys even when they don't have focus.
var UWindowHotkeyWindowList HotkeyWindows;
// Font table indexed by the F_* constants defined in UWindowBase.
// Index 0..29; only a subset are assigned — see SetupFonts(). Max 30 entries.
var Font Fonts[30];
// Cache of instantiated LookAndFeel objects. At most 20 simultaneous themes
// can exist; GetLookAndFeel() lazily creates and caches them here.
var UWindowLookAndFeel LooksAndFeels[20];
var R6GameColors Colors;                      // Shared palette of R6-specific UI colours
var UWindowMenuClassDefines MenuClassDefines; // Lookup table mapping widget class names to classes
// NEW IN 1.60
var UWindowWindow m_NotifyMsgWindow; // Single window registered to receive GameSpy network messages
// Cursor objects bundle a software-rendered texture, a hot-spot offset (the
// pixel within the image that maps to the actual pointer tip), and a Windows
// IDC_* cursor handle for when hardware cursor rendering is available.
var MouseCursor NormalCursor;   // Default arrow — hot-spot at top-left (0,0)
// NEW IN 1.60
var MouseCursor MoveCursor;     // Four-directional move arrow — hot-spot centred (8,8)
// NEW IN 1.60
var MouseCursor DiagCursor1;    // NW-SE diagonal resize — hot-spot centred (8,8)
// NEW IN 1.60
var MouseCursor HandCursor;     // Pointer/hand — hot-spot near fingertip (11,1)
// NEW IN 1.60
var MouseCursor HSplitCursor;   // Horizontal splitter — hot-spot centred (9,9)
// NEW IN 1.60
var MouseCursor VSplitCursor;   // Vertical splitter — hot-spot centred (9,9)
// NEW IN 1.60
var MouseCursor DiagCursor2;    // NE-SW diagonal resize — hot-spot centred (7,7)
// NEW IN 1.60
var MouseCursor NSCursor;       // North-South resize — hot-spot left-centre (3,7)
// NEW IN 1.60
var MouseCursor WECursor;       // West-East resize — hot-spot centre-top (7,3)
// NEW IN 1.60
var MouseCursor WaitCursor;     // Hourglass/busy — uses WECursor slot due to retail bug (see Created())
var MouseCursor AimCursor;      // R6 planning: aim icon for placing aim markers
var MouseCursor DragCursor;     // R6 planning: drag icon for moving waypoints
var config string LookAndFeelClass; // Fully-qualified class name of the active LookAndFeel, saved to .ini

// -----------------------------------------------------------------------
// Virtual stubs — overridden by R6RootWindow and its subclasses.
// Defined here so any code holding a UWindowRootWindow reference can call
// them without needing to know the concrete subclass.
// -----------------------------------------------------------------------

// Switch the currently active full-screen widget to widgetID.
// Implementations animate out the old widget and animate in the new one.
function ChangeCurrentWidget(UWindowRootWindow.eGameWidgetID widgetID)
{
	return;
}

// Tear down and rebuild menu state, e.g. after a disconnect or connection failure.
function ResetMenus(optional bool _bConnectionFailed)
{
	return;
}

// Notify menus that some game state has changed (iWhatToUpdate is a bitmask).
function UpdateMenus(int iWhatToUpdate)
{
	return;
}

// Show or hide a training instruction overlay for a given paragraph of a box.
function ChangeInstructionWidget(Actor pISV, bool bShow, int iBox, int iParagraph)
{
	return;
}

// Exit the in-game planning/play preview mode and return to the planning screen.
function StopPlayMode()
{
	return;
}

// Returns true if the planning widget should process keyboard input this frame.
function bool PlanningShouldProcessKey()
{
	return;
}

// Returns true if the planning widget should draw operative path overlays.
function bool PlanningShouldDrawPath()
{
	return;
}

// Returns the EPopUpID of the currently displayed simple pop-up dialog, or
// EPopUpID_None if no pop-up is active.
function UWindowBase.EPopUpID GetSimplePopUpID()
{
	return;
}

// Display a generic modal pop-up dialog with a title, body text, and buttons.
// _iButtonsType selects the button set (OK, OK/Cancel, etc.).
// bAddDisableDlg adds a "don't show again" checkbox.
function SimplePopUp(string _szTitle, string _szText, UWindowBase.EPopUpID _ePopUpID, optional int _iButtonsType, optional bool bAddDisableDlg, optional UWindowWindow OwnerWindow)
{
	return;
}

// Replace the body text lines of the currently displayed pop-up dialog.
function ModifyPopUpInsideText(array<string> _ANewText)
{
	return;
}

// Look up the localised display name for a map. Returns true on success and
// sets _szMapNameLoc. If _bReturnInitName is true, returns the raw map name
// when no localisation is found instead of an empty string.
function bool GetMapNameLocalisation(string _szMapName, out string _szMapNameLoc, optional bool _bReturnInitName)
{
	return;
}

// Bootstrap the root window. Called by the engine before Created().
// The root window is self-referential: Root points back to itself so that
// all child windows can reach the root via their own Root variable.
// MouseWindow and KeyFocusWindow start pointing at self (the desktop
// "catches" all input until a child claims it).
function BeginPlay()
{
	Root = self;
	MouseWindow = self;
	KeyFocusWindow = self;
	return;
}

// Lazy-init cache for LookAndFeel instances.
// LookAndFeel objects are expensive to recreate — this returns an existing
// one if the class already has an entry in the LooksAndFeels[] cache.
// Up to 20 simultaneous themes are supported; a Log warning fires if the
// cache is exhausted (would only happen with extremely unusual mod setups).
function UWindowLookAndFeel GetLookAndFeel(string LFClassName)
{
	local int i;
	local Class<UWindowLookAndFeel> LFClass;

	LFClass = Class<UWindowLookAndFeel>(DynamicLoadObject(LFClassName, Class'Core.Class'));
	i = 0;
	J0x22:

	// End:0xA9 [Loop If]
	if((i < 20)) // iterate over the fixed-size LooksAndFeels cache
	{
		// End:0x75
		if((LooksAndFeels[i] == none)) // empty slot: instantiate and cache here
		{
			LooksAndFeels[i] = new LFClass;
			LooksAndFeels[i].Setup(); // allows the LookAndFeel to load its textures/resources
			return LooksAndFeels[i];
		}
		// End:0x9F
		if((LooksAndFeels[i].Class == LFClass)) // already cached: return existing instance
		{
			return LooksAndFeels[i];
		}
		(i++);
		// [Loop Continue]
		goto J0x22;
	}
	Log("Out of LookAndFeel array space!!");
	return none;
	return;
}

// One-time initialisation called after BeginPlay().
// Sets up the LookAndFeel theme, fonts, all cursor objects, shared colour
// palette, menu class registry, and the hotkey window linked list sentinel.
function Created()
{
	m_eRootId = 0; // default to RootID_UWindow; subclasses overwrite this
	LookAndFeel = GetLookAndFeel(LookAndFeelClass);
	SetupFonts();

	// -----------------------------------------------------------------------
	// Cursor setup. Each cursor has:
	//   Tex           — the software-rendered cursor texture (drawn when
	//                   bWindowsMouseAvailable is false)
	//   HotX / HotY  — pixel offset from the texture's top-left to the
	//                   precise "click point"; the renderer subtracts these
	//                   so the hot spot lands exactly at MouseX,MouseY
	//   WindowsCursor — index into the viewport's IDC_* table for when
	//                   the engine delegates cursor rendering to Windows.
	//                   0=IDC_ARROW, 1=IDC_SIZEALL, 2=IDC_SIZENESW,
	//                   3=IDC_SIZENS, 4=IDC_SIZENWSE, 5=IDC_SIZEWE, 6=IDC_WAIT
	// -----------------------------------------------------------------------
	NormalCursor.Tex = Texture'R6MenuTextures.MouseCursor';
	NormalCursor.HotX = 0; // arrow tip is at the very top-left of the image
	NormalCursor.HotY = 0;
	NormalCursor.WindowsCursor = Console.ViewportOwner.0; // IDC_ARROW
	MoveCursor.Tex = Texture'UWindow.Icons.MouseMove';
	MoveCursor.HotX = 8; // centred on 16x16 texture
	MoveCursor.HotY = 8;
	MoveCursor.WindowsCursor = Console.ViewportOwner.1; // IDC_SIZEALL
	DiagCursor1.Tex = Texture'UWindow.Icons.MouseDiag1';
	DiagCursor1.HotX = 8;
	DiagCursor1.HotY = 8;
	DiagCursor1.WindowsCursor = Console.ViewportOwner.4; // IDC_SIZENWSE
	HandCursor.Tex = Texture'UWindow.Icons.MouseHand';
	HandCursor.HotX = 11; // fingertip is near the upper-right of the hand image
	HandCursor.HotY = 1;
	HandCursor.WindowsCursor = Console.ViewportOwner.0; // IDC_ARROW (no Win hand cursor in engine)
	HSplitCursor.Tex = Texture'UWindow.Icons.MouseHSplit';
	HSplitCursor.HotX = 9;
	HSplitCursor.HotY = 9;
	HSplitCursor.WindowsCursor = Console.ViewportOwner.5; // IDC_SIZEWE
	VSplitCursor.Tex = Texture'UWindow.Icons.MouseVSplit';
	VSplitCursor.HotX = 9;
	VSplitCursor.HotY = 9;
	VSplitCursor.WindowsCursor = Console.ViewportOwner.3; // IDC_SIZENS
	DiagCursor2.Tex = Texture'UWindow.Icons.MouseDiag2';
	DiagCursor2.HotX = 7;
	DiagCursor2.HotY = 7;
	DiagCursor2.WindowsCursor = Console.ViewportOwner.2; // IDC_SIZENESW
	NSCursor.Tex = Texture'UWindow.Icons.MouseNS';
	NSCursor.HotX = 3;
	NSCursor.HotY = 7;
	NSCursor.WindowsCursor = Console.ViewportOwner.3; // IDC_SIZENS
	WECursor.Tex = Texture'UWindow.Icons.MouseWE';
	WECursor.HotX = 7;
	WECursor.HotY = 3;
	WECursor.WindowsCursor = Console.ViewportOwner.5; // IDC_SIZEWE
	// RETAIL BUG: WaitCursor.Tex is set but the subsequent HotX/HotY/WindowsCursor
	// lines accidentally target WECursor instead of WaitCursor, so WaitCursor ends
	// up with no hot-spot and no Windows cursor assigned. The SDK (1.56) has the
	// same bug in a commented-out block; it appears to have never been fixed.
	WaitCursor.Tex = Texture'R6MenuTextures.MouseWait';
	WECursor.HotX = 6; // mistakenly modifies WECursor
	WECursor.HotY = 9;
	WECursor.WindowsCursor = Console.ViewportOwner.6; // IDC_WAIT — also on WECursor
	// R6-specific planning cursors — no WindowsCursor because the planning view
	// always uses the software rendering path for these specialised icons.
	AimCursor.Tex = Texture'R6Planning.Cursors.PlanCursor_Aim';
	AimCursor.HotX = 16; // aim reticle is centred on a 32x32 texture
	AimCursor.HotY = 16;
	DragCursor.Tex = Texture'R6Planning.Cursors.PlanCursor_Drag';
	DragCursor.HotX = 5;
	DragCursor.HotY = 5;
	Colors = new (none) Class'Engine.R6GameColors';
	MenuClassDefines = new (none) Class'UWindow.UWindowMenuClassDefines';
	MenuClassDefines.Created();
	// Initialise the hotkey window list as a circular sentinel list.
	// HotkeyWindows itself is the sentinel (head); real entries are inserted
	// between Sentinel and its Next. Sentinel.Next == None means the list is empty.
	HotkeyWindows = new Class'UWindow.UWindowHotkeyWindowList';
	HotkeyWindows.Last = HotkeyWindows;
	HotkeyWindows.Next = none;
	HotkeyWindows.Sentinel = HotkeyWindows;
	Cursor = NormalCursor; // start with the normal arrow cursor
	return;
}

// Called every frame by the Console with the current physical pixel
// mouse position. Handles:
//  1. Mouse focus routing — finds which child window the pointer is over
//     (unless captured), fires MouseLeave/MouseEnter if the window changed.
//  2. MouseMove dispatch — only fires when the position actually changes,
//     delivering coordinates that are local to the receiving window.
// bMouseCapture locks input to the current MouseWindow so that drag
// operations continue to receive events even if the cursor leaves the window.
function MoveMouse(float X, float Y)
{
	local UWindowWindow NewMouseWindow;
	local float tX, tY;

	MouseX = X; // store in root for any code that needs raw root-space coords
	MouseY = Y;
	// End:0x3A
	if((!bMouseCapture))
	{
		// Walk the child window tree to find the topmost window under (X,Y).
		// FindWindowUnder does a depth-first search and returns the deepest
		// visible, hit-testable window at that position.
		NewMouseWindow = FindWindowUnder(X, Y);		
	}
	else
	{
		// Mouse is captured: keep sending events to the same window even if
		// the cursor has moved outside it (e.g. drag-scrolling a list).
		NewMouseWindow = MouseWindow;
	}
	// End:0x7D
	if((NewMouseWindow != MouseWindow)) // focus changed: notify both windows
	{
		MouseWindow.MouseLeave();        // old window loses hover state
		NewMouseWindow.MouseEnter();     // new window gains hover state
		MouseWindow = NewMouseWindow;
	}
	// End:0xE5
	if(((MouseX != OldMouseX) || (MouseY != OldMouseY))) // skip if mouse didn't actually move
	{
		OldMouseX = MouseX;
		OldMouseY = MouseY;
		// GetMouseXY transforms root-space (X,Y) into the window's local
		// coordinate space, accounting for the window's position in the
		// hierarchy. This is the coordinate transform: screen → window-local.
		MouseWindow.GetMouseXY(tX, tY);
		MouseWindow.MouseMove(tX, tY);
	}
	return;
}

// Render the mouse cursor onto the canvas at the end of the frame.
// Two paths:
//  - Hardware cursor (bWindowsMouseAvailable): just tell the viewport which
//    Win32 IDC_* cursor to show; Windows composites it outside our render pass.
//  - Software cursor: draw the cursor texture directly onto the canvas.
//    Position = MouseX * GUIScale − HotX
//    The GUIScale multiply converts from logical GUI coordinates back to
//    physical pixel coordinates, and the HotX/HotY subtraction shifts the
//    image so the precise click-point (hot spot) lands at the pointer tip.
function DrawMouse(Canvas C)
{
	local float X, Y;

	// End:0x49
	if(Console.ViewportOwner.bWindowsMouseAvailable)
	{
		// Hardware path: set the Win32 cursor type; no canvas work needed.
		Console.ViewportOwner.SelectedCursor = MouseWindow.Cursor.WindowsCursor;		
	}
	else
	{
		// Software path: paint the cursor texture onto the canvas.
		C.SetDrawColor(byte(255), byte(255), byte(255)); // draw at full white (no tint)
		// Scale logical position back to physical pixels, offset by hot-spot.
		C.SetPos(((MouseX * GUIScale) - float(MouseWindow.Cursor.HotX)), ((MouseY * GUIScale) - float(MouseWindow.Cursor.HotY)));
		C.DrawIcon(MouseWindow.Cursor.Tex, 1.0000000); // scale=1.0 keeps the texture at its natural size
	}
	return;
}

// If the mouse is currently captured, synthesise an LMouseUp at the
// current position in the capturing window's local coordinates, then
// release the capture. Returns true if capture was active (event consumed).
// Used when a mouse-up arrives but the engine needs to know whether to
// route it to the capture owner rather than the normal hit-test path.
function bool CheckCaptureMouseUp()
{
	local float X, Y;

	// End:0x45
	if(bMouseCapture)
	{
		MouseWindow.GetMouseXY(X, Y); // transform root-space to window-local
		MouseWindow.LMouseUp(X, Y);
		bMouseCapture = false;
		return true;
	}
	return false;
	return;
}

// Same as CheckCaptureMouseUp() but delivers an LMouseDown instead.
// Needed when a drag capture needs to repeat clicks (e.g. auto-scrolling).
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

// Immediately release mouse capture without delivering any mouse event.
// Called when a drag is aborted (e.g. window closed mid-drag).
function CancelCapture()
{
	bMouseCapture = false;
	return;
}

// Lock all mouse events to window W (or to the current MouseWindow if W is
// omitted). While captured, MoveMouse() skips hit-testing and routes
// everything to MouseWindow so drag operations remain continuous.
function CaptureMouse(optional UWindowWindow W)
{
	bMouseCapture = true;
	// End:0x1E
	if((W != none))
	{
		MouseWindow = W; // redirect capture to a specific window
	}
	return;
}

// Convenience accessor used by child windows to get the current LookAndFeel
// atlas texture without needing a direct reference to the LookAndFeel object.
function Texture GetLookAndFeelTexture()
{
	return LookAndFeel.Active;
	return;
}

// The root window is always considered "active" — it never has a parent
// that could deactivate it, so this always returns true.
function bool IsActive()
{
	return true;
	return;
}

// Register a window to receive hotkey notifications globally. Hotkey windows
// are polled before normal focus-based dispatch, so they can intercept keys
// even when a modal dialog has focus.
function AddHotkeyWindow(UWindowWindow W)
{
	UWindowHotkeyWindowList(HotkeyWindows.Insert(Class'UWindow.UWindowHotkeyWindowList')).Window = W;
	return;
}

// Unregister a window from the global hotkey list (e.g. when it is closed).
function RemoveHotkeyWindow(UWindowWindow W)
{
	local UWindowHotkeyWindowList L;

	L = HotkeyWindows.FindWindow(W);
	// End:0x34
	if((L != none))
	{
		L.Remove();
	}
	return;
}

// Returns true if window W is currently in the global hotkey list.
function bool IsAHotKeyWindow(UWindowWindow W)
{
	local UWindowHotkeyWindowList L;

	L = HotkeyWindows.FindWindow(W);
	// End:0x27
	if((L != none))
	{
		return true;
	}
	return false;
	return;
}

// Top-level event dispatcher for this root window.
// Key events are offered to all registered hotkey windows first; if none
// consume them the event falls through to the normal UWindowWindow handler
// which routes them to the focused child window.
// Mouse button events are likewise offered to hotkey windows so that
// global UI handlers (e.g. drag helpers) can intercept clicks.
// Numeric cases correspond to the WinMessage enum:
//   0 = WM_LMouseDown, 2 = WM_MMouseDown, 4 = WM_RMouseDown
//   8 = WM_KeyUp,      9 = WM_KeyDown
function WindowEvent(UWindowWindow.WinMessage Msg, Canvas C, float X, float Y, int Key)
{
	switch(Msg)
	{
		// End:0x29
		case 9: // WM_KeyDown — broadcast to hotkey windows first
			// End:0x26
			if(HotKeyDown(Key, X, Y))
			{
				return; // consumed by a hotkey window; don't propagate further
			}
			// End:0x7A
			break;
		// End:0x4B
		case 8: // WM_KeyUp — broadcast to hotkey windows first
			// End:0x48
			if(HotKeyUp(Key, X, Y))
			{
				return;
			}
			// End:0x7A
			break;
		// End:0x50
		case 0:  // WM_LMouseDown
		// End:0x55
		case 2:  // WM_MMouseDown
		// End:0x77
		case 4:  // WM_RMouseDown — mouse-up variants are intentionally excluded
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
	super.WindowEvent(Msg, C, X, Y, Key); // normal focus-based dispatch
	return;
}

// Broadcast a key-down event to every registered hotkey window (except the
// root itself). Returns true as soon as one window consumes the event, so
// only the first matching window receives it (first-registered wins).
function bool HotKeyDown(int Key, float X, float Y)
{
	local UWindowHotkeyWindowList L;

	// Skip the sentinel (HotkeyWindows itself) and start from the first real entry.
	L = UWindowHotkeyWindowList(HotkeyWindows.Next);
	J0x19:

	// End:0x82 [Loop If]
	if((L != none))
	{
		// End:0x66
		if(((L.Window != self) && L.Window.HotKeyDown(Key, X, Y))) // self-skip guards against re-entrancy
		{
			return true; // event consumed
		}
		L = UWindowHotkeyWindowList(L.Next);
		// [Loop Continue]
		goto J0x19;
	}
	return false; // no hotkey window consumed the event
	return;
}

// Same as HotKeyDown but for key-release events.
function bool HotKeyUp(int Key, float X, float Y)
{
	local UWindowHotkeyWindowList L;

	L = UWindowHotkeyWindowList(HotkeyWindows.Next);
	J0x19:

	// End:0x82 [Loop If]
	if((L != none))
	{
		// End:0x66
		if(((L.Window != self) && L.Window.HotKeyUp(Key, X, Y)))
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

// Broadcast a mouse button event (down only; ups are excluded in WindowEvent)
// to all registered hotkey windows. Allows global drag handlers to claim
// a click before normal focus dispatch.
function bool MouseUpDown(int Key, float X, float Y)
{
	local UWindowHotkeyWindowList L;

	L = UWindowHotkeyWindowList(HotkeyWindows.Next);
	J0x19:

	// End:0x82 [Loop If]
	if((L != none))
	{
		// End:0x66
		if(((L.Window != self) && L.Window.MouseUpDown(Key, X, Y)))
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

// Handle Escape / close-active-window requests.
// If a modal or active child window exists, let it close itself via EscClose()
// (which may animate out, save state, etc.). If there is no active window,
// close the entire UWindow layer and return control to the game.
function CloseActiveWindow()
{
	// End:0x1D
	if((ActiveWindow != none))
	{
		ActiveWindow.EscClose();		
	}
	else
	{
		Console.CloseUWindow(); // dismiss the UI overlay entirely
	}
	return;
}

// Called by the engine when the viewport is resized. Forwards to
// ResolutionChanged() so all child windows can reposition themselves.
function Resized()
{
	ResolutionChanged(WinWidth, WinHeight);
	return;
}

// Apply a GUI scale factor. The root's logical dimensions shrink by NewScale
// so that all coordinates remain in a consistent "virtual" space regardless
// of the physical resolution. Example: at 1280×1024 with scale=2.0 the GUI
// sees a 640×512 canvas — elements stay the same visual size on screen.
// After changing WinWidth/Height, SetupFonts() re-selects appropriately
// sized fonts and Resized() notifies all children.
function SetScale(float NewScale)
{
	WinWidth = (RealWidth / NewScale);   // logical width = physical / scale
	WinHeight = (RealHeight / NewScale);
	GUIScale = NewScale;
	// Reset clipping to the full logical canvas
	ClippingRegion.X = 0;
	ClippingRegion.Y = 0;
	ClippingRegion.W = int(WinWidth);
	ClippingRegion.H = int(WinHeight);
	SetupFonts();
	Resized();
	return;
}

// Directly set the root's logical dimensions without changing GUIScale.
// Used when the viewport resolution changes but the UI scale stays the same
// (e.g. windowed-mode resize).
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

// Populate the Fonts[] table with R6-specific typefaces.
// Indices correspond to named F_* constants defined in UWindowBase.
// Fonts[0] (F_Normal) is assigned last as a catch-all fallback — it must
// always be valid because many windows call Root.Fonts[F_Normal] without
// checking for None. Indices 1-3 and 13 are intentionally left unassigned
// (no corresponding F_* slot in the R6 font scheme).
function SetupFonts()
{
	Fonts[4]  = Font'R6Font.Rainbow6_36pt';  // F_MenuMainTitle  — large heading
	Fonts[5]  = Font'R6Font.Rainbow6_14pt';  // F_SmallTitle
	Fonts[6]  = Font'R6Font.Rainbow6_12pt';  // F_VerySmallTitle
	Fonts[7]  = Font'R6Font.Rainbow6_15pt';  // F_TabMainTitle
	Fonts[8]  = Font'R6Font.Rainbow6_15pt';  // F_PopUpTitle
	Fonts[9]  = Font'R6Font.OcraExt_14pt';   // F_IntelTitle    — monospace "intel" font
	Fonts[10] = Font'R6Font.Arial_10pt';     // F_ListItemSmall  — compact list items
	Fonts[11] = Font'R6Font.Rainbow6_14pt';  // F_ListItemBig
	Fonts[12] = Font'R6Font.Rainbow6_12pt';  // F_HelpWindow
	Fonts[14] = Font'R6Font.Rainbow6_36pt';  // F_FirstMenuButton — hero button
	Fonts[15] = Font'R6Font.Rainbow6_17pt';  // F_MainButton
	Fonts[16] = Font'R6Font.Rainbow6_17pt';  // F_PrincipalButton
	Fonts[17] = Font'R6Font.Rainbow6_12pt';  // F_CheckBoxButton
	// F_Normal assigned last; keeps everything working even if
	// resolution-specific font selection has not yet been implemented.
	Fonts[0]  = Font'R6Font.Rainbow6_12pt';  // F_Normal — generic fallback
	return;
}

// Persist the new theme class name to the config file, then trigger a full
// UWindow restart so the new LookAndFeel is applied cleanly from scratch.
function ChangeLookAndFeel(string NewLookAndFeel)
{
	LookAndFeelClass = NewLookAndFeel;
	SaveConfig();
	Console.ResetUWindow(); // tear down and recreate the entire window hierarchy
	return;
}

// Intentionally empty — the root window cannot be hidden.
// Child windows call HideWindow() on themselves; this override ensures the
// root never disappears even if some generic code reaches it.
function HideWindow()
{
	return;
}

// Push a new mouse position into the Console so that hardware cursor sync
// and any C++ mouse-position queries see the same coordinates as the UI.
function SetMousePos(float X, float Y)
{
	Console.MouseX = X;
	Console.MouseY = Y;
	return;
}

// Request a graceful game exit. Sets the deferred-quit flag and resets the
// grace-period timer. The actual exit is deferred to allow network sockets,
// save files, and other systems to finish their current operations before the
// process terminates. NotifyQuitUnreal() notifies the engine so it can begin
// its own shutdown sequence.
function QuitGame()
{
	bRequestQuit = true;
	QuitTime = 0.0000000;
	NotifyQuitUnreal();
	return;
}

// Execute the final exit: persist config and issue the "exit" console command.
// Only called after the 0.25 s grace period in Tick() has elapsed.
function DoQuitGame()
{
	SaveConfig();
	Console.ViewportOwner.Actor.ConsoleCommand("exit");
	return;
}

// Per-frame update. The deferred quit timer counts up so that the system has
// roughly 0.25 seconds to flush sockets and finish any pending operations
// before DoQuitGame() is called. Super.Tick() propagates the tick to all
// child windows.
function Tick(float Delta)
{
	// End:0x2A
	if(bRequestQuit)
	{
		// End:0x1E
		if((QuitTime > 0.2500000)) // 0.25 s grace period before hard exit
		{
			DoQuitGame();
		}
		(QuitTime += Delta);
	}
	super.Tick(Delta);
	return;
}

//ifdef R6CODE
// MPF Yannick
// Stub: switch the background image folder for menu MODS.
function SetNewMODS(string _szNewBkgFolder, optional bool _bForceRefresh)
{
	return;
}

// Stub: load a random background image from a folder.
function SetLoadRandomBackgroundImage(string _szFolder)
{
	return;
}

// Stub: paint a per-widget background behind a child window (override in subclass).
function PaintBackground(Canvas C, UWindowWindow _WidgetWindow)
{
	return;
}

//===================================================================
// DrawBackGroundEffect: draw a background fullscreen -- need for pop-up 
//===================================================================
// Fills the entire physical viewport with a solid colour, bypassing the
// window clipping/origin that would otherwise restrict drawing to the
// current window's bounds. Used to dim the scene behind modal pop-ups.
// The canvas state (origin and clip rectangle) is saved and restored so
// subsequent rendering is unaffected.
function DrawBackGroundEffect(Canvas C, Color _BGColor)
{
	local float OrgX, OrgY, ClipX, ClipY;

	// Save current canvas transform so we can restore it after drawing.
	OrgX = C.OrgX;
	OrgY = C.OrgY;
	ClipX = C.ClipX;
	ClipY = C.ClipY;
	// Override canvas to full physical screen coordinates, not the GUI virtual space.
	C.SetOrigin(0.0000000, 0.0000000);
	C.SetClip(float(C.SizeX), float(C.SizeY));
	C.SetDrawColor(_BGColor.R, _BGColor.G, _BGColor.B, _BGColor.A);
	C.SetPos(0.0000000, 0.0000000);
	// WhiteTexture is a 1×1 white pixel; tiling it 10×10 UVs across SizeX×SizeY
	// gives a solid fill at the chosen draw colour. The UV values (0,0,10,10)
	// don't matter visually since the texture is uniform white.
	C.DrawTile(Texture'UWindow.WhiteTexture', float(C.SizeX), float(C.SizeY), 0.0000000, 0.0000000, 10.0000000, 10.0000000);
	// Restore canvas transform for subsequent window rendering.
	C.SetClip(ClipX, ClipY);
	C.SetOrigin(OrgX, OrgY);
	return;
}

//===================================================================
// TrapKey: Menu trap the key
//===================================================================
// The root always returns true, meaning the menu system consumes every
// key/mouse event while the UI is open — nothing passes through to the game
// underneath. Individual child windows can selectively release keys by
// calling the Console or returning false from their own key handlers.
function bool TrapKey(bool _bIncludeMouseMove)
{
	return true;
	return;
}

// NEW IN 1.60
// Register a window to receive GameSpy (online service) message callbacks.
// Only one window can be registered at a time; later calls replace the previous
// registration. Typically set by the multiplayer lobby widget.
function RegisterMsgWindow(UWindowWindow _NotifyMsgWindow)
{
	m_NotifyMsgWindow = _NotifyMsgWindow;
	return;
}

// NEW IN 1.60
// Deregister the current GameSpy message receiver (e.g. when the lobby closes).
function UnRegisterMsgWindow()
{
	m_NotifyMsgWindow = none;
	return;
}

// NEW IN 1.60
// Forward an incoming GameSpy network message string to the registered
// receiver window. If no window is registered the message is silently dropped.
function ProcessGSMsg(string _szMsg)
{
	// End:0x1F
	if((m_NotifyMsgWindow != none))
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
