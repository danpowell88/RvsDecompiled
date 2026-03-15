//=============================================================================
// R6MenuSinglePlayerCampaignSelect - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6MenuSinglePlayerCampaignSelect.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/12/17 * Created by Alexandre Dionne
//=============================================================================
class R6MenuSinglePlayerCampaignSelect extends UWindowDialogClientWindow;

var Texture m_BGTexture;
var R6WindowTextListBox m_CampaignListBox;
var R6WindowTextLabelCurved m_LCampaignTitle;

function Created()
{
	m_BGTexture = Texture(DynamicLoadObject("R6MenuTextures.Gui_BoxScroll", Class'Engine.Texture'));
	m_LCampaignTitle = R6WindowTextLabelCurved(CreateWindow(Class'R6Window.R6WindowTextLabelCurved', 0.0000000, 0.0000000, WinWidth, 31.0000000, self));
	m_LCampaignTitle.Text = Localize("SinglePlayer", "TitleCampaign", "R6Menu");
	m_LCampaignTitle.Align = 2;
	m_LCampaignTitle.m_Font = Root.Fonts[8];
	m_LCampaignTitle.TextColor = Root.Colors.White;
	m_CampaignListBox = R6WindowTextListBox(CreateControl(Class'R6Window.R6WindowTextListBox', 0.0000000, 30.0000000, WinWidth, (WinHeight - m_LCampaignTitle.WinHeight), self));
	m_CampaignListBox.ListClass = Class'R6Window.R6WindowListBoxItem';
	m_CampaignListBox.SetCornerType(3);
	m_CampaignListBox.ToolTipString = Localize("Tip", "CampaignListBox", "R6Menu");
	m_CampaignListBox.m_fXItemRightPadding = 5.0000000;
	return;
}

function RefreshListBox()
{
	local int iFiles, i;
	local string szFileName, szDir;
	local R6PlayerCampaign PC;
	local R6MenuRootWindow RootWindow;

	m_CampaignListBox.Clear();
	RootWindow = R6MenuRootWindow(Root);
	// End:0x6E
	if((RootWindow.m_pFileManager == none))
	{
		Log("R6MenuRootWindow(Root).m_pFileManager == NONE");
		iFiles = 0;		
	}
	else
	{
		szDir = Class'Engine.Actor'.static.GetModMgr().GetCampaignDir();
		iFiles = RootWindow.m_pFileManager.GetNbFile(szDir, "cmp");
	}
	i = 0;
	J0xB6:

	// End:0x105 [Loop If]
	if((i < iFiles))
	{
		RootWindow.m_pFileManager.GetFileName(i, szFileName);
		// End:0xFB
		if((szFileName != ""))
		{
			LoadCampaign(szFileName);
		}
		(i++);
		// [Loop Continue]
		goto J0xB6;
	}
	// End:0x1AB
	if((m_CampaignListBox.Items.Count() > 0))
	{
		m_CampaignListBox.SetSelectedItem(R6WindowListBoxItem(m_CampaignListBox.Items.Next));
		m_CampaignListBox.MakeSelectedVisible();
		PC = R6PlayerCampaign(R6WindowListBoxItem(m_CampaignListBox.m_SelectedItem).m_Object);
		// End:0x1A8
		if((PC != none))
		{
			R6MenuSinglePlayerWidget(OwnerWindow).UpdateSelectedCampaign(PC);
		}		
	}
	else
	{
		R6MenuSinglePlayerWidget(OwnerWindow).UpdateSelectedCampaign(none);
	}
	return;
}

function DeleteCampaign()
{
	local string temp, szDir;

	// End:0x84
	if((m_CampaignListBox.m_SelectedItem != none))
	{
		szDir = Class'Engine.Actor'.static.GetModMgr().GetCampaignDir();
		temp = ((szDir $ m_CampaignListBox.m_SelectedItem.HelpText) $ ".cmp");
		// End:0x84
		if(R6MenuRootWindow(Root).m_pFileManager.DeleteFile(temp))
		{
			RefreshListBox();
		}
	}
	return;
}

function LoadCampaign(string szCampaignName)
{
	local R6PlayerCampaign WorkCampaign;
	local R6WindowListBoxItem NewItem;

	// End:0x107
	if(((R6MenuRootWindow(Root) != none) && (R6MenuSinglePlayerWidget(OwnerWindow).m_pFileManager != none)))
	{
		WorkCampaign = new (none) Class'R6Game.R6PlayerCampaign';
		WorkCampaign.m_FileName = Left(szCampaignName, (Len(szCampaignName) - 4));
		WorkCampaign.m_OperativesMissionDetails = none;
		WorkCampaign.m_OperativesMissionDetails = new (none) Class'R6Game.R6MissionRoster';
		// End:0x107
		if(R6MenuSinglePlayerWidget(OwnerWindow).m_pFileManager.LoadCampaign(WorkCampaign))
		{
			NewItem = R6WindowListBoxItem(m_CampaignListBox.Items.Append(m_CampaignListBox.ListClass));
			NewItem.HelpText = WorkCampaign.m_FileName;
			NewItem.m_Object = WorkCampaign;
		}
	}
	return;
}

function bool SetupCampaign()
{
	local R6PlayerCampaign PC;

	// End:0x6F
	if((m_CampaignListBox.m_SelectedItem != none))
	{
		PC = R6PlayerCampaign(R6WindowListBoxItem(m_CampaignListBox.m_SelectedItem).m_Object);
		// End:0x6D
		if((PC != none))
		{
			R6Console(Root.Console).m_PlayerCampaign = PC;
			return true;			
		}
		else
		{
			return false;
		}
	}
	return false;
	return;
}

function Notify(UWindowDialogControl C, byte E)
{
	local R6PlayerCampaign PC;

	// End:0x7E
	if(((C == m_CampaignListBox) && (int(E) == 2)))
	{
		// End:0x7E
		if((m_CampaignListBox.m_SelectedItem != none))
		{
			PC = R6PlayerCampaign(R6WindowListBoxItem(m_CampaignListBox.m_SelectedItem).m_Object);
			// End:0x7E
			if((PC != none))
			{
				R6MenuSinglePlayerWidget(OwnerWindow).UpdateSelectedCampaign(PC);
			}
		}
	}
	return;
}


// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: function Paint
