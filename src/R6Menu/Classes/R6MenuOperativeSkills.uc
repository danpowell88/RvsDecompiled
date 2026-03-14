//=============================================================================
//  R6MenuOperativeSkills.uc : This Window Will display the skills of an operative
//                              and is created by R6MenuOperativeDetailControl
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/19 * Created by Alexandre Dionne
//=============================================================================
class R6MenuOperativeSkills extends UWindowWindow;

// --- Variables ---
// var ? bshowlog; // REMOVED IN 1.60
//Maximum Width for line charts
var float m_fMaxChartWidth;
var float m_fObservation;
var float m_fLeadership;
var float m_fSelfControl;
var float m_fStealth;
var float m_fSniper;
var float m_fElectronics;
var float m_fDemolitions;
//Skills
var float m_fAssault;
//Titles
var R6MenuOperativeSkillsLabel m_TAssault;
var R6MenuOperativeSkillsLabel m_TDemolitions;
var R6MenuOperativeSkillsLabel m_TElectronics;
var R6MenuOperativeSkillsLabel m_TSniper;
var R6MenuOperativeSkillsLabel m_TStealth;
var R6MenuOperativeSkillsLabel m_TSelfControl;
var R6MenuOperativeSkillsLabel m_TLeadership;
var R6MenuOperativeSkillsLabel m_TObservation;
//Titles Height
var float m_fTitleHeight;
//Vertical Padding Between Lines
var float m_fYPaddingBetweenElements;
//Display settings
//Horizontal padding where we start drawing from left
var float m_fNLeftPadding;
var R6MenuOperativeSkillsBitmap m_LCObservation;
var R6MenuOperativeSkillsBitmap m_LCLeadership;
var R6MenuOperativeSkillsBitmap m_LCSelfControl;
var R6MenuOperativeSkillsBitmap m_LCStealth;
var R6MenuOperativeSkillsBitmap m_LCSniper;
var R6MenuOperativeSkillsBitmap m_LCElectronics;
var R6MenuOperativeSkillsBitmap m_LCDemolitions;
//LineCharts
var R6MenuOperativeSkillsBitmap m_LCAssault;
//Vertical Padding from the top of the window
var float m_fTopYPadding;
//Horizontal Padding Between the numeric values and the charts
var float m_fBetweenLabelPadding;
var float m_fNumericLabelWidth;
var bool bShowLog;
// ^ NEW IN 1.60

// --- Functions ---
function Created() {}
function ResizeCharts(R6Operative _CurrentOperative) {}
function Paint(Canvas C, float X, float Y) {}
function R6MenuOperativeSkillsLabel CreateTitle(float _fX, float _fY, float _fW, float _fH, string _szTitle) {}
// ^ NEW IN 1.60

defaultproperties
{
}
