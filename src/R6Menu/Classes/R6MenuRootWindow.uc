//=============================================================================
//  R6MenuRootWindow.uc : (Root of all windows)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/05/25 * Created by Chaouky Garram
//	  2001/11/12 * Modified by Alexandre Dionne Support multi-Menus	
//=============================================================================
class R6MenuRootWindow extends R6WindowRootWindow;

#exec OBJ LOAD FILE=..\Sounds\Music.uax PACKAGE=Music
#exec OBJ LOAD FILE="..\textures\R6MenuBG.utx" Package="R6MenuBG.Backgrounds"

// --- Variables ---
// var ? bShowlog; // REMOVED IN 1.60
var R6MenuWidget m_CurrentWidget;
var R6MenuPlanningWidget m_PlanningWidget;
/////////////////////////////////////////////////////////////////////////////////////////
//                                  POP UP
/////////////////////////////////////////////////////////////////////////////////////////
var R6WindowPopUpBox m_PopUpLoadPlan;
var R6MenuWidget m_PreviousWidget;
var R6MenuCDKeyManager m_pMenuCDKeyManager;
// ^ NEW IN 1.60
var R6WindowPopUpBox m_PopUpSavePlan;
// ^ NEW IN 1.60
var R6MenuGearWidget m_GearRoomWidget;
// ID of currently active pop up menu
var EPopUpID m_ePopUpID;
/////////////////////////////////////////////////////////////////////////////////
var array<array> m_GameOperatives;
var R6FileManager m_pFileManager;
//this help us find out if we have to prompt the player with the loading default planing pop up
var bool m_bPlayerPlanInitialized;
var R6MenuMPCreateGameWidget m_pMPCreateGameWidget;
var R6MenuSinglePlayerWidget m_SinglePlayerWidget;
var bool bShowLog;
// ^ NEW IN 1.60
var R6MenuCustomMissionWidget m_CustomMissionWidget;
var R6MenuTrainingWidget m_TrainingWidget;
var R6MenuUbiComWidget m_pUbiComWidget;
var R6MenuMultiPlayerWidget m_MultiPlayerWidget;
var bool m_bLoadingPlanning;
var R6MenuOptionsWidget m_OptionsWidget;
var R6MenuIntelWidget m_IntelWidget;
var R6MenuMainWidget m_MainMenuWidget;
var R6MenuNonUbiWidget m_pNonUbiWidget;
//Load default plan, this is to be able to retouch last plan
var bool m_bReloadPlan;
var bool m_bPlayerDoNotWant3DView;
var bool m_bPlayerWantLegend;
var R6MenuQuit m_pMenuQuit;
var R6MenuUbiComModsWidget m_pUbiComModsWidget;
// ^ NEW IN 1.60
// true, we currently join a server
var bool m_bJoinServerProcess;
var R6MenuCreditsWidget m_CreditsWidget;
var R6MenuExecuteWidget m_ExecuteWidget;
// Music for the MainMenu
var Sound m_MainMenuMusic;
// Don't remove: they are here only to make sure they are referenced (needed by cpp code)
var Texture m_BGTexture0;
var Texture m_BGTexture1;

// --- Functions ---
// function ? SaveTrainingPlanning(...); // REMOVED IN 1.60
//=================================================================================
// MenuLoadProfile: Advice optionswidget that a load profile was occur
//=================================================================================
function MenuLoadProfile(bool _bServerProfile) {}
//==============================================================================
// PopUp The good menu
//==============================================================================
function PopUpMenu(optional bool _bautoLoadPrompt) {}
function KeyType(int iInputKey, float X, float Y) {}
function MoveMouse(float X, float Y) {}
function UpdateMenus(int iWhatToUpdate) {}
function ResetMenus(optional bool _bConnectionFailed) {}
function Created() {}
function Set3dView(bool bSelected) {}
function SimplePopUp(string _szTitle, string _szText, EPopUpID _ePopUpID, optional int _iButtonsType, optional bool bAddDisableDlg, optional UWindowWindow OwnerWindow) {}
//=================================================================================
// NotifyWindow: receive specific notify from pop-up window, etc
//=================================================================================
function NotifyWindow(UWindowWindow C, byte E) {}
function SetNewMODS(optional bool _bForceRefresh, string _szNewBkgFolder) {}
//==============================================================================
// PopUpBoxDone -  receive the result of the popup box
//==============================================================================
function PopUpBoxDone(EPopUpID _ePopUpID, MessageBoxResult Result) {}
function GotoCampaignPlanning(bool _bRetrying) {}
function ResetCustomMissionOperatives() {}
function DrawMouse(Canvas C) {}
function WindowEvent(int Key, WinMessage Msg, float X, float Y, Canvas C) {}
//===========================================================================
// LoadAPlanning: load a planning -- the file load process...
//===========================================================================
function bool LoadAPlanning(string _szFileName) {}
// ^ NEW IN 1.60
function GotoPlanning() {}
//===========================================================================================
// FillListOfSavedPlan: Fill a list, R6WindowTextListBox, of saved plan
//===========================================================================================
function FillListOfSavedPlan(R6WindowTextListBox _pListOfSavedPlan) {}
function PartialResetOriginalData() {}
// ^ NEW IN 1.60
function LaunchQuickPlay() {}
//===========================================================================================
// IsSaveFileAlreadyExist: A file with the same name already exist?
//===========================================================================================
function bool IsSaveFileAlreadyExist(string _szFileName) {}
// ^ NEW IN 1.60
//===========================================================================
// DeleteAPlanning: Let's try to delete a USER plan
//===========================================================================
function bool DeleteAPlanning(string szFileName) {}
// ^ NEW IN 1.60
//===========================================================================
// ISPlanning Empty: Check if something is planned
//===========================================================================
function bool IsPlanningEmpty() {}
// ^ NEW IN 1.60
//===========================================================================
// LeaveForGame: ready to start the game in single... after loadplanning process
//===========================================================================
function LeaveForGame(bool _ObserverMode, int _iTeamStart) {}
//===========================================================================================================
// Make sure that is one of these buttons needs to downsize it's font all buttons end up using the same font
//===========================================================================================================
function HarmonizeMenuFonts() {}
function ChangeCurrentWidget(eGameWidgetID widgetID) {}
function AssignShowFirstWidget() {}
function ClosePopups() {}
function bool IsInsidePlanning() {}
// ^ NEW IN 1.60
function bool PlanningShouldProcessKey() {}
// ^ NEW IN 1.60
function bool PlanningShouldDrawPath() {}
// ^ NEW IN 1.60
function NotifyAfterLevelChange() {}
function StopPlayMode() {}
//==============================================================================
// StopWidgetSound: stop the sound for the current widget
//==============================================================================
function StopWidgetSound() {}
function SetServerOptions() {}
//================================================
// InitBeaconService:
//================================================
function InitBeaconService() {}

defaultproperties
{
}
