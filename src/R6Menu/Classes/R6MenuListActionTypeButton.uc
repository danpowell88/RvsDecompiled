//=============================================================================
//  R6MenuListActionTypeButton.uc : Popup list button for selecting an action type/category in the planning bar; opens the action menu popup.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/22 * Created by Chaouky Garram
//=============================================================================
class R6MenuListActionTypeButton extends R6MenuPopupListButton;

// --- Variables ---
var R6MenuActionMenu m_WinAction;
var bool m_bAutoSelect;

// --- Functions ---
function DisplayMilestoneButton() {}
function ShowWindow() {}
function SetSelectedItem(UWindowListBoxItem NewSelected) {}
function ShowPopup() {}
function HidePopup() {}
function Created() {}

defaultproperties
{
}
