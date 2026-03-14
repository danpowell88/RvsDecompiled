//=============================================================================
//  R6MenuDebriefNavBar.uc : Bottom nav bar in debreifing room
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/06/17 * Created by Alexandre Dionne
//=============================================================================
class R6MenuDebriefNavBar extends UWindowDialogClientWindow;

// --- Variables ---
var R6WindowButton m_ContinueButton;
var R6WindowButton m_OptionsButton;
// ^ NEW IN 1.60
var R6WindowButton m_ActionButton;
// ^ NEW IN 1.60
var R6WindowButton m_PlanningButton;
var R6WindowButton m_MainMenuButton;
// ^ NEW IN 1.60
var float m_fButtonsYPos;
var Texture m_TMainMenuButton;
// ^ NEW IN 1.60
var Texture m_TOptionsButton;
// ^ NEW IN 1.60
var Texture m_TActionButton;
// ^ NEW IN 1.60
var Texture m_TPlanningButton;
// ^ NEW IN 1.60
var Texture m_TContinueButton;
var Region m_RMainMenuButtonUp;
// ^ NEW IN 1.60
var Region m_ROptionsButtonUp;
// ^ NEW IN 1.60
var Region m_RActionButtonUp;
// ^ NEW IN 1.60
var Region m_RPlanningButtonUp;
// ^ NEW IN 1.60
var Region m_RContinueButtonUp;
// ^ NEW IN 1.60
var float m_fOptionsXPos;
// ^ NEW IN 1.60
var float m_fMainMenuXPos;
// ^ NEW IN 1.60
var float m_fPlanningXPos;
// ^ NEW IN 1.60
var Region m_RContinueButtonOver;
var Region m_RContinueButtonDisabled;
// ^ NEW IN 1.60
var Region m_RContinueButtonDown;
// ^ NEW IN 1.60
var Region m_RPlanningButtonOver;
var Region m_RPlanningButtonDisabled;
// ^ NEW IN 1.60
var Region m_RPlanningButtonDown;
// ^ NEW IN 1.60
var Region m_RActionButtonOver;
var Region m_RActionButtonDisabled;
// ^ NEW IN 1.60
var Region m_RActionButtonDown;
// ^ NEW IN 1.60
var float m_fContinueXPos;
var Region m_ROptionsButtonOver;
var Region m_ROptionsButtonDisabled;
// ^ NEW IN 1.60
var Region m_ROptionsButtonDown;
// ^ NEW IN 1.60
var Region m_RMainMenuButtonOver;
var Region m_RMainMenuButtonDisabled;
// ^ NEW IN 1.60
var Region m_RMainMenuButtonDown;
// ^ NEW IN 1.60
var float m_fActionXPos;
// ^ NEW IN 1.60

// --- Functions ---
function bool AcceptMissionOutcome() {}
// ^ NEW IN 1.60
function Paint(Canvas C, float Y, float X) {}
function DenyMissionOutcome() {}
function Notify(UWindowDialogControl C, byte E) {}
function Created() {}

defaultproperties
{
}
