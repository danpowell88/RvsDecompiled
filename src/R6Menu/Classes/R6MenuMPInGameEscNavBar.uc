//=============================================================================
//  R6MenuMPInGameEscNavBar.uc : The nav bar of the esc menu for multiplayer in game
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/08/05 * Created by Yannick Joly
//=============================================================================
class R6MenuMPInGameEscNavBar extends R6MenuInGameEscSinglePlayerNavBar;

// --- Variables ---
var Texture m_TMPContinueButton;
// region of the popup
var Region m_RPopUp;
var Region m_RMPContinueButtonOver;
var Region m_RMPContinueButtonDisabled;
// ^ NEW IN 1.60
var Region m_RMPContinueButtonDown;
// ^ NEW IN 1.60
var Region m_RMPContinueButtonUp;
// ^ NEW IN 1.60

// --- Functions ---
function Notify(byte E, UWindowDialogControl C) {}
function Created() {}

defaultproperties
{
}
