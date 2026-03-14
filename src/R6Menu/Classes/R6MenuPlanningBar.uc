//=============================================================================
//  R6MenuPlanningBar.uc : Container bar for the mission planning toolbar; combines the team selector, node-delete bar, camera view bar and timeline controls.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/28 * Created by Chaouky Garram
//=============================================================================
class R6MenuPlanningBar extends UWindowWindow;

// --- Variables ---
var R6MenuTeamBar m_TeamBar;
var R6MenuDelNodeBar m_DelNodeBar;
var R6MenuViewCamBar m_ViewCamBar;
var R6MenuTimeLineBar m_TimeLine;
var Color m_iColor;

// --- Functions ---
function Created() {}
function ResetTeams(int iWhatToReset) {}
function Reset() {}

defaultproperties
{
}
