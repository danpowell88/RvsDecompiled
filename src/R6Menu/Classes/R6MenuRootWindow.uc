//=============================================================================
// R6MenuRootWindow - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6MenuRootWindow.uc : (Root of all windows)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/05/25 * Created by Chaouky Garram
//	  2001/11/12 * Modified by Alexandre Dionne Support multi-Menus	
//=============================================================================
class R6MenuRootWindow extends R6WindowRootWindow
    config;

// Top-level menu controller for RavenShield's entire UI. Owns every full-screen "widget"
// (major menu page) and manages which one is active via m_CurrentWidget. All navigation
// flows through ChangeCurrentWidget(). Pop-up dialogs (save/load plan, confirmations) are
// managed separately via m_ePopUpID + PopUpMenu(). Every widget is created hidden in
// Created() and shown on demand — only one is visible at a time.

var UWindowBase.EPopUpID m_ePopUpID;  // ID of currently active pop up menu
var bool m_bReloadPlan;  // Load default plan, this is to be able to retouch last plan
var bool m_bLoadingPlanning;  // true while waiting for the planning map to finish async loading
var bool m_bPlayerPlanInitialized;  // this help us find out if we have to prompt the player with the loading default planing pop up
var bool m_bPlayerDoNotWant3DView;  // mirrors pGameOptions.Hide3DView; true = skip 3D overlay in planning
var bool m_bPlayerWantLegend;  // true when the planning map legend panel is open
var bool bShowLog;  // debug flag: set in INI to enable verbose logging of window events
var bool m_bJoinServerProcess;  // true, we currently join a server
// Don't remove: they are here only to make sure they are referenced (needed by cpp code)
var Texture m_BGTexture0;
var Texture m_BGTexture1;
var R6MenuWidget m_CurrentWidget;   // the full-screen widget page currently displayed
var R6MenuWidget m_PreviousWidget;  // widget shown before CurrentWidget; restored by PreviousWidgetID (back-button)
// Mission planning pipeline screens: Intel -> GearRoom -> Planning -> Execute
var R6MenuIntelWidget m_IntelWidget;       // mission briefing / intel screen
var R6MenuPlanningWidget m_PlanningWidget; // tactical waypoint and action-point map
var R6MenuExecuteWidget m_ExecuteWidget;   // final go/no-go execution screen
var R6MenuMainWidget m_MainMenuWidget;              // top-level hub screen
var R6MenuSinglePlayerWidget m_SinglePlayerWidget;  // campaign mission selection
var R6MenuCustomMissionWidget m_CustomMissionWidget;// custom / skirmish mission setup
var R6MenuTrainingWidget m_TrainingWidget;          // training missions
var R6MenuMultiPlayerWidget m_MultiPlayerWidget;    // LAN / direct-connect server browser
var R6MenuOptionsWidget m_OptionsWidget;            // audio, video, controls settings
var R6MenuCreditsWidget m_CreditsWidget;            // credits roll
var R6MenuGearWidget m_GearRoomWidget;              // operative gear and loadout selection
// NEW IN 1.60
var R6MenuCDKeyManager m_pMenuCDKeyManager;          // CD key entry / validation screen
var R6MenuMPCreateGameWidget m_pMPCreateGameWidget;  // host a new multiplayer game
var R6MenuUbiComWidget m_pUbiComWidget;              // Ubi.com (GameSpy) online lobby
// NEW IN 1.60
var R6MenuUbiComModsWidget m_pUbiComModsWidget;  // Ubi.com mod and content browser
var R6MenuNonUbiWidget m_pNonUbiWidget;          // peer-to-peer matchmaking without Ubi.com
var R6MenuQuit m_pMenuQuit;                      // quit confirmation (shown in demo builds instead of direct quit)
var R6FileManager m_pFileManager;                // file I/O helper for save/load of .PLN planning files
/////////////////////////////////////////////////////////////////////////////////////////
//                                  POP UP
/////////////////////////////////////////////////////////////////////////////////////////
var R6WindowPopUpBox m_PopUpSavePlan;  // modal dialog for saving a tactical plan (EPopUpID 47 = EPopUpID_SavePlanning)
// NEW IN 1.60
var R6WindowPopUpBox m_PopUpLoadPlan;  // modal dialog for loading a saved plan  (EPopUpID 48 = EPopUpID_LoadPlanning)
var Sound m_MainMenuMusic;  // Music for the MainMenu
/////////////////////////////////////////////////////////////////////////////////
// Operative objects for the current mission; populated by GotoCampaignPlanning() and
// ResetCustomMissionOperatives(). Includes both campaign operatives and any from loaded mods.
var array<R6Operative> m_GameOperatives;

// Created: called once when the root window is first constructed.
// Initialises all subsystems, creates every widget page (all hidden), picks the
// first visible screen based on launch context, sets up save/load pop-up dialogs,
// and starts the main menu music (unless launched by the Ubi.com client).
function Created()
{
	local R6WindowEditBox EditPopUpBox;
	local R6WindowTextListBox SavedPlanningListBox;
	local R6GameOptions pGameOptions;

	// End:0x27
	if(bShowLog)
	{
		Log("R6MenuRootWindow Created()");
	}
	// Call UWindowRootWindow.Created() directly, skipping R6WindowRootWindow — no extra
	// R6-specific init is needed here that R6WindowRootWindow would add.
	super(UWindowRootWindow).Created();
	R6Console(Console).InitializedGameService();  // start GameSpy / online game service connection
	m_pFileManager = new Class'Engine.R6FileManager';  // planning file I/O helper (save/load .PLN files)
	// End:0x75
	if((m_pFileManager == none))
	{
		Log("m_pFileManager == NONE");
	}
	pGameOptions = Class'Engine.Actor'.static.GetGameOptions();
	m_bPlayerDoNotWant3DView = pGameOptions.Hide3DView;  // restore user preference for the 3D overlay
	m_eRootId = 1;  // 1 = RootID_R6Menu; identifies this root to the engine's C++ layer
	SetResolution(640.0000000, 480.0000000);  // the entire menu UI is authored at 640x480
	// Create every widget page up-front and immediately close (hide) each one.
	// ChangeCurrentWidget() will show the appropriate page on demand.
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
	// Ensure all SP-category widgets use consistent button fonts before any are shown.
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
	// Decide which screen to show first based on how the game was launched.
	AssignShowFirstWidget();
	m_CurrentWidget.SetMousePos((WinWidth * 0.5000000), (WinHeight * 0.5000000));  // start cursor at screen centre
	m_ePopUpID = 0;
	// Build the save/load pop-up dialogs. They are full 640x480 overlays; the visible
	// frame and client area are positioned inside them with absolute coordinates.
	m_PopUpSavePlan = R6WindowPopUpBox(CreateWindow(Class'R6Window.R6WindowPopUpBox', 0.0000000, 0.0000000, 640.0000000, 480.0000000));
	m_PopUpSavePlan.CreateStdPopUpWindow(Localize("POPUP", "PopUpTitle_SavePlan", "R6Menu"), 30.0000000, 188.0000000, 150.0000000, 264.0000000, 180.0000000);
	m_PopUpSavePlan.CreateClientWindow(Class'R6Menu.R6MenuSavePlan', false, true);
	m_PopUpSavePlan.m_ePopUpID = 47;  // 47 = EPopUpID_SavePlanning
	m_PopUpSavePlan.HideWindow();
	m_PopUpLoadPlan = R6WindowPopUpBox(CreateWindow(Class'R6Window.R6WindowPopUpBox', 0.0000000, 0.0000000, 640.0000000, 480.0000000));
	m_PopUpLoadPlan.CreateStdPopUpWindow(Localize("POPUP", "PopUpTitle_Load", "R6Menu"), 30.0000000, 188.0000000, 150.0000000, 264.0000000, 180.0000000);
	m_PopUpLoadPlan.CreateClientWindow(Class'R6Menu.R6MenuLoadPlan', false, true);
	m_PopUpLoadPlan.m_ePopUpID = 48;  // 48 = EPopUpID_LoadPlanning
	m_PopUpLoadPlan.HideWindow();
	GUIScale = 1.0000000;  // no scaling; menus run at native 640x480
	// End:0x6F4
	// Only play the main menu music when NOT launched by the Ubi.com client —
	// the GS client manages its own audio state.
	if((!R6Console(Console).m_bStartedByGSClient))
	{
		GetPlayerOwner().PlayMusic(m_MainMenuMusic, true);
	}
	return;
}

// AssignShowFirstWidget: decides which screen to display on startup based on launch context.
// Ubi.com client spawned us  -> show the Ubi.com lobby.
// Joining a P2P session     -> show non-Ubi matchmaking.
// Hosting a P2P session     -> show the create-game screen.
// Normal launch             -> show the main menu.
function AssignShowFirstWidget()
{
	// End:0x25
	// m_bStartedByGSClient: the Ubi.com (GameSpy) client launched us as a child process
	if(R6Console(Console).m_bStartedByGSClient)
	{
		m_CurrentWidget = m_pUbiComWidget;		
	}
	else
	{
		// End:0x4A
		// m_bNonUbiMatchMaking: joining a LAN/direct-connect game (client side)
		if(R6Console(Console).m_bNonUbiMatchMaking)
		{
			m_CurrentWidget = m_pNonUbiWidget;			
		}
		else
		{
			// End:0x7E
			// m_bNonUbiMatchMakingHost: we are hosting a LAN/direct-connect game
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

// Set3dView: persists the player's 3D-overlay preference across sessions.
// bSelected=true means the player wants the 3D view hidden (the flag name is inverted).
function Set3dView(bool bSelected)
{
	local R6GameOptions pGameOptions;

	pGameOptions = Class'Engine.Actor'.static.GetGameOptions();
	pGameOptions.Hide3DView = bSelected;
	m_bPlayerDoNotWant3DView = bSelected;
	return;
}

// DrawMouse: renders the software mouse cursor each frame.
// In windowed mode with a Windows cursor available, delegates to the OS cursor.
// Otherwise draws a texture cursor manually; it is clipped against the widget's right/bottom
// boundary (m_fRightMouseX/YClipping) to prevent the cursor rendering over the laptop bezel.
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
		C.Style = 5;  // STY_Alpha: alpha-blended cursor texture
		// End:0xD1
		if((m_bUseAimIcon == true))
		{
			C.SetPos(((MouseX * GUIScale) - float(AimCursor.HotX)), ((MouseY * GUIScale) - float(AimCursor.HotY)));
			MouseTex = AimCursor.Tex;			
		}
		else
		{
			// End:0x130
			if((m_bUseDragIcon == true))
			{
				C.SetPos(((MouseX * GUIScale) - float(DragCursor.HotX)), ((MouseY * GUIScale) - float(DragCursor.HotY)));
				MouseTex = DragCursor.Tex;				
			}
			else
			{
				C.SetPos(((MouseX * GUIScale) - float(MouseWindow.Cursor.HotX)), ((MouseY * GUIScale) - float(MouseWindow.Cursor.HotY)));
				MouseTex = MouseWindow.Cursor.Tex;
			}
		}
		fMouseClipX = (m_CurrentWidget.m_fRightMouseXClipping * GUIScale);
		fMouseClipY = (m_CurrentWidget.m_fRightMouseYClipping * GUIScale);
		C.SetClip(fMouseClipX, fMouseClipY);
		// End:0x24D
		if((MouseTex != none))
		{
			C.DrawTileClipped(MouseTex, float(MouseTex.USize), float(MouseTex.VSize), 0.0000000, 0.0000000, float(MouseTex.USize), float(MouseTex.VSize));
		}
		C.Style = 1;  // STY_Normal: restore default blend mode after drawing cursor
	}
	return;
}

// ResetMenus: called when returning to the main menu after a mission or connection attempt.
// If a connection failed, tells the multiplayer widget to display an error.
// Otherwise resets the intel/planning widgets and clears the plan-initialisation flag.
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

// UpdateMenus: refreshes team data in the planning widget.
// The none-check guards against a race where a multiplayer error message can recreate the
// menu root before the planning widget has been fully initialised in Created().
function UpdateMenus(int iWhatToUpdate)
{
	// End:0x1F
	if((m_PlanningWidget != none))
	{
		m_PlanningWidget.ResetTeams(iWhatToUpdate);
	}
	return;
}

// MoveMouse: propagates mouse position to the active widget for hover effects, then
// forwards to UWindowRootWindow (which routes to the currently focused child window).
function MoveMouse(float X, float Y)
{
	// End:0x24
	if((m_CurrentWidget != none))
	{
		m_CurrentWidget.SetMousePos(X, Y);
	}
	super(UWindowRootWindow).MoveMouse(Console.MouseX, Console.MouseY);
	return;
}

// ClosePopups: hides floating sub-panels (3D view, legend) on the planning widget.
// Called before a modal dialog opens so the dialog renders cleanly over the map.
function ClosePopups()
{
	// End:0x1E
	if((m_CurrentWidget == m_PlanningWidget))
	{
		m_PlanningWidget.Hide3DAndLegend();
	}
	return;
}

// IsInsidePlanning: returns true if the previous widget was any screen in the
// mission-preparation pipeline. Used by the C++ layer to gate planning-mode input.
// Widget IDs: 8=Intel, 12=GearRoom, 9=Planning, 13=Execute,
//             10=RetryCampaignPlanning, 11=RetryCustomMissionPlanning
function bool IsInsidePlanning()
{
	return ((((((int(m_ePrevWidgetInUse) == int(8)) || (int(m_ePrevWidgetInUse) == int(12))) || (int(m_ePrevWidgetInUse) == int(9))) || (int(m_ePrevWidgetInUse) == int(13))) || (int(m_ePrevWidgetInUse) == int(10))) || (int(m_ePrevWidgetInUse) == int(11)));
	return;
}

// ChangeCurrentWidget: the central navigation router for the entire menu system.
// Hides the current widget, shows the requested one, and updates the prev/cur tracking
// variables used by C++ for input routing (IsInsidePlanning, PlanningShouldProcessKey).
// widgetID 17 (PreviousWidgetID) is special: it swaps current/prev (back-button behaviour).
function ChangeCurrentWidget(UWindowRootWindow.eGameWidgetID widgetID)
{
	local bool bDontQuitNow;

	m_bJoinServerProcess = false;  // leaving any active flow; clear join-in-progress flag
	// End:0x2E
	// 17 = PreviousWidgetID: swap tracking variables so history stays consistent on back
	if((int(widgetID) == int(17)))
	{
		m_eCurWidgetInUse = m_ePrevWidgetInUse;
		m_ePrevWidgetInUse = 0;		
	}
	else
	{
		m_ePrevWidgetInUse = m_eCurWidgetInUse;
		m_eCurWidgetInUse = widgetID;
		// End:0x7A
		// 9 = PlanningWidgetID: cancel any in-progress waypoint placement when leaving planning
		if((int(m_ePrevWidgetInUse) == int(9)))
		{
			// End:0x7A
			if((R6PlanningCtrl(GetPlayerOwner()) != none))
			{
				R6PlanningCtrl(GetPlayerOwner()).CancelActionPointAction();
			}
		}
	}
	switch(widgetID)
	{
		// End:0xBD
		case 5:  // SinglePlayerWidgetID: campaign mission selection
			m_CurrentWidget.HideWindow();
			m_PreviousWidget = m_CurrentWidget;
			m_CurrentWidget = m_SinglePlayerWidget;
			m_CurrentWidget.ShowWindow();
			// End:0x5D3
			break;
		// End:0xF9
		case 4:  // TrainingWidgetID: training missions
			m_CurrentWidget.HideWindow();
			m_PreviousWidget = m_CurrentWidget;
			m_CurrentWidget = m_TrainingWidget;
			m_CurrentWidget.ShowWindow();
			// End:0x5D3
			break;
		// End:0x15E
		case 7:  // MainMenuWidgetID: return to the top-level hub
			// End:0x121
			if((m_CurrentWidget == m_MultiPlayerWidget))
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
		case 8:  // IntelWidgetID: mission briefing screen (called from nav planning)
			m_CurrentWidget.HideWindow();
			m_PreviousWidget = m_CurrentWidget;
			m_CurrentWidget = m_IntelWidget;
			m_CurrentWidget.ShowWindow();
			// End:0x5D3
			break;
		// End:0x1C6
		case 11:  // RetryCustomMissionPlanningID: re-enter planning after a failed custom mission
			ResetCustomMissionOperatives();
			m_bReloadPlan = true;
			m_bLoadingPlanning = true;
			m_bPlayerPlanInitialized = true;
			GotoPlanning();
			// End:0x5D3
			break;
		// End:0x211
		case 9:  // PlanningWidgetID: tactical waypoint map (guard prevents redundant re-show)
			// End:0x20E
			if((m_CurrentWidget != m_PlanningWidget))
			{
				m_CurrentWidget.HideWindow();
				m_PreviousWidget = m_CurrentWidget;
				m_CurrentWidget = m_PlanningWidget;
				m_CurrentWidget.ShowWindow();
			}
			// End:0x5D3
			break;
		// End:0x24D
		case 13:  // ExecuteWidgetID: final briefing before launching the mission
			m_CurrentWidget.HideWindow();
			m_PreviousWidget = m_CurrentWidget;
			m_CurrentWidget = m_ExecuteWidget;
			m_CurrentWidget.ShowWindow();
			// End:0x5D3
			break;
		// End:0x289
		case 12:  // GearRoomWidgetID: operative gear / loadout selection
			m_CurrentWidget.HideWindow();
			m_PreviousWidget = m_CurrentWidget;
			m_CurrentWidget = m_GearRoomWidget;
			m_CurrentWidget.ShowWindow();
			// End:0x5D3
			break;
		// End:0x2C5
		case 14:  // CustomMissionWidgetID: custom / skirmish mission configuration
			m_CurrentWidget.HideWindow();
			m_PreviousWidget = m_CurrentWidget;
			m_CurrentWidget = m_CustomMissionWidget;
			m_CurrentWidget.ShowWindow();
			// End:0x5D3
			break;
		// End:0x301
		case 15:  // MultiPlayerWidgetID: LAN / direct-connect server browser
			m_CurrentWidget.HideWindow();
			m_PreviousWidget = m_CurrentWidget;
			m_CurrentWidget = m_MultiPlayerWidget;
			m_CurrentWidget.ShowWindow();
			// End:0x5D3
			break;
		// End:0x33D
		case 20:  // UbiComWidgetID: Ubi.com (GameSpy) online lobby
			m_CurrentWidget.HideWindow();
			m_PreviousWidget = m_CurrentWidget;
			m_CurrentWidget = m_pUbiComWidget;
			m_CurrentWidget.ShowWindow();
			// End:0x5D3
			break;
		// End:0x379
		case 21:  // UbiComModsWidgetID: Ubi.com mod browser (new in 1.60)
			m_CurrentWidget.HideWindow();
			m_PreviousWidget = m_CurrentWidget;
			m_CurrentWidget = m_pUbiComModsWidget;
			m_CurrentWidget.ShowWindow();
			// End:0x5D3
			break;
		// End:0x414
		case 36:  // MultiPlayerError: route to the appropriate error screen based on connection type
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
		case 37:  // MultiPlayerErrorUbiCom: force Ubi.com error regardless of connection type
			ChangeCurrentWidget(20);
			m_pUbiComWidget.PromptConnectionError();
			// End:0x5D3
			break;
		// End:0x47E
		case 16:  // OptionsWidgetID: audio/video/controls settings (refreshed on every entry)
			m_CurrentWidget.HideWindow();
			m_PreviousWidget = m_CurrentWidget;
			m_CurrentWidget = m_OptionsWidget;
			m_OptionsWidget.RefreshOptions();
			m_CurrentWidget.ShowWindow();
			// End:0x5D3
			break;
		// End:0x4BA
		case 18:  // CreditsWidgetID
			m_CurrentWidget.HideWindow();
			m_PreviousWidget = m_CurrentWidget;
			m_CurrentWidget = m_CreditsWidget;
			m_CurrentWidget.ShowWindow();
			// End:0x5D3
			break;
		// End:0x505
		case 19:  // MPCreateGameWidgetID: host a new multiplayer game
			m_CurrentWidget.HideWindow();
			m_PreviousWidget = m_CurrentWidget;
			m_CurrentWidget = m_pMPCreateGameWidget;
			m_pMPCreateGameWidget.RefreshCreateGameMenu();
			m_CurrentWidget.ShowWindow();
			// End:0x5D3
			break;
		// End:0x524
		case 10:  // RetryCampaignPlanningID: re-enter planning after a failed campaign mission
			m_bReloadPlan = true;
			m_bPlayerPlanInitialized = true;
			GotoCampaignPlanning(true);  // true = map already loaded, skip preload
			// End:0x5D3
			break;
		// End:0x533
		case 6:  // CampaignPlanningID: first-time entry into campaign planning (must preload map)
			GotoCampaignPlanning(false);  // false = trigger async map preload first
			// End:0x5D3
			break;
		// End:0x58A
		// MenuQuitID: in the retail build bDontQuitNow is never set so this goes straight to DoQuitGame.
		// Demo builds would set it true to show a quit-confirmation screen instead.
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
		case 17:  // PreviousWidgetID: go back one level (back button in options etc.)
			// End:0x5CA
			if((m_PreviousWidget != none))
			{
				m_CurrentWidget.HideWindow();
				m_CurrentWidget = m_PreviousWidget;
				m_PreviousWidget = none;  // clear so a second back doesn't loop
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

// PlanningShouldProcessKey: returns true only when the planning widget is active AND
// no pop-up is open (m_ePopUpID == 0 = None). Called by C++ to gate planning hotkeys.
function bool PlanningShouldProcessKey()
{
	// End:0x24
	// 0 = EPopUpID_None; 9 = PlanningWidgetID
	if(((int(m_ePopUpID) == int(0)) && (int(m_eCurWidgetInUse) == int(9))))
	{
		return true;
	}
	return false;
	return;
}

// PlanningShouldDrawPath: returns true when the planning map is the active screen.
// Used by C++ to decide whether to render waypoint path overlays.
function bool PlanningShouldDrawPath()
{
	// End:0x12
	// 9 = PlanningWidgetID
	if((int(m_eCurWidgetInUse) == int(9)))
	{
		return true;
	}
	return false;
	return;
}

// ResetCustomMissionOperatives: rebuilds m_GameOperatives for a custom mission.
// First populates the list from the current campaign's operative class names, then
// appends any R6Operative subclasses found in loaded mod packages. This lets mods
// inject custom operatives without modifying the base campaign data.
function ResetCustomMissionOperatives()
{
	local R6Operative tmpOperative;
	local Class<R6Operative> tmpOperativeClass;
	local int iNbArrayElements, iNbTotalOperatives, i;
	local R6ModMgr pModManager;

	pModManager = Class'Engine.Actor'.static.GetModMgr();
	m_GameOperatives.Remove(0, m_GameOperatives.Length);
	iNbArrayElements = R6Console(Console).m_CurrentCampaign.m_OperativeClassName.Length;
	i = 0;
	J0x49:

	// End:0xAF [Loop If]
	if((i < iNbArrayElements))
	{
		tmpOperative = new (none) Class<R6Operative>(DynamicLoadObject(R6Console(Console).m_CurrentCampaign.m_OperativeClassName[i], Class'Core.Class'));
		m_GameOperatives[i] = tmpOperative;
		(i++);
		// [Loop Continue]
		goto J0x49;
	}
	// If the active mod uses custom operatives, scan all mod packages for R6Operative subclasses
	// and append any found to the list after the campaign defaults.
	iNbTotalOperatives = i;
	// End:0x19E
	if((pModManager.m_pCurrentMod.m_bUseCustomOperatives == true))
	{
		i = 0;
		J0xDF:

		// End:0x19E [Loop If]
		if((i < pModManager.GetPackageMgr().GetNbPackage()))
		{
			tmpOperativeClass = Class<R6Operative>(pModManager.GetPackageMgr().GetFirstClassFromPackage(i, Class'R6Game.R6Operative'));
			J0x130:

			// End:0x194 [Loop If]
			if((tmpOperativeClass != none))
			{
				tmpOperative = new (none) tmpOperativeClass;
				// End:0x16D
				if((tmpOperative != none))
				{
					m_GameOperatives[iNbTotalOperatives] = tmpOperative;
					(iNbTotalOperatives++);
				}
				tmpOperativeClass = Class<R6Operative>(pModManager.GetPackageMgr().GetNextClassFromPackage());
				// [Loop Continue]
				goto J0x130;
			}
			(i++);
			// [Loop Continue]
			goto J0xDF;
		}
	}
	return;
}

// KeyType: forwards typed-character input to the active widget.
// Used by text-input fields such as the save-plan name edit box.
function KeyType(int iInputKey, float X, float Y)
{
	m_CurrentWidget.KeyType(iInputKey, X, Y);
	return;
}

// WindowEvent: main input dispatcher for the menu system.
// In bShowLog debug mode it logs events and returns early. Normally:
//   1. WM_Paint (Msg==11) events always pass through; others check connection state.
//   2. Escape during a server-join aborts the connection.
//   3. Global hotkeys (HotKeyDown/Up) are processed before modal routing.
//   4. If a modal dialog is open (WaitModal), events go to it with screen-relative coords;
//      otherwise the base UWindowRootWindow dispatcher handles routing normally.
function WindowEvent(UWindowWindow.WinMessage Msg, Canvas C, float X, float Y, int Key)
{
	// End:0xD1
	if(bShowLog)
	{
		switch(Msg)
		{
			// End:0x50
			case 9:
				Log(("R6MenuRoot::WindowEvent Msg= WM_KeyDown Key" @ string(Key)));
				// End:0xD1
				break;
			// End:0x8E
			case 8:
				Log(("R6MenuRoot::WindowEvent Msg= WM_KeyUp Key" @ string(Key)));
				// End:0xD1
				break;
			// End:0xCE
			case 10:
				Log(("R6MenuRoot::WindowEvent Msg= WM_KeyType Key" @ string(Key)));
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
		// WM_Paint = 11: paint events always pass through; never block rendering
		if((int(Msg) != int(11)))
		{
			// End:0x10E
			if((Console.m_bInterruptConnectionProcess || R6Console(Console).m_bRenderMenuOneTime))
			{
				return;
			}
			// End:0x15A
			// Let the player press Escape to abort a server-join in progress
			if(m_bJoinServerProcess)
			{
				// End:0x15A
				// 9 = WM_KeyDown; 27 = IK_Escape key code
				if((int(Msg) == int(9)))
				{
					// End:0x15A
					if((Key == int(Root.Console.27)))
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
		// WM_Paint or no modal active: dispatch through the normal UWindow tree.
		// Modal open: send events directly to the modal window with screen-relative coords.
		if(((int(Msg) == int(11)) || (!WaitModal())))
		{
			super(UWindowRootWindow).WindowEvent(Msg, C, X, Y, Key);			
		}
		else
		{
			// End:0x238
			if(WaitModal())
			{
				ModalWindow.WindowEvent(Msg, C, (X - ModalWindow.WinLeft), (Y - ModalWindow.WinTop), Key);
			}
		}
		return;
	}
}

// GotoCampaignPlanning: prepares everything needed to enter the planning phase for a campaign mission.
// Loads the campaign data, picks the correct mission by index, copies the operative list, and sets
// up all game-start parameters (map name, difficulty, game mode).
// _bRetrying=true  -> map is already loaded (re-planning after failure), call GotoPlanning() directly.
// _bRetrying=false -> trigger PreloadMapForPlanning(); GotoPlanning() fires via NotifyAfterLevelChange().
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
		Log(("start GotoPlanning PlayerCampaign.m_FileName=" $ PlayerCampaign.m_FileName));
	}
	CurrentConsole.m_CurrentCampaign = new (none) Class'R6Game.R6Campaign';
	CurrentConsole.m_CurrentCampaign.InitCampaign(GetLevel(), PlayerCampaign.m_CampaignFileName, CurrentConsole);
	CurrentMission = CurrentConsole.m_CurrentCampaign.m_missions[PlayerCampaign.m_iNoMission];
	CurrentConsole.Master.m_StartGameInfo.m_CurrentMission = CurrentMission;
	// End:0x140
	if(bShowLog)
	{
		Log(("m_CurrentCampaign" @ string(CurrentConsole.m_CurrentCampaign)));
	}
	// End:0x164
	if(bShowLog)
	{
		Log(("currentMission" @ string(CurrentMission)));
	}
	CurrentConsole.Master.m_StartGameInfo.m_MapName = CurrentMission.m_MapName;
	// End:0x1C8
	if(bShowLog)
	{
		Log(("currentMission.m_MapName" @ CurrentMission.m_MapName));
	}
	CurrentConsole.Master.m_StartGameInfo.m_DifficultyLevel = PlayerCampaign.m_iDifficultyLevel;
	// End:0x237
	if(bShowLog)
	{
		Log(("PlayerCampaign.m_iDifficultyLevel" @ string(PlayerCampaign.m_iDifficultyLevel)));
	}
	CurrentConsole.Master.m_StartGameInfo.m_GameMode = "R6Game.R6StoryModeGame";  // single-player story game type
	iNbArrayElements = PlayerCampaign.m_OperativesMissionDetails.m_MissionOperatives.Length;
	// End:0x2D1
	if(bShowLog)
	{
		Log(("m_MissionOperatives.Length" @ string(PlayerCampaign.m_OperativesMissionDetails.m_MissionOperatives.Length)));
	}
	m_GameOperatives.Remove(0, m_GameOperatives.Length);
	i = 0;
	J0x2E5:

	// End:0x327 [Loop If]
	if((i < iNbArrayElements))
	{
		m_GameOperatives[i] = PlayerCampaign.m_OperativesMissionDetails.m_MissionOperatives[i];
		(i++);
		// [Loop Continue]
		goto J0x2E5;
	}
	// End:0x344
	if(bShowLog)
	{
		Log("end GotoPlanning");
	}
	m_bLoadingPlanning = true;
	// _bRetrying: map already in memory, go straight to planning UI.
	// Otherwise preload the map async; NotifyAfterLevelChange() calls GotoPlanning() when ready.
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

// GotoPlanning: performs the actual transition into the planning phase.
// Only runs when m_bLoadingPlanning is true (set by GotoCampaignPlanning or ChangeCurrentWidget).
// m_bReloadPlan=true: full reset — destroy old player controller, spawn a fresh R6PlanningCtrl,
//   then reload the backup plan so the player can rework their last saved strategy.
// m_bReloadPlan=false: map was already preloaded, just reset the gear room and show Intel.
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
			// Full planning reset: destroy the old controller and spawn a fresh R6PlanningCtrl.
			// This avoids reloading the entire map just to change the plan.
			R6GameInfo(GetLevel().Game).RestartGameMgr();
			CurrentPlayer = GetPlayerOwner().Player;
			GetPlayerOwner().Destroy();
			NewController = GetLevel().Spawn(Class'R6Game.R6PlanningCtrl');
			R6GameInfo(GetLevel().Game).SetController(NewController, CurrentPlayer);
			R6GameInfo(GetLevel().Game).bRestartLevel = false;
			R6GameInfo(GetLevel().Game).RestartPlayer(NewController);
			R6PlanningCtrl(NewController).SetPlanningInfo();
			NewController.SpawnDefaultHUD();
			NewController.ChangeInputSet(1);
			R6PlanningCtrl(GetPlayerOwner()).DeleteEverySingleNode();
			// Backup.pln is written by LeaveForGame() before launching a mission, allowing
			// the player to resume or retry their exact plan if the mission fails.
			R6PlanningCtrl(GetPlayerOwner()).m_pFileManager.LoadPlanning("Backup", "Backup", "Backup", "", "Backup.pln", Console.Master.m_StartGameInfo);
			R6PlanningCtrl(GetPlayerOwner()).InitNewPlanning(R6PlanningCtrl(GetPlayerOwner()).m_pFileManager.m_iCurrentTeam);
			m_GearRoomWidget.LoadRosterFromStartInfo();
			m_bReloadPlan = false;			
		}
		else
		{
			m_GearRoomWidget.Reset();
		}
		m_bLoadingPlanning = false;
		ChangeCurrentWidget(8);  // 8 = IntelWidgetID: show mission briefing as the first planning step
	}
	return;
}

// LaunchQuickPlay: loads the mission's default action plan and immediately starts the game
// if the team configuration is valid. The plan filename is built from the mission's short
// name plus the game's default action-plan suffix (e.g. "HOUSE_MISSION_DEFAULT").
function LaunchQuickPlay()
{
	local string szFileName;

	// Build the default plan filename: <MissionShortName><DefaultActionPlanSuffix>
	szFileName = R6MissionDescription(R6Console(Console).Master.m_StartGameInfo.m_CurrentMission).m_ShortName;
	szFileName = (szFileName $ R6AbstractGameInfo(GetLevel().Game).m_szDefaultActionPlan);
	// End:0x11C
	if(LoadAPlanning(Caps(szFileName)))
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
			// 49 = EPopUpID_PlanningIncomplete; 2 = MB_OK button
		SimplePopUp(Localize("POPUP", "INCOMPLETEPLANNING", "R6Menu"), Localize("POPUP", "INCOMPLETEPLANNINGPROBLEM", "R6Menu"), 49, int(2));
		}
	}
	return;
}

// NotifyAfterLevelChange: engine callback fired after a level (map) finishes loading.
// Picks up the planning flow where GotoCampaignPlanning() left off after PreloadMapForPlanning().
function NotifyAfterLevelChange()
{
	GotoPlanning();
	return;
}

//==============================================================================
// PopUpMenu: shows the modal dialog corresponding to the current m_ePopUpID.
// Called after m_ePopUpID is set to trigger a pop-up. _bautoLoadPrompt changes
// the load dialog to include a "don't show again" checkbox and makes it taller.
//==============================================================================
function PopUpMenu(optional bool _bautoLoadPrompt)
{
	local int i, iMax;
	local R6WindowListBoxItem NewItem;
	local string szFileName;

	switch(m_ePopUpID)
	{
		// End:0x70
		case 47:  // EPopUpID_SavePlanning: fill the list and show save dialog; focus the edit box
			FillListOfSavedPlan(R6MenuSavePlan(m_PopUpSavePlan.m_ClientArea).m_pListOfSavedPlan);
			m_PopUpSavePlan.ShowWindow();
			R6MenuSavePlan(m_PopUpSavePlan.m_ClientArea).m_pEditSaveNameBox.LMouseDown(0.0000000, 0.0000000);
			// End:0x17A
			break;
		// End:0x177
		case 48:  // EPopUpID_LoadPlanning
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

// SimplePopUp: overrides the parent to default OwnerWindow to 'self' when none provided,
// ensuring pop-ups are centred on this root window rather than floating freely.
function SimplePopUp(string _szTitle, string _szText, UWindowBase.EPopUpID _ePopUpID, optional int _iButtonsType, optional bool bAddDisableDlg, optional UWindowWindow OwnerWindow)
{
	// End:0x2F
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

//==============================================================================
// PopUpBoxDone: called when the user dismisses any pop-up dialog (OK or Cancel).
// Delegates to the parent first (which clears the modal window state), then handles
// the result. Result == 3 (MR_OK) means user confirmed; anything else means cancelled.
// After handling, restores the 3D view and legend panels if the planning widget is active,
// then clears m_ePopUpID to signal no pop-up is open.
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
	// 3 = MR_OK: user clicked the OK / Confirm button
	if((int(Result) == int(3)))
	{
		switch(_ePopUpID)
		{
			// End:0x2C
			case 4:   // EPopUpID_SaveFileExist: user confirmed overwrite of existing file
			// End:0x2AE
			case 47:  // EPopUpID_SavePlanning: initial save request
				szFileName = R6MenuSavePlan(m_PopUpSavePlan.m_ClientArea).m_pEditSaveNameBox.GetValue();
				// End:0x2AB
				if((szFileName != ""))
				{
					// End:0x8B
					if((int(_ePopUpID) == int(4)))
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
					if((szMapName == ""))
					{
						szMapName = string(GetLevel().Outer.Name);
					}
					GetLevel().GetGameTypeSaveDirectories(szGameTypeDirName, szEnglishGTDirectory);
					// End:0x2AB
					if((R6PlanningCtrl(GetPlayerOwner()).m_pFileManager.SavePlanning(mission.m_MapName, szMapName, szEnglishGTDirectory, szGameTypeDirName, szFileName, StartGameInfo) == false))
					{
						SimplePopUp(Localize("POPUP", "FILEERROR", "R6Menu"), ((szFileName @ ":") @ Localize("POPUP", "FILEERRORPROBLEM", "R6Menu")), 2, int(2));
					}
				}
				// End:0x56C
				break;
			// End:0x328
			case 48:  // EPopUpID_LoadPlanning: load the plan file selected in the list box
				SavedPlanningListBox = R6MenuLoadPlan(m_PopUpLoadPlan.m_ClientArea).m_pListOfSavedPlan;
				// End:0x325
				if((SavedPlanningListBox.m_SelectedItem != none))
				{
					szFileName = R6WindowListBoxItem(SavedPlanningListBox.m_SelectedItem).HelpText;
					// End:0x31A
					if((szFileName == ""))
					{
						// [Explicit Continue]
						goto J0x56C;
					}
					LoadAPlanning(szFileName);
				}
				// End:0x56C
				break;
			// End:0x3D8
			case 41:  // EPopUpID_SaveDelPlan: delete a plan from the save-plan dialog
				SavedPlanningListBox = R6MenuSavePlan(m_PopUpSavePlan.m_ClientArea).m_pListOfSavedPlan;
				// End:0x3C4
				if((SavedPlanningListBox.m_SelectedItem != none))
				{
					szFileName = R6WindowListBoxItem(SavedPlanningListBox.m_SelectedItem).HelpText;
					// End:0x394
					if((szFileName == ""))
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
			case 40:  // EPopUpID_LoadDelPlan: delete a plan from the load-plan dialog
				SavedPlanningListBox = R6MenuLoadPlan(m_PopUpLoadPlan.m_ClientArea).m_pListOfSavedPlan;
				// End:0x474
				if((SavedPlanningListBox.m_SelectedItem != none))
				{
					szFileName = R6WindowListBoxItem(SavedPlanningListBox.m_SelectedItem).HelpText;
					// End:0x444
					if((szFileName == ""))
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
			case 43:  // EPopUpID_OverWriteCampaign: confirmed overwrite of an existing campaign save
				m_SinglePlayerWidget.TryCreatingCampaign();
				// End:0x56C
				break;
			// End:0x4AF
			case 39:  // EPopUpID_QuickPlay: confirmed launch with default action plan
				LaunchQuickPlay();
				return;
				// End:0x56C
				break;
			// End:0x4C6
			case 42:  // EPopUpID_DeleteCampaign: confirmed deletion of a campaign save
				m_SinglePlayerWidget.DeleteCurrentSelectedCampaign();
				// End:0x56C
				break;
			// End:0x50E
			case 46:  // EPopUpID_LeavePlanningToMain: abandon planning and return to main menu
				Console.Master.m_StartGameInfo.m_ReloadPlanning = false;
				R6PlanningCtrl(GetPlayerOwner()).DeleteEverySingleNode();
				ChangeCurrentWidget(7);
				// End:0x56C
				break;
			// End:0x52B
			case 44:  // EPopUpID_DelAllWayPoints: delete waypoints for the current team only
				R6PlanningCtrl(GetPlayerOwner()).DeleteAllNode();
				// End:0x56C
				break;
			// End:0x548
			case 45:  // EPopUpID_DelAllTeamsWayPoints: delete waypoints for all teams
				R6PlanningCtrl(GetPlayerOwner()).DeleteEverySingleNode();
				// End:0x56C
				break;
			// End:0x54D
			// Informational pop-ups only; user simply acknowledges, nothing else needed.
			case 6:   // EPopUpID_InvalidLoad
			// End:0x552
			case 49:  // EPopUpID_PlanningIncomplete
			// End:0x557
			case 27:  // EPopUpID_InvalidPassword
			// End:0x55F
			case 37:  // (spare slot in 1.60)
				// End:0x56C
				break;
			// End:0x569
			case 5:  // EPopUpID_PlanDeleteError: file delete failed (read-only default plan)
				return;
				// End:0x56C
				break;
			// End:0xFFFF
			default:
				break;
		}
		J0x56C:
		
	}
	// User cancelled (MR_Cancel / closed dialog without confirming).
	// For delete operations, re-show the parent dialog so the user can pick another file.
	else
	{
		switch(_ePopUpID)
		{
			// End:0x58F
			case 40:  // EPopUpID_LoadDelPlan cancelled: go back to load dialog
				m_PopUpLoadPlan.ShowWindow();
				return;
				// End:0x5C0
				break;
			// End:0x5A8
			case 41:  // EPopUpID_SaveDelPlan cancelled: go back to save dialog
				m_PopUpSavePlan.ShowWindow();
				return;
				// End:0x5C0
				break;
			// End:0x5BA
			case 4:  // EPopUpID_SaveFileExist cancelled: keep save dialog open (m_ePopUpID stays set)
				m_ePopUpID = 47;  // EPopUpID_SavePlanning
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
	// If we're back in the planning widget, restore the 3D view and legend panels that
	// ClosePopups() hid when the dialog opened.
	if(((m_CurrentWidget == m_PlanningWidget) && (!m_bPlayerDoNotWant3DView)))
	{
		m_PlanningWidget.m_3DButton.m_bSelected = true;
		m_PlanningWidget.m_3DWindow.Toggle3DWindow();
		R6PlanningCtrl(GetPlayerOwner()).Toggle3DView();
	}
	// End:0x66F
	if(((m_CurrentWidget == m_PlanningWidget) && m_bPlayerWantLegend))
	{
		m_PlanningWidget.m_LegendWindow.ToggleLegend();
		m_PlanningWidget.m_LegendButton.m_bSelected = true;
	}
	// End:0x6A2
	// 3 = EPopUpID_FileWriteErrorBackupPln: backup save failed but game can still launch;
	// SetStartTeamInfo finalises team data, then LaunchR6Game starts the mission.
	if((int(_ePopUpID) == int(3)))
	{
		m_GearRoomWidget.SetStartTeamInfo();
		R6Console(Console).LaunchR6Game();
	}
	m_ePopUpID = 0;
	return;
}

// StopPlayMode: halts the timeline playback animation in the planning widget.
// Called before entering a game or opening a dialog to avoid animation playing in background.
function StopPlayMode()
{
	m_PlanningWidget.m_PlanningBar.m_TimeLine.StopPlayMode();
	return;
}

//==============================================================================
// StopWidgetSound: stops ambient audio for the current widget.
// Only the Intel widget (8 = IntelWidgetID) plays ambient sound that needs
// explicit stopping when navigating away.
//==============================================================================
function StopWidgetSound()
{
	// End:0x1F
	if((int(m_eCurWidgetInUse) == int(8)))
	{
		m_IntelWidget.StopIntelWidgetSound();
	}
	return;
}

// SetServerOptions: pushes current server configuration from the create-game widget to the
// underlying game service. Safe to call even if the widget hasn't been created yet.
function SetServerOptions()
{
	// End:0x39
	if(((m_pMPCreateGameWidget != none) && (m_pMPCreateGameWidget.m_pCreateTabOptions != none)))
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
	// Plans are stored at: ..\save\plan\<MapMenuName>\<GameTypeDir>\*.PLN
	// Resolve the human-readable map name from localisation; fall back to level package name.
	StartGameInfo = Console.Master.m_StartGameInfo;
	mission = R6MissionDescription(StartGameInfo.m_CurrentMission);
	GetLevel().GetGameTypeSaveDirectories(szGameTypeDirName, szEnglishGTDirectory);
	szMapName = Localize(mission.m_MapName, "ID_MENUNAME", mission.LocalizationFile, true);
	// End:0xC1
	if((szMapName == ""))
	{
		szMapName = string(GetLevel().Outer.Name);  // fallback: use the raw level package name
	i = 0;
	J0xF3:

	// End:0x193 [Loop If]
	if((i < iMax))
	{
		R6PlanningCtrl(GetPlayerOwner()).m_pFileManager.GetFileName(i, szFileName);
		// End:0x189
		if((szFileName != ""))
		{
			szFileName = Left(szFileName, InStr(szFileName, ".PLN"));  // strip .PLN extension for display
			NewItem = R6WindowListBoxItem(_pListOfSavedPlan.Items.Append(Class'R6Window.R6WindowListBoxItem'));
			NewItem.HelpText = szFileName;
		}
		(i++);
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
	if((szMapName == ""))
	{
		szMapName = string(GetLevel().Outer.Name);
	}
	// .PLN files live at: ..\save\plan\<MapMenuName>\<GameTypeDir>\<FileName>.PLN
	szPathAndFilename = (((((("..\\save\\plan\\" $ szMapName) $ "\\") $ szGameTypeDirName) $ "\\") $ _szFileName) $ ".PLN");
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

	// Clear existing waypoints before loading to avoid stale nodes from a previous plan
	R6PlanningCtrl(GetPlayerOwner()).DeleteEverySingleNode();
	if((szMapName == ""))
	{
		szMapName = string(GetLevel().Outer.Name);
	}
	GetLevel().GetGameTypeSaveDirectories(szGameTypeDirName, szEnglishGTDirectory);
	// End:0x167
	if((R6PlanningCtrl(GetPlayerOwner()).m_pFileManager.LoadPlanning(mission.m_MapName, szMapName, szEnglishGTDirectory, szGameTypeDirName, _szFileName, StartGameInfo, szLoadErrorMsgMapName, szLoadErrorMsgGameType) == true))
	{
		R6PlanningCtrl(GetPlayerOwner()).InitNewPlanning(R6PlanningCtrl(GetPlayerOwner()).m_pFileManager.m_iCurrentTeam);
		m_GearRoomWidget.LoadRosterFromStartInfo();  // sync loaded roster into the gear room UI
		return true;		
	}
	else
	{
		// Load failed: try to produce a human-readable error by resolving the map name
		// and game type from the error strings returned by the file manager.
		bFoundMission = false;
		iMission = 0;
		J0x176:

		// End:0x216 [Loop If]
		if((iMission < R6Console(Root.Console).m_aMissionDescriptions.Length))
		{
			mission = R6Console(Root.Console).m_aMissionDescriptions[iMission];
			// End:0x20C
			if((Caps(mission.m_MapName) == Caps(szLoadErrorMsgMapName)))
			{
				bFoundMission = true;
				iMission = R6Console(Root.Console).m_aMissionDescriptions.Length;
			}
			(iMission++);
			// [Loop Continue]
			goto J0x176;
		}
		szMapName = Localize(mission.m_MapName, "ID_MENUNAME", mission.LocalizationFile, true);
		// End:0x296
		if(((szMapName == "") || (bFoundMission == false)))
		{
			szMapName = Localize("POPUP", "LOADERRORMAPUNKNOWN", "R6Menu");
		}
		// End:0x2E6
		if((GetLevel().FindSaveDirectoryNameFromEnglish(szGameTypeDirName, szLoadErrorMsgGameType) == false))
		{
			szGameTypeDirName = Localize("POPUP", "LOADERRORMAPUNKNOWN", "R6Menu");
		}
		szLoadErrorMsg = (((Localize("POPUP", "LOADERRORPROBLEM", "R6Menu") @ szMapName) @ Localize("POPUP", "LOADERRORPROBLEM2", "R6Menu")) @ szGameTypeDirName);
		// 6 = EPopUpID_InvalidLoad; 2 = MB_OK button
		SimplePopUp(Localize("POPUP", "LOADERROR", "R6Menu"), (_szFileName @ szLoadErrorMsg), 6, int(2));
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
	if((szMapName == ""))
	{
		szMapName = string(GetLevel().Outer.Name);
	}
	// Construct the full path; same layout as IsSaveFileAlreadyExist and FillListOfSavedPlan
	szPathAndFilename = (((((("..\\save\\plan\\" $ szMapName) $ "\\") $ szGameTypeDirName) $ "\\") $ szFileName) $ ".PLN");
	// End:0x104
	if(m_pFileManager.DeleteFile(szPathAndFilename))
	{
		return true;
	}
	// Delete failed; most likely the file is read-only (default plans shipped with the game).
	// 5 = EPopUpID_PlanDeleteError; 2 = MB_OK button
	ErrorMsg = ((((Localize("POPUP", "PLANDELETEERRORPROBLEM", "R6Menu") @ ":") @ szFileName) @ "\\n") @ Localize("POPUP", "PLANDELETEERRORMSG", "R6Menu"));
	SimplePopUp(Localize("POPUP", "PLANDELETEERROR", "R6Menu"), ErrorMsg, 5, int(2));
	return false;
	return;
}

//===========================================================================
// IsPlanningEmpty: returns true only if ALL teams have zero waypoints.
// Checks all 3 teams (indices 0-2: Red, Gold, Blue). A single waypoint on any
// team means the planning is not empty.
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
	// 3 = total number of operative teams in RavenShield (Red, Gold, Blue)
	if((i < 3))
	{
		PlanningInfo = R6PlanningInfo(Console.Master.m_StartGameInfo.m_TeamInfo[i].m_pPlanning);
		// End:0x72
		if((PlanningInfo.m_NodeList.Length > 0))
		{
			Result = false;
		}
		(i++);
		// [Loop Continue]
		goto J0x0F;
	}
	return Result;
	return;
}

//===========================================================================
// LeaveForGame: final step before launching a single-player mission.
// Saves a backup copy of the plan (Backup.pln) so it can be restored if the
// player retries. _ObserverMode=true spawns as spectator; _iTeamStart selects
// which team the player controls. On backup save failure shows an error and
// does NOT launch the game.
//===========================================================================
function LeaveForGame(bool _ObserverMode, int _iTeamStart)
{
	local R6StartGameInfo StartGameInfo;

	StartGameInfo = Console.Master.m_StartGameInfo;
	StartGameInfo.m_bIsPlaying = (!_ObserverMode);  // false = spectator; true = active player
	StartGameInfo.m_iTeamStart = _iTeamStart;
	m_GearRoomWidget.SetStartTeamInfoForSaving();
	R6PlanningCtrl(GetPlayerOwner()).m_pFileManager.m_iCurrentTeam = R6PlanningCtrl(GetPlayerOwner()).m_iCurrentTeam;
	// End:0x13F
	// Save backup plan; GotoPlanning() reloads it so the player can retry with the same plan.
	// 2 = EPopUpID_FileWriteError; 2 = MB_OK. On failure we show the error but do NOT launch.
	if((R6PlanningCtrl(GetPlayerOwner()).m_pFileManager.SavePlanning("Backup", "Backup", "Backup", "", "Backup.pln", StartGameInfo) == false))
	{
		SimplePopUp(Localize("POPUP", "FILEERROR", "R6Menu"), (("Backup.pln" @ ":") @ Localize("POPUP", "FILEERRORPROBLEM", "R6Menu")), 2, int(2));		
	}
	else
	{
		m_GearRoomWidget.SetStartTeamInfo();  // finalise team data; must be called after SetStartTeamInfoForSaving
		SimpleTextPopUp(Localize("POPUP", "LAUNCHING", "R6Menu"));  // show "Launching..." overlay
		PartialResetOriginalData();  // reset decal manager before handing off to gameplay
		R6Console(Console).LaunchR6Game(true);
	}
	return;
}

// NEW IN 1.60
// PartialResetOriginalData: destroys and re-creates the decal manager before transitioning
// from planning into gameplay. Prevents decal state (footprints, blood, bullet marks from
// a prior planning session) from leaking into the live mission. bKNoInit suppresses respawn
// in editor/server contexts where a decal manager isn't meaningful.
function PartialResetOriginalData()
{
	local R6DecalManager aMgr;

	aMgr = GetLevel().m_DecalManager;
	GetLevel().m_DecalManager = none;  // detach first so Destroy can't cause re-entrant access
	// End:0x3D
	if((aMgr != none))
	{
		aMgr.Destroy();
	}
	// End:0x74
	if((!GetLevel().bKNoInit))
	{
		GetLevel().m_DecalManager = GetLevel().Spawn(Class'Engine.R6DecalManager');  // fresh instance
	}
	return;
}

//===========================================================================================================
// Make sure that is one of these buttons needs to downsize it's font all buttons end up using the same font
//===========================================================================================================
function HarmonizeMenuFonts()
{
	local Font ButtonFont, DownSizeFont;

	DownSizeFont = Root.Fonts[6];   // 6 = F_VerySmallTitle: fallback when button text is too long
	ButtonFont = Root.Fonts[16];    // 16 = F_PrincipalButton: standard button label font
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
	// If ANY of the three widgets needs a smaller font (e.g. long localised strings),
	// force ALL of them to use it so they look visually consistent across languages.
	if(((m_SinglePlayerWidget.ButtonsUsingDownSizeFont() || m_CustomMissionWidget.ButtonsUsingDownSizeFont()) || m_TrainingWidget.ButtonsUsingDownSizeFont()))
	{
		m_SinglePlayerWidget.ForceFontDownSizing();
		m_CustomMissionWidget.ForceFontDownSizing();
		m_TrainingWidget.ForceFontDownSizing();
	}
	return;
}

//=================================================================================
// MenuLoadProfile: notifies the relevant widget that the user has loaded a profile.
// Server profiles reload settings in the create-game widget; player profiles reload
// in the options widget (controls, audio, video preferences).
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
// NotifyWindow: receives widget notifications from child windows.
// Handles double-click (E == 11 = DE_DoubleClick) on a plan list box: simulates
// clicking OK on the parent pop-up so double-clicking a plan immediately loads/saves it.
// Result = 3 = MR_OK is set before Close() so PopUpBoxDone() handles it correctly.
//=================================================================================
function NotifyWindow(UWindowWindow C, byte E)
{
	// End:0x9D
	// 11 = DE_DoubleClick: treat double-click on a list item as an OK confirmation
	if((int(E) == 11))
	{
		// End:0x57
		if((C == R6MenuLoadPlan(m_PopUpLoadPlan.m_ClientArea).m_pListOfSavedPlan))
		{
			m_PopUpLoadPlan.Result = 3;  // 3 = MR_OK
			m_PopUpLoadPlan.Close();			
		}
		else
		{
			// End:0x9D
			if((C == R6MenuSavePlan(m_PopUpSavePlan.m_ClientArea).m_pListOfSavedPlan))
			{
				m_PopUpSavePlan.Result = 3;  // 3 = MR_OK
				m_PopUpSavePlan.Close();
			}
		}
	}
	return;
}

// SetNewMODS: called when the active mod changes; notifies the parent to swap background
// textures. The _bForceRefresh path was intended to swap the laptop background texture
// at runtime but was never completed — the body is empty in the retail build.
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
// InitBeaconService: sets up LAN server discovery via UDP broadcast beacons.
// Creates the R6LanServers container and the ClientBeaconReceiver if they don't
// already exist, then links the beacon to the game service. Safe to call repeatedly.
//================================================
function InitBeaconService()
{
	// End:0x6A
	if((R6Console(Console).m_LanServers == none))
	{
		R6Console(Console).m_LanServers = new (none) Class<R6LanServers>(Root.MenuClassDefines.ClassLanServer);
		R6Console(Console).m_LanServers.Created();
	}
	// End:0xCC
	if((R6Console(Console).m_LanServers.m_ClientBeacon == none))
	{
		R6Console(Console).m_LanServers.m_ClientBeacon = Console.ViewportOwner.Actor.Spawn(Class'IpDrv.ClientBeaconReceiver');
	}
	R6Console(Console).m_GameService.m_ClientBeacon = R6Console(Console).m_LanServers.m_ClientBeacon;
	return;
}

defaultproperties
{
	m_BGTexture0=Texture'R6MenuBG.Backgrounds.GenericLoad0'  // first loading screen background
	m_BGTexture1=Texture'R6MenuBG.Backgrounds.GenericLoad1'  // second loading screen background
	m_MainMenuMusic=Sound'Music.Play_theme_Menu1'             // title screen music track
	LookAndFeelClass="R6Menu.R6MenuRSLookAndFeel"            // R6-specific UI skin / theme class
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var n
// REMOVED IN 1.60: function SaveTrainingPlanning
