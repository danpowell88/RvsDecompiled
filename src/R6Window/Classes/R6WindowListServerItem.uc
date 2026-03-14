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

// --- Enums ---
enum eServerItem
{
	eSI_Favorites,
	eSI_Locked,
	eSI_Dedicated,
//#ifdefR6PUNKBUSTER
	eSI_PunkBuster,
//#endif
	eSI_ServerName,
	eSI_Ping,
	eSI_GameType,
	eSI_GameMode,
	eSI_Map,
	eSI_Players
};

// --- Variables ---
var stCoordItem m_stServerItemPos[10];
// Name of server
var string szName;
// Game mode (adversarial or cooperative)
var string szGameMode;
// Map name (first map to be played)
var string szMap;
// Game type (deathmatch, Mission, etc).
var string szGameType;
// it's a new item
var bool m_bNewItem;
// Current number of players
var int iNumPlayers;
// Max number of players allowed
var int iMaxPlayers;
// Ping time to server
var int iPing;
// The server s the same version as the client
var bool bSameVersion;
//#ifdefR6PUNKBUSTER
// Server with punk buster
var bool bPunkBuster;
// Server is a dedicated server
var bool bDedicated;
// Server requires a password
var bool bLocked;
// Favorite server
var bool bFavorite;
//#endif
// IP Address of server, eg 1.2.3.4
var string szIPAddr;
// The index of this intem in the main server list
var int iMainSvrListIdx;

// --- Functions ---
function Created() {}

defaultproperties
{
}
