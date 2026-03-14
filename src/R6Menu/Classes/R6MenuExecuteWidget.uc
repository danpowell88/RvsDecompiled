//=============================================================================
//  R6MenuExecuteWidget.uc : This widget is the last one in the planning phase
//                            this widget allows the player to choose the team
//                            he will play in and has a last glance at team copositions
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/06/12 * Created by Alexandre Dionne
//=============================================================================
class R6MenuExecuteWidget extends R6MenuLaptopWidget;

// --- Variables ---
//Missions Objectives for the current Mission
var R6WindowWrappedTextArea m_MissionObjectives;
var R6WindowTeamSummary m_RedSummary;
// ^ NEW IN 1.60
var R6WindowTeamSummary m_GreenSummary;
// ^ NEW IN 1.60
var R6WindowButton m_GoGameButton;
// ^ NEW IN 1.60
/////////////////////////////////////////////////////////////////////////
//                           Bottom Buttons
/////////////////////////////////////////////////////////////////////////
var R6WindowButton m_ObserverButton;
var R6WindowButton m_GoPlanningButton;
// ^ NEW IN 1.60
var R6WindowTeamSummary m_GoldSummary;
var R6WindowButton m_GoldSummaryButton;
var R6WindowButton m_GreenSummaryButton;
// ^ NEW IN 1.60
var R6WindowButton m_RedSummaryButton;
// ^ NEW IN 1.60
//Small world map top right
var R6WindowBitMap m_SmallMap;
var float m_fTeamSummaryMaxHeight;
var float m_fTeamSummaryWidth;
// ^ NEW IN 1.60
var R6WindowTextLabel m_DateTime;
// ^ NEW IN 1.60
var float m_fButtonY;
// ^ NEW IN 1.60
var Texture m_TGoGameButton;
var Texture m_TGoPlanningButton;
// ^ NEW IN 1.60
var Texture m_TObserverButton;
// ^ NEW IN 1.60
var float m_fTeamSummaryXPadding;
// ^ NEW IN 1.60
var R6WindowTextLabel m_Location;
// ^ NEW IN 1.60
var R6WindowTextLabel m_CodeName;
// ^ NEW IN 1.60
var float m_fButtonHeight;
// ^ NEW IN 1.60
var float m_fButtonAreaY;
// ^ NEW IN 1.60
var Region m_RObserverButtonUp;
// ^ NEW IN 1.60
var Region m_RGoGameButtonUp;
// ^ NEW IN 1.60
var Region m_RGoPlanningButtonUp;
// ^ NEW IN 1.60
var float m_fObjHeight;
// ^ NEW IN 1.60
var float m_fObserverButtonX;
// ^ NEW IN 1.60
var float m_fGoGameButtonX;
// ^ NEW IN 1.60
var float m_fGoPlanningButtonX;
// ^ NEW IN 1.60
var Region m_RObserverButtonDisabled;
var Region m_RObserverButtonOver;
// ^ NEW IN 1.60
var Region m_RObserverButtonDown;
// ^ NEW IN 1.60
var Region m_RGoGameButtonDisabled;
var Region m_RGoGameButtonOver;
// ^ NEW IN 1.60
var Region m_RGoGameButtonDown;
// ^ NEW IN 1.60
var Region m_RGoPlanningButtonDisabled;
var Region m_RGoPlanningButtonOver;
// ^ NEW IN 1.60
var Region m_RGoPlanningButtonDown;
// ^ NEW IN 1.60
//Mission Objectives and map dimensions
var float m_fMapWidth;
var float m_fObjWidth;
// ^ NEW IN 1.60
var float m_fTeamSummaryYPadding;
// ^ NEW IN 1.60

// --- Functions ---
function Notify(byte E, UWindowDialogControl C) {}
function Paint(Canvas C, float Y, float X) {}
function ShowWindow() {}
function UpdateTeamRoster() {}
function Created() {}
function CalculatePlanningDetails() {}
function int GetTeamStart() {}
// ^ NEW IN 1.60

defaultproperties
{
}
