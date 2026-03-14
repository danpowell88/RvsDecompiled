//=============================================================================
//  R6ModMgr.uc : 
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//=============================================================================
class R6ModMgr extends Object
    native;

// --- Variables ---
// var ? m_aObjects; // REMOVED IN 1.60
// var ? m_pMP1; // REMOVED IN 1.60
// var ? m_pMP2; // REMOVED IN 1.60
// the game type corresponding table (compatibility with code before/after sdk)
var array<array> m_aGameTypeCorrTable;
var R6Mod m_pCurrentMod;
var array<array> m_aMods;
var R6Mod m_pRVS;
var R6UPackageMgr m_pUPackageMgr;
var bool bShowLog;
// used when the server is started by Ubi.com
var string m_szPendingModName;

// --- Functions ---
// function ? DebugRegisterObject(...); // REMOVED IN 1.60
// function ? InitAllModObjects(...); // REMOVED IN 1.60
// function ? RegisterObject(...); // REMOVED IN 1.60
// function ? SetPendingMODFromGSName(...); // REMOVED IN 1.60
// function ? UnRegisterAllObject(...); // REMOVED IN 1.60
// function ? UnRegisterObject(...); // REMOVED IN 1.60
final native function AddNewModExtraPath(int iResetPaths, R6Mod pMod) {}
// ^ NEW IN 1.60
final native function SetGeneralModSettings(R6Mod pMod) {}
// ^ NEW IN 1.60
final native function bool IsOfficialMod(string _szName) {}
// ^ NEW IN 1.60
final native function CallSndEngineInit(Level pLevel) {}
// ^ NEW IN 1.60
function class<Pawn> GetDefaultPilotPawn() {}
// ^ NEW IN 1.60
event string GetGameTypeName(int _iIndex) {}
// ^ NEW IN 1.60
function bool CheckValidModVersion(R6Mod pModToCheck) {}
// ^ NEW IN 1.60
function bool IsGameTypeAvailable(string szGameType) {}
// ^ NEW IN 1.60
function string GetCampaignMapDir(string szIniCampaignName) {}
// ^ NEW IN 1.60
event int GetGameTypeIndex(string _szGameType) {}
// ^ NEW IN 1.60
function R6Mod GetModInstance(string szKeyWord) {}
// ^ NEW IN 1.60
function FindExtraMods(R6Mod pCurrentMod) {}
function AddGameTypes(LevelInfo pLevelInfo) {}
function IsMapAvailable(Console pConsole, string szKeyWord) {}
function class<Pawn> GetDefaultRainbowPawn(int Index) {}
// ^ NEW IN 1.60
function class<Actor> GetCurrentReticule(string ReticuleID) {}
// ^ NEW IN 1.60
event SetCurrentMod(string szKeyWord, LevelInfo pLevelInfo, optional Console pConsole, optional Level pLevel, optional bool bInitSystem) {}
///////////////////////////////////////////////////////////
// Init Mod,create the package manager
// fill the aMod array and load the mod's ini
event InitModMgr() {}
final native function SetSystemMod() {}
// ^ NEW IN 1.60
final native function int GetASBuildVersion() {}
// ^ NEW IN 1.60
final native function int GetIWBuildVersion() {}
// ^ NEW IN 1.60
event int GetNbMods() {}
// ^ NEW IN 1.60
event bool IsMissionPack() {}
// ^ NEW IN 1.60
event bool IsRavenShield() {}
// ^ NEW IN 1.60
function R6UPackageMgr GetPackageMgr() {}
// ^ NEW IN 1.60
event string GetBackgroundsRoot() {}
// ^ NEW IN 1.60
event string GetVideosRoot() {}
// ^ NEW IN 1.60
event string GetDefaultCampaignDir() {}
// ^ NEW IN 1.60
event string GetCampaignDir() {}
// ^ NEW IN 1.60
event string GetIniFilesDir() {}
// ^ NEW IN 1.60
event string GetMapsDir() {}
// ^ NEW IN 1.60
function class<HUD> GetDefaultHUD() {}
// ^ NEW IN 1.60
function class<AIController> GetDefaultRainbowAI() {}
// ^ NEW IN 1.60
function string GetCreditsFile() {}
// ^ NEW IN 1.60
function string GetMenuDefFile() {}
// ^ NEW IN 1.60
event string GetServerIni() {}
// ^ NEW IN 1.60
event string GetModKeyword() {}
// ^ NEW IN 1.60
event string GetModName() {}
// ^ NEW IN 1.60
//==================== COMPATIBILITY SECTION ===========================================================
// keep compatibilty with previous version until Ubi.com update their GSClient stuff
// THE ORDER IS IMPORTANT AND THE NAME TOO
function FillCorrepondanceTable() {}

defaultproperties
{
}
