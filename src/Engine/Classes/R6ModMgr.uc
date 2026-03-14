//=============================================================================
// R6ModMgr - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6ModMgr.uc : 
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//=============================================================================

// new MPF
class R6ModMgr extends Object
    native;

var bool bShowLog;
var R6UPackageMgr m_pUPackageMgr;
var R6Mod m_pCurrentMod;
var R6Mod m_pRVS;
var array<R6Mod> m_aMods;
var array<string> m_aGameTypeCorrTable;  // the game type corresponding table (compatibility with code before/after sdk)
var string m_szPendingModName;  // used when the server is started by Ubi.com

// Export UR6ModMgr::execAddNewModExtraPath(FFrame&, void* const)
native(2020) final function AddNewModExtraPath(R6Mod pMod, int iResetPaths);

// Export UR6ModMgr::execSetSystemMod(FFrame&, void* const)
native(2021) final function SetSystemMod();

// Export UR6ModMgr::execSetGeneralModSettings(FFrame&, void* const)
// NEW IN 1.60
native(2022) final function SetGeneralModSettings(R6Mod pMod);

// Export UR6ModMgr::execIsOfficialMod(FFrame&, void* const)
// NEW IN 1.60
native(2023) final function bool IsOfficialMod(string _szName);

// Export UR6ModMgr::execGetASBuildVersion(FFrame&, void* const)
// NEW IN 1.60
native(2024) final function int GetASBuildVersion();

// Export UR6ModMgr::execGetIWBuildVersion(FFrame&, void* const)
// NEW IN 1.60
native(2025) final function int GetIWBuildVersion();

// Export UR6ModMgr::execCallSndEngineInit(FFrame&, void* const)
native(3003) final function CallSndEngineInit(Level pLevel);

event int GetNbMods()
{
	return m_aMods.Length;
	return;
}

event bool IsMissionPack()
{
	return __NFUN_129__(IsRavenShield());
	return;
}

event bool IsRavenShield()
{
	return __NFUN_114__(m_pCurrentMod, m_pRVS);
	return;
}

// NEW IN 1.60
function bool CheckValidModVersion(R6Mod pModToCheck)
{
	local bool bReturnValue;

	bReturnValue = true;
	// End:0x45
	if(__NFUN_124__(pModToCheck.m_szKeyWord, "AthenaSword"))
	{
		bReturnValue = __NFUN_154__(__NFUN_2024__(), pModToCheck.BuildVersion);		
	}
	else
	{
		// End:0x7D
		if(__NFUN_124__(pModToCheck.m_szKeyWord, "IronWrath"))
		{
			bReturnValue = __NFUN_154__(__NFUN_2025__(), pModToCheck.BuildVersion);
		}
	}
	return bReturnValue;
	return;
}

///////////////////////////////////////////////////////////
// Init Mod,create the package manager
// fill the aMod array and load the mod's ini
event InitModMgr()
{
	local R6FileManager pFileManager;
	local int i, j, jMove, iFiles;
	local string szIniFilename;
	local R6Mod aMod;
	local bool bNotFound;
	local array<string> ModsList;

	ModsList[ModsList.Length] = "RAVENSHIELD.MOD";
	ModsList[ModsList.Length] = "IRONWRATH.MOD";
	ModsList[ModsList.Length] = "ATHENASWORD.MOD";
	pFileManager = new (none) Class'Engine.R6FileManager';
	m_pUPackageMgr = new (none) Class'Engine.R6UPackageMgr';
	m_pUPackageMgr.InitOperativeClassesMgr();
	iFiles = pFileManager.__NFUN_1525__("..\\Mods\\", "mod");
	i = 0;
	J0xAD:

	// End:0x1FD [Loop If]
	if(__NFUN_150__(i, iFiles))
	{
		pFileManager.__NFUN_1526__(i, szIniFilename);
		// End:0xE1
		if(__NFUN_122__(szIniFilename, ""))
		{
			// [Explicit Continue]
			goto J0x1F3;
		}
		bNotFound = true;
		j = 0;
		J0xF0:

		// End:0x129 [Loop If]
		if(__NFUN_150__(j, ModsList.Length))
		{
			// End:0x11F
			if(__NFUN_122__(ModsList[j], __NFUN_235__(szIniFilename)))
			{
				bNotFound = false;
			}
			__NFUN_165__(j);
			// [Loop Continue]
			goto J0xF0;
		}
		// End:0x135
		if(bNotFound)
		{
			// [Explicit Continue]
			goto J0x1F3;
		}
		aMod = new (none) Class'Engine.R6Mod';
		aMod.Init(szIniFilename);
		j = 0;
		J0x15F:

		// End:0x1A3 [Loop If]
		if(__NFUN_150__(j, m_aMods.Length))
		{
			// End:0x199
			if(__NFUN_176__(aMod.m_fPriority, m_aMods[j].m_fPriority))
			{
				// [Explicit Break]
				goto J0x1A3;
			}
			__NFUN_165__(j);
			// [Loop Continue]
			goto J0x15F;
		}
		J0x1A3:

		jMove = m_aMods.Length;
		J0x1AF:

		// End:0x1E2 [Loop If]
		if(__NFUN_155__(jMove, j))
		{
			m_aMods[jMove] = m_aMods[__NFUN_147__(jMove, 1)];
			__NFUN_166__(jMove);
			// [Loop Continue]
			goto J0x1AF;
		}
		m_aMods[j] = aMod;
		J0x1F3:

		__NFUN_165__(i);
		// [Loop Continue]
		goto J0xAD;
	}
	i = 0;
	J0x204:

	// End:0x22F [Loop If]
	if(__NFUN_150__(i, m_aMods.Length))
	{
		FindExtraMods(m_aMods[i]);
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x204;
	}
	m_pRVS = GetModInstance("RavenShield");
	FillCorrepondanceTable();
	return;
}

function FindExtraMods(R6Mod pCurrentMod)
{
	local int i, j;

	i = 0;
	J0x07:

	// End:0xA2 [Loop If]
	if(__NFUN_150__(i, pCurrentMod.m_aExtraModInfo.Length))
	{
		j = 0;
		J0x27:

		// End:0x98 [Loop If]
		if(__NFUN_150__(j, m_aMods.Length))
		{
			// End:0x8E
			if(__NFUN_124__(pCurrentMod.m_aExtraModInfo[i], m_aMods[j].m_szKeyWord))
			{
				pCurrentMod.m_aExtraMods[pCurrentMod.m_aExtraMods.Length] = m_aMods[j];
			}
			__NFUN_165__(j);
			// [Loop Continue]
			goto J0x27;
		}
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x07;
	}
	return;
}

function IsMapAvailable(string szKeyWord, Console pConsole)
{
	local int i;
	local string szMapDir;

	i = 0;
	J0x07:

	// End:0xB6 [Loop If]
	if(__NFUN_150__(i, m_aMods.Length))
	{
		// End:0xAC
		if(__NFUN_124__(m_aMods[i].m_szKeyWord, szKeyWord))
		{
			// End:0x5D
			if(__NFUN_114__(m_aMods[i], m_pRVS))
			{
				szMapDir = "..\\Maps\\";				
			}
			else
			{
				szMapDir = __NFUN_112__(__NFUN_112__("..\\mods\\", m_aMods[i].m_szKeyWord), "\\MAPS\\");
			}
			// End:0xAC
			if(__NFUN_119__(pConsole, none))
			{
				pConsole.GetAllMissionDescriptions(szMapDir);
			}
		}
		__NFUN_163__(i);
		// [Loop Continue]
		goto J0x07;
	}
	return;
}

function R6UPackageMgr GetPackageMgr()
{
	return m_pUPackageMgr;
	return;
}

function R6Mod GetModInstance(string szKeyWord)
{
	local int i;

	i = 0;
	J0x07:

	// End:0x4B [Loop If]
	if(__NFUN_150__(i, m_aMods.Length))
	{
		// End:0x41
		if(__NFUN_124__(m_aMods[i].m_szKeyWord, szKeyWord))
		{
			return m_aMods[i];
		}
		__NFUN_163__(i);
		// [Loop Continue]
		goto J0x07;
	}
	return none;
	return;
}

event SetCurrentMod(string szKeyWord, LevelInfo pLevelInfo, optional bool bInitSystem, optional Console pConsole, optional Level pLevel)
{
	local int i;
	local R6Mod pPreviousMod;

	pPreviousMod = m_pCurrentMod;
	m_pCurrentMod = m_pRVS;
	i = 0;
	J0x1D:

	// End:0x9C [Loop If]
	if(__NFUN_150__(i, m_aMods.Length))
	{
		// End:0x92
		if(__NFUN_130__(__NFUN_124__(m_aMods[i].m_szKeyWord, szKeyWord), CheckValidModVersion(m_aMods[i])))
		{
			// End:0x81
			if(bShowLog)
			{
				__NFUN_231__(__NFUN_112__("CurrentMod: ", szKeyWord));
			}
			m_pCurrentMod = m_aMods[i];
		}
		__NFUN_163__(i);
		// [Loop Continue]
		goto J0x1D;
	}
	// End:0x121
	if(__NFUN_119__(pPreviousMod, m_pCurrentMod))
	{
		__NFUN_3003__(pLevel);
		__NFUN_2020__(m_pCurrentMod, 1);
		i = 0;
		J0xC3:

		// End:0xFE [Loop If]
		if(__NFUN_150__(i, m_pCurrentMod.m_aExtraMods.Length))
		{
			__NFUN_2020__(m_pCurrentMod.m_aExtraMods[i], 0);
			__NFUN_165__(i);
			// [Loop Continue]
			goto J0xC3;
		}
		__NFUN_2021__();
		// End:0x121
		if(__NFUN_119__(pConsole, none))
		{
			pConsole.GetAllMissionDescriptions(GetMapsDir());
		}
	}
	__NFUN_2022__(m_pCurrentMod);
	// End:0x13F
	if(__NFUN_119__(pLevelInfo, none))
	{
		AddGameTypes(pLevelInfo);
	}
	return;
}

function AddGameTypes(LevelInfo pLevelInfo)
{
	local int i;

	pLevelInfo.m_aGameTypeInfo.Remove(0, pLevelInfo.m_aGameTypeInfo.Length);
	// End:0x5A
	if(__NFUN_130__(__NFUN_119__(m_pCurrentMod, m_pRVS), __NFUN_177__(m_pCurrentMod.m_fPriority, float(1))))
	{
		m_pRVS.AddGameTypesFromCurrentMod(pLevelInfo);
	}
	m_pCurrentMod.AddGameTypesFromCurrentMod(pLevelInfo);
	i = 0;
	J0x75:

	// End:0xBB [Loop If]
	if(__NFUN_150__(i, m_pCurrentMod.m_aExtraMods.Length))
	{
		m_pCurrentMod.m_aExtraMods[i].AddGameTypesFromCurrentMod(pLevelInfo);
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x75;
	}
	pLevelInfo.SetGameTypeStrings();
	return;
}

function bool IsGameTypeAvailable(string szGameType)
{
	local int i;

	i = 0;
	J0x07:

	// End:0x4A [Loop If]
	if(__NFUN_150__(i, m_pCurrentMod.m_szGameTypes.Length))
	{
		// End:0x40
		if(__NFUN_122__(szGameType, m_pCurrentMod.m_szGameTypes[i]))
		{
			return true;
		}
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x07;
	}
	return false;
	return;
}

event string GetBackgroundsRoot()
{
	return m_pCurrentMod.m_szBackgroundRootDir;
	return;
}

event string GetVideosRoot()
{
	return m_pCurrentMod.m_szVideosRootDir;
	return;
}

// NEW IN 1.60
event string GetDefaultCampaignDir()
{
	return "..\\save\\campaigns\\";
	return;
}

event string GetCampaignDir()
{
	// End:0x19
	if(__NFUN_114__(m_pCurrentMod, m_pRVS))
	{
		return GetDefaultCampaignDir();		
	}
	else
	{
		return __NFUN_112__(__NFUN_112__(GetDefaultCampaignDir(), m_pCurrentMod.m_szKeyWord), "\\");
	}
	return;
}

event string GetIniFilesDir()
{
	// End:0x1B
	if(__NFUN_114__(m_pCurrentMod, m_pRVS))
	{
		return "System";		
	}
	else
	{
		return __NFUN_112__(__NFUN_112__("mods\\", m_pCurrentMod.m_szKeyWord), "\\System");
	}
	return;
}

function string GetCampaignMapDir(string szIniCampaignName)
{
	local int i;

	i = 0;
	J0x07:

	// End:0x97 [Loop If]
	if(__NFUN_150__(i, m_aMods.Length))
	{
		// End:0x8D
		if(__NFUN_124__(m_aMods[i].m_szCampaignIniFile, szIniCampaignName))
		{
			// End:0x62
			if(__NFUN_124__(szIniCampaignName, "RavenshieldCampaign"))
			{
				return "..\\Maps\\";
				// [Explicit Continue]
				goto J0x8D;
			}
			return __NFUN_112__(__NFUN_112__("..\\mods\\", m_aMods[i].m_szKeyWord), "\\MAPS\\");
		}
		J0x8D:

		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x07;
	}
	return "";
	return;
}

event string GetMapsDir()
{
	// End:0x17
	if(IsRavenShield())
	{
		return "..\\Maps\\";		
	}
	else
	{
		return __NFUN_112__(__NFUN_112__("..\\mods\\", m_pCurrentMod.m_szKeyWord), "\\MAPS\\");
	}
	return;
}

function Class<HUD> GetDefaultHUD()
{
	// End:0x37
	if(__NFUN_123__(m_pCurrentMod.m_GlobalHUDToSpawn, ""))
	{
		return Class<HUD>(DynamicLoadObject(m_pCurrentMod.m_GlobalHUDToSpawn, Class'Core.Class'));		
	}
	else
	{
		return Class<HUD>(DynamicLoadObject("R6Game.R6HUD", Class'Core.Class'));
	}
	return;
}

function Class<Pawn> GetDefaultPilotPawn()
{
	local string CurrentPawnClassName;

	// End:0x2C
	if(__NFUN_123__(m_pCurrentMod.m_DefaultPilotPawn, ""))
	{
		CurrentPawnClassName = m_pCurrentMod.m_DefaultPilotPawn;		
	}
	else
	{
		CurrentPawnClassName = m_pRVS.m_DefaultPilotPawn;
	}
	return Class<Pawn>(DynamicLoadObject(CurrentPawnClassName, Class'Core.Class'));
	return;
}

function Class<Pawn> GetDefaultRainbowPawn(int Index)
{
	local string CurrentPawnClassName;

	// End:0x58
	if(__NFUN_132__(__NFUN_154__(Index, 0), __NFUN_154__(Index, 1)))
	{
		// End:0x44
		if(__NFUN_123__(m_pCurrentMod.m_DefaultLightPawn, ""))
		{
			CurrentPawnClassName = m_pCurrentMod.m_DefaultLightPawn;			
		}
		else
		{
			CurrentPawnClassName = m_pRVS.m_DefaultLightPawn;
		}
	}
	// End:0xA4
	if(__NFUN_154__(Index, 2))
	{
		// End:0x90
		if(__NFUN_123__(m_pCurrentMod.m_DefaultMediumPawn, ""))
		{
			CurrentPawnClassName = m_pCurrentMod.m_DefaultMediumPawn;			
		}
		else
		{
			CurrentPawnClassName = m_pRVS.m_DefaultMediumPawn;
		}
	}
	// End:0xF0
	if(__NFUN_154__(Index, 3))
	{
		// End:0xDC
		if(__NFUN_123__(m_pCurrentMod.m_DefaultHeavyPawn, ""))
		{
			CurrentPawnClassName = m_pCurrentMod.m_DefaultHeavyPawn;			
		}
		else
		{
			CurrentPawnClassName = m_pRVS.m_DefaultHeavyPawn;
		}
	}
	return Class<Pawn>(DynamicLoadObject(CurrentPawnClassName, Class'Core.Class'));
	return;
}

function Class<AIController> GetDefaultRainbowAI()
{
	// End:0x37
	if(__NFUN_123__(m_pCurrentMod.m_DefaultRainbowAI, ""))
	{
		return Class<AIController>(DynamicLoadObject(m_pCurrentMod.m_DefaultRainbowAI, Class'Core.Class'));		
	}
	else
	{
		return Class<AIController>(DynamicLoadObject(m_pRVS.m_DefaultRainbowAI, Class'Core.Class'));
	}
	return;
}

function string GetCreditsFile()
{
	return __NFUN_112__(__NFUN_112__(__NFUN_112__("..\\", GetIniFilesDir()), "\\"), m_pCurrentMod.m_szCreditsFile);
	return;
}

function string GetMenuDefFile()
{
	return __NFUN_112__(__NFUN_112__(__NFUN_112__("..\\", GetIniFilesDir()), "\\"), m_pCurrentMod.m_szMenuDefinesFile);
	return;
}

function Class<Actor> GetCurrentReticule(string ReticuleID)
{
	local string ReticuleClassName;
	local int i;

	// End:0x84
	if(__NFUN_155__(m_pCurrentMod.m_aReticuleList.Length, 0))
	{
		i = 0;
		J0x1C:

		// End:0x84 [Loop If]
		if(__NFUN_150__(i, m_pCurrentMod.m_aReticuleList.Length))
		{
			// End:0x7A
			if(__NFUN_122__(ReticuleID, m_pCurrentMod.m_aReticuleList[i].m_szReticuleId))
			{
				ReticuleClassName = m_pCurrentMod.m_aReticuleList[i].m_szReticuleClassName;
				// [Explicit Break]
				goto J0x84;
			}
			__NFUN_165__(i);
			// [Loop Continue]
			goto J0x1C;
		}
	}
	J0x84:

	// End:0xFC
	if(__NFUN_122__(ReticuleClassName, ""))
	{
		i = 0;
		J0x97:

		// End:0xFC [Loop If]
		if(__NFUN_150__(i, m_pRVS.m_aReticuleList.Length))
		{
			// End:0xF2
			if(__NFUN_122__(ReticuleID, m_pRVS.m_aReticuleList[i].m_szReticuleId))
			{
				ReticuleClassName = m_pRVS.m_aReticuleList[i].m_szReticuleClassName;
			}
			__NFUN_165__(i);
			// [Loop Continue]
			goto J0x97;
		}
	}
	return Class<Actor>(DynamicLoadObject(ReticuleClassName, Class'Core.Class'));
	return;
}

event string GetServerIni()
{
	return __NFUN_112__(__NFUN_112__(__NFUN_112__("..\\", GetIniFilesDir()), "\\"), m_pCurrentMod.m_szServerIni);
	return;
}

event string GetModKeyword()
{
	return m_pCurrentMod.m_szKeyWord;
	return;
}

event string GetModName()
{
	return m_pCurrentMod.m_szName;
	return;
}

//==================== COMPATIBILITY SECTION ===========================================================
// keep compatibilty with previous version until Ubi.com update their GSClient stuff
// THE ORDER IS IMPORTANT AND THE NAME TOO
function FillCorrepondanceTable()
{
	m_aGameTypeCorrTable[m_aGameTypeCorrTable.Length] = "RGM_AllMode";
	m_aGameTypeCorrTable[m_aGameTypeCorrTable.Length] = "RGM_StoryMode";
	m_aGameTypeCorrTable[m_aGameTypeCorrTable.Length] = "RGM_PracticeMode";
	m_aGameTypeCorrTable[m_aGameTypeCorrTable.Length] = "RGM_MissionMode";
	m_aGameTypeCorrTable[m_aGameTypeCorrTable.Length] = "RGM_TerroristHuntMode";
	m_aGameTypeCorrTable[m_aGameTypeCorrTable.Length] = "RGM_TerroristHuntCoopMode";
	m_aGameTypeCorrTable[m_aGameTypeCorrTable.Length] = "RGM_HostageRescueMode";
	m_aGameTypeCorrTable[m_aGameTypeCorrTable.Length] = "RGM_HostageRescueCoopMode";
	m_aGameTypeCorrTable[m_aGameTypeCorrTable.Length] = "RGM_HostageRescueAdvMode";
	m_aGameTypeCorrTable[m_aGameTypeCorrTable.Length] = "RGM_DefendMode";
	m_aGameTypeCorrTable[m_aGameTypeCorrTable.Length] = "RGM_DefendCoopMode";
	m_aGameTypeCorrTable[m_aGameTypeCorrTable.Length] = "RGM_ReconMode";
	m_aGameTypeCorrTable[m_aGameTypeCorrTable.Length] = "RGM_ReconCoopMode";
	m_aGameTypeCorrTable[m_aGameTypeCorrTable.Length] = "RGM_DeathmatchMode";
	m_aGameTypeCorrTable[m_aGameTypeCorrTable.Length] = "RGM_TeamDeathmatchMode";
	m_aGameTypeCorrTable[m_aGameTypeCorrTable.Length] = "RGM_BombAdvMode";
	m_aGameTypeCorrTable[m_aGameTypeCorrTable.Length] = "RGM_EscortAdvMode";
	m_aGameTypeCorrTable[m_aGameTypeCorrTable.Length] = "RGM_LoneWolfMode";
	m_aGameTypeCorrTable[m_aGameTypeCorrTable.Length] = "RGM_SquadDeathmatch";
	m_aGameTypeCorrTable[m_aGameTypeCorrTable.Length] = "RGM_SquadTeamDeathmatch";
	m_aGameTypeCorrTable[m_aGameTypeCorrTable.Length] = "RGM_TerroristHuntAdvMode";
	m_aGameTypeCorrTable[m_aGameTypeCorrTable.Length] = "RGM_ScatteredHuntAdvMode";
	m_aGameTypeCorrTable[m_aGameTypeCorrTable.Length] = "RGM_CaptureTheEnemyAdvMode";
	m_aGameTypeCorrTable[m_aGameTypeCorrTable.Length] = "RGM_CountDownMode";
	m_aGameTypeCorrTable[m_aGameTypeCorrTable.Length] = "RGM_KamikazeMode";
	m_aGameTypeCorrTable[m_aGameTypeCorrTable.Length] = "RGM_FreeBackupAdvMode";
	m_aGameTypeCorrTable[m_aGameTypeCorrTable.Length] = "RGM_GazAlertAdvMode";
	m_aGameTypeCorrTable[m_aGameTypeCorrTable.Length] = "RGM_IntruderAdvMode";
	m_aGameTypeCorrTable[m_aGameTypeCorrTable.Length] = "RGM_LimitSeatsAdvMode";
	m_aGameTypeCorrTable[m_aGameTypeCorrTable.Length] = "RGM_VirusUploadAdvMode";
	m_aGameTypeCorrTable[m_aGameTypeCorrTable.Length] = "RGM_NoRulesMode";
	return;
}

event int GetGameTypeIndex(string _szGameType)
{
	local int i;

	i = 0;
	J0x07:

	// End:0x3C [Loop If]
	if(__NFUN_150__(i, m_aGameTypeCorrTable.Length))
	{
		// End:0x32
		if(__NFUN_122__(_szGameType, m_aGameTypeCorrTable[i]))
		{
			return i;
		}
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x07;
	}
	return m_aGameTypeCorrTable.Length;
	return;
}

event string GetGameTypeName(int _iIndex)
{
	// End:0x88
	if(__NFUN_153__(_iIndex, m_aGameTypeCorrTable.Length))
	{
		__NFUN_231__(__NFUN_168__(__NFUN_168__(__NFUN_168__("GetGameTypeName() return RGM_NoRulesMode because iIndex ", string(_iIndex)), ">= nb of gametype "), string(m_aGameTypeCorrTable.Length)));
		return m_aGameTypeCorrTable[__NFUN_147__(m_aGameTypeCorrTable.Length, 1)];		
	}
	else
	{
		return m_aGameTypeCorrTable[_iIndex];
	}
	return;
}


// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var m_pMP1
// REMOVED IN 1.60: var m_pMP2
// REMOVED IN 1.60: var m_aObjects
// REMOVED IN 1.60: function InitAllModObjects
// REMOVED IN 1.60: function SetPendingMODFromGSName
// REMOVED IN 1.60: function GetPlayerCustomMission
// REMOVED IN 1.60: function isRegistered
// REMOVED IN 1.60: function RegisterObject
// REMOVED IN 1.60: function UnRegisterAllObject
// REMOVED IN 1.60: function UnRegisterObject
// REMOVED IN 1.60: function DebugRegisterObject
// REMOVED IN 1.60: function GetUbiComClientVersion
// REMOVED IN 1.60: function GetGameServiceGameName
