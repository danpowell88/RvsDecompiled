//=============================================================================
// R6WindowListServerItem - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6WindowListBoxItem.uc : Class used to hold the values for the entries
//  in the list of servers in the multi player menu.
//
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/28 * Created by John Bennett
//=============================================================================
class R6WindowListServerItem extends UWindowListBoxItem;

enum eServerItem
{
	eSI_Favorites,                  // 0
	eSI_Locked,                     // 1
	eSI_Dedicated,                  // 2
	eSI_PunkBuster,                 // 3
	eSI_ServerName,                 // 4
	eSI_Ping,                       // 5
	eSI_GameType,                   // 6
	eSI_GameMode,                   // 7
	eSI_Map,                        // 8
	eSI_Players                     // 9
};

var int iPing;  // Ping time to server
var int iMaxPlayers;  // Max number of players allowed
var int iNumPlayers;  // Current number of players
var int iMainSvrListIdx;  // The index of this intem in the main server list
var bool bFavorite;  // Favorite server
var bool bLocked;  // Server requires a password
var bool bDedicated;  // Server is a dedicated server
//#ifdefR6PUNKBUSTER
var bool bPunkBuster;  // Server with punk buster
var bool bSameVersion;  // The server s the same version as the client
var bool m_bNewItem;  // it's a new item
var stCoordItem m_stServerItemPos[10];
//#endif
var string szIPAddr;  // IP Address of server, eg 1.2.3.4
var string szName;  // Name of server
var string szGameMode;  // Game mode (adversarial or cooperative)
var string szMap;  // Map name (first map to be played)
var string szGameType;  // Game type (deathmatch, Mission, etc).

function Created()
{
	m_bNewItem = true;
	m_stServerItemPos[int(0)].fXPos = 0.0000000;
	m_stServerItemPos[int(0)].fWidth = 15.0000000;
	m_stServerItemPos[int(1)].fXPos = (m_stServerItemPos[int(0)].fXPos + m_stServerItemPos[int(0)].fWidth);
	m_stServerItemPos[int(1)].fWidth = 15.0000000;
	m_stServerItemPos[int(2)].fXPos = (m_stServerItemPos[int(1)].fXPos + m_stServerItemPos[int(1)].fWidth);
	m_stServerItemPos[int(2)].fWidth = 15.0000000;
	m_stServerItemPos[int(3)].fXPos = (m_stServerItemPos[int(2)].fXPos + m_stServerItemPos[int(2)].fWidth);
	m_stServerItemPos[int(3)].fWidth = 15.0000000;
	m_stServerItemPos[int(4)].fXPos = (m_stServerItemPos[int(3)].fXPos + m_stServerItemPos[int(3)].fWidth);
	m_stServerItemPos[int(4)].fWidth = 155.0000000;
	m_stServerItemPos[int(5)].fXPos = (m_stServerItemPos[int(4)].fXPos + m_stServerItemPos[int(4)].fWidth);
	m_stServerItemPos[int(5)].fWidth = 40.0000000;
	m_stServerItemPos[int(6)].fXPos = (m_stServerItemPos[int(5)].fXPos + m_stServerItemPos[int(5)].fWidth);
	m_stServerItemPos[int(6)].fWidth = 100.0000000;
	m_stServerItemPos[int(7)].fXPos = (m_stServerItemPos[int(6)].fXPos + m_stServerItemPos[int(6)].fWidth);
	m_stServerItemPos[int(7)].fWidth = 100.0000000;
	m_stServerItemPos[int(8)].fXPos = (m_stServerItemPos[int(7)].fXPos + m_stServerItemPos[int(7)].fWidth);
	m_stServerItemPos[int(8)].fWidth = 100.0000000;
	m_stServerItemPos[int(9)].fXPos = (m_stServerItemPos[int(8)].fXPos + m_stServerItemPos[int(8)].fWidth);
	m_stServerItemPos[int(9)].fWidth = 63.0000000;
	return;
}

