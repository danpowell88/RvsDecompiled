//=============================================================================
// R6MenuLoadPlan - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6MenuLoadPlan.uc : Window that pops up with all plans that can be loaded
//  Copyright 2003 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2003/01/14 * Created by Alexandre Dionne
//=============================================================================
class R6MenuLoadPlan extends UWindowDialogClientWindow;

var int m_IBXPos;  // Button Position
// NEW IN 1.60
var int m_IBYPos;
var R6WindowTextListBox m_pListOfSavedPlan;  // the save plan was displayed in this window
var R6WindowButton m_BDeletePlan;

function Created()
{
	m_BDeletePlan = R6WindowButton(CreateControl(Class'R6Window.R6WindowButton', float(m_IBXPos), ((WinHeight - float(R6MenuRSLookAndFeel(LookAndFeel).m_RSquareBgLeft.H)) - float(m_IBYPos)), (WinWidth - float(m_IBXPos)), float(R6MenuRSLookAndFeel(LookAndFeel).m_RSquareBgLeft.H)));
	m_BDeletePlan.m_buttonFont = Root.Fonts[6];
	m_BDeletePlan.m_fLMarge = 4.0000000;
	m_BDeletePlan.m_fRMarge = 4.0000000;
	m_BDeletePlan.Align = 0;
	m_BDeletePlan.m_bDrawSpecialBorder = true;
	m_BDeletePlan.m_bDrawBorders = true;
	m_BDeletePlan.Text = Localize("POPUP", "DELETEPLANBUTTON", "R6Menu");
	m_BDeletePlan.ResizeToText();
	m_pListOfSavedPlan = R6WindowTextListBox(CreateWindow(Class'R6Window.R6WindowTextListBox', 0.0000000, 0.0000000, WinWidth, m_BDeletePlan.WinTop));
	m_pListOfSavedPlan.ListClass = Class'R6Window.R6WindowListBoxItem';
	m_pListOfSavedPlan.m_Font = Root.Fonts[6];
	m_pListOfSavedPlan.Register(self);
	m_pListOfSavedPlan.m_fXItemOffset = 5.0000000;
	m_pListOfSavedPlan.m_DoubleClickClient = OwnerWindow;
	m_pListOfSavedPlan.m_bSkipDrawBorders = true;
	m_pListOfSavedPlan.m_fItemHeight = 10.0000000;
	return;
}

function Resized()
{
	m_BDeletePlan.WinTop = ((WinHeight - float(R6MenuRSLookAndFeel(LookAndFeel).m_RSquareBgLeft.H)) - float(m_IBYPos));
	m_pListOfSavedPlan.SetSize(WinWidth, m_BDeletePlan.WinTop);
	return;
}

function Notify(UWindowDialogControl C, byte E)
{
	local string DelPlanMsg;

	// End:0xDF
	if(((int(E) == 2) && (C == m_BDeletePlan)))
	{
		// End:0xDF
		if((m_pListOfSavedPlan.m_SelectedItem != none))
		{
			DelPlanMsg = ((((Localize("POPUP", "DelPlanMsg", "R6Menu") @ ":") @ m_pListOfSavedPlan.m_SelectedItem.HelpText) @ "\\n") @ Localize("POPUP", "DelPlanQuestion", "R6Menu"));
			R6MenuRootWindow(Root).SimplePopUp(Localize("POPUP", "DelPlan", "R6Menu"), DelPlanMsg, 40);
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
