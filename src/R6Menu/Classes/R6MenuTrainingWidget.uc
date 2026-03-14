//=============================================================================
//  R6MenuTrainingWidget.uc : Main training menu widget; lists all training mission chapters (basics, shooting, explosives, room clearing and hostage rescue) with a map preview.
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/12/11 * Created by Alexandre Dionne
//=============================================================================
class R6MenuTrainingWidget extends R6MenuWidget;

// --- Variables ---
// var ? bshowlog; // REMOVED IN 1.60
var Font m_LeftDownSizeFont;
//************************************************************************************************
//      Training sections Buttons
//************************************************************************************************
var R6WindowButton m_pButBasics;
var R6WindowButton m_pButExplosives;
var R6WindowButton m_pButRoomClearing1;
var R6WindowButton m_pButShooting;
var R6WindowButton m_pButRoomClearing2;
var R6WindowButton m_pButHostageRescue2;
var R6WindowButton m_pButHostageRescue1;
var R6WindowButton m_pButHostageRescue3;
var R6WindowButton m_pButRoomClearing3;
var Font m_LeftButtonFont;
var R6WindowButton m_ButtonStart;
var R6WindowTextLabel m_LMenuTitle;
var R6WindowButton m_ButtonOptions;
var R6WindowButton m_ButtonMainMenu;
var R6WindowSimpleFramedWindow m_Map;
var R6WindowButton m_pButCurrent;
// the help window (tooltip)
var R6MenuHelpWindow m_pHelpWindow;
var Color m_TitleTextColor;
var string m_mapNames[9];
var Texture m_mapPreviews[9];
var bool bShowLog;
// ^ NEW IN 1.60

// --- Functions ---
function bool ButtonsUsingDownSizeFont() {}
// ^ NEW IN 1.60
function CurrentSelectedButton(R6WindowButton _IwasPressed) {}
function StartTraining() {}
function CreateButtons() {}
function Paint(Canvas C, float Y, float X) {}
//=================================================================================
// Setup Help Text
//=================================================================================
function ToolTip(string strTip) {}
function Created() {}
//------------------------------------------------------------------
// SetCurrentMissionInTraining
//	set the mission description
//------------------------------------------------------------------
function SetCurrentMissionInTraining() {}
function Notify(UWindowDialogControl C, byte E) {}
function ForceFontDownSizing() {}
function ShowWindow() {}

defaultproperties
{
}
