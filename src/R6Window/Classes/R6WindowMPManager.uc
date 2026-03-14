//=============================================================================
//  R6WindowMPManager.uc : Manage all the windows to be display when you join a game/create a server/valid CD-Key
//
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2003/05/12 * Created by Yannick Joly
//=============================================================================
class R6WindowMPManager extends UWindowWindow;

// --- Constants ---
const k_CharsForSwitchToWrapped =  30;

// --- Variables ---
// Error pop-up
var R6WindowPopUpBox m_pError;
// Pop up to select a password
var R6WindowPopUpBox m_pPassword;
var R6WindowEditBox m_pPasswordEditBox;
// Wrapped Error Pop-Up (for long messages)
var R6WindowPopUpBox m_pLongError;
// Server info
var PreJoinResponseInfo m_preJoinRespInfo;
var bool bShowLog;
// ^ NEW IN 1.60

// --- Functions ---
function PopUpBoxCreate() {}
function DisplayErrorMsg(string _szErrorMsg, EPopUpID _ePopUpID) {}
//==============================================================================
// HandlePunkBusterSvrSituation -  handle the punk buster server situation
//==============================================================================
function HandlePunkBusterSvrSituation() {}
function HandleLockedServerPopUp() {}

defaultproperties
{
}
