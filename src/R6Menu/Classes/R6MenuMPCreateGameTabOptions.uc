//=============================================================================
//  R6MenuMPCreateGameTabOptions.uc : 
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2003/07/11  * Create by Yannick Joly
//=============================================================================
class R6MenuMPCreateGameTabOptions extends R6MenuMPCreateGameTab;

// --- Variables ---
// the current game mode selection
var R6WindowComboControl m_pOptionsGameMode;
var R6WindowButton m_pEditSkins;
// ^ NEW IN 1.60
var R6WindowEditControl m_pServerNameEdit;
var R6WindowButton m_pOptionsWelcomeMsg;
// The msg of the day pop-up
var R6WindowPopUpBox m_pMsgOfTheDayPopUp;
// OPTIONS TAB
var R6WindowTextLabelExt m_pOptionsText;
var R6WindowPopUpBox m_pPopUpChooseSkins;
// ^ NEW IN 1.60
// List of maps selected by the user
var array<array> m_SelectedMapList;
var string m_szMsgOfTheDay;
var bool m_bBkpCamGhost;
var bool m_bBkpTKPenalty;
var bool m_bBkpCamTeamOnly;
// List of game modes selected by the user
var array<array> m_SelectedModeList;
var bool m_bBkpCamFreeThirdP;
var bool m_bBkpCamThirdPerson;
var bool m_bBkpCamFirstPerson;
var bool m_bBkpCamFadeToBk;

// --- Functions ---
//===============================================================
// UpdateButtons: do the init of the buttons you need
//===============================================================
function UpdateButtons(optional bool _bUpdateValue, eCreateGameWindow_ID _eCGWindowID, EGameModeInfo _eGameMode) {}
//*******************************************************************************************
// INIT
//*******************************************************************************************
function Created() {}
//*******************************************************************************************
// NOTIFY FUNCTIONS
//*******************************************************************************************
//=================================================================
// notify the parent window by using the appropriate parent function
//=================================================================
function Notify(UWindowDialogControl C, byte E) {}
//*******************************************************************************************
// SERVER OPTIONS FUNCTIONS
//*******************************************************************************************
//=======================================================================
// RefreshServerOpt: Refresh the creategame options according the value find in class R6ServerInfo (init from server.ini)
//=======================================================================
function RefreshServerOpt(optional bool _bNewServerProfile) {}
function InitEditMsgButton() {}
function PopUpSetSkins() {}
// ^ NEW IN 1.60
//=================================================================
// manage the R6WindowButton notify message
//=================================================================
function ManageR6ButtonNotify(UWindowDialogControl C, byte E) {}
function SetServerOptions() {}
/////////////////////////////////////////////////////////////////
// manage the ComboControl notify message
/////////////////////////////////////////////////////////////////
function ManageComboControlNotify(UWindowDialogControl C) {}
//==============================================================
// IsAdminPasswordValid: Verify if you check the box and if your password is different of nothing
//==============================================================
function bool IsAdminPasswordValid() {}
// ^ NEW IN 1.60
//==============================================================
// PopUpBoxDone: For now, we just receive the result of the message of the day pop-up
//==============================================================
function PopUpBoxDone(EPopUpID _ePopUpID, MessageBoxResult Result) {}
//*******************************************************************************************
// UTILITIES FUNCTIONS
//*******************************************************************************************
//==============================================================
// Create a list of strings containing the list of maps that the
// user has selected
//==============================================================
function byte FillSelectedMapList() {}
// ^ NEW IN 1.60
function UpdateSkinButton() {}
// ^ NEW IN 1.60
//==========================================================================
// UpdateCamSpecialCase:  For death cam and cam teamonly only
//==========================================================================
function UpdateCamSpecialCase(bool _bButtonSel, bool _bUpdateDeathCam) {}
function InitOptionsTab(optional bool _bInGame) {}
function UpdateCamera(bool _bValue, int _iButtonID, R6WindowListGeneral _pCamList, optional bool _bBackupValue, bool _bDisable) {}
//==============================================================
// PopUpMOTDEditionBox: PopUp for the message of the day
//==============================================================
function PopUpMOTDEditionBox() {}
//=====================================================================================
// GetCameraSelection: return the current selection of the button. This function exist because when the button
//						is disable the selection is store in the bkp version
//=====================================================================================
function bool GetCameraSelection(int _iButtonID, R6WindowListGeneral _pCameraList) {}
// ^ NEW IN 1.60
function InitAllMapList() {}
//=======================================================================
// UpdateAllMapList:
//=======================================================================
function UpdateAllMapList() {}
function UpdateMenuOptions(bool _bNewValue, R6WindowListGeneral _pOptionsList, int _iButID, optional bool _bChangeByUserClick) {}
function InitAdminPassword(float _fX, float _fY, float _fW, float _fH) {}
function InitPassword(float _fX, float _fY, float _fW, float _fH) {}
//==============================================================
// GetCreateGamePassword: get the create game password
//==============================================================
function string GetCreateGamePassword() {}
// ^ NEW IN 1.60
function InitEditSkinsButton() {}
// ^ NEW IN 1.60

defaultproperties
{
}
