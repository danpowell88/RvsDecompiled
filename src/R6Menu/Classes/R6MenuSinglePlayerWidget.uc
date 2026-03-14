//=============================================================================
//  R6MenuSinglePlayerWidget.uc : Main single-player menu widget; presents campaign selection, creation and deletion with a map preview panel.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/11/22 * Created by Alexandre Dionne
//=============================================================================
class R6MenuSinglePlayerWidget extends R6MenuWidget;

// --- Enums ---
enum eWidgetID
{
    CampaignSelect,
	CampaignCreate
};
enum ECampaignButID
{
    ButtonResumeID,
    ButtonNewID,
    ButtonDeleteID,
	ButtonAccept
};

// --- Variables ---
// var ? bShowlog; // REMOVED IN 1.60
var R6MenuSinglePlayerCampaignSelect m_CampaignSelect;
var R6WindowButton m_ButtonStart;
var R6WindowButton m_pButResumeCampaign;
var R6WindowButton m_pButDelCampaign;
var R6WindowSimpleCurvedFramedWindow m_CampaignCreate;
var R6WindowButton m_pButNewCampaign;
var int m_iSelectedButtonID;
var R6WindowSimpleFramedWindow m_Map;
var R6WindowButton m_ButtonMainMenu;
// ^ NEW IN 1.60
var R6WindowButton m_ButtonOptions;
// ^ NEW IN 1.60
var R6WindowTextLabel m_LMenuTitle;
var Font m_LeftDownSizeFont;
var R6WindowSimpleFramedWindow m_CampaignDescription;
var R6FileManagerCampaign m_pFileManager;
var string m_ButtonStartHelpText[2];
var string m_ButtonStartText[2];
var R6WindowButton m_pButCurrent;
var Font m_LeftButtonFont;
// the help window (tooltip)
var R6MenuHelpWindow m_pHelpWindow;
var Color m_HelpTextColor;
var bool bShowLog;
// ^ NEW IN 1.60
var int m_iFont;

// --- Functions ---
function bool CampaignExists() {}
// ^ NEW IN 1.60
function KeyDown(int Key, float Y, float X) {}
function bool ButtonsUsingDownSizeFont() {}
// ^ NEW IN 1.60
function SetCurrentBut(int _iNewCurBut) {}
function Notify(UWindowDialogControl C, byte E) {}
function Paint(Canvas C, float Y, float X) {}
//=================================================================================
// Setup Help Text
//=================================================================================
function ToolTip(string strTip) {}
//=================================================================================
// Changing the poping window
//=================================================================================
function switchWidget(eWidgetID newWidget) {}
//Updates text for the current selected Campaign
function UpdateSelectedCampaign(R6PlayerCampaign _PlayerCampaign) {}
function CreateButtons() {}
//=================================================================================
// Button clicked
//=================================================================================
function ButtonClicked(int ButtonID) {}
function Created() {}
function ForceFontDownSizing() {}
function DeleteCurrentSelectedCampaign() {}
function TryCreatingCampaign() {}
function HideWindow() {}
function ShowWindow() {}

defaultproperties
{
}
