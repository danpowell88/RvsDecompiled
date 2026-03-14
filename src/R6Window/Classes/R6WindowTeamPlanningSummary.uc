//=============================================================================
//  R6WindowTeamPlanningSummary.uc : Top of each team summary in Execute screen
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/06/13 * Created by Alexandre Dionne
//=============================================================================
class R6WindowTeamPlanningSummary extends UWindowWindow;

// --- Variables ---
var R6WindowTextLabel m_GoCode;
// ^ NEW IN 1.60
var R6WindowTextLabel m_Waypoint;
// ^ NEW IN 1.60
var R6WindowTextLabel m_Team;
// ^ NEW IN 1.60
var R6WindowTextLabel m_WayPointVal;
var R6WindowTextLabel m_GoCodeVal;
// ^ NEW IN 1.60
var float m_fTopBGHeight;
var Color m_CDarkTeamColor;
var float m_fVlabelWidth;
var Texture m_TTopBG;
var float m_fLabelXOffset;
// ^ NEW IN 1.60
var byte m_BBottomAlpha;
var byte m_BTopAlpha;
var Region m_RTopBG;

// --- Functions ---
function SetPlanningValues(string szGoCode, string szWayPoint) {}
function SetTeamName(string szTeamName) {}
function Paint(Canvas C, float X, float Y) {}
function SetTeamColor(Color _c, Color _DarkColor) {}
function Created() {}

defaultproperties
{
}
