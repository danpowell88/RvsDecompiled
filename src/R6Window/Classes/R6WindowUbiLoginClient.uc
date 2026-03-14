//=============================================================================
//  R6WindowPopUpBox.uc : This provides the simple frame for all the pop-up window
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/04/04 * Created by Yannick Joly
//=============================================================================
class R6WindowUbiLoginClient extends UWindowDialogClientWindow;

// --- Constants ---
const K_RIGHT_HOR_OFF =  10;
const K_LEFT_HOR_OFF =  5;
const K_BOTTON_WIDTH =  95;
const K_VERTICAL_SPACER =  2;
const K_TEXT_WIDTH =  130;
const K_TEXT_HEIGHT =  15;
const K_EDIT_BOX_WIDTH =  140;
const K_EDIT_BOX_HEIGHT =  15;

// --- Variables ---
// auto login button box
var R6WindowButtonBox m_pAutoLogIn;
// save password button box
var R6WindowButtonBox m_pSavePassword;
// create account button (takes user to ubi.com website)
var R6WindowButton m_pCrAccountBut;
// username edit box
var R6WindowEditControl m_pUserName;
// password edit box
var R6WindowEditControl m_pPassword;
// create account text
var R6WindowTextLabelExt m_pCrAccountText;

// --- Functions ---
function SetupClientWindow(float fWindowWidth) {}
//-------------------------------------------------------------------------
// ManageR6ButtonBoxNotify - Notify function for classes of
// type 'R6WindowButtonBox'
//-------------------------------------------------------------------------
function Notify(UWindowDialogControl C, byte E) {}

defaultproperties
{
}
