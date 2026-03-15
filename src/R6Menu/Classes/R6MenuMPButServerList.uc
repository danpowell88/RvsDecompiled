//=============================================================================
// R6MenuMPButServerList - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6MenuMPButServerList.uc : manage buttons for server list
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/08/19  * Create by Yannick Joly
//=============================================================================
class R6MenuMPButServerList extends UWindowDialogClientWindow;

const C_fX_FAVORITES = 0;
const C_fW_FAVORITES = 15;
const C_fW_LOCKED = 15;
const C_fW_DEDICATED = 15;
const C_fW_PUNKBUSTER = 15;
const C_fW_NAME = 155;
const C_fW_PING = 40;
const C_fW_GAMEMODE = 100;
const C_fW_GAMETYPE = 100;
const C_fW_MAP = 100;
const C_fW_PLAYERS = 63;

var R6WindowButtonSort m_pButFavorites;
var R6WindowButtonSort m_pButLocked;
var R6WindowButtonSort m_pButDedicated;
//#ifdefR6PUNKBUSTER
var R6WindowButtonSort m_pButPunkBuster;
//#endif
var R6WindowButtonSort m_pButPingTime;
var R6WindowButtonSort m_pButName;
var R6WindowButtonSort m_pButGameType;
var R6WindowButtonSort m_pButGameMode;
var R6WindowButtonSort m_pButMap;
var R6WindowButtonSort m_pButNumPlayers;
var R6WindowButtonSort m_pLastButtonClick;

function Created()
{
	local R6ServerList pSLDummy;
	local float fXOffset;

	pSLDummy = R6MenuMultiPlayerWidget(OwnerWindow).m_GameService;
	fXOffset = 0.0000000;
	CreateServerListButton(int(pSLDummy.0), "InfoBar_F", "InfoBar_F", fXOffset, 15.0000000, m_pButFavorites);
	(fXOffset += float(15));
	CreateServerListButton(int(pSLDummy.1), "InfoBar_L", "InfoBar_L", fXOffset, 15.0000000, m_pButLocked);
	(fXOffset += float(15));
	CreateServerListButton(int(pSLDummy.2), "InfoBar_D", "InfoBar_D", fXOffset, 15.0000000, m_pButDedicated);
	(fXOffset += float(15));
	CreateServerListButton(int(pSLDummy.3), "InfoBar_P", "InfoBar_P", fXOffset, 15.0000000, m_pButPunkBuster);
	(fXOffset += float(15));
	CreateServerListButton(int(pSLDummy.5), "InfoBar_Server", "InfoBar_Server", fXOffset, 155.0000000, m_pButName);
	(fXOffset += float(155));
	CreateServerListButton(int(pSLDummy.4), "InfoBar_Ping", "InfoBar_Ping", fXOffset, 40.0000000, m_pButPingTime);
	(fXOffset += float(40));
	CreateServerListButton(int(pSLDummy.6), "InfoBar_Type", "InfoBar_Type", fXOffset, 100.0000000, m_pButGameType);
	(fXOffset += float(100));
	CreateServerListButton(int(pSLDummy.7), "InfoBar_GameMode", "InfoBar_GameMode", fXOffset, 100.0000000, m_pButGameMode);
	(fXOffset += float(100));
	CreateServerListButton(int(pSLDummy.8), "InfoBar_Map", "InfoBar_Map", fXOffset, 100.0000000, m_pButMap);
	(fXOffset += float(100));
	CreateServerListButton(int(pSLDummy.9), "InfoBar_Players", "InfoBar_Players", fXOffset, 63.0000000, m_pButNumPlayers);
	m_pButPingTime.m_bDrawSortIcon = true;
	m_pButPingTime.m_bAscending = true;
	m_pLastButtonClick = m_pButPingTime;
	return;
}

function CreateServerListButton(int _iButtonID, string _szName, string _szTip, float _fX, float _fWidth, out R6WindowButtonSort _R6Button)
{
	_R6Button = R6WindowButtonSort(CreateControl(Class'R6Window.R6WindowButtonSort', _fX, 0.0000000, _fWidth, WinHeight, self));
	_R6Button.ToolTipString = Localize("Tip", _szTip, "R6Menu");
	_R6Button.Text = Localize("MultiPlayer", _szName, "R6Menu");
	_R6Button.Align = 2;
	_R6Button.m_buttonFont = Root.Fonts[6];
	_R6Button.m_iButtonID = _iButtonID;
	return;
}

function Notify(UWindowDialogControl C, byte E)
{
	local bool bTypeOfSort;

	// End:0xE9
	if((int(E) == 2))
	{
		bTypeOfSort = R6MenuMultiPlayerWidget(OwnerWindow).m_bLastTypeOfSort;
		// End:0x44
		if((m_pLastButtonClick == none))
		{
			m_pLastButtonClick = R6WindowButtonSort(C);
		}
		m_pLastButtonClick.m_bDrawSortIcon = false;
		// End:0x7B
		if((m_pLastButtonClick == R6WindowButtonSort(C)))
		{
			bTypeOfSort = (!bTypeOfSort);			
		}
		else
		{
			m_pLastButtonClick = R6WindowButtonSort(C);
		}
		R6WindowButtonSort(C).m_bDrawSortIcon = true;
		R6WindowButtonSort(C).m_bAscending = bTypeOfSort;
		R6MenuMultiPlayerWidget(OwnerWindow).ResortServerList(R6WindowButtonSort(C).m_iButtonID, bTypeOfSort);
	}
	return;
}

