//=============================================================================
//  R6WindowServerInfoBox.uc : Class used to manage the "list box" of 
//  server information.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/05/03 * Created by John Bennett
//=============================================================================
class R6WindowServerInfoOptionsBox extends R6WindowListBox;

// --- Variables ---
var Font m_Font;
//var color   TextColor;          // color for text            N.B. var already define in class UWindowDialogControl
// color for selected text
var Color m_SelTextColor;
// draw the border and the background
var bool m_bDrawBorderAndBkg;

// --- Functions ---
function Paint(Canvas C, float fMouseX, float fMouseY) {}
function BeforePaint(Canvas C, float fMouseX, float fMouseY) {}
function DrawItem(Canvas C, float X, UWindowList Item, float Y, float W, float H) {}
function Created() {}

defaultproperties
{
}
