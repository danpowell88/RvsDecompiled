//=============================================================================
//  R6WindowListAreaItem.uc : List-box row item that embeds an R6WindowArea panel widget.
//  Extends UWindowListBoxItem and holds a reference to the hosted area sub-window.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//=============================================================================
class R6WindowListAreaItem extends UWindowListBoxItem;

// --- Variables ---
var R6WindowArea m_Area;

// --- Functions ---
function SetFront() {}
function SetBack() {}

defaultproperties
{
}
