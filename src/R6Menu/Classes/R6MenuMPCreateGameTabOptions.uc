//=============================================================================
// R6MenuMPCreateGameTabOptions - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6MenuMPCreateGameTabOptions.uc : 
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2003/07/11  * Create by Yannick Joly
//=============================================================================
class R6MenuMPCreateGameTabOptions extends R6MenuMPCreateGameTab;

var bool m_bBkpCamFadeToBk;
var bool m_bBkpCamFirstPerson;
var bool m_bBkpCamThirdPerson;
var bool m_bBkpCamFreeThirdP;
var bool m_bBkpCamGhost;
var bool m_bBkpCamTeamOnly;
var bool m_bBkpTKPenalty;
// OPTIONS TAB
var R6WindowTextLabelExt m_pOptionsText;
var R6WindowComboControl m_pOptionsGameMode;  // the current game mode selection
var R6WindowEditControl m_pServerNameEdit;
var R6WindowButton m_pOptionsWelcomeMsg;
// NEW IN 1.60
var R6WindowButton m_pEditSkins;
var R6WindowPopUpBox m_pMsgOfTheDayPopUp;  // The msg of the day pop-up
// NEW IN 1.60
var R6WindowPopUpBox m_pPopUpChooseSkins;
var array<string> m_SelectedMapList;  // List of maps selected by the user
var array<string> m_SelectedModeList;  // List of game modes selected by the user
var string m_szMsgOfTheDay;

//*******************************************************************************************
// INIT
//*******************************************************************************************
function Created()
{
	super.Created();
	return;
}

function InitOptionsTab(optional bool _bInGame)
{
	local stServerGameOpt stNewSGOItem;
	local float fXOffset, fYOffset, fYStep, fWidth, fHeight, fSizeOfCounter;

	local int i;

	m_bInGame = _bInGame;
	m_pOptionsText = R6WindowTextLabelExt(CreateWindow(Class'R6Window.R6WindowTextLabelExt', 0.0000000, 0.0000000, (2.0000000 * float(310)), WinHeight, self));
	m_pOptionsText.bAlwaysBehind = true;
	m_pOptionsText.ActiveBorder(0, false);
	m_pOptionsText.ActiveBorder(1, false);
	m_pOptionsText.SetBorderParam(2, 310.0000000, 1.0000000, 1.0000000, Root.Colors.White);
	m_pOptionsText.ActiveBorder(3, false);
	m_pOptionsText.m_Font = Root.Fonts[5];
	m_pOptionsText.m_vTextColor = Root.Colors.White;
	fXOffset = 5.0000000;
	fYOffset = 5.0000000;
	fWidth = 310.0000000;
	fYStep = 17.0000000;
	m_pOptionsText.AddTextLabel(Localize("MPCreateGame", "Options_GameMode", "R6Menu"), fXOffset, fYOffset, fWidth, 0, false);
	fXOffset = ((310.0000000 * 0.5000000) + float(10));
	fYOffset = 5.0000000;
	fWidth = ((310.0000000 * 0.5000000) - float(20));
	m_pOptionsGameMode = R6WindowComboControl(CreateControl(Class'R6Window.R6WindowComboControl', fXOffset, fYOffset, fWidth, LookAndFeel.Size_ComboHeight));
	m_pOptionsGameMode.SetEditBoxTip(Localize("Tip", "Options_GameMode", "R6Menu"));
	m_pOptionsGameMode.EditBoxWidth = (m_pOptionsGameMode.WinWidth - m_pOptionsGameMode.Button.WinWidth);
	m_pOptionsGameMode.SetFont(6);
	m_pOptionsGameMode.AddItem(Caps(m_ALocGameMode[0]), string(m_ANbOfGameMode[0]));
	m_pOptionsGameMode.AddItem(Caps(m_ALocGameMode[1]), string(m_ANbOfGameMode[1]));
	fXOffset = 5.0000000;
	fWidth = ((310.0000000 - fXOffset) - float(10));
	fHeight = 15.0000000;
	// End:0x46A
	if((!R6Console(Root.Console).m_bStartedByGSClient))
	{
		(fYOffset += fYStep);
		m_pServerNameEdit = R6WindowEditControl(CreateControl(Class'R6Window.R6WindowEditControl', fXOffset, fYOffset, fWidth, fHeight, self));
		m_pServerNameEdit.SetValue("");
		m_pServerNameEdit.CreateTextLabel(Localize("MPCreateGame", "Options_ServerName", "R6Menu"), 0.0000000, 0.0000000, (fWidth * 0.5000000), fHeight);
		m_pServerNameEdit.SetEditBoxTip(Localize("Tip", "Options_ServerName", "R6Menu"));
		m_pServerNameEdit.ModifyEditBoxW(160.0000000, 0.0000000, 135.0000000, fHeight);
		m_pServerNameEdit.EditBox.MaxLength = R6Console(Root.Console).m_GameService.GetMaxUbiServerNameSize();
		m_pServerNameEdit.SetEditControlStatus(_bInGame);
		(fYOffset += fYStep);
		InitPassword(fXOffset, fYOffset, fWidth, fHeight);
	}
	(fYOffset += fYStep);
	InitAdminPassword(fXOffset, fYOffset, fWidth, fHeight);
	(fYOffset += fYStep);
	fWidth = ((310.0000000 - fXOffset) - float(10));
	fHeight = 227.0000000;
	i = 0;
	J0x4C6:

	// End:0x507 [Loop If]
	if((i < m_ANbOfGameMode.Length))
	{
		CreateListOfButtons(fXOffset, fYOffset, fWidth, fHeight, m_ANbOfGameMode[i], 1);
		(i++);
		// [Loop Continue]
		goto J0x4C6;
	}
	fXOffset = (5.0000000 + float(310));
	fYOffset = 180.0000000;
	fHeight = 100.0000000;
	// End:0x582
	if(m_bInGame)
	{
		i = 0;
		J0x541:

		// End:0x582 [Loop If]
		if((i < m_ANbOfGameMode.Length))
		{
			CreateListOfButtons(fXOffset, fYOffset, fWidth, fHeight, m_ANbOfGameMode[i], 2);
			(i++);
			// [Loop Continue]
			goto J0x541;
		}
	}
	InitAllMapList();
	// End:0x59F
	if((!_bInGame))
	{
		InitEditMsgButton();
		InitEditSkinsButton();
	}
	SetCurrentGameMode(m_ANbOfGameMode[0]);
	RefreshServerOpt();
	m_bInitComplete = true;
	return;
}

function InitPassword(float _fX, float _fY, float _fW, float _fH)
{
	local R6WindowButtonAndEditBox pButton;
	local stServerGameOpt stNewSGOItem;
	local int i;

	i = 0;
	J0x07:

	// End:0xF9 [Loop If]
	if((i < m_ANbOfGameMode.Length))
	{
		pButton = CreateButAndEditBox(_fX, _fY, _fW, _fH, Localize("MPCreateGame", "Options_Password", "R6Menu"), Localize("Tip", "Options_UsePass", "R6Menu"), Localize("Tip", "Options_UsePassEdit", "R6Menu"));
		stNewSGOItem.pGameOptList = pButton;
		stNewSGOItem.eGameMode = m_ANbOfGameMode[i];
		stNewSGOItem.eCGWindowID = 4;
		AddWindowInCreateGameArray(stNewSGOItem);
		(i++);
		// [Loop Continue]
		goto J0x07;
	}
	return;
}

function InitAdminPassword(float _fX, float _fY, float _fW, float _fH)
{
	local R6WindowButtonAndEditBox pButton;
	local stServerGameOpt stNewSGOItem;
	local int i;

	i = 0;
	J0x07:

	// End:0xFB [Loop If]
	if((i < m_ANbOfGameMode.Length))
	{
		pButton = CreateButAndEditBox(_fX, _fY, _fW, _fH, Localize("MPCreateGame", "Options_AdminPwd", "R6Menu"), Localize("Tip", "Options_AdminPwd", "R6Menu"), Localize("Tip", "Options_AdminPwdEdit", "R6Menu"));
		stNewSGOItem.pGameOptList = pButton;
		stNewSGOItem.eGameMode = m_ANbOfGameMode[i];
		stNewSGOItem.eCGWindowID = 5;
		AddWindowInCreateGameArray(stNewSGOItem);
		(i++);
		// [Loop Continue]
		goto J0x07;
	}
	return;
}

function InitAllMapList()
{
	local R6MenuMapList pMapList;
	local stServerGameOpt stNewSGOItem;
	local float fXOffset, fYOffset, fYStep, fWidth, fHeight;

	local int i;

	fXOffset = 310.0000000;
	fYOffset = 5.0000000;
	fWidth = 310.0000000;
	i = 0;
	J0x28:

	// End:0x144 [Loop If]
	if((i < m_ANbOfGameMode.Length))
	{
		// End:0x7A
		if(m_bInGame)
		{
			fHeight = 155.0000000;
			pMapList = R6MenuMapList(CreateWindow(Class'R6Menu.R6MenuMapList', fXOffset, fYOffset, fWidth, fHeight, self));			
		}
		else
		{
			fHeight = 252.0000000;
			pMapList = R6MenuMapList(CreateWindow(Class'R6Menu.R6MenuMapListExt', fXOffset, fYOffset, fWidth, fHeight, self));
		}
		pMapList.m_bInGame = m_bInGame;
		pMapList.m_szLocGameMode = Caps(m_ALocGameMode[i]);
		pMapList.m_eMyGameMode = m_ANbOfGameMode[i];
		stNewSGOItem.pGameOptList = pMapList;
		stNewSGOItem.eGameMode = m_ANbOfGameMode[i];
		stNewSGOItem.eCGWindowID = 3;
		AddWindowInCreateGameArray(stNewSGOItem);
		(i++);
		// [Loop Continue]
		goto J0x28;
	}
	return;
}

//===============================================================
// UpdateButtons: do the init of the buttons you need
//===============================================================
function UpdateButtons(Actor.EGameModeInfo _eGameMode, R6MenuMPCreateGameTab.eCreateGameWindow_ID _eCGWindowID, optional bool _bUpdateValue)
{
	local R6WindowListGeneral pTempList;
	local R6ServerInfo pServerInfo;

	pTempList = R6WindowListGeneral(GetList(_eGameMode, _eCGWindowID));
	// End:0x28
	if((pTempList == none))
	{
		return;
	}
	// End:0x43
	if(_bUpdateValue)
	{
		pServerInfo = Class'Engine.Actor'.static.GetServerOptions();
	}
	switch(_eGameMode)
	{
		// End:0x765
		case m_ANbOfGameMode[0]:
			switch(_eCGWindowID)
			{
				// End:0x5C1
				case 1:
					// End:0x310
					if(_bUpdateValue)
					{
						// End:0xD8
						if(((!R6Console(Root.Console).m_bStartedByGSClient) && (!R6Console(Root.Console).m_bNonUbiMatchMakingHost)))
						{
							m_pButtonsDef.ChangeButtonComboValue(int(9), string(pServerInfo.InternetServer), pTempList);
						}
						m_pButtonsDef.ChangeButtonCounterValue(int(1), pServerInfo.RoundsPerMatch, pTempList);
						m_pButtonsDef.ChangeButtonCounterValue(int(2), (pServerInfo.RoundTime / 60), pTempList);
						m_pButtonsDef.ChangeButtonCounterValue(int(7), pServerInfo.BetweenRoundTime, pTempList);
						m_pButtonsDef.ChangeButtonCounterValue(int(4), pServerInfo.BombTime, pTempList);
						// End:0x205
						if((!R6Console(Root.Console).m_bStartedByGSClient))
						{
							m_pButtonsDef.ChangeButtonCounterValue(int(3), pServerInfo.MaxPlayers, pTempList);
							// End:0x205
							if((!R6Console(Root.Console).m_bNonUbiMatchMakingHost))
							{
								m_pButtonsDef.ChangeButtonBoxValue(int(10), pServerInfo.DedicatedServer, pTempList);
							}
						}
						m_pButtonsDef.ChangeButtonBoxValue(int(11), pServerInfo.FriendlyFire, pTempList);
						m_pButtonsDef.ChangeButtonBoxValue(int(14), pServerInfo.TeamKillerPenalty, pTempList);
						m_pButtonsDef.ChangeButtonBoxValue(int(13), pServerInfo.Autobalance, pTempList);
						m_pButtonsDef.ChangeButtonBoxValue(int(15), pServerInfo.AllowRadar, pTempList);
						m_pButtonsDef.ChangeButtonBoxValue(int(12), pServerInfo.ShowNames, pTempList);
						m_pButtonsDef.ChangeButtonBoxValue(int(18), pServerInfo.ForceFPersonWeapon, pTempList);
						UpdateMenuOptions(int(11), pServerInfo.FriendlyFire, pTempList);						
					}
					else
					{
						// End:0x413
						if(((!R6Console(Root.Console).m_bStartedByGSClient) && (!R6Console(Root.Console).m_bNonUbiMatchMakingHost)))
						{
							m_pButtonsDef.AddButtonCombo(int(9), pTempList, self);
							m_pButtonsDef.AddItemInComboButton(int(9), Localize("MPCreateGame", "Options_ServerLocationINT", "R6Menu"), string(true), pTempList);
							m_pButtonsDef.AddItemInComboButton(int(9), Localize("MPCreateGame", "Options_ServerLocationLAN", "R6Menu"), string(false), pTempList);
						}
						m_pButtonsDef.AddButtonInt(int(1), 1, 20, 10, pTempList, self);
						m_pButtonsDef.AddButtonInt(int(2), 1, 15, 3, pTempList, self);
						m_pButtonsDef.AddButtonInt(int(7), 10, 99, 15, pTempList, self);
						m_pButtonsDef.SetButtonCounterUnlimited(int(7), true, pTempList);
						m_pButtonsDef.AddButtonInt(int(4), 30, 60, 35, pTempList, self);
						// End:0x522
						if((!R6Console(Root.Console).m_bStartedByGSClient))
						{
							m_pButtonsDef.AddButtonInt(int(3), 1, 16, 16, pTempList, self);
							// End:0x522
							if((!R6Console(Root.Console).m_bNonUbiMatchMakingHost))
							{
								m_pButtonsDef.AddButtonBool(int(10), false, pTempList, self);
							}
						}
						m_pButtonsDef.AddButtonBool(int(11), true, pTempList, self);
						m_pButtonsDef.AddButtonBool(int(14), true, pTempList, self);
						m_pButtonsDef.AddButtonBool(int(13), true, pTempList, self);
						m_pButtonsDef.AddButtonBool(int(15), true, pTempList, self);
						m_pButtonsDef.AddButtonBool(int(12), true, pTempList, self);
						m_pButtonsDef.AddButtonBool(int(18), true, pTempList, self);
					}
					// End:0x762
					break;
				// End:0x75C
				case 2:
					// End:0x6BD
					if(_bUpdateValue)
					{
						UpdateCamera(int(28), pServerInfo.CamFadeToBlack, false, pTempList);
						UpdateCamera(int(24), pServerInfo.CamFirstPerson, false, pTempList, true);
						UpdateCamera(int(25), pServerInfo.CamThirdPerson, false, pTempList, true);
						UpdateCamera(int(26), pServerInfo.CamFreeThirdP, false, pTempList, true);
						UpdateCamera(int(27), pServerInfo.CamGhost, false, pTempList, true);
						UpdateCamera(int(29), pServerInfo.CamTeamOnly, false, pTempList, true);
						UpdateCamSpecialCase(pServerInfo.CamTeamOnly, false);
						UpdateCamSpecialCase(pServerInfo.CamFadeToBlack, true);						
					}
					else
					{
						m_pButtonsDef.AddButtonBool(int(28), false, pTempList, self);
						m_pButtonsDef.AddButtonBool(int(24), true, pTempList, self);
						m_pButtonsDef.AddButtonBool(int(25), true, pTempList, self);
						m_pButtonsDef.AddButtonBool(int(26), true, pTempList, self);
						m_pButtonsDef.AddButtonBool(int(27), true, pTempList, self);
						m_pButtonsDef.AddButtonBool(int(29), true, pTempList, self);
					}
					// End:0x762
					break;
				// End:0xFFFF
				default:
					// End:0x762
					break;
					break;
			}
			// End:0xF16
			break;
		// End:0xEE9
		case m_ANbOfGameMode[1]:
			switch(_eCGWindowID)
			{
				// End:0xDE8
				case 1:
					// End:0xA35
					if(_bUpdateValue)
					{
						// End:0x7F3
						if(((!R6Console(Root.Console).m_bStartedByGSClient) && (!R6Console(Root.Console).m_bNonUbiMatchMakingHost)))
						{
							m_pButtonsDef.ChangeButtonComboValue(int(9), string(pServerInfo.InternetServer), pTempList);
						}
						m_pButtonsDef.ChangeButtonComboValue(int(23), string(pServerInfo.DiffLevel), pTempList);
						m_pButtonsDef.ChangeButtonCounterValue(int(6), pServerInfo.RoundsPerMatch, pTempList);
						m_pButtonsDef.ChangeButtonCounterValue(int(2), (pServerInfo.RoundTime / 60), pTempList);
						m_pButtonsDef.ChangeButtonCounterValue(int(7), pServerInfo.BetweenRoundTime, pTempList);
						m_pButtonsDef.ChangeButtonCounterValue(int(8), pServerInfo.NbTerro, pTempList);
						// End:0x948
						if((!R6Console(Root.Console).m_bStartedByGSClient))
						{
							m_pButtonsDef.ChangeButtonCounterValue(int(3), pServerInfo.MaxPlayers, pTempList);
							// End:0x948
							if((!R6Console(Root.Console).m_bNonUbiMatchMakingHost))
							{
								m_pButtonsDef.ChangeButtonBoxValue(int(10), pServerInfo.DedicatedServer, pTempList);
							}
						}
						m_pButtonsDef.ChangeButtonBoxValue(int(17), pServerInfo.AIBkp, pTempList);
						m_pButtonsDef.ChangeButtonBoxValue(int(16), pServerInfo.RotateMap, pTempList);
						m_pButtonsDef.ChangeButtonBoxValue(int(11), pServerInfo.FriendlyFire, pTempList);
						m_pButtonsDef.ChangeButtonBoxValue(int(15), pServerInfo.AllowRadar, pTempList);
						m_pButtonsDef.ChangeButtonBoxValue(int(12), pServerInfo.ShowNames, pTempList);
						m_pButtonsDef.ChangeButtonBoxValue(int(18), pServerInfo.ForceFPersonWeapon, pTempList);						
					}
					else
					{
						// End:0xB38
						if(((!R6Console(Root.Console).m_bStartedByGSClient) && (!R6Console(Root.Console).m_bNonUbiMatchMakingHost)))
						{
							m_pButtonsDef.AddButtonCombo(int(9), pTempList, self);
							m_pButtonsDef.AddItemInComboButton(int(9), Localize("MPCreateGame", "Options_ServerLocationINT", "R6Menu"), string(true), pTempList);
							m_pButtonsDef.AddItemInComboButton(int(9), Localize("MPCreateGame", "Options_ServerLocationLAN", "R6Menu"), string(false), pTempList);
						}
						m_pButtonsDef.AddButtonCombo(int(23), pTempList, self);
						m_pButtonsDef.AddItemInComboButton(int(23), Localize("SinglePlayer", "Difficulty1", "R6Menu"), string(1), pTempList);
						m_pButtonsDef.AddItemInComboButton(int(23), Localize("SinglePlayer", "Difficulty2", "R6Menu"), string(2), pTempList);
						m_pButtonsDef.AddItemInComboButton(int(23), Localize("SinglePlayer", "Difficulty3", "R6Menu"), string(3), pTempList);
						m_pButtonsDef.ChangeButtonComboValue(int(23), "1", pTempList);
						m_pButtonsDef.AddButtonInt(int(6), 1, 20, 10, pTempList, self);
						m_pButtonsDef.AddButtonInt(int(2), 1, 60, 3, pTempList, self);
						m_pButtonsDef.AddButtonInt(int(7), 10, 99, 15, pTempList, self);
						m_pButtonsDef.SetButtonCounterUnlimited(int(7), true, pTempList);
						m_pButtonsDef.AddButtonInt(int(8), 5, 40, 32, pTempList, self);
						// End:0xD49
						if((!R6Console(Root.Console).m_bStartedByGSClient))
						{
							m_pButtonsDef.AddButtonInt(int(3), 1, 8, 8, pTempList, self);
							// End:0xD49
							if((!R6Console(Root.Console).m_bNonUbiMatchMakingHost))
							{
								m_pButtonsDef.AddButtonBool(int(10), false, pTempList, self);
							}
						}
						m_pButtonsDef.AddButtonBool(int(17), true, pTempList, self);
						m_pButtonsDef.AddButtonBool(int(16), true, pTempList, self);
						m_pButtonsDef.AddButtonBool(int(11), true, pTempList, self);
						m_pButtonsDef.AddButtonBool(int(15), false, pTempList, self);
						m_pButtonsDef.AddButtonBool(int(12), false, pTempList, self);
						m_pButtonsDef.AddButtonBool(int(18), false, pTempList, self);
					}
					// End:0xEE6
					break;
				// End:0xEE0
				case 2:
					// End:0xE75
					if(_bUpdateValue)
					{
						UpdateCamera(int(24), pServerInfo.CamFirstPerson, false, pTempList);
						UpdateCamera(int(25), pServerInfo.CamThirdPerson, false, pTempList);
						UpdateCamera(int(26), pServerInfo.CamFreeThirdP, false, pTempList);
						UpdateCamera(int(27), pServerInfo.CamGhost, false, pTempList);						
					}
					else
					{
						m_pButtonsDef.AddButtonBool(int(24), true, pTempList, self);
						m_pButtonsDef.AddButtonBool(int(25), true, pTempList, self);
						m_pButtonsDef.AddButtonBool(int(26), true, pTempList, self);
						m_pButtonsDef.AddButtonBool(int(27), true, pTempList, self);
					}
					// End:0xEE6
					break;
				// End:0xFFFF
				default:
					// End:0xEE6
					break;
					break;
			}
			// End:0xF16
			break;
		// End:0xFFFF
		default:
			Log("UpdateButtons not a valid game mode");
			// End:0xF16
			break;
			break;
	}
	return;
}

function InitEditMsgButton()
{
	local float fXOffset, fYOffset, fWidth, fHeight;

	fXOffset = (310.0000000 + float(10));
	fYOffset = (WinHeight - float(20));
	fWidth = (310.0000000 - float(20));
	fHeight = 15.0000000;
	m_pOptionsWelcomeMsg = R6WindowButton(CreateControl(Class'R6Window.R6WindowButton', fXOffset, fYOffset, fWidth, fHeight, self));
	m_pOptionsWelcomeMsg.SetButtonBorderColor(Root.Colors.White);
	m_pOptionsWelcomeMsg.m_bDrawBorders = true;
	m_pOptionsWelcomeMsg.m_bDrawSimpleBorder = true;
	m_pOptionsWelcomeMsg.TextColor = Root.Colors.White;
	m_pOptionsWelcomeMsg.Align = 2;
	m_pOptionsWelcomeMsg.SetFont(6);
	m_pOptionsWelcomeMsg.SetText(Localize("MPCreateGame", "EditWelcomeMsg", "R6Menu"));
	m_pOptionsWelcomeMsg.ToolTipString = Localize("Tip", "EditWelcomeMsg", "R6Menu");
	m_pOptionsWelcomeMsg.m_iButtonID = int(m_pButtonsDef.38);
	return;
}

// NEW IN 1.60
function InitEditSkinsButton()
{
	m_pEditSkins = R6WindowButton(CreateControl(Class'R6Window.R6WindowButton', (310.0000000 + float(10)), 260.0000000, (310.0000000 - float(20)), 15.0000000, self));
	m_pEditSkins.SetButtonBorderColor(Root.Colors.White);
	m_pEditSkins.m_bDrawBorders = true;
	m_pEditSkins.m_bDrawSimpleBorder = true;
	m_pEditSkins.TextColor = Root.Colors.White;
	m_pEditSkins.Align = 2;
	m_pEditSkins.SetFont(6);
	m_pEditSkins.SetText(Localize("MPCreateGame", "Tab_SetSkin", "R6Menu"));
	m_pEditSkins.ToolTipString = Localize("Tip", "Tab_SetSkin", "R6Menu");
	m_pEditSkins.m_iButtonID = int(m_pButtonsDef.40);
	return;
}

// NEW IN 1.60
function UpdateSkinButton()
{
	local R6MenuMapList pMapList;

	// End:0x66
	if((!m_bInGame))
	{
		pMapList = R6MenuMapList(GetList(GetCurrentGameMode(), 3));
		// End:0x66
		if((pMapList != none))
		{
			// End:0x55
			if(pMapList.IsFinalMapListEmpty())
			{
				m_pEditSkins.bDisabled = true;				
			}
			else
			{
				m_pEditSkins.bDisabled = false;
			}
		}
	}
	return;
}

//*******************************************************************************************
// UTILITIES FUNCTIONS
//*******************************************************************************************
//==============================================================
// Create a list of strings containing the list of maps that the
// user has selected
//==============================================================
function byte FillSelectedMapList()
{
	local R6MenuMapList pCurrentMapList;

	pCurrentMapList = R6MenuMapList(GetList(GetCurrentGameMode(), 3));
	// End:0x27
	if((pCurrentMapList == none))
	{
		return 0;
	}
	return pCurrentMapList.FillGameTypeMapArray(m_SelectedMapList, m_SelectedModeList);
	return;
}

//==============================================================
// PopUpMOTDEditionBox: PopUp for the message of the day
//==============================================================
function PopUpMOTDEditionBox()
{
	local R6WindowEditBox pR6EditBoxTemp;

	// End:0x131
	if((m_pMsgOfTheDayPopUp == none))
	{
		m_pMsgOfTheDayPopUp = R6WindowPopUpBox(R6MenuMPCreateGameWidget(OwnerWindow).CreateWindow(Class'R6Window.R6WindowPopUpBox', 0.0000000, 0.0000000, 640.0000000, 480.0000000, self));
		m_pMsgOfTheDayPopUp.CreateStdPopUpWindow(Localize("MPCreateGame", "WelcomeMsg", "R6Menu"), 30.0000000, 75.0000000, 150.0000000, 490.0000000, 70.0000000);
		m_pMsgOfTheDayPopUp.CreateClientWindow(Class'R6Window.R6WindowEditBox');
		m_pMsgOfTheDayPopUp.m_ePopUpID = 1;
		pR6EditBoxTemp = R6WindowEditBox(m_pMsgOfTheDayPopUp.m_ClientArea);
		pR6EditBoxTemp.SetValue(m_szMsgOfTheDay);
		pR6EditBoxTemp.TextColor = Root.Colors.BlueLight;
		pR6EditBoxTemp.SetFont(8);
		pR6EditBoxTemp.MaxLength = 60;		
	}
	else
	{
		pR6EditBoxTemp = R6WindowEditBox(m_pMsgOfTheDayPopUp.m_ClientArea);
		pR6EditBoxTemp.SetValue(m_szMsgOfTheDay);
		m_pMsgOfTheDayPopUp.ShowWindow();
	}
	return;
}

// NEW IN 1.60
function PopUpSetSkins()
{
	local R6MenuSkinsSelection pSkinsSelector;

	// End:0xBD
	if((m_pPopUpChooseSkins == none))
	{
		m_pPopUpChooseSkins = R6WindowPopUpBox(R6MenuMPCreateGameWidget(OwnerWindow).CreateWindow(Class'R6Window.R6WindowPopUpBox', 0.0000000, 0.0000000, 640.0000000, 480.0000000, self));
		m_pPopUpChooseSkins.CreateStdPopUpWindow(Localize("MultiPlayer", "Popup_SetSkin", "R6Menu"), 30.0000000, 75.0000000, 50.0000000, 490.0000000, 350.0000000);
		m_pPopUpChooseSkins.CreateClientWindow(Class'R6Menu.R6MenuSkinsSelection', false, true);
		m_pPopUpChooseSkins.m_ePopUpID = 38;
	}
	pSkinsSelector = R6MenuSkinsSelection(m_pPopUpChooseSkins.m_ClientArea);
	pSkinsSelector.CopyAllValues(R6MenuMapListExt(GetList(GetCurrentGameMode(), 3)));
	m_pPopUpChooseSkins.ShowWindow();
	return;
}

//==============================================================
// PopUpBoxDone: For now, we just receive the result of the message of the day pop-up
//==============================================================
function PopUpBoxDone(UWindowBase.MessageBoxResult Result, UWindowBase.EPopUpID _ePopUpID)
{
	local R6MenuSkinsSelection pSkinsSelector;
	local R6MenuMapListExt pTempMapList;

	// End:0xB1
	if((int(Result) == int(3)))
	{
		// End:0x4C
		if((int(_ePopUpID) == int(1)))
		{
			m_szMsgOfTheDay = R6WindowEditBox(m_pMsgOfTheDayPopUp.m_ClientArea).GetValue();
			SetServerOptions();			
		}
		else
		{
			// End:0xB1
			if((int(_ePopUpID) == int(38)))
			{
				pSkinsSelector = R6MenuSkinsSelection(m_pPopUpChooseSkins.m_ClientArea);
				pTempMapList = R6MenuMapListExt(GetList(GetCurrentGameMode(), 3));
				pSkinsSelector.GetAllValues(pTempMapList);
				pTempMapList.SetAllArmor();
			}
		}
	}
	return;
}

//==============================================================
// IsAdminPasswordValid: Verify if you check the box and if your password is different of nothing
//==============================================================
function bool IsAdminPasswordValid()
{
	local R6WindowButtonAndEditBox pAdminPassword;

	pAdminPassword = R6WindowButtonAndEditBox(GetList(GetCurrentGameMode(), 5));
	// End:0x4C
	if(pAdminPassword.m_bSelected)
	{
		// End:0x4C
		if((pAdminPassword.m_pEditBox.GetValue() == ""))
		{
			return false;
		}
	}
	return true;
	return;
}

//==============================================================
// GetCreateGamePassword: get the create game password 
//==============================================================
function string GetCreateGamePassword()
{
	return R6WindowButtonAndEditBox(GetList(GetCurrentGameMode(), 4)).m_pEditBox.GetValue();
	return;
}

function UpdateCamera(int _iButtonID, bool _bValue, bool _bDisable, R6WindowListGeneral _pCamList, optional bool _bBackupValue)
{
	switch(_iButtonID)
	{
		// End:0x30
		case int(28):
			m_pButtonsDef.ChangeButtonBoxValue(_iButtonID, _bValue, _pCamList);
			// End:0x18C
			break;
		// End:0x75
		case int(24):
			m_pButtonsDef.ChangeButtonBoxValue(_iButtonID, _bValue, _pCamList, _bDisable);
			// End:0x72
			if(_bBackupValue)
			{
				m_bBkpCamFirstPerson = _bValue;
			}
			// End:0x18C
			break;
		// End:0xBA
		case int(25):
			m_pButtonsDef.ChangeButtonBoxValue(_iButtonID, _bValue, _pCamList, _bDisable);
			// End:0xB7
			if(_bBackupValue)
			{
				m_bBkpCamThirdPerson = _bValue;
			}
			// End:0x18C
			break;
		// End:0xFF
		case int(26):
			m_pButtonsDef.ChangeButtonBoxValue(_iButtonID, _bValue, _pCamList, _bDisable);
			// End:0xFC
			if(_bBackupValue)
			{
				m_bBkpCamFreeThirdP = _bValue;
			}
			// End:0x18C
			break;
		// End:0x144
		case int(27):
			m_pButtonsDef.ChangeButtonBoxValue(_iButtonID, _bValue, _pCamList, _bDisable);
			// End:0x141
			if(_bBackupValue)
			{
				m_bBkpCamGhost = _bValue;
			}
			// End:0x18C
			break;
		// End:0x189
		case int(29):
			m_pButtonsDef.ChangeButtonBoxValue(_iButtonID, _bValue, _pCamList, _bDisable);
			// End:0x186
			if(_bBackupValue)
			{
				m_bBkpCamTeamOnly = _bValue;
			}
			// End:0x18C
			break;
		// End:0xFFFF
		default:
			break;
	}
	return;
}

//=====================================================================================
// GetCameraSelection: return the current selection of the button. This function exist because when the button
//						is disable the selection is store in the bkp version
//=====================================================================================
function bool GetCameraSelection(int _iButtonID, R6WindowListGeneral _pCameraList)
{
	local bool bSelection;

	// End:0x9C
	if(m_pButtonsDef.IsButtonBoxDisabled(_iButtonID, _pCameraList))
	{
		switch(_iButtonID)
		{
			// End:0x3A
			case int(24):
				bSelection = m_bBkpCamFirstPerson;
				// End:0x99
				break;
			// End:0x51
			case int(25):
				bSelection = m_bBkpCamThirdPerson;
				// End:0x99
				break;
			// End:0x68
			case int(26):
				bSelection = m_bBkpCamFreeThirdP;
				// End:0x99
				break;
			// End:0x7F
			case int(27):
				bSelection = m_bBkpCamGhost;
				// End:0x99
				break;
			// End:0x96
			case int(29):
				bSelection = m_bBkpCamTeamOnly;
				// End:0x99
				break;
			// End:0xFFFF
			default:
				break;
		}		
	}
	else
	{
		bSelection = m_pButtonsDef.GetButtonBoxValue(_iButtonID, _pCameraList);
	}
	return bSelection;
	return;
}

//==========================================================================
// UpdateCamSpecialCase:  For death cam and cam teamonly only
//==========================================================================
function UpdateCamSpecialCase(bool _bButtonSel, bool _bUpdateDeathCam)
{
	local bool bCamState, bCamFirstPerson, bCamThirdPerson, bCamFreeThPerson, bCamGhost, bCanTeamOnly,
		bCamGhostDis;

	local R6WindowListGeneral pCamList;

	// End:0x0D
	if((!m_bInGame))
	{
		return;
	}
	pCamList = R6WindowListGeneral(GetList(GetCurrentGameMode(), 2));
	// End:0x27B
	if(_bUpdateDeathCam)
	{
		bCamState = _bButtonSel;
		bCamFirstPerson = false;
		bCamThirdPerson = false;
		bCamFreeThPerson = false;
		bCamGhost = false;
		bCanTeamOnly = false;
		// End:0x14B
		if(bCamState)
		{
			m_bBkpCamFirstPerson = m_pButtonsDef.GetButtonBoxValue(int(24), pCamList);
			m_bBkpCamThirdPerson = m_pButtonsDef.GetButtonBoxValue(int(25), pCamList);
			m_bBkpCamFreeThirdP = m_pButtonsDef.GetButtonBoxValue(int(26), pCamList);
			bCamGhostDis = m_pButtonsDef.IsButtonBoxDisabled(int(27), pCamList);
			// End:0x113
			if((!bCamGhostDis))
			{
				m_bBkpCamGhost = m_pButtonsDef.GetButtonBoxValue(int(27), pCamList);
			}
			// End:0x148
			if((int(GetCurrentGameMode()) == int(m_ANbOfGameMode[0])))
			{
				m_bBkpCamTeamOnly = m_pButtonsDef.GetButtonBoxValue(int(29), pCamList);
			}			
		}
		else
		{
			bCamFirstPerson = m_bBkpCamFirstPerson;
			bCamThirdPerson = m_bBkpCamThirdPerson;
			bCamFreeThPerson = m_bBkpCamFreeThirdP;
			bCamGhost = m_bBkpCamGhost;
			// End:0x1A5
			if((int(GetCurrentGameMode()) == int(m_ANbOfGameMode[0])))
			{
				bCamGhostDis = m_bBkpCamTeamOnly;				
			}
			else
			{
				bCamGhostDis = false;
			}
			bCanTeamOnly = m_bBkpCamTeamOnly;
		}
		UpdateCamera(int(28), bCamState, false, pCamList);
		UpdateCamera(int(24), bCamFirstPerson, bCamState, pCamList);
		UpdateCamera(int(25), bCamThirdPerson, bCamState, pCamList);
		UpdateCamera(int(26), bCamFreeThPerson, bCamState, pCamList);
		// End:0x247
		if((!bCamGhostDis))
		{
			UpdateCamera(int(27), bCamGhost, bCamState, pCamList);
		}
		// End:0x278
		if((int(GetCurrentGameMode()) == int(m_ANbOfGameMode[0])))
		{
			UpdateCamera(int(29), bCanTeamOnly, bCamState, pCamList);
		}		
	}
	else
	{
		bCamState = _bButtonSel;
		bCamGhost = false;
		// End:0x2BB
		if(bCamState)
		{
			m_bBkpCamGhost = m_pButtonsDef.GetButtonBoxValue(int(27), pCamList);			
		}
		else
		{
			bCamGhost = m_bBkpCamGhost;
		}
		UpdateCamera(int(27), bCamGhost, bCamState, pCamList);
	}
	return;
}

function UpdateMenuOptions(int _iButID, bool _bNewValue, R6WindowListGeneral _pOptionsList, optional bool _bChangeByUserClick)
{
	local bool bButState;

	switch(_iButID)
	{
		// End:0x1E
		case int(28):
			UpdateCamSpecialCase(_bNewValue, true);
			// End:0xDE
			break;
		// End:0x35
		case int(29):
			UpdateCamSpecialCase(_bNewValue, false);
			// End:0xDE
			break;
		// End:0xD8
		case int(11):
			bButState = false;
			// End:0x6E
			if((!m_bInitComplete))
			{
				m_bBkpTKPenalty = m_pButtonsDef.GetButtonBoxValue(int(14), _pOptionsList);
			}
			// End:0x87
			if(_bNewValue)
			{
				bButState = m_bBkpTKPenalty;				
			}
			else
			{
				// End:0xAF
				if(_bChangeByUserClick)
				{
					m_bBkpTKPenalty = m_pButtonsDef.GetButtonBoxValue(int(14), _pOptionsList);
				}
			}
			m_pButtonsDef.ChangeButtonBoxValue(int(14), bButState, _pOptionsList, (!_bNewValue));
			// End:0xDE
			break;
		// End:0xFFFF
		default:
			// End:0xDE
			break;
			break;
	}
	return;
}

//=======================================================================
// UpdateAllMapList: 
//=======================================================================
function UpdateAllMapList()
{
	local R6MenuMapList pTempList;
	local int i;

	i = 0;
	J0x07:

	// End:0x59 [Loop If]
	if((i < m_ANbOfGameMode.Length))
	{
		pTempList = R6MenuMapList(GetList(m_ANbOfGameMode[i], 3));
		// End:0x4F
		if((pTempList != none))
		{
			pTempList.FillMapListItem();
		}
		(i++);
		// [Loop Continue]
		goto J0x07;
	}
	return;
}

//*******************************************************************************************
// SERVER OPTIONS FUNCTIONS
//*******************************************************************************************
//=======================================================================
// RefreshServerOpt: Refresh the creategame options according the value find in class R6ServerInfo (init from server.ini)
//=======================================================================
function RefreshServerOpt(optional bool _bNewServerProfile)
{
	local int iIndex;
	local R6ServerInfo pServerOpt;
	local R6MenuMapList pCurrentMapList;

	pServerOpt = Class'Engine.Actor'.static.GetServerOptions();
	m_bNewServerProfile = _bNewServerProfile;
	// End:0x2E
	if(m_bInitComplete)
	{
		UpdateAllMapList();
	}
	// End:0x88
	if(_bNewServerProfile)
	{
		pCurrentMapList = R6MenuMapList(GetList(GetCurrentGameMode(), 3));
		m_pOptionsGameMode.SetValue(m_pOptionsGameMode.GetValue(), pCurrentMapList.GetNewServerProfileGameMode());
		ManageComboControlNotify(m_pOptionsGameMode);
	}
	pCurrentMapList = R6MenuMapList(GetList(GetCurrentGameMode(), 3));
	iIndex = m_pOptionsGameMode.FindItemIndex2(pCurrentMapList.FillFinalMapList());
	m_pOptionsGameMode.SetSelectedIndex(iIndex);
	// End:0x13D
	if((!R6Console(Root.Console).m_bStartedByGSClient))
	{
		m_pServerNameEdit.SetValue(pServerOpt.ServerName);
		SetButtonAndEditBox(4, pServerOpt.GamePassword, pServerOpt.UsePassword);
	}
	SetButtonAndEditBox(5, pServerOpt.AdminPassword, pServerOpt.UseAdminPassword);
	m_szMsgOfTheDay = Localize("MPCreateGame", "Default_MsgOfTheDay", "R6Menu");
	// End:0x1C2
	if((pServerOpt.MOTD != ""))
	{
		m_szMsgOfTheDay = pServerOpt.MOTD;
	}
	super.RefreshServerOpt();
	m_bNewServerProfile = false;
	return;
}

function SetServerOptions()
{
	local UWindowWindow pCGWWindow;
	local R6WindowListGeneral pListGen;
	local int iCounter;
	local R6StartGameInfo StartGameInfo;
	local string szSvrName, szGameType;
	local R6ServerInfo _ServerSettings;
	local R6MapList myList;
	local int iButtonValue;

	_ServerSettings = Class'Engine.Actor'.static.GetServerOptions();
	// End:0x47
	if((_ServerSettings.m_ServerMapList == none))
	{
		_ServerSettings.m_ServerMapList = GetLevel().Spawn(Class'Engine.R6MapList');
	}
	// End:0x95
	if(R6Console(Root.Console).m_bStartedByGSClient)
	{
		szSvrName = R6Console(Root.Console).m_GameService.m_szGSServerName;		
	}
	else
	{
		szSvrName = m_pServerNameEdit.GetValue();
	}
	_ServerSettings.ServerName = szSvrName;
	// End:0x160
	if(R6Console(Root.Console).m_bStartedByGSClient)
	{
		_ServerSettings.UsePassword = (R6Console(Root.Console).m_GameService.m_szGSPassword != "");
		// End:0x15D
		if(_ServerSettings.UsePassword)
		{
			_ServerSettings.GamePassword = R6Console(Root.Console).m_GameService.m_szGSPassword;
		}		
	}
	else
	{
		pCGWWindow = GetList(GetCurrentGameMode(), 4);
		_ServerSettings.UsePassword = R6WindowButtonAndEditBox(pCGWWindow).m_bSelected;
		_ServerSettings.GamePassword = R6WindowButtonAndEditBox(pCGWWindow).m_pEditBox.GetValue();
	}
	pCGWWindow = GetList(GetCurrentGameMode(), 5);
	_ServerSettings.UseAdminPassword = R6WindowButtonAndEditBox(pCGWWindow).m_bSelected;
	_ServerSettings.AdminPassword = R6WindowButtonAndEditBox(pCGWWindow).m_pEditBox.GetValue();
	// End:0x368
	if(m_bInGame)
	{
		pListGen = R6WindowListGeneral(GetList(GetCurrentGameMode(), 2));
		_ServerSettings.CamFirstPerson = GetCameraSelection(int(24), pListGen);
		_ServerSettings.CamThirdPerson = GetCameraSelection(int(25), pListGen);
		_ServerSettings.CamFreeThirdP = GetCameraSelection(int(26), pListGen);
		_ServerSettings.CamGhost = GetCameraSelection(int(27), pListGen);
		// End:0x2F8
		if((m_pButtonsDef.FindButtonItem(int(28), pListGen) == none))
		{
			_ServerSettings.CamFadeToBlack = false;			
		}
		else
		{
			_ServerSettings.CamFadeToBlack = GetCameraSelection(int(28), pListGen);
		}
		// End:0x349
		if((m_pButtonsDef.FindButtonItem(int(29), pListGen) == none))
		{
			_ServerSettings.CamTeamOnly = false;			
		}
		else
		{
			_ServerSettings.CamTeamOnly = GetCameraSelection(int(29), pListGen);
		}
	}
	pListGen = R6WindowListGeneral(GetList(GetCurrentGameMode(), 1));
	// End:0x3CF
	if(R6Console(Root.Console).m_bStartedByGSClient)
	{
		iButtonValue = R6Console(Root.Console).m_GameService.m_iGSNumPlayers;		
	}
	else
	{
		iButtonValue = m_pButtonsDef.GetButtonCounterValue(int(3), pListGen);
	}
	// End:0x40F
	if((iButtonValue > 0))
	{
		_ServerSettings.MaxPlayers = iButtonValue;		
	}
	else
	{
		_ServerSettings.MaxPlayers = 1;
	}
	// End:0x464
	if((m_pButtonsDef.FindButtonItem(int(8), pListGen) != none))
	{
		_ServerSettings.NbTerro = m_pButtonsDef.GetButtonCounterValue(int(8), pListGen);
	}
	_ServerSettings.MOTD = m_szMsgOfTheDay;
	_ServerSettings.RoundTime = (m_pButtonsDef.GetButtonCounterValue(int(2), pListGen) * 60);
	// End:0x4E3
	if((int(GetCurrentGameMode()) == int(m_ANbOfGameMode[0])))
	{
		_ServerSettings.RoundsPerMatch = m_pButtonsDef.GetButtonCounterValue(int(1), pListGen);		
	}
	else
	{
		_ServerSettings.RoundsPerMatch = m_pButtonsDef.GetButtonCounterValue(int(6), pListGen);
	}
	_ServerSettings.BetweenRoundTime = m_pButtonsDef.GetButtonCounterValue(int(7), pListGen);
	// End:0x576
	if((m_pButtonsDef.FindButtonItem(int(4), pListGen) != none))
	{
		_ServerSettings.BombTime = m_pButtonsDef.GetButtonCounterValue(int(4), pListGen);
	}
	// End:0x5CC
	if((R6Console(Root.Console).m_bStartedByGSClient || R6Console(Root.Console).m_bNonUbiMatchMakingHost))
	{
		_ServerSettings.InternetServer = true;		
	}
	else
	{
		_ServerSettings.InternetServer = bool(m_pButtonsDef.GetButtonComboValue(int(9), pListGen));
	}
	_ServerSettings.DedicatedServer = m_pButtonsDef.GetButtonBoxValue(int(10), pListGen);
	_ServerSettings.FriendlyFire = m_pButtonsDef.GetButtonBoxValue(int(11), pListGen);
	// End:0x68C
	if((m_pButtonsDef.FindButtonItem(int(14), pListGen) != none))
	{
		_ServerSettings.TeamKillerPenalty = m_pButtonsDef.GetButtonBoxValue(int(14), pListGen);
	}
	// End:0x6D5
	if((m_pButtonsDef.FindButtonItem(int(17), pListGen) != none))
	{
		_ServerSettings.AIBkp = m_pButtonsDef.GetButtonBoxValue(int(17), pListGen);		
	}
	else
	{
		_ServerSettings.AIBkp = false;
	}
	// End:0x72C
	if((m_pButtonsDef.FindButtonItem(int(16), pListGen) != none))
	{
		_ServerSettings.RotateMap = m_pButtonsDef.GetButtonBoxValue(int(16), pListGen);
	}
	// End:0x772
	if((m_pButtonsDef.FindButtonItem(int(13), pListGen) != none))
	{
		_ServerSettings.Autobalance = m_pButtonsDef.GetButtonBoxValue(int(13), pListGen);
	}
	_ServerSettings.ShowNames = m_pButtonsDef.GetButtonBoxValue(int(12), pListGen);
	_ServerSettings.ForceFPersonWeapon = m_pButtonsDef.GetButtonBoxValue(int(18), pListGen);
	_ServerSettings.AllowRadar = m_pButtonsDef.GetButtonBoxValue(int(15), pListGen);
	// End:0x831
	if((m_pButtonsDef.FindButtonItem(int(23), pListGen) != none))
	{
		_ServerSettings.DiffLevel = int(m_pButtonsDef.GetButtonComboValue(int(23), pListGen));
	}
	FillSelectedMapList();
	// End:0x94F
	if((m_SelectedMapList.Length != 0))
	{
		szGameType = m_SelectedModeList[0];
		StartGameInfo = R6Console(Root.Console).Master.m_StartGameInfo;
		StartGameInfo.m_GameMode = szGameType;
		myList = _ServerSettings.m_ServerMapList;
		iCounter = 0;
		J0x8AA:

		// End:0x8EE [Loop If]
		if((iCounter < 32))
		{
			myList.Maps[iCounter] = "";
			myList.GameType[iCounter] = "";
			(iCounter++);
			// [Loop Continue]
			goto J0x8AA;
		}
		iCounter = 0;
		J0x8F5:

		// End:0x94F [Loop If]
		if((iCounter < m_SelectedMapList.Length))
		{
			myList.Maps[iCounter] = m_SelectedMapList[iCounter];
			myList.GameType[iCounter] = m_SelectedModeList[iCounter];
			(iCounter++);
			// [Loop Continue]
			goto J0x8F5;
		}
	}
	return;
}

//*******************************************************************************************
// NOTIFY FUNCTIONS
//*******************************************************************************************
//=================================================================
// notify the parent window by using the appropriate parent function
//=================================================================
function Notify(UWindowDialogControl C, byte E)
{
	local bool bProcessNotify;

	// End:0x27
	if(C.IsA('R6WindowButton'))
	{
		ManageR6ButtonNotify(C, E);		
	}
	else
	{
		// End:0x89
		if((int(E) == 2))
		{
			// End:0x5F
			if(C.IsA('R6WindowButtonBox'))
			{
				ManageR6ButtonBoxNotify(C);
				bProcessNotify = true;				
			}
			else
			{
				// End:0x86
				if(C.IsA('R6WindowButtonAndEditBox'))
				{
					ManageR6ButtonAndEditBoxNotify(C);
					bProcessNotify = true;
				}
			}			
		}
		else
		{
			// End:0xFD
			if((int(E) == 1))
			{
				// End:0xCB
				if(C.IsA('UWindowComboControl'))
				{
					// End:0xC8
					if((!m_bNewServerProfile))
					{
						ManageComboControlNotify(C);
						bProcessNotify = true;
					}					
				}
				else
				{
					// End:0xFD
					if((C.IsA('R6WindowButtonAndEditBox') || C.IsA('R6WindowEditControl')))
					{
						bProcessNotify = true;
					}
				}
			}
		}
	}
	// End:0x124
	if(((bProcessNotify && m_bInitComplete) && (!m_bNewServerProfile)))
	{
		SetServerOptions();
	}
	return;
}

//=================================================================
// manage the R6WindowButton notify message
//=================================================================
function ManageR6ButtonNotify(UWindowDialogControl C, byte E)
{
	super.ManageR6ButtonNotify(C, E);
	// End:0x77
	if((int(E) == 2))
	{
		// End:0x4C
		if((R6WindowButton(C).m_iButtonID == int(m_pButtonsDef.38)))
		{
			PopUpMOTDEditionBox();			
		}
		else
		{
			// End:0x77
			if((R6WindowButton(C).m_iButtonID == int(m_pButtonsDef.40)))
			{
				PopUpSetSkins();
			}
		}
	}
	return;
}

/////////////////////////////////////////////////////////////////
// manage the ComboControl notify message
/////////////////////////////////////////////////////////////////
function ManageComboControlNotify(UWindowDialogControl C)
{
	local string szTemp;
	local R6MenuMapList pCurrentMapList;

	// End:0xC8
	if((R6WindowComboControl(C) == m_pOptionsGameMode))
	{
		szTemp = m_pOptionsGameMode.GetValue2();
		switch(szTemp)
		{
			// End:0x67
			case string(m_ANbOfGameMode[0]):
				pCurrentMapList = R6MenuMapList(GetList(m_ANbOfGameMode[0], 3));
				SetCurrentGameMode(m_ANbOfGameMode[0], true);
				// End:0xA4
				break;
			// End:0x9E
			case string(m_ANbOfGameMode[1]):
				pCurrentMapList = R6MenuMapList(GetList(m_ANbOfGameMode[1], 3));
				SetCurrentGameMode(m_ANbOfGameMode[1], true);
				// End:0xA4
				break;
			// End:0xFFFF
			default:
				// End:0xA4
				break;
				break;
		}
		pCurrentMapList.SetGameModeToDisplay(m_pOptionsGameMode.GetValue2());
		UpdateSkinButton();
	}
	return;
}

