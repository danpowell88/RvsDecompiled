//=============================================================================
//  R6MenuMPInterHeader.uc : Intermission widget (when you press start during MP game or 
//  the size of the window is 640 * 480. The part in the top of multi menu in-game
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/04/25 * Created  Yannick Joly
//=============================================================================
class R6MenuMPInterHeader extends UWindowWindow;

// --- Constants ---
const C_iSERVER_NAME =  0;
const C_iSERVER_IP =  1;
const C_iMAP_NAME =  2;
const C_iGAME_TYPE =  3;
const C_iROUND =  4;
const C_iTIME_PER_ROUND =  5;
const C_iTOT_GREEN_TEAM_VICTORY =  6;
const C_iTOT_RED_TEAM_VICTORY =  7;
const C_iMISSION_STATUS =  8;
const C_fXBORDER_OFFSET =  2;
const C_fXTEXT_HEADER_OFFSET =  4;
const C_fYPOS_OF_TEAMSCORE =  48;

// --- Variables ---
// all the names for the header
var R6WindowTextLabelExt m_pTextHeader;
// array of text label (6 is for nb of server info + 2 for team case + 1 mission status)
var int m_iIndex[9];
var string m_szGameResult[5];
// display the win games for each team
var bool m_bDisplayTotVictory;
var bool m_bDisplayCoopBox;
// display the coop mission status
var bool m_bDisplayCoopStatus;

// --- Functions ---
//===============================================================================
// Init text header
//===============================================================================
function InitTextHeader() {}
//===============================================================================
// Refresh server header info
//===============================================================================
function RefreshInterHeaderInfo() {}
function Paint(Canvas C, float X, float Y) {}
//===============================================================================
// DrawTeamScore: Display a box with a background (use for team score and mission progress)
//===============================================================================
function DrawTeamScore(Canvas C, float _fY, float _fX, float _fW, float _fH, Color _cTeamColor, Color _cBGColor) {}
function RefreshRoundInfo() {}
function Created() {}
//===============================================================================
// ResetDisplayInfo:
//===============================================================================
function ResetDisplayInfo() {}
//===============================================================================
// Reset: reset all the gametype variables
//===============================================================================
function Reset() {}

defaultproperties
{
}
