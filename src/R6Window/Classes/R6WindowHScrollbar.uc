//=============================================================================
//  R6WindowHScrollBar.uc : Horizontal scrollbar with possibility to add a text (for tooltip option)
//							This class is different than vertical scrollbar
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/06/27 * Created by Yannick Joly
//=============================================================================
class R6WindowHScrollbar extends UWindowDialogControl;

// --- Variables ---
var UWindowHScrollbar m_pScrollBar;
var R6WindowTextLabelExt m_pSBText;

// --- Functions ---
//================================================================
//	Create an associate text to the scroll bar
//================================================================
function CreateSBTextLabel(string _szText, string _szToolTip) {}
//================================================================
//	SetScrollBarRange: Set the scroll bar range
//================================================================
function SetScrollBarRange(float _fMin, float _fMax, float _fStep) {}
//================================================================
//	Create the horizontal scroll bar
//================================================================
function CreateSB(float _fWidth, int _iScrollBarID, float _fY, UWindowDialogClientWindow _DialogClientW, float _fHeight, float _fX) {}
//================================================================
//	SetScrollBarValue: Set the scroll bar value
//================================================================
function SetScrollBarValue(float _fNewValue) {}
//================================================================
//	GetScrollBarValue: Get the scroll bar value
//================================================================
function float GetScrollBarValue() {}
// ^ NEW IN 1.60
function MouseLeave() {}
function MouseEnter() {}

defaultproperties
{
}
