//=============================================================================
// R6MenuMultiPlayerWidget - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6MenuMultiPlayerWidget.uc : The first multi player menu window
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/11/22 * Created by Alexandre Dionne
//    2002/03/7  * Modify by Yannick Joly
//=============================================================================
class R6MenuMultiPlayerWidget extends R6MenuWidget
    config(User);

// Pixel X origin for the main framed areas (server list, filter panels)
const K_XSTARTPOS = 10;
// Full width of the main content panels (fits within 640 wide screen)
const K_WINDOWWIDTH = 620;
// Inner origin/width strip borders for lists that have no drawn border frame
const K_XSTARTPOS_NOBORDER = 12;
const K_WINDOWWIDTH_NOBORDER = 616;
// Tab label strip is inset by this many pixels from the frame edge
const K_XTABOFFSET = 5;
// Width of the connection-type tab row (Internet / LAN) — narrower to leave room for page switcher
const K_FIRST_TABWINDOW_WIDTH = 500;
// Width of the filter/server-info tab row (Game Mode / Tech Filter / Server Info)
const K_SEC_TABWINDOW_WIDTH = 600;
// Pixel heights of the two content panels below their respective tab rows
const K_FFIRST_WINDOWHEIGHT = 154;   // Server list panel height
const K_FSECOND_WINDOWHEIGHT = 90;   // Filter / server-info panel height
// Y positions of the two tab-panel areas (measured from widget top)
const K_YPOS_FIRST_TABWINDOW = 126;
const K_YPOS_SECOND_TABWINDOW = 296;
// Y position of the help/status text bar at the bottom
const K_YPOS_HELPTEXT_WINDOW = 430;
// Vertical spacing between action buttons (Login, Join, JoinIP, Refresh, Create)
const C_fDIST_BETWEEN_BUTTON = 30;
// Minimum milliseconds between server-list display refreshes (throttles UI churn)
const K_LIST_UPDATE_TIME = 1000;
// Seconds the user must wait between manual Refresh presses (prevents spam)
const K_REFRESH_TIMEOUT = 2.0;
// Minimum seconds between filter-apply passes when checkboxes change rapidly
const K_UPDATE_FILTER_INTERVAL = 0.3;

// Which of the two top-level connection tabs is active (LAN or Internet)
enum MultiPlayerTabID
{
	TAB_Lan_Server,                 // 0 — Local Area Network server browser
	TAB_Internet_Server,            // 1 — GameSpy / ubi.com internet browser
	TAB_Game_Mode,                  // 2 — Game type filter panel (second tab row)
	TAB_Tech_Filter,                // 3 — Technical filters panel (ping, version, etc.)
	TAB_Server_Info                 // 4 — Selected-server details panel
};

// Indices into the eServerInfoID enum mirror the eServerInfoID_ values.
// Used to identify which filter checkbox was toggled in SetServerFilterBooleans().
enum eServerInfoID
{
	eServerInfoID_DeathMatch,       // 0
	eServerInfoID_TeamDeathMatch,   // 1
	eServerInfoID_Bomb,             // 2
	eServerInfoID_HostageAdv,       // 3
	eServerInfoID_Escort,           // 4
	eServerInfoID_Mission,          // 5
	eServerInfoID_Terrorist,        // 6
	eServerInfoID_HostageCoop,      // 7
	eServerInfoID_Defend,           // 8
	eServerInfoID_Recon,            // 9
	eServerInfoID_Unlocked,         // 10
	eServerInfoID_Favorites,        // 11
	eServerInfoID_Dedicated,        // 12
	eServerInfoID_PunkBuster,       // 13
	eServerInfoID_NotEmpty,         // 14
	eServerInfoID_NotFull,          // 15
	eServerInfoID_Responding,       // 16
	eServerInfoID_HasPlayer,        // 17 — REMOVED IN 1.60 (was szHasPlayer text filter)
	eServerInfoID_SameVersion       // 18
};

// Controls what happens after the ubi.com login dialog completes successfully.
// SendMessage() reads this flag to decide which step to take next.
enum eLoginSuccessAction
{
	eLSAct_None,                    // 0 — no pending action
	eLSAct_JoinIP,                  // 1 — finish a Join-by-IP flow
	eLSAct_Join,                    // 2 — finish a Join-from-list flow
	eLSAct_InternetTab,             // 3 — refresh internet server list after login
	eLSAct_LaunchServer,            // 4 — launch a dedicated server after login
	eLSAct_CloseWindow,             // 5 — re-login after router disconnect, refresh if on internet tab
	eLSAct_SwitchToInternetTab      // 6 — navigate to internet tab after login
};

var R6MenuMultiPlayerWidget.MultiPlayerTabID m_ConnectionTab; // Active connection tab (LAN=0 / Internet=1)
var R6MenuMultiPlayerWidget.MultiPlayerTabID m_FilterTab;    // Active bottom-panel tab (Game Mode / Tech Filter / Server Info)
var R6MenuMultiPlayerWidget.eLoginSuccessAction m_LoginSuccessAction;  // Action to take after login procedure succeeds
var int m_FrameCounter;  // Counter to schedule slower processes
                                                                 // keeps a history of pop up to return to./
var int m_iTimeLastUpdate;  // Time in ms of the last server list update (used to throttle redraws)
var int m_iLastSortCategory;  // the last sort column/category applied
var config int m_iLastTabSel;  // The last tab selected between Internet and LAN (persisted to User.ini)
var int m_iTotalPlayers;  // total players across all visible servers (shown in status bar)
// NEW IN 1.60
var config int m_iFilterFasterThan; // Hide servers with ping above this value (0 = disabled)
var bool m_bListUpdateReq;  // the server list needs to be updated
var bool m_bLastTypeOfSort; // true = ascending sort order
var bool m_bFPassWindowActv;  // First pass flag used for when window is first activated (restores last tab)
var bool m_bJoinIPInProgress; // A Join-by-IP popup dialog is currently active
var bool m_bQueryServerInfoInProgress; // A pre-join server query popup is currently active
var bool m_bGetServerInfo;  // Need to get the server info for the selected server (deferred request)
var bool m_bLanRefreshFPass;  // First pass flag for LAN server refresh (triggers auto-refresh on first visit)
var bool m_bIntRefreshFPass;  // First pass flag for Internet server refresh (triggers auto-refresh on first visit)
// NEW IN 1.60 — rate-limiting flag: a filter update is pending but was deferred
var bool m_bNeedUpdateServerFilter;
// NEW IN 1.60 — per-game-mode and per-tech filter booleans (config = saved to User.ini).
// In SDK 1.56 these were stored directly on the server list filter structs;
// in 1.60 they live here and are applied by UpdateFilters() each frame.
var config bool m_bFilterDeathMatch;
// NEW IN 1.60
var config bool m_bFilterTeamDeathMatch;
// NEW IN 1.60
var config bool m_bFilterDisarmBomb;
// NEW IN 1.60
var config bool m_bFilterHostageRescueAdv;
// NEW IN 1.60
var config bool m_bFilterEscortPilot;
// NEW IN 1.60
var config bool m_bFilterMission;
// NEW IN 1.60
var config bool m_bFilterTerroristHunt;
// NEW IN 1.60
var config bool m_bFilterHostageRescueCoop;
// NEW IN 1.60
var config bool m_bFilterUnlockedOnly;
// NEW IN 1.60
var config bool m_bFilterFavoritesOnly;
// NEW IN 1.60
var config bool m_bFilterDedicatedServersOnly;
// NEW IN 1.60
var config bool m_bFilterServersNotEmpty;
// NEW IN 1.60
var config bool m_bFilterServersNotFull;
// NEW IN 1.60
var config bool m_bFilterResponding;
// NEW IN 1.60
var config bool m_bFilterSameVersion;
// NEW IN 1.60
var config bool m_bFilterPunkBusterServerOnly;
var float m_fMouseX;  // X position of mouse (saved each frame to position the right-click menu)
var float m_fMouseY;  // Y position of mouse
var float m_fRefeshDeltaTime;  // Seconds since the Refresh button was last pressed (guards against spam)
// NEW IN 1.60 — timestamp of last filter update; paired with m_bNeedUpdateServerFilter for debounce
var float m_fLastUpdateServerFilterTime;
var R6WindowTextLabel m_LMenuTitle;
var R6WindowButton m_ButtonMainMenu;
var R6WindowButton m_ButtonOptions;
var R6WindowPageSwitch m_PageCount;
var R6WindowButtonMultiMenu m_ButtonLogInOut;
var R6WindowButtonMultiMenu m_ButtonJoin;
var R6WindowButtonMultiMenu m_ButtonJoinIP;
var R6WindowButtonMultiMenu m_ButtonRefresh;
var R6WindowButtonMultiMenu m_ButtonCreate;
var R6WindowTextLabelCurved m_FirstTabWindow;  // First tab window (on a simple curved frame)
var R6WindowTextLabelCurved m_SecondTabWindow;  // Second tab window ( on a simple curved frame)
var R6WindowTextLabelExt m_ServerDescription;  // the info bar description
var R6MenuMPButServerList m_pButServerList;  // the buttons for sorting
var R6MenuMPManageTab m_pFirstTabManager;  // creation of the tab manager for the first tab window
var R6MenuMPManageTab m_pSecondTabManager;  // creation of the tab manager for the second tab window
var R6MenuMPMenuTab m_pSecondWindow;
var R6MenuMPMenuTab m_pSecondWindowGameMode;
var R6MenuMPMenuTab m_pSecondWindowFilter;
var R6MenuMPMenuTab m_pSecondWindowServerInfo;
var R6WindowSimpleFramedWindowExt m_pFirstWindowBorder;
var R6WindowSimpleFramedWindowExt m_pSecondWindowBorder;
var R6MenuHelpWindow m_pHelpTextWindow;
var R6WindowServerListBox m_ServerListBox;  // List of servers with scroll bar
var R6WindowServerInfoPlayerBox m_ServerInfoPlayerBox;  // List of information for selected server
var R6WindowServerInfoMapBox m_ServerInfoMapBox;  // List of information for selected server
var R6WindowServerInfoOptionsBox m_ServerInfoOptionsBox;  // List of information for selected server
var R6GSServers m_GameService;  // Manages servers from game service
var R6LanServers m_LanServers;  // Manages servers on the LAN
var UWindowListBoxItem m_oldSelItem;  // Used to detect when selected server has changed
var R6WindowUbiLogIn m_pLoginWindow;  // Windows and logic for ubi.com login
var R6WindowJoinIP m_pJoinIPWindow;  // Windows and login for Join IP steps
var R6WindowQueryServerInfo m_pQueryServerInfo;  // Windows and login for logic to query a server for information
var R6WindowRightClickMenu m_pRightClickMenu;  // Used when user right clicks on a server
var string m_szGamePwd; // Password for the server being joined (empty if server is unlocked)
var config string m_szPopUpIP;  // IP adress entered in pop up
var string m_szServerIP;  // IP of server being joined (set before starting pre-join flow)
var string m_szMultiLoc[2];  // Cached localisation strings: [0]="N Servers", [1]="N Players"

// Called once when the widget is instantiated. Creates all child windows,
// buttons, popup dialogs, and tab panels. Does NOT create the server list or
// second tab content — those are deferred to ShowWindow() to avoid spawning
// actors (ClientBeaconReceiver) before they are needed.
function Created()
{
	// Grab the shared game service object that talks to ubi.com / GameSpy
	m_GameService = R6Console(Root.Console).m_GameService;
	InitText();
	InitButton();
	// Curved decorative frame strip that sits behind the tab labels
	m_FirstTabWindow = R6WindowTextLabelCurved(CreateWindow(Class'R6Window.R6WindowTextLabelCurved', 10.0000000, 85.0000000, 620.0000000, 30.0000000, self));
	m_FirstTabWindow.bAlwaysBehind = true;
	m_FirstTabWindow.Text = "";
	m_FirstTabWindow.m_BGTexture = none;
	// First tab row: Internet Server | LAN Server
	// Internet is added first so it appears as the leftmost tab
	m_pFirstTabManager = R6MenuMPManageTab(CreateWindow(Class'R6Menu.R6MenuMPManageTab', (10.0000000 + float(5)), 90.0000000, 500.0000000, 25.0000000, self));
	m_pFirstTabManager.AddTabInControl(Localize("MultiPlayer", "Tab_InternetServer", "R6Menu"), Localize("Tip", "Tab_InternetServer", "R6Menu"), int(1));
	m_pFirstTabManager.AddTabInControl(Localize("MultiPlayer", "Tab_LanServer", "R6Menu"), Localize("Tip", "Tab_LanServer", "R6Menu"), int(0));
	InitInfoBar();
	InitFirstTabWindow();
	InitServerInfoPlayer();
	InitServerInfoMap();
	InitServerInfoOptions();
	InitRightClickMenu();
	// Curved frame strip behind the second row of tabs (filter / server info)
	m_SecondTabWindow = R6WindowTextLabelCurved(CreateWindow(Class'R6Window.R6WindowTextLabelCurved', 10.0000000, 296.0000000, 620.0000000, 30.0000000, self));
	m_SecondTabWindow.bAlwaysBehind = true;
	m_SecondTabWindow.Text = "";
	m_SecondTabWindow.m_BGTexture = none;
	// Second tab row: Game Mode Filter | Tech Filter | Server Info
	m_pSecondTabManager = R6MenuMPManageTab(CreateWindow(Class'R6Menu.R6MenuMPManageTab', (10.0000000 + float(5)), (296.0000000 + float(5)), 600.0000000, 25.0000000, self));
	m_pSecondTabManager.AddTabInControl(Localize("MultiPlayer", "Tab_GameFilter", "R6Menu"), Localize("Tip", "Tab_GameFilter", "R6Menu"), int(2));
	m_pSecondTabManager.AddTabInControl(Localize("MultiPlayer", "Tab_TechFilter", "R6Menu"), Localize("Tip", "Tab_TechFilter", "R6Menu"), int(3));
	m_pSecondTabManager.AddTabInControl(Localize("MultiPlayer", "Tab_ServerInfo", "R6Menu"), Localize("Tip", "Tab_ServerInfo", "R6Menu"), int(4));
	m_pHelpTextWindow = R6MenuHelpWindow(CreateWindow(Class'R6Menu.R6MenuHelpWindow', 150.0000000, 429.0000000, 340.0000000, 42.0000000, self));
	m_pHelpTextWindow.m_bForceRefreshOnSameTip = true;
	// Popup windows are created at full-screen size (640x480) but hidden.
	// They are shown on demand and managed via Manager() calls in Paint().
	m_pLoginWindow = R6WindowUbiLogIn(CreateWindow(Root.MenuClassDefines.ClassUbiLogIn, 0.0000000, 0.0000000, 640.0000000, 480.0000000, self, true));
	m_pLoginWindow.m_GameService = m_GameService;
	m_pLoginWindow.PopUpBoxCreate();
	m_pLoginWindow.HideWindow();
	m_pJoinIPWindow = R6WindowJoinIP(CreateWindow(Root.MenuClassDefines.ClassMultiJoinIP, 0.0000000, 0.0000000, 640.0000000, 480.0000000, self, true));
	m_pJoinIPWindow.m_GameService = m_GameService;
	m_pJoinIPWindow.PopUpBoxCreate();
	m_pJoinIPWindow.HideWindow();
	m_pQueryServerInfo = R6WindowQueryServerInfo(CreateWindow(Root.MenuClassDefines.ClassQueryServerInfo, 0.0000000, 0.0000000, 640.0000000, 480.0000000, self, true));
	m_pQueryServerInfo.m_GameService = m_GameService;
	m_pQueryServerInfo.PopUpBoxCreate();
	m_pQueryServerInfo.HideWindow();
	// On first Tick(), restore the last tab the user had open
	m_bFPassWindowActv = true;
	// End:0x519
	// 31 = EBN_LogOut, 30 = EBN_LogIn (numeric enum values for the toggle button state)
	if(m_GameService.m_bLoggedInUbiDotCom)
	{
		m_ButtonLogInOut.SetButLogInOutState(31); // Show "Log Out"		
	}
	else
	{
		m_ButtonLogInOut.SetButLogInOutState(30); // Show "Log In"
	}
	// Pre-fill the cooldown so the user can refresh immediately when the menu opens
	m_fRefeshDeltaTime = 2.0000000;
	// Ensure any in-progress refresh from a previous session is stopped before we arrive
	m_GameService.StopRefreshServers();
	// Cache localisation strings used in the status bar to avoid per-frame Localize() calls
	m_szMultiLoc[0] = Localize("MultiPlayer", "NbOfServers", "R6Menu");
	m_szMultiLoc[1] = Localize("MultiPlayer", "NbOfPlayers", "R6Menu");
	// Page-switcher positioned to the right of the first tab row
	m_PageCount = R6WindowPageSwitch(CreateWindow(Class'R6Window.R6WindowPageSwitch', 530.0000000, 90.0000000, 90.0000000, 25.0000000, self));
	m_fLastUpdateServerFilterTime = GetTime();
	m_bNeedUpdateServerFilter = false;
	return;
}

/////////////////////////////////////////////////////////////////
// display the background
// Paint() is called every frame. As well as drawing, it acts as a per-frame
// tick for several state machines: server list polling, cursor feedback,
// selection-change detection, server info requests, and popup window management.
/////////////////////////////////////////////////////////////////
function Paint(Canvas C, float X, float Y)
{
	local R6WindowTextLabel pR6TextLabelTemp;

	Root.PaintBackground(C, self);
	// Track mouse position so DisplayRightClickMenu() can place the menu at the cursor
	m_fMouseX = X;
	m_fMouseY = Y;
	// End:0x4A
	// The LAN server manager must be pumped every frame (it polls the beacon socket).
	// The GameSpy service is pumped by R6Console, so we only need to handle LAN here.
	if((int(m_ConnectionTab) == int(0)))
	{
		m_LanServers.LANSeversManager();
	}
	// End:0xFF
	// Throttle display updates to once per second even if server data changes faster.
	// This prevents thrashing the list UI on every incoming beacon packet.
	if(((m_LanServers.m_bServerListChanged || m_GameService.m_bServerListChanged) && ((m_GameService.NativeGetMilliSeconds() - m_iTimeLastUpdate) > 1000)))
	{
		m_iTimeLastUpdate = m_GameService.NativeGetMilliSeconds();
		m_GameService.m_bServerListChanged = false;
		m_LanServers.m_bServerListChanged = false;
		// End:0xF3
		if((int(m_ConnectionTab) == int(0)))
		{
			ResortServerList(m_iLastSortCategory, m_bLastTypeOfSort);
			UpdateFilters();
			GetLanServers();			
		}
		else
		{
			UpdateFilters();
			GetGSServers();
		}
	}
	// End:0x18E
	// Internet tab: handle end-of-refresh and cursor feedback
	if((int(m_ConnectionTab) == int(1)))
	{
		// End:0x151
		// When GameSpy finishes a full server refresh, re-sort and repopulate the list
		if(m_GameService.m_bRefreshFinished)
		{
			m_GameService.m_bRefreshFinished = false;
			ResortServerList(m_iLastSortCategory, m_bLastTypeOfSort);
			GetGSServers();
			m_bGetServerInfo = true; // request updated detail info for currently selected server
		}
		// End:0x177
		// Show wait cursor while a GameSpy refresh is in-flight
		if(m_GameService.IsRefreshServersInProgress())
		{
			SetCursor(Root.WaitCursor);			
		}
		else
		{
			SetCursor(Root.NormalCursor);
		}		
	}
	else
	{
		SetCursor(Root.NormalCursor);
	}
	// End:0x272
	// Detect server selection changes by comparing against the cached previous selection
	if((m_ServerListBox.m_SelectedItem != m_oldSelItem))
	{
		m_oldSelItem = m_ServerListBox.m_SelectedItem;
		// End:0x22B
		if((int(m_ConnectionTab) == int(0)))
		{
			// End:0x21D
			if((m_ServerListBox.m_SelectedItem != none))
			{
				m_LanServers.SetSelectedServer(R6WindowListServerItem(m_ServerListBox.m_SelectedItem).iMainSvrListIdx);
			}
			GetServerInfo(m_LanServers); // LAN: info comes directly from beacon data		
		}
		else
		{
			// End:0x26A
			if((m_ServerListBox.m_SelectedItem != none))
			{
				m_GameService.SetSelectedServer(R6WindowListServerItem(m_ServerListBox.m_SelectedItem).iMainSvrListIdx);
			}
			// Internet: detailed info must be fetched asynchronously from ubi.com
			m_bGetServerInfo = true;
		}
	}
	// End:0x325
	// If Server Info tab is visible and info is needed, request it from ubi.com (NativeMSClientReqAltInfo).
	// Only request when no refresh is in progress — the SDK comment notes this limitation may change.
	if((((m_bGetServerInfo && (!m_GameService.IsRefreshServersInProgress())) && (int(m_ConnectionTab) == int(1))) && (int(m_FilterTab) == int(4))))
	{
		// End:0x317
		if((m_GameService.m_GameServerList.Length > 0))
		{
			m_GameService.NativeMSClientReqAltInfo(m_GameService.m_GameServerList[m_GameService.m_iSelSrvIndex].iLobbySrvID, m_GameService.m_GameServerList[m_GameService.m_iSelSrvIndex].iGroupID);
		}
		ClearServerInfo();
		m_bGetServerInfo = false;
	}
	// End:0x365
	// When the detailed server info arrives asynchronously, refresh the display
	if((m_GameService.m_bServerInfoChanged && (int(m_ConnectionTab) == int(1))))
	{
		GetServerInfo(m_GameService);
		m_GameService.m_bServerInfoChanged = false;
	}
	// End:0x38C
	// If the ubi.com router dropped us, force a re-login (eLSAct_CloseWindow = 5)
	if(m_GameService.NativeIsRouterDisconnect())
	{
		m_LoginSuccessAction = 5;
		m_pLoginWindow.LogInAfterDisconnect(self);
	}
	// End:0x3AC
	// Drive the login popup state machine while a login action is pending
	if((int(m_LoginSuccessAction) != int(0)))
	{
		m_pLoginWindow.Manager(self);
	}
	// End:0x3C5
	// Drive the Join-by-IP popup state machine while it is active
	if(m_bJoinIPInProgress)
	{
		m_pJoinIPWindow.Manager(self);
	}
	// End:0x3DE
	// Drive the pre-join server query popup state machine while it is active
	if(m_bQueryServerInfoInProgress)
	{
		m_pQueryServerInfo.Manager(self);
	}
	// End:0x406
	// Disable the Join button if no server is selected or the server is a different game version
	if((m_ServerListBox.m_SelectedItem == none))
	{
		m_ButtonJoin.bDisabled = true;		
	}
	else
	{
		// End:0x43C
		if((!R6WindowListServerItem(m_ServerListBox.m_SelectedItem).bSameVersion))
		{
			m_ButtonJoin.bDisabled = true; // Version mismatch — joining would fail			
		}
		else
		{
			m_ButtonJoin.bDisabled = false;
		}
	}
	return;
}

// Called when the widget becomes visible (e.g. user navigates to the multiplayer screen).
// The LanServers object and the ClientBeaconReceiver actor are created here rather than
// in Created(), because actors are destroyed on level changes — so we must re-spawn them
// whenever the menu is shown after a level transition.
function ShowWindow()
{
	local string _szIPAddress;

	// Registering the CD key manager user slot 15 links this widget as the recipient
	// of CD key validation results
	R6MenuRootWindow(Root).m_pMenuCDKeyManager.SetWindowUser(Root.15, self);
	// End:0x97
	// Create the LAN server manager on first show (deferred to avoid wasting memory
	// when the user never visits the multiplayer screen)
	if((m_LanServers == none))
	{
		m_LanServers = new (none) Class<R6LanServers>(Root.MenuClassDefines.ClassLanServer);
		R6Console(Root.Console).m_LanServers = m_LanServers;
		m_LanServers.Created();
		InitServerList();      // Creates the scrollable server list box
		InitSecondTabWindow(); // Creates game-mode, tech-filter, and server-info panels
	}
	// End:0xE6
	// ClientBeaconReceiver is an Actor, so it gets destroyed with levels.
	// Re-spawn it here whenever it is missing.
	if((m_LanServers.m_ClientBeacon == none))
	{
		m_LanServers.m_ClientBeacon = Root.Console.ViewportOwner.Actor.Spawn(Class'IpDrv.ClientBeaconReceiver');
	}
	// Share the beacon reference with the GameSpy service so both can use the same socket
	m_GameService.m_ClientBeacon = m_LanServers.m_ClientBeacon;
	// Default sort is by ping time, ascending
	m_iLastSortCategory = int(m_LanServers.4);
	m_bLastTypeOfSort = true;
	super(UWindowWindow).ShowWindow();
	// Initialise the CD key on the GameSpy client (needed before any internet join)
	R6Console(Root.Console).m_GameService.InitGSCDKey();
	// Pick a random multiplayer background image for this session
	Root.SetLoadRandomBackgroundImage("Multiplayer");
	// End:0x1B5
	// Non-ubi.com match making (e.g. ASE/All-Seeing Eye) provides the server IP
	// via a command-line argument; bypass the normal join flow and go direct
	if(R6Console(Root.Console).m_bNonUbiMatchMaking)
	{
		Class'Engine.Actor'.static.NativeNonUbiMatchMakingAddress(_szIPAddress);
		m_pJoinIPWindow.StartCmdLineJoinIPProcedure(m_ButtonJoinIP, _szIPAddress);
		m_bJoinIPInProgress = true;
	}
	return;
}

/////////////////////////////////////////////////////////////////
// display the help text in the m_pHelpTextWindow (derivate for uwindowwindow
/////////////////////////////////////////////////////////////////
// UWindow calls this when a child widget provides a tool-tip string.
function ToolTip(string strTip)
{
	ManageToolTip(strTip);
	return;
}

// Displays server count and total-player count in the help text bar.
// When _bForceATip is true the player count is refreshed even if a tooltip string is provided.
// When _strTip is empty the default "N Servers / N Players" status text is shown.
function ManageToolTip(string _strTip, optional bool _bForceATip)
{
	local string szTemp1, szTemp2;
	local int iNbOfServers;

	// End:0x1A
	if(((m_pHelpTextWindow == none) || (!bWindowVisible)))
	{
		return;
	}
	szTemp1 = _strTip;
	szTemp2 = "";
	// End:0x73
	if(_bForceATip)
	{
		// End:0x5E
		if((int(m_ConnectionTab) == int(1)))
		{
			m_iTotalPlayers = m_GameService.GetTotalPlayers();			
		}
		else
		{
			m_iTotalPlayers = m_LanServers.GetTotalPlayers();
		}
	}
	// End:0xF2
	if((_strTip == ""))
	{
		// End:0xA7
		if((int(m_ConnectionTab) == int(1)))
		{
			iNbOfServers = m_GameService.m_GameServerList.Length;			
		}
		else
		{
			iNbOfServers = m_LanServers.m_GameServerList.Length;
		}
		szTemp1 = ((m_szMultiLoc[0] $ " ") $ string(iNbOfServers));
		szTemp2 = ((m_szMultiLoc[1] $ " ") $ string(m_iTotalPlayers));
	}
	m_pHelpTextWindow.ToolTip(szTemp1);
	// End:0x126
	if((szTemp2 != ""))
	{
		m_pHelpTextWindow.AddTipText(szTemp2);
	}
	return;
}

/////////////////////////////////////////////////////////////////
// manage the tab selection (the call of the fct come from R6MenuMPManageTab
// Handles both the top connection tabs (LAN / Internet) and the bottom filter tabs.
/////////////////////////////////////////////////////////////////
function ManageTabSelection(int _MPTabChoiceID)
{
	switch(_MPTabChoiceID)
	{
		// End:0x59
		// TAB_Lan_Server (0): switch to LAN browser, auto-refresh if list is empty
		case int(0):
			m_ConnectionTab = 0;
			// End:0x32
			if((m_LanServers.m_GameServerList.Length == 0))
			{
				Refresh(false); // Not user-initiated, so the cooldown doesn't apply
			}
			GetLanServers();
			GetServerInfo(m_LanServers);
			UpdateServerFilters();
			m_iLastTabSel = int(0);
			SaveConfig(); // Persist tab choice so we return here next session
			// End:0x22E
			break;
		// End:0xB8
		// TAB_Internet_Server (1): begin login flow before showing internet servers
		// m_LoginSuccessAction = 3 (eLSAct_InternetTab) tells login success handler to do a Refresh
		case int(1):
			m_ConnectionTab = 1;
			m_LoginSuccessAction = 3; // eLSAct_InternetTab — refresh list after login
			m_pLoginWindow.StartLogInProcedure(self);
			// End:0x9C
			if((m_GameService.m_GameServerList.Length == 0))
			{
				Refresh(false);
			}
			GetGSServers();
			UpdateServerFilters();
			m_iLastTabSel = int(1);
			SaveConfig();
			// End:0x22E
			break;
		// End:0x120
		// TAB_Game_Mode (2): show game-type checkboxes, hide server detail panels
		case int(2):
			m_FilterTab = 2;
			m_ServerInfoPlayerBox.HideWindow();
			m_ServerInfoMapBox.HideWindow();
			m_ServerInfoOptionsBox.HideWindow();
			m_pSecondWindow.HideWindow();
			m_pSecondWindowGameMode.ShowWindow();
			m_pSecondWindow = m_pSecondWindowGameMode;
			// End:0x22E
			break;
		// End:0x188
		// TAB_Tech_Filter (3): show technical filter checkboxes (ping, dedicated, PunkBuster, etc.)
		case int(3):
			m_FilterTab = 3;
			m_ServerInfoPlayerBox.HideWindow();
			m_ServerInfoMapBox.HideWindow();
			m_ServerInfoOptionsBox.HideWindow();
			m_pSecondWindow.HideWindow();
			m_pSecondWindowFilter.ShowWindow();
			m_pSecondWindow = m_pSecondWindowFilter;
			// End:0x22E
			break;
		// End:0x1F0
		// TAB_Server_Info (4): show the three server detail boxes (players, maps, options)
		case int(4):
			m_FilterTab = 4;
			m_pSecondWindow.HideWindow();
			m_pSecondWindowServerInfo.ShowWindow();
			m_ServerInfoPlayerBox.ShowWindow();
			m_ServerInfoMapBox.ShowWindow();
			m_ServerInfoOptionsBox.ShowWindow();
			m_pSecondWindow = m_pSecondWindowServerInfo;
			// End:0x22E
			break;
		// End:0xFFFF
		default:
			Log("This tab was not supported (R6MenuMultiPlayerWidget)");
			// End:0x22E
			break;
			break;
	}
	return;
}

/////////////////////////////////////////////////////////////////
// set the button choice from game mode, tech filters
// Called by child tab panels when a filter checkbox is toggled.
// DIVERGENCE from SDK 1.56: In 1.56 this function wrote directly to
// m_LanServers.m_Filters and m_GameService.m_Filters structs. In 1.60
// the filter state is stored as local config booleans on this widget,
// and UpdateFilters() reads them during its per-server sweep. This
// allows the filters to be saved to User.ini via SaveConfig().
/////////////////////////////////////////////////////////////////
function SetServerFilterBooleans(int _iServerInfoID, bool _bNewChoice)
{
	switch(_iServerInfoID)
	{
		// End:0x1E
		case int(0): // eServerInfoID_DeathMatch
			m_bFilterDeathMatch = _bNewChoice;
			// End:0x1B1
			break;
		// End:0x35
		case int(1): // eServerInfoID_TeamDeathMatch
			m_bFilterTeamDeathMatch = _bNewChoice;
			// End:0x1B1
			break;
		// End:0x4C
		case int(2): // eServerInfoID_Bomb
			m_bFilterDisarmBomb = _bNewChoice;
			// End:0x1B1
			break;
		// End:0x63
		case int(3): // eServerInfoID_HostageAdv
			m_bFilterHostageRescueAdv = _bNewChoice;
			// End:0x1B1
			break;
		// End:0x7A
		case int(4): // eServerInfoID_Escort
			m_bFilterEscortPilot = _bNewChoice;
			// End:0x1B1
			break;
		// End:0x91
		case int(5): // eServerInfoID_Mission
			m_bFilterMission = _bNewChoice;
			// End:0x1B1
			break;
		// End:0xA8
		case int(6): // eServerInfoID_Terrorist
			m_bFilterTerroristHunt = _bNewChoice;
			// End:0x1B1
			break;
		// End:0xBF
		case int(7): // eServerInfoID_HostageCoop
			m_bFilterHostageRescueCoop = _bNewChoice;
			// End:0x1B1
			break;
		// End:0xD6
		case int(10): // eServerInfoID_Unlocked — note: no cases 8 or 9 (Defend/Recon removed in 1.60)
			m_bFilterUnlockedOnly = _bNewChoice;
			// End:0x1B1
			break;
		// End:0xED
		case int(11): // eServerInfoID_Favorites
			m_bFilterFavoritesOnly = _bNewChoice;
			// End:0x1B1
			break;
		// End:0x104
		case int(12): // eServerInfoID_Dedicated
			m_bFilterDedicatedServersOnly = _bNewChoice;
			// End:0x1B1
			break;
		// End:0x11B
		case int(13): // eServerInfoID_PunkBuster
			m_bFilterPunkBusterServerOnly = _bNewChoice;
			// End:0x1B1
			break;
		// End:0x132
		case int(14): // eServerInfoID_NotEmpty
			m_bFilterServersNotEmpty = _bNewChoice;
			// End:0x1B1
			break;
		// End:0x149
		case int(15): // eServerInfoID_NotFull
			m_bFilterServersNotFull = _bNewChoice;
			// End:0x1B1
			break;
		// End:0x160
		case int(16): // eServerInfoID_Responding (ping < 1000 ms)
			m_bFilterResponding = _bNewChoice;
			// End:0x1B1
			break;
		// End:0x177
		case int(18): // eServerInfoID_SameVersion
			m_bFilterSameVersion = _bNewChoice;
			// End:0x1B1
			break;
		// End:0xFFFF
		default:
			Log("Sorry, no server info associate with this button");
			// End:0x1B1
			break;
			break;
	}
	// Debounce: if another filter was changed very recently, defer the full update.
	// This prevents cascading filter passes when the user rapidly clicks checkboxes.
	if((GetTime() < (m_fLastUpdateServerFilterTime + 0.3000000)))
	{
		m_bNeedUpdateServerFilter = true;
		return;
	}
	m_bNeedUpdateServerFilter = false;
	UpdateServerFilters();
	return;
}

//-------------------------------------------------------
// SetServerFilterFasterThan - Set the "Faster Than" filter
// setting (ping time). Servers with ping above this value
// are hidden; 0 disables the filter.
//-------------------------------------------------------
function SetServerFilterFasterThan(int iFasterThan)
{
	m_iFilterFasterThan = iFasterThan;
	UpdateServerFilters();
	return;
}

//-------------------------------------------------------
// UpdateServerFilters - Call this every time one of the
// filter settings changes, it we check the list of servers
// to see whcih ones should be displayed.
// Also updates the visual state of the checkbox buttons
// in both filter panels, then re-sorts and saves config.
//-------------------------------------------------------
function UpdateServerFilters()
{
	// Sync checkbox button visual states with the current filter booleans
	m_pSecondWindowGameMode.UpdateGameTypeFilter();
	m_pSecondWindowFilter.UpdateGameTypeFilter();
	// End:0x40
	if((int(m_ConnectionTab) == int(0)))
	{
		UpdateFilters(); // Mark each server as visible/hidden based on active filters
		SaveConfig();    // Persist filter settings to User.ini
		GetLanServers(); // Rebuild the displayed list		
	}
	else
	{
		UpdateFilters();
		SaveConfig();
		GetGSServers();
	}
	m_fLastUpdateServerFilterTime = GetTime(); // Update debounce timestamp
	return;
}

// NEW IN 1.60
// UpdateFilters - Iterates over the entire server list (LAN or Internet) and sets
// each entry's bDisplay flag. This replaced the SDK 1.56 approach of calling
// UpdateFilters() on the server list objects themselves; the filter booleans are
// now owned by this widget so they can be persisted to User.ini via SaveConfig().
// The goto J0x503 pattern is the decompiler's representation of a loop `continue`.
function UpdateFilters()
{
	local R6ModMgr pModMgr;
	local int i, j, iNbOfServers;
	local bool bFound, bIsRavenShield, bIsLanServers;
	local string szCurrentMod, szTempGDGameType;
	local stGameServer stTempGameServerItem;

	pModMgr = Class'Engine.Actor'.static.GetModMgr();
	szCurrentMod = pModMgr.m_pCurrentMod.m_szKeyWord; // e.g. "RavenShield" or a mod name
	bIsLanServers = (int(m_ConnectionTab) == int(0));
	// End:0x64
	if(bIsLanServers)
	{
		iNbOfServers = m_LanServers.m_GameServerList.Length;		
	}
	else
	{
		iNbOfServers = m_GameService.m_GameServerList.Length;
	}
	i = 0;
	J0x80:

	// End:0x50D [Loop If]
	if((i < iNbOfServers))
	{
		// Default each server to hidden; only set bDisplay=true if it passes all filters
		if(bIsLanServers)
		{
			m_LanServers.m_GameServerList[i].bDisplay = false;
			stTempGameServerItem = m_LanServers.m_GameServerList[i];			
		}
		else
		{
			m_GameService.m_GameServerList[i].bDisplay = false;
			stTempGameServerItem = m_GameService.m_GameServerList[i];
		}
		szTempGDGameType = stTempGameServerItem.sGameData.szGameDataGameType;
		// End:0x14A
		// Skip (continue) if the game type filter is OFF for this game mode.
		// Each check below is: "if this type is disabled AND the server is running it, skip it"
		if(((!m_bFilterDeathMatch) && (szTempGDGameType == "RGM_DeathmatchMode")))
		{
			// [Explicit Continue]
			goto J0x503;
		}
		// End:0x17C
		if(((!m_bFilterTeamDeathMatch) && (szTempGDGameType == "RGM_TeamDeathmatchMode")))
		{
			// [Explicit Continue]
			goto J0x503;
		}
		// End:0x1A7
		if(((!m_bFilterDisarmBomb) && (szTempGDGameType == "RGM_BombAdvMode")))
		{
			// [Explicit Continue]
			goto J0x503;
		}
		// End:0x1DB
		if(((!m_bFilterHostageRescueAdv) && (szTempGDGameType == "RGM_HostageRescueAdvMode")))
		{
			// [Explicit Continue]
			goto J0x503;
		}
		// End:0x208
		if(((!m_bFilterEscortPilot) && (szTempGDGameType == "RGM_EscortAdvMode")))
		{
			// [Explicit Continue]
			goto J0x503;
		}
		// End:0x233
		if(((!m_bFilterMission) && (szTempGDGameType == "RGM_MissionMode")))
		{
			// [Explicit Continue]
			goto J0x503;
		}
		// End:0x268
		if(((!m_bFilterTerroristHunt) && (szTempGDGameType == "RGM_TerroristHuntCoopMode")))
		{
			// [Explicit Continue]
			goto J0x503;
		}
		// End:0x29D
		if(((!m_bFilterHostageRescueCoop) && (szTempGDGameType == "RGM_HostageRescueCoopMode")))
		{
			// [Explicit Continue]
			goto J0x503;
		}
		// End:0x327
		// Hide servers running a different mod than the currently active one
		if(((stTempGameServerItem.sGameData.szModName != "") && (!(stTempGameServerItem.sGameData.szModName ~= szCurrentMod))))
		{
			Log((("UpdateFilters() szModName is different than current MOD " @ stTempGameServerItem.sGameData.szModName) @ szCurrentMod));
			// [Explicit Continue]
			goto J0x503;
		}
		// End:0x348
		// "Unlocked Only" hides password-protected servers
		if((m_bFilterUnlockedOnly && stTempGameServerItem.sGameData.bUsePassword))
		{
			// [Explicit Continue]
			goto J0x503;
		}
		// End:0x366
		if((m_bFilterFavoritesOnly && (!stTempGameServerItem.bFavorite)))
		{
			// [Explicit Continue]
			goto J0x503;
		}
		// End:0x389
		if((m_bFilterDedicatedServersOnly && (!stTempGameServerItem.sGameData.bDedicatedServer)))
		{
			// [Explicit Continue]
			goto J0x503;
		}
		// End:0x3AC
		if((m_bFilterServersNotEmpty && (stTempGameServerItem.sGameData.iNbrPlayer == 0)))
		{
			// [Explicit Continue]
			goto J0x503;
		}
		// End:0x3F8
		// "Not Full" check uses the list-item's iMaxPlayer field (LAN and Internet differ)
		if(bIsLanServers)
		{
			// End:0x3F5
			if((m_bFilterServersNotFull && (stTempGameServerItem.sGameData.iNbrPlayer >= m_LanServers.m_GameServerList[i].sGameData.iMaxPlayer)))
			{
				// [Explicit Continue]
				goto J0x503;
			}			
		}
		else
		{
			// End:0x438
			if((m_bFilterServersNotFull && (stTempGameServerItem.sGameData.iNbrPlayer >= m_GameService.m_GameServerList[i].sGameData.iMaxPlayer)))
			{
				// [Explicit Continue]
				goto J0x503;
			}
		}
		// End:0x45B
		if((m_bFilterPunkBusterServerOnly && (!stTempGameServerItem.sGameData.bPunkBuster)))
		{
			// [Explicit Continue]
			goto J0x503;
		}
		// End:0x47D
		// "Responding" means the server replied within 1000 ms
		if((m_bFilterResponding && (stTempGameServerItem.iPing >= 1000)))
		{
			// [Explicit Continue]
			goto J0x503;
		}
		// End:0x4A1
		// "Faster Than" is a user-set ping ceiling (0 = disabled)
		if(((m_iFilterFasterThan > 0) && (stTempGameServerItem.iPing > m_iFilterFasterThan)))
		{
			// [Explicit Continue]
			goto J0x503;
		}
		// End:0x4BF
		if((m_bFilterSameVersion && (!stTempGameServerItem.bSameVersion)))
		{
			// [Explicit Continue]
			goto J0x503;
		}
		// End:0x4E7
		// Server passed all filters — mark it visible
		if(bIsLanServers)
		{
			m_LanServers.m_GameServerList[i].bDisplay = true;
			// [Explicit Continue]
			goto J0x503;
		}
		m_GameService.m_GameServerList[i].bDisplay = true;
		J0x503:

		(i++);
		// [Loop Continue]
		goto J0x80;
	}
	return;
}

//==============================================================================
// Refresh - Refresh the list of servers. Clears the list then calls the
// appropriate function to completely rebuild the list of servers with
// fresh data.
// bActivatedByUser: true when the player presses the Refresh button.
// The K_REFRESH_TIMEOUT cooldown prevents spamming when user-activated.
//==============================================================================
function Refresh(bool bActivatedByUser)
{
	local int i;

	// End:0x28
	// Guard against rapid button presses: only allow user-initiated refresh
	// if enough time has elapsed since the last one
	if(bActivatedByUser)
	{
		// End:0x26
		if((m_fRefeshDeltaTime > 2.0000000))
		{
			m_fRefeshDeltaTime = 0.0000000; // Reset cooldown timer			
		}
		else
		{
			return; // Too soon — ignore
		}
	}
	m_oldSelItem = none; // Clear the cached selection so it doesn't confuse the selection-change logic
	// End:0xB8
	if((int(m_ConnectionTab) == int(0)))
	{
		m_LanServers.RefreshServers();
		ResortServerList(m_iLastSortCategory, m_bLastTypeOfSort);
		GetLanServers();
		// Clear all pending beacon entries so stale data doesn't appear
		i = 0;
		J0x6C:

		// End:0xB5 [Loop If]
		if((i < m_LanServers.m_ClientBeacon.GetBeaconListSize()))
		{
			m_LanServers.m_ClientBeacon.ClearBeacon(i);
			(i++);
			// [Loop Continue]
			goto J0x6C;
		}		
	}
	else
	{
		// End:0xD6
		// Internet refresh only possible when logged in to ubi.com
		if(m_GameService.m_bLoggedInUbiDotCom)
		{
			m_GameService.RefreshServers();
		}
	}
	return;
}

//==============================================================================
// GetLanServers - Reads the pre-built LAN server list from m_LanServers and
// populates the scrollable server list box. Does not request new data.
// Only entries flagged bDisplay=true (by UpdateFilters) are shown.
// Pagination: only entries for the current page window are created as list items.
//==============================================================================
function GetLanServers()
{
	local R6WindowListServerItem NewItem;
	local int i, j, iNumServers, iNumServersDisplay;
	local string szSelSvrIP; // IP of currently selected server (preserved across rebuilds)
	local bool bFirstSvr;    // First visible server auto-selected as default
	local string szGameType;
	local LevelInfo pLevel;
	local R6Console Console;
	local int iNbPages, iStartingIndex, iEndIndex;
	local stGameServer _stGameServer;

	Console = R6Console(Root.Console);
	pLevel = GetLevel();
	// End:0x5E
	// Remember the selected server's IP so we can re-select it after rebuilding the list
	if((m_ServerListBox.m_SelectedItem != none))
	{
		szSelSvrIP = R6WindowListServerItem(m_ServerListBox.m_SelectedItem).szIPAddr;		
	}
	else
	{
		szSelSvrIP = "";
	}
	m_ServerListBox.ClearListOfItems(); // Wipe all current list entries
	m_ServerListBox.m_SelectedItem = none;
	iNumServers = m_LanServers.m_GameServerList.Length;
	iNumServersDisplay = m_LanServers.GetDisplayListSize(); // Count after filter
	bFirstSvr = true;
	// Calculate pagination: page indices are 1-based
	iNbPages = (iNumServersDisplay / Console.iBrowserMaxNbServerPerPage);
	(iNbPages += 1);
	// End:0x103
	// Cap current page to the new total (prevents being on page 5 of 2)
	if((m_PageCount.m_iCurrentPages > iNbPages))
	{
		m_PageCount.SetCurrentPage(iNbPages);
	}
	// End:0x12F
	if((iNbPages != m_PageCount.m_iTotalPages))
	{
		m_PageCount.SetTotalPages(iNbPages);
	}
	iStartingIndex = (Console.iBrowserMaxNbServerPerPage * (m_PageCount.m_iCurrentPages - 1));
	iEndIndex = (iStartingIndex + Console.iBrowserMaxNbServerPerPage);
	// End:0x18B
	if((iEndIndex > iNumServersDisplay))
	{
		iEndIndex = iNumServersDisplay;
	}
	j = 0;
	i = iStartingIndex;
	J0x19D:

	// End:0x52C [Loop If]
	if((iNumServersDisplay > 0))
	{
		// End:0x4F7
		// m_GSLSortIdx is the sort-order indirection array; use it to walk servers in sorted order
		if(m_LanServers.m_GameServerList[m_LanServers.m_GSLSortIdx[i]].bDisplay)
		{
			NewItem = R6WindowListServerItem(m_ServerListBox.GetNextItem(j, NewItem));
			NewItem.Created();
			NewItem.iMainSvrListIdx = i;
			m_LanServers.getServerListItem(i, _stGameServer);
			NewItem.bFavorite = _stGameServer.bFavorite;
			NewItem.bSameVersion = _stGameServer.bSameVersion; // Used to disable Join button
			NewItem.szIPAddr = _stGameServer.szIPAddress;
			NewItem.iPing = _stGameServer.iPing;
			NewItem.szName = _stGameServer.sGameData.szName;
			NewItem.szMap = _stGameServer.sGameData.szCurrentMap;
			NewItem.iMaxPlayers = _stGameServer.sGameData.iMaxPlayer;
			NewItem.iNumPlayers = _stGameServer.sGameData.iNbrPlayer;
			szGameType = _stGameServer.sGameData.szGameDataGameType;
			NewItem.bLocked = _stGameServer.sGameData.bUsePassword;
			NewItem.bDedicated = _stGameServer.sGameData.bDedicatedServer;
			NewItem.bPunkBuster = _stGameServer.sGameData.bPunkBuster;
			Root.GetMapNameLocalisation(NewItem.szMap, NewItem.szMap, true); // Localise map display name
			NewItem.szGameType = pLevel.GetGameNameLocalization(szGameType);  // e.g. "Deathmatch"
			// End:0x432
			// "Game Mode" in UI = Adversarial or Cooperative; "Game Type" = specific mode within that
			if(pLevel.IsGameTypeAdversarial(szGameType))
			{
				NewItem.szGameMode = Localize("MultiPlayer", "GameMode_Adversarial", "R6Menu");				
			}
			else
			{
				// End:0x48C
				if(pLevel.IsGameTypeCooperative(szGameType))
				{
					NewItem.szGameMode = Localize("MultiPlayer", "GameMode_Cooperative", "R6Menu");					
				}
				else
				{
					NewItem.szGameMode = ""; // Unknown/unsupported game type
				}
			}
			// End:0x4E8
			// Re-select this server if its IP matches the previously selected one,
			// or select it as default if it's the first visible entry
			if(((NewItem.szIPAddr == szSelSvrIP) || bFirstSvr))
			{
				m_ServerListBox.SetSelectedItem(NewItem);
				m_LanServers.SetSelectedServer(i);
			}
			bFirstSvr = false;
			(j++);
		}
		(i++);
		// End:0x517
		if(((iStartingIndex + j) >= iEndIndex))
		{
			// [Explicit Break]
			goto J0x52C;
		}
		// End:0x529
		if((i >= iNumServers))
		{
			// [Explicit Break]
			goto J0x52C;
		}
		// [Loop Continue]
		goto J0x19D;
	}
	J0x52C:

	ManageToolTip("", true);
	return;
}

//==============================================================================
// GetGSServers - Same as GetLanServers but reads from the GameSpy / ubi.com
// server list (m_GameService). Only called when on the Internet tab.
//==============================================================================
function GetGSServers()
{
	local R6WindowListServerItem NewItem;
	local int i, j, iNumServers, iNumServersDisplay;
	local string szSelSvrIP;
	local bool bFirstSvr;
	local string szGameType;
	local LevelInfo pLevel;
	local R6Console Console;
	local int iNbPages, iStartingIndex, iEndIndex;
	local stGameServer _stGameServer;

	Console = R6Console(Root.Console);
	pLevel = GetLevel();
	// End:0x5E
	if((m_ServerListBox.m_SelectedItem != none))
	{
		szSelSvrIP = R6WindowListServerItem(m_ServerListBox.m_SelectedItem).szIPAddr;		
	}
	else
	{
		szSelSvrIP = "";
	}
	m_ServerListBox.ClearListOfItems();
	m_ServerListBox.m_SelectedItem = none;
	iNumServers = m_GameService.m_GameServerList.Length;
	iNumServersDisplay = m_GameService.GetDisplayListSize();
	bFirstSvr = true;
	iNbPages = (iNumServersDisplay / Console.iBrowserMaxNbServerPerPage);
	(iNbPages += 1);
	// End:0x103
	if((m_PageCount.m_iCurrentPages > iNbPages))
	{
		m_PageCount.SetCurrentPage(iNbPages);
	}
	// End:0x12F
	if((iNbPages != m_PageCount.m_iTotalPages))
	{
		m_PageCount.SetTotalPages(iNbPages);
	}
	iStartingIndex = (Console.iBrowserMaxNbServerPerPage * (m_PageCount.m_iCurrentPages - 1));
	iEndIndex = (iStartingIndex + Console.iBrowserMaxNbServerPerPage);
	// End:0x18B
	if((iEndIndex > iNumServersDisplay))
	{
		iEndIndex = iNumServersDisplay;
	}
	j = 0;
	i = iStartingIndex;
	J0x19D:

	// End:0x518 [Loop If]
	if((iNumServersDisplay > 0))
	{
		// End:0x4E3
		if(m_GameService.m_GameServerList[m_GameService.m_GSLSortIdx[i]].bDisplay)
		{
			NewItem = R6WindowListServerItem(m_ServerListBox.GetNextItem(j, NewItem));
			NewItem.Created();
			NewItem.iMainSvrListIdx = i;
			m_GameService.getServerListItem(i, _stGameServer);
			NewItem.bFavorite = _stGameServer.bFavorite;
			NewItem.bSameVersion = _stGameServer.bSameVersion;
			NewItem.szIPAddr = _stGameServer.szIPAddress;
			NewItem.iPing = _stGameServer.iPing;
			NewItem.szName = _stGameServer.sGameData.szName;
			NewItem.szMap = _stGameServer.sGameData.szCurrentMap;
			NewItem.iMaxPlayers = _stGameServer.sGameData.iMaxPlayer;
			NewItem.iNumPlayers = _stGameServer.sGameData.iNbrPlayer;
			szGameType = _stGameServer.sGameData.szGameDataGameType;
			NewItem.bLocked = _stGameServer.sGameData.bUsePassword;
			NewItem.bDedicated = _stGameServer.sGameData.bDedicatedServer;
			NewItem.bPunkBuster = _stGameServer.sGameData.bPunkBuster;
			Root.GetMapNameLocalisation(NewItem.szMap, NewItem.szMap, true);
			NewItem.szGameType = pLevel.GetGameNameLocalization(szGameType);
			// End:0x432
			if(pLevel.IsGameTypeAdversarial(szGameType))
			{
				NewItem.szGameMode = Localize("MultiPlayer", "GameMode_Adversarial", "R6Menu");				
			}
			else
			{
				// End:0x489
				if(pLevel.IsGameTypeCooperative(szGameType))
				{
					NewItem.szGameMode = Localize("MultiPlayer", "GameMode_Cooperative", "R6Menu");
				}
			}
			// End:0x4D4
			if(((NewItem.szIPAddr == szSelSvrIP) || bFirstSvr))
			{
				m_ServerListBox.SetSelectedItem(NewItem);
				m_GameService.SetSelectedServer(i);
			}
			bFirstSvr = false;
			(j++);
		}
		(i++);
		// End:0x503
		if(((iStartingIndex + j) >= iEndIndex))
		{
			// [Explicit Break]
			goto J0x518;
		}
		// End:0x515
		if((i >= iNumServers))
		{
			// [Explicit Break]
			goto J0x518;
		}
		// [Loop Continue]
		goto J0x19D;
	}
	J0x518:

	ManageToolTip("", true);
	return;
}

//==============================================================================
// GetServerInfo - Populates the three Server Info panels (players, maps, options)
// with data from the currently selected server in the given server list.
// Does not request new data from the network; just reads what is cached.
// Button enum values: 1=RoundsPerMatch, 2=RoundTime, 4=BombTimer, 7=TimeBetweenRounds,
//   8=NbTerro, 11=FriendlyFire, 12=AllowTeamNames, 13=AutoBalTeam, 14=TKPenalty,
//   15=AllowRadar, 16=RotateMap, 17=AIBkp, 18=ForceFPWeapon
//==============================================================================
function GetServerInfo(R6ServerList pServerList)
{
	local R6WindowListInfoPlayerItem NewItemPlayer;
	local R6WindowListInfoMapItem NewItemMap;
	local R6WindowListInfoOptionsItem NewItemOptions;
	local R6MenuButtonsDefines pButtonsDef;
	local int i, iNum;

	ClearServerInfo();
	// End:0x1D
	if((pServerList.m_GameServerList.Length == 0))
	{
		return;
	}
	iNum = pServerList.m_GameServerList[pServerList.m_iSelSrvIndex].sGameData.gameMapList.Length;
	i = 0;
	J0x52:

	// End:0x148 [Loop If]
	if((i < iNum))
	{
		NewItemMap = R6WindowListInfoMapItem(m_ServerInfoMapBox.GetItemAtIndex(i));
		NewItemMap.szMap = pServerList.m_GameServerList[pServerList.m_iSelSrvIndex].sGameData.gameMapList[i].szMap;
		Root.GetMapNameLocalisation(NewItemMap.szMap, NewItemMap.szMap, true);
		NewItemMap.szType = GetLevel().GetGameNameLocalization(pServerList.m_GameServerList[pServerList.m_iSelSrvIndex].sGameData.gameMapList[i].szGameType);
		(i++);
		// [Loop Continue]
		goto J0x52;
	}
	iNum = pServerList.m_GameServerList[pServerList.m_iSelSrvIndex].sGameData.PlayerList.Length;
	// Sort players by kills descending before displaying
	pServerList.SortPlayersByKills(false, pServerList.m_iSelSrvIndex);
	i = 0;
	J0x19B:

	// End:0x2E7 [Loop If]
	if((i < iNum))
	{
		NewItemPlayer = R6WindowListInfoPlayerItem(m_ServerInfoPlayerBox.GetItemAtIndex(i));
		NewItemPlayer.szPlName = pServerList.m_GameServerList[pServerList.m_iSelSrvIndex].sGameData.PlayerList[i].szAlias;
		NewItemPlayer.iSkills = pServerList.m_GameServerList[pServerList.m_iSelSrvIndex].sGameData.PlayerList[i].iSkills;
		NewItemPlayer.szTime = pServerList.m_GameServerList[pServerList.m_iSelSrvIndex].sGameData.PlayerList[i].szTime;
		NewItemPlayer.iPing = pServerList.m_GameServerList[pServerList.m_iSelSrvIndex].sGameData.PlayerList[i].iPing;
		NewItemPlayer.iRank = 0; // Rank display was TODO in 1.56; still unimplemented in 1.60
		(i++);
		// [Loop Continue]
		goto J0x19B;
	}
	pButtonsDef = R6MenuButtonsDefines(GetButtonsDefinesUnique(Root.MenuClassDefines.ClassButtonsDefines));
	i = 0;
	// Options display: always-shown items first, then conditional items only if enabled on this server
	NewItemOptions = R6WindowListInfoOptionsItem(m_ServerInfoOptionsBox.GetItemAtIndex((i++)));
	NewItemOptions.szOptions = ((pButtonsDef.GetButtonLoc(int(1)) $ " = ") $ string(pServerList.m_GameServerList[pServerList.m_iSelSrvIndex].sGameData.iRoundsPerMatch));
	NewItemOptions = R6WindowListInfoOptionsItem(m_ServerInfoOptionsBox.GetItemAtIndex((i++)));
	NewItemOptions.szOptions = ((pButtonsDef.GetButtonLoc(int(2)) $ " = ") $ Class'Engine.Actor'.static.ConvertIntTimeToString(pServerList.m_GameServerList[pServerList.m_iSelSrvIndex].sGameData.iRoundTime));
	NewItemOptions = R6WindowListInfoOptionsItem(m_ServerInfoOptionsBox.GetItemAtIndex((i++)));
	NewItemOptions.szOptions = ((pButtonsDef.GetButtonLoc(int(7)) $ " = ") $ string(pServerList.m_GameServerList[pServerList.m_iSelSrvIndex].sGameData.iBetTime)); // Time between rounds
	// End:0x522
	// Adversarial modes show bomb timer; co-op modes show terrorist count and AI backup options
	if(pServerList.m_GameServerList[pServerList.m_iSelSrvIndex].sGameData.bAdversarial)
	{
		NewItemOptions = R6WindowListInfoOptionsItem(m_ServerInfoOptionsBox.GetItemAtIndex((i++)));
		NewItemOptions.szOptions = ((pButtonsDef.GetButtonLoc(int(4)) $ " = ") $ string(pServerList.m_GameServerList[pServerList.m_iSelSrvIndex].sGameData.iBombTime)); // EBN_BombTimer
	}
	else
	{
		NewItemOptions = R6WindowListInfoOptionsItem(m_ServerInfoOptionsBox.GetItemAtIndex((i++)));
		NewItemOptions.szOptions = ((pButtonsDef.GetButtonLoc(int(8)) $ " = ") $ string(pServerList.m_GameServerList[pServerList.m_iSelSrvIndex].sGameData.iNumTerro)); // EBN_NB_of_Terro
		// End:0x605
		if(pServerList.m_GameServerList[pServerList.m_iSelSrvIndex].sGameData.bAIBkp)
		{
			NewItemOptions = R6WindowListInfoOptionsItem(m_ServerInfoOptionsBox.GetItemAtIndex((i++)));
			NewItemOptions.szOptions = pButtonsDef.GetButtonLoc(int(17)); // EBN_AIBkp — AI fills empty player slots
		}
		// End:0x673
		if(pServerList.m_GameServerList[pServerList.m_iSelSrvIndex].sGameData.bRotateMap)
		{
			NewItemOptions = R6WindowListInfoOptionsItem(m_ServerInfoOptionsBox.GetItemAtIndex((i++)));
			NewItemOptions.szOptions = pButtonsDef.GetButtonLoc(int(16)); // EBN_RotateMap
		}
	}
	// End:0x6E1
	if(pServerList.m_GameServerList[pServerList.m_iSelSrvIndex].sGameData.bShowNames)
	{
		NewItemOptions = R6WindowListInfoOptionsItem(m_ServerInfoOptionsBox.GetItemAtIndex((i++)));
		NewItemOptions.szOptions = pButtonsDef.GetButtonLoc(int(12)); // EBN_AllowTeamNames
	}
	// End:0x74F
	if(pServerList.m_GameServerList[pServerList.m_iSelSrvIndex].sGameData.bFriendlyFire)
	{
		NewItemOptions = R6WindowListInfoOptionsItem(m_ServerInfoOptionsBox.GetItemAtIndex((i++)));
		NewItemOptions.szOptions = pButtonsDef.GetButtonLoc(int(11)); // EBN_FriendlyFire
	}
	// End:0x7BD
	if(pServerList.m_GameServerList[pServerList.m_iSelSrvIndex].sGameData.bAutoBalTeam)
	{
		NewItemOptions = R6WindowListInfoOptionsItem(m_ServerInfoOptionsBox.GetItemAtIndex((i++)));
		NewItemOptions.szOptions = pButtonsDef.GetButtonLoc(int(13)); // EBN_AutoBalTeam
	}
	// End:0x82B
	if(pServerList.m_GameServerList[pServerList.m_iSelSrvIndex].sGameData.bTKPenalty)
	{
		NewItemOptions = R6WindowListInfoOptionsItem(m_ServerInfoOptionsBox.GetItemAtIndex((i++)));
		NewItemOptions.szOptions = pButtonsDef.GetButtonLoc(int(14)); // EBN_TKPenalty
	}
	// End:0x899
	if(pServerList.m_GameServerList[pServerList.m_iSelSrvIndex].sGameData.bRadar)
	{
		NewItemOptions = R6WindowListInfoOptionsItem(m_ServerInfoOptionsBox.GetItemAtIndex((i++)));
		NewItemOptions.szOptions = pButtonsDef.GetButtonLoc(int(15)); // EBN_AllowRadar
	}
	// End:0x907
	if(pServerList.m_GameServerList[pServerList.m_iSelSrvIndex].sGameData.bForceFPWeapon)
	{
		NewItemOptions = R6WindowListInfoOptionsItem(m_ServerInfoOptionsBox.GetItemAtIndex((i++)));
		NewItemOptions.szOptions = pButtonsDef.GetButtonLoc(int(18)); // EBN_ForceFPersonWp
	}
	return;
}

//==============================================================================
// ClearServerInfo - clear all of the information in the server info tab.
// Called before repopulating or when the selection changes.
//==============================================================================
function ClearServerInfo()
{
	m_ServerInfoPlayerBox.ClearListOfItems();
	m_ServerInfoMapBox.ClearListOfItems();
	m_ServerInfoOptionsBox.ClearListOfItems();
	return;
}

// QuickJoin was removed from the design between SDK 1.56 and 1.60.
// In 1.56 it joined the first server in the list; in 1.60 it is an empty stub.
function QuickJoin()
{
	return;
}

// JoinSelectedServerRequested - Called when the user clicks Join or double-clicks
// a server. Initiates the pre-join query: first we query the server's beacon port
// to get lobby/room IDs and the server password requirement, then we decide
// whether a ubi.com login is needed before proceeding.
function JoinSelectedServerRequested()
{
	local int iBeaconPort;

	// End:0x16
	if((m_ServerListBox.m_SelectedItem == none))
	{
		return;
	}
	// End:0xFC
	// Only join if the server version matches ours
	if(R6WindowListServerItem(m_ServerListBox.m_SelectedItem).bSameVersion)
	{
		// End:0x86
		if((int(m_ConnectionTab) == int(1)))
		{
			m_szServerIP = m_GameService.GetSelectedServerIP();
			iBeaconPort = m_GameService.m_GameServerList[m_GameService.m_iSelSrvIndex].iBeaconPort;			
		}
		else
		{
			m_szServerIP = m_LanServers.m_GameServerList[m_LanServers.m_iSelSrvIndex].szIPAddress;
			iBeaconPort = m_LanServers.m_GameServerList[m_LanServers.m_iSelSrvIndex].iBeaconPort;
		}
		// Query the server on its beacon port to get pre-join info (lobby ID, password needed, etc.)
		m_pQueryServerInfo.StartQueryServerInfoProcedure(OwnerWindow, m_szServerIP, iBeaconPort);
		m_bQueryServerInfoInProgress = true;
	}
	return;
}

// QueryReceivedStartPreJoin - The beacon query to the server completed successfully.
// Now determine whether to join a ubi.com lobby room or join directly by IP.
// DIVERGENCE from SDK 1.56: 1.56 used m_pCDKeyCheckWindow.StartPreJoinProcedure().
// In 1.60, m_pCDKeyCheckWindow was removed and this function now calls
// R6MenuRootWindow.m_pMenuCDKeyManager.StartCDKeyProcess() directly.
function QueryReceivedStartPreJoin()
{
	local bool bRoomValid;

	// A valid ubi.com room requires both a lobby server ID and a group ID
	bRoomValid = ((m_GameService.m_ClientBeacon.PreJoinInfo.iLobbyID != 0) && (m_GameService.m_ClientBeacon.PreJoinInfo.iGroupID != 0));
	// End:0xEC
	// Internet join with no valid room ID means the server is not registered on ubi.com —
	// show an error and refresh the list
	if(((int(m_ConnectionTab) == int(1)) && (!bRoomValid)))
	{
		R6MenuRootWindow(Root).SimplePopUp(Localize("MultiPlayer", "PopUp_Error_RoomJoin", "R6Menu"), Localize("MultiPlayer", "PopUp_Error_NoServer", "R6Menu"), 32, int(2));
		Refresh(false);
		return;
	}
	// End:0x12E
	// 1 = EJRC_BY_LOBBY_AND_ROOM_ID, 0 = EJRC_NO — tells the CD key manager whether to join a room
	if(bRoomValid)
	{
		R6MenuRootWindow(Root).m_pMenuCDKeyManager.StartCDKeyProcess(1, m_GameService.m_ClientBeacon.PreJoinInfo);		
	}
	else
	{
		R6MenuRootWindow(Root).m_pMenuCDKeyManager.StartCDKeyProcess(0, m_GameService.m_ClientBeacon.PreJoinInfo);
	}
	return;
}

// Tick() is called every game frame. It handles deferred first-frame initialization
// and drives several per-frame timers that do not belong in Paint().
function Tick(float DeltaTime)
{
	// End:0x70
	// On the very first frame, attempt auto-login if credentials are stored.
	// m_bAutoLoginFirstPass is cleared to ensure this only fires once per session.
	// The !m_bStartedByGSClient guard skips this when launched from the GameSpy client
	// (which handles its own login flow)
	if(R6Console(Root.Console).m_bAutoLoginFirstPass)
	{
		R6Console(Root.Console).m_bAutoLoginFirstPass = false;
		// End:0x70
		if((!R6Console(Root.Console).m_bStartedByGSClient))
		{
			m_GameService.StartAutoLogin();
		}
	}
	// End:0x14B
	// m_bFPassWindowActv fires once to restore the last-used tab (Internet or LAN)
	if(m_bFPassWindowActv)
	{
		// End:0xE9
		if((m_iLastTabSel == int(1)))
		{
			m_pFirstTabManager.m_pMainTabControl.GotoTab(m_pFirstTabManager.m_pMainTabControl.GetTab(Localize("MultiPlayer", "Tab_InternetServer", "R6Menu")));			
		}
		else
		{
			m_pFirstTabManager.m_pMainTabControl.GotoTab(m_pFirstTabManager.m_pMainTabControl.GetTab(Localize("MultiPlayer", "Tab_LanServer", "R6Menu")));
		}
		m_bFPassWindowActv = false;
	}
	// Advance the refresh cooldown timer
	(m_fRefeshDeltaTime += DeltaTime);
	// End:0x196
	// Keep the Login/Logout toggle button state in sync with the actual login status
	// (login state can change asynchronously from the GameSpy service)
	if(m_GameService.m_bLoggedInUbiDotCom)
	{
		// End:0x193
		// 31 = EBN_LogOut
		if((int(m_ButtonLogInOut.m_eButton_Action) != int(31)))
		{
			m_ButtonLogInOut.SetButLogInOutState(31);
		}		
	}
	else
	{
		// End:0x1C0
		// 30 = EBN_LogIn
		if((int(m_ButtonLogInOut.m_eButton_Action) != int(30)))
		{
			m_ButtonLogInOut.SetButLogInOutState(30);
		}
	}
	// End:0x1FD
	// If auto-login failed while on the internet tab, re-trigger the tab selection
	// so the login dialog is shown again (prompting the user to log in manually)
	if(m_GameService.m_bAutoLoginFailed)
	{
		m_GameService.m_bAutoLoginFailed = false;
		// End:0x1FD
		if((int(m_ConnectionTab) == int(1)))
		{
			ManageTabSelection(int(1));
		}
	}
	// End:0x225
	// Automatic first-time refresh for LAN tab: fires once when the tab is first opened
	if(m_bLanRefreshFPass)
	{
		// End:0x225
		if((int(m_ConnectionTab) == int(0)))
		{
			Refresh(false);
			m_bLanRefreshFPass = false;
		}
	}
	// End:0x261
	// Automatic first-time refresh for Internet tab: fires once after login completes
	if(m_bIntRefreshFPass)
	{
		// End:0x261
		if(((int(m_ConnectionTab) == int(1)) && m_GameService.m_bLoggedInUbiDotCom))
		{
			Refresh(false);
			m_bIntRefreshFPass = false;
		}
	}
	// End:0x291
	// Process a deferred filter update (debounced in SetServerFilterBooleans)
	if((m_bNeedUpdateServerFilter && (GetTime() > (m_fLastUpdateServerFilterTime + 0.3000000))))
	{
		m_bNeedUpdateServerFilter = false;
		UpdateServerFilters();
	}
	return;
}

function AddServerToFavorites()
{
	// End:0x3E
	if((int(m_ConnectionTab) == int(0)))
	{
		m_LanServers.AddToFavorites(R6WindowListServerItem(m_ServerListBox.m_SelectedItem).iMainSvrListIdx);		
	}
	else
	{
		m_GameService.AddToFavorites(R6WindowListServerItem(m_ServerListBox.m_SelectedItem).iMainSvrListIdx);
	}
	return;
}

function DelServerFromFavorites()
{
	// End:0x3E
	if((int(m_ConnectionTab) == int(0)))
	{
		m_LanServers.DelFromFavorites(R6WindowListServerItem(m_ServerListBox.m_SelectedItem).iMainSvrListIdx);		
	}
	else
	{
		m_GameService.DelFromFavorites(R6WindowListServerItem(m_ServerListBox.m_SelectedItem).iMainSvrListIdx);
	}
	return;
}

// PromptConnectionError - Displays an error popup when a server connection fails.
// Tries to find a localised message for the error code; falls back to the raw
// error string if no localisation entry exists.
function PromptConnectionError()
{
	local R6MenuRootWindow r6Root;
	local string szTemp;

	r6Root = R6MenuRootWindow(Root);
	// Override the default popup size/position for this specific error dialog
	r6Root.m_RSimplePopUp.X = 140;
	r6Root.m_RSimplePopUp.Y = 170;
	r6Root.m_RSimplePopUp.W = 360;
	r6Root.m_RSimplePopUp.H = 77;
	// End:0x1AD
	if((R6Console(Root.Console).m_szLastError != ""))
	{
		szTemp = Localize("Multiplayer", R6Console(Root.Console).m_szLastError, "R6Menu", true);
		// End:0x113
		if((szTemp == ""))
		{
			szTemp = Localize("Errors", R6Console(Root.Console).m_szLastError, "R6Engine", true);
		}
		// End:0x141
		if((szTemp == ""))
		{
			szTemp = R6Console(Root.Console).m_szLastError;
		}
		r6Root.SimplePopUp(Localize("MultiPlayer", "Popup_Error_Title", "R6Menu"), szTemp, 24, int(2), false, self);
		R6Console(Root.Console).m_szLastError = "";		
	}
	else
	{
		r6Root.SimplePopUp(Localize("MultiPlayer", "Popup_Error_Title", "R6Menu"), Localize("MultiPlayer", "Popup_ConnectionError", "R6Menu"), 24, int(2), false, self);
	}
	return;
}

//==============================================================================
// PopUpBoxDone -  receive the result of the popup box  
// Restores the popup's size/position to default after any popup (error or otherwise)
// is dismissed, since PromptConnectionError() overrides it.
//==============================================================================
function PopUpBoxDone(UWindowBase.MessageBoxResult Result, UWindowBase.EPopUpID _ePopUpID)
{
	R6WindowRootWindow(Root).m_RSimplePopUp = R6WindowRootWindow(Root).default.m_RSimplePopUp;
	return;
}

//---------------------------------------------------------------------------------
// DisplayRightClickMenu - Called when the user has right clicked on a server, the
// right click menu is displayed at the current mouse position 
//---------------------------------------------------------------------------------
function DisplayRightClickMenu()
{
	m_pRightClickMenu.DisplayMenuHere(m_fMouseX, m_fMouseY);
	return;
}

//---------------------------------------------------------------------------------
// UpdateFavorites - Called when the user picks an option from the right-click menu.
// Handles Add to Favorites, Remove from Favorites, and Refresh Single Server.
//---------------------------------------------------------------------------------
function UpdateFavorites()
{
	// End:0x4B
	if((m_pRightClickMenu.GetValue() == Localize("MultiPlayer", "RightClick_AddFav", "R6Menu")))
	{
		AddServerToFavorites();		
	}
	else
	{
		// End:0x96
		if((m_pRightClickMenu.GetValue() == Localize("MultiPlayer", "RightClick_SubFav", "R6Menu")))
		{
			DelServerFromFavorites();			
		}
		else
		{
			// End:0x13C
			if((m_pRightClickMenu.GetValue() == Localize("MultiPlayer", "RightClick_Refr", "R6Menu")))
			{
				// End:0x114
				if((int(m_ConnectionTab) == int(0)))
				{
					m_LanServers.RefreshOneServer(R6WindowListServerItem(m_ServerListBox.m_SelectedItem).iMainSvrListIdx);					
				}
				else
				{
					m_GameService.RefreshOneServer(R6WindowListServerItem(m_ServerListBox.m_SelectedItem).iMainSvrListIdx);
				}
			}
		}
	}
	// End:0x15B
	if((int(m_ConnectionTab) == int(0)))
	{
		UpdateFilters();
		GetLanServers();		
	}
	else
	{
		UpdateFilters();
		GetGSServers();
	}
	return;
}

// ResortServerList - Re-sort both the LAN and Internet lists by the given
// category and direction, then refresh the displayed list for the active tab.
// Both lists are always sorted so switching tabs shows pre-sorted results.
function ResortServerList(int iCategory, bool _bAscending)
{
	m_iLastSortCategory = iCategory;
	m_bLastTypeOfSort = _bAscending;
	m_GameService.SortServers(iCategory, _bAscending);
	m_LanServers.SortServers(iCategory, _bAscending);
	// End:0x5F
	if((int(m_ConnectionTab) == int(0)))
	{
		GetLanServers();		
	}
	else
	{
		GetGSServers();
	}
	return;
}

//*********************************
//      INIT CREATE FUNCTION
//*********************************
// InitText - Creates the page title label ("MULTI PLAYER") at the top of the widget.
function InitText()
{
	m_LMenuTitle = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', 0.0000000, 18.0000000, (WinWidth - float(8)), 25.0000000, self));
	m_LMenuTitle.Text = Localize("MultiPlayer", "Title", "R6Menu");
	m_LMenuTitle.Align = 1; // TA_Right
	m_LMenuTitle.m_Font = Root.Fonts[4]; // F_MenuMainTitle
	m_LMenuTitle.TextColor = Root.Colors.White;
	m_LMenuTitle.m_BGTexture = none;
	m_LMenuTitle.m_HBorderTexture = none;
	m_LMenuTitle.m_VBorderTexture = none;
	return;
}

// InitButton - Creates all the action buttons in the button row:
// [Login/Out] [Join] [Join IP] [Refresh] [Create]
// fWidth=124 is 620 / 5 buttons = 124 pixels each.
// Buttons are laid out left-to-right using m_pPreviousButtonPos for auto-spacing,
// with m_pRefButtonPos pointing back to the first button as the layout anchor.
function InitButton()
{
	local Font ButtonFont;
	local float fXOffset, fYOffset, fWidth;
	local R6MenuButtonsDefines pButtonsDef;

	// Main Menu and Options are small navigation buttons at the bottom-left (y=425, y=447)
	m_ButtonMainMenu = R6WindowButton(CreateControl(Class'R6Window.R6WindowButton', 10.0000000, 425.0000000, 250.0000000, 25.0000000, self));
	m_ButtonMainMenu.ToolTipString = Localize("Tip", "ButtonMainMenu", "R6Menu");
	m_ButtonMainMenu.Text = Localize("SinglePlayer", "ButtonMainMenu", "R6Menu");
	m_ButtonMainMenu.Align = 0; // TA_Left
	m_ButtonMainMenu.m_fFontSpacing = 0.0000000;
	m_ButtonMainMenu.m_buttonFont = Root.Fonts[15]; // F_MainButton
	m_ButtonMainMenu.ResizeToText();
	m_ButtonOptions = R6WindowButton(CreateControl(Class'R6Window.R6WindowButton', 10.0000000, 447.0000000, 250.0000000, 25.0000000, self));
	m_ButtonOptions.ToolTipString = Localize("Tip", "ButtonOptions", "R6Menu");
	m_ButtonOptions.Text = Localize("SinglePlayer", "ButtonOptions", "R6Menu");
	m_ButtonOptions.Align = 0;
	m_ButtonOptions.m_fFontSpacing = 0.0000000;
	m_ButtonOptions.m_buttonFont = Root.Fonts[15];
	ButtonFont = Root.Fonts[16]; // F_PrincipalButton — slightly larger font for the main action row
	pButtonsDef = R6MenuButtonsDefines(GetButtonsDefinesUnique(Root.MenuClassDefines.ClassButtonsDefines));
	fXOffset = 10.0000000; // Start at left edge (K_XSTARTPOS)
	fYOffset = 50.0000000; // Action row Y position
	fWidth = 124.0000000;  // 620 / 5 = 124 px per button
	// EBN_LogIn=30, EBN_LogOut=31 (toggled based on login state in Tick)
	m_ButtonLogInOut = R6WindowButtonMultiMenu(CreateWindow(Class'R6Menu.R6WindowButtonMultiMenu', fXOffset, fYOffset, 400.0000000, 25.0000000, self));
	m_ButtonLogInOut.ToolTipString = pButtonsDef.GetButtonLoc(int(30), true);
	m_ButtonLogInOut.Text = pButtonsDef.GetButtonLoc(int(30));
	m_ButtonLogInOut.m_eButton_Action = 30; // EBN_LogIn
	m_ButtonLogInOut.Align = 0;
	m_ButtonLogInOut.m_fFontSpacing = 0.0000000;
	m_ButtonLogInOut.m_buttonFont = ButtonFont;
	m_ButtonLogInOut.ResizeToText();
	(fXOffset += fWidth); // Advance to next button slot
	// EBN_Join=32
	m_ButtonJoin = R6WindowButtonMultiMenu(CreateWindow(Class'R6Menu.R6WindowButtonMultiMenu', fXOffset, fYOffset, 400.0000000, 25.0000000, self));
	m_ButtonJoin.ToolTipString = pButtonsDef.GetButtonLoc(int(32), true);
	m_ButtonJoin.Text = pButtonsDef.GetButtonLoc(int(32));
	m_ButtonJoin.m_eButton_Action = 32; // EBN_Join
	m_ButtonJoin.Align = 0;
	m_ButtonJoin.m_fFontSpacing = 0.0000000;
	m_ButtonJoin.m_buttonFont = ButtonFont;
	m_ButtonJoin.ResizeToText();
	m_ButtonJoin.m_pPreviousButtonPos = m_ButtonLogInOut; // Position relative to previous button
	m_ButtonJoin.m_pRefButtonPos = m_ButtonLogInOut;      // Anchor for alignment
	(fXOffset += fWidth);
	// EBN_JoinIP=33
	m_ButtonJoinIP = R6WindowButtonMultiMenu(CreateWindow(Class'R6Menu.R6WindowButtonMultiMenu', fXOffset, fYOffset, 400.0000000, 25.0000000, self));
	m_ButtonJoinIP.ToolTipString = pButtonsDef.GetButtonLoc(int(33), true);
	m_ButtonJoinIP.Text = pButtonsDef.GetButtonLoc(int(33));
	m_ButtonJoinIP.m_eButton_Action = 33; // EBN_JoinIP
	m_ButtonJoinIP.Align = 0;
	m_ButtonJoinIP.m_fFontSpacing = 0.0000000;
	m_ButtonJoinIP.m_buttonFont = ButtonFont;
	m_ButtonJoinIP.ResizeToText();
	m_ButtonJoinIP.m_pPreviousButtonPos = m_ButtonJoin;
	m_ButtonJoinIP.m_pRefButtonPos = m_ButtonLogInOut;
	(fXOffset += fWidth);
	// EBN_Refresh=34
	m_ButtonRefresh = R6WindowButtonMultiMenu(CreateWindow(Class'R6Menu.R6WindowButtonMultiMenu', fXOffset, fYOffset, 400.0000000, 25.0000000, self));
	m_ButtonRefresh.ToolTipString = pButtonsDef.GetButtonLoc(int(34), true);
	m_ButtonRefresh.Text = pButtonsDef.GetButtonLoc(int(34));
	m_ButtonRefresh.m_eButton_Action = 34; // EBN_Refresh
	m_ButtonRefresh.Align = 0;
	m_ButtonRefresh.m_fFontSpacing = 0.0000000;
	m_ButtonRefresh.m_buttonFont = ButtonFont;
	m_ButtonRefresh.ResizeToText();
	m_ButtonRefresh.m_pPreviousButtonPos = m_ButtonJoinIP;
	m_ButtonRefresh.m_pRefButtonPos = m_ButtonLogInOut;
	(fXOffset += fWidth);
	// EBN_Create=35 — launches the host server flow
	m_ButtonCreate = R6WindowButtonMultiMenu(CreateWindow(Class'R6Menu.R6WindowButtonMultiMenu', fXOffset, fYOffset, fWidth, 25.0000000, self));
	m_ButtonCreate.ToolTipString = pButtonsDef.GetButtonLoc(int(35), true);
	m_ButtonCreate.Text = pButtonsDef.GetButtonLoc(int(35));
	m_ButtonCreate.m_eButton_Action = 35; // EBN_Create
	m_ButtonCreate.Align = 1; // TA_Right
	m_ButtonCreate.m_fFontSpacing = 0.0000000;
	m_ButtonCreate.m_buttonFont = ButtonFont;
	m_ButtonCreate.ResizeToText();
	m_ButtonCreate.m_pRefButtonPos = m_ButtonLogInOut;
	return;
}

// InitInfoBar - Creates the sortable column header row (server name, ping, players, etc.)
// that sits between the tab row and the server list at y=114.
function InitInfoBar()
{
	local float fWidth, fPreviousPos;

	fWidth = 15.0000000;
	fPreviousPos = 0.0000000;
	// x=11 is K_XSTARTPOS+1; width is K_WINDOWWIDTH-2 — slight inset from frame border
	m_pButServerList = R6MenuMPButServerList(CreateWindow(Class'R6Menu.R6MenuMPButServerList', (10.0000000 + float(1)), 114.0000000, (620.0000000 - float(2)), 12.0000000, self));
	return;
}

// InitFirstTabWindow - Creates the decorative border frame for the server list area.
// SetBorderParam(side, style, offset, width, color): sides 0=top, 1=bottom, 2=left, 3=right.
// Top border (side 0) is disabled; the tab row visually fills that edge.
// m_eCornerType=2 = Bottom_Corners — only the bottom two corners are rounded.
function InitFirstTabWindow()
{
	local float fWidth;

	fWidth = 1.0000000; // 1-pixel border lines
	// Position matches K_XSTARTPOS, K_YPOS_FIRST_TABWINDOW, K_WINDOWWIDTH, K_FFIRST_WINDOWHEIGHT
	m_pFirstWindowBorder = R6WindowSimpleFramedWindowExt(CreateWindow(Class'R6Window.R6WindowSimpleFramedWindowExt', 10.0000000, 126.0000000, 620.0000000, 154.0000000, self));
	m_pFirstWindowBorder.bAlwaysBehind = true;
	m_pFirstWindowBorder.ActiveBorder(0, false); // Disable top border (replaced by tab row)
	m_pFirstWindowBorder.SetBorderParam(1, 7.0000000, 0.0000000, fWidth, Root.Colors.White); // Bottom: style 7 (thicker)
	m_pFirstWindowBorder.SetBorderParam(2, 1.0000000, 0.0000000, fWidth, Root.Colors.White); // Left
	m_pFirstWindowBorder.SetBorderParam(3, 1.0000000, 0.0000000, fWidth, Root.Colors.White); // Right
	m_pFirstWindowBorder.m_eCornerType = 2; // Bottom_Corners
	m_pFirstWindowBorder.SetCornerColor(2, Root.Colors.White);
	m_pFirstWindowBorder.ActiveBackGround(true, Root.Colors.Black); // Black fill behind server list
	return;
}

// InitServerList - Creates the scrollable server list box. Called from ShowWindow()
// rather than Created() because m_LanServers (needed for ping timeout) is also
// created in ShowWindow(). Guard prevents double-creation on subsequent ShowWindow calls.
function InitServerList()
{
	local Font ButtonFont;
	local int iFiles, i, j;

	// End:0x0D
	if((m_ServerListBox != none))
	{
		return;
	}
	// K_XSTARTPOS_NOBORDER=12, K_YPOS_FIRST_TABWINDOW=126, K_WINDOWWIDTH_NOBORDER=616, K_FFIRST_WINDOWHEIGHT=154
	m_ServerListBox = R6WindowServerListBox(CreateWindow(Class'R6Window.R6WindowServerListBox', 12.0000000, 126.0000000, 616.0000000, 154.0000000, self));
	m_ServerListBox.Register(m_pFirstTabManager); // Tab manager gets notified of list events
	m_ServerListBox.SetCornerType(1); // No_Borders — list fills the frame with no extra border
	m_ServerListBox.m_Font = Root.Fonts[10]; // F_ListItemSmall
	m_ServerListBox.m_iPingTimeOut = m_LanServers.NativeGetPingTimeOut(); // Highlight servers above this ping
	return;
}

// InitServerInfoPlayer - Creates the player list panel in the Server Info tab.
// Positioned at x=10, y=336 (below the second tab row area), width=245, height=79.
// Hidden by default; shown when TAB_Server_Info is active.
function InitServerInfoPlayer()
{
	local Font ButtonFont;
	local int iFiles, i, j;

	m_ServerInfoPlayerBox = R6WindowServerInfoPlayerBox(CreateWindow(Class'R6Window.R6WindowServerInfoPlayerBox', 10.0000000, 336.0000000, 245.0000000, 79.0000000, self));
	m_ServerInfoPlayerBox.ToolTipString = Localize("Tip", "InfoBar_ServerInfo_Player", "R6Menu");
	m_ServerInfoPlayerBox.SetCornerType(1); // No_Borders
	m_ServerInfoPlayerBox.m_Font = Root.Fonts[10]; // F_ListItemSmall
	m_ServerInfoPlayerBox.HideWindow();
	return;
}

// InitServerInfoMap - Creates the map rotation list panel in the Server Info tab.
// Positioned at x=255 (beside the player box), same height row. Hidden by default.
function InitServerInfoMap()
{
	local Font ButtonFont;
	local int iFiles, i, j;

	m_ServerInfoMapBox = R6WindowServerInfoMapBox(CreateWindow(Class'R6Window.R6WindowServerInfoMapBox', 255.0000000, 336.0000000, 174.0000000, 79.0000000, self));
	m_ServerInfoMapBox.ToolTipString = Localize("Tip", "InfoBar_ServerInfo_Map", "R6Menu");
	m_ServerInfoMapBox.SetCornerType(0); // No_Corners
	m_ServerInfoMapBox.m_Font = Root.Fonts[10];
	m_ServerInfoMapBox.HideWindow();
	return;
}

// InitServerInfoOptions - Creates the server options list panel in the Server Info tab.
// Positioned at x=429 (beside the map box), same height row. Hidden by default.
function InitServerInfoOptions()
{
	local Font ButtonFont;
	local int iFiles, i, j;

	m_ServerInfoOptionsBox = R6WindowServerInfoOptionsBox(CreateWindow(Class'R6Window.R6WindowServerInfoOptionsBox', 429.0000000, 336.0000000, 200.0000000, 79.0000000, self));
	m_ServerInfoOptionsBox.ToolTipString = Localize("Tip", "InfoBar_ServerInfo_Opt", "R6Menu");
	m_ServerInfoOptionsBox.SetCornerType(0); // No_Corners
	m_ServerInfoOptionsBox.m_Font = Root.Fonts[10];
	m_ServerInfoOptionsBox.HideWindow();
	return;
}

// InitSecondTabWindow - Creates the bottom content area: the decorative frame and the
// three interchangeable panels (Game Mode filters, Tech filters, Server Info header).
// Deferred to ShowWindow() like the server list. Guard prevents double-creation.
// Y offset is K_YPOS_SECOND_TABWINDOW (296) + 29 = 325, placing content below the tab strip.
function InitSecondTabWindow()
{
	local float fWidth;

	fWidth = 1.0000000;
	// End:0x279
	if((m_pSecondWindowBorder == none))
	{
		// K_YPOS_SECOND_TABWINDOW + 29 = 325 (below the tab label strip)
		m_pSecondWindowBorder = R6WindowSimpleFramedWindowExt(CreateWindow(Class'R6Window.R6WindowSimpleFramedWindowExt', 10.0000000, (296.0000000 + float(29)), 620.0000000, 90.0000000, self));
		m_pSecondWindowBorder.bAlwaysBehind = true;
		m_pSecondWindowBorder.ActiveBorder(0, false); // No top border; tab row fills it
		m_pSecondWindowBorder.SetBorderParam(1, 7.0000000, 0.0000000, fWidth, Root.Colors.White); // Bottom
		m_pSecondWindowBorder.SetBorderParam(2, 1.0000000, 1.0000000, fWidth, Root.Colors.White); // Left
		m_pSecondWindowBorder.SetBorderParam(3, 1.0000000, 1.0000000, fWidth, Root.Colors.White); // Right
		m_pSecondWindowBorder.m_eCornerType = 2; // Bottom_Corners
		m_pSecondWindowBorder.SetCornerColor(2, Root.Colors.White);
		m_pSecondWindowBorder.ActiveBackGround(true, Root.Colors.Black);
		// Game Mode filter panel (shown by default — first tab in the second row)
		m_pSecondWindowGameMode = R6MenuMPMenuTab(CreateWindow(Root.MenuClassDefines.ClassMPMenuTabGameModeFilters, 10.0000000, (296.0000000 + float(29)), 620.0000000, 90.0000000, self));
		m_pSecondWindowGameMode.InitGameModeTab();
		// Tech Filter panel (ping, dedicated, PunkBuster, etc.) — hidden initially
		m_pSecondWindowFilter = R6MenuMPMenuTab(CreateWindow(Class'R6Menu.R6MenuMPMenuTab', 10.0000000, (296.0000000 + float(29)), 620.0000000, 90.0000000, self));
		m_pSecondWindowFilter.InitFilterTab();
		m_pSecondWindowFilter.HideWindow();
		// Server Info header bar — hidden initially (shown alongside the three detail boxes)
		m_pSecondWindowServerInfo = R6MenuMPMenuTab(CreateWindow(Class'R6Menu.R6MenuMPMenuTab', 10.0000000, (296.0000000 + float(29)), 620.0000000, 90.0000000, self));
		m_pSecondWindowServerInfo.bAlwaysBehind = true;
		m_pSecondWindowServerInfo.InitServerTab();
		m_pSecondWindowServerInfo.HideWindow();
		// Start with the Game Mode filter panel active
		m_pSecondWindow = m_pSecondWindowGameMode;
	}
	return;
}

///////////////////////////////////////////////////////////////
// Initialize values for right-click menu, used in the server list.
// The menu has three items: Add to Favorites, Remove from Favorites, Refresh One Server.
// It is registered on m_pFirstTabManager so it can intercept clicks in that area.
///////////////////////////////////////////////////////////////
function InitRightClickMenu()
{
	// 100,150 is initial position; it will be repositioned to the mouse cursor before display
	m_pRightClickMenu = R6WindowRightClickMenu(CreateControl(Class'R6Window.R6WindowRightClickMenu', 100.0000000, 150.0000000, 140.0000000, 14.0000000));
	m_pRightClickMenu.Register(m_pFirstTabManager);
	m_pRightClickMenu.EditBoxWidth = 140.0000000;
	m_pRightClickMenu.SetFont(6); // F_VerySmallTitle
	m_pRightClickMenu.SetValue("");
	m_pRightClickMenu.AddItem(Localize("MultiPlayer", "RightClick_AddFav", "R6Menu"));
	m_pRightClickMenu.AddItem(Localize("MultiPlayer", "RightClick_SubFav", "R6Menu"));
	m_pRightClickMenu.AddItem(Localize("MultiPlayer", "RightClick_Refr", "R6Menu"));
	m_pRightClickMenu.HideWindow();
	return;
}

// SendMessage - IPC hub for receiving completion messages from popup sub-windows.
// Each popup (login, join-IP, query-server, CD key check) calls SendMessage()
// when it finishes, passing a numeric message code. This function dispatches
// to the appropriate next step based on the code and m_LoginSuccessAction.
//
// Message codes (eR6MenuWidgetMessage):
//   0 = MWM_UBI_LOGIN_SUCCESS  — ubi.com login succeeded
//   1 = MWM_UBI_LOGIN_FAIL     — ubi.com login failed; fall back to LAN tab
//   2 = MWM_UBI_LOGIN_SKIPPED  — already logged in, skip login dialog
//   3 = MWM_CDKEYVAL_SKIPPED   — CD key check not required (LAN join)
//   4 = MWM_CDKEYVAL_SUCCESS   — CD key validated; JoinServer()
//   5 = MWM_CDKEYVAL_FAIL      — CD key invalid; abort join
//   6 = MWM_UBI_JOINIP_SUCCESS — Join-by-IP query succeeded; continue to login/CDKey
//   7 = MWM_UBI_JOINIP_FAIL    — Join-by-IP cancelled or timed out
//   8 = MWM_QUERYSERVER_SUCCESS — Pre-join server query succeeded; continue to login/CDKey
//   9 = MWM_QUERYSERVER_FAIL   — Pre-join query failed
//
// NOTE: Cases 3,4,5 (CD key) are logged as errors — in 1.60 they are handled
// by R6MenuCDKeyManager, not directly by this widget.
function SendMessage(UWindowWindow.eR6MenuWidgetMessage eMessage)
{
	switch(eMessage)
	{
		// End:0xE3
		// MWM_UBI_LOGIN_SUCCESS (0) — login succeeded; act on m_LoginSuccessAction
		case 0:
			switch(m_LoginSuccessAction)
			{
				// End:0x35
				// eLSAct_JoinIP: user was joining by IP, continue to pre-join phase
				case 1:
					m_szServerIP = m_pJoinIPWindow.m_szIP;
					QueryReceivedStartPreJoin();
					// End:0xD8
					break;
				// End:0x43
				// eLSAct_Join: user was joining from list, continue to pre-join phase
				case 2:
					QueryReceivedStartPreJoin();
					// End:0xD8
					break;
				// End:0x52
				// eLSAct_InternetTab: user selected internet tab, now refresh the server list
				case 3:
					Refresh(false);
					// End:0xD8
					break;
				// End:0xB9
				// eLSAct_SwitchToInternetTab: navigate to the Internet tab after login
				case 6:
					m_pFirstTabManager.m_pMainTabControl.GotoTab(m_pFirstTabManager.m_pMainTabControl.GetTab(Localize("MultiPlayer", "Tab_InternetServer", "R6Menu")));
					// End:0xD8
					break;
				// End:0xD5
				// eLSAct_CloseWindow: reconnected after router drop; refresh if on internet tab
				case 5:
					// End:0xD5
					if((int(m_ConnectionTab) == int(1)))
					{
						Refresh(false);
					}
				// End:0xFFFF
				default:
					break;
			}
			m_LoginSuccessAction = 0; // eLSAct_None — clear pending action
			// End:0x2E8
			break;
		// End:0x14D
		// MWM_UBI_LOGIN_FAIL (1) — login failed; revert to LAN tab
		case 1:
			m_pFirstTabManager.m_pMainTabControl.GotoTab(m_pFirstTabManager.m_pMainTabControl.GetTab(Localize("MultiPlayer", "Tab_LanServer", "R6Menu")));
			m_LoginSuccessAction = 0;
			// End:0x2E8
			break;
		// End:0x197
		// MWM_UBI_LOGIN_SKIPPED (2) — already logged in; act on m_LoginSuccessAction same as success
		case 2:
			switch(m_LoginSuccessAction)
			{
				// End:0x17B
				case 1: // eLSAct_JoinIP
					m_szServerIP = m_pJoinIPWindow.m_szIP;
					QueryReceivedStartPreJoin();
					// End:0x18C
					break;
				// End:0x189
				case 2: // eLSAct_Join
					QueryReceivedStartPreJoin();
					// End:0x18C
					break;
				// End:0xFFFF
				default:
					break;
			}
			m_LoginSuccessAction = 0;
			// End:0x2E8
			break;
		// End:0x19C
		// MWM_CDKEYVAL_SKIPPED (3), MWM_CDKEYVAL_SUCCESS (4), MWM_CDKEYVAL_FAIL (5)
		// These should not arrive here in 1.60 — they are handled by R6MenuCDKeyManager
		case 3:
		// End:0x1A1
		case 4:
		// End:0x214
		case 5:
			Log("R6MenuMultiplayerWidget SendMessage() not supposed to arrive here (should be in R6MenuCDKeyManager)!!!!");
			// End:0x2E8
			break;
		// End:0x282
		// MWM_UBI_JOINIP_SUCCESS (6) — Join-by-IP query completed; continue join flow
		case 6:
			m_bJoinIPInProgress = false;
			m_szPopUpIP = m_pJoinIPWindow.m_szIP; // Save for next session
			SaveConfig();
			// End:0x265
			// If the server is registered on ubi.com, require login before joining
			if(m_pJoinIPWindow.m_bRoomValid)
			{
				m_LoginSuccessAction = 1; // eLSAct_JoinIP
				m_pLoginWindow.StartLogInProcedure(self);				
			}
			else
			{
				// LAN/non-ubi server: skip login, go straight to CD key check
				m_szServerIP = m_pJoinIPWindow.m_szIP;
				QueryReceivedStartPreJoin();
			}
			// End:0x2E8
			break;
		// End:0x292
		// MWM_UBI_JOINIP_FAIL (7) — user cancelled Join-by-IP or it timed out
		case 7:
			m_bJoinIPInProgress = false;
			// End:0x2E8
			break;
		// End:0x2D5
		// MWM_QUERYSERVER_SUCCESS (8) — pre-join beacon query succeeded
		case 8:
			// End:0x2C4
			// If the server is on ubi.com, login is required before joining
			if(m_pQueryServerInfo.m_bRoomValid)
			{
				m_LoginSuccessAction = 2; // eLSAct_Join
				m_pLoginWindow.StartLogInProcedure(self);				
			}
			else
			{
				QueryReceivedStartPreJoin(); // Not on ubi.com: go directly to CD key check
			}
			m_bQueryServerInfoInProgress = false;
			// End:0x2E8
			break;
		// End:0x2E5
		// MWM_QUERYSERVER_FAIL (9) — pre-join query failed or timed out
		case 9:
			m_bQueryServerInfoInProgress = false;
			// End:0x2E8
			break;
		// End:0xFFFF
		default:
			break;
	}
	return;
}

// Notify - Standard UWindow button click handler (DE_Click = event 2).
// Routes button clicks to the appropriate action.
// Widget IDs: 7 = MainMenuWidgetID, 16 = OptionsWidgetID.
function Notify(UWindowDialogControl C, byte E)
{
	// End:0xC6
	if((int(E) == 2)) // DE_Click
	{
		switch(C)
		{
			// End:0x31
			case m_ButtonMainMenu:
				Root.ChangeCurrentWidget(7); // MainMenuWidgetID
				// End:0xC6
				break;
			// End:0x4D
			case m_ButtonOptions:
				Root.ChangeCurrentWidget(16); // OptionsWidgetID
				// End:0xC6
				break;
			// End:0x88
			// Page navigation buttons force a list refresh by resetting the update timestamp
			case m_PageCount.m_pNextButton:
				m_PageCount.NextPage();
				m_GameService.m_bServerListChanged = true;
				m_iTimeLastUpdate = 0; // Force immediate redraw on next Paint() call
				// End:0xC6
				break;
			// End:0xC3
			case m_PageCount.m_pPreviousButton:
				m_PageCount.PreviousPage();
				m_GameService.m_bServerListChanged = true;
				m_iTimeLastUpdate = 0;
				// End:0xC6
				break;
			// End:0xFFFF
			default:
				break;
		}
	}
	else
	{
		return;
	}
}

// BackToMainMenu - Called when the user navigates away from the multiplayer screen.
// Delegates to ResetMultiplayerMenu() to clean up network resources.
function BackToMainMenu()
{
	local ClientBeaconReceiver _BeaconReceiver;

	ResetMultiplayerMenu();
	return;
}

// ResetMultiplayerMenu - Tears down the LAN discovery infrastructure.
// The ClientBeaconReceiver is an Actor that must be explicitly destroyed;
// if it is left alive it will continue broadcasting LAN queries.
// m_LanServers is set to none so it will be re-created on the next ShowWindow() call.
function ResetMultiplayerMenu()
{
	local ClientBeaconReceiver _BeaconReceiver;

	// End:0x2F
	if((m_LanServers != none))
	{
		_BeaconReceiver = m_LanServers.m_ClientBeacon;
		m_LanServers.m_ClientBeacon = none; // Detach before destroy to avoid use-after-free
	}
	// End:0x4A
	if((m_GameService != none))
	{
		m_GameService.m_ClientBeacon = none; // GameSpy service shared this reference
	}
	// End:0x61
	if((_BeaconReceiver != none))
	{
		_BeaconReceiver.Destroy(); // Kills the UDP beacon Actor
	}
	m_LanServers = none;
	R6Console(Root.Console).m_LanServers = none; // Clear console reference too
	return;
}

// All game mode filter booleans default to true so the list shows all game types
// when the user opens multiplayer for the first time (or after resetting User.ini).
// m_bLanRefreshFPass and m_bIntRefreshFPass default to true to trigger an
// automatic server list refresh the first time each tab is visited.
defaultproperties
{
	m_bLanRefreshFPass=true
	m_bIntRefreshFPass=true
	m_bFilterDeathMatch=true
	m_bFilterTeamDeathMatch=true
	m_bFilterDisarmBomb=true
	m_bFilterHostageRescueAdv=true
	m_bFilterEscortPilot=true
	m_bFilterMission=true
	m_bFilterTerroristHunt=true
	m_bFilterHostageRescueCoop=true
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var m_pCDKeyCheckWindow
// REMOVED IN 1.60: var m_bChangeMap
// REMOVED IN 1.60: var m_bPreJoinInProgress
// REMOVED IN 1.60: function SetServerFilterHasPlayer
// REMOVED IN 1.60: function JoinServer
