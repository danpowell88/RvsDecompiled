//=============================================================================
//  R6WindowListBoxItem.uc : Class used to hold the values for the entries
//  in the list of servers in the multi player menu.
//
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/28 * Created by John Bennett
//=============================================================================
class R6WindowListIGPlayerInfoItem extends UWindowListBoxItem;

// --- Constants ---
const C_NB_OF_PLAYER_INFO =  11;

// --- Enums ---
enum ePlStatus
{
    ePlayerStatus_Alive,
    ePlayerStatus_Wounded,
    ePlayerStatus_Incapacitated,
    ePlayerStatus_Dead,
	ePlayerStatus_Spectator,
    ePlayerStatus_TooLate
};
enum ePLInfo
{
	ePL_Ready,
	ePL_HealthStatus,
	ePL_Name,
	ePL_RoundsWon,
	ePL_Kill,
	ePL_DeadCounter,
	ePL_Efficiency,
	ePL_RoundFired,
	ePL_RoundHit,
	ePL_KillerName,
	ePL_PingTime,
};

// --- Structs ---
struct stSettings
{
    var FLOAT    fXPos;
    var FLOAT    fWidth;
	var BOOL	 bDisplay;
};

// --- Variables ---
// var ? bDisplay; // REMOVED IN 1.60
// var ? fWidth; // REMOVED IN 1.60
// var ? fXPos; // REMOVED IN 1.60
// Variables used to define X position of the fields in the
// server list menu.
//
var stSettings stTagCoord[11];
// Status of the player at the end of the round
var ePlStatus eStatus;
// Number of kills
var int iKills;
// Efficiency (hits/shot)
var int iEfficiency;
// Rounds fired (Bullets shot by the player)
var int iRoundsFired;
// Bullets shot by the player and that hit somebody
var int iRoundsHit;
// Variables holding infomation on servers
// Player name
var string szPlName;
// This is for single player to know in wich team the rainbow is //0= Red, 1=Green, 2=Gold
var int m_iRainbowTeam;
// The player is ready
var bool bReady;
// This player is the player on this computer
var bool bOwnPlayer;
// ping (The delay between player and server communication)
var int iPingTime;
// Number of time I die
var int iMyDeadCounter;
// Nb of rounds wons on nb of round play
var string szRoundsWon;
// Kill by (This icon show the name of the killer)
var string szKillBy;
// This is usefull when we try to retreive the r6rainbow class
var int m_iOperativeID;

// --- Functions ---
function int GetHealth(ePlStatus _ePLStatus) {}

defaultproperties
{
}
