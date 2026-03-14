//=============================================================================
//  R6MenuWeaponDetailRadioArea.uc : Top buttons that allow us to change from weapon
//                                  stats to the text description
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/07/02 * Created by Alexandre Dionne
//=============================================================================
class R6MenuWeaponDetailRadioArea extends UWindowDialogClientWindow;

// --- Variables ---
var R6WindowStayDownButton m_WeaponHistoryButton;
var R6WindowStayDownButton m_WeaponStatsButton;
var R6WindowStayDownButton m_CurrentSelectedButton;
var float m_fButtonTabHeight;
var float m_fButtonTabWidth;
// ^ NEW IN 1.60
var Region m_RHistoryUp;
// ^ NEW IN 1.60
var float m_fBetweenButtonOffset;
var float m_fFirstButtonOffset;
var Region m_RStatsDown;
// ^ NEW IN 1.60
var Region m_RStatsOver;
// ^ NEW IN 1.60
var Region m_RStatsUp;
// ^ NEW IN 1.60
var Region m_RHistoryDown;
// ^ NEW IN 1.60
var Region m_RHistoryOver;
// ^ NEW IN 1.60

// --- Functions ---
function Notify(UWindowDialogControl C, byte E) {}
function Created() {}
function AfterPaint(Canvas C, float X, float Y) {}
function ShowWindow() {}

defaultproperties
{
}
