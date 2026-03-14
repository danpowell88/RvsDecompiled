//=============================================================================
//  R6MenuInGameEscSinglePlayerNavBar.uc : (add small description)
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/06/14 * Created by Alexandre Dionne
//=============================================================================
class R6MenuInGameEscSinglePlayerNavBar extends UWindowDialogClientWindow;

// --- Variables ---
var R6WindowButton m_ContinueButton;
var R6WindowButton m_AbortButton;
// ^ NEW IN 1.60
var R6WindowButton m_MainMenuButton;
// ^ NEW IN 1.60
var R6WindowButton m_OptionsButton;
// ^ NEW IN 1.60
var R6WindowButton m_ExitButton;
// ^ NEW IN 1.60
var float m_fButtonsYPos;
var Texture m_TExitButton;
// ^ NEW IN 1.60
var Texture m_TMainMenuButton;
// ^ NEW IN 1.60
var Texture m_TOptionsButton;
// ^ NEW IN 1.60
var Texture m_TAbortButton;
// ^ NEW IN 1.60
var Texture m_TContinueButton;
var Texture m_TRetryTrainingButton;
var R6MenuMPInGameHelpBar m_HelpTextBar;
var Region m_RExitButtonUp;
// ^ NEW IN 1.60
var Region m_RMainMenuButtonUp;
// ^ NEW IN 1.60
var Region m_ROptionsButtonUp;
// ^ NEW IN 1.60
var Region m_RAbortButtonUp;
// ^ NEW IN 1.60
var Region m_RContinueButtonUp;
// ^ NEW IN 1.60
var bool m_bInTraining;
var Region m_RRetryTrainingButtonUp;
// ^ NEW IN 1.60
var float m_fContinueXPos;
var float m_fAbortXPos;
// ^ NEW IN 1.60
var float m_fOptionsXPos;
// ^ NEW IN 1.60
var float m_fMainMenuXPos;
// ^ NEW IN 1.60
var float m_fExitXPos;
// ^ NEW IN 1.60
var float m_fHelpTextHeight;
// ^ NEW IN 1.60
var Region m_RRetryTrainingButtonOver;
var Region m_RRetryTrainingButtonDisabled;
// ^ NEW IN 1.60
var Region m_RRetryTrainingButtonDown;
// ^ NEW IN 1.60
var Region m_RContinueButtonOver;
var Region m_RContinueButtonDisabled;
// ^ NEW IN 1.60
var Region m_RContinueButtonDown;
// ^ NEW IN 1.60
var Region m_RAbortButtonOver;
var Region m_RAbortButtonDisabled;
// ^ NEW IN 1.60
var Region m_RAbortButtonDown;
// ^ NEW IN 1.60
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
var Region m_RExitButtonOver;
var Region m_RExitButtonDisabled;
// ^ NEW IN 1.60
var Region m_RExitButtonDown;
// ^ NEW IN 1.60

// --- Functions ---
function Created() {}
function Notify(byte E, UWindowDialogControl C) {}
//===============================================================================================
// SetTrainingNavbar: If you are in training, use thoses settings instead of what's you have in created
//===============================================================================================
function SetTrainingNavbar() {}

defaultproperties
{
}
