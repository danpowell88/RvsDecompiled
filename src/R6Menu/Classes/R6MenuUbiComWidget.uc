//=============================================================================
//  R6MenuUbiComWidget.uc : Game Main Menu when the game is start by Ubi.com
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//	Main Menu
//
//  Revision history:
//    2002/09/18 * Created by Yannick Joly
//=============================================================================
class R6MenuUbiComWidget extends R6MenuWidget;

// --- Variables ---
// var ? m_bChangeMap; // REMOVED IN 1.60
// var ? m_bPreJoinInProgress; // REMOVED IN 1.60
// var ? m_pCDKeyCheckWindow; // REMOVED IN 1.60
var R6WindowButtonMainMenu m_ButtonQuit;
var R6WindowButtonMainMenu m_ButtonReturn;
// Manages servers from game service
var R6GSServers m_GameService;
var R6WindowQueryServerInfo m_pQueryServerInfo;
// ^ NEW IN 1.60
var bool m_bIsAnOfficialMod;
// ^ NEW IN 1.60
var bool m_bIsACustomMod;
// ^ NEW IN 1.60
var bool m_bQueryServerInfoInProgress;
// ^ NEW IN 1.60
var string m_szIPAddress;
var R6MenuUbiComModsWidget m_UbiComModsWidget;
// ^ NEW IN 1.60

// --- Functions ---
// function ? JoinServer(...); // REMOVED IN 1.60
function SendMessage(eR6MenuWidgetMessage eMessage) {}
function ProcessGSMsg(string _szMsg) {}
// ^ NEW IN 1.60
function Paint(Canvas C, float Y, float X) {}
function Created() {}
//==============================================================================
// Notify -  Called when the player presses on a button (quit or return).
//==============================================================================
function Notify(UWindowDialogControl C, byte E) {}
//===============================================================
// Tick: Overload this fct in mod to bypass CheckForGSClientStart or change empty CheckForGSClientStart
//===============================================================
function Tick(float Delta) {}
function bool SwitchToAppropriateMod() {}
// ^ NEW IN 1.60
//==============================================================================
// PromptConnectionError -  A connection error has occured, put up a pop
// up menu.
//==============================================================================
function PromptConnectionError() {}
//==============================================================================
// PopUpBoxDone -  receive the result of the popup box
//==============================================================================
function PopUpBoxDone(EPopUpID _ePopUpID, MessageBoxResult Result) {}
function HideWindow() {}
// ^ NEW IN 1.60
function ShowWindow() {}

defaultproperties
{
}
