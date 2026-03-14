//=============================================================================
//  R6MenuMPMenuTab.uc : All the create game tab menu were define overhere
//                       You can choose only one of the 3 possible settings!!!!
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/04/15  * Create by Yannick Joly
//=============================================================================
class R6MenuMPCreateGameTab extends UWindowDialogClientWindow;

// --- Constants ---
const K_HALFWINDOWWIDTH =  310;

// --- Enums ---
enum eCreateGameWindow_ID
{
	eCGW_NotDefine,
	eCGW_Opt,							// regular options
	eCGW_Camera,						// camera options
	eCGW_MapList,						// map list
	eCGW_Password,						// password
	eCGW_AdminPassword,					// admin password
	eCGW_LeftAdvOpt,					// left advanced options list
	eCGW_RightAdvOpt					// right advanced options list
};

// --- Structs ---
struct stServerGameOpt
{
	var UWindowWindow					pGameOptList;
	var Actor.EGameModeInfo				eGameMode;					// the gamemode with list was associate
	var eCreateGameWindow_ID			eCGWindowID;
};

// --- Variables ---
// var ? eCGWindowID; // REMOVED IN 1.60
// var ? eGameMode; // REMOVED IN 1.60
// var ? m_bShowLog; // REMOVED IN 1.60
// var ? pGameOptList; // REMOVED IN 1.60
var R6MenuButtonsDefines m_pButtonsDef;
//temp until you can get the info from modmanager
var array<array> m_ANbOfGameMode;
// an array of all buttons list and their associate gamemode
var array<array> m_AServerGameOpt;
// the init is complete or not
var bool m_bInitComplete;
// temp
var bool m_bInGame;
var array<array> m_ALocGameMode;
var bool m_bNewServerProfile;
var array<array> m_ALinkWindow;
// the current game mode
var EGameModeInfo m_eCurrentGameMode;

// --- Functions ---
//*******************************************************************************************
// INIT
//*******************************************************************************************
function Created() {}
function SetServerOptions() {}
//=================================================================
// manage the R6WindowButton notify message
//=================================================================
function ManageR6ButtonNotify(UWindowDialogControl C, byte E) {}
function UpdateMenuOptions(optional bool _bChangeByUserClick, R6WindowListGeneral _pOptionsList, bool _bNewValue, int _iButID) {}
//*******************************************************************************************
// SERVER OPTIONS FUNCTIONS
//*******************************************************************************************
//=======================================================================
// RefreshServerOpt: Refresh the creategame options according the value find in class R6ServerInfo (init from server.ini)
//=======================================================================
function RefreshServerOpt(optional bool _bNewServerProfile) {}
//===============================================================
// UpdateButtons: do the init of the buttons you need
//===============================================================
function UpdateButtons(optional bool _bUpdateValue, eCreateGameWindow_ID _eCGWindowID, EGameModeInfo _eGameMode) {}
function bool SendNewServerSettings() {}
// ^ NEW IN 1.60
function bool SendNewMapSettings(out byte _bMapCount) {}
// ^ NEW IN 1.60
//*******************************************************************************************
// NOTIFY FUNCTIONS
//*******************************************************************************************
//=================================================================
// notify the parent window by using the appropriate parent function
//=================================================================
function Notify(UWindowDialogControl C, byte E) {}
//*******************************************************************************************
// IN-GAME FUNCTIONS
//*******************************************************************************************
function Refresh() {}
//*******************************************************************************************
// UTILITIES FUNCTIONS
//*******************************************************************************************
function AddLinkWindow(R6MenuMPCreateGameTab _pLinkWindow) {}
//===============================================================
// AddWindowInCreateGameArray: add Window object in creategame array window.
//===============================================================
function AddWindowInCreateGameArray(stServerGameOpt _NewList) {}
//===============================================================
// SetCurrentGameMode: set the new game mode
//===============================================================
function SetCurrentGameMode(EGameModeInfo _eGameMode, optional bool _bAdviceLinkWindow) {}
function R6WindowButtonAndEditBox CreateButAndEditBox(string _szCheckBoxTip, string _szButTip, string _szButName, float _H, float _W, float _Y, float _X) {}
// ^ NEW IN 1.60
/////////////////////////////////////////////////////////////////
// manage the R6WindowButtonAndEditBox notify message
/////////////////////////////////////////////////////////////////
function ManageR6ButtonAndEditBoxNotify(UWindowDialogControl C) {}
//===============================================================
// CreateListOfButtons: create the stServerGameOpt for this list of buttons
//===============================================================
function CreateListOfButtons(eCreateGameWindow_ID _eCGWindowID, EGameModeInfo _eGameMode, float _fH, float _fW, float _fY, float _fX) {}
//===============================================================
// GetList: get list base on his gamemode and ID
//===============================================================
function UWindowWindow GetList(eCreateGameWindow_ID _eCGWindowID, EGameModeInfo _eGameMode) {}
// ^ NEW IN 1.60
function RefreshCGButtons() {}
/////////////////////////////////////////////////////////////////
// manage the R6WindowButtonBox notify message
/////////////////////////////////////////////////////////////////
function ManageR6ButtonBoxNotify(UWindowDialogControl C) {}
function SetButtonAndEditBox(bool _bSelected, string _szEditBoxValue, eCreateGameWindow_ID _eCGW_ID) {}
//===============================================================
// GetCurrentGameMode: Get the current game mode
//===============================================================
function EGameModeInfo GetCurrentGameMode() {}
// ^ NEW IN 1.60

defaultproperties
{
}
