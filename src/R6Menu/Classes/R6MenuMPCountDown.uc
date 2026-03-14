//=============================================================================
//  R6MenuMPCountDown.uc : this menu show the count down before the game start in multi 
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/12/09 * Created by Yannick Joly
//=============================================================================
class R6MenuMPCountDown extends UWindowWindow;

// --- Constants ---
const C_iWAIT_XFRAMES =  10;

// --- Variables ---
// the countdown text window
var R6WindowTextLabel m_pCountDown;
var int m_iFrameRefresh;
// the countdown text window
var R6WindowTextLabel m_pCountDownLabel;
var int m_iLastValue;

// --- Functions ---
function Created() {}
function Paint(Canvas C, float X, float Y) {}

defaultproperties
{
}
