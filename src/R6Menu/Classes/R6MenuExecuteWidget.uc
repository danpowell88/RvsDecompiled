//=============================================================================
// R6MenuExecuteWidget - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6MenuExecuteWidget.uc : This widget is the last one in the planning phase
//                            this widget allows the player to choose the team
//                            he will play in and has a last glance at team copositions
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/06/12 * Created by Alexandre Dionne
//=============================================================================
class R6MenuExecuteWidget extends R6MenuLaptopWidget;

//Mission Objectives and map dimensions 
var float m_fObjWidth;
// NEW IN 1.60
var float m_fObjHeight;
// NEW IN 1.60
var float m_fMapWidth;
var float m_fTeamSummaryWidth;
// NEW IN 1.60
var float m_fTeamSummaryYPadding;
// NEW IN 1.60
var float m_fTeamSummaryXPadding;
// NEW IN 1.60
var float m_fTeamSummaryMaxHeight;
//Buttons coordinates
var float m_fGoPlanningButtonX;
// NEW IN 1.60
var float m_fGoGameButtonX;
// NEW IN 1.60
var float m_fObserverButtonX;
// NEW IN 1.60
var float m_fButtonHeight;
// NEW IN 1.60
var float m_fButtonAreaY;
// NEW IN 1.60
var float m_fButtonY;
//Top Labels showing location of the current mission
var R6WindowTextLabel m_CodeName;
// NEW IN 1.60
var R6WindowTextLabel m_DateTime;
// NEW IN 1.60
var R6WindowTextLabel m_Location;
//Missions Objectives for the current Mission
var R6WindowWrappedTextArea m_MissionObjectives;
//Small world map top right 
var R6WindowBitMap m_SmallMap;
var R6WindowTeamSummary m_RedSummary;
// NEW IN 1.60
var R6WindowTeamSummary m_GreenSummary;
// NEW IN 1.60
var R6WindowTeamSummary m_GoldSummary;
var R6WindowButton m_RedSummaryButton;
// NEW IN 1.60
var R6WindowButton m_GreenSummaryButton;
// NEW IN 1.60
var R6WindowButton m_GoldSummaryButton;
/////////////////////////////////////////////////////////////////////////
//                           Bottom Buttons
/////////////////////////////////////////////////////////////////////////
var R6WindowButton m_GoPlanningButton;
// NEW IN 1.60
var R6WindowButton m_GoGameButton;
// NEW IN 1.60
var R6WindowButton m_ObserverButton;
var Texture m_TObserverButton;
// NEW IN 1.60
var Texture m_TGoPlanningButton;
// NEW IN 1.60
var Texture m_TGoGameButton;
var Region m_RGoPlanningButtonUp;
// NEW IN 1.60
var Region m_RGoPlanningButtonDown;
// NEW IN 1.60
var Region m_RGoPlanningButtonOver;
// NEW IN 1.60
var Region m_RGoPlanningButtonDisabled;
var Region m_RGoGameButtonUp;
// NEW IN 1.60
var Region m_RGoGameButtonDown;
// NEW IN 1.60
var Region m_RGoGameButtonOver;
// NEW IN 1.60
var Region m_RGoGameButtonDisabled;
var Region m_RObserverButtonUp;
// NEW IN 1.60
var Region m_RObserverButtonDown;
// NEW IN 1.60
var Region m_RObserverButtonOver;
// NEW IN 1.60
var Region m_RObserverButtonDisabled;

function Created()
{
	local float labelWidth, fTeamSummaryYPos;

	super.Created();
	labelWidth = float((int((m_Right.WinLeft - m_Left.WinWidth)) / 3));
	m_CodeName = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', m_Left.WinWidth, m_Top.WinHeight, labelWidth, 18.0000000, self));
	m_DateTime = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', (m_CodeName.WinLeft + m_CodeName.WinWidth), m_Top.WinHeight, labelWidth, 18.0000000, self));
	m_Location = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', (m_DateTime.WinLeft + m_DateTime.WinWidth), m_Top.WinHeight, m_DateTime.WinWidth, 18.0000000, self));
	m_MissionObjectives = R6WindowWrappedTextArea(CreateWindow(Class'R6Window.R6WindowWrappedTextArea', (m_Left.WinWidth + m_fLaptopPadding), (m_Location.WinTop + m_Location.WinHeight), m_fObjWidth, m_fObjHeight, self));
	m_MissionObjectives.m_BorderColor = Root.Colors.GrayLight;
	m_MissionObjectives.SetScrollable(true);
	m_MissionObjectives.VertSB.SetBorderColor(Root.Colors.GrayLight);
	m_MissionObjectives.VertSB.SetHideWhenDisable(true);
	m_MissionObjectives.VertSB.SetEffect(true);
	m_MissionObjectives.m_BorderStyle = int(1);
	m_MissionObjectives.VertSB.m_BorderStyle = int(1);
	m_MissionObjectives.m_bUseBGTexture = true;
	m_MissionObjectives.m_BGTexture = Texture'UWindow.WhiteTexture';
	m_MissionObjectives.m_BGRegion.X = 0;
	m_MissionObjectives.m_BGRegion.Y = 0;
	m_MissionObjectives.m_BGRegion.W = m_MissionObjectives.m_BGTexture.USize;
	m_MissionObjectives.m_BGRegion.H = m_MissionObjectives.m_BGTexture.VSize;
	m_MissionObjectives.m_bUseBGColor = true;
	m_MissionObjectives.m_BGColor = Root.Colors.Black;
	m_MissionObjectives.m_BGColor.A = byte(Root.Colors.DarkBGAlpha);
	m_SmallMap = R6WindowBitMap(CreateWindow(Class'R6Window.R6WindowBitMap', ((m_MissionObjectives.WinLeft + m_MissionObjectives.WinWidth) + float(4)), m_MissionObjectives.WinTop, m_fMapWidth, m_fObjHeight, self));
	m_SmallMap.m_BorderColor = Root.Colors.GrayLight;
	m_SmallMap.m_BorderStyle = int(1);
	m_SmallMap.m_bDrawBorder = true;
	m_SmallMap.bStretch = true;
	m_SmallMap.m_iDrawStyle = 5;
	m_NavBar.HideWindow();
	m_fButtonAreaY = ((m_Bottom.WinTop - float(33)) - m_fLaptopPadding);
	m_fButtonY = (m_fButtonAreaY + float(1));
	m_BorderColor = Root.Colors.BlueLight;
	m_GoPlanningButton = R6WindowButton(CreateControl(Class'R6Window.R6WindowButton', m_fGoPlanningButtonX, m_fButtonY, float(m_RGoPlanningButtonUp.W), m_fButtonHeight, self));
	m_GoPlanningButton.DisabledTexture = m_TGoPlanningButton;
	m_GoPlanningButton.DownTexture = m_TGoPlanningButton;
	m_GoPlanningButton.OverTexture = m_TGoPlanningButton;
	m_GoPlanningButton.UpTexture = m_TGoPlanningButton;
	m_GoPlanningButton.UpRegion = m_RGoPlanningButtonUp;
	m_GoPlanningButton.DownRegion = m_RGoPlanningButtonDown;
	m_GoPlanningButton.DisabledRegion = m_RGoPlanningButtonDisabled;
	m_GoPlanningButton.OverRegion = m_RGoPlanningButtonOver;
	m_GoPlanningButton.bUseRegion = true;
	m_GoPlanningButton.ToolTipString = Localize("ExecuteMenu", "GOPLANNING", "R6Menu");
	m_GoPlanningButton.m_iDrawStyle = 5;
	m_GoGameButton = R6WindowButton(CreateControl(Class'R6Window.R6WindowButton', m_fGoGameButtonX, m_fButtonY, float(m_RGoGameButtonUp.W), m_fButtonHeight, self));
	m_GoGameButton.DisabledTexture = m_TGoGameButton;
	m_GoGameButton.DownTexture = m_TGoGameButton;
	m_GoGameButton.OverTexture = m_TGoGameButton;
	m_GoGameButton.UpTexture = m_TGoGameButton;
	m_GoGameButton.UpRegion = m_RGoGameButtonUp;
	m_GoGameButton.DownRegion = m_RGoGameButtonDown;
	m_GoGameButton.DisabledRegion = m_RGoGameButtonDisabled;
	m_GoGameButton.OverRegion = m_RGoGameButtonOver;
	m_GoGameButton.bUseRegion = true;
	m_GoGameButton.ToolTipString = Localize("ExecuteMenu", "GOGAME", "R6Menu");
	m_GoGameButton.m_iDrawStyle = 5;
	m_ObserverButton = R6WindowButton(CreateControl(Class'R6Window.R6WindowButton', m_fObserverButtonX, (m_fButtonY + float(1)), float(m_RObserverButtonUp.W), m_fButtonHeight, self));
	m_ObserverButton.DisabledTexture = m_TObserverButton;
	m_ObserverButton.DownTexture = m_TObserverButton;
	m_ObserverButton.OverTexture = m_TObserverButton;
	m_ObserverButton.UpTexture = m_TObserverButton;
	m_ObserverButton.UpRegion = m_RObserverButtonUp;
	m_ObserverButton.DownRegion = m_RObserverButtonDown;
	m_ObserverButton.DisabledRegion = m_RObserverButtonDisabled;
	m_ObserverButton.OverRegion = m_RObserverButtonOver;
	m_ObserverButton.bUseRegion = true;
	m_ObserverButton.ToolTipString = Localize("ExecuteMenu", "OBSERVER", "R6Menu");
	m_ObserverButton.m_iDrawStyle = 5;
	fTeamSummaryYPos = 152.0000000;
	m_fTeamSummaryMaxHeight = 237.0000000;
	m_RedSummary = R6WindowTeamSummary(CreateWindow(Class'R6Window.R6WindowTeamSummary', m_MissionObjectives.WinLeft, fTeamSummaryYPos, m_fTeamSummaryWidth, m_fTeamSummaryMaxHeight, self));
	m_RedSummary.SetTeam(0);
	m_RedSummary.bAlwaysBehind = true;
	m_GreenSummary = R6WindowTeamSummary(CreateWindow(Class'R6Window.R6WindowTeamSummary', ((m_RedSummary.WinLeft + m_RedSummary.WinWidth) + m_fTeamSummaryXPadding), fTeamSummaryYPos, m_fTeamSummaryWidth, m_fTeamSummaryMaxHeight, self));
	m_GreenSummary.SetTeam(1);
	m_GreenSummary.bAlwaysBehind = true;
	m_GoldSummary = R6WindowTeamSummary(CreateWindow(Class'R6Window.R6WindowTeamSummary', ((m_GreenSummary.WinLeft + m_GreenSummary.WinWidth) + m_fTeamSummaryXPadding), fTeamSummaryYPos, m_fTeamSummaryWidth, m_fTeamSummaryMaxHeight, self));
	m_GoldSummary.SetTeam(2);
	m_GoldSummary.bAlwaysBehind = true;
	m_RedSummaryButton = R6WindowButton(CreateControl(Class'R6Window.R6WindowButton', m_MissionObjectives.WinLeft, fTeamSummaryYPos, m_fTeamSummaryWidth, m_fTeamSummaryMaxHeight, self));
	m_RedSummaryButton.ToolTipString = Localize("ExecuteMenu", "OverATeam", "R6Menu");
	m_RedSummaryButton.m_BorderColor = Root.Colors.BlueLight;
	m_RedSummaryButton.m_bDrawSimpleBorder = true;
	m_GreenSummaryButton = R6WindowButton(CreateControl(Class'R6Window.R6WindowButton', ((m_RedSummary.WinLeft + m_RedSummary.WinWidth) + m_fTeamSummaryXPadding), fTeamSummaryYPos, m_fTeamSummaryWidth, m_fTeamSummaryMaxHeight, self));
	m_GreenSummaryButton.ToolTipString = Localize("ExecuteMenu", "OverATeam", "R6Menu");
	m_GreenSummaryButton.m_BorderColor = Root.Colors.BlueLight;
	m_GreenSummaryButton.m_bDrawSimpleBorder = true;
	m_GoldSummaryButton = R6WindowButton(CreateControl(Class'R6Window.R6WindowButton', ((m_GreenSummary.WinLeft + m_GreenSummary.WinWidth) + m_fTeamSummaryXPadding), fTeamSummaryYPos, m_fTeamSummaryWidth, m_fTeamSummaryMaxHeight, self));
	m_GoldSummaryButton.ToolTipString = Localize("ExecuteMenu", "OverATeam", "R6Menu");
	m_GoldSummaryButton.m_BorderColor = Root.Colors.BlueLight;
	m_GoldSummaryButton.m_bDrawSimpleBorder = true;
	return;
}

function ShowWindow()
{
	local R6MissionObjectiveMgr moMgr;
	local int i;
	local string szDescription;
	local R6GameOptions pGameOptions;
	local R6MissionDescription CurrentMission;

	super(UWindowWindow).ShowWindow();
	CurrentMission = R6MissionDescription(R6Console(Root.Console).Master.m_StartGameInfo.m_CurrentMission);
	m_CodeName.SetProperties(Localize(CurrentMission.m_MapName, "ID_CODENAME", CurrentMission.LocalizationFile), 2, Root.Fonts[9], Root.Colors.White, false);
	m_DateTime.SetProperties(Localize(CurrentMission.m_MapName, "ID_DATETIME", CurrentMission.LocalizationFile), 2, Root.Fonts[9], Root.Colors.White, false);
	m_Location.SetProperties(Localize(CurrentMission.m_MapName, "ID_LOCATION", CurrentMission.LocalizationFile), 2, Root.Fonts[9], Root.Colors.White, false);
	moMgr = R6AbstractGameInfo(Root.Console.ViewportOwner.Actor.Level.Game).m_missionMgr;
	m_MissionObjectives.Clear();
	m_MissionObjectives.m_fXOffSet = 10.0000000;
	m_MissionObjectives.m_fYOffSet = 5.0000000;
	m_MissionObjectives.AddText(Localize("Briefing", "Objectives", "R6Menu"), Root.Colors.BlueLight, Root.Fonts[5]);
	i = 0;
	J0x259:

	// End:0x35E [Loop If]
	if((i < moMgr.m_aMissionObjectives.Length))
	{
		// End:0x354
		if(((!moMgr.m_aMissionObjectives[i].m_bMoralityObjective) && moMgr.m_aMissionObjectives[i].m_bVisibleInMenu))
		{
			szDescription = ("-" @ Localize("Game", moMgr.m_aMissionObjectives[i].m_szDescriptionInMenu, moMgr.Level.GetMissionObjLocFile(moMgr.m_aMissionObjectives[i])));
			m_MissionObjectives.AddText(szDescription, Root.Colors.White, Root.Fonts[10]);
		}
		(++i);
		// [Loop Continue]
		goto J0x259;
	}
	m_SmallMap.t = CurrentMission.m_TWorldMap;
	m_SmallMap.R = CurrentMission.m_RWorldMap;
	CalculatePlanningDetails();
	UpdateTeamRoster();
	// End:0x410
	if((R6MenuRootWindow(Root).m_bPlayerPlanInitialized == false))
	{
		pGameOptions = Class'Engine.Actor'.static.GetGameOptions();
		// End:0x410
		if((pGameOptions.PopUpLoadPlan == true))
		{
			R6MenuRootWindow(Root).m_ePopUpID = 48;
			R6MenuRootWindow(Root).PopUpMenu(true);
		}
	}
	return;
}

function CalculatePlanningDetails()
{
	local R6PlanningInfo PlanningInfo;
	local int iWaypoint, iGoCode, i, Y;
	local R6WindowTeamSummary TeamSummarys[3];

	TeamSummarys[0] = m_RedSummary;
	TeamSummarys[1] = m_GreenSummary;
	TeamSummarys[2] = m_GoldSummary;
	i = 0;
	J0x2F:

	// End:0x18A [Loop If]
	if((i < 3))
	{
		PlanningInfo = R6PlanningInfo(Root.Console.Master.m_StartGameInfo.m_TeamInfo[i].m_pPlanning);
		iWaypoint = 0;
		iGoCode = 0;
		Y = 0;
		J0x93:

		// End:0x148 [Loop If]
		if((Y < PlanningInfo.m_NodeList.Length))
		{
			// End:0x13E
			if((((int(R6ActionPoint(PlanningInfo.m_NodeList[Y]).m_eActionType) == int(2)) || (int(R6ActionPoint(PlanningInfo.m_NodeList[Y]).m_eActionType) == int(3))) || (int(R6ActionPoint(PlanningInfo.m_NodeList[Y]).m_eActionType) == int(4))))
			{
				(iGoCode++);
			}
			(Y++);
			// [Loop Continue]
			goto J0x93;
		}
		iWaypoint = PlanningInfo.m_NodeList.Length;
		TeamSummarys[i].SetPlanningDetails(string(iWaypoint), string(iGoCode));
		(i++);
		// [Loop Continue]
		goto J0x2F;
	}
	return;
}

function UpdateTeamRoster()
{
	local int i, Y;
	local R6WindowTeamSummary TeamSummarys[3];
	local R6WindowButton TeamSummaryButton[3];
	local R6Operative tmpOperative;
	local R6WindowTextIconsListBox tmpListBox[3], currentListBox;
	local R6WindowListBoxItem tmpItem;
	local R6MenuRootWindow r6Root;
	local bool bselectedSet;

	TeamSummarys[0] = m_RedSummary;
	TeamSummarys[1] = m_GreenSummary;
	TeamSummarys[2] = m_GoldSummary;
	TeamSummaryButton[0] = m_RedSummaryButton;
	TeamSummaryButton[1] = m_GreenSummaryButton;
	TeamSummaryButton[2] = m_GoldSummaryButton;
	m_RedSummary.SetSelected(false);
	m_GreenSummary.SetSelected(false);
	m_GoldSummary.SetSelected(false);
	m_RedSummaryButton.m_bDrawBorders = false;
	m_GreenSummaryButton.m_bDrawBorders = false;
	m_GoldSummaryButton.m_bDrawBorders = false;
	bselectedSet = false;
	m_RedSummary.Init();
	m_GreenSummary.Init();
	m_GoldSummary.Init();
	r6Root = R6MenuRootWindow(Root);
	tmpListBox[0] = r6Root.m_GearRoomWidget.m_RosterListCtrl.m_RedListBox.m_listBox;
	tmpListBox[1] = r6Root.m_GearRoomWidget.m_RosterListCtrl.m_GreenListBox.m_listBox;
	tmpListBox[2] = r6Root.m_GearRoomWidget.m_RosterListCtrl.m_GoldListBox.m_listBox;
	Y = 0;
	J0x193:

	// End:0x2A7 [Loop If]
	if((Y < 3))
	{
		currentListBox = tmpListBox[Y];
		tmpItem = R6WindowListBoxItem(currentListBox.Items.Next);
		i = 0;
		J0x1D9:

		// End:0x29D [Loop If]
		if((i < currentListBox.Items.Count()))
		{
			tmpOperative = R6Operative(tmpItem.m_Object);
			// End:0x27A
			if((tmpOperative != none))
			{
				TeamSummarys[Y].AddOperative(tmpOperative);
				// End:0x27A
				if((bselectedSet == false))
				{
					TeamSummaryButton[Y].m_bDrawBorders = true;
					TeamSummarys[Y].SetSelected(true);
					bselectedSet = true;
				}
			}
			tmpItem = R6WindowListBoxItem(tmpItem.Next);
			(i++);
			// [Loop Continue]
			goto J0x1D9;
		}
		(Y++);
		// [Loop Continue]
		goto J0x193;
	}
	return;
}

function Notify(UWindowDialogControl C, byte E)
{
	// End:0x209
	if((int(E) == 2))
	{
		switch(C)
		{
			// End:0x31
			case m_GoPlanningButton:
				Root.ChangeCurrentWidget(17);
				// End:0x209
				break;
			// End:0x57
			case m_GoGameButton:
				R6MenuRootWindow(Root).LeaveForGame(false, GetTeamStart());
				// End:0x209
				break;
			// End:0x7D
			case m_ObserverButton:
				R6MenuRootWindow(Root).LeaveForGame(true, GetTeamStart());
				// End:0x209
				break;
			// End:0x100
			case m_RedSummaryButton:
				// End:0xFD
				if((m_RedSummary.OperativeCount() > 0))
				{
					m_RedSummary.SetSelected(true);
					m_GreenSummary.SetSelected(false);
					m_GoldSummary.SetSelected(false);
					m_RedSummaryButton.m_bDrawBorders = true;
					m_GreenSummaryButton.m_bDrawBorders = false;
					m_GoldSummaryButton.m_bDrawBorders = false;
				}
				// End:0x209
				break;
			// End:0x183
			case m_GreenSummaryButton:
				// End:0x180
				if((m_GreenSummary.OperativeCount() > 0))
				{
					m_RedSummary.SetSelected(false);
					m_GreenSummary.SetSelected(true);
					m_GoldSummary.SetSelected(false);
					m_RedSummaryButton.m_bDrawBorders = false;
					m_GreenSummaryButton.m_bDrawBorders = true;
					m_GoldSummaryButton.m_bDrawBorders = false;
				}
				// End:0x209
				break;
			// End:0x206
			case m_GoldSummaryButton:
				// End:0x203
				if((m_GoldSummary.OperativeCount() > 0))
				{
					m_RedSummary.SetSelected(false);
					m_GreenSummary.SetSelected(false);
					m_GoldSummary.SetSelected(true);
					m_RedSummaryButton.m_bDrawBorders = false;
					m_GreenSummaryButton.m_bDrawBorders = false;
					m_GoldSummaryButton.m_bDrawBorders = true;
				}
				// End:0x209
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

function Paint(Canvas C, float X, float Y)
{
	local float boxX;

	super.Paint(C, X, Y);
	boxX = (m_Left.WinWidth + float(2));
	R6WindowLookAndFeel(LookAndFeel).DrawBox(self, C, boxX, m_fButtonAreaY, (640.0000000 - (float(2) * boxX)), 33.0000000);
	return;
}

function int GetTeamStart()
{
	// End:0x17
	if(m_RedSummary.m_bIsSelected)
	{
		return 0;		
	}
	else
	{
		// End:0x2E
		if(m_GreenSummary.m_bIsSelected)
		{
			return 1;			
		}
		else
		{
			// End:0x43
			if(m_GoldSummary.m_bIsSelected)
			{
				return 2;
			}
		}
	}
	return 0;
	return;
}

defaultproperties
{
	m_fObjWidth=396.0000000
	m_fObjHeight=98.0000000
	m_fMapWidth=196.0000000
	m_fTeamSummaryWidth=196.0000000
	m_fTeamSummaryYPadding=4.0000000
	m_fTeamSummaryXPadding=4.0000000
	m_fGoPlanningButtonX=172.0000000
	m_fGoGameButtonX=442.0000000
	m_fObserverButtonX=303.0000000
	m_fButtonHeight=33.0000000
	m_TObserverButton=Texture'R6MenuTextures.Gui_02'
	m_TGoPlanningButton=Texture'R6MenuTextures.Gui_01'
	m_TGoGameButton=Texture'R6MenuTextures.Gui_01'
	m_RGoPlanningButtonUp=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=6690,ZoneNumber=0)
	m_RGoPlanningButtonDown=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=6690,ZoneNumber=0)
	m_RGoPlanningButtonOver=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=6690,ZoneNumber=0)
	m_RGoPlanningButtonDisabled=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=6690,ZoneNumber=0)
	m_RGoGameButtonUp=(Zone=ObjectProperty'R6Menu.R6MenuMPCreateGameTab.m_pButtonsDef',iLeaf=30754,ZoneNumber=0)
	m_RGoGameButtonDown=(Zone=ObjectProperty'R6Menu.R6MenuMPCreateGameTab.m_pButtonsDef',iLeaf=46114,ZoneNumber=0)
	m_RGoGameButtonOver=(Zone=ObjectProperty'R6Menu.R6MenuMPCreateGameTab.m_pButtonsDef',iLeaf=38434,ZoneNumber=0)
	m_RGoGameButtonDisabled=(Zone=ObjectProperty'R6Menu.R6MenuMPCreateGameTab.m_pButtonsDef',iLeaf=53794,ZoneNumber=0)
	m_RObserverButtonUp=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=45858,ZoneNumber=0)
	m_RObserverButtonDown=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=45858,ZoneNumber=0)
	m_RObserverButtonOver=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=45858,ZoneNumber=0)
	m_RObserverButtonDisabled=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=45858,ZoneNumber=0)
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var t
// REMOVED IN 1.60: var h
// REMOVED IN 1.60: var y
// REMOVED IN 1.60: var g
// REMOVED IN 1.60: var n
// REMOVED IN 1.60: var r
// REMOVED IN 1.60: var d
// REMOVED IN 1.60: var X
