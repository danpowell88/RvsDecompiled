//=============================================================================
// R6MenuMainWidget - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6MenuMainWidget.uc : Game Main Menu
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//	Main Menu
//
//  Revision history:
//    2001/11/08 * Created by Alexandre Dionne
//=============================================================================
class R6MenuMainWidget extends R6MenuWidget;

var float m_fButtonXpos;
// NEW IN 1.60
var float m_fButtonWidth;
// NEW IN 1.60
var float m_fButtonHeight;
// NEW IN 1.60
var float m_fFirstButtonYpos;
// NEW IN 1.60
var float m_fButtonOffset;
var R6WindowButtonMainMenu m_ButtonSinglePlayer;
var R6WindowButtonMainMenu m_ButtonCustomMission;
var R6WindowButtonMainMenu m_ButtonMultiPlayer;
var R6WindowButtonMainMenu m_ButtonTraining;
var R6WindowButtonMainMenu m_ButtonOption;
var R6WindowButtonMainMenu m_ButtonCredits;
var R6WindowButtonMainMenu m_ButtonQuit;
var R6WindowTextLabel m_Version;

function Created()
{
	local int iRand;
	local R6GameOptions pGameOptions;

	pGameOptions = Class'Engine.Actor'.static.GetGameOptions();
	// End:0x30
	if(pGameOptions.AutoPatchDownload)
	{
		Class'R6GameService.eviLPatchService'.static.StartPatch();
	}
	m_ButtonSinglePlayer = R6WindowButtonMainMenu(CreateWindow(Class'R6Menu.R6WindowButtonMainMenu', m_fButtonXpos, m_fFirstButtonYpos, m_fButtonWidth, m_fButtonHeight, self));
	m_ButtonSinglePlayer.ToolTipString = Localize("MainMenu", "ButtonSinglePlayer", "R6Menu");
	m_ButtonSinglePlayer.Text = Localize("MainMenu", "ButtonSinglePlayer", "R6Menu");
	m_ButtonSinglePlayer.m_eButton_Action = 0;
	m_ButtonSinglePlayer.Align = 1;
	m_ButtonSinglePlayer.m_buttonFont = Root.Fonts[14];
	m_ButtonSinglePlayer.ResizeToText();
	m_ButtonCustomMission = R6WindowButtonMainMenu(CreateWindow(Class'R6Menu.R6WindowButtonMainMenu', m_fButtonXpos, (m_ButtonSinglePlayer.WinTop + m_fButtonOffset), m_fButtonWidth, m_fButtonHeight, self));
	m_ButtonCustomMission.ToolTipString = Localize("MainMenu", "ButtonCustomMission", "R6Menu");
	m_ButtonCustomMission.Text = Localize("MainMenu", "ButtonCustomMission", "R6Menu");
	m_ButtonCustomMission.m_eButton_Action = 1;
	m_ButtonCustomMission.Align = 1;
	m_ButtonCustomMission.m_buttonFont = Root.Fonts[14];
	m_ButtonCustomMission.ResizeToText();
	m_ButtonMultiPlayer = R6WindowButtonMainMenu(CreateWindow(Class'R6Menu.R6WindowButtonMainMenu', m_fButtonXpos, (m_ButtonCustomMission.WinTop + m_fButtonOffset), m_fButtonWidth, m_fButtonHeight, self));
	m_ButtonMultiPlayer.ToolTipString = Localize("MainMenu", "ButtonMultiPlayer", "R6Menu");
	m_ButtonMultiPlayer.Text = Localize("MainMenu", "ButtonMultiPlayer", "R6Menu");
	m_ButtonMultiPlayer.m_eButton_Action = 2;
	m_ButtonMultiPlayer.Align = 1;
	m_ButtonMultiPlayer.m_buttonFont = Root.Fonts[14];
	m_ButtonMultiPlayer.ResizeToText();
	m_ButtonTraining = R6WindowButtonMainMenu(CreateWindow(Class'R6Menu.R6WindowButtonMainMenu', m_fButtonXpos, (m_ButtonMultiPlayer.WinTop + m_fButtonOffset), m_fButtonWidth, m_fButtonHeight, self));
	m_ButtonTraining.ToolTipString = Localize("MainMenu", "ButtonTraining", "R6Menu");
	m_ButtonTraining.Text = Localize("MainMenu", "ButtonTraining", "R6Menu");
	m_ButtonTraining.m_eButton_Action = 3;
	m_ButtonTraining.Align = 1;
	m_ButtonTraining.m_buttonFont = Root.Fonts[14];
	m_ButtonTraining.ResizeToText();
	m_ButtonOption = R6WindowButtonMainMenu(CreateWindow(Class'R6Menu.R6WindowButtonMainMenu', m_fButtonXpos, (m_ButtonTraining.WinTop + m_fButtonOffset), m_fButtonWidth, m_fButtonHeight, self));
	m_ButtonOption.ToolTipString = Localize("MainMenu", "ButtonOptions", "R6Menu");
	m_ButtonOption.Text = Localize("MainMenu", "ButtonOptions", "R6Menu");
	m_ButtonOption.m_eButton_Action = 4;
	m_ButtonOption.Align = 1;
	m_ButtonOption.m_buttonFont = Root.Fonts[14];
	m_ButtonOption.ResizeToText();
	m_ButtonCredits = R6WindowButtonMainMenu(CreateWindow(Class'R6Menu.R6WindowButtonMainMenu', m_fButtonXpos, (m_ButtonOption.WinTop + m_fButtonOffset), m_fButtonWidth, m_fButtonHeight, self));
	m_ButtonCredits.ToolTipString = Localize("MainMenu", "ButtonCredits", "R6Menu");
	m_ButtonCredits.Text = Localize("MainMenu", "ButtonCredits", "R6Menu");
	m_ButtonCredits.m_eButton_Action = 6;
	m_ButtonCredits.Align = 1;
	m_ButtonCredits.m_buttonFont = Root.Fonts[14];
	m_ButtonCredits.ResizeToText();
	m_ButtonQuit = R6WindowButtonMainMenu(CreateWindow(Class'R6Menu.R6WindowButtonMainMenu', m_fButtonXpos, (m_ButtonCredits.WinTop + m_fButtonOffset), m_fButtonWidth, m_fButtonHeight, self));
	m_ButtonQuit.ToolTipString = Localize("MainMenu", "ButtonQuit", "R6Menu");
	m_ButtonQuit.Text = Localize("MainMenu", "ButtonQuit", "R6Menu");
	m_ButtonQuit.m_eButton_Action = 7;
	m_ButtonQuit.Align = 1;
	m_ButtonQuit.m_buttonFont = Root.Fonts[14];
	m_ButtonQuit.ResizeToText();
	m_Version = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', 421.0000000, (WinHeight - float(18)), 200.0000000, 15.0000000, self));
	m_Version.SetProperties(Class'Engine.Actor'.static.GetGameVersion(true), 1, Root.Fonts[10], Root.Colors.White, false);
	return;
}

function Paint(Canvas C, float X, float Y)
{
	Root.PaintBackground(C, self);
	return;
}

function ShowWindow()
{
	Root.SetLoadRandomBackgroundImage("");
	super(UWindowWindow).ShowWindow();
	return;
}

defaultproperties
{
	m_fButtonXpos=371.0000000
	m_fButtonWidth=250.0000000
	m_fButtonHeight=35.0000000
	m_fFirstButtonYpos=166.0000000
	m_fButtonOffset=35.0000000
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var h
// REMOVED IN 1.60: var t
// REMOVED IN 1.60: var s
