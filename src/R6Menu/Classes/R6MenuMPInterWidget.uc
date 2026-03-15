//=============================================================================
// R6MenuMPInterWidget - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6MenuMPInterWidget.uc : Intermission widget (when you press start during MP game or 
//                           during the between round time)
//  the size of the window is 640 * 480
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/04/25 * Created  Yannick Joly
//=============================================================================
class R6MenuMPInterWidget extends R6MenuWidget;

var UWindowBase.EPopUpID m_InGameOptionsChange;
//test
var int m_Counter;
var bool m_bDisplayNavBar;  // display the Inter Bar only if you are in between round time
var bool m_bRefreshRestKit;  // refesh rest kit when you click on the button
var bool m_bForceRefreshOfGear;  // force refresh the first time this window is displaying
var bool m_bNavBarActive;
var float m_fYStartTeamBarPos;  // the Y team bar start pos
var R6MenuMPInterHeader m_pMPInterHeader;  // the intermission header menu
var R6MenuMPTeamBar m_pR6AlphaTeam;  // the alpha team bar with stats
var R6MenuMPTeamBar m_pR6BravoTeam;  // the bravo team bar with stats
var R6MenuMPTeamBar m_pR6MissionObj;  // the mission objectives in coop
var R6MenuMPInGameNavBar m_pInGameNavBar;  // the nav bar
var R6WindowPopUpBox m_pPopUpBoxCurrent;
var R6WindowPopUpBox m_pPopUpGearRoom;
var R6WindowPopUpBox m_pPopUpServerOption;  // Pop up server option menu
var R6WindowPopUpBox m_pPopUpKitRest;  // Pop up the kit restriction menu
var string m_szCurGameType;

//===================================================================================
// Create the window and all the area for displaying game information
//===================================================================================
function Created()
{
	m_fYStartTeamBarPos = (float(R6MenuInGameMultiPlayerRootWindow(OwnerWindow).m_RInterWidget.Y) + R6MenuRSLookAndFeel(LookAndFeel).GetTextHeaderSize());
	m_pMPInterHeader = R6MenuMPInterHeader(CreateWindow(Class'R6Menu.R6MenuMPInterHeader', float(R6MenuInGameMultiPlayerRootWindow(OwnerWindow).m_RInterWidget.X), m_fYStartTeamBarPos, float(R6MenuInGameMultiPlayerRootWindow(OwnerWindow).m_RInterWidget.W), 66.0000000, self));
	(m_fYStartTeamBarPos += m_pMPInterHeader.WinHeight);
	m_pR6AlphaTeam = R6MenuMPTeamBar(CreateWindow(Class'R6Menu.R6MenuMPTeamBar', 0.0000000, 0.0000000, 10.0000000, 10.0000000, self));
	m_pR6AlphaTeam.m_vTeamColor = Root.Colors.TeamColorLight[1];
	m_pR6AlphaTeam.m_szTeamName = Localize("MPInGame", "AlphaTeam", "R6Menu");
	m_pR6BravoTeam = R6MenuMPTeamBar(CreateWindow(Class'R6Menu.R6MenuMPTeamBar', 0.0000000, 0.0000000, 10.0000000, 10.0000000, self));
	m_pR6BravoTeam.m_vTeamColor = Root.Colors.TeamColorLight[0];
	m_pR6BravoTeam.m_szTeamName = Localize("MPInGame", "BravoTeam", "R6Menu");
	m_pR6MissionObj = R6MenuMPTeamBar(CreateWindow(Class'R6Menu.R6MenuMPTeamBar', 0.0000000, 0.0000000, 10.0000000, 10.0000000, self));
	m_pR6MissionObj.m_bDisplayObj = true;
	m_pInGameNavBar = R6MenuMPInGameNavBar(CreateWindow(Class'R6Menu.R6MenuMPInGameNavBar', float(R6MenuInGameMultiPlayerRootWindow(OwnerWindow).m_RInterWidget.X), 0.0000000, float(R6MenuInGameMultiPlayerRootWindow(OwnerWindow).m_RInterWidget.W), m_pMPInterHeader.WinHeight));
	m_Counter = 0;
	m_pR6AlphaTeam.InitTeamBar();
	m_pR6BravoTeam.InitTeamBar();
	m_pR6MissionObj.InitMissionWindows();
	return;
}

function Tick(float Delta)
{
	(m_Counter++);
	// End:0x1F
	if(m_bForceRefreshOfGear)
	{
		m_bForceRefreshOfGear = false;
		RefreshGearMenu(true);
	}
	// End:0x31
	if((m_Counter > 10))
	{
		RefreshServerInfo();
	}
	return;
}

//function SetInterWidgetMenu( INT _iGameType, bool _bActiveMenuBar)
function SetInterWidgetMenu(string _szCurrentGameType, bool _bActiveMenuBar)
{
	local R6MenuInGameMultiPlayerRootWindow r6Root;
	local float fXPos, fWidth, fAvailableSpace;
	local bool bActiveMenuBar;

	r6Root = R6MenuInGameMultiPlayerRootWindow(Root);
	fXPos = float(r6Root.m_RInterWidget.X);
	fWidth = float(r6Root.m_RInterWidget.W);
	fAvailableSpace = (float(r6Root.m_RInterWidget.H) - m_pMPInterHeader.WinHeight);
	m_pR6BravoTeam.HideWindow();
	m_pR6MissionObj.HideWindow();
	m_bDisplayNavBar = _bActiveMenuBar;
	m_pInGameNavBar.SetNavBarButtonsStatus(_bActiveMenuBar);
	bActiveMenuBar = true;
	// End:0xE2
	if((m_szCurGameType != _szCurrentGameType))
	{
		m_pMPInterHeader.ResetDisplayInfo();
		m_szCurGameType = _szCurrentGameType;
	}
	m_pMPInterHeader.Reset();
	// End:0x27E
	if(GetLevel().IsGameTypeTeamAdversarial(_szCurrentGameType))
	{
		m_pMPInterHeader.m_bDisplayTotVictory = true;
		m_pR6AlphaTeam.InitMenuLayout(1);
		m_pR6BravoTeam.InitMenuLayout(1);
		// End:0x20A
		if(bActiveMenuBar)
		{
			(fAvailableSpace -= m_pInGameNavBar.WinHeight);
			m_pR6AlphaTeam.SetWindowSize(fXPos, m_fYStartTeamBarPos, fWidth, (fAvailableSpace * 0.5000000));
			m_pR6BravoTeam.SetWindowSize(fXPos, (m_fYStartTeamBarPos + (fAvailableSpace * 0.5000000)), fWidth, (fAvailableSpace * 0.5000000));
			m_pR6BravoTeam.ShowWindow();
			SetWindowSize(m_pInGameNavBar, fXPos, (m_fYStartTeamBarPos + fAvailableSpace), fWidth, m_pInGameNavBar.WinHeight);
			m_pInGameNavBar.ShowWindow();			
		}
		else
		{
			m_pR6AlphaTeam.SetWindowSize(fXPos, m_fYStartTeamBarPos, fWidth, (fAvailableSpace * 0.5000000));
			m_pR6BravoTeam.SetWindowSize(fXPos, (m_fYStartTeamBarPos + (fAvailableSpace * 0.5000000)), fWidth, (fAvailableSpace * 0.5000000));
			m_pR6BravoTeam.ShowWindow();
		}		
	}
	else
	{
		// End:0x34E
		if(GetLevel().IsGameTypeAdversarial(_szCurrentGameType))
		{
			m_pR6AlphaTeam.InitMenuLayout(0);
			// End:0x328
			if(bActiveMenuBar)
			{
				(fAvailableSpace -= m_pInGameNavBar.WinHeight);
				m_pR6AlphaTeam.SetWindowSize(fXPos, m_fYStartTeamBarPos, fWidth, fAvailableSpace);
				SetWindowSize(m_pInGameNavBar, fXPos, (m_fYStartTeamBarPos + fAvailableSpace), fWidth, m_pInGameNavBar.WinHeight);
				m_pInGameNavBar.ShowWindow();				
			}
			else
			{
				m_pR6AlphaTeam.SetWindowSize(fXPos, m_fYStartTeamBarPos, fWidth, fAvailableSpace);
			}			
		}
		else
		{
			// End:0x4C8
			if(GetLevel().IsGameTypeCooperative(_szCurrentGameType))
			{
				m_pMPInterHeader.m_bDisplayCoopStatus = true;
				m_pR6AlphaTeam.InitMenuLayout(1);
				// End:0x457
				if(bActiveMenuBar)
				{
					(fAvailableSpace -= m_pInGameNavBar.WinHeight);
					m_pR6AlphaTeam.SetWindowSize(fXPos, m_fYStartTeamBarPos, fWidth, (fAvailableSpace * 0.5000000));
					SetWindowSize(m_pInGameNavBar, fXPos, (m_fYStartTeamBarPos + fAvailableSpace), fWidth, m_pInGameNavBar.WinHeight);
					m_pInGameNavBar.ShowWindow();
					m_pR6MissionObj.SetWindowSize(fXPos, (m_fYStartTeamBarPos + (fAvailableSpace * 0.5000000)), fWidth, (fAvailableSpace * 0.5000000));
					m_pR6MissionObj.ShowWindow();					
				}
				else
				{
					m_pR6AlphaTeam.SetWindowSize(fXPos, m_fYStartTeamBarPos, fWidth, (fAvailableSpace * 0.5000000));
					m_pR6MissionObj.SetWindowSize(fXPos, (m_fYStartTeamBarPos + (fAvailableSpace * 0.5000000)), fWidth, (fAvailableSpace * 0.5000000));
					m_pR6MissionObj.ShowWindow();
				}
			}
		}
	}
	RefreshServerInfo();
	// End:0x4DF
	if(_bActiveMenuBar)
	{
		m_bForceRefreshOfGear = true;
	}
	return;
}

//===================================================================================
// PopUpGearMenu(): This function pop-up the gear menu with accept and cancel button
//===================================================================================
function PopUpGearMenu()
{
	// End:0xD4
	if((m_pPopUpGearRoom == none))
	{
		m_pPopUpGearRoom = R6WindowPopUpBox(CreateWindow(Class'R6Window.R6WindowPopUpBox', 0.0000000, 0.0000000, 640.0000000, 480.0000000));
		m_pPopUpGearRoom.CreateStdPopUpWindow(Localize("MPInGame", "Gear", "R6Menu"), 32.0000000, 103.0000000, 70.0000000, 434.0000000, 340.0000000);
		m_pPopUpGearRoom.CreateClientWindow(Class'R6Menu.R6MenuMPAdvGearWidget');
		m_pPopUpGearRoom.m_ePopUpID = 9;
		m_pPopUpGearRoom.bAlwaysOnTop = true;
		m_pPopUpGearRoom.m_bBGFullScreen = true;
		m_pPopUpGearRoom.Close();		
	}
	else
	{
		m_pPopUpGearRoom.ShowWindow();
		RefreshGearMenu(true);
		m_pPopUpBoxCurrent = m_pPopUpGearRoom;
	}
	return;
}

//===================================================================================
// PopUpServerOptMenu(): This function pop-up the server option menu with accept and cancel button
//===================================================================================
function PopUpServerOptMenu()
{
	// End:0xD9
	if((m_pPopUpServerOption == none))
	{
		m_pPopUpServerOption = R6WindowPopUpBox(CreateWindow(Class'R6Window.R6WindowPopUpBox', 0.0000000, 0.0000000, 640.0000000, 480.0000000));
		m_pPopUpServerOption.CreateStdPopUpWindow(Localize("MPInGame", "ServerOpt", "R6Menu"), 32.0000000, 10.0000000, 80.0000000, 620.0000000, 325.0000000);
		m_pPopUpServerOption.CreateClientWindow(Root.MenuClassDefines.ClassMPServerOption);
		m_pPopUpServerOption.m_ePopUpID = 7;
		m_pPopUpServerOption.bAlwaysOnTop = true;
		m_pPopUpServerOption.m_bBGFullScreen = true;
	}
	m_pPopUpServerOption.ShowWindow();
	R6PlayerController(GetPlayerOwner()).ServerPausePreGameRoundTime();
	m_pPopUpBoxCurrent = m_pPopUpServerOption;
	R6MenuMPCreateGameTab(m_pPopUpServerOption.m_ClientArea).RefreshServerOpt();
	return;
}

//===================================================================================
// PopUpKitRestMenu(): This function pop-up the server option menu with accept and cancel button
//===================================================================================
function PopUpKitRestMenu()
{
	local R6MenuMPRestKitMain pR6MenuMPRestKitMain;

	// End:0xF4
	if((m_pPopUpKitRest == none))
	{
		m_pPopUpKitRest = R6WindowPopUpBox(CreateWindow(Class'R6Window.R6WindowPopUpBox', 0.0000000, 0.0000000, 640.0000000, 480.0000000));
		m_pPopUpKitRest.CreateStdPopUpWindow(Localize("MPInGame", "KitRestriction", "R6Menu"), 32.0000000, 10.0000000, 70.0000000, 620.0000000, 332.0000000);
		m_pPopUpKitRest.CreateClientWindow(Class'R6Menu.R6MenuMPRestKitMain');
		m_pPopUpKitRest.m_ePopUpID = 8;
		m_pPopUpKitRest.bAlwaysOnTop = true;
		m_pPopUpKitRest.m_bBGFullScreen = true;
		pR6MenuMPRestKitMain = R6MenuMPRestKitMain(m_pPopUpKitRest.m_ClientArea);
		pR6MenuMPRestKitMain.CreateKitRestriction();
	}
	m_pPopUpKitRest.ShowWindow();
	R6PlayerController(GetPlayerOwner()).ServerPausePreGameRoundTime();
	m_pPopUpBoxCurrent = m_pPopUpKitRest;
	R6MenuMPRestKitMain(m_pPopUpKitRest.m_ClientArea).RefreshKitRest();
	return;
}

//==============================================================================
// ForceClosePopUp -  Force to close all the popup -- temporary... 
//==============================================================================
function ForceClosePopUp()
{
	// End:0x31
	if((m_pPopUpGearRoom != none))
	{
		// End:0x31
		if(m_bDisplayNavBar)
		{
			R6MenuMPAdvGearWidget(m_pPopUpGearRoom.m_ClientArea).AcceptSelection();
		}
	}
	// End:0x5D
	if((m_pPopUpBoxCurrent != none))
	{
		// End:0x5D
		if(m_pPopUpBoxCurrent.bWindowVisible)
		{
			m_pPopUpBoxCurrent.Close();
		}
	}
	return;
}

//==============================================================================
// HideWindow: When you hide this window, hide the current pop-up too
//==============================================================================
function HideWindow()
{
	ForceClosePopUp();
	super(UWindowWindow).HideWindow();
	return;
}

//==============================================================================
// PopUpBoxDone -  receive the result of the popup box  
//==============================================================================
function PopUpBoxDone(UWindowBase.MessageBoxResult Result, UWindowBase.EPopUpID _ePopUpID)
{
	// End:0x92
	if((int(Result) == int(3)))
	{
		m_InGameOptionsChange = _ePopUpID;
		switch(_ePopUpID)
		{
			// End:0x52
			case 9:
				// End:0x4F
				if((m_pPopUpGearRoom != none))
				{
					R6MenuMPAdvGearWidget(m_pPopUpGearRoom.m_ClientArea).AcceptSelection();
				}
				// End:0x8F
				break;
			// End:0x6F
			case 7:
				R6PlayerController(GetPlayerOwner()).ServerStartChangingInfo();
				// End:0x8F
				break;
			// End:0x8C
			case 8:
				R6PlayerController(GetPlayerOwner()).ServerStartChangingInfo();
				// End:0x8F
				break;
			// End:0xFFFF
			default:
				break;
		}		
	}
	else
	{
		// End:0xE9
		if((int(Result) == int(4)))
		{
			switch(_ePopUpID)
			{
				// End:0xD9
				case 9:
					// End:0xD6
					if((m_pPopUpGearRoom != none))
					{
						R6MenuMPAdvGearWidget(m_pPopUpGearRoom.m_ClientArea).CancelSelection();
					}
					// End:0xE9
					break;
				// End:0xDE
				case 7:
				// End:0xE3
				case 8:
				// End:0xFFFF
				default:
					// End:0xE9
					break;
					break;
			}
		}
	}
	R6PlayerController(GetPlayerOwner()).ServerUnPausePreGameRoundTime();
	return;
}

function SetClientServerSettings(bool _bChange)
{
	local R6MenuMPCreateGameTab pServerOpt;
	local R6MenuMPRestKitMain pKitRest;
	local bool bSetNewSettings;
	local byte _bMapCount;

	// End:0x120
	if(_bChange)
	{
		switch(m_InGameOptionsChange)
		{
			// End:0xCA
			case 7:
				pServerOpt = R6MenuMPCreateGameTab(m_pPopUpServerOption.m_ClientArea);
				bSetNewSettings = pServerOpt.SendNewServerSettings();
				bSetNewSettings = (pServerOpt.SendNewMapSettings(_bMapCount) || bSetNewSettings);
				// End:0x9F
				if(((bSetNewSettings == true) && (int(_bMapCount) == 0)))
				{
					R6PlayerController(GetPlayerOwner()).SendSettingsAndRestartServer(false, false);					
				}
				else
				{
					SetNavBarInActive(bSetNewSettings);
					R6PlayerController(GetPlayerOwner()).SendSettingsAndRestartServer(false, bSetNewSettings);
				}
				// End:0x120
				break;
			// End:0x11D
			case 8:
				pKitRest = R6MenuMPRestKitMain(m_pPopUpKitRest.m_ClientArea);
				bSetNewSettings = pKitRest.SendNewRestrictionsKit();
				R6PlayerController(GetPlayerOwner()).SendSettingsAndRestartServer(true, bSetNewSettings);
				// End:0x120
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

//==============================================================================
// RefreshServerInfo -  refresh the server info  
//==============================================================================
function RefreshServerInfo()
{
	local R6MenuInGameMultiPlayerRootWindow r6Root;

	r6Root = R6MenuInGameMultiPlayerRootWindow(Root);
	m_Counter = 0;
	// End:0xEC
	if((!r6Root.m_bPreventMenuSwitch))
	{
		// End:0xEC
		if((r6Root.m_R6GameMenuCom != none))
		{
			r6Root.m_R6GameMenuCom.RefreshMPlayerInfo();
			m_pMPInterHeader.RefreshInterHeaderInfo();
			m_pR6AlphaTeam.RefreshTeamBarInfo(int(r6Root.m_R6GameMenuCom.2));
			// End:0xC2
			if(m_pR6BravoTeam.bWindowVisible)
			{
				m_pR6BravoTeam.RefreshTeamBarInfo(int(r6Root.m_R6GameMenuCom.3));
			}
			// End:0xEC
			if(m_pR6MissionObj.bWindowVisible)
			{
				m_pR6MissionObj.m_pMissionObj.UpdateObjectives();
			}
		}
	}
	// End:0x1D3
	if((m_pPopUpBoxCurrent != none))
	{
		// End:0x1CB
		if(m_pPopUpBoxCurrent.bWindowVisible)
		{
			// End:0x170
			if((int(m_pPopUpBoxCurrent.m_ePopUpID) == int(8)))
			{
				// End:0x150
				if(m_bRefreshRestKit)
				{
					m_bRefreshRestKit = false;
					R6MenuMPRestKitMain(m_pPopUpKitRest.m_ClientArea).RefreshKitRest();
				}
				R6MenuMPRestKitMain(m_pPopUpKitRest.m_ClientArea).Refresh();				
			}
			else
			{
				// End:0x1A9
				if((int(m_pPopUpBoxCurrent.m_ePopUpID) == int(7)))
				{
					R6MenuMPCreateGameTab(m_pPopUpServerOption.m_ClientArea).Refresh();					
				}
				else
				{
					// End:0x1C8
					if((int(m_pPopUpBoxCurrent.m_ePopUpID) == int(9)))
					{
						RefreshGearMenu();
					}
				}
			}			
		}
		else
		{
			m_bRefreshRestKit = true;
		}
	}
	return;
}

//==============================================================================
// RefreshGearMenu -  refresh the gear menu  
//==============================================================================
function RefreshGearMenu(optional bool _bForceUpdate)
{
	local bool bForceUpdate;

	bForceUpdate = _bForceUpdate;
	// End:0x26
	if((m_pPopUpGearRoom == none))
	{
		PopUpGearMenu();
		bForceUpdate = true;
	}
	R6MenuMPAdvGearWidget(m_pPopUpGearRoom.m_ClientArea).RefreshGearInfo(bForceUpdate);
	return;
}

function SetWindowSize(UWindowWindow _W, float _fX, float _fY, float _fW, float _fH)
{
	_W.WinTop = _fY;
	_W.WinLeft = _fX;
	_W.WinWidth = _fW;
	_W.WinHeight = _fH;
	return;
}

function SetNavBarInActive(bool _bDisable, optional bool _bError)
{
	// End:0x27
	if(_bError)
	{
		// End:0x17
		if(m_bNavBarActive)
		{
			return;			
		}
		else
		{
			m_bNavBarActive = _bDisable;
		}		
	}
	else
	{
		m_bNavBarActive = _bDisable;
	}
	m_pInGameNavBar.SetNavBarState(m_bNavBarActive);
	return;
}

//====================================================================================================
//====================================================================================================
// THOSES FUNCTIONS ARE ONLY FOR COOP MODE
//==============================================================================
// IsMissionInProgress -  Is mission is on progress  
//==============================================================================
function bool IsMissionInProgress()
{
	local R6MenuInGameMultiPlayerRootWindow r6Root;

	r6Root = R6MenuInGameMultiPlayerRootWindow(Root);
	return (int(r6Root.m_R6GameMenuCom.m_GameRepInfo.m_bRepMObjInProgress) == 1);
	return;
}

function byte GetLastMissionSuccess()
{
	local R6MenuInGameMultiPlayerRootWindow r6Root;

	r6Root = R6MenuInGameMultiPlayerRootWindow(Root);
	return r6Root.m_R6GameMenuCom.m_GameRepInfo.m_bRepLastRoundSuccess;
	return;
}

function bool IsMissionSuccess()
{
	local R6MenuInGameMultiPlayerRootWindow r6Root;

	r6Root = R6MenuInGameMultiPlayerRootWindow(Root);
	return (int(r6Root.m_R6GameMenuCom.m_GameRepInfo.m_bRepMObjSuccess) == 1);
	return;
}

