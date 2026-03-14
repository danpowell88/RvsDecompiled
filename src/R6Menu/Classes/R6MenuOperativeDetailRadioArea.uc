//=============================================================================
//  R6MenuOperativeDetailRadioArea.uc : This is the top part of R6WindowOperativeDetailControl
//                                         
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/15 * Created by Alexandre Dionne
//=============================================================================
class R6MenuOperativeDetailRadioArea extends UWindowDialogClientWindow;

// --- Variables ---
var R6WindowStayDownButton m_OperativeSkillsButton;
var R6WindowStayDownButton m_OperativeBioButton;
var R6WindowStayDownButton m_OperativeHistoryButton;
var R6WindowStayDownButton m_OperativeStatsButton;
var R6WindowStayDownButton m_CurrentSelectedButton;
var float m_fButtonTabHeight;
var float m_fButtonTabWidth;
// ^ NEW IN 1.60
var float m_fBetweenButtonOffset;
var float m_fFirstButtonOffset;
var Region m_RStatsDown;
// ^ NEW IN 1.60
var Region m_RStatsOver;
// ^ NEW IN 1.60
var Region m_RStatsUp;
// ^ NEW IN 1.60
var Region m_RBioDown;
// ^ NEW IN 1.60
var Region m_RBioOver;
// ^ NEW IN 1.60
var Region m_RBioUp;
// ^ NEW IN 1.60
var Region m_RSkillsDown;
// ^ NEW IN 1.60
var Region m_RSkillsOver;
// ^ NEW IN 1.60
var Region m_RSkillsUp;
// ^ NEW IN 1.60
var Region m_RHistoryDown;
// ^ NEW IN 1.60
var Region m_RHistoryOver;
// ^ NEW IN 1.60
var Region m_RHistoryUp;
// ^ NEW IN 1.60

// --- Functions ---
function Created() {}
function Notify(UWindowDialogControl C, byte E) {}

defaultproperties
{
}
