//=============================================================================
//  R6WindowTeamSummary.uc : Team summary in execute screen there is one for each team
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/06/13 * Created by Alexandre Dionne
//=============================================================================
class R6WindowTeamSummary extends UWindowWindow;

// --- Variables ---
var R6WindowOperativePlanningSummary m_OperativeSummary[4];
var R6WindowTeamPlanningSummary m_TeamPlanningSummary;
var R6Operative m_teamOperatives[4];
var float m_fYPaddingBetweenElements;
var float m_fOperativeSummaryHeight;
// ^ NEW IN 1.60
var bool m_bIsSelected;
var float m_fSummaryHeight;
// ^ NEW IN 1.60

// --- Functions ---
function SetPlanningDetails(string szGoCode, string szWayPoint) {}
function TexRegion GetSpeciality(R6Operative _Operative) {}
// ^ NEW IN 1.60
function TexRegion GetOpHealth(R6Operative _Operative) {}
// ^ NEW IN 1.60
function SetTeam(int _Team) {}
function AddOperative(R6Operative _Operative) {}
function int OperativeCount() {}
// ^ NEW IN 1.60
function SetSelected(bool _IsSelected) {}
function Created() {}
function Init() {}

defaultproperties
{
}
