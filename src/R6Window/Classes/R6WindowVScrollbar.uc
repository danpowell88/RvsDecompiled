//=============================================================================
//  R6WindowVScrollBar.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//=============================================================================
class R6WindowVScrollbar extends UWindowVScrollbar;

// --- Variables ---
var class<UWindowSBDownButton> m_DownButtonClass;
var class<UWindowSBUpButton> m_UpButtonClass;

// --- Functions ---
function SetRange(optional float NewScrollAmount, float NewMaxVisible, float NewMinPos, float NewMaxPos) {}
function CheckRange() {}

defaultproperties
{
}
