//=============================================================================
// R6MenuDebriefingWidget - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6MenuDebriefingWidget.uc : Menu Poping at the end of the mission
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/07/04 * Created by Alexandre Dionne
//=============================================================================
class R6MenuDebriefingWidget extends R6MenuLaptopWidget;

var int m_iCountFrame;
var bool m_bReadyShowWindow;
var bool m_bMissionVictory;
//Mission Objectives dimensions 
var float m_fObjHeight;
var float m_fMissionResultTitleHeight;
// NEW IN 1.60
var float m_fMissionResultTitleWidth;
var float m_fNavAreaY;
var float m_fPaddingBetween;
// NEW IN 1.60
var float m_fStatsWidth;
//Top Labels showing location of the current mission
var R6WindowTextLabel m_CodeName;
// NEW IN 1.60
var R6WindowTextLabel m_DateTime;
// NEW IN 1.60
var R6WindowTextLabel m_Location;
//Missions Objectives for the current Mission
var R6WindowWrappedTextArea m_MissionObjectives;
//BIG MISSIN RESULT LABEL AT THE TOP OF THE PAGE
var R6WindowTextLabel m_MissionResultTitle;
var Texture m_TBGMissionResult;
//NAV BAR
var R6MenuDebriefNavBar m_DebriefNavBar;
var R6MenuSingleTeamBar m_pR6RainbowTeamBar;  // the rainbows for the mission with their stats
var R6MenuCarreerStats m_RainbowCarreerStats;
var Sound m_sndVictoryMusic;
var Sound m_sndLossMusic;
var array<R6Operative> m_MissionOperatives;
var Region m_RBGMissionResult;
var Region m_RBGExtMissionResult;

function Created()
{
	local float labelWidth, NavXPos, fStatsHeight, fStatsWidth;

	super.Created();
	labelWidth = ((m_Right.WinLeft - m_Left.WinWidth) / float(3));
	m_CodeName = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', m_Left.WinWidth, m_Top.WinHeight, labelWidth, 18.0000000, self));
	m_DateTime = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', (m_CodeName.WinLeft + m_CodeName.WinWidth), m_Top.WinHeight, labelWidth, 18.0000000, self));
	m_Location = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', (m_DateTime.WinLeft + m_DateTime.WinWidth), m_Top.WinHeight, m_DateTime.WinWidth, 18.0000000, self));
	m_MissionResultTitle = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', 21.0000000, 52.0000000, m_fMissionResultTitleWidth, m_fMissionResultTitleHeight, self));
	m_MissionResultTitle.m_bUseBGColor = true;
	m_MissionResultTitle.m_BGTexture = m_TBGMissionResult;
	m_MissionResultTitle.m_BGTextureRegion = m_RBGMissionResult;
	m_MissionResultTitle.m_BGExtRegion = m_RBGExtMissionResult;
	m_MissionResultTitle.m_DrawStyle = 5;
	m_MissionResultTitle.m_BorderColor = Root.Colors.GrayLight;
	m_MissionResultTitle.m_bDrawBorders = true;
	m_MissionResultTitle.m_bDrawBG = true;
	m_MissionResultTitle.m_bUseExtRegion = true;
	m_MissionObjectives = R6WindowWrappedTextArea(CreateWindow(Class'R6Window.R6WindowWrappedTextArea', m_MissionResultTitle.WinLeft, 87.0000000, m_MissionResultTitle.WinWidth, m_fObjHeight, self));
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
	m_NavBar.HideWindow();
	m_fNavAreaY = ((m_Bottom.WinTop - float(33)) - m_fLaptopPadding);
	NavXPos = (m_Left.WinWidth + float(2));
	m_DebriefNavBar = R6MenuDebriefNavBar(CreateWindow(Class'R6Menu.R6MenuDebriefNavBar', m_NavBar.WinLeft, m_NavBar.WinTop, m_NavBar.WinWidth, m_NavBar.WinHeight, self));
	fStatsHeight = 227.0000000;
	m_pR6RainbowTeamBar = R6MenuSingleTeamBar(CreateControl(Class'R6Menu.R6MenuSingleTeamBar', m_MissionObjectives.WinLeft, ((m_MissionObjectives.WinTop + m_MissionObjectives.WinHeight) + float(3)), m_fStatsWidth, fStatsHeight, self));
	m_pR6RainbowTeamBar.m_bDrawBorders = true;
	m_pR6RainbowTeamBar.m_bDrawTotalsShading = true;
	m_pR6RainbowTeamBar.m_IFirstItempYOffset = 4;
	m_pR6RainbowTeamBar.m_IBorderVOffset = 0;
	m_pR6RainbowTeamBar.m_fRainbowWidth = 131.0000000;
	m_pR6RainbowTeamBar.m_fTeamcolorWidth = 21.0000000;
	m_pR6RainbowTeamBar.m_fHealthWidth = 23.0000000;
	m_pR6RainbowTeamBar.m_fSkullWidth = 23.0000000;
	m_pR6RainbowTeamBar.m_fEfficiencyWidth = 25.0000000;
	m_pR6RainbowTeamBar.m_fShotsWidth = 39.0000000;
	m_pR6RainbowTeamBar.m_fHitsWidth = 32.0000000;
	m_pR6RainbowTeamBar.m_fBottomTitleWidth = 175.0000000;
	m_pR6RainbowTeamBar.m_IGPlayerInfoListBox.m_fXItemOffset = 1.0000000;
	m_pR6RainbowTeamBar.m_IGPlayerInfoListBox.m_fXItemRightPadding = 1.0000000;
	m_pR6RainbowTeamBar.m_IGPlayerInfoListBox.m_fItemHeight = 18.0000000;
	m_pR6RainbowTeamBar.Resize();
	m_RainbowCarreerStats = R6MenuCarreerStats(CreateWindow(Class'R6Menu.R6MenuCarreerStats', ((m_pR6RainbowTeamBar.WinLeft + m_pR6RainbowTeamBar.WinWidth) + m_fPaddingBetween), m_pR6RainbowTeamBar.WinTop, 301.0000000, m_pR6RainbowTeamBar.WinHeight, self));
	return;
}

function Paint(Canvas C, float X, float Y)
{
	super.Paint(C, X, Y);
	// End:0xAB
	if(m_bReadyShowWindow)
	{
		// End:0xA4
		if((m_iCountFrame == 1))
		{
			m_bReadyShowWindow = false;
			GetPlayerOwner().StopAllMusic();
			R6AbstractHUD(GetPlayerOwner().myHUD).StopFadeToBlack();
			GetPlayerOwner().ResetVolume_TypeSound(5);
			// End:0x8F
			if(m_bMissionVictory)
			{
				GetPlayerOwner().PlayMusic(m_sndVictoryMusic);				
			}
			else
			{
				GetPlayerOwner().PlayMusic(m_sndLossMusic);
			}
		}
		m_iCountFrame = 1;
	}
	return;
}

function ShowWindow()
{
	local R6MissionDescription CurrentMission;
	local R6MissionObjectiveMgr moMgr;
	local int i;
	local string szObjectiveDesc;
	local Canvas C;

	C = Class'Engine.Actor'.static.GetCanvas();
	C.m_iNewResolutionX = 640;
	C.m_iNewResolutionY = 480;
	C.m_bChangeResRequested = true;
	GetLevel().m_bAllow3DRendering = false;
	super(UWindowWindow).ShowWindow();
	m_DebriefNavBar.m_ContinueButton.bDisabled = false;
	GetPlayerOwner().SetPause(true);
	m_bReadyShowWindow = true;
	m_iCountFrame = 0;
	CurrentMission = R6MissionDescription(R6Console(Root.Console).Master.m_StartGameInfo.m_CurrentMission);
	m_CodeName.SetProperties(Localize(CurrentMission.m_MapName, "ID_CODENAME", CurrentMission.LocalizationFile), 2, Root.Fonts[9], Root.Colors.White, false);
	m_DateTime.SetProperties(Localize(CurrentMission.m_MapName, "ID_DATETIME", CurrentMission.LocalizationFile), 2, Root.Fonts[9], Root.Colors.White, false);
	m_Location.SetProperties(Localize(CurrentMission.m_MapName, "ID_LOCATION", CurrentMission.LocalizationFile), 2, Root.Fonts[9], Root.Colors.White, false);
	moMgr = R6AbstractGameInfo(Root.Console.ViewportOwner.Actor.Level.Game).m_missionMgr;
	m_MissionObjectives.Clear();
	m_MissionObjectives.m_fXOffSet = 10.0000000;
	m_MissionObjectives.m_fYOffSet = 5.0000000;
	m_MissionObjectives.AddText(Localize("Briefing", "SUMMARY", "R6Menu"), Root.Colors.BlueLight, Root.Fonts[5]);
	// End:0x52F
	if((int(moMgr.m_eMissionObjectiveStatus) == int(1)))
	{
		m_bMissionVictory = true;
		m_MissionResultTitle.SetProperties(Localize("DebriefingMenu", "SUCCESS", "R6Menu"), 2, Root.Fonts[4], Root.Colors.Green, true);
		m_MissionResultTitle.m_BGColor = Root.Colors.Green;
		i = 0;
		J0x395:

		// End:0x52C [Loop If]
		if((i < moMgr.m_aMissionObjectives.Length))
		{
			// End:0x522
			if(((!moMgr.m_aMissionObjectives[i].m_bMoralityObjective) && moMgr.m_aMissionObjectives[i].m_bVisibleInMenu))
			{
				szObjectiveDesc = Localize("Game", moMgr.m_aMissionObjectives[i].m_szDescriptionInMenu, moMgr.Level.GetMissionObjLocFile(moMgr.m_aMissionObjectives[i]));
				// End:0x4AD
				if(moMgr.m_aMissionObjectives[i].isCompleted())
				{
					szObjectiveDesc = ((("-" @ szObjectiveDesc) @ ":") @ Localize("OBJECTIVES", "SUCCESS", "R6Menu"));					
				}
				else
				{
					szObjectiveDesc = ((("-" @ szObjectiveDesc) @ ":") @ Localize("OBJECTIVES", "FAILED", "R6Menu"));
				}
				m_MissionObjectives.AddText(szObjectiveDesc, Root.Colors.White, Root.Fonts[10]);
			}
			(++i);
			// [Loop Continue]
			goto J0x395;
		}		
	}
	else
	{
		m_bMissionVictory = false;
		m_MissionResultTitle.SetProperties(Localize("DebriefingMenu", "FAILED", "R6Menu"), 2, Root.Fonts[4], Root.Colors.Red, true);
		m_MissionResultTitle.m_BGColor = Root.Colors.Red;
		i = 0;
		J0x5C4:

		// End:0x7DE [Loop If]
		if((i < moMgr.m_aMissionObjectives.Length))
		{
			// End:0x7D4
			if(moMgr.m_aMissionObjectives[i].m_bVisibleInMenu)
			{
				szObjectiveDesc = "";
				// End:0x6AB
				if(moMgr.m_aMissionObjectives[i].m_bMoralityObjective)
				{
					// End:0x6A8
					if(moMgr.m_aMissionObjectives[i].isFailed())
					{
						szObjectiveDesc = ("-" @ Localize("Game", moMgr.m_aMissionObjectives[i].m_szDescriptionFailure, moMgr.Level.GetMissionObjLocFile(moMgr.m_aMissionObjectives[i])));
					}					
				}
				else
				{
					// End:0x6F8
					if(moMgr.m_aMissionObjectives[i].isCompleted())
					{
						szObjectiveDesc = Localize("OBJECTIVES", "SUCCESS", "R6Menu");						
					}
					else
					{
						szObjectiveDesc = Localize("OBJECTIVES", "FAILED", "R6Menu");
					}
					szObjectiveDesc = ((("-" @ Localize("Game", moMgr.m_aMissionObjectives[i].m_szDescriptionInMenu, moMgr.Level.GetMissionObjLocFile(moMgr.m_aMissionObjectives[i]))) @ ":") @ szObjectiveDesc);
				}
				// End:0x7D4
				if((szObjectiveDesc != ""))
				{
					m_MissionObjectives.AddText(szObjectiveDesc, Root.Colors.White, Root.Fonts[10]);
				}
			}
			(++i);
			// [Loop Continue]
			goto J0x5C4;
		}
		// End:0x83C
		if(R6GameInfo(Root.Console.ViewportOwner.Actor.Level.Game).m_bUsingPlayerCampaign)
		{
			m_DebriefNavBar.m_ContinueButton.bDisabled = true;
		}
	}
	m_pR6RainbowTeamBar.RefreshTeamBarInfo();
	// End:0x897
	if((!R6GameInfo(Root.Console.ViewportOwner.Actor.Level.Game).m_bUsingPlayerCampaign))
	{
		BuildMissionOperatives();
	}
	// End:0x928
	if((m_pR6RainbowTeamBar.m_IGPlayerInfoListBox.Items.Next != none))
	{
		m_pR6RainbowTeamBar.m_IGPlayerInfoListBox.SetSelectedItem(R6WindowListIGPlayerInfoItem(m_pR6RainbowTeamBar.m_IGPlayerInfoListBox.Items.Next));
		DisplayOperativeStats(R6WindowListIGPlayerInfoItem(m_pR6RainbowTeamBar.m_IGPlayerInfoListBox.m_SelectedItem).m_iOperativeID);		
	}
	else
	{
		m_RainbowCarreerStats.UpdateStats("", "", "", "", "");
	}
	return;
}

function HideWindow()
{
	local Canvas C;

	C = Class'Engine.Actor'.static.GetCanvas();
	super(UWindowWindow).HideWindow();
	C.m_iNewResolutionX = 0;
	C.m_iNewResolutionY = 0;
	C.m_bChangeResRequested = true;
	GetLevel().m_bAllow3DRendering = true;
	GetPlayerOwner().SetPause(false);
	return;
}

function BuildMissionOperatives()
{
	local R6Operative tmpOperative;
	local R6WindowListIGPlayerInfoItem tmpItem;

	m_MissionOperatives.Remove(0, m_MissionOperatives.Length);
	tmpItem = R6WindowListIGPlayerInfoItem(m_pR6RainbowTeamBar.m_IGPlayerInfoListBox.Items.Next);
	J0x38:

	// End:0x15A [Loop If]
	if((tmpItem != none))
	{
		tmpOperative = new (none) Class<R6Operative>(DynamicLoadObject(R6Console(Root.Console).m_CurrentCampaign.m_OperativeClassName[tmpItem.m_iOperativeID], Class'Core.Class'));
		tmpItem.m_iOperativeID = m_MissionOperatives.Length;
		m_MissionOperatives[m_MissionOperatives.Length] = tmpOperative;
		tmpOperative.m_iNbMissionPlayed = 1;
		tmpOperative.m_iTerrokilled = tmpItem.iKills;
		tmpOperative.m_iRoundsfired = tmpItem.iRoundsFired;
		tmpOperative.m_iRoundsOntarget = tmpItem.iRoundsHit;
		tmpOperative.m_iHealth = int(tmpItem.eStatus);
		tmpItem = R6WindowListIGPlayerInfoItem(tmpItem.Next);
		// [Loop Continue]
		goto J0x38;
	}
	return;
}

function DisplayOperativeStats(int _OperativeId)
{
	local R6Operative tmpOperative;
	local R6PlayerCampaign MyCampaign;
	local R6MissionRoster PlayerCampaignOperatives;
	local R6WindowListIGPlayerInfoItem SelectedItem;
	local Region R;

	SelectedItem = R6WindowListIGPlayerInfoItem(m_pR6RainbowTeamBar.m_IGPlayerInfoListBox.m_SelectedItem);
	// End:0xB9
	if(R6GameInfo(Root.Console.ViewportOwner.Actor.Level.Game).m_bUsingPlayerCampaign)
	{
		MyCampaign = R6Console(Root.Console).m_PlayerCampaign;
		PlayerCampaignOperatives = MyCampaign.m_OperativesMissionDetails;
		tmpOperative = PlayerCampaignOperatives.m_MissionOperatives[_OperativeId];		
	}
	else
	{
		tmpOperative = m_MissionOperatives[_OperativeId];
	}
	m_RainbowCarreerStats.UpdateStats(tmpOperative.GetNbMissionPlayed(), tmpOperative.GetNbTerrokilled(), tmpOperative.GetNbRoundsfired(), tmpOperative.GetNbRoundsOnTarget(), tmpOperative.GetShootPercent());
	R.X = tmpOperative.m_RMenuFaceX;
	R.Y = tmpOperative.m_RMenuFaceY;
	R.W = tmpOperative.m_RMenuFaceW;
	R.H = tmpOperative.m_RMenuFaceH;
	m_RainbowCarreerStats.UpdateFace(tmpOperative.m_TMenuFace, R);
	m_RainbowCarreerStats.UpdateTeam(SelectedItem.m_iRainbowTeam);
	m_RainbowCarreerStats.UpdateName(tmpOperative.GetName());
	m_RainbowCarreerStats.UpdateSpeciality(tmpOperative.GetSpeciality());
	m_RainbowCarreerStats.UpdateHealthStatus(tmpOperative.GetHealthStatus());
	return;
}

function Notify(UWindowDialogControl C, byte E)
{
	// End:0x74
	if((int(E) == 2))
	{
		switch(C)
		{
			// End:0x71
			case m_pR6RainbowTeamBar.m_IGPlayerInfoListBox:
				// End:0x6E
				if((m_pR6RainbowTeamBar.m_IGPlayerInfoListBox.m_SelectedItem != none))
				{
					DisplayOperativeStats(R6WindowListIGPlayerInfoItem(m_pR6RainbowTeamBar.m_IGPlayerInfoListBox.m_SelectedItem).m_iOperativeID);
				}
				// End:0x74
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
	m_fObjHeight=72.0000000
	m_fMissionResultTitleHeight=32.0000000
	m_fMissionResultTitleWidth=598.0000000
	m_fPaddingBetween=3.0000000
	m_fStatsWidth=294.0000000
	m_TBGMissionResult=Texture'R6MenuTextures.Gui_BoxScroll'
	m_sndVictoryMusic=Sound'Music.Play_theme_MissionVictory'
	m_sndLossMusic=Sound'Music.Play_theme_MissionLoss'
	m_RBGMissionResult=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=34338,ZoneNumber=0)
	m_RBGExtMissionResult=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=29730,ZoneNumber=0)
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var h
