//=============================================================================
// R6MenuSavePlan - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6MenuSavePlan.uc : This is the class where you manage the save plan. You have an edit box to edit
//						the name of the save file and a text list box where we displaying the other save files
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/10/02 * Created by Yannick Joly
//=============================================================================
class R6MenuSavePlan extends UWindowDialogClientWindow;

const C_iEDITBOX_HEIGHT = 24;

var int m_IBXPos;  // Button Position
// NEW IN 1.60
var int m_IBYPos;
var R6WindowEditBox m_pEditSaveNameBox;  // the edit box to edit the save name
var R6WindowTextListBox m_pListOfSavedPlan;  // the save plan was displayed in this window
var R6WindowButton m_BDeletePlan;

function Created()
{
	m_pEditSaveNameBox = R6WindowEditBox(CreateWindow(Class'R6Window.R6WindowEditBox', 0.0000000, 0.0000000, WinWidth, 24.0000000));
	m_pEditSaveNameBox.TextColor = Root.Colors.White;
	m_pEditSaveNameBox.SetFont(6);
	m_pEditSaveNameBox.bCaps = false;
	m_pEditSaveNameBox.SetValue("");
	m_pEditSaveNameBox.MoveEnd();
	m_pEditSaveNameBox.MaxLength = 20;
	m_pEditSaveNameBox.offset = 5.0000000;
	m_BDeletePlan = R6WindowButton(CreateControl(Class'R6Window.R6WindowButton', float(m_IBXPos), ((WinHeight - float(R6MenuRSLookAndFeel(LookAndFeel).m_RSquareBgLeft.H)) - float(m_IBYPos)), (WinWidth - float(m_IBXPos)), float(R6MenuRSLookAndFeel(LookAndFeel).m_RSquareBgLeft.H)));
	m_BDeletePlan.m_buttonFont = Root.Fonts[6];
	m_BDeletePlan.m_fLMarge = 4.0000000;
	m_BDeletePlan.m_fRMarge = 4.0000000;
	m_BDeletePlan.m_bDrawSpecialBorder = true;
	m_BDeletePlan.m_bDrawBorders = true;
	m_BDeletePlan.Align = 0;
	m_BDeletePlan.Text = Localize("POPUP", "DELETEPLANBUTTON", "R6Menu");
	m_BDeletePlan.ResizeToText();
	m_pListOfSavedPlan = R6WindowTextListBox(CreateWindow(Class'R6Window.R6WindowTextListBox', 0.0000000, 24.0000000, WinWidth, (m_BDeletePlan.WinTop - float(24))));
	m_pListOfSavedPlan.ListClass = Class'R6Window.R6WindowListBoxItem';
	m_pListOfSavedPlan.m_Font = Root.Fonts[6];
	m_pListOfSavedPlan.Register(self);
	m_pListOfSavedPlan.m_fXItemOffset = 5.0000000;
	m_pListOfSavedPlan.m_DoubleClickClient = OwnerWindow;
	m_pListOfSavedPlan.m_bSkipDrawBorders = true;
	m_pListOfSavedPlan.m_fItemHeight = 10.0000000;
	return;
}

function Paint(Canvas C, float X, float Y)
{
	C.Style = 1;
	C.SetDrawColor(m_BorderColor.R, m_BorderColor.G, m_BorderColor.B);
	DrawStretchedTexture(C, 0.0000000, m_pListOfSavedPlan.WinTop, WinWidth, 1.0000000, Texture'UWindow.WhiteTexture');
	return;
}

function Notify(UWindowDialogControl C, byte E)
{
	local string DelPlanMsg;

	// End:0x129
	if((int(E) == 2))
	{
		// End:0x5A
		if((C == m_pListOfSavedPlan))
		{
			// End:0x57
			if((m_pListOfSavedPlan.m_SelectedItem != none))
			{
				m_pEditSaveNameBox.SetValue(m_pListOfSavedPlan.m_SelectedItem.HelpText);
			}			
		}
		else
		{
			// End:0x129
			if((C == m_BDeletePlan))
			{
				// End:0x129
				if((m_pListOfSavedPlan.m_SelectedItem != none))
				{
					DelPlanMsg = ((((Localize("POPUP", "DelPlanMsg", "R6Menu") @ ":") @ m_pListOfSavedPlan.m_SelectedItem.HelpText) @ "\\n") @ Localize("POPUP", "DelPlanQuestion", "R6Menu"));
					R6MenuRootWindow(Root).SimplePopUp(Localize("POPUP", "DelPlan", "R6Menu"), DelPlanMsg, 41);
				}
			}
		}
	}
	return;
}

defaultproperties
{
	m_IBXPos=6
	m_IBYPos=4
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var s
