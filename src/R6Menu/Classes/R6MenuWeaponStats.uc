//=============================================================================
//  R6MenuWeaponStats.uc : (add small description)
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/07/02 * Created by Alexandre Dionne
//=============================================================================
class R6MenuWeaponStats extends UWindowWindow;

// --- Variables ---
// var ? bshowlog; // REMOVED IN 1.60
// var ? m_bDrawBg; // REMOVED IN 1.60
var float m_fRangePercent;
var float m_fDamagePercent;
var float m_fAccuracyPercent;
var float m_fRecoveryPercent;
var float m_fRecoilPercent;
//Maximum Width for line charts
var float m_fMaxChartWidth;
//Stats
var float m_fInitRangePercent;
var float m_fInitDamagePercent;
var float m_fInitAccuracyPercent;
var float m_fInitRecoilPercent;
var float m_fInitRecoveryPercent;
//Titles Height
var float m_fTitleHeight;
//Titles
var R6MenuOperativeSkillsLabel m_TRange;
var R6MenuOperativeSkillsLabel m_TDamage;
var R6MenuOperativeSkillsLabel m_TAccuracy;
var R6MenuOperativeSkillsLabel m_TRecoil;
var R6MenuOperativeSkillsLabel m_TRecovery;
var bool m_bDrawBG;
// ^ NEW IN 1.60
var bool m_bDrawBorders;
//Vertical Padding Between Lines
var float m_fYPaddingBetweenElements;
//Display settings
//Horizontal padding where we start drawing from left
var float m_fNLeftPadding;
var R6MenuOperativeSkillsBitmap m_LCRecovery;
var R6MenuOperativeSkillsBitmap m_LCRecoil;
var R6MenuOperativeSkillsBitmap m_LCAccuracy;
var R6MenuOperativeSkillsBitmap m_LCDamage;
//LineCharts
var R6MenuOperativeSkillsBitmap m_LCRange;
//Vertical Padding from the top of the window
var float m_fTopYPadding;
var bool bShowLog;
// ^ NEW IN 1.60
//Horizontal Padding Between the numeric values and the charts
var float m_fBetweenLabelPadding;
var float m_fNumericLabelWidth;

// --- Functions ---
function Paint(Canvas C, float X, float Y) {}
function Created() {}
function R6MenuOperativeSkillsLabel CreateTitle(float _fX, float _fY, float _fW, float _fH, string _szTitle) {}
// ^ NEW IN 1.60
function ResizeCharts() {}

defaultproperties
{
}
