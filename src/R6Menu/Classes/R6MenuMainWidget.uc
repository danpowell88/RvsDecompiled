//=============================================================================
//  R6MenuMainWidget.uc : Game Main Menu
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//	Main Menu
//
//  Revision history:
//    2001/11/08 * Created by Alexandre Dionne
//=============================================================================
class R6MenuMainWidget extends R6MenuWidget;

// --- Variables ---
var R6WindowButtonMainMenu m_ButtonSinglePlayer;
var R6WindowButtonMainMenu m_ButtonCustomMission;
var R6WindowButtonMainMenu m_ButtonMultiPlayer;
var R6WindowButtonMainMenu m_ButtonTraining;
var R6WindowButtonMainMenu m_ButtonOption;
var R6WindowButtonMainMenu m_ButtonCredits;
var float m_fButtonHeight;
// ^ NEW IN 1.60
var float m_fButtonWidth;
// ^ NEW IN 1.60
var float m_fButtonXpos;
// ^ NEW IN 1.60
var R6WindowButtonMainMenu m_ButtonQuit;
var float m_fButtonOffset;
var R6WindowTextLabel m_Version;
var float m_fFirstButtonYpos;
// ^ NEW IN 1.60

// --- Functions ---
function Created() {}
function Paint(Canvas C, float X, float Y) {}
function ShowWindow() {}

defaultproperties
{
}
