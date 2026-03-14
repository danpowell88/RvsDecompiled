//=============================================================================
//  R6MenuHelpWindow.uc : This is the help window where the tooltip is suppose to be display
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/05/11 * Created by Yannick Joly
//=============================================================================
class R6MenuHelpWindow extends R6WindowSimpleFramedWindowExt;

// --- Variables ---
// force to clear wrapped text area for a same tip
var bool m_bForceRefreshOnSameTip;

// --- Functions ---
//==========================================================================
// AddTipText: Call this after a new tooltip. Force to put the next on the next line
//==========================================================================
function AddTipText(string _szNewText) {}
/////////////////////////////////////////////////////////////////
// display the help text in the m_pHelpTextWindow (derivate for uwindowwindow
/////////////////////////////////////////////////////////////////
function ToolTip(string strTip) {}
function Created() {}

defaultproperties
{
}
