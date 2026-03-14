//=============================================================================
// R6MenuInGameMultiPlayerRootWindow - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6MenuInGameRootMultiPlayerRootWindow.uc : This ingame root menu should provide us with
//                              uwindow support in the multiplayer game
//
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/19 * Created by Alexandre Dionne
//=============================================================================
class R6MenuInGameMultiPlayerRootWindow extends R6WindowRootWindow
    config;

const C_iESC_POP_UP_HEIGHT = 30;
const C_iWKA_NONE = 0x00;
const C_iWKA_INBETROUND = 0x01;
const C_iWKA_PRERECMESSAGES = 0x02;
const C_iWKA_DRAWINGTOOL = 0x04;
const C_iWKA_TOGGLE_STATS = 0x08;
const C_iWKA_MENUCOUNTDOWN = 0x10;
const C_iWKA_ESC = 0x20;
const C_iWKA_INGAME = 0x1F;
const C_iWKA_ALL = 0x3F;

var Actor.EGameModeInfo m_eCurrentGameMode;
var bool bShowLog;
var bool m_bActiveBar;  // active the bar for IN-GAME widget (server option, gear menu, etc)
var bool m_bActiveVoteMenu;
var bool m_bCanDisplayOperativeSelector;
var bool m_bPreventMenuSwitch;  // When this is true we don't allow widget change
var bool m_bMenuInvalid;  // true when gamemenucom is none or the playercontroller
var bool m_bPlayerDidASelection;  // true, player did a selection
var bool m_bJoinTeamWidget;  // force the welcome screen
var bool m_bTrapKey;  // trap key , engine will not receive the key
var R6MenuInGameWritableMapWidget m_InGameWritableMapWidget;
var R6MenuMPJoinTeamWidget m_pJoinTeamWidget;
var R6MenuMPInterWidget m_pIntermissionMenuWidget;
var R6MenuMPInGameEsc m_pInGameEscMenu;
var R6MenuMPInGameRecMessages m_pRecMessagesMenuWidget;
var R6MenuMPInGameMsgOffensive m_pOffensiveMenuWidget;
var R6MenuMPInGameMsgDefensive m_pDefensiveMenuWidget;
var R6MenuMPInGameMsgReply m_pReplyMenuWidget;
var R6MenuMPInGameMsgStatus m_pStatusMenuWidget;
var R6MenuMPInGameVote m_pVoteWidget;
var R6MPGameMenuCom m_R6GameMenuCom;
var R6MenuOptionsWidget m_pOptionsWidget;
var R6MenuMPCountDown m_pCountDownWidget;
var R6MenuInGameOperativeSelectorWidget m_InGameOperativeSelectorWidget;
var Sound m_sndOpenDrawingTool;
var Sound m_sndCloseDrawingTool;
var Region m_RJoinWidget;
var Region m_RInterWidget;  // the border region
var Region m_REscPopUp;
var string m_szCurrentGameType;
var string m_szGameModeLoc[2];  // string of game mode loc
var string m_szCurrentGameModeLoc;

function Created()
{
	super(UWindowRootWindow).Created();
	m_R6GameMenuCom = R6MPGameMenuCom(new Root.MenuClassDefines.ClassGameMenuCom);
	m_R6GameMenuCom.m_pCurrentRoot = self;
	m_R6GameMenuCom.PostBeginPlay();
	R6Console(Root.Console).Master.m_MenuCommunication = m_R6GameMenuCom;
	m_eRootId = 3;
	m_InGameWritableMapWidget = R6MenuInGameWritableMapWidget(CreateWindow(Root.MenuClassDefines.ClassWritableMapWidget, 0.0000000, 0.0000000, 640.0000000, 480.0000000));
	m_InGameWritableMapWidget.HideWindow();
	m_pJoinTeamWidget = R6MenuMPJoinTeamWidget(CreateWindow(Root.MenuClassDefines.ClassJoinTeamWidget, 0.0000000, 0.0000000, 640.0000000, 480.0000000));
	m_pJoinTeamWidget.HideWindow();
	m_pIntermissionMenuWidget = R6MenuMPInterWidget(CreateWindow(Root.MenuClassDefines.ClassInterWidget, 0.0000000, 0.0000000, 640.0000000, 480.0000000));
	m_pIntermissionMenuWidget.HideWindow();
	m_pRecMessagesMenuWidget = R6MenuMPInGameRecMessages(CreateWindow(Root.MenuClassDefines.ClassInGameRecMessages, 0.0000000, 0.0000000, 640.0000000, 480.0000000));
	m_pRecMessagesMenuWidget.HideWindow();
	m_pOffensiveMenuWidget = R6MenuMPInGameMsgOffensive(CreateWindow(Root.MenuClassDefines.ClassInGameMsgOffensive, 0.0000000, 0.0000000, 640.0000000, 480.0000000));
	m_pOffensiveMenuWidget.HideWindow();
	m_pDefensiveMenuWidget = R6MenuMPInGameMsgDefensive(CreateWindow(Root.MenuClassDefines.ClassInGameMsgDefensive, 0.0000000, 0.0000000, 640.0000000, 480.0000000));
	m_pDefensiveMenuWidget.HideWindow();
	m_pReplyMenuWidget = R6MenuMPInGameMsgReply(CreateWindow(Root.MenuClassDefines.ClassInGameMsgReply, 0.0000000, 0.0000000, 640.0000000, 480.0000000));
	m_pReplyMenuWidget.HideWindow();
	m_pStatusMenuWidget = R6MenuMPInGameMsgStatus(CreateWindow(Root.MenuClassDefines.ClassInGameMsgStatus, 0.0000000, 0.0000000, 640.0000000, 480.0000000));
	m_pStatusMenuWidget.HideWindow();
	m_pVoteWidget = R6MenuMPInGameVote(CreateWindow(Root.MenuClassDefines.ClassInGameVote, 0.0000000, 0.0000000, 640.0000000, 480.0000000));
	m_pVoteWidget.HideWindow();
	m_pInGameEscMenu = R6MenuMPInGameEsc(CreateWindow(Root.MenuClassDefines.ClassInGameEsc, 0.0000000, 0.0000000, 640.0000000, 480.0000000));
	m_pInGameEscMenu.HideWindow();
	m_pOptionsWidget = R6MenuOptionsWidget(CreateWindow(Root.MenuClassDefines.ClassOptionsWidget, 0.0000000, 0.0000000, 640.0000000, 480.0000000));
	m_pOptionsWidget.HideWindow();
	m_pCountDownWidget = R6MenuMPCountDown(CreateWindow(Root.MenuClassDefines.ClassCountDown, 0.0000000, 0.0000000, 640.0000000, 480.0000000));
	m_pCountDownWidget.HideWindow();
	m_InGameOperativeSelectorWidget = R6MenuInGameOperativeSelectorWidget(CreateWindow(Root.MenuClassDefines.ClassInGameOperativeSelectorWidget, 0.0000000, 0.0000000, 640.0000000, 480.0000000));
	m_InGameOperativeSelectorWidget.HideWindow();
	m_szGameModeLoc[0] = __NFUN_235__(Localize("MultiPlayer", "GameMode_Adversarial", "R6Menu"));
	m_szGameModeLoc[1] = __NFUN_235__(Localize("MultiPlayer", "GameMode_Cooperative", "R6Menu"));
	FillListOfKeyAvailability();
	return;
}

//=============================================================================================
// FillListOfKeyAvailability: Fill the list of key availability
//							  Each widget (pop-up by a key) is define here
//=============================================================================================
function FillListOfKeyAvailability()
{
	AddKeyInList(int(GetPlayerOwner().__NFUN_2706__("Talk")), 63);
	AddKeyInList(int(GetPlayerOwner().__NFUN_2706__("TeamTalk")), 63);
	AddKeyInList(int(GetPlayerOwner().__NFUN_2706__("ToggleGameStats")), 8);
	AddKeyInList(int(GetPlayerOwner().__NFUN_2706__("DrawingTool")), 4);
	AddKeyInList(int(GetPlayerOwner().__NFUN_2706__("VotingMenu")), 2);
	AddKeyInList(int(GetPlayerOwner().__NFUN_2706__("PreRecMessages")), 2);
	AddKeyInList(int(GetPlayerOwner().__NFUN_2706__("PrimaryWeapon")), 16);
	AddKeyInList(int(GetPlayerOwner().__NFUN_2706__("SecondaryWeapon")), 16);
	AddKeyInList(int(GetPlayerOwner().__NFUN_2706__("GadgetOne")), 16);
	AddKeyInList(int(GetPlayerOwner().__NFUN_2706__("GadgetTwo")), 16);
	AddKeyInList(int(GetPlayerOwner().__NFUN_2706__("RaisePosture")), 16);
	AddKeyInList(int(GetPlayerOwner().__NFUN_2706__("LowerPosture")), 16);
	AddKeyInList(int(GetPlayerOwner().__NFUN_2706__("ChangeRateOfFire")), 16);
	AddKeyInList(int(GetPlayerOwner().__NFUN_2706__("Reload")), 16);
	AddKeyInList(int(Console.27), 32);
	return;
}

//=============================================================================================
// ChangeCurrentWidget: Change the current widget
//=============================================================================================
function ChangeCurrentWidget(UWindowRootWindow.eGameWidgetID widgetID)
{
	switch(widgetID)
	{
		// End:0x0C
		case 28:
		// End:0x11
		case 29:
		// End:0x16
		case 30:
		// End:0x1B
		case 31:
		// End:0x20
		case 32:
		// End:0x25
		case 33:
		// End:0x2A
		case 24:
		// End:0x2F
		case 25:
		// End:0x34
		case 23:
		// End:0x39
		case 35:
		// End:0x3E
		case 17:
		// End:0x53
		case 0:
			ChangeWidget(widgetID, true, false);
			// End:0xE1
			break;
		// End:0x58
		case 34:
		// End:0x6D
		case 26:
			ChangeWidget(widgetID, true, true);
			// End:0xE1
			break;
		// End:0x82
		case 16:
			ChangeWidget(widgetID, false, false);
			// End:0xE1
			break;
		// End:0xDB
		case 27:
			// End:0xCB
			if(Console.__NFUN_281__('UWindowCanPlay'))
			{
				// End:0xB1
				if(m_bPlayerDidASelection)
				{
					ChangeWidget(0, true, false);					
				}
				else
				{
					ChangeWidget(0, false, false);
					ChangeWidget(widgetID, false, false);
				}				
			}
			else
			{
				ChangeWidget(widgetID, false, false);
			}
			// End:0xE1
			break;
		// End:0xFFFF
		default:
			// End:0xE1
			break;
			break;
	}
	return;
}

//=============================================================================================
// ChangeWidget: Change widget according what`s you already have in your window list
//=============================================================================================
function ChangeWidget(UWindowRootWindow.eGameWidgetID widgetID, bool _bClearPrevWInHistory, bool _bCloseAll)
{
	local StWidget pStNewWidget;
	local name ConsoleState;
	local int iNbOfShowWindow, i;

	// End:0x0B
	if(m_bPreventMenuSwitch)
	{
		return;
	}
	iNbOfShowWindow = m_pListOfActiveWidget.Length;
	ConsoleState = 'UWindow';
	// End:0x38
	if(_bCloseAll)
	{
		CloseAllWindow();
		iNbOfShowWindow = 0;
	}
	ManagePrevWInHistory(_bClearPrevWInHistory, iNbOfShowWindow);
	m_eCurWidgetInUse = widgetID;
	pStNewWidget.m_eGameWidgetID = widgetID;
	GetPopUpFrame(iNbOfShowWindow).m_bBGClientArea = true;
	switch(widgetID)
	{
		// End:0x152
		case 24:
			UpdateCurrentGameMode();
			pStNewWidget.m_pPopUpFrame = GetPopUpFrame(iNbOfShowWindow);
			pStNewWidget.m_pPopUpFrame.ModifyPopUpFrameWindow(Localize("MPInGame", "TeamSelect", "R6Menu"), R6MenuRSLookAndFeel(LookAndFeel).GetTextHeaderSize(), float(m_RJoinWidget.X), float(m_RJoinWidget.Y), float(m_RJoinWidget.W), float(m_RJoinWidget.H));
			pStNewWidget.m_pWidget = m_pJoinTeamWidget;
			m_pJoinTeamWidget.SetMenuToDisplay(m_szCurrentGameType);
			m_iWidgetKA = __NFUN_158__(8, 32);
			// End:0x663
			break;
		// End:0x279
		case 25:
			pStNewWidget.m_pPopUpFrame = GetPopUpFrame(iNbOfShowWindow);
			pStNewWidget.m_pPopUpFrame.ModifyPopUpFrameWindow(m_szCurrentGameModeLoc, R6MenuRSLookAndFeel(LookAndFeel).GetTextHeaderSize(), float(m_RInterWidget.X), float(m_RInterWidget.Y), float(m_RInterWidget.W), float(m_RInterWidget.H));
			pStNewWidget.m_pPopUpFrame.m_bBGClientArea = false;
			pStNewWidget.m_pWidget = m_pIntermissionMenuWidget;
			m_pIntermissionMenuWidget.SetInterWidgetMenu(m_szCurrentGameType, m_bActiveBar);
			m_iWidgetKA = __NFUN_158__(__NFUN_158__(8, 32), 4);
			// End:0x255
			if(__NFUN_130__(__NFUN_119__(GetPlayerOwner().Pawn, none), GetPlayerOwner().Pawn.IsAlive()))
			{
				m_bActiveBar = false;
			}
			// End:0x276
			if(__NFUN_130__(__NFUN_129__(m_bActiveBar), m_bPlayerDidASelection))
			{
				ConsoleState = 'UWindowCanPlay';
			}
			// End:0x663
			break;
		// End:0x348
		case 26:
			pStNewWidget.m_pPopUpFrame = GetPopUpFrame(iNbOfShowWindow);
			pStNewWidget.m_pPopUpFrame.ModifyPopUpFrameWindow(m_szCurrentGameModeLoc, R6MenuRSLookAndFeel(LookAndFeel).GetTextHeaderSize(), float(m_RInterWidget.X), float(m_RInterWidget.Y), float(m_RInterWidget.W), float(m_RInterWidget.H));
			pStNewWidget.m_pPopUpFrame.m_bBGClientArea = false;
			pStNewWidget.m_pWidget = m_pIntermissionMenuWidget;
			m_bActiveBar = true;
			m_pIntermissionMenuWidget.SetInterWidgetMenu(m_szCurrentGameType, m_bActiveBar);
			m_iWidgetKA = __NFUN_158__(32, 4);
			// End:0x663
			break;
		// End:0x382
		case 23:
			pStNewWidget.m_pPopUpFrame = GetPopUpFrame(iNbOfShowWindow);
			pStNewWidget.m_pWidget = m_InGameWritableMapWidget;
			m_iWidgetKA = __NFUN_158__(4, 32);
			// End:0x663
			break;
		// End:0x422
		case 27:
			pStNewWidget.m_pPopUpFrame = GetPopUpFrame(iNbOfShowWindow);
			pStNewWidget.m_pPopUpFrame.ModifyPopUpFrameWindow(Localize("ESCMENUS", "ESCMENU", "R6Menu"), 30.0000000, float(m_REscPopUp.X), float(m_REscPopUp.Y), float(m_REscPopUp.W), float(m_REscPopUp.H));
			pStNewWidget.m_pWidget = m_pInGameEscMenu;
			m_iWidgetKA = 32;
			// End:0x663
			break;
		// End:0x451
		case 16:
			pStNewWidget.m_pWidget = m_pOptionsWidget;
			m_pOptionsWidget.RefreshOptions();
			m_iWidgetKA = 63;
			// End:0x663
			break;
		// End:0x480
		case 28:
			pStNewWidget.m_pWidget = m_pRecMessagesMenuWidget;
			m_iWidgetKA = __NFUN_158__(2, 32);
			ConsoleState = 'UWindowCanPlay';
			// End:0x663
			break;
		// End:0x4AF
		case 29:
			pStNewWidget.m_pWidget = m_pOffensiveMenuWidget;
			m_iWidgetKA = __NFUN_158__(2, 32);
			ConsoleState = 'UWindowCanPlay';
			// End:0x663
			break;
		// End:0x4DE
		case 30:
			pStNewWidget.m_pWidget = m_pDefensiveMenuWidget;
			m_iWidgetKA = __NFUN_158__(2, 32);
			ConsoleState = 'UWindowCanPlay';
			// End:0x663
			break;
		// End:0x50D
		case 31:
			pStNewWidget.m_pWidget = m_pReplyMenuWidget;
			m_iWidgetKA = __NFUN_158__(2, 32);
			ConsoleState = 'UWindowCanPlay';
			// End:0x663
			break;
		// End:0x53C
		case 32:
			pStNewWidget.m_pWidget = m_pStatusMenuWidget;
			m_iWidgetKA = __NFUN_158__(2, 32);
			ConsoleState = 'UWindowCanPlay';
			// End:0x663
			break;
		// End:0x56B
		case 33:
			pStNewWidget.m_pWidget = m_pVoteWidget;
			m_iWidgetKA = __NFUN_158__(2, 32);
			ConsoleState = 'UWindowCanPlay';
			// End:0x663
			break;
		// End:0x58B
		case 34:
			pStNewWidget.m_pWidget = m_pCountDownWidget;
			m_iWidgetKA = 16;
			// End:0x663
			break;
		// End:0x611
		case 35:
			pStNewWidget.m_pPopUpFrame = GetPopUpFrame(iNbOfShowWindow);
			pStNewWidget.m_pPopUpFrame.ModifyPopUpFrameWindow(Localize("OPERATIVESELECTOR", "Title_ID", "R6Menu"), 30.0000000, 217.0000000, 33.0000000, 206.0000000, 397.0000000);
			pStNewWidget.m_pWidget = m_InGameOperativeSelectorWidget;
			// End:0x663
			break;
		// End:0x61E
		case 0:
			m_iWidgetKA = 63;
		// End:0x65D
		case 17:
			// End:0x65A
			if(__NFUN_155__(iNbOfShowWindow, 0))
			{
				pStNewWidget = m_pListOfActiveWidget[__NFUN_147__(iNbOfShowWindow, 1)];
				m_iWidgetKA = pStNewWidget.iWidgetKA;
				__NFUN_162__(iNbOfShowWindow, 1);
			}
			// End:0x663
			break;
		// End:0xFFFF
		default:
			// End:0x663
			break;
			break;
	}
	// End:0x7B2
	if(__NFUN_119__(pStNewWidget.m_pWidget, none))
	{
		// End:0x6D9
		if(__NFUN_129__(Console.__NFUN_281__(ConsoleState)))
		{
			CloseAllWindow();
			Console.bUWindowActive = true;
			// End:0x6CE
			if(__NFUN_119__(Console.Root, none))
			{
				Console.Root.bWindowVisible = true;
			}
			CheckConsoleTypingState(ConsoleState);
		}
		// End:0x71C
		if(__NFUN_254__(ConsoleState, 'UWindow'))
		{
			Console.ViewportOwner.bSuspendPrecaching = true;
			Console.ViewportOwner.bShowWindowsMouse = true;
		}
		// End:0x740
		if(__NFUN_119__(pStNewWidget.m_pPopUpFrame, none))
		{
			pStNewWidget.m_pPopUpFrame.ShowWindow();
		}
		pStNewWidget.m_pWidget.ShowWindow();
		pStNewWidget.iWidgetKA = m_iWidgetKA;
		m_eCurWidgetInUse = pStNewWidget.m_eGameWidgetID;
		m_pListOfActiveWidget[iNbOfShowWindow] = pStNewWidget;
		// End:0x7AF
		if(__NFUN_154__(int(m_eCurWidgetInUse), int(34)))
		{
			Console.ViewportOwner.bShowWindowsMouse = false;
		}		
	}
	else
	{
		Console.bUWindowActive = false;
		Console.ViewportOwner.bShowWindowsMouse = false;
		bWindowVisible = false;
		CheckConsoleTypingState('Game');
	}
	return;
}

function UpdateCurrentGameMode()
{
	m_szCurrentGameType = m_R6GameMenuCom.GetGameType();
	// End:0x4F
	if(GetLevel().IsGameTypeAdversarial(m_szCurrentGameType))
	{
		m_eCurrentGameMode = GetLevel().3;
		m_szCurrentGameModeLoc = m_szGameModeLoc[0];		
	}
	else
	{
		// End:0x89
		if(GetLevel().IsGameTypeCooperative(m_szCurrentGameType))
		{
			m_eCurrentGameMode = GetLevel().2;
			m_szCurrentGameModeLoc = m_szGameModeLoc[1];			
		}
		else
		{
			__NFUN_231__(__NFUN_168__(__NFUN_168__("szGameType:", m_szCurrentGameType), "in R6MenuInGameMultiPlayerRootWindow not VALID"));
		}
	}
	return;
}

//=====================================================================================================
//=====================================================================================================
function SimplePopUp(string _szTitle, string _szText, UWindowBase.EPopUpID _ePopUpID, optional int _iButtonsType, optional bool bAddDisableDlg, optional UWindowWindow OwnerWindow)
{
	// End:0x2F
	if(__NFUN_114__(OwnerWindow, none))
	{
		super.SimplePopUp(_szTitle, _szText, _ePopUpID, _iButtonsType, bAddDisableDlg, self);		
	}
	else
	{
		super.SimplePopUp(_szTitle, _szText, _ePopUpID, _iButtonsType, bAddDisableDlg, OwnerWindow);
	}
	// End:0x6C
	if(__NFUN_154__(int(m_eCurWidgetInUse), int(23)))
	{
		ChangeCurrentWidget(0);
	}
	return;
}

//==============================================================================
// PopUpBoxDone -  receive the result of the popup box  
//==============================================================================
function PopUpBoxDone(UWindowBase.MessageBoxResult Result, UWindowBase.EPopUpID _ePopUpID)
{
	super.PopUpBoxDone(Result, _ePopUpID);
	// End:0x125
	if(__NFUN_154__(int(Result), int(3)))
	{
		switch(_ePopUpID)
		{
			// End:0x3F
			case 30:
				m_R6GameMenuCom.TKPopUpDone(true);
				// End:0x122
				break;
			// End:0x92
			case 31:
				m_R6GameMenuCom.DisconnectClient(GetLevel());
				R6Console(Root.Console).LeaveR6Game(R6Console(Root.Console).3);
				// End:0x122
				break;
			// End:0xF5
			case 50:
				GetPlayerOwner().StopAllMusic();
				m_R6GameMenuCom.DisconnectClient(GetLevel());
				R6Console(Root.Console).LeaveR6Game(R6Console(Root.Console).0);
				// End:0x122
				break;
			// End:0x11C
			case 51:
				GetPlayerOwner().StopAllMusic();
				Root.DoQuitGame();
				// End:0x122
				break;
			// End:0xFFFF
			default:
				// End:0x122
				break;
				break;
		}		
	}
	else
	{
		// End:0x15A
		if(__NFUN_154__(int(Result), int(4)))
		{
			switch(_ePopUpID)
			{
				// End:0x154
				case 30:
					m_R6GameMenuCom.TKPopUpDone(false);
					// End:0x15A
					break;
				// End:0xFFFF
				default:
					// End:0x15A
					break;
					break;
			}
		}
	}
	// End:0x1AF
	if(__NFUN_154__(int(m_eCurWidgetInUse), int(0)))
	{
		Console.bUWindowActive = false;
		Console.ViewportOwner.bShowWindowsMouse = false;
		bWindowVisible = false;
		m_bActiveBar = true;
		ChangeWidget(0, false, false);
	}
	m_pInGameEscMenu.m_bEscAvailable = true;
	return;
}

function CloseSimplePopUpBox()
{
	// End:0x1A
	if(__NFUN_119__(m_pSimplePopUp, none))
	{
		m_pSimplePopUp.Close();
	}
	return;
}

//=====================================================================================
// VoteMenuOn: Active the vote menu on/off (only if the player press on the specific key)
//=====================================================================================
function VoteMenu(string _szPlayerNameToKick, bool _ActiveMenu)
{
	m_bActiveVoteMenu = _ActiveMenu;
	m_pVoteWidget.m_szPlayerNameToKick = _szPlayerNameToKick;
	m_pVoteWidget.m_bFirstTimePaint = false;
	return;
}

function NotifyBeforeLevelChange()
{
	// End:0x49
	if(bShowLog)
	{
		__NFUN_231__("R6MenuInGameMultiPlayerRootWindow::NotifyBeforeLevelChange()");
	}
	// End:0xB9
	if(__NFUN_119__(m_R6GameMenuCom, none))
	{
		// End:0xA9
		if(bShowLog)
		{
			R6Console(Root.Console).ConsoleCommand(__NFUN_112__("OBJ REFS CLASS=R6MPGameMenuCom NAME=", string(m_R6GameMenuCom)));
		}
		m_R6GameMenuCom.m_pCurrentRoot = none;
	}
	R6Console(Root.Console).Master.m_MenuCommunication = none;
	m_R6GameMenuCom = none;
	CheckConsoleTypingState('UWindow');
	super(UWindowWindow).NotifyBeforeLevelChange();
	return;
}

function NotifyAfterLevelChange()
{
	// End:0x48
	if(bShowLog)
	{
		__NFUN_231__("R6MenuInGameMultiPlayerRootWindow::NotifyAfterLevelChange()");
	}
	m_R6GameMenuCom = R6MPGameMenuCom(new Root.MenuClassDefines.ClassGameMenuCom);
	m_R6GameMenuCom.m_pCurrentRoot = self;
	m_R6GameMenuCom.PostBeginPlay();
	R6Console(Root.Console).Master.m_MenuCommunication = m_R6GameMenuCom;
	m_bJoinTeamWidget = true;
	m_bPlayerDidASelection = false;
	m_bPreventMenuSwitch = false;
	ChangeWidget(0, true, true);
	m_pIntermissionMenuWidget.SetNavBarInActive(false);
	super(UWindowWindow).NotifyAfterLevelChange();
	return;
}

function MoveMouse(float X, float Y)
{
	local UWindowWindow NewMouseWindow;
	local float tX, tY;

	MouseX = X;
	MouseY = Y;
	// End:0x48
	if(__NFUN_129__(bMouseCapture))
	{
		NewMouseWindow = FindWindowUnder(__NFUN_171__(X, m_fWindowScaleX), __NFUN_171__(Y, m_fWindowScaleY));		
	}
	else
	{
		NewMouseWindow = MouseWindow;
	}
	// End:0x8B
	if(__NFUN_119__(NewMouseWindow, MouseWindow))
	{
		MouseWindow.MouseLeave();
		NewMouseWindow.MouseEnter();
		MouseWindow = NewMouseWindow;
	}
	// End:0xF3
	if(__NFUN_132__(__NFUN_181__(MouseX, OldMouseX), __NFUN_181__(MouseY, OldMouseY)))
	{
		OldMouseX = MouseX;
		OldMouseY = MouseY;
		MouseWindow.GetMouseXY(tX, tY);
		MouseWindow.MouseMove(tX, tY);
	}
	return;
}

function DrawMouse(Canvas C)
{
	local float X, Y, fMouseClipX, fMouseClipY;
	local Texture MouseTex;

	// End:0x49
	if(Console.ViewportOwner.bWindowsMouseAvailable)
	{
		Console.ViewportOwner.SelectedCursor = MouseWindow.Cursor.WindowsCursor;		
	}
	else
	{
		C.__NFUN_2626__(byte(255), byte(255), byte(255));
		C.Style = 5;
		C.__NFUN_2623__(__NFUN_175__(MouseX, float(MouseWindow.Cursor.HotX)), __NFUN_175__(MouseY, float(MouseWindow.Cursor.HotY)));
		// End:0x143
		if(__NFUN_119__(MouseWindow.Cursor.Tex, none))
		{
			MouseTex = MouseWindow.Cursor.Tex;
			C.__NFUN_466__(MouseTex, float(MouseTex.USize), float(MouseTex.VSize), 0.0000000, 0.0000000, float(MouseTex.USize), float(MouseTex.VSize));
		}
		C.Style = 1;
	}
	return;
}

function Tick(float Delta)
{
	// End:0x1A
	if(m_bJoinTeamWidget)
	{
		// End:0x1A
		if(IsGameMenuComInitialized())
		{
			m_bJoinTeamWidget = false;
		}
	}
	return;
}

function Paint(Canvas C, float X, float Y)
{
	local string szTemp;
	local float W, H;

	// End:0x1D2
	if(m_bJoinTeamWidget)
	{
		C.Style = 5;
		C.__NFUN_2626__(Root.Colors.Black.R, Root.Colors.Black.G, Root.Colors.Black.B);
		DrawStretchedTextureSegment(C, 0.0000000, 0.0000000, WinWidth, WinHeight, 0.0000000, 0.0000000, 10.0000000, 10.0000000, Texture'UWindow.WhiteTexture');
		szTemp = Localize("MP", "WaitingForServer", "R6Engine");
		C.Font = Root.Fonts[14];
		C.__NFUN_2626__(Root.Colors.White.R, Root.Colors.White.G, Root.Colors.White.B);
		TextSize(C, szTemp, W, H);
		W = __NFUN_171__(__NFUN_175__(WinWidth, W), 0.5000000);
		H = __NFUN_171__(__NFUN_175__(WinHeight, H), 0.5000000);
		C.__NFUN_2623__(W, H);
		C.__NFUN_465__(szTemp);
	}
	return;
}

function bool IsGameMenuComInitialized()
{
	// End:0x21
	if(__NFUN_130__(__NFUN_119__(m_R6GameMenuCom, none), m_R6GameMenuCom.IsInitialisationCompleted()))
	{
		return true;
	}
	return false;
	return;
}

function WindowEvent(UWindowWindow.WinMessage Msg, Canvas C, float X, float Y, int Key)
{
	// End:0xC2
	if(__NFUN_155__(int(Msg), int(11)))
	{
		// End:0xA0
		if(__NFUN_132__(__NFUN_132__(__NFUN_132__(__NFUN_129__(IsGameMenuComInitialized()), __NFUN_114__(GetPlayerOwner(), none)), __NFUN_114__(GetLevel(), none)), __NFUN_114__(Console, none)))
		{
			// End:0x82
			if(__NFUN_154__(int(GetSimplePopUpID()), int(33)))
			{
				super(UWindowRootWindow).WindowEvent(Msg, C, __NFUN_171__(X, m_fWindowScaleX), __NFUN_171__(Y, m_fWindowScaleY), Key);
			}
			m_bMenuInvalid = true;
			m_pIntermissionMenuWidget.SetNavBarInActive(true, true);
			return;			
		}
		else
		{
			// End:0xC2
			if(m_bMenuInvalid)
			{
				m_bMenuInvalid = false;
				m_pIntermissionMenuWidget.SetNavBarInActive(false, true);
			}
		}
	}
	switch(Msg)
	{
		// End:0x1FF
		case 11:
			// End:0x16B
			if(m_bScaleWindowToRoot)
			{
				C.__NFUN_1606__(true, 640.0000000, 480.0000000);
				m_fWindowScaleX = __NFUN_172__(C.GetVirtualSizeX(), float(C.SizeX));
				m_fWindowScaleY = __NFUN_172__(C.GetVirtualSizeY(), float(C.SizeY));
				super(UWindowRootWindow).WindowEvent(Msg, C, X, Y, Key);
				C.__NFUN_1606__(false);				
			}
			else
			{
				// End:0x1C7
				if(__NFUN_132__(__NFUN_181__(WinWidth, float(C.SizeX)), __NFUN_181__(WinHeight, float(C.SizeY))))
				{
					SetResolution(float(C.SizeX), float(C.SizeY));
				}
				m_fWindowScaleX = 1.0000000;
				m_fWindowScaleY = 1.0000000;
				super(UWindowRootWindow).WindowEvent(Msg, C, X, Y, Key);
			}
			// End:0x320
			break;
		// End:0x257
		case 9:
			// End:0x227
			if(__NFUN_155__(int(m_eCurWidgetInUse), int(16)))
			{
				// End:0x227
				if(__NFUN_129__(ProcessKeyDown(Key)))
				{
					// [Explicit Continue]
					goto J0x320;
				}
			}
			super(UWindowRootWindow).WindowEvent(Msg, C, __NFUN_171__(X, m_fWindowScaleX), __NFUN_171__(Y, m_fWindowScaleY), Key);
			// End:0x320
			break;
		// End:0x29F
		case 8:
			// End:0x26F
			if(__NFUN_129__(ProcessKeyUp(Key)))
			{
				// [Explicit Continue]
				goto J0x320;
			}
			super(UWindowRootWindow).WindowEvent(Msg, C, __NFUN_171__(X, m_fWindowScaleX), __NFUN_171__(Y, m_fWindowScaleY), Key);
			// End:0x320
			break;
		// End:0x2A4
		case 0:
		// End:0x2A9
		case 1:
		// End:0x2AE
		case 2:
		// End:0x2B3
		case 3:
		// End:0x2B8
		case 4:
		// End:0x2ED
		case 5:
			super(UWindowRootWindow).WindowEvent(Msg, C, __NFUN_171__(X, m_fWindowScaleX), __NFUN_171__(Y, m_fWindowScaleY), Key);
			// End:0x320
			break;
		// End:0xFFFF
		default:
			super(UWindowRootWindow).WindowEvent(Msg, C, __NFUN_171__(X, m_fWindowScaleX), __NFUN_171__(Y, m_fWindowScaleY), Key);
			// End:0x320
			break;
			break;
	}
	J0x320:

	return;
}

function bool ProcessKeyDown(int Key)
{
	local UWindowRootWindow.eGameWidgetID eNextWidgetIDUp, eNextWidgetIDDown;
	local int i, iNbOfKeys;
	local bool bProcessWChange, bProcessKeyToAllMenu, bIsInBetweenRound;
	local PlayerController PC;

	PC = GetPlayerOwner();
	// End:0x1D
	if(__NFUN_155__(m_iLastKeyDown, -1))
	{
		return true;
	}
	bProcessKeyToAllMenu = true;
	iNbOfKeys = m_pListOfKeyAvailability.Length;
	m_bTrapKey = true;
	i = 0;
	J0x40:

	// End:0xB5 [Loop If]
	if(__NFUN_150__(i, iNbOfKeys))
	{
		// End:0xAB
		if(__NFUN_154__(m_pListOfKeyAvailability[i].iKey, Key))
		{
			// End:0xA4
			if(__NFUN_151__(__NFUN_156__(m_pListOfKeyAvailability[i].iWidgetKA, m_iWidgetKA), 0))
			{
				// End:0x9E
				if(__NFUN_154__(int(m_eCurWidgetInUse), int(34)))
				{
					m_bTrapKey = false;
				}
				// [Explicit Break]
				goto J0xB5;
				// [Explicit Continue]
				goto J0xAB;
			}
			return bProcessKeyToAllMenu;
		}
		J0xAB:

		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x40;
	}
	J0xB5:

	bIsInBetweenRound = m_R6GameMenuCom.IsInBetweenRoundMenu();
	switch(Key)
	{
		// End:0xFB
		case int(PC.__NFUN_2706__("Talk")):
			Console.Talk();
			// End:0x564
			break;
		// End:0x128
		case int(PC.__NFUN_2706__("TeamTalk")):
			Console.TeamTalk();
			// End:0x564
			break;
		// End:0x1BB
		case int(PC.__NFUN_2706__("ToggleGameStats")):
			R6Console(Root.Console).bCancelFire = false;
			eNextWidgetIDUp = 25;
			// End:0x1A8
			if(m_bPlayerDidASelection)
			{
				// End:0x1A5
				if(m_R6GameMenuCom.m_GameRepInfo.IsInAGameState())
				{
					eNextWidgetIDDown = 0;
					bProcessWChange = true;
				}				
			}
			else
			{
				eNextWidgetIDDown = 24;
				bProcessWChange = true;
			}
			// End:0x564
			break;
		// End:0x315
		case int(PC.__NFUN_2706__("DrawingTool")):
			// End:0x312
			if(__NFUN_130__(R6GameReplicationInfo(PC.GameReplicationInfo).m_bIsWritableMapAllowed, m_R6GameMenuCom.IsAPlayerSelection()))
			{
				// End:0x312
				if(__NFUN_132__(__NFUN_130__(__NFUN_119__(PC.Pawn, none), PC.Pawn.IsAlive()), bIsInBetweenRound))
				{
					eNextWidgetIDUp = 23;
					eNextWidgetIDDown = 0;
					// End:0x2B0
					if(__NFUN_154__(int(m_eCurWidgetInUse), int(23)))
					{
						// End:0x27D
						if(bIsInBetweenRound)
						{
							eNextWidgetIDDown = m_ePrevWidgetInUse;
						}
						// End:0x2AD
						if(__NFUN_119__(PC.Pawn, none))
						{
							PC.Pawn.__NFUN_264__(m_sndCloseDrawingTool, 9);
						}						
					}
					else
					{
						// End:0x2C7
						if(bIsInBetweenRound)
						{
							m_ePrevWidgetInUse = m_eCurWidgetInUse;							
						}
						else
						{
							// End:0x2DA
							if(__NFUN_155__(int(m_eCurWidgetInUse), int(0)))
							{
								// [Explicit Continue]
								goto J0x564;
							}
						}
						// End:0x30A
						if(__NFUN_119__(PC.Pawn, none))
						{
							PC.Pawn.__NFUN_264__(m_sndOpenDrawingTool, 9);
						}
					}
					bProcessWChange = true;
				}
			}
			// End:0x564
			break;
		// End:0x3BB
		case int(Console.27):
			eNextWidgetIDUp = 27;
			eNextWidgetIDDown = 0;
			bProcessWChange = true;
			// End:0x389
			if(__NFUN_154__(int(m_eCurWidgetInUse), int(27)))
			{
				// End:0x37E
				if(R6MenuMPInGameEsc(m_pListOfActiveWidget[__NFUN_147__(m_pListOfActiveWidget.Length, 1)].m_pWidget).m_bEscAvailable)
				{
					bProcessKeyToAllMenu = false;					
				}
				else
				{
					bProcessWChange = false;
				}				
			}
			else
			{
				// End:0x3B8
				if(__NFUN_154__(int(m_eCurWidgetInUse), int(23)))
				{
					// End:0x3B0
					if(bIsInBetweenRound)
					{
						eNextWidgetIDUp = m_ePrevWidgetInUse;						
					}
					else
					{
						eNextWidgetIDUp = 0;
					}
				}
			}
			// End:0x564
			break;
		// End:0x41B
		case int(PC.__NFUN_2706__("VotingMenu")):
			// End:0x418
			if(m_bActiveVoteMenu)
			{
				R6Console(Root.Console).bCancelFire = false;
				eNextWidgetIDUp = 33;
				eNextWidgetIDDown = 0;
				bProcessWChange = true;
			}
			// End:0x564
			break;
		// End:0x4C2
		case int(PC.__NFUN_2706__("PreRecMessages")):
			// End:0x4BF
			if(__NFUN_130__(__NFUN_130__(__NFUN_123__(m_szCurrentGameType, "RGM_DeathmatchMode"), __NFUN_129__(PC.__NFUN_281__('Dead'))), __NFUN_129__(PC.bOnlySpectator)))
			{
				R6Console(Root.Console).bCancelFire = false;
				eNextWidgetIDUp = 28;
				eNextWidgetIDDown = 0;
				bProcessWChange = true;
			}
			// End:0x564
			break;
		// End:0x55E
		case int(PC.__NFUN_2706__("OperativeSelector")):
			// End:0x55B
			if(__NFUN_130__(__NFUN_130__(__NFUN_130__(GetLevel().IsGameTypeCooperative(m_R6GameMenuCom.GetGameType()), __NFUN_154__(int(m_eCurWidgetInUse), int(0))), __NFUN_129__(PC.bOnlySpectator)), m_bCanDisplayOperativeSelector))
			{
				m_bCanDisplayOperativeSelector = false;
				eNextWidgetIDUp = 35;
				eNextWidgetIDDown = 0;
				bProcessWChange = true;
			}
			// End:0x564
			break;
		// End:0xFFFF
		default:
			// End:0x564
			break;
			break;
	}
	J0x564:

	// End:0x5AF
	if(bProcessWChange)
	{
		// End:0x599
		if(__NFUN_154__(int(m_eCurWidgetInUse), int(eNextWidgetIDUp)))
		{
			ChangeCurrentWidget(eNextWidgetIDDown);
			m_iLastKeyDown = -1;			
		}
		else
		{
			ChangeCurrentWidget(eNextWidgetIDUp);
			m_iLastKeyDown = Key;
		}
	}
	return bProcessKeyToAllMenu;
	return;
}

function bool ProcessKeyUp(int Key)
{
	// End:0x2B
	if(__NFUN_130__(__NFUN_155__(m_iLastKeyDown, -1), __NFUN_154__(m_iLastKeyDown, Key)))
	{
		m_iLastKeyDown = -1;
	}
	// End:0x79
	if(__NFUN_154__(Key, int(GetPlayerOwner().__NFUN_2706__("OperativeSelector"))))
	{
		// End:0x6F
		if(__NFUN_154__(int(m_eCurWidgetInUse), int(35)))
		{
			ChangeCurrentWidget(0);
		}
		m_bCanDisplayOperativeSelector = true;
		return false;
	}
	return true;
	return;
}

//===================================================================
// TrapKey: Menu trap the key
//===================================================================
function bool TrapKey(bool _bIncludeMouseMove)
{
	// End:0x1B
	if(_bIncludeMouseMove)
	{
		// End:0x1B
		if(__NFUN_154__(int(m_eCurWidgetInUse), int(34)))
		{
			return false;
		}
	}
	return m_bTrapKey;
	return;
}

//=============================================================================================
// UpdateTimeInBetRound:  Get the time between round pop-up and update the time
//=============================================================================================
function UpdateTimeInBetRound(int _iNewTime, optional string _StringInstead)
{
	local int i, iNbOfWindow;

	iNbOfWindow = m_pListOfActiveWidget.Length;
	i = 0;
	J0x13:

	// End:0x8B [Loop If]
	if(__NFUN_150__(i, iNbOfWindow))
	{
		// End:0x81
		if(__NFUN_132__(__NFUN_154__(int(m_pListOfActiveWidget[i].m_eGameWidgetID), int(26)), __NFUN_154__(int(m_pListOfActiveWidget[i].m_eGameWidgetID), int(25))))
		{
			m_pListOfActiveWidget[i].m_pPopUpFrame.UpdateTimeInTextLabel(_iNewTime, _StringInstead);
			// [Explicit Break]
			goto J0x8B;
		}
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x13;
	}
	J0x8B:

	return;
}

//=================================================================================
// MenuLoadProfile: Advice optionswidget that a load profile was occur
//=================================================================================
function MenuLoadProfile(bool _bServerProfile)
{
	// End:0x1A
	if(__NFUN_129__(_bServerProfile))
	{
		m_pOptionsWidget.MenuOptionsLoadProfile();
	}
	return;
}

defaultproperties
{
	m_bCanDisplayOperativeSelector=true
	m_bJoinTeamWidget=true
	m_bTrapKey=true
	m_sndOpenDrawingTool=Sound'Common_Multiplayer.Play_DrawingTool_Open'
	m_sndCloseDrawingTool=Sound'Common_Multiplayer.Play_DrawingTool_Close'
	m_RJoinWidget=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=6434,ZoneNumber=0)
	m_RInterWidget=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=6434,ZoneNumber=0)
	m_REscPopUp=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=29474,ZoneNumber=0)
	LookAndFeelClass="R6Menu.R6MenuRSLookAndFeel"
}
