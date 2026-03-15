//=============================================================================
// R6MenuUbiComWidget - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6MenuUbiComWidget.uc : Game Main Menu when the game is start by Ubi.com
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//	Main Menu
//
//  Revision history:
//    2002/09/18 * Created by Yannick Joly
//=============================================================================
class R6MenuUbiComWidget extends R6MenuWidget;

// NEW IN 1.60
var bool m_bQueryServerInfoInProgress;
// NEW IN 1.60
var bool m_bIsACustomMod;
// NEW IN 1.60
var bool m_bIsAnOfficialMod;
var R6GSServers m_GameService;  // Manages servers from game service
var R6WindowButtonMainMenu m_ButtonQuit;
var R6WindowButtonMainMenu m_ButtonReturn;
// NEW IN 1.60
var R6MenuUbiComModsWidget m_UbiComModsWidget;
// NEW IN 1.60
var R6WindowQueryServerInfo m_pQueryServerInfo;
var string m_szIPAddress;

function Created()
{
	local float fButtonXpos, fButtonWidth, fButtonHeight, fFirstButtonYpos, fButtonOffset;

	fButtonXpos = 350.0000000;
	fButtonWidth = 250.0000000;
	fFirstButtonYpos = 225.0000000;
	fButtonOffset = 35.0000000;
	fButtonHeight = 35.0000000;
	Root.SetLoadRandomBackgroundImage("");
	m_GameService = R6Console(Root.Console).m_GameService;
	m_ButtonQuit = R6WindowButtonMainMenu(CreateControl(Class'R6Menu.R6WindowButtonMainMenu', fButtonXpos, fFirstButtonYpos, fButtonWidth, fButtonHeight, self));
	m_ButtonQuit.ToolTipString = Localize("UbiCom", "ButtonQuit", "R6Menu");
	m_ButtonQuit.Text = Localize("UbiCom", "ButtonQuit", "R6Menu");
	m_ButtonQuit.Align = 1;
	m_ButtonQuit.m_buttonFont = Root.Fonts[14];
	m_ButtonQuit.m_eButton_Action = 8;
	m_ButtonQuit.ResizeToText();
	m_ButtonReturn = R6WindowButtonMainMenu(CreateControl(Class'R6Menu.R6WindowButtonMainMenu', fButtonXpos, (fFirstButtonYpos + fButtonOffset), fButtonWidth, fButtonHeight, self));
	m_ButtonReturn.ToolTipString = Localize("UbiCom", "ButtonReturn", "R6Menu");
	m_ButtonReturn.Text = Localize("UbiCom", "ButtonReturn", "R6Menu");
	m_ButtonReturn.Align = 1;
	m_ButtonReturn.m_buttonFont = Root.Fonts[14];
	m_ButtonReturn.m_eButton_Action = 9;
	m_ButtonReturn.ResizeToText();
	m_pQueryServerInfo = R6WindowQueryServerInfo(CreateWindow(Root.MenuClassDefines.ClassQueryServerInfo, 0.0000000, 0.0000000, 640.0000000, 480.0000000, self, true));
	m_pQueryServerInfo.m_GameService = m_GameService;
	m_pQueryServerInfo.PopUpBoxCreate();
	m_pQueryServerInfo.HideWindow();
	return;
}

function Paint(Canvas C, float X, float Y)
{
	Root.PaintBackground(C, self);
	// End:0x6D
	if(m_GameService.NativeIsWaitingForGSInit())
	{
		// End:0x47
		if((!m_ButtonQuit.bWindowVisible))
		{
			m_ButtonQuit.ShowWindow();
		}
		// End:0x6A
		if((!m_ButtonReturn.bWindowVisible))
		{
			m_ButtonReturn.ShowWindow();
		}		
	}
	else
	{
		// End:0x8E
		if(m_ButtonQuit.bWindowVisible)
		{
			m_ButtonQuit.HideWindow();
		}
		// End:0xAF
		if(m_ButtonReturn.bWindowVisible)
		{
			m_ButtonReturn.HideWindow();
		}
	}
	return;
}

function ShowWindow()
{
	// End:0x42
	if((R6MenuRootWindow(Root).m_pMenuCDKeyManager != none))
	{
		R6MenuRootWindow(Root).m_pMenuCDKeyManager.SetWindowUser(Root.20, self);
	}
	Root.SetLoadRandomBackgroundImage("");
	Root.RegisterMsgWindow(self);
	super(UWindowWindow).ShowWindow();
	return;
}

// NEW IN 1.60
function HideWindow()
{
	Root.UnRegisterMsgWindow();
	super(UWindowWindow).HideWindow();
	return;
}

//===============================================================
// Tick: Overload this fct in mod to bypass CheckForGSClientStart or change empty CheckForGSClientStart 
//===============================================================
function Tick(float Delta)
{
	local R6ModMgr pModManager;
	local R6GameManager pGameMgr;
	local bool bRequestSrvInfo;

	pGameMgr = R6GameManager(Class'Engine.Actor'.static.GetGameManager());
	pModManager = Class'Engine.Actor'.static.GetModMgr();
	// End:0x46
	if(Root.Console.m_bChangeModInProgress)
	{
		return;
	}
	// End:0x353
	if((pModManager.m_szPendingModName != ""))
	{
		// End:0x2A2
		if(pGameMgr.m_bGSJoinUbiServer)
		{
			// End:0x180
			if((m_bIsAnOfficialMod || ((!pModManager.IsRavenShield()) && pModManager.IsOfficialMod(pModManager.m_pCurrentMod.m_szKeyWord))))
			{
				// End:0x175
				if((pModManager.m_szPendingModName ~= pModManager.m_pCurrentMod.m_szKeyWord))
				{
					// End:0x172
					if(pGameMgr.m_bQueryServerInfoDone)
					{
						pGameMgr.m_bGSJoinUbiServer = false;
						Log("UbiComWidget Ready to Join server");
						m_szIPAddress = m_GameService.m_szGSClientIP;
						R6MenuRootWindow(Root).m_pMenuCDKeyManager.StartCDKeyProcess(0, m_GameService.m_ClientBeacon.PreJoinInfo);
						return;
					}					
				}
				else
				{
					SwitchToAppropriateMod();
					return;
				}				
			}
			else
			{
				// End:0x222
				if(pGameMgr.m_bQueryServerInfoDone)
				{
					// End:0x21A
					if((pModManager.m_szPendingModName ~= pModManager.m_pCurrentMod.m_szKeyWord))
					{
						pGameMgr.m_bGSJoinUbiServer = false;
						m_szIPAddress = m_GameService.m_szGSClientIP;
						R6MenuRootWindow(Root).m_pMenuCDKeyManager.StartCDKeyProcess(0, m_GameService.m_ClientBeacon.PreJoinInfo);						
					}
					else
					{
						SwitchToAppropriateMod();
					}
					return;
				}
			}
			// End:0x23E
			if(m_bQueryServerInfoInProgress)
			{
				m_pQueryServerInfo.Manager(self);				
			}
			else
			{
				Log("UbiComWidget Join a srv query info");
				m_bQueryServerInfoInProgress = true;
				R6MenuRootWindow(Root).InitBeaconService();
				m_pQueryServerInfo.StartQueryServerInfoProcedure(self, m_GameService.m_szGSClientIP, 0);
			}			
		}
		else
		{
			// End:0x353
			if(pGameMgr.NativeInit())
			{
				// End:0x330
				if((pModManager.m_szPendingModName ~= pModManager.m_pCurrentMod.m_szKeyWord))
				{
					Root.Console.ViewportOwner.Actor.PlaySound(Sound'Music.Play_theme_Musicsilence', 5);
					Root.ChangeCurrentWidget(19);
					R6MenuRootWindow(Root).InitBeaconService();
					return;
				}
				// End:0x34D
				if(m_bIsACustomMod)
				{
					Root.ChangeCurrentWidget(21);					
				}
				else
				{
					SwitchToAppropriateMod();
				}
			}
		}
	}
	return;
}

// NEW IN 1.60
function bool SwitchToAppropriateMod()
{
	local array<UWindowRootWindow.eGameWidgetID> AWIDList;
	local R6ModMgr pModManager;
	local string szTemp;
	local int i;
	local bool bModExist;

	// End:0x1B9
	if((m_bIsAnOfficialMod || m_bIsACustomMod))
	{
		pModManager = Class'Engine.Actor'.static.GetModMgr();
		bModExist = false;
		i = 0;
		J0x35:

		// End:0x90 [Loop If]
		if((i < pModManager.m_aMods.Length))
		{
			// End:0x86
			if((pModManager.m_aMods[i].m_szKeyWord ~= pModManager.m_szPendingModName))
			{
				bModExist = true;
			}
			(++i);
			// [Loop Continue]
			goto J0x35;
		}
		// End:0x10E
		if(bModExist)
		{
			pModManager.SetCurrentMod(pModManager.m_szPendingModName, GetLevel(), true, Root.Console, GetPlayerOwner().XLevel);
			AWIDList[AWIDList.Length] = 20;
			R6Console(Root.Console).CleanAndChangeMod(AWIDList);			
		}
		else
		{
			szTemp = Localize("MultiPlayer", "PopUp_Error_InvalidMod", "R6Menu");
			R6MenuRootWindow(Root).SimplePopUp(Localize("MultiPlayer", "Popup_Error_Title", "R6Menu"), (pModManager.m_szPendingModName @ szTemp), 36, int(2), false, self);
			m_bIsAnOfficialMod = false;
			m_bIsACustomMod = false;
		}		
	}
	else
	{
		bModExist = true;
	}
	return bModExist;
	return;
}

// NEW IN 1.60
function ProcessGSMsg(string _szMsg)
{
	switch(_szMsg)
	{
		// End:0x23
		case "IsACustomMod":
			m_bIsACustomMod = true;
			// End:0x5A
			break;
		// End:0x42
		case "IsAnOfficialMod":
			m_bIsAnOfficialMod = true;
			// End:0x5A
			break;
		// End:0x54
		case "IsRavenShield":
		// End:0xFFFF
		default:
			// End:0x5A
			break;
			break;
	}
	return;
}

function SendMessage(UWindowWindow.eR6MenuWidgetMessage eMessage)
{
	local R6WindowUbiCDKeyCheck.eJoinRoomChoice eJoinRoom;
	local bool bRoomValid;
	local string _szIPAddress;

	switch(eMessage)
	{
		// End:0x61
		case 8:
			m_bQueryServerInfoInProgress = false;
			Class'Engine.Actor'.static.GetModMgr().m_szPendingModName = m_GameService.m_ClientBeacon.PreJoinInfo.szPreJoinModName;
			Class'Engine.Actor'.static.GetGameManager().m_bQueryServerInfoDone = true;
			// End:0x9F
			break;
		// End:0x84
		case 9:
			m_bQueryServerInfoInProgress = false;
			Class'Engine.Actor'.static.GetGameManager().RemoveFromIDList();
			// End:0x9F
			break;
		// End:0xFFFF
		default:
			Log("Msg not supported");
			// End:0x9F
			break;
			break;
	}
	return;
}

//==============================================================================
// PromptConnectionError -  A connection error has occured, put up a pop
// up menu.
//==============================================================================
function PromptConnectionError()
{
	local R6MenuRootWindow r6Root;
	local string szTemp;

	r6Root = R6MenuRootWindow(Root);
	r6Root.m_RSimplePopUp.X = 140;
	r6Root.m_RSimplePopUp.Y = 170;
	r6Root.m_RSimplePopUp.W = 360;
	r6Root.m_RSimplePopUp.H = 77;
	// End:0x1AD
	if((R6Console(Root.Console).m_szLastError != ""))
	{
		szTemp = Localize("Multiplayer", R6Console(Root.Console).m_szLastError, "R6Menu", true);
		// End:0x113
		if((szTemp == ""))
		{
			szTemp = Localize("Errors", R6Console(Root.Console).m_szLastError, "R6Engine", true);
		}
		// End:0x141
		if((szTemp == ""))
		{
			szTemp = R6Console(Root.Console).m_szLastError;
		}
		r6Root.SimplePopUp(Localize("MultiPlayer", "Popup_Error_Title", "R6Menu"), szTemp, 24, int(2), false, self);
		R6Console(Root.Console).m_szLastError = "";		
	}
	else
	{
		r6Root.SimplePopUp(Localize("MultiPlayer", "Popup_Error_Title", "R6Menu"), Localize("MultiPlayer", "Popup_ConnectionError", "R6Menu"), 24, int(2), false, self);
	}
	return;
}

//==============================================================================
// PopUpBoxDone -  receive the result of the popup box  
//==============================================================================
function PopUpBoxDone(UWindowBase.MessageBoxResult Result, UWindowBase.EPopUpID _ePopUpID)
{
	R6WindowRootWindow(Root).m_RSimplePopUp = R6WindowRootWindow(Root).default.m_RSimplePopUp;
	Class'Engine.Actor'.static.GetGameManager().RemoveFromIDList();
	return;
}

//==============================================================================
// Notify -  Called when the player presses on a button (quit or return).
//==============================================================================
function Notify(UWindowDialogControl C, byte E)
{
	// End:0x6A
	if(C.IsA('R6WindowButtonMainMenu'))
	{
		// End:0x6A
		if((int(E) == 2))
		{
			// End:0x43
			if((C == m_ButtonQuit))
			{
				Root.DoQuitGame();				
			}
			else
			{
				// End:0x6A
				if((C == m_ButtonReturn))
				{
					Class'Engine.Actor'.static.GetGameManager().m_bReturnToGSClient = true;
				}
			}
		}
	}
	return;
}


// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var m_pCDKeyCheckWindow
// REMOVED IN 1.60: var m_bPreJoinInProgress
// REMOVED IN 1.60: var m_bChangeMap
// REMOVED IN 1.60: function JoinServer
// REMOVED IN 1.60: function CheckForGSClientStart
