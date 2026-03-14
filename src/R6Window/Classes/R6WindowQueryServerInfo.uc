//=============================================================================
//  R6WindowQueryServerInfo.uc : Used to get some basic information
//  from a server before allowing the user to join the server.
//
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/10/15 * Created by John Bennett
//=============================================================================
class R6WindowQueryServerInfo extends R6WindowMPManager;

// --- Constants ---
const K_MAX_TIME_BEACON =  5.0;

// --- Variables ---
// Manages servers from game service
var R6GSServers m_GameService;
// Ask user to wait
var R6WindowPopUpBox m_pPleaseWait;
// Waiting for the beacon response from the server
var bool m_bWaitingForBeacon;
// Window to which the send message function will communicate
var UWindowWindow m_pSendMessageDest;
// Time at which beacon was sent to query server
var float m_fBeaconTime;
// ubi.com room valid
var bool m_bRoomValid;

// --- Functions ---
function Manager(UWindowWindow _pCurrentWidget) {}
function PopUpBoxCreate() {}
function bool IsSameGameVersion(string _szPreJoinInfoGameVer, string _szPreJoinModName) {}
// ^ NEW IN 1.60
//=======================================================================
// StartQueryServerInfoProcedure - Called from  the menus when the
// query procedure is started
//=======================================================================
function StartQueryServerInfoProcedure(string _szServerIP, int _iBeaconPort, UWindowWindow _pCurrentWidget) {}
//==============================================================================
// PopUpBoxDone -  receive the result of the popup box
//==============================================================================
function PopUpBoxDone(EPopUpID _ePopUpID, MessageBoxResult Result) {}

defaultproperties
{
}
