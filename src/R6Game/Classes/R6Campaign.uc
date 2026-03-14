//=============================================================================
//  R6Campaign.uc : This class represents a single player campaign and the list of missions (maps)
//					included in it
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/02/18 * Created by Alexandre Dionne
//=============================================================================
class R6Campaign extends Object
    config;

// --- Variables ---
// file to load
var config array<array> missions;
// R6MissionDescription
var array<array> m_missions;
var string m_szCampaignFile;
// Array of Rookies to spawn when needed.
var config array<array> m_OperativeBackupClassName;
var config string LocalizationFile;
var config array<array> m_OperativeClassName;

// --- Functions ---
//------------------------------------------------------------------
// LogInfo
//
//------------------------------------------------------------------
function LogInfo() {}
//------------------------------------------------------------------
// Ini: init the campaign, load all the mission description
//	   aLevel: needed for getting r6gametype
//    console: needed to access the array of mission descriptions
// szFileName: campaign file name
//------------------------------------------------------------------
function InitCampaign(R6Console Console, string szFileName, LevelInfo aLevel) {}

defaultproperties
{
}
