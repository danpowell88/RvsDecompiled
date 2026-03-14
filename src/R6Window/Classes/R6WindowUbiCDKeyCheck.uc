//=============================================================================
//  R6WindowUbiLogIn.uc : This is used to pop up a window that will ask the user
//                  to input his ubi.com account info.
//
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/01/08 * Created by John Bennett
//=============================================================================
class R6WindowUbiCDKeyCheck extends R6WindowMPManager;

// --- Enums ---
enum eJoinRoomChoice
{
    EJRC_NO,
//    EJRC_BY_MSCLIENT_ID,
    EJRC_BY_LOBBY_AND_ROOM_ID
};

// --- Variables ---
// var ? bShowLog; // REMOVED IN 1.60
// Ask user to wait while we get authorization ID
var R6WindowPopUpBox m_pPleaseWait;
// Menu to enter a cd key.
var R6WindowPopUpBox m_pR6EnterCDKey;
var string m_szLocMod;
// ^ NEW IN 1.60
var UWindowWindow m_pSendMessageDest;
// Manages servers from game service
var R6GSServers m_GameService;
// Game Password
var string m_szPassword;
// Need to join the ubi.com room
var eJoinRoomChoice m_eJoinRoomChoice;

// --- Functions ---
// function ? Manager(...); // REMOVED IN 1.60
// function ? PopUpBoxCreate(...); // REMOVED IN 1.60
// function ? StartPreJoinProcedure(...); // REMOVED IN 1.60
//==============================================================================
// PopUpBoxDone -  receive the result of the popup box
//==============================================================================
function PopUpBoxDone(MessageBoxResult Result, EPopUpID _ePopUpID) {}
function ProcessGSMsg(string _szMsg) {}
// ^ NEW IN 1.60
function Created() {}
// ^ NEW IN 1.60
function DisplayErrorMsg(EPopUpID _ePopUpID, string _szErrorMsg) {}
// ^ NEW IN 1.60
function SelectCDKeyBox(bool _bClearEditBox) {}
// ^ NEW IN 1.60

defaultproperties
{
}
