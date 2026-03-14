//=============================================================================
//  R6WindowServerInfoBox.uc : Class used to manage the "list box" of 
//  server information.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/05/03 * Created by John Bennett
//=============================================================================
class R6WindowServerInfoPlayerBox extends R6WindowListBox;

// --- Variables ---
var Font m_Font;
// color for text            N.B. var already define in class UWindowDialogControl
var Color TextColor;
// color for selected text
var Color m_SelTextColor;
// draw the border and the background
var bool m_bDrawBorderAndBkg;

// --- Functions ---
function Paint(Canvas C, float fMouseY, float fMouseX) {}
function BeforePaint(Canvas C, float fMouseY, float fMouseX) {}
function DrawItem(Canvas C, float X, float Y, float H, UWindowList Item, float W) {}
function Created() {}

defaultproperties
{
}
