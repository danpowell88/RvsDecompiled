//=============================================================================
//  R6WindowUbiLogIn.uc : This is used to pop up a window that will ask the user
//                  to input his ubi.com account info.
//
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/01/08 * Created by John Bennett
//=============================================================================
class R6WindowUbiLogIn extends R6WindowMPManager;

// --- Variables ---
// Manages servers from game service
var R6GSServers m_GameService;
// Pop up for ubi account
var R6WindowPopUpBox m_pR6UbiAccount;
var string m_szInitError;
// ^ NEW IN 1.60
// Disconnected from ubi.com
var R6WindowPopUpBox m_pDisconnected;
var UWindowWindow m_pSendMessageDest;

// --- Functions ---
function PopUpBoxCreate() {}
//==============================================================================
// PopUpBoxDone -  receive the result of the popup box
//==============================================================================
function PopUpBoxDone(MessageBoxResult Result, EPopUpID _ePopUpID) {}
function Manager(UWindowWindow _pCurrentWidget) {}
//=======================================================================
// LogInAfterDisconnect - Called from the menus when the connection
// to ubi.com has been lost
//=======================================================================
function LogInAfterDisconnect(UWindowWindow _pCurrentWidget) {}
//=======================================================================
// StartLogInProcedure - Called from the menus when the user should
// enter his ubi.com userID/password
//=======================================================================
function StartLogInProcedure(UWindowWindow _pCurrentWidget) {}
function ProcessGSMsg(string _szMsg) {}
// ^ NEW IN 1.60
function ShowWindow() {}
function HideWindow() {}

defaultproperties
{
}
