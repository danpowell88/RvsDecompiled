//=============================================================================
//  R6MenuNonUbiWidget.uc : 
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//	Main Menu
//
//  Revision history:
//    2003/07/03 * Created by Yannick Joly
//=============================================================================
class R6MenuNonUbiWidget extends R6MenuWidget;

// --- Variables ---
// var ? m_bPreJoinInProgress; // REMOVED IN 1.60
// var ? m_pCDKeyCheckWindow; // REMOVED IN 1.60
// Windows and login for logic to query a server for information
var R6WindowQueryServerInfo m_pQueryServerInfo;
var R6WindowUbiLogIn m_pLoginWindow;
var R6GSServers m_GameService;
// Windows and login for Join IP steps
var R6WindowJoinIP m_pJoinIPWindow;
// procedure to login to ubi.com in progress
var bool m_bLoginInProgress;
var bool m_bQueryServerInfoInProgress;
var bool m_bNonUbiMatchMakingClient;
var bool m_bJoinIPInProgress;
var string m_szGamePwd;

// --- Functions ---
// function ? JoinServer(...); // REMOVED IN 1.60
function SendMessage(eR6MenuWidgetMessage eMessage) {}
function QueryReceivedStartPreJoin() {}
function Paint(Canvas C, float Y, float X) {}
//==============================================================================
// PopUpBoxDone -  receive the result of the popup box
//==============================================================================
function PopUpBoxDone(MessageBoxResult Result, EPopUpID _ePopUpID) {}
function PromptConnectionError() {}
function Tick(float Delta) {}
function ShowWindow() {}
function Created() {}

defaultproperties
{
}
