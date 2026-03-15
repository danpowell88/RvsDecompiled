//=============================================================================
// R6MenuInGameEsc - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6MenuInGameEsc.uc : This pops in single player when we presse ESC 
//                              in single player
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/5/16 * Created by Alexandre Dionne
//=============================================================================
class R6MenuInGameEsc extends R6MenuWidget;

var float m_fLabelHeight;
var float m_fNavBarHeight;
var float m_fRainbowStatsHeight;
//Top Labels showing location of the current mission
var R6WindowTextLabel m_CodeName;
// NEW IN 1.60
var R6WindowTextLabel m_DateTime;
// NEW IN 1.60
var R6WindowTextLabel m_Location;
// the nav bar 
var R6MenuInGameEscSinglePlayerNavBar m_pInGameNavBar;
var R6MenuSingleTeamBar m_pR6RainbowTeamBar;  // the rainbows for the mission with their stats
var R6MenuEscObjectives m_EscObj;

function Created()
{
	// End:0x20
	if(R6MenuInGameRootWindow(Root).m_bInTraining)
	{
		InitTrainingEsc();		
	}
	else
	{
		InitInGameEsc();
	}
	return;
}

function InitInGameEsc()
{
	local float labelWidth;
	local R6MenuInGameRootWindow r6Root;

	r6Root = R6MenuInGameRootWindow(Root);
	labelWidth = float((r6Root.m_REscMenuWidget.W / 3));
	m_CodeName = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', float(r6Root.m_REscMenuWidget.X), (float(r6Root.m_REscMenuWidget.Y) + r6Root.m_fTopLabelHeight), labelWidth, m_fLabelHeight, self));
	m_DateTime = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', (m_CodeName.WinLeft + m_CodeName.WinWidth), m_CodeName.WinTop, labelWidth, m_fLabelHeight, self));
	m_Location = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', (m_DateTime.WinLeft + m_DateTime.WinWidth), m_CodeName.WinTop, m_DateTime.WinWidth, m_fLabelHeight, self));
	m_pInGameNavBar = R6MenuInGameEscSinglePlayerNavBar(CreateWindow(Class'R6Menu.R6MenuInGameEscSinglePlayerNavBar', float(r6Root.m_REscMenuWidget.X), (((float(r6Root.m_REscMenuWidget.Y) + r6Root.m_fTopLabelHeight) + float(r6Root.m_REscMenuWidget.H)) - m_fNavBarHeight), float(r6Root.m_REscMenuWidget.W), m_fNavBarHeight, self));
	m_BorderColor = Root.Colors.Red;
	m_pR6RainbowTeamBar = R6MenuSingleTeamBar(CreateWindow(Class'R6Menu.R6MenuSingleTeamBar', m_CodeName.WinLeft, (m_CodeName.WinTop + m_CodeName.WinHeight), float(r6Root.m_REscMenuWidget.W), m_fRainbowStatsHeight, self));
	m_pR6RainbowTeamBar.m_IGPlayerInfoListBox.m_bIgnoreUserClicks = true;
	m_EscObj = R6MenuEscObjectives(CreateWindow(Class'R6Menu.R6MenuEscObjectives', m_pR6RainbowTeamBar.WinLeft, (m_pR6RainbowTeamBar.WinTop + m_pR6RainbowTeamBar.WinHeight), m_pR6RainbowTeamBar.WinWidth, ((m_pInGameNavBar.WinTop - m_pR6RainbowTeamBar.WinTop) - m_pR6RainbowTeamBar.WinHeight)));
	return;
}

function InitTrainingEsc()
{
	local R6MenuInGameRootWindow r6Root;

	r6Root = R6MenuInGameRootWindow(Root);
	m_pInGameNavBar = R6MenuInGameEscSinglePlayerNavBar(CreateWindow(Class'R6Menu.R6MenuInGameEscSinglePlayerNavBar', float(r6Root.m_REscTraining.X), (((float(r6Root.m_REscTraining.Y) + r6Root.m_fTopLabelHeight) + float(r6Root.m_REscTraining.H)) - m_fNavBarHeight), float(r6Root.m_REscTraining.W), m_fNavBarHeight, self));
	m_pInGameNavBar.SetTrainingNavbar();
	return;
}

function ShowWindow()
{
	local R6MissionDescription CurrentMission;
	local R6MenuInGameRootWindow r6Root;

	super(UWindowWindow).ShowWindow();
	r6Root = R6MenuInGameRootWindow(Root);
	// End:0x8D
	if((!r6Root.m_bInEscMenu))
	{
		GetPlayerOwner().SetPause(true);
		GetPlayerOwner().SaveCurrentFadeValue();
		R6PlayerController(GetPlayerOwner()).ClientFadeCommonSound(0.5000000, 0);
		GetPlayerOwner().FadeSound(0.5000000, 0, 5);
		GetPlayerOwner().FadeSound(0.5000000, 0, 7);
	}
	// End:0xA1
	if(r6Root.m_bInTraining)
	{
		return;
	}
	CurrentMission = R6MissionDescription(R6Console(Root.Console).Master.m_StartGameInfo.m_CurrentMission);
	m_CodeName.SetProperties(Localize(CurrentMission.m_MapName, "ID_CODENAME", CurrentMission.LocalizationFile), 2, Root.Fonts[0], Root.Colors.White, false);
	m_DateTime.SetProperties(Localize(CurrentMission.m_MapName, "ID_DATETIME", CurrentMission.LocalizationFile), 2, Root.Fonts[0], Root.Colors.White, false);
	m_Location.SetProperties(Localize(CurrentMission.m_MapName, "ID_LOCATION", CurrentMission.LocalizationFile), 2, Root.Fonts[0], Root.Colors.White, false);
	m_pR6RainbowTeamBar.RefreshTeamBarInfo();
	m_EscObj.UpdateObjectives();
	return;
}

function HideWindow()
{
	local R6MenuInGameRootWindow r6Root;

	super(UWindowWindow).HideWindow();
	r6Root = R6MenuInGameRootWindow(Root);
	// End:0x4D
	if((!r6Root.m_bInEscMenu))
	{
		GetPlayerOwner().SetPause(false);
		GetPlayerOwner().ReturnSavedFadeValue(0.5000000);
	}
	return;
}

defaultproperties
{
	m_fLabelHeight=18.0000000
	m_fNavBarHeight=55.0000000
	m_fRainbowStatsHeight=166.0000000
}
