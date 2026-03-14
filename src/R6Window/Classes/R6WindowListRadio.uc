//=============================================================================
//  R6WindowListRadio.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//=============================================================================
class R6WindowListRadio extends UWindowListControl;

// --- Variables ---
var UWindowListBoxItem m_SelectedItem;
var float m_fItemHeight;
// list to send items to on double-click
var R6WindowListRadio m_DoubleClickList;
var string m_szDefaultHelpText;

// --- Functions ---
function SetSelectedItem(UWindowListBoxItem NewSelected) {}
function Paint(Canvas C, float fMouseX, float fMouseY) {}
function UWindowListBoxItem GetItemAt(float fMouseY, float fMouseX) {}
// ^ NEW IN 1.60
function DoubleClickItem(UWindowListBoxItem i) {}
function DoubleClick(float Y, float X) {}
function LMouseDown(float Y, float X) {}
function SetSelected(float Y, float X) {}
function SetHelpText(string t) {}
function MakeSelectedVisible() {}
function ReceiveDoubleClickItem(UWindowListBoxItem i, R6WindowListRadio L) {}
function BeforePaint(float fMouseY, float fMouseX, Canvas C) {}
function Sort() {}

defaultproperties
{
}
