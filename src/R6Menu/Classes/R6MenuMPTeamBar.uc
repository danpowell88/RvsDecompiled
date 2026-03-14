//=============================================================================
//  R6MenuMPTeamBar.uc : The team bar with the name of each player and theirs stats
//  the size of the window is 640 * 480
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/04/25 * Created  Yannick Joly
//=============================================================================
class R6MenuMPTeamBar extends UWindowWindow;

// --- Constants ---
const C_fTEAMBAR_ICON_HEIGHT =  15;
const C_fTEAMBAR_TOT_HEIGHT =  12;
const C_iMISSION_TITLE_H =  20;
const C_iREADY =  0;
const C_iTEAM_NAME =  1;
const C_iROUNDSWON =  2;
const C_iNUMBER_OF_KILLS =  3;
const C_iNUMBER_OF_MYDEAD =  4;
const C_iPERCENT_EFFICIENT =  5;
const C_iROUND_FIRED =  6;
const C_iTOT_ROUND_TAKEN =  7;
const C_iTOTAL_TEAM_STATUS =  8;
const C_iPLAYER_MAX =  16;

// --- Enums ---
enum eIconType 
{
	IT_Ready,
	IT_Health,
	IT_RoundsWon,
	IT_Kill,		// X icon
	IT_DeadCounter, // Skull icon
	IT_Efficiency,	// % icon
	IT_RoundFired,  // Bullet icon
	IT_RoundTaken,	// Target icon
	IT_KillerName,	// Gun icon
	IT_Ping
};
enum eMenuLayout
{
	eML_Ready,
	eML_HealthStatus,
	eML_Name,
	eML_RoundsWon,
	eML_Kill,
	eML_DeadCounter,
	eML_Efficiency,
	eML_RoundFired,
	eML_RoundHit,
	eML_KillerName,
	eML_PingTime
};

// --- Structs ---
struct stCoord
{
    var FLOAT    fXPos;
    var FLOAT    fWidth;
};

// --- Variables ---
// var ? fWidth; // REMOVED IN 1.60
// var ? fXPos; // REMOVED IN 1.60
// the coordinates of all menu
var stCoord m_stMenuCoord[11];
// display the names of the team and nb of players
var R6WindowTextLabelExt m_pTextTeamBar;
// array of text label
var int m_iIndex[9];
// List of players with scroll bar
var R6WindowIGPlayerInfoListBox m_IGPlayerInfoListBox;
// the color of the team
var Color m_vTeamColor;
// COOP
var R6WindowTextLabel m_pTitleCoop;
var R6MenuMPInGameObj m_pMissionObj;
// Team total Efficiency (hits/shot)
var int m_iTotalEfficiency;
var string m_szTeamName;
var int m_iTotalRoomTake;
// for team menu layout (team deathmatch, tema survivor, team etc!!!)
var bool m_bTeamMenuLayout;
// Team total Number of kills
var int m_iTotalKills;
// Team total Number of Dead
var int m_iTotalNbOfDead;
// Team total Rounds fired (Bullets shot by the player)
var int m_iTotalRoundsFired;
// Team total Rounds taken (Rounds that hits the player)
var int m_iTotalRoundsTaken;
// display the objectives
var bool m_bDisplayObj;
// where are the icon tex
var Texture m_TIcon;

// --- Functions ---
//=======================================================================================================
// Draw in game team bar down border. This function is right now call by DrawInGameTeamBar
//=======================================================================================================
function DrawInGameTeamBarDownBorder(Canvas C, float _fX, float _fY, float _fWidth, float _fHeight) {}
function AddItems(int _iTotalOfPlayers, int _iTeam) {}
function AddIcon(Canvas C, float _fX, float _fY, float _fWidth, float _fHeight, eIconType _eIconType) {}
//=================================================================================================
// DrawInGameTeamBar: This function draw the in-game team bar, icons and lines
//=================================================================================================
function DrawInGameTeamBar(float _fY, Canvas C, float _fHeight) {}
//===============================================================================
// Refresh server info
//===============================================================================
function RefreshTeamBarInfo(int _iTeam) {}
//=======================================================================================================
// Draw in game team bar up border. This function is right now call by DrawInGameTeamBar
//=======================================================================================================
function DrawInGameTeamBarUpBorder(Canvas C, float _fWidth, float _fY, float _fX, float _fHeight) {}
//===============================================================================
// Refresh: The fix team bar parameters are refresh (because we change the window size)
//===============================================================================
function Refresh() {}
function AddVerticalLine(Canvas C, float _fX, float _fY, float _fWidth, float _fHeight) {}
//===================================================================================
// InitMenuLayout: init menu layout (the size of the winwidth is 590)
//===================================================================================
function InitMenuLayout(int _MenuToDisplay) {}
function Paint(Canvas C, float X, float Y) {}
//===============================================================================
// Set the new parameters of this window and the child
//===============================================================================
function SetWindowSize(float _fW, float _fH, float _fX, float _fY) {}
function ClearListOfItem() {}
//===============================================================================
// Get the total height of the header ALPHA TEAM and TOTAL TEAM STATUS
//===============================================================================
function float GetPlayerListBorderHeight() {}
// ^ NEW IN 1.60
//===============================================================================
// Init text header
//===============================================================================
function InitTeamBar() {}
function InitIGPlayerInfoList() {}
function InitMissionWindows() {}

defaultproperties
{
}
