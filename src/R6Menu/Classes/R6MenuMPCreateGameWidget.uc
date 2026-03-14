//=============================================================================
//  R6MenuMultiPlayerWidget.uc : The first multi player menu window
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/11/22 * Created by Alexandre Dionne
//    2002/04/7  * Modify by Yannick Joly
//=============================================================================
class R6MenuMPCreateGameWidget extends R6MenuWidget;

// --- Constants ---
const K_XSTARTPOS =  10;
const K_WINDOWWIDTH =  620;
const K_XTABOFFSET =  5;
const K_TABWINDOW_WIDTH =  550;
const K_YPOS_TABWINDOW_CURVED =  87;
const K_YPOS_TABWINDOW =  92;
const K_YPOS_HELPTEXT_WINDOW =  430;
const K_HSIZE_TABWINDOWCURVED =  30;
const K_HSIZE_TABWINDOW =  25;
const K_HSIZE_UNDER_TABWINDOW =  300;

// --- Enums ---
enum eCreateGameTabID
{
    TAB_Options,
	TAB_AdvancedOptions,
    TAB_Kit
};
enum eRestrictionKit
{
    KIT_SubMachineGuns,
    KIT_Shotguns
};

// --- Variables ---
// var ? m_bPreJoinInProgress; // REMOVED IN 1.60
// var ? m_pCDKeyCheckWindow; // REMOVED IN 1.60
var R6MenuMPCreateGameTabOptions m_pCreateTabOptions;
var R6MenuMPCreateGameTabAdvOptions m_pCreateTabAdvOptions;
var R6MenuMPCreateGameTabKitRest m_pCreateTabKit;
var R6WindowSimpleFramedWindowExt m_pWindowBorder;
var R6WindowButtonMultiMenu m_ButtonCancel;
var R6WindowButton m_ButtonMainMenu;
var R6WindowButtonMultiMenu m_ButtonLaunch;
var R6WindowButton m_ButtonOptions;
var R6WindowUbiLogIn m_pLoginWindow;
var R6WindowTextLabel m_LMenuTitle;
var R6MenuMPCreateGameTab m_pCreateTabWindow;
// procedure to login to ubi.com in progress
var bool m_bLoginInProgress;
// First tab window (on a simple curved frame)
var R6WindowTextLabelCurved m_FirstTabWindow;
// creation of the tab manager for the first tab window
var R6MenuMPManageTab m_pFirstTabManager;
var R6MenuHelpWindow m_pHelpTextWindow;

// --- Functions ---
// function ? LaunchServer(...); // REMOVED IN 1.60
function InitButton() {}
/////////////////////////////////////////////////////////////////
// display the background
/////////////////////////////////////////////////////////////////
function Paint(Canvas C, float X, float Y) {}
function SendMessage(eR6MenuWidgetMessage eMessage) {}
/////////////////////////////////////////////////////////////////
// display the help text in the m_pHelpTextWindow (derivate for uwindowwindow
/////////////////////////////////////////////////////////////////
function ToolTip(string strTip) {}
/////////////////////////////////////////////////////////////////
// manage the tab selection (the call of the fct come from R6MenuMPManageTab
/////////////////////////////////////////////////////////////////
function ManageTabSelection(int _MPTabChoiceID) {}
function Notify(UWindowDialogControl C, byte E) {}
function InitTabWindow() {}
function Created() {}
function ShowWindow() {}
function RefreshCreateGameMenu() {}
function MenuServerLoadProfile() {}
//*********************************
//      INIT CREATE FUNCTION
//*********************************
function InitText() {}

defaultproperties
{
}
