//=============================================================================
//  R6WindowListRadioButton.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//=============================================================================
class R6WindowListRadioButton extends R6WindowTextListRadio;

// --- Variables ---
var float m_fItemWidth;
var float m_fItemVPadding;
// item can be unselected
var bool m_bCanBeUnselected;

// --- Functions ---
function SetDefaultButton(UWindowList Item) {}
function SetSelectedItem(UWindowListBoxItem NewSelected) {}
function UWindowListBoxItem GetItemAt(float fMouseX, float fMouseY) {}
// ^ NEW IN 1.60
function UWindowListBoxItem GetElement(int ButtonID) {}
// ^ NEW IN 1.60
function DrawItem(float H, float Y, float X, UWindowList Item, Canvas C, float W) {}
function Paint(Canvas C, float MouseX, float MouseY) {}
function Created() {}
//When the window is resized.
function ChangeItemsSize(float iNewSize) {}

defaultproperties
{
}
