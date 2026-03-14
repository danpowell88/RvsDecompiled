//=============================================================================
//  R6MenuGearGadget.uc : This will display the current 2D model
//                        of one of the 2 gadgets selected for the current 
//                        operative
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/14 * Created by Alexandre Dionne
//=============================================================================
class R6MenuGearGadget extends UWindowDialogControl;

// --- Variables ---
var R6WindowButtonGear m_2DGadget;
var R6MenuAssignAllButton m_AssignAll;
var bool m_bCenterTexture;
var bool m_bAssignAllButton;
var float m_2DGadgetWidth;

// --- Functions ---
function Created() {}
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
function SetGadgetTexture(Texture t, Region R) {}

defaultproperties
{
}
