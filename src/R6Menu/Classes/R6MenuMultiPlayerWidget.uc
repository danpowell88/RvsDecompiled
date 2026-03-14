//=============================================================================
// R6MenuMultiPlayerWidget - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6MenuMultiPlayerWidget.uc : The first multi player menu window
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/11/22 * Created by Alexandre Dionne
//    2002/03/7  * Modify by Yannick Joly
//=============================================================================
class R6MenuMultiPlayerWidget extends R6MenuWidget
 config(User);

const K_XSTARTPOS = 10;
const K_WINDOWWIDTH = 620;
const K_XSTARTPOS_NOBORDER = 12;
const K_WINDOWWIDTH_NOBORDER = 616;
const K_XTABOFFSET = 5;
const K_FIRST_TABWINDOW_WIDTH = 500;
const K_SEC_TABWINDOW_WIDTH = 600;
const K_FFIRST_WINDOWHEIGHT = 154;
const K_FSECOND_WINDOWHEIGHT = 90;
const K_YPOS_FIRST_TABWINDOW = 126;
const K_YPOS_SECOND_TABWINDOW = 296;
const K_YPOS_HELPTEXT_WINDOW = 430;
const C_fDIST_BETWEEN_BUTTON = 30;
const K_LIST_UPDATE_TIME = 1000;
const K_REFRESH_TIMEOUT = 2.0;
const K_UPDATE_FILTER_INTERVAL = 0.3;

enum MultiPlayerTabID
{
	TAB_Lan_Server,                 // 0
	TAB_Internet_Server,            // 1
	TAB_Game_Mode,                  // 2
	TAB_Tech_Filter,                // 3
	TAB_Server_Info                 // 4
};

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
	eServerInfoID_HasPlayer,        // 17
	eServerInfoID_SameVersion       // 18
};

enum eLoginSuccessAction
{
	eLSAct_None,                    // 0
	eLSAct_JoinIP,                  // 1
	eLSAct_Join,                    // 2
	eLSAct_InternetTab,             // 3
	eLSAct_LaunchServer,            // 4
	eLSAct_CloseWindow,             // 5
	eLSAct_SwitchToInternetTab      // 6
};

var R6MenuMultiPlayerWidget.MultiPlayerTabID m_ConnectionTab;
var R6MenuMultiPlayerWidget.MultiPlayerTabID m_FilterTab;
var R6MenuMultiPlayerWidget.eLoginSuccessAction m_LoginSuccessAction;  // Action to take after login procedure succeeds
var int m_FrameCounter;  // Counter to schedule slower processes
                                                                 // keeps a history of pop up to return to./
var int m_iTimeLastUpdate;  // Time in ms of the last server list update
var int m_iLastSortCategory;  // the last sort we did
var config int m_iLastTabSel;  // The last tab selected between Internet and LAN
var int m_iTotalPlayers;  // total players
// NEW IN 1.60
var config int m_iFilterFasterThan;
var bool m_bListUpdateReq;  // the server list needs to be updated
var bool m_bLastTypeOfSort;
var bool m_bFPassWindowActv;  // First pass flag used for when window is first activated
var bool m_bJoinIPInProgress;
var bool m_bQueryServerInfoInProgress;
var bool m_bGetServerInfo;  // Need to get the server info for the selected server
var bool m_bLanRefreshFPass;  // First pass flag for LAN server refresh
var bool m_bIntRefreshFPass;  // First pass flag for Internet server refresh
// NEW IN 1.60
var bool m_bNeedUpdateServerFilter;
// NEW IN 1.60
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
var float m_fMouseX;  // X position of mouse
var float m_fMouseY;  // Y position of mouse
var float m_fRefeshDeltaTime;  // Time since refresh button last hit
// NEW IN 1.60
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
var string m_szGamePwd;
var config string m_szPopUpIP;  // IP adress entered in pop up
var string m_szServerIP;  // IP of server
var string m_szMultiLoc[2];  // array of text localization

function Created()
{
	m_GameService = R6Console(Root.Console).m_GameService;
	InitText();
	InitButton();
	m_FirstTabWindow = R6WindowTextLabelCurved(CreateWindow(Class'R6Window.R6WindowTextLabelCurved', 10.0000000, 85.0000000, 620.0000000, 30.0000000, self));
	m_FirstTabWindow.bAlwaysBehind = true;
	m_FirstTabWindow.Text = "";
	m_FirstTabWindow.m_BGTexture = none;
	m_pFirstTabManager = R6MenuMPManageTab(CreateWindow(Class'R6Menu.R6MenuMPManageTab', __NFUN_174__(10.0000000, float(5)), 90.0000000, 500.0000000, 25.0000000, self));
	m_pFirstTabManager.AddTabInControl(Localize("MultiPlayer", "Tab_InternetServer", "R6Menu"), Localize("Tip", "Tab_InternetServer", "R6Menu"), int(1));
	m_pFirstTabManager.AddTabInControl(Localize("MultiPlayer", "Tab_LanServer", "R6Menu"), Localize("Tip", "Tab_LanServer", "R6Menu"), int(0));
	InitInfoBar();
	InitFirstTabWindow();
	InitServerInfoPlayer();
	InitServerInfoMap();
	InitServerInfoOptions();
	InitRightClickMenu();
	m_SecondTabWindow = R6WindowTextLabelCurved(CreateWindow(Class'R6Window.R6WindowTextLabelCurved', 10.0000000, 296.0000000, 620.0000000, 30.0000000, self));
	m_SecondTabWindow.bAlwaysBehind = true;
	m_SecondTabWindow.Text = "";
	m_SecondTabWindow.m_BGTexture = none;
	m_pSecondTabManager = R6MenuMPManageTab(CreateWindow(Class'R6Menu.R6MenuMPManageTab', __NFUN_174__(10.0000000, float(5)), __NFUN_174__(296.0000000, float(5)), 600.0000000, 25.0000000, self));
	m_pSecondTabManager.AddTabInControl(Localize("MultiPlayer", "Tab_GameFilter", "R6Menu"), Localize("Tip", "Tab_GameFilter", "R6Menu"), int(2));
	m_pSecondTabManager.AddTabInControl(Localize("MultiPlayer", "Tab_TechFilter", "R6Menu"), Localize("Tip", "Tab_TechFilter", "R6Menu"), int(3));
	m_pSecondTabManager.AddTabInControl(Localize("MultiPlayer", "Tab_ServerInfo", "R6Menu"), Localize("Tip", "Tab_ServerInfo", "R6Menu"), int(4));
	m_pHelpTextWindow = R6MenuHelpWindow(CreateWindow(Class'R6Menu.R6MenuHelpWindow', 150.0000000, 429.0000000, 340.0000000, 42.0000000, self));
	m_pHelpTextWindow.m_bForceRefreshOnSameTip = true;
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
	m_bFPassWindowActv = true;
	// End:0x519
	if(m_GameService.m_bLoggedInUbiDotCom)
	{
		m_ButtonLogInOut.SetButLogInOutState(31);		
	}
	else
	{
		m_ButtonLogInOut.SetButLogInOutState(30);
	}
	m_fRefeshDeltaTime = 2.0000000;
	m_GameService.__NFUN_3523__();
	m_szMultiLoc[0] = Localize("MultiPlayer", "NbOfServers", "R6Menu");
	m_szMultiLoc[1] = Localize("MultiPlayer", "NbOfPlayers", "R6Menu");
	m_PageCount = R6WindowPageSwitch(CreateWindow(Class'R6Window.R6WindowPageSwitch', 530.0000000, 90.0000000, 90.0000000, 25.0000000, self));
	m_fLastUpdateServerFilterTime = GetTime();
	m_bNeedUpdateServerFilter = false;
	return;
}

/////////////////////////////////////////////////////////////////
// display the background
/////////////////////////////////////////////////////////////////
function Paint(Canvas C, float X, float Y)
{
	local R6WindowTextLabel pR6TextLabelTemp;

	Root.PaintBackground(C, self);
	m_fMouseX = X;
	m_fMouseY = Y;
	// End:0x4A
	if(__NFUN_154__(int(m_ConnectionTab), int(0)))
	{
		m_LanServers.LANSeversManager();
	}
	// End:0xFF
	if(__NFUN_130__(__NFUN_132__(m_LanServers.m_bServerListChanged, m_GameService.m_bServerListChanged), __NFUN_151__(__NFUN_147__(m_GameService.__NFUN_1278__(), m_iTimeLastUpdate), 1000)))
	{
		m_iTimeLastUpdate = m_GameService.__NFUN_1278__();
		m_GameService.m_bServerListChanged = false;
		m_LanServers.m_bServerListChanged = false;
		// End:0xF3
		if(__NFUN_154__(int(m_ConnectionTab), int(0)))
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
	if(__NFUN_154__(int(m_ConnectionTab), int(1)))
	{
		// End:0x151
		if(m_GameService.m_bRefreshFinished)
		{
			m_GameService.m_bRefreshFinished = false;
			ResortServerList(m_iLastSortCategory, m_bLastTypeOfSort);
			GetGSServers();
			m_bGetServerInfo = true;
		}
		// End:0x177
		if(m_GameService.__NFUN_3522__())
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
	if(__NFUN_119__(m_ServerListBox.m_SelectedItem, m_oldSelItem))
	{
		m_oldSelItem = m_ServerListBox.m_SelectedItem;
		// End:0x22B
		if(__NFUN_154__(int(m_ConnectionTab), int(0)))
		{
			// End:0x21D
			if(__NFUN_119__(m_ServerListBox.m_SelectedItem, none))
			{
				m_LanServers.SetSelectedServer(R6WindowListServerItem(m_ServerListBox.m_SelectedItem).iMainSvrListIdx);
			}
			GetServerInfo(m_LanServers);			
		}
		else
		{
			// End:0x26A
			if(__NFUN_119__(m_ServerListBox.m_SelectedItem, none))
			{
				m_GameService.SetSelectedServer(R6WindowListServerItem(m_ServerListBox.m_SelectedItem).iMainSvrListIdx);
			}
			m_bGetServerInfo = true;
		}
	}
	// End:0x325
	if(__NFUN_130__(__NFUN_130__(__NFUN_130__(m_bGetServerInfo, __NFUN_129__(m_GameService.__NFUN_3522__())), __NFUN_154__(int(m_ConnectionTab), int(1))), __NFUN_154__(int(m_FilterTab), int(4))))
	{
		// End:0x317
		if(__NFUN_151__(m_GameService.m_GameServerList.Length, 0))
		{
			m_GameService.__NFUN_3570__(m_GameService.m_GameServerList[m_GameService.m_iSelSrvIndex].iLobbySrvID, m_GameService.m_GameServerList[m_GameService.m_iSelSrvIndex].iGroupID);
		}
		ClearServerInfo();
		m_bGetServerInfo = false;
	}
	// End:0x365
	if(__NFUN_130__(m_GameService.m_bServerInfoChanged, __NFUN_154__(int(m_ConnectionTab), int(1))))
	{
		GetServerInfo(m_GameService);
		m_GameService.m_bServerInfoChanged = false;
	}
	// End:0x38C
	if(m_GameService.__NFUN_3550__())
	{
		m_LoginSuccessAction = 5;
		m_pLoginWindow.LogInAfterDisconnect(self);
	}
	// End:0x3AC
	if(__NFUN_155__(int(m_LoginSuccessAction), int(0)))
	{
		m_pLoginWindow.Manager(self);
	}
	// End:0x3C5
	if(m_bJoinIPInProgress)
	{
		m_pJoinIPWindow.Manager(self);
	}
	// End:0x3DE
	if(m_bQueryServerInfoInProgress)
	{
		m_pQueryServerInfo.Manager(self);
	}
	// End:0x406
	if(__NFUN_114__(m_ServerListBox.m_SelectedItem, none))
	{
		m_ButtonJoin.bDisabled = true;		
	}
	else
	{
		// End:0x43C
		if(__NFUN_129__(R6WindowListServerItem(m_ServerListBox.m_SelectedItem).bSameVersion))
		{
			m_ButtonJoin.bDisabled = true;			
		}
		else
		{
			m_ButtonJoin.bDisabled = false;
		}
	}
	return;
}

function ShowWindow()
{
	local string _szIPAddress;

	R6MenuRootWindow(Root).m_pMenuCDKeyManager.SetWindowUser(Root.15, self);
	// End:0x97
	if(__NFUN_114__(m_LanServers, none))
	{
		m_LanServers = new (none) Class<R6LanServers>(Root.MenuClassDefines.ClassLanServer);
		R6Console(Root.Console).m_LanServers = m_LanServers;
		m_LanServers.Created();
		InitServerList();
		InitSecondTabWindow();
	}
	// End:0xE6
	if(__NFUN_114__(m_LanServers.m_ClientBeacon, none))
	{
		m_LanServers.m_ClientBeacon = Root.Console.ViewportOwner.Actor.__NFUN_278__(Class'IpDrv.ClientBeaconReceiver');
	}
	m_GameService.m_ClientBeacon = m_LanServers.m_ClientBeacon;
	m_iLastSortCategory = int(m_LanServers.4);
	m_bLastTypeOfSort = true;
	super(UWindowWindow).ShowWindow();
	R6Console(Root.Console).m_GameService.__NFUN_3501__();
	Root.SetLoadRandomBackgroundImage("Multiplayer");
	// End:0x1B5
	if(R6Console(Root.Console).m_bNonUbiMatchMaking)
	{
		Class'Engine.Actor'.static.__NFUN_1304__(_szIPAddress);
		m_pJoinIPWindow.StartCmdLineJoinIPProcedure(m_ButtonJoinIP, _szIPAddress);
		m_bJoinIPInProgress = true;
	}
	return;
}

/////////////////////////////////////////////////////////////////
// display the help text in the m_pHelpTextWindow (derivate for uwindowwindow
/////////////////////////////////////////////////////////////////
function ToolTip(string strTip)
{
	ManageToolTip(strTip);
	return;
}

function ManageToolTip(string _strTip, optional bool _bForceATip)
{
	local string szTemp1, szTemp2;
	local int iNbOfServers;

	// End:0x1A
	if(__NFUN_132__(__NFUN_114__(m_pHelpTextWindow, none), __NFUN_129__(bWindowVisible)))
	{
		return;
	}
	szTemp1 = _strTip;
	szTemp2 = "";
	// End:0x73
	if(_bForceATip)
	{
		// End:0x5E
		if(__NFUN_154__(int(m_ConnectionTab), int(1)))
		{
			m_iTotalPlayers = m_GameService.GetTotalPlayers();			
		}
		else
		{
			m_iTotalPlayers = m_LanServers.GetTotalPlayers();
		}
	}
	// End:0xF2
	if(__NFUN_122__(_strTip, ""))
	{
		// End:0xA7
		if(__NFUN_154__(int(m_ConnectionTab), int(1)))
		{
			iNbOfServers = m_GameService.m_GameServerList.Length;			
		}
		else
		{
			iNbOfServers = m_LanServers.m_GameServerList.Length;
		}
		szTemp1 = __NFUN_112__(__NFUN_112__(m_szMultiLoc[0], " "), string(iNbOfServers));
		szTemp2 = __NFUN_112__(__NFUN_112__(m_szMultiLoc[1], " "), string(m_iTotalPlayers));
	}
	m_pHelpTextWindow.ToolTip(szTemp1);
	// End:0x126
	if(__NFUN_123__(szTemp2, ""))
	{
		m_pHelpTextWindow.AddTipText(szTemp2);
	}
	return;
}

/////////////////////////////////////////////////////////////////
// manage the tab selection (the call of the fct come from R6MenuMPManageTab
/////////////////////////////////////////////////////////////////
function ManageTabSelection(int _MPTabChoiceID)
{
	switch(_MPTabChoiceID)
	{
		// End:0x59
		case int(0):
			m_ConnectionTab = 0;
			// End:0x32
			if(__NFUN_154__(m_LanServers.m_GameServerList.Length, 0))
			{
				Refresh(false);
			}
			GetLanServers();
			GetServerInfo(m_LanServers);
			UpdateServerFilters();
			m_iLastTabSel = int(0);
			__NFUN_536__();
			// End:0x22E
			break;
		// End:0xB8
		case int(1):
			m_ConnectionTab = 1;
			m_LoginSuccessAction = 3;
			m_pLoginWindow.StartLogInProcedure(self);
			// End:0x9C
			if(__NFUN_154__(m_GameService.m_GameServerList.Length, 0))
			{
				Refresh(false);
			}
			GetGSServers();
			UpdateServerFilters();
			m_iLastTabSel = int(1);
			__NFUN_536__();
			// End:0x22E
			break;
		// End:0x120
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
			__NFUN_231__("This tab was not supported (R6MenuMultiPlayerWidget)");
			// End:0x22E
			break;
			break;
	}
	return;
}

/////////////////////////////////////////////////////////////////
// set the button choice from game mode, tech filters
/////////////////////////////////////////////////////////////////
function SetServerFilterBooleans(int _iServerInfoID, bool _bNewChoice)
{
	switch(_iServerInfoID)
	{
		// End:0x1E
		case int(0):
			m_bFilterDeathMatch = _bNewChoice;
			// End:0x1B1
			break;
		// End:0x35
		case int(1):
			m_bFilterTeamDeathMatch = _bNewChoice;
			// End:0x1B1
			break;
		// End:0x4C
		case int(2):
			m_bFilterDisarmBomb = _bNewChoice;
			// End:0x1B1
			break;
		// End:0x63
		case int(3):
			m_bFilterHostageRescueAdv = _bNewChoice;
			// End:0x1B1
			break;
		// End:0x7A
		case int(4):
			m_bFilterEscortPilot = _bNewChoice;
			// End:0x1B1
			break;
		// End:0x91
		case int(5):
			m_bFilterMission = _bNewChoice;
			// End:0x1B1
			break;
		// End:0xA8
		case int(6):
			m_bFilterTerroristHunt = _bNewChoice;
			// End:0x1B1
			break;
		// End:0xBF
		case int(7):
			m_bFilterHostageRescueCoop = _bNewChoice;
			// End:0x1B1
			break;
		// End:0xD6
		case int(10):
			m_bFilterUnlockedOnly = _bNewChoice;
			// End:0x1B1
			break;
		// End:0xED
		case int(11):
			m_bFilterFavoritesOnly = _bNewChoice;
			// End:0x1B1
			break;
		// End:0x104
		case int(12):
			m_bFilterDedicatedServersOnly = _bNewChoice;
			// End:0x1B1
			break;
		// End:0x11B
		case int(13):
			m_bFilterPunkBusterServerOnly = _bNewChoice;
			// End:0x1B1
			break;
		// End:0x132
		case int(14):
			m_bFilterServersNotEmpty = _bNewChoice;
			// End:0x1B1
			break;
		// End:0x149
		case int(15):
			m_bFilterServersNotFull = _bNewChoice;
			// End:0x1B1
			break;
		// End:0x160
		case int(16):
			m_bFilterResponding = _bNewChoice;
			// End:0x1B1
			break;
		// End:0x177
		case int(18):
			m_bFilterSameVersion = _bNewChoice;
			// End:0x1B1
			break;
		// End:0xFFFF
		default:
			__NFUN_231__("Sorry, no server info associate with this button");
			// End:0x1B1
			break;
			break;
	}
	// End:0x1D2
	if(__NFUN_176__(GetTime(), __NFUN_174__(m_fLastUpdateServerFilterTime, 0.3000000)))
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
// setting (ping time)
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
//-------------------------------------------------------
function UpdateServerFilters()
{
	m_pSecondWindowGameMode.UpdateGameTypeFilter();
	m_pSecondWindowFilter.UpdateGameTypeFilter();
	// End:0x40
	if(__NFUN_154__(int(m_ConnectionTab), int(0)))
	{
		UpdateFilters();
		__NFUN_536__();
		GetLanServers();		
	}
	else
	{
		UpdateFilters();
		__NFUN_536__();
		GetGSServers();
	}
	m_fLastUpdateServerFilterTime = GetTime();
	return;
}

// NEW IN 1.60
function UpdateFilters()
{
	local R6ModMgr pModMgr;
	local int i, j, iNbOfServers;
	local bool bFound, bIsRavenShield, bIsLanServers;
	local string szCurrentMod, szTempGDGameType;
	local stGameServer stTempGameServerItem;

	pModMgr = Class'Engine.Actor'.static.__NFUN_1524__();
	szCurrentMod = pModMgr.m_pCurrentMod.m_szKeyWord;
	bIsLanServers = __NFUN_154__(int(m_ConnectionTab), int(0));
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
	if(__NFUN_150__(i, iNbOfServers))
	{
		// End:0xD1
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
		if(__NFUN_130__(__NFUN_129__(m_bFilterDeathMatch), __NFUN_122__(szTempGDGameType, "RGM_DeathmatchMode")))
		{
			// [Explicit Continue]
			goto J0x503;
		}
		// End:0x17C
		if(__NFUN_130__(__NFUN_129__(m_bFilterTeamDeathMatch), __NFUN_122__(szTempGDGameType, "RGM_TeamDeathmatchMode")))
		{
			// [Explicit Continue]
			goto J0x503;
		}
		// End:0x1A7
		if(__NFUN_130__(__NFUN_129__(m_bFilterDisarmBomb), __NFUN_122__(szTempGDGameType, "RGM_BombAdvMode")))
		{
			// [Explicit Continue]
			goto J0x503;
		}
		// End:0x1DB
		if(__NFUN_130__(__NFUN_129__(m_bFilterHostageRescueAdv), __NFUN_122__(szTempGDGameType, "RGM_HostageRescueAdvMode")))
		{
			// [Explicit Continue]
			goto J0x503;
		}
		// End:0x208
		if(__NFUN_130__(__NFUN_129__(m_bFilterEscortPilot), __NFUN_122__(szTempGDGameType, "RGM_EscortAdvMode")))
		{
			// [Explicit Continue]
			goto J0x503;
		}
		// End:0x233
		if(__NFUN_130__(__NFUN_129__(m_bFilterMission), __NFUN_122__(szTempGDGameType, "RGM_MissionMode")))
		{
			// [Explicit Continue]
			goto J0x503;
		}
		// End:0x268
		if(__NFUN_130__(__NFUN_129__(m_bFilterTerroristHunt), __NFUN_122__(szTempGDGameType, "RGM_TerroristHuntCoopMode")))
		{
			// [Explicit Continue]
			goto J0x503;
		}
		// End:0x29D
		if(__NFUN_130__(__NFUN_129__(m_bFilterHostageRescueCoop), __NFUN_122__(szTempGDGameType, "RGM_HostageRescueCoopMode")))
		{
			// [Explicit Continue]
			goto J0x503;
		}
		// End:0x327
		if(__NFUN_130__(__NFUN_123__(stTempGameServerItem.sGameData.szModName, ""), __NFUN_129__(__NFUN_124__(stTempGameServerItem.sGameData.szModName, szCurrentMod))))
		{
			__NFUN_231__(__NFUN_168__(__NFUN_168__("UpdateFilters() szModName is different than current MOD ", stTempGameServerItem.sGameData.szModName), szCurrentMod));
			// [Explicit Continue]
			goto J0x503;
		}
		// End:0x348
		if(__NFUN_130__(m_bFilterUnlockedOnly, stTempGameServerItem.sGameData.bUsePassword))
		{
			// [Explicit Continue]
			goto J0x503;
		}
		// End:0x366
		if(__NFUN_130__(m_bFilterFavoritesOnly, __NFUN_129__(stTempGameServerItem.bFavorite)))
		{
			// [Explicit Continue]
			goto J0x503;
		}
		// End:0x389
		if(__NFUN_130__(m_bFilterDedicatedServersOnly, __NFUN_129__(stTempGameServerItem.sGameData.bDedicatedServer)))
		{
			// [Explicit Continue]
			goto J0x503;
		}
		// End:0x3AC
		if(__NFUN_130__(m_bFilterServersNotEmpty, __NFUN_154__(stTempGameServerItem.sGameData.iNbrPlayer, 0)))
		{
			// [Explicit Continue]
			goto J0x503;
		}
		// End:0x3F8
		if(bIsLanServers)
		{
			// End:0x3F5
			if(__NFUN_130__(m_bFilterServersNotFull, __NFUN_153__(stTempGameServerItem.sGameData.iNbrPlayer, m_LanServers.m_GameServerList[i].sGameData.iMaxPlayer)))
			{
				// [Explicit Continue]
				goto J0x503;
			}			
		}
		else
		{
			// End:0x438
			if(__NFUN_130__(m_bFilterServersNotFull, __NFUN_153__(stTempGameServerItem.sGameData.iNbrPlayer, m_GameService.m_GameServerList[i].sGameData.iMaxPlayer)))
			{
				// [Explicit Continue]
				goto J0x503;
			}
		}
		// End:0x45B
		if(__NFUN_130__(m_bFilterPunkBusterServerOnly, __NFUN_129__(stTempGameServerItem.sGameData.bPunkBuster)))
		{
			// [Explicit Continue]
			goto J0x503;
		}
		// End:0x47D
		if(__NFUN_130__(m_bFilterResponding, __NFUN_153__(stTempGameServerItem.iPing, 1000)))
		{
			// [Explicit Continue]
			goto J0x503;
		}
		// End:0x4A1
		if(__NFUN_130__(__NFUN_151__(m_iFilterFasterThan, 0), __NFUN_151__(stTempGameServerItem.iPing, m_iFilterFasterThan)))
		{
			// [Explicit Continue]
			goto J0x503;
		}
		// End:0x4BF
		if(__NFUN_130__(m_bFilterSameVersion, __NFUN_129__(stTempGameServerItem.bSameVersion)))
		{
			// [Explicit Continue]
			goto J0x503;
		}
		// End:0x4E7
		if(bIsLanServers)
		{
			m_LanServers.m_GameServerList[i].bDisplay = true;
			// [Explicit Continue]
			goto J0x503;
		}
		m_GameService.m_GameServerList[i].bDisplay = true;
		J0x503:

		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x80;
	}
	return;
}

//==============================================================================
// Refresh -  Refresh the list of servers.  CLears the list then calls the
// appropriate function to completetly rebuild the list of servers with 
// fresh data.
//==============================================================================
function Refresh(bool bActivatedByUser)
{
	local int i;

	// End:0x28
	if(bActivatedByUser)
	{
		// End:0x26
		if(__NFUN_177__(m_fRefeshDeltaTime, 2.0000000))
		{
			m_fRefeshDeltaTime = 0.0000000;			
		}
		else
		{
			return;
		}
	}
	m_oldSelItem = none;
	// End:0xB8
	if(__NFUN_154__(int(m_ConnectionTab), int(0)))
	{
		m_LanServers.RefreshServers();
		ResortServerList(m_iLastSortCategory, m_bLastTypeOfSort);
		GetLanServers();
		i = 0;
		J0x6C:

		// End:0xB5 [Loop If]
		if(__NFUN_150__(i, m_LanServers.m_ClientBeacon.GetBeaconListSize()))
		{
			m_LanServers.m_ClientBeacon.ClearBeacon(i);
			__NFUN_165__(i);
			// [Loop Continue]
			goto J0x6C;
		}		
	}
	else
	{
		// End:0xD6
		if(m_GameService.m_bLoggedInUbiDotCom)
		{
			m_GameService.__NFUN_3520__();
		}
	}
	return;
}

function GetLanServers()
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
	if(__NFUN_119__(m_ServerListBox.m_SelectedItem, none))
	{
		szSelSvrIP = R6WindowListServerItem(m_ServerListBox.m_SelectedItem).szIPAddr;		
	}
	else
	{
		szSelSvrIP = "";
	}
	m_ServerListBox.ClearListOfItems();
	m_ServerListBox.m_SelectedItem = none;
	iNumServers = m_LanServers.m_GameServerList.Length;
	iNumServersDisplay = m_LanServers.__NFUN_1314__();
	bFirstSvr = true;
	iNbPages = __NFUN_145__(iNumServersDisplay, Console.iBrowserMaxNbServerPerPage);
	__NFUN_161__(iNbPages, 1);
	// End:0x103
	if(__NFUN_151__(m_PageCount.m_iCurrentPages, iNbPages))
	{
		m_PageCount.SetCurrentPage(iNbPages);
	}
	// End:0x12F
	if(__NFUN_155__(iNbPages, m_PageCount.m_iTotalPages))
	{
		m_PageCount.SetTotalPages(iNbPages);
	}
	iStartingIndex = __NFUN_144__(Console.iBrowserMaxNbServerPerPage, __NFUN_147__(m_PageCount.m_iCurrentPages, 1));
	iEndIndex = __NFUN_146__(iStartingIndex, Console.iBrowserMaxNbServerPerPage);
	// End:0x18B
	if(__NFUN_151__(iEndIndex, iNumServersDisplay))
	{
		iEndIndex = iNumServersDisplay;
	}
	j = 0;
	i = iStartingIndex;
	J0x19D:

	// End:0x52C [Loop If]
	if(__NFUN_151__(iNumServersDisplay, 0))
	{
		// End:0x4F7
		if(m_LanServers.m_GameServerList[m_LanServers.m_GSLSortIdx[i]].bDisplay)
		{
			NewItem = R6WindowListServerItem(m_ServerListBox.GetNextItem(j, NewItem));
			NewItem.Created();
			NewItem.iMainSvrListIdx = i;
			m_LanServers.getServerListItem(i, _stGameServer);
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
				// End:0x48C
				if(pLevel.IsGameTypeCooperative(szGameType))
				{
					NewItem.szGameMode = Localize("MultiPlayer", "GameMode_Cooperative", "R6Menu");					
				}
				else
				{
					NewItem.szGameMode = "";
				}
			}
			// End:0x4E8
			if(__NFUN_132__(__NFUN_122__(NewItem.szIPAddr, szSelSvrIP), bFirstSvr))
			{
				m_ServerListBox.SetSelectedItem(NewItem);
				m_LanServers.SetSelectedServer(i);
			}
			bFirstSvr = false;
			__NFUN_165__(j);
		}
		__NFUN_165__(i);
		// End:0x517
		if(__NFUN_153__(__NFUN_146__(iStartingIndex, j), iEndIndex))
		{
			// [Explicit Break]
			goto J0x52C;
		}
		// End:0x529
		if(__NFUN_153__(i, iNumServers))
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
// GetGSServers - This functions gets the current list of servers from the 
// game service code, it does not refresh this list, it is simply used for
// passing a list that has already been built.  It will only get the elements
// in the list that have been flagged to be displayed.
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
	if(__NFUN_119__(m_ServerListBox.m_SelectedItem, none))
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
	iNumServersDisplay = m_GameService.__NFUN_1314__();
	bFirstSvr = true;
	iNbPages = __NFUN_145__(iNumServersDisplay, Console.iBrowserMaxNbServerPerPage);
	__NFUN_161__(iNbPages, 1);
	// End:0x103
	if(__NFUN_151__(m_PageCount.m_iCurrentPages, iNbPages))
	{
		m_PageCount.SetCurrentPage(iNbPages);
	}
	// End:0x12F
	if(__NFUN_155__(iNbPages, m_PageCount.m_iTotalPages))
	{
		m_PageCount.SetTotalPages(iNbPages);
	}
	iStartingIndex = __NFUN_144__(Console.iBrowserMaxNbServerPerPage, __NFUN_147__(m_PageCount.m_iCurrentPages, 1));
	iEndIndex = __NFUN_146__(iStartingIndex, Console.iBrowserMaxNbServerPerPage);
	// End:0x18B
	if(__NFUN_151__(iEndIndex, iNumServersDisplay))
	{
		iEndIndex = iNumServersDisplay;
	}
	j = 0;
	i = iStartingIndex;
	J0x19D:

	// End:0x518 [Loop If]
	if(__NFUN_151__(iNumServersDisplay, 0))
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
			if(__NFUN_132__(__NFUN_122__(NewItem.szIPAddr, szSelSvrIP), bFirstSvr))
			{
				m_ServerListBox.SetSelectedItem(NewItem);
				m_GameService.SetSelectedServer(i);
			}
			bFirstSvr = false;
			__NFUN_165__(j);
		}
		__NFUN_165__(i);
		// End:0x503
		if(__NFUN_153__(__NFUN_146__(iStartingIndex, j), iEndIndex))
		{
			// [Explicit Break]
			goto J0x518;
		}
		// End:0x515
		if(__NFUN_153__(i, iNumServers))
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

function GetServerInfo(R6ServerList pServerList)
{
	local R6WindowListInfoPlayerItem NewItemPlayer;
	local R6WindowListInfoMapItem NewItemMap;
	local R6WindowListInfoOptionsItem NewItemOptions;
	local R6MenuButtonsDefines pButtonsDef;
	local int i, iNum;

	ClearServerInfo();
	// End:0x1D
	if(__NFUN_154__(pServerList.m_GameServerList.Length, 0))
	{
		return;
	}
	iNum = pServerList.m_GameServerList[pServerList.m_iSelSrvIndex].sGameData.gameMapList.Length;
	i = 0;
	J0x52:

	// End:0x148 [Loop If]
	if(__NFUN_150__(i, iNum))
	{
		NewItemMap = R6WindowListInfoMapItem(m_ServerInfoMapBox.GetItemAtIndex(i));
		NewItemMap.szMap = pServerList.m_GameServerList[pServerList.m_iSelSrvIndex].sGameData.gameMapList[i].szMap;
		Root.GetMapNameLocalisation(NewItemMap.szMap, NewItemMap.szMap, true);
		NewItemMap.szType = GetLevel().GetGameNameLocalization(pServerList.m_GameServerList[pServerList.m_iSelSrvIndex].sGameData.gameMapList[i].szGameType);
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x52;
	}
	iNum = pServerList.m_GameServerList[pServerList.m_iSelSrvIndex].sGameData.PlayerList.Length;
	pServerList.SortPlayersByKills(false, pServerList.m_iSelSrvIndex);
	i = 0;
	J0x19B:

	// End:0x2E7 [Loop If]
	if(__NFUN_150__(i, iNum))
	{
		NewItemPlayer = R6WindowListInfoPlayerItem(m_ServerInfoPlayerBox.GetItemAtIndex(i));
		NewItemPlayer.szPlName = pServerList.m_GameServerList[pServerList.m_iSelSrvIndex].sGameData.PlayerList[i].szAlias;
		NewItemPlayer.iSkills = pServerList.m_GameServerList[pServerList.m_iSelSrvIndex].sGameData.PlayerList[i].iSkills;
		NewItemPlayer.szTime = pServerList.m_GameServerList[pServerList.m_iSelSrvIndex].sGameData.PlayerList[i].szTime;
		NewItemPlayer.iPing = pServerList.m_GameServerList[pServerList.m_iSelSrvIndex].sGameData.PlayerList[i].iPing;
		NewItemPlayer.iRank = 0;
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x19B;
	}
	pButtonsDef = R6MenuButtonsDefines(GetButtonsDefinesUnique(Root.MenuClassDefines.ClassButtonsDefines));
	i = 0;
	NewItemOptions = R6WindowListInfoOptionsItem(m_ServerInfoOptionsBox.GetItemAtIndex(__NFUN_165__(i)));
	NewItemOptions.szOptions = __NFUN_112__(__NFUN_112__(pButtonsDef.GetButtonLoc(int(1)), " = "), string(pServerList.m_GameServerList[pServerList.m_iSelSrvIndex].sGameData.iRoundsPerMatch));
	NewItemOptions = R6WindowListInfoOptionsItem(m_ServerInfoOptionsBox.GetItemAtIndex(__NFUN_165__(i)));
	NewItemOptions.szOptions = __NFUN_112__(__NFUN_112__(pButtonsDef.GetButtonLoc(int(2)), " = "), Class'Engine.Actor'.static.__NFUN_1520__(pServerList.m_GameServerList[pServerList.m_iSelSrvIndex].sGameData.iRoundTime));
	NewItemOptions = R6WindowListInfoOptionsItem(m_ServerInfoOptionsBox.GetItemAtIndex(__NFUN_165__(i)));
	NewItemOptions.szOptions = __NFUN_112__(__NFUN_112__(pButtonsDef.GetButtonLoc(int(7)), " = "), string(pServerList.m_GameServerList[pServerList.m_iSelSrvIndex].sGameData.iBetTime));
	// End:0x522
	if(pServerList.m_GameServerList[pServerList.m_iSelSrvIndex].sGameData.bAdversarial)
	{
		NewItemOptions = R6WindowListInfoOptionsItem(m_ServerInfoOptionsBox.GetItemAtIndex(__NFUN_165__(i)));
		NewItemOptions.szOptions = __NFUN_112__(__NFUN_112__(pButtonsDef.GetButtonLoc(int(4)), " = "), string(pServerList.m_GameServerList[pServerList.m_iSelSrvIndex].sGameData.iBombTime));		
	}
	else
	{
		NewItemOptions = R6WindowListInfoOptionsItem(m_ServerInfoOptionsBox.GetItemAtIndex(__NFUN_165__(i)));
		NewItemOptions.szOptions = __NFUN_112__(__NFUN_112__(pButtonsDef.GetButtonLoc(int(8)), " = "), string(pServerList.m_GameServerList[pServerList.m_iSelSrvIndex].sGameData.iNumTerro));
		// End:0x605
		if(pServerList.m_GameServerList[pServerList.m_iSelSrvIndex].sGameData.bAIBkp)
		{
			NewItemOptions = R6WindowListInfoOptionsItem(m_ServerInfoOptionsBox.GetItemAtIndex(__NFUN_165__(i)));
			NewItemOptions.szOptions = pButtonsDef.GetButtonLoc(int(17));
		}
		// End:0x673
		if(pServerList.m_GameServerList[pServerList.m_iSelSrvIndex].sGameData.bRotateMap)
		{
			NewItemOptions = R6WindowListInfoOptionsItem(m_ServerInfoOptionsBox.GetItemAtIndex(__NFUN_165__(i)));
			NewItemOptions.szOptions = pButtonsDef.GetButtonLoc(int(16));
		}
	}
	// End:0x6E1
	if(pServerList.m_GameServerList[pServerList.m_iSelSrvIndex].sGameData.bShowNames)
	{
		NewItemOptions = R6WindowListInfoOptionsItem(m_ServerInfoOptionsBox.GetItemAtIndex(__NFUN_165__(i)));
		NewItemOptions.szOptions = pButtonsDef.GetButtonLoc(int(12));
	}
	// End:0x74F
	if(pServerList.m_GameServerList[pServerList.m_iSelSrvIndex].sGameData.bFriendlyFire)
	{
		NewItemOptions = R6WindowListInfoOptionsItem(m_ServerInfoOptionsBox.GetItemAtIndex(__NFUN_165__(i)));
		NewItemOptions.szOptions = pButtonsDef.GetButtonLoc(int(11));
	}
	// End:0x7BD
	if(pServerList.m_GameServerList[pServerList.m_iSelSrvIndex].sGameData.bAutoBalTeam)
	{
		NewItemOptions = R6WindowListInfoOptionsItem(m_ServerInfoOptionsBox.GetItemAtIndex(__NFUN_165__(i)));
		NewItemOptions.szOptions = pButtonsDef.GetButtonLoc(int(13));
	}
	// End:0x82B
	if(pServerList.m_GameServerList[pServerList.m_iSelSrvIndex].sGameData.bTKPenalty)
	{
		NewItemOptions = R6WindowListInfoOptionsItem(m_ServerInfoOptionsBox.GetItemAtIndex(__NFUN_165__(i)));
		NewItemOptions.szOptions = pButtonsDef.GetButtonLoc(int(14));
	}
	// End:0x899
	if(pServerList.m_GameServerList[pServerList.m_iSelSrvIndex].sGameData.bRadar)
	{
		NewItemOptions = R6WindowListInfoOptionsItem(m_ServerInfoOptionsBox.GetItemAtIndex(__NFUN_165__(i)));
		NewItemOptions.szOptions = pButtonsDef.GetButtonLoc(int(15));
	}
	// End:0x907
	if(pServerList.m_GameServerList[pServerList.m_iSelSrvIndex].sGameData.bForceFPWeapon)
	{
		NewItemOptions = R6WindowListInfoOptionsItem(m_ServerInfoOptionsBox.GetItemAtIndex(__NFUN_165__(i)));
		NewItemOptions.szOptions = pButtonsDef.GetButtonLoc(int(18));
	}
	return;
}

//==============================================================================
// ClearServerInfo - clear all of the information in the server info tab.
//==============================================================================
function ClearServerInfo()
{
	m_ServerInfoPlayerBox.ClearListOfItems();
	m_ServerInfoMapBox.ClearListOfItems();
	m_ServerInfoOptionsBox.ClearListOfItems();
	return;
}

function QuickJoin()
{
	return;
}

function JoinSelectedServerRequested()
{
	local int iBeaconPort;

	// End:0x16
	if(__NFUN_114__(m_ServerListBox.m_SelectedItem, none))
	{
		return;
	}
	// End:0xFC
	if(R6WindowListServerItem(m_ServerListBox.m_SelectedItem).bSameVersion)
	{
		// End:0x86
		if(__NFUN_154__(int(m_ConnectionTab), int(1)))
		{
			m_szServerIP = m_GameService.GetSelectedServerIP();
			iBeaconPort = m_GameService.m_GameServerList[m_GameService.m_iSelSrvIndex].iBeaconPort;			
		}
		else
		{
			m_szServerIP = m_LanServers.m_GameServerList[m_LanServers.m_iSelSrvIndex].szIPAddress;
			iBeaconPort = m_LanServers.m_GameServerList[m_LanServers.m_iSelSrvIndex].iBeaconPort;
		}
		m_pQueryServerInfo.StartQueryServerInfoProcedure(OwnerWindow, m_szServerIP, iBeaconPort);
		m_bQueryServerInfoInProgress = true;
	}
	return;
}

function QueryReceivedStartPreJoin()
{
	local bool bRoomValid;

	bRoomValid = __NFUN_130__(__NFUN_155__(m_GameService.m_ClientBeacon.PreJoinInfo.iLobbyID, 0), __NFUN_155__(m_GameService.m_ClientBeacon.PreJoinInfo.iGroupID, 0));
	// End:0xEC
	if(__NFUN_130__(__NFUN_154__(int(m_ConnectionTab), int(1)), __NFUN_129__(bRoomValid)))
	{
		R6MenuRootWindow(Root).SimplePopUp(Localize("MultiPlayer", "PopUp_Error_RoomJoin", "R6Menu"), Localize("MultiPlayer", "PopUp_Error_NoServer", "R6Menu"), 32, int(2));
		Refresh(false);
		return;
	}
	// End:0x12E
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

function Tick(float DeltaTime)
{
	// End:0x70
	if(R6Console(Root.Console).m_bAutoLoginFirstPass)
	{
		R6Console(Root.Console).m_bAutoLoginFirstPass = false;
		// End:0x70
		if(__NFUN_129__(R6Console(Root.Console).m_bStartedByGSClient))
		{
			m_GameService.StartAutoLogin();
		}
	}
	// End:0x14B
	if(m_bFPassWindowActv)
	{
		// End:0xE9
		if(__NFUN_154__(m_iLastTabSel, int(1)))
		{
			m_pFirstTabManager.m_pMainTabControl.GotoTab(m_pFirstTabManager.m_pMainTabControl.GetTab(Localize("MultiPlayer", "Tab_InternetServer", "R6Menu")));			
		}
		else
		{
			m_pFirstTabManager.m_pMainTabControl.GotoTab(m_pFirstTabManager.m_pMainTabControl.GetTab(Localize("MultiPlayer", "Tab_LanServer", "R6Menu")));
		}
		m_bFPassWindowActv = false;
	}
	__NFUN_184__(m_fRefeshDeltaTime, DeltaTime);
	// End:0x196
	if(m_GameService.m_bLoggedInUbiDotCom)
	{
		// End:0x193
		if(__NFUN_155__(int(m_ButtonLogInOut.m_eButton_Action), int(31)))
		{
			m_ButtonLogInOut.SetButLogInOutState(31);
		}		
	}
	else
	{
		// End:0x1C0
		if(__NFUN_155__(int(m_ButtonLogInOut.m_eButton_Action), int(30)))
		{
			m_ButtonLogInOut.SetButLogInOutState(30);
		}
	}
	// End:0x1FD
	if(m_GameService.m_bAutoLoginFailed)
	{
		m_GameService.m_bAutoLoginFailed = false;
		// End:0x1FD
		if(__NFUN_154__(int(m_ConnectionTab), int(1)))
		{
			ManageTabSelection(int(1));
		}
	}
	// End:0x225
	if(m_bLanRefreshFPass)
	{
		// End:0x225
		if(__NFUN_154__(int(m_ConnectionTab), int(0)))
		{
			Refresh(false);
			m_bLanRefreshFPass = false;
		}
	}
	// End:0x261
	if(m_bIntRefreshFPass)
	{
		// End:0x261
		if(__NFUN_130__(__NFUN_154__(int(m_ConnectionTab), int(1)), m_GameService.m_bLoggedInUbiDotCom))
		{
			Refresh(false);
			m_bIntRefreshFPass = false;
		}
	}
	// End:0x291
	if(__NFUN_130__(m_bNeedUpdateServerFilter, __NFUN_177__(GetTime(), __NFUN_174__(m_fLastUpdateServerFilterTime, 0.3000000))))
	{
		m_bNeedUpdateServerFilter = false;
		UpdateServerFilters();
	}
	return;
}

function AddServerToFavorites()
{
	// End:0x3E
	if(__NFUN_154__(int(m_ConnectionTab), int(0)))
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
	if(__NFUN_154__(int(m_ConnectionTab), int(0)))
	{
		m_LanServers.DelFromFavorites(R6WindowListServerItem(m_ServerListBox.m_SelectedItem).iMainSvrListIdx);		
	}
	else
	{
		m_GameService.DelFromFavorites(R6WindowListServerItem(m_ServerListBox.m_SelectedItem).iMainSvrListIdx);
	}
	return;
}

function PromptConnectionError()
{
	local R6MenuRootWindow r6Root;
	local string szTemp;

	r6Root = R6MenuRootWindow(Root);
	r6Root.m_RSimplePopUp.X = 140;
	r6Root.m_RSimplePopUp.Y = 170;
	r6Root.m_RSimplePopUp.W = 360;
	r6Root.m_RSimplePopUp.H = 77;
	// End:0x1AD
	if(__NFUN_123__(R6Console(Root.Console).m_szLastError, ""))
	{
		szTemp = Localize("Multiplayer", R6Console(Root.Console).m_szLastError, "R6Menu", true);
		// End:0x113
		if(__NFUN_122__(szTemp, ""))
		{
			szTemp = Localize("Errors", R6Console(Root.Console).m_szLastError, "R6Engine", true);
		}
		// End:0x141
		if(__NFUN_122__(szTemp, ""))
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

function UpdateFavorites()
{
	// End:0x4B
	if(__NFUN_122__(m_pRightClickMenu.GetValue(), Localize("MultiPlayer", "RightClick_AddFav", "R6Menu")))
	{
		AddServerToFavorites();		
	}
	else
	{
		// End:0x96
		if(__NFUN_122__(m_pRightClickMenu.GetValue(), Localize("MultiPlayer", "RightClick_SubFav", "R6Menu")))
		{
			DelServerFromFavorites();			
		}
		else
		{
			// End:0x13C
			if(__NFUN_122__(m_pRightClickMenu.GetValue(), Localize("MultiPlayer", "RightClick_Refr", "R6Menu")))
			{
				// End:0x114
				if(__NFUN_154__(int(m_ConnectionTab), int(0)))
				{
					m_LanServers.RefreshOneServer(R6WindowListServerItem(m_ServerListBox.m_SelectedItem).iMainSvrListIdx);					
				}
				else
				{
					m_GameService.__NFUN_3521__(R6WindowListServerItem(m_ServerListBox.m_SelectedItem).iMainSvrListIdx);
				}
			}
		}
	}
	// End:0x15B
	if(__NFUN_154__(int(m_ConnectionTab), int(0)))
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

function ResortServerList(int iCategory, bool _bAscending)
{
	m_iLastSortCategory = iCategory;
	m_bLastTypeOfSort = _bAscending;
	m_GameService.__NFUN_1206__(iCategory, _bAscending);
	m_LanServers.__NFUN_1206__(iCategory, _bAscending);
	// End:0x5F
	if(__NFUN_154__(int(m_ConnectionTab), int(0)))
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
function InitText()
{
	m_LMenuTitle = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', 0.0000000, 18.0000000, __NFUN_175__(WinWidth, float(8)), 25.0000000, self));
	m_LMenuTitle.Text = Localize("MultiPlayer", "Title", "R6Menu");
	m_LMenuTitle.Align = 1;
	m_LMenuTitle.m_Font = Root.Fonts[4];
	m_LMenuTitle.TextColor = Root.Colors.White;
	m_LMenuTitle.m_BGTexture = none;
	m_LMenuTitle.m_HBorderTexture = none;
	m_LMenuTitle.m_VBorderTexture = none;
	return;
}

function InitButton()
{
	local Font ButtonFont;
	local float fXOffset, fYOffset, fWidth;
	local R6MenuButtonsDefines pButtonsDef;

	m_ButtonMainMenu = R6WindowButton(CreateControl(Class'R6Window.R6WindowButton', 10.0000000, 425.0000000, 250.0000000, 25.0000000, self));
	m_ButtonMainMenu.ToolTipString = Localize("Tip", "ButtonMainMenu", "R6Menu");
	m_ButtonMainMenu.Text = Localize("SinglePlayer", "ButtonMainMenu", "R6Menu");
	m_ButtonMainMenu.Align = 0;
	m_ButtonMainMenu.m_fFontSpacing = 0.0000000;
	m_ButtonMainMenu.m_buttonFont = Root.Fonts[15];
	m_ButtonMainMenu.ResizeToText();
	m_ButtonOptions = R6WindowButton(CreateControl(Class'R6Window.R6WindowButton', 10.0000000, 447.0000000, 250.0000000, 25.0000000, self));
	m_ButtonOptions.ToolTipString = Localize("Tip", "ButtonOptions", "R6Menu");
	m_ButtonOptions.Text = Localize("SinglePlayer", "ButtonOptions", "R6Menu");
	m_ButtonOptions.Align = 0;
	m_ButtonOptions.m_fFontSpacing = 0.0000000;
	m_ButtonOptions.m_buttonFont = Root.Fonts[15];
	ButtonFont = Root.Fonts[16];
	pButtonsDef = R6MenuButtonsDefines(GetButtonsDefinesUnique(Root.MenuClassDefines.ClassButtonsDefines));
	fXOffset = 10.0000000;
	fYOffset = 50.0000000;
	fWidth = 124.0000000;
	m_ButtonLogInOut = R6WindowButtonMultiMenu(CreateWindow(Class'R6Menu.R6WindowButtonMultiMenu', fXOffset, fYOffset, 400.0000000, 25.0000000, self));
	m_ButtonLogInOut.ToolTipString = pButtonsDef.GetButtonLoc(int(30), true);
	m_ButtonLogInOut.Text = pButtonsDef.GetButtonLoc(int(30));
	m_ButtonLogInOut.m_eButton_Action = 30;
	m_ButtonLogInOut.Align = 0;
	m_ButtonLogInOut.m_fFontSpacing = 0.0000000;
	m_ButtonLogInOut.m_buttonFont = ButtonFont;
	m_ButtonLogInOut.ResizeToText();
	__NFUN_184__(fXOffset, fWidth);
	m_ButtonJoin = R6WindowButtonMultiMenu(CreateWindow(Class'R6Menu.R6WindowButtonMultiMenu', fXOffset, fYOffset, 400.0000000, 25.0000000, self));
	m_ButtonJoin.ToolTipString = pButtonsDef.GetButtonLoc(int(32), true);
	m_ButtonJoin.Text = pButtonsDef.GetButtonLoc(int(32));
	m_ButtonJoin.m_eButton_Action = 32;
	m_ButtonJoin.Align = 0;
	m_ButtonJoin.m_fFontSpacing = 0.0000000;
	m_ButtonJoin.m_buttonFont = ButtonFont;
	m_ButtonJoin.ResizeToText();
	m_ButtonJoin.m_pPreviousButtonPos = m_ButtonLogInOut;
	m_ButtonJoin.m_pRefButtonPos = m_ButtonLogInOut;
	__NFUN_184__(fXOffset, fWidth);
	m_ButtonJoinIP = R6WindowButtonMultiMenu(CreateWindow(Class'R6Menu.R6WindowButtonMultiMenu', fXOffset, fYOffset, 400.0000000, 25.0000000, self));
	m_ButtonJoinIP.ToolTipString = pButtonsDef.GetButtonLoc(int(33), true);
	m_ButtonJoinIP.Text = pButtonsDef.GetButtonLoc(int(33));
	m_ButtonJoinIP.m_eButton_Action = 33;
	m_ButtonJoinIP.Align = 0;
	m_ButtonJoinIP.m_fFontSpacing = 0.0000000;
	m_ButtonJoinIP.m_buttonFont = ButtonFont;
	m_ButtonJoinIP.ResizeToText();
	m_ButtonJoinIP.m_pPreviousButtonPos = m_ButtonJoin;
	m_ButtonJoinIP.m_pRefButtonPos = m_ButtonLogInOut;
	__NFUN_184__(fXOffset, fWidth);
	m_ButtonRefresh = R6WindowButtonMultiMenu(CreateWindow(Class'R6Menu.R6WindowButtonMultiMenu', fXOffset, fYOffset, 400.0000000, 25.0000000, self));
	m_ButtonRefresh.ToolTipString = pButtonsDef.GetButtonLoc(int(34), true);
	m_ButtonRefresh.Text = pButtonsDef.GetButtonLoc(int(34));
	m_ButtonRefresh.m_eButton_Action = 34;
	m_ButtonRefresh.Align = 0;
	m_ButtonRefresh.m_fFontSpacing = 0.0000000;
	m_ButtonRefresh.m_buttonFont = ButtonFont;
	m_ButtonRefresh.ResizeToText();
	m_ButtonRefresh.m_pPreviousButtonPos = m_ButtonJoinIP;
	m_ButtonRefresh.m_pRefButtonPos = m_ButtonLogInOut;
	__NFUN_184__(fXOffset, fWidth);
	m_ButtonCreate = R6WindowButtonMultiMenu(CreateWindow(Class'R6Menu.R6WindowButtonMultiMenu', fXOffset, fYOffset, fWidth, 25.0000000, self));
	m_ButtonCreate.ToolTipString = pButtonsDef.GetButtonLoc(int(35), true);
	m_ButtonCreate.Text = pButtonsDef.GetButtonLoc(int(35));
	m_ButtonCreate.m_eButton_Action = 35;
	m_ButtonCreate.Align = 1;
	m_ButtonCreate.m_fFontSpacing = 0.0000000;
	m_ButtonCreate.m_buttonFont = ButtonFont;
	m_ButtonCreate.ResizeToText();
	m_ButtonCreate.m_pRefButtonPos = m_ButtonLogInOut;
	return;
}

function InitInfoBar()
{
	local float fWidth, fPreviousPos;

	fWidth = 15.0000000;
	fPreviousPos = 0.0000000;
	m_pButServerList = R6MenuMPButServerList(CreateWindow(Class'R6Menu.R6MenuMPButServerList', __NFUN_174__(10.0000000, float(1)), 114.0000000, __NFUN_175__(620.0000000, float(2)), 12.0000000, self));
	return;
}

function InitFirstTabWindow()
{
	local float fWidth;

	fWidth = 1.0000000;
	m_pFirstWindowBorder = R6WindowSimpleFramedWindowExt(CreateWindow(Class'R6Window.R6WindowSimpleFramedWindowExt', 10.0000000, 126.0000000, 620.0000000, 154.0000000, self));
	m_pFirstWindowBorder.bAlwaysBehind = true;
	m_pFirstWindowBorder.ActiveBorder(0, false);
	m_pFirstWindowBorder.SetBorderParam(1, 7.0000000, 0.0000000, fWidth, Root.Colors.White);
	m_pFirstWindowBorder.SetBorderParam(2, 1.0000000, 0.0000000, fWidth, Root.Colors.White);
	m_pFirstWindowBorder.SetBorderParam(3, 1.0000000, 0.0000000, fWidth, Root.Colors.White);
	m_pFirstWindowBorder.m_eCornerType = 2;
	m_pFirstWindowBorder.SetCornerColor(2, Root.Colors.White);
	m_pFirstWindowBorder.ActiveBackGround(true, Root.Colors.Black);
	return;
}

function InitServerList()
{
	local Font ButtonFont;
	local int iFiles, i, j;

	// End:0x0D
	if(__NFUN_119__(m_ServerListBox, none))
	{
		return;
	}
	m_ServerListBox = R6WindowServerListBox(CreateWindow(Class'R6Window.R6WindowServerListBox', 12.0000000, 126.0000000, 616.0000000, 154.0000000, self));
	m_ServerListBox.Register(m_pFirstTabManager);
	m_ServerListBox.SetCornerType(1);
	m_ServerListBox.m_Font = Root.Fonts[10];
	m_ServerListBox.m_iPingTimeOut = m_LanServers.__NFUN_1202__();
	return;
}

function InitServerInfoPlayer()
{
	local Font ButtonFont;
	local int iFiles, i, j;

	m_ServerInfoPlayerBox = R6WindowServerInfoPlayerBox(CreateWindow(Class'R6Window.R6WindowServerInfoPlayerBox', 10.0000000, 336.0000000, 245.0000000, 79.0000000, self));
	m_ServerInfoPlayerBox.ToolTipString = Localize("Tip", "InfoBar_ServerInfo_Player", "R6Menu");
	m_ServerInfoPlayerBox.SetCornerType(1);
	m_ServerInfoPlayerBox.m_Font = Root.Fonts[10];
	m_ServerInfoPlayerBox.HideWindow();
	return;
}

function InitServerInfoMap()
{
	local Font ButtonFont;
	local int iFiles, i, j;

	m_ServerInfoMapBox = R6WindowServerInfoMapBox(CreateWindow(Class'R6Window.R6WindowServerInfoMapBox', 255.0000000, 336.0000000, 174.0000000, 79.0000000, self));
	m_ServerInfoMapBox.ToolTipString = Localize("Tip", "InfoBar_ServerInfo_Map", "R6Menu");
	m_ServerInfoMapBox.SetCornerType(0);
	m_ServerInfoMapBox.m_Font = Root.Fonts[10];
	m_ServerInfoMapBox.HideWindow();
	return;
}

function InitServerInfoOptions()
{
	local Font ButtonFont;
	local int iFiles, i, j;

	m_ServerInfoOptionsBox = R6WindowServerInfoOptionsBox(CreateWindow(Class'R6Window.R6WindowServerInfoOptionsBox', 429.0000000, 336.0000000, 200.0000000, 79.0000000, self));
	m_ServerInfoOptionsBox.ToolTipString = Localize("Tip", "InfoBar_ServerInfo_Opt", "R6Menu");
	m_ServerInfoOptionsBox.SetCornerType(0);
	m_ServerInfoOptionsBox.m_Font = Root.Fonts[10];
	m_ServerInfoOptionsBox.HideWindow();
	return;
}

function InitSecondTabWindow()
{
	local float fWidth;

	fWidth = 1.0000000;
	// End:0x279
	if(__NFUN_114__(m_pSecondWindowBorder, none))
	{
		m_pSecondWindowBorder = R6WindowSimpleFramedWindowExt(CreateWindow(Class'R6Window.R6WindowSimpleFramedWindowExt', 10.0000000, __NFUN_174__(296.0000000, float(29)), 620.0000000, 90.0000000, self));
		m_pSecondWindowBorder.bAlwaysBehind = true;
		m_pSecondWindowBorder.ActiveBorder(0, false);
		m_pSecondWindowBorder.SetBorderParam(1, 7.0000000, 0.0000000, fWidth, Root.Colors.White);
		m_pSecondWindowBorder.SetBorderParam(2, 1.0000000, 1.0000000, fWidth, Root.Colors.White);
		m_pSecondWindowBorder.SetBorderParam(3, 1.0000000, 1.0000000, fWidth, Root.Colors.White);
		m_pSecondWindowBorder.m_eCornerType = 2;
		m_pSecondWindowBorder.SetCornerColor(2, Root.Colors.White);
		m_pSecondWindowBorder.ActiveBackGround(true, Root.Colors.Black);
		m_pSecondWindowGameMode = R6MenuMPMenuTab(CreateWindow(Root.MenuClassDefines.ClassMPMenuTabGameModeFilters, 10.0000000, __NFUN_174__(296.0000000, float(29)), 620.0000000, 90.0000000, self));
		m_pSecondWindowGameMode.InitGameModeTab();
		m_pSecondWindowFilter = R6MenuMPMenuTab(CreateWindow(Class'R6Menu.R6MenuMPMenuTab', 10.0000000, __NFUN_174__(296.0000000, float(29)), 620.0000000, 90.0000000, self));
		m_pSecondWindowFilter.InitFilterTab();
		m_pSecondWindowFilter.HideWindow();
		m_pSecondWindowServerInfo = R6MenuMPMenuTab(CreateWindow(Class'R6Menu.R6MenuMPMenuTab', 10.0000000, __NFUN_174__(296.0000000, float(29)), 620.0000000, 90.0000000, self));
		m_pSecondWindowServerInfo.bAlwaysBehind = true;
		m_pSecondWindowServerInfo.InitServerTab();
		m_pSecondWindowServerInfo.HideWindow();
		m_pSecondWindow = m_pSecondWindowGameMode;
	}
	return;
}

function InitRightClickMenu()
{
	m_pRightClickMenu = R6WindowRightClickMenu(CreateControl(Class'R6Window.R6WindowRightClickMenu', 100.0000000, 150.0000000, 140.0000000, 14.0000000));
	m_pRightClickMenu.Register(m_pFirstTabManager);
	m_pRightClickMenu.EditBoxWidth = 140.0000000;
	m_pRightClickMenu.SetFont(6);
	m_pRightClickMenu.SetValue("");
	m_pRightClickMenu.AddItem(Localize("MultiPlayer", "RightClick_AddFav", "R6Menu"));
	m_pRightClickMenu.AddItem(Localize("MultiPlayer", "RightClick_SubFav", "R6Menu"));
	m_pRightClickMenu.AddItem(Localize("MultiPlayer", "RightClick_Refr", "R6Menu"));
	m_pRightClickMenu.HideWindow();
	return;
}

function SendMessage(UWindowWindow.eR6MenuWidgetMessage eMessage)
{
	switch(eMessage)
	{
		// End:0xE3
		case 0:
			switch(m_LoginSuccessAction)
			{
				// End:0x35
				case 1:
					m_szServerIP = m_pJoinIPWindow.m_szIP;
					QueryReceivedStartPreJoin();
					// End:0xD8
					break;
				// End:0x43
				case 2:
					QueryReceivedStartPreJoin();
					// End:0xD8
					break;
				// End:0x52
				case 3:
					Refresh(false);
					// End:0xD8
					break;
				// End:0xB9
				case 6:
					m_pFirstTabManager.m_pMainTabControl.GotoTab(m_pFirstTabManager.m_pMainTabControl.GetTab(Localize("MultiPlayer", "Tab_InternetServer", "R6Menu")));
					// End:0xD8
					break;
				// End:0xD5
				case 5:
					// End:0xD5
					if(__NFUN_154__(int(m_ConnectionTab), int(1)))
					{
						Refresh(false);
					}
				// End:0xFFFF
				default:
					break;
			}
			m_LoginSuccessAction = 0;
			// End:0x2E8
			break;
		// End:0x14D
		case 1:
			m_pFirstTabManager.m_pMainTabControl.GotoTab(m_pFirstTabManager.m_pMainTabControl.GetTab(Localize("MultiPlayer", "Tab_LanServer", "R6Menu")));
			m_LoginSuccessAction = 0;
			// End:0x2E8
			break;
		// End:0x197
		case 2:
			switch(m_LoginSuccessAction)
			{
				// End:0x17B
				case 1:
					m_szServerIP = m_pJoinIPWindow.m_szIP;
					QueryReceivedStartPreJoin();
					// End:0x18C
					break;
				// End:0x189
				case 2:
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
		case 3:
		// End:0x1A1
		case 4:
		// End:0x214
		case 5:
			__NFUN_231__("R6MenuMultiplayerWidget SendMessage() not supposed to arrive here (should be in R6MenuCDKeyManager)!!!!");
			// End:0x2E8
			break;
		// End:0x282
		case 6:
			m_bJoinIPInProgress = false;
			m_szPopUpIP = m_pJoinIPWindow.m_szIP;
			__NFUN_536__();
			// End:0x265
			if(m_pJoinIPWindow.m_bRoomValid)
			{
				m_LoginSuccessAction = 1;
				m_pLoginWindow.StartLogInProcedure(self);				
			}
			else
			{
				m_szServerIP = m_pJoinIPWindow.m_szIP;
				QueryReceivedStartPreJoin();
			}
			// End:0x2E8
			break;
		// End:0x292
		case 7:
			m_bJoinIPInProgress = false;
			// End:0x2E8
			break;
		// End:0x2D5
		case 8:
			// End:0x2C4
			if(m_pQueryServerInfo.m_bRoomValid)
			{
				m_LoginSuccessAction = 2;
				m_pLoginWindow.StartLogInProcedure(self);				
			}
			else
			{
				QueryReceivedStartPreJoin();
			}
			m_bQueryServerInfoInProgress = false;
			// End:0x2E8
			break;
		// End:0x2E5
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

function Notify(UWindowDialogControl C, byte E)
{
	// End:0xC6
	if(__NFUN_154__(int(E), 2))
	{
		switch(C)
		{
			// End:0x31
			case m_ButtonMainMenu:
				Root.ChangeCurrentWidget(7);
				// End:0xC6
				break;
			// End:0x4D
			case m_ButtonOptions:
				Root.ChangeCurrentWidget(16);
				// End:0xC6
				break;
			// End:0x88
			case m_PageCount.m_pNextButton:
				m_PageCount.NextPage();
				m_GameService.m_bServerListChanged = true;
				m_iTimeLastUpdate = 0;
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

function BackToMainMenu()
{
	local ClientBeaconReceiver _BeaconReceiver;

	ResetMultiplayerMenu();
	return;
}

function ResetMultiplayerMenu()
{
	local ClientBeaconReceiver _BeaconReceiver;

	// End:0x2F
	if(__NFUN_119__(m_LanServers, none))
	{
		_BeaconReceiver = m_LanServers.m_ClientBeacon;
		m_LanServers.m_ClientBeacon = none;
	}
	// End:0x4A
	if(__NFUN_119__(m_GameService, none))
	{
		m_GameService.m_ClientBeacon = none;
	}
	// End:0x61
	if(__NFUN_119__(_BeaconReceiver, none))
	{
		_BeaconReceiver.__NFUN_279__();
	}
	m_LanServers = none;
	R6Console(Root.Console).m_LanServers = none;
	return;
}

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
