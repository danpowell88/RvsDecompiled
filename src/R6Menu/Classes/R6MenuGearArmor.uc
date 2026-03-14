//=============================================================================
//  R6MenuGearArmor.uc : This will display the current 2D model
//                        of the Armor for the current 
//                        operative
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/14 * Created by Alexandre Dionne
//=============================================================================
class R6MenuGearArmor extends UWindowDialogControl;

// --- Variables ---
var R6WindowButtonGear m_2DArmor;
var R6MenuAssignAllButton m_AssignAll;

// --- Functions ---
//=================================================================
// SetBorderColor: set the border color
//=================================================================
function SetBorderColor(Color _NewColor) {}
//===========================================================
// SetButtonStatus: set the status of all the buttons, colors maybe change here too
//===========================================================
function SetButtonsStatus(bool _bDisable) {}
function Register(UWindowDialogClientWindow W) {}
function Paint(Canvas C, float Y, float X) {}
//=================================================================
// ForceMouseOver: Force mouse over on all the window on this page
//=================================================================
function ForceMouseOver(bool _bForceMouseOver) {}
function SetArmorTexture(Region R, Texture t) {}
function Created() {}

defaultproperties
{
}
