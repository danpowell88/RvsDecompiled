//=============================================================================
//  R6WindowListButtonItem.uc : List-box row item that embeds an R6WindowButton widget.
//  Allows a list control to present a clickable button inside each row entry.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//=============================================================================
class R6WindowListButtonItem extends UWindowListBoxItem;

// --- Variables ---
var R6WindowButton m_Button;

// --- Functions ---
function SetFront() {}
function SetBack() {}

defaultproperties
{
}
