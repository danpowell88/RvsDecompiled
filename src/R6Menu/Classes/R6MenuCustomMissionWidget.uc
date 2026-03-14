//=============================================================================
//  R6MenuCustomMissionWidget.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/11/22 * Created by Alexandre Dionne
//=============================================================================
class R6MenuCustomMissionWidget extends R6MenuWidget
    config(USER);

// --- Variables ---
// var ? bshowlog; // REMOVED IN 1.60
var R6WindowTextListBox m_GameLevelBox;
var R6WindowButton m_pButPraticeMission;
var R6WindowButton m_pButHostageRescue;
var R6WindowButton m_pButTerroHunt;
var R6WindowButton m_pButLoneWolf;
var R6WindowSimpleCurvedFramedWindow m_DifficultyArea;
var R6WindowButton m_pButCurrent;
var Font m_LeftDownSizeFont;
var R6WindowButton m_ButtonStart;
var R6WindowButton m_ButtonMainMenu;
var R6WindowButton m_ButtonOptions;
var R6WindowTextLabel m_LMenuTitle;
var R6WindowSimpleFramedWindow m_TerroArea;
var bool bShowLog;
// ^ NEW IN 1.60
var R6WindowSimpleFramedWindow m_Map;
var R6WindowTextLabelCurved m_LGameLevelTitle;
var Font m_LeftButtonFont;
var Color m_TitleTextColor;
// the help window (tooltip)
var R6MenuHelpWindow m_pHelpWindow;
//To update when we come back from a custom menu game
var string m_LastMapPlayed;
var config int CustomMissionGameType;
var config string CustomMissionMap;
var R6FileManagerCampaign m_pFileManager;

// --- Functions ---
function Paint(Canvas C, float X, float Y) {}
//=================================================================================
// Setup Help Text
//=================================================================================
function ToolTip(string strTip) {}
function bool ButtonsUsingDownSizeFont() {}
// ^ NEW IN 1.60
function RefreshList() {}
function InitCustomMission() {}
function CreateButtons() {}
function GotoPlanning() {}
function Notify(UWindowDialogControl C, byte E) {}
function Created() {}
function bool CampainMapExistInMapList(R6MissionDescription pMission) {}
// ^ NEW IN 1.60
function bool ValidateBeforePlanning() {}
// ^ NEW IN 1.60
function ShowWindow() {}
//=================================================================================
// UpdateBackground: update background
//=================================================================================
function UpdateBackground() {}
function ForceFontDownSizing() {}

defaultproperties
{
}
