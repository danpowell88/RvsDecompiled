//=============================================================================
// R6MenuMPInGameEscNavBar - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6MenuMPInGameEscNavBar.uc : The nav bar of the esc menu for multiplayer in game
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/08/05 * Created by Yannick Joly
//=============================================================================
class R6MenuMPInGameEscNavBar extends R6MenuInGameEscSinglePlayerNavBar;

var Texture m_TMPContinueButton;
var Region m_RMPContinueButtonUp;
// NEW IN 1.60
var Region m_RMPContinueButtonDown;
// NEW IN 1.60
var Region m_RMPContinueButtonDisabled;
// NEW IN 1.60
var Region m_RMPContinueButtonOver;
var Region m_RPopUp;  // region of the popup

function Created()
{
	super.Created();
	m_HelpTextBar.m_szDefaultText = "";
	m_AbortButton.ToolTipString = Localize("ESCMENUS", "ESCABORTMP", "R6Menu");
	m_ContinueButton.ToolTipString = Localize("ESCMENUS", "ESCCONTINUE", "R6Menu");
	m_ContinueButton.UpTexture = m_TMPContinueButton;
	m_ContinueButton.OverTexture = m_TMPContinueButton;
	m_ContinueButton.DownTexture = m_TMPContinueButton;
	m_ContinueButton.DisabledTexture = m_TMPContinueButton;
	m_ContinueButton.UpRegion = m_RMPContinueButtonUp;
	m_ContinueButton.OverRegion = m_RMPContinueButtonOver;
	m_ContinueButton.DownRegion = m_RMPContinueButtonDown;
	m_ContinueButton.DisabledRegion = m_RMPContinueButtonDisabled;
	// End:0x152
	if(R6Console(Root.Console).m_bStartedByGSClient)
	{
		m_MainMenuButton.bDisabled = true;		
	}
	else
	{
		// End:0x1B6
		if((R6Console(Root.Console).m_bNonUbiMatchMakingHost || R6Console(Root.Console).m_bNonUbiMatchMaking))
		{
			m_MainMenuButton.bDisabled = true;
			m_AbortButton.bDisabled = true;
		}
	}
	return;
}

function Notify(UWindowDialogControl C, byte E)
{
	local R6MenuInGameMultiPlayerRootWindow r6Root;

	r6Root = R6MenuInGameMultiPlayerRootWindow(Root);
	// End:0x237
	if((int(E) == 2))
	{
		switch(C)
		{
			// End:0xBA
			case m_ExitButton:
				R6MenuMPInGameEsc(OwnerWindow).m_bEscAvailable = false;
				r6Root.m_RSimplePopUp = m_RPopUp;
				r6Root.SimplePopUp(Localize("ESCMENUS", "QuitConfirmTitle", "R6Menu"), Localize("ESCMENUS", "QuitConfirm", "R6Menu"), 51);
				// End:0x237
				break;
			// End:0x15B
			case m_MainMenuButton:
				R6MenuMPInGameEsc(OwnerWindow).m_bEscAvailable = false;
				r6Root.m_RSimplePopUp = m_RPopUp;
				r6Root.SimplePopUp(Localize("ESCMENUS", "DisconnectConfirmTitle", "R6Menu"), Localize("ESCMENUS", "DisconnectConfirm", "R6Menu"), 50);
				// End:0x237
				break;
			// End:0x177
			case m_OptionsButton:
				r6Root.ChangeCurrentWidget(16);
				// End:0x237
				break;
			// End:0x218
			case m_AbortButton:
				R6MenuMPInGameEsc(OwnerWindow).m_bEscAvailable = false;
				r6Root.m_RSimplePopUp = m_RPopUp;
				r6Root.SimplePopUp(Localize("ESCMENUS", "DisconnectConfirmTitle", "R6Menu"), Localize("ESCMENUS", "DisconnectConfirm", "R6Menu"), 31);
				// End:0x237
				break;
			// End:0x234
			case m_ContinueButton:
				r6Root.ChangeCurrentWidget(0);
				// End:0x237
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
	m_TMPContinueButton=Texture'R6MenuTextures.Gui_01'
	m_RMPContinueButtonUp=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=52002,ZoneNumber=0)
	m_RMPContinueButtonDown=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=52002,ZoneNumber=0)
	m_RMPContinueButtonDisabled=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=52002,ZoneNumber=0)
	m_RMPContinueButtonOver=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=52002,ZoneNumber=0)
	m_RPopUp=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=38434,ZoneNumber=0)
	m_TAbortButton=Texture'R6MenuTextures.Gui_02'
	m_RAbortButtonUp=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=54562,ZoneNumber=0)
	m_RAbortButtonDown=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=54562,ZoneNumber=0)
	m_RAbortButtonDisabled=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=54562,ZoneNumber=0)
	m_RAbortButtonOver=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=54562,ZoneNumber=0)
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var n
// REMOVED IN 1.60: var d
// REMOVED IN 1.60: var r
