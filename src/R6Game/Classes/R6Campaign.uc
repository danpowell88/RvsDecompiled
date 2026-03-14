//=============================================================================
// R6Campaign - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
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
	__NFUN_1010__(__NFUN_112__(Class'Engine.Actor'.static.__NFUN_1524__().GetCampaignMapDir(szFileName), m_szCampaignFile));
	Console.GetAllMissionDescriptions(Class'Engine.Actor'.static.__NFUN_1524__().GetCampaignMapDir(szFileName));
	i = 0;
	iMission = 0;
	J0x68:

	// End:0x1E5 [Loop If]
	if(__NFUN_150__(i, missions.Length))
	{
		missions[i] = __NFUN_235__(missions[i]);
		szIniFile = __NFUN_112__(missions[i], ".INI");
		bFound = false;
		j = 0;
		J0xB9:

		// End:0x188 [Loop If]
		if(__NFUN_150__(j, Console.m_aMissionDescriptions.Length))
		{
			// End:0x17E
			if(__NFUN_122__(Console.m_aMissionDescriptions[j].m_missionIniFile, szIniFile))
			{
				m_missions[iMission] = Console.m_aMissionDescriptions[j];
				m_missions[iMission].m_bCampaignMission = true;
				// End:0x155
				if(__NFUN_154__(iMission, 0))
				{
					m_missions[iMission].m_bIsLocked = false;					
				}
				else
				{
					m_missions[iMission].m_bIsLocked = true;
				}
				__NFUN_165__(iMission);
				bFound = true;
				// [Explicit Break]
				goto J0x188;
			}
			__NFUN_165__(j);
			// [Loop Continue]
			goto J0xB9;
		}
		J0x188:

		// End:0x1DB
		if(__NFUN_129__(bFound))
		{
			__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__("Warning: missing mission description ", szIniFile), " in campaign "), szFileName));
		}
		__NFUN_165__(i);
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

	__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__("CAMPAIGN name=", m_szCampaignFile), " localizationFile="), LocalizationFile));
	__NFUN_231__("===========================================================");
	__NFUN_231__(" List mission (.ini files)");
	J0x93:

	// End:0xD6 [Loop If]
	if(__NFUN_150__(i, missions.Length))
	{
		__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__("  Mission ", string(i)), " "), missions[i]));
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x93;
	}
	__NFUN_231__(" List operative");
	i = 0;
	__NFUN_231__("  List backup operative");
	i = 0;
	J0x112:

	// End:0x150 [Loop If]
	if(__NFUN_150__(i, m_OperativeBackupClassName.Length))
	{
		__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__("  bk ", string(i)), " "), m_OperativeBackupClassName[i]));
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x112;
	}
	return;
}

