//=============================================================================
//  R6MenuMPManageTab.uc : Manage Tab for multiplayer menu
//                                         
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/04/03 * Created by Yannick Joly
//=============================================================================
class R6MenuMPManageTab extends UWindowDialogClientWindow;

// --- Variables ---
var R6WindowTabControl m_pMainTabControl;

// --- Functions ---
/////////////////////////////////////////////////////////////////
// this method add tab in a list use by UWindowTabControlTabArea
/////////////////////////////////////////////////////////////////
function AddTabInControl(string _Caption, string _TabToolTip, int _ItemID) {}
/////////////////////////////////////////////////////////////////
// this method receive a "msg" sent by ? dialogclientwindow or uwindowwindow
/////////////////////////////////////////////////////////////////
function Notify(byte E, UWindowDialogControl C) {}
function Created() {}

defaultproperties
{
}
