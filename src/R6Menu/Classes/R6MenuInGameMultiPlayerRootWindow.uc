//=============================================================================
//  R6MenuInGameRootMultiPlayerRootWindow.uc : This ingame root menu should provide us with
//                              uwindow support in the multiplayer game
//
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/19 * Created by Alexandre Dionne
//=============================================================================
class R6MenuInGameMultiPlayerRootWindow extends R6WindowRootWindow;

// --- Constants ---
const C_iESC_POP_UP_HEIGHT =  30;
const C_iWKA_NONE =  0x00;
const C_iWKA_INBETROUND =  0x01;
const C_iWKA_PRERECMESSAGES =  0x02;
const C_iWKA_DRAWINGTOOL =  0x04;
const C_iWKA_TOGGLE_STATS =  0x08;
const C_iWKA_MENUCOUNTDOWN =  0x10;
const C_iWKA_ESC =  0x20;
const C_iWKA_INGAME =  0x1F;
const C_iWKA_ALL =  0x3F;

// --- Variables ---
var R6MPGameMenuCom m_R6GameMenuCom;
var R6MenuMPInterWidget m_pIntermissionMenuWidget;
var string m_szCurrentGameType;
// the border region
var Region m_RInterWidget;
var Region m_REscPopUp;
var Region m_RJoinWidget;
// active the bar for IN-GAME widget (server option, gear menu, etc)
var bool m_bActiveBar;
// true, player did a selection
var bool m_bPlayerDidASelection;
//When this is true we don't allow widget change
var bool m_bPreventMenuSwitch;
var R6MenuOptionsWidget m_pOptionsWidget;
var R6MenuMPInGameVote m_pVoteWidget;
var R6MenuMPJoinTeamWidget m_pJoinTeamWidget;
var R6MenuMPInGameEsc m_pInGameEscMenu;
// string of game mode loc
var string m_szGameModeLoc[2];
var string m_szCurrentGameModeLoc;
// force the welcome screen
var bool m_bJoinTeamWidget;
// trap key , engine will not receive the key
var bool m_bTrapKey;
// true when gamemenucom is none or the playercontroller
var bool m_bMenuInvalid;
var EGameModeInfo m_eCurrentGameMode;
var bool m_bCanDisplayOperativeSelector;
var bool bShowLog;
var R6MenuInGameOperativeSelectorWidget m_InGameOperativeSelectorWidget;
var R6MenuMPCountDown m_pCountDownWidget;
var R6MenuMPInGameMsgStatus m_pStatusMenuWidget;
var R6MenuMPInGameMsgReply m_pReplyMenuWidget;
var R6MenuMPInGameMsgDefensive m_pDefensiveMenuWidget;
var R6MenuMPInGameMsgOffensive m_pOffensiveMenuWidget;
var R6MenuMPInGameRecMessages m_pRecMessagesMenuWidget;
var R6MenuInGameWritableMapWidget m_InGameWritableMapWidget;
var bool m_bActiveVoteMenu;
var Sound m_sndCloseDrawingTool;
var Sound m_sndOpenDrawingTool;

// --- Functions ---
//=====================================================================================
// VoteMenuOn: Active the vote menu on/off (only if the player press on the specific key)
//=====================================================================================
function VoteMenu(bool _ActiveMenu, string _szPlayerNameToKick) {}
//===================================================================
// TrapKey: Menu trap the key
//===================================================================
function bool TrapKey(bool _bIncludeMouseMove) {}
// ^ NEW IN 1.60
//=================================================================================
// MenuLoadProfile: Advice optionswidget that a load profile was occur
//=================================================================================
function MenuLoadProfile(bool _bServerProfile) {}
function bool ProcessKeyUp(int Key) {}
// ^ NEW IN 1.60
//=====================================================================================================
//=====================================================================================================
function SimplePopUp(optional UWindowWindow OwnerWindow, optional bool bAddDisableDlg, optional int _iButtonsType, EPopUpID _ePopUpID, string _szText, string _szTitle) {}
//=============================================================================================
// ChangeWidget: Change widget according what`s you already have in your window list
//=============================================================================================
function ChangeWidget(eGameWidgetID widgetID, bool _bCloseAll, bool _bClearPrevWInHistory) {}
function bool ProcessKeyDown(int Key) {}
// ^ NEW IN 1.60
function WindowEvent(Canvas C, int Key, WinMessage Msg, float X, float Y) {}
function Paint(Canvas C, float X, float Y) {}
//=============================================================================================
// ChangeCurrentWidget: Change the current widget
//=============================================================================================
function ChangeCurrentWidget(eGameWidgetID widgetID) {}
function DrawMouse(Canvas C) {}
//=============================================================================================
// UpdateTimeInBetRound:  Get the time between round pop-up and update the time
//=============================================================================================
function UpdateTimeInBetRound(optional string _StringInstead, int _iNewTime) {}
//==============================================================================
// PopUpBoxDone -  receive the result of the popup box
//==============================================================================
function PopUpBoxDone(EPopUpID _ePopUpID, MessageBoxResult Result) {}
function MoveMouse(float Y, float X) {}
function Created() {}
//=============================================================================================
// FillListOfKeyAvailability: Fill the list of key availability
//							  Each widget (pop-up by a key) is define here
//=============================================================================================
function FillListOfKeyAvailability() {}
function UpdateCurrentGameMode() {}
function CloseSimplePopUpBox() {}
function NotifyBeforeLevelChange() {}
function NotifyAfterLevelChange() {}
function Tick(float Delta) {}
function bool IsGameMenuComInitialized() {}
// ^ NEW IN 1.60

defaultproperties
{
}
