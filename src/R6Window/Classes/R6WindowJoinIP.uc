//=============================================================================
//  R6WindowJoinIP.uc : This class handles the logic and pop up windows
//                      associated with the user joining a server by using
//                      the Join IP button
//
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/10/02 * Created by John Bennett
//=============================================================================
class R6WindowJoinIP extends UWindowWindow;

// --- Constants ---
const K_MAX_TIME_BEACON =  5.0;

// --- Enums ---
enum eJoinIPState
{
    EJOINIP_ENTER_IP,               // User needs to enter an IP
    EJOINIP_WAITING_FOR_BEACON,     // Waiting for response from the server
    EJOINIP_BEACON_FAIL,            // no response from server
	EJOINIP_WAITING_FOR_UBICOMLOGIN // Waiting to be logged in on Ubi.Com
};

// --- Variables ---
// Error pop up window
var R6WindowPopUpBox m_pError;
// Ask user to wait while we get authorization ID (pop up window)
var R6WindowPopUpBox m_pPleaseWait;
// The enter IP window
var R6WindowPopUpBox m_pEnterIP;
// Manages servers from game service
var R6GSServers m_GameService;
// Enumeration used in state machine for JOIN IO procedure
var eJoinIPState eState;
// ASE DEVELOPMENT - Eric Begin - May 11th, 2003
//
// This variable is set locally to prevent hidding and showing windows for nothing.
var bool m_bStartByCmdLine;
// Window to which the send message function will communicate
var UWindowWindow m_pSendMessageDest;
// IP address entered by user
var string m_szIP;
// Time at which beacon was sent to query server
var float m_fBeaconTime;
// ubi.com room valid
var bool m_bRoomValid;

// --- Functions ---
function Manager(UWindowWindow _pCurrentWidget) {}
//==============================================================================
// PopUpBoxDone -  receive the result of the popup box
//==============================================================================
function PopUpBoxDone(MessageBoxResult Result, EPopUpID _ePopUpID) {}
function PopUpBoxCreate() {}
//=======================================================================
// StartJoinIPProcedure - Called from the menus when the user should
// enter an IP of the server he wishes to join
//=======================================================================
function StartJoinIPProcedure(UWindowWindow _pCurrentWidget, string _szLastIP) {}
// ASE DEVELOPMENT - Eric Begin - May 11th, 2003
//
// Add a new function to deal with the fact that when the player connect to a server via the
// command line, chances are that he won't be connect on ubi.com.
function StartCmdLineJoinIPProcedure(string _szLastIP, UWindowWindow _pCurrentWidget) {}

defaultproperties
{
}
