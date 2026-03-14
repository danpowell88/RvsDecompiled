//=============================================================================
//  R6MenuCreditsWidget.uc : Full-screen widget that displays the game credits; scrolls a list of contributor names with optional video panels.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/11/22 * Created by Alexandre Dionne
//=============================================================================
class R6MenuCreditsWidget extends R6MenuWidget
    config(R6Credits);

// --- Variables ---
var Region m_RVideo;
var R6MenuCredits m_ListOfCredits;
var R6WindowButton m_ButtonMainMenu;
var int m_IBottomVideoY;
// ^ NEW IN 1.60
var R6WindowTextLabel m_LMenuTitle;
var int m_IBottomVideoH;
// ^ NEW IN 1.60
var config array<array> CreditsName;
var int m_ILeftVideoW;
var int m_IRightVideoW;
// ^ NEW IN 1.60
var int m_IRightVideoTextX;
// ^ NEW IN 1.60
var int m_IRightVideoX;
// ^ NEW IN 1.60

// --- Functions ---
function Notify(byte E, UWindowDialogControl C) {}
function Paint(Canvas C, float X, float Y) {}
function FillListOfCredits() {}
//=========================================================================================
// TO REMOVE FOR THE END OF THE PROJECT
//=========================================================================================
function WindowEvent(int Key, WinMessage Msg, float Y, float X, Canvas C) {}
function Created() {}
function ShowWindow() {}
function HideWindow() {}

defaultproperties
{
}
