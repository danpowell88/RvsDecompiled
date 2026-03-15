//=============================================================================
// R6Mod - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6Mod.uc : 
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//=============================================================================

// MPF a mod
class R6Mod extends Object
    native
    config;

const C_iR6ModVersion = 1;

struct ReticuleListElement
{
// NEW IN 1.60
	var string m_szReticuleId;
// NEW IN 1.60
	var string m_szReticuleClassName;
};

var config int Version;
// NEW IN 1.60
var config int MinorVersion;
// NEW IN 1.60
var config int BuildVersion;
var config bool m_bUseMyKarma;  // If the mod has his own karmadata.
// NEW IN 1.60
var config bool m_bUseCustomOperatives;
var config float m_fPriority;
// NEW IN 1.60
var config array<ReticuleListElement> m_aReticuleList;
var config array<string> m_ALocFile;
var config array<string> m_aExtraPaths;
var config array<string> m_aDescriptionPackage;
// NEW IN 1.60
var config array<string> m_aExtraModInfo;
var array<R6Mod> m_aExtraMods;  // pointer to the extra mods list
var config array<string> m_szGameTypes;
var config string m_szKeyWord;  // system name  (not localized)
var string m_szName;  // name from dictionnary
var string m_szModInfo;
var config string m_szCampaignIniFile;
var config string m_szServerIni;
// NEW IN 1.60
var config string m_szUserIni;
var config string m_ConfigClass;
var config string m_PlayerCtrlToSpawn;
// NEW IN 1.60
var config string m_GlobalHUDToSpawn;
// NEW IN 1.60
var config string m_DefaultLightPawn;
// NEW IN 1.60
var config string m_DefaultMediumPawn;
// NEW IN 1.60
var config string m_DefaultHeavyPawn;
// NEW IN 1.60
var config string m_DefaultPilotPawn;
// NEW IN 1.60
var config string m_DefaultRainbowAI;
// NEW IN 1.60
var config string m_HostageMgrToSpawn;
var config string m_szBackgroundRootDir;
var config string m_szVideosRootDir;
var config string m_szCreditsFile;
var config string m_szMenuDefinesFile;

function Init(string szFile)
{
	local R6ModMgr pModManager;
	local R6Mod ProperMod;

	LoadConfig(("..\\Mods\\" $ szFile));
	// End:0x69
	if((((Version != 1) || (Version == 0)) || (m_szKeyWord == "")))
	{
		Log(("WARNING: problem initializing mod " $ szFile));
		return;
	}
	// End:0x81
	if((m_fPriority == float(0)))
	{
		m_fPriority = 2.0000000;
	}
	pModManager = Class'Engine.Actor'.static.GetModMgr();
	ProperMod = pModManager.m_pCurrentMod;
	pModManager.m_pCurrentMod = self;
	pModManager.SetSystemMod();
	m_szName = Localize(m_szKeyWord, "ModName", "R6Mod", true);
	m_szModInfo = Localize(m_szKeyWord, "ModInfo", "R6Mod", true);
	// End:0x119
	if((Len(m_szKeyWord) > 20))
	{
		assert(false);
	}
	// End:0x144
	if((ProperMod != none))
	{
		pModManager.m_pCurrentMod = ProperMod;
		pModManager.SetSystemMod();
	}
	return;
}

function LogArray(string S, array<string> anArray)
{
	local int i;

	Log((S $ ":"));
	i = 0;
	J0x13:

	// End:0x42 [Loop If]
	if((i < anArray.Length))
	{
		Log(("   -" $ anArray[i]));
		(++i);
		// [Loop Continue]
		goto J0x13;
	}
	return;
}

function R6Mod GetExtraMods(int Index)
{
	// End:0x1F
	if((Index < m_aExtraMods.Length))
	{
		return m_aExtraMods[Index];		
	}
	else
	{
		return none;
	}
	return;
}

function AddGameTypesFromCurrentMod(LevelInfo pLevelInfo)
{
	local Class<R6ModConfig> pConfigClass;
	local R6ModConfig pModConfig;

	// End:0x4A
	if((m_ConfigClass != ""))
	{
		pConfigClass = Class<R6ModConfig>(DynamicLoadObject(m_ConfigClass, Class'Core.Class'));
		pModConfig = new (self) pConfigClass;
		pModConfig.AddModSpecificGameModes(pLevelInfo);
	}
	return;
}

function LogInfo()
{
	Log("");
	Log(" R6Mod Information");
	Log(" =================");
	Log(("	m_szKeyWord = " $ m_szKeyWord));
	Log(("  version= " $ string(Version)));
	Log(("  m_fPriority=" $ string(m_fPriority)));
	Log(("  m_szName= " $ m_szName));
	Log(("  m_szModInfo=" $ m_szModInfo));
	Log(("  m_szCampaignIniFile=" $ m_szCampaignIniFile));
	Log(("  m_szBackgroundRootDir=" $ m_szBackgroundRootDir));
	Log(("  m_szVideosRootDir=" $ m_szVideosRootDir));
	Log(("  m_szCreditsFile= " $ m_szCreditsFile));
	Log("");
	Log("Localization Files:");
	Log("===================");
	Log("");
	Log(" Description Packages");
	Log(" ====================");
	LogArray("	 m_aDescriptionPackage", m_aDescriptionPackage);
	return;
}


// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var m_bInstalled
// REMOVED IN 1.60: var m_szGameServiceGameName
// REMOVED IN 1.60: var m_szCampaignDir
// REMOVED IN 1.60: var m_szPlayerCustomMission
// REMOVED IN 1.60: var m_aExtraModMaps
// REMOVED IN 1.60: var m_szIniFilesDir
