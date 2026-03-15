//=============================================================================
// R6MenuMPCreateGameTabAdvOptions - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6MenuMPCreateGameTabAdvOptions.uc : class for advanced options
//
//  Copyright 2003 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2003/07/10  * Create by Yannick Joly
//=============================================================================
class R6MenuMPCreateGameTabAdvOptions extends R6MenuMPCreateGameTab;

// NEW IN 1.60
var bool m_bBkpCamFadeToBk;
// NEW IN 1.60
var bool m_bBkpCamFirstPerson;
// NEW IN 1.60
var bool m_bBkpCamThirdPerson;
// NEW IN 1.60
var bool m_bBkpCamFreeThirdP;
// NEW IN 1.60
var bool m_bBkpCamGhost;
// NEW IN 1.60
var bool m_bBkpCamTeamOnly;
// NEW IN 1.60
var R6WindowTextLabelExt m_pOptionsTextAdv;

//*******************************************************************************************
// INIT
//*******************************************************************************************
function Created()
{
	super.Created();
	return;
}

function InitAdvOptionsTab(optional bool _bInGame)
{
	local float fXOffset, fYOffset, fWidth, fHeight;
	local int i;

	m_pOptionsTextAdv = R6WindowTextLabelExt(CreateWindow(Class'R6Window.R6WindowTextLabelExt', 0.0000000, 0.0000000, (2.0000000 * float(310)), WinHeight, self));
	m_pOptionsTextAdv.bAlwaysBehind = true;
	m_pOptionsTextAdv.ActiveBorder(0, false);
	m_pOptionsTextAdv.ActiveBorder(1, false);
	m_pOptionsTextAdv.SetBorderParam(2, 310.0000000, 1.0000000, 1.0000000, Root.Colors.White);
	m_pOptionsTextAdv.ActiveBorder(3, false);
	m_pOptionsTextAdv.m_Font = Root.Fonts[5];
	m_pOptionsTextAdv.m_vTextColor = Root.Colors.White;
	fXOffset = (310.0000000 + float(5));
	fYOffset = 5.0000000;
	fWidth = 310.0000000;
	m_pOptionsTextAdv.AddTextLabel(Localize("MPCreateGame", "Options_DeathCam", "R6Menu"), fXOffset, fYOffset, fWidth, 0, false);
	fXOffset = 5.0000000;
	fYOffset = 5.0000000;
	fWidth = ((310.0000000 - fXOffset) - float(10));
	fHeight = (WinHeight - fYOffset);
	i = 0;
	J0x1B3:

	// End:0x1F4 [Loop If]
	if((i < m_ANbOfGameMode.Length))
	{
		CreateListOfButtons(fXOffset, fYOffset, fWidth, fHeight, m_ANbOfGameMode[i], 6);
		(i++);
		// [Loop Continue]
		goto J0x1B3;
	}
	fXOffset = (5.0000000 + float(310));
	fHeight = 100.0000000;
	i = 0;
	J0x21A:

	// End:0x25B [Loop If]
	if((i < m_ANbOfGameMode.Length))
	{
		CreateListOfButtons(fXOffset, fYOffset, fWidth, fHeight, m_ANbOfGameMode[i], 2);
		(i++);
		// [Loop Continue]
		goto J0x21A;
	}
	m_bInitComplete = true;
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
		// End:0x2A7
		case GetPlayerOwner().3:
			switch(_eCGWindowID)
			{
				// End:0xEE
				case 6:
					// End:0xD1
					if(_bUpdateValue)
					{
						// End:0xB4
						if(Class'Engine.Actor'.static.GetGameOptions().m_bPBInstalled)
						{
							m_pButtonsDef.ChangeButtonBoxValue(int(22), (GetLevel().iPBEnabled > 0), pTempList);							
						}
						else
						{
							m_pButtonsDef.ChangeButtonBoxValue(int(22), false, pTempList, true);
						}						
					}
					else
					{
						m_pButtonsDef.AddButtonBool(int(22), false, pTempList, self);
					}
					// End:0x2A4
					break;
				// End:0x29E
				case 2:
					// End:0x1EA
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
						m_pButtonsDef.AddFakeButton(pTempList, self);
						m_pButtonsDef.AddButtonBool(int(28), false, pTempList, self);
						m_pButtonsDef.AddButtonBool(int(24), true, pTempList, self);
						m_pButtonsDef.AddButtonBool(int(25), true, pTempList, self);
						m_pButtonsDef.AddButtonBool(int(26), true, pTempList, self);
						m_pButtonsDef.AddButtonBool(int(27), true, pTempList, self);
						m_pButtonsDef.AddButtonBool(int(29), true, pTempList, self);
					}
					// End:0x2A4
					break;
				// End:0xFFFF
				default:
					// End:0x2A4
					break;
					break;
			}
			// End:0x48F
			break;
		// End:0x462
		case GetPlayerOwner().2:
			switch(_eCGWindowID)
			{
				// End:0x34C
				case 6:
					// End:0x32F
					if(_bUpdateValue)
					{
						// End:0x312
						if(Class'Engine.Actor'.static.GetGameOptions().m_bPBInstalled)
						{
							m_pButtonsDef.ChangeButtonBoxValue(int(22), (GetLevel().iPBEnabled > 0), pTempList, false);							
						}
						else
						{
							m_pButtonsDef.ChangeButtonBoxValue(int(22), false, pTempList, true);
						}						
					}
					else
					{
						m_pButtonsDef.AddButtonBool(int(22), false, pTempList, self);
					}
					// End:0x45F
					break;
				// End:0x459
				case 2:
					// End:0x3D9
					if(_bUpdateValue)
					{
						UpdateCamera(int(24), pServerInfo.CamFirstPerson, false, pTempList);
						UpdateCamera(int(25), pServerInfo.CamThirdPerson, false, pTempList);
						UpdateCamera(int(26), pServerInfo.CamFreeThirdP, false, pTempList);
						UpdateCamera(int(27), pServerInfo.CamGhost, false, pTempList);						
					}
					else
					{
						m_pButtonsDef.AddFakeButton(pTempList, self);
						m_pButtonsDef.AddButtonBool(int(24), true, pTempList, self);
						m_pButtonsDef.AddButtonBool(int(25), true, pTempList, self);
						m_pButtonsDef.AddButtonBool(int(26), true, pTempList, self);
						m_pButtonsDef.AddButtonBool(int(27), true, pTempList, self);
					}
					// End:0x45F
					break;
				// End:0xFFFF
				default:
					// End:0x45F
					break;
					break;
			}
			// End:0x48F
			break;
		// End:0xFFFF
		default:
			Log("UpdateButtons not a valid game mode");
			// End:0x48F
			break;
			break;
	}
	return;
}

// NEW IN 1.60
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

// NEW IN 1.60
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

// NEW IN 1.60
function UpdateCamSpecialCase(bool _bButtonSel, bool _bUpdateDeathCam)
{
	local bool bCamState, bCamFirstPerson, bCamThirdPerson, bCamFreeThPerson, bCamGhost, bCanTeamOnly,
		bCamGhostDis;

	local R6WindowListGeneral pCamList;

	pCamList = R6WindowListGeneral(GetList(GetCurrentGameMode(), 2));
	// End:0x26E
	if(_bUpdateDeathCam)
	{
		bCamState = _bButtonSel;
		bCamFirstPerson = false;
		bCamThirdPerson = false;
		bCamFreeThPerson = false;
		bCamGhost = false;
		bCanTeamOnly = false;
		// End:0x13E
		if(bCamState)
		{
			m_bBkpCamFirstPerson = m_pButtonsDef.GetButtonBoxValue(int(24), pCamList);
			m_bBkpCamThirdPerson = m_pButtonsDef.GetButtonBoxValue(int(25), pCamList);
			m_bBkpCamFreeThirdP = m_pButtonsDef.GetButtonBoxValue(int(26), pCamList);
			bCamGhostDis = m_pButtonsDef.IsButtonBoxDisabled(int(27), pCamList);
			// End:0x106
			if((!bCamGhostDis))
			{
				m_bBkpCamGhost = m_pButtonsDef.GetButtonBoxValue(int(27), pCamList);
			}
			// End:0x13B
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
			// End:0x198
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
		// End:0x23A
		if((!bCamGhostDis))
		{
			UpdateCamera(int(27), bCamGhost, bCamState, pCamList);
		}
		// End:0x26B
		if((int(GetCurrentGameMode()) == int(m_ANbOfGameMode[0])))
		{
			UpdateCamera(int(29), bCanTeamOnly, bCamState, pCamList);
		}		
	}
	else
	{
		bCamState = _bButtonSel;
		bCamGhost = false;
		// End:0x2AE
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

// NEW IN 1.60
function UpdateMenuOptions(int _iButID, bool _bNewValue, R6WindowListGeneral _pOptionsList, optional bool _bChangeByUserClick)
{
	local bool bButState;

	switch(_iButID)
	{
		// End:0x1E
		case int(28):
			UpdateCamSpecialCase(_bNewValue, true);
			// End:0x3B
			break;
		// End:0x35
		case int(29):
			UpdateCamSpecialCase(_bNewValue, false);
			// End:0x3B
			break;
		// End:0xFFFF
		default:
			// End:0x3B
			break;
			break;
	}
	return;
}

//*******************************************************************************************
// SERVER OPTIONS FUNCTIONS
//*******************************************************************************************
function SetServerOptions()
{
	local R6ServerInfo _ServerSettings;
	local R6WindowListGeneral pListGen;
	local bool bPBButtonValue;

	_ServerSettings = Class'Engine.Actor'.static.GetServerOptions();
	pListGen = R6WindowListGeneral(GetList(GetCurrentGameMode(), 2));
	_ServerSettings.CamFirstPerson = GetCameraSelection(int(24), pListGen);
	_ServerSettings.CamThirdPerson = GetCameraSelection(int(25), pListGen);
	_ServerSettings.CamFreeThirdP = GetCameraSelection(int(26), pListGen);
	_ServerSettings.CamGhost = GetCameraSelection(int(27), pListGen);
	// End:0xD9
	if((m_pButtonsDef.FindButtonItem(int(28), pListGen) == none))
	{
		_ServerSettings.CamFadeToBlack = false;		
	}
	else
	{
		_ServerSettings.CamFadeToBlack = GetCameraSelection(int(28), pListGen);
	}
	// End:0x12A
	if((m_pButtonsDef.FindButtonItem(int(29), pListGen) == none))
	{
		_ServerSettings.CamTeamOnly = false;		
	}
	else
	{
		_ServerSettings.CamTeamOnly = GetCameraSelection(int(29), pListGen);
	}
	pListGen = R6WindowListGeneral(GetList(GetCurrentGameMode(), 6));
	// End:0x16F
	if((pListGen == none))
	{
		return;
	}
	bPBButtonValue = m_pButtonsDef.GetButtonBoxValue(int(22), pListGen);
	Class'Engine.Actor'.static.SetPBStatus((!bPBButtonValue), true);
	// End:0x1BD
	if((bPBButtonValue == true))
	{
		Class'Engine.Actor'.static.SetPBStatus(false, false);
	}
	return;
}


// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var m_pAdvOptionsLineW
