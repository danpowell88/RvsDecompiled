//=============================================================================
// R6MenuMPServerOption - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6MenuMPServerOption.uc : Display the server option depending if you are an admin or a client
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/05/09  * Create by Yannick Joly
//=============================================================================
class R6MenuMPServerOption extends R6MenuMPCreateGameTabOptions;

var bool m_bServerSettingsChange;  // at least one of the server settings change
var bool m_bImAnAdmin;  // if the client can change the settings
var UWindowWindow m_pServerOptFakeW;  // fake window to hide all access buttons
var UWindowWindow m_pServerOptFakeW2;  // fake window to hide all access buttons
var R6WindowTextLabel m_InTheReleaseLabel;

function Created()
{
	super.Created();
	m_pServerOptFakeW = CreateWindow(Class'UWindow.UWindowWindow', 0.0000000, 0.0000000, __NFUN_171__(WinWidth, 0.5000000), WinHeight, self);
	m_pServerOptFakeW.bAlwaysOnTop = true;
	m_pServerOptFakeW2 = CreateWindow(Class'UWindow.UWindowWindow', 310.0000000, 136.0000000, __NFUN_171__(WinWidth, 0.5000000), __NFUN_175__(WinHeight, float(136)), self);
	m_pServerOptFakeW2.bAlwaysOnTop = true;
	InitOptionsTab(true);
	Refresh();
	return;
}

//=======================================================================================
// Refresh : Verify is the client is now an admin
//=======================================================================================
function Refresh()
{
	// End:0x72
	if(R6PlayerController(GetPlayerOwner()).CheckAuthority(R6PlayerController(GetPlayerOwner()).1))
	{
		// End:0x51
		if(__NFUN_242__(m_bImAnAdmin, false))
		{
			m_bImAnAdmin = true;
			R6PlayerController(GetPlayerOwner()).ServerPausePreGameRoundTime();
		}
		m_pServerOptFakeW.HideWindow();
		m_pServerOptFakeW2.HideWindow();		
	}
	else
	{
		m_bImAnAdmin = false;
		m_pServerOptFakeW.ShowWindow();
		m_pServerOptFakeW2.ShowWindow();
	}
	return;
}

//=======================================================================================
// RefreshServerOpt : Update server info menu with the values of the server
//=======================================================================================
function RefreshServerOpt(optional bool _bNewServerProfile)
{
	local int iIndex;
	local R6GameReplicationInfo pGameRepInfo;
	local R6MenuMapList pCurrentMapList;

	Refresh();
	pGameRepInfo = R6GameReplicationInfo(R6MenuInGameMultiPlayerRootWindow(Root).m_R6GameMenuCom.m_GameRepInfo);
	// End:0x3C
	if(m_bInitComplete)
	{
		UpdateAllMapList();
	}
	pCurrentMapList = R6MenuMapList(GetList(GetCurrentGameMode(), 3));
	m_pOptionsGameMode.SetValue(m_pOptionsGameMode.GetValue(), pCurrentMapList.GetNewServerProfileGameMode(true));
	ManageComboControlNotify(m_pOptionsGameMode);
	pCurrentMapList = R6MenuMapList(GetList(GetCurrentGameMode(), 3));
	iIndex = m_pOptionsGameMode.FindItemIndex2(pCurrentMapList.FillFinalMapListInGame());
	m_pOptionsGameMode.SetSelectedIndex(iIndex);
	m_pOptionsGameMode.SetDisableButton(true);
	m_pServerNameEdit.SetValue(pGameRepInfo.ServerName);
	SetButtonAndEditBox(4, "*******", pGameRepInfo.m_bPasswordReq);
	R6WindowButtonAndEditBox(GetList(GetCurrentGameMode(), 4)).SetDisableButtonAndEditBox(true);
	SetButtonAndEditBox(5, "*******", pGameRepInfo.m_bAdminPasswordReq);
	R6WindowButtonAndEditBox(GetList(GetCurrentGameMode(), 5)).SetDisableButtonAndEditBox(true);
	m_szMsgOfTheDay = pGameRepInfo.MOTDLine1;
	RefreshCGButtons();
	return;
}

function UpdateButtons(Actor.EGameModeInfo _eGameMode, R6MenuMPCreateGameTab.eCreateGameWindow_ID _eCGWindowID, optional bool _bUpdateValue)
{
	local R6WindowListGeneral pTempList;
	local R6GameReplicationInfo pR6GameRepInfo;

	pTempList = R6WindowListGeneral(GetList(_eGameMode, _eCGWindowID));
	// End:0x28
	if(__NFUN_114__(pTempList, none))
	{
		return;
	}
	// End:0x58
	if(_bUpdateValue)
	{
		pR6GameRepInfo = R6GameReplicationInfo(R6MenuInGameMultiPlayerRootWindow(Root).m_R6GameMenuCom.m_GameRepInfo);
	}
	switch(_eGameMode)
	{
		// End:0x4BD
		case m_ANbOfGameMode[0]:
			switch(_eCGWindowID)
			{
				// End:0x2F8
				case 1:
					// End:0x2DF
					if(_bUpdateValue)
					{
						m_pButtonsDef.ChangeButtonComboValue(int(9), string(pR6GameRepInfo.m_bInternetSvr), pTempList, true);
						m_pButtonsDef.ChangeButtonCounterValue(int(1), pR6GameRepInfo.m_iRoundsPerMatch, pTempList, __NFUN_129__(m_bImAnAdmin));
						m_pButtonsDef.ChangeButtonCounterValue(int(2), __NFUN_145__(pR6GameRepInfo.TimeLimit, 60), pTempList, __NFUN_129__(m_bImAnAdmin));
						m_pButtonsDef.ChangeButtonCounterValue(int(7), int(pR6GameRepInfo.m_fTimeBetRounds), pTempList, __NFUN_129__(m_bImAnAdmin));
						m_pButtonsDef.ChangeButtonCounterValue(int(3), pR6GameRepInfo.m_MaxPlayers, pTempList, __NFUN_129__(m_bImAnAdmin));
						m_pButtonsDef.ChangeButtonCounterValue(int(4), int(pR6GameRepInfo.m_fBombTime), pTempList, __NFUN_129__(m_bImAnAdmin));
						m_pButtonsDef.ChangeButtonBoxValue(int(10), pR6GameRepInfo.m_bDedicatedSvr, pTempList, true);
						m_pButtonsDef.ChangeButtonBoxValue(int(11), pR6GameRepInfo.m_bFriendlyFire, pTempList);
						m_bBkpTKPenalty = pR6GameRepInfo.m_bMenuTKPenaltySetting;
						m_pButtonsDef.ChangeButtonBoxValue(int(14), pR6GameRepInfo.m_bMenuTKPenaltySetting, pTempList);
						m_pButtonsDef.ChangeButtonBoxValue(int(15), pR6GameRepInfo.m_bRepAllowRadarOption, pTempList);
						m_pButtonsDef.ChangeButtonBoxValue(int(12), pR6GameRepInfo.m_bShowNames, pTempList);
						m_pButtonsDef.ChangeButtonBoxValue(int(18), pR6GameRepInfo.m_bFFPWeapon, pTempList);
						m_pButtonsDef.ChangeButtonBoxValue(int(13), pR6GameRepInfo.m_bAutoBalance, pTempList);
						UpdateMenuOptions(int(11), pR6GameRepInfo.m_bFriendlyFire, pTempList);						
					}
					else
					{
						super.UpdateButtons(_eGameMode, _eCGWindowID, _bUpdateValue);
					}
					// End:0x4BA
					break;
				// End:0x4B4
				case 2:
					// End:0x481
					if(_bUpdateValue)
					{
						// End:0x34A
						if(Class'Engine.Actor'.static.__NFUN_1009__().m_bPBInstalled)
						{
							m_pButtonsDef.ChangeButtonBoxValue(int(22), pR6GameRepInfo.m_bPunkBuster, pTempList, true);							
						}
						else
						{
							m_pButtonsDef.ChangeButtonBoxValue(int(22), false, pTempList, true);
						}
						UpdateCamera(int(28), __NFUN_151__(__NFUN_156__(pR6GameRepInfo.m_iDeathCameraMode, 16), 0), false, pTempList);
						UpdateCamera(int(24), __NFUN_151__(__NFUN_156__(pR6GameRepInfo.m_iDeathCameraMode, 1), 0), false, pTempList, true);
						UpdateCamera(int(25), __NFUN_151__(__NFUN_156__(pR6GameRepInfo.m_iDeathCameraMode, 2), 0), false, pTempList, true);
						UpdateCamera(int(26), __NFUN_151__(__NFUN_156__(pR6GameRepInfo.m_iDeathCameraMode, 4), 0), false, pTempList, true);
						UpdateCamera(int(27), __NFUN_151__(__NFUN_156__(pR6GameRepInfo.m_iDeathCameraMode, 8), 0), false, pTempList, true);
						UpdateCamera(int(29), __NFUN_151__(__NFUN_156__(pR6GameRepInfo.m_iDeathCameraMode, 32), 0), false, pTempList, true);
						UpdateCamSpecialCase(__NFUN_151__(__NFUN_156__(pR6GameRepInfo.m_iDeathCameraMode, 32), 0), false);
						UpdateCamSpecialCase(__NFUN_151__(__NFUN_156__(pR6GameRepInfo.m_iDeathCameraMode, 16), 0), true);						
					}
					else
					{
						super.UpdateButtons(_eGameMode, _eCGWindowID, _bUpdateValue);
						m_pButtonsDef.AddButtonBool(int(22), false, pTempList, self);
					}
					// End:0x4BA
					break;
				// End:0xFFFF
				default:
					// End:0x4BA
					break;
					break;
			}
			// End:0x88B
			break;
		// End:0x85E
		case m_ANbOfGameMode[1]:
			switch(_eCGWindowID)
			{
				// End:0x720
				case 1:
					// End:0x707
					if(_bUpdateValue)
					{
						m_pButtonsDef.ChangeButtonComboValue(int(9), string(pR6GameRepInfo.m_bInternetSvr), pTempList, true);
						m_pButtonsDef.ChangeButtonComboValue(int(23), string(pR6GameRepInfo.m_iDiffLevel), pTempList);
						m_pButtonsDef.ChangeButtonCounterValue(int(6), pR6GameRepInfo.m_iRoundsPerMatch, pTempList);
						m_pButtonsDef.ChangeButtonCounterValue(int(2), __NFUN_145__(pR6GameRepInfo.TimeLimit, 60), pTempList);
						m_pButtonsDef.ChangeButtonCounterValue(int(7), int(pR6GameRepInfo.m_fTimeBetRounds), pTempList);
						m_pButtonsDef.ChangeButtonCounterValue(int(3), pR6GameRepInfo.m_MaxPlayers, pTempList);
						m_pButtonsDef.ChangeButtonCounterValue(int(8), pR6GameRepInfo.m_iNbOfTerro, pTempList);
						m_pButtonsDef.ChangeButtonBoxValue(int(10), pR6GameRepInfo.m_bDedicatedSvr, pTempList, true);
						m_pButtonsDef.ChangeButtonBoxValue(int(17), pR6GameRepInfo.m_bAIBkp, pTempList);
						m_pButtonsDef.ChangeButtonBoxValue(int(16), pR6GameRepInfo.m_bRotateMap, pTempList);
						m_pButtonsDef.ChangeButtonBoxValue(int(11), pR6GameRepInfo.m_bFriendlyFire, pTempList);
						m_pButtonsDef.ChangeButtonBoxValue(int(15), pR6GameRepInfo.m_bRepAllowRadarOption, pTempList);
						m_pButtonsDef.ChangeButtonBoxValue(int(12), pR6GameRepInfo.m_bShowNames, pTempList);
						m_pButtonsDef.ChangeButtonBoxValue(int(18), pR6GameRepInfo.m_bFFPWeapon, pTempList);						
					}
					else
					{
						super.UpdateButtons(_eGameMode, _eCGWindowID, _bUpdateValue);
					}
					// End:0x85B
					break;
				// End:0x855
				case 2:
					// End:0x822
					if(_bUpdateValue)
					{
						// End:0x772
						if(Class'Engine.Actor'.static.__NFUN_1009__().m_bPBInstalled)
						{
							m_pButtonsDef.ChangeButtonBoxValue(int(22), pR6GameRepInfo.m_bPunkBuster, pTempList, true);							
						}
						else
						{
							m_pButtonsDef.ChangeButtonBoxValue(int(22), false, pTempList, true);
						}
						UpdateCamera(int(24), __NFUN_151__(__NFUN_156__(pR6GameRepInfo.m_iDeathCameraMode, 1), 0), false, pTempList);
						UpdateCamera(int(25), __NFUN_151__(__NFUN_156__(pR6GameRepInfo.m_iDeathCameraMode, 2), 0), false, pTempList);
						UpdateCamera(int(26), __NFUN_151__(__NFUN_156__(pR6GameRepInfo.m_iDeathCameraMode, 4), 0), false, pTempList);
						UpdateCamera(int(27), __NFUN_151__(__NFUN_156__(pR6GameRepInfo.m_iDeathCameraMode, 8), 0), false, pTempList);						
					}
					else
					{
						super.UpdateButtons(_eGameMode, _eCGWindowID, _bUpdateValue);
						m_pButtonsDef.AddButtonBool(int(22), false, pTempList, self);
					}
					// End:0x85B
					break;
				// End:0xFFFF
				default:
					// End:0x85B
					break;
					break;
			}
			// End:0x88B
			break;
		// End:0xFFFF
		default:
			__NFUN_231__("UpdateButtons not a valid game mode");
			// End:0x88B
			break;
			break;
	}
	return;
}

//=================================================================================
// SendNewServerSettings: Send the new server settings to the server, only the change values. 
//						  If no modification was made return false 
//=================================================================================
function bool SendNewServerSettings()
{
	local R6GameReplicationInfo pGameRepInfo;
	local R6PlayerController pPlayContr;
	local R6WindowListGeneral pTempButList, pTempCamList;
	local int iTempValue;
	local bool bTempValue, bSettingsChange, bLogSettingsChange;

	// End:0x0D
	if(__NFUN_129__(m_bServerSettingsChange))
	{
		return false;
	}
	pTempButList = R6WindowListGeneral(GetList(GetCurrentGameMode(), 1));
	pTempCamList = R6WindowListGeneral(GetList(GetCurrentGameMode(), 2));
	pGameRepInfo = R6GameReplicationInfo(R6MenuInGameMultiPlayerRootWindow(Root).m_R6GameMenuCom.m_GameRepInfo);
	pPlayContr = R6PlayerController(GetPlayerOwner());
	// End:0xAB
	if(__NFUN_132__(__NFUN_132__(__NFUN_132__(__NFUN_114__(pTempButList, none), __NFUN_114__(pTempCamList, none)), __NFUN_114__(pGameRepInfo, none)), __NFUN_114__(pPlayContr, none)))
	{
		return false;
	}
	iTempValue = m_pButtonsDef.GetButtonCounterValue(int(2), pTempButList);
	// End:0x108
	if(__NFUN_155__(iTempValue, __NFUN_145__(pGameRepInfo.TimeLimit, 60)))
	{
		bSettingsChange = true;
		pPlayContr.ServerNewGeneralSettings(2,, __NFUN_144__(iTempValue, 60));
	}
	iTempValue = m_pButtonsDef.GetButtonCounterValue(int(7), pTempButList);
	// End:0x16A
	if(__NFUN_181__(float(iTempValue), pGameRepInfo.m_fTimeBetRounds))
	{
		bSettingsChange = true;
		__NFUN_132__(pPlayContr.ServerNewGeneralSettings(7,, iTempValue), bSettingsChange);
	}
	iTempValue = m_pButtonsDef.GetButtonCounterValue(int(3), pTempButList);
	// End:0x1D0
	if(__NFUN_130__(__NFUN_151__(iTempValue, -1), __NFUN_155__(iTempValue, pGameRepInfo.m_MaxPlayers)))
	{
		bSettingsChange = true;
		pPlayContr.ServerNewGeneralSettings(3,, iTempValue);
	}
	bTempValue = m_pButtonsDef.GetButtonBoxValue(int(11), pTempButList);
	// End:0x228
	if(__NFUN_243__(bTempValue, pGameRepInfo.m_bFriendlyFire))
	{
		bSettingsChange = true;
		pPlayContr.ServerNewGeneralSettings(11, bTempValue);
	}
	// End:0x2C9
	if(__NFUN_119__(m_pButtonsDef.FindButtonItem(int(14), pTempButList), none))
	{
		// End:0x271
		if(m_pButtonsDef.IsButtonBoxDisabled(int(14), pTempButList))
		{
			bTempValue = m_bBkpTKPenalty;			
		}
		else
		{
			bTempValue = m_pButtonsDef.GetButtonBoxValue(int(14), pTempButList);
		}
		// End:0x2C9
		if(__NFUN_243__(bTempValue, pGameRepInfo.m_bMenuTKPenaltySetting))
		{
			bSettingsChange = true;
			pPlayContr.ServerNewGeneralSettings(14, bTempValue);
		}
	}
	// End:0x33F
	if(__NFUN_119__(m_pButtonsDef.FindButtonItem(int(15), pTempButList), none))
	{
		bTempValue = m_pButtonsDef.GetButtonBoxValue(int(15), pTempButList);
		// End:0x33F
		if(__NFUN_243__(bTempValue, pGameRepInfo.m_bRepAllowRadarOption))
		{
			bSettingsChange = true;
			pPlayContr.ServerNewGeneralSettings(15, bTempValue);
		}
	}
	// End:0x3B5
	if(__NFUN_119__(m_pButtonsDef.FindButtonItem(int(12), pTempButList), none))
	{
		bTempValue = m_pButtonsDef.GetButtonBoxValue(int(12), pTempButList);
		// End:0x3B5
		if(__NFUN_243__(bTempValue, pGameRepInfo.m_bShowNames))
		{
			bSettingsChange = true;
			pPlayContr.ServerNewGeneralSettings(12, bTempValue);
		}
	}
	// End:0x42B
	if(__NFUN_119__(m_pButtonsDef.FindButtonItem(int(18), pTempButList), none))
	{
		bTempValue = m_pButtonsDef.GetButtonBoxValue(int(18), pTempButList);
		// End:0x42B
		if(__NFUN_243__(bTempValue, pGameRepInfo.m_bFFPWeapon))
		{
			bSettingsChange = true;
			pPlayContr.ServerNewGeneralSettings(18, bTempValue);
		}
	}
	bTempValue = GetCameraSelection(int(24), pTempCamList);
	// End:0x47F
	if(__NFUN_243__(bTempValue, __NFUN_151__(__NFUN_156__(pGameRepInfo.m_iDeathCameraMode, 1), 0)))
	{
		bSettingsChange = true;
		pPlayContr.ServerNewGeneralSettings(24, bTempValue);
	}
	bTempValue = GetCameraSelection(int(25), pTempCamList);
	// End:0x4D4
	if(__NFUN_243__(bTempValue, __NFUN_151__(__NFUN_156__(pGameRepInfo.m_iDeathCameraMode, 2), 0)))
	{
		bSettingsChange = true;
		pPlayContr.ServerNewGeneralSettings(25, bTempValue);
	}
	bTempValue = GetCameraSelection(int(26), pTempCamList);
	// End:0x529
	if(__NFUN_243__(bTempValue, __NFUN_151__(__NFUN_156__(pGameRepInfo.m_iDeathCameraMode, 4), 0)))
	{
		bSettingsChange = true;
		pPlayContr.ServerNewGeneralSettings(26, bTempValue);
	}
	bTempValue = GetCameraSelection(int(27), pTempCamList);
	// End:0x57E
	if(__NFUN_243__(bTempValue, __NFUN_151__(__NFUN_156__(pGameRepInfo.m_iDeathCameraMode, 8), 0)))
	{
		bSettingsChange = true;
		pPlayContr.ServerNewGeneralSettings(27, bTempValue);
	}
	// End:0x76D
	if(__NFUN_122__(m_pOptionsGameMode.GetValue2(), string(m_ANbOfGameMode[0])))
	{
		bTempValue = GetCameraSelection(int(28), pTempCamList);
		// End:0x5F0
		if(__NFUN_243__(bTempValue, __NFUN_151__(__NFUN_156__(pGameRepInfo.m_iDeathCameraMode, 16), 0)))
		{
			bSettingsChange = true;
			pPlayContr.ServerNewGeneralSettings(28, bTempValue);
		}
		bTempValue = GetCameraSelection(int(29), pTempCamList);
		// End:0x645
		if(__NFUN_243__(bTempValue, __NFUN_151__(__NFUN_156__(pGameRepInfo.m_iDeathCameraMode, 32), 0)))
		{
			bSettingsChange = true;
			pPlayContr.ServerNewGeneralSettings(29, bTempValue);
		}
		iTempValue = m_pButtonsDef.GetButtonCounterValue(int(4), pTempButList);
		// End:0x6BD
		if(__NFUN_181__(float(iTempValue), pGameRepInfo.m_fBombTime))
		{
			bSettingsChange = true;
			pPlayContr.ServerNewGeneralSettings(4,, iTempValue);
			// End:0x6BD
			if(bLogSettingsChange)
			{
				__NFUN_231__("EBN_BombTimer change");
			}
		}
		iTempValue = m_pButtonsDef.GetButtonCounterValue(int(1), pTempButList);
		// End:0x712
		if(__NFUN_155__(iTempValue, pGameRepInfo.m_iRoundsPerMatch))
		{
			bSettingsChange = true;
			pPlayContr.ServerNewGeneralSettings(1,, iTempValue);
		}
		bTempValue = m_pButtonsDef.GetButtonBoxValue(int(13), pTempButList);
		// End:0x76A
		if(__NFUN_243__(bTempValue, pGameRepInfo.m_bAutoBalance))
		{
			bSettingsChange = true;
			pPlayContr.ServerNewGeneralSettings(13, bTempValue);
		}		
	}
	else
	{
		iTempValue = m_pButtonsDef.GetButtonCounterValue(int(6), pTempButList);
		// End:0x7C2
		if(__NFUN_155__(iTempValue, pGameRepInfo.m_iRoundsPerMatch))
		{
			bSettingsChange = true;
			pPlayContr.ServerNewGeneralSettings(6,, iTempValue);
		}
		iTempValue = m_pButtonsDef.GetButtonCounterValue(int(8), pTempButList);
		// End:0x817
		if(__NFUN_155__(iTempValue, pGameRepInfo.m_iNbOfTerro))
		{
			bSettingsChange = true;
			pPlayContr.ServerNewGeneralSettings(8,, iTempValue);
		}
		bTempValue = m_pButtonsDef.GetButtonBoxValue(int(17), pTempButList);
		// End:0x86F
		if(__NFUN_243__(bTempValue, pGameRepInfo.m_bAIBkp))
		{
			bSettingsChange = true;
			pPlayContr.ServerNewGeneralSettings(17, bTempValue);
		}
		bTempValue = m_pButtonsDef.GetButtonBoxValue(int(16), pTempButList);
		// End:0x8C7
		if(__NFUN_243__(bTempValue, pGameRepInfo.m_bRotateMap))
		{
			bSettingsChange = true;
			pPlayContr.ServerNewGeneralSettings(16, bTempValue);
		}
		iTempValue = int(m_pButtonsDef.GetButtonComboValue(int(23), pTempButList));
		// End:0x91E
		if(__NFUN_155__(iTempValue, pGameRepInfo.m_iDiffLevel))
		{
			bSettingsChange = true;
			pPlayContr.ServerNewGeneralSettings(23,, iTempValue);
		}
	}
	return bSettingsChange;
	return;
}

//=================================================================================
// SendNewMapSettings: Send the new map server settings to the server, only the change values. 
//					   If no modification was made return false 
//=================================================================================
function bool SendNewMapSettings(out byte _bMapCount)
{
	local R6MenuInGameMultiPlayerRootWindow r6Root;
	local R6GameReplicationInfo R6GameRepInfo;
	local R6PlayerController pPlayContr;
	local string szCurrentSrvMap, szMenuMap, szCurrentSrvGameType, szMenuGameType;
	local int i, iTotFinalListItem, iTotGameRepItem, iTotalMax, iLastValidItem, iUpdate;

	local bool bSettingsChange;

	// End:0x0D
	if(__NFUN_129__(m_bServerSettingsChange))
	{
		return false;
	}
	r6Root = R6MenuInGameMultiPlayerRootWindow(Root);
	R6GameRepInfo = R6GameReplicationInfo(r6Root.m_R6GameMenuCom.m_GameRepInfo);
	pPlayContr = R6PlayerController(GetPlayerOwner());
	_bMapCount = FillSelectedMapList();
	// End:0x6B
	if(__NFUN_154__(int(_bMapCount), 0))
	{
		return true;
	}
	i = 0;
	J0x72:

	// End:0xAE [Loop If]
	if(__NFUN_130__(__NFUN_150__(i, R6GameRepInfo.32), __NFUN_123__(R6GameRepInfo.m_mapArray[i], "")))
	{
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x72;
	}
	iTotGameRepItem = i;
	iTotFinalListItem = m_SelectedMapList.Length;
	// End:0xD9
	if(__NFUN_151__(iTotFinalListItem, 32))
	{
		iTotFinalListItem = 32;
	}
	iTotalMax = iTotFinalListItem;
	i = 0;
	J0xEB:

	// End:0x1E6 [Loop If]
	if(__NFUN_150__(i, iTotalMax))
	{
		szCurrentSrvMap = R6GameRepInfo.m_mapArray[i];
		szMenuMap = m_SelectedMapList[i];
		szCurrentSrvGameType = GetLevel().GetGameTypeFromClassName(R6GameRepInfo.m_gameModeArray[i]);
		szMenuGameType = m_SelectedModeList[i];
		iUpdate = 0;
		// End:0x17E
		if(__NFUN_123__(szCurrentSrvMap, szMenuMap))
		{
			__NFUN_161__(iUpdate, 1);
		}
		// End:0x196
		if(__NFUN_123__(szCurrentSrvGameType, szMenuGameType))
		{
			__NFUN_161__(iUpdate, 2);
		}
		// End:0x1DC
		if(__NFUN_155__(iUpdate, 0))
		{
			pPlayContr.ServerNewMapListSettings(i, iUpdate, GetLevel().GetGameTypeClassName(szMenuGameType), szMenuMap);
			bSettingsChange = true;
		}
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0xEB;
	}
	// End:0x231
	if(__NFUN_151__(iTotGameRepItem, iTotFinalListItem))
	{
		pPlayContr.ServerNewMapListSettings(i, 0, GetLevel().GetGameTypeClassName(szMenuGameType), szMenuMap, i);
		bSettingsChange = true;
	}
	return bSettingsChange;
	return;
}

//=================================================================================
// Notify: Overload parent notify to avoid button selection, except for the host of the game
//=================================================================================
function Notify(UWindowDialogControl C, byte E)
{
	// End:0x39
	if(__NFUN_129__(m_bImAnAdmin))
	{
		// End:0x37
		if(__NFUN_154__(int(E), 1))
		{
			// End:0x37
			if(C.__NFUN_303__('UWindowComboControl'))
			{
				ManageComboControlNotify(C);
			}
		}
		return;
	}
	// End:0x60
	if(C.__NFUN_303__('R6WindowButton'))
	{
		ManageR6ButtonNotify(C, E);		
	}
	else
	{
		// End:0xB2
		if(__NFUN_154__(int(E), 2))
		{
			// End:0x90
			if(C.__NFUN_303__('R6WindowButtonBox'))
			{
				ManageR6ButtonBoxNotify(C);				
			}
			else
			{
				// End:0xAF
				if(C.__NFUN_303__('R6WindowButtonAndEditBox'))
				{
					ManageR6ButtonAndEditBoxNotify(C);
				}
			}			
		}
		else
		{
			// End:0xDE
			if(__NFUN_154__(int(E), 1))
			{
				// End:0xDE
				if(C.__NFUN_303__('UWindowComboControl'))
				{
					ManageComboControlNotify(C);
				}
			}
		}
	}
	// End:0xEF
	if(m_bInitComplete)
	{
		m_bServerSettingsChange = true;
	}
	return;
}

