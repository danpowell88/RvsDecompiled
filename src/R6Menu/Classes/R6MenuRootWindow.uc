//=============================================================================
// R6MenuRootWindow - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6MenuRootWindow.uc : (Root of all windows)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/05/25 * Created by Chaouky Garram
//	  2001/11/12 * Modified by Alexandre Dionne Support multi-Menus	
//=============================================================================
class R6MenuRootWindow extends R6WindowRootWindow
 config;

var UWindowBase.EPopUpID m_ePopUpID;  // ID of currently active pop up menu
var bool m_bReloadPlan;  // Load default plan, this is to be able to retouch last plan
var bool m_bLoadingPlanning;
var bool m_bPlayerPlanInitialized;  // this help us find out if we have to prompt the player with the loading default planing pop up
var bool m_bPlayerDoNotWant3DView;
var bool m_bPlayerWantLegend;
var bool bShowLog;
var bool m_bJoinServerProcess;  // true, we currently join a server
// Don't remove: they are here only to make sure they are referenced (needed by cpp code)
var Texture m_BGTexture0;
var Texture m_BGTexture1;
var R6MenuWidget m_CurrentWidget;
var R6MenuWidget m_PreviousWidget;
var R6MenuIntelWidget m_IntelWidget;
var R6MenuPlanningWidget m_PlanningWidget;
var R6MenuExecuteWidget m_ExecuteWidget;
var R6MenuMainWidget m_MainMenuWidget;
var R6MenuSinglePlayerWidget m_SinglePlayerWidget;
var R6MenuCustomMissionWidget m_CustomMissionWidget;
var R6MenuTrainingWidget m_TrainingWidget;
var R6MenuMultiPlayerWidget m_MultiPlayerWidget;
var R6MenuOptionsWidget m_OptionsWidget;
var R6MenuCreditsWidget m_CreditsWidget;
var R6MenuGearWidget m_GearRoomWidget;
// NEW IN 1.60
var R6MenuCDKeyManager m_pMenuCDKeyManager;
var R6MenuMPCreateGameWidget m_pMPCreateGameWidget;
var R6MenuUbiComWidget m_pUbiComWidget;
// NEW IN 1.60
var R6MenuUbiComModsWidget m_pUbiComModsWidget;
var R6MenuNonUbiWidget m_pNonUbiWidget;
var R6MenuQuit m_pMenuQuit;
var R6FileManager m_pFileManager;
/////////////////////////////////////////////////////////////////////////////////////////
//                                  POP UP
/////////////////////////////////////////////////////////////////////////////////////////
var R6WindowPopUpBox m_PopUpSavePlan;
// NEW IN 1.60
var R6WindowPopUpBox m_PopUpLoadPlan;
var Sound m_MainMenuMusic;  // Music for the MainMenu
/////////////////////////////////////////////////////////////////////////////////
var array<R6Operative> m_GameOperatives;

function Created()
{
	local R6WindowEditBox EditPopUpBox;
	local R6WindowTextListBox SavedPlanningListBox;
	local R6GameOptions pGameOptions;

	// End:0x27
	if(bShowLog)
	{
		__NFUN_231__("R6MenuRootWindow Created()");
	}
	super(UWindowRootWindow).Created();
	R6Console(Console).InitializedGameService();
	m_pFileManager = new Class'Engine.R6FileManager';
	// End:0x75
	if(__NFUN_114__(m_pFileManager, none))
	{
		__NFUN_231__("m_pFileManager == NONE");
	}
	pGameOptions = Class'Engine.Actor'.static.__NFUN_1009__();
	m_bPlayerDoNotWant3DView = pGameOptions.Hide3DView;
	m_eRootId = 1;
	SetResolution(640.0000000, 480.0000000);
	m_IntelWidget = R6MenuIntelWidget(CreateWindow(MenuClassDefines.ClassIntelWidget, WinLeft, WinTop, WinWidth, WinHeight, self));
	m_IntelWidget.Close();
	m_PlanningWidget = R6MenuPlanningWidget(CreateWindow(MenuClassDefines.ClassPlanningWidget, WinLeft, WinTop, WinWidth, WinHeight, self));
	m_PlanningWidget.Close();
	m_ExecuteWidget = R6MenuExecuteWidget(CreateWindow(MenuClassDefines.ClassExecuteWidget, WinLeft, WinTop, WinWidth, WinHeight, self));
	m_ExecuteWidget.Close();
	m_SinglePlayerWidget = R6MenuSinglePlayerWidget(CreateWindow(MenuClassDefines.ClassSinglePlayerWidget, WinLeft, WinTop, WinWidth, WinHeight, self));
	m_SinglePlayerWidget.Close();
	m_CustomMissionWidget = R6MenuCustomMissionWidget(CreateWindow(MenuClassDefines.ClassCustomMissionWidget, WinLeft, WinTop, WinWidth, WinHeight, self));
	m_CustomMissionWidget.Close();
	m_TrainingWidget = R6MenuTrainingWidget(CreateWindow(MenuClassDefines.ClassTrainingWidget, WinLeft, WinTop, WinWidth, WinHeight, self));
	m_TrainingWidget.Close();
	HarmonizeMenuFonts();
	m_MultiPlayerWidget = R6MenuMultiPlayerWidget(CreateWindow(MenuClassDefines.ClassMultiPlayerWidget, WinLeft, WinTop, WinWidth, WinHeight, self));
	m_MultiPlayerWidget.Close();
	m_OptionsWidget = R6MenuOptionsWidget(CreateWindow(MenuClassDefines.ClassOptionsWidget, WinLeft, WinTop, WinWidth, WinHeight, self));
	m_OptionsWidget.Close();
	m_CreditsWidget = R6MenuCreditsWidget(CreateWindow(MenuClassDefines.ClassCreditsWidget, WinLeft, WinTop, WinWidth, WinHeight, self));
	m_CreditsWidget.Close();
	m_GearRoomWidget = R6MenuGearWidget(CreateWindow(MenuClassDefines.ClassGearWidget, WinLeft, WinTop, WinWidth, WinHeight, self));
	m_GearRoomWidget.Close();
	m_pMenuCDKeyManager = R6MenuCDKeyManager(CreateWindow(MenuClassDefines.ClassMenuCDKeyManager, WinLeft, WinTop, WinWidth, WinHeight, self));
	m_pMenuCDKeyManager.Close();
	m_pMPCreateGameWidget = R6MenuMPCreateGameWidget(CreateWindow(MenuClassDefines.ClassMPCreateGameWidget, WinLeft, WinTop, WinWidth, WinHeight, self));
	m_pMPCreateGameWidget.Close();
	m_pUbiComWidget = R6MenuUbiComWidget(CreateWindow(MenuClassDefines.ClassUbiComWidget, WinLeft, WinTop, WinWidth, WinHeight, self));
	m_pUbiComWidget.Close();
	m_pUbiComModsWidget = R6MenuUbiComModsWidget(CreateWindow(Class'R6Menu.R6MenuUbiComModsWidget', WinLeft, WinTop, WinWidth, WinHeight, self));
	m_pUbiComModsWidget.Close();
	m_pNonUbiWidget = R6MenuNonUbiWidget(CreateWindow(MenuClassDefines.ClassNonUbiComWidget, WinLeft, WinTop, WinWidth, WinHeight, self));
	m_pNonUbiWidget.Close();
	m_pMenuQuit = R6MenuQuit(CreateWindow(MenuClassDefines.ClassQuitWidget, WinLeft, WinTop, WinWidth, WinHeight, self));
	m_pMenuQuit.Close();
	m_MainMenuWidget = R6MenuMainWidget(CreateWindow(MenuClassDefines.ClassMainWidget, WinLeft, WinTop, WinWidth, WinHeight, self));
	m_MainMenuWidget.Close();
	AssignShowFirstWidget();
	m_CurrentWidget.SetMousePos(__NFUN_171__(WinWidth, 0.5000000), __NFUN_171__(WinHeight, 0.5000000));
	m_ePopUpID = 0;
	m_PopUpSavePlan = R6WindowPopUpBox(CreateWindow(Class'R6Window.R6WindowPopUpBox', 0.0000000, 0.0000000, 640.0000000, 480.0000000));
	m_PopUpSavePlan.CreateStdPopUpWindow(Localize("POPUP", "PopUpTitle_SavePlan", "R6Menu"), 30.0000000, 188.0000000, 150.0000000, 264.0000000, 180.0000000);
	m_PopUpSavePlan.CreateClientWindow(Class'R6Menu.R6MenuSavePlan', false, true);
	m_PopUpSavePlan.m_ePopUpID = 47;
	m_PopUpSavePlan.HideWindow();
	m_PopUpLoadPlan = R6WindowPopUpBox(CreateWindow(Class'R6Window.R6WindowPopUpBox', 0.0000000, 0.0000000, 640.0000000, 480.0000000));
	m_PopUpLoadPlan.CreateStdPopUpWindow(Localize("POPUP", "PopUpTitle_Load", "R6Menu"), 30.0000000, 188.0000000, 150.0000000, 264.0000000, 180.0000000);
	m_PopUpLoadPlan.CreateClientWindow(Class'R6Menu.R6MenuLoadPlan', false, true);
	m_PopUpLoadPlan.m_ePopUpID = 48;
	m_PopUpLoadPlan.HideWindow();
	GUIScale = 1.0000000;
	// End:0x6F4
	if(__NFUN_129__(R6Console(Console).m_bStartedByGSClient))
	{
		GetPlayerOwner().PlayMusic(m_MainMenuMusic, true);
	}
	return;
}

function AssignShowFirstWidget()
{
	// End:0x25
	if(R6Console(Console).m_bStartedByGSClient)
	{
		m_CurrentWidget = m_pUbiComWidget;		
	}
	else
	{
		// End:0x4A
		if(R6Console(Console).m_bNonUbiMatchMaking)
		{
			m_CurrentWidget = m_pNonUbiWidget;			
		}
		else
		{
			// End:0x7E
			if(R6Console(Console).m_bNonUbiMatchMakingHost)
			{
				m_CurrentWidget = m_pMPCreateGameWidget;
				m_pMPCreateGameWidget.RefreshCreateGameMenu();				
			}
			else
			{
				m_CurrentWidget = m_MainMenuWidget;
			}
		}
	}
	m_CurrentWidget.ShowWindow();
	return;
}

function Set3dView(bool bSelected)
{
	local R6GameOptions pGameOptions;

	pGameOptions = Class'Engine.Actor'.static.__NFUN_1009__();
	pGameOptions.Hide3DView = bSelected;
	m_bPlayerDoNotWant3DView = bSelected;
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
		// End:0xD1
		if(__NFUN_242__(m_bUseAimIcon, true))
		{
			C.__NFUN_2623__(__NFUN_175__(__NFUN_171__(MouseX, GUIScale), float(AimCursor.HotX)), __NFUN_175__(__NFUN_171__(MouseY, GUIScale), float(AimCursor.HotY)));
			MouseTex = AimCursor.Tex;			
		}
		else
		{
			// End:0x130
			if(__NFUN_242__(m_bUseDragIcon, true))
			{
				C.__NFUN_2623__(__NFUN_175__(__NFUN_171__(MouseX, GUIScale), float(DragCursor.HotX)), __NFUN_175__(__NFUN_171__(MouseY, GUIScale), float(DragCursor.HotY)));
				MouseTex = DragCursor.Tex;				
			}
			else
			{
				C.__NFUN_2623__(__NFUN_175__(__NFUN_171__(MouseX, GUIScale), float(MouseWindow.Cursor.HotX)), __NFUN_175__(__NFUN_171__(MouseY, GUIScale), float(MouseWindow.Cursor.HotY)));
				MouseTex = MouseWindow.Cursor.Tex;
			}
		}
		fMouseClipX = __NFUN_171__(m_CurrentWidget.m_fRightMouseXClipping, GUIScale);
		fMouseClipY = __NFUN_171__(m_CurrentWidget.m_fRightMouseYClipping, GUIScale);
		C.__NFUN_2625__(fMouseClipX, fMouseClipY);
		// End:0x24D
		if(__NFUN_119__(MouseTex, none))
		{
			C.__NFUN_468__(MouseTex, float(MouseTex.USize), float(MouseTex.VSize), 0.0000000, 0.0000000, float(MouseTex.USize), float(MouseTex.VSize));
		}
		C.Style = 1;
	}
	return;
}

function ResetMenus(optional bool _bConnectionFailed)
{
	// End:0x1B
	if(_bConnectionFailed)
	{
		m_MultiPlayerWidget.ResetMultiplayerMenu();		
	}
	else
	{
		m_IntelWidget.Reset();
		m_PlanningWidget.Reset();
		m_bPlayerPlanInitialized = false;
	}
	return;
}

function UpdateMenus(int iWhatToUpdate)
{
	// End:0x1F
	if(__NFUN_119__(m_PlanningWidget, none))
	{
		m_PlanningWidget.ResetTeams(iWhatToUpdate);
	}
	return;
}

function MoveMouse(float X, float Y)
{
	// End:0x24
	if(__NFUN_119__(m_CurrentWidget, none))
	{
		m_CurrentWidget.SetMousePos(X, Y);
	}
	super(UWindowRootWindow).MoveMouse(Console.MouseX, Console.MouseY);
	return;
}

function ClosePopups()
{
	// End:0x1E
	if(__NFUN_114__(m_CurrentWidget, m_PlanningWidget))
	{
		m_PlanningWidget.Hide3DAndLegend();
	}
	return;
}

function bool IsInsidePlanning()
{
	return __NFUN_132__(__NFUN_132__(__NFUN_132__(__NFUN_132__(__NFUN_132__(__NFUN_154__(int(m_ePrevWidgetInUse), int(8)), __NFUN_154__(int(m_ePrevWidgetInUse), int(12))), __NFUN_154__(int(m_ePrevWidgetInUse), int(9))), __NFUN_154__(int(m_ePrevWidgetInUse), int(13))), __NFUN_154__(int(m_ePrevWidgetInUse), int(10))), __NFUN_154__(int(m_ePrevWidgetInUse), int(11)));
	return;
}

function ChangeCurrentWidget(UWindowRootWindow.eGameWidgetID widgetID)
{
	local bool bDontQuitNow;

	m_bJoinServerProcess = false;
	// End:0x2E
	if(__NFUN_154__(int(widgetID), int(17)))
	{
		m_eCurWidgetInUse = m_ePrevWidgetInUse;
		m_ePrevWidgetInUse = 0;		
	}
	else
	{
		m_ePrevWidgetInUse = m_eCurWidgetInUse;
		m_eCurWidgetInUse = widgetID;
		// End:0x7A
		if(__NFUN_154__(int(m_ePrevWidgetInUse), int(9)))
		{
			// End:0x7A
			if(__NFUN_119__(R6PlanningCtrl(GetPlayerOwner()), none))
			{
				R6PlanningCtrl(GetPlayerOwner()).CancelActionPointAction();
			}
		}
	}
	switch(widgetID)
	{
		// End:0xBD
		case 5:
			m_CurrentWidget.HideWindow();
			m_PreviousWidget = m_CurrentWidget;
			m_CurrentWidget = m_SinglePlayerWidget;
			m_CurrentWidget.ShowWindow();
			// End:0x5D3
			break;
		// End:0xF9
		case 4:
			m_CurrentWidget.HideWindow();
			m_PreviousWidget = m_CurrentWidget;
			m_CurrentWidget = m_TrainingWidget;
			m_CurrentWidget.ShowWindow();
			// End:0x5D3
			break;
		// End:0x15E
		case 7:
			// End:0x121
			if(__NFUN_114__(m_CurrentWidget, m_MultiPlayerWidget))
			{
				R6MenuMultiPlayerWidget(m_CurrentWidget).BackToMainMenu();
			}
			m_CurrentWidget.HideWindow();
			m_PreviousWidget = m_CurrentWidget;
			m_CurrentWidget = m_MainMenuWidget;
			m_CurrentWidget.ShowWindow();
			ResetMenus();
			// End:0x5D3
			break;
		// End:0x19A
		case 8:
			m_CurrentWidget.HideWindow();
			m_PreviousWidget = m_CurrentWidget;
			m_CurrentWidget = m_IntelWidget;
			m_CurrentWidget.ShowWindow();
			// End:0x5D3
			break;
		// End:0x1C6
		case 11:
			ResetCustomMissionOperatives();
			m_bReloadPlan = true;
			m_bLoadingPlanning = true;
			m_bPlayerPlanInitialized = true;
			GotoPlanning();
			// End:0x5D3
			break;
		// End:0x211
		case 9:
			// End:0x20E
			if(__NFUN_119__(m_CurrentWidget, m_PlanningWidget))
			{
				m_CurrentWidget.HideWindow();
				m_PreviousWidget = m_CurrentWidget;
				m_CurrentWidget = m_PlanningWidget;
				m_CurrentWidget.ShowWindow();
			}
			// End:0x5D3
			break;
		// End:0x24D
		case 13:
			m_CurrentWidget.HideWindow();
			m_PreviousWidget = m_CurrentWidget;
			m_CurrentWidget = m_ExecuteWidget;
			m_CurrentWidget.ShowWindow();
			// End:0x5D3
			break;
		// End:0x289
		case 12:
			m_CurrentWidget.HideWindow();
			m_PreviousWidget = m_CurrentWidget;
			m_CurrentWidget = m_GearRoomWidget;
			m_CurrentWidget.ShowWindow();
			// End:0x5D3
			break;
		// End:0x2C5
		case 14:
			m_CurrentWidget.HideWindow();
			m_PreviousWidget = m_CurrentWidget;
			m_CurrentWidget = m_CustomMissionWidget;
			m_CurrentWidget.ShowWindow();
			// End:0x5D3
			break;
		// End:0x301
		case 15:
			m_CurrentWidget.HideWindow();
			m_PreviousWidget = m_CurrentWidget;
			m_CurrentWidget = m_MultiPlayerWidget;
			m_CurrentWidget.ShowWindow();
			// End:0x5D3
			break;
		// End:0x33D
		case 20:
			m_CurrentWidget.HideWindow();
			m_PreviousWidget = m_CurrentWidget;
			m_CurrentWidget = m_pUbiComWidget;
			m_CurrentWidget.ShowWindow();
			// End:0x5D3
			break;
		// End:0x379
		case 21:
			m_CurrentWidget.HideWindow();
			m_PreviousWidget = m_CurrentWidget;
			m_CurrentWidget = m_pUbiComModsWidget;
			m_CurrentWidget.ShowWindow();
			// End:0x5D3
			break;
		// End:0x414
		case 36:
			// End:0x3AF
			if(R6Console(Console).m_bStartedByGSClient)
			{
				ChangeCurrentWidget(20);
				m_pUbiComWidget.PromptConnectionError();				
			}
			else
			{
				// End:0x3E0
				if(R6Console(Console).m_bNonUbiMatchMaking)
				{
					ChangeCurrentWidget(22);
					m_pNonUbiWidget.PromptConnectionError();					
				}
				else
				{
					// End:0x3FA
					if(R6Console(Console).m_bNonUbiMatchMakingHost)
					{						
					}
					else
					{
						ChangeCurrentWidget(15);
						m_MultiPlayerWidget.PromptConnectionError();
					}
				}
			}
			// End:0x5D3
			break;
		// End:0x433
		case 37:
			ChangeCurrentWidget(20);
			m_pUbiComWidget.PromptConnectionError();
			// End:0x5D3
			break;
		// End:0x47E
		case 16:
			m_CurrentWidget.HideWindow();
			m_PreviousWidget = m_CurrentWidget;
			m_CurrentWidget = m_OptionsWidget;
			m_OptionsWidget.RefreshOptions();
			m_CurrentWidget.ShowWindow();
			// End:0x5D3
			break;
		// End:0x4BA
		case 18:
			m_CurrentWidget.HideWindow();
			m_PreviousWidget = m_CurrentWidget;
			m_CurrentWidget = m_CreditsWidget;
			m_CurrentWidget.ShowWindow();
			// End:0x5D3
			break;
		// End:0x505
		case 19:
			m_CurrentWidget.HideWindow();
			m_PreviousWidget = m_CurrentWidget;
			m_CurrentWidget = m_pMPCreateGameWidget;
			m_pMPCreateGameWidget.RefreshCreateGameMenu();
			m_CurrentWidget.ShowWindow();
			// End:0x5D3
			break;
		// End:0x524
		case 10:
			m_bReloadPlan = true;
			m_bPlayerPlanInitialized = true;
			GotoCampaignPlanning(true);
			// End:0x5D3
			break;
		// End:0x533
		case 6:
			GotoCampaignPlanning(false);
			// End:0x5D3
			break;
		// End:0x58A
		case 38:
			// End:0x578
			if(bDontQuitNow)
			{
				m_CurrentWidget.HideWindow();
				m_PreviousWidget = m_CurrentWidget;
				m_CurrentWidget = m_pMenuQuit;
				m_CurrentWidget.ShowWindow();				
			}
			else
			{
				Root.DoQuitGame();
			}
			// End:0x5D3
			break;
		// End:0x5CD
		case 17:
			// End:0x5CA
			if(__NFUN_119__(m_PreviousWidget, none))
			{
				m_CurrentWidget.HideWindow();
				m_CurrentWidget = m_PreviousWidget;
				m_PreviousWidget = none;
				m_CurrentWidget.ShowWindow();
			}
			// End:0x5D3
			break;
		// End:0xFFFF
		default:
			// End:0x5D3
			break;
			break;
	}
	return;
}

function bool PlanningShouldProcessKey()
{
	// End:0x24
	if(__NFUN_130__(__NFUN_154__(int(m_ePopUpID), int(0)), __NFUN_154__(int(m_eCurWidgetInUse), int(9))))
	{
		return true;
	}
	return false;
	return;
}

function bool PlanningShouldDrawPath()
{
	// End:0x12
	if(__NFUN_154__(int(m_eCurWidgetInUse), int(9)))
	{
		return true;
	}
	return false;
	return;
}

function ResetCustomMissionOperatives()
{
	local R6Operative tmpOperative;
	local Class<R6Operative> tmpOperativeClass;
	local int iNbArrayElements, iNbTotalOperatives, i;
	local R6ModMgr pModManager;

	pModManager = Class'Engine.Actor'.static.__NFUN_1524__();
	m_GameOperatives.Remove(0, m_GameOperatives.Length);
	iNbArrayElements = R6Console(Console).m_CurrentCampaign.m_OperativeClassName.Length;
	i = 0;
	J0x49:

	// End:0xAF [Loop If]
	if(__NFUN_150__(i, iNbArrayElements))
	{
		tmpOperative = new (none) Class<R6Operative>(DynamicLoadObject(R6Console(Console).m_CurrentCampaign.m_OperativeClassName[i], Class'Core.Class'));
		m_GameOperatives[i] = tmpOperative;
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x49;
	}
	iNbTotalOperatives = i;
	// End:0x19E
	if(__NFUN_242__(pModManager.m_pCurrentMod.m_bUseCustomOperatives, true))
	{
		i = 0;
		J0xDF:

		// End:0x19E [Loop If]
		if(__NFUN_150__(i, pModManager.GetPackageMgr().GetNbPackage()))
		{
			tmpOperativeClass = Class<R6Operative>(pModManager.GetPackageMgr().GetFirstClassFromPackage(i, Class'R6Game.R6Operative'));
			J0x130:

			// End:0x194 [Loop If]
			if(__NFUN_119__(tmpOperativeClass, none))
			{
				tmpOperative = new (none) tmpOperativeClass;
				// End:0x16D
				if(__NFUN_119__(tmpOperative, none))
				{
					m_GameOperatives[iNbTotalOperatives] = tmpOperative;
					__NFUN_165__(iNbTotalOperatives);
				}
				tmpOperativeClass = Class<R6Operative>(pModManager.GetPackageMgr().GetNextClassFromPackage());
				// [Loop Continue]
				goto J0x130;
			}
			__NFUN_165__(i);
			// [Loop Continue]
			goto J0xDF;
		}
	}
	return;
}

function KeyType(int iInputKey, float X, float Y)
{
	m_CurrentWidget.KeyType(iInputKey, X, Y);
	return;
}

function WindowEvent(UWindowWindow.WinMessage Msg, Canvas C, float X, float Y, int Key)
{
	// End:0xD1
	if(bShowLog)
	{
		switch(Msg)
		{
			// End:0x50
			case 9:
				__NFUN_231__(__NFUN_168__("R6MenuRoot::WindowEvent Msg= WM_KeyDown Key", string(Key)));
				// End:0xD1
				break;
			// End:0x8E
			case 8:
				__NFUN_231__(__NFUN_168__("R6MenuRoot::WindowEvent Msg= WM_KeyUp Key", string(Key)));
				// End:0xD1
				break;
			// End:0xCE
			case 10:
				__NFUN_231__(__NFUN_168__("R6MenuRoot::WindowEvent Msg= WM_KeyType Key", string(Key)));
				// End:0xD1
				break;
			// End:0xFFFF
			default:
				break;
		}
	}
	else
	{
		// End:0x15A
		if(__NFUN_155__(int(Msg), int(11)))
		{
			// End:0x10E
			if(__NFUN_132__(Console.m_bInterruptConnectionProcess, R6Console(Console).m_bRenderMenuOneTime))
			{
				return;
			}
			// End:0x15A
			if(m_bJoinServerProcess)
			{
				// End:0x15A
				if(__NFUN_154__(int(Msg), int(9)))
				{
					// End:0x15A
					if(__NFUN_154__(Key, int(Root.Console.27)))
					{
						Console.m_bInterruptConnectionProcess = true;
						return;
					}
				}
			}
		}
		switch(Msg)
		{
			// End:0x183
			case 9:
				// End:0x180
				if(HotKeyDown(Key, X, Y))
				{
					return;
				}
				// End:0x1A8
				break;
			// End:0x1A5
			case 8:
				// End:0x1A2
				if(HotKeyUp(Key, X, Y))
				{
					return;
				}
				// End:0x1A8
				break;
			// End:0xFFFF
			default:
				break;
		}
		// End:0x1E7
		if(__NFUN_132__(__NFUN_154__(int(Msg), int(11)), __NFUN_129__(WaitModal())))
		{
			super(UWindowRootWindow).WindowEvent(Msg, C, X, Y, Key);			
		}
		else
		{
			// End:0x238
			if(WaitModal())
			{
				ModalWindow.WindowEvent(Msg, C, __NFUN_175__(X, ModalWindow.WinLeft), __NFUN_175__(Y, ModalWindow.WinTop), Key);
			}
		}
		return;
	}
}

function GotoCampaignPlanning(bool _bRetrying)
{
	local R6PlayerCampaign PlayerCampaign;
	local int iNbArrayElements, i;
	local R6MissionDescription CurrentMission;
	local R6Console CurrentConsole;

	CurrentConsole = R6Console(Console);
	PlayerCampaign = CurrentConsole.m_PlayerCampaign;
	iNbArrayElements = 0;
	// End:0x75
	if(bShowLog)
	{
		__NFUN_231__(__NFUN_112__("start GotoPlanning PlayerCampaign.m_FileName=", PlayerCampaign.m_FileName));
	}
	CurrentConsole.m_CurrentCampaign = new (none) Class'R6Game.R6Campaign';
	CurrentConsole.m_CurrentCampaign.InitCampaign(GetLevel(), PlayerCampaign.m_CampaignFileName, CurrentConsole);
	CurrentMission = CurrentConsole.m_CurrentCampaign.m_missions[PlayerCampaign.m_iNoMission];
	CurrentConsole.Master.m_StartGameInfo.m_CurrentMission = CurrentMission;
	// End:0x140
	if(bShowLog)
	{
		__NFUN_231__(__NFUN_168__("m_CurrentCampaign", string(CurrentConsole.m_CurrentCampaign)));
	}
	// End:0x164
	if(bShowLog)
	{
		__NFUN_231__(__NFUN_168__("currentMission", string(CurrentMission)));
	}
	CurrentConsole.Master.m_StartGameInfo.m_MapName = CurrentMission.m_MapName;
	// End:0x1C8
	if(bShowLog)
	{
		__NFUN_231__(__NFUN_168__("currentMission.m_MapName", CurrentMission.m_MapName));
	}
	CurrentConsole.Master.m_StartGameInfo.m_DifficultyLevel = PlayerCampaign.m_iDifficultyLevel;
	// End:0x237
	if(bShowLog)
	{
		__NFUN_231__(__NFUN_168__("PlayerCampaign.m_iDifficultyLevel", string(PlayerCampaign.m_iDifficultyLevel)));
	}
	CurrentConsole.Master.m_StartGameInfo.m_GameMode = "R6Game.R6StoryModeGame";
	iNbArrayElements = PlayerCampaign.m_OperativesMissionDetails.m_MissionOperatives.Length;
	// End:0x2D1
	if(bShowLog)
	{
		__NFUN_231__(__NFUN_168__("m_MissionOperatives.Length", string(PlayerCampaign.m_OperativesMissionDetails.m_MissionOperatives.Length)));
	}
	m_GameOperatives.Remove(0, m_GameOperatives.Length);
	i = 0;
	J0x2E5:

	// End:0x327 [Loop If]
	if(__NFUN_150__(i, iNbArrayElements))
	{
		m_GameOperatives[i] = PlayerCampaign.m_OperativesMissionDetails.m_MissionOperatives[i];
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x2E5;
	}
	// End:0x344
	if(bShowLog)
	{
		__NFUN_231__("end GotoPlanning");
	}
	m_bLoadingPlanning = true;
	// End:0x35E
	if(_bRetrying)
	{
		GotoPlanning();		
	}
	else
	{
		CurrentConsole.PreloadMapForPlanning();
	}
	return;
}

function GotoPlanning()
{
	local Player CurrentPlayer;
	local PlayerController NewController;
	local R6IORotatingDoor RotDoor;
	local R6DeploymentZone DeployZone;

	// End:0x1DB
	if(m_bLoadingPlanning)
	{
		// End:0x1BC
		if(m_bReloadPlan)
		{
			R6GameInfo(GetLevel().Game).RestartGameMgr();
			CurrentPlayer = GetPlayerOwner().Player;
			GetPlayerOwner().__NFUN_279__();
			NewController = GetLevel().__NFUN_278__(Class'R6Game.R6PlanningCtrl');
			R6GameInfo(GetLevel().Game).__NFUN_2010__(NewController, CurrentPlayer);
			R6GameInfo(GetLevel().Game).bRestartLevel = false;
			R6GameInfo(GetLevel().Game).RestartPlayer(NewController);
			R6PlanningCtrl(NewController).SetPlanningInfo();
			NewController.SpawnDefaultHUD();
			NewController.__NFUN_2709__(1);
			R6PlanningCtrl(GetPlayerOwner()).DeleteEverySingleNode();
			R6PlanningCtrl(GetPlayerOwner()).m_pFileManager.__NFUN_1416__("Backup", "Backup", "Backup", "", "Backup.pln", Console.Master.m_StartGameInfo);
			R6PlanningCtrl(GetPlayerOwner()).InitNewPlanning(R6PlanningCtrl(GetPlayerOwner()).m_pFileManager.m_iCurrentTeam);
			m_GearRoomWidget.LoadRosterFromStartInfo();
			m_bReloadPlan = false;			
		}
		else
		{
			m_GearRoomWidget.Reset();
		}
		m_bLoadingPlanning = false;
		ChangeCurrentWidget(8);
	}
	return;
}

function LaunchQuickPlay()
{
	local string szFileName;

	szFileName = R6MissionDescription(R6Console(Console).Master.m_StartGameInfo.m_CurrentMission).m_ShortName;
	szFileName = __NFUN_112__(szFileName, R6AbstractGameInfo(GetLevel().Game).m_szDefaultActionPlan);
	// End:0x11C
	if(LoadAPlanning(__NFUN_235__(szFileName)))
	{
		// End:0xB7
		if(m_GearRoomWidget.IsTeamConfigValid())
		{
			StopWidgetSound();
			m_PlanningWidget.m_PlanningBar.m_TimeLine.Reset();
			LeaveForGame(false, 0);			
		}
		else
		{
			SimplePopUp(Localize("POPUP", "INCOMPLETEPLANNING", "R6Menu"), Localize("POPUP", "INCOMPLETEPLANNINGPROBLEM", "R6Menu"), 49, int(2));
		}
	}
	return;
}

function NotifyAfterLevelChange()
{
	GotoPlanning();
	return;
}

//==============================================================================
// PopUp The good menu
//==============================================================================
function PopUpMenu(optional bool _bautoLoadPrompt)
{
	local int i, iMax;
	local R6WindowListBoxItem NewItem;
	local string szFileName;

	switch(m_ePopUpID)
	{
		// End:0x70
		case 47:
			FillListOfSavedPlan(R6MenuSavePlan(m_PopUpSavePlan.m_ClientArea).m_pListOfSavedPlan);
			m_PopUpSavePlan.ShowWindow();
			R6MenuSavePlan(m_PopUpSavePlan.m_ClientArea).m_pEditSaveNameBox.LMouseDown(0.0000000, 0.0000000);
			// End:0x17A
			break;
		// End:0x177
		case 48:
			// End:0xE6
			if(_bautoLoadPrompt)
			{
				m_PopUpLoadPlan.ModifyPopUpFrameWindow(Localize("POPUP", "PopUpTitle_Load", "R6Menu"), 30.0000000, 165.0000000, 150.0000000, 310.0000000, 180.0000000);
				m_PopUpLoadPlan.AddDisableDLG();
				m_bPlayerPlanInitialized = true;				
			}
			else
			{
				m_PopUpLoadPlan.ModifyPopUpFrameWindow(Localize("POPUP", "PopUpTitle_Load", "R6Menu"), 30.0000000, 188.0000000, 150.0000000, 264.0000000, 180.0000000);
				m_PopUpLoadPlan.RemoveDisableDLG();
			}
			FillListOfSavedPlan(R6MenuLoadPlan(m_PopUpLoadPlan.m_ClientArea).m_pListOfSavedPlan);
			m_PopUpLoadPlan.ShowWindow();
			// End:0x17A
			break;
		// End:0xFFFF
		default:
			break;
	}
	return;
}

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
	return;
}

//==============================================================================
// PopUpBoxDone -  receive the result of the popup box  
//==============================================================================
function PopUpBoxDone(UWindowBase.MessageBoxResult Result, UWindowBase.EPopUpID _ePopUpID)
{
	local string szFileName;
	local R6WindowListBoxItem SelectedItem;
	local R6WindowTextListBox SavedPlanningListBox;
	local R6StartGameInfo StartGameInfo;
	local R6MissionDescription mission;
	local string szMapName, szGameTypeDirName, szEnglishGTDirectory;

	super.PopUpBoxDone(Result, _ePopUpID);
	// End:0x56F
	if(__NFUN_154__(int(Result), int(3)))
	{
		switch(_ePopUpID)
		{
			// End:0x2C
			case 4:
			// End:0x2AE
			case 47:
				szFileName = R6MenuSavePlan(m_PopUpSavePlan.m_ClientArea).m_pEditSaveNameBox.GetValue();
				// End:0x2AB
				if(__NFUN_123__(szFileName, ""))
				{
					// End:0x8B
					if(__NFUN_154__(int(_ePopUpID), int(4)))
					{
						m_PopUpSavePlan.HideWindow();						
					}
					else
					{
						// End:0xFC
						if(IsSaveFileAlreadyExist(szFileName))
						{
							m_ePopUpID = 47;
							PopUpMenu();
							SimplePopUp(Localize("POPUP", "SaveFileExist", "R6Menu"), Localize("POPUP", "SaveFileExistMsg", "R6Menu"), 4);
							return;
						}
					}
					R6PlanningCtrl(GetPlayerOwner()).ResetAllID();
					m_GearRoomWidget.SetStartTeamInfoForSaving();
					R6PlanningCtrl(GetPlayerOwner()).m_pFileManager.m_iCurrentTeam = R6PlanningCtrl(GetPlayerOwner()).m_iCurrentTeam;
					StartGameInfo = Console.Master.m_StartGameInfo;
					mission = R6MissionDescription(StartGameInfo.m_CurrentMission);
					szMapName = Localize(mission.m_MapName, "ID_MENUNAME", mission.LocalizationFile, true);
					// End:0x1EA
					if(__NFUN_122__(szMapName, ""))
					{
						szMapName = string(GetLevel().Outer.Name);
					}
					GetLevel().GetGameTypeSaveDirectories(szGameTypeDirName, szEnglishGTDirectory);
					// End:0x2AB
					if(__NFUN_242__(R6PlanningCtrl(GetPlayerOwner()).m_pFileManager.__NFUN_1417__(mission.m_MapName, szMapName, szEnglishGTDirectory, szGameTypeDirName, szFileName, StartGameInfo), false))
					{
						SimplePopUp(Localize("POPUP", "FILEERROR", "R6Menu"), __NFUN_168__(__NFUN_168__(szFileName, ":"), Localize("POPUP", "FILEERRORPROBLEM", "R6Menu")), 2, int(2));
					}
				}
				// End:0x56C
				break;
			// End:0x328
			case 48:
				SavedPlanningListBox = R6MenuLoadPlan(m_PopUpLoadPlan.m_ClientArea).m_pListOfSavedPlan;
				// End:0x325
				if(__NFUN_119__(SavedPlanningListBox.m_SelectedItem, none))
				{
					szFileName = R6WindowListBoxItem(SavedPlanningListBox.m_SelectedItem).HelpText;
					// End:0x31A
					if(__NFUN_122__(szFileName, ""))
					{
						// [Explicit Continue]
						goto J0x56C;
					}
					LoadAPlanning(szFileName);
				}
				// End:0x56C
				break;
			// End:0x3D8
			case 41:
				SavedPlanningListBox = R6MenuSavePlan(m_PopUpSavePlan.m_ClientArea).m_pListOfSavedPlan;
				// End:0x3C4
				if(__NFUN_119__(SavedPlanningListBox.m_SelectedItem, none))
				{
					szFileName = R6WindowListBoxItem(SavedPlanningListBox.m_SelectedItem).HelpText;
					// End:0x394
					if(__NFUN_122__(szFileName, ""))
					{
						// [Explicit Continue]
						goto J0x56C;
					}
					// End:0x3C4
					if(DeleteAPlanning(szFileName))
					{
						FillListOfSavedPlan(R6MenuSavePlan(m_PopUpSavePlan.m_ClientArea).m_pListOfSavedPlan);
					}
				}
				m_PopUpSavePlan.ShowWindow();
				return;
				// End:0x56C
				break;
			// End:0x488
			case 40:
				SavedPlanningListBox = R6MenuLoadPlan(m_PopUpLoadPlan.m_ClientArea).m_pListOfSavedPlan;
				// End:0x474
				if(__NFUN_119__(SavedPlanningListBox.m_SelectedItem, none))
				{
					szFileName = R6WindowListBoxItem(SavedPlanningListBox.m_SelectedItem).HelpText;
					// End:0x444
					if(__NFUN_122__(szFileName, ""))
					{
						// [Explicit Continue]
						goto J0x56C;
					}
					// End:0x474
					if(DeleteAPlanning(szFileName))
					{
						FillListOfSavedPlan(R6MenuLoadPlan(m_PopUpLoadPlan.m_ClientArea).m_pListOfSavedPlan);
					}
				}
				m_PopUpLoadPlan.ShowWindow();
				return;
				// End:0x56C
				break;
			// End:0x49F
			case 43:
				m_SinglePlayerWidget.TryCreatingCampaign();
				// End:0x56C
				break;
			// End:0x4AF
			case 39:
				LaunchQuickPlay();
				return;
				// End:0x56C
				break;
			// End:0x4C6
			case 42:
				m_SinglePlayerWidget.DeleteCurrentSelectedCampaign();
				// End:0x56C
				break;
			// End:0x50E
			case 46:
				Console.Master.m_StartGameInfo.m_ReloadPlanning = false;
				R6PlanningCtrl(GetPlayerOwner()).DeleteEverySingleNode();
				ChangeCurrentWidget(7);
				// End:0x56C
				break;
			// End:0x52B
			case 44:
				R6PlanningCtrl(GetPlayerOwner()).DeleteAllNode();
				// End:0x56C
				break;
			// End:0x548
			case 45:
				R6PlanningCtrl(GetPlayerOwner()).DeleteEverySingleNode();
				// End:0x56C
				break;
			// End:0x54D
			case 6:
			// End:0x552
			case 49:
			// End:0x557
			case 27:
			// End:0x55F
			case 37:
				// End:0x56C
				break;
			// End:0x569
			case 5:
				return;
				// End:0x56C
				break;
			// End:0xFFFF
			default:
				break;
		}
		J0x56C:
		
	}
	else
	{
		switch(_ePopUpID)
		{
			// End:0x58F
			case 40:
				m_PopUpLoadPlan.ShowWindow();
				return;
				// End:0x5C0
				break;
			// End:0x5A8
			case 41:
				m_PopUpSavePlan.ShowWindow();
				return;
				// End:0x5C0
				break;
			// End:0x5BA
			case 4:
				m_ePopUpID = 47;
				return;
				// End:0x5C0
				break;
			// End:0xFFFF
			default:
				// End:0x5C0
				break;
				break;
		}
	}
	// End:0x623
	if(__NFUN_130__(__NFUN_114__(m_CurrentWidget, m_PlanningWidget), __NFUN_129__(m_bPlayerDoNotWant3DView)))
	{
		m_PlanningWidget.m_3DButton.m_bSelected = true;
		m_PlanningWidget.m_3DWindow.Toggle3DWindow();
		R6PlanningCtrl(GetPlayerOwner()).Toggle3DView();
	}
	// End:0x66F
	if(__NFUN_130__(__NFUN_114__(m_CurrentWidget, m_PlanningWidget), m_bPlayerWantLegend))
	{
		m_PlanningWidget.m_LegendWindow.ToggleLegend();
		m_PlanningWidget.m_LegendButton.m_bSelected = true;
	}
	// End:0x6A2
	if(__NFUN_154__(int(_ePopUpID), int(3)))
	{
		m_GearRoomWidget.SetStartTeamInfo();
		R6Console(Console).LaunchR6Game();
	}
	m_ePopUpID = 0;
	return;
}

function StopPlayMode()
{
	m_PlanningWidget.m_PlanningBar.m_TimeLine.StopPlayMode();
	return;
}

//==============================================================================
// StopWidgetSound: stop the sound for the current widget
//==============================================================================
function StopWidgetSound()
{
	// End:0x1F
	if(__NFUN_154__(int(m_eCurWidgetInUse), int(8)))
	{
		m_IntelWidget.StopIntelWidgetSound();
	}
	return;
}

function SetServerOptions()
{
	// End:0x39
	if(__NFUN_130__(__NFUN_119__(m_pMPCreateGameWidget, none), __NFUN_119__(m_pMPCreateGameWidget.m_pCreateTabOptions, none)))
	{
		m_pMPCreateGameWidget.m_pCreateTabOptions.SetServerOptions();
	}
	return;
}

//===========================================================================================
// FillListOfSavedPlan: Fill a list, R6WindowTextListBox, of saved plan
//===========================================================================================
function FillListOfSavedPlan(R6WindowTextListBox _pListOfSavedPlan)
{
	local R6WindowListBoxItem NewItem;
	local string szFileName;
	local int i, iMax;
	local R6StartGameInfo StartGameInfo;
	local R6MissionDescription mission;
	local string szMapName, szGameTypeDirName, szEnglishGTDirectory;

	_pListOfSavedPlan.Clear();
	StartGameInfo = Console.Master.m_StartGameInfo;
	mission = R6MissionDescription(StartGameInfo.m_CurrentMission);
	GetLevel().GetGameTypeSaveDirectories(szGameTypeDirName, szEnglishGTDirectory);
	szMapName = Localize(mission.m_MapName, "ID_MENUNAME", mission.LocalizationFile, true);
	// End:0xC1
	if(__NFUN_122__(szMapName, ""))
	{
		szMapName = string(GetLevel().Outer.Name);
	}
	iMax = R6PlanningCtrl(GetPlayerOwner()).m_pFileManager.__NFUN_1418__(szMapName, szGameTypeDirName);
	i = 0;
	J0xF3:

	// End:0x193 [Loop If]
	if(__NFUN_150__(i, iMax))
	{
		R6PlanningCtrl(GetPlayerOwner()).m_pFileManager.__NFUN_1526__(i, szFileName);
		// End:0x189
		if(__NFUN_123__(szFileName, ""))
		{
			szFileName = __NFUN_128__(szFileName, __NFUN_126__(szFileName, ".PLN"));
			NewItem = R6WindowListBoxItem(_pListOfSavedPlan.Items.Append(Class'R6Window.R6WindowListBoxItem'));
			NewItem.HelpText = szFileName;
		}
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0xF3;
	}
	return;
}

//===========================================================================================
// IsSaveFileAlreadyExist: A file with the same name already exist?
//===========================================================================================
function bool IsSaveFileAlreadyExist(string _szFileName)
{
	local string szPathAndFilename, szGameTypeDirName;
	local R6StartGameInfo StartGameInfo;
	local string szMapName;
	local R6MissionDescription mission;
	local string szEnglishGTDirectory;

	StartGameInfo = Console.Master.m_StartGameInfo;
	mission = R6MissionDescription(StartGameInfo.m_CurrentMission);
	GetLevel().GetGameTypeSaveDirectories(szGameTypeDirName, szEnglishGTDirectory);
	szMapName = Localize(mission.m_MapName, "ID_MENUNAME", mission.LocalizationFile, true);
	// End:0xB2
	if(__NFUN_122__(szMapName, ""))
	{
		szMapName = string(GetLevel().Outer.Name);
	}
	szPathAndFilename = __NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__("..\\save\\plan\\", szMapName), "\\"), szGameTypeDirName), "\\"), _szFileName), ".PLN");
	// End:0x104
	if(m_pFileManager.__NFUN_1528__(szPathAndFilename))
	{
		return true;
	}
	return false;
	return;
}

//===========================================================================
// LoadAPlanning: load a planning -- the file load process...
//===========================================================================
function bool LoadAPlanning(string _szFileName)
{
	local string szLoadErrorMsg, szLoadErrorMsgMapName, szLoadErrorMsgGameType;
	local R6StartGameInfo StartGameInfo;
	local R6MissionDescription mission;
	local string szMapName, szGameTypeDirName, szEnglishGTDirectory;
	local int iMission;
	local bool bFoundMission;

	R6PlanningCtrl(GetPlayerOwner()).DeleteEverySingleNode();
	StartGameInfo = Console.Master.m_StartGameInfo;
	mission = R6MissionDescription(StartGameInfo.m_CurrentMission);
	szMapName = Localize(mission.m_MapName, "ID_MENUNAME", mission.LocalizationFile, true);
	// End:0xAD
	if(__NFUN_122__(szMapName, ""))
	{
		szMapName = string(GetLevel().Outer.Name);
	}
	GetLevel().GetGameTypeSaveDirectories(szGameTypeDirName, szEnglishGTDirectory);
	// End:0x167
	if(__NFUN_242__(R6PlanningCtrl(GetPlayerOwner()).m_pFileManager.__NFUN_1416__(mission.m_MapName, szMapName, szEnglishGTDirectory, szGameTypeDirName, _szFileName, StartGameInfo, szLoadErrorMsgMapName, szLoadErrorMsgGameType), true))
	{
		R6PlanningCtrl(GetPlayerOwner()).InitNewPlanning(R6PlanningCtrl(GetPlayerOwner()).m_pFileManager.m_iCurrentTeam);
		m_GearRoomWidget.LoadRosterFromStartInfo();
		m_bPlayerPlanInitialized = true;
		return true;		
	}
	else
	{
		bFoundMission = false;
		iMission = 0;
		J0x176:

		// End:0x216 [Loop If]
		if(__NFUN_150__(iMission, R6Console(Root.Console).m_aMissionDescriptions.Length))
		{
			mission = R6Console(Root.Console).m_aMissionDescriptions[iMission];
			// End:0x20C
			if(__NFUN_122__(__NFUN_235__(mission.m_MapName), __NFUN_235__(szLoadErrorMsgMapName)))
			{
				bFoundMission = true;
				iMission = R6Console(Root.Console).m_aMissionDescriptions.Length;
			}
			__NFUN_165__(iMission);
			// [Loop Continue]
			goto J0x176;
		}
		szMapName = Localize(mission.m_MapName, "ID_MENUNAME", mission.LocalizationFile, true);
		// End:0x296
		if(__NFUN_132__(__NFUN_122__(szMapName, ""), __NFUN_242__(bFoundMission, false)))
		{
			szMapName = Localize("POPUP", "LOADERRORMAPUNKNOWN", "R6Menu");
		}
		// End:0x2E6
		if(__NFUN_242__(GetLevel().FindSaveDirectoryNameFromEnglish(szGameTypeDirName, szLoadErrorMsgGameType), false))
		{
			szGameTypeDirName = Localize("POPUP", "LOADERRORMAPUNKNOWN", "R6Menu");
		}
		szLoadErrorMsg = __NFUN_168__(__NFUN_168__(__NFUN_168__(Localize("POPUP", "LOADERRORPROBLEM", "R6Menu"), szMapName), Localize("POPUP", "LOADERRORPROBLEM2", "R6Menu")), szGameTypeDirName);
		SimplePopUp(Localize("POPUP", "LOADERROR", "R6Menu"), __NFUN_168__(_szFileName, szLoadErrorMsg), 6, int(2));
		return false;
	}
	return;
}

//===========================================================================
// DeleteAPlanning: Let's try to delete a USER plan
//===========================================================================
function bool DeleteAPlanning(string szFileName)
{
	local string szPathAndFilename, ErrorMsg;
	local R6StartGameInfo StartGameInfo;
	local string szMapName, szGameTypeDirName, szEnglishGTDirectory;
	local R6MissionDescription mission;
	local int i;

	StartGameInfo = Console.Master.m_StartGameInfo;
	mission = R6MissionDescription(StartGameInfo.m_CurrentMission);
	GetLevel().GetGameTypeSaveDirectories(szGameTypeDirName, szEnglishGTDirectory);
	szMapName = Localize(mission.m_MapName, "ID_MENUNAME", mission.LocalizationFile, true);
	// End:0xB2
	if(__NFUN_122__(szMapName, ""))
	{
		szMapName = string(GetLevel().Outer.Name);
	}
	szPathAndFilename = __NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__("..\\save\\plan\\", szMapName), "\\"), szGameTypeDirName), "\\"), szFileName), ".PLN");
	// End:0x104
	if(m_pFileManager.__NFUN_1527__(szPathAndFilename))
	{
		return true;
	}
	ErrorMsg = __NFUN_168__(__NFUN_168__(__NFUN_168__(__NFUN_168__(Localize("POPUP", "PLANDELETEERRORPROBLEM", "R6Menu"), ":"), szFileName), "\\n"), Localize("POPUP", "PLANDELETEERRORMSG", "R6Menu"));
	SimplePopUp(Localize("POPUP", "PLANDELETEERROR", "R6Menu"), ErrorMsg, 5, int(2));
	return false;
	return;
}

//===========================================================================
// ISPlanning Empty: Check if something is planned
//===========================================================================
function bool IsPlanningEmpty()
{
	local bool Result;
	local R6PlanningInfo PlanningInfo;
	local int i;

	Result = true;
	i = 0;
	J0x0F:

	// End:0x7C [Loop If]
	if(__NFUN_150__(i, 3))
	{
		PlanningInfo = R6PlanningInfo(Console.Master.m_StartGameInfo.m_TeamInfo[i].m_pPlanning);
		// End:0x72
		if(__NFUN_151__(PlanningInfo.m_NodeList.Length, 0))
		{
			Result = false;
		}
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x0F;
	}
	return Result;
	return;
}

//===========================================================================
// LeaveForGame: ready to start the game in single... after loadplanning process
//===========================================================================
function LeaveForGame(bool _ObserverMode, int _iTeamStart)
{
	local R6StartGameInfo StartGameInfo;

	StartGameInfo = Console.Master.m_StartGameInfo;
	StartGameInfo.m_bIsPlaying = __NFUN_129__(_ObserverMode);
	StartGameInfo.m_iTeamStart = _iTeamStart;
	m_GearRoomWidget.SetStartTeamInfoForSaving();
	R6PlanningCtrl(GetPlayerOwner()).m_pFileManager.m_iCurrentTeam = R6PlanningCtrl(GetPlayerOwner()).m_iCurrentTeam;
	// End:0x13F
	if(__NFUN_242__(R6PlanningCtrl(GetPlayerOwner()).m_pFileManager.__NFUN_1417__("Backup", "Backup", "Backup", "", "Backup.pln", StartGameInfo), false))
	{
		SimplePopUp(Localize("POPUP", "FILEERROR", "R6Menu"), __NFUN_168__(__NFUN_168__("Backup.pln", ":"), Localize("POPUP", "FILEERRORPROBLEM", "R6Menu")), 2, int(2));		
	}
	else
	{
		m_GearRoomWidget.SetStartTeamInfo();
		SimpleTextPopUp(Localize("POPUP", "LAUNCHING", "R6Menu"));
		PartialResetOriginalData();
		R6Console(Console).LaunchR6Game(true);
	}
	return;
}

// NEW IN 1.60
function PartialResetOriginalData()
{
	local R6DecalManager aMgr;

	aMgr = GetLevel().m_DecalManager;
	GetLevel().m_DecalManager = none;
	// End:0x3D
	if(__NFUN_119__(aMgr, none))
	{
		aMgr.__NFUN_279__();
	}
	// End:0x74
	if(__NFUN_129__(GetLevel().bKNoInit))
	{
		GetLevel().m_DecalManager = GetLevel().__NFUN_278__(Class'Engine.R6DecalManager');
	}
	return;
}

//===========================================================================================================
// Make sure that is one of these buttons needs to downsize it's font all buttons end up using the same font
//===========================================================================================================
function HarmonizeMenuFonts()
{
	local Font ButtonFont, DownSizeFont;

	DownSizeFont = Root.Fonts[6];
	ButtonFont = Root.Fonts[16];
	m_SinglePlayerWidget.m_LeftButtonFont = ButtonFont;
	m_CustomMissionWidget.m_LeftButtonFont = ButtonFont;
	m_TrainingWidget.m_LeftButtonFont = ButtonFont;
	m_SinglePlayerWidget.m_LeftDownSizeFont = DownSizeFont;
	m_CustomMissionWidget.m_LeftDownSizeFont = DownSizeFont;
	m_TrainingWidget.m_LeftDownSizeFont = DownSizeFont;
	m_SinglePlayerWidget.CreateButtons();
	m_CustomMissionWidget.CreateButtons();
	m_TrainingWidget.CreateButtons();
	// End:0x13A
	if(__NFUN_132__(__NFUN_132__(m_SinglePlayerWidget.ButtonsUsingDownSizeFont(), m_CustomMissionWidget.ButtonsUsingDownSizeFont()), m_TrainingWidget.ButtonsUsingDownSizeFont()))
	{
		m_SinglePlayerWidget.ForceFontDownSizing();
		m_CustomMissionWidget.ForceFontDownSizing();
		m_TrainingWidget.ForceFontDownSizing();
	}
	return;
}

//=================================================================================
// MenuLoadProfile: Advice optionswidget that a load profile was occur
//=================================================================================
function MenuLoadProfile(bool _bServerProfile)
{
	// End:0x1B
	if(_bServerProfile)
	{
		m_pMPCreateGameWidget.MenuServerLoadProfile();		
	}
	else
	{
		m_OptionsWidget.MenuOptionsLoadProfile();
	}
	return;
}

//=================================================================================
// NotifyWindow: receive specific notify from pop-up window, etc
//=================================================================================
function NotifyWindow(UWindowWindow C, byte E)
{
	// End:0x9D
	if(__NFUN_154__(int(E), 11))
	{
		// End:0x57
		if(__NFUN_114__(C, R6MenuLoadPlan(m_PopUpLoadPlan.m_ClientArea).m_pListOfSavedPlan))
		{
			m_PopUpLoadPlan.Result = 3;
			m_PopUpLoadPlan.Close();			
		}
		else
		{
			// End:0x9D
			if(__NFUN_114__(C, R6MenuSavePlan(m_PopUpSavePlan.m_ClientArea).m_pListOfSavedPlan))
			{
				m_PopUpSavePlan.Result = 3;
				m_PopUpSavePlan.Close();
			}
		}
	}
	return;
}

function SetNewMODS(string _szNewBkgFolder, optional bool _bForceRefresh)
{
	// End:0x09
	if(_bForceRefresh)
	{
	}
	super(UWindowRootWindow).SetNewMODS(_szNewBkgFolder, _bForceRefresh);
	return;
}

//================================================
// InitBeaconService: 
//================================================
function InitBeaconService()
{
	// End:0x6A
	if(__NFUN_114__(R6Console(Console).m_LanServers, none))
	{
		R6Console(Console).m_LanServers = new (none) Class<R6LanServers>(Root.MenuClassDefines.ClassLanServer);
		R6Console(Console).m_LanServers.Created();
	}
	// End:0xCC
	if(__NFUN_114__(R6Console(Console).m_LanServers.m_ClientBeacon, none))
	{
		R6Console(Console).m_LanServers.m_ClientBeacon = Console.ViewportOwner.Actor.__NFUN_278__(Class'IpDrv.ClientBeaconReceiver');
	}
	R6Console(Console).m_GameService.m_ClientBeacon = R6Console(Console).m_LanServers.m_ClientBeacon;
	return;
}

defaultproperties
{
	m_BGTexture0=Texture'R6MenuBG.Backgrounds.GenericLoad0'
	m_BGTexture1=Texture'R6MenuBG.Backgrounds.GenericLoad1'
	m_MainMenuMusic=Sound'Music.Play_theme_Menu1'
	LookAndFeelClass="R6Menu.R6MenuRSLookAndFeel"
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var n
// REMOVED IN 1.60: function SaveTrainingPlanning
