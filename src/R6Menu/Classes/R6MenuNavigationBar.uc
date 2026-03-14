//=============================================================================
// R6MenuNavigationBar - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6MenuNavigationBar.uc : (add small description)
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/06/26 * Created by Alexandre Dionne
//=============================================================================
class R6MenuNavigationBar extends UWindowDialogClientWindow;

var int m_iNavBarLocation[9];
var int m_iBigButtonHeight;
var R6WindowButton m_MainMenuButton;
// NEW IN 1.60
var R6WindowButton m_OptionsButton;
// NEW IN 1.60
var R6WindowButton m_BriefingButton;
// NEW IN 1.60
var R6WindowButton m_GearButton;
// NEW IN 1.60
var R6WindowButton m_PlanningButton;
// NEW IN 1.60
var R6WindowButton m_PlayButton;
// NEW IN 1.60
var R6WindowButton m_SaveButton;
// NEW IN 1.60
var R6WindowButton m_LoadButton;
// NEW IN 1.60
var R6WindowButton m_QuickPlayButton;
var Texture m_TMainMenuTexture;
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
var Region m_RBriefingButtonUp;
// NEW IN 1.60
var Region m_RBriefingButtonDown;
// NEW IN 1.60
var Region m_RBriefingButtonDisabled;
// NEW IN 1.60
var Region m_RBriefingButtonOver;
var Region m_RGearButtonUp;
// NEW IN 1.60
var Region m_RGearButtonDown;
// NEW IN 1.60
var Region m_RGearButtonDisabled;
// NEW IN 1.60
var Region m_RGearButtonOver;
var Region m_RPlanningButtonUp;
// NEW IN 1.60
var Region m_RPlanningButtonDown;
// NEW IN 1.60
var Region m_RPlanningButtonDisabled;
// NEW IN 1.60
var Region m_RPlanningButtonOver;
var Region m_RPlayButtonUp;
// NEW IN 1.60
var Region m_RPlayButtonDown;
// NEW IN 1.60
var Region m_RPlayButtonDisabled;
// NEW IN 1.60
var Region m_RPlayButtonOver;
var Region m_RSaveButtonUp;
// NEW IN 1.60
var Region m_RSaveButtonDown;
// NEW IN 1.60
var Region m_RSaveButtonDisabled;
// NEW IN 1.60
var Region m_RSaveButtonOver;
var Region m_RLoadButtonUp;
// NEW IN 1.60
var Region m_RLoadButtonDown;
// NEW IN 1.60
var Region m_RLoadButtonDisabled;
// NEW IN 1.60
var Region m_RLoadButtonOver;
var Region m_RQuickPlayButtonUp;
// NEW IN 1.60
var Region m_RQuickPlayButtonDown;
// NEW IN 1.60
var Region m_RQuickPlayButtonDisabled;
// NEW IN 1.60
var Region m_RQuickPlayButtonOver;

function Created()
{
	m_MainMenuButton = R6WindowButton(CreateControl(Class'R6Window.R6WindowButton', float(m_iNavBarLocation[0]), float(m_iBigButtonHeight), float(m_RMainMenuButtonUp.W), float(m_RMainMenuButtonUp.H), self));
	m_MainMenuButton.UpTexture = m_TMainMenuTexture;
	m_MainMenuButton.OverTexture = m_TMainMenuTexture;
	m_MainMenuButton.DownTexture = m_TMainMenuTexture;
	m_MainMenuButton.DisabledTexture = m_TMainMenuTexture;
	m_MainMenuButton.UpRegion = m_RMainMenuButtonUp;
	m_MainMenuButton.OverRegion = m_RMainMenuButtonOver;
	m_MainMenuButton.DownRegion = m_RMainMenuButtonDown;
	m_MainMenuButton.DisabledRegion = m_RMainMenuButtonDisabled;
	m_MainMenuButton.bUseRegion = true;
	m_MainMenuButton.ToolTipString = Localize("PlanningMenu", "Home", "R6Menu");
	m_MainMenuButton.m_iDrawStyle = 5;
	m_OptionsButton = R6WindowButton(CreateControl(Class'R6Window.R6WindowButton', float(m_iNavBarLocation[1]), float(m_iBigButtonHeight), float(m_ROptionsButtonUp.W), float(m_ROptionsButtonUp.H), self));
	m_OptionsButton.UpTexture = m_TMainMenuTexture;
	m_OptionsButton.OverTexture = m_TMainMenuTexture;
	m_OptionsButton.DownTexture = m_TMainMenuTexture;
	m_OptionsButton.DisabledTexture = m_TMainMenuTexture;
	m_OptionsButton.UpRegion = m_ROptionsButtonUp;
	m_OptionsButton.DownRegion = m_ROptionsButtonDown;
	m_OptionsButton.DisabledRegion = m_ROptionsButtonDisabled;
	m_OptionsButton.OverRegion = m_ROptionsButtonOver;
	m_OptionsButton.bUseRegion = true;
	m_OptionsButton.ToolTipString = Localize("PlanningMenu", "Option", "R6Menu");
	m_OptionsButton.m_iDrawStyle = 5;
	m_BriefingButton = R6WindowButton(CreateControl(Class'R6Window.R6WindowButton', float(m_iNavBarLocation[2]), float(m_iBigButtonHeight), float(m_RBriefingButtonUp.W), float(m_RBriefingButtonUp.H), self));
	m_BriefingButton.UpTexture = m_TMainMenuTexture;
	m_BriefingButton.OverTexture = m_TMainMenuTexture;
	m_BriefingButton.DownTexture = m_TMainMenuTexture;
	m_BriefingButton.DisabledTexture = m_TMainMenuTexture;
	m_BriefingButton.UpRegion = m_RBriefingButtonUp;
	m_BriefingButton.OverRegion = m_RBriefingButtonOver;
	m_BriefingButton.DownRegion = m_RBriefingButtonDown;
	m_BriefingButton.DisabledRegion = m_RBriefingButtonDisabled;
	m_BriefingButton.bUseRegion = true;
	m_BriefingButton.ToolTipString = Localize("PlanningMenu", "Breifing", "R6Menu");
	m_BriefingButton.m_iDrawStyle = 5;
	m_GearButton = R6WindowButton(CreateControl(Class'R6Window.R6WindowButton', float(m_iNavBarLocation[3]), float(m_iBigButtonHeight), float(m_RGearButtonUp.W), float(m_RGearButtonUp.H), self));
	m_GearButton.UpTexture = m_TMainMenuTexture;
	m_GearButton.OverTexture = m_TMainMenuTexture;
	m_GearButton.DownTexture = m_TMainMenuTexture;
	m_GearButton.DisabledTexture = m_TMainMenuTexture;
	m_GearButton.UpRegion = m_RGearButtonUp;
	m_GearButton.OverRegion = m_RGearButtonOver;
	m_GearButton.DownRegion = m_RGearButtonDown;
	m_GearButton.DisabledRegion = m_RGearButtonDisabled;
	m_GearButton.bUseRegion = true;
	m_GearButton.ToolTipString = Localize("PlanningMenu", "Gear", "R6Menu");
	m_GearButton.m_iDrawStyle = 5;
	m_PlanningButton = R6WindowButton(CreateControl(Class'R6Window.R6WindowButton', float(m_iNavBarLocation[4]), float(m_iBigButtonHeight), float(m_RPlanningButtonUp.W), float(m_RPlanningButtonUp.H), self));
	m_PlanningButton.UpTexture = m_TMainMenuTexture;
	m_PlanningButton.OverTexture = m_TMainMenuTexture;
	m_PlanningButton.DownTexture = m_TMainMenuTexture;
	m_PlanningButton.DisabledTexture = m_TMainMenuTexture;
	m_PlanningButton.UpRegion = m_RPlanningButtonUp;
	m_PlanningButton.OverRegion = m_RPlanningButtonOver;
	m_PlanningButton.DownRegion = m_RPlanningButtonDown;
	m_PlanningButton.DisabledRegion = m_RPlanningButtonDisabled;
	m_PlanningButton.bUseRegion = true;
	m_PlanningButton.ToolTipString = Localize("PlanningMenu", "Planning", "R6Menu");
	m_PlanningButton.m_iDrawStyle = 5;
	m_PlayButton = R6WindowButton(CreateControl(Class'R6Window.R6WindowButton', float(m_iNavBarLocation[5]), float(m_iBigButtonHeight), float(m_RPlayButtonUp.W), float(m_RPlayButtonUp.H), self));
	m_PlayButton.UpTexture = m_TMainMenuTexture;
	m_PlayButton.OverTexture = m_TMainMenuTexture;
	m_PlayButton.DownTexture = m_TMainMenuTexture;
	m_PlayButton.DisabledTexture = m_TMainMenuTexture;
	m_PlayButton.UpRegion = m_RPlayButtonUp;
	m_PlayButton.OverRegion = m_RPlayButtonOver;
	m_PlayButton.DownRegion = m_RPlayButtonDown;
	m_PlayButton.DisabledRegion = m_RPlayButtonDisabled;
	m_PlayButton.bUseRegion = true;
	m_PlayButton.ToolTipString = Localize("PlanningMenu", "Play", "R6Menu");
	m_PlayButton.m_iDrawStyle = 5;
	m_SaveButton = R6WindowButton(CreateControl(Class'R6Window.R6WindowButton', float(m_iNavBarLocation[6]), float(m_iBigButtonHeight), float(m_RSaveButtonUp.W), float(m_RSaveButtonUp.H), self));
	m_SaveButton.UpTexture = m_TMainMenuTexture;
	m_SaveButton.OverTexture = m_TMainMenuTexture;
	m_SaveButton.DownTexture = m_TMainMenuTexture;
	m_SaveButton.DisabledTexture = m_TMainMenuTexture;
	m_SaveButton.UpRegion = m_RSaveButtonUp;
	m_SaveButton.OverRegion = m_RSaveButtonOver;
	m_SaveButton.DownRegion = m_RSaveButtonDown;
	m_SaveButton.DisabledRegion = m_RSaveButtonDisabled;
	m_SaveButton.bUseRegion = true;
	m_SaveButton.ToolTipString = Localize("PlanningMenu", "Save", "R6Menu");
	m_SaveButton.m_iDrawStyle = 5;
	m_LoadButton = R6WindowButton(CreateControl(Class'R6Window.R6WindowButton', float(m_iNavBarLocation[7]), float(m_iBigButtonHeight), float(m_RSaveButtonUp.W), float(m_RSaveButtonUp.H), self));
	m_LoadButton.UpTexture = m_TMainMenuTexture;
	m_LoadButton.OverTexture = m_TMainMenuTexture;
	m_LoadButton.DownTexture = m_TMainMenuTexture;
	m_LoadButton.DisabledTexture = m_TMainMenuTexture;
	m_LoadButton.UpRegion = m_RLoadButtonUp;
	m_LoadButton.OverRegion = m_RLoadButtonOver;
	m_LoadButton.DownRegion = m_RLoadButtonDown;
	m_LoadButton.DisabledRegion = m_RLoadButtonDisabled;
	m_LoadButton.bUseRegion = true;
	m_LoadButton.ToolTipString = Localize("PlanningMenu", "Load", "R6Menu");
	m_LoadButton.m_iDrawStyle = 5;
	m_QuickPlayButton = R6WindowButton(CreateControl(Class'R6Window.R6WindowButton', float(m_iNavBarLocation[8]), float(m_iBigButtonHeight), float(m_RQuickPlayButtonUp.W), float(m_RQuickPlayButtonUp.H), self));
	m_QuickPlayButton.UpTexture = m_TMainMenuTexture;
	m_QuickPlayButton.OverTexture = m_TMainMenuTexture;
	m_QuickPlayButton.DownTexture = m_TMainMenuTexture;
	m_QuickPlayButton.DisabledTexture = m_TMainMenuTexture;
	m_QuickPlayButton.UpRegion = m_RQuickPlayButtonUp;
	m_QuickPlayButton.OverRegion = m_RQuickPlayButtonOver;
	m_QuickPlayButton.DownRegion = m_RQuickPlayButtonDown;
	m_QuickPlayButton.DisabledRegion = m_RQuickPlayButtonDisabled;
	m_QuickPlayButton.bUseRegion = true;
	m_QuickPlayButton.ToolTipString = Localize("PlanningMenu", "QuickPlay", "R6Menu");
	m_QuickPlayButton.m_iDrawStyle = 5;
	m_BorderColor = Root.Colors.BlueLight;
	return;
}

function Notify(UWindowDialogControl C, byte E)
{
	local R6MenuRootWindow r6Root;
	local R6GameOptions pGameOptions;

	// End:0x392
	if(__NFUN_154__(int(E), 2))
	{
		r6Root = R6MenuRootWindow(Root);
		switch(C)
		{
			// End:0xB0
			case m_MainMenuButton:
				r6Root.StopPlayMode();
				r6Root.ClosePopups();
				r6Root.SimplePopUp(Localize("POPUP", "PopUpTitle_QuitToMain", "R6Menu"), Localize("ESCMENUS", "MAINCONFIRM", "R6Menu"), 46);
				// End:0x392
				break;
			// End:0xCC
			case m_OptionsButton:
				r6Root.ChangeCurrentWidget(16);
				// End:0x392
				break;
			// End:0xE8
			case m_BriefingButton:
				r6Root.ChangeCurrentWidget(8);
				// End:0x392
				break;
			// End:0x104
			case m_GearButton:
				r6Root.ChangeCurrentWidget(12);
				// End:0x392
				break;
			// End:0x120
			case m_PlanningButton:
				r6Root.ChangeCurrentWidget(9);
				// End:0x392
				break;
			// End:0x210
			case m_PlayButton:
				// End:0x181
				if(r6Root.m_GearRoomWidget.IsTeamConfigValid())
				{
					r6Root.m_PlanningWidget.m_PlanningBar.m_TimeLine.Reset();
					Root.ChangeCurrentWidget(13);					
				}
				else
				{
					r6Root.StopPlayMode();
					r6Root.ClosePopups();
					r6Root.SimplePopUp(Localize("POPUP", "INCOMPLETEPLANNING", "R6Menu"), Localize("POPUP", "INCOMPLETEPLANNINGPROBLEM", "R6Menu"), 49, int(2));
				}
				// End:0x392
				break;
			// End:0x259
			case m_SaveButton:
				r6Root.StopPlayMode();
				r6Root.ClosePopups();
				r6Root.m_ePopUpID = 47;
				r6Root.PopUpMenu();
				// End:0x392
				break;
			// End:0x2A2
			case m_LoadButton:
				r6Root.StopPlayMode();
				r6Root.ClosePopups();
				r6Root.m_ePopUpID = 48;
				r6Root.PopUpMenu();
				// End:0x392
				break;
			// End:0x38F
			case m_QuickPlayButton:
				r6Root.ClosePopups();
				pGameOptions = Class'Engine.Actor'.static.__NFUN_1009__();
				// End:0x37D
				if(__NFUN_130__(__NFUN_242__(pGameOptions.PopUpQuickPlay, true), __NFUN_132__(r6Root.m_GearRoomWidget.IsTeamConfigValid(), __NFUN_242__(r6Root.IsPlanningEmpty(), false))))
				{
					r6Root.SimplePopUp(Localize("POPUP", "PopUpTitle_QuiPlay", "R6Menu"), Localize("POPUP", "PopUpMsg_QuiPlay", "R6Menu"), 39, int(0), true);					
				}
				else
				{
					r6Root.LaunchQuickPlay();
				}
				// End:0x392
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
	R6MenuRSLookAndFeel(LookAndFeel).DrawNavigationBar(self, C);
	return;
}

defaultproperties
{
	m_iNavBarLocation[0]=22
	m_iNavBarLocation[1]=74
	m_iNavBarLocation[2]=170
	m_iNavBarLocation[3]=252
	m_iNavBarLocation[4]=338
	m_iNavBarLocation[5]=420
	m_iNavBarLocation[6]=466
	m_iNavBarLocation[7]=510
	m_iNavBarLocation[8]=559
	m_iBigButtonHeight=1
	m_TMainMenuTexture=Texture'R6MenuTextures.Gui_01'
	m_RMainMenuButtonUp=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=28962,ZoneNumber=0)
	m_RMainMenuButtonDown=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=28962,ZoneNumber=0)
	m_RMainMenuButtonDisabled=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=28962,ZoneNumber=0)
	m_RMainMenuButtonOver=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=28962,ZoneNumber=0)
	m_ROptionsButtonUp=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=22306,ZoneNumber=0)
	m_ROptionsButtonDown=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=22306,ZoneNumber=0)
	m_ROptionsButtonDisabled=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=22306,ZoneNumber=0)
	m_ROptionsButtonOver=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=22306,ZoneNumber=0)
	m_RBriefingButtonUp=(Zone=Class'R6Menu.R6MenuRootWindow',iLeaf=7714,ZoneNumber=0)
	m_RBriefingButtonDown=(Zone=ObjectProperty'R6Menu.R6MenuMPCreateGameTab.m_pButtonsDef',iLeaf=15394,ZoneNumber=0)
	m_RBriefingButtonDisabled=(Zone=ObjectProperty'R6Menu.R6MenuMPCreateGameTab.m_pButtonsDef',iLeaf=23074,ZoneNumber=0)
	m_RBriefingButtonOver=(Zone=ObjectProperty'R6Menu.R6MenuMPCreateGameTab.m_pButtonsDef',iLeaf=7714,ZoneNumber=0)
	m_RGearButtonUp=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=7714,ZoneNumber=0)
	m_RGearButtonDown=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=7714,ZoneNumber=0)
	m_RGearButtonDisabled=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=7714,ZoneNumber=0)
	m_RGearButtonOver=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=7714,ZoneNumber=0)
	m_RPlanningButtonUp=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=16418,ZoneNumber=0)
	m_RPlanningButtonDown=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=16418,ZoneNumber=0)
	m_RPlanningButtonDisabled=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=16418,ZoneNumber=0)
	m_RPlanningButtonOver=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=16418,ZoneNumber=0)
	m_RPlayButtonUp=(Zone=ObjectProperty'R6Menu.R6MenuMPCreateGameTab.m_pButtonsDef',iLeaf=30754,ZoneNumber=0)
	m_RPlayButtonDown=(Zone=ObjectProperty'R6Menu.R6MenuMPCreateGameTab.m_pButtonsDef',iLeaf=46114,ZoneNumber=0)
	m_RPlayButtonDisabled=(Zone=ObjectProperty'R6Menu.R6MenuMPCreateGameTab.m_pButtonsDef',iLeaf=53794,ZoneNumber=0)
	m_RPlayButtonOver=(Zone=ObjectProperty'R6Menu.R6MenuMPCreateGameTab.m_pButtonsDef',iLeaf=38434,ZoneNumber=0)
	m_RSaveButtonUp=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=44322,ZoneNumber=0)
	m_RSaveButtonDown=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=44322,ZoneNumber=0)
	m_RSaveButtonDisabled=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=44322,ZoneNumber=0)
	m_RSaveButtonOver=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=44322,ZoneNumber=0)
	m_RLoadButtonUp=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=36642,ZoneNumber=0)
	m_RLoadButtonDown=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=36642,ZoneNumber=0)
	m_RLoadButtonDisabled=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=36642,ZoneNumber=0)
	m_RLoadButtonOver=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=36642,ZoneNumber=0)
	m_RQuickPlayButtonUp=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=13346,ZoneNumber=0)
	m_RQuickPlayButtonDown=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=13346,ZoneNumber=0)
	m_RQuickPlayButtonDisabled=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=13346,ZoneNumber=0)
	m_RQuickPlayButtonOver=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=13346,ZoneNumber=0)
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var n
// REMOVED IN 1.60: var d
// REMOVED IN 1.60: var r
