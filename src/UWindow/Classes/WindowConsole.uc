//=============================================================================
// WindowConsole - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// WindowConsole - console replacer to implement UWindow UI System
//=============================================================================
class WindowConsole extends Console
 config;

const MaxLines = 64;
const TextMsgSize = 128;

var int Scrollback;
// NEW IN 1.60
var int numLines;
// NEW IN 1.60
var int TopLine;
// NEW IN 1.60
var int TextLines;
var int ConsoleLines;
var bool bNoStuff;
// NEW IN 1.60
var bool bTyping;
var bool bShowLog;
var bool bCreatedRoot;
var config bool bShowConsole;
var bool bBlackout;
var bool bUWindowType;
var bool bUWindowActive;
var bool bLocked;
var bool bLevelChange;
var float MsgTime;
// NEW IN 1.60
var float MsgTickTime;
var float MsgTick[64];
var float OldClipX;
var float OldClipY;
var float MouseX;
var float MouseY;
var config float MouseScale;
// Variables.
var Viewport Viewport;
var UWindowRootWindow Root;
// R6CODE
var name ConsoleState;
var Class<UWindowConsoleWindow> ConsoleClass;
var string MsgText[64];
var() config string RootWindow;
var string OldLevel;
var string szStoreIP;  // String used to store IP of host server

//function class<object> GetRestKitDescName(string WeaponNameTag);
function GetRestKitDescName(GameReplicationInfo _GRI, R6ServerInfo pServerOptions)
{
	return;
}

function ResetUWindow()
{
	// End:0x28
	if(bShowLog)
	{
		__NFUN_231__("WindowConsole::ResetUWindow");
	}
	// End:0x42
	if(__NFUN_119__(Root, none))
	{
		Root.Close();
	}
	Root = none;
	bCreatedRoot = false;
	bShowConsole = false;
	CloseUWindow();
	return;
}

function bool KeyEvent(Interactions.EInputKey Key, Interactions.EInputAction Action, float Delta)
{
	local byte k;

	k = Key;
	// End:0x57
	if(bShowLog)
	{
		__NFUN_231__(__NFUN_168__(__NFUN_168__(__NFUN_168__("WindowConsole state \" KeyEvent eAction", string(Action)), "Key"), string(Key)));
	}
	switch(Action)
	{
		// End:0xD8
		case 1:
			// End:0xB3
			if(__NFUN_154__(int(k), int(ViewportOwner.Actor.__NFUN_2706__("Console"))))
			{
				// End:0x9A
				if(bLocked)
				{
					return true;
				}
				LaunchUWindow();
				// End:0xB1
				if(__NFUN_129__(bShowConsole))
				{
					ShowConsole();
				}
				return true;
			}
			switch(k)
			{
				// End:0xD2
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

function ShowConsole()
{
	bShowConsole = true;
	return;
}

function HideConsole()
{
	ConsoleLines = 0;
	bShowConsole = false;
	return;
}

function ToggleUWindow()
{
	return;
}

function LaunchUWindow()
{
	// End:0x29
	if(bShowLog)
	{
		__NFUN_231__("WindowConsole::LaunchUWindow");
	}
	ViewportOwner.bSuspendPrecaching = true;
	bUWindowActive = true;
	ViewportOwner.bShowWindowsMouse = true;
	// End:0x6F
	if(__NFUN_119__(Root, none))
	{
		Root.bWindowVisible = true;
	}
	__NFUN_113__('UWindow');
	return;
}

function CloseUWindow()
{
	// End:0x28
	if(bShowLog)
	{
		__NFUN_231__("WindowConsole::CloseUWindow");
	}
	bUWindowActive = false;
	ViewportOwner.bShowWindowsMouse = false;
	// End:0x5D
	if(__NFUN_119__(Root, none))
	{
		Root.bWindowVisible = false;
	}
	__NFUN_113__('Game');
	ViewportOwner.bSuspendPrecaching = false;
	return;
}

function CreateRootWindow(Canvas Canvas)
{
	local int i;

	// End:0x2C
	if(bShowLog)
	{
		__NFUN_231__("WindowConsole::CreateRootWindow");
	}
	// End:0x62
	if(__NFUN_119__(Canvas, none))
	{
		OldClipX = Canvas.ClipX;
		OldClipY = Canvas.ClipY;		
	}
	else
	{
		OldClipX = 0.0000000;
		OldClipY = 0.0000000;
	}
	Root = new (none) Class<UWindowRootWindow>(DynamicLoadObject(RootWindow, Class'Core.Class'));
	Root.BeginPlay();
	Root.WinTop = 0.0000000;
	Root.WinLeft = 0.0000000;
	// End:0x170
	if(__NFUN_119__(Canvas, none))
	{
		Root.WinWidth = __NFUN_172__(Canvas.ClipX, Root.GUIScale);
		Root.WinHeight = __NFUN_172__(Canvas.ClipY, Root.GUIScale);
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
	Root.ClippingRegion.X = 0;
	Root.ClippingRegion.Y = 0;
	Root.ClippingRegion.W = int(Root.WinWidth);
	Root.ClippingRegion.H = int(Root.WinHeight);
	Root.Console = self;
	Root.bUWindowActive = bUWindowActive;
	// End:0x2A5
	if(bShowLog)
	{
		__NFUN_231__(__NFUN_168__("CreateRootWindow Setting Root.bUWindowActive=", string(Root.bUWindowActive)));
	}
	Root.Created();
	bCreatedRoot = true;
	// End:0x2CD
	if(__NFUN_129__(bShowConsole))
	{
		HideConsole();
	}
	return;
}

function RenderUWindow(Canvas Canvas)
{
	local UWindowWindow NewFocusWindow;
	local R6GameOptions pGameOptions;

	// End:0x36
	if(bShowLog)
	{
		__NFUN_231__(__NFUN_168__("WindowConsole::RenderUWindow state", string(__NFUN_284__())));
	}
	pGameOptions = Class'Engine.Actor'.static.__NFUN_1009__();
	Canvas.bNoSmooth = false;
	Canvas.Z = 1.0000000;
	Canvas.Style = 1;
	Canvas.__NFUN_2626__(byte(255), byte(255), byte(255));
	MouseScale = __NFUN_172__(float(__NFUN_251__(int(pGameOptions.MouseSensitivity), 10, 100)), 32.0000000);
	// End:0x122
	if(__NFUN_130__(ViewportOwner.bWindowsMouseAvailable, __NFUN_119__(Root, none)))
	{
		MouseX = __NFUN_172__(ViewportOwner.WindowsMouseX, Root.GUIScale);
		MouseY = __NFUN_172__(ViewportOwner.WindowsMouseY, Root.GUIScale);
	}
	// End:0x138
	if(__NFUN_129__(bCreatedRoot))
	{
		CreateRootWindow(Canvas);
	}
	Root.bWindowVisible = true;
	Root.bUWindowActive = bUWindowActive;
	// End:0x1B1
	if(bShowLog)
	{
		__NFUN_231__(__NFUN_168__(__NFUN_168__(__NFUN_168__("RenderUWindow Setting", string(Root)), ".bUWindowActive="), string(Root.bUWindowActive)));
	}
	// End:0x237
	if(__NFUN_132__(__NFUN_181__(Canvas.ClipX, float(Canvas.SizeX)), __NFUN_181__(Canvas.ClipY, float(Canvas.SizeY))))
	{
		Canvas.ClipX = float(Canvas.SizeX);
		Canvas.ClipY = float(Canvas.SizeY);
	}
	// End:0x3CE
	if(__NFUN_132__(__NFUN_181__(Canvas.ClipX, OldClipX), __NFUN_181__(Canvas.ClipY, OldClipY)))
	{
		OldClipX = Canvas.ClipX;
		OldClipY = Canvas.ClipY;
		Root.WinTop = 0.0000000;
		Root.WinLeft = 0.0000000;
		Root.WinWidth = __NFUN_172__(Canvas.ClipX, Root.GUIScale);
		Root.WinHeight = __NFUN_172__(Canvas.ClipY, Root.GUIScale);
		Root.RealWidth = Canvas.ClipX;
		Root.RealHeight = Canvas.ClipY;
		Root.ClippingRegion.X = 0;
		Root.ClippingRegion.Y = 0;
		Root.ClippingRegion.W = int(Root.WinWidth);
		Root.ClippingRegion.H = int(Root.WinHeight);
		Root.Resized();
	}
	// End:0x3FE
	if(__NFUN_177__(MouseX, float(Canvas.SizeX)))
	{
		MouseX = float(Canvas.SizeX);
	}
	// End:0x42E
	if(__NFUN_177__(MouseY, float(Canvas.SizeY)))
	{
		MouseY = float(Canvas.SizeY);
	}
	// End:0x446
	if(__NFUN_176__(MouseX, float(0)))
	{
		MouseX = 0.0000000;
	}
	// End:0x45E
	if(__NFUN_176__(MouseY, float(0)))
	{
		MouseY = 0.0000000;
	}
	NewFocusWindow = Root.CheckKeyFocusWindow();
	// End:0x4CF
	if(__NFUN_119__(NewFocusWindow, Root.KeyFocusWindow))
	{
		Root.KeyFocusWindow.KeyFocusExit();
		Root.KeyFocusWindow = NewFocusWindow;
		Root.KeyFocusWindow.KeyFocusEnter();
	}
	// End:0x506
	if(bShowLog)
	{
		__NFUN_231__(__NFUN_168__("WindowConsole::RenderUWindow root", string(Root)));
	}
	Root.ApplyResolutionOnWindowsPos(MouseX, MouseY);
	Root.MoveMouse(MouseX, MouseY);
	Root.WindowEvent(11, Canvas, MouseX, MouseY, 0);
	// End:0x58A
	if(__NFUN_130__(bUWindowActive, ViewportOwner.bShowWindowsMouse))
	{
		Root.DrawMouse(Canvas);
	}
	return;
}

event Message(coerce string Msg, float MsgLife)
{
	super.Message(Msg, MsgLife);
	// End:0x26
	if(__NFUN_114__(ViewportOwner.Actor, none))
	{
		return;
	}
	return;
}

function UpdateHistory()
{
	History[int(__NFUN_173__(float(__NFUN_165__(HistoryCur)), float(16)))] = TypedStr;
	// End:0x33
	if(__NFUN_151__(HistoryCur, HistoryBot))
	{
		__NFUN_165__(HistoryBot);
	}
	// End:0x58
	if(__NFUN_153__(__NFUN_147__(HistoryCur, HistoryTop), 16))
	{
		HistoryTop = __NFUN_146__(__NFUN_147__(HistoryCur, 16), 1);
	}
	return;
}

function HistoryUp()
{
	// End:0x47
	if(__NFUN_151__(HistoryCur, HistoryTop))
	{
		History[int(__NFUN_173__(float(HistoryCur), float(16)))] = TypedStr;
		TypedStr = History[int(__NFUN_173__(float(__NFUN_164__(HistoryCur)), float(16)))];
	}
	return;
}

function HistoryDown()
{
	History[int(__NFUN_173__(float(HistoryCur), float(16)))] = TypedStr;
	// End:0x4A
	if(__NFUN_150__(HistoryCur, HistoryBot))
	{
		TypedStr = History[int(__NFUN_173__(float(__NFUN_163__(HistoryCur)), float(16)))];		
	}
	else
	{
		TypedStr = "";
	}
	return;
}

function NotifyLevelChange()
{
	// End:0x2C
	if(bShowLog)
	{
		__NFUN_231__("WindowConsole NotifyLevelChange");
	}
	// End:0x5F
	if(__NFUN_254__(__NFUN_284__(), 'Typing'))
	{
		// End:0x58
		if(__NFUN_123__(TypedStr, ""))
		{
			TypedStr = "";
			HistoryCur = HistoryTop;
		}
		__NFUN_113__(ConsoleState);
	}
	bLevelChange = true;
	// End:0x81
	if(__NFUN_119__(Root, none))
	{
		Root.NotifyBeforeLevelChange();
	}
	return;
}

function NotifyAfterLevelChange()
{
	// End:0x31
	if(bShowLog)
	{
		__NFUN_231__("WindowConsole NotifyAfterLevelChange");
	}
	// End:0x5E
	if(__NFUN_130__(bLevelChange, __NFUN_119__(Root, none)))
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

state UWindowCanPlay
{
	function BeginState()
	{
		// End:0x27
		if(bShowLog)
		{
			__NFUN_231__("UWindowCanPlay::BeginState");
		}
		ConsoleState = __NFUN_284__();
		return;
	}

	event Tick(float Delta)
	{
		global.Tick(Delta);
		// End:0x2A
		if(__NFUN_119__(Root, none))
		{
			Root.DoTick(Delta);
		}
		return;
	}

	function PostRender(Canvas Canvas)
	{
		// End:0x27
		if(bShowLog)
		{
			__NFUN_231__("UWindowCanPlay::PostRender");
		}
		// End:0x43
		if(__NFUN_119__(Root, none))
		{
			Root.bUWindowActive = true;
		}
		RenderUWindow(Canvas);
		return;
	}

	function bool KeyType(Interactions.EInputKey Key)
	{
		// End:0x44
		if(bShowLog)
		{
			__NFUN_231__(__NFUN_168__("WindowConsole state UWindowCanPlay KeyType Key", string(Key)));
		}
		// End:0x72
		if(__NFUN_119__(Root, none))
		{
			Root.WindowEvent(10, none, MouseX, MouseY, int(Key));
		}
		return true;
		return;
	}

	function bool KeyEvent(Interactions.EInputKey Key, Interactions.EInputAction Action, float Delta)
	{
		local byte k;

		k = Key;
		// End:0x64
		if(bShowLog)
		{
			__NFUN_231__(__NFUN_168__(__NFUN_168__(__NFUN_168__("WindowConsole state UWindowCanPlay KeyEvent eAction", string(Action)), "Key"), string(Key)));
		}
		switch(Action)
		{
			// End:0xA1
			case 3:
				// End:0x9E
				if(__NFUN_119__(Root, none))
				{
					Root.WindowEvent(8, none, MouseX, MouseY, int(k));
				}
				// End:0x147
				break;
			// End:0x141
			case 1:
				// End:0xE5
				if(__NFUN_154__(int(k), int(ViewportOwner.Actor.__NFUN_2706__("Console"))))
				{
					// End:0xDD
					if(bLocked)
					{
						return true;
					}
					type();
					return true;
				}
				switch(k)
				{
					// End:0x10A
					case 120:
						return global.KeyEvent(Key, Action, Delta);
						// End:0x13E
						break;
					// End:0xFFFF
					default:
						// End:0x13B
						if(__NFUN_119__(Root, none))
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
		if(__NFUN_130__(__NFUN_153__(int(k), int(48)), __NFUN_152__(int(k), int(57))))
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

state UWindow
{
	event Tick(float Delta)
	{
		global.Tick(Delta);
		// End:0x2A
		if(__NFUN_119__(Root, none))
		{
			Root.DoTick(Delta);
		}
		return;
	}

	function PostRender(Canvas Canvas)
	{
		// End:0x35
		if(bShowLog)
		{
			__NFUN_231__("Window Console state UWindow::PostRender");
		}
		// End:0x51
		if(__NFUN_119__(Root, none))
		{
			Root.bUWindowActive = true;
		}
		RenderUWindow(Canvas);
		return;
	}

	function bool KeyType(Interactions.EInputKey Key)
	{
		// End:0x3D
		if(bShowLog)
		{
			__NFUN_231__(__NFUN_168__("WindowConsole state UWindow KeyType Key", string(Key)));
		}
		// End:0x6B
		if(__NFUN_119__(Root, none))
		{
			Root.WindowEvent(10, none, MouseX, MouseY, int(Key));
		}
		return true;
		return;
	}

	function bool KeyEvent(Interactions.EInputKey Key, Interactions.EInputAction Action, float Delta)
	{
		local byte k;

		k = Key;
		// End:0x5D
		if(bShowLog)
		{
			__NFUN_231__(__NFUN_168__(__NFUN_168__(__NFUN_168__("WindowConsole state UWindow KeyEvent eAction", string(Action)), "Key"), string(Key)));
		}
		switch(Action)
		{
			// End:0x149
			case 3:
				switch(k)
				{
					// End:0xA6
					case 1:
						// End:0xA3
						if(__NFUN_119__(Root, none))
						{
							Root.WindowEvent(1, none, MouseX, MouseY, int(k));
						}
						// End:0x146
						break;
					// End:0xDC
					case 2:
						// End:0xD9
						if(__NFUN_119__(Root, none))
						{
							Root.WindowEvent(5, none, MouseX, MouseY, int(k));
						}
						// End:0x146
						break;
					// End:0x112
					case 4:
						// End:0x10F
						if(__NFUN_119__(Root, none))
						{
							Root.WindowEvent(3, none, MouseX, MouseY, int(k));
						}
						// End:0x146
						break;
					// End:0xFFFF
					default:
						// End:0x143
						if(__NFUN_119__(Root, none))
						{
							Root.WindowEvent(8, none, MouseX, MouseY, int(k));
						}
						// End:0x146
						break;
						break;
				}
				goto J0x344;
			// End:0x2ED
			case 1:
				// End:0x1CD
				if(__NFUN_154__(int(k), int(ViewportOwner.Actor.__NFUN_2706__("Console"))))
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
					case 120:
						return global.KeyEvent(Key, Action, Delta);
						// End:0x2EA
						break;
					// End:0x214
					case 27:
						// End:0x211
						if(__NFUN_119__(Root, none))
						{
							Root.CloseActiveWindow();
						}
						// End:0x2EA
						break;
					// End:0x24A
					case 1:
						// End:0x247
						if(__NFUN_119__(Root, none))
						{
							Root.WindowEvent(0, none, MouseX, MouseY, int(k));
						}
						// End:0x2EA
						break;
					// End:0x280
					case 2:
						// End:0x27D
						if(__NFUN_119__(Root, none))
						{
							Root.WindowEvent(4, none, MouseX, MouseY, int(k));
						}
						// End:0x2EA
						break;
					// End:0x2B6
					case 4:
						// End:0x2B3
						if(__NFUN_119__(Root, none))
						{
							Root.WindowEvent(2, none, MouseX, MouseY, int(k));
						}
						// End:0x2EA
						break;
					// End:0xFFFF
					default:
						// End:0x2E7
						if(__NFUN_119__(Root, none))
						{
							Root.WindowEvent(9, none, MouseX, MouseY, int(k));
						}
						// End:0x2EA
						break;
						break;
				}
				goto J0x344;
			// End:0x33E
			case 4:
				switch(Key)
				{
					// End:0x31A
					case 228:
						MouseX = __NFUN_174__(MouseX, __NFUN_171__(MouseScale, Delta));
						// End:0x33E
						break;
					// End:0x33B
					case 229:
						MouseY = __NFUN_175__(MouseY, __NFUN_171__(MouseScale, Delta));
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
	MouseScale=0.6000000
	RootWindow="UWindow.UWindowRootWindow"
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var s
// REMOVED IN 1.60: var e
// REMOVED IN 1.60: var g
