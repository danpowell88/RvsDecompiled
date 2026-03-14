//=============================================================================
// R6MenuInGameEscSinglePlayerNavBar - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6MenuInGameEscSinglePlayerNavBar.uc : (add small description)
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/06/14 * Created by Alexandre Dionne
//=============================================================================
class R6MenuInGameEscSinglePlayerNavBar extends UWindowDialogClientWindow;

var bool m_bInTraining;
var float m_fHelpTextHeight;
// NEW IN 1.60
var float m_fButtonsYPos;
var float m_fExitXPos;
// NEW IN 1.60
var float m_fMainMenuXPos;
// NEW IN 1.60
var float m_fOptionsXPos;
// NEW IN 1.60
var float m_fAbortXPos;
// NEW IN 1.60
var float m_fContinueXPos;
var R6MenuMPInGameHelpBar m_HelpTextBar;
var R6WindowButton m_ExitButton;
// NEW IN 1.60
var R6WindowButton m_MainMenuButton;
// NEW IN 1.60
var R6WindowButton m_OptionsButton;
// NEW IN 1.60
var R6WindowButton m_AbortButton;
// NEW IN 1.60
var R6WindowButton m_ContinueButton;
var Texture m_TExitButton;
// NEW IN 1.60
var Texture m_TMainMenuButton;
// NEW IN 1.60
var Texture m_TOptionsButton;
// NEW IN 1.60
var Texture m_TAbortButton;
// NEW IN 1.60
var Texture m_TContinueButton;
var Texture m_TRetryTrainingButton;
var Region m_RExitButtonUp;
// NEW IN 1.60
var Region m_RExitButtonDown;
// NEW IN 1.60
var Region m_RExitButtonDisabled;
// NEW IN 1.60
var Region m_RExitButtonOver;
var Region m_RMainMenuButtonUp;
// NEW IN 1.60
var Region m_RMainMenuButtonDown;
// NEW IN 1.60
var Region m_RMainMenuButtonDisabled;
// NEW IN 1.60
var Region m_RMainMenuButtonOver;
var Region m_ROptionsButtonUp;
// NEW IN 1.60
var Region m_ROptionsButtonDown;
// NEW IN 1.60
var Region m_ROptionsButtonDisabled;
// NEW IN 1.60
var Region m_ROptionsButtonOver;
var Region m_RAbortButtonUp;
// NEW IN 1.60
var Region m_RAbortButtonDown;
// NEW IN 1.60
var Region m_RAbortButtonDisabled;
// NEW IN 1.60
var Region m_RAbortButtonOver;
var Region m_RContinueButtonUp;
// NEW IN 1.60
var Region m_RContinueButtonDown;
// NEW IN 1.60
var Region m_RContinueButtonDisabled;
// NEW IN 1.60
var Region m_RContinueButtonOver;
var Region m_RRetryTrainingButtonUp;
// NEW IN 1.60
var Region m_RRetryTrainingButtonDown;
// NEW IN 1.60
var Region m_RRetryTrainingButtonDisabled;
// NEW IN 1.60
var Region m_RRetryTrainingButtonOver;

function Created()
{
	m_HelpTextBar = R6MenuMPInGameHelpBar(CreateWindow(Class'R6Menu.R6MenuMPInGameHelpBar', 1.0000000, 0.0000000, __NFUN_175__(WinWidth, float(2)), m_fHelpTextHeight, self));
	m_HelpTextBar.m_szDefaultText = Localize("ESCMENUS", "ESCRESUME", "R6Menu");
	m_ExitButton = R6WindowButton(CreateControl(Class'R6Window.R6WindowButton', m_fExitXPos, m_fButtonsYPos, float(m_RExitButtonUp.W), float(m_RExitButtonUp.H), self));
	m_ExitButton.UpTexture = m_TExitButton;
	m_ExitButton.OverTexture = m_TExitButton;
	m_ExitButton.DownTexture = m_TExitButton;
	m_ExitButton.DisabledTexture = m_TExitButton;
	m_ExitButton.UpRegion = m_RExitButtonUp;
	m_ExitButton.OverRegion = m_RExitButtonOver;
	m_ExitButton.DownRegion = m_RExitButtonDown;
	m_ExitButton.DisabledRegion = m_RExitButtonDisabled;
	m_ExitButton.bUseRegion = true;
	m_ExitButton.ToolTipString = Localize("ESCMENUS", "QUIT", "R6Menu");
	m_ExitButton.m_iDrawStyle = 5;
	m_MainMenuButton = R6WindowButton(CreateControl(Class'R6Window.R6WindowButton', m_fMainMenuXPos, m_fButtonsYPos, float(m_RMainMenuButtonUp.W), float(m_RMainMenuButtonUp.H), self));
	m_MainMenuButton.UpTexture = m_TMainMenuButton;
	m_MainMenuButton.OverTexture = m_TMainMenuButton;
	m_MainMenuButton.DownTexture = m_TMainMenuButton;
	m_MainMenuButton.DisabledTexture = m_TMainMenuButton;
	m_MainMenuButton.UpRegion = m_RMainMenuButtonUp;
	m_MainMenuButton.OverRegion = m_RMainMenuButtonOver;
	m_MainMenuButton.DownRegion = m_RMainMenuButtonDown;
	m_MainMenuButton.DisabledRegion = m_RMainMenuButtonDisabled;
	m_MainMenuButton.bUseRegion = true;
	m_MainMenuButton.ToolTipString = Localize("ESCMENUS", "MAIN", "R6Menu");
	m_MainMenuButton.m_iDrawStyle = 5;
	m_OptionsButton = R6WindowButton(CreateControl(Class'R6Window.R6WindowButton', m_fOptionsXPos, m_fButtonsYPos, float(m_ROptionsButtonUp.W), float(m_ROptionsButtonUp.H), self));
	m_OptionsButton.UpTexture = m_TOptionsButton;
	m_OptionsButton.OverTexture = m_TOptionsButton;
	m_OptionsButton.DownTexture = m_TOptionsButton;
	m_OptionsButton.DisabledTexture = m_TOptionsButton;
	m_OptionsButton.UpRegion = m_ROptionsButtonUp;
	m_OptionsButton.OverRegion = m_ROptionsButtonOver;
	m_OptionsButton.DownRegion = m_ROptionsButtonDown;
	m_OptionsButton.DisabledRegion = m_ROptionsButtonDisabled;
	m_OptionsButton.bUseRegion = true;
	m_OptionsButton.ToolTipString = Localize("ESCMENUS", "ESCOPTIONS", "R6Menu");
	m_OptionsButton.m_iDrawStyle = 5;
	m_AbortButton = R6WindowButton(CreateControl(Class'R6Window.R6WindowButton', m_fAbortXPos, m_fButtonsYPos, float(m_RAbortButtonUp.W), float(m_RAbortButtonUp.H), self));
	m_AbortButton.UpTexture = m_TAbortButton;
	m_AbortButton.OverTexture = m_TAbortButton;
	m_AbortButton.DownTexture = m_TAbortButton;
	m_AbortButton.DisabledTexture = m_TAbortButton;
	m_AbortButton.UpRegion = m_RAbortButtonUp;
	m_AbortButton.OverRegion = m_RAbortButtonOver;
	m_AbortButton.DownRegion = m_RAbortButtonDown;
	m_AbortButton.DisabledRegion = m_RAbortButtonDisabled;
	m_AbortButton.bUseRegion = true;
	m_AbortButton.ToolTipString = Localize("ESCMENUS", "ESCABORT_ACTION", "R6Menu");
	m_AbortButton.m_iDrawStyle = 5;
	m_ContinueButton = R6WindowButton(CreateControl(Class'R6Window.R6WindowButton', m_fContinueXPos, m_fButtonsYPos, float(m_RContinueButtonUp.W), float(m_RContinueButtonUp.H), self));
	m_ContinueButton.UpTexture = m_TContinueButton;
	m_ContinueButton.OverTexture = m_TContinueButton;
	m_ContinueButton.DownTexture = m_TContinueButton;
	m_ContinueButton.DisabledTexture = m_TContinueButton;
	m_ContinueButton.UpRegion = m_RContinueButtonUp;
	m_ContinueButton.OverRegion = m_RContinueButtonOver;
	m_ContinueButton.DownRegion = m_RContinueButtonDown;
	m_ContinueButton.DisabledRegion = m_RContinueButtonDisabled;
	m_ContinueButton.bUseRegion = true;
	m_ContinueButton.ToolTipString = Localize("ESCMENUS", "ESCABORT_PLANNING", "R6Menu");
	m_ContinueButton.m_iDrawStyle = 5;
	return;
}

//===============================================================================================
// SetTrainingNavbar: If you are in training, use thoses settings instead of what's you have in created
//===============================================================================================
function SetTrainingNavbar()
{
	m_bInTraining = true;
	m_ContinueButton.UpTexture = m_TRetryTrainingButton;
	m_ContinueButton.OverTexture = m_TRetryTrainingButton;
	m_ContinueButton.DownTexture = m_TRetryTrainingButton;
	m_ContinueButton.DisabledTexture = m_TRetryTrainingButton;
	m_ContinueButton.UpRegion = m_RRetryTrainingButtonUp;
	m_ContinueButton.OverRegion = m_RRetryTrainingButtonOver;
	m_ContinueButton.DownRegion = m_RRetryTrainingButtonDown;
	m_ContinueButton.DisabledRegion = m_RRetryTrainingButtonDisabled;
	m_ContinueButton.ToolTipString = Localize("ESCMENUS", "ESCQUIT_TRAINING", "R6Menu");
	m_ContinueButton.SetSize(float(m_RRetryTrainingButtonUp.W), float(m_RRetryTrainingButtonUp.H));
	m_AbortButton.ToolTipString = Localize("ESCMENUS", "ESCABORT_TRAINING", "R6Menu");
	return;
}

function Notify(UWindowDialogControl C, byte E)
{
	// End:0x316
	if(__NFUN_154__(int(E), 2))
	{
		switch(C)
		{
			// End:0x81
			case m_ExitButton:
				R6MenuInGameRootWindow(Root).SimplePopUp(Localize("POPUP", "PopUpTitle_QUIT", "R6Menu"), Localize("ESCMENUS", "QuitConfirm", "R6Menu"), 51);
				// End:0x316
				break;
			// End:0xF3
			case m_MainMenuButton:
				R6MenuInGameRootWindow(Root).SimplePopUp(Localize("POPUP", "PopUpTitle_QuitToMain", "R6Menu"), Localize("ESCMENUS", "MAINCONFIRM", "R6Menu"), 50);
				// End:0x316
				break;
			// End:0x10F
			case m_OptionsButton:
				Root.ChangeCurrentWidget(16);
				// End:0x316
				break;
			// End:0x212
			case m_AbortButton:
				// End:0x19B
				if(m_bInTraining)
				{
					R6MenuInGameRootWindow(Root).SimplePopUp(Localize("POPUP", "PopUpTitle_ESCABORT_TRAINING", "R6Menu"), Localize("ESCMENUS", "ABORTCONFIRM_TRAINING", "R6Menu"), 52);					
				}
				else
				{
					R6MenuInGameRootWindow(Root).SimplePopUp(Localize("POPUP", "PopUpTitle_ESCABORT_ACTION", "R6Menu"), Localize("ESCMENUS", "ABORTCONFIRM_ACTION", "R6Menu"), 52);
				}
				// End:0x316
				break;
			// End:0x313
			case m_ContinueButton:
				// End:0x29C
				if(m_bInTraining)
				{
					R6MenuInGameRootWindow(Root).SimplePopUp(Localize("POPUP", "PopUpTitle_ESCQUIT_TRAINING", "R6Menu"), Localize("ESCMENUS", "QUITCONFIRM_TRAINING", "R6Menu"), 54);					
				}
				else
				{
					R6MenuInGameRootWindow(Root).SimplePopUp(Localize("POPUP", "PopUpTitle_ESCABORT_PLANNING", "R6Menu"), Localize("ESCMENUS", "ABORTCONFIRM_PLAN", "R6Menu"), 53);
				}
				// End:0x316
				break;
			// End:0xFFFF
			default:
				break;
		}
	}
	else
	{
		return;
	}
}

defaultproperties
{
	m_fHelpTextHeight=20.0000000
	m_fButtonsYPos=22.0000000
	m_fExitXPos=32.0000000
	m_fMainMenuXPos=110.0000000
	m_fOptionsXPos=194.0000000
	m_fAbortXPos=267.0000000
	m_fContinueXPos=346.0000000
	m_TExitButton=Texture'R6MenuTextures.Gui_02'
	m_TMainMenuButton=Texture'R6MenuTextures.Gui_02'
	m_TOptionsButton=Texture'R6MenuTextures.Gui_02'
	m_TAbortButton=Texture'R6MenuTextures.Gui_01'
	m_TContinueButton=Texture'R6MenuTextures.Gui_01'
	m_TRetryTrainingButton=Texture'R6MenuTextures.Gui_02'
	m_RExitButtonUp=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=19234,ZoneNumber=0)
	m_RExitButtonDown=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=19234,ZoneNumber=0)
	m_RExitButtonDisabled=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=19234,ZoneNumber=0)
	m_RExitButtonOver=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=19234,ZoneNumber=0)
	m_RMainMenuButtonUp=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=28450,ZoneNumber=0)
	m_RMainMenuButtonDown=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=28450,ZoneNumber=0)
	m_RMainMenuButtonDisabled=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=28450,ZoneNumber=0)
	m_RMainMenuButtonOver=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=28450,ZoneNumber=0)
	m_ROptionsButtonUp=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=37922,ZoneNumber=0)
	m_ROptionsButtonDown=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=37922,ZoneNumber=0)
	m_ROptionsButtonDisabled=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=37922,ZoneNumber=0)
	m_ROptionsButtonOver=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=37922,ZoneNumber=0)
	m_RAbortButtonUp=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=23842,ZoneNumber=0)
	m_RAbortButtonDown=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=23842,ZoneNumber=0)
	m_RAbortButtonDisabled=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=23842,ZoneNumber=0)
	m_RAbortButtonOver=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=23842,ZoneNumber=0)
	m_RContinueButtonUp=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=32034,ZoneNumber=0)
	m_RContinueButtonDown=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=32034,ZoneNumber=0)
	m_RContinueButtonDisabled=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=32034,ZoneNumber=0)
	m_RContinueButtonOver=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=32034,ZoneNumber=0)
	m_RRetryTrainingButtonUp=(Zone=ObjectProperty'R6Menu.R6MenuMPCreateGameTab.m_pButtonsDef',iLeaf=30754,ZoneNumber=0)
	m_RRetryTrainingButtonDown=(Zone=ObjectProperty'R6Menu.R6MenuMPCreateGameTab.m_pButtonsDef',iLeaf=46114,ZoneNumber=0)
	m_RRetryTrainingButtonDisabled=(Zone=ObjectProperty'R6Menu.R6MenuMPCreateGameTab.m_pButtonsDef',iLeaf=53794,ZoneNumber=0)
	m_RRetryTrainingButtonOver=(Zone=ObjectProperty'R6Menu.R6MenuMPCreateGameTab.m_pButtonsDef',iLeaf=38434,ZoneNumber=0)
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var n
// REMOVED IN 1.60: var d
// REMOVED IN 1.60: var r
// REMOVED IN 1.60: var s
