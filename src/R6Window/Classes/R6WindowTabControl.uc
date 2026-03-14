//=============================================================================
//  R6WindowTabControl.uc : Manage, display tab menu
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/04/02 * Created by Yannick Joly
//=============================================================================
class R6WindowTabControl extends UWindowTabControl;

// --- Functions ---
// why we overwrite tooltip string overhere, to transmit the string to the parent window where the management of
// this string is done
function ToolTip(string strTip) {}
function GotoTab(UWindowTabControlItem NewSelected, optional bool bByUser) {}
function int GetSelectedTabID() {}
// ^ NEW IN 1.60
function Created() {}

defaultproperties
{
}
