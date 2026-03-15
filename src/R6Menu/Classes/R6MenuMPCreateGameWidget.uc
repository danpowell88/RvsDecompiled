//=============================================================================
// R6MenuMPCreateGameWidget - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6MenuMultiPlayerWidget.uc : The first multi player menu window
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/11/22 * Created by Alexandre Dionne
//    2002/04/7  * Modify by Yannick Joly
//=============================================================================
class R6MenuMPCreateGameWidget extends R6MenuWidget;

const K_XSTARTPOS = 10;
const K_WINDOWWIDTH = 620;
const K_XTABOFFSET = 5;
const K_TABWINDOW_WIDTH = 550;
const K_YPOS_TABWINDOW_CURVED = 87;
const K_YPOS_TABWINDOW = 92;
const K_YPOS_HELPTEXT_WINDOW = 430;
const K_HSIZE_TABWINDOWCURVED = 30;
const K_HSIZE_TABWINDOW = 25;
const K_HSIZE_UNDER_TABWINDOW = 300;

enum eCreateGameTabID
{
	TAB_Options,                    // 0
	TAB_AdvancedOptions,            // 1
	TAB_Kit                         // 2
};

enum eRestrictionKit
{
	KIT_SubMachineGuns,             // 0
	KIT_Shotguns                    // 1
};

var bool m_bLoginInProgress;  // procedure to login to ubi.com in progress
var R6WindowTextLabel m_LMenuTitle;
var R6WindowButton m_ButtonMainMenu;
var R6WindowButton m_ButtonOptions;
var R6WindowButtonMultiMenu m_ButtonCancel;
var R6WindowButtonMultiMenu m_ButtonLaunch;
var R6WindowTextLabelCurved m_FirstTabWindow;  // First tab window (on a simple curved frame)
var R6MenuMPManageTab m_pFirstTabManager;  // creation of the tab manager for the first tab window
var R6MenuMPCreateGameTab m_pCreateTabWindow;
var R6MenuMPCreateGameTabOptions m_pCreateTabOptions;
var R6MenuMPCreateGameTabKitRest m_pCreateTabKit;
var R6MenuMPCreateGameTabAdvOptions m_pCreateTabAdvOptions;
var R6MenuHelpWindow m_pHelpTextWindow;
var R6WindowSimpleFramedWindowExt m_pWindowBorder;
var R6WindowUbiLogIn m_pLoginWindow;

function Created()
{
	InitText();
	InitButton();
	m_FirstTabWindow = R6WindowTextLabelCurved(CreateWindow(Class'R6Window.R6WindowTextLabelCurved', 10.0000000, 87.0000000, 620.0000000, 30.0000000, self));
	m_FirstTabWindow.bAlwaysBehind = true;
	m_FirstTabWindow.Text = "";
	m_FirstTabWindow.m_BGTexture = none;
	m_pFirstTabManager = R6MenuMPManageTab(CreateWindow(Class'R6Menu.R6MenuMPManageTab', (10.0000000 + float(5)), 92.0000000, 550.0000000, 25.0000000, self));
	m_pFirstTabManager.AddTabInControl(Localize("MPCreateGame", "Tab_Options", "R6Menu"), Localize("Tip", "Tab_Options", "R6Menu"), int(0));
	m_pFirstTabManager.AddTabInControl(Localize("MPCreateGame", "Tab_AdvOptions", "R6Menu"), Localize("Tip", "Tab_AdvOptions", "R6Menu"), int(1));
	m_pFirstTabManager.AddTabInControl(Localize("MPCreateGame", "Tab_Kit", "R6Menu"), Localize("Tip", "Tab_Kit", "R6Menu"), int(2));
	m_pLoginWindow = R6WindowUbiLogIn(CreateWindow(Root.MenuClassDefines.ClassUbiLogIn, 0.0000000, 0.0000000, 640.0000000, 480.0000000, self, true));
	m_pLoginWindow.m_GameService = R6Console(Root.Console).m_GameService;
	m_pLoginWindow.PopUpBoxCreate();
	m_pLoginWindow.HideWindow();
	m_pHelpTextWindow = R6MenuHelpWindow(CreateWindow(Class'R6Menu.R6MenuHelpWindow', 150.0000000, 429.0000000, 340.0000000, 42.0000000, self));
	InitTabWindow();
	return;
}

/////////////////////////////////////////////////////////////////
// display the background
/////////////////////////////////////////////////////////////////
function Paint(Canvas C, float X, float Y)
{
	Root.PaintBackground(C, self);
	// End:0x2E
	if(m_bLoginInProgress)
	{
		m_pLoginWindow.Manager(self);
	}
	return;
}

function ShowWindow()
{
	R6MenuRootWindow(Root).m_pMenuCDKeyManager.SetWindowUser(Root.19, self);
	Root.SetLoadRandomBackgroundImage("CreateGame");
	// End:0x191
	if(((!R6Console(Root.Console).m_bStartedByGSClient) && (R6Console(Root.Console).m_bNonUbiMatchMakingHost || R6Console(Root.Console).m_bAutoLoginFirstPass)))
	{
		R6Console(Root.Console).m_bAutoLoginFirstPass = false;
		R6MenuRootWindow(Root).InitBeaconService();
		R6Console(Root.Console).m_GameService.StartAutoLogin();
		// End:0x179
		if((!R6Console(Root.Console).m_GameService.m_bAutoLoginInProgress))
		{
			R6Console(Root.Console).szStoreGamePassWd = m_pCreateTabOptions.GetCreateGamePassword();
			m_pLoginWindow.StartLogInProcedure(OwnerWindow);
			m_bLoginInProgress = true;			
		}
		else
		{
			m_pLoginWindow.m_pSendMessageDest = self;
			m_bLoginInProgress = true;
		}
	}
	super(UWindowWindow).ShowWindow();
	return;
}

function SendMessage(UWindowWindow.eR6MenuWidgetMessage eMessage)
{
	switch(eMessage)
	{
		// End:0x0C
		case 0:
		// End:0x81
		case 2:
			m_bLoginInProgress = false;
			// End:0x61
			if(R6Console(Root.Console).m_bNonUbiMatchMakingHost)
			{
				Root.ChangeCurrentWidget(19);
				R6MenuRootWindow(Root).InitBeaconService();				
			}
			else
			{
				R6MenuRootWindow(Root).m_pMenuCDKeyManager.StartCDKeyProcess();
			}
			// End:0xB7
			break;
		// End:0xB1
		case 1:
			// End:0xAE
			if(R6Console(Root.Console).m_bNonUbiMatchMakingHost)
			{
				m_bLoginInProgress = false;
			}
			// End:0xB7
			break;
		// End:0xFFFF
		default:
			// End:0xB7
			break;
			break;
	}
	return;
}

/////////////////////////////////////////////////////////////////
// display the help text in the m_pHelpTextWindow (derivate for uwindowwindow
/////////////////////////////////////////////////////////////////
function ToolTip(string strTip)
{
	m_pHelpTextWindow.ToolTip(strTip);
	return;
}

/////////////////////////////////////////////////////////////////
// manage the tab selection (the call of the fct come from R6MenuMPManageTab
/////////////////////////////////////////////////////////////////
function ManageTabSelection(int _MPTabChoiceID)
{
	switch(_MPTabChoiceID)
	{
		// End:0x3A
		case int(0):
			m_pCreateTabWindow.HideWindow();
			m_pCreateTabOptions.ShowWindow();
			m_pCreateTabWindow = m_pCreateTabOptions;
			// End:0xDF
			break;
		// End:0x6D
		case int(2):
			m_pCreateTabWindow.HideWindow();
			m_pCreateTabKit.ShowWindow();
			m_pCreateTabWindow = m_pCreateTabKit;
			// End:0xDF
			break;
		// End:0xA0
		case int(1):
			m_pCreateTabWindow.HideWindow();
			m_pCreateTabAdvOptions.ShowWindow();
			m_pCreateTabWindow = m_pCreateTabAdvOptions;
			// End:0xDF
			break;
		// End:0xFFFF
		default:
			Log("This tab was not supported (R6MenuMPCreateGameWidget)");
			// End:0xDF
			break;
			break;
	}
	return;
}

function RefreshCreateGameMenu()
{
	m_pCreateTabOptions.RefreshServerOpt();
	m_pCreateTabAdvOptions.RefreshServerOpt();
	return;
}

function MenuServerLoadProfile()
{
	m_pCreateTabOptions.RefreshServerOpt(true);
	m_pCreateTabAdvOptions.RefreshServerOpt();
	m_pCreateTabKit.m_pMainRestriction.RefreshCreateGameKitRest();
	return;
}

//*********************************
//      INIT CREATE FUNCTION
//*********************************
function InitText()
{
	m_LMenuTitle = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', 0.0000000, 18.0000000, (WinWidth - float(8)), 25.0000000, self));
	m_LMenuTitle.Text = Localize("MPCreateGame", "Title", "R6Menu");
	m_LMenuTitle.Align = 1;
	m_LMenuTitle.m_Font = Root.Fonts[4];
	m_LMenuTitle.TextColor = Root.Colors.White;
	m_LMenuTitle.m_BGTexture = none;
	m_LMenuTitle.m_HBorderTexture = none;
	m_LMenuTitle.m_VBorderTexture = none;
	return;
}

function InitButton()
{
	local Font ButtonFont;
	local float fYOffset;

	fYOffset = 50.0000000;
	ButtonFont = Root.Fonts[15];
	m_ButtonMainMenu = R6WindowButton(CreateControl(Class'R6Window.R6WindowButton', 10.0000000, 425.0000000, 250.0000000, 25.0000000, self));
	m_ButtonMainMenu.ToolTipString = Localize("Tip", "ButtonMainMenu", "R6Menu");
	m_ButtonMainMenu.Text = Localize("SinglePlayer", "ButtonMainMenu", "R6Menu");
	m_ButtonMainMenu.Align = 0;
	m_ButtonMainMenu.m_fFontSpacing = 0.0000000;
	m_ButtonMainMenu.m_buttonFont = Root.Fonts[15];
	m_ButtonMainMenu.ResizeToText();
	m_ButtonMainMenu.bDisabled = (R6Console(Root.Console).m_bStartedByGSClient || R6Console(Root.Console).m_bNonUbiMatchMakingHost);
	m_ButtonOptions = R6WindowButton(CreateControl(Class'R6Window.R6WindowButton', 10.0000000, 447.0000000, 250.0000000, 25.0000000, self));
	m_ButtonOptions.ToolTipString = Localize("Tip", "ButtonOptions", "R6Menu");
	m_ButtonOptions.Text = Localize("SinglePlayer", "ButtonOptions", "R6Menu");
	m_ButtonOptions.Align = 0;
	m_ButtonOptions.m_fFontSpacing = 0.0000000;
	m_ButtonOptions.m_buttonFont = Root.Fonts[15];
	m_ButtonOptions.ResizeToText();
	m_ButtonCancel = R6WindowButtonMultiMenu(CreateWindow(Class'R6Menu.R6WindowButtonMultiMenu', 10.0000000, fYOffset, 200.0000000, 25.0000000, self));
	m_ButtonCancel.Text = Localize("MPCreateGame", "ButtonCancel", "R6Menu");
	m_ButtonCancel.ToolTipString = Localize("Tip", "ButtonCancel", "R6Menu");
	m_ButtonCancel.m_eButton_Action = 36;
	m_ButtonCancel.Align = 0;
	m_ButtonCancel.m_fFontSpacing = 2.0000000;
	m_ButtonCancel.m_buttonFont = ButtonFont;
	m_ButtonCancel.ResizeToText();
	// End:0x365
	if(R6Console(Root.Console).m_bStartedByGSClient)
	{
		m_ButtonCancel.m_eButton_Action = 39;
	}
	m_ButtonLaunch = R6WindowButtonMultiMenu(CreateWindow(Class'R6Menu.R6WindowButtonMultiMenu', 200.0000000, fYOffset, 106.0000000, 25.0000000, self));
	m_ButtonLaunch.Text = Localize("MPCreateGame", "ButtonLaunch", "R6Menu");
	m_ButtonLaunch.ToolTipString = Localize("Tip", "ButtonLaunch", "R6Menu");
	m_ButtonLaunch.m_eButton_Action = 37;
	m_ButtonLaunch.Align = 2;
	m_ButtonLaunch.m_fFontSpacing = 2.0000000;
	m_ButtonLaunch.m_buttonFont = ButtonFont;
	m_ButtonLaunch.ResizeToText();
	return;
}

function InitTabWindow()
{
	local float fWidth, fYPos;

	fWidth = 1.0000000;
	fYPos = ((87.0000000 + float(30)) - float(1));
	m_pWindowBorder = R6WindowSimpleFramedWindowExt(CreateWindow(Class'R6Window.R6WindowSimpleFramedWindowExt', 10.0000000, fYPos, 620.0000000, 300.0000000, self));
	m_pWindowBorder.bAlwaysBehind = true;
	m_pWindowBorder.ActiveBorder(0, false);
	m_pWindowBorder.SetBorderParam(1, 7.0000000, 0.0000000, fWidth, Root.Colors.White);
	m_pWindowBorder.SetBorderParam(2, 1.0000000, 1.0000000, fWidth, Root.Colors.White);
	m_pWindowBorder.SetBorderParam(3, 1.0000000, 1.0000000, fWidth, Root.Colors.White);
	m_pWindowBorder.m_eCornerType = 2;
	m_pWindowBorder.SetCornerColor(2, Root.Colors.White);
	m_pWindowBorder.ActiveBackGround(true, Root.Colors.Black);
	m_pCreateTabOptions = R6MenuMPCreateGameTabOptions(CreateWindow(Root.MenuClassDefines.ClassMPCreateGameTabOpt, 10.0000000, fYPos, 620.0000000, 300.0000000, self));
	m_pCreateTabOptions.InitOptionsTab();
	m_pCreateTabKit = R6MenuMPCreateGameTabKitRest(CreateWindow(Class'R6Menu.R6MenuMPCreateGameTabKitRest', 10.0000000, fYPos, 620.0000000, 300.0000000, self));
	m_pCreateTabKit.InitKitTab();
	m_pCreateTabKit.HideWindow();
	m_pCreateTabAdvOptions = R6MenuMPCreateGameTabAdvOptions(CreateWindow(Root.MenuClassDefines.ClassMPCreateGameTabAdvOpt, 10.0000000, fYPos, 620.0000000, 300.0000000, self));
	m_pCreateTabAdvOptions.InitAdvOptionsTab();
	m_pCreateTabAdvOptions.HideWindow();
	m_pCreateTabOptions.AddLinkWindow(m_pCreateTabKit);
	m_pCreateTabOptions.AddLinkWindow(m_pCreateTabAdvOptions);
	m_pCreateTabKit.AddLinkWindow(m_pCreateTabOptions);
	m_pCreateTabKit.AddLinkWindow(m_pCreateTabAdvOptions);
	m_pCreateTabAdvOptions.AddLinkWindow(m_pCreateTabKit);
	m_pCreateTabAdvOptions.AddLinkWindow(m_pCreateTabOptions);
	m_pCreateTabWindow = m_pCreateTabOptions;
	return;
}

function Notify(UWindowDialogControl C, byte E)
{
	// End:0x50
	if((int(E) == 2))
	{
		switch(C)
		{
			// End:0x31
			case m_ButtonMainMenu:
				Root.ChangeCurrentWidget(7);
				// End:0x50
				break;
			// End:0x4D
			case m_ButtonOptions:
				Root.ChangeCurrentWidget(16);
				// End:0x50
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


// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var m_pCDKeyCheckWindow
// REMOVED IN 1.60: var m_bPreJoinInProgress
// REMOVED IN 1.60: function LaunchServer
