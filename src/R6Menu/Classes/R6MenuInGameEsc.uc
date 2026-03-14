//=============================================================================
//  R6MenuInGameEsc.uc : This pops in single player when we presse ESC 
//                              in single player
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/5/16 * Created by Alexandre Dionne
//=============================================================================
class R6MenuInGameEsc extends R6MenuWidget;

// --- Variables ---
// the rainbows for the mission with their stats
var R6MenuSingleTeamBar m_pR6RainbowTeamBar;
var R6WindowTextLabel m_CodeName;
// ^ NEW IN 1.60
var R6WindowTextLabel m_DateTime;
// ^ NEW IN 1.60
var float m_fNavBarHeight;
// the nav bar
var R6MenuInGameEscSinglePlayerNavBar m_pInGameNavBar;
var float m_fLabelHeight;
var R6WindowTextLabel m_Location;
// ^ NEW IN 1.60
var R6MenuEscObjectives m_EscObj;
var float m_fRainbowStatsHeight;

// --- Functions ---
function HideWindow() {}
function InitInGameEsc() {}
function ShowWindow() {}
function InitTrainingEsc() {}
function Created() {}

defaultproperties
{
}
