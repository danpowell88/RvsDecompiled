//=============================================================================
//  R6MenuPlanningWidget.uc : Planning phase Menu
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/11/12 * Created by Alexandre Dionne
//=============================================================================
class R6MenuPlanningWidget extends R6MenuLaptopWidget;

// --- Constants ---
const R6InputKey_ActionPopup =  1024;
const R6InputKey_NewNode =  1025;
const R6InputKey_PathFlagPopup =  1026;

// --- Variables ---
var float m_fLabelHeight;
var bool m_bClosePopup;
var R6MenuPlanningBar m_PlanningBar;
var R6MenuActionPointMenu m_PopUpMenuPoint;
var R6MenuModeMenu m_PopUpMenuMode;
var bool m_bMoveUDByLaptop;
var bool m_bMoveRLByLaptop;
var R6Window3DButton m_3DWindow;
var R6Menu3DViewOnOffButton m_3DButton;
var R6WindowLegend m_LegendWindow;
var R6WindowTextLabel m_DateTime;
// ^ NEW IN 1.60
var R6MenuLegendButton m_LegendButton;
var R6WindowTextLabel m_CodeName;
// ^ NEW IN 1.60
var Font m_labelFont;
//Action PopUp menu is beeing displayed
var bool m_bPopUpMenuPoint;
//Speed PopUp Menu is beeing displayed
var bool m_bPopUpMenuSpeed;
var R6WindowTextLabel m_Location;
// ^ NEW IN 1.60
// Debug vars
var UWindowWindow DEB_FocusedWindow;
var bool bShowLog;
var float m_fLMouseDownX;
var float m_fLMouseDownY;

// --- Functions ---
function ResetTeams(int iWhatToReset) {}
function HideWindow() {}
//-----------------------------------------------------------//
//                      External commands                    //
//-----------------------------------------------------------//
function KeyType(float X, float Y, int iInputKey) {}
function Created() {}
function Tick(float fDelta) {}
function Paint(Canvas C, float X, float Y) {}
// Ideally Key would be a EInputKey but I can't see that class here.
function WindowEvent(WinMessage Msg, Canvas C, float X, float Y, int Key) {}
function ShowWindow() {}
function MouseMove(float fMouseX, float fMouseY) {}
function RMouseUp(float fMouseX, float fMouseY) {}
function RMouseDown(float fMouseX, float fMouseY) {}
function LMouseUp(float fMouseX, float fMouseY) {}
function LMouseDown(float fMouseX, float fMouseY) {}
//-----------------------------------------------------------//
//                      Mouse functions                      //
//-----------------------------------------------------------//
function SetMousePos(float X, float Y) {}
function DisplayActionTypePopUp(float Y, float X) {}
function DisplayPathFlagPopUp(float Y, float X) {}
function Reset() {}
function Hide3DAndLegend() {}
function CloseAllPopup() {}

defaultproperties
{
}
