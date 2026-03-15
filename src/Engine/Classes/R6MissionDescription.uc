//=============================================================================
// R6MissionDescription - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
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

const C_iR6MissionDescriptionVersion = 3;

struct GameTypeMaxPlayer
{
	var string Package;
	var string type;
	var int maxNb;
};

struct GameTypeSkin
{
	var string Package;
	var string type;
	var string greenPackage;
	var string Green;
	var string redPackage;
	var string Red;
};

var config int Version;
var bool m_bCampaignMission;  // true if used in a campaign
var bool m_bIsLocked;  // true if locked
var config Sound m_PlayEventControl;
var config Sound m_PlayEventClark;
var config Sound m_PlayEventSweeney;
var config Sound m_PlayMissionIntro;
var config Sound m_PlayMissionExtro;
var config Texture m_TMissionOverview;  // This is for the campaign select menu
var config Texture m_TWorldMap;  // World map showing mission Location
var config array<GameTypeMaxPlayer> GameTypes;
var array<string> m_szGameTypes;
var config array< Class > m_MissionArmorTypes;  // This array should contain the list of the classes
var config array<GameTypeSkin> SkinsPerGameTypes;
var config Region m_RMissionOverview;
var config Region m_RWorldMap;
var string m_missionIniFile;  // this var tring is always in upper case
var config string m_MapName;
var config string m_ShortName;
var config string mod;
var config string LocalizationFile;
var config string m_AudioBankName;
var config string m_InGameVoiceClarkBankName;

event Reset()
{
	m_missionIniFile = "";
	m_MapName = "";
	Version = 0;
	GameTypes.Remove(0, GameTypes.Length);
	SkinsPerGameTypes.Remove(0, SkinsPerGameTypes.Length);
	m_szGameTypes.Remove(0, m_szGameTypes.Length);
	LocalizationFile = "";
	m_AudioBankName = "";
	m_bCampaignMission = false;
	m_bIsLocked = default.m_bIsLocked;
	return;
}

//------------------------------------------------------------------
// Init
//	
//------------------------------------------------------------------
event bool Init(LevelInfo aLevel, string szMissionFile)
{
	local int i;
	local string szIniFile, szClassName;

	m_missionIniFile = Caps(szMissionFile);
	LoadConfig(szMissionFile);
	// End:0x30
	if(((Version == 0) || (m_MapName == "")))
	{
		return false;
	}
	szIniFile = (m_MapName $ ".ini");
	szIniFile = Caps(szIniFile);
	// End:0xDD
	if((InStr(m_missionIniFile, szIniFile) < 0))
	{
		Log(((((("WARNING: R6MissionDescription m_missionIniFile (", m_missionIniFile) $ ") != m_MapName (") $ szIniFile) $ ") - " $ ???) $ string(InStr(m_missionIniFile, szIniFile))));
		m_MapName = "";
		return false;		
	}
	else
	{
		m_missionIniFile = szIniFile;
	}
	// End:0xF5
	if((aLevel == none))
	{
		return false;
	}
	i = 0;
	J0xFC:

	// End:0x163 [Loop If]
	if((i < GameTypes.Length))
	{
		szClassName = ((GameTypes[i].Package $ ".") $ GameTypes[i].type);
		m_szGameTypes[i] = aLevel.GetGameTypeFromClassName(szClassName);
		(++i);
		// [Loop Continue]
		goto J0xFC;
	}
	// End:0x190
	if(((Version <= 2) || (mod == "")))
	{
		mod = "RavenShield";
	}
	return true;
	return;
}

//------------------------------------------------------------------
// GetSkins
//	
//------------------------------------------------------------------
event bool GetSkins(out LevelInfo aLevel, string szGameTypeClass)
{
	local int i;
	local string szGameMode, szClassName;
	local Class<Pawn> TempGreenClass, TempRedClass;

	i = 0;
	J0x07:

	// End:0x448 [Loop If]
	if((i < SkinsPerGameTypes.Length))
	{
		szClassName = ((SkinsPerGameTypes[i].Package $ ".") $ SkinsPerGameTypes[i].type);
		// End:0x43E
		if((szGameTypeClass ~= szClassName))
		{
			// End:0xA3
			if(((SkinsPerGameTypes[i].greenPackage ~= "none") || (SkinsPerGameTypes[i].Green ~= "none")))
			{
				aLevel.GreenTeamPawnClass = "none";				
			}
			else
			{
				aLevel.GreenTeamPawnClass = ((SkinsPerGameTypes[i].greenPackage $ ".") $ SkinsPerGameTypes[i].Green);
			}
			// End:0x129
			if(((SkinsPerGameTypes[i].redPackage ~= "none") && (SkinsPerGameTypes[i].Red ~= "none")))
			{
				aLevel.RedTeamPawnClass = "none";				
			}
			else
			{
				aLevel.RedTeamPawnClass = ((SkinsPerGameTypes[i].redPackage $ ".") $ SkinsPerGameTypes[i].Red);
			}
			// End:0x43C
			if((int(aLevel.NetMode) != int(NM_Client)))
			{
				// End:0x1B5
				if((aLevel.GreenTeamPawnClass != "none"))
				{
					TempGreenClass = Class<Pawn>(DynamicLoadObject(aLevel.GreenTeamPawnClass, Class'Core.Class'));
				}
				// End:0x2DA
				if((TempGreenClass != none))
				{
					aLevel.GreenTeamSkin = TempGreenClass.default.Skins[0];
					aLevel.GreenHeadSkin = TempGreenClass.default.Skins[1];
					aLevel.GreenGogglesSkin = TempGreenClass.default.Skins[2];
					aLevel.GreenHandSkin = TempGreenClass.default.Skins[5];
					aLevel.GreenMesh = TempGreenClass.default.Mesh;
					aLevel.GreenHelmet = TempGreenClass.default.m_HelmetClass;
					// End:0x2DA
					if((aLevel.GreenHelmet != none))
					{
						aLevel.GreenHelmetMesh = aLevel.GreenHelmet.default.StaticMesh;
						aLevel.GreenHelmetSkin = aLevel.GreenHelmet.default.Skins[0];
					}
				}
				// End:0x317
				if((aLevel.RedTeamPawnClass != "none"))
				{
					TempRedClass = Class<Pawn>(DynamicLoadObject(aLevel.RedTeamPawnClass, Class'Core.Class'));
				}
				// End:0x43C
				if((TempRedClass != none))
				{
					aLevel.RedTeamSkin = TempRedClass.default.Skins[0];
					aLevel.RedHeadSkin = TempRedClass.default.Skins[1];
					aLevel.RedGogglesSkin = TempRedClass.default.Skins[2];
					aLevel.RedHandSkin = TempRedClass.default.Skins[5];
					aLevel.RedMesh = TempRedClass.default.Mesh;
					aLevel.RedHelmet = TempRedClass.default.m_HelmetClass;
					// End:0x43C
					if((aLevel.RedHelmet != none))
					{
						aLevel.RedHelmetMesh = aLevel.RedHelmet.default.StaticMesh;
						aLevel.RedHelmetSkin = aLevel.RedHelmet.default.Skins[0];
					}
				}
			}
			return true;
		}
		(++i);
		// [Loop Continue]
		goto J0x07;
	}
	return false;
	return;
}

// NEW IN 1.60
function SetSkins(string szGameTypeClass, string GreenSkinClass, string RedSkinClass)
{
	local int i;
	local string szClassName, szSkinPackage, szSkinClass, szMapDir;

	i = 0;
	J0x07:

	// End:0x190 [Loop If]
	if((i < SkinsPerGameTypes.Length))
	{
		szClassName = ((SkinsPerGameTypes[i].Package $ ".") $ SkinsPerGameTypes[i].type);
		// End:0x186
		if((szGameTypeClass ~= szClassName))
		{
			SkinsPerGameTypes[i].greenPackage = Left(GreenSkinClass, InStr(GreenSkinClass, "."));
			SkinsPerGameTypes[i].Green = Mid(GreenSkinClass, (InStr(GreenSkinClass, ".") + 1));
			// End:0xD7
			if((RedSkinClass ~= ""))
			{
				SkinsPerGameTypes[i].redPackage = "None";
				SkinsPerGameTypes[i].Red = "None";				
			}
			else
			{
				SkinsPerGameTypes[i].redPackage = Left(RedSkinClass, InStr(RedSkinClass, "."));
				SkinsPerGameTypes[i].Red = Mid(RedSkinClass, (InStr(RedSkinClass, ".") + 1));
			}
			// End:0x156
			if(((mod ~= "") || (mod ~= "RavenShield")))
			{
				szMapDir = "..\\maps\\";				
			}
			else
			{
				szMapDir = (("..\\mods\\" $ mod) $ "\\maps\\");
			}
			SaveConfig((szMapDir $ m_missionIniFile));
		}
		(i++);
		// [Loop Continue]
		goto J0x07;
	}
	return;
}

//------------------------------------------------------------------
// LogInfo
//	
//------------------------------------------------------------------
function LogInfo()
{
	local int i;
	local string szClassName, szGreen, szRed;
	local Class<Pawn> RedPawnClass, GreenPawnClass;

	Log(((((((("MissionDescription " $ m_missionIniFile) $ " mapName=") $ m_MapName) $ " localizationFile=") $ LocalizationFile) $ " version=") $ string(Version)));
	Log((" mod                    =" $ mod));
	Log((" m_TMissionOverview     =" $ string(m_TMissionOverview)));
	Log((((((((" m_RMissionOverview     =" $ string(m_RMissionOverview.X)) $ ") $ string(m_RMissionOverview.Y)) $ ") $ string(m_RMissionOverview.W)) $ ") $ string(m_RMissionOverview.H)));
	Log((" m_TWorldMap            =" $ string(m_TWorldMap)));
	Log((((((((" m_RWorldMap            =" $ string(m_RWorldMap.X)) $ ") $ string(m_RWorldMap.Y)) $ ") $ string(m_RWorldMap.W)) $ ") $ string(m_RWorldMap.H)));
	Log((" m_AudioBankName        =" $ m_AudioBankName));
	Log((" m_PlayEventControl     =" $ string(m_PlayEventControl)));
	Log((" m_PlayEventClark       =" $ string(m_PlayEventClark)));
	Log((" m_PlayEventSweeney     =" $ string(m_PlayEventSweeney)));
	i = 0;
	J0x23A:

	// End:0x28A [Loop If]
	if((i < m_MissionArmorTypes.Length))
	{
		Log((((" m_MissionArmorTypes " $ string(i)) $ "=") $ string(m_MissionArmorTypes[i])));
		(++i);
		// [Loop Continue]
		goto J0x23A;
	}
	i = 0;
	J0x291:

	// End:0x32E [Loop If]
	if((i < GameTypes.Length))
	{
		Log((((((((((" GameTypes " $ string(i)) $ "=") $ GameTypes[i].Package) $ ".") $ GameTypes[i].type) $ " ID=") $ m_szGameTypes[i]) $ " max nb players=") $ string(GameTypes[i].maxNb)));
		(++i);
		// [Loop Continue]
		goto J0x291;
	}
	i = 0;
	J0x335:

	// End:0x425 [Loop If]
	if((i < SkinsPerGameTypes.Length))
	{
		szClassName = ((SkinsPerGameTypes[i].Package $ ".") $ SkinsPerGameTypes[i].type);
		szGreen = ((SkinsPerGameTypes[i].greenPackage $ ".") $ SkinsPerGameTypes[i].Green);
		szRed = ((SkinsPerGameTypes[i].redPackage $ ".") $ SkinsPerGameTypes[i].Red);
		Log((((((((" SkinsPerGameTypes " $ string(i)) $ "- ") $ szClassName) $ " green=") $ szGreen) $ " red=") $ szRed));
		(++i);
		// [Loop Continue]
		goto J0x335;
	}
	return;
}

//------------------------------------------------------------------
// IsAvailableInGameType
//	
//------------------------------------------------------------------
function bool IsAvailableInGameType(string szGameType)
{
	local int i;

	J0x00:
	// End:0x31 [Loop If]
	if((i < m_szGameTypes.Length))
	{
		// End:0x27
		if((m_szGameTypes[i] == szGameType))
		{
			return true;
		}
		(++i);
		// [Loop Continue]
		goto J0x00;
	}
	return false;
	return;
}

//------------------------------------------------------------------
// GetMaxNbPlayers
//	
//------------------------------------------------------------------
function int GetMaxNbPlayers(string szGameType)
{
	local int i;

	J0x00:
	// End:0x40 [Loop If]
	if((i < m_szGameTypes.Length))
	{
		// End:0x36
		if((m_szGameTypes[i] == szGameType))
		{
			return GameTypes[i].maxNb;
		}
		(++i);
		// [Loop Continue]
		goto J0x00;
	}
	return 0;
	return;
}

defaultproperties
{
	m_MissionArmorTypes[0]=none
}
