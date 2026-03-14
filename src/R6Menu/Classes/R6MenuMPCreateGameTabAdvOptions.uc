//=============================================================================
//  R6MenuMPCreateGameTabAdvOptions.uc : class for advanced options
//
//  Copyright 2003 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2003/07/10  * Create by Yannick Joly
//=============================================================================
class R6MenuMPCreateGameTabAdvOptions extends R6MenuMPCreateGameTab;

// --- Variables ---
// var ? m_pAdvOptionsLineW; // REMOVED IN 1.60
var R6WindowTextLabelExt m_pOptionsTextAdv;
// ^ NEW IN 1.60
var bool m_bBkpCamGhost;
// ^ NEW IN 1.60
var bool m_bBkpCamTeamOnly;
// ^ NEW IN 1.60
var bool m_bBkpCamFirstPerson;
// ^ NEW IN 1.60
var bool m_bBkpCamThirdPerson;
// ^ NEW IN 1.60
var bool m_bBkpCamFreeThirdP;
// ^ NEW IN 1.60
var bool m_bBkpCamFadeToBk;
// ^ NEW IN 1.60

// --- Functions ---
function UpdateMenuOptions(bool _bNewValue, int _iButID, optional bool _bChangeByUserClick, R6WindowListGeneral _pOptionsList) {}
// ^ NEW IN 1.60
//===============================================================
// UpdateButtons: do the init of the buttons you need
//===============================================================
function UpdateButtons(optional bool _bUpdateValue, eCreateGameWindow_ID _eCGWindowID, EGameModeInfo _eGameMode) {}
function UpdateCamSpecialCase(bool _bButtonSel, bool _bUpdateDeathCam) {}
// ^ NEW IN 1.60
//*******************************************************************************************
// SERVER OPTIONS FUNCTIONS
//*******************************************************************************************
function SetServerOptions() {}
function UpdateCamera(bool _bValue, int _iButtonID, R6WindowListGeneral _pCamList, optional bool _bBackupValue, bool _bDisable) {}
// ^ NEW IN 1.60
function InitAdvOptionsTab(optional bool _bInGame) {}
function bool GetCameraSelection(int _iButtonID, R6WindowListGeneral _pCameraList) {}
// ^ NEW IN 1.60
//*******************************************************************************************
// INIT
//*******************************************************************************************
function Created() {}

defaultproperties
{
}
