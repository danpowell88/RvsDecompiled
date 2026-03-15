//=============================================================================
// R6MenuOptionsWidget - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6MenuOptionsWidget.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/11/22 * Created by Alexandre Dionne
//=============================================================================
class R6MenuOptionsWidget extends R6MenuWidget;

const C_fXSTARTPOS = 198;
const C_fYSTARTPOS = 101;
const C_fWINDOWWIDTH = 422;
const C_fWINDOWHEIGHT = 321;
const C_fHEIGHT_OF_LABELW = 30;
const C_iARBITRARY_COUNTER = 10;

enum eOptionsWindow
{
	OW_Game,                        // 0
	OW_Sound,                       // 1
	OW_Graphic,                     // 2
	OW_Hud,                         // 3
	OW_Multiplayer,                 // 4
	OW_Controls,                    // 5
	OW_MOD,                         // 6
	OW_PatchService                 // 7
};

struct stOptionsPage
{
// NEW IN 1.60
	var UWindowWindow pOptionsPage;
// NEW IN 1.60
	var R6WindowButtonOptions pAssociateButton;
// NEW IN 1.60
	var string szPageTitle;
// NEW IN 1.60
	var R6MenuOptionsWidget.eOptionsWindow ePageID;
};

// NEW IN 1.60
var R6MenuOptionsWidget.eOptionsWindow m_eCurrentPageDisplay;
var bool m_bInGame;
var R6WindowTextLabelCurved m_pOptionsTextLabel;  // the text label of the window option
var R6WindowTextLabel m_LMenuTitle;  // the title
var R6WindowSimpleFramedWindowExt m_pOptionsBorder;  // the border of the option window
var R6MenuHelpWindow m_pHelpWindow;  // the help window (tooltip)
var R6WindowButtonOptions m_ButtonReturn;
var R6WindowButtonOptions m_ButtonGame;
var R6WindowButtonOptions m_ButtonSound;
var R6WindowButtonOptions m_ButtonGraphic;
var R6WindowButtonOptions m_ButtonHudFilter;
var R6WindowButtonOptions m_ButtonMultiPlayer;
var R6WindowButtonOptions m_ButtonControls;
var R6WindowButtonOptions m_ButtonMODS;
var R6WindowButtonOptions m_ButtonPatchService;
var Font m_SmallButtonFont;
// NEW IN 1.60
var array<stOptionsPage> m_AListOptionsPages;
var string m_sDisplayLOGO;

function Created()
{
	// End:0x2A
	if(((R6MenuInGameMultiPlayerRootWindow(Root) != none) || (R6MenuInGameRootWindow(Root) != none)))
	{
		m_bInGame = true;
	}
	GetRegistryKey("SOFTWARE\\Red Storm Entertainment\\RAVENSHIELD", "DisplayLOGO", m_sDisplayLOGO);
	InitTitle();
	InitOptionsButtons();
	InitOptionsWindow();
	m_pHelpWindow = R6MenuHelpWindow(CreateWindow(Class'R6Menu.R6MenuHelpWindow', 150.0000000, 429.0000000, 340.0000000, 42.0000000, self));
	return;
}

function Paint(Canvas C, float X, float Y)
{
	Root.PaintBackground(C, self);
	// End:0xCD
	if(m_ButtonGraphic.m_bSelected)
	{
		C.Style = 5;
		// End:0x82
		if((m_sDisplayLOGO ~= "New"))
		{
			DrawStretchedTextureSegment(C, 544.0000000, 436.0000000, 64.0000000, 64.0000000, 0.0000000, 0.0000000, 64.0000000, 64.0000000, Texture'R6Characters_T.Rainbow.R6armpatch');			
		}
		else
		{
			// End:0x95
			if((m_sDisplayLOGO ~= "None"))
			{				
			}
			else
			{
				DrawStretchedTextureSegment(C, 544.0000000, 436.0000000, 64.0000000, 64.0000000, 0.0000000, 0.0000000, 64.0000000, 64.0000000, Texture'R6MenuTextures.ATI_menus');
			}
		}
	}
	return;
}

function ShowWindow()
{
	Root.SetLoadRandomBackgroundImage("Option");
	// End:0x96
	if((!m_bInGame))
	{
		m_ButtonMODS.bDisabled = (R6MenuRootWindow(Root).IsInsidePlanning() || R6Console(Root.Console).m_bStartedByGSClient);
		// End:0x96
		if((m_ButtonMODS.bDisabled && (int(m_eCurrentPageDisplay) == int(6))))
		{
			ManageOptionsSelection(int(0));
		}
	}
	super(UWindowWindow).ShowWindow();
	return;
}

function HideWindow()
{
	super(UWindowWindow).HideWindow();
	Root.ActivateWindow(0, false);
	return;
}

/////////////////////////////////////////////////////////////////
// display the help text in the m_pHelpTextWindow (derivate for uwindowwindow
/////////////////////////////////////////////////////////////////
function ToolTip(string strTip)
{
	m_pHelpWindow.ToolTip(strTip);
	return;
}

function ManageOptionsSelection(int _OptionsChoice)
{
	local R6MenuOptionsWidget.eOptionsWindow eCurrentPageDisplay;
	local int i;

	eCurrentPageDisplay = m_eCurrentPageDisplay;
	i = 0;
	J0x12:

	// End:0x113 [Loop If]
	if((i < m_AListOptionsPages.Length))
	{
		m_AListOptionsPages[i].pAssociateButton.m_bSelected = false;
		// End:0x76
		if((int(m_AListOptionsPages[i].ePageID) == int(m_eCurrentPageDisplay)))
		{
			m_AListOptionsPages[i].pOptionsPage.HideWindow();
		}
		// End:0x109
		if((int(m_AListOptionsPages[i].ePageID) == _OptionsChoice))
		{
			m_AListOptionsPages[i].pAssociateButton.m_bSelected = true;
			eCurrentPageDisplay = m_AListOptionsPages[i].ePageID;
			// End:0xEF
			if((m_pOptionsTextLabel != none))
			{
				m_pOptionsTextLabel.SetNewText(m_AListOptionsPages[i].szPageTitle, true);
			}
			m_AListOptionsPages[i].pOptionsPage.ShowWindow();
		}
		(i++);
		// [Loop Continue]
		goto J0x12;
	}
	m_eCurrentPageDisplay = eCurrentPageDisplay;
	return;
}

//=============================================================================================
// UpdateOptions: Update the options that's are not change directly in R6MenuOptionsTab
//=============================================================================================
function UpdateOptions()
{
	local int i;
	local R6GameOptions pGameOptions;

	pGameOptions = Class'Engine.Actor'.static.GetGameOptions();
	i = 0;
	J0x19:

	// End:0x52 [Loop If]
	if((i < m_AListOptionsPages.Length))
	{
		R6MenuOptionsTab(m_AListOptionsPages[i].pOptionsPage).UpdateOptionsInEngine();
		(i++);
		// [Loop Continue]
		goto J0x19;
	}
	pGameOptions.m_bChangeResolution = (m_bInGame && (!Root.m_bWidgetResolutionFix));
	pGameOptions.SaveConfig();
	GetPlayerOwner().SetSoundOptions();
	GetPlayerOwner().UpdateOptions();
	// End:0x126
	if(m_bInGame)
	{
		R6HUD(GetPlayerOwner().myHUD).UpdateHudFilter();
		R6PlayerController(GetPlayerOwner()).UpdateTriggerLagInfo();
		// End:0x126
		if((!Root.m_bWidgetResolutionFix))
		{
			Root.SetResolution(float(pGameOptions.R6ScreenSizeX), float(pGameOptions.R6ScreenSizeY));
		}
	}
	return;
}

//=============================================================================================
// RefreshOptions: Refresh the options only when this window is activated
//=============================================================================================
function RefreshOptions()
{
	local int i;
	local R6GameOptions pGameOptions;

	pGameOptions = Class'Engine.Actor'.static.GetGameOptions();
	i = 0;
	J0x19:

	// End:0x52 [Loop If]
	if((i < m_AListOptionsPages.Length))
	{
		R6MenuOptionsTab(m_AListOptionsPages[i].pOptionsPage).UpdateOptionsInPage();
		(i++);
		// [Loop Continue]
		goto J0x19;
	}
	return;
}

//===========================================================================================
// MenuLoadProfile: A new profiles is load, refresh the options
//===========================================================================================
function MenuOptionsLoadProfile()
{
	RefreshOptions();
	UpdateOptions();
	return;
}

//*********************************
//      INIT CREATE FUNCTION
//*********************************
function InitTitle()
{
	m_LMenuTitle = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', 0.0000000, 18.0000000, (WinWidth - float(8)), 25.0000000, self));
	m_LMenuTitle.Text = Localize("Options", "Title", "R6Menu");
	m_LMenuTitle.Align = 1;
	m_LMenuTitle.m_Font = Root.Fonts[4];
	m_LMenuTitle.m_BGTexture = none;
	m_LMenuTitle.m_bDrawBorders = false;
	return;
}

function InitOptionsWindow()
{
	Class'Engine.Actor'.static.GetGameOptions().m_bChangeResolution = m_bInGame;
	m_pOptionsTextLabel = R6WindowTextLabelCurved(CreateWindow(Class'R6Window.R6WindowTextLabelCurved', 198.0000000, ((101.0000000 - float(30)) + float(1)), 422.0000000, 30.0000000, self));
	m_pOptionsTextLabel.bAlwaysBehind = true;
	m_pOptionsTextLabel.Align = 2;
	m_pOptionsTextLabel.m_Font = Root.Fonts[5];
	m_pOptionsBorder = R6WindowSimpleFramedWindowExt(CreateWindow(Class'R6Window.R6WindowSimpleFramedWindowExt', 198.0000000, 101.0000000, 422.0000000, 321.0000000, self));
	m_pOptionsBorder.bAlwaysBehind = true;
	m_pOptionsBorder.ActiveBorder(0, false);
	m_pOptionsBorder.SetBorderParam(1, 7.0000000, 0.0000000, 1.0000000, Root.Colors.White);
	m_pOptionsBorder.SetBorderParam(2, 1.0000000, 1.0000000, 1.0000000, Root.Colors.White);
	m_pOptionsBorder.SetBorderParam(3, 1.0000000, 1.0000000, 1.0000000, Root.Colors.White);
	m_pOptionsBorder.m_eCornerType = 2;
	m_pOptionsBorder.SetCornerColor(2, Root.Colors.White);
	m_pOptionsBorder.ActiveBackGround(true, Root.Colors.Black);
	CreateAndAddPageOptionsToList(Root.MenuClassDefines.ClassOptionsGame, m_ButtonGame, 0, Localize("Options", "ButtonGame", "R6Menu"));
	CreateAndAddPageOptionsToList(Root.MenuClassDefines.ClassOptionsSound, m_ButtonSound, 1, Localize("Options", "ButtonSound", "R6Menu"));
	CreateAndAddPageOptionsToList(Root.MenuClassDefines.ClassOptionsGraphic, m_ButtonGraphic, 2, Localize("Options", "ButtonGraphic", "R6Menu"));
	CreateAndAddPageOptionsToList(Root.MenuClassDefines.ClassOptionsHud, m_ButtonHudFilter, 3, Localize("Options", "ButtonHud", "R6Menu"));
	CreateAndAddPageOptionsToList(Root.MenuClassDefines.ClassOptionsMulti, m_ButtonMultiPlayer, 4, Localize("Options", "ButtonMultiPlayer", "R6Menu"));
	CreateAndAddPageOptionsToList(Root.MenuClassDefines.ClassOptionsControls, m_ButtonControls, 5, Localize("Options", "ButtonControls", "R6Menu"));
	CreateAndAddPageOptionsToList(Root.MenuClassDefines.ClassOptionsMOD, m_ButtonMODS, 6, Localize("Options", "ButtonCustomGame", "R6Menu"));
	CreateAndAddPageOptionsToList(Root.MenuClassDefines.ClassOptionsPatchService, m_ButtonPatchService, 7, Localize("Options", "ButtonPatchService", "R6Menu"));
	ManageOptionsSelection(int(0));
	return;
}

// NEW IN 1.60
function CreateAndAddPageOptionsToList(Class<UWindowWindow> _PageToCreate, R6WindowButtonOptions _pAssociateButton, R6MenuOptionsWidget.eOptionsWindow _ePageID, string _szTitle)
{
	local R6MenuOptionsTab NewOptionsPage;
	local stOptionsPage NewItem;

	NewOptionsPage = R6MenuOptionsTab(CreateWindow(_PageToCreate, (198.0000000 + m_pOptionsBorder.m_fVBorderOffset), 101.0000000, (422.0000000 - (float(2) * m_pOptionsBorder.m_fVBorderOffset)), 321.0000000, self));
	NewOptionsPage.InitPageOptions();
	NewOptionsPage.HideWindow();
	NewItem.pOptionsPage = NewOptionsPage;
	NewItem.pAssociateButton = _pAssociateButton;
	NewItem.ePageID = _ePageID;
	NewItem.szPageTitle = _szTitle;
	m_AListOptionsPages[m_AListOptionsPages.Length] = NewItem;
	return;
}

function InitOptionsButtons()
{
	local Font ButtonFont;
	local float fXOffset, fYOffset, fWidth, fHeight, fYPos;

	ButtonFont = Root.Fonts[16];
	m_SmallButtonFont = Root.Fonts[5];
	m_ButtonReturn = R6WindowButtonOptions(CreateWindow(Class'R6Menu.R6WindowButtonOptions', 10.0000000, 425.0000000, 250.0000000, 25.0000000, self));
	m_ButtonReturn.ToolTipString = Localize("Tip", "ButtonReturn", "R6Menu");
	m_ButtonReturn.Text = Localize("Options", "ButtonReturn", "R6Menu");
	m_ButtonReturn.m_eButton_Action = 8;
	m_ButtonReturn.Align = 0;
	m_ButtonReturn.m_buttonFont = ButtonFont;
	m_ButtonReturn.CheckToDownSizeFont(Root.Fonts[6], 0.0000000);
	m_ButtonReturn.ResizeToText();
	fXOffset = 10.0000000;
	fYPos = 64.0000000;
	fYOffset = 26.0000000;
	fWidth = 189.0000000;
	fHeight = 25.0000000;
	m_ButtonGame = R6WindowButtonOptions(CreateWindow(Class'R6Menu.R6WindowButtonOptions', fXOffset, fYPos, fWidth, fHeight, self));
	m_ButtonGame.ToolTipString = Localize("Tip", "ButtonGame", "R6Menu");
	m_ButtonGame.Text = Localize("Options", "ButtonGame", "R6Menu");
	m_ButtonGame.m_eButton_Action = 0;
	m_ButtonGame.Align = 0;
	m_ButtonGame.m_buttonFont = ButtonFont;
	m_ButtonGame.CheckToDownSizeFont(m_SmallButtonFont, 0.0000000);
	m_ButtonGame.ResizeToText();
	m_ButtonGame.m_bSelected = true;
	(fYPos += fYOffset);
	m_ButtonSound = R6WindowButtonOptions(CreateWindow(Class'R6Menu.R6WindowButtonOptions', fXOffset, fYPos, fWidth, fHeight, self));
	m_ButtonSound.ToolTipString = Localize("Tip", "ButtonSound", "R6Menu");
	m_ButtonSound.Text = Localize("Options", "ButtonSound", "R6Menu");
	m_ButtonSound.m_eButton_Action = 1;
	m_ButtonSound.Align = 0;
	m_ButtonSound.m_buttonFont = ButtonFont;
	m_ButtonSound.CheckToDownSizeFont(m_SmallButtonFont, 0.0000000);
	m_ButtonSound.ResizeToText();
	(fYPos += fYOffset);
	m_ButtonGraphic = R6WindowButtonOptions(CreateWindow(Class'R6Menu.R6WindowButtonOptions', fXOffset, fYPos, fWidth, fHeight, self));
	m_ButtonGraphic.ToolTipString = Localize("Tip", "ButtonGraphic", "R6Menu");
	m_ButtonGraphic.Text = Localize("Options", "ButtonGraphic", "R6Menu");
	m_ButtonGraphic.m_eButton_Action = 2;
	m_ButtonGraphic.Align = 0;
	m_ButtonGraphic.m_buttonFont = ButtonFont;
	m_ButtonGraphic.CheckToDownSizeFont(m_SmallButtonFont, 0.0000000);
	m_ButtonGraphic.ResizeToText();
	(fYPos += fYOffset);
	m_ButtonHudFilter = R6WindowButtonOptions(CreateWindow(Class'R6Menu.R6WindowButtonOptions', fXOffset, fYPos, fWidth, fHeight, self));
	m_ButtonHudFilter.ToolTipString = Localize("Tip", "ButtonHud", "R6Menu");
	m_ButtonHudFilter.Text = Localize("Options", "ButtonHud", "R6Menu");
	m_ButtonHudFilter.m_eButton_Action = 3;
	m_ButtonHudFilter.Align = 0;
	m_ButtonHudFilter.m_buttonFont = ButtonFont;
	m_ButtonHudFilter.CheckToDownSizeFont(m_SmallButtonFont, 0.0000000);
	m_ButtonHudFilter.ResizeToText();
	(fYPos += fYOffset);
	m_ButtonMultiPlayer = R6WindowButtonOptions(CreateWindow(Class'R6Menu.R6WindowButtonOptions', fXOffset, fYPos, fWidth, fHeight, self));
	m_ButtonMultiPlayer.ToolTipString = Localize("Tip", "ButtonMultiPlayer", "R6Menu");
	m_ButtonMultiPlayer.Text = Localize("Options", "ButtonMultiPlayer", "R6Menu");
	m_ButtonMultiPlayer.m_eButton_Action = 4;
	m_ButtonMultiPlayer.Align = 0;
	m_ButtonMultiPlayer.m_buttonFont = ButtonFont;
	m_ButtonMultiPlayer.CheckToDownSizeFont(m_SmallButtonFont, 0.0000000);
	m_ButtonMultiPlayer.ResizeToText();
	(fYPos += fYOffset);
	m_ButtonControls = R6WindowButtonOptions(CreateWindow(Class'R6Menu.R6WindowButtonOptions', fXOffset, fYPos, fWidth, fHeight, self));
	m_ButtonControls.ToolTipString = Localize("Tip", "ButtonControls", "R6Menu");
	m_ButtonControls.Text = Localize("Options", "ButtonControls", "R6Menu");
	m_ButtonControls.m_eButton_Action = 5;
	m_ButtonControls.Align = 0;
	m_ButtonControls.m_buttonFont = ButtonFont;
	m_ButtonControls.CheckToDownSizeFont(m_SmallButtonFont, 0.0000000);
	m_ButtonControls.ResizeToText();
	(fYPos += fYOffset);
	m_ButtonMODS = R6WindowButtonOptions(CreateWindow(Class'R6Menu.R6WindowButtonOptions', fXOffset, fYPos, fWidth, fHeight, self));
	m_ButtonMODS.ToolTipString = Localize("Tip", "ButtonCustomGame", "R6Menu");
	m_ButtonMODS.Text = Localize("Options", "ButtonCustomGame", "R6Menu");
	m_ButtonMODS.m_eButton_Action = 6;
	m_ButtonMODS.Align = 0;
	m_ButtonMODS.m_buttonFont = ButtonFont;
	m_ButtonMODS.CheckToDownSizeFont(m_SmallButtonFont, 0.0000000);
	m_ButtonMODS.ResizeToText();
	m_ButtonMODS.bDisabled = m_bInGame;
	(fYPos += fYOffset);
	m_ButtonPatchService = R6WindowButtonOptions(CreateWindow(Class'R6Menu.R6WindowButtonOptions', fXOffset, fYPos, fWidth, fHeight, self));
	m_ButtonPatchService.ToolTipString = Localize("Tip", "ButtonPatchService", "R6Menu");
	m_ButtonPatchService.Text = Localize("Options", "ButtonPatchService", "R6Menu");
	m_ButtonPatchService.m_eButton_Action = 7;
	m_ButtonPatchService.Align = 0;
	m_ButtonPatchService.m_buttonFont = ButtonFont;
	m_ButtonPatchService.CheckToDownSizeFont(m_SmallButtonFont, 0.0000000);
	m_ButtonPatchService.ResizeToText();
	ResizeAllOptionsButtons();
	return;
}

function ResizeAllOptionsButtons()
{
	// End:0x1B6
	if((((((((m_ButtonGame.IsFontDownSizingNeeded() || m_ButtonSound.IsFontDownSizingNeeded()) || m_ButtonGraphic.IsFontDownSizingNeeded()) || m_ButtonHudFilter.IsFontDownSizingNeeded()) || m_ButtonMultiPlayer.IsFontDownSizingNeeded()) || m_ButtonControls.IsFontDownSizingNeeded()) || m_ButtonMODS.IsFontDownSizingNeeded()) || m_ButtonPatchService.IsFontDownSizingNeeded()))
	{
		m_ButtonGame.m_buttonFont = m_SmallButtonFont;
		m_ButtonSound.m_buttonFont = m_SmallButtonFont;
		m_ButtonGraphic.m_buttonFont = m_SmallButtonFont;
		m_ButtonHudFilter.m_buttonFont = m_SmallButtonFont;
		m_ButtonMultiPlayer.m_buttonFont = m_SmallButtonFont;
		m_ButtonControls.m_buttonFont = m_SmallButtonFont;
		m_ButtonMODS.m_buttonFont = m_SmallButtonFont;
		m_ButtonPatchService.m_buttonFont = m_SmallButtonFont;
		m_ButtonGame.ResizeToText();
		m_ButtonSound.ResizeToText();
		m_ButtonGraphic.ResizeToText();
		m_ButtonHudFilter.ResizeToText();
		m_ButtonMultiPlayer.ResizeToText();
		m_ButtonControls.ResizeToText();
		m_ButtonMODS.ResizeToText();
		m_ButtonPatchService.ResizeToText();
	}
	return;
}


// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var m_pOptionsGame
// REMOVED IN 1.60: var m_pOptionsSound
// REMOVED IN 1.60: var m_pOptionsGraphic
// REMOVED IN 1.60: var m_pOptionsHud
// REMOVED IN 1.60: var m_pOptionsMulti
// REMOVED IN 1.60: var m_pOptionsControls
// REMOVED IN 1.60: var m_pOptionsMODS
// REMOVED IN 1.60: var m_pOptionsPatchService
// REMOVED IN 1.60: var m_pOptionCurrent
// REMOVED IN 1.60: var m_pSimplePopUp
// REMOVED IN 1.60: var m_bPBWaitForInit
// REMOVED IN 1.60: function Tick
// REMOVED IN 1.60: function SimplePopUp
// REMOVED IN 1.60: function PopUpBoxDone
// REMOVED IN 1.60: function SetOptionsTitle
