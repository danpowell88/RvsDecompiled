//=============================================================================
//  R6MissionDescription.uc : This class contains descriptions
//								of a specific mission, do a LoadConfig("..\maps\"$m_MapName)
//                              after you do a new on an object of this class        
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/02/18 * Created by Alexandre Dionne
//=============================================================================
class R6MissionDescription extends Object
    native
    config;

// --- Constants ---
const C_iR6MissionDescriptionVersion =  3;

// --- Structs ---
struct GameTypeSkin
{
    var string package;
    var string type;
    var string greenPackage;
    var string green;
    var string redPackage;
    var string red;
};

struct GameTypeMaxPlayer
{
    var string package;
    var string type;
    var int    maxNb;
};

// --- Variables ---
// var ? green; // REMOVED IN 1.60
// var ? greenPackage; // REMOVED IN 1.60
// var ? maxNb; // REMOVED IN 1.60
// var ? package; // REMOVED IN 1.60
// var ? red; // REMOVED IN 1.60
// var ? redPackage; // REMOVED IN 1.60
// var ? type; // REMOVED IN 1.60
// var ? version; // REMOVED IN 1.60
var config array<array> SkinsPerGameTypes;
var config array<array> GameTypes;
// this var tring is always in upper case
var string m_missionIniFile;
var array<array> m_szGameTypes;
var config string mod;
var config string m_MapName;
var config int Version;
// ^ NEW IN 1.60
var config Region m_RMissionOverview;
var config Region m_RWorldMap;
var config string LocalizationFile;
var config string m_AudioBankName;
//This array should contain the list of the classes
var config array<array> m_MissionArmorTypes;
// true if locked
var bool m_bIsLocked;
// true if used in a campaign
var bool m_bCampaignMission;
//World map showing mission Location
var config Texture m_TWorldMap;
//This is for the campaign select menu
var config Texture m_TMissionOverview;
var config Sound m_PlayEventSweeney;
var config Sound m_PlayEventClark;
var config Sound m_PlayEventControl;
var config string m_ShortName;
var config string m_InGameVoiceClarkBankName;
var config Sound m_PlayMissionIntro;
var config Sound m_PlayMissionExtro;

// --- Functions ---
//------------------------------------------------------------------
// IsAvailableInGameType
//
//------------------------------------------------------------------
function bool IsAvailableInGameType(string szGameType) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// GetMaxNbPlayers
//
//------------------------------------------------------------------
function int GetMaxNbPlayers(string szGameType) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// Init
//
//------------------------------------------------------------------
event bool Init(LevelInfo aLevel, string szMissionFile) {}
// ^ NEW IN 1.60
function SetSkins(string RedSkinClass, string GreenSkinClass, string szGameTypeClass) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// LogInfo
//
//------------------------------------------------------------------
function LogInfo() {}
//------------------------------------------------------------------
// GetSkins
//
//------------------------------------------------------------------
event bool GetSkins(out LevelInfo aLevel, string szGameTypeClass) {}
// ^ NEW IN 1.60
event Reset() {}

defaultproperties
{
}
