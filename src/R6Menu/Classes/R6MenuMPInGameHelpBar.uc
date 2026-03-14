//=============================================================================
//  R6MenuMPInGameHelpBar.uc : The help text bar for in game menu
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/04/28 * Created by Yannick Joly
//=============================================================================
class R6MenuMPInGameHelpBar extends R6MenuHelpTextBar;

// --- Variables ---
var bool m_bUseExternSetTip;
var string m_szExternTip;

// --- Functions ---
function BeforePaint(Canvas C, float X, float Y) {}
function SetToolTip(string _szToolTip) {}
function Paint(Canvas C, float X, float Y) {}
function string GetToolTip() {}
// ^ NEW IN 1.60

defaultproperties
{
}
