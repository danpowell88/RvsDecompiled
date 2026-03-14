//=============================================================================
// R6MenuCustomMissionWidget - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6MenuCustomMissionWidget.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/11/22 * Created by Alexandre Dionne
//=============================================================================
class R6MenuCustomMissionWidget extends R6MenuWidget
 config(User);

var config int CustomMissionGameType;
var bool bShowLog;
var R6WindowButton m_ButtonStart;
var R6WindowButton m_ButtonMainMenu;
var R6WindowButton m_ButtonOptions;
var R6WindowSimpleFramedWindow m_Map;
var R6WindowTextLabel m_LMenuTitle;
var R6WindowTextLabelCurved m_LGameLevelTitle;
var R6WindowTextListBox m_GameLevelBox;
var R6WindowSimpleCurvedFramedWindow m_DifficultyArea;
var R6FileManagerCampaign m_pFileManager;
var R6MenuHelpWindow m_pHelpWindow;  // the help window (tooltip)
var R6WindowButton m_pButPraticeMission;
var R6WindowButton m_pButLoneWolf;
var R6WindowButton m_pButTerroHunt;
var R6WindowButton m_pButHostageRescue;
var R6WindowButton m_pButCurrent;
var R6WindowSimpleFramedWindow m_TerroArea;
var Font m_LeftButtonFont;
var Font m_LeftDownSizeFont;
var Color m_TitleTextColor;
//To update when we come back from a custom menu game
var string m_LastMapPlayed;
var config string CustomMissionMap;

function Created()
{
	local Font ButtonFont;
	local Color co, TitleTextColor;
	local int iFiles, i;
	local string szFileName;
	local bool bInTab;
	local R6WindowListBoxItem NewItem;
	local R6MenuRootWindow r6Root;
	local int XPos;

	r6Root = R6MenuRootWindow(Root);
	ButtonFont = Root.Fonts[16];
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
	XPos = int(__NFUN_174__(m_pHelpWindow.WinLeft, m_pHelpWindow.WinWidth));
	m_ButtonStart = R6WindowButton(CreateControl(Class'R6Window.R6WindowButton', float(XPos), 452.0000000, __NFUN_175__(__NFUN_175__(WinWidth, float(XPos)), float(20)), 25.0000000, self));
	m_ButtonStart.ToolTipString = Localize("Tip", "ButtonStart", "R6Menu");
	m_ButtonStart.Text = Localize("CustomMission", "ButtonStart1", "R6Menu");
	m_ButtonStart.Align = 1;
	m_ButtonStart.m_buttonFont = ButtonFont;
	m_ButtonStart.ResizeToText();
	m_ButtonStart.m_bWaitSoundFinish = true;
	m_Map = R6WindowSimpleFramedWindow(CreateWindow(Class'R6Window.R6WindowSimpleFramedWindow', 390.0000000, 268.0000000, 230.0000000, 130.0000000, self));
	m_Map.CreateClientWindow(Class'R6Window.R6WindowBitMap');
	m_Map.m_eCornerType = 3;
	m_TitleTextColor = Root.Colors.White;
	m_LMenuTitle = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', 0.0000000, 18.0000000, __NFUN_175__(WinWidth, float(8)), 25.0000000, self));
	m_LMenuTitle.Text = Localize("CustomMission", "Title", "R6Menu");
	m_LMenuTitle.Align = 1;
	m_LMenuTitle.m_Font = Root.Fonts[4];
	m_LMenuTitle.TextColor = m_TitleTextColor;
	m_LMenuTitle.m_BGTexture = none;
	m_LMenuTitle.m_bDrawBorders = false;
	m_GameLevelBox = R6WindowTextListBox(CreateControl(Class'R6Window.R6WindowTextListBox', 198.0000000, 102.0000000, 156.0000000, 296.0000000, self));
	m_GameLevelBox.ListClass = Class'R6Window.R6WindowListBoxItem';
	m_GameLevelBox.SetCornerType(3);
	m_GameLevelBox.ToolTipString = Localize("Tip", "CustomMListBox", "R6Menu");
	m_LGameLevelTitle = R6WindowTextLabelCurved(CreateWindow(Class'R6Window.R6WindowTextLabelCurved', 198.0000000, 72.0000000, 156.0000000, 31.0000000, self));
	m_LGameLevelTitle.Text = Localize("CustomMission", "TitleGameLevel", "R6Menu");
	m_LGameLevelTitle.Align = 2;
	m_LGameLevelTitle.m_Font = Root.Fonts[8];
	m_LGameLevelTitle.TextColor = m_TitleTextColor;
	m_DifficultyArea = R6WindowSimpleCurvedFramedWindow(CreateWindow(Class'R6Window.R6WindowSimpleCurvedFramedWindow', 390.0000000, 72.0000000, m_Map.WinWidth, 122.0000000, self));
	m_DifficultyArea.CreateClientWindow(Class'R6Menu.R6MenuDiffCustomMissionSelect');
	m_DifficultyArea.m_Title = Localize("SinglePlayer", "Difficulty", "R6Menu");
	m_DifficultyArea.m_TitleAlign = 2;
	m_DifficultyArea.m_Font = Root.Fonts[8];
	m_DifficultyArea.m_TextColor = m_TitleTextColor;
	m_DifficultyArea.m_BorderColor = Root.Colors.White;
	m_DifficultyArea.SetCornerType(3);
	m_TerroArea = R6WindowSimpleFramedWindow(CreateWindow(Class'R6Window.R6WindowSimpleFramedWindow', 390.0000000, __NFUN_175__(__NFUN_174__(m_DifficultyArea.WinTop, m_DifficultyArea.WinHeight), float(1)), m_DifficultyArea.WinWidth, 63.0000000, self));
	m_TerroArea.CreateClientWindow(Class'R6Menu.R6MenuCustomMissionNbTerroSelect');
	m_TerroArea.SetCornerType(2);
	m_TerroArea.HideWindow();
	// End:0x723
	if(__NFUN_114__(r6Root.m_pFileManager, none))
	{
		__NFUN_231__("R6MenuRootWindow(Root).m_pFileManager == NONE");
	}
	m_pFileManager = new Class'R6Game.R6FileManagerCampaign';
	InitCustomMission();
	return;
}

function bool ValidateBeforePlanning()
{
	local R6MenuRootWindow r6Root;

	r6Root = R6MenuRootWindow(Root);
	// End:0x50
	if(__NFUN_114__(r6Root, none))
	{
		// End:0x4E
		if(bShowLog)
		{
			__NFUN_231__("ValidateBeforePlanning: R6Root == None");
		}
		return false;
	}
	// End:0xB0
	if(__NFUN_114__(m_GameLevelBox.m_SelectedItem, none))
	{
		// End:0xAE
		if(bShowLog)
		{
			__NFUN_231__("ValidateBeforePlanning: m_GameLevelBox.m_SelectedItem == NONE");
		}
		return false;
	}
	// End:0x121
	if(__NFUN_122__(m_GameLevelBox.m_SelectedItem.HelpText, ""))
	{
		// End:0x11F
		if(bShowLog)
		{
			__NFUN_231__("ValidateBeforePlanning: m_GameLevelBox.m_SelectedItem.HelpText == \"\"");
		}
		return false;
	}
	r6Root.ResetCustomMissionOperatives();
	// End:0x17A
	if(__NFUN_152__(r6Root.m_GameOperatives.Length, 0))
	{
		// End:0x175
		if(bShowLog)
		{
			__NFUN_231__("R6Root.m_GameOperatives.Length <= 0");
		}
		return false;		
	}
	else
	{
		// End:0x1AA
		if(bShowLog)
		{
			__NFUN_231__("ValidateBeforePlanning: return true");
		}
		return true;
	}
	return;
}

function GotoPlanning()
{
	local R6MenuRootWindow r6Root;
	local R6MissionDescription CurrentMission;
	local R6WindowListBoxItem SelectedItem;
	local R6Console R6Console;

	r6Root = R6MenuRootWindow(Root);
	SelectedItem = R6WindowListBoxItem(m_GameLevelBox.m_SelectedItem);
	CurrentMission = R6MissionDescription(SelectedItem.m_Object);
	R6Console = R6Console(Root.Console);
	R6Console.Master.m_StartGameInfo.m_CurrentMission = CurrentMission;
	R6Console.Master.m_StartGameInfo.m_MapName = CurrentMission.m_MapName;
	R6Console.Master.m_StartGameInfo.m_DifficultyLevel = R6MenuDiffCustomMissionSelect(m_DifficultyArea.m_ClientArea).GetDifficulty();
	R6Console.Master.m_StartGameInfo.m_iNbTerro = R6MenuCustomMissionNbTerroSelect(m_TerroArea.m_ClientArea).GetNbTerro();
	R6Console.Master.m_StartGameInfo.m_GameMode = GetLevel().GetGameTypeClassName(GetLevel().__NFUN_1256__(m_pButCurrent.m_iButtonID));
	CustomMissionMap = CurrentMission.m_MapName;
	CustomMissionGameType = m_pButCurrent.m_iButtonID;
	__NFUN_536__();
	Root.ResetMenus();
	r6Root.m_bLoadingPlanning = true;
	R6Console.PreloadMapForPlanning();
	return;
}

function ShowWindow()
{
	RefreshList();
	super(UWindowWindow).ShowWindow();
	return;
}

function bool CampainMapExistInMapList(R6MissionDescription pMission)
{
	local int iMission;

	iMission = 0;
	J0x07:

	// End:0x66 [Loop If]
	if(__NFUN_150__(iMission, R6Console(Root.Console).m_aMissionDescriptions.Length))
	{
		// End:0x5C
		if(__NFUN_114__(pMission, R6Console(Root.Console).m_aMissionDescriptions[iMission]))
		{
			return true;
		}
		__NFUN_165__(iMission);
		// [Loop Continue]
		goto J0x07;
	}
	return false;
	return;
}

function RefreshList()
{
	local int i, iCampaign, iMission;
	local R6Console R6Console;
	local string szMapName;
	local R6WindowListBoxItem NewItem, ItemToSelect;
	local string szGameType;
	local R6MissionDescription mission;

	R6Console = R6Console(Root.Console);
	szGameType = GetLevel().__NFUN_1256__(m_pButCurrent.m_iButtonID);
	m_GameLevelBox.Clear();
	iCampaign = 0;
	J0x50:

	// End:0x218 [Loop If]
	if(__NFUN_150__(iCampaign, R6Console.m_aCampaigns.Length))
	{
		iMission = 0;
		J0x70:

		// End:0x20E [Loop If]
		if(__NFUN_150__(iMission, R6Console.m_aCampaigns[iCampaign].m_missions.Length))
		{
			mission = R6Console.m_aCampaigns[iCampaign].m_missions[iMission];
			// End:0x204
			if(__NFUN_130__(__NFUN_130__(mission.IsAvailableInGameType(szGameType), __NFUN_123__(mission.m_MapName, "")), CampainMapExistInMapList(mission)))
			{
				szMapName = Localize(mission.m_MapName, "ID_MENUNAME", mission.LocalizationFile, true);
				// End:0x155
				if(__NFUN_122__(szMapName, ""))
				{
					szMapName = mission.m_MapName;
				}
				NewItem = R6WindowListBoxItem(m_GameLevelBox.Items.Append(m_GameLevelBox.ListClass));
				NewItem.HelpText = szMapName;
				NewItem.m_Object = mission;
				// End:0x1D4
				if(mission.m_bIsLocked)
				{
					NewItem.m_bDisabled = true;
					// [Explicit Continue]
					goto J0x204;
				}
				// End:0x204
				if(__NFUN_130__(__NFUN_122__(mission.m_MapName, m_LastMapPlayed), __NFUN_114__(ItemToSelect, none)))
				{
					ItemToSelect = NewItem;
				}
			}
			J0x204:

			__NFUN_163__(iMission);
			// [Loop Continue]
			goto J0x70;
		}
		__NFUN_163__(iCampaign);
		// [Loop Continue]
		goto J0x50;
	}
	iMission = 0;
	J0x21F:

	// End:0x3A5 [Loop If]
	if(__NFUN_150__(iMission, R6Console.m_aMissionDescriptions.Length))
	{
		mission = R6Console.m_aMissionDescriptions[iMission];
		// End:0x39B
		if(__NFUN_130__(__NFUN_130__(__NFUN_129__(mission.m_bCampaignMission), mission.IsAvailableInGameType(szGameType)), __NFUN_123__(mission.m_MapName, "")))
		{
			szMapName = Localize(mission.m_MapName, "ID_MENUNAME", mission.LocalizationFile, true);
			// End:0x2EC
			if(__NFUN_122__(szMapName, ""))
			{
				szMapName = mission.m_MapName;
			}
			NewItem = R6WindowListBoxItem(m_GameLevelBox.Items.Append(m_GameLevelBox.ListClass));
			NewItem.HelpText = szMapName;
			NewItem.m_Object = mission;
			// End:0x36B
			if(mission.m_bIsLocked)
			{
				NewItem.m_bDisabled = true;
				// [Explicit Continue]
				goto J0x39B;
			}
			// End:0x39B
			if(__NFUN_130__(__NFUN_122__(mission.m_MapName, m_LastMapPlayed), __NFUN_114__(ItemToSelect, none)))
			{
				ItemToSelect = NewItem;
			}
		}
		J0x39B:

		__NFUN_163__(iMission);
		// [Loop Continue]
		goto J0x21F;
	}
	// End:0x41F
	if(__NFUN_151__(m_GameLevelBox.Items.Count(), 0))
	{
		// End:0x3E5
		if(__NFUN_119__(ItemToSelect, none))
		{
			m_GameLevelBox.SetSelectedItem(ItemToSelect);			
		}
		else
		{
			m_GameLevelBox.SetSelectedItem(R6WindowListBoxItem(m_GameLevelBox.Items.Next));
		}
		m_GameLevelBox.MakeSelectedVisible();
	}
	UpdateBackground();
	m_LastMapPlayed = "";
	return;
}

function InitCustomMission()
{
	local bool bCheckedRvSDir, bCheckCampaignMission;
	local string szDir;
	local int i, iFiles;
	local R6MenuRootWindow r6Root;
	local R6PlayerCampaign MyCampaign;
	local R6Console R6Console;

	r6Root = R6MenuRootWindow(Root);
	R6Console = R6Console(Root.Console);
	MyCampaign = new Class'R6Game.R6PlayerCampaign';
	bCheckedRvSDir = false;
	szDir = Class'Engine.Actor'.static.__NFUN_1524__().GetCampaignDir();
	J0x5C:

	// End:0x1D0 [Loop If]
	if(__NFUN_123__(szDir, ""))
	{
		iFiles = r6Root.m_pFileManager.__NFUN_1525__(szDir, "cmp");
		i = 0;
		J0x94:

		// End:0x175 [Loop If]
		if(__NFUN_150__(i, iFiles))
		{
			r6Root.m_pFileManager.__NFUN_1526__(i, MyCampaign.m_FileName);
			MyCampaign.m_FileName = __NFUN_128__(MyCampaign.m_FileName, __NFUN_126__(MyCampaign.m_FileName, "."));
			MyCampaign.m_OperativesMissionDetails = none;
			MyCampaign.m_OperativesMissionDetails = new (none) Class'R6Game.R6MissionRoster';
			m_pFileManager.__NFUN_1003__(MyCampaign);
			bCheckCampaignMission = false;
			// End:0x151
			if(__NFUN_154__(i, 0))
			{
				bCheckCampaignMission = true;
			}
			R6Console.UpdateCurrentMapAvailable(MyCampaign, bCheckCampaignMission);
			__NFUN_165__(i);
			// [Loop Continue]
			goto J0x94;
		}
		// End:0x1C5
		if(__NFUN_130__(__NFUN_242__(bCheckedRvSDir, false), __NFUN_129__(Class'Engine.Actor'.static.__NFUN_1524__().IsRavenShield())))
		{
			bCheckedRvSDir = true;
			szDir = Class'Engine.Actor'.static.__NFUN_1524__().GetDefaultCampaignDir();			
		}
		else
		{
			szDir = "";
		}
		// [Loop Continue]
		goto J0x5C;
	}
	m_LastMapPlayed = CustomMissionMap;
	R6Console.UnlockMissions();
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

//=================================================================================
// UpdateBackground: update background
//=================================================================================
function UpdateBackground()
{
	// End:0x6E
	if(GetLevel().GameTypeUseNbOfTerroristToSpawn(GetLevel().__NFUN_1256__(m_pButCurrent.m_iButtonID)))
	{
		m_DifficultyArea.SetCornerType(1);
		m_TerroArea.ShowWindow();
		Root.SetLoadRandomBackgroundImage("OtherMission");		
	}
	else
	{
		m_DifficultyArea.SetCornerType(3);
		m_TerroArea.HideWindow();
		Root.SetLoadRandomBackgroundImage("PracticeMission");
	}
	return;
}

function Paint(Canvas C, float X, float Y)
{
	Root.PaintBackground(C, self);
	return;
}

function Notify(UWindowDialogControl C, byte E)
{
	local R6WindowListBoxItem SelectedItem;
	local R6MissionDescription CurrentMission;
	local R6WindowBitMap mapBitmap;

	// End:0x1AB
	if(__NFUN_154__(int(E), 2))
	{
		switch(C)
		{
			// End:0x31
			case m_ButtonMainMenu:
				Root.ChangeCurrentWidget(7);
				// End:0x1A8
				break;
			// End:0x4D
			case m_ButtonOptions:
				Root.ChangeCurrentWidget(16);
				// End:0x1A8
				break;
			// End:0x67
			case m_ButtonStart:
				// End:0x64
				if(ValidateBeforePlanning())
				{
					GotoPlanning();
				}
				// End:0x1A8
				break;
			// End:0x6F
			case m_pButPraticeMission:
			// End:0x77
			case m_pButLoneWolf:
			// End:0x7F
			case m_pButTerroHunt:
			// End:0x87
			case m_pButHostageRescue:
			// End:0xCF
			case m_pButCurrent:
				m_pButCurrent.m_bSelected = false;
				R6WindowButton(C).m_bSelected = true;
				m_pButCurrent = R6WindowButton(C);
				RefreshList();
				// End:0x1A8
				break;
			// End:0x1A2
			case m_GameLevelBox:
				mapBitmap = R6WindowBitMap(m_Map.m_ClientArea);
				SelectedItem = R6WindowListBoxItem(m_GameLevelBox.m_SelectedItem);
				// End:0x127
				if(__NFUN_114__(SelectedItem, none))
				{
					mapBitmap.t = none;
					// [Explicit Continue]
					goto J0x1A8;
				}
				// End:0x13E
				if(__NFUN_114__(SelectedItem.m_Object, none))
				{
					// [Explicit Continue]
					goto J0x1A8;
				}
				CurrentMission = R6MissionDescription(SelectedItem.m_Object);
				// End:0x165
				if(__NFUN_114__(CurrentMission, none))
				{
					// [Explicit Continue]
					goto J0x1A8;
				}
				mapBitmap.R = CurrentMission.m_RMissionOverview;
				mapBitmap.t = CurrentMission.m_TMissionOverview;
				// End:0x1A8
				break;
			// End:0xFFFF
			default:
				// End:0x1A8
				break;
				break;
		}
		J0x1A8:
		
	}
	else
	{
		// End:0x1D7
		if(__NFUN_154__(int(E), 11))
		{
			// End:0x1D7
			if(__NFUN_114__(C, m_GameLevelBox))
			{
				// End:0x1D7
				if(ValidateBeforePlanning())
				{
					GotoPlanning();
				}
			}
		}
	}
	return;
}

function CreateButtons()
{
	local float fXOffset, fYOffset, fWidth, fHeight, fYPos;

	fXOffset = 10.0000000;
	fYOffset = 26.0000000;
	fWidth = 200.0000000;
	fHeight = 25.0000000;
	fYPos = 64.0000000;
	m_pButPraticeMission = R6WindowButton(CreateControl(Class'R6Window.R6WindowButton', fXOffset, fYPos, fWidth, fHeight, self));
	m_pButPraticeMission.ToolTipString = Localize("Tip", "GameType_Practice", "R6Menu");
	m_pButPraticeMission.Text = Localize("CustomMission", "ButtonPractice", "R6Menu");
	m_pButPraticeMission.m_iButtonID = GetLevel().__NFUN_2015__("RGM_PracticeMode");
	m_pButPraticeMission.Align = 0;
	m_pButPraticeMission.m_buttonFont = m_LeftButtonFont;
	m_pButPraticeMission.CheckToDownSizeFont(m_LeftDownSizeFont, 0.0000000);
	m_pButPraticeMission.ResizeToText();
	__NFUN_184__(fYPos, fYOffset);
	m_pButLoneWolf = R6WindowButton(CreateControl(Class'R6Window.R6WindowButton', fXOffset, fYPos, fWidth, fHeight, self));
	m_pButLoneWolf.ToolTipString = Localize("Tip", "GameType_LoneWolf", "R6Menu");
	m_pButLoneWolf.Text = Localize("CustomMission", "ButtonLoneWolf", "R6Menu");
	m_pButLoneWolf.m_iButtonID = GetLevel().__NFUN_2015__("RGM_LoneWolfMode");
	m_pButLoneWolf.Align = 0;
	m_pButLoneWolf.m_buttonFont = m_LeftButtonFont;
	m_pButLoneWolf.CheckToDownSizeFont(m_LeftDownSizeFont, 0.0000000);
	m_pButLoneWolf.ResizeToText();
	__NFUN_184__(fYPos, fYOffset);
	m_pButTerroHunt = R6WindowButton(CreateControl(Class'R6Window.R6WindowButton', fXOffset, fYPos, fWidth, fHeight, self));
	m_pButTerroHunt.ToolTipString = Localize("Tip", "GameType_TerroristHunt", "R6Menu");
	m_pButTerroHunt.Text = Localize("CustomMission", "ButtonTerroHunt", "R6Menu");
	m_pButTerroHunt.m_iButtonID = GetLevel().__NFUN_2015__("RGM_TerroristHuntMode");
	m_pButTerroHunt.Align = 0;
	m_pButTerroHunt.m_buttonFont = m_LeftButtonFont;
	m_pButTerroHunt.CheckToDownSizeFont(m_LeftDownSizeFont, 0.0000000);
	m_pButTerroHunt.ResizeToText();
	__NFUN_184__(fYPos, fYOffset);
	m_pButHostageRescue = R6WindowButton(CreateControl(Class'R6Window.R6WindowButton', fXOffset, fYPos, fWidth, fHeight, self));
	m_pButHostageRescue.ToolTipString = Localize("Tip", "GameType_HostageRescue", "R6Menu");
	m_pButHostageRescue.Text = Localize("CustomMission", "ButtonHostageRescue", "R6Menu");
	m_pButHostageRescue.m_iButtonID = GetLevel().__NFUN_2015__("RGM_HostageRescueMode");
	m_pButHostageRescue.Align = 0;
	m_pButHostageRescue.m_buttonFont = m_LeftButtonFont;
	m_pButHostageRescue.CheckToDownSizeFont(m_LeftDownSizeFont, 0.0000000);
	m_pButHostageRescue.ResizeToText();
	switch(CustomMissionGameType)
	{
		// End:0x4F7
		case m_pButPraticeMission.m_iButtonID:
			m_pButCurrent = m_pButPraticeMission;
			// End:0x562
			break;
		// End:0x516
		case m_pButLoneWolf.m_iButtonID:
			m_pButCurrent = m_pButLoneWolf;
			// End:0x562
			break;
		// End:0x535
		case m_pButTerroHunt.m_iButtonID:
			m_pButCurrent = m_pButTerroHunt;
			// End:0x562
			break;
		// End:0x554
		case m_pButHostageRescue.m_iButtonID:
			m_pButCurrent = m_pButHostageRescue;
			// End:0x562
			break;
		// End:0xFFFF
		default:
			m_pButCurrent = m_pButPraticeMission;
			break;
	}
	m_pButCurrent.m_bSelected = true;
	return;
}

function bool ButtonsUsingDownSizeFont()
{
	local bool Result;

	// End:0x56
	if(__NFUN_132__(__NFUN_132__(__NFUN_132__(m_pButPraticeMission.IsFontDownSizingNeeded(), m_pButLoneWolf.IsFontDownSizingNeeded()), m_pButTerroHunt.IsFontDownSizingNeeded()), m_pButHostageRescue.IsFontDownSizingNeeded()))
	{
		Result = true;
	}
	return Result;
	return;
}

function ForceFontDownSizing()
{
	m_pButPraticeMission.m_buttonFont = m_LeftDownSizeFont;
	m_pButLoneWolf.m_buttonFont = m_LeftDownSizeFont;
	m_pButTerroHunt.m_buttonFont = m_LeftDownSizeFont;
	m_pButHostageRescue.m_buttonFont = m_LeftDownSizeFont;
	m_pButPraticeMission.ResizeToText();
	m_pButLoneWolf.ResizeToText();
	m_pButTerroHunt.ResizeToText();
	m_pButHostageRescue.ResizeToText();
	return;
}

defaultproperties
{
	CustomMissionGameType=2
	CustomMissionMap="Oil_Refinery"
}
