//=============================================================================
// R6MenuSinglePlayerWidget - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6MenuSinglePlayerWidget.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/11/22 * Created by Alexandre Dionne
//=============================================================================
class R6MenuSinglePlayerWidget extends R6MenuWidget;

enum eWidgetID
{
	CampaignSelect,                 // 0
	CampaignCreate                  // 1
};

enum ECampaignButID
{
	ButtonResumeID,                 // 0
	ButtonNewID,                    // 1
	ButtonDeleteID,                 // 2
	ButtonAccept                    // 3
};

var int m_iFont;
var int m_iSelectedButtonID;
var bool bShowLog;
var R6WindowButton m_ButtonMainMenu;
// NEW IN 1.60
var R6WindowButton m_ButtonOptions;
// NEW IN 1.60
var R6WindowButton m_ButtonStart;
var R6WindowSimpleFramedWindow m_Map;
var R6WindowTextLabel m_LMenuTitle;
var R6MenuSinglePlayerCampaignSelect m_CampaignSelect;
var R6WindowSimpleCurvedFramedWindow m_CampaignCreate;
var R6MenuHelpWindow m_pHelpWindow;  // the help window (tooltip)
var R6FileManagerCampaign m_pFileManager;
var R6WindowSimpleFramedWindow m_CampaignDescription;
var R6WindowButton m_pButResumeCampaign;
var R6WindowButton m_pButNewCampaign;
var R6WindowButton m_pButDelCampaign;
var R6WindowButton m_pButCurrent;
var Font m_LeftButtonFont;
var Font m_LeftDownSizeFont;
var Color m_HelpTextColor;
var string m_ButtonStartText[2];
var string m_ButtonStartHelpText[2];

function Created()
{
	local Font ButtonFont;
	local UWindowWrappedTextArea localHelpZone;
	local int XPos;

	m_pFileManager = new Class'R6Game.R6FileManagerCampaign';
	ButtonFont = Root.Fonts[15];
	m_ButtonStartText[0] = Localize("CustomMission", "ButtonStart1", "R6Menu");
	m_ButtonStartText[1] = Localize("CustomMission", "ButtonStart2", "R6Menu");
	m_ButtonStartHelpText[0] = Localize("Tip", "ButtonStart", "R6Menu");
	m_ButtonStartHelpText[1] = Localize("Tip", "ButtonDelete", "R6Menu");
	m_HelpTextColor = Root.Colors.GrayLight;
	m_pHelpWindow = R6MenuHelpWindow(CreateWindow(Class'R6Menu.R6MenuHelpWindow', 150.0000000, 429.0000000, 340.0000000, 42.0000000, self));
	m_ButtonMainMenu = R6WindowButton(CreateControl(Class'R6Window.R6WindowButton', 10.0000000, 421.0000000, 250.0000000, 25.0000000, self));
	m_ButtonMainMenu.ToolTipString = Localize("Tip", "ButtonMainMenu", "R6Menu");
	m_ButtonMainMenu.Text = Localize("SinglePlayer", "ButtonMainMenu", "R6Menu");
	m_ButtonMainMenu.Align = 0;
	m_ButtonMainMenu.m_buttonFont = ButtonFont;
	m_ButtonMainMenu.ResizeToText();
	m_ButtonOptions = R6WindowButton(CreateControl(Class'R6Window.R6WindowButton', 10.0000000, 452.0000000, 250.0000000, 25.0000000, self));
	m_ButtonOptions.ToolTipString = Localize("Tip", "ButtonOptions", "R6Menu");
	m_ButtonOptions.Text = Localize("SinglePlayer", "ButtonOptions", "R6Menu");
	m_ButtonOptions.Align = 0;
	m_ButtonOptions.m_buttonFont = ButtonFont;
	m_ButtonOptions.ResizeToText();
	XPos = int((m_pHelpWindow.WinLeft + m_pHelpWindow.WinWidth));
	m_ButtonStart = R6WindowButton(CreateControl(Class'R6Window.R6WindowButton', float(XPos), 452.0000000, ((WinWidth - float(XPos)) - float(20)), 25.0000000, self));
	m_ButtonStart.ToolTipString = m_ButtonStartHelpText[0];
	m_ButtonStart.Text = m_ButtonStartText[0];
	m_ButtonStart.Align = 1;
	m_ButtonStart.m_buttonFont = ButtonFont;
	m_ButtonStart.ResizeToText();
	m_ButtonStart.m_iButtonID = int(3);
	m_ButtonStart.m_bWaitSoundFinish = true;
	m_Map = R6WindowSimpleFramedWindow(CreateWindow(Class'R6Window.R6WindowSimpleFramedWindow', 390.0000000, 268.0000000, 230.0000000, 130.0000000, self));
	m_Map.CreateClientWindow(Class'R6Window.R6WindowBitMap');
	m_Map.m_eCornerType = 3;
	m_Map.HideWindow();
	m_LMenuTitle = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', 0.0000000, 18.0000000, (WinWidth - float(8)), 25.0000000, self));
	m_LMenuTitle.Text = Localize("SinglePlayer", "Title", "R6Menu");
	m_LMenuTitle.Align = 1;
	m_LMenuTitle.m_Font = Root.Fonts[4];
	m_LMenuTitle.TextColor = Root.Colors.White;
	m_LMenuTitle.m_BGTexture = none;
	m_LMenuTitle.m_bDrawBorders = false;
	m_CampaignSelect = R6MenuSinglePlayerCampaignSelect(CreateWindow(Class'R6Menu.R6MenuSinglePlayerCampaignSelect', 198.0000000, 72.0000000, 156.0000000, 327.0000000, self));
	m_CampaignSelect.HideWindow();
	m_CampaignCreate = R6WindowSimpleCurvedFramedWindow(CreateWindow(Class'R6Window.R6WindowSimpleCurvedFramedWindow', m_CampaignSelect.WinLeft, m_CampaignSelect.WinTop, m_CampaignSelect.WinWidth, 326.0000000, self));
	m_CampaignCreate.CreateClientWindow(Class'R6Menu.R6MenuSinglePlayerCampaignCreate');
	m_CampaignCreate.m_Title = Localize("SinglePlayer", "TitleCampaign", "R6Menu");
	m_CampaignCreate.m_TitleAlign = 2;
	m_CampaignCreate.m_Font = Root.Fonts[8];
	m_CampaignCreate.m_TextColor = Root.Colors.White;
	m_CampaignCreate.SetCornerType(3);
	m_CampaignDescription = R6WindowSimpleFramedWindow(CreateWindow(Class'R6Window.R6WindowSimpleFramedWindow', m_Map.WinLeft, m_CampaignSelect.WinTop, m_Map.WinWidth, 122.0000000, self));
	m_CampaignDescription.CreateClientWindow(Class'R6Menu.R6MenuCampaignDescription');
	m_CampaignDescription.SetCornerType(3);
	return;
}

function ShowWindow()
{
	super(UWindowWindow).ShowWindow();
	m_CampaignSelect.RefreshListBox();
	// End:0x51
	if((m_CampaignSelect.m_CampaignListBox.Items.Count() == 0))
	{
		switchWidget(1);
		SetCurrentBut(int(1));		
	}
	else
	{
		m_iSelectedButtonID = int(1);
		ButtonClicked(int(0));
	}
	return;
}

function HideWindow()
{
	super(UWindowWindow).HideWindow();
	m_CampaignSelect.m_CampaignListBox.Clear();
	return;
}

//=================================================================================
// Changing the poping window
//=================================================================================
function switchWidget(R6MenuSinglePlayerWidget.eWidgetID newWidget)
{
	switch(newWidget)
	{
		// End:0x4B
		case 0:
			m_CampaignCreate.HideWindow();
			m_CampaignSelect.ShowWindow();
			m_CampaignDescription.ShowWindow();
			m_Map.ShowWindow();
			// End:0xF4
			break;
		// End:0xF1
		case 1:
			m_CampaignSelect.HideWindow();
			m_CampaignCreate.ShowWindow();
			R6MenuSinglePlayerCampaignCreate(m_CampaignCreate.m_ClientArea).Reset();
			m_ButtonStart.ToolTipString = m_ButtonStartHelpText[0];
			m_ButtonStart.Text = m_ButtonStartText[0];
			m_ButtonStart.ResizeToText();
			m_iSelectedButtonID = int(1);
			m_CampaignDescription.HideWindow();
			m_Map.HideWindow();
			// End:0xF4
			break;
		// End:0xFFFF
		default:
			break;
	}
	return;
}

//=================================================================================
// Button clicked
//=================================================================================
function ButtonClicked(int ButtonID)
{
	// End:0x2B4
	if((ButtonID != m_iSelectedButtonID))
	{
		switch(ButtonID)
		{
			// End:0xA6
			case int(0):
				// End:0x47
				if((m_CampaignSelect.m_CampaignListBox.Items.Count() == 0))
				{
					// [Explicit Continue]
					goto J0x2A9;
				}
				// End:0x5D
				if((m_iSelectedButtonID == int(1)))
				{
					switchWidget(0);
				}
				m_ButtonStart.ToolTipString = m_ButtonStartHelpText[0];
				m_ButtonStart.Text = m_ButtonStartText[0];
				m_ButtonStart.ResizeToText();
				m_iSelectedButtonID = ButtonID;
				// End:0x2A9
				break;
			// End:0xB8
			case int(1):
				switchWidget(1);
				// End:0x2A9
				break;
			// End:0x148
			case int(2):
				// End:0xE9
				if((m_CampaignSelect.m_CampaignListBox.Items.Count() == 0))
				{
					// [Explicit Continue]
					goto J0x2A9;
				}
				// End:0xFF
				if((m_iSelectedButtonID == int(1)))
				{
					switchWidget(0);
				}
				m_ButtonStart.ToolTipString = m_ButtonStartHelpText[1];
				m_ButtonStart.Text = m_ButtonStartText[1];
				m_ButtonStart.ResizeToText();
				m_iSelectedButtonID = ButtonID;
				// End:0x2A9
				break;
			// End:0x2A6
			case int(3):
				switch(m_iSelectedButtonID)
				{
					// End:0x192
					case int(0):
						// End:0x18F
						if(m_CampaignSelect.SetupCampaign())
						{
							Root.ResetMenus();
							Root.ChangeCurrentWidget(6);
						}
						// End:0x2A3
						break;
					// End:0x214
					case int(1):
						// End:0x20B
						if(CampaignExists())
						{
							R6MenuRootWindow(Root).SimplePopUp(Localize("POPUP", "CAMPAIGNEXISTTITLE", "R6Menu"), Localize("POPUP", "CAMPAIGNEXISTMSG", "R6Menu"), 43);							
						}
						else
						{
							TryCreatingCampaign();
						}
						// End:0x2A3
						break;
					// End:0x2A0
					case int(2):
						// End:0x29D
						if((m_CampaignSelect.m_CampaignListBox.m_SelectedItem != none))
						{
							R6MenuRootWindow(Root).SimplePopUp(Localize("SinglePlayer", "ButtonDelete", "R6Menu"), Localize("POPUP", "DELETECAMPAIGN", "R6Menu"), 42);
						}
						// End:0x2A3
						break;
					// End:0xFFFF
					default:
						break;
				}
				// End:0x2A9
				break;
			// End:0xFFFF
			default:
				break;
		}
		J0x2A9:

		SetCurrentBut(m_iSelectedButtonID);
	}
	return;
}

function bool CampaignExists()
{
	local string temp, szDir;
	local R6MenuSinglePlayerCampaignCreate R6PCC;

	R6PCC = R6MenuSinglePlayerCampaignCreate(m_CampaignCreate.m_ClientArea);
	szDir = Class'Engine.Actor'.static.GetModMgr().GetCampaignDir();
	temp = ((szDir $ R6PCC.m_CampaignNameEdit.GetValue()) $ ".cmp");
	return m_pFileManager.FindFile(temp);
	return;
}

function TryCreatingCampaign()
{
	// End:0x40
	if(R6MenuSinglePlayerCampaignCreate(m_CampaignCreate.m_ClientArea).CreateCampaign())
	{
		Root.ResetMenus();
		Root.ChangeCurrentWidget(6);
	}
	return;
}

function DeleteCurrentSelectedCampaign()
{
	m_CampaignSelect.DeleteCampaign();
	// End:0x48
	if((m_CampaignSelect.m_CampaignListBox.Items.Count() == 0))
	{
		switchWidget(1);
		SetCurrentBut(int(1));
	}
	return;
}

//Updates text for the current selected Campaign
function UpdateSelectedCampaign(R6PlayerCampaign _PlayerCampaign)
{
	local R6MenuCampaignDescription tempVar;
	local R6Campaign CampaignType;
	local R6MissionDescription CurrentMission;
	local R6WindowBitMap mapBitmap;

	tempVar = R6MenuCampaignDescription(m_CampaignDescription.m_ClientArea);
	mapBitmap = R6WindowBitMap(m_Map.m_ClientArea);
	// End:0x9D
	if((_PlayerCampaign == none))
	{
		tempVar.m_MissionValue.Text = "";
		tempVar.m_NameValue.Text = "";
		tempVar.m_DifficultyValue.Text = "";
		mapBitmap.t = none;
		return;
	}
	CampaignType = new (none) Class'R6Game.R6Campaign';
	CampaignType.InitCampaign(GetLevel(), _PlayerCampaign.m_CampaignFileName, R6Console(Root.Console));
	CurrentMission = CampaignType.m_missions[_PlayerCampaign.m_iNoMission];
	tempVar.m_MissionValue.SetNewText(string((_PlayerCampaign.m_iNoMission + 1)), true);
	tempVar.m_NameValue.SetNewText(Localize(CurrentMission.m_MapName, "ID_CODENAME", CurrentMission.LocalizationFile), true);
	tempVar.m_DifficultyValue.SetNewText(Localize("SinglePlayer", ("Difficulty" $ string(_PlayerCampaign.m_iDifficultyLevel)), "R6Menu"), true);
	mapBitmap.R = CurrentMission.m_RMissionOverview;
	mapBitmap.t = CurrentMission.m_TMissionOverview;
	return;
}

function KeyDown(int Key, float X, float Y)
{
	super.KeyDown(Key, X, Y);
	// End:0x3F
	if((Key == int(Root.Console.13)))
	{
		ButtonClicked(int(3));
	}
	return;
}

function Notify(UWindowDialogControl C, byte E)
{
	// End:0x7C
	if((int(E) == 2))
	{
		switch(C)
		{
			// End:0x31
			case m_ButtonMainMenu:
				Root.ChangeCurrentWidget(7);
				// End:0x7C
				break;
			// End:0x4D
			case m_ButtonOptions:
				Root.ChangeCurrentWidget(16);
				// End:0x7C
				break;
			// End:0xFFFF
			default:
				// End:0x79
				if((R6WindowButton(C) != none))
				{
					ButtonClicked(R6WindowButton(C).m_iButtonID);
				}
				// End:0x7C
				break;
				break;
		}
	}
	return;
}

//=================================================================================
// Setup Help Text
//=================================================================================
function ToolTip(string strTip)
{
	m_pHelpWindow.ToolTip(strTip);
	return;
}

function Paint(Canvas C, float X, float Y)
{
	Root.PaintBackground(C, self);
	return;
}

function CreateButtons()
{
	local float fXOffset, fYOffset, fWidth, fHeight, fYPos;

	fXOffset = 10.0000000;
	fYPos = 64.0000000;
	fYOffset = 26.0000000;
	fWidth = 200.0000000;
	fHeight = 25.0000000;
	m_pButResumeCampaign = R6WindowButton(CreateControl(Class'R6Window.R6WindowButton', fXOffset, fYPos, fWidth, fHeight, self));
	m_pButResumeCampaign.ToolTipString = Localize("Tip", "ButtonResumeCampaign", "R6Menu");
	m_pButResumeCampaign.Text = Localize("SinglePlayer", "ButtonResume", "R6Menu");
	m_pButResumeCampaign.m_iButtonID = int(0);
	m_pButResumeCampaign.Align = 0;
	m_pButResumeCampaign.m_buttonFont = m_LeftButtonFont;
	m_pButResumeCampaign.CheckToDownSizeFont(m_LeftDownSizeFont, 0.0000000);
	m_pButResumeCampaign.ResizeToText();
	m_pButResumeCampaign.m_bSelected = true;
	(fYPos += fYOffset);
	m_pButNewCampaign = R6WindowButton(CreateControl(Class'R6Window.R6WindowButton', fXOffset, fYPos, fWidth, fHeight, self));
	m_pButNewCampaign.ToolTipString = Localize("Tip", "ButtonNewCampaign", "R6Menu");
	m_pButNewCampaign.Text = Localize("SinglePlayer", "ButtonNew", "R6Menu");
	m_pButNewCampaign.m_iButtonID = int(1);
	m_pButNewCampaign.Align = 0;
	m_pButNewCampaign.m_buttonFont = m_LeftButtonFont;
	m_pButNewCampaign.CheckToDownSizeFont(m_LeftDownSizeFont, 0.0000000);
	m_pButNewCampaign.ResizeToText();
	(fYPos += fYOffset);
	m_pButDelCampaign = R6WindowButton(CreateControl(Class'R6Window.R6WindowButton', fXOffset, fYPos, fWidth, fHeight, self));
	m_pButDelCampaign.ToolTipString = Localize("Tip", "ButtonDeleteCampaign", "R6Menu");
	m_pButDelCampaign.Text = Localize("SinglePlayer", "ButtonDelete", "R6Menu");
	m_pButDelCampaign.m_iButtonID = int(2);
	m_pButDelCampaign.Align = 0;
	m_pButDelCampaign.m_buttonFont = m_LeftButtonFont;
	m_pButDelCampaign.CheckToDownSizeFont(m_LeftDownSizeFont, 0.0000000);
	m_pButDelCampaign.ResizeToText();
	m_pButCurrent = m_pButResumeCampaign;
	return;
}

function bool ButtonsUsingDownSizeFont()
{
	local bool Result;

	// End:0x42
	if(((m_pButResumeCampaign.IsFontDownSizingNeeded() || m_pButNewCampaign.IsFontDownSizingNeeded()) || m_pButDelCampaign.IsFontDownSizingNeeded()))
	{
		Result = true;
	}
	return Result;
	return;
}

function ForceFontDownSizing()
{
	m_pButResumeCampaign.m_buttonFont = m_LeftDownSizeFont;
	m_pButNewCampaign.m_buttonFont = m_LeftDownSizeFont;
	m_pButDelCampaign.m_buttonFont = m_LeftDownSizeFont;
	m_pButResumeCampaign.ResizeToText();
	m_pButNewCampaign.ResizeToText();
	m_pButDelCampaign.ResizeToText();
	return;
}

function SetCurrentBut(int _iNewCurBut)
{
	m_pButCurrent.m_bSelected = false;
	m_iSelectedButtonID = _iNewCurBut;
	switch(_iNewCurBut)
	{
		// End:0x53
		case int(0):
			m_pButCurrent = m_pButResumeCampaign;
			Root.SetLoadRandomBackgroundImage("CampResume");
			// End:0xB3
			break;
		// End:0x80
		case int(1):
			m_pButCurrent = m_pButNewCampaign;
			Root.SetLoadRandomBackgroundImage("CampNew");
			// End:0xB3
			break;
		// End:0xB0
		case int(2):
			m_pButCurrent = m_pButDelCampaign;
			Root.SetLoadRandomBackgroundImage("CampResume");
			// End:0xB3
			break;
		// End:0xFFFF
		default:
			break;
	}
	m_pButCurrent.m_bSelected = true;
	return;
}


// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var s
// REMOVED IN 1.60: var t
