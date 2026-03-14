//=============================================================================
//  R6Mod.uc : 
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//=============================================================================
class R6Mod extends Object
    native
    config;

// --- Constants ---
const C_iR6ModVersion =  1;

// --- Structs ---
struct ReticuleListElement
{
    var string m_szReticuleClassName;
    var string m_szReticuleId;
};

// --- Variables ---
// var ? m_aExtraModMaps; // REMOVED IN 1.60
// var ? m_bInstalled; // REMOVED IN 1.60
// var ? m_szCampaignDir; // REMOVED IN 1.60
// var ? m_szGameServiceGameName; // REMOVED IN 1.60
// var ? m_szIniFilesDir; // REMOVED IN 1.60
// var ? m_szPlayerCustomMission; // REMOVED IN 1.60
// var ? version; // REMOVED IN 1.60
// system name  (not localized)
var config string m_szKeyWord;
// pointer to the extra mods list
var array<array> m_aExtraMods;
var config array<array> m_aReticuleList;
// ^ NEW IN 1.60
var config float m_fPriority;
var config int Version;
// ^ NEW IN 1.60
// name from dictionnary
var string m_szName;
var config string m_DefaultLightPawn;
// ^ NEW IN 1.60
var config string m_DefaultMediumPawn;
// ^ NEW IN 1.60
var config string m_DefaultHeavyPawn;
// ^ NEW IN 1.60
var config string m_DefaultPilotPawn;
// ^ NEW IN 1.60
var config string m_DefaultRainbowAI;
// ^ NEW IN 1.60
var config array<array> m_szGameTypes;
var config array<array> m_aExtraModInfo;
// ^ NEW IN 1.60
var config string m_szCreditsFile;
var config string m_szVideosRootDir;
var config string m_szBackgroundRootDir;
var config string m_HostageMgrToSpawn;
// ^ NEW IN 1.60
var config string m_GlobalHUDToSpawn;
// ^ NEW IN 1.60
var config string m_ConfigClass;
var config string m_szCampaignIniFile;
var string m_szModInfo;
var config int BuildVersion;
// ^ NEW IN 1.60
var config array<array> m_aDescriptionPackage;
var config string m_szMenuDefinesFile;
var config string m_szServerIni;
var config int MinorVersion;
// ^ NEW IN 1.60
var config string m_szUserIni;
// ^ NEW IN 1.60
//If the mod has his own karmadata.
var config bool m_bUseMyKarma;
var config bool m_bUseCustomOperatives;
// ^ NEW IN 1.60
var config string m_PlayerCtrlToSpawn;
var config array<array> m_ALocFile;
var config array<array> m_aExtraPaths;

// --- Functions ---
function AddGameTypesFromCurrentMod(LevelInfo pLevelInfo) {}
function R6Mod GetExtraMods(int Index) {}
// ^ NEW IN 1.60
function LogArray(array<array> anArray, string S) {}
function Init(string szFile) {}
function LogInfo() {}

defaultproperties
{
}
