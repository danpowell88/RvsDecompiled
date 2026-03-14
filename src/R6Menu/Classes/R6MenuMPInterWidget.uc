//=============================================================================
//  R6MenuMPInterWidget.uc : Intermission widget (when you press start during MP game or 
//                           during the between round time)
//  the size of the window is 640 * 480
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/04/25 * Created  Yannick Joly
//=============================================================================
class R6MenuMPInterWidget extends R6MenuWidget;

// --- Variables ---
// the nav bar
var R6MenuMPInGameNavBar m_pInGameNavBar;
var R6WindowPopUpBox m_pPopUpGearRoom;
// the alpha team bar with stats
var R6MenuMPTeamBar m_pR6AlphaTeam;
// the Y team bar start pos
var float m_fYStartTeamBarPos;
// Pop up the kit restriction menu
var R6WindowPopUpBox m_pPopUpKitRest;
// Pop up server option menu
var R6WindowPopUpBox m_pPopUpServerOption;
// the bravo team bar with stats
var R6MenuMPTeamBar m_pR6BravoTeam;
var R6WindowPopUpBox m_pPopUpBoxCurrent;
// the intermission header menu
var R6MenuMPInterHeader m_pMPInterHeader;
// the mission objectives in coop
var R6MenuMPTeamBar m_pR6MissionObj;
//test
var int m_Counter;
var bool m_bNavBarActive;
// force refresh the first time this window is displaying
var bool m_bForceRefreshOfGear;
// refesh rest kit when you click on the button
var bool m_bRefreshRestKit;
var string m_szCurGameType;
// display the Inter Bar only if you are in between round time
var bool m_bDisplayNavBar;
var EPopUpID m_InGameOptionsChange;

// --- Functions ---
//===================================================================================
// PopUpKitRestMenu(): This function pop-up the server option menu with accept and cancel button
//===================================================================================
function PopUpKitRestMenu() {}
function SetNavBarInActive(bool _bDisable, optional bool _bError) {}
//====================================================================================================
//====================================================================================================
// THOSES FUNCTIONS ARE ONLY FOR COOP MODE
//==============================================================================
// IsMissionInProgress -  Is mission is on progress
//==============================================================================
function bool IsMissionInProgress() {}
// ^ NEW IN 1.60
function byte GetLastMissionSuccess() {}
// ^ NEW IN 1.60
function bool IsMissionSuccess() {}
// ^ NEW IN 1.60
//function SetInterWidgetMenu( INT _iGameType, bool _bActiveMenuBar)
function SetInterWidgetMenu(string _szCurrentGameType, bool _bActiveMenuBar) {}
function SetClientServerSettings(bool _bChange) {}
//==============================================================================
// RefreshServerInfo -  refresh the server info
//==============================================================================
function RefreshServerInfo() {}
//==============================================================================
// RefreshGearMenu -  refresh the gear menu
//==============================================================================
function RefreshGearMenu(optional bool _bForceUpdate) {}
//==============================================================================
// PopUpBoxDone -  receive the result of the popup box
//==============================================================================
function PopUpBoxDone(EPopUpID _ePopUpID, MessageBoxResult Result) {}
function SetWindowSize(UWindowWindow _W, float _fH, float _fW, float _fY, float _fX) {}
//==============================================================================
// HideWindow: When you hide this window, hide the current pop-up too
//==============================================================================
function HideWindow() {}
//==============================================================================
// ForceClosePopUp -  Force to close all the popup -- temporary...
//==============================================================================
function ForceClosePopUp() {}
//===================================================================================
// PopUpServerOptMenu(): This function pop-up the server option menu with accept and cancel button
//===================================================================================
function PopUpServerOptMenu() {}
//===================================================================================
// PopUpGearMenu(): This function pop-up the gear menu with accept and cancel button
//===================================================================================
function PopUpGearMenu() {}
function Tick(float Delta) {}
//===================================================================================
// Create the window and all the area for displaying game information
//===================================================================================
function Created() {}

defaultproperties
{
}
