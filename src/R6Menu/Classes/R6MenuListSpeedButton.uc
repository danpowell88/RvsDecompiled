//=============================================================================
//  R6MenuListSpeedButton.uc : Popup list button for selecting the operative movement speed in the mission planning bar.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//=============================================================================
class R6MenuListSpeedButton extends R6MenuPopupListButton;

// --- Variables ---
var bool m_bAutoSelect;

// --- Functions ---
function SetSelectedItem(UWindowListBoxItem NewSelected) {}
function ShowWindow() {}
function Created() {}

defaultproperties
{
}
