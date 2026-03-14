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

// --- Constants ---
const K_UPDATE_FILTER_INTERVAL =  0.3;
const K_REFRESH_TIMEOUT =  2.0;
const K_LIST_UPDATE_TIME =  1000;
const C_fDIST_BETWEEN_BUTTON =  30;
const K_YPOS_HELPTEXT_WINDOW =  430;
const K_YPOS_SECOND_TABWINDOW =  296;
const K_YPOS_FIRST_TABWINDOW =  126;
const K_FSECOND_WINDOWHEIGHT =  90;
const K_FFIRST_WINDOWHEIGHT =  154;
const K_SEC_TABWINDOW_WIDTH =  600;
const K_FIRST_TABWINDOW_WIDTH =  500;
const K_XTABOFFSET =  5;
const K_WINDOWWIDTH_NOBORDER =  616;
const K_XSTARTPOS_NOBORDER =  12;
const K_WINDOWWIDTH =  620;
const K_XSTARTPOS =  10;

// --- Enums ---
enum MultiPlayerTabID
{
    TAB_Lan_Server,
    TAB_Internet_Server,
    TAB_Game_Mode,
    TAB_Tech_Filter,
    TAB_Server_Info
};
enum eLoginSuccessAction
{
    eLSAct_None,
    eLSAct_JoinIP,
    eLSAct_Join,
    eLSAct_InternetTab,
    eLSAct_LaunchServer,
    eLSAct_CloseWindow,
    eLSAct_SwitchToInternetTab
};
enum eServerInfoID
{
    eServerInfoID_DeathMatch,
    eServerInfoID_TeamDeathMatch,
	eServerInfoID_Bomb,
    eServerInfoID_HostageAdv,
    eServerInfoID_Escort,
    eServerInfoID_Mission,
    eServerInfoID_Terrorist,
    eServerInfoID_HostageCoop,
    eServerInfoID_Defend,
    eServerInfoID_Recon,
    eServerInfoID_Unlocked,
    eServerInfoID_Favorites,
    eServerInfoID_Dedicated,
//#ifdefR6PUNKBUSTER
    eServerInfoID_PunkBuster,
//#endif
    eServerInfoID_NotEmpty,
    eServerInfoID_NotFull,
    eServerInfoID_Responding,
    eServerInfoID_HasPlayer,
    eServerInfoID_SameVersion
};

// --- Variables ---
// var ? m_bChangeMap; // REMOVED IN 1.60
// var ? m_bPreJoinInProgress; // REMOVED IN 1.60
// var ? m_pCDKeyCheckWindow; // REMOVED IN 1.60
// Manages servers from game service
var R6GSServers m_GameService;
// Manages servers on the LAN
var R6LanServers m_LanServers;
// List of servers with scroll bar
var R6WindowServerListBox m_ServerListBox;
var MultiPlayerTabID m_ConnectionTab;
// List of information for selected server
var R6WindowServerInfoOptionsBox m_ServerInfoOptionsBox;
var R6WindowButtonMultiMenu m_ButtonLogInOut;
var R6WindowPageSwitch m_PageCount;
// creation of the tab manager for the first tab window
var R6MenuMPManageTab m_pFirstTabManager;
var R6WindowButtonMultiMenu m_ButtonJoin;
// Used when user right clicks on a server
var R6WindowRightClickMenu m_pRightClickMenu;
var R6WindowButtonMultiMenu m_ButtonJoinIP;
// Windows and login for Join IP steps
var R6WindowJoinIP m_pJoinIPWindow;
// Action to take after login procedure succeeds
var eLoginSuccessAction m_LoginSuccessAction;
var R6WindowButtonMultiMenu m_ButtonRefresh;
var R6WindowSimpleFramedWindowExt m_pSecondWindowBorder;
// List of information for selected server
var R6WindowServerInfoPlayerBox m_ServerInfoPlayerBox;
// List of information for selected server
var R6WindowServerInfoMapBox m_ServerInfoMapBox;
// Windows and logic for ubi.com login
var R6WindowUbiLogIn m_pLoginWindow;
var R6WindowButtonMultiMenu m_ButtonCreate;
var R6WindowSimpleFramedWindowExt m_pFirstWindowBorder;
var R6WindowButton m_ButtonMainMenu;
var R6WindowTextLabel m_LMenuTitle;
var R6MenuMPMenuTab m_pSecondWindow;
var R6WindowButton m_ButtonOptions;
// Windows and login for logic to query a server for information
var R6WindowQueryServerInfo m_pQueryServerInfo;
// IP of server
var string m_szServerIP;
var bool m_bLastTypeOfSort;
var R6MenuMPMenuTab m_pSecondWindowServerInfo;
var R6MenuMPMenuTab m_pSecondWindowGameMode;
var R6MenuMPMenuTab m_pSecondWindowFilter;
var config int m_iFilterFasterThan;
// ^ NEW IN 1.60
var bool m_bNeedUpdateServerFilter;
// ^ NEW IN 1.60
var bool m_bJoinIPInProgress;
// the last sort we did
var int m_iLastSortCategory;
var R6MenuHelpWindow m_pHelpTextWindow;
var config bool m_bFilterServersNotFull;
// ^ NEW IN 1.60
var float m_fLastUpdateServerFilterTime;
// ^ NEW IN 1.60
// Need to get the server info for the selected server
var bool m_bGetServerInfo;
// Time since refresh button last hit
var float m_fRefeshDeltaTime;
var bool m_bQueryServerInfoInProgress;
                                                                 // keeps a history of pop up to return to./
// Time in ms of the last server list update
var int m_iTimeLastUpdate;
// array of text localization
var string m_szMultiLoc[2];
var MultiPlayerTabID m_FilterTab;
// creation of the tab manager for the second tab window
var R6MenuMPManageTab m_pSecondTabManager;
// Second tab window ( on a simple curved frame)
var R6WindowTextLabelCurved m_SecondTabWindow;
// First tab window (on a simple curved frame)
var R6WindowTextLabelCurved m_FirstTabWindow;
// Used to detect when selected server has changed
var UWindowListBoxItem m_oldSelItem;
// The last tab selected between Internet and LAN
var config int m_iLastTabSel;
// total players
var int m_iTotalPlayers;
// First pass flag used for when window is first activated
var bool m_bFPassWindowActv;
var config bool m_bFilterDeathMatch;
// ^ NEW IN 1.60
var config bool m_bFilterTeamDeathMatch;
// ^ NEW IN 1.60
var config bool m_bFilterDisarmBomb;
// ^ NEW IN 1.60
var config bool m_bFilterHostageRescueAdv;
// ^ NEW IN 1.60
var config bool m_bFilterEscortPilot;
// ^ NEW IN 1.60
var config bool m_bFilterMission;
// ^ NEW IN 1.60
var config bool m_bFilterTerroristHunt;
// ^ NEW IN 1.60
var config bool m_bFilterHostageRescueCoop;
// ^ NEW IN 1.60
var config bool m_bFilterUnlockedOnly;
// ^ NEW IN 1.60
var config bool m_bFilterFavoritesOnly;
// ^ NEW IN 1.60
var config bool m_bFilterDedicatedServersOnly;
// ^ NEW IN 1.60
var config bool m_bFilterServersNotEmpty;
// ^ NEW IN 1.60
var config bool m_bFilterResponding;
// ^ NEW IN 1.60
var config bool m_bFilterSameVersion;
// ^ NEW IN 1.60
var config bool m_bFilterPunkBusterServerOnly;
// ^ NEW IN 1.60
// IP adress entered in pop up
var config string m_szPopUpIP;
// X position of mouse
var float m_fMouseX;
// Y position of mouse
var float m_fMouseY;
// First pass flag for LAN server refresh
var bool m_bLanRefreshFPass;
// First pass flag for Internet server refresh
var bool m_bIntRefreshFPass;
// the buttons for sorting
var R6MenuMPButServerList m_pButServerList;
// the server list needs to be updated
var bool m_bListUpdateReq;
var string m_szGamePwd;
// Counter to schedule slower processes
var int m_FrameCounter;
// the info bar description
var R6WindowTextLabelExt m_ServerDescription;

// --- Functions ---
// function ? JoinServer(...); // REMOVED IN 1.60
// function ? SetServerFilterHasPlayer(...); // REMOVED IN 1.60
function ShowWindow() {}
function GetServerInfo(R6ServerList pServerList) {}
function GetLanServers() {}
//==============================================================================
// GetGSServers - This functions gets the current list of servers from the
// game service code, it does not refresh this list, it is simply used for
// passing a list that has already been built.  It will only get the elements
// in the list that have been flagged to be displayed.
//==============================================================================
function GetGSServers() {}
function UpdateFilters() {}
// ^ NEW IN 1.60
/////////////////////////////////////////////////////////////////
// set the button choice from game mode, tech filters
/////////////////////////////////////////////////////////////////
function SetServerFilterBooleans(bool _bNewChoice, int _iServerInfoID) {}
function InitButton() {}
function ResetMultiplayerMenu() {}
function ResortServerList(bool _bAscending, int iCategory) {}
function QueryReceivedStartPreJoin() {}
function JoinSelectedServerRequested() {}
function Notify(byte E, UWindowDialogControl C) {}
function SendMessage(eR6MenuWidgetMessage eMessage) {}
function PromptConnectionError() {}
function InitInfoBar() {}
function Tick(float DeltaTime) {}
//-------------------------------------------------------
// SetServerFilterFasterThan - Set the "Faster Than" filter
// setting (ping time)
//-------------------------------------------------------
function SetServerFilterFasterThan(int iFasterThan) {}
/////////////////////////////////////////////////////////////////
// manage the tab selection (the call of the fct come from R6MenuMPManageTab
/////////////////////////////////////////////////////////////////
function ManageTabSelection(int _MPTabChoiceID) {}
/////////////////////////////////////////////////////////////////
// display the help text in the m_pHelpTextWindow (derivate for uwindowwindow
/////////////////////////////////////////////////////////////////
function ToolTip(string strTip) {}
/////////////////////////////////////////////////////////////////
// display the background
/////////////////////////////////////////////////////////////////
function Paint(float Y, float X, Canvas C) {}
function InitSecondTabWindow() {}
function InitFirstTabWindow() {}
//==============================================================================
// Refresh -  Refresh the list of servers.  CLears the list then calls the
// appropriate function to completetly rebuild the list of servers with
// fresh data.
//==============================================================================
function Refresh(bool bActivatedByUser) {}
function ManageToolTip(string _strTip, optional bool _bForceATip) {}
function BackToMainMenu() {}
function InitRightClickMenu() {}
function InitServerInfoOptions() {}
function InitServerInfoMap() {}
function InitServerInfoPlayer() {}
function InitServerList() {}
//*********************************
//      INIT CREATE FUNCTION
//*********************************
function InitText() {}
function UpdateFavorites() {}
//---------------------------------------------------------------------------------
// DisplayRightClickMenu - Called when the user has right clicked on a server, the
// right click menu is displayed at the current mouse position
//---------------------------------------------------------------------------------
function DisplayRightClickMenu() {}
//==============================================================================
// PopUpBoxDone -  receive the result of the popup box
//==============================================================================
function PopUpBoxDone(EPopUpID _ePopUpID, MessageBoxResult Result) {}
function DelServerFromFavorites() {}
function AddServerToFavorites() {}
function QuickJoin() {}
//==============================================================================
// ClearServerInfo - clear all of the information in the server info tab.
//==============================================================================
function ClearServerInfo() {}
//-------------------------------------------------------
// UpdateServerFilters - Call this every time one of the
// filter settings changes, it we check the list of servers
// to see whcih ones should be displayed.
//-------------------------------------------------------
function UpdateServerFilters() {}
function Created() {}

defaultproperties
{
}
