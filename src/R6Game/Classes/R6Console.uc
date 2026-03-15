//=============================================================================
// R6Console - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//============================================================================//
// Class            R6Console
// Date             20 April 2001
// Description
//
//  Revision history:
//    
//============================================================================//
class R6Console extends WindowConsole
    config;

const K_CHECKTIME_INTERVAL = 3000;
const K_CHECKTIME_TIMEOUT = 9000;

enum eLeaveGame
{
	LG_MainMenu,                    // 0
	LG_NextLevel,                   // 1
	LG_Trainning,                   // 2
	LG_MultiPlayerMenu,             // 3
	LG_RetryPlanningCustomMission,  // 4
	LG_CustomMissionMenu,           // 5
	LG_RetryPlanningCampaign,       // 6
	LG_QuitGame,                    // 7
	LG_MultiPlayerError,            // 8
	LG_InitMod                      // 9
};

// NEW IN 1.60
var R6Console.eLeaveGame m_eNextStep;
var int m_iLastCheckTime;  // Time at which the last check was made to see if ubi.com client is still responding
var int m_iLastSuccCheckTime;  // Time at which the last check was made to see if ubi.com client is still responding
var bool bResetLevel;
var bool bLaunchWasCalled;
var bool bLaunchMultiPlayer;
var bool bReturnToMenu;
var bool bCancelFire;
//R6CODE
var bool m_bInGamePlanningKeyDown;
var bool m_bSkipAFrameAndStart;  // To render one last frame before leaving
var bool m_bRenderMenuOneTime;  // render the menu one time before processing key in the case of and connection interruption
var bool m_bStartR6GameInProgress;  // currently create new menu and load sound bank fct StartR6Game
var R6Campaign m_CurrentCampaign;
var R6PlayerCampaign m_PlayerCampaign;
var R6GSServers m_GameService;  // Manages servers from game service
var R6LanServers m_LanServers;  // Manages servers on the LAN
var R6PlayerCustomMission m_playerCustomMission;  // containt all the map unlock for each campaign
var Sound m_StopMainMenuMusic;
//////////////////////////////////////////////////////////////////////////////////
//This Stuff Is single Player Game Specific and Might Need to be moved elsewhere
//This is needed to launch the game with the good operatives and 
/////////////////////////////////////////////////////////////////////////////////
var array<R6Campaign> m_aCampaigns;
var array<R6MissionDescription> m_aMissionDescriptions;
// NEW IN 1.60
var array<UWindowRootWindow.eGameWidgetID> m_AWIDList;
var string m_szLastError;  // String used to store error to be later displayed
//var string szStoreIP;           // String used to store IP of host server
var string szStoreGamePassWd;  // String used to store game password

//------------------------------------------------------------------
// Inhereited
//------------------------------------------------------------------
event Message(coerce string Msg, float MsgLife)
{
	local PlayerController PController;

	// End:0x0D
	if((ViewportOwner == none))
	{
		return;
	}
	PController = ViewportOwner.Actor;
	PController.myHUD.Message(PController.PlayerReplicationInfo, Msg, 'Console');
	return;
}

function CreateRootWindow(Canvas Canvas)
{
	InitCampaignAndMissionDescription();
	super.CreateRootWindow(Canvas);
	return;
}

function InitCampaignAndMissionDescription()
{
	local R6FileManager pFileManager;
	local string szCampaignName, szCampaignPathName;
	local int iAdditionalModIndex;

	szCampaignName = Class'Engine.Actor'.static.GetModMgr().m_pCurrentMod.m_szCampaignIniFile;
	pFileManager = new (none) Class'Engine.R6FileManager';
	szCampaignPathName = ("..\\maps\\" $ szCampaignName);
	// End:0x68
	if((!pFileManager.FindFile(szCampaignPathName)))
	{
		szCampaignName = "";
	}
	m_aMissionDescriptions.Remove(0, m_aMissionDescriptions.Length);
	// End:0xCC
	if(((!Class'Engine.Actor'.static.GetModMgr().IsRavenShield()) && (szCampaignName != "RavenShieldCampaign")))
	{
		LoadCampaignIni("RavenShieldCampaign");
	}
	iAdditionalModIndex = 0;
	J0xD3:

	// End:0x14D [Loop If]
	if((Class'Engine.Actor'.static.GetModMgr().m_pCurrentMod.GetExtraMods(iAdditionalModIndex) != none))
	{
		szCampaignName = Class'Engine.Actor'.static.GetModMgr().m_pCurrentMod.GetExtraMods(iAdditionalModIndex).m_szCampaignIniFile;
		LoadCampaignIni(szCampaignName);
		(iAdditionalModIndex++);
		szCampaignName = "";
		// [Loop Continue]
		goto J0xD3;
	}
	// End:0x17D
	if((szCampaignName == ""))
	{
		szCampaignName = Class'Engine.Actor'.static.GetModMgr().m_pCurrentMod.m_szCampaignIniFile;
	}
	LoadCampaignIni(szCampaignName);
	return;
}

// MPF: LoadCampaignIni 
function LoadCampaignIni(string szCampaign)
{
	local int i;
	local bool bFound;

	i = 0;
	J0x07:

	// End:0x58 [Loop If]
	if((i < m_aCampaigns.Length))
	{
		// End:0x4E
		if((m_aCampaigns[i].m_szCampaignFile == szCampaign))
		{
			m_CurrentCampaign = m_aCampaigns[i];
			bFound = true;
		}
		(i++);
		// [Loop Continue]
		goto J0x07;
	}
	// End:0x84
	if((bFound == false))
	{
		m_CurrentCampaign = new (none) Class'R6Game.R6Campaign';
		m_aCampaigns[i] = m_CurrentCampaign;
	}
	m_CurrentCampaign.InitCampaign(ViewportOwner.Actor.Level, szCampaign, self);
	UnlockMissions();
	return;
}

function InitMod()
{
	local string szCampaign;
	local int iAdditionalModIndex;

	m_aMissionDescriptions.Remove(0, m_aMissionDescriptions.Length);
	// End:0x43
	if((!Class'Engine.Actor'.static.GetModMgr().IsRavenShield()))
	{
		LoadCampaignIni("RavenShieldCampaign");
	}
	iAdditionalModIndex = 0;
	iAdditionalModIndex = 0;
	J0x51:

	// End:0xC3 [Loop If]
	if((Class'Engine.Actor'.static.GetModMgr().m_pCurrentMod.GetExtraMods(iAdditionalModIndex) != none))
	{
		szCampaign = Class'Engine.Actor'.static.GetModMgr().m_pCurrentMod.GetExtraMods(iAdditionalModIndex).m_szCampaignIniFile;
		LoadCampaignIni(szCampaign);
		(iAdditionalModIndex++);
		// [Loop Continue]
		goto J0x51;
	}
	szCampaign = Class'Engine.Actor'.static.GetModMgr().m_pCurrentMod.m_szCampaignIniFile;
	LoadCampaignIni(szCampaign);
	// End:0x10E
	if((m_PlayerCampaign != none))
	{
		m_PlayerCampaign.m_bCampaignCompleted = 0;
	}
	ConsoleCommand((("LOADSERVER " $ Class'Engine.Actor'.static.GetModMgr().GetServerIni()) $ ".ini"));
	return;
}

event Initialized()
{
	// End:0x22
	if(bShowLog)
	{
		Log("R6Console Initialized");
	}
	m_PlayerCampaign = new (none) Class'R6Game.R6PlayerCampaign';
	m_PlayerCampaign.m_OperativesMissionDetails = new (none) Class'R6Game.R6MissionRoster';
	m_playerCustomMission = new (none) Class'R6Game.R6PlayerCustomMission';
	Class'Engine.Actor'.static.GetGameManager().SetConsoleInGameMgr(self);
	return;
}

function InitializedGameService()
{
	m_GameService = R6GSServers(Class'Engine.Actor'.static.GetGameManager().GetGameMgrGameService());
	// End:0x45
	if((m_GameService == none))
	{
		Log("m_GameService is none");
	}
	return;
}

function Object SetGameServiceLinks(PlayerController _localPlayer)
{
	// End:0x37
	if((Class'Engine.Actor'.static.GetGameManager().GetGameMgrGameService() != none))
	{
		Class'Engine.Actor'.static.GetGameManager().SetLocalPlayerCtrl(_localPlayer);
	}
	// End:0x56
	if((m_LanServers != none))
	{
		m_LanServers.m_LocalPlayerController = _localPlayer;
	}
	return Class'Engine.Actor'.static.GetGameManager().GetGameMgrGameService();
	return;
}

event UserDisconnected()
{
	// End:0x5A
	if(bShowLog)
	{
		Log("R6Console::UserDisconnected() Returning to menus due to Server disconnection!");
	}
	Class'Engine.Actor'.static.GetGameManager().ConnectionInterrupted(true);
	SetGameServiceLinks(none);
	// End:0x94
	if((m_bNonUbiMatchMaking || m_bNonUbiMatchMakingHost))
	{
		LeaveR6Game(7);		
	}
	else
	{
		LeaveR6Game(3);
	}
	return;
}

event ServerDisconnected()
{
	// End:0x5C
	if(bShowLog)
	{
		Log("R6Console::ServerDisconnected() Returning to menus due to Server disconnection!");
	}
	LeaveR6Game(8);
	Class'Engine.Actor'.static.GetGameManager().ConnectionInterrupted();
	SetGameServiceLinks(none);
	return;
}

event R6ConnectionFailed(string szError)
{
	// End:0x34
	if(bShowLog)
	{
		Log(("R6Console::R6ConnectionFailed() " $ szError));
	}
	m_szLastError = szError;
	Root.ResetMenus(true);
	LeaveR6Game(8);
	Class'Engine.Actor'.static.GetGameManager().ConnectionInterrupted();
	SetGameServiceLinks(none);
	return;
}

event R6ConnectionSuccess()
{
	// End:0x2D
	if(bShowLog)
	{
		Log("R6Console::R6ConnectionSuccess()");
	}
	// End:0x55
	if((int(Root.m_eRootId) != int(Root.3)))
	{
		LaunchR6MultiPlayerGame();
	}
	return;
}

event R6ConnectionInterrupted()
{
	// End:0x31
	if(bShowLog)
	{
		Log("R6Console::R6ConnectionInterrupted()");
	}
	// End:0x4C
	if((m_bNonUbiMatchMaking == true))
	{
		Root.DoQuitGame();
	}
	Class'Engine.Actor'.static.EnableLoadingScreen(true);
	Root.ResetMenus(true);
	LeaveR6Game(3);
	Class'Engine.Actor'.static.GetGameManager().ConnectionInterrupted();
	SetGameServiceLinks(none);
	return;
}

event R6ConnectionInProgress()
{
	// End:0x80
	if((int(Root.GetSimplePopUpID()) == int(0)))
	{
		Root.SimplePopUp(Localize("MultiPlayer", "PopUp_Downloading", "R6Menu"), Localize("PopUP", "PopUpEscCancel", "R6Menu"), 33, 4);
	}
	return;
}

event R6ProgressMsg(string _Str1, string _Str2, float Seconds)
{
	local array<string> ATextMsg;

	ATextMsg[0] = _Str1;
	ATextMsg[1] = _Str2;
	Root.ModifyPopUpInsideText(ATextMsg);
	return;
}

// NEW IN 1.60
event string GetStoreGamePwd()
{
	return szStoreGamePassWd;
	return;
}

function bool KeyEvent(Interactions.EInputKey Key, Interactions.EInputAction Action, float Delta)
{
	// End:0x3E
	if(bShowLog)
	{
		Log("ERROR!!!!!!!!!!!!!!!!!!! IN R6Console >> KeyEvent");
	}
	return false;
	return;
}

function bool KeyType(Interactions.EInputKey Key)
{
	// End:0x3D
	if(bShowLog)
	{
		Log("ERROR!!!!!!!!!!!!!!!!!!! IN R6Console >> KeyType");
	}
	return false;
	return;
}

function PostRender(Canvas Canvas)
{
	// End:0x40
	if(bShowLog)
	{
		Log("ERROR!!!!!!!!!!!!!!!!!!! IN R6Console >> PostRender");
	}
	return;
}

function LaunchInstructionMenu(R6InstructionSoundVolume pISV, bool bShow, int iBox, int iParagraph)
{
	Root.ChangeInstructionWidget(pISV, bShow, iBox, iParagraph);
	return;
}

event LaunchR6MainMenu()
{
	local UWindowMenuClassDefines pMenuDefGSServers;
	local int i;

	// End:0x27
	if(bShowLog)
	{
		Log("R6Console LaunchR6MainMenu");
	}
	bVisible = true;
	bUWindowActive = true;
	pMenuDefGSServers = new (none) Class'UWindow.UWindowMenuClassDefines';
	pMenuDefGSServers.Created();
	RootWindow = pMenuDefGSServers.RegularRoot;
	CreateRootWindow(none);
	LaunchUWindow();
	return;
}

function NotifyLevelChange()
{
	// End:0x28
	if(bShowLog)
	{
		Log("R6Console NotifyLevelChange");
	}
	super.NotifyLevelChange();
	// End:0x64
	if((R6PlayerController(ViewportOwner.Actor) != none))
	{
		R6PlayerController(ViewportOwner.Actor).ClearReferences();
	}
	return;
}

function CleanAndChangeMod(array<UWindowRootWindow.eGameWidgetID> _AWIDListToUse)
{
	m_AWIDList = _AWIDListToUse;
	m_bChangeModInProgress = true;
	LeaveR6Game(9);
	R6GSServers(Class'Engine.Actor'.static.GetGameManager().GetGameMgrGameService()).InitializeMod();
	return;
}

function LeaveR6Game(R6Console.eLeaveGame _bwhatToDo)
{
	local Canvas C;
	local bool bCleanUp;
	local R6ServerInfo ServerInfo;

	// End:0x22
	if(bShowLog)
	{
		Log("R6Console LeaveR6Game");
	}
	// End:0x2D
	if(bReturnToMenu)
	{
		return;
	}
	bReturnToMenu = true;
	CleanSound(_bwhatToDo);
	Master.m_MenuCommunication = none;
	CloseR6MainMenu(true);
	LaunchR6MainMenu();
	C = Class'Engine.Actor'.static.GetCanvas();
	C.m_iNewResolutionX = 640;
	C.m_iNewResolutionY = 480;
	C.m_bChangeResRequested = true;
	C.m_bFading = false;
	ServerInfo = Class'Engine.Actor'.static.GetServerOptions();
	ServerInfo.m_ServerMapList = none;
	ServerInfo.m_GameInfo = none;
	switch(_bwhatToDo)
	{
		// End:0x126
		case 1:
			m_eNextStep = 1;
			CleanPlanning();
			// End:0x123
			if((int(m_PlayerCampaign.m_bCampaignCompleted) == 1))
			{
				bCleanUp = true;
			}
			// End:0x2E7
			break;
		// End:0x13E
		case 3:
			m_eNextStep = 3;
			bCleanUp = true;
			// End:0x2E7
			break;
		// End:0x1BA
		case 4:
			CleanPlanning();
			Master.m_StartGameInfo.m_ReloadPlanning = true;
			ViewportOwner.Actor.SetPlanningMode(true);
			m_eNextStep = 4;
			// End:0x1B7
			if((R6PlayerController(ViewportOwner.Actor) != none))
			{
				R6PlayerController(ViewportOwner.Actor).ClearReferences();
			}
			// End:0x2E7
			break;
		// End:0x1D8
		case 5:
			CleanPlanning();
			m_eNextStep = 5;
			bCleanUp = true;
			// End:0x2E7
			break;
		// End:0x254
		case 6:
			CleanPlanning();
			Master.m_StartGameInfo.m_ReloadPlanning = true;
			ViewportOwner.Actor.SetPlanningMode(true);
			m_eNextStep = 6;
			// End:0x251
			if((R6PlayerController(ViewportOwner.Actor) != none))
			{
				R6PlayerController(ViewportOwner.Actor).ClearReferences();
			}
			// End:0x2E7
			break;
		// End:0x272
		case 7:
			CleanPlanning();
			m_eNextStep = 7;
			bCleanUp = true;
			// End:0x2E7
			break;
		// End:0x28A
		case 8:
			m_eNextStep = 8;
			bCleanUp = true;
			// End:0x2E7
			break;
		// End:0x2A8
		case 2:
			CleanPlanning();
			m_eNextStep = 2;
			bCleanUp = true;
			// End:0x2E7
			break;
		// End:0x2C6
		case 9:
			CleanPlanning();
			m_eNextStep = 9;
			bCleanUp = true;
			// End:0x2E7
			break;
		// End:0x2CB
		case 0:
		// End:0xFFFF
		default:
			CleanPlanning();
			m_eNextStep = 0;
			bCleanUp = true;
			// End:0x2E7
			break;
			break;
	}
	// End:0x39F
	if(bCleanUp)
	{
		// End:0x38D
		if(((ViewportOwner.Actor != none) && (int(ViewportOwner.Actor.Level.NetMode) == int(NM_Standalone))))
		{
			// End:0x38A
			if((ViewportOwner.Actor.Level != ViewportOwner.Actor.GetEntryLevel()))
			{
				Master.m_StartGameInfo.m_MapName = "Entry";
				PreloadMapForPlanning();
			}			
		}
		else
		{
			ConsoleCommand("DISCONNECT");
		}
	}
	Class'Engine.Actor'.static.GetGameManager().GetIDListSize();
	ViewportOwner.Actor.SpawnDefaultHUD();
	return;
}

function CleanSound(R6Console.eLeaveGame _bwhatToDo)
{
	ViewportOwner.Actor.StopAllSounds();
	ViewportOwner.Actor.ResetVolume_AllTypeSound();
	switch(_bwhatToDo)
	{
		// End:0x54
		case 4:
			ViewportOwner.Actor.FadeSound(0.0000000, 25, 5);
		// End:0x59
		case 5:
		// End:0x61
		case 6:
			// End:0x15F
			break;
		// End:0xEA
		case 1:
			// End:0xA9
			if((int(ViewportOwner.Actor.Level.NetMode) != int(NM_Standalone)))
			{
				ViewportOwner.Actor.StopAllMusic();
			}
			ViewportOwner.Actor.Level.SetBankSound(1);
			ViewportOwner.Actor.Level.FinalizeLoading();
			// End:0x15F
			break;
		// End:0xEF
		case 7:
		// End:0xF4
		case 2:
		// End:0xF9
		case 3:
		// End:0x116
		case 9:
			ViewportOwner.Actor.StopAllMusic();
		// End:0x11B
		case 0:
		// End:0xFFFF
		default:
			ViewportOwner.Actor.Level.SetBankSound(1);
			ViewportOwner.Actor.Level.FinalizeLoading();
			// End:0x15F
			break;
			break;
	}
	return;
}

function CleanPlanning()
{
	// End:0x1F2
	if((int(ViewportOwner.Actor.Level.NetMode) == int(NM_Standalone)))
	{
		// End:0x4E
		if(((Master == none) || (Master.m_StartGameInfo == none)))
		{
			return;
		}
		Master.m_StartGameInfo.m_TeamInfo[0].m_iNumberOfMembers = 0;
		Master.m_StartGameInfo.m_TeamInfo[1].m_iNumberOfMembers = 0;
		Master.m_StartGameInfo.m_TeamInfo[2].m_iNumberOfMembers = 0;
		// End:0xE5
		if((Master.m_StartGameInfo.m_TeamInfo[0].m_pPlanning == none))
		{
			return;
		}
		Master.m_StartGameInfo.m_TeamInfo[0].m_pPlanning.DeleteAllNode();
		Master.m_StartGameInfo.m_TeamInfo[1].m_pPlanning.DeleteAllNode();
		Master.m_StartGameInfo.m_TeamInfo[2].m_pPlanning.DeleteAllNode();
		Master.m_StartGameInfo.m_TeamInfo[0].m_pPlanning.m_pTeamManager = none;
		Master.m_StartGameInfo.m_TeamInfo[1].m_pPlanning.m_pTeamManager = none;
		Master.m_StartGameInfo.m_TeamInfo[2].m_pPlanning.m_pTeamManager = none;
	}
	return;
}

function CloseR6MainMenu(optional bool bKeepInputSystem)
{
	// End:0x26
	if(bShowLog)
	{
		Log("R6Console CloseR6MainMenu");
	}
	// End:0x6C
	if(((m_LanServers != none) && (m_LanServers.m_ClientBeacon != none)))
	{
		m_LanServers.m_ClientBeacon.Destroy();
		m_LanServers.m_ClientBeacon = none;
	}
	// End:0x9D
	if(((m_GameService != none) && (m_GameService.m_ClientBeacon != none)))
	{
		m_GameService.m_ClientBeacon = none;
	}
	m_LanServers = none;
	bVisible = false;
	ResetUWindow();
	// End:0xF8
	if((bKeepInputSystem == false))
	{
		ViewportOwner.Actor.ChangeInputSet(0);
		ViewportOwner.Actor.Level.m_bPlaySound = true;
	}
	return;
}

function PreloadMapForPlanning()
{
	local int iPlayerSpawnNumber;

	ConsoleCommand(((("Start " $ Master.m_StartGameInfo.m_MapName) $ "?SpawnNum=") $ string(iPlayerSpawnNumber)));
	ViewportOwner.Actor.ChangeInputSet(1);
	return;
}

function CreateInGameMenus()
{
	local UWindowMenuClassDefines pMenuDefGSServers;

	Log(("R6Console CreateInGameMenus bLaunchMultiPlayer" @ string(bLaunchMultiPlayer)));
	pMenuDefGSServers = new (none) Class'UWindow.UWindowMenuClassDefines';
	pMenuDefGSServers.Created();
	// End:0x8F
	if(bLaunchMultiPlayer)
	{
		RootWindow = pMenuDefGSServers.InGameMultiRoot;
		bUWindowActive = true;
		CreateRootWindow(none);
		LaunchUWindow();		
	}
	else
	{
		RootWindow = pMenuDefGSServers.InGameSingleRoot;
		CreateRootWindow(none);
	}
	return;
}

function ResetR6Game()
{
	// End:0x22
	if(bShowLog)
	{
		Log("R6Console ResetR6Game");
	}
	bLaunchWasCalled = true;
	bResetLevel = true;
	return;
}

function LaunchR6Game(optional bool bSkipFrameAndStart_)
{
	// End:0x23
	if(bShowLog)
	{
		Log("R6Console LaunchR6Game");
	}
	bLaunchWasCalled = true;
	m_bSkipAFrameAndStart = bSkipFrameAndStart_;
	return;
}

function LaunchR6MultiPlayerGame()
{
	// End:0x2E
	if(bShowLog)
	{
		Log("R6Console LaunchR6MultiPlayerGame");
	}
	bLaunchWasCalled = true;
	bLaunchMultiPlayer = true;
	return;
}

//=================================================================================
// LaunchTraining(): Launch training map and in-game menu, process is like single player map loading
//=================================================================================
function LaunchTraining()
{
	Master.m_StartGameInfo.m_bIsPlaying = true;
	PreloadMapForPlanning();
	return;
}

function StartR6Game(optional bool bResetLevel)
{
	local R6PlayerController aPC;
	local R6GameInfo pGameInfo;

	// End:0x39
	if(bShowLog)
	{
		Log(("R6Console StartR6Game bResetLevel=" @ string(bResetLevel)));
	}
	ViewportOwner.Actor.StopMusic(m_StopMainMenuMusic);
	m_bStartR6GameInProgress = true;
	// End:0xAF
	if((!bResetLevel))
	{
		Class'Engine.Actor'.static.GetCanvas().m_iNewResolutionX = 0;
		Class'Engine.Actor'.static.GetCanvas().m_iNewResolutionY = 0;
		Class'Engine.Actor'.static.GetCanvas().m_bChangeResRequested = true;
	}
	// End:0xC0
	if((!bResetLevel))
	{
		CloseR6MainMenu();
	}
	// End:0xD1
	if((!bResetLevel))
	{
		CreateInGameMenus();
	}
	// End:0x144
	if((bLaunchMultiPlayer == false))
	{
		// End:0x144
		if(ViewportOwner.Actor.Level.Game.IsA('R6GameInfo'))
		{
			ViewportOwner.Actor.Level.Game.DeployCharacters(ViewportOwner.Actor);
		}
	}
	pGameInfo = R6GameInfo(ViewportOwner.Actor.Level.Game);
	// End:0x1DA
	if(((pGameInfo != none) && (pGameInfo.m_HudClass != none)))
	{
		ViewportOwner.Actor.ClientSetHUD(R6GameInfo(ViewportOwner.Actor.Level.Game).m_HudClass, none);		
	}
	else
	{
		ViewportOwner.Actor.ClientSetHUD(Class'Engine.Actor'.static.GetModMgr().GetDefaultHUD(), none);
	}
	Class'Engine.Actor'.static.GarbageCollect();
	// End:0x2CC
	if(((int(ViewportOwner.Actor.Level.NetMode) == int(NM_Standalone)) && ViewportOwner.Actor.Level.Game.IsA('R6AbstractGameInfo')))
	{
		R6AbstractGameInfo(ViewportOwner.Actor.Level.Game).SpawnAIandInitGoInGame();
		ViewportOwner.Actor.Level.Game.m_bGameStarted = true;
	}
	// End:0x2F0
	if(bLaunchMultiPlayer)
	{
		Class'Engine.Actor'.static.GetGameManager().m_bMultiPlayerGameActive = true;		
	}
	else
	{
		aPC = R6PlayerController(ViewportOwner.Actor);
		// End:0x472
		if((aPC != none))
		{
			// End:0x44B
			if(R6GameInfo(ViewportOwner.Actor.Level.Game).m_bUseClarkVoice)
			{
				aPC.AddSoundBankName(R6MissionDescription(R6Console(Root.Console).Master.m_StartGameInfo.m_CurrentMission).m_InGameVoiceClarkBankName);
				ViewportOwner.Actor.Level.m_sndPlayMissionIntro = R6MissionDescription(R6Console(Root.Console).Master.m_StartGameInfo.m_CurrentMission).m_PlayMissionIntro;
				ViewportOwner.Actor.Level.m_sndPlayMissionExtro = R6MissionDescription(R6Console(Root.Console).Master.m_StartGameInfo.m_CurrentMission).m_PlayMissionExtro;
			}
			ViewportOwner.Actor.ServerSendBankToLoad();
			aPC.ServerReadyToLoadWeaponSound();
		}
	}
	bLaunchMultiPlayer = false;
	m_bStartR6GameInProgress = false;
	return;
}

exec function unlock()
{
	local int i, j;

	i = 0;
	J0x07:

	// End:0x77 [Loop If]
	if((i < m_aCampaigns.Length))
	{
		j = 0;
		J0x1E:

		// End:0x6D [Loop If]
		if((j < m_aCampaigns[i].m_missions.Length))
		{
			m_aCampaigns[i].m_missions[j].m_bIsLocked = false;
			(j++);
			// [Loop Continue]
			goto J0x1E;
		}
		(i++);
		// [Loop Continue]
		goto J0x07;
	}
	return;
}

function SendGoCode(Object.EGoCode eGo)
{
	local int i;

	i = 0;
	J0x07:

	// End:0x54 [Loop If]
	if((i < 3))
	{
		Master.m_StartGameInfo.m_TeamInfo[i].m_pPlanning.NotifyActionPoint(4, eGo);
		(i++);
		// [Loop Continue]
		goto J0x07;
	}
	return;
}

//==============================================================================
// GetSpawnNumber -  Helper function, returns the spawning point number.
//==============================================================================
function int GetSpawnNumber()
{
	local R6StartGameInfo StartGameInfo;

	StartGameInfo = Master.m_StartGameInfo;
	// End:0x21
	if((StartGameInfo == none))
	{
		return 0;
	}
	// End:0x37
	if((!StartGameInfo.m_bIsPlaying))
	{
		return 0;
	}
	return StartGameInfo.m_TeamInfo[StartGameInfo.m_iTeamStart].m_iSpawningPointNumber;
	return;
}

//------------------------------------------------------------------
// GetCampaignFromString
//	
//------------------------------------------------------------------
function R6Campaign GetCampaignFromString(string szName)
{
	local int i, j;

	J0x00:
	// End:0x48 [Loop If]
	if((i < m_aCampaigns.Length))
	{
		// End:0x3E
		if((Caps(m_aCampaigns[i].m_szCampaignFile) == Caps(szName)))
		{
			return m_aCampaigns[i];
		}
		(++i);
		// [Loop Continue]
		goto J0x00;
	}
	return none;
	return;
}

//------------------------------------------------------------------
// UnlockMissions
//	- updated every time UpdateCurrentMapAvailable is changed
//------------------------------------------------------------------
function UnlockMissions()
{
	local int i, iMissionIndex, iMaxMissionIndex;
	local R6Campaign campaign;

	// End:0x0D
	if((m_playerCustomMission == none))
	{
		return;
	}
	i = 0;
	J0x14:

	// End:0xE0 [Loop If]
	if((i < m_playerCustomMission.m_aCampaignFileName.Length))
	{
		campaign = GetCampaignFromString(m_playerCustomMission.m_aCampaignFileName[i]);
		// End:0xD6
		if((campaign != none))
		{
			iMaxMissionIndex = m_playerCustomMission.m_iNbMapUnlock[i];
			(iMaxMissionIndex++);
			iMaxMissionIndex = Clamp(iMaxMissionIndex, 0, campaign.m_missions.Length);
			iMissionIndex = 0;
			J0x9D:

			// End:0xD6 [Loop If]
			if((iMissionIndex < iMaxMissionIndex))
			{
				campaign.m_missions[iMissionIndex].m_bIsLocked = false;
				(++iMissionIndex);
				// [Loop Continue]
				goto J0x9D;
			}
		}
		(i++);
		// [Loop Continue]
		goto J0x14;
	}
	return;
}

//------------------------------------------------------------------
// UpdateCurrentMapAvailable
// 
//------------------------------------------------------------------
function bool UpdateCurrentMapAvailable(R6PlayerCampaign pCampaign, optional bool bCheckCampaignMission)
{
	local bool bFileChange, bInTab;
	local int i, j;
	local string szIniFile;
	local R6Campaign pCampaignMatch;

	i = 0;
	J0x07:

	// End:0xAE [Loop If]
	if((i < m_playerCustomMission.m_aCampaignFileName.Length))
	{
		// End:0xA4
		if((m_playerCustomMission.m_aCampaignFileName[i] == pCampaign.m_CampaignFileName))
		{
			bInTab = true;
			// End:0xA1
			if((m_playerCustomMission.m_iNbMapUnlock[i] < pCampaign.m_iNoMission))
			{
				bFileChange = true;
				m_playerCustomMission.m_iNbMapUnlock[i] = pCampaign.m_iNoMission;
			}
			// [Explicit Break]
			goto J0xAE;
		}
		(i++);
		// [Loop Continue]
		goto J0x07;
	}
	J0xAE:

	// End:0x132
	if(((!bInTab) && (pCampaign.m_CampaignFileName != "")))
	{
		m_playerCustomMission.m_aCampaignFileName[m_playerCustomMission.m_aCampaignFileName.Length] = pCampaign.m_CampaignFileName;
		m_playerCustomMission.m_iNbMapUnlock[m_playerCustomMission.m_iNbMapUnlock.Length] = pCampaign.m_iNoMission;
		bFileChange = true;
	}
	// End:0x277
	if((bCheckCampaignMission == true))
	{
		i = 0;
		J0x145:

		// End:0x19A [Loop If]
		if((i < m_aCampaigns.Length))
		{
			// End:0x190
			if((pCampaign.m_CampaignFileName == m_aCampaigns[i].m_szCampaignFile))
			{
				pCampaignMatch = m_aCampaigns[i];
				// [Explicit Break]
				goto J0x19A;
			}
			(i++);
			// [Loop Continue]
			goto J0x145;
		}
		J0x19A:

		i = 0;
		J0x1A1:

		// End:0x277 [Loop If]
		if(((pCampaignMatch != none) && (i < pCampaignMatch.missions.Length)))
		{
			pCampaignMatch.missions[i] = Caps(pCampaignMatch.missions[i]);
			szIniFile = (pCampaignMatch.missions[i] $ ".INI");
			j = 0;
			J0x21B:

			// End:0x26D [Loop If]
			if((j < m_aMissionDescriptions.Length))
			{
				// End:0x263
				if((m_aMissionDescriptions[j].m_missionIniFile == szIniFile))
				{
					m_aMissionDescriptions[j].m_bCampaignMission = true;
					// [Explicit Break]
					goto J0x26D;
				}
				(j++);
				// [Loop Continue]
				goto J0x21B;
			}
			J0x26D:

			(i++);
			// [Loop Continue]
			goto J0x1A1;
		}
	}
	// End:0x286
	if(bFileChange)
	{
		UnlockMissions();
	}
	return bFileChange;
	return;
}

function bool MapAlreadyInList(string szIniFilename)
{
	local int i;

	i = 0;
	J0x07:

	// End:0x41 [Loop If]
	if((i < m_aMissionDescriptions.Length))
	{
		// End:0x37
		if((szIniFilename == m_aMissionDescriptions[i].m_missionIniFile))
		{
			return true;
		}
		(i++);
		// [Loop Continue]
		goto J0x07;
	}
	return false;
	return;
}

//------------------------------------------------------------------
// GetAllMissionDescriptions
//	
//------------------------------------------------------------------
function GetAllMissionDescriptions(string szCurrentMapDir)
{
	local int i, j, iFiles, iIniFiles, Index;

	local R6FileManager pIniFileManager;
	local string szName, szFileName, szIniName, szIniFilename;
	local bool bMissionIsValid;
	local R6FileManager pFileManager;

	pIniFileManager = new (none) Class'Engine.R6FileManager';
	pFileManager = new (none) Class'Engine.R6FileManager';
	iIniFiles = pIniFileManager.GetNbFile(szCurrentMapDir, "ini");
	iFiles = pFileManager.GetNbFile(szCurrentMapDir, Class'Engine.Actor'.static.GetMapNameExt());
	// End:0xCB
	if(bShowLog)
	{
		Log(((((((("Looking for maps In Dir : " $ szCurrentMapDir) $ ") $ string(iIniFiles)) $ " .ini files") $ " and ") $ string(iFiles)) $ ".rsm"));
	}
	i = 0;
	J0xD2:

	// End:0x25B [Loop If]
	if((i < iIniFiles))
	{
		pIniFileManager.GetFileName(i, szIniFilename);
		// End:0x106
		if((szIniFilename == ""))
		{
			// [Explicit Continue]
			goto J0x251;
		}
		bMissionIsValid = true;
		Index = m_aMissionDescriptions.Length;
		// End:0x12B
		if(MapAlreadyInList(szIniFilename))
		{
			// [Explicit Continue]
			goto J0x251;
		}
		m_aMissionDescriptions[Index] = new (none) Class'Engine.R6MissionDescription';
		m_aMissionDescriptions[Index].Init(ViewportOwner.Actor.Level, (szCurrentMapDir $ szIniFilename));
		// End:0x232
		if((m_aMissionDescriptions[Index].m_MapName != ""))
		{
			j = 0;
			J0x19A:

			// End:0x22F [Loop If]
			if((j < iFiles))
			{
				bMissionIsValid = false;
				pFileManager.GetFileName(j, szFileName);
				// End:0x1D6
				if((szFileName == ""))
				{
					// [Explicit Continue]
					goto J0x225;
				}
				szName = Left(szFileName, InStr(szFileName, "."));
				szName = Caps(szName);
				// End:0x225
				if((szName == Caps(m_aMissionDescriptions[Index].m_MapName)))
				{
					bMissionIsValid = true;
					// [Explicit Break]
					goto J0x22F;
				}
				J0x225:

				(j++);
				// [Loop Continue]
				goto J0x19A;
			}
			J0x22F:
			
		}
		else
		{
			bMissionIsValid = false;
		}
		// End:0x251
		if((!bMissionIsValid))
		{
			m_aMissionDescriptions.Remove(Index, 1);
		}
		J0x251:

		(i++);
		// [Loop Continue]
		goto J0xD2;
	}
	UnlockMissions();
	return;
}

function GetRestKitDescName(GameReplicationInfo gameRepInfo, R6ServerInfo pServerOptions)
{
	local int _iCount;
	local bool _bFound;
	local Class<R6Description> WeaponClass;
	local R6GameReplicationInfo _GRI;
	local R6Mod pCurrentMod;
	local int i;

	pCurrentMod = Class'Engine.Actor'.static.GetModMgr().m_pCurrentMod;
	_GRI = R6GameReplicationInfo(gameRepInfo);
	i = 0;
	J0x32:

	// End:0x5DA [Loop If]
	if((i < pCurrentMod.m_aDescriptionPackage.Length))
	{
		WeaponClass = Class<R6Description>(GetFirstPackageClass((pCurrentMod.m_aDescriptionPackage[i] $ ".u"), Class'R6Description.R6Description'));
		_iCount = 0;
		J0x7F:

		// End:0x13B [Loop If]
		if(((_iCount < 32) && (_GRI.m_szSubMachineGunsRes[_iCount] != "")))
		{
			_bFound = false;
			J0xB0:

			// End:0x123 [Loop If]
			if(((WeaponClass != none) && (_bFound == false)))
			{
				// End:0x112
				if((WeaponClass.default.m_NameID == _GRI.m_szSubMachineGunsRes[_iCount]))
				{
					pServerOptions.RestrictedSubMachineGuns[_iCount] = WeaponClass;
					_bFound = true;
				}
				WeaponClass = Class<R6Description>(GetNextClass());
				// [Loop Continue]
				goto J0xB0;
			}
			WeaponClass = Class<R6Description>(RewindToFirstClass());
			(_iCount++);
			// [Loop Continue]
			goto J0x7F;
		}
		_iCount = 0;
		J0x142:

		// End:0x1FE [Loop If]
		if(((_iCount < 32) && (_GRI.m_szShotGunRes[_iCount] != "")))
		{
			_bFound = false;
			J0x173:

			// End:0x1E6 [Loop If]
			if(((WeaponClass != none) && (_bFound == false)))
			{
				// End:0x1D5
				if((WeaponClass.default.m_NameID == _GRI.m_szShotGunRes[_iCount]))
				{
					pServerOptions.RestrictedShotGuns[_iCount] = WeaponClass;
					_bFound = true;
				}
				WeaponClass = Class<R6Description>(GetNextClass());
				// [Loop Continue]
				goto J0x173;
			}
			WeaponClass = Class<R6Description>(RewindToFirstClass());
			(_iCount++);
			// [Loop Continue]
			goto J0x142;
		}
		_iCount = 0;
		J0x205:

		// End:0x2C1 [Loop If]
		if(((_iCount < 32) && (_GRI.m_szAssRifleRes[_iCount] != "")))
		{
			_bFound = false;
			J0x236:

			// End:0x2A9 [Loop If]
			if(((WeaponClass != none) && (_bFound == false)))
			{
				// End:0x298
				if((WeaponClass.default.m_NameID == _GRI.m_szAssRifleRes[_iCount]))
				{
					pServerOptions.RestrictedAssultRifles[_iCount] = WeaponClass;
					_bFound = true;
				}
				WeaponClass = Class<R6Description>(GetNextClass());
				// [Loop Continue]
				goto J0x236;
			}
			WeaponClass = Class<R6Description>(RewindToFirstClass());
			(_iCount++);
			// [Loop Continue]
			goto J0x205;
		}
		_iCount = 0;
		J0x2C8:

		// End:0x384 [Loop If]
		if(((_iCount < 32) && (_GRI.m_szMachGunRes[_iCount] != "")))
		{
			_bFound = false;
			J0x2F9:

			// End:0x36C [Loop If]
			if(((WeaponClass != none) && (_bFound == false)))
			{
				// End:0x35B
				if((WeaponClass.default.m_NameID == _GRI.m_szMachGunRes[_iCount]))
				{
					pServerOptions.RestrictedMachineGuns[_iCount] = WeaponClass;
					_bFound = true;
				}
				WeaponClass = Class<R6Description>(GetNextClass());
				// [Loop Continue]
				goto J0x2F9;
			}
			WeaponClass = Class<R6Description>(RewindToFirstClass());
			(_iCount++);
			// [Loop Continue]
			goto J0x2C8;
		}
		_iCount = 0;
		J0x38B:

		// End:0x447 [Loop If]
		if(((_iCount < 32) && (_GRI.m_szSnipRifleRes[_iCount] != "")))
		{
			_bFound = false;
			J0x3BC:

			// End:0x42F [Loop If]
			if(((WeaponClass != none) && (_bFound == false)))
			{
				// End:0x41E
				if((WeaponClass.default.m_NameID == _GRI.m_szSnipRifleRes[_iCount]))
				{
					pServerOptions.RestrictedSniperRifles[_iCount] = WeaponClass;
					_bFound = true;
				}
				WeaponClass = Class<R6Description>(GetNextClass());
				// [Loop Continue]
				goto J0x3BC;
			}
			WeaponClass = Class<R6Description>(RewindToFirstClass());
			(_iCount++);
			// [Loop Continue]
			goto J0x38B;
		}
		_iCount = 0;
		J0x44E:

		// End:0x50A [Loop If]
		if(((_iCount < 32) && (_GRI.m_szPistolRes[_iCount] != "")))
		{
			_bFound = false;
			J0x47F:

			// End:0x4F2 [Loop If]
			if(((WeaponClass != none) && (_bFound == false)))
			{
				// End:0x4E1
				if((WeaponClass.default.m_NameID == _GRI.m_szPistolRes[_iCount]))
				{
					pServerOptions.RestrictedPistols[_iCount] = WeaponClass;
					_bFound = true;
				}
				WeaponClass = Class<R6Description>(GetNextClass());
				// [Loop Continue]
				goto J0x47F;
			}
			WeaponClass = Class<R6Description>(RewindToFirstClass());
			(_iCount++);
			// [Loop Continue]
			goto J0x44E;
		}
		_iCount = 0;
		J0x511:

		// End:0x5CD [Loop If]
		if(((_iCount < 32) && (_GRI.m_szMachPistolRes[_iCount] != "")))
		{
			_bFound = false;
			J0x542:

			// End:0x5B5 [Loop If]
			if(((WeaponClass != none) && (_bFound == false)))
			{
				// End:0x5A4
				if((WeaponClass.default.m_NameID == _GRI.m_szMachPistolRes[_iCount]))
				{
					pServerOptions.RestrictedMachinePistols[_iCount] = WeaponClass;
					_bFound = true;
				}
				WeaponClass = Class<R6Description>(GetNextClass());
				// [Loop Continue]
				goto J0x542;
			}
			WeaponClass = Class<R6Description>(RewindToFirstClass());
			(_iCount++);
			// [Loop Continue]
			goto J0x511;
		}
		FreePackageObjects();
		(i++);
		// [Loop Continue]
		goto J0x32;
	}
	return;
}

state UWindow
{
	function BeginState()
	{
		ConsoleState = GetStateName();
		return;
	}

	function PostRender(Canvas Canvas)
	{
		local int i;

		// End:0x25
		if(m_bRenderMenuOneTime)
		{
			// End:0x1D
			if(m_bInterruptConnectionProcess)
			{
				m_bInterruptConnectionProcess = false;				
			}
			else
			{
				m_bRenderMenuOneTime = false;
			}
		}
		// End:0x209
		if(((bReturnToMenu == true) && (Root != none)))
		{
			bReturnToMenu = false;
			// End:0x57
			if(m_bInterruptConnectionProcess)
			{
				m_bRenderMenuOneTime = true;
			}
			switch(m_eNextStep)
			{
				// End:0xA9
				case 9:
					i = 0;
					J0x6A:

					// End:0x9E [Loop If]
					if((i < m_AWIDList.Length))
					{
						Root.ChangeCurrentWidget(m_AWIDList[i]);
						(i++);
						// [Loop Continue]
						goto J0x6A;
					}
					m_bChangeModInProgress = false;
					// End:0x209
					break;
				// End:0xC2
				case 0:
					Root.ChangeCurrentWidget(7);
					// End:0x209
					break;
				// End:0xDB
				case 2:
					Root.ChangeCurrentWidget(4);
					// End:0x209
					break;
				// End:0x12F
				case 1:
					// End:0x11B
					if((int(m_PlayerCampaign.m_bCampaignCompleted) == 1))
					{
						Root.ChangeCurrentWidget(18);
						Canvas.m_bDisplayGameOutroVideo = true;						
					}
					else
					{
						Root.ChangeCurrentWidget(6);
					}
					// End:0x209
					break;
				// End:0x17D
				case 3:
					// End:0x169
					if(m_bStartedByGSClient)
					{
						Root.ChangeCurrentWidget(20);
						Class'Engine.Actor'.static.GetGameManager().m_bReturnToGSClient = true;						
					}
					else
					{
						Root.ChangeCurrentWidget(15);
					}
					// End:0x209
					break;
				// End:0x196
				case 4:
					Root.ChangeCurrentWidget(11);
					// End:0x209
					break;
				// End:0x1AF
				case 5:
					Root.ChangeCurrentWidget(14);
					// End:0x209
					break;
				// End:0x1C8
				case 6:
					Root.ChangeCurrentWidget(10);
					// End:0x209
					break;
				// End:0x1E1
				case 7:
					Root.ChangeCurrentWidget(38);
					// End:0x209
					break;
				// End:0x206
				case 8:
					Class'Engine.Actor'.static.GarbageCollect();
					Root.ChangeCurrentWidget(36);
					// End:0x209
					break;
				// End:0xFFFF
				default:
					break;
			}
		}
		else
		{
			// End:0x2BA
			if(((bLaunchWasCalled == true) && (m_bSkipAFrameAndStart == false)))
			{
				// End:0x2A3
				if(bResetLevel)
				{
					ViewportOwner.Actor.Level.SetBankSound(0);
					R6GameInfo(ViewportOwner.Actor.Level.Game).RestartGameMgr();
					StartR6Game(bResetLevel);
					Root.ChangeCurrentWidget(0);
					bResetLevel = false;					
				}
				else
				{
					StartR6Game(bResetLevel);
				}
				bLaunchWasCalled = false;				
			}
			else
			{
				m_bSkipAFrameAndStart = false;
				// End:0x2DE
				if((Root != none))
				{
					Root.bUWindowActive = true;
				}
				RenderUWindow(Canvas);
			}
			return;
		}
	}

	function bool KeyEvent(Interactions.EInputKey eKey, Interactions.EInputAction eAction, float fDelta)
	{
		local byte k;

		k = eKey;
		// End:0x59
		if(bShowLog)
		{
			Log(((("R6Console state Uwindow KeyEvent eAction" @ string(eAction)) @ "Key") @ string(eKey)));
		}
		switch(eAction)
		{
			// End:0x180
			case 3:
				switch(eKey)
				{
					// End:0xA1
					case 1:
						// End:0x9F
						if((Root != none))
						{
							Root.WindowEvent(1, none, MouseX, MouseY, int(k));
						}
						return true;
					// End:0xD6
					case 2:
						// End:0xD4
						if((Root != none))
						{
							Root.WindowEvent(5, none, MouseX, MouseY, int(k));
						}
						return true;
					// End:0x10B
					case 4:
						// End:0x109
						if((Root != none))
						{
							Root.WindowEvent(3, none, MouseX, MouseY, int(k));
						}
						return true;
					// End:0xFFFF
					default:
						// End:0x13C
						if((Root != none))
						{
							Root.WindowEvent(8, none, MouseX, MouseY, int(k));
						}
						// End:0x159
						if(ViewportOwner.Actor.InPlanningMode())
						{
							return false;							
						}
						else
						{
							// End:0x178
							if((Root != none))
							{
								return Root.TrapKey(false);								
							}
							else
							{
								return true;
							}
						}
						// End:0x17D
						break;
						break;
				}
				// End:0x3A3
				break;
			// End:0x349
			case 1:
				// End:0x1C4
				if((int(k) == int(ViewportOwner.Actor.GetKey("Console"))))
				{
					// End:0x1BC
					if(bLocked)
					{
						return true;
					}
					type();
					return true;
				}
				switch(k)
				{
					// End:0x200
					case 1:
						// End:0x1FE
						if((Root != none))
						{
							Root.WindowEvent(0, none, MouseX, MouseY, int(k));
						}
						return true;
					// End:0x235
					case 2:
						// End:0x233
						if((Root != none))
						{
							Root.WindowEvent(4, none, MouseX, MouseY, int(k));
						}
						return true;
					// End:0x26A
					case 4:
						// End:0x268
						if((Root != none))
						{
							Root.WindowEvent(2, none, MouseX, MouseY, int(k));
						}
						return true;
					// End:0x29F
					case 237:
						// End:0x29D
						if((Root != none))
						{
							Root.WindowEvent(6, none, MouseX, MouseY, int(k));
						}
						return true;
					// End:0x2D4
					case 236:
						// End:0x2D2
						if((Root != none))
						{
							Root.WindowEvent(7, none, MouseX, MouseY, int(k));
						}
						return true;
					// End:0xFFFF
					default:
						// End:0x305
						if((Root != none))
						{
							Root.WindowEvent(9, none, MouseX, MouseY, int(k));
						}
						// End:0x322
						if(ViewportOwner.Actor.InPlanningMode())
						{
							return false;							
						}
						else
						{
							// End:0x341
							if((Root != none))
							{
								return Root.TrapKey(false);								
							}
							else
							{
								return true;
							}
						}
						// End:0x346
						break;
						break;
				}
				// End:0x3A3
				break;
			// End:0x39D
			case 4:
				switch(k)
				{
					// End:0x376
					case 228:
						MouseX = (MouseX + (MouseScale * fDelta));
						// End:0x39A
						break;
					// End:0x397
					case 229:
						MouseY = (MouseY - (MouseScale * fDelta));
						// End:0x39A
						break;
					// End:0xFFFF
					default:
						break;
				}
				// End:0x3A3
				break;
			// End:0xFFFF
			default:
				// End:0x3A3
				break;
				break;
		}
		// End:0x3C0
		if(ViewportOwner.Actor.InPlanningMode())
		{
			return false;			
		}
		else
		{
			// End:0x3DF
			if((Root != none))
			{
				return Root.TrapKey(true);				
			}
			else
			{
				return true;
			}
		}
		return;
	}
	stop;
}

state Typing
{
	function PostRender(Canvas Canvas)
	{
		// End:0x1C
		if((Root != none))
		{
			Root.bUWindowActive = true;
		}
		RenderUWindow(Canvas);
		super.PostRender(Canvas);
		return;
	}

	function bool KeyEvent(Interactions.EInputKey Key, Interactions.EInputAction Action, float Delta)
	{
		local string temp, Temp1, FileName;
		local int i;

		// End:0x4C
		if(bShowLog)
		{
			Log(((("R6Console state Typing KeyEvent Action" @ string(Action)) @ "Key") @ string(Key)));
		}
		// End:0x64
		if((int(Action) == int(1)))
		{
			bIgnoreKeys = false;
		}
		// End:0xAB
		if(((int(Action) == int(1)) && (int(Key) == int(ViewportOwner.Actor.GetKey("Console")))))
		{
			GotoState(ConsoleState);
			return true;
		}
		// End:0xE7
		if((int(Key) == int(27)))
		{
			// End:0xDD
			if((TypedStr != ""))
			{
				TypedStr = "";
				HistoryCur = HistoryTop;				
			}
			else
			{
				GotoState(ConsoleState);
			}			
		}
		else
		{
			// End:0x3D4
			if(((int(Key) == int(13)) && (int(Action) == int(3))))
			{
				// End:0x3CA
				if((TypedStr != ""))
				{
					// End:0x212
					if((Caps(Left(TypedStr, Len("WRITESERVER"))) == "WRITESERVER"))
					{
						FileName = (("..\\" $ Class'Engine.Actor'.static.GetModMgr().GetIniFilesDir()) $ "\\");
						FileName = (FileName $ Right(TypedStr, (Len(TypedStr) - Len("WRITESERVER "))));
						// End:0x212
						if((int(Root.m_eCurWidgetInUse) == int(Root.19)))
						{
							Root.SetServerOptions();
							Class'Engine.Actor'.static.SaveServerOptions(FileName);
							Message(Localize("Errors", "SaveSuccessful", "R6Engine"), 6.0000000);
							GotoState(ConsoleState);
							return true;
						}
					}
					// End:0x23E
					if((Caps(Left(TypedStr, Len("SHOT"))) != "SHOT"))
					{
						Message(TypedStr, 6.0000000);
					}
					History[HistoryTop] = TypedStr;
					HistoryTop = int((float((HistoryTop + 1)) % float(16)));
					// End:0x29F
					if(((HistoryBot == -1) || (HistoryBot == HistoryTop)))
					{
						HistoryBot = int((float((HistoryBot + 1)) % float(16)));
					}
					HistoryCur = HistoryTop;
					temp = TypedStr;
					TypedStr = "";
					Temp1 = temp;
					J0x2C8:

					// End:0x301 [Loop If]
					if(((Len(Temp1) > 0) && (Left(Temp1, 1) == " ")))
					{
						Temp1 = Right(Temp1, (Len(Temp1) - 1));
						// [Loop Continue]
						goto J0x2C8;
					}
					// End:0x349
					if((Caps(Left(Temp1, Len("TYPE"))) == "TYPE"))
					{
						Message(Localize("Errors", "Exec", "R6Engine"), 6.0000000);						
					}
					else
					{
						// End:0x382
						if((!ConsoleCommand(temp)))
						{
							Message(Localize("Errors", "Exec", "R6Engine"), 6.0000000);
						}
					}
					Message("", 6.0000000);
					// End:0x3B5
					if((Caps(Left(temp, Len("SHOT"))) == "SHOT"))
					{
						GotoState(ConsoleState);						
					}
					else
					{
						// End:0x3C7
						if((!bShowConsoleLog))
						{
							GotoState(ConsoleState);
						}
					}					
				}
				else
				{
					GotoState(ConsoleState);
				}				
			}
			else
			{
				// End:0x3E9
				if((int(Action) == int(3)))
				{
					return true;					
				}
				else
				{
					// End:0x452
					if((int(Key) == int(38)))
					{
						// End:0x44F
						if((HistoryBot >= 0))
						{
							// End:0x421
							if((HistoryCur == HistoryBot))
							{
								HistoryCur = HistoryTop;								
							}
							else
							{
								(HistoryCur--);
								// End:0x43E
								if((HistoryCur < 0))
								{
									HistoryCur = (16 - 1);
								}
							}
							TypedStr = History[HistoryCur];
						}						
					}
					else
					{
						// End:0x4B6
						if((int(Key) == int(40)))
						{
							// End:0x4B3
							if((HistoryBot >= 0))
							{
								// End:0x48A
								if((HistoryCur == HistoryTop))
								{
									HistoryCur = HistoryBot;									
								}
								else
								{
									HistoryCur = int((float((HistoryCur + 1)) % float(16)));
								}
								TypedStr = History[HistoryCur];
							}							
						}
						else
						{
							// End:0x504
							if(((int(Key) == int(8)) || (int(Key) == int(37))))
							{
								m_bStringIsTooLong = false;
								// End:0x504
								if((Len(TypedStr) > 0))
								{
									TypedStr = Left(TypedStr, (Len(TypedStr) - 1));
								}
							}
						}
					}
				}
			}
		}
		return true;
		return;
	}
	stop;
}

state Game
{
	function BeginState()
	{
		// End:0x28
		if(bShowLog)
		{
			Log("R6Console  Game::BeginState");
		}
		bCancelFire = true;
		ConsoleState = GetStateName();
		return;
	}

	function PostRender(Canvas Canvas)
	{
		// End:0x27
		if((Root != none))
		{
			Root.bUWindowActive = true;
			RenderUWindow(Canvas);
		}
		return;
	}

	function EndState()
	{
		// End:0x26
		if(bShowLog)
		{
			Log("R6Console  Game::EndState");
		}
		// End:0xE1
		if((ViewportOwner.Actor != none))
		{
			// End:0x7E
			if((R6PlayerController(ViewportOwner.Actor) != none))
			{
				// End:0x7E
				if((bCancelFire == true))
				{
					R6PlayerController(ViewportOwner.Actor).bFire = 0;
				}
			}
			// End:0xE1
			if((ViewportOwner.Actor.Level != none))
			{
				ViewportOwner.Actor.Level.m_bInGamePlanningZoomingIn = false;
				ViewportOwner.Actor.Level.m_bInGamePlanningZoomingOut = false;
			}
		}
		return;
	}

	function bool KeyEvent(Interactions.EInputKey eKey, Interactions.EInputAction eAction, float fDelta)
	{
		local byte k;
		local int i;

		k = eKey;
		// End:0x56
		if(bShowLog)
		{
			Log(((("R6Console state Game KeyEvent eAction" @ string(eAction)) @ "Key") @ string(eKey)));
		}
		// End:0x720
		if((!bTyping))
		{
			// End:0x414
			if(((ViewportOwner.Actor != none) && (!ViewportOwner.Actor.IsInState('Dead'))))
			{
				switch(eAction)
				{
					// End:0x1D2
					case 3:
						// End:0xDD
						if((int(k) == int(ViewportOwner.Actor.GetKey("ToggleMap"))))
						{
							m_bInGamePlanningKeyDown = false;
							return true;							
						}
						else
						{
							// End:0x157
							if((int(k) == int(ViewportOwner.Actor.GetKey("MapZoomIn"))))
							{
								// End:0x154
								if(ViewportOwner.Actor.Level.m_bInGamePlanningActive)
								{
									ViewportOwner.Actor.Level.m_bInGamePlanningZoomingIn = false;
									return true;
								}								
							}
							else
							{
								// End:0x1CF
								if((int(k) == int(ViewportOwner.Actor.GetKey("MapZoomOut"))))
								{
									// End:0x1CF
									if(ViewportOwner.Actor.Level.m_bInGamePlanningActive)
									{
										ViewportOwner.Actor.Level.m_bInGamePlanningZoomingOut = false;
										return true;
									}
								}
							}
						}
						// End:0x414
						break;
					// End:0x411
					case 1:
						// End:0x31C
						if((int(k) == int(ViewportOwner.Actor.GetKey("ToggleMap"))))
						{
							// End:0x2A2
							if((ViewportOwner.Actor.Level.m_bInGamePlanningActive == false))
							{
								ViewportOwner.Actor.Level.m_bInGamePlanningActive = true;
								ViewportOwner.Actor.Level.m_bInGamePlanningZoomingIn = false;
								ViewportOwner.Actor.Level.m_bInGamePlanningZoomingOut = false;
								m_bInGamePlanningKeyDown = true;
								return true;								
							}
							else
							{
								// End:0x319
								if((m_bInGamePlanningKeyDown == false))
								{
									ViewportOwner.Actor.Level.m_bInGamePlanningActive = false;
									ViewportOwner.Actor.Level.m_bInGamePlanningZoomingIn = false;
									ViewportOwner.Actor.Level.m_bInGamePlanningZoomingOut = false;
									return true;
								}
							}							
						}
						else
						{
							// End:0x396
							if((int(k) == int(ViewportOwner.Actor.GetKey("MapZoomIn"))))
							{
								// End:0x393
								if(ViewportOwner.Actor.Level.m_bInGamePlanningActive)
								{
									ViewportOwner.Actor.Level.m_bInGamePlanningZoomingIn = true;
									return true;
								}								
							}
							else
							{
								// End:0x40E
								if((int(k) == int(ViewportOwner.Actor.GetKey("MapZoomOut"))))
								{
									// End:0x40E
									if(ViewportOwner.Actor.Level.m_bInGamePlanningActive)
									{
										ViewportOwner.Actor.Level.m_bInGamePlanningZoomingOut = true;
										return true;
									}
								}
							}
						}
						// End:0x414
						break;
					// End:0xFFFF
					default:
						break;
				}
			}
			else
			{
				switch(eAction)
				{
					// End:0x555
					case 3:
						// End:0x475
						if((int(k) == int(ViewportOwner.Actor.GetKey("ShowCompleteHUD"))))
						{
							R6PlayerController(ViewportOwner.Actor).m_bShowCompleteHUD = false;
							return true;
						}
						switch(k)
						{
							// End:0x4B2
							case 1:
								// End:0x4AF
								if((Root != none))
								{
									Root.WindowEvent(1, none, MouseX, MouseY, int(k));
								}
								// End:0x552
								break;
							// End:0x4E8
							case 2:
								// End:0x4E5
								if((Root != none))
								{
									Root.WindowEvent(5, none, MouseX, MouseY, int(k));
								}
								// End:0x552
								break;
							// End:0x51E
							case 4:
								// End:0x51B
								if((Root != none))
								{
									Root.WindowEvent(3, none, MouseX, MouseY, int(k));
								}
								// End:0x552
								break;
							// End:0xFFFF
							default:
								// End:0x54F
								if((Root != none))
								{
									Root.WindowEvent(8, none, MouseX, MouseY, int(k));
								}
								// End:0x552
								break;
								break;
						}
						// End:0x720
						break;
					// End:0x6C6
					case 1:
						// End:0x591
						if((int(k) == int(ViewportOwner.Actor.GetKey("Console"))))
						{
							type();
							return true;							
						}
						else
						{
							// End:0x5E6
							if((int(k) == int(ViewportOwner.Actor.GetKey("ShowCompleteHUD"))))
							{
								R6PlayerController(ViewportOwner.Actor).m_bShowCompleteHUD = true;
								return true;
							}
						}
						switch(k)
						{
							// End:0x623
							case 1:
								// End:0x620
								if((Root != none))
								{
									Root.WindowEvent(0, none, MouseX, MouseY, int(k));
								}
								// End:0x6C3
								break;
							// End:0x659
							case 2:
								// End:0x656
								if((Root != none))
								{
									Root.WindowEvent(4, none, MouseX, MouseY, int(k));
								}
								// End:0x6C3
								break;
							// End:0x68F
							case 4:
								// End:0x68C
								if((Root != none))
								{
									Root.WindowEvent(2, none, MouseX, MouseY, int(k));
								}
								// End:0x6C3
								break;
							// End:0xFFFF
							default:
								// End:0x6C0
								if((Root != none))
								{
									Root.WindowEvent(9, none, MouseX, MouseY, int(k));
								}
								// End:0x6C3
								break;
								break;
						}
						// End:0x720
						break;
					// End:0x71A
					case 4:
						switch(k)
						{
							// End:0x6F3
							case 228:
								MouseX = (MouseX + (MouseScale * fDelta));
								// End:0x717
								break;
							// End:0x714
							case 229:
								MouseY = (MouseY - (MouseScale * fDelta));
								// End:0x717
								break;
							// End:0xFFFF
							default:
								break;
						}
						// End:0x720
						break;
					// End:0xFFFF
					default:
						// End:0x720
						break;
						break;
				}
			}/* !MISMATCHING REMOVE, tried If got Type:Else Position:0x414! */
			return false;
			return;
		}/* !MISMATCHING REMOVE, tried Else got Type:If Position:0x056! */
	}
	stop;
}

state TrainingInstruction extends UWindowCanPlay
{
	function bool KeyEvent(Interactions.EInputKey Key, Interactions.EInputAction Action, float Delta)
	{
		local byte k;

		k = Key;
		// End:0x65
		if(bShowLog)
		{
			Log(((("R6Console state TrainingInstruction KeyEvent eAction" @ string(Action)) @ "Key") @ string(Key)));
		}
		switch(Action)
		{
			// End:0xE1
			case 3:
				// End:0xDE
				if(((int(k) == int(27)) || (int(k) == int(ViewportOwner.Actor.GetKey("Action")))))
				{
					// End:0xDC
					if((Root != none))
					{
						Root.WindowEvent(8, none, MouseX, MouseY, int(k));
					}
					return true;
				}
				// End:0x189
				break;
			// End:0x183
			case 1:
				// End:0x125
				if((int(k) == int(ViewportOwner.Actor.GetKey("Console"))))
				{
					// End:0x11D
					if(bLocked)
					{
						return true;
					}
					type();
					return true;
				}
				// End:0x152
				if((int(k) == int(ViewportOwner.Actor.GetKey("Action"))))
				{
					return true;
				}
				// End:0x180
				if((Root != none))
				{
					Root.WindowEvent(9, none, MouseX, MouseY, int(k));
				}
				// End:0x189
				break;
			// End:0xFFFF
			default:
				// End:0x189
				break;
				break;
		}
		return false;
		return;
	}
	stop;
}

defaultproperties
{
	m_StopMainMenuMusic=Sound'Music.Play_theme_Musicsilence'
	RootWindow="R6Menu.R6MenuRootWindow"
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var bMultiPlayerGameActive
// REMOVED IN 1.60: var m_iRetryTime
// REMOVED IN 1.60: var m_bAutoLoginFirstPass
// REMOVED IN 1.60: var m_bJoinUbiServer
// REMOVED IN 1.60: var m_bCreateUbiServer
// REMOVED IN 1.60: var eLeaveGame
// REMOVED IN 1.60: var m_eLastPreviousWID
// REMOVED IN 1.60: function Tick
// REMOVED IN 1.60: function gg
// REMOVED IN 1.60: function GoToGame
// REMOVED IN 1.60: function GameServiceTick
// REMOVED IN 1.60: function MSClientManager
// REMOVED IN 1.60: function MinimizeAndPauseMusic
