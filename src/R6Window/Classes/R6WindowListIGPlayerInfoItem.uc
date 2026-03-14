//=============================================================================
// R6WindowListIGPlayerInfoItem - extracted from retail RavenShield 1.60
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
class R6WindowListIGPlayerInfoItem extends UWindowListBoxItem;

const C_NB_OF_PLAYER_INFO = 11;

enum ePlStatus
{
	ePlayerStatus_Alive,            // 0
	ePlayerStatus_Wounded,          // 1
	ePlayerStatus_Incapacitated,    // 2
	ePlayerStatus_Dead,             // 3
	ePlayerStatus_Spectator,        // 4
	ePlayerStatus_TooLate           // 5
};

enum ePLInfo
{
	ePL_Ready,                      // 0
	ePL_HealthStatus,               // 1
	ePL_Name,                       // 2
	ePL_RoundsWon,                  // 3
	ePL_Kill,                       // 4
	ePL_DeadCounter,                // 5
	ePL_Efficiency,                 // 6
	ePL_RoundFired,                 // 7
	ePL_RoundHit,                   // 8
	ePL_KillerName,                 // 9
	ePL_PingTime                    // 10
};

struct stSettings
{
	var float fXPos;
	var float fWidth;
	var bool bDisplay;
};

var R6WindowListIGPlayerInfoItem.ePlStatus eStatus;  // Status of the player at the end of the round
var int iKills;  // Number of kills
var int iMyDeadCounter;  // Number of time I die
var int iEfficiency;  // Efficiency (hits/shot)
var int iRoundsFired;  // Rounds fired (Bullets shot by the player)
var int iRoundsHit;  // Bullets shot by the player and that hit somebody
var int iPingTime;  // ping (The delay between player and server communication)
var int m_iRainbowTeam;  // This is for single player to know in wich team the rainbow is //0= Red, 1=Green, 2=Gold
var int m_iOperativeID;  // This is usefull when we try to retreive the r6rainbow class
var bool bOwnPlayer;  // This player is the player on this computer
var bool bReady;  // The player is ready
// NEW IN 1.60
var stSettings stTagCoord[11];
// Variables holding infomation on servers
var string szPlName;  // Player name
var string szKillBy;  // Kill by (This icon show the name of the killer)
var string szRoundsWon;  // Nb of rounds wons on nb of round play

function int GetHealth(R6WindowListIGPlayerInfoItem.ePlStatus _ePLStatus)
{
	switch(_ePLStatus)
	{
		// End:0x0E
		case 0:
			return 0;
		// End:0x15
		case 1:
			return 1;
		// End:0x1D
		case 2:
			return 2;
		// End:0x25
		case 3:
			return 3;
		// End:0x2D
		case 4:
			return 4;
		// End:0xFFFF
		default:
			return 0;
			break;
	}
	return;
}


// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var stTagCoordC_NB_OF_PLAYER_INFO
