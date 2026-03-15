//=============================================================================
// R6Campaign - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6Campaign.uc : This class represents a single player campaign and the list of missions (maps)
//					included in it
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/02/18 * Created by Alexandre Dionne
//=============================================================================
class R6Campaign extends Object
    config;

var config array<string> missions;  // file to load
var array<R6MissionDescription> m_missions;  // R6MissionDescription
var config array<string> m_OperativeClassName;
var config array<string> m_OperativeBackupClassName;  // Array of Rookies to spawn when needed.
var string m_szCampaignFile;
var config string LocalizationFile;

//------------------------------------------------------------------
// Ini: init the campaign, load all the mission description
//	   aLevel: needed for getting r6gametype
//    console: needed to access the array of mission descriptions
// szFileName: campaign file name
//------------------------------------------------------------------
function InitCampaign(LevelInfo aLevel, string szFileName, R6Console Console)
{
	local int i, j, iMission;
	local string szIniFile;
	local bool bFound;

	m_szCampaignFile = szFileName;
	LoadConfig((Class'Engine.Actor'.static.GetModMgr().GetCampaignMapDir(szFileName) $ m_szCampaignFile));
	Console.GetAllMissionDescriptions(Class'Engine.Actor'.static.GetModMgr().GetCampaignMapDir(szFileName));
	i = 0;
	iMission = 0;
	J0x68:

	// End:0x1E5 [Loop If]
	if((i < missions.Length))
	{
		missions[i] = Caps(missions[i]);
		szIniFile = (missions[i] $ ".INI");
		bFound = false;
		j = 0;
		J0xB9:

		// End:0x188 [Loop If]
		if((j < Console.m_aMissionDescriptions.Length))
		{
			// End:0x17E
			if((Console.m_aMissionDescriptions[j].m_missionIniFile == szIniFile))
			{
				m_missions[iMission] = Console.m_aMissionDescriptions[j];
				m_missions[iMission].m_bCampaignMission = true;
				// End:0x155
				if((iMission == 0))
				{
					m_missions[iMission].m_bIsLocked = false;					
				}
				else
				{
					m_missions[iMission].m_bIsLocked = true;
				}
				(iMission++);
				bFound = true;
				// [Explicit Break]
				goto J0x188;
			}
			(j++);
			// [Loop Continue]
			goto J0xB9;
		}
		J0x188:

		// End:0x1DB
		if((!bFound))
		{
			Log(((("Warning: missing mission description " $ szIniFile) $ " in campaign ") $ szFileName));
		}
		(i++);
		// [Loop Continue]
		goto J0x68;
	}
	Console.UnlockMissions();
	return;
}

//------------------------------------------------------------------
// LogInfo
//	
//------------------------------------------------------------------
function LogInfo()
{
	local int i;

	Log(((("CAMPAIGN name=" $ m_szCampaignFile) $ " localizationFile=") $ LocalizationFile));
	Log("===========================================================");
	Log(" List mission (.ini files)");
	J0x93:

	// End:0xD6 [Loop If]
	if((i < missions.Length))
	{
		Log(((("  Mission " $ string(i)) $ " ") $ missions[i]));
		(i++);
		// [Loop Continue]
		goto J0x93;
	}
	Log(" List operative");
	i = 0;
	Log("  List backup operative");
	i = 0;
	J0x112:

	// End:0x150 [Loop If]
	if((i < m_OperativeBackupClassName.Length))
	{
		Log(((("  bk " $ string(i)) $ " ") $ m_OperativeBackupClassName[i]));
		(i++);
		// [Loop Continue]
		goto J0x112;
	}
	return;
}

