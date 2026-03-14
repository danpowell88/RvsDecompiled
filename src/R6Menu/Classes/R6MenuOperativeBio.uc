//=============================================================================
//  R6MenuOperativeBio.uc : This Class Should Provide us with a window displaying
//                              an operative bio details in a R6MenuOperativeDetailControl
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/20 * Created by Alexandre Dionne
//=============================================================================
class R6MenuOperativeBio extends UWindowWindow;

// --- Variables ---
// var ? bshowlog; // REMOVED IN 1.60
var R6WindowTextLabel m_TStatus;
var float m_fValueLabelWidth;
//Titles Height
var float m_fTitleHeight;
//Display settings
//Horizontal padding where we start drawing from left and right
var float m_fHSidePadding;
var float m_fTileLabelWidth;
var R6MenuOperativeSkillsLabel m_TEyes;
var R6MenuOperativeSkillsLabel m_THair;
var R6MenuOperativeSkillsLabel m_TWeight;
var R6MenuOperativeSkillsLabel m_THeight;
//Titles
var R6MenuOperativeSkillsLabel m_TDateBirth;
var R6MenuOperativeSkillsLabel m_TGender;
//Values Labels
var R6MenuOperativeSkillsLabel m_NDateBirth;
var R6MenuOperativeSkillsLabel m_NHeight;
var R6MenuOperativeSkillsLabel m_NWeight;
var R6MenuOperativeSkillsLabel m_NHair;
var R6MenuOperativeSkillsLabel m_NEyes;
var R6MenuOperativeSkillsLabel m_NGender;
var float m_fHealthHeight;
//Vertical Padding from the top of the window
var float m_fTopYPadding;
//Vertical Padding Between Lines
var float m_fYPaddingBetweenElements;
var bool bShowLog;
// ^ NEW IN 1.60

// --- Functions ---
function SetBorderColor(Color _NewColor) {}
function Created() {}
function SetBirthDate(string _szBirthDate) {}
function SetHeight(string _szHeight) {}
function SetWeight(string _szWeight) {}
function SetHairColor(string _szHair) {}
function SetEyesColor(string _szEyes) {}
function SetGender(string _szGender) {}
function SetHealthStatus(string _Health) {}
function Paint(Canvas C, float X, float Y) {}

defaultproperties
{
}
