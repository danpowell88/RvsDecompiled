//=============================================================================
//  R6MenuMPServerOption.uc : Display the server option depending if you are an admin or a client
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/05/09  * Create by Yannick Joly
//=============================================================================
class R6MenuMPServerOption extends R6MenuMPCreateGameTabOptions;

// --- Variables ---
// if the client can change the settings
var bool m_bImAnAdmin;
// fake window to hide all access buttons
var UWindowWindow m_pServerOptFakeW2;
// fake window to hide all access buttons
var UWindowWindow m_pServerOptFakeW;
// at least one of the server settings change
var bool m_bServerSettingsChange;
var R6WindowTextLabel m_InTheReleaseLabel;

// --- Functions ---
function UpdateButtons(optional bool _bUpdateValue, eCreateGameWindow_ID _eCGWindowID, EGameModeInfo _eGameMode) {}
//=================================================================================
// SendNewServerSettings: Send the new server settings to the server, only the change values.
//						  If no modification was made return false
//=================================================================================
function bool SendNewServerSettings() {}
// ^ NEW IN 1.60
//=================================================================================
// SendNewMapSettings: Send the new map server settings to the server, only the change values.
//					   If no modification was made return false
//=================================================================================
function bool SendNewMapSettings(out byte _bMapCount) {}
// ^ NEW IN 1.60
//=================================================================================
// Notify: Overload parent notify to avoid button selection, except for the host of the game
//=================================================================================
function Notify(UWindowDialogControl C, byte E) {}
//=======================================================================================
// RefreshServerOpt : Update server info menu with the values of the server
//=======================================================================================
function RefreshServerOpt(optional bool _bNewServerProfile) {}
//=======================================================================================
// Refresh : Verify is the client is now an admin
//=======================================================================================
function Refresh() {}
function Created() {}

defaultproperties
{
}
