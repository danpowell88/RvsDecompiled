//=============================================================================
//  R6MenuSingleTeamBar.uc : (add small description)
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/06/18 * Created by Alexandre Dionne
//=============================================================================
class R6MenuSingleTeamBar extends UWindowDialogControl;

// --- Constants ---
const C_fTEAMBAR_ICON_HEIGHT =  16;
const C_fTEAMBAR_MISSIONTIME_HEIGHT =  14;
const C_fTEAMBAR_TOTALS_HEIGHT =  15;
const C_fXICONS_START_POS =  0;

// --- Variables ---
var Region m_RBorder;
// ^ NEW IN 1.60
// List of players with scroll bar
var R6WindowSimpleIGPlayerListBox m_IGPlayerInfoListBox;
var R6WindowTextLabel m_TimeMissionTitle;
// ^ NEW IN 1.60
var R6WindowTextLabel m_RoundsFiredLabel;
// ^ NEW IN 1.60
var R6WindowTextLabel m_EfficiencyLabel;
// ^ NEW IN 1.60
var R6WindowTextLabel m_KillLabel;
// ^ NEW IN 1.60
var R6WindowTextLabel m_BottomTitle;
// ^ NEW IN 1.60
var Texture m_TBorder;
// ^ NEW IN 1.60
var float m_fBottomTitleWidth;
var R6WindowTextLabel m_TimeMissionValue;
// ^ NEW IN 1.60
var R6WindowTextLabel m_RoundsTakenLabel;
var Texture m_TIcon;
var float m_fHitsWidth;
// ^ NEW IN 1.60
var float m_fShotsWidth;
// ^ NEW IN 1.60
var float m_fEfficiencyWidth;
// ^ NEW IN 1.60
var float m_fSkullWidth;
// ^ NEW IN 1.60
// Team total Rounds fired (Bullets shot by the player)
var int m_iTotalRoundsFired;
var int m_IBorderVOffset;
// Team total Number of kills
var int m_iTotalNeutralized;
// Team total Efficiency (hits/shot)
var int m_iTotalEfficiency;
// Team total Rounds taken (Rounds that hits the player)
var int m_iTotalRoundsTaken;
var int m_IFirstItempYOffset;
var bool m_bDrawBorders;
var float m_fTeamcolorWidth;
// ^ NEW IN 1.60
var float m_fRainbowWidth;
// ^ NEW IN 1.60
var float m_fHealthWidth;
// ^ NEW IN 1.60
var bool m_bDrawTotalsShading;
//Put some padding at the left of the player name
var int m_INameTextPadding;
var bool bShowLog;
var Texture m_THighLight;
var Region m_RHighLight;

// --- Functions ---
function Register(UWindowDialogClientWindow W) {}
function DrawInGameSingleTeamBar(Canvas C, float _fHeight, float _fY, float _fX) {}
function AddItems() {}
function Created() {}
function Paint(Canvas C, float X, float Y) {}
function DrawInGameSingleTeamBarUpBorder(Canvas C, float _fX, float _fY, float _fWidth, float _fHeight) {}
function DrawInGameSingleTeamBarDownBorder(Canvas C, float _fY, float _fHeight, float _fWidth, float _fX) {}
function DrawInGameSingleTeamBarMiddleBorder(Canvas C, float _fY, float _fX, float _fWidth, float _fHeight) {}
//===============================================================================
// Refresh server info
//===============================================================================
function RefreshTeamBarInfo() {}
function ClearListOfItem() {}
//===============================================================================
// Get the total height of the header ALPHA TEAM and TOTAL TEAM STATUS
//===============================================================================
function float GetPlayerListBorderHeight() {}
// ^ NEW IN 1.60
function CreateIGPListBox() {}
function Resize() {}

defaultproperties
{
}
