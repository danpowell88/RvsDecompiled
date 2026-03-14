//=============================================================================
//  R6WindowListControls.uc : Create the controls page in options. Scrollbar page with 3 types of the same items
//							  Title, selected item and line item
//							  see default properties for some settings
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/07/16 * Created by Yannick Joly
//=============================================================================
class R6WindowListControls extends R6WindowTextListBox;

// --- Variables ---
// var ? m_fXOffset; // REMOVED IN 1.60
// for the draw line
var Region m_BorderTextureRegion;
var UWindowListBoxItem m_pPreviousItem;
var float m_fXOffSet;
// ^ NEW IN 1.60
var Texture m_BorderTexture;

// --- Functions ---
function MouseMove(float X, float Y) {}
//=====================================================================
// SetSelectedItem: derivate from R6WindowListBox
//=====================================================================
function SetSelectedItem(UWindowListBoxItem NewSelected) {}
function DrawItem(Canvas C, float H, UWindowList Item, float Y, float W, float X) {}
function Paint(Canvas C, float fMouseX, float fMouseY) {}
function ManageOverEffect(float X, float Y) {}
function MouseLeave() {}

defaultproperties
{
}
