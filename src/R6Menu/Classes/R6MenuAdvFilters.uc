//=============================================================================
//  R6MenuAdvFilters.uc : 
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2003/07/21 * Created by Yannick Joly
//=============================================================================
class R6MenuAdvFilters extends UWindowDialogClientWindow;

// --- Variables ---
var R6WindowListRestKit m_pListGen;

// --- Functions ---
function Notify(UWindowDialogControl C, byte E) {}
//=======================================================================================
// MouseWheelUp: advice scroll bar for mouse wheel up
//=======================================================================================
function MouseWheelUp(float Y, float X) {}
//=======================================================================================
// MouseWheelDown: advice scroll bar for mouse wheel down
//=======================================================================================
function MouseWheelDown(float Y, float X) {}
function AddButtonInList(int _iButtonID, string _szTip, string _szLoc, bool _bSelected) {}
function Created() {}

defaultproperties
{
}
