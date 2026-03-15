//=============================================================================
// R6MenuInGameRootWindow - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6MenuInGameRootWindow.uc : This ingame root menu should provide us with
//                              uwindow support in the game
//
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/19 * Created by Alexandre Dionne
//=============================================================================
class R6MenuInGameRootWindow extends R6WindowRootWindow
    config;

var int m_ESCMenuKey;
var bool m_bCanDisplayOperativeSelector;
var bool m_bInEscMenu;
var bool m_bInTraining;
var bool m_bInPopUp;
var float m_fTopLabelHeight;
var R6MenuDebriefingWidget m_DebriefingWidget;
var R6MenuInGameInstructionWidget m_pInstructionWidget;
var R6MenuOptionsWidget m_OptionsWidget;
var R6MenuInGameOperativeSelectorWidget m_InGameOperativeSelectorWidget;
//For esc menu and temporarely for enf of games as well
var R6MenuInGameEsc m_EscMenuWidget;
var Region m_REscMenuWidget;  // the border region
var Region m_REscTraining;

function Created()
{
	super(UWindowRootWindow).Created();
	m_eRootId = 2;
	m_bInTraining = (Root.Console.Master.m_StartGameInfo.m_GameMode == "R6Game.R6TrainingMgr");
	m_DebriefingWidget = R6MenuDebriefingWidget(CreateWindow(Class'R6Menu.R6MenuDebriefingWidget', 0.0000000, 0.0000000, 640.0000000, 480.0000000));
	m_DebriefingWidget.HideWindow();
	m_InGameOperativeSelectorWidget = R6MenuInGameOperativeSelectorWidget(CreateWindow(Class'R6Menu.R6MenuInGameOperativeSelectorWidget', 0.0000000, 0.0000000, 640.0000000, 480.0000000));
	m_InGameOperativeSelectorWidget.HideWindow();
	m_EscMenuWidget = R6MenuInGameEsc(CreateWindow(Class'R6Menu.R6MenuInGameEsc', 0.0000000, 0.0000000, 640.0000000, 480.0000000, self));
	m_EscMenuWidget.HideWindow();
	m_OptionsWidget = R6MenuOptionsWidget(CreateWindow(Class'R6Menu.R6MenuOptionsWidget', 0.0000000, 0.0000000, 640.0000000, 480.0000000));
	m_OptionsWidget.HideWindow();
	m_pInstructionWidget = R6MenuInGameInstructionWidget(CreateWindow(Class'R6Menu.R6MenuInGameInstructionWidget', 0.0000000, 0.0000000, 640.0000000, 480.0000000, self));
	m_pInstructionWidget.HideWindow();
	return;
}

//==============================================================================================================
// ChangeInstructionWidget: change the instruction widget -- only in training
//==============================================================================================================
function ChangeInstructionWidget(Actor pISV, bool bShow, int iBox, int iParagraph)
{
	local int i, iNbOfWindow;
	local R6InstructionSoundVolume aISV;

	aISV = R6InstructionSoundVolume(pISV);
	// End:0x8B
	if(bShow)
	{
		m_pInstructionWidget.ChangeText(aISV, iBox, iParagraph);
		iNbOfWindow = m_pListOfActiveWidget.Length;
		i = 0;
		J0x4A:

		// End:0x80 [Loop If]
		if((i < iNbOfWindow))
		{
			// End:0x76
			if((int(m_pListOfActiveWidget[i].m_eGameWidgetID) == int(3)))
			{
				return;
			}
			(i++);
			// [Loop Continue]
			goto J0x4A;
		}
		ChangeCurrentWidget(3);		
	}
	else
	{
		ChangeCurrentWidget(0);
	}
	return;
}

function ChangeCurrentWidget(UWindowRootWindow.eGameWidgetID widgetID)
{
	switch(widgetID)
	{
		// End:0x0C
		case 17:
		// End:0x11
		case 3:
		// End:0x16
		case 35:
		// End:0x1B
		case 2:
		// End:0x30
		case 0:
			ChangeWidget(widgetID, true, false);
			// End:0x50
			break;
		// End:0x35
		case 1:
		// End:0x4A
		case 16:
			ChangeWidget(widgetID, false, false);
			// End:0x50
			break;
		// End:0xFFFF
		default:
			// End:0x50
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

	iNbOfShowWindow = m_pListOfActiveWidget.Length;
	ConsoleState = 'UWindow';
	m_bWidgetResolutionFix = false;
	// End:0x35
	if(_bCloseAll)
	{
		CloseAllWindow();
		iNbOfShowWindow = 0;
	}
	ManagePrevWInHistory(_bClearPrevWInHistory, iNbOfShowWindow);
	m_eCurWidgetInUse = widgetID;
	pStNewWidget.m_eGameWidgetID = widgetID;
	pStNewWidget.m_WidgetConsoleState = ConsoleState;
	GetPopUpFrame(iNbOfShowWindow).m_bBGClientArea = true;
	switch(widgetID)
	{
		// End:0xC2
		case 3:
			pStNewWidget.m_pWidget = m_pInstructionWidget;
			pStNewWidget.m_WidgetConsoleState = 'TrainingInstruction';
			ConsoleState = 'TrainingInstruction';
			// End:0x360
			break;
		// End:0x148
		case 2:
			Root.Console.ViewportOwner.Actor.Level.m_bInGamePlanningActive = false;
			Root.Console.ViewportOwner.Actor.Level.SetPlanningMode(false);
			pStNewWidget.m_pWidget = m_DebriefingWidget;
			m_bWidgetResolutionFix = true;
			// End:0x360
			break;
		// End:0x1CE
		case 35:
			pStNewWidget.m_pPopUpFrame = GetPopUpFrame(iNbOfShowWindow);
			pStNewWidget.m_pPopUpFrame.ModifyPopUpFrameWindow(Localize("OPERATIVESELECTOR", "Title_ID", "R6Menu"), m_fTopLabelHeight, 17.0000000, 33.0000000, 606.0000000, 397.0000000);
			pStNewWidget.m_pWidget = m_InGameOperativeSelectorWidget;
			// End:0x360
			break;
		// End:0x2DC
		case 1:
			pStNewWidget.m_pPopUpFrame = GetPopUpFrame(iNbOfShowWindow);
			// End:0x25F
			if(m_bInTraining)
			{
				pStNewWidget.m_pPopUpFrame.ModifyPopUpFrameWindow(Localize("ESCMENUS", "ESCMENU", "R6Menu"), m_fTopLabelHeight, float(m_REscTraining.X), float(m_REscTraining.Y), float(m_REscTraining.W), float(m_REscTraining.H));				
			}
			else
			{
				pStNewWidget.m_pPopUpFrame.ModifyPopUpFrameWindow(Localize("ESCMENUS", "ESCMENU", "R6Menu"), m_fTopLabelHeight, float(m_REscMenuWidget.X), float(m_REscMenuWidget.Y), float(m_REscMenuWidget.W), float(m_REscMenuWidget.H));
			}
			pStNewWidget.m_pWidget = m_EscMenuWidget;
			// End:0x360
			break;
		// End:0x316
		case 16:
			// End:0x2F4
			if(IsWidgetIsInHistory(2))
			{
				m_bWidgetResolutionFix = true;
			}
			pStNewWidget.m_pWidget = m_OptionsWidget;
			m_OptionsWidget.RefreshOptions();
			// End:0x360
			break;
		// End:0x31B
		case 0:
		// End:0x35A
		case 17:
			// End:0x357
			if((iNbOfShowWindow != 0))
			{
				pStNewWidget = m_pListOfActiveWidget[(iNbOfShowWindow - 1)];
				ConsoleState = pStNewWidget.m_WidgetConsoleState;
				(iNbOfShowWindow -= 1);
			}
			// End:0x360
			break;
		// End:0xFFFF
		default:
			// End:0x360
			break;
			break;
	}
	// End:0x4A6
	if((pStNewWidget.m_pWidget != none))
	{
		// End:0x44A
		if((!Console.IsInState(ConsoleState)))
		{
			// End:0x3CC
			if((ConsoleState == 'TrainingInstruction'))
			{
				Console.ViewportOwner.bSuspendPrecaching = false;
				Console.ViewportOwner.bShowWindowsMouse = false;				
			}
			else
			{
				Console.ViewportOwner.bSuspendPrecaching = true;
				Console.ViewportOwner.bShowWindowsMouse = true;
			}
			Console.bUWindowActive = true;
			// End:0x43F
			if((Console.Root != none))
			{
				Console.Root.bWindowVisible = true;
			}
			CheckConsoleTypingState(ConsoleState);
		}
		// End:0x46E
		if((pStNewWidget.m_pPopUpFrame != none))
		{
			pStNewWidget.m_pPopUpFrame.ShowWindow();
		}
		pStNewWidget.m_pWidget.ShowWindow();
		m_eCurWidgetInUse = pStNewWidget.m_eGameWidgetID;
		m_pListOfActiveWidget[iNbOfShowWindow] = pStNewWidget;		
	}
	else
	{
		Console.bUWindowActive = false;
		Console.ViewportOwner.bShowWindowsMouse = false;
		// End:0x4FF
		if((Console.Root != none))
		{
			Console.Root.bWindowVisible = false;
		}
		CheckConsoleTypingState('Game');
		Console.ViewportOwner.bSuspendPrecaching = false;
	}
	return;
}

function MoveMouse(float X, float Y)
{
	local UWindowWindow NewMouseWindow;
	local float tX, tY;

	MouseX = X;
	MouseY = Y;
	// End:0x3A
	if((!bMouseCapture))
	{
		NewMouseWindow = FindWindowUnder(X, Y);		
	}
	else
	{
		NewMouseWindow = MouseWindow;
	}
	// End:0x7D
	if((NewMouseWindow != MouseWindow))
	{
		MouseWindow.MouseLeave();
		NewMouseWindow.MouseEnter();
		MouseWindow = NewMouseWindow;
	}
	// End:0xE5
	if(((MouseX != OldMouseX) || (MouseY != OldMouseY)))
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
		C.SetDrawColor(byte(255), byte(255), byte(255));
		C.Style = 5;
		C.SetPos((MouseX - float(MouseWindow.Cursor.HotX)), (MouseY - float(MouseWindow.Cursor.HotY)));
		// End:0x143
		if((MouseWindow.Cursor.Tex != none))
		{
			MouseTex = MouseWindow.Cursor.Tex;
			C.DrawTile(MouseTex, float(MouseTex.USize), float(MouseTex.VSize), 0.0000000, 0.0000000, float(MouseTex.USize), float(MouseTex.VSize));
		}
		C.Style = 1;
	}
	return;
}

//==============================================================================
// PopUpBoxDone -  receive the result of the popup box  
//==============================================================================
function PopUpBoxDone(UWindowBase.MessageBoxResult Result, UWindowBase.EPopUpID _ePopUpID)
{
	local R6GameInfo GameInfo;

	super.PopUpBoxDone(Result, _ePopUpID);
	// End:0x360
	if((int(Result) == int(3)))
	{
		switch(_ePopUpID)
		{
			// End:0xBC
			case 50:
				Console.Master.m_StartGameInfo.m_SkipPlanningPhase = false;
				Console.Master.m_StartGameInfo.m_ReloadPlanning = false;
				Console.Master.m_StartGameInfo.m_ReloadActionPointOnly = false;
				R6Console(Console).LeaveR6Game(R6Console(Console).0);
				// End:0x360
				break;
			// End:0xE3
			case 51:
				GetPlayerOwner().StopAllMusic();
				Root.DoQuitGame();
				// End:0x360
				break;
			// End:0x189
			case 52:
				Console.Master.m_StartGameInfo.m_SkipPlanningPhase = true;
				Console.Master.m_StartGameInfo.m_ReloadPlanning = true;
				Console.Master.m_StartGameInfo.m_ReloadActionPointOnly = true;
				m_bInEscMenu = false;
				GetPlayerOwner().StopAllMusic();
				R6Console(Root.Console).ResetR6Game();
				// End:0x360
				break;
			// End:0x21E
			case 54:
				Console.Master.m_StartGameInfo.m_SkipPlanningPhase = false;
				Console.Master.m_StartGameInfo.m_ReloadPlanning = false;
				Console.Master.m_StartGameInfo.m_ReloadActionPointOnly = false;
				R6Console(Console).LeaveR6Game(R6Console(Console).2);
				// End:0x360
				break;
			// End:0x35D
			case 53:
				Console.Master.m_StartGameInfo.m_SkipPlanningPhase = false;
				Console.Master.m_StartGameInfo.m_ReloadPlanning = true;
				Console.Master.m_StartGameInfo.m_ReloadActionPointOnly = false;
				GameInfo = R6GameInfo(Root.Console.ViewportOwner.Actor.Level.Game);
				GetPlayerOwner().StopAllMusic();
				// End:0x324
				if(GameInfo.m_bUsingPlayerCampaign)
				{
					R6Console(Root.Console).LeaveR6Game(R6Console(Root.Console).6);					
				}
				else
				{
					R6Console(Root.Console).LeaveR6Game(R6Console(Root.Console).4);
				}
				// End:0x360
				break;
			// End:0xFFFF
			default:
				break;
		}
	}
	else
	{
		m_bInPopUp = false;
		return;
	}
}

function WindowEvent(UWindowWindow.WinMessage Msg, Canvas C, float X, float Y, int Key)
{
	switch(Msg)
	{
		// End:0x8A
		case 11:
			// End:0x68
			if(((WinWidth != float(C.SizeX)) || (WinHeight != float(C.SizeY))))
			{
				SetResolution(float(C.SizeX), float(C.SizeY));
			}
			super(UWindowRootWindow).WindowEvent(Msg, C, X, Y, Key);
			// End:0x120
			break;
		// End:0xC4
		case 8:
			// End:0xA2
			if((!ProcessKeyUp(Key)))
			{
				// [Explicit Continue]
				goto J0x120;
			}
			super(UWindowRootWindow).WindowEvent(Msg, C, X, Y, Key);
			// End:0x120
			break;
		// End:0xFE
		case 9:
			// End:0xDC
			if((!ProcessKeyDown(Key)))
			{
				// [Explicit Continue]
				goto J0x120;
			}
			super(UWindowRootWindow).WindowEvent(Msg, C, X, Y, Key);
			// End:0x120
			break;
		// End:0xFFFF
		default:
			super(UWindowRootWindow).WindowEvent(Msg, C, X, Y, Key);
			break;
	}
	J0x120:

	return;
}

function SimplePopUp(string _szTitle, string _szText, UWindowBase.EPopUpID _ePopUpID, optional int _iButtonsType, optional bool bAddDisableDlg, optional UWindowWindow OwnerWindow)
{
	m_bInPopUp = true;
	// End:0x37
	if((OwnerWindow == none))
	{
		super.SimplePopUp(_szTitle, _szText, _ePopUpID, _iButtonsType, bAddDisableDlg, self);		
	}
	else
	{
		super.SimplePopUp(_szTitle, _szText, _ePopUpID, _iButtonsType, bAddDisableDlg, OwnerWindow);
	}
	return;
}

//=======================================================================================
// ProcessKeyDown: Process key down for menu, return true, the key is process to all the menus
//=======================================================================================
function bool ProcessKeyDown(int Key)
{
	// End:0x12
	if((int(m_eCurWidgetInUse) == int(16)))
	{
		return true;
	}
	// End:0x12C
	if((Key == m_ESCMenuKey))
	{
		// End:0x40
		if(((m_bInPopUp == true) || (m_iLastKeyDown == m_ESCMenuKey)))
		{
			return true;
		}
		// End:0x11A
		if((int(m_eCurWidgetInUse) != int(1)))
		{
			// End:0x117
			if((!R6GameInfo(Root.Console.ViewportOwner.Actor.Level.Game).m_bGameOver))
			{
				Root.Console.ViewportOwner.Actor.Level.m_bInGamePlanningActive = false;
				Root.Console.ViewportOwner.Actor.Level.SetPlanningMode(false);
				m_iLastKeyDown = m_ESCMenuKey;
				ChangeCurrentWidget(1);
				m_bInEscMenu = true;
			}			
		}
		else
		{
			m_bInEscMenu = false;
			ChangeCurrentWidget(0);
		}
		return false;
	}
	// End:0x185
	if(((Key == int(GetPlayerOwner().GetKey("OperativeSelector"))) && (int(m_eCurWidgetInUse) == int(0))))
	{
		// End:0x183
		if(m_bCanDisplayOperativeSelector)
		{
			m_bCanDisplayOperativeSelector = false;
			ChangeCurrentWidget(35);
		}
		return false;
	}
	return true;
	return;
}

//=======================================================================================
// ProcessKeyUp: Process key up for menu, return true, the key is process to all the menus
//=======================================================================================
function bool ProcessKeyUp(int Key)
{
	// End:0x2B
	if(((m_iLastKeyDown != -1) && (m_iLastKeyDown == m_ESCMenuKey)))
	{
		m_iLastKeyDown = -1;
	}
	// End:0x79
	if((Key == int(GetPlayerOwner().GetKey("OperativeSelector"))))
	{
		// End:0x6F
		if((int(m_eCurWidgetInUse) == int(35)))
		{
			ChangeCurrentWidget(0);
		}
		m_bCanDisplayOperativeSelector = true;
		return false;
	}
	return true;
	return;
}

//=================================================================================
// MenuLoadProfile: Advice optionswidget that a load profile was occur
//=================================================================================
function MenuLoadProfile(bool _bServerProfile)
{
	// End:0x1A
	if((!_bServerProfile))
	{
		m_OptionsWidget.MenuOptionsLoadProfile();
	}
	return;
}

defaultproperties
{
	m_ESCMenuKey=27
	m_bCanDisplayOperativeSelector=true
	m_fTopLabelHeight=30.0000000
	m_REscMenuWidget=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=29474,ZoneNumber=0)
	m_REscTraining=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=29474,ZoneNumber=0)
	LookAndFeelClass="R6Menu.R6MenuRSLookAndFeel"
}
