//=============================================================================
//  R6WindowRightClickMenu.uc : This class is used to create a "right-click"
//  menu at a given position.  A drop down menu will appear and the user
//  can select from the list of choices
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/05/24 * Created by John Bennett
//=============================================================================
class R6WindowRightClickMenu extends R6WindowComboControl;

// --- Functions ---
//------------------------------------------------------------
// Display the menu at the position indicated by the function
// arguments
//------------------------------------------------------------
function DisplayMenuHere(float fXPos, float fYPos) {}
//------------------------------------------------------------
// Once the user has selected an item from the list, hide this
// menu.
//------------------------------------------------------------
function CloseUp() {}
//------------------------------------------------------------
// Called when the window is first created.
//------------------------------------------------------------
function Created() {}

defaultproperties
{
}
