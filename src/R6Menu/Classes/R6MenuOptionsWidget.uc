//=============================================================================
//  R6MenuOptionsWidget.uc : Full-screen options widget; manages tabbed sub-pages for game, sound, graphics, HUD, multiplayer, controls, mods and patch-service settings.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/11/22 * Created by Alexandre Dionne
//=============================================================================
class R6MenuOptionsWidget extends R6MenuWidget;

// --- Constants ---
const C_iARBITRARY_COUNTER =  10;
const C_fHEIGHT_OF_LABELW =  30;
const C_fWINDOWHEIGHT =  321;
const C_fWINDOWWIDTH =  422;
const C_fYSTARTPOS =  101;
const C_fXSTARTPOS =  198;

// --- Enums ---
enum eOptionsWindow
{
	OW_Game,
    OW_Sound,
    OW_Graphic,
    OW_Hud,
    OW_Multiplayer,
    OW_Controls,
	OW_MOD,
	OW_PatchService
};

// --- Structs ---
struct stOptionsPage
{
    var UWindowWindow pOptionsPage;
    var eOptionsWindow ePageID;
    var R6WindowButtonOptions pAssociateButton;
    var string szPageTitle;
};

// --- Variables ---
// var ? m_bPBWaitForInit; // REMOVED IN 1.60
// var ? m_pOptionCurrent; // REMOVED IN 1.60
// var ? m_pOptionsControls; // REMOVED IN 1.60
// var ? m_pOptionsGame; // REMOVED IN 1.60
// var ? m_pOptionsGraphic; // REMOVED IN 1.60
// var ? m_pOptionsHud; // REMOVED IN 1.60
// var ? m_pOptionsMODS; // REMOVED IN 1.60
// var ? m_pOptionsMulti; // REMOVED IN 1.60
// var ? m_pOptionsPatchService; // REMOVED IN 1.60
// var ? m_pOptionsSound; // REMOVED IN 1.60
// var ? m_pSimplePopUp; // REMOVED IN 1.60
var Font m_SmallButtonFont;
var R6WindowButtonOptions m_ButtonMODS;
var array<array> m_AListOptionsPages;
// ^ NEW IN 1.60
var R6WindowButtonOptions m_ButtonGame;
var R6WindowButtonOptions m_ButtonGraphic;
var R6WindowButtonOptions m_ButtonSound;
var R6WindowButtonOptions m_ButtonHudFilter;
var R6WindowButtonOptions m_ButtonMultiPlayer;
var R6WindowButtonOptions m_ButtonControls;
var R6WindowButtonOptions m_ButtonPatchService;
// the border of the option window
var R6WindowSimpleFramedWindowExt m_pOptionsBorder;
var R6WindowButtonOptions m_ButtonReturn;
var bool m_bInGame;
// the text label of the window option
var R6WindowTextLabelCurved m_pOptionsTextLabel;
// the title
var R6WindowTextLabel m_LMenuTitle;
var eOptionsWindow m_eCurrentPageDisplay;
// ^ NEW IN 1.60
var string m_sDisplayLOGO;
// the help window (tooltip)
var R6MenuHelpWindow m_pHelpWindow;

// --- Functions ---
// function ? PopUpBoxDone(...); // REMOVED IN 1.60
// function ? SetOptionsTitle(...); // REMOVED IN 1.60
// function ? SimplePopUp(...); // REMOVED IN 1.60
// function ? Tick(...); // REMOVED IN 1.60
function InitOptionsButtons() {}
function ManageOptionsSelection(int _OptionsChoice) {}
/////////////////////////////////////////////////////////////////
// display the help text in the m_pHelpTextWindow (derivate for uwindowwindow
/////////////////////////////////////////////////////////////////
function ToolTip(string strTip) {}
//=============================================================================================
// UpdateOptions: Update the options that's are not change directly in R6MenuOptionsTab
//=============================================================================================
function UpdateOptions() {}
function CreateAndAddPageOptionsToList(string _szTitle, eOptionsWindow _ePageID, R6WindowButtonOptions _pAssociateButton, class<UWindowWindow> _PageToCreate) {}
// ^ NEW IN 1.60
//=============================================================================================
// RefreshOptions: Refresh the options only when this window is activated
//=============================================================================================
function RefreshOptions() {}
function Paint(Canvas C, float Y, float X) {}
function ResizeAllOptionsButtons() {}
function InitOptionsWindow() {}
//*********************************
//      INIT CREATE FUNCTION
//*********************************
function InitTitle() {}
//===========================================================================================
// MenuLoadProfile: A new profiles is load, refresh the options
//===========================================================================================
function MenuOptionsLoadProfile() {}
function HideWindow() {}
function ShowWindow() {}
function Created() {}

defaultproperties
{
}
