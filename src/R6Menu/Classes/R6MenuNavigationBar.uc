//=============================================================================
//  R6MenuNavigationBar.uc : (add small description)
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/06/26 * Created by Alexandre Dionne
//=============================================================================
class R6MenuNavigationBar extends UWindowDialogClientWindow;

// --- Variables ---
var Texture m_TMainMenuTexture;
var R6WindowButton m_BriefingButton;
// ^ NEW IN 1.60
var R6WindowButton m_PlanningButton;
// ^ NEW IN 1.60
var R6WindowButton m_MainMenuButton;
// ^ NEW IN 1.60
var R6WindowButton m_GearButton;
// ^ NEW IN 1.60
var R6WindowButton m_QuickPlayButton;
// ^ NEW IN 1.60
var R6WindowButton m_LoadButton;
// ^ NEW IN 1.60
var R6WindowButton m_SaveButton;
// ^ NEW IN 1.60
var R6WindowButton m_PlayButton;
// ^ NEW IN 1.60
var R6WindowButton m_OptionsButton;
// ^ NEW IN 1.60
var int m_iNavBarLocation[9];
var int m_iBigButtonHeight;
var Region m_RSaveButtonUp;
// ^ NEW IN 1.60
var Region m_RQuickPlayButtonUp;
// ^ NEW IN 1.60
var Region m_RPlayButtonUp;
// ^ NEW IN 1.60
var Region m_RPlanningButtonUp;
// ^ NEW IN 1.60
var Region m_RGearButtonUp;
// ^ NEW IN 1.60
var Region m_RBriefingButtonUp;
// ^ NEW IN 1.60
var Region m_ROptionsButtonUp;
// ^ NEW IN 1.60
var Region m_RMainMenuButtonUp;
// ^ NEW IN 1.60
var Region m_RQuickPlayButtonOver;
var Region m_RQuickPlayButtonDisabled;
// ^ NEW IN 1.60
var Region m_RQuickPlayButtonDown;
// ^ NEW IN 1.60
var Region m_RLoadButtonOver;
var Region m_RLoadButtonDisabled;
// ^ NEW IN 1.60
var Region m_RLoadButtonDown;
// ^ NEW IN 1.60
var Region m_RLoadButtonUp;
// ^ NEW IN 1.60
var Region m_RSaveButtonOver;
var Region m_RSaveButtonDisabled;
// ^ NEW IN 1.60
var Region m_RSaveButtonDown;
// ^ NEW IN 1.60
var Region m_RPlayButtonOver;
var Region m_RPlayButtonDisabled;
// ^ NEW IN 1.60
var Region m_RPlayButtonDown;
// ^ NEW IN 1.60
var Region m_RPlanningButtonOver;
var Region m_RPlanningButtonDisabled;
// ^ NEW IN 1.60
var Region m_RPlanningButtonDown;
// ^ NEW IN 1.60
var Region m_RGearButtonOver;
var Region m_RGearButtonDisabled;
// ^ NEW IN 1.60
var Region m_RGearButtonDown;
// ^ NEW IN 1.60
var Region m_RBriefingButtonOver;
var Region m_RBriefingButtonDisabled;
// ^ NEW IN 1.60
var Region m_RBriefingButtonDown;
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

// --- Functions ---
function Notify(byte E, UWindowDialogControl C) {}
function Paint(Canvas C, float X, float Y) {}
function Created() {}

defaultproperties
{
}
