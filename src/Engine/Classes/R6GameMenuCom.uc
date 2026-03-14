//=============================================================================
//  R6GameMenuCom.uc : Native client-side menu communication object.
//  Bridges the HUD/menu system with game state: tracks team selection, player loadout prefs,
//  ready-button state, vote-kick UI, and stat-screen display mode.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/04/25 * Created by Aristomenis Kolokathis
//=============================================================================
class R6GameMenuCom extends Object
    native;

// --- Enums ---
enum eClientMenuState
{
    CMS_Initial,            // this is before we know what state the server is in
    CMS_SpecMenu,           // check tab, menus has icons
    CMS_BetRoundmenu,       // always display, has icons
    CMS_DisplayStat,        // check for tab, no icons
    CMS_DisplayForceStat,   // forced CMS_DisplayStat at end of round
    CMS_PlayerDead,          // player is dead, same thing than CMS_BetRoundmenu, but the menu is activable or not by tab
    CMS_DisplayForceStatLocked,  //Bring up the stat page and lock it
	CMS_InPreGameState		// close the gear pop-up menu...
};

// --- Structs ---
struct PlayerPrefInfo
{
    var string m_CharacterName;
    var string m_ArmorName;
    var string m_WeaponName[2];
    var string m_WeaponGadgetName[2];
    var string m_BulletType[2];
    var string m_GadgetName[2];
};

// --- Variables ---
// var ? m_ArmorName; // REMOVED IN 1.60
// var ? m_BulletType; // REMOVED IN 1.60
// var ? m_CharacterName; // REMOVED IN 1.60
// var ? m_GadgetName; // REMOVED IN 1.60
// var ? m_WeaponGadgetName; // REMOVED IN 1.60
// var ? m_WeaponName; // REMOVED IN 1.60
var PlayerController m_PlayerController;
var GameReplicationInfo m_GameRepInfo;
// this was the mode played in the last round
var string m_szPreviousGameType;
var bool bShowLog;
var eClientMenuState m_eStatMenuState;
// when this is updated, make sure to call SavePlayerSetupInfo() after;
var PlayerPrefInfo m_PlayerPrefInfo;
//Weapons Descriptions
//R6PrimaryWeaponDescription class name
var string m_szPrimaryWeapon;
//Token representing type of weapon gadget
var string m_szPrimaryWeaponGadget;
//Token representing type of bullets
var string m_szPrimaryWeaponBullet;
//R6GadgetDescription class name
var string m_szPrimaryGadget;
//R6SecondaryWeaponDescription class name
var string m_szSecondaryWeapon;
//Token representing type of weapon gadget
var string m_szSecondaryWeaponGadget;
///Token representing type of bullets
var string m_szSecondaryWeaponBullet;
//R6GadgetDescription class name
var string m_szSecondaryGadget;
//R6ArmorDescription class name
var string m_szArmor;
var int m_iLastValidIndex;
var string m_szServerName;
// used to determine if map has been rotated
var int m_iOldMapIndex;
// when we are in disconnecting process
var bool m_bImCurrentlyDisconnect;

// --- Functions ---
function ePlayerTeamSelection IntToPTS(int InInt) {}
// ^ NEW IN 1.60
function int PTSToInt(ePlayerTeamSelection inEnum) {}
// ^ NEW IN 1.60
//====================================================================================
// SetPlayerReadyStatus: Set the ready button status of the player
//====================================================================================
function SetPlayerReadyStatus(bool _bPlayerReady) {}
function PlayerSelection(ePlayerTeamSelection newTeam) {}
// PostBeginPlays are generally called on actors by native code
// since this is now an object it's PostBeginPlay get's called by
// R6MenuInGameMultiPlayerRootWindow.uc, this is the object that
// created this instance
function PostBeginPlay() {}
function ClearLevelReferences() {}
//====================================================================================
// IsInitialisationComplete: true when the initialisation is complete
//====================================================================================
function bool IsInitialisationCompleted() {}
// ^ NEW IN 1.60
//=======================================================================================
// GetGameType: Get the game mode (game type for the menus) of the game
//=======================================================================================
simulated function string GetGameType() {}
// ^ NEW IN 1.60
simulated function InitialisePlayerSetupInfo() {}
simulated function SavePlayerSetupInfo() {}
simulated function SelectTeam() {}
function SetupPlayerPrefs() {}
function TKPopUpBox(string _KillerName) {}
function TKPopUpDone(bool _bApplyTeamKillerPenalty) {}
function ActiveVoteMenu(bool _bActiveMenu, optional string _szPlayerNameToKick) {}
function SetClientServerSettings(bool _bCanChangeOptions) {}
function CountDownPopUpBox() {}
function CountDownPopUpBoxDone() {}
function LoadSoundBankInSpectator() {}
function RefreshMPlayerInfo() {}
// this returns an INT so that we can know where to display the player on
// the tab menu page
function int GeTTeamSelection(int _iIndex) {}
// ^ NEW IN 1.60
function NewServerState() {}
//=====================================================================
// SetStatMenuState : set the new statmenustate
//=====================================================================
function SetStatMenuState(eClientMenuState _eNewClientMenuState) {}
//====================================================================================
// SetReadyButton: Set the ready button state in the menu (disable when the player play or  -- spectator)
// set this to true when the game is in session, or someone joins as spectator, false otherwise
//====================================================================================
function RefreshReadyButtonStatus() {}
function SetReadyButton(bool _bDisable) {}
//====================================================================================
// GetPlayerReadyStatus: Get the ready button status of the player
//====================================================================================
function bool GetPlayerReadyStatus() {}
// ^ NEW IN 1.60
//====================================================================================
// GetPlayerDidASelection:
//====================================================================================
function bool GetPlayerDidASelection() {}
// ^ NEW IN 1.60
//====================================================================================
// DisconnectClient: Disconnect the client from the server
//====================================================================================
function DisconnectClient(LevelInfo _Level) {}
simulated function bool IsInGame() {}
// ^ NEW IN 1.60

defaultproperties
{
}
