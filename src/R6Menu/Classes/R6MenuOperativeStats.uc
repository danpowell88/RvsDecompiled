//=============================================================================
//  R6MenuOperativeStats.uc : This class will provode us with an 
//                              view of an operative stats
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/21 * Created by Alexandre Dionne
//=============================================================================
class R6MenuOperativeStats extends UWindowWindow;

// --- Variables ---
// var ? bshowlog; // REMOVED IN 1.60
//Display settings
//Horizontal padding where we start drawing from left and right
var float m_fHSidePadding;
//Titles Height
var float m_fTitleHeight;
var float m_fValueLabelWidth;
var R6MenuOperativeSkillsLabel m_TTerroKilled;
var R6MenuOperativeSkillsLabel m_TRoundsFired;
var R6MenuOperativeSkillsLabel m_TRoundsOnTarget;
var float m_fTileLabelWidth;
//Titles
var R6MenuOperativeSkillsLabel m_TNbMissions;
var R6MenuOperativeSkillsLabel m_TShootPercent;
//Values Labels
var R6MenuOperativeSkillsLabel m_NNbMissions;
var R6MenuOperativeSkillsLabel m_NTerroKilled;
var R6MenuOperativeSkillsLabel m_NRoundsFired;
var R6MenuOperativeSkillsLabel m_NRoundsOnTarget;
var R6MenuOperativeSkillsLabel m_NShootPercent;
//Vertical Padding from the top of the window
var float m_fTopYPadding;
//Vertical Padding Between Lines
var float m_fYPaddingBetweenElements;
var R6MenuOperativeSkillsLabel m_TGender;
var R6MenuOperativeSkillsLabel m_NGender;
var bool bShowLog;
// ^ NEW IN 1.60

// --- Functions ---
function Created() {}
function SetNbMissions(string _szNbMissions) {}
function SeTTerroKilled(string _szTerroKilled) {}
function SetRoundsFired(string _szRoundsFired) {}
function SetRoundsOnTarget(string _szRoundsOnTarget) {}
function SetShootPercent(string _szShootPercent) {}
function Paint(Canvas C, float X, float Y) {}

defaultproperties
{
}
