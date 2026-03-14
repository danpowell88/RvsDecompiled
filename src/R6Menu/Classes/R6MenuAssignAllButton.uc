//=============================================================================
//  R6MenuAssignAllButton.uc : This button should assign it's associated item
//                              to all team members
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/15 * Created by Alexandre Dionne
//=============================================================================
class R6MenuAssignAllButton extends R6WindowButton;

// --- Variables ---
var Color m_DisableColor;
var Color m_EnableColor;
// draw the left broder
var bool m_bDrawLeftBorder;
var bool m_bDrawRightBorder;
var bool m_bDrawTopBorder;
var bool m_bDrawDownBorder;

// --- Functions ---
//===========================================================
// SetButtonStatus: set the status of all the buttons, colors maybe change here too
//===========================================================
function SetButtonStatus(bool _bDisable) {}
//=================================================================
// SetBorderColor: set the border color
//=================================================================
function SetBorderColor(Color _NewColor) {}
function DrawSimpleBorder(Canvas C) {}
function SetCompleteAssignAllButton() {}
function LMouseDown(float Y, float X) {}
function MMouseDown(float Y, float X) {}
function RMouseDown(float Y, float X) {}
function Created() {}

defaultproperties
{
}
