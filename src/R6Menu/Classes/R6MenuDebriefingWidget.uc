//=============================================================================
//  R6MenuDebriefingWidget.uc : Menu Poping at the end of the mission
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/07/04 * Created by Alexandre Dionne
//=============================================================================
class R6MenuDebriefingWidget extends R6MenuLaptopWidget;

// --- Variables ---
// the rainbows for the mission with their stats
var R6MenuSingleTeamBar m_pR6RainbowTeamBar;
//Missions Objectives for the current Mission
var R6WindowWrappedTextArea m_MissionObjectives;
//BIG MISSIN RESULT LABEL AT THE TOP OF THE PAGE
var R6WindowTextLabel m_MissionResultTitle;
var R6MenuCarreerStats m_RainbowCarreerStats;
var array<array> m_MissionOperatives;
var R6WindowTextLabel m_DateTime;
// ^ NEW IN 1.60
var R6WindowTextLabel m_CodeName;
// ^ NEW IN 1.60
var int m_iCountFrame;
var bool m_bMissionVictory;
var bool m_bReadyShowWindow;
//NAV BAR
var R6MenuDebriefNavBar m_DebriefNavBar;
var R6WindowTextLabel m_Location;
// ^ NEW IN 1.60
var Sound m_sndLossMusic;
var Sound m_sndVictoryMusic;
var float m_fStatsWidth;
var float m_fPaddingBetween;
// ^ NEW IN 1.60
var float m_fNavAreaY;
var Region m_RBGExtMissionResult;
var Region m_RBGMissionResult;
var Texture m_TBGMissionResult;
var float m_fMissionResultTitleWidth;
var float m_fMissionResultTitleHeight;
// ^ NEW IN 1.60
//Mission Objectives dimensions
var float m_fObjHeight;

// --- Functions ---
function Paint(float Y, float X, Canvas C) {}
function Notify(byte E, UWindowDialogControl C) {}
function ShowWindow() {}
function DisplayOperativeStats(int _OperativeId) {}
function BuildMissionOperatives() {}
function Created() {}
function HideWindow() {}

defaultproperties
{
}
