//=============================================================================
//  R6WindowStayDownButton.uc : Toggle/latch button that remains pressed until explicitly released.
//  Extends R6WindowButton with selection-state tracking and optional notify-only unselect mode.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//=============================================================================
class R6WindowStayDownButton extends R6WindowButton;

// --- Variables ---
// the state of button selection is change outside, by a notify msg to button creator
var bool m_bUseOnlyNotifyMsg;
var bool m_bCheckSelectState;
var bool m_bCanBeUnselected;

// --- Functions ---
function LMouseDown(float Y, float X) {}
function Paint(Canvas C, float Y, float X) {}

defaultproperties
{
}
