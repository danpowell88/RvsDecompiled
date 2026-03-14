//=============================================================================
//  R6GameReplicationInfo.uc : Replicates R6-specific per-game state to all clients.
//  Extends GameReplicationInfo with map name, team details, and mission parameters.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/09/10 * Created by Aristomenis Kolokathis
//=============================================================================
class R6GameReplicationInfo extends GameReplicationInfo
    native;

// --- Constants ---
const m_MapLength =  32;

// --- Variables ---
// Camer mode used for dead players
var /* replicated */ int m_iDeathCameraMode;
var R6GameMenuCom m_MenuCommunication;
var /* replicated */ string m_mapArray[32];
// Force first person weapons
var /* replicated */ bool m_bFFPWeapon;
var /* replicated */ float m_fRepMenuCountDownTime;
// The difficulty level of the terro -- in coop
var /* replicated */ int m_iDiffLevel;
var R6RainbowTeam m_RainbowTeam[3];
// AI backup
var /* replicated */ bool m_bAIBkp;
// Gadget: misceleaneous restricted
var /* replicated */ string m_szGadgMiscRes[32];
// Gadget: secondary restricted
var /* replicated */ string m_szGadgSecondayRes[32];
// Gadget: primary weapon restricted
var /* replicated */ string m_szGadgPrimaryRes[32];
var /* replicated */ string m_gameModeArray[32];
var bool bShowLog;
var /* replicated */ string m_szCurrGameType;
var /* replicated */ int m_MaxPlayers;
var /* replicated */ int m_iRoundsPerMatch;
// The number of terro -- in coop
var /* replicated */ int m_iNbOfTerro;
var /* replicated */ float m_fTimeBetRounds;
var /* replicated */ bool m_bFriendlyFire;
var /* replicated */ bool m_bAutoBalance;
// This is the Team killer penalty setting as set in the menus
var /* replicated */ bool m_bMenuTKPenaltySetting;
var /* replicated */ bool m_bShowNames;
var /* replicated */ float m_fBombTime;
// The server is a internet server
var /* replicated */ bool m_bInternetSvr;
// The server is a dedicated server
var /* replicated */ bool m_bDedicatedSvr;
// in coop, rotate map automatically if it's true
var /* replicated */ bool m_bRotateMap;
var int m_iMenuCountDownTime;
var /* replicated */ bool m_bRepMenuCountDownTimePaused;
var /* replicated */ bool m_bRepMenuCountDownTimeUnlimited;
var const int c_iTeamNumBravo;
// in some game type, the writablemap can't be used (ie: deathmatch)
var /* replicated */ bool m_bIsWritableMapAllowed;
var /* replicated */ int m_aTeamScore[2];
var float m_fRepMenuCountDownTimeLastUpdate;
// this is the Team killer penalty setting as seen by the game mode
var /* replicated */ bool m_bTKPenalty;
// Secondary weapon: Machine pistols restricted
var /* replicated */ string m_szMachPistolRes[32];
// Secondary weapon: Pistols restricted
var /* replicated */ string m_szPistolRes[32];
// Primary weapon: Sniper rifles restricted
var /* replicated */ string m_szSnipRifleRes[32];
// Primary weapon: Machine Guns restricted
var /* replicated */ string m_szMachGunRes[32];
// Primary weapon: Assault rifles restricted
var /* replicated */ string m_szAssRifleRes[32];
// Primary weapon: Shotguns restricted
var /* replicated */ string m_szShotGunRes[32];
// Primary weapon: List of restricted sub maching guns
var /* replicated */ string m_szSubMachineGunsRes[32];
var /* replicated */ bool m_bAdminPasswordReq;
var /* replicated */ bool m_bPasswordReq;
//var FLOAT         m_fTimeMap;
// this is the current round in this match
var /* replicated */ int m_iCurrentRound;

// --- Functions ---
simulated function ControllerStarted(R6GameMenuCom NewMenuCom) {}
simulated event Tick(float fDeltaTime) {}
simulated function RefreshMPInfoPlayerStats() {}
simulated event SaveRemoteServerSettings(string NewServerFile) {}
simulated event NewServerState() {}
simulated function RefreshMPlayerInfo() {}
function PlaySoundStatus() {}
simulated event Destroyed() {}
simulated event float GetRoundTime() {}
// ^ NEW IN 1.60
simulated function FirstPassReset() {}

defaultproperties
{
}
