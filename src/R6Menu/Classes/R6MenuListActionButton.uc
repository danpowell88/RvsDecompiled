//=============================================================================
//  R6MenuListActionButton.uc : Popup list button for selecting a waypoint action (e.g. snipe, breach door) in the mission planning bar.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//=============================================================================
class R6MenuListActionButton extends R6MenuPopupListButton;

// --- Variables ---
var bool m_bAutoSelect;

// --- Functions ---
function DisplaySnipeButton(bool bDoIDisplay) {}
function DisplayBreachDoor(bool bDoIDisplay) {}
function ShowWindow() {}
function SetSelectedItem(UWindowListBoxItem NewSelected) {}
function Created() {}

defaultproperties
{
}
