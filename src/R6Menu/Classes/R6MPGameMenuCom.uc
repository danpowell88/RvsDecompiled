//=============================================================================
//  R6MPGameMenuCom.uc : the interface between server and menu 
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/04/29 * Created by Yannick Joly
//=============================================================================
class R6MPGameMenuCom extends R6GameMenuCom;

// --- Variables ---
// var ? m_eLogOldCurrectServerState; // REMOVED IN 1.60
var R6MenuInGameMultiPlayerRootWindow m_pCurrentRoot;

// --- Functions ---
// function ? LogServerState(...); // REMOVED IN 1.60
//====================================================================================
// SetPlayerReadyStatus: Set the ready button status of the player
//====================================================================================
function SetPlayerReadyStatus(bool _bPlayerReady) {}
function SetupPlayerPrefs() {}
//=====================================================================
// SetStatMenuState : Overloaded from Parent. Set the new client menu state
//=====================================================================
function SetStatMenuState(eClientMenuState _eNewClientMenuState) {}
function SetClientServerSettings(bool _bCanChangeOptions) {}
//============================================================================================
// SetVoteResult: Set the vote result
//============================================================================================
function SetVoteResult(bool _bKickPlayer) {}
//============================================================================================
// ActiveVoteMenu: Active the vote menu -- kick or not the player
//============================================================================================
function ActiveVoteMenu(optional string _szPlayerNameToKick, bool _bActiveMenu) {}
function TKPopUpDone(bool _bApplyTeamKillerPenalty) {}
//this function is called when team killer options are on and I have been killed by my team mate
function TKPopUpBox(string _KillerName) {}
function bool IsInBetweenRoundMenu(optional bool _bIncludeCMSInit) {}
// ^ NEW IN 1.60
//====================================================================================
// SetReadyButton: Set the ready button state in the menu (disable when the player play, or enable -- spectator)
//====================================================================================
function SetReadyButton(bool _bDisable) {}
//====================================================================================
// DisconnectClient: Disconnect the client from the server
//====================================================================================
function DisconnectClient(LevelInfo _Level) {}
function PlayerSelection(ePlayerTeamSelection newTeam) {}
//===========================================================================================
// GetNbOfTeamPlayer: get the number of player of a specific team, spectator include
//===========================================================================================
function int GetNbOfTeamPlayer(bool _bGreenTeam) {}
// ^ NEW IN 1.60
// this returns an INT so that we can know where to display the player on
// the tab menu page
function int GeTTeamSelection(int _iIndex) {}
// ^ NEW IN 1.60
//====================================================================================
// GetPlayerDidASelection:
//====================================================================================
function bool GetPlayerDidASelection() {}
// ^ NEW IN 1.60
simulated function bool IsInGame() {}
// ^ NEW IN 1.60
function NewServerState() {}
function CountDownPopUpBoxDone() {}
event CountDownPopUpBox() {}
simulated function string GetGameType() {}
// ^ NEW IN 1.60
simulated function InitialisePlayerSetupInfo() {}
simulated function SavePlayerSetupInfo() {}
function RefreshReadyButtonStatus() {}
function bool IsAPlayerSelection() {}
// ^ NEW IN 1.60
function ePlayerTeamSelection GetPlayerSelection() {}
// ^ NEW IN 1.60
simulated function SelectTeam() {}

defaultproperties
{
}
