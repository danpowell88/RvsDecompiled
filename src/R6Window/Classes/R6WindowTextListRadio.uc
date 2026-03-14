//=============================================================================
//  R6WindowTextListRadio.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//=============================================================================
class R6WindowTextListRadio extends R6WindowListRadio;

// --- Variables ---
//var color   TextColor;           color for text            N.B. var already define in class UWindowDialogControl
// color for selected text
var Color m_SelTextColor;

// --- Functions ---
function Paint(Canvas C, float fMouseX, float fMouseY) {}
function DrawItem(Canvas C, float W, float H, UWindowList Item, float X, float Y) {}

defaultproperties
{
}
