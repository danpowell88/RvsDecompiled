//=============================================================================
//  R6MenuInGameRootWindow.uc : This ingame root menu should provide us with
//                              uwindow support in the game
//
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/19 * Created by Alexandre Dionne
//=============================================================================
class R6MenuInGameRootWindow extends R6WindowRootWindow;

// --- Variables ---
// the border region
var Region m_REscMenuWidget;
var Region m_REscTraining;
var float m_fTopLabelHeight;
var bool m_bInEscMenu;
var R6MenuOptionsWidget m_OptionsWidget;
var R6MenuInGameInstructionWidget m_pInstructionWidget;
var int m_ESCMenuKey;
var bool m_bInTraining;
var bool m_bInPopUp;
var R6MenuDebriefingWidget m_DebriefingWidget;
var R6MenuInGameOperativeSelectorWidget m_InGameOperativeSelectorWidget;
//For esc menu and temporarely for enf of games as well
var R6MenuInGameEsc m_EscMenuWidget;
var bool m_bCanDisplayOperativeSelector;

// --- Functions ---
//=======================================================================================
// ProcessKeyUp: Process key up for menu, return true, the key is process to all the menus
//=======================================================================================
function bool ProcessKeyUp(int Key) {}
// ^ NEW IN 1.60
//=================================================================================
// MenuLoadProfile: Advice optionswidget that a load profile was occur
//=================================================================================
function MenuLoadProfile(bool _bServerProfile) {}
//=======================================================================================
// ProcessKeyDown: Process key down for menu, return true, the key is process to all the menus
//=======================================================================================
function bool ProcessKeyDown(int Key) {}
// ^ NEW IN 1.60
function SimplePopUp(optional UWindowWindow OwnerWindow, optional bool bAddDisableDlg, optional int _iButtonsType, EPopUpID _ePopUpID, string _szText, string _szTitle) {}
//==============================================================================
// PopUpBoxDone -  receive the result of the popup box
//==============================================================================
function PopUpBoxDone(EPopUpID _ePopUpID, MessageBoxResult Result) {}
//=============================================================================================
// ChangeWidget: Change widget according what`s you already have in your window list
//=============================================================================================
function ChangeWidget(eGameWidgetID widgetID, bool _bCloseAll, bool _bClearPrevWInHistory) {}
function WindowEvent(Canvas C, int Key, WinMessage Msg, float X, float Y) {}
function DrawMouse(Canvas C) {}
function MoveMouse(float Y, float X) {}
//==============================================================================================================
// ChangeInstructionWidget: change the instruction widget -- only in training
//==============================================================================================================
function ChangeInstructionWidget(int iParagraph, int iBox, bool bShow, Actor pISV) {}
function ChangeCurrentWidget(eGameWidgetID widgetID) {}
function Created() {}

defaultproperties
{
}
