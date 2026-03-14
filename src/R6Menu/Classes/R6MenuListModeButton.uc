//=============================================================================
//  R6MenuListModeButton.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//=============================================================================
class R6MenuListModeButton extends R6MenuPopupListButton;

// --- Variables ---
var R6MenuSpeedMenu m_WinSpeed;
var bool m_bAutoSelect;

// --- Functions ---
function SetSelectedItem(UWindowListBoxItem NewSelected) {}
function ShowWindow() {}
function ShowPopup() {}
function HidePopup() {}
function Created() {}

defaultproperties
{
}
