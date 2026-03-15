//=============================================================================
// R6MenuDebriefNavBar - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6MenuDebriefNavBar.uc : Bottom nav bar in debreifing room
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/06/17 * Created by Alexandre Dionne
//=============================================================================
class R6MenuDebriefNavBar extends UWindowDialogClientWindow;

var float m_fButtonsYPos;
var float m_fMainMenuXPos;
// NEW IN 1.60
var float m_fOptionsXPos;
// NEW IN 1.60
var float m_fActionXPos;
// NEW IN 1.60
var float m_fPlanningXPos;
// NEW IN 1.60
var float m_fContinueXPos;
var R6WindowButton m_MainMenuButton;
// NEW IN 1.60
var R6WindowButton m_OptionsButton;
// NEW IN 1.60
var R6WindowButton m_ActionButton;
// NEW IN 1.60
var R6WindowButton m_PlanningButton;
var R6WindowButton m_ContinueButton;
var Texture m_TMainMenuButton;
// NEW IN 1.60
var Texture m_TOptionsButton;
// NEW IN 1.60
var Texture m_TActionButton;
// NEW IN 1.60
var Texture m_TPlanningButton;
// NEW IN 1.60
var Texture m_TContinueButton;
var Region m_RMainMenuButtonUp;
// NEW IN 1.60
var Region m_RMainMenuButtonDown;
// NEW IN 1.60
var Region m_RMainMenuButtonDisabled;
// NEW IN 1.60
var Region m_RMainMenuButtonOver;
var Region m_ROptionsButtonUp;
// NEW IN 1.60
var Region m_ROptionsButtonDown;
// NEW IN 1.60
var Region m_ROptionsButtonDisabled;
// NEW IN 1.60
var Region m_ROptionsButtonOver;
var Region m_RActionButtonUp;
// NEW IN 1.60
var Region m_RActionButtonDown;
// NEW IN 1.60
var Region m_RActionButtonDisabled;
// NEW IN 1.60
var Region m_RActionButtonOver;
var Region m_RPlanningButtonUp;
// NEW IN 1.60
var Region m_RPlanningButtonDown;
// NEW IN 1.60
var Region m_RPlanningButtonDisabled;
// NEW IN 1.60
var Region m_RPlanningButtonOver;
var Region m_RContinueButtonUp;
// NEW IN 1.60
var Region m_RContinueButtonDown;
// NEW IN 1.60
var Region m_RContinueButtonDisabled;
// NEW IN 1.60
var Region m_RContinueButtonOver;

function Created()
{
	m_MainMenuButton = R6WindowButton(CreateControl(Class'R6Window.R6WindowButton', m_fMainMenuXPos, m_fButtonsYPos, float(m_RMainMenuButtonUp.W), float(m_RMainMenuButtonUp.H), self));
	m_MainMenuButton.UpTexture = m_TMainMenuButton;
	m_MainMenuButton.OverTexture = m_TMainMenuButton;
	m_MainMenuButton.DownTexture = m_TMainMenuButton;
	m_MainMenuButton.DisabledTexture = m_TMainMenuButton;
	m_MainMenuButton.UpRegion = m_RMainMenuButtonUp;
	m_MainMenuButton.OverRegion = m_RMainMenuButtonOver;
	m_MainMenuButton.DownRegion = m_RMainMenuButtonDown;
	m_MainMenuButton.DisabledRegion = m_RMainMenuButtonDisabled;
	m_MainMenuButton.bUseRegion = true;
	m_MainMenuButton.ToolTipString = Localize("ESCMENUS", "MAIN", "R6Menu");
	m_MainMenuButton.m_iDrawStyle = 5;
	m_MainMenuButton.m_bWaitSoundFinish = true;
	m_OptionsButton = R6WindowButton(CreateControl(Class'R6Window.R6WindowButton', m_fOptionsXPos, m_fButtonsYPos, float(m_ROptionsButtonUp.W), float(m_ROptionsButtonUp.H), self));
	m_OptionsButton.UpTexture = m_TOptionsButton;
	m_OptionsButton.OverTexture = m_TOptionsButton;
	m_OptionsButton.DownTexture = m_TOptionsButton;
	m_OptionsButton.DisabledTexture = m_TOptionsButton;
	m_OptionsButton.UpRegion = m_ROptionsButtonUp;
	m_OptionsButton.DownRegion = m_ROptionsButtonDown;
	m_OptionsButton.DisabledRegion = m_ROptionsButtonDisabled;
	m_OptionsButton.OverRegion = m_ROptionsButtonOver;
	m_OptionsButton.bUseRegion = true;
	m_OptionsButton.ToolTipString = Localize("ESCMENUS", "ESCOPTIONS", "R6Menu");
	m_OptionsButton.m_iDrawStyle = 5;
	m_OptionsButton.m_bWaitSoundFinish = true;
	m_ActionButton = R6WindowButton(CreateControl(Class'R6Window.R6WindowButton', m_fActionXPos, m_fButtonsYPos, float(m_RActionButtonUp.W), float(m_RActionButtonUp.H), self));
	m_ActionButton.UpTexture = m_TActionButton;
	m_ActionButton.OverTexture = m_TActionButton;
	m_ActionButton.DownTexture = m_TActionButton;
	m_ActionButton.DisabledTexture = m_TActionButton;
	m_ActionButton.UpRegion = m_RActionButtonUp;
	m_ActionButton.OverRegion = m_RActionButtonOver;
	m_ActionButton.DownRegion = m_RActionButtonDown;
	m_ActionButton.DisabledRegion = m_RActionButtonDisabled;
	m_ActionButton.bUseRegion = true;
	m_ActionButton.ToolTipString = Localize("DebriefingMenu", "ACTION", "R6Menu");
	m_ActionButton.m_iDrawStyle = 5;
	m_ActionButton.m_bWaitSoundFinish = true;
	m_PlanningButton = R6WindowButton(CreateControl(Class'R6Window.R6WindowButton', m_fPlanningXPos, m_fButtonsYPos, float(m_RPlanningButtonUp.W), float(m_RPlanningButtonUp.H), self));
	m_PlanningButton.UpTexture = m_TPlanningButton;
	m_PlanningButton.OverTexture = m_TPlanningButton;
	m_PlanningButton.DownTexture = m_TPlanningButton;
	m_PlanningButton.DisabledTexture = m_TPlanningButton;
	m_PlanningButton.UpRegion = m_RPlanningButtonUp;
	m_PlanningButton.OverRegion = m_RPlanningButtonOver;
	m_PlanningButton.DownRegion = m_RPlanningButtonDown;
	m_PlanningButton.DisabledRegion = m_RPlanningButtonDisabled;
	m_PlanningButton.bUseRegion = true;
	m_PlanningButton.ToolTipString = Localize("DebriefingMenu", "PLAN", "R6Menu");
	m_PlanningButton.m_iDrawStyle = 5;
	m_PlanningButton.m_bWaitSoundFinish = true;
	m_ContinueButton = R6WindowButton(CreateControl(Class'R6Window.R6WindowButton', m_fContinueXPos, m_fButtonsYPos, float(m_RContinueButtonUp.W), float(m_RContinueButtonUp.H), self));
	m_ContinueButton.UpTexture = m_TContinueButton;
	m_ContinueButton.OverTexture = m_TContinueButton;
	m_ContinueButton.DownTexture = m_TContinueButton;
	m_ContinueButton.DisabledTexture = m_TContinueButton;
	m_ContinueButton.UpRegion = m_RContinueButtonUp;
	m_ContinueButton.OverRegion = m_RContinueButtonOver;
	m_ContinueButton.DownRegion = m_RContinueButtonDown;
	m_ContinueButton.DisabledRegion = m_RContinueButtonDisabled;
	m_ContinueButton.bUseRegion = true;
	m_ContinueButton.ToolTipString = Localize("DebriefingMenu", "CONTINUE", "R6Menu");
	m_ContinueButton.m_iDrawStyle = 5;
	m_ContinueButton.m_bWaitSoundFinish = true;
	m_BorderColor = Root.Colors.BlueLight;
	return;
}

function Notify(UWindowDialogControl C, byte E)
{
	local R6GameInfo GameInfo;
	local R6PlayerCampaign MyCampaign;
	local R6FileManagerCampaign pFileManager;

	GameInfo = R6GameInfo(Root.Console.ViewportOwner.Actor.Level.Game);
	// End:0x3D9
	if((int(E) == 2))
	{
		switch(C)
		{
			// End:0xC4
			case m_MainMenuButton:
				R6MenuInGameRootWindow(Root).SimplePopUp(Localize("POPUP", "PopUpTitle_QuitToMain", "R6Menu"), Localize("ESCMENUS", "MAINCONFIRM", "R6Menu"), 50);
				// End:0x3D9
				break;
			// End:0xE0
			case m_OptionsButton:
				Root.ChangeCurrentWidget(16);
				// End:0x3D9
				break;
			// End:0x1A4
			case m_ActionButton:
				// End:0x100
				if(GameInfo.m_bUsingPlayerCampaign)
				{
					DenyMissionOutcome();
				}
				Root.Console.Master.m_StartGameInfo.m_SkipPlanningPhase = true;
				Root.Console.Master.m_StartGameInfo.m_ReloadPlanning = true;
				Root.Console.Master.m_StartGameInfo.m_ReloadActionPointOnly = true;
				R6Console(Root.Console).ResetR6Game();
				// End:0x3D9
				break;
			// End:0x2BA
			case m_PlanningButton:
				Root.Console.Master.m_StartGameInfo.m_SkipPlanningPhase = false;
				Root.Console.Master.m_StartGameInfo.m_ReloadPlanning = true;
				Root.Console.Master.m_StartGameInfo.m_ReloadActionPointOnly = false;
				// End:0x281
				if(GameInfo.m_bUsingPlayerCampaign)
				{
					DenyMissionOutcome();
					R6Console(Root.Console).LeaveR6Game(R6Console(Root.Console).6);					
				}
				else
				{
					R6Console(Root.Console).LeaveR6Game(R6Console(Root.Console).4);
				}
				// End:0x3D9
				break;
			// End:0x3D6
			case m_ContinueButton:
				Root.Console.Master.m_StartGameInfo.m_SkipPlanningPhase = false;
				Root.Console.Master.m_StartGameInfo.m_ReloadPlanning = false;
				Root.Console.Master.m_StartGameInfo.m_ReloadActionPointOnly = false;
				// End:0x39D
				if(GameInfo.m_bUsingPlayerCampaign)
				{
					// End:0x39A
					if((AcceptMissionOutcome() == true))
					{
						R6Console(Root.Console).LeaveR6Game(R6Console(Root.Console).1);
					}					
				}
				else
				{
					R6Console(Root.Console).LeaveR6Game(R6Console(Root.Console).5);
				}
				// End:0x3D9
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

function DenyMissionOutcome()
{
	local R6FileManagerCampaign FileManager;
	local R6PlayerCampaign MyCampaign;

	FileManager = new (none) Class'R6Game.R6FileManagerCampaign';
	MyCampaign = R6Console(Root.Console).m_PlayerCampaign;
	MyCampaign.m_OperativesMissionDetails = none;
	MyCampaign.m_OperativesMissionDetails = new (none) Class'R6Game.R6MissionRoster';
	FileManager.LoadCampaign(MyCampaign);
	return;
}

function Paint(Canvas C, float X, float Y)
{
	DrawSimpleBorder(C);
	C.Style = 5;
	C.SetDrawColor(m_BorderColor.R, m_BorderColor.G, m_BorderColor.B);
	DrawStretchedTextureSegment(C, 120.0000000, 0.0000000, 1.0000000, 33.0000000, float(m_BorderTextureRegion.X), float(m_BorderTextureRegion.Y), float(m_BorderTextureRegion.W), float(m_BorderTextureRegion.H), m_BorderTexture);
	return;
}

function bool AcceptMissionOutcome()
{
	local R6PlayerCampaign MyCampaign;
	local R6FileManagerCampaign pFileManager;
	local R6Console R6Console;

	R6Console = R6Console(Root.Console);
	MyCampaign = R6Console.m_PlayerCampaign;
	pFileManager = new Class'R6Game.R6FileManagerCampaign';
	// End:0xCB
	if((pFileManager.SaveCampaign(MyCampaign) == false))
	{
		R6MenuInGameRootWindow(Root).SimplePopUp(Localize("POPUP", "FILEERROR", "R6Menu"), ((MyCampaign.m_FileName @ ":") @ Localize("POPUP", "FILEERRORPROBLEM", "R6Menu")), 2, int(2));
		return false;
	}
	return true;
	return;
}

defaultproperties
{
	m_fButtonsYPos=1.0000000
	m_fMainMenuXPos=22.0000000
	m_fOptionsXPos=74.0000000
	m_fActionXPos=217.0000000
	m_fPlanningXPos=344.0000000
	m_fContinueXPos=467.0000000
	m_TMainMenuButton=Texture'R6MenuTextures.Gui_01'
	m_TOptionsButton=Texture'R6MenuTextures.Gui_01'
	m_TActionButton=Texture'R6MenuTextures.Gui_01'
	m_TPlanningButton=Texture'R6MenuTextures.Gui_01'
	m_TContinueButton=Texture'R6MenuTextures.Gui_01'
	m_RMainMenuButtonUp=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=28962,ZoneNumber=0)
	m_RMainMenuButtonDown=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=28962,ZoneNumber=0)
	m_RMainMenuButtonDisabled=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=28962,ZoneNumber=0)
	m_RMainMenuButtonOver=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=28962,ZoneNumber=0)
	m_ROptionsButtonUp=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=22306,ZoneNumber=0)
	m_ROptionsButtonDown=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=22306,ZoneNumber=0)
	m_ROptionsButtonDisabled=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=22306,ZoneNumber=0)
	m_ROptionsButtonOver=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=22306,ZoneNumber=0)
	m_RActionButtonUp=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=23842,ZoneNumber=0)
	m_RActionButtonDown=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=23842,ZoneNumber=0)
	m_RActionButtonDisabled=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=23842,ZoneNumber=0)
	m_RActionButtonOver=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=23842,ZoneNumber=0)
	m_RPlanningButtonUp=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=32034,ZoneNumber=0)
	m_RPlanningButtonDown=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=32034,ZoneNumber=0)
	m_RPlanningButtonDisabled=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=32034,ZoneNumber=0)
	m_RPlanningButtonOver=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=32034,ZoneNumber=0)
	m_RContinueButtonUp=(Zone=ObjectProperty'R6Menu.R6MenuMPCreateGameTab.m_pButtonsDef',iLeaf=30754,ZoneNumber=0)
	m_RContinueButtonDown=(Zone=ObjectProperty'R6Menu.R6MenuMPCreateGameTab.m_pButtonsDef',iLeaf=46114,ZoneNumber=0)
	m_RContinueButtonDisabled=(Zone=ObjectProperty'R6Menu.R6MenuMPCreateGameTab.m_pButtonsDef',iLeaf=53794,ZoneNumber=0)
	m_RContinueButtonOver=(Zone=ObjectProperty'R6Menu.R6MenuMPCreateGameTab.m_pButtonsDef',iLeaf=38434,ZoneNumber=0)
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var n
// REMOVED IN 1.60: var d
// REMOVED IN 1.60: var r
// REMOVED IN 1.60: var s
