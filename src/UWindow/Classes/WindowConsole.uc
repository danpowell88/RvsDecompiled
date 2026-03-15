//=============================================================================
// WindowConsole - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
// WindowConsole - console replacer to implement UWindow UI System
//=============================================================================
// WindowConsole is the bridge between the Unreal Engine console subsystem and
// the UWindow widget layer. The Engine calls PostRender/KeyEvent/KeyType on
// this object every frame; we intercept those calls and forward them to Root
// (a UWindowRootWindow tree) instead of the raw console. It also owns the
// console state machine: three states drive rendering behaviour —
//   'Game'          — default; UWindow is invisible, normal gameplay
//   'UWindowCanPlay'— UWindow is visible but the player can still move
//   'UWindow'       — UWindow is visible and has full input focus
class WindowConsole extends Console
    config;

// MaxLines: capacity of the rolling message log ring-buffer (MsgText/MsgTick arrays)
const MaxLines = 64;
// TextMsgSize: maximum byte length of a single on-screen message string
const TextMsgSize = 128;

// Scrollback: how many lines the player has scrolled back in the console view
var int Scrollback;
// NEW IN 1.60
// numLines: total number of lines currently stored in the message ring-buffer
var int numLines;
// NEW IN 1.60
// TopLine: index of the oldest visible line in the ring-buffer
var int TopLine;
// NEW IN 1.60
// TextLines: number of lines that fit on-screen in the text display area
var int TextLines;
// ConsoleLines: number of lines currently shown in the slide-down console overlay
var int ConsoleLines;
// bNoStuff: suppresses console output when true (used during loading/transitions)
var bool bNoStuff;
// NEW IN 1.60
// bTyping: true while the player is entering text in the console input bar
var bool bTyping;
// bShowLog: debug flag — when true, verbose logging is emitted for all console events
var bool bShowLog;
// bCreatedRoot: guards against double-initialising the Root window tree
var bool bCreatedRoot;
// bShowConsole: persisted in config — whether the slide-down console overlay is visible
var config bool bShowConsole;
// bBlackout: blanks the screen during certain transitions (e.g. loading screens)
var bool bBlackout;
// bUWindowType: marks this console as UWindow-capable (used by engine introspection)
var bool bUWindowType;
// bUWindowActive: true when the UWindow layer is taking input focus
var bool bUWindowActive;
// bLocked: prevents the tilde/Escape keys from toggling UWindow (used by cinematics etc.)
var bool bLocked;
// bLevelChange: set true in NotifyLevelChange so NotifyAfterLevelChange can act once
var bool bLevelChange;
// MsgTime: accumulated age of the current on-screen message batch (seconds)
var float MsgTime;
// NEW IN 1.60
// MsgTickTime: time-step accumulator used to expire individual messages
var float MsgTickTime;
// MsgTick[64]: per-message expiry timestamp (seconds), parallel array to MsgText
var float MsgTick[64];
// OldClipX/OldClipY: previous frame's canvas dimensions — used to detect resolution changes
var float OldClipX;
var float OldClipY;
// MouseX/MouseY: current cursor position in GUIScale-adjusted logical pixels
var float MouseX;
var float MouseY;
// MouseScale: multiplier applied to raw axis deltas to get MouseX/Y movement speed
var config float MouseScale;
// Variables.
// Viewport: the engine viewport this console is attached to
var Viewport Viewport;
// Root: the root of the entire UWindow widget tree — every menu/HUD widget descends from here
var UWindowRootWindow Root;
// R6CODE
// ConsoleState: remembers which non-Typing state to return to after the console closes
var name ConsoleState;
// ConsoleClass: class used to instantiate the legacy console text window (not used in 1.60)
var Class<UWindowConsoleWindow> ConsoleClass;
// MsgText[64]: ring-buffer of the last 64 on-screen message strings
var string MsgText[64];
// RootWindow: config-driven class name for the root window; dynamically loaded at runtime
var() config string RootWindow;
// OldLevel: name of the previous level, used to detect when a map transition is complete
var string OldLevel;
var string szStoreIP;  // String used to store IP of host server

//function class<object> GetRestKitDescName(string WeaponNameTag);
// GetRestKitDescName: R6-specific stub replacing the original weapon-name query.
// The signature was changed from returning class<object> to void; nothing calls
// the return value in 1.60, so the body is a no-op.
function GetRestKitDescName(GameReplicationInfo _GRI, R6ServerInfo pServerOptions)
{
	return;
}

// ResetUWindow: tears down the entire UWindow tree and returns to the 'Game' state.
// Called on disconnect, main-menu exit, or whenever the UI needs a full reset.
// Closes Root (fires its Close chain), clears the reference, then delegates to
// CloseUWindow to restore the viewport's mouse/precaching flags.
function ResetUWindow()
{
	// End:0x28
	if(bShowLog)
	{
		Log("WindowConsole::ResetUWindow");
	}
	// End:0x42
	if((Root != none))
	{
		Root.Close();
	}
	Root = none;
	bCreatedRoot = false;
	bShowConsole = false;
	CloseUWindow();
	return;
}

// KeyEvent (global/default state): handles key presses before any UWindow state is active.
// Two keys are special here:
//   - The bound "Console" key (tilde by default): opens UWindow and shows the console overlay.
//   - Escape (key code 27): opens UWindow without the console overlay (e.g. pause menu).
// bLocked prevents either key from doing anything (used during cinematics / loading).
// Returns true to consume the event (stop the engine from processing it further).
function bool KeyEvent(Interactions.EInputKey Key, Interactions.EInputAction Action, float Delta)
{
	local byte k;

	k = Key;
	// End:0x57
	if(bShowLog)
	{
		Log(((("WindowConsole state \" KeyEvent eAction" @ string(Action)) @ "Key") @ string(Key)));
	}
	switch(Action)
	{
		// End:0xD8
		// Action 1 = IST_Press (key pressed down)
		case 1:
			// End:0xB3
			// Check whether the pressed key is the player's configured "Console" binding
			if((int(k) == int(ViewportOwner.Actor.GetKey("Console"))))
			{
				// End:0x9A
				if(bLocked)
				{
					return true;
				}
				LaunchUWindow();
				// End:0xB1
				if((!bShowConsole))
				{
					ShowConsole();
				}
				return true;
			}
			switch(k)
			{
				// End:0xD2
				// 27 = IK_Escape — open UWindow without showing the console text bar
				case 27:
					// End:0xCA
					if(bLocked)
					{
						return true;
					}
					LaunchUWindow();
					return true;
				// End:0xFFFF
				default:
					// End:0xDB
					break;
					break;
			}
		// End:0xFFFF
		default:
			return false;
			break;
	}
	return;
}

// ShowConsole: makes the slide-down console text overlay visible.
// In 1.60 this is a lightweight flag flip; the original SDK also showed the
// ConsoleWindow widget, but that was removed in R6 (see ORIGINAL UNREAL CONSOLE notes).
function ShowConsole()
{
	bShowConsole = true;
	return;
}

// HideConsole: hides the console overlay and resets the line count.
// Setting ConsoleLines = 0 collapses the overlay to zero height immediately.
function HideConsole()
{
	ConsoleLines = 0;
	bShowConsole = false;
	return;
}

// ToggleUWindow: stub retained for binary compatibility — toggling is handled
// by the individual state KeyEvent handlers in 1.60.
function ToggleUWindow()
{
	return;
}

// LaunchUWindow: activates the UWindow overlay and transitions the console state machine
// to 'UWindow'. Three things happen together:
//   1. Texture precaching is suspended so menus don't stutter during rendering.
//   2. The OS mouse cursor is enabled (bShowWindowsMouse) so widgets can be clicked.
//   3. The Root window tree is made visible and state switches to 'UWindow'.
function LaunchUWindow()
{
	// End:0x29
	if(bShowLog)
	{
		Log("WindowConsole::LaunchUWindow");
	}
	ViewportOwner.bSuspendPrecaching = true;
	bUWindowActive = true;
	ViewportOwner.bShowWindowsMouse = true;
	// End:0x6F
	if((Root != none))
	{
		Root.bWindowVisible = true;
	}
	GotoState('UWindow');
	return;
}

// CloseUWindow: deactivates the UWindow overlay and returns to the 'Game' state.
// Reverses exactly what LaunchUWindow did: hides the mouse cursor, hides the Root
// tree, resumes texture precaching, and transitions back to 'Game'.
function CloseUWindow()
{
	// End:0x28
	if(bShowLog)
	{
		Log("WindowConsole::CloseUWindow");
	}
	bUWindowActive = false;
	ViewportOwner.bShowWindowsMouse = false;
	// End:0x5D
	if((Root != none))
	{
		Root.bWindowVisible = false;
	}
	GotoState('Game');
	ViewportOwner.bSuspendPrecaching = false;
	return;
}

// CreateRootWindow: one-time initialisation of the UWindow widget tree.
// Called lazily from RenderUWindow on the first frame that needs to draw UI.
// Steps:
//   1. Snapshot the canvas size so we can detect resolution changes later.
//   2. Dynamically load and instantiate the class named by RootWindow config string.
//   3. Anchor the root at (0,0), set logical and pixel sizes accounting for GUIScale.
//   4. Set up the full-screen clipping rectangle.
//   5. Hand Root a back-reference to this console (Root.Console = self).
//   6. Propagate bUWindowActive so Root knows if it has input focus from the start.
//   7. Call Root.Created() to let it build its child widget hierarchy.
//   8. If the console overlay should be hidden, collapse it immediately.
function CreateRootWindow(Canvas Canvas)
{
	local int i;

	// End:0x2C
	if(bShowLog)
	{
		Log("WindowConsole::CreateRootWindow");
	}
	// End:0x62
	if((Canvas != none))
	{
		OldClipX = Canvas.ClipX;
		OldClipY = Canvas.ClipY;		
	}
	else
	{
		OldClipX = 0.0000000;
		OldClipY = 0.0000000;
	}
	// Dynamically load the class string (e.g. "UWindow.UWindowRootWindow") and
	// allocate a new instance in the global (None) outer package.
	Root = new (none) Class<UWindowRootWindow>(DynamicLoadObject(RootWindow, Class'Core.Class'));
	Root.BeginPlay();
	Root.WinTop = 0.0000000;
	Root.WinLeft = 0.0000000;
	// End:0x170
	// WinWidth/WinHeight are in logical (GUIScale-divided) units; RealWidth/RealHeight
	// are raw pixel counts. Widgets work in logical coords; the renderer uses real ones.
	if((Canvas != none))
	{
		Root.WinWidth = (Canvas.ClipX / Root.GUIScale);
		Root.WinHeight = (Canvas.ClipY / Root.GUIScale);
		Root.RealWidth = Canvas.ClipX;
		Root.RealHeight = Canvas.ClipY;		
	}
	else
	{
		Root.WinWidth = 0.0000000;
		Root.WinHeight = 0.0000000;
		Root.RealWidth = 0.0000000;
		Root.RealHeight = 0.0000000;
	}
	// ClippingRegion is the scissor rect used during rendering; starts as full-screen.
	Root.ClippingRegion.X = 0;
	Root.ClippingRegion.Y = 0;
	Root.ClippingRegion.W = int(Root.WinWidth);
	Root.ClippingRegion.H = int(Root.WinHeight);
	// Give Root a back-reference so child widgets can reach the console.
	Root.Console = self;
	Root.bUWindowActive = bUWindowActive;
	// End:0x2A5
	if(bShowLog)
	{
		Log(("CreateRootWindow Setting Root.bUWindowActive=" @ string(Root.bUWindowActive)));
	}
	Root.Created();
	bCreatedRoot = true;
	// End:0x2CD
	if((!bShowConsole))
	{
		HideConsole();
	}
	return;
}

// RenderUWindow: called every frame from PostRender in each UWindow state.
// Responsibilities (in order):
//   1. Configure Canvas for UI rendering (no smoothing, front Z-layer, opaque style, white tint).
//   2. Derive MouseScale from the player's sensitivity setting (10-100 → ~0.31-3.125).
//   3. If the OS mouse is available, read its pixel position and convert to logical coords.
//   4. Lazily create the Root window tree on the first call.
//   5. Detect resolution changes and resize the entire widget tree accordingly.
//   6. Clamp cursor to screen bounds.
//   7. Update keyboard focus (which widget receives key events).
//   8. Dispatch WM_Paint (event 11) to the Root so it draws all widgets.
//   9. If the OS cursor is active, draw the software mouse cursor on top.
function RenderUWindow(Canvas Canvas)
{
	local UWindowWindow NewFocusWindow;
	local R6GameOptions pGameOptions;

	// End:0x36
	if(bShowLog)
	{
		Log(("WindowConsole::RenderUWindow state" @ string(GetStateName())));
	}
	pGameOptions = Class'Engine.Actor'.static.GetGameOptions();
	Canvas.bNoSmooth = false;
	Canvas.Z = 1.0000000;
	// Style 1 = STY_Normal (solid, no translucency) — needed for opaque UI panels.
	Canvas.Style = 1;
	Canvas.SetDrawColor(byte(255), byte(255), byte(255));
	// Map sensitivity range 10-100 to a useful multiplier by dividing by 32.
	// At sensitivity=32 MouseScale≈1.0; at 100 it's ~3.125; at 10 it's ~0.31.
	MouseScale = (float(Clamp(int(pGameOptions.MouseSensitivity), 10, 100)) / 32.0000000);
	// End:0x122
	if((ViewportOwner.bWindowsMouseAvailable && (Root != none)))
	{
		MouseX = (ViewportOwner.WindowsMouseX / Root.GUIScale);
		MouseY = (ViewportOwner.WindowsMouseY / Root.GUIScale);
	}
	// End:0x138
	if((!bCreatedRoot))
	{
		CreateRootWindow(Canvas);
	}
	Root.bWindowVisible = true;
	Root.bUWindowActive = bUWindowActive;
	// End:0x1B1
	if(bShowLog)
	{
		Log(((("RenderUWindow Setting" @ string(Root)) @ ".bUWindowActive=") @ string(Root.bUWindowActive)));
	}
	// Canvas.ClipX/ClipY can be smaller than SizeX/SizeY when the engine clips a sub-region
	// (e.g. splitscreen). Force full-screen extents so UI always fills the whole viewport.
	// End:0x237
	if(((Canvas.ClipX != float(Canvas.SizeX)) || (Canvas.ClipY != float(Canvas.SizeY))))
	{
		Canvas.ClipX = float(Canvas.SizeX);
		Canvas.ClipY = float(Canvas.SizeY);
	}
	// Resolution changed — recompute all widget sizes and notify the tree.
	// End:0x3CE
	if(((Canvas.ClipX != OldClipX) || (Canvas.ClipY != OldClipY)))
	{
		OldClipX = Canvas.ClipX;
		OldClipY = Canvas.ClipY;
		Root.WinTop = 0.0000000;
		Root.WinLeft = 0.0000000;
		Root.WinWidth = (Canvas.ClipX / Root.GUIScale);
		Root.WinHeight = (Canvas.ClipY / Root.GUIScale);
		Root.RealWidth = Canvas.ClipX;
		Root.RealHeight = Canvas.ClipY;
		Root.ClippingRegion.X = 0;
		Root.ClippingRegion.Y = 0;
		Root.ClippingRegion.W = int(Root.WinWidth);
		Root.ClippingRegion.H = int(Root.WinHeight);
		Root.Resized();
	}
	// Clamp cursor to [0, SizeX] × [0, SizeY] so no widget gets out-of-bounds coords.
	// End:0x3FE
	if((MouseX > float(Canvas.SizeX)))
	{
		MouseX = float(Canvas.SizeX);
	}
	// End:0x42E
	if((MouseY > float(Canvas.SizeY)))
	{
		MouseY = float(Canvas.SizeY);
	}
	// End:0x446
	if((MouseX < float(0)))
	{
		MouseX = 0.0000000;
	}
	// End:0x45E
	if((MouseY < float(0)))
	{
		MouseY = 0.0000000;
	}
	// Walk the widget tree to find which window should receive keyboard events this frame.
	NewFocusWindow = Root.CheckKeyFocusWindow();
	// End:0x4CF
	// If focus has shifted, fire exit/enter callbacks so widgets can update their visual state.
	if((NewFocusWindow != Root.KeyFocusWindow))
	{
		Root.KeyFocusWindow.KeyFocusExit();
		Root.KeyFocusWindow = NewFocusWindow;
		Root.KeyFocusWindow.KeyFocusEnter();
	}
	// End:0x506
	if(bShowLog)
	{
		Log(("WindowConsole::RenderUWindow root" @ string(Root)));
	}
	// Apply any DPI/resolution scaling offsets to the raw mouse position.
	Root.ApplyResolutionOnWindowsPos(MouseX, MouseY);
	// Notify the widget tree of the new cursor position (triggers hover effects etc.).
	Root.MoveMouse(MouseX, MouseY);
	// WM_Paint = 11: dispatch the full paint pass to every visible widget.
	Root.WindowEvent(11, Canvas, MouseX, MouseY, 0);
	// End:0x58A
	// Draw the software mouse cursor last so it appears on top of all widgets.
	if((bUWindowActive && ViewportOwner.bShowWindowsMouse))
	{
		Root.DrawMouse(Canvas);
	}
	return;
}

// Message: called by the engine whenever an on-screen notification message arrives.
// Delegates to the parent Console for ring-buffer bookkeeping, then bails early if
// no actor is present (can happen during map loading before the world is ready).
// In the original SDK this also forwarded the text to the ConsoleWindow widget;
// that path is unused in 1.60 (ConsoleWindow was removed in R6).
event Message(coerce string Msg, float MsgLife)
{
	super.Message(Msg, MsgLife);
	// End:0x26
	if((ViewportOwner.Actor == none))
	{
		return;
	}
	return;
}

// UpdateHistory: appends the current TypedStr to the ring-buffer and advances the
// cursor.  The buffer holds up to 16 entries (MaxHistory); HistoryTop tracks
// the oldest slot and is bumped forward when the buffer wraps around.
function UpdateHistory()
{
	History[int((float((HistoryCur++)) % float(16)))] = TypedStr;
	// End:0x33
	if((HistoryCur > HistoryBot))
	{
		(HistoryBot++);
	}
	// End:0x58
	if(((HistoryCur - HistoryTop) >= 16))
	{
		HistoryTop = ((HistoryCur - 16) + 1);
	}
	return;
}

// HistoryUp: navigates to the previous (older) command in the history ring-buffer.
// Saves the current TypedStr first so it can be restored if the user navigates back down.
function HistoryUp()
{
	// End:0x47
	if((HistoryCur > HistoryTop))
	{
	// Store the current line before moving — preserves edits if the user typed
	// something after navigating away, then wants to come back.
	History[int((float(HistoryCur) % float(16)))] = TypedStr;
	// 16 = MaxHistory — the ring-buffer capacity for command history
	TypedStr = History[int((float((--HistoryCur)) % float(16)))];
	}
	return;
}

// HistoryDown: navigates to the next (newer) command in the ring-buffer.
// If already at the most recent entry, clears TypedStr to give a blank line.
function HistoryDown()
{
	History[int((float(HistoryCur) % float(16)))] = TypedStr;
	// End:0x4A
	if((HistoryCur < HistoryBot))
	{
		TypedStr = History[int((float((++HistoryCur)) % float(16)))];		
	}
	else
	{
		TypedStr = "";
	}
	return;
}

// NotifyLevelChange: called by the engine just before a new map begins loading.
// If the player had the console open (state 'Typing'), clear it and return to the
// previous UI state so the console doesn't block the loading screen.
// Sets bLevelChange so NotifyAfterLevelChange can forward the event to Root once.
function NotifyLevelChange()
{
	// End:0x2C
	if(bShowLog)
	{
		Log("WindowConsole NotifyLevelChange");
	}
	// End:0x5F
	if((GetStateName() == 'Typing'))
	{
		// End:0x58
		if((TypedStr != ""))
		{
			TypedStr = "";
			HistoryCur = HistoryTop;
		}
		GotoState(ConsoleState);
	}
	bLevelChange = true;
	// End:0x81
	if((Root != none))
	{
		Root.NotifyBeforeLevelChange();
	}
	return;
}

// NotifyAfterLevelChange: called after the new map has finished loading.
// Guards with bLevelChange so only one notification reaches Root even if the engine
// fires this callback multiple times during a complex transition.
function NotifyAfterLevelChange()
{
	// End:0x31
	if(bShowLog)
	{
		Log("WindowConsole NotifyAfterLevelChange");
	}
	// End:0x5E
	if((bLevelChange && (Root != none)))
	{
		bLevelChange = false;
		Root.NotifyAfterLevelChange();
	}
	return;
}

//===========================================================================================
// MenuLoadProfile: A profile was load
//===========================================================================================
function MenuLoadProfile(bool _bServerProfile)
{
	Root.MenuLoadProfile(_bServerProfile);
	return;
}

// ─────────────────────────────────────────────────────────────────────────────
// State: UWindowCanPlay
// The UWindow overlay is visible but the player retains movement/action control.
// Used for persistent HUDs that should be drawn without stealing game input.
// BeginState records the state name so NotifyLevelChange can restore it later.
// ─────────────────────────────────────────────────────────────────────────────
state UWindowCanPlay
{
	function BeginState()
	{
		// End:0x27
		if(bShowLog)
		{
			Log("UWindowCanPlay::BeginState");
		}
		ConsoleState = GetStateName();
		return;
	}

	// Tick (UWindowCanPlay): advance engine timers first, then tick the widget tree
	// so animations, fade-ins, and tooltip timers update each frame.
	event Tick(float Delta)
	{
		global.Tick(Delta);
		// End:0x2A
		if((Root != none))
		{
			Root.DoTick(Delta);
		}
		return;
	}

	// PostRender (UWindowCanPlay): mark UWindow as active so widgets draw themselves,
	// then render the full widget tree onto the canvas.
	function PostRender(Canvas Canvas)
	{
		// End:0x27
		if(bShowLog)
		{
			Log("UWindowCanPlay::PostRender");
		}
		// End:0x43
		if((Root != none))
		{
			Root.bUWindowActive = true;
		}
		RenderUWindow(Canvas);
		return;
	}

	// KeyType (UWindowCanPlay): printable character typed — forward as WM_KeyType (10)
	// so the focused widget (e.g. an edit box) can append the character.
	function bool KeyType(Interactions.EInputKey Key)
	{
		// End:0x44
		if(bShowLog)
		{
			Log(("WindowConsole state UWindowCanPlay KeyType Key" @ string(Key)));
		}
	// WM_KeyType = 10: text character event (after IME/dead-key processing)
		if((Root != none))
		{
			Root.WindowEvent(10, none, MouseX, MouseY, int(Key));
		}
		return true;
		return;
	}

	// KeyEvent (UWindowCanPlay): raw key press/release routing.
	// In this state the Console key switches to the 'Typing' state rather than
	// toggling UWindow visibility. All other keys are forwarded to the focused widget.
	// F9 (key 120) is punted to the global handler for screenshot capture.
	// Digit keys 0-9 (48-57) are consumed (return true) to prevent them triggering
	// bound game actions while a widget might want them.
	function bool KeyEvent(Interactions.EInputKey Key, Interactions.EInputAction Action, float Delta)
	{
		local byte k;

		k = Key;
		// End:0x64
		if(bShowLog)
		{
			Log(((("WindowConsole state UWindowCanPlay KeyEvent eAction" @ string(Action)) @ "Key") @ string(Key)));
		}
		switch(Action)
		{
			// End:0xA1
			// Action 3 = IST_Release: key released — send WM_KeyUp (8) to widget tree
			case 3:
				// End:0x9E
				if((Root != none))
				{
					Root.WindowEvent(8, none, MouseX, MouseY, int(k));
				}
				// End:0x147
				break;
				// Action 1 = IST_Press: key pressed — check Console key first, then route others
			case 1:
				// End:0xE5
				if((int(k) == int(ViewportOwner.Actor.GetKey("Console"))))
				{
					// End:0xDD
					if(bLocked)
					{
						return true;
					}
					// Switch to 'Typing' state to open the console input bar
					type();
					return true;
				}
				switch(k)
				{
					// End:0x10A
					// 120 = IK_F9: screenshot — bypass UWindow, let the engine handle it
					case 120:
						return global.KeyEvent(Key, Action, Delta);
						// End:0x13E
						break;
					// End:0xFFFF
					default:
						// End:0x13B
						// WM_KeyDown = 9: forward all other key presses to the focused widget
						if((Root != none))
						{
							Root.WindowEvent(9, none, MouseX, MouseY, int(k));
						}
						// End:0x13E
						break;
						break;
				}
				// End:0x147
				break;
			// End:0xFFFF
			default:
				// End:0x147
				break;
				break;
		}
		// End:0x16E
		// Consume digit keys 0-9 (48=IK_0, 57=IK_9) so they don't trigger weapon-switch
		// binds while a widget is active, but pass all other unrecognised keys through.
		if(((int(k) >= int(48)) && (int(k) <= int(57))))
		{
			return true;			
		}
		else
		{
			return false;
		}
		return;
	}
	stop;
}

// ─────────────────────────────────────────────────────────────────────────────
// State: UWindow
// Full UWindow mode — the overlay has exclusive input focus and mouse control.
// All mouse buttons, keyboard keys and axis movement are routed to the widget
// tree. The player cannot move or shoot while in this state.
// ─────────────────────────────────────────────────────────────────────────────
state UWindow
{
	// Tick (UWindow): same as UWindowCanPlay — advance engine then tick widgets.
	event Tick(float Delta)
	{
		global.Tick(Delta);
		// End:0x2A
		if((Root != none))
		{
			Root.DoTick(Delta);
		}
		return;
	}

	// PostRender (UWindow): same pattern as UWindowCanPlay — force active flag then paint.
	function PostRender(Canvas Canvas)
	{
		// End:0x35
		if(bShowLog)
		{
			Log("Window Console state UWindow::PostRender");
		}
		// End:0x51
		if((Root != none))
		{
			Root.bUWindowActive = true;
		}
		RenderUWindow(Canvas);
		return;
	}

	// KeyType (UWindow): printable character — forward to focused widget as WM_KeyType (10).
	function bool KeyType(Interactions.EInputKey Key)
	{
		// End:0x3D
		if(bShowLog)
		{
			Log(("WindowConsole state UWindow KeyType Key" @ string(Key)));
		}
		// End:0x6B
		if((Root != none))
		{
			Root.WindowEvent(10, none, MouseX, MouseY, int(Key));
		}
		return true;
		return;
	}

	// KeyEvent (UWindow): full UWindow input routing — the most complex handler.
	// Action codes: 1=IST_Press, 3=IST_Release, 4=IST_Axis.
	// Mouse button key codes: 1=IK_LeftMouse, 2=IK_RightMouse, 4=IK_MiddleMouse.
	// Every unrecognised key press/release falls through to WM_KeyDown/WM_KeyUp on Root.
	// Returns true unconditionally to prevent the game engine from acting on any input.
	function bool KeyEvent(Interactions.EInputKey Key, Interactions.EInputAction Action, float Delta)
	{
		local byte k;

		k = Key;
		// End:0x5D
		if(bShowLog)
		{
			Log(((("WindowConsole state UWindow KeyEvent eAction" @ string(Action)) @ "Key") @ string(Key)));
		}
		switch(Action)
		{
			// End:0x149
			// Action 3 = IST_Release — translate to the appropriate WM_*MouseUp or WM_KeyUp
			case 3:
				switch(k)
				{
					// End:0xA6
					// 1 = IK_LeftMouse: WM_LMouseUp = 1
					case 1:
						// End:0xA3
						if((Root != none))
						{
							Root.WindowEvent(1, none, MouseX, MouseY, int(k));
						}
						// End:0x146
						break;
					// End:0xDC
					// 2 = IK_RightMouse: WM_RMouseUp = 5
					case 2:
						// End:0xD9
						if((Root != none))
						{
							Root.WindowEvent(5, none, MouseX, MouseY, int(k));
						}
						// End:0x146
						break;
					// End:0x112
					// 4 = IK_MiddleMouse: WM_MMouseUp = 3
					case 4:
						// End:0x10F
						if((Root != none))
						{
							Root.WindowEvent(3, none, MouseX, MouseY, int(k));
						}
						// End:0x146
						break;
					// End:0xFFFF
					default:
						// End:0x143
						// WM_KeyUp = 8 for all other released keys
						if((Root != none))
						{
							Root.WindowEvent(8, none, MouseX, MouseY, int(k));
						}
						// End:0x146
						break;
						break;
				}
				goto J0x344;
			// End:0x2ED
			// Action 1 = IST_Press — key or button pressed
			case 1:
				// End:0x1CD
				// Console key toggles the slide-down text overlay while UWindow stays active.
				// If Root doesn't allow the console (bAllowConsole=false), treat it as WM_KeyDown.
				if((int(k) == int(ViewportOwner.Actor.GetKey("Console"))))
				{
					// End:0x18C
					if(bShowConsole)
					{
						HideConsole();						
					}
					else
					{
						// End:0x1A7
						if(Root.bAllowConsole)
						{
							ShowConsole();							
						}
						else
						{
							Root.WindowEvent(9, none, MouseX, MouseY, int(k));
						}
					}
					// [Explicit Continue]
					goto J0x344;
				}
				switch(k)
				{
					// End:0x1F2
					// 120 = IK_F9: screenshot — bypass UWindow entirely
					case 120:
						return global.KeyEvent(Key, Action, Delta);
						// End:0x2EA
						break;
					// End:0x214
					// 27 = IK_Escape: close the topmost active widget (e.g. dismiss a dialog)
					case 27:
						// End:0x211
						if((Root != none))
						{
							Root.CloseActiveWindow();
						}
						// End:0x2EA
						break;
					// End:0x24A
					// 1 = IK_LeftMouse: WM_LMouseDown = 0
					case 1:
						// End:0x247
						if((Root != none))
						{
							Root.WindowEvent(0, none, MouseX, MouseY, int(k));
						}
						// End:0x2EA
						break;
					// End:0x280
					// 2 = IK_RightMouse: WM_RMouseDown = 4
					case 2:
						// End:0x27D
						if((Root != none))
						{
							Root.WindowEvent(4, none, MouseX, MouseY, int(k));
						}
						// End:0x2EA
						break;
					// End:0x2B6
					// 4 = IK_MiddleMouse: WM_MMouseDown = 2
					case 4:
						// End:0x2B3
						if((Root != none))
						{
							Root.WindowEvent(2, none, MouseX, MouseY, int(k));
						}
						// End:0x2EA
						break;
					// End:0xFFFF
					default:
						// End:0x2E7
						// WM_KeyDown = 9 for all other pressed keys
						if((Root != none))
						{
							Root.WindowEvent(9, none, MouseX, MouseY, int(k));
						}
						// End:0x2EA
						break;
						break;
				}
				goto J0x344;
			// End:0x33E
			// Action 4 = IST_Axis: analogue mouse movement — accumulate into MouseX/MouseY.
			// 228 = IK_MouseX (horizontal axis), 229 = IK_MouseY (vertical axis, inverted).
			case 4:
				switch(Key)
				{
					// End:0x31A
					// IK_MouseX = 228: horizontal movement — add scaled delta to cursor X
					case 228:
						MouseX = (MouseX + (MouseScale * Delta));
						// End:0x33E
						break;
					// End:0x33B
					// IK_MouseY = 229: vertical movement — subtract because screen Y grows downward
					case 229:
						MouseY = (MouseY - (MouseScale * Delta));
						// End:0x33E
						break;
					// End:0xFFFF
					default:
						break;
				}
			// End:0xFFFF
			default:
				// End:0x344
				break;
				break;
		}
		J0x344:

		return true;
		return;
	}
Begin:

	stop;			
}

defaultproperties
{
	// Default sensitivity: maps to MouseScale ≈ 0.6 (a mid-range feel for menus)
	MouseScale=0.6000000
	// Default root window class; can be overridden in game INI for custom UI mods
	RootWindow="UWindow.UWindowRootWindow"
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var s
// REMOVED IN 1.60: var e
// REMOVED IN 1.60: var g
